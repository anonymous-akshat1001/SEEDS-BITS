"""Learning journeys: recordings, narration, questions and polls played as one flow.

Teachers author a private draft and publish immutable snapshots. Students play a
snapshot online or after downloading it, and later sync their runs. The server
recomputes correctness and scores from the snapshot the run was played against.
"""

import os
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from pydantic import TypeAdapter, ValidationError
from sqlalchemy import func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

import access_control as access
import auth
import journey_schemas as js
import models
from database import get_db
from notification_service import fcm_service
from quiz_routes import _score

router = APIRouter(tags=["Learning journeys"])

CONTENT_KINDS = ("audio", "narration")
ANSWER_KINDS = ("question", "poll")
_step_adapter = TypeAdapter(js.Step)


def _now() -> datetime:
    return datetime.utcnow()


def _naive_utc(value: datetime) -> datetime:
    if value.tzinfo is not None:
        value = value.astimezone(timezone.utc).replace(tzinfo=None)
    return value


def _not_found() -> HTTPException:
    return HTTPException(status_code=404, detail="Learning journey not found.")


async def _owned(db: AsyncSession, teacher: models.User, journey_id: int, *, lock: bool = False):
    query = select(models.LearningJourney).where(
        models.LearningJourney.journey_id == journey_id,
    ).execution_options(populate_existing=True)
    if lock:
        query = query.with_for_update()
    journey = (await db.execute(query)).scalar_one_or_none()
    if journey is None or journey.owner_teacher_id != teacher.user_id:
        raise _not_found()
    await access.require_teacher_assignment(db, teacher.user_id, journey.class_id, journey.subject_id)
    return journey


def _require_revision(journey: models.LearningJourney, revision: int) -> None:
    if revision != journey.revision:
        raise HTTPException(
            status_code=409,
            detail="This journey changed on another phone. Refresh before trying again.",
        )


def _effective_replay(steps: list[dict], index: int) -> int | None:
    explicit = steps[index].get("replay_from")
    if explicit is not None:
        return explicit
    start = 0
    for position in range(index - 1, -1, -1):
        if steps[position]["kind"] in ANSWER_KINDS:
            start = position + 1
            break
    for position in range(start, index):
        if steps[position]["kind"] in CONTENT_KINDS:
            return position
    return None


def _counts(steps: list[dict]) -> dict:
    return {
        "step_count": len(steps),
        "question_count": sum(step["kind"] == "question" for step in steps),
        "poll_count": sum(step["kind"] == "poll" for step in steps),
        "recording_count": sum(step["kind"] == "audio" for step in steps),
    }


def _teacher_payload(journey: models.LearningJourney, *, include_steps: bool = True) -> dict:
    payload = {
        "journey_id": journey.journey_id,
        "owner_teacher_id": journey.owner_teacher_id,
        "class_id": journey.class_id,
        "subject_id": journey.subject_id,
        "title": journey.title,
        "description": journey.description,
        "status": journey.status,
        "graded": journey.graded,
        "max_retries": journey.max_retries,
        "revision": journey.revision,
        "published_revision": journey.published_revision,
        "published_at": journey.published_at,
        "has_unpublished_changes": (
            journey.published_from_revision is not None
            and journey.published_from_revision != journey.revision
        ),
        **_counts(journey.steps or []),
    }
    if include_steps:
        payload["steps"] = journey.steps or []
    return payload


async def _resolve_steps(
    db: AsyncSession, teacher: models.User, journey_class: int, journey_subject: int, steps,
) -> list[dict]:
    resolved = []
    for index, step in enumerate(steps):
        data = step.model_dump()
        if step.kind == "audio":
            audio = await db.get(models.AudioFile, step.audio_id)
            if audio is None:
                raise HTTPException(
                    status_code=409,
                    detail=f"The recording in step {index + 1} is no longer available. Remove or replace that step.",
                )
            if (
                audio.uploaded_by != teacher.user_id
                or (audio.class_id, audio.subject_id) != (journey_class, journey_subject)
            ):
                raise HTTPException(
                    status_code=403,
                    detail=f"Step {index + 1} must use your own recording from this class and subject.",
                )
            data["title"] = audio.title
        elif step.kind == "question" and step.source_question_id is not None:
            source = await db.get(models.QuestionBankQuestion, step.source_question_id)
            if source is None or source.owner_teacher_id != teacher.user_id:
                raise HTTPException(status_code=404, detail="Question bank entry not found.")
        resolved.append(data)
    return resolved


async def _build_snapshot(
    db: AsyncSession, journey: models.LearningJourney, revision: int,
) -> tuple[dict, list[str], list[str]]:
    """Returns student-facing content, blocking issues and non-blocking warnings."""
    issues: list[str] = []
    warnings: list[str] = []
    raw_steps = journey.steps or []
    steps: list[dict] = []
    for index, raw in enumerate(raw_steps):
        number = index + 1
        try:
            step = _step_adapter.validate_python(raw)
        except ValidationError:
            issues.append(f"Step {number} could not be read. Edit or remove it.")
            continue
        if step.kind == "audio":
            audio = await db.get(models.AudioFile, step.audio_id)
            if audio is None or not os.path.isfile(audio.file_path):
                issues.append(f"The recording in step {number} is unavailable. Remove or replace it.")
                continue
            steps.append({
                "kind": "audio", "audio_id": audio.audio_id, "title": audio.title,
                "mime_type": audio.mime_type, "duration": audio.duration,
            })
        elif step.kind == "narration":
            steps.append({"kind": "narration", "text": step.text})
        elif step.kind == "question":
            replay = _effective_replay(raw_steps, index)
            if replay is None:
                warnings.append(f"Question in step {number} has no recording or narration before it to replay.")
            if not step.explanation:
                warnings.append(f"Question in step {number} has no explanation.")
            steps.append({
                "kind": "question", "text": step.text, "options": step.options,
                "correct_index": step.correct_index, "explanation": step.explanation,
                "replay_from": replay,
            })
        else:
            steps.append({"kind": "poll", "text": step.text, "options": step.options})
    if not raw_steps:
        issues.append("Add at least one step before publishing.")
    elif not any(step["kind"] in CONTENT_KINDS for step in raw_steps):
        warnings.append("This journey has no recording or narration.")
    if journey.graded and not any(step["kind"] == "question" for step in raw_steps):
        issues.append("A graded journey needs at least one question. Add a question or turn grading off.")
    subject = await db.get(models.Subject, journey.subject_id)
    snapshot = {
        "journey_id": journey.journey_id,
        "revision": revision,
        "class_id": journey.class_id,
        "subject_id": journey.subject_id,
        "subject_name": subject.name if subject else None,
        "title": journey.title,
        "description": journey.description,
        "graded": journey.graded,
        "max_retries": journey.max_retries,
        "steps": steps,
    }
    return snapshot, issues, warnings


async def _eligible_students(db: AsyncSession, class_id: int) -> list[models.User]:
    return list((await db.execute(
        select(models.User)
        .join(models.StudentClassMembership, models.StudentClassMembership.student_id == models.User.user_id)
        .where(
            models.StudentClassMembership.class_id == class_id,
            models.StudentClassMembership.is_active.is_(True),
            models.User.role == "student",
        )
        .order_by(models.User.name)
    )).scalars().all())


async def _notify_published(db: AsyncSession, journey: models.LearningJourney) -> dict:
    students = await _eligible_students(db, journey.class_id)
    if not students:
        return {"recipients": 0, "success": 0, "failure": 0}
    tokens = (await db.execute(select(models.FCMToken.token).where(
        models.FCMToken.user_id.in_([student.user_id for student in students]),
    ))).scalars().all()
    try:
        delivery = await fcm_service.send_to_multiple(
            list(tokens),
            title="New learning journey",
            body=f"{journey.title} is ready to play.",
            data={"type": "journey_published", "journey_id": str(journey.journey_id)},
        )
    except Exception:  # Delivery problems never undo a publication.
        delivery = {"success": 0, "failure": len(tokens)}
    return {"recipients": len(students), **delivery}


# ─── Teacher authoring ──────────────────────────────────────────────────────


@router.get("/teacher/journeys")
async def list_teacher_journeys(
    class_id: int, subject_id: int,
    teacher: models.User = Depends(auth.require_teacher), db: AsyncSession = Depends(get_db),
):
    await access.require_teacher_assignment(db, teacher.user_id, class_id, subject_id)
    journeys = (await db.execute(select(models.LearningJourney).where(
        models.LearningJourney.owner_teacher_id == teacher.user_id,
        models.LearningJourney.class_id == class_id,
        models.LearningJourney.subject_id == subject_id,
    ).order_by(models.LearningJourney.updated_at.desc(), models.LearningJourney.journey_id.desc()))).scalars().all()
    return {
        "class_id": class_id, "subject_id": subject_id,
        "journeys": [_teacher_payload(journey, include_steps=False) for journey in journeys],
    }


@router.post("/teacher/journeys")
async def create_journey(
    body: js.JourneyCreate,
    teacher: models.User = Depends(auth.require_teacher), db: AsyncSession = Depends(get_db),
):
    await access.require_teacher_assignment(db, teacher.user_id, body.class_id, body.subject_id)
    journey = models.LearningJourney(
        owner_teacher_id=teacher.user_id, class_id=body.class_id, subject_id=body.subject_id,
        title=body.title, steps=[], revision=1, status="draft", graded=False, max_retries=1,
    )
    db.add(journey)
    await db.commit()
    await db.refresh(journey)
    return {"ok": True, "journey": _teacher_payload(journey)}


@router.get("/teacher/journeys/{journey_id}")
async def get_teacher_journey(
    journey_id: int,
    teacher: models.User = Depends(auth.require_teacher), db: AsyncSession = Depends(get_db),
):
    return {"journey": _teacher_payload(await _owned(db, teacher, journey_id))}


@router.put("/teacher/journeys/{journey_id}")
async def update_journey(
    journey_id: int, body: js.JourneyUpdate,
    teacher: models.User = Depends(auth.require_teacher), db: AsyncSession = Depends(get_db),
):
    journey = await _owned(db, teacher, journey_id, lock=True)
    _require_revision(journey, body.revision)
    steps = await _resolve_steps(db, teacher, journey.class_id, journey.subject_id, body.steps)
    journey.title = body.title
    journey.description = body.description
    journey.graded = body.graded
    journey.max_retries = body.max_retries
    journey.steps = steps
    journey.revision += 1
    journey.updated_at = _now()
    await db.commit()
    return {"ok": True, "journey": _teacher_payload(journey)}


@router.get("/teacher/journeys/{journey_id}/preview")
async def preview_journey(
    journey_id: int,
    teacher: models.User = Depends(auth.require_teacher), db: AsyncSession = Depends(get_db),
):
    journey = await _owned(db, teacher, journey_id)
    snapshot, issues, warnings = await _build_snapshot(db, journey, (journey.published_revision or 0) + 1)
    return {
        "revision": journey.revision, "snapshot": snapshot,
        "issues": issues, "warnings": warnings, **_counts(journey.steps or []),
    }


@router.post("/teacher/journeys/{journey_id}/publish")
async def publish_journey(
    journey_id: int, body: js.RevisionBody,
    teacher: models.User = Depends(auth.require_teacher), db: AsyncSession = Depends(get_db),
):
    journey = await _owned(db, teacher, journey_id, lock=True)
    _require_revision(journey, body.revision)
    revision = (journey.published_revision or 0) + 1
    snapshot, issues, _ = await _build_snapshot(db, journey, revision)
    if issues:
        raise HTTPException(status_code=409, detail=" ".join(issues))
    now = _now()
    db.add(models.JourneySnapshot(journey_id=journey.journey_id, revision=revision, content=snapshot, published_at=now))
    journey.published_revision = revision
    journey.published_from_revision = journey.revision
    journey.published_at = now
    journey.status = "published"
    await db.commit()
    notifications = await _notify_published(db, journey)
    return {"ok": True, "journey": _teacher_payload(journey), "notifications": notifications}


@router.post("/teacher/journeys/{journey_id}/archive")
async def archive_journey(
    journey_id: int, body: js.RevisionBody,
    teacher: models.User = Depends(auth.require_teacher), db: AsyncSession = Depends(get_db),
):
    journey = await _owned(db, teacher, journey_id, lock=True)
    _require_revision(journey, body.revision)
    if journey.status != "published":
        raise HTTPException(status_code=409, detail="Only a published journey can be archived.")
    journey.status = "archived"
    await db.commit()
    return {"ok": True, "journey": _teacher_payload(journey)}


@router.post("/teacher/journeys/{journey_id}/restore")
async def restore_journey(
    journey_id: int, body: js.RevisionBody,
    teacher: models.User = Depends(auth.require_teacher), db: AsyncSession = Depends(get_db),
):
    journey = await _owned(db, teacher, journey_id, lock=True)
    _require_revision(journey, body.revision)
    if journey.status != "archived" or journey.published_revision is None:
        raise HTTPException(status_code=409, detail="Only an archived journey can be restored.")
    journey.status = "published"
    await db.commit()
    return {"ok": True, "journey": _teacher_payload(journey)}


@router.post("/teacher/journeys/{journey_id}/duplicate")
async def duplicate_journey(
    journey_id: int,
    teacher: models.User = Depends(auth.require_teacher), db: AsyncSession = Depends(get_db),
):
    source = await _owned(db, teacher, journey_id)
    copy = models.LearningJourney(
        owner_teacher_id=teacher.user_id, class_id=source.class_id, subject_id=source.subject_id,
        title=f"Copy of {source.title}"[:160], description=source.description,
        graded=source.graded, max_retries=source.max_retries,
        steps=list(source.steps or []), revision=1, status="draft",
    )
    db.add(copy)
    await db.commit()
    await db.refresh(copy)
    return {"ok": True, "journey": _teacher_payload(copy)}


@router.delete("/teacher/journeys/{journey_id}")
async def delete_journey(
    journey_id: int, revision: int,
    teacher: models.User = Depends(auth.require_teacher), db: AsyncSession = Depends(get_db),
):
    journey = await _owned(db, teacher, journey_id, lock=True)
    _require_revision(journey, revision)
    played = await db.scalar(select(func.count()).select_from(models.JourneyRun).where(
        models.JourneyRun.journey_id == journey.journey_id,
    ))
    if played:
        raise HTTPException(
            status_code=409,
            detail="Students have played this journey, so it cannot be deleted. Archive it instead.",
        )
    await db.delete(journey)
    await db.commit()
    return {"ok": True}


@router.get("/teacher/journeys/{journey_id}/results")
async def journey_results(
    journey_id: int,
    teacher: models.User = Depends(auth.require_teacher), db: AsyncSession = Depends(get_db),
):
    journey = await _owned(db, teacher, journey_id)
    students = await _eligible_students(db, journey.class_id)
    runs = (await db.execute(select(models.JourneyRun).where(
        models.JourneyRun.journey_id == journey.journey_id,
    ).order_by(models.JourneyRun.started_at))).scalars().all()
    by_student: dict[int, list[models.JourneyRun]] = {}
    for run in runs:
        if run.student_id is not None:
            by_student.setdefault(run.student_id, []).append(run)

    rows = []
    percentages = []
    for student in students:
        own = by_student.get(student.user_id, [])
        completed = sorted(
            (run for run in own if run.status == "completed"), key=lambda run: run.completed_at,
        )
        first = completed[0] if completed else (own[-1] if own else None)
        status = "completed" if completed else "in_progress" if own else "not_started"
        percentage = completed[0].percentage_score if completed and journey.graded else None
        if percentage is not None:
            percentages.append(percentage)
        rows.append({
            "student_id": student.user_id, "name": student.name, "status": status,
            "runs": len(own), "completed_runs": len(completed),
            "first_try_correct": first.first_try_correct if first else 0,
            "question_count": first.question_count if first else 0,
            "replays": first.replays if first else 0,
            "percentage": percentage,
        })

    questions, polls = [], []
    if journey.published_revision is not None:
        snapshot = await db.get(models.JourneySnapshot, (journey.journey_id, journey.published_revision))
        current = [run.run_id for run in runs if run.journey_revision == journey.published_revision]
        answers = (await db.execute(select(models.JourneyAnswer).where(
            models.JourneyAnswer.run_id.in_(current),
        ))).scalars().all() if current else []
        per_step: dict[int, list[models.JourneyAnswer]] = {}
        for answer in answers:
            per_step.setdefault(answer.step_index, []).append(answer)
        for index, step in enumerate(snapshot.content["steps"] if snapshot else []):
            given = per_step.get(index, [])
            first_tries = [answer for answer in given if answer.attempt == 0]
            if step["kind"] == "question":
                attempts_per_run: dict[str, int] = {}
                for answer in given:
                    attempts_per_run[answer.run_id] = max(attempts_per_run.get(answer.run_id, 0), answer.attempt + 1)
                correct = sum(1 for answer in first_tries if answer.is_correct)
                questions.append({
                    "step_index": index, "text": step["text"], "answered": len(first_tries),
                    "first_try_correct": correct,
                    "first_try_rate": _score(correct, len(first_tries)) if first_tries else None,
                    "average_attempts": (
                        round(sum(attempts_per_run.values()) / len(attempts_per_run), 2)
                        if attempts_per_run else None
                    ),
                })
            elif step["kind"] == "poll":
                counts = [0] * len(step["options"])
                for answer in first_tries:
                    if 0 <= answer.selected_option < len(counts):
                        counts[answer.selected_option] += 1
                polls.append({
                    "step_index": index, "text": step["text"], "answered": len(first_tries),
                    "options": [
                        {"text": option, "count": counts[position]}
                        for position, option in enumerate(step["options"])
                    ],
                })

    return {
        "journey_id": journey.journey_id, "title": journey.title, "graded": journey.graded,
        "revision": journey.published_revision,
        "summary": {
            "eligible": len(students),
            "completed": sum(row["status"] == "completed" for row in rows),
            "in_progress": sum(row["status"] == "in_progress" for row in rows),
            "not_started": sum(row["status"] == "not_started" for row in rows),
            "average_percentage": (
                round(sum(percentages) / len(percentages), 2) if percentages else None
            ),
        },
        "students": rows, "questions": questions, "polls": polls,
    }


# ─── Student playing and sync ───────────────────────────────────────────────


async def _student_journey(
    db: AsyncSession, student: models.User, journey_id: int, *, allow_archived: bool = False,
) -> models.LearningJourney:
    journey = await db.get(models.LearningJourney, journey_id)
    if (
        journey is None
        or journey.published_revision is None
        or journey.status == "draft"
        or (journey.status == "archived" and not allow_archived)
    ):
        raise _not_found()
    membership = await access.get_active_student_membership(db, student.user_id)
    if membership.class_id != journey.class_id:
        raise _not_found()
    try:
        await access.require_active_class_subject(db, journey.class_id, journey.subject_id)
    except HTTPException as error:
        raise _not_found() from error
    return journey


@router.get("/student/journeys")
async def list_student_journeys(
    student: models.User = Depends(auth.require_student), db: AsyncSession = Depends(get_db),
):
    membership = await access.get_active_student_membership(db, student.user_id)
    rows = (await db.execute(
        select(models.LearningJourney, models.Subject.name, models.JourneySnapshot.content)
        .join(models.Subject, models.Subject.subject_id == models.LearningJourney.subject_id)
        .join(
            models.ClassSubjectAssociation,
            (models.ClassSubjectAssociation.class_id == models.LearningJourney.class_id)
            & (models.ClassSubjectAssociation.subject_id == models.LearningJourney.subject_id),
        )
        .join(
            models.JourneySnapshot,
            (models.JourneySnapshot.journey_id == models.LearningJourney.journey_id)
            & (models.JourneySnapshot.revision == models.LearningJourney.published_revision),
        )
        .where(
            models.LearningJourney.class_id == membership.class_id,
            models.LearningJourney.status == "published",
            models.ClassSubjectAssociation.is_active.is_(True),
            models.Subject.is_active.is_(True),
        )
        .order_by(models.LearningJourney.published_at.desc())
    )).all()
    ids = [journey.journey_id for journey, _, _ in rows]
    runs = (await db.execute(select(models.JourneyRun).where(
        models.JourneyRun.student_id == student.user_id,
        models.JourneyRun.journey_id.in_(ids),
    ))).scalars().all() if ids else []
    mine: dict[int, list[models.JourneyRun]] = {}
    for run in runs:
        mine.setdefault(run.journey_id, []).append(run)
    result = []
    for journey, subject_name, content in rows:
        own = mine.get(journey.journey_id, [])
        completed = sorted((run for run in own if run.status == "completed"), key=lambda run: run.completed_at)
        result.append({
            "journey_id": journey.journey_id, "title": journey.title,
            "description": journey.description, "subject_id": journey.subject_id,
            "subject_name": subject_name, "revision": journey.published_revision,
            "graded": journey.graded, "published_at": journey.published_at,
            **_counts(content["steps"]),
            "my_status": "completed" if completed else "in_progress" if own else "new",
            "my_completed_runs": len(completed),
            "my_percentage": completed[0].percentage_score if completed and journey.graded else None,
        })
    return {"journeys": result}


@router.get("/student/journeys/{journey_id}")
async def get_student_journey(
    journey_id: int,
    student: models.User = Depends(auth.require_student), db: AsyncSession = Depends(get_db),
):
    journey = await _student_journey(db, student, journey_id)
    snapshot = await db.get(models.JourneySnapshot, (journey.journey_id, journey.published_revision))
    if snapshot is None:
        raise _not_found()
    return {"snapshot": snapshot.content}


class _Rejected(Exception):
    def __init__(self, reason: str):
        self.reason = reason


async def _sync_one(db: AsyncSession, student: models.User, body: js.SyncRun, snapshots: dict) -> None:
    try:
        journey = await _student_journey(db, student, body.journey_id, allow_archived=True)
    except HTTPException:
        raise _Rejected("This journey is no longer available to your class.")
    key = (journey.journey_id, body.journey_revision)
    if key not in snapshots:
        snapshots[key] = await db.get(models.JourneySnapshot, key)
    snapshot = snapshots[key]
    if snapshot is None:
        raise _Rejected("This journey version is unknown.")
    content = snapshot.content
    steps = content["steps"]
    max_retries = content.get("max_retries", 0)
    now = _now()

    answers: dict[tuple[int, int], js.SyncAnswer] = {}
    for answer in body.answers:
        if answer.step_index >= len(steps) or steps[answer.step_index]["kind"] not in ANSWER_KINDS:
            raise _Rejected("An answer did not match a question in this journey.")
        step = steps[answer.step_index]
        if answer.selected_option >= len(step["options"]):
            raise _Rejected("An answer chose an option that does not exist.")
        limit = 0 if step["kind"] == "poll" else max_retries
        if answer.attempt > limit:
            raise _Rejected("An answer had more attempts than this journey allows.")
        answers.setdefault((answer.step_index, answer.attempt), answer)

    run = await db.get(models.JourneyRun, body.run_id)
    if run is not None and (
        run.student_id != student.user_id
        or (run.journey_id, run.journey_revision) != key
    ):
        raise _Rejected("This progress record could not be matched to your account.")
    if run is None:
        run = models.JourneyRun(
            run_id=body.run_id, journey_id=journey.journey_id, journey_revision=body.journey_revision,
            student_id=student.user_id, status="in_progress",
            started_at=min(_naive_utc(body.started_at), now), synced_at=now,
            played_offline=body.played_offline,
        )
        db.add(run)
        await db.flush()
    existing = (await db.execute(select(models.JourneyAnswer).where(
        models.JourneyAnswer.run_id == run.run_id,
    ))).scalars().all()
    known = {(answer.step_index, answer.attempt) for answer in existing}
    stored = list(existing)
    for (step_index, attempt), answer in answers.items():
        if (step_index, attempt) in known:
            continue
        step = steps[step_index]
        row = models.JourneyAnswer(
            run_id=run.run_id, step_index=step_index, attempt=attempt,
            selected_option=answer.selected_option,
            is_correct=None if step["kind"] == "poll" else answer.selected_option == step["correct_index"],
            answered_at=min(_naive_utc(answer.answered_at), now),
        )
        db.add(row)
        stored.append(row)

    question_steps = [index for index, step in enumerate(steps) if step["kind"] == "question"]
    run.question_count = len(question_steps)
    run.first_try_correct = sum(
        1 for answer in stored if answer.attempt == 0 and answer.is_correct is True
    )
    run.replays = sum(1 for answer in stored if answer.is_correct is False)
    run.played_offline = run.played_offline or body.played_offline
    run.synced_at = now
    if body.completed_at is not None and run.status != "completed":
        run.status = "completed"
        run.completed_at = min(_naive_utc(body.completed_at), now)
    if run.status == "completed" and content.get("graded") and question_steps:
        run.percentage_score = _score(run.first_try_correct, len(question_steps))


@router.post("/student/journeys/sync")
async def sync_journey_runs(
    body: js.SyncBody,
    student: models.User = Depends(auth.require_student), db: AsyncSession = Depends(get_db),
):
    accepted, rejected = [], []
    snapshots: dict = {}
    for run in body.runs:
        # Every rejection is raised before any row is added for that run.
        try:
            await _sync_one(db, student, run, snapshots)
            accepted.append(run.run_id)
        except _Rejected as rejection:
            rejected.append({"run_id": run.run_id, "reason": rejection.reason})
    await db.commit()
    return {"accepted": accepted, "rejected": rejected}
