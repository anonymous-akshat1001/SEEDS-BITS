# auth_utils.py
from datetime import datetime, timedelta
from jose import jwt, JWTError
from passlib.context import CryptContext
from fastapi import HTTPException, status, Query
import schemas, models
import os
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from database import get_db

SECRET_KEY = os.getenv("JWT_SECRET")    # Acts as a seal which is verified each time a token is accessed
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24  # 1 day

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Type of authentication used by FASTAPI endpoints
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login", auto_error=False)
ALLOW_DEV_USER_IMPERSONATION = os.getenv(
    "ALLOW_DEV_USER_IMPERSONATION", "false"
).strip().lower() in {"1", "true", "yes"}

# Compares plain text password with the hashed password stored in the database
def verify_password(plain, hashed):
    return pwd_context.verify(plain, hashed)

# Get the hashed password
def get_password_hash(password):
    return pwd_context.hash(password)

# Input the data of claims(user, id , etc) in the form of a dictionary
def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()

    # Add on an expiration field to the token ( 1 Day in our case )
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    
    if not SECRET_KEY:
        raise ValueError("JWT_SECRET not found in environment variables")
    
    token = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

    # Output : a JWT string (3 parts: header, payload, signature)
    return token

def decode_access_token(token: str):
    try:
        if not SECRET_KEY:
            raise ValueError("JWT_SECRET not found in environment variables")
        # jwt.decode matches the signature with the SECRET_KEY we have set
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        # Output is the same as the input to the last function used to encode
        return payload
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")


# Get current user from JWT token
async def get_current_user(
    token: Optional[str] = Depends(oauth2_scheme),
    user_id: Optional[int] = Query(None),
    db: AsyncSession = Depends(get_db),
) -> models.User:
    if user_id is not None and ALLOW_DEV_USER_IMPERSONATION:
        q = await db.execute(select(models.User).filter(models.User.user_id == user_id))
        user = q.scalar_one_or_none()
        if not user:
            raise HTTPException(status_code=401, detail="Development user not found")
        _check_session(user, user.auth_version)
        return user
    if not token:
        raise HTTPException(status_code=401, detail="Authentication required")
    return await get_current_user_from_token(token, db)

# Get current user from JWT token (for WebSocket authentication)
async def get_current_user_from_token(
    token: str, db: AsyncSession, *, allow_password_change: bool = False,
) -> models.User:
    payload = decode_access_token(token)
    user_id = payload.get("user_id")
    version = payload.get("auth_version", 0)
    if type(user_id) is not int or type(version) is not int or version < 0:
        raise HTTPException(status_code=401, detail="Invalid token")
    q = await db.execute(
        select(models.User).filter(models.User.user_id == user_id)
        .execution_options(populate_existing=True)
    )
    user = q.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    _check_session(user, version, allow_password_change=allow_password_change)
    return user


def _check_session(user, version, *, allow_password_change=False):
    if user.auth_version != version:
        raise HTTPException(status_code=401, detail="Session expired. Sign in again.")
    if user.must_change_password and not allow_password_change:
        raise HTTPException(status_code=403, detail="Password change required")


async def get_password_change_user(
    token: Optional[str] = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
) -> models.User:
    if not token:
        raise HTTPException(status_code=401, detail="Authentication required")
    return await get_current_user_from_token(token, db, allow_password_change=True)


async def session_is_current(db: AsyncSession, user_id: int, version: int) -> bool:
    result = await db.execute(select(
        models.User.auth_version, models.User.must_change_password,
    ).where(models.User.user_id == user_id))
    row = result.one_or_none()
    return row is not None and row.auth_version == version and not row.must_change_password


def session_payload(user: models.User) -> dict:
    duration = timedelta(days=7)
    if user.must_change_password:
        duration = min(duration, user.temporary_password_expires_at - datetime.utcnow())
        if duration.total_seconds() <= 0:
            raise HTTPException(status_code=401, detail="Temporary credential expired. Contact your school administrator.")
    return {
        "access_token": create_access_token(
            {"user_id": user.user_id, "role": user.role, "auth_version": user.auth_version},
            expires_delta=duration,
        ),
        "token_type": "bearer",
        "user_id": user.user_id,
        "role": user.role,
        "name": user.name,
        "must_change_password": bool(user.must_change_password),
    }


async def verify_temporary_password(user: models.User, password: str, db: AsyncSession):
    now = datetime.utcnow()
    if user.temporary_password_expires_at is None or now >= user.temporary_password_expires_at:
        raise HTTPException(status_code=401, detail="Temporary credential expired. Contact your school administrator.")
    if user.temporary_password_locked_until:
        if now < user.temporary_password_locked_until:
            raise HTTPException(status_code=429, detail="Temporary-credential sign-in paused for 15 minutes. Try later or contact your school administrator.")
        user.temporary_password_locked_until = None
        user.temporary_password_failures = 0
    if not verify_password(password, user.password_hash):
        user.temporary_password_failures += 1
        if user.temporary_password_failures >= 10:
            user.temporary_password_locked_until = now + timedelta(minutes=15)
        await db.commit()
        if user.temporary_password_locked_until:
            raise HTTPException(status_code=429, detail="Temporary-credential sign-in paused for 15 minutes. Try later or contact your school administrator.")
        raise HTTPException(status_code=401, detail="Invalid credentials")
    user.temporary_password_failures = 0
    user.temporary_password_locked_until = None


async def get_media_user(
    access_token: Optional[str] = Query(None),
    user_id: Optional[int] = Query(None),
    db: AsyncSession = Depends(get_db),
) -> models.User:
    """Authenticate media clients that cannot attach an Authorization header."""
    if access_token:
        return await get_current_user_from_token(access_token, db)
    if user_id is not None and ALLOW_DEV_USER_IMPERSONATION:
        result = await db.execute(select(models.User).filter(models.User.user_id == user_id))
        user = result.scalar_one_or_none()
        if user:
            _check_session(user, user.auth_version)
            return user
    raise HTTPException(status_code=401, detail="Authentication required")

# Only allow teachers
async def require_teacher(current_user: models.User = Depends(get_current_user)) -> models.User:
    if current_user.role != "teacher":
        raise HTTPException(status_code=403, detail="Teacher role required")
    return current_user

# Only allow students
async def require_student(current_user: models.User = Depends(get_current_user)) -> models.User:
    if current_user.role != "student":
        raise HTTPException(status_code=403, detail="Student role required")
    return current_user


async def require_admin(current_user: models.User = Depends(get_current_user)) -> models.User:
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Administrator role required")
    return current_user
