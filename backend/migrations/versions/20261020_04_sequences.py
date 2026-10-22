"""Add private, teacher-owned reusable lesson plans without changing classrooms."""

from alembic import op
import sqlalchemy as sa

revision = "20261020_04"
down_revision = "20261020_03"
branch_labels = None
depends_on = None


def upgrade() -> None:
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


def downgrade() -> None:
    op.drop_table("lesson_sequences")
