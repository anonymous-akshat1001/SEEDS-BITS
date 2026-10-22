import sqlite3
import sys
from pathlib import Path
import pytest

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
        CREATE TABLE participants (
            participant_id INTEGER PRIMARY KEY,
            session_id INTEGER NOT NULL,
            hand_raised BOOLEAN DEFAULT 0
        );
        INSERT INTO participants VALUES (1, 1, 1);
        INSERT INTO users VALUES (1, 'Legacy teacher', '9000000001', 'teacher', 'legacy-hash');
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
    command.upgrade(configuration, "20261020_04")
    with sqlite3.connect(database_path) as before_policy:
        before_policy.executescript("""
            CREATE TABLE fcm_tokens (
                token_id INTEGER PRIMARY KEY,
                user_id INTEGER NOT NULL REFERENCES users(user_id),
                token TEXT NOT NULL,
                device_type VARCHAR(20),
                created_at TIMESTAMP,
                last_used TIMESTAMP
            );
            INSERT INTO users VALUES (2, 'Legacy learner', '9000000002', 'student', 'learner-hash');
            INSERT INTO fcm_tokens (token_id, user_id, token) VALUES
                (1, 1, 'ambiguous-cross-account'),
                (2, 2, 'ambiguous-cross-account'),
                (3, 1, 'duplicate-same-account'),
                (4, 1, 'duplicate-same-account'),
                (5, 2, 'unambiguous-token');
        """)
        before_policy.execute(
            "INSERT INTO quizzes (quiz_id, class_id, subject_id, title, status) VALUES (1, 1, 1, 'Legacy quiz', 'published')"
        )
        before_policy.execute(
            "INSERT INTO quiz_questions (quiz_question_id, quiz_id, question_text, position) VALUES (1, 1, 'Legacy wording', 0)"
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
    assert version == ("20261020_08",)
    assert "lesson_sequences" in table_names
    with sqlite3.connect(database_path) as migrated:
        assert migrated.execute(
            "SELECT user_id, token FROM fcm_tokens"
        ).fetchall() == [(2, "unambiguous-token")]
        with pytest.raises(sqlite3.IntegrityError):
            migrated.execute(
                "INSERT INTO fcm_tokens (user_id, token) VALUES (1, 'unambiguous-token')"
            )
        assert migrated.execute(
            "SELECT password_hash, auth_version, must_change_password, "
            "temporary_password_failures, temporary_password_expires_at FROM users WHERE user_id = 1"
        ).fetchone() == ("legacy-hash", 0, 0, 0, None)
        assert migrated.execute(
            "SELECT title, mode, feedback_policy FROM quizzes WHERE quiz_id = 1"
        ).fetchone() == ("Legacy quiz", "graded", "legacy_immediate")
        assert migrated.execute(
            "SELECT question_text, source_revision, topics, spoken_question_text FROM quiz_questions WHERE quiz_question_id = 1"
        ).fetchone() == ("Legacy wording", None, None, None)
        assert migrated.execute("SELECT count(*) FROM question_bank_revisions").fetchone() == (0,)
        assert migrated.execute("SELECT hand_queue_sequence FROM sessions WHERE session_id = 1").fetchone() == (0,)
        assert migrated.execute(
            "SELECT hand_raised, hand_queue_order, hand_revision FROM participants WHERE participant_id = 1"
        ).fetchone() == (1, None, 0)
