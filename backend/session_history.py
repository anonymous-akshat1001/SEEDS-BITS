"""Verified attendance facts, independent of the live session's deletion lifecycle."""

from datetime import datetime
from uuid import uuid4

from sqlalchemy import select
from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.dialects.sqlite import insert as sqlite_insert

import models
from activity_events import enabled


async def ensure_history(db, session, *, opening=False):
    if not enabled():
        return None
    # Serialize lifecycle/first joins on the existing session lock, also across processes.
    await db.execute(select(models.Session.session_id).where(
        models.Session.session_id == session.session_id,
    ).with_for_update())
    history = await db.get(models.AnalyticsSession, session.session_id)
    now = datetime.utcnow()
    if history is None:
        await db.refresh(session, attribute_names=["created_at"])
        history = models.AnalyticsSession(
            session_id=session.session_id, owner_teacher_id=session.created_by,
            class_id=session.class_id, subject_id=session.subject_id,
            created_at=session.created_at or now,
            provenance="verified" if opening else "partial",
        )
        db.add(history)
        await db.flush()
    run = (await db.execute(select(models.SessionRun).where(
        models.SessionRun.session_id == session.session_id,
        models.SessionRun.ended_at.is_(None),
    ))).scalar_one_or_none()
    if run is None and (opening or session.is_active):
        run = models.SessionRun(
            run_id=str(uuid4()), session_id=session.session_id, opened_at=now,
        )
        db.add(run)
        await db.flush()
    return run


async def close_run(db, session):
    if not enabled():
        return
    run = await ensure_history(db, session)
    if run is not None:
        run.ended_at = session.ended_at or datetime.utcnow()
        from analytics_service import month_shift
        run.expires_at = month_shift(run.ended_at, 18)


async def confirm_attendance(db, session, student):
    if not enabled() or student.role != "student":
        return
    run = await ensure_history(db, session)
    if run is None:
        raise RuntimeError("Cannot confirm attendance without an active run")
    now = datetime.utcnow()
    values = dict(run_id=run.run_id, student_id=student.user_id,
                  first_joined_at=now, last_joined_at=now)
    dialect = db.bind.dialect.name
    if dialect not in {"postgresql", "sqlite"}:
        raise RuntimeError("Unsupported attendance database")
    insert = pg_insert if dialect == "postgresql" else sqlite_insert
    await db.execute(insert(models.Attendance).values(**values).on_conflict_do_update(
        index_elements=["run_id", "student_id"], set_={"last_joined_at": now},
    ))
    db.add(models.AttendanceJoin(
        join_id=str(uuid4()), run_id=run.run_id,
        student_id=student.user_id, joined_at=now,
    ))
