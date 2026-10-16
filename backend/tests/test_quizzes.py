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
    assert feedback["is_correct"] is True
    assert feedback["correct_option_id"] == correct["quiz_option_id"]
    assert feedback["explanation"] == "Iron oxide makes Mars appear red."
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
