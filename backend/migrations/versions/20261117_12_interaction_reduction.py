"""Interaction reduction: phone-number sign-in, shared phones, timetable,
class lifecycle, durable jobs, class alerts and the administrator issue queue.

The deployment is in testing with no data to preserve; this migration only
adds schema. Tables that startup `create_all` already made are left in
place and only missing columns, constraints and indexes are added. Duplicate live sessions (impossible to create from now on) are
closed first so the one-live-class indexes can be built.
"""

from alembic import op
import sqlalchemy as sa

revision = "20261117_12"
down_revision = "20261112_11"
branch_labels = None
depends_on = None


def _inspect():
    return sa.inspect(op.get_bind())


def _create_table(name, *columns, **kwargs):
    if name not in _inspect().get_table_names():
        op.create_table(name, *columns, **kwargs)


def _create_index(name, table, columns, **kwargs):
    if name not in {index["name"] for index in _inspect().get_indexes(table)}:
        op.create_index(name, table, columns, **kwargs)


def _add_missing_columns(batch, table, columns):
    existing = {column["name"] for column in _inspect().get_columns(table)}
    for column in columns:
        if column.name not in existing:
            batch.add_column(column)


def upgrade() -> None:
    _create_table(
        "device_groups",
        sa.Column("group_id", sa.Integer(), primary_key=True),
        sa.Column("name", sa.String(120), nullable=False),
        sa.Column("entry_phone_number", sa.Text(), nullable=False, unique=True),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("created_at", sa.TIMESTAMP(), nullable=False, server_default=sa.func.now()),
    )
    _create_table(
        "device_group_members",
        sa.Column("member_id", sa.Integer(), primary_key=True),
        sa.Column("group_id", sa.Integer(), sa.ForeignKey("device_groups.group_id", ondelete="CASCADE"), nullable=False),
        sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False),
        sa.Column("profile_code", sa.String(8), nullable=False),
        sa.UniqueConstraint("group_id", "profile_code", name="uq_device_group_profile_code"),
        sa.UniqueConstraint("user_id", name="uq_device_group_member_user"),
    )
    _create_table(
        "timetable_entries",
        sa.Column("entry_id", sa.Integer(), primary_key=True),
        sa.Column("teacher_id", sa.Integer(), sa.ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False),
        sa.Column("class_id", sa.Integer(), sa.ForeignKey("classes.class_id", ondelete="RESTRICT"), nullable=False),
        sa.Column("subject_id", sa.Integer(), sa.ForeignKey("subjects.subject_id", ondelete="RESTRICT"), nullable=False),
        sa.Column("weekday", sa.Integer(), nullable=False),
        sa.Column("start_minute", sa.Integer(), nullable=False),
        sa.Column("end_minute", sa.Integer(), nullable=False),
        sa.Column("valid_from", sa.Date()),
        sa.Column("valid_until", sa.Date()),
        sa.Column("lesson_playlist_id", sa.Integer(), sa.ForeignKey("teacher_playlists.playlist_id", ondelete="SET NULL")),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("created_at", sa.TIMESTAMP(), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(
            ["class_id", "subject_id"],
            ["class_subject_associations.class_id", "class_subject_associations.subject_id"],
            name="fk_timetable_class_subject", ondelete="RESTRICT",
        ),
        sa.CheckConstraint("weekday >= 0 AND weekday <= 6", name="check_timetable_weekday"),
        sa.CheckConstraint(
            "start_minute >= 0 AND end_minute <= 1440 AND start_minute < end_minute",
            name="check_timetable_minutes",
        ),
    )
    _create_index("ix_timetable_teacher_day", "timetable_entries", ["teacher_id", "weekday"])
    _create_index("ix_timetable_class_day", "timetable_entries", ["class_id", "weekday"])
    _create_table(
        "timetable_occurrence_overrides",
        sa.Column("override_id", sa.Integer(), primary_key=True),
        sa.Column("entry_id", sa.Integer(), sa.ForeignKey("timetable_entries.entry_id", ondelete="CASCADE"), nullable=False),
        sa.Column("occurrence_date", sa.Date(), nullable=False),
        sa.Column("is_cancelled", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("substitute_teacher_id", sa.Integer(), sa.ForeignKey("users.user_id", ondelete="SET NULL")),
        sa.Column("lesson_playlist_id", sa.Integer(), sa.ForeignKey("teacher_playlists.playlist_id", ondelete="SET NULL")),
        sa.Column("note", sa.Text()),
        sa.UniqueConstraint("entry_id", "occurrence_date", name="uq_occurrence_override"),
    )
    _create_table(
        "school_holidays",
        sa.Column("holiday_id", sa.Integer(), primary_key=True),
        sa.Column("holiday_date", sa.Date(), nullable=False, unique=True),
        sa.Column("name", sa.String(120), nullable=False),
    )
    _create_table(
        "scheduled_jobs",
        sa.Column("job_id", sa.Integer(), primary_key=True),
        sa.Column("kind", sa.String(40), nullable=False),
        sa.Column("dedupe_key", sa.String(200), nullable=False, unique=True),
        sa.Column("run_at", sa.TIMESTAMP(), nullable=False),
        sa.Column("payload", sa.JSON(), nullable=False),
        sa.Column("status", sa.String(20), nullable=False, server_default="pending"),
        sa.Column("attempts", sa.Integer(), nullable=False, server_default=sa.text("0")),
        sa.Column("last_error", sa.Text()),
        sa.Column("locked_until", sa.TIMESTAMP()),
        sa.Column("created_at", sa.TIMESTAMP(), nullable=False, server_default=sa.func.now()),
        sa.Column("completed_at", sa.TIMESTAMP()),
        sa.CheckConstraint(
            "status IN ('pending', 'running', 'done', 'failed', 'cancelled')", name="check_job_status",
        ),
    )
    _create_index("ix_job_due", "scheduled_jobs", ["status", "run_at"])
    _create_table(
        "admin_issues",
        sa.Column("issue_id", sa.Integer(), primary_key=True),
        sa.Column("kind", sa.String(40), nullable=False),
        sa.Column("dedupe_key", sa.String(200), nullable=False, unique=True),
        sa.Column("message", sa.Text(), nullable=False),
        sa.Column("details", sa.JSON()),
        sa.Column("status", sa.String(20), nullable=False, server_default="open"),
        sa.Column("occurrences", sa.Integer(), nullable=False, server_default=sa.text("1")),
        sa.Column("created_at", sa.TIMESTAMP(), nullable=False, server_default=sa.func.now()),
        sa.Column("last_seen_at", sa.TIMESTAMP(), nullable=False, server_default=sa.func.now()),
        sa.Column("resolved_at", sa.TIMESTAMP()),
        sa.Column("resolved_by", sa.Integer(), sa.ForeignKey("users.user_id", ondelete="SET NULL")),
        sa.CheckConstraint("status IN ('open', 'resolved')", name="check_admin_issue_status"),
    )
    _create_index("ix_admin_issue_status", "admin_issues", ["status", "last_seen_at"])

    with op.batch_alter_table("users") as batch:
        _add_missing_columns(batch, "users", [
            sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        ])
    with op.batch_alter_table("participants") as batch:
        _add_missing_columns(batch, "participants", [sa.Column("first_connected_at", sa.TIMESTAMP())])
    foreign_keys = {key["name"] for key in _inspect().get_foreign_keys("sessions")}
    uniques = {constraint["name"] for constraint in _inspect().get_unique_constraints("sessions")}
    with op.batch_alter_table("sessions") as batch:
        _add_missing_columns(batch, "sessions", [
            sa.Column("timetable_entry_id", sa.Integer()),
            sa.Column("occurrence_date", sa.Date()),
            sa.Column("scheduled_start", sa.TIMESTAMP()),
            sa.Column("scheduled_end", sa.TIMESTAMP()),
            sa.Column("started_at", sa.TIMESTAMP()),
            sa.Column("cutoff_at", sa.TIMESTAMP()),
            sa.Column("extension_minutes", sa.Integer(), nullable=False, server_default=sa.text("0")),
            sa.Column("lesson_playlist_id", sa.Integer()),
            sa.Column("end_reason", sa.String(20)),
        ])
        if "fk_session_timetable_entry" not in foreign_keys:
            batch.create_foreign_key(
                "fk_session_timetable_entry", "timetable_entries",
                ["timetable_entry_id"], ["entry_id"], ondelete="SET NULL",
            )
        if "fk_session_lesson_playlist" not in foreign_keys:
            batch.create_foreign_key(
                "fk_session_lesson_playlist", "teacher_playlists",
                ["lesson_playlist_id"], ["playlist_id"], ondelete="SET NULL",
            )
        if "uq_session_occurrence" not in uniques:
            batch.create_unique_constraint("uq_session_occurrence", ["timetable_entry_id", "occurrence_date"])

    _create_table(
        "class_alerts",
        sa.Column("alert_id", sa.String(36), primary_key=True),
        sa.Column("session_id", sa.Integer(), sa.ForeignKey("sessions.session_id", ondelete="CASCADE"), nullable=False),
        sa.Column("kind", sa.String(20), nullable=False),
        sa.Column("requested_by", sa.Integer(), sa.ForeignKey("users.user_id", ondelete="SET NULL")),
        sa.Column("created_at", sa.TIMESTAMP(), nullable=False),
        sa.Column("ring_until", sa.TIMESTAMP(), nullable=False),
        sa.CheckConstraint(
            "kind IN ('start', 'auto_reminder', 'manual_reminder')", name="check_class_alert_kind",
        ),
    )
    _create_table(
        "class_alert_recipients",
        sa.Column("recipient_id", sa.Integer(), primary_key=True),
        sa.Column("alert_id", sa.String(36), sa.ForeignKey("class_alerts.alert_id", ondelete="CASCADE"), nullable=False),
        sa.Column("session_id", sa.Integer(), nullable=False),
        sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False),
        sa.Column("status", sa.String(20), nullable=False),
        sa.Column("created_at", sa.TIMESTAMP(), nullable=False),
        sa.Column("sent_at", sa.TIMESTAMP()),
        sa.UniqueConstraint("alert_id", "user_id", name="uq_class_alert_recipient"),
    )
    _create_index(
        "ix_class_alert_cooldown", "class_alert_recipients", ["session_id", "user_id", "created_at"],
    )

    bind = op.get_bind()
    true = "true" if bind.dialect.name == "postgresql" else "1"
    false = "false" if bind.dialect.name == "postgresql" else "0"
    # Keep only the newest live session per teacher and per class.
    for column in ("created_by", "class_id"):
        bind.execute(sa.text(
            f"UPDATE sessions SET is_active = {false}, ended_at = CURRENT_TIMESTAMP, end_reason = 'migration' "
            f"WHERE is_active = {true} AND {column} IS NOT NULL AND session_id NOT IN ("
            f"SELECT MAX(session_id) FROM sessions WHERE is_active = {true} AND {column} IS NOT NULL "
            f"GROUP BY {column})"
        ))
    for name, column in (("uq_live_session_teacher", "created_by"), ("uq_live_session_class", "class_id")):
        _create_index(
            name, "sessions", [column], unique=True,
            postgresql_where=sa.text("is_active = true"), sqlite_where=sa.text("is_active = 1"),
        )


def downgrade() -> None:
    op.drop_index("uq_live_session_class", table_name="sessions")
    op.drop_index("uq_live_session_teacher", table_name="sessions")
    op.drop_index("ix_class_alert_cooldown", table_name="class_alert_recipients")
    op.drop_table("class_alert_recipients")
    op.drop_table("class_alerts")
    with op.batch_alter_table("sessions") as batch:
        batch.drop_constraint("uq_session_occurrence", type_="unique")
        batch.drop_constraint("fk_session_lesson_playlist", type_="foreignkey")
        batch.drop_constraint("fk_session_timetable_entry", type_="foreignkey")
        for column in (
            "end_reason", "lesson_playlist_id", "extension_minutes", "cutoff_at", "started_at",
            "scheduled_end", "scheduled_start", "occurrence_date", "timetable_entry_id",
        ):
            batch.drop_column(column)
    with op.batch_alter_table("participants") as batch:
        batch.drop_column("first_connected_at")
    with op.batch_alter_table("users") as batch:
        batch.drop_column("is_active")
    op.drop_index("ix_admin_issue_status", table_name="admin_issues")
    op.drop_table("admin_issues")
    op.drop_index("ix_job_due", table_name="scheduled_jobs")
    op.drop_table("scheduled_jobs")
    op.drop_table("school_holidays")
    op.drop_table("timetable_occurrence_overrides")
    op.drop_index("ix_timetable_class_day", table_name="timetable_entries")
    op.drop_index("ix_timetable_teacher_day", table_name="timetable_entries")
    op.drop_table("timetable_entries")
    op.drop_table("device_group_members")
    op.drop_table("device_groups")
