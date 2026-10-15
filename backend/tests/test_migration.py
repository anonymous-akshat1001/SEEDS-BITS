import sqlite3
import sys
from pathlib import Path

from alembic import command
from alembic.config import Config


def test_class_subject_migration_backfills_legacy_pairs(tmp_path, monkeypatch):
    database_path = tmp_path / "legacy.db"
    connection = sqlite3.connect(database_path)
    connection.executescript(
        """
        CREATE TABLE users (
            user_id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            phone_number TEXT NOT NULL UNIQUE,
            role TEXT NOT NULL,
            password_hash TEXT NOT NULL
        );
        CREATE TABLE classes (
            class_id INTEGER PRIMARY KEY,
            name TEXT NOT NULL UNIQUE,
            sort_order INTEGER NOT NULL UNIQUE,
            is_active BOOLEAN NOT NULL DEFAULT 1,
            created_at TIMESTAMP
        );
        CREATE TABLE subjects (
            subject_id INTEGER PRIMARY KEY,
            name TEXT NOT NULL UNIQUE,
            is_active BOOLEAN NOT NULL DEFAULT 1,
            created_at TIMESTAMP,
            archived_at TIMESTAMP
        );
        CREATE TABLE sessions (
            session_id INTEGER PRIMARY KEY,
            class_id INTEGER NOT NULL,
            subject_id INTEGER NOT NULL
        );
        CREATE TABLE audio_files (
            audio_id INTEGER PRIMARY KEY,
            class_id INTEGER NOT NULL,
            subject_id INTEGER NOT NULL
        );
        CREATE TABLE teacher_class_subject_assignments (
            assignment_id INTEGER PRIMARY KEY,
            teacher_id INTEGER NOT NULL,
            class_id INTEGER NOT NULL,
            subject_id INTEGER NOT NULL
        );
        INSERT INTO classes VALUES (1, 'Class 1', 1, 1, CURRENT_TIMESTAMP);
        INSERT INTO subjects VALUES (1, 'English', 1, CURRENT_TIMESTAMP, NULL);
        INSERT INTO sessions VALUES (1, 1, 1);
        INSERT INTO audio_files VALUES (1, 1, 1);
        INSERT INTO teacher_class_subject_assignments VALUES (1, 1, 1, 1);
        """
    )
    connection.commit()
    connection.close()

    monkeypatch.setenv(
        "DATABASE_URL",
        f"sqlite+aiosqlite:///{database_path.as_posix()}",
    )
    root = Path(__file__).resolve().parents[2]
    configuration = Config(str(root / "alembic.ini"))
    configuration.set_main_option(
        "script_location",
        str(root / "backend" / "migrations"),
    )
    command.upgrade(configuration, "head")

    connection = sqlite3.connect(database_path)
    rows = connection.execute(
        "SELECT class_id, subject_id, is_active "
        "FROM class_subject_associations"
    ).fetchall()
    version = connection.execute(
        "SELECT version_num FROM alembic_version"
    ).fetchone()
    connection.close()

    assert rows == [(1, 1, 1)]
    quiz_tables = connection = sqlite3.connect(database_path)
    table_names = {
        row[0]
        for row in quiz_tables.execute(
            "SELECT name FROM sqlite_master WHERE type = 'table'"
        ).fetchall()
    }
    quiz_tables.close()

    assert {
        "question_bank_questions",
        "quizzes",
        "quiz_attempts",
        "quiz_responses",
    }.issubset(table_names)
    assert version == ("20261013_02",)
