"""In-class activity: the quiz or journey a teacher starts for a live class.

Only adds columns; tolerant of databases where startup already added them.
"""

from alembic import op
import sqlalchemy as sa

revision = "20261119_13"
down_revision = "20261117_12"
branch_labels = None
depends_on = None

COLUMNS = (
    ("activity_kind", sa.String(10)),
    ("activity_id", sa.Integer()),
    ("activity_title", sa.String(300)),
    ("activity_started_at", sa.TIMESTAMP()),
)


def upgrade() -> None:
    existing = {column["name"] for column in sa.inspect(op.get_bind()).get_columns("sessions")}
    with op.batch_alter_table("sessions") as batch:
        for name, kind in COLUMNS:
            if name not in existing:
                batch.add_column(sa.Column(name, kind))


def downgrade() -> None:
    with op.batch_alter_table("sessions") as batch:
        for name, _ in reversed(COLUMNS):
            batch.drop_column(name)
