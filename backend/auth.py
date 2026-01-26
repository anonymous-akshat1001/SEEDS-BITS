# auth_utils.py
from datetime import datetime, timedelta
from jose import jwt, JWTError
from passlib.context import CryptContext
from fastapi import HTTPException, status
from . import schemas, models
import os
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from .database import get_db

SECRET_KEY = os.getenv("JWT_SECRET")    # Acts as a seal which is verified each time a token is accessed
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24  # 1 day

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Type of authentication used by FASTAPI endpoints
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

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
async def get_current_user(token: str = Depends(oauth2_scheme), db: AsyncSession = Depends(get_db)) -> models.User:
    try:
        payload = decode_access_token(token)    # Calls the above function to decode the payload(token)
        user_id = payload.get("user_id")
    except:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    # Queries DB to check if the user with that user_id exists.
    q = await db.execute(
        select(models.User).filter(models.User.user_id == user_id)  # Acts like a SELECT + WHERE SQL query
    )
    # Extract a single row from the query
    user = q.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return user

# Get current user from JWT token (for WebSocket authentication)
async def get_current_user_from_token(token: str, db: AsyncSession) -> models.User:
    try:
        payload = decode_access_token(token)
        user_id = payload.get("user_id")
    except:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    q = await db.execute(
        select(models.User).filter(models.User.user_id == user_id)
    )
    user = q.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return user

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
