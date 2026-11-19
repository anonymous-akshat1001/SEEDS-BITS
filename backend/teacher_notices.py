"""Notices telling a teacher what an administrator did on their behalf."""

from datetime import datetime

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy import update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

import auth
import models
from database import get_db

router = APIRouter(tags=["Teacher notices"])

MAX_UNSEEN = 50


async def record(db: AsyncSession, teacher: models.User, kind: str, item, action: str) -> None:
    """Queues a notice in the caller's transaction when an administrator is
    acting for this teacher; does nothing for the teacher's own changes."""
    admin_id = auth.acting_admin_id(db, teacher)
    if admin_id is None:
        return
    key = "quiz_id" if kind == "quiz" else "journey_id"
    if getattr(item, key) is None:
        await db.flush()
    db.add(models.TeacherNotice(
        teacher_id=teacher.user_id, actor_id=admin_id, kind=kind,
        item_id=getattr(item, key), title=(item.title or "")[:300], action=action,
        created_at=datetime.utcnow(),
    ))


async def unseen(db: AsyncSession, teacher_id: int) -> list[dict]:
    rows = (await db.execute(
        select(models.TeacherNotice).where(
            models.TeacherNotice.teacher_id == teacher_id,
            models.TeacherNotice.seen_at.is_(None),
        ).order_by(models.TeacherNotice.created_at, models.TeacherNotice.notice_id).limit(MAX_UNSEEN)
    )).scalars().all()
    return [
        {"notice_id": row.notice_id, "kind": row.kind, "title": row.title, "action": row.action}
        for row in rows
    ]


class SeenBody(BaseModel):
    notice_ids: list[int] = Field(min_length=1, max_length=200)


@router.post("/me/notices/seen")
async def mark_seen(
    body: SeenBody,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        update(models.TeacherNotice).where(
            models.TeacherNotice.teacher_id == teacher.user_id,
            models.TeacherNotice.notice_id.in_(set(body.notice_ids)),
            models.TeacherNotice.seen_at.is_(None),
        ).values(seen_at=datetime.utcnow()).execution_options(synchronize_session=False)
    )
    await db.commit()
    return {"ok": True, "seen": result.rowcount or 0}
