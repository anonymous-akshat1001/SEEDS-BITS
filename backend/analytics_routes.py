"""Authenticated read-only analytics and privacy-filtered client ingestion."""

import asyncio
import os
import math
from datetime import datetime, timedelta
from collections import defaultdict, deque
from time import monotonic

import httpx
from fastapi import APIRouter, Depends, HTTPException, Query, Request
from sqlalchemy import select, func, case, text
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

import auth
import models
from database import get_db, get_analytics_db
from activity_events import record_event, enabled
from analytics_schemas import QueryRequest, EventBatch, CLIENT_EVENTS
from analytics_service import catalog, execute
from logging_config import HEALTH
from model_client import interpret, local_url

router = APIRouter(tags=["Analytics"])
_inference = asyncio.Semaphore(1)
_limits = defaultdict(deque)


async def require_analytics(user=Depends(auth.get_current_user)):
    if os.getenv("ANALYTICS_ENABLED", "false").lower() != "true":
        raise HTTPException(503, "Analytics is not enabled.")
    if user.role not in {"admin", "teacher"}:
        raise HTTPException(403, "Administrator or teacher required.")
    return user


def rate_limit(user_id, category, maximum=30):
    now = monotonic()
    if len(_limits) >= 1000:
        for key in list(_limits):
            if not _limits[key] or _limits[key][-1] < now - 60:
                del _limits[key]
        if len(_limits) >= 1000:
            raise HTTPException(429, "Analytics is busy. Retry later.")
    queue = _limits[(user_id, category)]
    while queue and queue[0] < now - 60:
        queue.popleft()
    if len(queue) >= maximum:
        raise HTTPException(429, "Too many requests. Retry in one minute.")
    queue.append(now)


@router.get("/analytics/catalog")
async def get_catalog(
    kind: str = Query(pattern="^(teacher|student|class|subject|session)$"),
    search: str = Query(default="", max_length=160),
    page: int = Query(default=1, ge=1, le=1000),
    user=Depends(require_analytics), db: AsyncSession = Depends(get_analytics_db),
):
    return await catalog(db, user, kind, search, page)


@router.post("/analytics/query")
async def query(
    payload: QueryRequest, user=Depends(require_analytics),
    db: AsyncSession = Depends(get_analytics_db),
):
    rate_limit(user.user_id, "query")
    intent = payload.intent
    if intent is None:
        try:
            await asyncio.wait_for(_inference.acquire(), timeout=0.1)
        except asyncio.TimeoutError:
            raise HTTPException(429, "Local model is busy. Use structured filters or retry.") from None
        try:
            intent = await interpret(payload.question, payload.context)
        finally:
            _inference.release()
    result = await execute(db, user, intent)
    result["intent"] = intent.model_dump(mode="json")
    return result


@router.get("/analytics/health")
async def health(user=Depends(require_analytics), db: AsyncSession = Depends(get_analytics_db)):
    if user.role != "admin":
        raise HTTPException(403, "Administrator required.")
    await db.execute(select(models.User.user_id).limit(1))
    states = (await db.execute(select(models.MaintenanceState))).scalars().all()
    day = (func.date(models.Log.created_at + text("INTERVAL '5 hours 30 minutes'"))
           if db.bind.dialect.name == "postgresql"
           else func.date(models.Log.created_at, "+5 hours", "+30 minutes"))
    daily = (await db.execute(select(
        day.label("day"), func.count().label("requests"),
        func.sum(case((models.Log.event_details["status"].as_integer() >= 500, 1), else_=0)).label("errors"),
    ).where(
        models.Log.event_type == "http_request",
        models.Log.created_at > datetime.utcnow() - timedelta(days=30),
    ).group_by(day).order_by(day))).mappings().all()
    return {
        "database": "reachable", "diagnostics": dict(HEALTH),
        "collection_enabled": enabled(),
        "model_enabled": os.getenv("ANALYTICS_MODEL_ENABLED", "false") == "true",
        "runtime": os.getenv("LOCAL_MODEL_RUNTIME", "not_selected"),
        "speech_enabled": os.getenv("TRANSCRIPTION_ENABLED", "false") == "true",
        "smtp_configured": bool(os.getenv("ALERT_SMTP_HOST") and os.getenv("ALERT_EMAIL_TO")),
        "maintenance": [{"name": s.name, "status": s.status,
                         "succeeded_at": s.succeeded_at, "count": s.count} for s in states],
        "daily": [dict(row) for row in daily],
        "chart_coverage": "Last 30 days of persisted request observations.",
        "deployment_gates": ["Benchmark campus runtime/model and ASR",
                             "Verify read-only DB role, SMTP delivery and backup/erasure policy"],
    }


@router.post("/activity/events")
async def ingest(
    payload: EventBatch, user=Depends(auth.get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if not enabled() or os.getenv("CLIENT_TELEMETRY_ENABLED", "false") != "true":
        raise HTTPException(503, "Client telemetry is not enabled.")
    rate_limit(user.user_id, "events", 20)
    now = datetime.utcnow()
    result = {"accepted": [], "duplicates": [], "rejected": []}
    for event in payload.events:
        event_id = str(event.event_id)
        reason = None
        if event.event_type not in CLIENT_EVENTS:
            reason = "unsupported_event"
        elif not now - timedelta(days=30) < event.occurred_at <= now + timedelta(minutes=5):
            reason = "expired_or_invalid_clock"
        elif set(event.details) - {"position", "speed", "offline", "count", "reason_code"}:
            reason = "private_or_unknown_fields"
        elif any(not isinstance(v, (int, float, bool, str)) for v in event.details.values()):
            reason = "invalid_details"
        elif any(
            (key == "reason_code" and value not in {"network", "storage", "cancelled", "permission", "invalid", "unknown"})
            or (key == "offline" and type(value) is not bool)
            or (key not in {"reason_code", "offline"} and
                (type(value) not in {int, float} or not math.isfinite(value) or value < 0 or value > 1000000))
            for key, value in event.details.items()
        ):
            reason = "invalid_details"
        audio = None
        content_event = event.event_type.startswith(("learning_", "bookmark_", "download_"))
        if content_event:
            if event.resource_type != "audio" or event.resource_id is None:
                reason = "audio_required"
            else:
                audio = await db.get(models.AudioFile, event.resource_id)
                if audio is None:
                    reason = "unavailable_content"
                else:
                    import access_control
                    try:
                        await access_control.require_audio_access(db, user, audio)
                    except HTTPException:
                        reason = "unavailable_content"
        elif event.resource_id is not None or event.resource_type not in {None, "global"}:
            reason = "invalid_resource"
        if reason:
            result["rejected"].append({"event_id": event_id, "reason": reason})
            continue
        existing = await db.scalar(select(models.Log.log_id).where(models.Log.event_id == event_id))
        if existing:
            result["duplicates"].append(event_id)
            continue
        try:
            async with db.begin_nested():
                record_event(
                    db, event.event_type, actor_id=user.user_id,
                    resource_type="audio" if audio else "global",
                    resource_id=audio.audio_id if audio else None,
                    owner_teacher_id=audio.uploaded_by if audio else None,
                    class_id=audio.class_id if audio else None,
                    subject_id=audio.subject_id if audio else None,
                    source="client_reported", outcome="observed",
                    event_id=event_id, occurred_at=event.occurred_at, details=event.details,
                )
                await db.flush()
        except IntegrityError:
            existing = await db.scalar(select(models.Log.log_id).where(models.Log.event_id == event_id))
            if not existing:
                raise
            result["duplicates"].append(event_id)
        else:
            result["accepted"].append(event_id)
    await db.commit()
    return result


@router.post("/analytics/transcribe")
async def transcribe(request: Request, user=Depends(require_analytics)):
    rate_limit(user.user_id, "speech", 6)
    data = bytearray()
    try:
        if os.getenv("TRANSCRIPTION_ENABLED", "false") != "true":
            raise HTTPException(503, "Campus transcription is not enabled. Type your question instead.")
        async for chunk in request.stream():
            if len(data) + len(chunk) > 10 * 1024 * 1024:
                raise HTTPException(413, "Recording must be nonempty and at most 10 MB.")
            data.extend(chunk)
        if not data:
            raise HTTPException(413, "Recording must be nonempty and at most 10 MB.")
        key = os.getenv("SPEECH_WORKER_KEY")
        if not key:
            raise HTTPException(503, "Campus transcription is not configured.")
        url = local_url("SPEECH_WORKER_URL", "http://127.0.0.1:8001")
        try:
            async with httpx.AsyncClient(timeout=90, trust_env=False, follow_redirects=False) as client:
                response = await client.post(url + "/transcribe", content=bytes(data),
                                             headers={"X-Worker-Key": key, "Content-Type": "application/octet-stream"})
            if response.status_code in {413, 422, 429}:
                raise HTTPException(response.status_code, "Invalid, oversized or busy recording. Retry or use text.")
            response.raise_for_status()
            body = response.json()
            if not isinstance(body, dict) or not isinstance(body.get("text"), str) or not 1 <= len(body["text"]) <= 2000:
                raise HTTPException(422, "No usable English transcript. Retry or type your question.")
            return {"text": body["text"]}
        except (httpx.HTTPError, ValueError):
            raise HTTPException(503, "Campus transcription unavailable. Use text instead.") from None
    finally:
        data.clear()
