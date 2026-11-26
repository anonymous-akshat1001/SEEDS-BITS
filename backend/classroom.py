"""Live-class lifecycle: one-action start, home resolution, alerts, roster,
bounded extensions and automatic ending (S05–S15, S20, S24, S38, S44, S45)."""

from __future__ import annotations

import asyncio
import logging
import uuid
from datetime import date, datetime, timedelta
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy import select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

import access_control as access
import auth
import jobs
import models
import scheduling as sched
import teacher_notices
from admin_issues import report_issue
from database import get_db
from notification_service import fcm_service
from session_history import close_run, ensure_history
from session_logger import SessionLogger
from ws_manager import SESSION_LOCK, SESSION_STATE, ws_mgr

router = APIRouter(tags=["Classes"])
logger = logging.getLogger("seeds")


# ─── Shared helpers ──────────────────────────────────────────────────────────


def _fresh_runtime_state() -> dict:
    return {
        "connections": {},
        "participants": {},
        "playback": {"audio_id": None, "status": "stopped", "speed": 1.0, "position": 0.0},
    }


async def live_session_for_teacher(db: AsyncSession, teacher_id: int) -> Optional[models.Session]:
    return (await db.execute(
        select(models.Session).options(
            selectinload(models.Session.school_class),
            selectinload(models.Session.subject),
            selectinload(models.Session.creator),
        ).where(models.Session.created_by == teacher_id, models.Session.is_active.is_(True))
    )).scalars().first()


async def live_session_for_class(db: AsyncSession, class_id: int) -> Optional[models.Session]:
    return (await db.execute(
        select(models.Session).options(
            selectinload(models.Session.school_class),
            selectinload(models.Session.subject),
            selectinload(models.Session.creator),
        ).where(models.Session.class_id == class_id, models.Session.is_active.is_(True))
    )).scalars().first()


async def _extension_limit(db: AsyncSession, session: models.Session) -> Optional[datetime]:
    anchor = session.scheduled_start or session.started_at or sched.utcnow()
    exclude = (
        (session.timetable_entry_id, session.occurrence_date)
        if session.timetable_entry_id and session.occurrence_date else None
    )
    teacher_next, class_next = await sched.cutoff_context(
        db, teacher_id=session.created_by, class_id=session.class_id,
        after=anchor, exclude=exclude,
    )
    return sched.extension_limit(teacher_next, class_next)


async def session_summary(
    db: AsyncSession, session: models.Session, *, for_teacher: bool = False,
) -> dict:
    payload = {
        "session_id": session.session_id,
        "title": session.title,
        "class_id": session.class_id,
        "class_name": session.school_class.name if session.school_class else None,
        "subject_id": session.subject_id,
        "subject_name": session.subject.name if session.subject else None,
        "teacher_name": session.creator.name if session.creator else None,
        "is_active": bool(session.is_active),
        "scheduled": session.timetable_entry_id is not None,
        "started_at": sched.iso_utc(session.started_at or session.created_at),
        "scheduled_end": sched.iso_utc(session.scheduled_end),
        "cutoff_at": sched.iso_utc(session.cutoff_at),
        "cutoff_clock": sched.local_clock(session.cutoff_at) if session.cutoff_at else None,
        "lesson_playlist_id": session.lesson_playlist_id,
    }
    if for_teacher and session.is_active and session.cutoff_at is not None:
        limit = await _extension_limit(db, session)
        payload["can_extend"] = sched.extended_cutoff(session.cutoff_at, limit) is not None
    if for_teacher and session.lesson_playlist_id is not None:
        payload["lesson_items"] = await lesson_items(db, session)
    return payload


async def lesson_items(db: AsyncSession, session: models.Session) -> list[dict]:
    """Today's prepared lesson (S21/S22): playable recordings, in order."""
    playlist = (await db.execute(
        select(models.TeacherPlaylist).options(
            selectinload(models.TeacherPlaylist.items).selectinload(models.TeacherPlaylistItem.audio),
        ).where(models.TeacherPlaylist.playlist_id == session.lesson_playlist_id)
    )).scalar_one_or_none()
    if playlist is None or playlist.is_archived:
        return []
    return [
        {"audio_id": item.audio_id, "title": item.audio.title}
        for item in playlist.items
        if item.audio is not None
        and item.audio.class_id == session.class_id
        and item.audio.subject_id == session.subject_id
    ]


async def _link_lesson(db: AsyncSession, session: models.Session) -> None:
    """Makes the prepared recordings selectable in this class without the
    teacher linking each one."""
    if session.lesson_playlist_id is None:
        return
    items = await lesson_items(db, session)
    if not items:
        await report_issue(
            db, "lesson_unavailable", f"lesson_unavailable:{session.lesson_playlist_id}",
            "A prepared lesson has no playable recordings for its class and subject.",
            {"playlist_id": session.lesson_playlist_id, "session_id": session.session_id},
            commit=False,
        )
    for item in items:
        db.add(models.SessionAudio(session_id=session.session_id, audio_id=item["audio_id"]))


def _occurrence_payload(occurrence: sched.Occurrence) -> dict:
    return {
        "entry_id": occurrence.entry_id,
        "occurrence_date": occurrence.occurrence_date.isoformat(),
        "class_id": occurrence.class_id,
        "class_name": occurrence.class_name,
        "subject_id": occurrence.subject_id,
        "subject_name": occurrence.subject_name,
        "teacher_name": occurrence.teacher_name,
        "starts_at": sched.iso_utc(occurrence.start),
        "ends_at": sched.iso_utc(occurrence.end),
        "start_clock": sched.local_clock(occurrence.start),
        "end_clock": sched.local_clock(occurrence.end),
        "has_lesson": occurrence.lesson_playlist_id is not None,
    }


async def _occurrence_cutoff(db: AsyncSession, occurrence: sched.Occurrence) -> datetime:
    teacher_next, class_next = await sched.cutoff_context(
        db, teacher_id=occurrence.teacher_id, class_id=occurrence.class_id,
        after=occurrence.start, exclude=occurrence.key,
    )
    return sched.base_cutoff(occurrence.end, teacher_next, class_next)


async def _held_occurrences(db: AsyncSession, occurrences: list[sched.Occurrence]) -> dict:
    if not occurrences:
        return {}
    rows = (await db.execute(
        select(models.Session).where(
            models.Session.timetable_entry_id.in_({occurrence.entry_id for occurrence in occurrences}),
            models.Session.occurrence_date.in_({occurrence.occurrence_date for occurrence in occurrences}),
        )
    )).scalars().all()
    return {(row.timetable_entry_id, row.occurrence_date): row for row in rows}


async def teacher_schedule_today(db: AsyncSession, teacher_id: int, now: datetime) -> list[dict]:
    """Today's remaining classes, each marked open (startable now) or upcoming."""
    occurrences = await sched.occurrences_on(db, sched.local_today(now), teacher_id=teacher_id)
    held = await _held_occurrences(db, occurrences)
    result = []
    for occurrence in occurrences:
        if occurrence.key in held:
            continue
        cutoff = await _occurrence_cutoff(db, occurrence)
        opens_at, closes_at = sched.startable_window(occurrence, cutoff)
        if now >= closes_at:
            continue
        payload = _occurrence_payload(occurrence)
        payload.update({
            "status": "open" if now >= opens_at else "upcoming",
            "can_start": opens_at <= now < closes_at,
            "opens_at": sched.iso_utc(opens_at),
            "cutoff_at": sched.iso_utc(cutoff),
        })
        result.append(payload)
    return result


async def _teacher_workspaces(db: AsyncSession, teacher_id: int) -> list[dict]:
    rows = (await db.execute(
        select(models.TeacherClassSubjectAssignment).options(
            selectinload(models.TeacherClassSubjectAssignment.school_class),
            selectinload(models.TeacherClassSubjectAssignment.subject),
        ).join(
            models.ClassSubjectAssociation,
            (models.ClassSubjectAssociation.class_id == models.TeacherClassSubjectAssignment.class_id)
            & (models.ClassSubjectAssociation.subject_id == models.TeacherClassSubjectAssignment.subject_id),
        ).where(
            models.TeacherClassSubjectAssignment.teacher_id == teacher_id,
            models.TeacherClassSubjectAssignment.is_active.is_(True),
            models.ClassSubjectAssociation.is_active.is_(True),
        )
    )).scalars().all()
    return [
        {
            "assignment_id": row.assignment_id,
            "class_id": row.class_id,
            "class_name": row.school_class.name,
            "subject_id": row.subject_id,
            "subject_name": row.subject.name,
        }
        for row in rows
        if row.school_class.is_active and row.subject.is_active
    ]


# ─── Home (S38): what this person can do now ─────────────────────────────────


@router.get("/me/home")
async def home(
    current_user: models.User = Depends(auth.get_current_user),
    db: AsyncSession = Depends(get_db),
):
    now = sched.utcnow()
    payload: dict = {
        "role": current_user.role,
        "name": current_user.name,
        "server_time": sched.iso_utc(now),
        "live_class": None,
        "speech": auth.speech_payload(current_user),
    }
    if current_user.role == "teacher":
        live = await live_session_for_teacher(db, current_user.user_id)
        if live is not None:
            payload["live_class"] = await session_summary(db, live, for_teacher=True)
        payload["today"] = await teacher_schedule_today(db, current_user.user_id, now)
        payload["workspaces"] = await _teacher_workspaces(db, current_user.user_id)
        if not payload["workspaces"]:
            await report_issue(
                db, "teacher_without_assignment", f"teacher_without_assignment:{current_user.user_id}",
                f"Teacher {current_user.name} has no class and subject assigned.",
                {"user_id": current_user.user_id},
            )
        payload["notices"] = await teacher_notices.unseen(db, current_user.user_id)
        # Older apps read the same list under its first name.
        payload["admin_notices"] = payload["notices"]
        return payload
    if current_user.role == "student":
        membership = (await db.execute(
            select(models.StudentClassMembership).options(
                selectinload(models.StudentClassMembership.school_class),
            ).where(
                models.StudentClassMembership.student_id == current_user.user_id,
                models.StudentClassMembership.is_active.is_(True),
            )
        )).scalar_one_or_none()
        if membership is None:
            payload["class_name"] = None
            payload["next_class"] = None
            await report_issue(
                db, "student_without_class", f"student_without_class:{current_user.user_id}",
                f"Student {current_user.name} is not enrolled in a class.",
                {"user_id": current_user.user_id},
            )
            return payload
        payload["notices"] = await teacher_notices.unseen(db, current_user.user_id)
        payload["class_name"] = membership.school_class.name if membership.school_class else None
        live = await live_session_for_class(db, membership.class_id)
        if live is not None:
            payload["live_class"] = await session_summary(db, live)
        upcoming = [
            occurrence for occurrence in await sched.occurrences_on(
                db, sched.local_today(now), class_id=membership.class_id,
            )
            if occurrence.end > now
        ]
        held = await _held_occurrences(db, upcoming)
        upcoming = [occurrence for occurrence in upcoming if occurrence.key not in held]
        payload["next_class"] = _occurrence_payload(upcoming[0]) if upcoming else None
        return payload
    raise HTTPException(status_code=403, detail="Administrators use the administrator dashboard.")


# ─── Start (S10) ─────────────────────────────────────────────────────────────


class StartClassRequest(BaseModel):
    entry_id: Optional[int] = None
    occurrence_date: Optional[date] = None
    # Unscheduled class (testing and exceptions): an assigned class and subject.
    class_id: Optional[int] = None
    subject_id: Optional[int] = None


async def _conflict_detail(db: AsyncSession, teacher_id: int, class_id: int) -> Optional[str]:
    if await live_session_for_teacher(db, teacher_id) is not None:
        return "You already have a live class. Return to it or end it first."
    if await live_session_for_class(db, class_id) is not None:
        return "This class already has a live lesson with another teacher."
    return None


async def start_class(
    db: AsyncSession, teacher: models.User, request: StartClassRequest,
) -> tuple[models.Session, bool]:
    """Start (or return to) a class. Returns (session, created)."""
    now = sched.utcnow()
    live = await live_session_for_teacher(db, teacher.user_id)
    if request.entry_id is not None:
        day = request.occurrence_date or sched.local_today(now)
        if live is not None and live.timetable_entry_id == request.entry_id and live.occurrence_date == day:
            return live, False
        occurrence = next(
            (item for item in await sched.occurrences_on(db, day, teacher_id=teacher.user_id)
             if item.entry_id == request.entry_id),
            None,
        )
        if occurrence is None:
            raise HTTPException(status_code=404, detail="This class is not on your timetable today.")
        held = await _held_occurrences(db, [occurrence])
        if occurrence.key in held:
            raise HTTPException(status_code=409, detail="This class has already been held today.")
        cutoff = await _occurrence_cutoff(db, occurrence)
        opens_at, closes_at = sched.startable_window(occurrence, cutoff)
        if now < opens_at:
            raise HTTPException(
                status_code=409,
                detail=f"This class can start from {sched.local_clock(opens_at)}.",
            )
        if now >= closes_at:
            raise HTTPException(status_code=409, detail="The time for this class has passed.")
        class_id, subject_id = occurrence.class_id, occurrence.subject_id
        scheduled_start, scheduled_end = occurrence.start, occurrence.end
        playlist_id = occurrence.lesson_playlist_id
        entry_id, occurrence_date = occurrence.entry_id, occurrence.occurrence_date
    else:
        if request.class_id is None or request.subject_id is None:
            raise HTTPException(status_code=422, detail="Choose a class to start.")
        if live is not None and live.class_id == request.class_id and live.subject_id == request.subject_id:
            return live, False
        class_id, subject_id = request.class_id, request.subject_id
        scheduled_start, scheduled_end = now, now + sched.UNSCHEDULED_LENGTH
        teacher_next, class_next = await sched.cutoff_context(
            db, teacher_id=teacher.user_id, class_id=class_id, after=now,
        )
        cutoff = sched.base_cutoff(scheduled_end, teacher_next, class_next)
        if cutoff - now < sched.MINIMUM_TEACHING_TIME:
            raise HTTPException(status_code=409, detail="Your next scheduled class starts too soon.")
        playlist_id = None
        entry_id, occurrence_date = None, None
    school_class, subject = await access.require_active_class_subject(db, class_id, subject_id)
    await access.require_teacher_assignment(db, teacher.user_id, class_id, subject_id)
    conflict = await _conflict_detail(db, teacher.user_id, class_id)
    if conflict:
        raise HTTPException(status_code=409, detail=conflict)
    session = models.Session(
        title=sched.session_label(subject.name, school_class.name, now),
        created_by=teacher.user_id,
        class_id=class_id,
        subject_id=subject_id,
        is_active=True,
        timetable_entry_id=entry_id,
        occurrence_date=occurrence_date,
        scheduled_start=scheduled_start,
        scheduled_end=scheduled_end,
        started_at=now,
        cutoff_at=cutoff,
        lesson_playlist_id=playlist_id,
    )
    db.add(session)
    try:
        await db.flush()
    except IntegrityError:
        await db.rollback()
        live = await live_session_for_teacher(db, teacher.user_id)
        if live is not None and (
            (entry_id is not None and live.timetable_entry_id == entry_id and live.occurrence_date == occurrence_date)
            or (entry_id is None and live.class_id == class_id and live.subject_id == subject_id)
        ):
            return live, False
        raise HTTPException(
            status_code=409,
            detail=await _conflict_detail(db, teacher.user_id, class_id)
            or "This class has already been started.",
        )
    await ensure_history(db, session, opening=True)
    await _link_lesson(db, session)
    await schedule_cutoff_jobs(db, session)
    await jobs.enqueue(
        db, "class_auto_reminder", f"session:{session.session_id}:auto_reminder",
        now + sched.AUTO_REMINDER_AFTER, {"session_id": session.session_id},
    )
    await queue_alert(db, session, "start", requested_by=teacher.user_id, commit=False)
    await db.commit()
    async with SESSION_LOCK:
        SESSION_STATE[session.session_id] = _fresh_runtime_state()
    await SessionLogger.log_session_created(db, session.session_id, teacher.user_id, session.title)
    refreshed = await live_session_for_teacher(db, teacher.user_id)
    return refreshed or session, True


@router.post("/classes/start")
async def start_class_route(
    request: StartClassRequest,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    session, created = await start_class(db, teacher, request)
    return {"created": created, "live_class": await session_summary(db, session, for_teacher=True)}


# ─── Alerts (S13/S15/S45) ────────────────────────────────────────────────────


async def _enrolled_students(db: AsyncSession, class_id: int) -> list[models.User]:
    return list((await db.execute(
        select(models.User).join(
            models.StudentClassMembership,
            models.StudentClassMembership.student_id == models.User.user_id,
        ).where(
            models.StudentClassMembership.class_id == class_id,
            models.StudentClassMembership.is_active.is_(True),
            models.User.role == "student",
            models.User.is_active.is_(True),
        ).order_by(models.User.name)
    )).scalars().all())


async def _participants_by_user(db: AsyncSession, session_id: int) -> dict[int, models.Participant]:
    rows = (await db.execute(
        select(models.Participant).where(models.Participant.session_id == session_id)
    )).scalars().all()
    return {row.user_id: row for row in rows}


async def queue_alert(
    db: AsyncSession,
    session: models.Session,
    kind: str,
    *,
    requested_by: Optional[int] = None,
    commit: bool = True,
) -> dict:
    """Record one ringing alert for every eligible student who has never
    joined, honouring the five-minute per-student cooldown, and enqueue its
    delivery. Returns counts; no alert is created when nobody qualifies."""
    now = sched.utcnow()
    participants = await _participants_by_user(db, session.session_id)
    eligible = [
        student for student in await _enrolled_students(db, session.class_id)
        if not (
            student.user_id in participants
            and (participants[student.user_id].first_connected_at is not None
                 or participants[student.user_id].is_kicked)
        )
    ]
    counts = {"eligible": len(eligible), "queued": 0, "cooldown": 0}
    if not eligible:
        if commit:
            await db.commit()
        return counts
    recent = set((await db.execute(
        select(models.ClassAlertRecipient.user_id).where(
            models.ClassAlertRecipient.session_id == session.session_id,
            models.ClassAlertRecipient.user_id.in_([student.user_id for student in eligible]),
            models.ClassAlertRecipient.status.in_(["queued", "sent"]),
            models.ClassAlertRecipient.created_at > now - sched.REMINDER_COOLDOWN,
        )
    )).scalars().all())
    alert = models.ClassAlert(
        alert_id=str(uuid.uuid4()), session_id=session.session_id, kind=kind,
        requested_by=requested_by, created_at=now, ring_until=now + sched.RING_DURATION,
    )
    db.add(alert)
    for student in eligible:
        status = "skipped_cooldown" if student.user_id in recent else "queued"
        counts["queued" if status == "queued" else "cooldown"] += 1
        db.add(models.ClassAlertRecipient(
            alert_id=alert.alert_id, session_id=session.session_id,
            user_id=student.user_id, status=status, created_at=now,
        ))
    if counts["queued"]:
        await jobs.enqueue(
            db, "class_alert_dispatch", f"alert:{alert.alert_id}", now, {"alert_id": alert.alert_id},
        )
    if commit:
        await db.commit()
    return counts


@jobs.handler("class_alert_dispatch")
async def dispatch_alert(db: AsyncSession, payload: dict) -> None:
    alert = await db.get(models.ClassAlert, payload["alert_id"])
    if alert is None:
        return
    session = await db.get(models.Session, alert.session_id)
    recipients = (await db.execute(
        select(models.ClassAlertRecipient).where(
            models.ClassAlertRecipient.alert_id == alert.alert_id,
            models.ClassAlertRecipient.status == "queued",
        )
    )).scalars().all()
    if session is None or not session.is_active:
        for recipient in recipients:
            recipient.status = "cancelled"
        await db.commit()
        return
    participants = await _participants_by_user(db, session.session_id)
    ring_until_ms = int((alert.ring_until - datetime(1970, 1, 1)).total_seconds() * 1000)
    without_device = []
    for recipient in recipients:
        participant = participants.get(recipient.user_id)
        if participant is not None and participant.first_connected_at is not None:
            recipient.status = "skipped_joined"
            continue
        tokens = (await db.execute(
            select(models.FCMToken.token).where(models.FCMToken.user_id == recipient.user_id)
        )).scalars().all()
        if not tokens:
            recipient.status = "no_device"
            without_device.append(recipient.user_id)
            continue
        delivered = False
        for token in tokens:
            delivered = await fcm_service.send_class_alert(
                token, session_id=session.session_id, alert_id=alert.alert_id,
                alert_kind=alert.kind, ring_until_ms=ring_until_ms,
            ) or delivered
        recipient.status = "sent" if delivered else "failed"
        recipient.sent_at = sched.utcnow()
    await db.commit()
    for user_id in without_device:
        student = await db.get(models.User, user_id)
        await report_issue(
            db, "student_without_device", f"student_without_device:{user_id}",
            f"{student.name if student else 'A student'} cannot receive class alerts: "
            "no phone is registered for notifications.",
            {"user_id": user_id},
        )


@jobs.handler("class_alert_cancel")
async def cancel_alerts(db: AsyncSession, payload: dict) -> None:
    """Stop phones that are still ringing for a class that has ended."""
    session_id = payload["session_id"]
    now = sched.utcnow()
    user_ids = set((await db.execute(
        select(models.ClassAlertRecipient.user_id).join(models.ClassAlert).where(
            models.ClassAlert.session_id == session_id,
            models.ClassAlert.ring_until > now - timedelta(minutes=1),
            models.ClassAlertRecipient.status == "sent",
        )
    )).scalars().all())
    for user_id in user_ids:
        tokens = (await db.execute(
            select(models.FCMToken.token).where(models.FCMToken.user_id == user_id)
        )).scalars().all()
        for token in tokens:
            await fcm_service.send_notification(
                token, "SEEDS update", "Open SEEDS to review your updates.",
                {"type": "class_alert_cancel", "session_id": str(session_id)},
                data_only=True,
            )


@jobs.handler("class_auto_reminder")
async def auto_reminder(db: AsyncSession, payload: dict) -> None:
    session = await db.get(models.Session, payload["session_id"])
    if session is None or not session.is_active:
        return
    await queue_alert(db, session, "auto_reminder")


@router.post("/sessions/{session_id}/remind-not-joined")
async def remind_not_joined(
    session_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    session = await _managed_live_session(db, teacher, session_id)
    counts = await queue_alert(db, session, "manual_reminder", requested_by=teacher.user_id)
    return {"ok": True, **counts}


# ─── In-class quiz or journey ────────────────────────────────────────────────
# The teacher starts one published quiz or journey for the class; students are
# told at once and begin it with one key. It stays in their normal lists.


def activity_payload(session: models.Session) -> Optional[dict]:
    if not session.activity_kind or session.activity_id is None:
        return None
    return {
        "kind": session.activity_kind,
        "id": session.activity_id,
        "title": session.activity_title,
    }


def _quiz_open(quiz: models.Quiz, now: datetime) -> bool:
    return (
        quiz.status == "published"
        and (quiz.opens_at is None or quiz.opens_at <= now)
        and (quiz.closes_at is None or quiz.closes_at > now)
    )


async def _workspace_activities(db: AsyncSession, session: models.Session) -> dict:
    now = sched.utcnow()
    quizzes = (await db.execute(
        select(models.Quiz).options(selectinload(models.Quiz.questions)).where(
            models.Quiz.class_id == session.class_id,
            models.Quiz.subject_id == session.subject_id,
            models.Quiz.status == "published",
        ).order_by(models.Quiz.published_at.desc())
    )).scalars().all()
    journeys = (await db.execute(
        select(models.LearningJourney).where(
            models.LearningJourney.class_id == session.class_id,
            models.LearningJourney.subject_id == session.subject_id,
            models.LearningJourney.status == "published",
        ).order_by(models.LearningJourney.published_at.desc())
    )).scalars().all()
    return {
        "current": activity_payload(session),
        "quizzes": [
            {"kind": "quiz", "id": quiz.quiz_id, "title": quiz.title, "questions": len(quiz.questions)}
            for quiz in quizzes if _quiz_open(quiz, now)
        ],
        "journeys": [
            {"kind": "journey", "id": journey.journey_id, "title": journey.title}
            for journey in journeys
        ],
    }


@router.get("/sessions/{session_id}/activities")
async def list_activities(
    session_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    return await _workspace_activities(db, await _managed_live_session(db, teacher, session_id))


class ActivityStart(BaseModel):
    kind: str = Field(pattern="^(quiz|journey)$")
    id: int


@router.post("/sessions/{session_id}/activity")
async def start_activity(
    session_id: int,
    payload: ActivityStart,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    session = await _managed_live_session(db, teacher, session_id)
    if payload.kind == "quiz":
        item = await db.get(models.Quiz, payload.id)
        usable = item is not None and _quiz_open(item, sched.utcnow())
    else:
        item = await db.get(models.LearningJourney, payload.id)
        usable = item is not None and item.status == "published"
    if not usable or item.class_id != session.class_id or item.subject_id != session.subject_id:
        raise HTTPException(
            status_code=404,
            detail="Choose a published quiz or journey for this class and subject.",
        )
    session.activity_kind = payload.kind
    session.activity_id = payload.id
    session.activity_title = item.title
    session.activity_started_at = sched.utcnow()
    await db.commit()
    activity = activity_payload(session)
    await ws_mgr.broadcast(session.session_id, {"type": "activity_started", **activity})
    return {"ok": True, "activity": activity}


@router.delete("/sessions/{session_id}/activity")
async def stop_activity(
    session_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    session = await _managed_live_session(db, teacher, session_id)
    session.activity_kind = None
    session.activity_id = None
    session.activity_title = None
    session.activity_started_at = None
    await db.commit()
    await ws_mgr.broadcast(session.session_id, {"type": "activity_stopped"})
    return {"ok": True}


async def _activity_statuses(
    db: AsyncSession, activity: dict, student_ids: list[int],
) -> dict[int, str]:
    """'done' or 'in_progress' per student who has begun it; others have not started."""
    if activity["kind"] == "quiz":
        rows = (await db.execute(
            select(models.QuizAttempt.student_id, models.QuizAttempt.status).where(
                models.QuizAttempt.quiz_id == activity["id"],
                models.QuizAttempt.student_id.in_(student_ids or [-1]),
            )
        )).all()
        done = {"completed", "timed_out"}
    else:
        rows = (await db.execute(
            select(models.JourneyRun.student_id, models.JourneyRun.status).where(
                models.JourneyRun.journey_id == activity["id"],
                models.JourneyRun.student_id.in_(student_ids or [-1]),
            )
        )).all()
        done = {"completed"}
    statuses: dict[int, str] = {}
    for student_id, status in rows:
        if status in done or statuses.get(student_id) != "done":
            statuses[student_id] = "done" if status in done else "in_progress"
    return statuses


async def activity_progress(db: AsyncSession, session: models.Session, student_ids: list[int]) -> Optional[dict]:
    """How many of the class's students have started and finished it."""
    activity = activity_payload(session)
    if activity is None:
        return None
    statuses = await _activity_statuses(db, activity, student_ids)
    finished = sum(1 for status in statuses.values() if status == "done")
    return {**activity, "started": len(statuses), "finished": finished}


async def activity_left(db: AsyncSession, session: models.Session) -> dict:
    """Enrolled students who have not finished the open quiz or journey,
    each marked not started or started, and whether they are in class now."""
    activity = activity_payload(session)
    if activity is None:
        raise HTTPException(status_code=409, detail="No quiz or journey is open in class.")
    students = await _enrolled_students(db, session.class_id)
    statuses = await _activity_statuses(db, activity, [student.user_id for student in students])
    participants = await _participants_by_user(db, session.session_id)
    connected = set(ws_mgr.active.get(session.session_id, {}).keys())
    left = []
    for student in students:
        status = statuses.get(student.user_id, "not_started")
        if status == "done":
            continue
        participant = participants.get(student.user_id)
        present = (
            participant is not None
            and participant.participant_id in connected
            and not participant.is_kicked
        )
        left.append({
            "user_id": student.user_id,
            "name": student.name,
            "status": status,
            "in_class": present,
            "participant_id": participant.participant_id if present else None,
        })
        present = 0
    for student in students:
        participant = participants.get(student.user_id)
        if participant is not None and participant.participant_id in connected and not participant.is_kicked:
            present += 1
    return {
        **activity,
        "whole_class": left,
        "in_class": [student for student in left if student["in_class"]],
        "present": present,
        "started": len(statuses),
        "finished": sum(1 for status in statuses.values() if status == "done"),
        "enrolled": len(students),
    }


@router.get("/sessions/{session_id}/activity/left")
async def activity_left_route(
    session_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    return await activity_left(db, await _managed_live_session(db, teacher, session_id))


@router.post("/sessions/{session_id}/activity/remind")
async def remind_activity(
    session_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    """Announces the open quiz or journey again on the phones of students in
    class who have not finished it. Nobody else hears it."""
    left = await activity_left(db, await _managed_live_session(db, teacher, session_id))
    event = {"type": "activity_reminder", "kind": left["kind"], "id": left["id"], "title": left["title"]}
    queues = ws_mgr.active.get(session_id, {})
    reminded = 0
    for student in left["in_class"]:
        queue = queues.get(student["participant_id"])
        if queue is not None:
            await ws_mgr.send_personal(queue, event)
            reminded += 1
    return {"ok": True, "reminded": reminded}


# ─── Roster (S44) ────────────────────────────────────────────────────────────


async def class_roster(db: AsyncSession, session: models.Session) -> dict:
    participants = await _participants_by_user(db, session.session_id)
    connected_ids = set(ws_mgr.active.get(session.session_id, {}).keys())
    connected, left, not_joined = [], [], []
    students = await _enrolled_students(db, session.class_id)
    for student in students:
        participant = participants.get(student.user_id)
        entry = {"user_id": student.user_id, "name": student.name}
        if participant is None or participant.first_connected_at is None:
            not_joined.append(entry)
        elif participant.participant_id in connected_ids and not participant.is_kicked:
            connected.append(entry)
        else:
            left.append({**entry, "removed": bool(participant.is_kicked)})
    return {
        "connected": connected,
        "left": left,
        "not_joined": not_joined,
        "counts": {"connected": len(connected), "left": len(left), "not_joined": len(not_joined)},
        "activity": await activity_progress(db, session, [student.user_id for student in students]),
    }


@router.get("/sessions/{session_id}/roster")
async def roster(
    session_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    session = await _managed_live_session(db, teacher, session_id)
    return await class_roster(db, session)


# ─── Extension, warnings and ending (S06/S24) ────────────────────────────────


async def _managed_live_session(db: AsyncSession, user: models.User, session_id: int) -> models.Session:
    session = (await db.execute(
        select(models.Session).options(
            selectinload(models.Session.school_class),
            selectinload(models.Session.subject),
            selectinload(models.Session.creator),
        ).where(models.Session.session_id == session_id)
    )).scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=404, detail="Session not found")
    if user.role != "admin":
        await access.require_session_access(db, user, session, manage=True)
    if not session.is_active:
        raise HTTPException(status_code=409, detail="This class has already ended.")
    return session


async def schedule_cutoff_jobs(db: AsyncSession, session: models.Session) -> None:
    if session.cutoff_at is None:
        return
    stamp = session.cutoff_at.replace(microsecond=0).isoformat()
    for before in sched.CUTOFF_WARNINGS:
        minutes = int(before.total_seconds() // 60)
        await jobs.enqueue(
            db, "class_cutoff_warning",
            f"session:{session.session_id}:warn:{minutes}:{stamp}",
            session.cutoff_at - before,
            {"session_id": session.session_id, "cutoff": stamp, "minutes": minutes},
        )
    await jobs.enqueue(
        db, "class_auto_end", f"session:{session.session_id}:end:{stamp}",
        session.cutoff_at, {"session_id": session.session_id, "cutoff": stamp},
    )


async def extend_class(db: AsyncSession, session: models.Session) -> dict:
    limit = await _extension_limit(db, session)
    new_cutoff = sched.extended_cutoff(session.cutoff_at, limit)
    if new_cutoff is None:
        raise HTTPException(status_code=409, detail="No more time can be added before the next class.")
    added = int((new_cutoff - session.cutoff_at).total_seconds() // 60)
    session.cutoff_at = new_cutoff
    session.extension_minutes = (session.extension_minutes or 0) + added
    await jobs.cancel_jobs(db, prefix=f"session:{session.session_id}:warn:")
    await jobs.cancel_jobs(db, prefix=f"session:{session.session_id}:end:")
    await schedule_cutoff_jobs(db, session)
    await db.commit()
    can_extend_again = sched.extended_cutoff(new_cutoff, limit) is not None
    event = {
        "type": "class_extended",
        "cutoff_at": sched.iso_utc(new_cutoff),
        "cutoff_clock": sched.local_clock(new_cutoff),
        "minutes_added": added,
        "can_extend": can_extend_again,
    }
    await ws_mgr.broadcast(session.session_id, event)
    return {"ok": True, **event}


@router.post("/sessions/{session_id}/extend")
async def extend_route(
    session_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    return await extend_class(db, await _managed_live_session(db, teacher, session_id))


@jobs.handler("class_cutoff_warning")
async def cutoff_warning(db: AsyncSession, payload: dict) -> None:
    session = await db.get(models.Session, payload["session_id"])
    if session is None or not session.is_active or session.cutoff_at is None:
        return
    if session.cutoff_at.replace(microsecond=0).isoformat() != payload["cutoff"]:
        return
    limit = await _extension_limit(db, session)
    await ws_mgr.broadcast(session.session_id, {
        "type": "class_ending_soon",
        "minutes": payload["minutes"],
        "cutoff_at": sched.iso_utc(session.cutoff_at),
        "can_extend": sched.extended_cutoff(session.cutoff_at, limit) is not None,
    })


@jobs.handler("class_auto_end")
async def auto_end(db: AsyncSession, payload: dict) -> None:
    session = await db.get(models.Session, payload["session_id"])
    if session is None or not session.is_active or session.cutoff_at is None:
        return
    if session.cutoff_at > sched.utcnow():
        return  # extended since this job was queued; a newer job exists
    await end_class(db, session, reason="automatic", ended_by=None)


async def end_class(
    db: AsyncSession, session: models.Session, *, reason: str, ended_by: Optional[int],
) -> bool:
    """End a live class for everyone. Idempotent; returns False if already ended."""
    locked = (await db.execute(
        select(models.Session).where(models.Session.session_id == session.session_id)
        .with_for_update().execution_options(populate_existing=True)
    )).scalar_one()
    if not locked.is_active:
        return False
    locked.is_active = False
    locked.ended_at = sched.utcnow()
    locked.end_reason = reason
    await close_run(db, locked)
    await jobs.cancel_jobs(db, prefix=f"session:{locked.session_id}:")
    await db.execute(
        update(models.ClassAlertRecipient)
        .where(
            models.ClassAlertRecipient.session_id == locked.session_id,
            models.ClassAlertRecipient.status == "queued",
        )
        .values(status="cancelled")
        .execution_options(synchronize_session=False)
    )
    await jobs.enqueue(
        db, "class_alert_cancel", f"alert_cancel:{locked.session_id}",
        sched.utcnow(), {"session_id": locked.session_id},
    )
    await db.commit()
    await ws_mgr.broadcast(locked.session_id, {"type": "session_ending", "reason": reason})
    asyncio.create_task(ws_mgr.close_session(locked.session_id))
    await SessionLogger.log_session_ended(db, locked.session_id, ended_by)
    return True
