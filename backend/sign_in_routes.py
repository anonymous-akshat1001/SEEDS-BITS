"""Sign-in (S01/S02/S43).

Students and teachers enter only their registered phone number. This is a
deliberately unverified identity model chosen for the testing deployment:
anyone who knows a registered number (and, for shared phones, the short
profile code) can use that account. Administrators always use a password and
can never be signed in through the number-only path.
"""

from __future__ import annotations

import re
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Response, status
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

import auth
import models
from activity_events import record_event
from database import get_db

router = APIRouter(tags=["Sign in"])

_SEPARATORS = re.compile(r"[\s\-().]")


def normalize_phone(value: str) -> str:
    """Remove spacing and punctuation; keep digits and a leading plus."""
    cleaned = _SEPARATORS.sub("", value or "")
    if cleaned.startswith("+"):
        return "+" + re.sub(r"\D", "", cleaned[1:])
    return re.sub(r"\D", "", cleaned)


class PhoneSignIn(BaseModel):
    phone_number: str = Field(min_length=1, max_length=32)
    profile_code: Optional[str] = Field(default=None, max_length=8)


NOT_REGISTERED = "This phone number is not registered. Ask your school administrator to add you."


@router.post("/auth/phone-login")
async def phone_login(
    payload: PhoneSignIn,
    response: Response,
    db: AsyncSession = Depends(get_db),
):
    phone = normalize_phone(payload.phone_number)
    if not phone:
        raise HTTPException(status_code=422, detail="Enter your phone number.")
    group = (await db.execute(
        select(models.DeviceGroup).options(
            selectinload(models.DeviceGroup.members).selectinload(models.DeviceGroupMember.user),
        ).where(
            models.DeviceGroup.entry_phone_number == phone,
            models.DeviceGroup.is_active.is_(True),
        )
    )).scalar_one_or_none()
    if group is not None:
        code = (payload.profile_code or "").strip()
        if not code:
            lengths = [len(member.profile_code) for member in group.members] or [2]
            return {
                "profile_required": True,
                "code_length": max(lengths),
            }
        member = next((member for member in group.members if member.profile_code == code), None)
        if member is None or member.user is None:
            raise HTTPException(status_code=401, detail="That profile number is not recognised on this phone.")
        user = member.user
    else:
        user = (await db.execute(
            select(models.User).where(models.User.phone_number == phone)
        )).scalar_one_or_none()
        if user is None:
            raise HTTPException(status_code=401, detail=NOT_REGISTERED)
    if user.role == "admin":
        raise HTTPException(status_code=403, detail="Administrators sign in with a password.")
    if user.role not in {"teacher", "student"} or not user.is_active:
        raise HTTPException(status_code=401, detail=NOT_REGISTERED)
    record_event(db, "login_succeeded", actor_id=user.user_id, resource_type="user", resource_id=user.user_id)
    await db.commit()
    response.headers["Cache-Control"] = "no-store"
    return {"profile_required": False, **auth.session_payload(user)}


@router.post("/auth/login")
async def admin_login(
    response: Response,
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: AsyncSession = Depends(get_db),
):
    """Administrator password sign-in only."""
    phone = normalize_phone(form_data.username)
    user = (await db.execute(
        select(models.User).where(models.User.phone_number == phone)
        .with_for_update().execution_options(populate_existing=True)
    )).scalar_one_or_none()
    if user is None or user.role != "admin" or not user.is_active:
        import logging
        logging.getLogger("seeds").warning("login_denied", extra={"event_code": "login_denied"})
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    if user.must_change_password:
        await auth.verify_temporary_password(user, form_data.password, db)
    elif not auth.verify_password(form_data.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    record_event(db, "login_succeeded", actor_id=user.user_id, resource_type="user", resource_id=user.user_id)
    await db.commit()
    response.headers["Cache-Control"] = "no-store"
    return auth.session_payload(user)
