"""Notices telling an account what someone else changed for it.

Teachers hear what an administrator did on their behalf and which lessons
were scheduled, changed or handed over; students hear what was published or
scheduled for their class. Home returns the unheard ones and the app speaks
them once.
"""

from datetime import date, datetime
from typing import Iterable, Optional

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy import update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload

import auth
import models
from database import get_db

router = APIRouter(tags=["Notices"])

MAX_UNSEEN = 50


def notify(
    db: AsyncSession,
    recipient_ids: Iterable[int],
    actor_id: Optional[int],
    kind: str,
    item_id: int,
    title: str,
    action: str,
    detail: Optional[str] = None,
) -> None:
    """Queues one notice per recipient in the caller's transaction. Nobody is
    told about their own change."""
    now = datetime.utcnow()
    for recipient in dict.fromkeys(recipient_ids):
        if recipient is None or recipient == actor_id:
            continue
        db.add(models.TeacherNotice(
            teacher_id=recipient, actor_id=actor_id, kind=kind, item_id=item_id,
            title=(title or "")[:300], action=action, detail=detail, created_at=now,
        ))


async def record(db: AsyncSession, teacher: models.User, kind: str, item, action: str) -> None:
    """Queues a notice when an administrator is acting for this teacher; does
    nothing for the teacher's own changes."""
    admin_id = auth.acting_admin_id(db, teacher)
    if admin_id is None:
        return
    key = "quiz_id" if kind == "quiz" else "journey_id"
    if getattr(item, key) is None:
        await db.flush()
    notify(db, [teacher.user_id], admin_id, kind, getattr(item, key), item.title, action)


async def class_student_ids(db: AsyncSession, class_id: int) -> list[int]:
    return list((await db.execute(
        select(models.StudentClassMembership.student_id).where(
            models.StudentClassMembership.class_id == class_id,
            models.StudentClassMembership.is_active.is_(True),
        )
    )).scalars().all())


async def notify_class(
    db: AsyncSession, class_id: int, actor_id: Optional[int], kind: str, item_id: int,
    title: str, action: str, detail: Optional[str] = None,
) -> None:
    """Tells every student enrolled in the class."""
    notify(db, await class_student_ids(db, class_id), actor_id, kind, item_id, title, action, detail)


def lesson_title(entry: models.TimetableEntry) -> str:
    """"English, Class 6": the subject and class, as entered by the school."""
    parts = [
        entry.subject.name if entry.subject else None,
        entry.school_class.name if entry.school_class else None,
    ]
    return ", ".join(part for part in parts if part)


def day_detail(day: Optional[date]) -> Optional[str]:
    return day.isoformat() if day else None


async def unseen(db: AsyncSession, user_id: int) -> list[dict]:
    rows = (await db.execute(
        select(models.TeacherNotice).options(selectinload(models.TeacherNotice.actor)).where(
            models.TeacherNotice.teacher_id == user_id,
            models.TeacherNotice.seen_at.is_(None),
        ).order_by(models.TeacherNotice.created_at, models.TeacherNotice.notice_id).limit(MAX_UNSEEN)
    )).scalars().all()
    return [
        {
            "notice_id": row.notice_id,
            "kind": row.kind,
            "title": row.title,
            "action": row.action,
            "detail": row.detail,
            "actor_role": row.actor.role if row.actor else None,
            "actor_name": row.actor.name if row.actor else None,
        }
        for row in rows
    ]


class SeenBody(BaseModel):
    notice_ids: list[int] = Field(min_length=1, max_length=200)


@router.post("/me/notices/seen")
async def mark_seen(
    body: SeenBody,
    user: models.User = Depends(auth.get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        update(models.TeacherNotice).where(
            models.TeacherNotice.teacher_id == user.user_id,
            models.TeacherNotice.notice_id.in_(set(body.notice_ids)),
            models.TeacherNotice.seen_at.is_(None),
        ).values(seen_at=datetime.utcnow()).execution_options(synchronize_session=False)
    )
    await db.commit()
    return {"ok": True, "seen": result.rowcount or 0}
