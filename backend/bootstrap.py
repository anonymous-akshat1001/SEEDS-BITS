"""Secure, idempotent creation of the configured bootstrap administrator."""

import os

from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

import auth
import models


def required_admin_environment() -> tuple[str, str, str]:
    name = os.getenv("BOOTSTRAP_ADMIN_NAME", "").strip()
    phone = os.getenv("BOOTSTRAP_ADMIN_PHONE", "").strip()
    password = os.getenv("BOOTSTRAP_ADMIN_PASSWORD", "")
    if not name or not phone or not password:
        raise RuntimeError(
            "BOOTSTRAP_ADMIN_NAME, BOOTSTRAP_ADMIN_PHONE, and "
            "BOOTSTRAP_ADMIN_PASSWORD must all be configured."
        )
    if len(password) < 8:
        raise RuntimeError("BOOTSTRAP_ADMIN_PASSWORD must be at least 8 characters.")
    return name, phone, password


async def ensure_bootstrap_admin(db: AsyncSession) -> models.User:
    name, phone, password = required_admin_environment()
    result = await db.execute(
        select(models.User).filter(models.User.phone_number == phone)
    )
    existing = result.scalar_one_or_none()
    if existing is not None:
        if existing.role != "admin":
            raise RuntimeError(
                "BOOTSTRAP_ADMIN_PHONE belongs to a non-administrator account."
            )
        return existing

    admin = models.User(
        name=name,
        phone_number=phone,
        role="admin",
        password_hash=auth.get_password_hash(password),
    )
    db.add(admin)
    try:
        await db.commit()
        await db.refresh(admin)
        return admin
    except IntegrityError:
        await db.rollback()
        result = await db.execute(
            select(models.User).filter(models.User.phone_number == phone)
        )
        concurrent = result.scalar_one_or_none()
        if concurrent is None or concurrent.role != "admin":
            raise RuntimeError(
                "Bootstrap administrator creation conflicted with another account."
            )
        return concurrent
