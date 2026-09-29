"""Destructively reset the test database and seed SEEDS reference data.

Usage from the repository root:

    python -m backend.reset_db --confirm-reset

The bootstrap administrator is deliberately read from environment variables so
credentials never need to be committed to source control.
"""

import argparse
import asyncio
import os
import sys
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import sessionmaker

sys.path.insert(0, str(Path(__file__).resolve().parent))
import auth  # type: ignore  # noqa: E402
import models  # type: ignore  # noqa: E402
from database import engine  # type: ignore  # noqa: E402


ROOT_ENV = Path(__file__).resolve().parent.parent / ".env"
load_dotenv(ROOT_ENV)

CLASS_NAMES = ["LKG", "UKG", *[f"Class {number}" for number in range(1, 13)]]
SUBJECT_NAMES = ["English", "Maths", "Science"]


def _required_environment() -> tuple[str, str, str]:
    values = (
        os.getenv("BOOTSTRAP_ADMIN_NAME", "").strip(),
        os.getenv("BOOTSTRAP_ADMIN_PHONE", "").strip(),
        os.getenv("BOOTSTRAP_ADMIN_PASSWORD", ""),
    )
    if not all(values):
        raise RuntimeError(
            "BOOTSTRAP_ADMIN_NAME, BOOTSTRAP_ADMIN_PHONE, and "
            "BOOTSTRAP_ADMIN_PASSWORD must all be set before resetting the database."
        )
    if len(values[2]) < 8:
        raise RuntimeError("BOOTSTRAP_ADMIN_PASSWORD must be at least 8 characters.")
    return values


async def reset_and_seed() -> None:
    admin_name, admin_phone, admin_password = _required_environment()

    async with engine.begin() as connection:
        print("Dropping all SEEDS tables...")
        await connection.run_sync(models.Base.metadata.drop_all)
        print("Creating class-aware SEEDS tables...")
        await connection.run_sync(models.Base.metadata.create_all)

    session_factory = sessionmaker(
        bind=engine, class_=AsyncSession, expire_on_commit=False,
    )
    async with session_factory() as session:
        session.add_all(
            [
                models.SchoolClass(name=name, sort_order=index)
                for index, name in enumerate(CLASS_NAMES)
            ]
        )
        session.add_all([models.Subject(name=name) for name in SUBJECT_NAMES])
        session.add(
            models.User(
                name=admin_name,
                phone_number=admin_phone,
                role="admin",
                password_hash=auth.get_password_hash(admin_password),
            )
        )
        await session.commit()

    print(f"Seeded {len(CLASS_NAMES)} classes and {len(SUBJECT_NAMES)} subjects.")
    print(f"Bootstrap administrator created for phone {admin_phone}.")
    print("Database reset complete.")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--confirm-reset",
        action="store_true",
        help="Required acknowledgement that all existing database data will be deleted.",
    )
    arguments = parser.parse_args()
    if not arguments.confirm_reset:
        parser.error("Refusing destructive reset without --confirm-reset")
    asyncio.run(reset_and_seed())


if __name__ == "__main__":
    main()
