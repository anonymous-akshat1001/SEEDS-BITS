# We use async because:
# Database queries and file I/O are slow compared to CPU instructions.
# Async frees the server to handle other users while waiting.
# It scales better under high load (hundreds/thousands of concurrent users).

import os
from dotenv import load_dotenv
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from collections.abc import AsyncGenerator
from pathlib import Path

# Load .env from project root
env_path = Path(__file__).resolve().parent.parent / ".env"
load_dotenv(dotenv_path=env_path)

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise ValueError("DATABASE_URL is not set in environment variables")

# Async engine
engine = create_async_engine(
    DATABASE_URL, echo=False, hide_parameters=True, future=True,
    connect_args={"server_settings": {"timezone": "UTC"}}
    if DATABASE_URL.startswith("postgresql+asyncpg:") else {},
)

# Base model - parent class of all ORM Models
Base = declarative_base()

# Async session factory
AsyncSessionLocal = sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False
)

# FASTAPI dependency for the endpoints - to provide database 
async def get_db() -> AsyncGenerator[AsyncSession, None]:
    from activity_events import install_orm_audit
    install_orm_audit()
    async with AsyncSessionLocal() as session:
        yield session


analytics_url = os.getenv("ANALYTICS_DATABASE_URL")
analytics_engine = (
    create_async_engine(
        analytics_url, echo=False, hide_parameters=True, future=True,
        connect_args={"server_settings": {"timezone": "UTC"}}
        if analytics_url.startswith("postgresql+asyncpg:") else {},
    )
    if analytics_url else engine
)
AnalyticsSessionLocal = sessionmaker(
    bind=analytics_engine, class_=AsyncSession, expire_on_commit=False,
)


async def get_analytics_db() -> AsyncGenerator[AsyncSession, None]:
    async with AnalyticsSessionLocal() as session:
        if session.bind.dialect.name == "postgresql":
            from sqlalchemy import text
            await session.execute(text("SET TRANSACTION READ ONLY"))
            await session.execute(text("SET LOCAL statement_timeout = '5000ms'"))
        yield session
