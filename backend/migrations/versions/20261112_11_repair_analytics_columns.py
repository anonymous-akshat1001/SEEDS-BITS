"""Repair databases where the analytics columns were never added.

Startup `create_all` creates missing tables but never adds columns to
existing ones, so a database whose analytics tables were created that way and
then stamped at head lacks the new `logs` and `quiz_attempts` columns. Every
student quiz request then fails. This migration only adds what is missing and
is a no-op on correctly migrated databases.
"""

import calendar
from datetime import datetime

from alembic import op
import sqlalchemy as sa

revision = "20261112_11"
down_revision = "20261109_10"
branch_labels = None
depends_on = None


def _columns(bind, table):
    return {column["name"] for column in sa.inspect(bind).get_columns(table)}


def _indexes(bind, table):
    return {index["name"] for index in sa.inspect(bind).get_indexes(table)}


def upgrade():
    bind = op.get_bind()
    tables = set(sa.inspect(bind).get_table_names())

    if "logs" in tables:
        existing = _columns(bind, "logs")
        fields = [
            sa.Column("event_id", sa.String(36)),
            sa.Column("schema_version", sa.Integer(), nullable=False, server_default="1"),
            sa.Column("resource_type", sa.String(40)),
            sa.Column("resource_id", sa.Integer()),
            sa.Column("owner_teacher_id", sa.Integer()),
            sa.Column("class_id", sa.Integer()),
            sa.Column("subject_id", sa.Integer()),
            sa.Column("source", sa.String(24), nullable=False, server_default="legacy"),
            sa.Column("outcome", sa.String(24), nullable=False, server_default="observed"),
            sa.Column("received_at", sa.TIMESTAMP(), server_default=sa.func.now()),
            sa.Column("request_id", sa.String(36)),
        ]
        missing = [field for field in fields if field.name not in existing]
        if missing:
            with op.batch_alter_table("logs") as batch:
                for field in missing:
                    batch.add_column(field)
                if any(field.name == "event_id" for field in missing):
                    batch.create_unique_constraint("uq_logs_event_id", ["event_id"])
        indexes = _indexes(bind, "logs")
        for name, columns in [
            ("ix_logs_scope_time", ["owner_teacher_id", "class_id", "subject_id", "created_at"]),
            ("ix_logs_type_time", ["event_type", "created_at"]),
            ("ix_logs_owner_teacher_id", ["owner_teacher_id"]),
        ]:
            if name not in indexes:
                op.create_index(name, "logs", columns)

    if "quiz_attempts" in tables and "retention_expires_at" not in _columns(bind, "quiz_attempts"):
        with op.batch_alter_table("quiz_attempts") as batch:
            batch.add_column(sa.Column("retention_expires_at", sa.TIMESTAMP()))
            batch.create_index("ix_quiz_attempts_retention_expires_at", ["retention_expires_at"])
        # Same 18-month retention the analytics migration gives finished attempts.
        for row in bind.execute(sa.text(
            "SELECT attempt_id, completed_at FROM quiz_attempts WHERE completed_at IS NOT NULL"
        )).mappings():
            value = row["completed_at"]
            ended = datetime.fromisoformat(value) if isinstance(value, str) else value
            year, month = divmod(ended.year * 12 + ended.month - 1 + 18, 12)
            month += 1
            expires = ended.replace(
                year=year, month=month,
                day=min(ended.day, calendar.monthrange(year, month)[1]),
            )
            bind.execute(sa.text(
                "UPDATE quiz_attempts SET retention_expires_at=:expires WHERE attempt_id=:id"
            ), {"expires": expires, "id": row["attempt_id"]})


def downgrade():
    # Repair only; the columns belong to 20261102_09 and are removed there.
    pass
