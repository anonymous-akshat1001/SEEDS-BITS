"""Speech language and speed chosen by the administrator for each account.

Both are optional. The phone applies a value when it changes, so a blind
person never has to find Settings; they can still change it there.
"""

from alembic import op
import sqlalchemy as sa

revision = "20261126_16"
down_revision = "20261125_15"
branch_labels = None
depends_on = None


def upgrade() -> None:
    with op.batch_alter_table("users") as batch:
        batch.add_column(sa.Column("speech_language", sa.String(length=5), nullable=True))
        batch.add_column(sa.Column("speech_rate", sa.Float(), nullable=True))
        batch.create_check_constraint(
            "check_user_speech_language",
            "speech_language IS NULL OR speech_language IN ('en', 'hi', 'kn', 'te', 'bn')",
        )
        batch.create_check_constraint(
            "check_user_speech_rate",
            "speech_rate IS NULL OR (speech_rate >= 0.25 AND speech_rate <= 2.0)",
        )


def downgrade() -> None:
    with op.batch_alter_table("users") as batch:
        batch.drop_constraint("check_user_speech_rate", type_="check")
        batch.drop_constraint("check_user_speech_language", type_="check")
        batch.drop_column("speech_rate")
        batch.drop_column("speech_language")
