import sys
import uuid
from datetime import datetime, timedelta, timezone
from pathlib import Path

import pytest
import pytest_asyncio
from fastapi import HTTPException
from pydantic import ValidationError
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import journey_routes as jr  # noqa: E402
import journey_schemas as js  # noqa: E402
import models  # noqa: E402


@pytest_asyncio.fixture
async def world(tmp_path):
    engine = create_async_engine(
        "sqlite+aiosqlite://", poolclass=StaticPool, connect_args={"check_same_thread": False},
    )
    async with engine.begin() as connection:
        await connection.run_sync(models.Base.metadata.create_all)
    factory = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    async with factory() as db:
        classroom = models.SchoolClass(name="Class 3", sort_order=3)
        other_class = models.SchoolClass(name="Class 4", sort_order=4)
        subject = models.Subject(name="Environment")
        teacher = models.User(name="Teacher", phone_number="9100000001", role="teacher", password_hash="x")
        other_teacher = models.User(name="Other", phone_number="9100000002", role="teacher", password_hash="x")
        asha = models.User(name="Asha", phone_number="9100000003", role="student", password_hash="x")
        ravi = models.User(name="Ravi", phone_number="9100000004", role="student", password_hash="x")
        outsider = models.User(name="Outsider", phone_number="9100000005", role="student", password_hash="x")
        db.add_all([classroom, other_class, subject, teacher, other_teacher, asha, ravi, outsider])
        await db.flush()
        db.add_all([
            models.ClassSubjectAssociation(class_id=classroom.class_id, subject_id=subject.subject_id),
            models.ClassSubjectAssociation(class_id=other_class.class_id, subject_id=subject.subject_id),
        ])
        await db.flush()
        for person in (teacher, other_teacher):
            db.add(models.TeacherClassSubjectAssignment(
                teacher_id=person.user_id, class_id=classroom.class_id, subject_id=subject.subject_id,
            ))
        db.add_all([
            models.StudentClassMembership(student_id=asha.user_id, class_id=classroom.class_id),
            models.StudentClassMembership(student_id=ravi.user_id, class_id=classroom.class_id),
            models.StudentClassMembership(student_id=outsider.user_id, class_id=other_class.class_id),
        ])
        path = tmp_path / "food.mp3"
        path.write_bytes(b"story about food")
        audio = models.AudioFile(
            title="Food story", file_path=str(path), mime_type="audio/mpeg",
            uploaded_by=teacher.user_id, class_id=classroom.class_id, subject_id=subject.subject_id,
        )
        foreign_audio = models.AudioFile(
            title="Not mine", file_path=str(path), mime_type="audio/mpeg",
            uploaded_by=other_teacher.user_id, class_id=classroom.class_id, subject_id=subject.subject_id,
        )
        db.add_all([audio, foreign_audio])
        await db.commit()
        yield db, {
            "classroom": classroom, "subject": subject, "teacher": teacher,
            "other_teacher": other_teacher, "asha": asha, "ravi": ravi, "outsider": outsider,
            "audio": audio, "foreign_audio": foreign_audio, "path": path,
        }
    await engine.dispose()


def food_steps(audio_id):
    return [
        {"kind": "narration", "text": "Let's hear about some food today."},
        {"kind": "audio", "audio_id": audio_id},
        {"kind": "question", "text": "Which grain is in the story?",
         "options": ["Rice", "Stone", "Sand", "Glass"], "correct_index": 0,
         "explanation": "The story talks about rice."},
        {"kind": "poll", "text": "Have you eaten rice this week?", "options": ["Yes", "No"]},
        {"kind": "narration", "text": "Dal is made from lentils."},
        {"kind": "question", "text": "What is dal made from?",
         "options": ["Lentils", "Milk"], "correct_index": 0},
    ]


async def create(db, w, *, graded=False, steps=None, max_retries=1):
    created = await jr.create_journey(js.JourneyCreate(
        class_id=w["classroom"].class_id, subject_id=w["subject"].subject_id, title="Food around us",
    ), w["teacher"], db)
    journey = created["journey"]
    updated = await jr.update_journey(journey["journey_id"], js.JourneyUpdate(
        revision=journey["revision"], title="Food around us", graded=graded, max_retries=max_retries,
        steps=steps if steps is not None else food_steps(w["audio"].audio_id),
    ), w["teacher"], db)
    return updated["journey"]


async def publish(db, w, journey):
    return (await jr.publish_journey(
        journey["journey_id"], js.RevisionBody(revision=journey["revision"]), w["teacher"], db,
    ))["journey"]


def run_body(journey_id, revision, answers, *, completed=True, run_id=None):
    now = datetime.now(timezone.utc)
    return js.SyncRun(
        run_id=run_id or str(uuid.uuid4()), journey_id=journey_id, journey_revision=revision,
        started_at=now - timedelta(minutes=5), completed_at=now if completed else None,
        played_offline=True,
        answers=[
            js.SyncAnswer(step_index=step, attempt=attempt, selected_option=option, answered_at=now)
            for step, attempt, option in answers
        ],
    )


@pytest.mark.asyncio
async def test_authoring_resolves_recordings_and_guards_revision_and_ownership(world):
    db, w = world
    journey = await create(db, w)
    assert journey["revision"] == 2
    assert journey["steps"][1]["title"] == "Food story"
    assert (journey["step_count"], journey["question_count"], journey["poll_count"]) == (6, 2, 1)
    with pytest.raises(HTTPException) as stale:
        await jr.update_journey(journey["journey_id"], js.JourneyUpdate(
            revision=1, title="Stale", steps=[],
        ), w["teacher"], db)
    assert stale.value.status_code == 409
    with pytest.raises(HTTPException) as foreign:
        await jr.update_journey(journey["journey_id"], js.JourneyUpdate(
            revision=2, title="Foreign", steps=[{"kind": "audio", "audio_id": w["foreign_audio"].audio_id}],
        ), w["teacher"], db)
    assert foreign.value.status_code == 403
    with pytest.raises(HTTPException) as hidden:
        await jr.get_teacher_journey(journey["journey_id"], w["other_teacher"], db)
    assert hidden.value.status_code == 404
    listed = await jr.list_teacher_journeys(
        w["classroom"].class_id, w["subject"].subject_id, w["other_teacher"], db,
    )
    assert listed["journeys"] == []


@pytest.mark.parametrize("steps", [
    [{"kind": "question", "text": "Q", "options": ["A", "B"], "correct_index": 2}],
    [{"kind": "question", "text": "Q", "options": ["A", "a"], "correct_index": 0}],
    [{"kind": "poll", "text": "Only one", "options": ["Yes"]}],
    [{"kind": "narration", "text": "   "}],
    [{"kind": "quiz", "text": "Unknown"}],
    [{"kind": "narration", "text": "Intro"},
     {"kind": "question", "text": "Q", "options": ["A", "B"], "correct_index": 0, "replay_from": 1}],
    [{"kind": "poll", "text": "P", "options": ["A", "B"]},
     {"kind": "question", "text": "Q", "options": ["A", "B"], "correct_index": 0, "replay_from": 0}],
])
def test_step_contract_rejects_malformed_steps(steps):
    with pytest.raises(ValidationError):
        js.JourneyUpdate(revision=1, title="T", steps=steps)


@pytest.mark.asyncio
async def test_preview_computes_replay_points_and_publish_blocks_problems(world):
    db, w = world
    journey = await create(db, w)
    preview = await jr.preview_journey(journey["journey_id"], w["teacher"], db)
    steps = preview["snapshot"]["steps"]
    assert steps[2]["replay_from"] == 0
    assert steps[5]["replay_from"] == 4
    assert preview["issues"] == []
    assert any("step 6 has no explanation" in warning for warning in preview["warnings"])

    empty = await create(db, w, steps=[])
    with pytest.raises(HTTPException) as blocked:
        await publish(db, w, empty)
    assert blocked.value.status_code == 409

    graded = await create(db, w, graded=True, steps=[{"kind": "narration", "text": "No questions"}])
    with pytest.raises(HTTPException) as no_question:
        await publish(db, w, graded)
    assert "graded journey needs at least one question" in no_question.value.detail

    w["path"].unlink()
    with pytest.raises(HTTPException) as missing:
        await publish(db, w, journey)
    assert "step 2" in missing.value.detail


@pytest.mark.asyncio
async def test_students_see_only_published_journeys_of_their_class(world):
    db, w = world
    journey = await create(db, w)
    assert (await jr.list_student_journeys(w["asha"], db))["journeys"] == []
    with pytest.raises(HTTPException):
        await jr.get_student_journey(journey["journey_id"], w["asha"], db)

    published = await publish(db, w, journey)
    assert published["status"] == "published" and published["published_revision"] == 1
    listed = (await jr.list_student_journeys(w["asha"], db))["journeys"]
    assert [(item["journey_id"], item["my_status"], item["step_count"]) for item in listed] == [
        (journey["journey_id"], "new", 6),
    ]
    snapshot = (await jr.get_student_journey(journey["journey_id"], w["asha"], db))["snapshot"]
    assert snapshot["revision"] == 1 and snapshot["steps"][1]["audio_id"] == w["audio"].audio_id
    with pytest.raises(HTTPException) as outsider:
        await jr.get_student_journey(journey["journey_id"], w["outsider"], db)
    assert outsider.value.status_code == 404

    archived = await jr.archive_journey(
        journey["journey_id"], js.RevisionBody(revision=published["revision"]), w["teacher"], db,
    )
    assert archived["journey"]["status"] == "archived"
    assert (await jr.list_student_journeys(w["asha"], db))["journeys"] == []
    restored = await jr.restore_journey(
        journey["journey_id"], js.RevisionBody(revision=published["revision"]), w["teacher"], db,
    )
    assert restored["journey"]["status"] == "published"


@pytest.mark.asyncio
async def test_sync_recomputes_correctness_is_idempotent_and_scores_first_tries(world):
    db, w = world
    journey = await publish(db, w, await create(db, w, graded=True))
    journey_id = journey["journey_id"]
    run_id = str(uuid.uuid4())
    # Wrong first try on step 3, correct on the replay; poll answered; step 6 right first time.
    answers = [(2, 0, 1), (2, 1, 0), (3, 0, 0), (5, 0, 0)]
    first = await jr.sync_journey_runs(js.SyncBody(runs=[
        run_body(journey_id, 1, answers, run_id=run_id),
    ]), w["asha"], db)
    assert first == {"accepted": [run_id], "rejected": []}
    again = await jr.sync_journey_runs(js.SyncBody(runs=[
        run_body(journey_id, 1, answers, run_id=run_id),
    ]), w["asha"], db)
    assert again["accepted"] == [run_id]
    run = await db.get(models.JourneyRun, run_id)
    assert (run.status, run.question_count, run.first_try_correct, run.replays) == ("completed", 2, 1, 1)
    assert run.percentage_score == 50.0 and run.played_offline

    stolen = await jr.sync_journey_runs(js.SyncBody(runs=[
        run_body(journey_id, 1, answers, run_id=run_id),
    ]), w["ravi"], db)
    assert stolen["accepted"] == [] and stolen["rejected"][0]["run_id"] == run_id

    invalid = await jr.sync_journey_runs(js.SyncBody(runs=[
        run_body(journey_id, 1, [(5, 0, 3)]),
        run_body(journey_id, 1, [(0, 0, 0)]),
        run_body(journey_id, 1, [(3, 1, 0)]),
        run_body(journey_id, 1, [(2, 2, 0)]),
        run_body(journey_id, 9, [(2, 0, 0)]),
    ]), w["ravi"], db)
    assert invalid["accepted"] == [] and len(invalid["rejected"]) == 5

    outsider = await jr.sync_journey_runs(js.SyncBody(runs=[run_body(journey_id, 1, [])]), w["outsider"], db)
    assert outsider["accepted"] == []

    listed = (await jr.list_student_journeys(w["asha"], db))["journeys"][0]
    assert (listed["my_status"], listed["my_percentage"]) == ("completed", 50.0)


@pytest.mark.asyncio
async def test_old_revision_runs_use_their_own_snapshot_after_republish(world):
    db, w = world
    first = await publish(db, w, await create(db, w, graded=True))
    journey_id = first["journey_id"]
    changed = await jr.update_journey(journey_id, js.JourneyUpdate(
        revision=first["revision"], title="Food around us", graded=True,
        steps=[{"kind": "question", "text": "New only question", "options": ["No", "Yes"], "correct_index": 1}],
    ), w["teacher"], db)
    assert changed["journey"]["has_unpublished_changes"]
    second = await publish(db, w, changed["journey"])
    assert second["published_revision"] == 2
    result = await jr.sync_journey_runs(js.SyncBody(runs=[
        run_body(journey_id, 1, [(2, 0, 0), (3, 0, 1), (5, 0, 0)]),
    ]), w["asha"], db)
    assert len(result["accepted"]) == 1
    run = await db.get(models.JourneyRun, result["accepted"][0])
    assert (run.journey_revision, run.first_try_correct, run.percentage_score) == (1, 2, 100.0)


@pytest.mark.asyncio
async def test_results_summarise_students_questions_and_polls_and_block_delete(world):
    db, w = world
    journey = await publish(db, w, await create(db, w, graded=True))
    journey_id = journey["journey_id"]
    await jr.sync_journey_runs(js.SyncBody(runs=[
        run_body(journey_id, 1, [(2, 0, 0), (3, 0, 0), (5, 0, 0)]),
    ]), w["asha"], db)
    await jr.sync_journey_runs(js.SyncBody(runs=[
        run_body(journey_id, 1, [(2, 0, 2), (3, 0, 1)], completed=False),
    ]), w["ravi"], db)
    results = await jr.journey_results(journey_id, w["teacher"], db)
    assert results["summary"] == {
        "eligible": 2, "completed": 1, "in_progress": 1, "not_started": 0, "average_percentage": 100.0,
    }
    by_name = {row["name"]: row for row in results["students"]}
    assert by_name["Asha"]["percentage"] == 100.0 and by_name["Ravi"]["status"] == "in_progress"
    first_question = results["questions"][0]
    assert (first_question["answered"], first_question["first_try_correct"], first_question["first_try_rate"]) == (
        2, 1, 50.0,
    )
    assert [option["count"] for option in results["polls"][0]["options"]] == [1, 1]

    with pytest.raises(HTTPException) as protected:
        await jr.delete_journey(journey_id, journey["revision"], w["teacher"], db)
    assert protected.value.status_code == 409
    draft = await create(db, w)
    assert (await jr.delete_journey(draft["journey_id"], draft["revision"], w["teacher"], db))["ok"]


@pytest.mark.asyncio
async def test_duplicate_creates_private_draft_copy(world):
    db, w = world
    journey = await publish(db, w, await create(db, w))
    copy = (await jr.duplicate_journey(journey["journey_id"], w["teacher"], db))["journey"]
    assert copy["status"] == "draft" and copy["title"] == "Copy of Food around us"
    assert copy["steps"] == journey["steps"] and copy["published_revision"] is None
