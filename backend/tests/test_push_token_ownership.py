import asyncio
import sys
from pathlib import Path

import httpx
import pytest
import pytest_asyncio
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import auth
import main
import models
from database import get_db


@pytest_asyncio.fixture
async def push_accounts(tmp_path, monkeypatch):
    monkeypatch.setattr(auth, "SECRET_KEY", "synthetic-push-ownership-test-key")
    engine = create_async_engine(f"sqlite+aiosqlite:///{(tmp_path / 'push.db').as_posix()}")
    async with engine.begin() as connection:
        await connection.run_sync(models.Base.metadata.create_all)
    sessions = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    async with sessions() as db:
        users = [
            models.User(name=f"Account {number}", phone_number=f"900000000{number}",
                        role="student", password_hash="unused-test-hash")
            for number in (1, 2)
        ]
        db.add_all(users)
        await db.commit()
        headers = [
            {"Authorization": "Bearer " + auth.create_access_token({"user_id": user.user_id, "auth_version": 0})}
            for user in users
        ]

    async def database():
        async with sessions() as db:
            yield db

    original = main.app.dependency_overrides.copy()
    main.app.dependency_overrides[get_db] = database
    try:
        async with httpx.AsyncClient(
            transport=httpx.ASGITransport(app=main.app), base_url="http://test",
        ) as client:
            yield client, sessions, headers
    finally:
        main.app.dependency_overrides.clear()
        main.app.dependency_overrides.update(original)
        await engine.dispose()


@pytest.mark.asyncio
async def test_shared_token_moves_to_signed_in_account_and_stale_logout_cannot_remove_it(push_accounts):
    client, sessions, headers = push_accounts
    body = {"token": "synthetic-shared-device", "device_type": "mobile"}
    assert (await client.post("/users/fcm-token", headers=headers[0], json=body)).status_code == 200
    assert (await client.post("/users/fcm-token", headers=headers[1], json=body)).json()["ok"]
    async with sessions() as db:
        tokens = (await db.execute(select(models.FCMToken))).scalars().all()
        assert len(tokens) == 1 and tokens[0].user_id == 2
    removed = await client.request("DELETE", "/users/fcm-token", headers=headers[0], json={"token": body["token"]})
    assert removed.status_code == 200
    async with sessions() as db:
        assert (await db.execute(select(models.FCMToken.user_id))).scalar_one() == 2
    assert (await client.request("DELETE", "/users/fcm-token", headers=headers[1], json={"token": body["token"]})).status_code == 200
    async with sessions() as db:
        assert (await db.execute(select(models.FCMToken))).scalars().all() == []


@pytest.mark.asyncio
async def test_concurrent_registration_has_one_owner_and_repeated_registration_is_idempotent(push_accounts):
    client, sessions, headers = push_accounts
    body = {"token": "synthetic-concurrent-device", "device_type": "mobile"}
    responses = await asyncio.gather(*[
        client.post("/users/fcm-token", headers=identity, json=body)
        for identity in headers
    ])
    assert [response.status_code for response in responses] == [200, 200]
    async with sessions() as db:
        tokens = (await db.execute(select(models.FCMToken))).scalars().all()
        assert len(tokens) == 1
        assert tokens[0].user_id in (1, 2)
    for _ in range(2):
        assert (await client.post("/users/fcm-token", headers=headers[0], json=body)).status_code == 200
    async with sessions() as db:
        assert (await db.execute(select(models.FCMToken.user_id))).scalars().all() == [1]


@pytest.mark.asyncio
async def test_push_registration_requires_normal_authenticated_session_and_valid_input(push_accounts):
    client, sessions, headers = push_accounts
    body = {"token": "synthetic-valid-device"}
    assert (await client.post("/users/fcm-token", json=body)).status_code == 401
    for invalid in ({"token": ""}, {"token": "x", "device_type": "x" * 21}):
        assert (await client.post("/users/fcm-token", headers=headers[0], json=invalid)).status_code == 422
    async with sessions() as db:
        user = await db.get(models.User, 1)
        user.must_change_password = True
        await db.commit()
    assert (await client.post("/users/fcm-token", headers=headers[0], json=body)).status_code == 403
