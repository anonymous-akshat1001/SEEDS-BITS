"""Administrators authoring quizzes and journeys on a teacher's behalf."""

import sys
from pathlib import Path

import pytest
import pytest_asyncio
from fastapi import HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import auth  # noqa: E402
import classroom  # noqa: E402
import journey_routes as jr  # noqa: E402
import journey_schemas as js  # noqa: E402
import main  # noqa: E402
import models  # noqa: E402
import quiz_routes  # noqa: E402
import quiz_schemas as qs  # noqa: E402
import teacher_notices  # noqa: E402


@pytest_asyncio.fixture
async def school(tmp_path, monkeypatch):
    engine = create_async_engine(
        "sqlite+aiosqlite://", poolclass=StaticPool, connect_args={"check_same_thread": False},
    )
    async with engine.begin() as connection:
        await connection.run_sync(models.Base.metadata.create_all)
    factory = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    pushes = []

    async def fake_push(tokens, **kwargs):
        pushes.append((sorted(tokens), kwargs))
        return {"success": len(tokens), "failure": 0}

    monkeypatch.setattr(quiz_routes.fcm_service, "send_to_multiple", fake_push)
    async with factory() as db:
        class_six = models.SchoolClass(name="Class 6", sort_order=1)
        english = models.Subject(name="English")
        maths = models.Subject(name="Maths")
        admin = models.User(name="Admin", phone_number="9200000000", role="admin", password_hash="x")
        rao = models.User(name="Mrs Rao", phone_number="9200000001", role="teacher", password_hash="x")
        das = models.User(name="Mr Das", phone_number="9200000002", role="teacher", password_hash="x")
        asha = models.User(name="Asha", phone_number="9200000003", role="student", password_hash="x")
        db.add_all([class_six, english, maths, admin, rao, das, asha])
        await db.flush()
        db.add_all([
            models.ClassSubjectAssociation(class_id=class_six.class_id, subject_id=english.subject_id),
            models.ClassSubjectAssociation(class_id=class_six.class_id, subject_id=maths.subject_id),
        ])
        await db.flush()
        db.add_all([
            models.TeacherClassSubjectAssignment(
                teacher_id=rao.user_id, class_id=class_six.class_id, subject_id=english.subject_id,
            ),
            models.TeacherClassSubjectAssignment(
                teacher_id=das.user_id, class_id=class_six.class_id, subject_id=english.subject_id,
            ),
            models.TeacherClassSubjectAssignment(
                teacher_id=das.user_id, class_id=class_six.class_id, subject_id=maths.subject_id,
            ),
            models.StudentClassMembership(student_id=asha.user_id, class_id=class_six.class_id),
            models.FCMToken(user_id=asha.user_id, token="asha-phone"),
        ])
        path = tmp_path / "story.mp3"
        path.write_bytes(b"story")
        rao_audio = models.AudioFile(
            title="Rao story", file_path=str(path), mime_type="audio/mpeg",
            uploaded_by=rao.user_id, class_id=class_six.class_id, subject_id=english.subject_id,
        )
        das_audio = models.AudioFile(
            title="Das story", file_path=str(path), mime_type="audio/mpeg",
            uploaded_by=das.user_id, class_id=class_six.class_id, subject_id=english.subject_id,
        )
        db.add_all([rao_audio, das_audio])
        await db.commit()
        yield db, dict(
            class_six=class_six, english=english, maths=maths, admin=admin, rao=rao, das=das,
            asha=asha, rao_audio=rao_audio, das_audio=das_audio,
        ), pushes
    await engine.dispose()


async def as_admin(db, data, teacher="rao"):
    return await auth.acting_teacher(data["admin"], data[teacher].user_id, None, db)


async def as_self(db, data, teacher="rao"):
    return await auth.acting_teacher(data[teacher], None, None, db)


def question(text="Which word is a noun?", **extra):
    return dict(
        question_text=text, options=["Dog", "Run", "Quickly", "Blue"],
        correct_option_index=0, **extra,
    )


def workspace(data, subject="english"):
    return {"class_id": data["class_six"].class_id, "subject_id": data[subject].subject_id}


async def home_notices(db, teacher):
    return (await classroom.home(teacher, db))["admin_notices"]


@pytest.mark.asyncio
async def test_acting_teacher_resolves_only_active_teachers(school):
    db, data, _ = school
    assert (await as_admin(db, data)).user_id == data["rao"].user_id
    assert auth.acting_admin_id(db, data["rao"]) == data["admin"].user_id
    assert (await as_self(db, data)).user_id == data["rao"].user_id
    assert auth.acting_admin_id(db, data["rao"]) is None
    # A teacher's header is ignored: they always act as themselves.
    assert (await auth.acting_teacher(data["rao"], data["das"].user_id, None, db)).user_id == data["rao"].user_id
    assert (await auth.acting_teacher(data["admin"], None, data["das"].user_id, db)).user_id == data["das"].user_id
    for target, code in ((None, 422), (data["asha"].user_id, 404), (999, 404)):
        with pytest.raises(HTTPException) as error:
            await auth.acting_teacher(data["admin"], target, None, db)
        assert error.value.status_code == code
    with pytest.raises(HTTPException) as student:
        await auth.acting_teacher(data["asha"], data["rao"].user_id, None, db)
    assert student.value.status_code == 403
    data["das"].is_active = False
    await db.commit()
    with pytest.raises(HTTPException) as inactive:
        await auth.acting_teacher(data["admin"], data["das"].user_id, None, db)
    assert inactive.value.status_code == 409


@pytest.mark.asyncio
async def test_admin_creates_and_publishes_quiz_for_teacher_with_new_and_bank_questions(school):
    db, data, pushes = school
    teacher = await as_self(db, data)
    bank = await quiz_routes.create_bank_question(
        qs.BankQuestionCreate(**workspace(data), **question("Pick the verb")), teacher, db,
    )
    teacher = await as_admin(db, data)
    listed = await quiz_routes.list_bank_questions(
        data["class_six"].class_id, data["english"].subject_id, "", False, 100, teacher, db,
    )
    assert [item["question_id"] for item in listed] == [bank["question_id"]]
    quiz = await quiz_routes.create_quiz(qs.QuizCreate(**workspace(data), title="Nouns"), teacher, db)
    assert quiz["owner_teacher_id"] == data["rao"].user_id
    quiz = await quiz_routes.create_and_add_question(
        quiz["quiz_id"], qs.AddNewQuestion(**question()), teacher, db,
    )
    quiz = await quiz_routes.add_bank_question_to_quiz(
        quiz["quiz_id"], qs.AddBankQuestion(question_id=bank["question_id"]), teacher, db,
    )
    assert quiz["question_count"] == 2
    readiness = await quiz_routes.quiz_readiness(quiz["quiz_id"], teacher, db)
    assert readiness == {"ready": True, "errors": []}
    published = await quiz_routes.publish_quiz(quiz["quiz_id"], teacher, db)
    assert published["status"] == "published"
    assert published["notification_recipients"] == 1
    assert pushes[-1][0] == ["asha-phone"]
    assert "Mrs Rao published 'Nouns'" in pushes[-1][1]["body"]
    new_bank = (await db.execute(select(models.QuestionBankQuestion).where(
        models.QuestionBankQuestion.question_text == "Which word is a noun?",
    ))).scalar_one()
    assert new_bank.owner_teacher_id == data["rao"].user_id
    job = (await db.execute(select(models.ScheduledJob).where(
        models.ScheduledJob.kind == "quiz_auto_reminder",
    ))).scalar_one()
    assert job.payload == {"quiz_id": quiz["quiz_id"]}
    closed = await quiz_routes.close_quiz(quiz["quiz_id"], await as_admin(db, data), db)
    assert closed["status"] == "closed"
    notices = await home_notices(db, data["rao"])
    assert [(n["kind"], n["title"], n["action"]) for n in notices] == [
        ("quiz", "Nouns", "created"), ("quiz", "Nouns", "published"), ("quiz", "Nouns", "closed"),
    ]
    assert set(notices[0]) == {"notice_id", "kind", "title", "action"}
    stored = (await db.execute(select(models.TeacherNotice))).scalars().all()
    assert {row.actor_id for row in stored} == {data["admin"].user_id}
    assert {row.item_id for row in stored} == {quiz["quiz_id"]}
    assert await home_notices(db, data["das"]) == []


@pytest.mark.asyncio
async def test_admin_cannot_use_other_teachers_bank_or_unassigned_workspace(school):
    db, data, _ = school
    das = await as_self(db, data, "das")
    foreign = await quiz_routes.create_bank_question(
        qs.BankQuestionCreate(**workspace(data), **question("Das question")), das, db,
    )
    teacher = await as_admin(db, data)
    with pytest.raises(HTTPException) as unassigned:
        await quiz_routes.create_quiz(qs.QuizCreate(**workspace(data, "maths"), title="Sums"), teacher, db)
    assert unassigned.value.status_code == 403
    quiz = await quiz_routes.create_quiz(qs.QuizCreate(**workspace(data), title="Nouns"), teacher, db)
    with pytest.raises(HTTPException) as hidden:
        await quiz_routes.add_bank_question_to_quiz(
            quiz["quiz_id"], qs.AddBankQuestion(question_id=foreign["question_id"]), teacher, db,
        )
    assert hidden.value.status_code == 404
    with pytest.raises(HTTPException) as bank:
        await quiz_routes.get_bank_question(foreign["question_id"], teacher, db)
    assert bank.value.status_code == 404
    with pytest.raises(HTTPException) as other_quiz:
        await quiz_routes.get_teacher_quiz(quiz["quiz_id"], await as_admin(db, data, "das"), db)
    assert other_quiz.value.status_code == 404
    with pytest.raises(HTTPException) as empty:
        await quiz_routes.publish_quiz(quiz["quiz_id"], await as_admin(db, data), db)
    assert empty.value.status_code == 422
    # Failed attempts leave only the successful creation notice.
    assert [n["action"] for n in await home_notices(db, data["rao"])] == ["created"]


@pytest.mark.asyncio
async def test_admin_journey_uses_only_that_teachers_recordings(school):
    db, data, pushes = school
    teacher = await as_admin(db, data)
    audio = await main.list_audio_files(
        data["english"].subject_id, data["admin"], db, data["rao"].user_id, None,
    )
    assert [item["title"] for item in audio] == ["Rao story"]
    with pytest.raises(HTTPException) as no_target:
        await main.list_audio_files(None, data["admin"], db, None, None)
    assert no_target.value.status_code == 403
    created = (await jr.create_journey(js.JourneyCreate(**workspace(data), title="Stories"), teacher, db))["journey"]
    with pytest.raises(HTTPException) as foreign:
        await jr.update_journey(created["journey_id"], js.JourneyUpdate(
            revision=created["revision"], title="Stories",
            steps=[{"kind": "audio", "audio_id": data["das_audio"].audio_id}],
        ), teacher, db)
    assert foreign.value.status_code == 403
    updated = (await jr.update_journey(created["journey_id"], js.JourneyUpdate(
        revision=created["revision"], title="Stories", graded=True,
        steps=[
            {"kind": "narration", "text": "Listen well."},
            {"kind": "audio", "audio_id": data["rao_audio"].audio_id},
            {"kind": "question", "text": "Who told it?", "options": ["Rao", "Das"], "correct_index": 0},
            {"kind": "poll", "text": "Did you like it?", "options": ["Yes", "No"]},
        ],
    ), teacher, db))["journey"]
    assert updated["owner_teacher_id"] == data["rao"].user_id
    published = await jr.publish_journey(
        updated["journey_id"], js.RevisionBody(revision=updated["revision"]), teacher, db,
    )
    assert published["notifications"]["recipients"] == 1
    listed = await jr.list_teacher_journeys(
        data["class_six"].class_id, data["english"].subject_id, await as_self(db, data), db,
    )
    assert [item["title"] for item in listed["journeys"]] == ["Stories"]
    teacher = await as_admin(db, data)
    archived = await jr.archive_journey(
        updated["journey_id"], js.RevisionBody(revision=updated["revision"]), teacher, db,
    )
    assert archived["journey"]["status"] == "archived"
    notices = await home_notices(db, data["rao"])
    assert [(n["kind"], n["action"]) for n in notices] == [
        ("journey", "created"), ("journey", "published"), ("journey", "archived"),
    ]


@pytest.mark.asyncio
async def test_teacher_own_changes_create_no_notices_and_notices_can_be_marked_seen(school):
    db, data, _ = school
    teacher = await as_self(db, data)
    quiz = await quiz_routes.create_quiz(qs.QuizCreate(**workspace(data), title="Own"), teacher, db)
    await quiz_routes.create_and_add_question(quiz["quiz_id"], qs.AddNewQuestion(**question()), teacher, db)
    await quiz_routes.publish_quiz(quiz["quiz_id"], teacher, db)
    await jr.create_journey(js.JourneyCreate(**workspace(data), title="Own trip"), teacher, db)
    assert await home_notices(db, data["rao"]) == []
    admin_quiz = await quiz_routes.create_quiz(
        qs.QuizCreate(**workspace(data), title="From office"), await as_admin(db, data), db,
    )
    await quiz_routes.create_quiz(
        qs.QuizCreate(**workspace(data), title="For Das"), await as_admin(db, data, "das"), db,
    )
    notices = await home_notices(db, data["rao"])
    assert [n["title"] for n in notices] == ["From office"]
    das_notice = (await home_notices(db, data["das"]))[0]["notice_id"]
    # Another teacher's notice ids are ignored.
    result = await teacher_notices.mark_seen(
        teacher_notices.SeenBody(notice_ids=[notices[0]["notice_id"], das_notice]), data["rao"], db,
    )
    assert result == {"ok": True, "seen": 1}
    assert await home_notices(db, data["rao"]) == []
    assert len(await home_notices(db, data["das"])) == 1
    again = await teacher_notices.mark_seen(
        teacher_notices.SeenBody(notice_ids=[notices[0]["notice_id"]]), data["rao"], db,
    )
    assert again["seen"] == 0
    assert admin_quiz["owner_teacher_id"] == data["rao"].user_id
