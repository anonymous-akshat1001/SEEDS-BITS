"""Durable, idempotent background jobs (S39).

Jobs are rows in ``scheduled_jobs`` so they survive restarts. Each has a unique
``dedupe_key``; enqueueing the same key twice is a no-op. Handlers must recheck
current state because a job may be late, retried, or superseded.

The worker runs inside the API process (``JOB_WORKER_ENABLED``, default on).
Claims use ``SKIP LOCKED`` on PostgreSQL so several workers never run the same
job; a crashed claim becomes runnable again after its lease expires.
"""

from __future__ import annotations

import asyncio
import logging
import os
from datetime import datetime, timedelta
from typing import Awaitable, Callable, Optional

from sqlalchemy import select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

import models
from admin_issues import report_issue
from scheduling import utcnow

Handler = Callable[[AsyncSession, dict], Awaitable[None]]
HANDLERS: dict[str, Handler] = {}
MAX_ATTEMPTS = 5
LEASE = timedelta(minutes=2)
logger = logging.getLogger("seeds")


def handler(kind: str):
    def register(function: Handler) -> Handler:
        HANDLERS[kind] = function
        return function
    return register


async def enqueue(
    db: AsyncSession,
    kind: str,
    dedupe_key: str,
    run_at: datetime,
    payload: dict,
) -> bool:
    """Add a job in the caller's transaction. Returns False if the key exists."""
    existing = (await db.execute(
        select(models.ScheduledJob.job_id).where(models.ScheduledJob.dedupe_key == dedupe_key)
    )).scalar_one_or_none()
    if existing is not None:
        return False
    try:
        async with db.begin_nested():
            db.add(models.ScheduledJob(
                kind=kind, dedupe_key=dedupe_key, run_at=run_at,
                payload=payload, status="pending", attempts=0,
            ))
    except IntegrityError:
        return False
    return True


async def cancel_jobs(db: AsyncSession, *, prefix: str) -> None:
    """Cancel pending jobs whose dedupe key starts with ``prefix``."""
    await db.execute(
        update(models.ScheduledJob)
        .where(
            models.ScheduledJob.status == "pending",
            models.ScheduledJob.dedupe_key.like(f"{prefix}%"),
        )
        .values(status="cancelled", completed_at=utcnow())
        .execution_options(synchronize_session=False)
    )


async def _claim(db: AsyncSession, limit: int) -> list[int]:
    now = utcnow()
    query = select(models.ScheduledJob).where(
        models.ScheduledJob.run_at <= now,
        (models.ScheduledJob.status == "pending")
        | ((models.ScheduledJob.status == "running") & (models.ScheduledJob.locked_until < now)),
    ).order_by(models.ScheduledJob.run_at).limit(limit)
    if db.bind.dialect.name == "postgresql":
        query = query.with_for_update(skip_locked=True)
    jobs = (await db.execute(query)).scalars().all()
    for job in jobs:
        job.status = "running"
        job.locked_until = now + LEASE
        job.attempts = (job.attempts or 0) + 1
    await db.commit()
    return [job.job_id for job in jobs]


async def run_job(session_factory, job_id: int) -> None:
    async with session_factory() as db:
        job = await db.get(models.ScheduledJob, job_id)
        if job is None or job.status != "running":
            return
        function = HANDLERS.get(job.kind)
        try:
            if function is None:
                raise RuntimeError(f"No handler for job kind {job.kind}")
            await function(db, dict(job.payload or {}))
            await db.rollback()  # discard anything a handler left uncommitted
            job = await db.get(models.ScheduledJob, job_id)
            job.status = "done"
            job.completed_at = utcnow()
            job.locked_until = None
            await db.commit()
        except Exception as error:  # noqa: BLE001 - every failure is recorded
            await db.rollback()
            job = await db.get(models.ScheduledJob, job_id)
            job.last_error = type(error).__name__
            job.locked_until = None
            if job.attempts >= MAX_ATTEMPTS:
                job.status = "failed"
                job.completed_at = utcnow()
                await db.commit()
                await report_issue(
                    db, "job_failed", f"job:{job.job_id}",
                    "A background task kept failing and was stopped.",
                    {"kind": job.kind, "job_id": job.job_id, "error": type(error).__name__},
                )
            else:
                job.status = "pending"
                job.run_at = utcnow() + timedelta(seconds=15 * (2 ** (job.attempts - 1)))
                await db.commit()
            logger.warning("job_failed", extra={"event_code": "job_failed", "kind": job.kind})


async def run_due_jobs(session_factory, limit: int = 20) -> int:
    async with session_factory() as db:
        ids = await _claim(db, limit)
    for job_id in ids:
        await run_job(session_factory, job_id)
    return len(ids)


class JobWorker:
    def __init__(self, session_factory, interval: Optional[float] = None):
        self.session_factory = session_factory
        self.interval = interval or float(os.getenv("JOB_POLL_SECONDS", "2"))
        self._task: Optional[asyncio.Task] = None
        self._stopping = asyncio.Event()

    def start(self) -> None:
        if self._task is None:
            self._task = asyncio.create_task(self._loop())

    async def stop(self) -> None:
        self._stopping.set()
        if self._task is not None:
            self._task.cancel()
            try:
                await self._task
            except asyncio.CancelledError:
                pass
            self._task = None

    async def _loop(self) -> None:
        while not self._stopping.is_set():
            try:
                await run_due_jobs(self.session_factory)
            except asyncio.CancelledError:
                raise
            except Exception:  # noqa: BLE001 - keep the worker alive
                logger.exception("job_worker_error", extra={"event_code": "job_worker_error"})
            try:
                await asyncio.wait_for(self._stopping.wait(), timeout=self.interval)
            except asyncio.TimeoutError:
                pass


def worker_enabled() -> bool:
    return os.getenv("JOB_WORKER_ENABLED", "true").strip().lower() not in {"0", "false", "no"}
