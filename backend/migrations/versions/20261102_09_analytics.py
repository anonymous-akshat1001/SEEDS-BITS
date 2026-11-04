"""Privacy-filtered activity fields and deletion-safe attendance history."""

import calendar
from datetime import datetime

from alembic import op
import sqlalchemy as sa

revision = "20261102_09"
down_revision = "20261020_08"
branch_labels = None
depends_on = None


def upgrade():
    bind = op.get_bind()
    tables = sa.inspect(bind).get_table_names()
    if "logs" not in tables:
        op.create_table(
            "logs",
            sa.Column("log_id", sa.Integer(), primary_key=True),
            sa.Column("session_id", sa.Integer(), sa.ForeignKey("sessions.session_id", ondelete="SET NULL")),
            sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.user_id", ondelete="SET NULL")),
            sa.Column("event_type", sa.String(50), nullable=False),
            sa.Column("event_details", sa.JSON()),
            sa.Column("created_at", sa.TIMESTAMP(), server_default=sa.func.now()),
        )
    fields = [
        sa.Column("event_id", sa.String(36)), sa.Column("schema_version", sa.Integer(), nullable=False, server_default="1"),
        sa.Column("resource_type", sa.String(40)), sa.Column("resource_id", sa.Integer()),
        sa.Column("owner_teacher_id", sa.Integer()), sa.Column("class_id", sa.Integer()),
        sa.Column("subject_id", sa.Integer()),
        sa.Column("source", sa.String(24), nullable=False, server_default="legacy"),
        sa.Column("outcome", sa.String(24), nullable=False, server_default="observed"),
        sa.Column("received_at", sa.TIMESTAMP(), server_default=sa.func.now()),
        sa.Column("request_id", sa.String(36)),
    ]
    convention = {"fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s"}
    foreign_keys = sa.inspect(bind).get_foreign_keys("logs")
    with op.batch_alter_table("logs", naming_convention=convention) as batch:
        for field in fields:
            batch.add_column(field)
        for key in foreign_keys:
            if key["constrained_columns"] == ["session_id"]:
                batch.drop_constraint(key["name"] or "fk_logs_session_id_sessions", type_="foreignkey")
        batch.create_foreign_key("fk_logs_session_id_sessions", "sessions", ["session_id"], ["session_id"], ondelete="SET NULL")
        batch.create_unique_constraint("uq_logs_event_id", ["event_id"])
    op.create_index("ix_logs_scope_time", "logs", ["owner_teacher_id", "class_id", "subject_id", "created_at"])
    op.create_index("ix_logs_type_time", "logs", ["event_type", "created_at"])
    op.create_index("ix_logs_owner_teacher_id", "logs", ["owner_teacher_id"])
    legacy_logs = sa.table("logs", sa.column("event_details", sa.JSON()))
    bind.execute(legacy_logs.update().values(event_details={}))
    with op.batch_alter_table("quiz_attempts") as batch:
        batch.add_column(sa.Column("retention_expires_at", sa.TIMESTAMP()))
        batch.create_index("ix_quiz_attempts_retention_expires_at", ["retention_expires_at"])
    # Legacy attempts are real grades, unlike ambiguous participant placeholders.
    for row in bind.execute(sa.text(
        "SELECT attempt_id, completed_at FROM quiz_attempts WHERE completed_at IS NOT NULL"
    )).mappings():
        value = row["completed_at"]
        ended = datetime.fromisoformat(value) if isinstance(value, str) else value
        year, month = divmod(ended.year * 12 + ended.month - 1 + 18, 12)
        month += 1
        expires = ended.replace(year=year, month=month,
                               day=min(ended.day, calendar.monthrange(year, month)[1]))
        bind.execute(sa.text(
            "UPDATE quiz_attempts SET retention_expires_at=:expires WHERE attempt_id=:id"
        ), {"expires": expires, "id": row["attempt_id"]})
    op.create_table(
        "analytics_sessions",
        sa.Column("session_id", sa.Integer(), primary_key=True, autoincrement=False),
        sa.Column("owner_teacher_id", sa.Integer()), sa.Column("class_id", sa.Integer(), nullable=False),
        sa.Column("subject_id", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.TIMESTAMP(), nullable=False),
        sa.Column("provenance", sa.String(24), nullable=False, server_default="verified"),
        sa.Column("deleted_at", sa.TIMESTAMP()),
    )
    op.create_index("ix_analytics_sessions_owner_teacher_id", "analytics_sessions", ["owner_teacher_id"])
    session_columns = {column["name"] for column in sa.inspect(bind).get_columns("sessions")}
    if {"created_by", "created_at", "is_active", "ended_at"}.issubset(session_columns):
        bind.execute(sa.text(
            "INSERT INTO analytics_sessions "
            "(session_id, owner_teacher_id, class_id, subject_id, created_at, provenance) "
            "SELECT session_id, created_by, class_id, subject_id, created_at, 'partial' "
            "FROM sessions WHERE created_at IS NOT NULL "
            "AND (is_active = true OR ended_at IS NOT NULL)"
        ))
    op.create_table(
        "session_runs",
        sa.Column("run_id", sa.String(36), primary_key=True),
        sa.Column("session_id", sa.Integer(), sa.ForeignKey("analytics_sessions.session_id", ondelete="CASCADE"), nullable=False),
        sa.Column("opened_at", sa.TIMESTAMP(), nullable=False),
        sa.Column("ended_at", sa.TIMESTAMP()), sa.Column("expires_at", sa.TIMESTAMP()),
    )
    op.create_index("ix_session_run_end", "session_runs", ["ended_at"])
    op.create_index("ix_session_runs_expires_at", "session_runs", ["expires_at"])
    op.create_index("uq_open_session_run", "session_runs", ["session_id"], unique=True,
                    postgresql_where=sa.text("ended_at IS NULL"), sqlite_where=sa.text("ended_at IS NULL"))
    op.create_table(
        "analytics_attendance",
        sa.Column("run_id", sa.String(36), sa.ForeignKey("session_runs.run_id", ondelete="CASCADE"), primary_key=True),
        sa.Column("student_id", sa.Integer(), sa.ForeignKey("users.user_id", ondelete="CASCADE"), primary_key=True),
        sa.Column("first_joined_at", sa.TIMESTAMP(), nullable=False),
        sa.Column("last_joined_at", sa.TIMESTAMP(), nullable=False),
    )
    op.create_table(
        "analytics_attendance_joins",
        sa.Column("join_id", sa.String(36), primary_key=True),
        sa.Column("run_id", sa.String(36), sa.ForeignKey("session_runs.run_id", ondelete="CASCADE"), nullable=False),
        sa.Column("student_id", sa.Integer(), sa.ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False),
        sa.Column("joined_at", sa.TIMESTAMP(), nullable=False),
    )
    op.create_index("ix_analytics_attendance_joins_joined_at", "analytics_attendance_joins", ["joined_at"])
    op.create_table(
        "analytics_maintenance",
        sa.Column("name", sa.String(60), primary_key=True),
        sa.Column("succeeded_at", sa.TIMESTAMP()), sa.Column("status", sa.String(24), nullable=False),
        sa.Column("count", sa.Integer(), nullable=False, server_default="0"),
    )


def downgrade():
    raise RuntimeError("Disable analytics flags to roll back code; retained educational facts must not be dropped.")
