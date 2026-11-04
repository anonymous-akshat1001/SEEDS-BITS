"""HTTP/database regressions; real local inference is an explicit opt-in."""

import asyncio
import json
import os
import sys
from datetime import datetime, timedelta
from pathlib import Path
from uuid import uuid4

import httpx
import pytest
import pytest_asyncio
from httpx import AsyncClient
from sqlalchemy import event
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import analytics_routes
import analytics_service
import auth
import database
import main
import model_client
import models
from analytics_schemas import Intent

NOW = datetime(2026, 11, 4, 6, 30)


class ReportingClock(datetime):
    @classmethod
    def utcnow(cls):
        return NOW


def credentials(user):
    token = auth.create_access_token({
        "user_id": user.user_id, "role": user.role, "auth_version": user.auth_version,
    })
    return {"Authorization": "Bearer " + token}


@pytest_asyncio.fixture
async def campus(monkeypatch):
    monkeypatch.setenv("ANALYTICS_ENABLED", "true")
    monkeypatch.setenv("ACTIVITY_COLLECTION_ENABLED", "false")
    monkeypatch.setattr(auth, "SECRET_KEY", "synthetic-only-analytics-e2e-signing-key")
    monkeypatch.setattr(auth, "ALLOW_DEV_USER_IMPERSONATION", False)
    monkeypatch.setattr(analytics_service, "datetime", ReportingClock)
    monkeypatch.setattr(analytics_routes, "_limits", analytics_routes.defaultdict(analytics_routes.deque))
    monkeypatch.setattr(analytics_routes, "_inference", asyncio.Semaphore(1))
    engine = create_async_engine("sqlite+aiosqlite://", poolclass=StaticPool)

    @event.listens_for(engine.sync_engine, "connect")
    def foreign_keys(connection, _):
        cursor = connection.cursor()
        cursor.execute("PRAGMA foreign_keys=ON")
        cursor.close()

    factory = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    monkeypatch.setattr(database, "AsyncSessionLocal", factory)
    monkeypatch.setattr(database, "AnalyticsSessionLocal", factory)
    try:
        async with engine.begin() as connection:
            await connection.run_sync(models.Base.metadata.create_all)
        async with factory() as db:
            names = [
                ("admin", "Campus Admin", "admin"), ("teacher", "Teacher Ishan", "teacher"),
                ("other", "Teacher Leela", "teacher"),
                *[(f"s{i}", f"Student {name}", "student")
                  for i, name in enumerate(("Anaya", "Dev", "Farah", "Kabir", "Noor", "Ritu", "Dev", "Uma"))],
            ]
            users = {}
            for index, (key, name, role) in enumerate(names):
                users[key] = models.User(
                    name=name, role=role, phone_number=f"synthetic-{index}", password_hash="unused",
                )
            school = models.SchoolClass(name="Class 6", sort_order=1)
            subject = models.Subject(name="Geography")
            db.add_all([*users.values(), school, subject])
            await db.flush()
            db.add(models.ClassSubjectAssociation(class_id=school.class_id, subject_id=subject.subject_id))
            await db.flush()
            assignments = {}
            for key in ("teacher", "other"):
                assignments[key] = models.TeacherClassSubjectAssignment(
                    teacher_id=users[key].user_id, class_id=school.class_id, subject_id=subject.subject_id,
                )
                db.add(assignments[key])
            await db.flush()
            rooms, runs = {}, {}
            for key, title, owner, age, expired in [
                ("river", "River Workshop", "teacher", 5, False),
                ("older", "Older Workshop", "teacher", 40, False),
                ("other", "Other Workshop", "other", 3, False),
                ("expired", "Expired Workshop", "teacher", 600, True),
                ("active", "Long Running Workshop", "teacher", 700, False),
            ]:
                opened = NOW - timedelta(days=age)
                room = models.Session(
                    title=title, created_by=users[owner].user_id, class_id=school.class_id,
                    subject_id=subject.subject_id, created_at=opened,
                    is_active=key == "active", ended_at=None if key == "active" else opened + timedelta(hours=1),
                )
                db.add(room)
                await db.flush()
                db.add(models.AnalyticsSession(
                    session_id=room.session_id, owner_teacher_id=room.created_by,
                    class_id=school.class_id, subject_id=subject.subject_id, created_at=opened,
                ))
                await db.flush()
                run = models.SessionRun(
                    run_id=str(uuid4()), session_id=room.session_id,
                    opened_at=NOW - timedelta(days=2) if key == "older" else opened,
                    ended_at=None if key == "active" else opened + timedelta(hours=1),
                    expires_at=None if key == "active" else NOW + timedelta(days=-1 if expired else 300),
                )
                db.add(run)
                rooms[key], runs[key] = room, run
            await db.flush()
            runs["reopen"] = models.SessionRun(
                run_id=str(uuid4()), session_id=rooms["river"].session_id,
                opened_at=NOW - timedelta(days=1), ended_at=NOW - timedelta(hours=12),
                expires_at=NOW + timedelta(days=300),
            )
            db.add(runs["reopen"])
            await db.flush()
            for key, students in [
                ("river", (0, 0, 1)), ("reopen", (0, 2)), ("older", (2, 3)),
                ("other", (4,)), ("expired", (5,)), ("active", (5,)),
            ]:
                for index in students:
                    db.add(models.AttendanceJoin(
                        join_id=str(uuid4()), run_id=runs[key].run_id, student_id=users[f"s{index}"].user_id,
                        joined_at=runs[key].opened_at + timedelta(minutes=10),
                    ))
            quizzes = {}
            for key, owner, mode in [
                ("graded", "teacher", "graded"), ("practice", "teacher", "practice"),
                ("other", "other", "graded"),
            ]:
                quizzes[key] = models.Quiz(
                    title=key, owner_teacher_id=users[owner].user_id,
                    class_id=school.class_id, subject_id=subject.subject_id,
                    mode=mode, status="published",
                )
                db.add(quizzes[key])
            await db.flush()
            for number, (quiz, student, score, status, age, expired) in enumerate([
                ("graded", 0, 20, "completed", 2, False),
                ("graded", 0, 80, "completed", 2, False),
                ("graded", 0, 50, "timed_out", 2, False),
                ("graded", 1, 100, "completed", 2, False),
                ("graded", 0, 100, "in_progress", 0, False),
                ("practice", 0, 100, "completed", 2, False),
                ("graded", 0, 90, "completed", 600, True),
                ("other", 4, 10, "completed", 2, False),
            ], 1):
                db.add(models.QuizAttempt(
                    quiz_id=quizzes[quiz].quiz_id, student_id=users[f"s{student}"].user_id,
                    attempt_number=number, status=status, total_questions=5,
                    percentage_score=score, question_order=[], option_order={},
                    completed_at=None if status == "in_progress" else NOW - timedelta(days=age),
                    retention_expires_at=NOW + timedelta(days=-1 if expired else 300),
                ))
            for owner, age, source in [
                ("teacher", 1, "client_reported"), ("teacher", 1, "client_reported"),
                ("teacher", 1, "server"), ("other", 1, "client_reported"),
                ("other", 1, "client_reported"), ("teacher", 31, "client_reported"),
            ]:
                db.add(models.Log(
                    event_type="learning_pause", source=source, event_details={},
                    user_id=users["s0"].user_id, owner_teacher_id=users[owner].user_id,
                    class_id=school.class_id, subject_id=subject.subject_id,
                    created_at=NOW - timedelta(days=age),
                ))
            await db.commit()

            async def isolated_db():
                async with factory() as session:
                    yield session

            overrides = main.app.dependency_overrides.copy()
            main.app.dependency_overrides[database.get_db] = isolated_db
            main.app.dependency_overrides[database.get_analytics_db] = isolated_db
            try:
                async with httpx.AsyncClient(
                    transport=httpx.ASGITransport(app=main.app), base_url="http://test",
                ) as client:
                    yield client, db, users, rooms, assignments
            finally:
                main.app.dependency_overrides.clear()
                main.app.dependency_overrides.update(overrides)
    finally:
        await engine.dispose()


async def structured(client, user, metric, **filters):
    return await client.post("/analytics/query", headers=credentials(user),
                             json={"intent": {"metric": metric, **filters}})


@pytest.mark.asyncio
@pytest.mark.parametrize("role,metric,value,count", [
    ("admin", "sessions_created", 2, 2), ("admin", "session_openings", 4, 4),
    ("admin", "attendance", 5, 5), ("admin", "quiz_average", 52, 5),
    ("admin", "quiz_attempts", 5, 5), ("admin", "activity_counts", 5, 5),
    ("teacher", "sessions_created", 1, 1), ("teacher", "session_openings", 3, 3),
    ("teacher", "attendance", 4, 4), ("teacher", "quiz_average", 62.5, 4),
    ("teacher", "quiz_attempts", 4, 4), ("teacher", "activity_counts", 3, 3),
    ("other", "attendance", 1, 1), ("other", "quiz_average", 10, 1),
])
async def test_seeded_numeric_answers_and_http_contract(campus, role, metric, value, count):
    client, _, users, _, _ = campus
    response = await structured(client, users[role], metric)
    assert response.status_code == 200, response.text
    body = response.json()
    assert body["value"] == value
    assert body["count"] == count
    assert body["status"] == "answered"
    assert body["metric"] == body["intent"]["metric"] == metric
    assert body["has_more"] is False
    assert body["timezone"] == "Asia/Kolkata"
    assert body["as_of"] == NOW.isoformat() + "Z"
    assert body["coverage"]
    if metric == "quiz_average":
        assert "%" in body["answer"]
    if metric == "activity_counts":
        assert sum(row["count"] for row in body["rows"]) == count


@pytest.mark.asyncio
async def test_retained_all_time_and_session_deduplication(campus):
    client, _, users, _, _ = campus
    for metric, expected in [("sessions_created", 4), ("session_openings", 5), ("attendance", 6)]:
        result = await structured(client, users["admin"], metric, all_time=True)
        assert result.status_code == 200, result.text
        assert result.json()["value"] == expected
    for metric, expected in [("sessions_created", 1), ("session_openings", 2), ("attendance", 3)]:
        result = await structured(client, users["admin"], metric, session="River Workshop")
        assert result.status_code == 200
        assert result.json()["value"] == expected
    result = await structured(client, users["admin"], "activity_counts", all_time=True)
    assert result.status_code == 422


@pytest.mark.asyncio
async def test_timezone_boundaries_are_inclusive_start_exclusive_end(campus):
    client, _, users, _, _ = campus
    # River Workshop was created at 12:00 IST on October 30.
    for start, end, expected in [
        ("2026-10-30T12:00:00+05:30", "2026-10-30T12:00:01+05:30", 1),
        ("2026-10-30T11:59:59+05:30", "2026-10-30T12:00:00+05:30", 0),
    ]:
        response = await structured(
            client, users["admin"], "sessions_created", start=start, end=end,
        )
        assert response.status_code == 200
        assert response.json()["value"] == expected
        assert response.json()["filters"]["start"] == Intent(
            metric="sessions_created", start=start,
        ).model_dump(mode="json")["start"]


@pytest.mark.asyncio
async def test_student_mean_no_data_and_duplicate_names(campus):
    client, _, users, _, _ = campus
    result = await structured(client, users["admin"], "quiz_average", student="Student Anaya")
    assert result.status_code == 200
    assert (result.json()["value"], result.json()["count"]) == (50, 3)
    empty = await structured(client, users["admin"], "quiz_average", student="Student Uma")
    assert empty.status_code == 200
    assert (empty.json()["status"], empty.json()["value"], empty.json()["count"]) == ("no_data", None, 0)
    assert empty.json()["answer"] == "No finalized graded attempts."
    duplicate = await structured(client, users["admin"], "quiz_average", student="Student Dev")
    assert duplicate.status_code == 409
    assert duplicate.json()["detail"]["status"] == "clarification_required"
    selected = await structured(
        client, users["admin"], "quiz_average", student="Student Dev", student_id=users["s1"].user_id,
    )
    assert selected.status_code == 200
    assert selected.json()["value"] == 100


@pytest.mark.asyncio
async def test_quiz_date_boundaries_and_retention_are_independent(campus):
    client, _, users, _, _ = campus
    for metric, expected in [("quiz_average", 52), ("quiz_attempts", 5)]:
        retained = await structured(client, users["admin"], metric, all_time=True)
        assert retained.status_code == 200
        assert retained.json()["value"] == expected
    for start, end, expected in [
        ("2026-11-02T12:00:00+05:30", "2026-11-02T12:00:01+05:30", 5),
        ("2026-11-02T11:59:59+05:30", "2026-11-02T12:00:00+05:30", 0),
    ]:
        response = await structured(
            client, users["admin"], "quiz_attempts", start=start, end=end,
        )
        assert response.status_code == 200
        assert response.json()["value"] == expected


@pytest.mark.asyncio
async def test_authentication_scope_ids_and_assignment_revocation(campus, monkeypatch):
    client, db, users, rooms, assignments = campus

    async def never_infer(*args):
        pytest.fail("Unauthorized questions must be denied before inference.")

    monkeypatch.setattr(analytics_routes, "interpret", never_infer)
    assert (await client.post("/analytics/query", json={"question": "Count attendees."})).status_code == 401
    result = await client.post("/analytics/query", headers=credentials(users["s0"]),
                               json={"question": "Count attendees."})
    assert result.status_code == 403
    denied = await structured(
        client, users["teacher"], "attendance", session_id=rooms["other"].session_id,
    )
    assert denied.status_code == 409
    assert denied.json()["detail"]["clarifications"] == []
    assignments["teacher"].is_active = False
    await db.commit()
    assert (await structured(client, users["teacher"], "attendance")).json()["value"] == 0
    revoked = await structured(
        client, users["teacher"], "attendance", session_id=rooms["river"].session_id,
    )
    assert revoked.status_code == 409
    assert revoked.json()["detail"]["clarifications"] == []


QUESTION_CASES = [
    ("How many unique students attended River Workshop?",
     {"metric": "attendance", "session": "River Workshop"}, None, 3, 3),
    ("What is Student Anaya's average finalized graded quiz percentage?",
     {"metric": "quiz_average", "student": "Student Anaya"}, None, 50, 3),
    ("How many finalized graded attempts are there for Student Anaya?",
     {"metric": "quiz_attempts", "student": "Student Anaya"}, None, 3, 3),
    ("Count opening runs for River Workshop.",
     {"metric": "session_openings", "session": "River Workshop"}, None, 2, 2),
    ("Count originally created sessions for Teacher Ishan.",
     {"metric": "sessions_created", "teacher": "Teacher Ishan"}, None, 1, 1),
    ("Count learning_pause events for Teacher Ishan.",
     {"metric": "activity_counts", "teacher": "Teacher Ishan", "event_type": "learning_pause"}, None, 3, 3),
    ("For the same session, count opening runs instead of attendees.",
     {"metric": "session_openings", "session": "River Workshop"},
     {"metric": "attendance", "session": "River Workshop"}, 2, 2),
]


def simulated_runtime(monkeypatch, output):
    def reply(request):
        assert request.url.host in {"localhost", "127.0.0.1"}
        return httpx.Response(200, json={
            "message": {"content": json.dumps(output)}, "done_reason": "stop",
        })

    monkeypatch.setenv("ANALYTICS_MODEL_ENABLED", "true")
    monkeypatch.setenv("LOCAL_MODEL_RUNTIME", "ollama")
    monkeypatch.setenv("LOCAL_MODEL_NAME", "synthetic-contract-model")
    monkeypatch.setenv("LOCAL_MODEL_URL", "http://127.0.0.1:11434")
    monkeypatch.setattr(model_client.httpx, "AsyncClient",
                        lambda **kwargs: AsyncClient(transport=httpx.MockTransport(reply), **kwargs))


@pytest.mark.asyncio
@pytest.mark.parametrize("question,expected,context,value,count", QUESTION_CASES)
async def test_question_to_validated_model_output_to_database_answer(
    campus, monkeypatch, question, expected, context, value, count,
):
    client, _, users, _, _ = campus
    simulated_runtime(monkeypatch, expected)
    payload = {"question": question}
    if context is not None:
        payload["context"] = context
    response = await client.post("/analytics/query", headers=credentials(users["admin"]), json=payload)
    assert response.status_code == 200, response.text
    assert response.json()["intent"] == Intent(**expected).model_dump(mode="json")
    assert (response.json()["value"], response.json()["count"]) == (value, count)


@pytest.mark.asyncio
@pytest.mark.parametrize("output,status", [
    ({"metric": "clarification_required"}, 422),
    ({"metric": "quiz_average", "student_id": 999}, 422),
    ({"metric": "quiz_average", "student": "Student Dev"}, 409),
])
async def test_untrusted_or_ambiguous_model_output_does_not_answer(campus, monkeypatch, output, status):
    client, _, users, _, _ = campus
    simulated_runtime(monkeypatch, output)
    response = await client.post("/analytics/query", headers=credentials(users["admin"]),
                                 json={"question": "Synthetic ambiguous or unsupported question."})
    assert response.status_code == status
    assert "value" not in response.json()


@pytest.mark.asyncio
async def test_question_and_followup_ids_cannot_bypass_teacher_scope(campus, monkeypatch):
    client, db, users, rooms, assignments = campus
    simulated_runtime(monkeypatch, {"metric": "attendance"})
    response = await client.post("/analytics/query", headers=credentials(users["teacher"]),
                                 json={"question": "Count unique attendees."})
    assert response.status_code == 200
    assert response.json()["value"] == 4
    simulated_runtime(monkeypatch, {"metric": "attendance", "session": "River Workshop"})
    assignments["teacher"].is_active = False
    await db.commit()
    response = await client.post("/analytics/query", headers=credentials(users["teacher"]), json={
        "question": "Repeat that same attendance query.",
        "context": {"metric": "attendance", "session": "River Workshop",
                    "session_id": rooms["river"].session_id},
    })
    assert response.status_code == 409
    assert response.json()["detail"]["clarifications"] == []


@pytest.mark.asyncio
@pytest.mark.skipif(os.getenv("RUN_ANALYTICS_MODEL_E2E") != "true",
                    reason="Explicitly opt in to calls to an already provisioned local model.")
@pytest.mark.parametrize("question,expected,context,value,count", QUESTION_CASES)
async def test_live_model_question_to_database_answer(campus, question, expected, context, value, count):
    assert os.getenv("ANALYTICS_MODEL_ENABLED", "").lower() == "true", "Enable the local model explicitly."
    client, _, users, _, _ = campus
    payload = {"question": question}
    if context is not None:
        payload["context"] = context
    response = await client.post("/analytics/query", headers=credentials(users["admin"]), json=payload)
    assert response.status_code == 200, response.text
    assert response.json()["intent"] == Intent(**expected).model_dump(mode="json")
    assert (response.json()["value"], response.json()["count"]) == (value, count)
