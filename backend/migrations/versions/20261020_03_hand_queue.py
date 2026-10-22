"""Persist classroom hand order without inventing ages for existing hands."""

from alembic import op
import sqlalchemy as sa


revision = "20261020_03"
down_revision = "20261013_02"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("sessions", sa.Column("hand_queue_sequence", sa.Integer(), nullable=False, server_default=sa.text("0")))
    op.add_column("participants", sa.Column("hand_queue_order", sa.Integer(), nullable=True))
    op.add_column("participants", sa.Column("hand_revision", sa.Integer(), nullable=False, server_default=sa.text("0")))


def downgrade() -> None:
    op.drop_column("participants", "hand_revision")
    op.drop_column("participants", "hand_queue_order")
    op.drop_column("sessions", "hand_queue_sequence")
