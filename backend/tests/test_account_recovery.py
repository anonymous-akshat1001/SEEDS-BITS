import asyncio
import sys
from datetime import datetime, timedelta
from pathlib import Path

import httpx
import pytest
import pytest_asyncio
from fastapi import HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import auth
import database as database_module
import main
import models
from database import get_db
from ws_manager import SESSION_STATE, ws_mgr


@pytest_asyncio.fixture
async def recovery(monkeypatch):
    monkeypatch.setattr(auth, "SECRET_KEY", "synthetic-test-only-recovery-signing-key")
    engine = create_async_engine("sqlite+aiosqlite://", poolclass=StaticPool)
    async with engine.begin() as connection:
        await connection.run_sync(models.Base.metadata.create_all)
    sessions = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    monkeypatch.setattr(database_module, "AsyncSessionLocal", sessions)
    async with sessions() as db:
        users = {}
        for index, role in enumerate(("admin", "teacher", "student")):
            user = models.User(
                name=f"Test {role}", phone_number=f"900000000{index}",
                role=role, password_hash=auth.get_password_hash("old-password"),
            )
            db.add(user)
            users[role] = user
        await db.commit()

        async def database():
            yield db

        old_overrides = main.app.dependency_overrides.copy()
        main.app.dependency_overrides[get_db] = database
        async with httpx.AsyncClient(
            transport=httpx.ASGITransport(app=main.app), base_url="http://test",
        ) as client:
            try:
                yield client, db, users
            finally:
                main.app.dependency_overrides.clear()
                main.app.dependency_overrides.update(old_overrides)
                ws_mgr.active.pop(700, None)
                SESSION_STATE.pop(700, None)
    await engine.dispose()


def headers(user, *, legacy=False):
    claims = {"user_id": user.user_id, "role": user.role}
    if not legacy:
        claims["auth_version"] = user.auth_version
    return {"Authorization": f"Bearer {auth.create_access_token(claims)}"}


async def sign_out(client, users, *, version=0):
    response = await client.post(
        f"/admin/users/{users['student'].user_id}/sign-out-everywhere",
        headers=headers(users["admin"]),
        json={"expected_auth_version": version},
    )
    assert response.status_code == 200, response.text
    return response


async def login(client, user, password):
    return await client.post("/auth/login", data={
        "username": user.phone_number, "password": password,
    })


async def phone_login(client, phone, code=None):
    body = {"phone_number": phone}
    if code is not None:
        body["profile_code"] = code
    return await client.post("/auth/phone-login", json=body)


@pytest.mark.asyncio
async def test_students_and_teachers_sign_in_with_number_only_and_admins_never_can(recovery):
    client, db, users = recovery
    student = await phone_login(client, "9000-000 002")
    assert student.status_code == 200, student.text
    assert student.headers["cache-control"] == "no-store"
    body = student.json()
    assert body["role"] == "student" and body["profile_required"] is False
    bearer = {"Authorization": f"Bearer {body['access_token']}"}
    assert (await client.get("/me/access-context", headers=bearer)).status_code == 200
    teacher = await phone_login(client, users["teacher"].phone_number)
    assert teacher.status_code == 200 and teacher.json()["role"] == "teacher"
    admin = await phone_login(client, users["admin"].phone_number)
    assert admin.status_code == 403
    assert "access_token" not in admin.text
    unknown = await phone_login(client, "9111111111")
    assert unknown.status_code == 401 and "administrator" in unknown.json()["detail"]
    # Password sign-in is only for administrators.
    assert (await login(client, users["teacher"], "old-password")).status_code == 401
    assert (await login(client, users["admin"], "old-password")).status_code == 200
    users["student"].is_active = False
    await db.commit()
    assert (await phone_login(client, users["student"].phone_number)).status_code == 401
    assert (await client.get("/me/access-context", headers=bearer)).status_code == 401


@pytest.mark.asyncio
async def test_shared_phone_selects_profile_by_code_without_granting_admin(recovery):
    client, db, users = recovery
    created = await client.post("/admin/device-groups", headers=headers(users["admin"]), json={
        "name": "Family phone", "entry_phone_number": "9888 000 000",
    })
    assert created.status_code == 200, created.text
    group = created.json()
    for user, code in ((users["student"], "11"), (users["teacher"], "12")):
        added = await client.post(
            f"/admin/device-groups/{group['group_id']}/members",
            headers=headers(users["admin"]), json={"user_id": user.user_id, "profile_code": code},
        )
        assert added.status_code == 200, added.text
    admin_member = await client.post(
        f"/admin/device-groups/{group['group_id']}/members",
        headers=headers(users["admin"]), json={"user_id": users["admin"].user_id, "profile_code": "13"},
    )
    assert admin_member.status_code == 404
    duplicate_phone = await client.post("/admin/device-groups", headers=headers(users["admin"]), json={
        "name": "Clash", "entry_phone_number": users["student"].phone_number,
    })
    assert duplicate_phone.status_code == 409
    asked = await phone_login(client, "9888000000")
    assert asked.status_code == 200
    assert asked.json() == {"profile_required": True, "code_length": 2}
    student = await phone_login(client, "9888000000", "11")
    assert student.status_code == 200 and student.json()["user_id"] == users["student"].user_id
    teacher = await phone_login(client, "9888000000", "12")
    assert teacher.json()["user_id"] == users["teacher"].user_id
    assert (await phone_login(client, "9888000000", "99")).status_code == 401


@pytest.mark.asyncio
async def test_sign_out_everywhere_is_admin_only_versioned_and_preserves_accounts(recovery):
    client, db, users = recovery
    path = f"/admin/users/{users['student'].user_id}/sign-out-everywhere"
    body = {"expected_auth_version": 0}
    for credentials, status in (({}, 401), (headers(users["teacher"]), 403)):
        result = await client.post(path, headers=credentials, json=body)
        assert result.status_code == status
    admin_reset = await client.post(
        f"/admin/users/{users['admin'].user_id}/sign-out-everywhere",
        headers=headers(users["admin"]), json=body,
    )
    assert admin_reset.status_code == 403
    old_token = headers(users["student"], legacy=True)
    assert (await client.get("/catalog/classes", headers=old_token)).status_code == 200
    response = await sign_out(client, users)
    assert response.headers["cache-control"] == "no-store"
    await db.refresh(users["student"])
    student = users["student"]
    assert student.password_reset_by == users["admin"].user_id
    assert student.name == "Test student" and student.role == "student"
    assert student.auth_version == 1 and not student.must_change_password
    assert (await client.get("/catalog/classes", headers=old_token)).status_code == 401
    stale = await client.post(path, headers=headers(users["admin"]), json=body)
    assert stale.status_code == 409
    # The account itself still works: the person signs in again by number.
    assert (await phone_login(client, student.phone_number)).status_code == 200


@pytest.mark.asyncio
async def test_request_diagnostics_use_the_isolated_recovery_database(recovery, monkeypatch):
    client, db, users = recovery
    monkeypatch.setenv("ACTIVITY_COLLECTION_ENABLED", "true")
    response = await client.get("/catalog/classes", headers=headers(users["admin"]))
    assert response.status_code == 200
    events = (await db.execute(select(models.Log).where(
        models.Log.event_type == "http_request",
    ))).scalars().all()
    assert len(events) == 1
    assert events[0].event_details["status"] == 200


async def _temporary_admin_credential(db, admin, credential="000000000000"):
    admin.password_hash = auth.get_password_hash(credential)
    admin.must_change_password = True
    admin.temporary_password_expires_at = datetime.utcnow() + timedelta(hours=24)
    admin.temporary_password_failures = 0
    await db.commit()
    return credential


@pytest.mark.asyncio
async def test_forced_admin_session_cannot_read_mutate_media_or_skip_change(recovery):
    client, db, users = recovery
    credential = await _temporary_admin_credential(db, users["admin"])
    signed_in = await login(client, users["admin"], credential)
    assert signed_in.status_code == 200
    session = signed_in.json()
    assert session["must_change_password"] is True
    bearer = {"Authorization": f"Bearer {session['access_token']}"}
    assert (await client.get("/catalog/classes", headers=bearer)).status_code == 403
    with pytest.raises(HTTPException) as media:
        await auth.get_media_user(session["access_token"], None, db)
    assert media.value.status_code == 403
    unchanged = await client.post("/auth/change-password", headers=bearer, json={
        "current_password": credential, "new_password": credential,
    })
    assert unchanged.status_code == 400
    too_short = await client.post("/auth/change-password", headers=bearer, json={
        "current_password": credential, "new_password": "short",
    })
    assert too_short.status_code == 422
    changed = await client.post("/auth/change-password", headers=bearer, json={
        "current_password": credential, "new_password": "my-new-password",
    })
    assert changed.status_code == 200
    replacement = changed.json()
    assert replacement["ok"] and replacement["must_change_password"] is False
    assert (await client.get("/catalog/classes", headers=bearer)).status_code == 401
    valid = {"Authorization": f"Bearer {replacement['access_token']}"}
    assert (await client.get("/catalog/classes", headers=valid)).status_code == 200
    assert (await login(client, users["admin"], credential)).status_code == 401
    assert (await login(client, users["admin"], "my-new-password")).status_code == 200


@pytest.mark.asyncio
async def test_tenth_failure_pauses_even_valid_temporary_admin_login(recovery):
    client, db, users = recovery
    admin = users["admin"]
    credential = await _temporary_admin_credential(db, admin)
    for attempt in range(1, 11):
        failed = await login(client, admin, "wrong-password")
        assert failed.status_code == (429 if attempt == 10 else 401)
    assert (await login(client, admin, credential)).status_code == 429
    admin.temporary_password_locked_until = datetime.utcnow() - timedelta(seconds=1)
    await db.commit()
    assert (await login(client, admin, credential)).status_code == 200
    admin.temporary_password_expires_at = datetime.utcnow() - timedelta(seconds=1)
    await db.commit()
    assert (await login(client, admin, credential)).status_code == 401


@pytest.mark.asyncio
async def test_sign_out_discards_full_stream_queue_and_push_associations(recovery):
    client, db, users = recovery
    student = users["student"]
    db.add(models.FCMToken(user_id=student.user_id, token="synthetic-token"))
    await db.commit()
    await ws_mgr.connect(700, 77, student.user_id, student.name, False, is_muted=False)
    queue = asyncio.Queue(maxsize=1)
    queue.put_nowait({"type": "chat", "text": "Queued private content"})
    ws_mgr.active[700][77] = queue
    SESSION_STATE[700]["connections"][77] = queue
    before = student.auth_version
    await sign_out(client, users)
    assert await queue.get() == {"type": "authentication_revoked"}
    assert queue.empty()
    assert 77 not in ws_mgr.active[700]
    assert 77 not in SESSION_STATE[700]["participants"]
    assert not await auth.session_is_current(db, student.user_id, before)
    assert (await db.execute(select(models.FCMToken))).scalars().all() == []
