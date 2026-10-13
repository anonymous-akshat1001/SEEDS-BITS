import sys
from pathlib import Path

import pytest
import pytest_asyncio
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.future import select
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import auth  # noqa: E402
import bootstrap  # noqa: E402
import models  # noqa: E402


@pytest_asyncio.fixture
async def db():
    engine = create_async_engine(
        "sqlite+aiosqlite://",
        poolclass=StaticPool,
        connect_args={"check_same_thread": False},
    )
    async with engine.begin() as connection:
        await connection.run_sync(models.Base.metadata.create_all)
    factory = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    async with factory() as session:
        yield session
    await engine.dispose()


def _environment(monkeypatch):
    monkeypatch.setenv("BOOTSTRAP_ADMIN_NAME", "Configured Admin")
    monkeypatch.setenv("BOOTSTRAP_ADMIN_PHONE", "9999999999")
    monkeypatch.setenv("BOOTSTRAP_ADMIN_PASSWORD", "strong-password")


@pytest.mark.asyncio
async def test_bootstrap_admin_created_once_without_password_overwrite(
    db,
    monkeypatch,
):
    _environment(monkeypatch)
    created = await bootstrap.ensure_bootstrap_admin(db)
    original_hash = created.password_hash

    monkeypatch.setenv("BOOTSTRAP_ADMIN_PASSWORD", "different-password")
    existing = await bootstrap.ensure_bootstrap_admin(db)

    assert existing.user_id == created.user_id
    assert existing.password_hash == original_hash
    assert auth.verify_password("strong-password", existing.password_hash)
    users = (await db.execute(select(models.User))).scalars().all()
    assert len(users) == 1


def test_bootstrap_admin_configuration_is_required(monkeypatch):
    monkeypatch.delenv("BOOTSTRAP_ADMIN_NAME", raising=False)
    monkeypatch.delenv("BOOTSTRAP_ADMIN_PHONE", raising=False)
    monkeypatch.delenv("BOOTSTRAP_ADMIN_PASSWORD", raising=False)
    with pytest.raises(RuntimeError, match="must all be configured"):
        bootstrap.required_admin_environment()
