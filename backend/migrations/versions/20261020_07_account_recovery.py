"""Versioned sessions and administrator-assisted account recovery."""

from alembic import op
import sqlalchemy as sa

revision = "20261020_07"
down_revision = "20261020_06"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column("users", sa.Column("auth_version", sa.Integer(), nullable=False, server_default=sa.text("0")))
    op.add_column("users", sa.Column("must_change_password", sa.Boolean(), nullable=False, server_default=sa.false()))
    op.add_column("users", sa.Column("temporary_password_expires_at", sa.TIMESTAMP()))
    op.add_column("users", sa.Column("temporary_password_failures", sa.Integer(), nullable=False, server_default=sa.text("0")))
    op.add_column("users", sa.Column("temporary_password_locked_until", sa.TIMESTAMP()))
    op.add_column("users", sa.Column("password_reset_at", sa.TIMESTAMP()))
    op.add_column("users", sa.Column("password_reset_by", sa.Integer()))


def downgrade():
    for name in (
        "password_reset_by", "password_reset_at", "temporary_password_locked_until",
        "temporary_password_failures", "temporary_password_expires_at",
        "must_change_password", "auth_version",
    ):
        op.drop_column("users", name)
