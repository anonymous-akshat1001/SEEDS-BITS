"""Preserve teacher-reviewed notation and traceable question revisions."""

from alembic import op
import sqlalchemy as sa

revision = "20261020_06"
down_revision = "20261020_05"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("question_bank_questions", sa.Column("revision", sa.Integer()))
    op.add_column("quiz_questions", sa.Column("source_revision", sa.Integer()))
    for table in ("question_bank_questions", "quiz_questions"):
        op.add_column(table, sa.Column("topics", sa.JSON()))
        op.add_column(table, sa.Column("notation", sa.String(20), nullable=False, server_default="plain_text"))
        op.add_column(table, sa.Column("spoken_question_text", sa.Text()))
        op.add_column(table, sa.Column("spoken_options", sa.JSON()))
        op.add_column(table, sa.Column("spoken_explanation", sa.Text()))
        op.add_column(table, sa.Column("spoken_reviewed", sa.Boolean(), nullable=False, server_default=sa.false()))
    op.create_table(
        "question_bank_revisions",
        sa.Column("question_id", sa.Integer(), sa.ForeignKey("question_bank_questions.question_id", ondelete="CASCADE"), primary_key=True),
        sa.Column("revision", sa.Integer(), primary_key=True),
        sa.Column("content", sa.JSON(), nullable=False),
        sa.Column("recorded_at", sa.TIMESTAMP(), nullable=False, server_default=sa.func.now()),
    )


def downgrade() -> None:
    op.drop_table("question_bank_revisions")
    for table in ("question_bank_questions", "quiz_questions"):
        for column in ("spoken_reviewed", "spoken_explanation", "spoken_options", "spoken_question_text", "notation", "topics"):
            op.drop_column(table, column)
    op.drop_column("quiz_questions", "source_revision")
    op.drop_column("question_bank_questions", "revision")
