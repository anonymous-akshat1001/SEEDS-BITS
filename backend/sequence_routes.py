"""Reusable private teaching plans; preparation never executes classroom actions."""

import os
from typing import Literal

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field, model_validator
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

import access_control as access
import auth
import models
from database import get_db

router = APIRouter(tags=["Lesson sequences"])


class Step(BaseModel):
    kind: Literal["audio", "prompt", "check"]
    text: str = Field(min_length=1, max_length=4000)
    audio_id: int | None = Field(default=None, gt=0)

    @model_validator(mode="after")
    def validate_content(self):
        self.text = self.text.strip()
        if not self.text or (self.kind == "audio") != (self.audio_id is not None):
            raise ValueError("A step needs text and only recording steps need an audio ID")
        return self


class PlanBody(BaseModel):
    title: str = Field(min_length=1, max_length=160)
    steps: list[Step] = Field(default_factory=list, max_length=100)


class CreatePlan(PlanBody):
    class_id: int = Field(gt=0)
    subject_id: int = Field(gt=0)


class UpdatePlan(PlanBody):
    revision: int = Field(gt=0)


async def workspace(db, teacher, class_id=None, subject_id=None, session_id=None):
    if session_id is not None:
        room = await db.get(models.Session, session_id)
        if room is None or not room.is_active:
            raise HTTPException(404, "Active session not found")
        await access.require_session_access(db, teacher, room, manage=True)
        class_id, subject_id = room.class_id, room.subject_id
    if class_id is None or subject_id is None:
        raise HTTPException(422, "Select a class and subject")
    await access.require_active_class_subject(db, class_id, subject_id)
    await access.require_teacher_assignment(db, teacher.user_id, class_id, subject_id)
    return class_id, subject_id


async def owned(db, teacher, sequence_id, *, lock=False):
    query = select(models.LessonSequence).where(models.LessonSequence.sequence_id == sequence_id)
    if lock:
        query = query.with_for_update().execution_options(populate_existing=True)
    plan = (await db.execute(query)).scalar_one_or_none()
    if plan is None:
        raise HTTPException(404, "Lesson sequence not found")
    if plan.owner_teacher_id != teacher.user_id:
        raise HTTPException(403, "This lesson sequence belongs to another teacher")
    await workspace(db, teacher, plan.class_id, plan.subject_id)
    return plan


def payload(plan):
    return {key: getattr(plan, key) for key in (
        "sequence_id", "owner_teacher_id", "class_id", "subject_id", "title", "revision", "steps",
    )}


async def recording(db, teacher, audio_id, class_id, subject_id):
    audio = await db.get(models.AudioFile, audio_id)
    if audio is None:
        raise HTTPException(409, "A sequence recording is no longer available. Edit the selected step.")
    await access.require_audio_access(db, teacher, audio)
    if (audio.class_id, audio.subject_id) != (class_id, subject_id):
        raise HTTPException(403, "Sequence recordings must belong to the selected class and subject")
    return audio


async def validate_body(db, teacher, body, class_id, subject_id):
    if not body.title.strip():
        raise HTTPException(422, "Enter a lesson sequence title")
    for step in body.steps:
        if step.kind == "audio":
            await recording(db, teacher, step.audio_id, class_id, subject_id)


@router.get("/teacher-sequences")
async def list_plans(
    class_id: int | None = None, subject_id: int | None = None, session_id: int | None = None,
    teacher: models.User = Depends(auth.require_teacher), db: AsyncSession = Depends(get_db),
):
    class_id, subject_id = await workspace(db, teacher, class_id, subject_id, session_id)
    plans = (await db.execute(select(models.LessonSequence).where(
        models.LessonSequence.owner_teacher_id == teacher.user_id,
        models.LessonSequence.class_id == class_id,
        models.LessonSequence.subject_id == subject_id,
    ).order_by(models.LessonSequence.sequence_id))).scalars().all()
    return {"class_id": class_id, "subject_id": subject_id, "plans": [payload(plan) for plan in plans]}


@router.post("/teacher-sequences")
async def create_plan(
    body: CreatePlan, teacher: models.User = Depends(auth.require_teacher), db: AsyncSession = Depends(get_db),
):
    await workspace(db, teacher, body.class_id, body.subject_id)
    await validate_body(db, teacher, body, body.class_id, body.subject_id)
    plan = models.LessonSequence(
        owner_teacher_id=teacher.user_id, class_id=body.class_id, subject_id=body.subject_id,
        title=body.title.strip(), steps=[step.model_dump() for step in body.steps], revision=1,
    )
    db.add(plan)
    await db.commit()
    return {"ok": True, "plan": payload(plan)}


@router.post("/teacher-sequences/{sequence_id}/update")
async def update_plan(
    sequence_id: int, body: UpdatePlan,
    teacher: models.User = Depends(auth.require_teacher), db: AsyncSession = Depends(get_db),
):
    plan = await owned(db, teacher, sequence_id, lock=True)
    if body.revision != plan.revision:
        raise HTTPException(409, "This plan changed elsewhere. Refresh before editing.")
    await validate_body(db, teacher, body, plan.class_id, plan.subject_id)
    plan.title, plan.steps = body.title.strip(), [step.model_dump() for step in body.steps]
    plan.revision += 1
    await db.commit()
    return {"ok": True, "plan": payload(plan)}


@router.post("/teacher-sequences/{sequence_id}/remove")
async def delete_plan(
    sequence_id: int, revision: int,
    teacher: models.User = Depends(auth.require_teacher), db: AsyncSession = Depends(get_db),
):
    plan = await owned(db, teacher, sequence_id, lock=True)
    if revision != plan.revision:
        raise HTTPException(409, "This plan changed elsewhere. Refresh before removing.")
    await db.delete(plan)
    await db.commit()
    return {"ok": True}


@router.post("/teacher-sequences/{sequence_id}/steps/{position}/prepare")
async def prepare_step(
    sequence_id: int, position: int, revision: int, session_id: int | None = None,
    teacher: models.User = Depends(auth.require_teacher), db: AsyncSession = Depends(get_db),
):
    plan = await owned(db, teacher, sequence_id)
    if revision != plan.revision:
        raise HTTPException(409, "This sequence changed. Refresh and select the intended step again.")
    if session_id is not None:
        current = await workspace(db, teacher, session_id=session_id)
        if current != (plan.class_id, plan.subject_id):
            raise HTTPException(403, "This plan does not belong to this live classroom")
    if position < 0 or position >= len(plan.steps):
        raise HTTPException(404, "Selected sequence step not found")
    step = Step.model_validate(plan.steps[position]).model_dump()
    if step["kind"] == "audio":
        audio = await recording(db, teacher, step["audio_id"], plan.class_id, plan.subject_id)
        if not os.path.isfile(audio.file_path):
            raise HTTPException(409, "The selected recording file is unavailable. No classroom action was run.")
        step["text"] = audio.title
    return {"ok": True, "sequence_id": plan.sequence_id, "revision": plan.revision, "position": position, "step": step}
