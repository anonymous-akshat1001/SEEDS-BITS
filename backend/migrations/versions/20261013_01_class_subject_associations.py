"""Add explicit class-subject associations and backfill legacy workspaces.

Revision ID: 20261013_01
Revises:
Create Date: 2026-10-13
"""

from typing import Optional

from alembic import op
import sqlalchemy as sa


revision = "20261013_01"
down_revision: Optional[str] = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("classes", sa.Column("archived_at", sa.TIMESTAMP(), nullable=True))
    op.create_table(
        "class_subject_associations",
        sa.Column("association_id", sa.Integer(), primary_key=True),
        sa.Column(
            "class_id",
            sa.Integer(),
            sa.ForeignKey("classes.class_id", ondelete="RESTRICT"),
            nullable=False,
        ),
        sa.Column(
            "subject_id",
            sa.Integer(),
            sa.ForeignKey("subjects.subject_id", ondelete="RESTRICT"),
            nullable=False,
        ),
        sa.Column(
            "is_active",
            sa.Boolean(),
            nullable=False,
            server_default=sa.text("true"),
        ),
        sa.Column(
            "associated_at",
            sa.TIMESTAMP(),
            nullable=False,
            server_default=sa.func.now(),
        ),
        sa.Column("archived_at", sa.TIMESTAMP(), nullable=True),
        sa.Column(
            "associated_by",
            sa.Integer(),
            sa.ForeignKey("users.user_id", ondelete="SET NULL"),
            nullable=True,
        ),
        sa.UniqueConstraint("class_id", "subject_id", name="uq_class_subject"),
    )
    op.create_index(
        "ix_class_subject_associations_association_id",
        "class_subject_associations",
        ["association_id"],
    )

    connection = op.get_bind()
    pairs = sa.union(
        sa.select(
            sa.column("class_id", sa.Integer),
            sa.column("subject_id", sa.Integer),
        ).select_from(sa.table("sessions")),
        sa.select(
            sa.column("class_id", sa.Integer),
            sa.column("subject_id", sa.Integer),
        ).select_from(sa.table("audio_files")),
        sa.select(
            sa.column("class_id", sa.Integer),
            sa.column("subject_id", sa.Integer),
        ).select_from(sa.table("teacher_class_subject_assignments")),
    ).alias("legacy_pairs")
    classes = sa.table("classes", sa.column("class_id", sa.Integer))
    subjects = sa.table("subjects", sa.column("subject_id", sa.Integer))
    valid_pairs = (
        sa.select(pairs.c.class_id, pairs.c.subject_id)
        .join(classes, classes.c.class_id == pairs.c.class_id)
        .join(subjects, subjects.c.subject_id == pairs.c.subject_id)
        .distinct()
    )
    association = sa.table(
        "class_subject_associations",
        sa.column("class_id", sa.Integer),
        sa.column("subject_id", sa.Integer),
    )
    connection.execute(
        association.insert().from_select(
            ["class_id", "subject_id"],
            valid_pairs,
        )
    )

    invalid_count = connection.scalar(
        sa.select(sa.func.count()).select_from(
            sa.select(pairs.c.class_id, pairs.c.subject_id)
            .outerjoin(classes, classes.c.class_id == pairs.c.class_id)
            .outerjoin(subjects, subjects.c.subject_id == pairs.c.subject_id)
            .where(
                (classes.c.class_id.is_(None))
                | (subjects.c.subject_id.is_(None))
            )
            .subquery()
        )
    )
    if invalid_count:
        raise RuntimeError(
            f"Migration found {invalid_count} legacy class-subject pairs with "
            "missing class or subject rows. Repair those references and rerun."
        )

    with op.batch_alter_table("teacher_class_subject_assignments") as batch:
        batch.create_foreign_key(
            "fk_teacher_assignment_class_subject",
            "class_subject_associations",
            ["class_id", "subject_id"],
            ["class_id", "subject_id"],
            ondelete="RESTRICT",
        )
    with op.batch_alter_table("sessions") as batch:
        batch.create_foreign_key(
            "fk_session_class_subject",
            "class_subject_associations",
            ["class_id", "subject_id"],
            ["class_id", "subject_id"],
            ondelete="RESTRICT",
        )
    with op.batch_alter_table("audio_files") as batch:
        batch.create_foreign_key(
            "fk_audio_class_subject",
            "class_subject_associations",
            ["class_id", "subject_id"],
            ["class_id", "subject_id"],
            ondelete="RESTRICT",
        )


def downgrade() -> None:
    with op.batch_alter_table("audio_files") as batch:
        batch.drop_constraint("fk_audio_class_subject", type_="foreignkey")
    with op.batch_alter_table("sessions") as batch:
        batch.drop_constraint("fk_session_class_subject", type_="foreignkey")
    with op.batch_alter_table("teacher_class_subject_assignments") as batch:
        batch.drop_constraint(
            "fk_teacher_assignment_class_subject",
            type_="foreignkey",
        )
    op.drop_index(
        "ix_class_subject_associations_association_id",
        table_name="class_subject_associations",
    )
    op.drop_table("class_subject_associations")
    op.drop_column("classes", "archived_at")
