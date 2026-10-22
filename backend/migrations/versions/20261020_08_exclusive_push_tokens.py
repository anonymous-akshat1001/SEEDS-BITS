"""Give each push token one owner; revoke ambiguous legacy associations."""

from alembic import op
import sqlalchemy as sa

revision = "20261020_08"
down_revision = "20261020_07"
branch_labels = None
depends_on = None


def upgrade():
    bind = op.get_bind()
    if "fcm_tokens" not in sa.inspect(bind).get_table_names():
        op.create_table(
            "fcm_tokens",
            sa.Column("token_id", sa.Integer(), primary_key=True),
            sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False),
            sa.Column("token", sa.Text(), nullable=False),
            sa.Column("device_type", sa.String(20)),
            sa.Column("created_at", sa.TIMESTAMP(), server_default=sa.func.now()),
            sa.Column("last_used", sa.TIMESTAMP(), server_default=sa.func.now()),
        )
    bind.execute(sa.text(
        "DELETE FROM fcm_tokens WHERE token IN "
        "(SELECT token FROM fcm_tokens GROUP BY token HAVING COUNT(*) > 1)"
    ))
    with op.batch_alter_table("fcm_tokens") as batch:
        batch.create_unique_constraint("uq_fcm_token", ["token"])


def downgrade():
    with op.batch_alter_table("fcm_tokens") as batch:
        batch.drop_constraint("uq_fcm_token", type_="unique")
    # Revoked ambiguous links cannot safely be reconstructed.
