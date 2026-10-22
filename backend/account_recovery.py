"""School-admin-assisted reset; no SMS, identity inference, or plaintext storage."""

import secrets
from datetime import datetime, timedelta
from typing import Literal

from fastapi import APIRouter, Depends, HTTPException, Response
from pydantic import BaseModel, Field
from sqlalchemy import delete, select, update
from sqlalchemy.ext.asyncio import AsyncSession

import auth
import models
from database import get_db
from ws_manager import ws_mgr

router = APIRouter(tags=["Account recovery"])


class ResetRequest(BaseModel):
    identity_verified: Literal[True]
    expected_auth_version: int = Field(ge=0, strict=True)


class PasswordChange(BaseModel):
    current_password: str = Field(min_length=1)
    new_password: str = Field(min_length=6)


@router.post("/admin/users/{account_id}/reset-password")
async def reset_password(
    account_id: int, payload: ResetRequest, response: Response,
    admin: models.User = Depends(auth.require_admin),
    db: AsyncSession = Depends(get_db),
):
    user_id = account_id
    result = await db.execute(select(models.User).where(
        models.User.user_id == user_id,
    ).with_for_update().execution_options(populate_existing=True))
    user = result.scalar_one_or_none()
    if user is None:
        raise HTTPException(status_code=404, detail="Account not found")
    if user.role not in {"teacher", "student"}:
        raise HTTPException(status_code=403, detail="Only teacher and student accounts can be reset here")
    if user.auth_version != payload.expected_auth_version:
        raise HTTPException(status_code=409, detail="Account changed. Refresh before considering another reset.")
    credential = "".join(secrets.choice("0123456789") for _ in range(12))
    now = datetime.utcnow()
    user.password_hash = auth.get_password_hash(credential)
    user.auth_version += 1
    user.must_change_password = True
    user.temporary_password_expires_at = now + timedelta(hours=24)
    user.temporary_password_failures = 0
    user.temporary_password_locked_until = None
    user.password_reset_at = now
    user.password_reset_by = admin.user_id
    await db.execute(delete(models.FCMToken).where(models.FCMToken.user_id == user_id))
    await db.execute(update(models.Participant).where(
        models.Participant.user_id == user_id,
    ).values(
        is_muted=True, hand_raised=False, hand_queue_order=None,
        hand_revision=models.Participant.hand_revision + 1,
    ))
    await db.commit()
    await ws_mgr.revoke_user(user_id)
    response.headers["Cache-Control"] = "no-store"
    return {
        "ok": True, "temporary_credential": credential,
        "expires_at": user.temporary_password_expires_at.isoformat() + "Z",
        "auth_version": user.auth_version,
    }


@router.post("/auth/change-password")
async def change_password(
    payload: PasswordChange, response: Response,
    current_user: models.User = Depends(auth.get_password_change_user),
    db: AsyncSession = Depends(get_db),
):
    expected_version = current_user.auth_version
    result = await db.execute(select(models.User).where(
        models.User.user_id == current_user.user_id,
    ).with_for_update().execution_options(populate_existing=True))
    user = result.scalar_one()
    auth._check_session(user, expected_version, allow_password_change=True)
    if not user.must_change_password:
        raise HTTPException(status_code=409, detail="Password change is no longer required. Sign in again.")
    await auth.verify_temporary_password(user, payload.current_password, db)
    if auth.verify_password(payload.new_password, user.password_hash):
        raise HTTPException(status_code=400, detail="Choose a password different from the temporary credential.")
    user.password_hash = auth.get_password_hash(payload.new_password)
    user.must_change_password = False
    user.auth_version += 1
    user.temporary_password_expires_at = None
    user.temporary_password_failures = 0
    user.temporary_password_locked_until = None
    await db.commit()
    await ws_mgr.revoke_user(user.user_id)
    response.headers["Cache-Control"] = "no-store"
    return {"ok": True, **auth.session_payload(user)}
