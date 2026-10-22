import sys
from datetime import datetime, timedelta
from pathlib import Path

import pytest
import pytest_asyncio
from fastapi import HTTPException
from pydantic import ValidationError
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import models  # noqa: E402
import quiz_routes  # noqa: E402
import quiz_schemas as qs  # noqa: E402


@pytest_asyncio.fixture
async def quiz_db():
    engine = create_async_engine(
        "sqlite+aiosqlite://",
        poolclass=StaticPool,
        connect_args={"check_same_thread": False},
    )
    async with engine.begin() as connection:
        await connection.run_sync(models.Base.metadata.create_all)
    factory = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    async with factory() as db:
        classroom = models.SchoolClass(name="Class 5", sort_order=5)
        other_class = models.SchoolClass(name="Class 6", sort_order=6)
        subject = models.Subject(name="Science")
        teacher = models.User(
            name="Quiz Teacher",
            phone_number="9111111111",
            role="teacher",
            password_hash="test",
        )
        other_teacher = models.User(
            name="Other Teacher",
            phone_number="9222222222",
            role="teacher",
            password_hash="test",
        )
        student = models.User(
            name="Quiz Student",
            phone_number="9333333333",
            role="student",
            password_hash="test",
        )
        outsider = models.User(
            name="Other Student",
            phone_number="9444444444",
            role="student",
            password_hash="test",
        )
        db.add_all(
            [classroom, other_class, subject, teacher, other_teacher, student, outsider]
        )
        await db.flush()
        db.add_all(
            [
                models.ClassSubjectAssociation(
                    class_id=classroom.class_id,
                    subject_id=subject.subject_id,
                ),
                models.ClassSubjectAssociation(
                    class_id=other_class.class_id,
                    subject_id=subject.subject_id,
                ),
            ]
        )
        await db.flush()
        db.add_all(
            [
                models.TeacherClassSubjectAssignment(
                    teacher_id=teacher.user_id,
                    class_id=classroom.class_id,
                    subject_id=subject.subject_id,
                ),
                models.TeacherClassSubjectAssignment(
                    teacher_id=other_teacher.user_id,
                    class_id=classroom.class_id,
                    subject_id=subject.subject_id,
                ),
                models.StudentClassMembership(
                    student_id=student.user_id,
                    class_id=classroom.class_id,
                ),
                models.StudentClassMembership(
                    student_id=outsider.user_id,
                    class_id=other_class.class_id,
                ),
            ]
        )
        await db.commit()
        yield db, {
            "classroom": classroom,
            "other_class": other_class,
            "subject": subject,
            "teacher": teacher,
            "other_teacher": other_teacher,
            "student": student,
            "outsider": outsider,
        }
    await engine.dispose()


def valid_question(**overrides):
    values = {
        "question_text": "Which planet is known as the Red Planet?",
        "options": ["Earth", "Mars", "Venus", "Jupiter"],
        "correct_option_index": 1,
        "explanation": "Iron oxide makes Mars appear red.",
    }
    values.update(overrides)
    return values


async def assessment_quiz(db, data, **settings):
    quiz = await quiz_routes.create_quiz(qs.QuizCreate(
        class_id=data["classroom"].class_id, subject_id=data["subject"].subject_id,
        title="Accessible assessment", **settings,
    ), data["teacher"], db)
    await quiz_routes.create_and_add_question(quiz["quiz_id"], qs.AddNewQuestion(
        **valid_question(), save_to_bank=False,
    ), data["teacher"], db)
    return await quiz_routes.publish_quiz(quiz["quiz_id"], data["teacher"], db)


def described_question(**overrides):
    return valid_question(
        topics=["Algebra", "Reading notation"],
        notation="described",
        spoken_question_text="Which planet is called the Red Planet?",
        spoken_options=["Earth spoken", "Mars spoken", "Venus spoken", "Jupiter spoken"],
        spoken_explanation="Iron oxide gives Mars a red appearance.",
        spoken_reviewed=True,
        **overrides,
    )


@pytest.mark.parametrize("overrides", [
    {"spoken_reviewed": False}, {"spoken_question_text": None},
    {"spoken_options": ["Only one"]}, {"spoken_explanation": None},
    {"topics": ["Algebra", "algebra"]}, {"topics": ["x" * 81]},
])
def test_notation_requires_teacher_review_and_complete_alternatives(overrides):
    content = described_question()
    content.update(overrides)
    with pytest.raises(ValidationError):
        qs.QuestionContent(**content)


@pytest.mark.asyncio
async def test_revisions_preserve_snapshots_and_spoken_options_follow_shuffled_ids(quiz_db):
    db, data = quiz_db
    teacher = data["teacher"]
    workspace = {"class_id": data["classroom"].class_id, "subject_id": data["subject"].subject_id}
    bank = await quiz_routes.create_bank_question(qs.BankQuestionCreate(**workspace, **described_question()), teacher, db)
    assert bank["revision"] == 1
    quiz = await quiz_routes.create_quiz(qs.QuizCreate(**workspace, title="Revision snapshot"), teacher, db)
    quiz = await quiz_routes.add_bank_question_to_quiz(quiz["quiz_id"], qs.AddBankQuestion(question_id=bank["question_id"]), teacher, db)
    assert quiz["questions"][0]["source_revision"] == 1
    changed = described_question()
    changed.update(question_text="Updated bank question", spoken_question_text="Updated spoken bank question")
    updated = await quiz_routes.update_bank_question(bank["question_id"], qs.BankQuestionUpdate(
        **workspace, **changed, expected_revision=1,
    ), teacher, db)
    assert updated["revision"] == 2
    history = await quiz_routes.bank_question_revisions(bank["question_id"], 0, teacher, db)
    assert [row["revision"] for row in history["revisions"]] == [2, 1]
    assert history["revisions"][1]["content"]["spoken_question_text"] == described_question()["spoken_question_text"]
    assert history["has_more"] is False
    with pytest.raises(HTTPException) as denied:
        await quiz_routes.bank_question_revisions(bank["question_id"], 0, data["other_teacher"], db)
    assert denied.value.status_code == 404
    with pytest.raises(HTTPException) as stale:
        await quiz_routes.update_bank_question(bank["question_id"], qs.BankQuestionUpdate(
            **workspace, **changed, expected_revision=1,
        ), teacher, db)
    assert stale.value.status_code == 409
    await db.rollback()
    # The rollback expires ORM objects; retain only the integer IDs below.
    snapshot = await quiz_routes._get_quiz(db, quiz["quiz_id"])
    question = snapshot.questions[0]
    assert question.source_revision == 1
    assert question.spoken_question_text == described_question()["spoken_question_text"]
    reversed_ids = [option.quiz_option_id for option in reversed(question.options)]
    safe = qs.SafeQuizQuestion(**quiz_routes._safe_question(question, reversed_ids)).model_dump()
    assert [option["spoken_option_text"] for option in safe["options"]] == list(reversed(described_question()["spoken_options"]))
    assert "correct_option_index" not in safe and "spoken_explanation" not in safe
    assert all("is_correct" not in option for option in safe["options"])
    duplicate = await quiz_routes.duplicate_quiz(quiz["quiz_id"], await db.get(models.User, bank["owner_teacher_id"]), db)
    assert duplicate["questions"][0]["source_revision"] == 1
    assert duplicate["questions"][0]["spoken_question_text"] == described_question()["spoken_question_text"]


@pytest.mark.asyncio
async def test_spoken_answer_keys_follow_the_same_release_gate_as_visible_keys(quiz_db):
    db, data = quiz_db
    teacher, student = data["teacher"], data["student"]
    quiz = await quiz_routes.create_quiz(qs.QuizCreate(
        class_id=data["classroom"].class_id, subject_id=data["subject"].subject_id, title="Spoken policy",
    ), teacher, db)
    quiz = await quiz_routes.create_and_add_question(quiz["quiz_id"], qs.AddNewQuestion(**described_question()), teacher, db)
    assert quiz["questions"][0]["source_revision"] == 1
    await quiz_routes.publish_quiz(quiz["quiz_id"], teacher, db)
    attempt = await quiz_routes.start_or_resume_attempt(quiz["quiz_id"], student, db)
    question = attempt["question"]
    assert question["spoken_question_text"] == described_question()["spoken_question_text"]
    feedback = await quiz_routes.submit_answer(attempt["attempt_id"], qs.AnswerSubmission(
        quiz_question_id=question["quiz_question_id"], selected_option_id=question["options"][1]["quiz_option_id"],
    ), student, db)
    assert feedback["selected_option_spoken_text"] == "Mars spoken"
    assert "correct_option_spoken_text" not in feedback and "spoken_explanation" not in feedback
    await quiz_routes.complete_attempt(attempt["attempt_id"], student, db)
    review = await quiz_routes.review_attempt(attempt["attempt_id"], student, db)
    assert review["questions"][0]["correct_option_spoken_text"] == "Mars spoken"
    assert review["questions"][0]["spoken_explanation"] == described_question()["spoken_explanation"]


@pytest.mark.asyncio
@pytest.mark.parametrize("policy", ["after_completion", "scheduled", "score_only"])
async def test_feedback_release_is_enforced_across_answers_completion_history_and_review(quiz_db, monkeypatch, policy):
    db, data = quiz_db
    now = datetime(2026, 10, 21, 10)
    monkeypatch.setattr(quiz_routes, "_now", lambda: now)
    settings = {"feedback_policy": policy}
    if policy == "scheduled":
        settings["feedback_release_at"] = now + timedelta(hours=2)
    quiz = await assessment_quiz(db, data, **settings)
    started = await quiz_routes.start_or_resume_attempt(quiz["quiz_id"], data["student"], db)
    question = quiz["questions"][0]
    correct = next(option for option in question["options"] if option["is_correct"])
    saved = await quiz_routes.submit_answer(started["attempt_id"], qs.AnswerSubmission(
        quiz_question_id=question["quiz_question_id"], selected_option_id=correct["quiz_option_id"],
    ), data["student"], db)
    assert saved["feedback_released"] is False
    assert not {"correct_option_id", "correct_option_text", "is_correct", "explanation"} & saved.keys()
    finished = await quiz_routes.complete_attempt(started["attempt_id"], data["student"], db)
    review = await quiz_routes.review_attempt(started["attempt_id"], data["student"], db)
    history = await quiz_routes.student_attempt_history(quiz["quiz_id"], data["student"], db)
    if policy == "scheduled":
        assert finished["score_released"] is False
        assert finished["percentage_score"] is None
        assert history["highest_score"] is None
        assert review["questions"] == []
        monkeypatch.setattr(quiz_routes, "_now", lambda: now + timedelta(hours=2))
        released = await quiz_routes.review_attempt(started["attempt_id"], data["student"], db)
        assert released["questions"][0]["correct_option_text"] == "Mars"
        assert released["attempt"]["percentage_score"] == 100
    elif policy == "score_only":
        assert finished["percentage_score"] == 100
        assert review["questions"] == []
    else:
        assert finished["percentage_score"] == 100
        assert review["questions"][0]["correct_option_text"] == "Mars"
    teacher_review = await quiz_routes.teacher_attempt_review(quiz["quiz_id"], started["attempt_id"], data["teacher"], db)
    assert teacher_review["questions"][0]["correct_option_text"] == "Mars"


@pytest.mark.asyncio
async def test_practice_is_untimed_unlimited_immediate_and_not_reported_as_academic_scores(quiz_db):
    db, data = quiz_db
    quiz = await assessment_quiz(db, data, mode="practice", attempt_limit=1)
    for number in range(3):
        attempt = await quiz_routes.start_or_resume_attempt(quiz["quiz_id"], data["student"], db)
        assert attempt["deadline_at"] is None
        assert attempt["attempt_number"] == number + 1
        assert attempt["is_graded"] is False
        question = quiz["questions"][0]
        option = next(option for option in question["options"] if option["is_correct"])
        feedback = await quiz_routes.submit_answer(attempt["attempt_id"], qs.AnswerSubmission(
            quiz_question_id=question["quiz_question_id"], selected_option_id=option["quiz_option_id"],
        ), data["student"], db)
        assert feedback["feedback_released"] is True
        assert feedback["correct_option_text"] == "Mars"
        finished = await quiz_routes.complete_attempt(attempt["attempt_id"], data["student"], db)
        assert finished["percentage_score"] is None
    listed = await quiz_routes.get_student_quiz(quiz["quiz_id"], data["student"], db)
    assert listed["attempts_remaining"] is None
    assert listed["highest_score"] is None
    assert listed["can_start_attempt"] is True
    summary = await quiz_routes.quiz_summary(quiz["quiz_id"], data["teacher"], db)
    assert summary["mode"] == "practice" and summary["completed"] == 1
    assert summary["highest_score"] is None and summary["average_highest_score"] is None
    results = await quiz_routes.quiz_results(quiz["quiz_id"], data["teacher"], db)
    assert results[0]["highest_score"] is None


@pytest.mark.asyncio
async def test_extra_minutes_only_affect_future_attempts_and_never_extend_past_closing(quiz_db, monkeypatch):
    db, data = quiz_db
    now = datetime(2026, 10, 21, 10)
    monkeypatch.setattr(quiz_routes, "_now", lambda: now)
    quiz = await assessment_quiz(db, data, attempt_limit=3, time_limit_minutes=10, closes_at=now + timedelta(minutes=40))
    first = await quiz_routes.start_or_resume_attempt(quiz["quiz_id"], data["student"], db)
    saved = await quiz_routes.set_accommodation(quiz["quiz_id"], qs.AccommodationUpdate(
        student_id=data["student"].user_id, extra_minutes=15,
    ), data["teacher"], db)
    assert saved["ok"] is True
    resumed = await quiz_routes.start_or_resume_attempt(quiz["quiz_id"], data["student"], db)
    assert resumed["deadline_at"] == first["deadline_at"] == now + timedelta(minutes=10)
    assert resumed["extra_time_minutes"] == 0
    await quiz_routes.complete_attempt(first["attempt_id"], data["student"], db)
    second = await quiz_routes.start_or_resume_attempt(quiz["quiz_id"], data["student"], db)
    assert second["deadline_at"] == now + timedelta(minutes=25)
    assert second["extra_time_minutes"] == 15
    await quiz_routes.set_accommodation(quiz["quiz_id"], qs.AccommodationUpdate(
        student_id=data["student"].user_id, extra_minutes=100,
    ), data["teacher"], db)
    await quiz_routes.complete_attempt(second["attempt_id"], data["student"], db)
    third = await quiz_routes.start_or_resume_attempt(quiz["quiz_id"], data["student"], db)
    assert third["deadline_at"] == now + timedelta(minutes=40)
    assert third["extra_time_minutes"] == 100


@pytest.mark.asyncio
async def test_accommodation_owner_and_student_eligibility_are_enforced(quiz_db):
    db, data = quiz_db
    quiz = await assessment_quiz(db, data, time_limit_minutes=10)
    with pytest.raises(HTTPException) as owner:
        await quiz_routes.set_accommodation(quiz["quiz_id"], qs.AccommodationUpdate(
            student_id=data["student"].user_id, extra_minutes=15,
        ), data["other_teacher"], db)
    assert owner.value.status_code == 404
    with pytest.raises(HTTPException) as student:
        await quiz_routes.set_accommodation(quiz["quiz_id"], qs.AccommodationUpdate(
            student_id=data["outsider"].user_id, extra_minutes=15,
        ), data["teacher"], db)
    assert student.value.status_code == 403


@pytest.mark.parametrize(
    "options",
    [
        ["One", "Two", "Three"],
        ["One", "Two", "Three", "Four", "Five"],
        ["One", "Two", "", "Four"],
        ["One", "Two", " two ", "Four"],
    ],
)
def test_question_schema_rejects_malformed_options(options):
    with pytest.raises(ValidationError):
        qs.QuestionContent(**valid_question(options=options))


@pytest.mark.asyncio
async def test_private_bank_and_snapshot_are_isolated(quiz_db):
    db, data = quiz_db
    bank = await quiz_routes.create_bank_question(
        qs.BankQuestionCreate(
            class_id=data["classroom"].class_id,
            subject_id=data["subject"].subject_id,
            **valid_question(),
        ),
        teacher=data["teacher"],
        db=db,
    )
    with pytest.raises(HTTPException) as hidden:
        await quiz_routes.get_bank_question(
            bank["question_id"],
            teacher=data["other_teacher"],
            db=db,
        )
    assert hidden.value.status_code == 404

    quiz = await quiz_routes.create_quiz(
        qs.QuizCreate(
            class_id=data["classroom"].class_id,
            subject_id=data["subject"].subject_id,
            title="Planets",
        ),
        teacher=data["teacher"],
        db=db,
    )
    quiz = await quiz_routes.add_bank_question_to_quiz(
        quiz["quiz_id"],
        qs.AddBankQuestion(question_id=bank["question_id"]),
        teacher=data["teacher"],
        db=db,
    )
    snapshot_text = quiz["questions"][0]["question_text"]
    await quiz_routes.update_bank_question(
        bank["question_id"],
        qs.BankQuestionUpdate(
            class_id=data["classroom"].class_id,
            subject_id=data["subject"].subject_id,
            **valid_question(question_text="Changed bank wording"),
        ),
        teacher=data["teacher"],
        db=db,
    )
    unchanged = await quiz_routes.get_teacher_quiz(
        quiz["quiz_id"],
        teacher=data["teacher"],
        db=db,
    )
    assert unchanged["questions"][0]["question_text"] == snapshot_text


@pytest.mark.asyncio
async def test_lifecycle_attempt_feedback_idempotency_and_grading(quiz_db):
    db, data = quiz_db
    quiz = await quiz_routes.create_quiz(
        qs.QuizCreate(
            class_id=data["classroom"].class_id,
            subject_id=data["subject"].subject_id,
            title="Planets",
            attempt_limit=2,
            time_limit_minutes=30,
            shuffle_questions=True,
            shuffle_options=True,
        ),
        teacher=data["teacher"],
        db=db,
    )
    with pytest.raises(HTTPException) as empty_publish:
        await quiz_routes.publish_quiz(
            quiz["quiz_id"], teacher=data["teacher"], db=db,
        )
    assert empty_publish.value.status_code == 422

    quiz = await quiz_routes.create_and_add_question(
        quiz["quiz_id"],
        qs.AddNewQuestion(**valid_question(), save_to_bank=True),
        teacher=data["teacher"],
        db=db,
    )
    published = await quiz_routes.publish_quiz(
        quiz["quiz_id"], teacher=data["teacher"], db=db,
    )
    assert published["status"] == "published"

    student_list = await quiz_routes.list_student_quizzes(
        subject_id=None,
        quiz_status=None,
        student=data["student"],
        db=db,
    )
    assert [item["quiz_id"] for item in student_list] == [quiz["quiz_id"]]
    outsider_list = await quiz_routes.list_student_quizzes(
        subject_id=None,
        quiz_status=None,
        student=data["outsider"],
        db=db,
    )
    assert outsider_list == []

    attempt = await quiz_routes.start_or_resume_attempt(
        quiz["quiz_id"], student=data["student"], db=db,
    )
    resumed = await quiz_routes.start_or_resume_attempt(
        quiz["quiz_id"], student=data["student"], db=db,
    )
    assert resumed["attempt_id"] == attempt["attempt_id"]
    question = attempt["question"]
    assert "is_correct" not in question
    assert all("is_correct" not in option for option in question["options"])

    author_quiz = await quiz_routes.get_teacher_quiz(
        quiz["quiz_id"], teacher=data["teacher"], db=db,
    )
    author_question = author_quiz["questions"][0]
    correct = next(option for option in author_question["options"] if option["is_correct"])
    feedback = await quiz_routes.submit_answer(
        attempt["attempt_id"],
        qs.AnswerSubmission(
            quiz_question_id=question["quiz_question_id"],
            selected_option_id=correct["quiz_option_id"],
        ),
        student=data["student"],
        db=db,
    )
    assert feedback["feedback_released"] is False
    assert "is_correct" not in feedback
    assert "correct_option_id" not in feedback
    assert "explanation" not in feedback
    duplicate = await quiz_routes.submit_answer(
        attempt["attempt_id"],
        qs.AnswerSubmission(
            quiz_question_id=question["quiz_question_id"],
            selected_option_id=correct["quiz_option_id"],
        ),
        student=data["student"],
        db=db,
    )
    assert duplicate["response_id"] == feedback["response_id"]
    wrong = next(
        option for option in author_question["options"]
        if option["quiz_option_id"] != correct["quiz_option_id"]
    )
    with pytest.raises(HTTPException) as locked:
        await quiz_routes.submit_answer(
            attempt["attempt_id"],
            qs.AnswerSubmission(
                quiz_question_id=question["quiz_question_id"],
                selected_option_id=wrong["quiz_option_id"],
            ),
            student=data["student"],
            db=db,
        )
    assert locked.value.status_code == 409

    completed = await quiz_routes.complete_attempt(
        attempt["attempt_id"], student=data["student"], db=db,
    )
    assert completed["correct_count"] == 1
    assert completed["percentage_score"] == 100.0
    review = await quiz_routes.review_attempt(
        attempt["attempt_id"], student=data["student"], db=db,
    )
    assert review["questions"][0]["correct_option_text"] == "Mars"

    second_attempt = await quiz_routes.start_or_resume_attempt(
        quiz["quiz_id"], student=data["student"], db=db,
    )
    second_question = second_attempt["question"]
    await quiz_routes.submit_answer(
        second_attempt["attempt_id"],
        qs.AnswerSubmission(
            quiz_question_id=second_question["quiz_question_id"],
            selected_option_id=correct["quiz_option_id"],
        ),
        student=data["student"],
        db=db,
    )
    await quiz_routes.complete_attempt(
        second_attempt["attempt_id"], student=data["student"], db=db,
    )
    exhausted = await quiz_routes.get_student_quiz(
        quiz["quiz_id"], student=data["student"], db=db,
    )
    assert exhausted["attempts_remaining"] == 0
    assert exhausted["can_start_attempt"] is False
    with pytest.raises(HTTPException) as attempt_limit:
        await quiz_routes.start_or_resume_attempt(
            quiz["quiz_id"], student=data["student"], db=db,
        )
    assert attempt_limit.value.detail == "Attempt limit reached."

    with pytest.raises(HTTPException) as retained:
        await quiz_routes.delete_draft_quiz(
            quiz["quiz_id"], teacher=data["teacher"], db=db,
        )
    assert retained.value.status_code == 409


@pytest.mark.asyncio
async def test_publish_and_reminder_notifications_target_eligible_students(
    quiz_db, monkeypatch,
):
    db, data = quiz_db
    deliveries = []

    async def send_to_multiple(tokens, title, body, data=None):
        deliveries.append(
            {
                "tokens": list(tokens),
                "title": title,
                "body": body,
                "data": data,
            }
        )
        return {"success": len(tokens), "failure": 0}

    monkeypatch.setattr(
        quiz_routes.fcm_service,
        "send_to_multiple",
        send_to_multiple,
    )
    second_student = models.User(
        name="Second Quiz Student",
        phone_number="9555555555",
        role="student",
        password_hash="test",
    )
    db.add(second_student)
    await db.flush()
    db.add_all(
        [
            models.StudentClassMembership(
                student_id=second_student.user_id,
                class_id=data["classroom"].class_id,
            ),
            models.FCMToken(
                user_id=data["student"].user_id,
                token="student-one-token",
                device_type="android",
            ),
            models.FCMToken(
                user_id=second_student.user_id,
                token="student-two-token",
                device_type="android",
            ),
        ]
    )
    await db.commit()
    quiz = await quiz_routes.create_quiz(
        qs.QuizCreate(
            class_id=data["classroom"].class_id,
            subject_id=data["subject"].subject_id,
            title="Notification quiz",
        ),
        teacher=data["teacher"],
        db=db,
    )
    await quiz_routes.create_and_add_question(
        quiz["quiz_id"],
        qs.AddNewQuestion(**valid_question(), save_to_bank=False),
        teacher=data["teacher"],
        db=db,
    )
    published = await quiz_routes.publish_quiz(
        quiz["quiz_id"],
        teacher=data["teacher"],
        db=db,
    )
    assert published["notification_recipients"] == 2
    assert published["notifications_sent"] == 2
    assert published["notification_failures"] == 0
    assert set(deliveries[0]["tokens"]) == {
        "student-one-token",
        "student-two-token",
    }
    assert deliveries[0]["data"]["type"] == "quiz_published"

    await quiz_routes.start_or_resume_attempt(
        quiz["quiz_id"], student=data["student"], db=db,
    )
    reminder = await quiz_routes.remind_students_not_attempted(
        quiz["quiz_id"],
        teacher=data["teacher"],
        db=db,
    )
    assert reminder["eligible_students"] == 2
    assert reminder["students_notified"] == 1
    assert reminder["device_notifications_queued"] == 1
    assert deliveries[1]["tokens"] == ["student-two-token"]
    assert deliveries[1]["data"]["type"] == "quiz_reminder"


@pytest.mark.asyncio
async def test_schedule_and_timeout_are_server_enforced(quiz_db):
    db, data = quiz_db
    quiz = await quiz_routes.create_quiz(
        qs.QuizCreate(
            class_id=data["classroom"].class_id,
            subject_id=data["subject"].subject_id,
            title="Scheduled",
            opens_at=datetime.utcnow() + timedelta(hours=1),
        ),
        teacher=data["teacher"],
        db=db,
    )
    await quiz_routes.create_and_add_question(
        quiz["quiz_id"],
        qs.AddNewQuestion(**valid_question(), save_to_bank=False),
        teacher=data["teacher"],
        db=db,
    )
    await quiz_routes.publish_quiz(
        quiz["quiz_id"], teacher=data["teacher"], db=db,
    )
    with pytest.raises(HTTPException) as scheduled:
        await quiz_routes.start_or_resume_attempt(
            quiz["quiz_id"], student=data["student"], db=db,
        )
    assert scheduled.value.status_code == 409
