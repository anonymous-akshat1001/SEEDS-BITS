import asyncio
import re
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


async def reset(client, users, *, version=0):
    response = await client.post(
        f"/admin/users/{users['student'].user_id}/reset-password",
        headers=headers(users["admin"]),
        json={"identity_verified": True, "expected_auth_version": version},
    )
    assert response.status_code == 200, response.text
    return response


async def login(client, user, password):
    return await client.post("/auth/login", data={
        "username": user.phone_number, "password": password,
    })


@pytest.mark.asyncio
async def test_reset_is_admin_only_attested_versioned_and_preserves_accounts(recovery):
    client, db, users = recovery
    path = f"/admin/users/{users['student'].user_id}/reset-password"
    body = {"identity_verified": True, "expected_auth_version": 0}
    for credentials, status in (({}, 401), (headers(users["teacher"]), 403)):
        result = await client.post(path, headers=credentials, json=body)
        assert result.status_code == status
    denied = await client.post(path, headers=headers(users["admin"]), json={
        **body, "identity_verified": False,
    })
    assert denied.status_code == 422
    admin_reset = await client.post(
        f"/admin/users/{users['admin'].user_id}/reset-password",
        headers=headers(users["admin"]), json=body,
    )
    assert admin_reset.status_code == 403
    old_token = headers(users["student"], legacy=True)
    assert (await client.get("/catalog/classes", headers=old_token)).status_code == 200
    response = await reset(client, users)
    assert response.headers["cache-control"] == "no-store"
    data = response.json()
    assert re.fullmatch(r"\d{12}", data["temporary_credential"])
    expires = datetime.fromisoformat(data["expires_at"].removesuffix("Z"))
    assert timedelta(hours=24) - timedelta(seconds=5) < expires - datetime.utcnow() <= timedelta(hours=24)
    await db.refresh(users["student"])
    student = users["student"]
    assert student.password_hash != data["temporary_credential"]
    assert auth.verify_password(data["temporary_credential"], student.password_hash)
    assert student.password_reset_by == users["admin"].user_id
    assert student.name == "Test student" and student.role == "student"
    assert student.auth_version == 1 and student.must_change_password
    assert (await client.get("/catalog/classes", headers=old_token)).status_code == 401
    stale = await client.post(path, headers=headers(users["admin"]), json=body)
    assert stale.status_code == 409
    assert (await login(client, student, "old-password")).status_code == 401
    assert auth.verify_password("old-password", users["teacher"].password_hash)


@pytest.mark.asyncio
async def test_forced_session_cannot_read_mutate_media_or_skip_change(recovery, monkeypatch):
    client, db, users = recovery
    monkeypatch.setattr(main.account_recovery.secrets, "choice", lambda _: "0")
    credential = (await reset(client, users)).json()["temporary_credential"]
    assert credential == "000000000000"
    signed_in = await login(client, users["student"], credential)
    assert signed_in.status_code == 200
    session = signed_in.json()
    assert session["must_change_password"] is True
    bearer = {"Authorization": f"Bearer {session['access_token']}"}
    assert (await client.get("/catalog/classes", headers=bearer)).status_code == 403
    assert (await client.post("/users/fcm-token", headers=bearer, json={
        "token": "synthetic-device-token", "device_type": "android",
    })).status_code == 403
    with pytest.raises(HTTPException) as media:
        await auth.get_media_user(session["access_token"], None, db)
    assert media.value.status_code == 403
    with pytest.raises(HTTPException) as streaming:
        await auth.get_current_user_from_token(session["access_token"], db)
    assert streaming.value.status_code == 403
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
    assert changed.headers["cache-control"] == "no-store"
    replacement = changed.json()
    assert replacement["ok"] and replacement["must_change_password"] is False
    assert (await client.get("/catalog/classes", headers=bearer)).status_code == 401
    valid = {"Authorization": f"Bearer {replacement['access_token']}"}
    assert (await client.get("/catalog/classes", headers=valid)).status_code == 200
    assert (await login(client, users["student"], credential)).status_code == 401
    assert (await login(client, users["student"], "my-new-password")).status_code == 200
    assert users["student"].temporary_password_expires_at is None
    assert users["student"].auth_version == 2


@pytest.mark.asyncio
async def test_tenth_failure_pauses_even_valid_temporary_login_then_recovers(recovery):
    client, db, users = recovery
    credential = (await reset(client, users)).json()["temporary_credential"]
    for attempt in range(1, 11):
        failed = await login(client, users["student"], "wrong-password")
        assert failed.status_code == (429 if attempt == 10 else 401)
    student = users["student"]
    assert student.temporary_password_failures == 10
    assert timedelta(minutes=15) - timedelta(seconds=5) < student.temporary_password_locked_until - datetime.utcnow() <= timedelta(minutes=15)
    assert (await login(client, student, credential)).status_code == 429
    student.temporary_password_locked_until = datetime.utcnow() - timedelta(seconds=1)
    await db.commit()
    assert (await login(client, student, credential)).status_code == 200
    assert student.temporary_password_failures == 0
    assert student.temporary_password_locked_until is None
    student.temporary_password_expires_at = datetime.utcnow() - timedelta(seconds=1)
    await db.commit()
    assert (await login(client, student, credential)).status_code == 401
    replacement = (await reset(client, users, version=1)).json()["temporary_credential"]
    assert (await login(client, student, credential)).status_code == 401
    assert (await login(client, student, replacement)).status_code == 200


@pytest.mark.asyncio
async def test_reset_discards_full_stream_queue_and_push_associations(recovery):
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
    await reset(client, users)
    assert await queue.get() == {"type": "authentication_revoked"}
    assert queue.empty()
    assert 77 not in ws_mgr.active[700]
    assert 77 not in SESSION_STATE[700]["participants"]
    assert not await auth.session_is_current(db, student.user_id, before)
    assert (await db.execute(select(models.FCMToken))).scalars().all() == []
