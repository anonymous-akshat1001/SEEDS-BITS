"""Add explicit new assessment policies while preserving legacy quiz feedback."""

from alembic import op
import sqlalchemy as sa

revision = "20261020_05"
down_revision = "20261020_04"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("quizzes", sa.Column("mode", sa.String(20), nullable=False, server_default="graded"))
    op.add_column("quizzes", sa.Column("feedback_policy", sa.String(30), nullable=False, server_default="legacy_immediate"))
    op.add_column("quizzes", sa.Column("feedback_release_at", sa.TIMESTAMP()))
    op.add_column("quiz_attempts", sa.Column("extra_time_minutes", sa.Integer(), nullable=False, server_default=sa.text("0")))
    op.create_table(
        "quiz_accommodations",
        sa.Column("quiz_id", sa.Integer(), sa.ForeignKey("quizzes.quiz_id", ondelete="CASCADE"), primary_key=True),
        sa.Column("student_id", sa.Integer(), sa.ForeignKey("users.user_id", ondelete="CASCADE"), primary_key=True),
        sa.Column("extra_minutes", sa.Integer(), nullable=False, server_default=sa.text("0")),
    )


def downgrade() -> None:
    op.drop_table("quiz_accommodations")
    op.drop_column("quiz_attempts", "extra_time_minutes")
    op.drop_column("quizzes", "feedback_release_at")
    op.drop_column("quizzes", "feedback_policy")
    op.drop_column("quizzes", "mode")
