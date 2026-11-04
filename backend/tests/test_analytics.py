import json
import logging
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from uuid import uuid4

import pytest
import pytest_asyncio
from fastapi import HTTPException
from sqlalchemy import select, func, text
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import models
from activity_events import record_event, install_orm_audit
from analytics_service import execute, month_shift, catalog
from analytics_schemas import Intent, QueryRequest, EventBatch
from analytics_routes import ingest
from logging_config import SafeFormatter
from maintenance import retain, erase_student
from session_history import ensure_history, close_run, confirm_attendance
from session_logger import get_session_summary
from model_client import local_url


@pytest_asyncio.fixture
async def data(monkeypatch):
    monkeypatch.setenv("ACTIVITY_COLLECTION_ENABLED", "true")
    monkeypatch.setenv("CLIENT_TELEMETRY_ENABLED", "true")
    install_orm_audit()
    engine = create_async_engine("sqlite+aiosqlite://", poolclass=StaticPool)
    factory = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    async with engine.begin() as conn:
        await conn.run_sync(models.Base.metadata.create_all)
    async with factory() as db:
        admin = models.User(name="Admin", phone_number="1", role="admin", password_hash="test")
        teacher = models.User(name="Teacher X", phone_number="2", role="teacher", password_hash="test")
        other = models.User(name="Teacher Y", phone_number="3", role="teacher", password_hash="test")
        students = [models.User(name=f"Student {i}", phone_number=f"10{i}", role="student", password_hash="test")
                    for i in range(7)]
        school = models.SchoolClass(name="Class Z", sort_order=1)
        subject = models.Subject(name="Subject Y")
        db.add_all([admin, teacher, other, school, subject, *students])
        await db.flush()
        db.add(models.ClassSubjectAssociation(class_id=school.class_id, subject_id=subject.subject_id))
        for person in (teacher, other):
            db.add(models.TeacherClassSubjectAssignment(
                teacher_id=person.user_id, class_id=school.class_id, subject_id=subject.subject_id,
            ))
        room = models.Session(title="Learning room", created_by=teacher.user_id,
                              class_id=school.class_id, subject_id=subject.subject_id, is_active=True)
        audio = models.AudioFile(title="Lesson", file_path="not-read.mp3", uploaded_by=teacher.user_id,
                                 class_id=school.class_id, subject_id=subject.subject_id)
        db.add_all([room, audio])
        await db.flush()
        await ensure_history(db, room, opening=True)
        await db.commit()
        yield db, admin, teacher, other, students, room, audio
    await engine.dispose()


@pytest.mark.asyncio
async def test_same_session_reopens_and_deduplicates_attendance(data):
    db, admin, teacher, other, students, room, audio = data
    for student in students[:5]:
        await confirm_attendance(db, room, student)
    await confirm_attendance(db, room, students[0])
    await confirm_attendance(db, room, teacher)
    room.is_active = False
    room.ended_at = datetime.utcnow()
    await close_run(db, room)
    await db.commit()
    room.is_active = True
    room.ended_at = None
    await ensure_history(db, room, opening=True)
    for student in [*students[:3], *students[5:]]:
        await confirm_attendance(db, room, student)
    await db.commit()
    for metric, expected in (("sessions_created", 1), ("session_openings", 2), ("attendance", 7)):
        result = await execute(db, admin, Intent(
            metric=metric, teacher="teacher x", subject="Subject Y", class_name="Class Z",
        ))
        assert result["value"] == expected
    assert (await execute(db, other, Intent(metric="attendance")))["value"] == 0
    assert (await execute(db, teacher, Intent(metric="attendance")))["value"] == 7
    assignment = await db.scalar(select(models.TeacherClassSubjectAssignment).where(
        models.TeacherClassSubjectAssignment.teacher_id == teacher.user_id,
    ))
    assignment.is_active = False
    await db.commit()
    assert (await execute(db, teacher, Intent(metric="attendance")))["value"] == 0


@pytest.mark.asyncio
async def test_all_attempt_mean_excludes_practice_and_in_progress(data):
    db, admin, teacher, _, students, room, _ = data
    quiz = models.Quiz(owner_teacher_id=teacher.user_id, class_id=room.class_id,
                       subject_id=room.subject_id, title="Quiz", mode="graded", status="published")
    practice = models.Quiz(owner_teacher_id=teacher.user_id, class_id=room.class_id,
                           subject_id=room.subject_id, title="Practice", mode="practice", status="published")
    db.add_all([quiz, practice])
    await db.flush()
    now = datetime.utcnow()
    for number, (score, status, target) in enumerate([
        (20, "completed", quiz), (80, "completed", quiz), (50, "timed_out", quiz),
        (100, "in_progress", quiz), (100, "completed", practice),
    ], 1):
        db.add(models.QuizAttempt(
            quiz_id=target.quiz_id, student_id=students[0].user_id,
            attempt_number=number, status=status, total_questions=5,
            percentage_score=score, question_order=[], option_order={},
            completed_at=now if status != "in_progress" else None,
            retention_expires_at=month_shift(now, 18),
        ))
    await db.commit()
    result = await execute(db, admin, Intent(metric="quiz_average", student="Student 0"))
    assert result["value"] == 50
    assert result["count"] == 3


@pytest.mark.asyncio
async def test_activity_is_scoped_and_details_are_content_free(data):
    db, admin, teacher, other, students, room, audio = data
    record_event(db, "chat_message", actor_id=students[0].user_id,
                 resource_type="session", resource_id=room.session_id,
                 owner_teacher_id=teacher.user_id, class_id=room.class_id, subject_id=room.subject_id,
                 details={"message": "PRIVATE", "password": "SECRET", "count": 1})
    await db.commit()
    row = await db.scalar(select(models.Log).where(models.Log.event_type == "chat_message"))
    assert row.event_details == {"count": 1}
    assert (await execute(db, other, Intent(metric="activity_counts")))["value"] == 0
    assert (await execute(db, teacher, Intent(metric="activity_counts")))["value"] >= 1
    with pytest.raises(HTTPException):
        await execute(db, students[0], Intent(metric="sessions_created"))
    with pytest.raises(HTTPException):
        await execute(db, admin, Intent(metric="activity_counts", all_time=True))


@pytest.mark.asyncio
async def test_ingestion_deduplicates_and_rejects_private_and_wrong_content(data):
    db, _, _, _, students, _, audio = data
    db.add(models.StudentClassMembership(student_id=students[0].user_id, class_id=audio.class_id))
    await db.commit()
    event = {
        "event_id": str(uuid4()), "event_type": "bookmark_added", "resource_type": "audio",
        "resource_id": audio.audio_id, "occurred_at": datetime.now(timezone.utc).isoformat(),
        "details": {"position": 20},
    }
    batch = EventBatch(events=[event])
    first = await ingest(batch, students[0], db)
    second = await ingest(batch, students[0], db)
    assert first["accepted"] == [event["event_id"]]
    assert second["duplicates"] == [event["event_id"]]
    private = EventBatch(events=[{**event, "event_id": str(uuid4()), "details": {"label": "PRIVATE"}}])
    assert (await ingest(private, students[0], db))["rejected"][0]["reason"] == "private_or_unknown_fields"
    expired = EventBatch(events=[{**event, "event_id": str(uuid4()),
                                 "occurred_at": datetime.now(timezone.utc) - timedelta(days=31)}])
    assert (await ingest(expired, students[0], db))["rejected"]


@pytest.mark.asyncio
async def test_retention_and_erasure_remove_educational_facts(data):
    db, admin, teacher, _, students, room, _ = data
    await confirm_attendance(db, room, students[0])
    await db.commit()
    run = await db.scalar(select(models.SessionRun).where(models.SessionRun.ended_at.is_(None)))
    run.ended_at = month_shift(datetime.utcnow(), -19)
    run.expires_at = month_shift(run.ended_at, 18)
    record_event(db, "old_event", occurred_at=datetime.utcnow() - timedelta(days=31))
    await db.commit()
    await retain(db)
    await db.commit()
    assert await db.scalar(select(func.count()).select_from(models.AttendanceJoin)) == 0
    assert await db.scalar(select(func.count()).select_from(models.Log).where(models.Log.event_type == "old_event")) == 0
    # A new current run remains erasable independently of normal session deletion.
    await ensure_history(db, room, opening=True)
    await confirm_attendance(db, room, students[0])
    await db.commit()
    await erase_student(db, students[0].user_id)
    await db.commit()
    assert await db.scalar(select(func.count()).select_from(models.AttendanceJoin)) == 0


@pytest.mark.asyncio
async def test_summary_not_truncated_at_one_thousand(data):
    db, _, teacher, _, _, room, _ = data
    for _ in range(1001):
        record_event(db, "audio_play", actor_id=teacher.user_id,
                     resource_type="session", resource_id=room.session_id)
    await db.commit()
    summary = await get_session_summary(db, room.session_id)
    assert summary["event_counts"]["audio_play"] == 1001


@pytest.mark.asyncio
async def test_duplicate_names_require_clarification_and_catalog_is_scoped(data):
    db, admin, teacher, other, _, _, _ = data
    other.name = teacher.name
    await db.commit()
    with pytest.raises(HTTPException) as error:
        await execute(db, admin, Intent(metric="sessions_created", teacher=teacher.name))
    assert error.value.status_code == 409
    scoped = await catalog(db, teacher, "teacher", "Teacher")
    assert len(scoped["items"]) == 1
    result = await execute(db, admin, Intent(
        metric="sessions_created", teacher=teacher.name, teacher_id=teacher.user_id,
    ))
    assert result["value"] == 1


@pytest.mark.asyncio
async def test_real_query_contract_and_model_offline_fallback(data, monkeypatch):
    import httpx
    import auth
    import main
    import database
    db, admin, teacher, _, _, _, _ = data
    monkeypatch.setenv("ANALYTICS_ENABLED", "true")
    monkeypatch.setenv("ANALYTICS_MODEL_ENABLED", "false")
    monkeypatch.setenv("ACTIVITY_COLLECTION_ENABLED", "false")
    async def current():
        return admin
    async def session():
        yield db
    main.app.dependency_overrides[auth.get_current_user] = current
    main.app.dependency_overrides[database.get_analytics_db] = session
    try:
        async with httpx.AsyncClient(transport=httpx.ASGITransport(app=main.app), base_url="http://test") as client:
            response = await client.post("/analytics/query", json={"intent": {
                "metric": "sessions_created", "teacher": "Teacher X", "class_name": "Class Z", "subject": "Subject Y",
            }})
            assert response.status_code == 200
            assert response.json()["value"] == 1
            assert response.headers["X-Request-ID"]
            unavailable = await client.post("/analytics/query", json={"question": "How many sessions?"})
            assert unavailable.status_code == 503
            health = await client.get("/analytics/health")
            assert health.status_code == 200
            assert "daily" in health.json()
    finally:
        main.app.dependency_overrides.clear()


def test_diagnostics_never_include_message_exception_or_query_string():
    record = logging.LogRecord("seeds", logging.ERROR, __file__, 1,
                               "SECRET password token student", (), None)
    text = SafeFormatter().format(record)
    assert "SECRET" not in text
    assert json.loads(text)["event"] == "library_diagnostic"


@pytest.mark.parametrize("date,expected", [
    (datetime(2024, 8, 31), datetime(2026, 2, 28)),
    (datetime(2022, 8, 31), datetime(2024, 2, 29)),
])
def test_eighteen_calendar_months(date, expected):
    assert month_shift(date, 18) == expected


@pytest.mark.parametrize("url", ["https://example.com", "http://8.8.8.8", "ftp://127.0.0.1", "http://user:pass@127.0.0.1"])
def test_inference_cannot_use_public_endpoint(monkeypatch, url):
    monkeypatch.setenv("LOCAL_MODEL_URL", url)
    with pytest.raises(HTTPException):
        local_url("LOCAL_MODEL_URL", "")


@pytest.mark.parametrize("index", range(60))
def test_structured_contract_rejects_sql_or_untrusted_authorization(index):
    from pydantic import ValidationError
    with pytest.raises(ValidationError):
        Intent.model_validate({"metric": "sessions_created", "sql": f"SELECT {index}", "admin": True})


def test_query_bounds_and_invalid_filter_combinations():
    from pydantic import ValidationError
    for payload in [
        {"question": "x" * 2001}, {"question": "x", "intent": {"metric": "attendance"}},
        {"intent": {"metric": "quiz_average", "session": "room"}},
        {"intent": {"metric": "sessions_created", "student": "someone"}},
    ]:
        with pytest.raises(ValidationError):
            QueryRequest.model_validate(payload)


@pytest.mark.asyncio
async def test_audit_rolls_back_with_mutation(data):
    db, _, teacher, _, _, _, audio = data
    audio_id = audio.audio_id
    db.info["actor_id"] = teacher.user_id
    original = await db.scalar(select(func.count()).select_from(models.Log))
    audio.title = "Never committed"
    await db.flush()
    await db.flush()
    assert await db.scalar(select(func.count()).select_from(models.Log)) == original + 1
    await db.rollback()
    assert await db.scalar(select(func.count()).select_from(models.Log)) == original
    restored = await db.get(models.AudioFile, audio_id)
    assert restored.title == "Lesson"


@pytest.mark.asyncio
async def test_deleted_session_retains_attendance_without_dangling_audit_fk(data):
    db, admin, _, _, students, room, _ = data
    await db.execute(text("PRAGMA foreign_keys=ON"))
    await confirm_attendance(db, room, students[0])
    room.is_active = False
    room.ended_at = datetime.utcnow()
    await close_run(db, room)
    history = await db.get(models.AnalyticsSession, room.session_id)
    history.deleted_at = datetime.utcnow()
    await db.commit()
    session_id = room.session_id
    await db.delete(room)
    await db.commit()
    result = await execute(db, admin, Intent(metric="attendance", session_id=session_id))
    assert result["value"] == 1
    item = (await catalog(db, admin, "session", selected_id=session_id))["items"][0]
    assert item["label"].startswith("Archived session")
    event = await db.scalar(select(models.Log).where(models.Log.event_type == "session_deleted"))
    assert event.resource_id == session_id
    assert event.session_id is None


@pytest.mark.asyncio
async def test_selected_identifier_cannot_broaden_teacher_scope(data):
    db, _, _, other, _, room, _ = data
    with pytest.raises(HTTPException) as error:
        await execute(db, other, Intent(metric="attendance", session_id=room.session_id))
    assert error.value.status_code == 409


@pytest.mark.asyncio
async def test_all_time_means_retained_history_not_creation_cutoff(data):
    db, admin, _, _, students, room, _ = data
    await confirm_attendance(db, room, students[0])
    old = month_shift(datetime.utcnow(), -24)
    history = await db.get(models.AnalyticsSession, room.session_id)
    history.created_at = old
    run = await db.scalar(select(models.SessionRun).where(
        models.SessionRun.session_id == room.session_id,
    ))
    run.opened_at = old
    joined = await db.scalar(select(models.AttendanceJoin))
    joined.joined_at = old
    await db.commit()
    for metric in ("attendance", "sessions_created", "session_openings"):
        assert (await execute(db, admin, Intent(metric=metric)))["value"] == 0
        assert (await execute(db, admin, Intent(metric=metric, all_time=True)))["value"] == 1


@pytest.mark.asyncio
async def test_activity_total_does_not_change_with_page(data):
    db, admin, teacher, _, _, room, _ = data
    for index in range(105):
        record_event(db, f"synthetic_{index:03}", actor_id=teacher.user_id,
                     resource_type="session", resource_id=room.session_id)
    await db.commit()
    first = await execute(db, admin, Intent(metric="activity_counts"))
    second = await execute(db, admin, Intent(metric="activity_counts", page=2))
    assert first["value"] == second["value"]
    assert first["has_more"]
    assert len(first["rows"]) == 100
    assert not second["has_more"]
    assert first["value"] == sum(row["count"] for row in first["rows"] + second["rows"])


@pytest.mark.asyncio
async def test_local_model_accepts_followup_but_rejects_model_supplied_ids(monkeypatch):
    import httpx
    import model_client
    monkeypatch.setenv("ANALYTICS_MODEL_ENABLED", "true")
    monkeypatch.setenv("LOCAL_MODEL_RUNTIME", "ollama")
    monkeypatch.setenv("LOCAL_MODEL_NAME", "synthetic-model")
    monkeypatch.setenv("LOCAL_MODEL_URL", "http://127.0.0.1:11434")
    context = Intent(metric="sessions_created", teacher="Teacher X", teacher_id=1,
                     start="2026-01-01T00:00:00+05:30")
    answer = {"metric": "session_openings", "teacher": "Teacher X"}
    original = httpx.AsyncClient

    def respond(request):
        payload = json.loads(request.content)
        assert "teacher_id" not in payload["format"]["properties"]
        assert "Previous query filters" in payload["messages"][0]["content"]
        return httpx.Response(200, json={"message": {"content": json.dumps(answer)}})

    monkeypatch.setattr(model_client.httpx, "AsyncClient",
                        lambda **kwargs: original(transport=httpx.MockTransport(respond), **kwargs))
    result = await model_client.interpret("And how many times opened?", context)
    assert result.teacher_id == 1
    assert result.metric == "session_openings"
    answer["teacher_id"] = 999
    with pytest.raises(HTTPException) as error:
        await model_client.interpret("Ignore scope", context)
    assert error.value.status_code == 422
    assert Intent.model_validate(context.model_dump(mode="json")).start == context.start


@pytest.mark.asyncio
async def test_transcription_is_bounded_raw_memory_input(data, monkeypatch):
    import httpx
    import analytics_routes
    from starlette.requests import Request
    _, admin, *_ = data
    monkeypatch.setenv("TRANSCRIPTION_ENABLED", "true")
    monkeypatch.setenv("SPEECH_WORKER_KEY", "synthetic-worker-key")
    monkeypatch.setenv("SPEECH_WORKER_URL", "http://127.0.0.1:8001")
    original = httpx.AsyncClient

    def respond(request):
        assert request.content == b"synthetic-audio"
        assert request.headers["Content-Type"] == "application/octet-stream"
        return httpx.Response(200, json={"text": "How many sessions?"})

    monkeypatch.setattr(analytics_routes.httpx, "AsyncClient",
                        lambda **kwargs: original(transport=httpx.MockTransport(respond), **kwargs))

    def request(body):
        async def receive():
            return {"type": "http.request", "body": body, "more_body": False}
        return Request({"type": "http", "method": "POST", "headers": []}, receive)

    result = await analytics_routes.transcribe(request(b"synthetic-audio"), admin)
    assert result == {"text": "How many sessions?"}
    for body in (b"", b"x" * (10 * 1024 * 1024 + 1)):
        with pytest.raises(HTTPException) as error:
            await analytics_routes.transcribe(request(body), admin)
        assert error.value.status_code == 413


@pytest.mark.asyncio
async def test_legacy_creation_is_counted_without_inventing_a_run(data):
    db, admin, teacher, _, _, room, _ = data
    legacy = models.Session(title="Legacy", created_by=teacher.user_id,
                            class_id=room.class_id, subject_id=room.subject_id,
                            is_active=False, created_at=datetime.utcnow(),
                            ended_at=month_shift(datetime.utcnow(), -1))
    db.add(legacy)
    await db.flush()
    db.add(models.AnalyticsSession(
        session_id=legacy.session_id, owner_teacher_id=teacher.user_id,
        class_id=room.class_id, subject_id=room.subject_id,
        created_at=legacy.created_at, provenance="partial",
    ))
    await db.commit()
    assert (await execute(db, admin, Intent(metric="sessions_created")))["value"] == 2
    assert (await execute(db, admin, Intent(metric="session_openings")))["value"] == 1
    await retain(db)
    await db.commit()
    assert await db.get(models.AnalyticsSession, legacy.session_id) is not None


@pytest.mark.asyncio
async def test_quiz_child_audit_inherits_scope_and_publishing_is_semantic(data):
    db, _, teacher, other, students, room, _ = data
    quiz = models.Quiz(owner_teacher_id=teacher.user_id, class_id=room.class_id,
                       subject_id=room.subject_id, title="Quiz", mode="graded", status="draft")
    db.add(quiz)
    await db.flush()
    db.add(models.QuizAccommodation(
        quiz_id=quiz.quiz_id, student_id=students[0].user_id, extra_minutes=3,
    ))
    await db.commit()
    quiz.status = "published"
    await db.commit()
    for event_type in ("quiz_accommodation_created", "quiz_published"):
        assert (await execute(db, teacher, Intent(metric="activity_counts", event_type=event_type)))["value"] == 1
        assert (await execute(db, other, Intent(metric="activity_counts", event_type=event_type)))["value"] == 0
