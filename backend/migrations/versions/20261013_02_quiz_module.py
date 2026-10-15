"""Add retained question-bank and quiz academic records.

Revision ID: 20261013_02
Revises: 20261013_01
Create Date: 2026-10-13
"""

from typing import Optional

from alembic import op
import sqlalchemy as sa


revision = "20261013_02"
down_revision: Optional[str] = "20261013_01"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "question_bank_questions",
        sa.Column("question_id", sa.Integer(), primary_key=True),
        sa.Column("owner_teacher_id", sa.Integer(), nullable=False),
        sa.Column("class_id", sa.Integer(), nullable=False),
        sa.Column("subject_id", sa.Integer(), nullable=False),
        sa.Column("question_text", sa.Text(), nullable=False),
        sa.Column("explanation", sa.Text()),
        sa.Column("is_archived", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("created_at", sa.TIMESTAMP(), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.TIMESTAMP(), nullable=False, server_default=sa.func.now()),
        sa.Column("archived_at", sa.TIMESTAMP()),
        sa.ForeignKeyConstraint(["owner_teacher_id"], ["users.user_id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["class_id"], ["classes.class_id"], ondelete="RESTRICT"),
        sa.ForeignKeyConstraint(["subject_id"], ["subjects.subject_id"], ondelete="RESTRICT"),
        sa.ForeignKeyConstraint(
            ["class_id", "subject_id"],
            ["class_subject_associations.class_id", "class_subject_associations.subject_id"],
            name="fk_bank_question_class_subject",
            ondelete="RESTRICT",
        ),
    )
    op.create_index(
        "ix_bank_question_owner_workspace",
        "question_bank_questions",
        ["owner_teacher_id", "class_id", "subject_id"],
    )
    op.create_index(
        "ix_bank_question_owner_archived",
        "question_bank_questions",
        ["owner_teacher_id", "is_archived"],
    )
    op.create_table(
        "question_bank_options",
        sa.Column("option_id", sa.Integer(), primary_key=True),
        sa.Column("question_id", sa.Integer(), nullable=False),
        sa.Column("option_text", sa.Text(), nullable=False),
        sa.Column("position", sa.Integer(), nullable=False),
        sa.Column("is_correct", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.CheckConstraint("position >= 0 AND position < 4", name="check_bank_option_position"),
        sa.ForeignKeyConstraint(
            ["question_id"], ["question_bank_questions.question_id"], ondelete="CASCADE",
        ),
        sa.UniqueConstraint("question_id", "position", name="uq_bank_option_position"),
    )
    op.create_table(
        "quizzes",
        sa.Column("quiz_id", sa.Integer(), primary_key=True),
        sa.Column("owner_teacher_id", sa.Integer()),
        sa.Column("class_id", sa.Integer(), nullable=False),
        sa.Column("subject_id", sa.Integer(), nullable=False),
        sa.Column("title", sa.String(length=300), nullable=False),
        sa.Column("description", sa.Text()),
        sa.Column("status", sa.String(length=20), nullable=False, server_default="draft"),
        sa.Column("attempt_limit", sa.Integer(), nullable=False, server_default=sa.text("1")),
        sa.Column("opens_at", sa.TIMESTAMP()),
        sa.Column("closes_at", sa.TIMESTAMP()),
        sa.Column("time_limit_minutes", sa.Integer()),
        sa.Column("shuffle_questions", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("shuffle_options", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("created_at", sa.TIMESTAMP(), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.TIMESTAMP(), nullable=False, server_default=sa.func.now()),
        sa.Column("published_at", sa.TIMESTAMP()),
        sa.Column("closed_at", sa.TIMESTAMP()),
        sa.CheckConstraint("status IN ('draft', 'published', 'closed')", name="check_quiz_status"),
        sa.CheckConstraint("attempt_limit >= 1 AND attempt_limit <= 20", name="check_quiz_attempt_limit"),
        sa.CheckConstraint(
            "time_limit_minutes IS NULL OR (time_limit_minutes >= 1 AND time_limit_minutes <= 1440)",
            name="check_quiz_time_limit",
        ),
        sa.CheckConstraint(
            "opens_at IS NULL OR closes_at IS NULL OR opens_at < closes_at",
            name="check_quiz_schedule",
        ),
        sa.ForeignKeyConstraint(["owner_teacher_id"], ["users.user_id"], ondelete="SET NULL"),
        sa.ForeignKeyConstraint(["class_id"], ["classes.class_id"], ondelete="RESTRICT"),
        sa.ForeignKeyConstraint(["subject_id"], ["subjects.subject_id"], ondelete="RESTRICT"),
        sa.ForeignKeyConstraint(
            ["class_id", "subject_id"],
            ["class_subject_associations.class_id", "class_subject_associations.subject_id"],
            name="fk_quiz_class_subject",
            ondelete="RESTRICT",
        ),
    )
    op.create_index(
        "ix_quiz_owner_workspace_status",
        "quizzes",
        ["owner_teacher_id", "class_id", "subject_id", "status"],
    )
    op.create_index(
        "ix_quiz_student_listing",
        "quizzes",
        ["class_id", "subject_id", "status", "opens_at", "closes_at"],
    )
    op.create_table(
        "quiz_questions",
        sa.Column("quiz_question_id", sa.Integer(), primary_key=True),
        sa.Column("quiz_id", sa.Integer(), nullable=False),
        sa.Column("source_question_id", sa.Integer()),
        sa.Column("question_text", sa.Text(), nullable=False),
        sa.Column("explanation", sa.Text()),
        sa.Column("position", sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(["quiz_id"], ["quizzes.quiz_id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(
            ["source_question_id"], ["question_bank_questions.question_id"], ondelete="SET NULL",
        ),
        sa.UniqueConstraint("quiz_id", "position", name="uq_quiz_question_position"),
    )
    op.create_table(
        "quiz_options",
        sa.Column("quiz_option_id", sa.Integer(), primary_key=True),
        sa.Column("quiz_question_id", sa.Integer(), nullable=False),
        sa.Column("option_text", sa.Text(), nullable=False),
        sa.Column("position", sa.Integer(), nullable=False),
        sa.Column("is_correct", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.CheckConstraint("position >= 0 AND position < 4", name="check_quiz_option_position"),
        sa.ForeignKeyConstraint(
            ["quiz_question_id"], ["quiz_questions.quiz_question_id"], ondelete="CASCADE",
        ),
        sa.UniqueConstraint("quiz_question_id", "position", name="uq_quiz_option_position"),
    )
    op.create_table(
        "quiz_attempts",
        sa.Column("attempt_id", sa.Integer(), primary_key=True),
        sa.Column("quiz_id", sa.Integer(), nullable=False),
        sa.Column("student_id", sa.Integer()),
        sa.Column("attempt_number", sa.Integer(), nullable=False),
        sa.Column("status", sa.String(length=20), nullable=False, server_default="in_progress"),
        sa.Column("started_at", sa.TIMESTAMP(), nullable=False, server_default=sa.func.now()),
        sa.Column("deadline_at", sa.TIMESTAMP()),
        sa.Column("completed_at", sa.TIMESTAMP()),
        sa.Column("correct_count", sa.Integer(), nullable=False, server_default=sa.text("0")),
        sa.Column("total_questions", sa.Integer(), nullable=False),
        sa.Column("percentage_score", sa.Float(), nullable=False, server_default=sa.text("0")),
        sa.Column("question_order", sa.JSON(), nullable=False),
        sa.Column("option_order", sa.JSON(), nullable=False),
        sa.CheckConstraint(
            "status IN ('in_progress', 'completed', 'timed_out')",
            name="check_quiz_attempt_status",
        ),
        sa.ForeignKeyConstraint(["quiz_id"], ["quizzes.quiz_id"], ondelete="RESTRICT"),
        sa.ForeignKeyConstraint(["student_id"], ["users.user_id"], ondelete="SET NULL"),
        sa.UniqueConstraint(
            "quiz_id", "student_id", "attempt_number", name="uq_quiz_attempt_number",
        ),
    )
    op.create_index(
        "uq_active_quiz_attempt",
        "quiz_attempts",
        ["quiz_id", "student_id"],
        unique=True,
        postgresql_where=sa.text("status = 'in_progress'"),
        sqlite_where=sa.text("status = 'in_progress'"),
    )
    op.create_index(
        "ix_quiz_attempt_student_quiz",
        "quiz_attempts",
        ["student_id", "quiz_id", "status"],
    )
    op.create_table(
        "quiz_responses",
        sa.Column("response_id", sa.Integer(), primary_key=True),
        sa.Column("attempt_id", sa.Integer(), nullable=False),
        sa.Column("quiz_question_id", sa.Integer(), nullable=False),
        sa.Column("selected_option_id", sa.Integer(), nullable=False),
        sa.Column("is_correct", sa.Boolean(), nullable=False),
        sa.Column("submitted_at", sa.TIMESTAMP(), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(["attempt_id"], ["quiz_attempts.attempt_id"], ondelete="RESTRICT"),
        sa.ForeignKeyConstraint(
            ["quiz_question_id"], ["quiz_questions.quiz_question_id"], ondelete="RESTRICT",
        ),
        sa.ForeignKeyConstraint(
            ["selected_option_id"], ["quiz_options.quiz_option_id"], ondelete="RESTRICT",
        ),
        sa.UniqueConstraint(
            "attempt_id", "quiz_question_id", name="uq_quiz_response_question",
        ),
    )
    op.create_index(
        "ix_quiz_response_question",
        "quiz_responses",
        ["quiz_question_id"],
    )


def downgrade() -> None:
    op.drop_index("ix_quiz_response_question", table_name="quiz_responses")
    op.drop_table("quiz_responses")
    op.drop_index("ix_quiz_attempt_student_quiz", table_name="quiz_attempts")
    op.drop_index("uq_active_quiz_attempt", table_name="quiz_attempts")
    op.drop_table("quiz_attempts")
    op.drop_table("quiz_options")
    op.drop_table("quiz_questions")
    op.drop_index("ix_quiz_student_listing", table_name="quizzes")
    op.drop_index("ix_quiz_owner_workspace_status", table_name="quizzes")
    op.drop_table("quizzes")
    op.drop_table("question_bank_options")
    op.drop_index("ix_bank_question_owner_archived", table_name="question_bank_questions")
    op.drop_index("ix_bank_question_owner_workspace", table_name="question_bank_questions")
    op.drop_table("question_bank_questions")
