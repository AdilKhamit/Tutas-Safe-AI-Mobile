"""
Dependency Injection for FastAPI
"""
from typing import AsyncGenerator
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import SessionLocal


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """
    Dependency for getting database session.
    Yields async session and closes it after request.
    """
    async with SessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()
