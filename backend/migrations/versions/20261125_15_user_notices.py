"""Notices for every account: lessons and published class work.

Teachers also hear about lessons an administrator added, changed, removed,
cancelled or handed to a substitute; students hear what was published or
scheduled for their class. Widens the kind and action checks and adds a
short detail (an ISO date for one-day changes).
"""

from alembic import op
import sqlalchemy as sa

revision = "20261125_15"
down_revision = "20261119_14"
branch_labels = None
depends_on = None

KINDS = "kind IN ('quiz', 'journey', 'playlist', 'lesson')"
ACTIONS = (
    "action IN ('created', 'published', 'closed', 'archived', 'updated', "
    "'removed', 'cancelled', 'substitute', 'covered')"
)


def upgrade() -> None:
    inspector = sa.inspect(op.get_bind())
    columns = {column["name"] for column in inspector.get_columns("teacher_notices")}
    checks = {check["name"] for check in inspector.get_check_constraints("teacher_notices")}
    with op.batch_alter_table("teacher_notices") as batch:
        for name in ("check_teacher_notice_kind", "check_teacher_notice_action"):
            if name in checks:
                batch.drop_constraint(name, type_="check")
        if "detail" not in columns:
            batch.add_column(sa.Column("detail", sa.String(40)))
        batch.create_check_constraint("check_teacher_notice_kind", KINDS)
        batch.create_check_constraint("check_teacher_notice_action", ACTIONS)


def downgrade() -> None:
    op.execute(
        "DELETE FROM teacher_notices WHERE kind NOT IN ('quiz', 'journey') "
        "OR action NOT IN ('created', 'published', 'closed', 'archived')"
    )
    with op.batch_alter_table("teacher_notices") as batch:
        batch.drop_constraint("check_teacher_notice_kind", type_="check")
        batch.drop_constraint("check_teacher_notice_action", type_="check")
        batch.drop_column("detail")
        batch.create_check_constraint("check_teacher_notice_kind", "kind IN ('quiz', 'journey')")
        batch.create_check_constraint(
            "check_teacher_notice_action",
            "action IN ('created', 'published', 'closed', 'archived')",
        )
