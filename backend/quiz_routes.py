"""Question-bank, quiz authoring, attempts, grading, and results APIs."""

import random
from datetime import datetime, timedelta
from decimal import Decimal, ROUND_HALF_UP

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload

import access_control as access
import auth
import models
import quiz_schemas as qs
from database import get_db
from notification_service import fcm_service


router = APIRouter(tags=["Quizzes"])


async def _eligible_students(
    db: AsyncSession, class_id: int,
) -> list[models.User]:
    return list(
        (
            await db.execute(
                select(models.User)
                .join(
                    models.StudentClassMembership,
                    models.StudentClassMembership.student_id
                    == models.User.user_id,
                )
                .filter(
                    models.StudentClassMembership.class_id == class_id,
                    models.StudentClassMembership.is_active.is_(True),
                    models.User.role == "student",
                )
                .order_by(models.User.name)
            )
        )
        .scalars()
        .all()
    )


async def _send_quiz_notifications(
    db: AsyncSession,
    quiz: models.Quiz,
    students: list[models.User],
    *,
    title: str,
    body: str,
    notification_type: str,
) -> dict[str, int]:
    if not students:
        return {"recipients": 0, "success": 0, "failure": 0}
    student_ids = [student.user_id for student in students]
    tokens = (
        await db.execute(
            select(models.FCMToken.token).filter(
                models.FCMToken.user_id.in_(student_ids),
            )
        )
    ).scalars().all()
    delivery = await fcm_service.send_to_multiple(
        list(tokens),
        title=title,
        body=body,
        data={
            "type": notification_type,
            "quiz_id": quiz.quiz_id,
            "quiz_title": quiz.title,
            "class_id": quiz.class_id,
            "subject_id": quiz.subject_id,
        },
    )
    return {
        "recipients": len(students),
        "success": delivery["success"],
        "failure": delivery["failure"],
    }


def _now() -> datetime:
    return datetime.utcnow()


def _score(correct: int, total: int) -> float:
    if total <= 0:
        return 0.0
    value = (Decimal(correct) * Decimal("100") / Decimal(total)).quantize(
        Decimal("0.01"), rounding=ROUND_HALF_UP,
    )
    return float(value)


def _quiz_options():
    return (
        selectinload(models.Quiz.owner),
        selectinload(models.Quiz.school_class),
        selectinload(models.Quiz.subject),
        selectinload(models.Quiz.questions).selectinload(models.QuizQuestion.options),
    )


def _bank_options():
    return (
        selectinload(models.QuestionBankQuestion.school_class),
        selectinload(models.QuestionBankQuestion.subject),
        selectinload(models.QuestionBankQuestion.options),
    )


async def _get_quiz(db: AsyncSession, quiz_id: int, *, lock: bool = False) -> models.Quiz:
    query = select(models.Quiz).options(*_quiz_options()).filter(
        models.Quiz.quiz_id == quiz_id,
    ).execution_options(populate_existing=True)
    if lock:
        query = query.with_for_update()
    quiz = (await db.execute(query)).scalar_one_or_none()
    if quiz is None:
        raise HTTPException(status_code=404, detail="Quiz not found.")
    return quiz


async def _get_bank_question(
    db: AsyncSession, question_id: int, *, lock: bool = False,
) -> models.QuestionBankQuestion:
    query = select(models.QuestionBankQuestion).options(*_bank_options()).filter(
        models.QuestionBankQuestion.question_id == question_id,
    ).execution_options(populate_existing=True)
    if lock:
        query = query.with_for_update()
    question = (await db.execute(query)).scalar_one_or_none()
    if question is None:
        raise HTTPException(status_code=404, detail="Question bank entry not found.")
    return question


async def _get_attempt(db: AsyncSession, attempt_id: int) -> models.QuizAttempt:
    attempt = (
        await db.execute(
            select(models.QuizAttempt)
            .options(
                selectinload(models.QuizAttempt.responses),
                selectinload(models.QuizAttempt.quiz)
                .selectinload(models.Quiz.questions)
                .selectinload(models.QuizQuestion.options),
            )
            .filter(models.QuizAttempt.attempt_id == attempt_id)
            .with_for_update()
            .execution_options(populate_existing=True)
        )
    ).scalar_one_or_none()
    if attempt is None:
        raise HTTPException(status_code=404, detail="Quiz attempt not found.")
    return attempt


def _display_status(quiz: models.Quiz, now: datetime | None = None) -> str:
    now = now or _now()
    if quiz.status == "closed" or (quiz.closes_at and now >= quiz.closes_at):
        return "closed"
    if quiz.status == "draft":
        return "draft"
    if quiz.opens_at and now < quiz.opens_at:
        return "scheduled"
    return "open"


def _content_metadata(question) -> dict:
    return {
        "topics": list(question.topics or []),
        "notation": question.notation or "plain_text",
        "spoken_question_text": question.spoken_question_text,
        "spoken_options": list(question.spoken_options) if question.spoken_options else None,
        "spoken_explanation": question.spoken_explanation,
        "spoken_reviewed": bool(question.spoken_reviewed),
    }


def _record_revision(db: AsyncSession, question: models.QuestionBankQuestion) -> None:
    options = sorted(question.options, key=lambda option: option.position)
    db.add(models.QuestionBankRevision(
        question_id=question.question_id, revision=question.revision,
        content={
            **_content_metadata(question),
            "class_id": question.class_id, "subject_id": question.subject_id,
            "question_text": question.question_text, "explanation": question.explanation,
            "options": [option.option_text for option in options],
            "correct_option_index": next(index for index, option in enumerate(options) if option.is_correct),
        },
    ))


def _spoken_option(question, option) -> str | None:
    if option is None or not question.spoken_reviewed or not question.spoken_options:
        return None
    return question.spoken_options[option.position]


def _bank_payload(question: models.QuestionBankQuestion) -> dict:
    return {
        **_content_metadata(question),
        "revision": question.revision,
        "question_id": question.question_id,
        "owner_teacher_id": question.owner_teacher_id,
        "class_id": question.class_id,
        "class_name": question.school_class.name if question.school_class else None,
        "subject_id": question.subject_id,
        "subject_name": question.subject.name if question.subject else None,
        "question_text": question.question_text,
        "explanation": question.explanation,
        "is_archived": question.is_archived,
        "created_at": question.created_at,
        "updated_at": question.updated_at,
        "archived_at": question.archived_at,
        "options": [
            {
                "option_id": option.option_id,
                "option_text": option.option_text,
                "position": option.position,
                "is_correct": option.is_correct,
            }
            for option in sorted(question.options, key=lambda item: item.position)
        ],
    }


def _author_question_payload(question: models.QuizQuestion) -> dict:
    return {
        **_content_metadata(question),
        "source_revision": question.source_revision,
        "quiz_question_id": question.quiz_question_id,
        "source_question_id": question.source_question_id,
        "question_text": question.question_text,
        "explanation": question.explanation,
        "position": question.position,
        "options": [
            {
                "quiz_option_id": option.quiz_option_id,
                "option_text": option.option_text,
                "position": option.position,
                "is_correct": option.is_correct,
            }
            for option in sorted(question.options, key=lambda item: item.position)
        ],
    }


def _quiz_payload(quiz: models.Quiz, include_questions: bool = False) -> dict:
    return {
        "quiz_id": quiz.quiz_id,
        "owner_teacher_id": quiz.owner_teacher_id,
        "class_id": quiz.class_id,
        "class_name": quiz.school_class.name if quiz.school_class else None,
        "subject_id": quiz.subject_id,
        "subject_name": quiz.subject.name if quiz.subject else None,
        "title": quiz.title,
        "description": quiz.description,
        "mode": quiz.mode,
        "feedback_policy": quiz.feedback_policy,
        "feedback_release_at": quiz.feedback_release_at,
        "status": quiz.status,
        "display_status": _display_status(quiz),
        "attempt_limit": quiz.attempt_limit,
        "opens_at": quiz.opens_at,
        "closes_at": quiz.closes_at,
        "time_limit_minutes": quiz.time_limit_minutes,
        "shuffle_questions": quiz.shuffle_questions,
        "shuffle_options": quiz.shuffle_options,
        "created_at": quiz.created_at,
        "updated_at": quiz.updated_at,
        "published_at": quiz.published_at,
        "closed_at": quiz.closed_at,
        "question_count": len(quiz.questions),
        "questions": (
            [_author_question_payload(question) for question in quiz.questions]
            if include_questions else []
        ),
    }


def _safe_question(
    question: models.QuizQuestion, option_ids: list[int] | None = None,
) -> dict:
    options_by_id = {option.quiz_option_id: option for option in question.options}
    ordered = (
        [options_by_id[option_id] for option_id in option_ids]
        if option_ids is not None else sorted(question.options, key=lambda item: item.position)
    )
    return {
        "quiz_question_id": question.quiz_question_id,
        "question_text": question.question_text,
        "spoken_question_text": question.spoken_question_text if question.spoken_reviewed else None,
        "topics": list(question.topics or []),
        "position": question.position,
        "options": [
            {
                "quiz_option_id": option.quiz_option_id,
                "option_text": option.option_text,
                "spoken_option_text": _spoken_option(question, option),
                "position": index,
            }
            for index, option in enumerate(ordered)
        ],
    }


def _validate_snapshot(question: models.QuizQuestion) -> list[str]:
    errors = []
    try:
        qs.QuestionContent(
            **_content_metadata(question),
            question_text=question.question_text, explanation=question.explanation,
            options=[option.option_text for option in question.options],
            correct_option_index=0,
        )
    except ValueError as error:
        errors.append(f"Question {question.position + 1} has invalid content or unreviewed spoken notation: {error}")
    if not question.question_text.strip():
        errors.append(f"Question {question.position + 1} has no text.")
    if len(question.options) != 4:
        errors.append(f"Question {question.position + 1} must have exactly four options.")
        return errors
    texts = [option.option_text.strip().casefold() for option in question.options]
    if any(not text for text in texts) or len(set(texts)) != 4:
        errors.append(f"Question {question.position + 1} has blank or duplicate options.")
    if sum(1 for option in question.options if option.is_correct) != 1:
        errors.append(f"Question {question.position + 1} must have one correct option.")
    return errors


def _readiness(quiz: models.Quiz) -> list[str]:
    errors = []
    if not quiz.title.strip():
        errors.append("Quiz title is required.")
    if not quiz.questions:
        errors.append("Add at least one question before publishing.")
    for question in quiz.questions:
        errors.extend(_validate_snapshot(question))
    if quiz.opens_at and quiz.closes_at and quiz.opens_at >= quiz.closes_at:
        errors.append("Opening time must be before closing time.")
    return errors


async def _attempt_exists(db: AsyncSession, quiz_id: int) -> bool:
    count = await db.scalar(
        select(func.count(models.QuizAttempt.attempt_id)).filter(
            models.QuizAttempt.quiz_id == quiz_id,
        )
    )
    return bool(count)


async def _replace_bank_options(
    db: AsyncSession,
    question: models.QuestionBankQuestion,
    payload: qs.QuestionContent,
) -> None:
    for option in list(question.options):
        await db.delete(option)
    await db.flush()
    question.options = [
        models.QuestionBankOption(
            option_text=text,
            position=index,
            is_correct=index == payload.correct_option_index,
        )
        for index, text in enumerate(payload.options)
    ]


def _snapshot_from_bank(
    quiz: models.Quiz, question: models.QuestionBankQuestion,
) -> models.QuizQuestion:
    snapshot = models.QuizQuestion(
        **_content_metadata(question),
        source_revision=question.revision,
        quiz_id=quiz.quiz_id,
        source_question_id=question.question_id,
        question_text=question.question_text,
        explanation=question.explanation,
        position=len(quiz.questions),
    )
    snapshot.options = [
        models.QuizOption(
            option_text=option.option_text,
            position=option.position,
            is_correct=option.is_correct,
        )
        for option in sorted(question.options, key=lambda item: item.position)
    ]
    return snapshot


@router.get("/question-bank", response_model=list[qs.BankQuestionOut])
async def list_bank_questions(
    class_id: int | None = None,
    subject_id: int | None = None,
    search: str = "",
    include_archived: bool = False,
    limit: int = Query(100, ge=1, le=200),
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    query = select(models.QuestionBankQuestion).options(*_bank_options()).filter(
        models.QuestionBankQuestion.owner_teacher_id == teacher.user_id,
    )
    if class_id is not None:
        query = query.filter(models.QuestionBankQuestion.class_id == class_id)
    if subject_id is not None:
        query = query.filter(models.QuestionBankQuestion.subject_id == subject_id)
    if not include_archived:
        query = query.filter(models.QuestionBankQuestion.is_archived.is_(False))
    normalized = " ".join(search.split())
    if normalized:
        query = query.filter(
            func.lower(models.QuestionBankQuestion.question_text).like(
                f"%{normalized.casefold()}%",
            )
        )
    questions = (
        await db.execute(
            query.order_by(models.QuestionBankQuestion.updated_at.desc()).limit(limit),
        )
    ).scalars().all()
    return [_bank_payload(question) for question in questions]


@router.post("/question-bank", response_model=qs.BankQuestionOut)
async def create_bank_question(
    payload: qs.BankQuestionCreate,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    await access.require_teacher_assignment(
        db, teacher.user_id, payload.class_id, payload.subject_id,
    )
    question = models.QuestionBankQuestion(
        **_content_metadata(payload),
        revision=1,
        owner_teacher_id=teacher.user_id,
        class_id=payload.class_id,
        subject_id=payload.subject_id,
        question_text=payload.question_text,
        explanation=payload.explanation,
    )
    question.options = [
        models.QuestionBankOption(
            option_text=text,
            position=index,
            is_correct=index == payload.correct_option_index,
        )
        for index, text in enumerate(payload.options)
    ]
    db.add(question)
    await db.flush()
    _record_revision(db, question)
    await db.commit()
    return _bank_payload(await _get_bank_question(db, question.question_id))


@router.get("/question-bank/{question_id}", response_model=qs.BankQuestionOut)
async def get_bank_question(
    question_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    question = await _get_bank_question(db, question_id)
    access.require_bank_question_owner(teacher, question)
    return _bank_payload(question)


@router.put("/question-bank/{question_id}", response_model=qs.BankQuestionOut)
async def update_bank_question(
    question_id: int,
    payload: qs.BankQuestionUpdate,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    question = await _get_bank_question(db, question_id, lock=True)
    access.require_bank_question_owner(teacher, question)
    if "expected_revision" in payload.model_fields_set and payload.expected_revision != question.revision:
        raise HTTPException(status_code=409, detail="This question changed. Refresh and review the current revision before saving.")
    await access.require_teacher_assignment(
        db, teacher.user_id, payload.class_id, payload.subject_id,
    )
    question.class_id = payload.class_id
    question.subject_id = payload.subject_id
    question.question_text = payload.question_text
    question.explanation = payload.explanation
    for field, value in _content_metadata(payload).items():
        setattr(question, field, value)
    question.revision = (question.revision or 0) + 1
    await _replace_bank_options(db, question, payload)
    _record_revision(db, question)
    await db.commit()
    return _bank_payload(await _get_bank_question(db, question_id))


@router.get("/question-bank/{question_id}/revisions")
async def bank_question_revisions(
    question_id: int,
    offset: int = Query(0, ge=0),
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    question = await _get_bank_question(db, question_id)
    access.require_bank_question_owner(teacher, question)
    rows = (await db.execute(
        select(models.QuestionBankRevision)
        .filter(models.QuestionBankRevision.question_id == question_id)
        .order_by(models.QuestionBankRevision.revision.desc()).offset(offset).limit(21)
    )).scalars().all()
    return {
        "question_id": question_id,
        "has_more": len(rows) > 20,
        "revisions": [{"revision": row.revision, "recorded_at": row.recorded_at, "content": row.content} for row in rows[:20]],
        "history_notice": "Only revisions saved after revision tracking was introduced are available. Older history is unknown.",
    }


@router.post("/question-bank/{question_id}/archive", response_model=qs.BankQuestionOut)
async def archive_bank_question(
    question_id: int,
    archived: bool = True,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    question = await _get_bank_question(db, question_id)
    access.require_bank_question_owner(teacher, question)
    question.is_archived = archived
    question.archived_at = _now() if archived else None
    await db.commit()
    return _bank_payload(await _get_bank_question(db, question_id))


@router.post("/question-bank/{question_id}/duplicate", response_model=qs.BankQuestionOut)
async def duplicate_bank_question(
    question_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    source = await _get_bank_question(db, question_id)
    access.require_bank_question_owner(teacher, source)
    await access.require_teacher_assignment(
        db, teacher.user_id, source.class_id, source.subject_id,
    )
    duplicate = models.QuestionBankQuestion(
        **_content_metadata(source),
        revision=1,
        owner_teacher_id=teacher.user_id,
        class_id=source.class_id,
        subject_id=source.subject_id,
        question_text=f"{source.question_text} (copy)",
        explanation=source.explanation,
    )
    duplicate.options = [
        models.QuestionBankOption(
            option_text=option.option_text,
            position=option.position,
            is_correct=option.is_correct,
        )
        for option in source.options
    ]
    db.add(duplicate)
    await db.flush()
    _record_revision(db, duplicate)
    await db.commit()
    return _bank_payload(await _get_bank_question(db, duplicate.question_id))


@router.get("/teacher/quizzes", response_model=list[qs.QuizOut])
async def list_teacher_quizzes(
    class_id: int | None = None,
    subject_id: int | None = None,
    quiz_status: str | None = Query(None, alias="status"),
    limit: int = Query(100, ge=1, le=200),
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    query = select(models.Quiz).options(*_quiz_options()).filter(
        models.Quiz.owner_teacher_id == teacher.user_id,
    )
    if class_id is not None:
        query = query.filter(models.Quiz.class_id == class_id)
    if subject_id is not None:
        query = query.filter(models.Quiz.subject_id == subject_id)
    if quiz_status is not None:
        if quiz_status not in {"draft", "published", "closed"}:
            raise HTTPException(status_code=422, detail="Invalid quiz status.")
        query = query.filter(models.Quiz.status == quiz_status)
    quizzes = (
        await db.execute(query.order_by(models.Quiz.updated_at.desc()).limit(limit))
    ).scalars().all()
    return [_quiz_payload(quiz) for quiz in quizzes]


@router.post("/teacher/quizzes", response_model=qs.QuizOut)
async def create_quiz(
    payload: qs.QuizCreate,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    if payload.feedback_policy == "legacy_immediate":
        raise HTTPException(422, "Legacy immediate feedback is only retained for existing quizzes.")
    await access.require_teacher_assignment(
        db, teacher.user_id, payload.class_id, payload.subject_id,
    )
    quiz = models.Quiz(
        owner_teacher_id=teacher.user_id,
        status="draft",
        **payload.dict(),
    )
    db.add(quiz)
    await db.commit()
    return _quiz_payload(await _get_quiz(db, quiz.quiz_id), include_questions=True)


@router.get("/teacher/quizzes/{quiz_id}", response_model=qs.QuizOut)
async def get_teacher_quiz(
    quiz_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    quiz = await _get_quiz(db, quiz_id)
    access.require_quiz_owner(teacher, quiz)
    return _quiz_payload(quiz, include_questions=True)


@router.put("/teacher/quizzes/{quiz_id}", response_model=qs.QuizOut)
async def update_quiz(
    quiz_id: int,
    payload: qs.QuizUpdate,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    quiz = await _get_quiz(db, quiz_id)
    access.require_quiz_owner(teacher, quiz)
    if payload.feedback_policy == "legacy_immediate" and quiz.feedback_policy != "legacy_immediate":
        raise HTTPException(422, "Legacy feedback cannot be enabled on a new quiz.")
    if quiz.status != "draft":
        raise HTTPException(status_code=409, detail="Only draft quiz settings can be edited.")
    if await _attempt_exists(db, quiz_id):
        raise HTTPException(status_code=409, detail="Attempted quiz content is immutable.")
    await access.require_teacher_assignment(
        db, teacher.user_id, payload.class_id, payload.subject_id,
    )
    for field, value in payload.dict().items():
        setattr(quiz, field, value)
    await db.commit()
    return _quiz_payload(await _get_quiz(db, quiz_id), include_questions=True)


@router.post(
    "/teacher/quizzes/{quiz_id}/questions/from-bank",
    response_model=qs.QuizOut,
)
async def add_bank_question_to_quiz(
    quiz_id: int,
    payload: qs.AddBankQuestion,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    quiz = await _get_quiz(db, quiz_id)
    access.require_quiz_owner(teacher, quiz)
    if quiz.status != "draft" or await _attempt_exists(db, quiz_id):
        raise HTTPException(status_code=409, detail="Quiz content is immutable.")
    question = await _get_bank_question(db, payload.question_id)
    access.require_bank_question_owner(teacher, question)
    if question.is_archived:
        raise HTTPException(status_code=409, detail="Archived questions cannot be added.")
    if question.class_id != quiz.class_id or question.subject_id != quiz.subject_id:
        raise HTTPException(status_code=400, detail="Question must match the quiz workspace.")
    db.add(_snapshot_from_bank(quiz, question))
    await db.commit()
    return _quiz_payload(await _get_quiz(db, quiz_id), include_questions=True)


@router.post(
    "/teacher/quizzes/{quiz_id}/questions/new",
    response_model=qs.QuizOut,
)
async def create_and_add_question(
    quiz_id: int,
    payload: qs.AddNewQuestion,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    quiz = await _get_quiz(db, quiz_id)
    access.require_quiz_owner(teacher, quiz)
    if quiz.status != "draft" or await _attempt_exists(db, quiz_id):
        raise HTTPException(status_code=409, detail="Quiz content is immutable.")
    await access.require_teacher_assignment(
        db, teacher.user_id, quiz.class_id, quiz.subject_id,
    )
    source = None
    if payload.save_to_bank:
        source = models.QuestionBankQuestion(
            **_content_metadata(payload),
            revision=1,
            owner_teacher_id=teacher.user_id,
            class_id=quiz.class_id,
            subject_id=quiz.subject_id,
            question_text=payload.question_text,
            explanation=payload.explanation,
        )
        source.options = [
            models.QuestionBankOption(
                option_text=text,
                position=index,
                is_correct=index == payload.correct_option_index,
            )
            for index, text in enumerate(payload.options)
        ]
        db.add(source)
        await db.flush()
        _record_revision(db, source)
    snapshot = models.QuizQuestion(
        **_content_metadata(payload),
        source_revision=source.revision if source else None,
        quiz_id=quiz.quiz_id,
        source_question_id=source.question_id if source else None,
        question_text=payload.question_text,
        explanation=payload.explanation,
        position=len(quiz.questions),
    )
    snapshot.options = [
        models.QuizOption(
            option_text=text,
            position=index,
            is_correct=index == payload.correct_option_index,
        )
        for index, text in enumerate(payload.options)
    ]
    db.add(snapshot)
    await db.commit()
    return _quiz_payload(await _get_quiz(db, quiz_id), include_questions=True)


@router.delete(
    "/teacher/quizzes/{quiz_id}/questions/{quiz_question_id}",
    response_model=qs.QuizOut,
)
async def remove_quiz_question(
    quiz_id: int,
    quiz_question_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    quiz = await _get_quiz(db, quiz_id)
    access.require_quiz_owner(teacher, quiz)
    if quiz.status != "draft" or await _attempt_exists(db, quiz_id):
        raise HTTPException(status_code=409, detail="Quiz content is immutable.")
    question = next(
        (entry for entry in quiz.questions if entry.quiz_question_id == quiz_question_id),
        None,
    )
    if question is None:
        raise HTTPException(status_code=404, detail="Quiz question not found.")
    await db.delete(question)
    await db.flush()
    remaining = [entry for entry in quiz.questions if entry is not question]
    for index, entry in enumerate(remaining):
        entry.position = -(index + 1)
    await db.flush()
    for index, entry in enumerate(remaining):
        entry.position = index
    await db.commit()
    return _quiz_payload(await _get_quiz(db, quiz_id), include_questions=True)


@router.post("/teacher/quizzes/{quiz_id}/reorder", response_model=qs.QuizOut)
async def reorder_quiz_questions(
    quiz_id: int,
    payload: qs.QuizReorder,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    quiz = await _get_quiz(db, quiz_id)
    access.require_quiz_owner(teacher, quiz)
    if quiz.status != "draft" or await _attempt_exists(db, quiz_id):
        raise HTTPException(status_code=409, detail="Quiz content is immutable.")
    current_ids = [question.quiz_question_id for question in quiz.questions]
    if (
        len(payload.quiz_question_ids) != len(set(payload.quiz_question_ids))
        or set(payload.quiz_question_ids) != set(current_ids)
    ):
        raise HTTPException(
            status_code=400,
            detail="Reorder list must contain every quiz question exactly once.",
        )
    by_id = {question.quiz_question_id: question for question in quiz.questions}
    for index, question in enumerate(quiz.questions):
        question.position = -(index + 1)
    await db.flush()
    for index, question_id in enumerate(payload.quiz_question_ids):
        by_id[question_id].position = index
    await db.commit()
    return _quiz_payload(await _get_quiz(db, quiz_id), include_questions=True)


@router.get("/teacher/quizzes/{quiz_id}/preview")
async def preview_quiz(
    quiz_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    quiz = await _get_quiz(db, quiz_id)
    access.require_quiz_owner(teacher, quiz)
    return {
        "quiz": _quiz_payload(quiz),
        "questions": [_safe_question(question) for question in quiz.questions],
    }


@router.get(
    "/teacher/quizzes/{quiz_id}/readiness",
    response_model=qs.PublicationReadiness,
)
async def quiz_readiness(
    quiz_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    quiz = await _get_quiz(db, quiz_id)
    access.require_quiz_owner(teacher, quiz)
    errors = _readiness(quiz)
    try:
        await access.require_teacher_assignment(
            db, teacher.user_id, quiz.class_id, quiz.subject_id,
        )
    except HTTPException:
        errors.append("The quiz workspace is no longer active or assigned.")
    return {"ready": not errors, "errors": errors}


@router.post("/teacher/quizzes/{quiz_id}/publish", response_model=qs.QuizOut)
async def publish_quiz(
    quiz_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    quiz = await _get_quiz(db, quiz_id)
    access.require_quiz_owner(teacher, quiz)
    if quiz.status != "draft":
        raise HTTPException(status_code=409, detail="Only a draft can be published.")
    await access.require_teacher_assignment(
        db, teacher.user_id, quiz.class_id, quiz.subject_id,
    )
    errors = _readiness(quiz)
    if errors:
        raise HTTPException(status_code=422, detail=errors)
    quiz.status = "published"
    quiz.published_at = _now()
    await db.commit()
    published = await _get_quiz(db, quiz_id)
    students = await _eligible_students(db, published.class_id)
    delivery = await _send_quiz_notifications(
        db,
        published,
        students,
        title="New quiz published",
        body=(
            f"{teacher.name} published '{published.title}' for "
            f"{published.subject.name}."
        ),
        notification_type="quiz_published",
    )
    payload = _quiz_payload(published, include_questions=True)
    payload.update(
        {
            "notification_recipients": delivery["recipients"],
            "notifications_sent": delivery["success"],
            "notification_failures": delivery["failure"],
        }
    )
    return payload


async def _finalize_attempt(
    db: AsyncSession,
    attempt: models.QuizAttempt,
    final_status: str,
    now: datetime | None = None,
) -> None:
    if attempt.status != "in_progress":
        return
    now = now or _now()
    responses = list(attempt.responses)
    attempt.correct_count = sum(1 for response in responses if response.is_correct)
    attempt.percentage_score = _score(attempt.correct_count, attempt.total_questions)
    attempt.status = final_status
    attempt.completed_at = now


@router.post("/teacher/quizzes/{quiz_id}/close", response_model=qs.QuizOut)
async def close_quiz(
    quiz_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    quiz = await _get_quiz(db, quiz_id)
    access.require_quiz_owner(teacher, quiz)
    if quiz.status != "published":
        raise HTTPException(status_code=409, detail="Only a published quiz can be closed.")
    now = _now()
    active_attempts = (
        await db.execute(
            select(models.QuizAttempt)
            .options(selectinload(models.QuizAttempt.responses))
            .filter(
                models.QuizAttempt.quiz_id == quiz_id,
                models.QuizAttempt.status == "in_progress",
            )
        )
    ).scalars().all()
    for attempt in active_attempts:
        await _finalize_attempt(db, attempt, "timed_out", now)
    quiz.status = "closed"
    quiz.closed_at = now
    await db.commit()
    return _quiz_payload(await _get_quiz(db, quiz_id), include_questions=True)


@router.post("/teacher/quizzes/{quiz_id}/duplicate", response_model=qs.QuizOut)
async def duplicate_quiz(
    quiz_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    source = await _get_quiz(db, quiz_id)
    access.require_quiz_owner(teacher, source)
    await access.require_teacher_assignment(
        db, teacher.user_id, source.class_id, source.subject_id,
    )
    duplicate = models.Quiz(
        owner_teacher_id=teacher.user_id,
        class_id=source.class_id,
        subject_id=source.subject_id,
        title=f"{source.title} (copy)",
        description=source.description,
        mode=source.mode,
        feedback_policy=("after_completion" if source.feedback_policy == "legacy_immediate" else source.feedback_policy),
        feedback_release_at=source.feedback_release_at,
        status="draft",
        attempt_limit=source.attempt_limit,
        opens_at=None,
        closes_at=None,
        time_limit_minutes=source.time_limit_minutes,
        shuffle_questions=source.shuffle_questions,
        shuffle_options=source.shuffle_options,
    )
    duplicate.questions = []
    for source_question in source.questions:
        question = models.QuizQuestion(
            **_content_metadata(source_question),
            source_revision=source_question.source_revision,
            source_question_id=source_question.source_question_id,
            question_text=source_question.question_text,
            explanation=source_question.explanation,
            position=source_question.position,
        )
        question.options = [
            models.QuizOption(
                option_text=option.option_text,
                position=option.position,
                is_correct=option.is_correct,
            )
            for option in source_question.options
        ]
        duplicate.questions.append(question)
    db.add(duplicate)
    await db.commit()
    return _quiz_payload(await _get_quiz(db, duplicate.quiz_id), include_questions=True)


@router.delete("/teacher/quizzes/{quiz_id}")
async def delete_draft_quiz(
    quiz_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    quiz = await _get_quiz(db, quiz_id)
    access.require_quiz_owner(teacher, quiz)
    if quiz.status != "draft" or await _attempt_exists(db, quiz_id):
        raise HTTPException(
            status_code=409,
            detail="Published or attempted quizzes must be retained. Close or duplicate the quiz instead.",
        )
    await db.delete(quiz)
    await db.commit()
    return {"ok": True}


async def _close_if_due(db: AsyncSession, quiz: models.Quiz, now: datetime) -> None:
    if quiz.status == "published" and quiz.closes_at and now >= quiz.closes_at:
        quiz.status = "closed"
        quiz.closed_at = quiz.closes_at
        active_attempts = (
            await db.execute(
                select(models.QuizAttempt)
                .options(selectinload(models.QuizAttempt.responses))
                .filter(
                    models.QuizAttempt.quiz_id == quiz.quiz_id,
                    models.QuizAttempt.status == "in_progress",
                )
                .with_for_update()
            )
        ).scalars().all()
        for attempt in active_attempts:
            await _finalize_attempt(db, attempt, "timed_out", now)
        await db.flush()


async def _student_quiz_payload(
    db: AsyncSession, quiz: models.Quiz, student_id: int, now: datetime,
) -> dict:
    attempts = (
        await db.execute(
            select(models.QuizAttempt).filter(
                models.QuizAttempt.quiz_id == quiz.quiz_id,
                models.QuizAttempt.student_id == student_id,
            )
        )
    ).scalars().all()
    completed = [
        attempt for attempt in attempts
        if attempt.status in {"completed", "timed_out"}
    ]
    for attempt in attempts:
        attempt.quiz = quiz
    active = next(
        (attempt for attempt in attempts if attempt.status == "in_progress"),
        None,
    )
    attempts_remaining = None if quiz.mode == "practice" else max(quiz.attempt_limit - len(attempts), 0)
    display_status = _display_status(quiz, now)
    return {
        "quiz_id": quiz.quiz_id,
        "title": quiz.title,
        "description": quiz.description,
        "mode": quiz.mode,
        "feedback_policy": quiz.feedback_policy,
        "feedback_release_at": quiz.feedback_release_at,
        "class_name": quiz.school_class.name,
        "subject_id": quiz.subject_id,
        "subject_name": quiz.subject.name,
        "teacher_name": quiz.owner.name if quiz.owner else None,
        "status": quiz.status,
        "display_status": display_status,
        "opens_at": quiz.opens_at,
        "closes_at": quiz.closes_at,
        "time_limit_minutes": quiz.time_limit_minutes,
        "attempt_limit": quiz.attempt_limit,
        "attempts_used": len(attempts),
        "attempts_remaining": attempts_remaining,
        "can_start_attempt": (
            active is not None
            or (display_status == "open" and (attempts_remaining is None or attempts_remaining > 0))
        ),
        "in_progress_attempt_id": active.attempt_id if active else None,
        "highest_score": (
            max((attempt.percentage_score for attempt in completed if _score_released(attempt)), default=None)
            if quiz.mode == "graded" else None
        ),
        "question_count": len(quiz.questions),
        "server_time": now,
    }


@router.get("/student/quizzes", response_model=list[qs.StudentQuizOut])
async def list_student_quizzes(
    subject_id: int | None = None,
    quiz_status: str | None = Query(None, alias="status"),
    student: models.User = Depends(auth.require_student),
    db: AsyncSession = Depends(get_db),
):
    membership = await access.get_active_student_membership(db, student.user_id)
    query = (
        select(models.Quiz)
        .join(
            models.ClassSubjectAssociation,
            (models.ClassSubjectAssociation.class_id == models.Quiz.class_id)
            & (models.ClassSubjectAssociation.subject_id == models.Quiz.subject_id),
        )
        .options(*_quiz_options())
        .filter(
            models.Quiz.class_id == membership.class_id,
            models.Quiz.status.in_(["published", "closed"]),
            models.ClassSubjectAssociation.is_active.is_(True),
        )
    )
    if subject_id is not None:
        query = query.filter(models.Quiz.subject_id == subject_id)
    quizzes = (
        await db.execute(query.order_by(models.Quiz.updated_at.desc()))
    ).scalars().all()
    now = _now()
    output = []
    for quiz in quizzes:
        await _close_if_due(db, quiz, now)
        payload = await _student_quiz_payload(db, quiz, student.user_id, now)
        if quiz.status == "closed" and payload["attempts_used"] == 0:
            continue
        if quiz_status and payload["display_status"] != quiz_status:
            continue
        output.append(payload)
    await db.commit()
    return output


@router.get("/student/quizzes/{quiz_id}", response_model=qs.StudentQuizOut)
async def get_student_quiz(
    quiz_id: int,
    student: models.User = Depends(auth.require_student),
    db: AsyncSession = Depends(get_db),
):
    quiz = await _get_quiz(db, quiz_id)
    await access.require_student_quiz_access(db, student, quiz)
    now = _now()
    await _close_if_due(db, quiz, now)
    payload = await _student_quiz_payload(db, quiz, student.user_id, now)
    if quiz.status == "closed" and payload["attempts_used"] == 0:
        raise HTTPException(status_code=404, detail="Quiz not found.")
    await db.commit()
    return payload


def _next_question(attempt: models.QuizAttempt) -> dict | None:
    answered_ids = {response.quiz_question_id for response in attempt.responses}
    questions = {question.quiz_question_id: question for question in attempt.quiz.questions}
    for question_id in attempt.question_order:
        if question_id not in answered_ids:
            option_ids = attempt.option_order[str(question_id)]
            return _safe_question(questions[question_id], option_ids)
    return None


def _feedback_released(attempt: models.QuizAttempt) -> bool:
    quiz = attempt.quiz
    if quiz.mode == "practice" or quiz.feedback_policy == "legacy_immediate":
        return True
    if attempt.status == "in_progress" or quiz.feedback_policy == "score_only":
        return False
    if quiz.feedback_policy == "scheduled":
        return quiz.feedback_release_at is not None and _now() >= quiz.feedback_release_at
    return quiz.feedback_policy == "after_completion"


def _score_released(attempt: models.QuizAttempt) -> bool:
    if attempt.quiz.mode == "practice" or attempt.quiz.feedback_policy == "legacy_immediate":
        return True
    if attempt.status == "in_progress":
        return False
    return attempt.quiz.feedback_policy != "scheduled" or _feedback_released(attempt)


def _feedback_message(attempt: models.QuizAttempt) -> str:
    quiz = attempt.quiz
    if quiz.mode == "practice":
        return "Practice feedback, not an academic grade."
    if quiz.feedback_policy == "score_only":
        return "Only the score is released after final submission. Answer keys and explanations are not released."
    if quiz.feedback_policy == "scheduled":
        return f"Answer feedback and scores are released after final submission and {quiz.feedback_release_at.isoformat()} UTC."
    if quiz.feedback_policy == "after_completion" and attempt.status == "in_progress":
        return "Answer saved and locked. Answer feedback and scores are released after final submission."
    return "Answer feedback is available."


def _attempt_payload(attempt: models.QuizAttempt, include_question: bool = True, *, teacher: bool = False) -> dict:
    score_visible = teacher or _score_released(attempt)
    graded = attempt.quiz.mode == "graded"
    return {
        "attempt_id": attempt.attempt_id,
        "quiz_id": attempt.quiz_id,
        "attempt_number": attempt.attempt_number,
        "status": attempt.status,
        "started_at": attempt.started_at,
        "deadline_at": attempt.deadline_at,
        "completed_at": attempt.completed_at,
        "correct_count": attempt.correct_count if score_visible else None,
        "total_questions": attempt.total_questions,
        "percentage_score": attempt.percentage_score if score_visible and graded else None,
        "is_graded": graded,
        "score_released": score_visible,
        "feedback_message": _feedback_message(attempt),
        "extra_time_minutes": attempt.extra_time_minutes,
        "answered_count": len(attempt.responses),
        "server_time": _now(),
        "question": (
            _next_question(attempt)
            if include_question and attempt.status == "in_progress" else None
        ),
    }


async def _expire_if_due(
    db: AsyncSession, attempt: models.QuizAttempt, now: datetime,
) -> bool:
    if (
        attempt.status == "in_progress"
        and attempt.deadline_at is not None
        and now >= attempt.deadline_at
    ):
        await _finalize_attempt(db, attempt, "timed_out", now)
        await db.commit()
        return True
    return False


@router.post("/student/quizzes/{quiz_id}/attempts", response_model=qs.AttemptOut)
async def start_or_resume_attempt(
    quiz_id: int,
    student: models.User = Depends(auth.require_student),
    db: AsyncSession = Depends(get_db),
):
    quiz = await _get_quiz(db, quiz_id, lock=True)
    await access.require_student_quiz_access(db, student, quiz)
    now = _now()
    existing = (
        await db.execute(
            select(models.QuizAttempt).options(
                selectinload(models.QuizAttempt.responses),
            ).filter(
                models.QuizAttempt.quiz_id == quiz_id,
                models.QuizAttempt.student_id == student.user_id,
                models.QuizAttempt.status == "in_progress",
            )
        )
    ).scalar_one_or_none()
    if existing is not None:
        existing.quiz = quiz
        if not await _expire_if_due(db, existing, now):
            return _attempt_payload(existing)
        quiz = await _get_quiz(db, quiz_id, lock=True)
    await _close_if_due(db, quiz, now)
    if quiz.status != "published":
        await db.commit()
        raise HTTPException(status_code=409, detail="This quiz is closed.")
    if quiz.opens_at and now < quiz.opens_at:
        raise HTTPException(status_code=409, detail="This quiz has not opened yet.")
    attempts = (
        await db.execute(
            select(models.QuizAttempt).filter(
                models.QuizAttempt.quiz_id == quiz_id,
                models.QuizAttempt.student_id == student.user_id,
            )
        )
    ).scalars().all()
    if quiz.mode != "practice" and len(attempts) >= quiz.attempt_limit:
        raise HTTPException(status_code=409, detail="Attempt limit reached.")
    if not quiz.questions:
        raise HTTPException(status_code=409, detail="This quiz has no questions.")
    question_ids = [question.quiz_question_id for question in quiz.questions]
    if quiz.shuffle_questions:
        random.SystemRandom().shuffle(question_ids)
    option_order = {}
    questions_by_id = {
        question.quiz_question_id: question for question in quiz.questions
    }
    for question_id in question_ids:
        option_ids = [
            option.quiz_option_id for option in questions_by_id[question_id].options
        ]
        if quiz.shuffle_options:
            random.SystemRandom().shuffle(option_ids)
        option_order[str(question_id)] = option_ids
    boundaries = []
    accommodation = await db.get(models.QuizAccommodation, (quiz_id, student.user_id))
    extra_minutes = accommodation.extra_minutes if accommodation is not None and quiz.time_limit_minutes else 0
    if quiz.time_limit_minutes:
        boundaries.append(now + timedelta(minutes=quiz.time_limit_minutes + extra_minutes))
    if quiz.closes_at:
        boundaries.append(quiz.closes_at)
    attempt = models.QuizAttempt(
        quiz_id=quiz_id,
        student_id=student.user_id,
        attempt_number=len(attempts) + 1,
        status="in_progress",
        started_at=now,
        deadline_at=min(boundaries) if boundaries else None,
        extra_time_minutes=extra_minutes,
        total_questions=len(question_ids),
        question_order=question_ids,
        option_order=option_order,
    )
    db.add(attempt)
    try:
        await db.commit()
    except IntegrityError:
        await db.rollback()
        resumed = (
            await db.execute(
                select(models.QuizAttempt).options(
                    selectinload(models.QuizAttempt.responses),
                ).filter(
                    models.QuizAttempt.quiz_id == quiz_id,
                    models.QuizAttempt.student_id == student.user_id,
                    models.QuizAttempt.status == "in_progress",
                )
            )
        ).scalar_one_or_none()
        if resumed is None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="A concurrent attempt request could not be completed. Retry safely.",
            )
        resumed.quiz = await _get_quiz(db, quiz_id)
        return _attempt_payload(resumed)
    loaded = await _get_attempt(db, attempt.attempt_id)
    return _attempt_payload(loaded)


@router.get("/student/attempts/{attempt_id}", response_model=qs.AttemptOut)
async def get_attempt(
    attempt_id: int,
    student: models.User = Depends(auth.require_student),
    db: AsyncSession = Depends(get_db),
):
    attempt = await _get_attempt(db, attempt_id)
    access.require_attempt_owner(student, attempt)
    await access.require_student_quiz_access(db, student, attempt.quiz)
    await _expire_if_due(db, attempt, _now())
    return _attempt_payload(attempt)


def _feedback(
    attempt: models.QuizAttempt,
    response: models.QuizResponse,
) -> dict:
    question = next(
        item for item in attempt.quiz.questions
        if item.quiz_question_id == response.quiz_question_id
    )
    selected = next(
        option for option in question.options
        if option.quiz_option_id == response.selected_option_id
    )
    correct = next(option for option in question.options if option.is_correct)
    result = {
        "response_id": response.response_id,
        "quiz_question_id": question.quiz_question_id,
        "selected_option_id": selected.quiz_option_id,
        "selected_option_text": selected.option_text,
        "selected_option_spoken_text": _spoken_option(question, selected),
        "feedback_released": _feedback_released(attempt),
        "feedback_message": _feedback_message(attempt),
        "submitted_at": response.submitted_at,
        "next_question": _next_question(attempt),
    }
    if result["feedback_released"]:
        result.update(correct_option_id=correct.quiz_option_id, correct_option_text=correct.option_text,
                      correct_option_spoken_text=_spoken_option(question, correct),
                      spoken_explanation=question.spoken_explanation if question.spoken_reviewed else None,
                      is_correct=response.is_correct, explanation=question.explanation)
    return result


@router.post(
    "/student/attempts/{attempt_id}/answers",
    response_model=qs.AnswerFeedback,
)
async def submit_answer(
    attempt_id: int,
    payload: qs.AnswerSubmission,
    student: models.User = Depends(auth.require_student),
    db: AsyncSession = Depends(get_db),
):
    attempt = await _get_attempt(db, attempt_id)
    access.require_attempt_owner(student, attempt)
    await access.require_student_quiz_access(db, student, attempt.quiz)
    if await _expire_if_due(db, attempt, _now()):
        raise HTTPException(status_code=409, detail="The attempt deadline has passed.")
    if attempt.status != "in_progress":
        raise HTTPException(status_code=409, detail="This attempt is already final.")
    if payload.quiz_question_id not in attempt.question_order:
        raise HTTPException(status_code=400, detail="Question does not belong to this attempt.")
    existing = next(
        (
            response for response in attempt.responses
            if response.quiz_question_id == payload.quiz_question_id
        ),
        None,
    )
    if existing is not None:
        if existing.selected_option_id != payload.selected_option_id:
            raise HTTPException(status_code=409, detail="This answer is locked and cannot be changed.")
        return _feedback(attempt, existing)
    question = next(
        item for item in attempt.quiz.questions
        if item.quiz_question_id == payload.quiz_question_id
    )
    selected = next(
        (
            option for option in question.options
            if option.quiz_option_id == payload.selected_option_id
        ),
        None,
    )
    if selected is None:
        raise HTTPException(status_code=400, detail="Option does not belong to this question.")
    response = models.QuizResponse(
        attempt_id=attempt_id,
        quiz_question_id=question.quiz_question_id,
        selected_option_id=selected.quiz_option_id,
        is_correct=selected.is_correct,
        submitted_at=_now(),
    )
    db.add(response)
    try:
        await db.commit()
    except IntegrityError:
        await db.rollback()
        attempt = await _get_attempt(db, attempt_id)
        existing = next(
            (
                item for item in attempt.responses
                if item.quiz_question_id == payload.quiz_question_id
            ),
            None,
        )
        if existing and existing.selected_option_id == payload.selected_option_id:
            return _feedback(attempt, existing)
        raise HTTPException(status_code=409, detail="This answer is locked and cannot be changed.")
    attempt = await _get_attempt(db, attempt_id)
    response = next(
        item for item in attempt.responses
        if item.quiz_question_id == payload.quiz_question_id
    )
    return _feedback(attempt, response)


@router.post("/student/attempts/{attempt_id}/complete", response_model=qs.AttemptOut)
async def complete_attempt(
    attempt_id: int,
    student: models.User = Depends(auth.require_student),
    db: AsyncSession = Depends(get_db),
):
    attempt = await _get_attempt(db, attempt_id)
    access.require_attempt_owner(student, attempt)
    await access.require_student_quiz_access(db, student, attempt.quiz)
    if attempt.status == "in_progress":
        now = _now()
        final_status = (
            "timed_out"
            if attempt.deadline_at is not None and now >= attempt.deadline_at
            else "completed"
        )
        await _finalize_attempt(db, attempt, final_status, now)
        await db.commit()
    return _attempt_payload(attempt, include_question=False)


@router.get(
    "/student/quizzes/{quiz_id}/attempts",
    response_model=qs.AttemptHistoryOut,
)
async def student_attempt_history(
    quiz_id: int,
    student: models.User = Depends(auth.require_student),
    db: AsyncSession = Depends(get_db),
):
    quiz = await _get_quiz(db, quiz_id)
    await access.require_student_quiz_access(db, student, quiz)
    attempts = (
        await db.execute(
            select(models.QuizAttempt).options(
                selectinload(models.QuizAttempt.responses),
            ).filter(
                models.QuizAttempt.quiz_id == quiz_id,
                models.QuizAttempt.student_id == student.user_id,
            ).order_by(models.QuizAttempt.attempt_number)
        )
    ).scalars().all()
    for attempt in attempts:
        attempt.quiz = quiz
        await _expire_if_due(db, attempt, _now())
    final = [
        attempt for attempt in attempts
        if attempt.status in {"completed", "timed_out"}
    ]
    return {
        "quiz_id": quiz_id,
        "highest_score": (
            max((attempt.percentage_score for attempt in final if _score_released(attempt)), default=None)
            if quiz.mode == "graded" else None
        ),
        "attempts": [
            _attempt_payload(attempt, include_question=False)
            for attempt in attempts
        ],
    }


def _review_payload(attempt: models.QuizAttempt, *, teacher: bool = False) -> dict:
    if not teacher and not _feedback_released(attempt):
        return {"attempt": _attempt_payload(attempt, include_question=False), "questions": [],
                "feedback_message": _feedback_message(attempt)}
    responses = {
        response.quiz_question_id: response for response in attempt.responses
    }
    questions = {
        question.quiz_question_id: question for question in attempt.quiz.questions
    }
    review = []
    for question_id in attempt.question_order:
        question = questions[question_id]
        response = responses.get(question_id)
        selected = (
            next(
                option for option in question.options
                if option.quiz_option_id == response.selected_option_id
            )
            if response else None
        )
        correct = next(option for option in question.options if option.is_correct)
        review.append(
            {
                "quiz_question_id": question_id,
                "question_text": question.question_text,
                "spoken_question_text": question.spoken_question_text if question.spoken_reviewed else None,
                "selected_option_id": selected.quiz_option_id if selected else None,
                "selected_option_text": selected.option_text if selected else None,
                "selected_option_spoken_text": _spoken_option(question, selected),
                "correct_option_id": correct.quiz_option_id,
                "correct_option_text": correct.option_text,
                "correct_option_spoken_text": _spoken_option(question, correct),
                "spoken_explanation": question.spoken_explanation if question.spoken_reviewed else None,
                "is_correct": bool(response and response.is_correct),
                "explanation": question.explanation,
            }
        )
    return {
        "attempt": _attempt_payload(attempt, include_question=False, teacher=teacher),
        "questions": review,
        "feedback_message": _feedback_message(attempt),
    }


@router.get(
    "/student/attempts/{attempt_id}/review",
    response_model=qs.AttemptReviewOut,
)
async def review_attempt(
    attempt_id: int,
    student: models.User = Depends(auth.require_student),
    db: AsyncSession = Depends(get_db),
):
    attempt = await _get_attempt(db, attempt_id)
    access.require_attempt_owner(student, attempt)
    await access.require_student_quiz_access(db, student, attempt.quiz)
    await _expire_if_due(db, attempt, _now())
    if attempt.status == "in_progress":
        raise HTTPException(status_code=409, detail="Complete the attempt before reviewing it.")
    return _review_payload(attempt)


async def _owner_quiz(
    db: AsyncSession, teacher: models.User, quiz_id: int,
) -> models.Quiz:
    quiz = await _get_quiz(db, quiz_id)
    access.require_quiz_owner(teacher, quiz)
    return quiz


@router.post("/teacher/quizzes/{quiz_id}/accommodations")
async def set_accommodation(
    quiz_id: int, payload: qs.AccommodationUpdate,
    teacher: models.User = Depends(auth.require_teacher), db: AsyncSession = Depends(get_db),
):
    quiz = await _get_quiz(db, quiz_id, lock=True)
    access.require_quiz_owner(teacher, quiz)
    await access.require_teacher_assignment(db, teacher.user_id, quiz.class_id, quiz.subject_id)
    student = await db.get(models.User, payload.student_id)
    if student is None or student.role != "student":
        raise HTTPException(404, "Eligible student not found.")
    membership = await access.get_active_student_membership(db, student.user_id)
    if membership.class_id != quiz.class_id:
        raise HTTPException(403, "This student is not eligible for this quiz.")
    if quiz.mode == "practice" or quiz.time_limit_minutes is None:
        raise HTTPException(422, "This quiz has no per-attempt timer to extend.")
    accommodation = await db.get(models.QuizAccommodation, (quiz_id, student.user_id))
    if accommodation is None:
        accommodation = models.QuizAccommodation(quiz_id=quiz_id, student_id=student.user_id)
        db.add(accommodation)
    accommodation.extra_minutes = payload.extra_minutes
    await db.commit()
    return {"ok": True, "student_id": student.user_id, "extra_minutes": payload.extra_minutes,
            "message": "Saved for future attempts only. Existing attempt deadlines remain unchanged; quiz closing time still applies."}


@router.get(
    "/teacher/quizzes/{quiz_id}/results",
    response_model=list[qs.EligibleStudentOut],
)
async def quiz_results(
    quiz_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    quiz = await _owner_quiz(db, teacher, quiz_id)
    students = await _eligible_students(db, quiz.class_id)
    accommodations = (await db.execute(select(models.QuizAccommodation).where(models.QuizAccommodation.quiz_id == quiz_id))).scalars().all()
    extra_by_student = {item.student_id: item.extra_minutes for item in accommodations}
    student_ids = [student.user_id for student in students]
    attempts = (
        await db.execute(
            select(models.QuizAttempt).options(
                selectinload(models.QuizAttempt.responses),
            ).filter(
                models.QuizAttempt.quiz_id == quiz_id,
                models.QuizAttempt.student_id.in_(student_ids),
            ).order_by(models.QuizAttempt.attempt_number)
        )
    ).scalars().all() if student_ids else []
    by_student: dict[int, list[models.QuizAttempt]] = {}
    for attempt in attempts:
        attempt.quiz = quiz
        by_student.setdefault(attempt.student_id, []).append(attempt)
    output = []
    for student in students:
        student_attempts = by_student.get(student.user_id, [])
        final = [
            attempt for attempt in student_attempts
            if attempt.status in {"completed", "timed_out"}
        ]
        output.append(
            {
                "student_id": student.user_id,
                "student_name": student.name,
                "extra_time_minutes": extra_by_student.get(student.user_id, 0),
                "started": bool(student_attempts),
                "completed": bool(final),
                "highest_score": (
                    max(attempt.percentage_score for attempt in final)
                    if final and quiz.mode == "graded" else None
                ),
                "attempts": [
                    _attempt_payload(attempt, include_question=False, teacher=True)
                    for attempt in student_attempts
                ],
            }
        )
    return output


@router.post(
    "/teacher/quizzes/{quiz_id}/remind-not-attempted",
    response_model=qs.QuizNotificationOut,
)
async def remind_students_not_attempted(
    quiz_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    quiz = await _owner_quiz(db, teacher, quiz_id)
    students = await _eligible_students(db, quiz.class_id)
    attempted_student_ids = set(
        (
            await db.execute(
                select(models.QuizAttempt.student_id)
                .filter(models.QuizAttempt.quiz_id == quiz_id)
                .distinct()
            )
        )
        .scalars()
        .all()
    )
    not_attempted = [
        student
        for student in students
        if student.user_id not in attempted_student_ids
    ]
    delivery = await _send_quiz_notifications(
        db,
        quiz,
        not_attempted,
        title="Quiz reminder",
        body=(
            f"Please attempt '{quiz.title}' for {quiz.subject.name}. "
            f"Your teacher {teacher.name} sent this reminder."
        ),
        notification_type="quiz_reminder",
    )
    return {
        "eligible_students": len(students),
        "students_notified": len(not_attempted),
        "device_notifications_queued": delivery["success"],
    }


@router.get(
    "/teacher/quizzes/{quiz_id}/attempts/{attempt_id}",
    response_model=qs.AttemptReviewOut,
)
async def teacher_attempt_review(
    quiz_id: int,
    attempt_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    await _owner_quiz(db, teacher, quiz_id)
    attempt = await _get_attempt(db, attempt_id)
    if attempt.quiz_id != quiz_id:
        raise HTTPException(status_code=404, detail="Quiz attempt not found.")
    return _review_payload(attempt, teacher=True)


@router.get(
    "/teacher/quizzes/{quiz_id}/summary",
    response_model=qs.QuizSummaryOut,
)
async def quiz_summary(
    quiz_id: int,
    teacher: models.User = Depends(auth.require_teacher),
    db: AsyncSession = Depends(get_db),
):
    quiz = await _owner_quiz(db, teacher, quiz_id)
    eligible = await db.scalar(
        select(func.count(models.StudentClassMembership.membership_id))
        .join(models.User, models.User.user_id == models.StudentClassMembership.student_id)
        .filter(
            models.StudentClassMembership.class_id == quiz.class_id,
            models.StudentClassMembership.is_active.is_(True),
            models.User.role == "student",
        )
    ) or 0
    attempts = (
        await db.execute(
            select(models.QuizAttempt).options(
                selectinload(models.QuizAttempt.responses),
            ).filter(models.QuizAttempt.quiz_id == quiz_id)
        )
    ).scalars().all()
    by_student: dict[int, list[models.QuizAttempt]] = {}
    for attempt in attempts:
        if attempt.student_id is not None:
            by_student.setdefault(attempt.student_id, []).append(attempt)
    highest_scores = []
    for student_attempts in by_student.values():
        final = [
            attempt for attempt in student_attempts
            if attempt.status in {"completed", "timed_out"}
        ]
        if final:
            highest_scores.append(max(attempt.percentage_score for attempt in final))
    completed_attempts = [
        attempt for attempt in attempts
        if attempt.status in {"completed", "timed_out"}
    ]
    question_stats = []
    for question in quiz.questions:
        responses = [
            response
            for attempt in completed_attempts
            for response in attempt.responses
            if response.quiz_question_id == question.quiz_question_id
        ]
        correct = sum(1 for response in responses if response.is_correct)
        question_stats.append(
            {
                "quiz_question_id": question.quiz_question_id,
                "question_text": question.question_text,
                "response_count": len(responses),
                "spoken_question_text": question.spoken_question_text if question.spoken_reviewed else None,
                "correct_percentage": _score(correct, len(responses)),
            }
        )
    started = len(by_student)
    completed = len(highest_scores)
    grades = highest_scores if quiz.mode == "graded" else []
    return {
        "mode": quiz.mode,
        "time_limit_minutes": quiz.time_limit_minutes,
        "eligible_students": eligible,
        "started": started,
        "completed": completed,
        "not_attempted": max(eligible - started, 0),
        "completion_percentage": _score(completed, eligible),
        "average_highest_score": (
            float(
                (sum(Decimal(str(score)) for score in grades) / len(grades))
                .quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
            )
            if grades else None
        ),
        "highest_score": max(grades) if grades else None,
        "lowest_completed_score": min(grades) if grades else None,
        "per_question": question_stats,
    }
