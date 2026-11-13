import sys
from pathlib import Path

import pytest
import pytest_asyncio
from sqlalchemy import inspect, text
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.future import select
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import auth  # noqa: E402
import bootstrap  # noqa: E402
import models  # noqa: E402
import reset_db  # noqa: E402


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


@pytest.mark.asyncio
@pytest.mark.parametrize("with_legacy_sequences", [True, False])
async def test_reset_handles_retired_sequences_and_preserves_unrelated_tables(
    db, monkeypatch, with_legacy_sequences,
):
    _environment(monkeypatch)
    monkeypatch.setattr(reset_db, "engine", db.bind)
    async with db.bind.begin() as connection:
        await connection.execute(text("PRAGMA foreign_keys=ON"))
        await connection.execute(text(
            "INSERT INTO subjects (subject_id, name) VALUES (99, 'Legacy subject')"
        ))
        await connection.execute(text("CREATE TABLE unrelated_records (value TEXT)"))
        await connection.execute(text("INSERT INTO unrelated_records VALUES ('keep')"))
        if with_legacy_sequences:
            await connection.execute(text("""
                CREATE TABLE lesson_sequences (
                    sequence_id INTEGER PRIMARY KEY,
                    subject_id INTEGER NOT NULL REFERENCES subjects(subject_id)
                        ON DELETE RESTRICT
                )
            """))
            await connection.execute(text("INSERT INTO lesson_sequences VALUES (1, 99)"))

    await reset_db.reset_and_seed()

    async with db.bind.connect() as connection:
        tables = await connection.run_sync(lambda sync: inspect(sync).get_table_names())
        assert "lesson_sequences" not in tables
        assert "learning_journeys" in tables
        assert (await connection.execute(text(
            "SELECT value FROM unrelated_records"
        ))).scalars().all() == ["keep"]
        assert (await connection.execute(text(
            "SELECT name FROM subjects ORDER BY name"
        ))).scalars().all() == ["English", "Maths", "Science"]
        assert (await connection.execute(text(
            "SELECT count(*) FROM class_subject_associations"
        ))).scalar_one() == 42
        assert (await connection.execute(text(
            "SELECT phone_number, role FROM users"
        ))).all() == [("9999999999", "admin")]
