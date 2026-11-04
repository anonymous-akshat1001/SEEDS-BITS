"""Run from the backend directory: python maintenance.py retain|reconcile|erase|check."""

import argparse
import asyncio
import logging
import os
import smtplib
import httpx
from pathlib import Path
from datetime import datetime, timedelta
from email.message import EmailMessage

from sqlalchemy import delete, select, exists, text, or_, and_

import models
from database import AsyncSessionLocal
from analytics_service import month_shift
from logging_config import configure_logging

BATCH = 500


async def retain(db, now=None):
    now = now or datetime.utcnow()
    logs = (await db.execute(select(models.Log.log_id).where(
        models.Log.created_at <= now - timedelta(days=30),
    ).limit(BATCH))).scalars().all()
    await db.execute(delete(models.Log).where(models.Log.log_id.in_(logs)))
    runs = (await db.execute(select(models.SessionRun.run_id).where(
        models.SessionRun.expires_at <= now,
    ).limit(BATCH))).scalars().all()
    # Explicit child deletion also makes SQLite test/restore behavior independent of FK pragmas.
    for cls in (models.AttendanceJoin, models.Attendance):
        await db.execute(delete(cls).where(cls.run_id.in_(runs)))
    await db.execute(delete(models.SessionRun).where(models.SessionRun.run_id.in_(runs)))
    attempts = (await db.execute(select(models.QuizAttempt.attempt_id).where(
        models.QuizAttempt.retention_expires_at <= now,
    ).limit(BATCH))).scalars().all()
    await db.execute(delete(models.QuizResponse).where(models.QuizResponse.attempt_id.in_(attempts)))
    await db.execute(delete(models.QuizAttempt).where(models.QuizAttempt.attempt_id.in_(attempts)))
    orphaned = (await db.execute(select(models.AnalyticsSession.session_id).where(
        ~exists(select(models.SessionRun.run_id).where(
            models.SessionRun.session_id == models.AnalyticsSession.session_id,
        )),
        ~exists(select(models.Session.session_id).where(
            models.Session.session_id == models.AnalyticsSession.session_id,
            or_(models.Session.is_active.is_(True),
                models.Session.ended_at > month_shift(now, -18)),
        )),
    ).limit(BATCH))).scalars().all()
    await db.execute(delete(models.AnalyticsSession).where(models.AnalyticsSession.session_id.in_(orphaned)))
    directory = os.getenv("LOG_DIRECTORY")
    if directory:
        root = Path(directory).resolve()
        for path in root.glob("seeds.jsonl.*"):
            if path.is_file() and datetime.utcfromtimestamp(path.stat().st_mtime) <= now - timedelta(days=30):
                path.unlink()
    return len(logs) + len(runs) + len(attempts) + len(orphaned)


async def reconcile(db, now=None):
    import quiz_routes
    now = now or datetime.utcnow()
    ids = (await db.execute(select(models.QuizAttempt.attempt_id).where(
        models.QuizAttempt.status == "in_progress",
        models.QuizAttempt.deadline_at <= now,
    ).limit(BATCH).with_for_update(skip_locked=True))).scalars().all()
    for attempt_id in ids:
        attempt = await quiz_routes._get_attempt(db, attempt_id)
        if attempt.status == "in_progress":
            await quiz_routes._finalize_attempt(db, attempt, "timed_out", attempt.deadline_at)
    return len(ids)


async def erase_student(db, student_id):
    student = await db.get(models.User, student_id)
    if student is None or student.role != "student":
        raise ValueError("An existing student account is required")
    attempts = select(models.QuizAttempt.attempt_id).where(models.QuizAttempt.student_id == student_id)
    await db.execute(delete(models.QuizResponse).where(
        models.QuizResponse.attempt_id.in_(attempts),
    ).execution_options(synchronize_session=False))
    await db.execute(delete(models.QuizAttempt).where(models.QuizAttempt.student_id == student_id))
    for cls in (models.Attendance, models.AttendanceJoin):
        await db.execute(delete(cls).where(cls.student_id == student_id))
    participants = select(models.Participant.participant_id).where(
        models.Participant.user_id == student_id,
    )
    await db.execute(delete(models.Log).where(or_(
        models.Log.user_id == student_id,
        and_(models.Log.resource_type == "user", models.Log.resource_id == student_id),
        models.Log.event_details["target_user_id"].as_integer() == student_id,
        models.Log.event_details["participant_id"].as_integer().in_(participants),
    )).execution_options(synchronize_session=False))
    return 1


def send_alert():
    host, recipient, sender = (os.getenv("ALERT_SMTP_HOST"), os.getenv("ALERT_EMAIL_TO"),
                               os.getenv("ALERT_EMAIL_FROM"))
    if not all((host, recipient, sender)):
        raise RuntimeError("Campus SMTP host, sender and recipient must be configured")
    message = EmailMessage()
    message["Subject"] = "SEEDS local health alert"
    message["From"], message["To"] = sender, recipient
    message.set_content("SEEDS health/maintenance needs administrator attention. Check the campus dashboard and service. No student data is included.")
    with smtplib.SMTP(host, int(os.getenv("ALERT_SMTP_PORT", "25")), timeout=10) as smtp:
        if os.getenv("ALERT_SMTP_STARTTLS", "true") == "true":
            smtp.starttls()
        if os.getenv("ALERT_SMTP_USER"):
            smtp.login(os.environ["ALERT_SMTP_USER"], os.environ["ALERT_SMTP_PASSWORD"])
        smtp.send_message(message)


async def run(args):
    configure_logging()
    from activity_events import install_orm_audit
    install_orm_audit()
    async with AsyncSessionLocal() as db:
        if db.bind.dialect.name == "postgresql":
            if not await db.scalar(text("SELECT pg_try_advisory_xact_lock(53454544)")):
                raise RuntimeError("Another maintenance operation is running")
        if args.operation == "retain":
            count = 0
            while True:
                removed = await retain(db)
                count += removed
                if not removed:
                    break
        elif args.operation == "reconcile":
            count = await reconcile(db)
        elif args.operation == "erase":
            if not args.confirm or not args.student_id:
                raise ValueError("Erasure requires --student-id and --confirm")
            count = await erase_student(db, args.student_id)
        else:
            now = datetime.utcnow()
            from model_client import local_url
            backend_reachable = False
            try:
                url = local_url("WATCHDOG_URL", "http://127.0.0.1:8000")
                async with httpx.AsyncClient(timeout=5, trust_env=False, follow_redirects=False) as client:
                    response = await client.get(url + "/healthz")
                    backend_reachable = response.status_code == 200
            except httpx.HTTPError:
                logging.getLogger("seeds").error("watchdog_backend_unreachable", extra={"event_code": "watchdog_backend_unreachable"})
            overdue = await db.scalar(select(models.MaintenanceState.name).where(
                models.MaintenanceState.name.in_(["retain", "reconcile"]),
                models.MaintenanceState.succeeded_at < now - timedelta(hours=2),
            ).limit(1))
            states = (await db.execute(select(models.MaintenanceState.name))).scalars().all()
            if not backend_reachable or overdue or not {"retain", "reconcile"}.issubset(states) or args.test_alert:
                last = await db.get(models.MaintenanceState, "alert")
                if args.test_alert or last is None or last.succeeded_at < now - timedelta(hours=1):
                    await asyncio.to_thread(send_alert)
                    if last is None:
                        last = models.MaintenanceState(name="alert", status="sent", count=0)
                        db.add(last)
                    last.succeeded_at = now
            count = 0
        state = await db.get(models.MaintenanceState, args.operation)
        if state is None:
            state = models.MaintenanceState(name=args.operation, status="ok", count=count)
            db.add(state)
        state.succeeded_at, state.status, state.count = datetime.utcnow(), "ok", count
        await db.commit()
        logging.getLogger("seeds").info("maintenance_completed", extra={"event_code": "maintenance_completed"})


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("operation", choices=["retain", "reconcile", "erase", "check"])
    parser.add_argument("--student-id", type=int)
    parser.add_argument("--confirm", action="store_true")
    parser.add_argument("--test-alert", action="store_true")
    asyncio.run(run(parser.parse_args()))
