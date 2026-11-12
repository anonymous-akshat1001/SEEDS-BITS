"""Replace private lesson sequences with student-facing learning journeys."""

from alembic import op
import sqlalchemy as sa

revision = "20261109_10"
down_revision = "20261102_09"
branch_labels = None
depends_on = None


def upgrade() -> None:
    tables = sa.inspect(op.get_bind()).get_table_names()
    if "lesson_sequences" in tables:
        op.drop_table("lesson_sequences")
    op.create_table(
        "learning_journeys",
        sa.Column("journey_id", sa.Integer(), primary_key=True),
        sa.Column("owner_teacher_id", sa.Integer(), sa.ForeignKey("users.user_id", ondelete="SET NULL")),
        sa.Column("class_id", sa.Integer(), sa.ForeignKey("classes.class_id", ondelete="RESTRICT"), nullable=False),
        sa.Column("subject_id", sa.Integer(), sa.ForeignKey("subjects.subject_id", ondelete="RESTRICT"), nullable=False),
        sa.Column("title", sa.String(160), nullable=False),
        sa.Column("description", sa.Text()),
        sa.Column("status", sa.String(20), nullable=False, server_default="draft"),
        sa.Column("graded", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("max_retries", sa.Integer(), nullable=False, server_default=sa.text("1")),
        sa.Column("revision", sa.Integer(), nullable=False, server_default=sa.text("1")),
        sa.Column("steps", sa.JSON(), nullable=False),
        sa.Column("published_from_revision", sa.Integer()),
        sa.Column("published_revision", sa.Integer()),
        sa.Column("published_at", sa.TIMESTAMP()),
        sa.Column("created_at", sa.TIMESTAMP(), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.TIMESTAMP(), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(
            ["class_id", "subject_id"],
            ["class_subject_associations.class_id", "class_subject_associations.subject_id"],
            name="fk_journey_class_subject", ondelete="RESTRICT",
        ),
        sa.CheckConstraint("status IN ('draft', 'published', 'archived')", name="check_journey_status"),
        sa.CheckConstraint("max_retries >= 0 AND max_retries <= 5", name="check_journey_retries"),
    )
    op.create_index("ix_learning_journeys_owner_teacher_id", "learning_journeys", ["owner_teacher_id"])
    op.create_index("ix_journey_workspace_status", "learning_journeys", ["class_id", "subject_id", "status"])
    op.create_table(
        "journey_snapshots",
        sa.Column("journey_id", sa.Integer(), sa.ForeignKey("learning_journeys.journey_id", ondelete="CASCADE"), primary_key=True),
        sa.Column("revision", sa.Integer(), primary_key=True),
        sa.Column("content", sa.JSON(), nullable=False),
        sa.Column("published_at", sa.TIMESTAMP(), nullable=False, server_default=sa.func.now()),
    )
    op.create_table(
        "journey_runs",
        sa.Column("run_id", sa.String(36), primary_key=True),
        sa.Column("journey_id", sa.Integer(), sa.ForeignKey("learning_journeys.journey_id", ondelete="RESTRICT"), nullable=False),
        sa.Column("journey_revision", sa.Integer(), nullable=False),
        sa.Column("student_id", sa.Integer(), sa.ForeignKey("users.user_id", ondelete="SET NULL")),
        sa.Column("status", sa.String(20), nullable=False, server_default="in_progress"),
        sa.Column("started_at", sa.TIMESTAMP(), nullable=False),
        sa.Column("completed_at", sa.TIMESTAMP()),
        sa.Column("synced_at", sa.TIMESTAMP(), nullable=False, server_default=sa.func.now()),
        sa.Column("played_offline", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("question_count", sa.Integer(), nullable=False, server_default=sa.text("0")),
        sa.Column("first_try_correct", sa.Integer(), nullable=False, server_default=sa.text("0")),
        sa.Column("replays", sa.Integer(), nullable=False, server_default=sa.text("0")),
        sa.Column("percentage_score", sa.Float()),
        sa.CheckConstraint("status IN ('in_progress', 'completed')", name="check_journey_run_status"),
    )
    op.create_index("ix_journey_run_student", "journey_runs", ["journey_id", "student_id", "status"])
    op.create_table(
        "journey_answers",
        sa.Column("answer_id", sa.Integer(), primary_key=True),
        sa.Column("run_id", sa.String(36), sa.ForeignKey("journey_runs.run_id", ondelete="CASCADE"), nullable=False),
        sa.Column("step_index", sa.Integer(), nullable=False),
        sa.Column("attempt", sa.Integer(), nullable=False),
        sa.Column("selected_option", sa.Integer(), nullable=False),
        sa.Column("is_correct", sa.Boolean()),
        sa.Column("answered_at", sa.TIMESTAMP(), nullable=False),
        sa.UniqueConstraint("run_id", "step_index", "attempt", name="uq_journey_answer_attempt"),
    )


def downgrade() -> None:
    op.drop_table("journey_answers")
    op.drop_index("ix_journey_run_student", table_name="journey_runs")
    op.drop_table("journey_runs")
    op.drop_table("journey_snapshots")
    op.drop_index("ix_journey_workspace_status", table_name="learning_journeys")
    op.drop_index("ix_learning_journeys_owner_teacher_id", table_name="learning_journeys")
    op.drop_table("learning_journeys")
    op.create_table(
        "lesson_sequences",
        sa.Column("sequence_id", sa.Integer(), primary_key=True),
        sa.Column("owner_teacher_id", sa.Integer(), sa.ForeignKey("users.user_id", ondelete="RESTRICT"), nullable=False),
        sa.Column("class_id", sa.Integer(), sa.ForeignKey("classes.class_id", ondelete="RESTRICT"), nullable=False),
        sa.Column("subject_id", sa.Integer(), sa.ForeignKey("subjects.subject_id", ondelete="RESTRICT"), nullable=False),
        sa.Column("title", sa.String(160), nullable=False),
        sa.Column("revision", sa.Integer(), nullable=False, server_default=sa.text("1")),
        sa.Column("steps", sa.JSON(), nullable=False),
    )
    op.create_index("ix_lesson_sequences_owner_teacher_id", "lesson_sequences", ["owner_teacher_id"])
