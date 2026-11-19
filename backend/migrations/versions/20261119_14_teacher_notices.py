"""Teacher notices: what an administrator did on a teacher's behalf.

Only adds a table; tolerant of databases where startup already created it.
"""

from alembic import op
import sqlalchemy as sa

revision = "20261119_14"
down_revision = "20261119_13"
branch_labels = None
depends_on = None


def upgrade() -> None:
    inspector = sa.inspect(op.get_bind())
    if "teacher_notices" not in inspector.get_table_names():
        op.create_table(
            "teacher_notices",
            sa.Column("notice_id", sa.Integer(), primary_key=True),
            sa.Column("teacher_id", sa.Integer(), sa.ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False),
            sa.Column("actor_id", sa.Integer(), sa.ForeignKey("users.user_id", ondelete="SET NULL")),
            sa.Column("kind", sa.String(10), nullable=False),
            sa.Column("item_id", sa.Integer(), nullable=False),
            sa.Column("title", sa.String(300), nullable=False),
            sa.Column("action", sa.String(12), nullable=False),
            sa.Column("created_at", sa.TIMESTAMP(), nullable=False),
            sa.Column("seen_at", sa.TIMESTAMP()),
            sa.CheckConstraint("kind IN ('quiz', 'journey')", name="check_teacher_notice_kind"),
            sa.CheckConstraint(
                "action IN ('created', 'published', 'closed', 'archived')",
                name="check_teacher_notice_action",
            ),
        )
    indexes = {index["name"] for index in sa.inspect(op.get_bind()).get_indexes("teacher_notices")}
    if "ix_teacher_notice_unseen" not in indexes:
        op.create_index("ix_teacher_notice_unseen", "teacher_notices", ["teacher_id", "seen_at"])


def downgrade() -> None:
    op.drop_index("ix_teacher_notice_unseen", table_name="teacher_notices")
    op.drop_table("teacher_notices")
