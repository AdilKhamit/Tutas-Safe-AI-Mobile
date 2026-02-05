"""
Pytest configuration and fixtures for backend tests
"""
import pytest
import asyncio
import uuid
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from sqlalchemy.pool import StaticPool
from sqlalchemy import String, event, TypeDecorator
from sqlalchemy.engine import Engine
from sqlalchemy.dialects.postgresql import UUID as PostgresUUID
from sqlalchemy.dialects.sqlite import BLOB
from sqlalchemy.orm import Mapped, mapped_column
from app.main import app
from app.api.deps import get_db
from app.models.base import Base
from app.models.pipes import Pipe


# Test database URL (in-memory SQLite for testing)
TEST_DATABASE_URL = "sqlite+aiosqlite:///:memory:"


# Override UUID type for SQLite
class GUID(TypeDecorator):
    """Platform-independent GUID type for SQLite"""
    impl = String(36)
    cache_ok = True
    
    def load_dialect_impl(self, dialect):
        if dialect.name == 'postgresql':
            return dialect.type_descriptor(PostgresUUID(as_uuid=True))
        else:
            return dialect.type_descriptor(String(36))
    
    def process_bind_param(self, value, dialect):
        if value is None:
            return value
        # Always convert UUID to string for binding
        if isinstance(value, uuid.UUID):
            return str(value)
        return value
    
    def process_result_value(self, value, dialect):
        if value is None:
            return value
        # Convert string back to UUID for Python
        if isinstance(value, str):
            return uuid.UUID(value)
        return value


@pytest.fixture(scope="session")
def event_loop():
    """Create an instance of the default event loop for the test session."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="function")
async def test_db():
    """Create a test database session with UUID converted to String for SQLite"""
    from sqlalchemy.dialects.postgresql import UUID as PostgresUUID
    from sqlalchemy import String
    
    engine = create_async_engine(
        TEST_DATABASE_URL,
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
        echo=False,
    )
    
    # Enable foreign keys for SQLite using event listener
    @event.listens_for(engine.sync_engine, "connect")
    def set_sqlite_pragma(dbapi_conn, connection_record):
        """Enable foreign keys for SQLite"""
        cursor = dbapi_conn.cursor()
        cursor.execute("PRAGMA foreign_keys=ON")
        cursor.close()
    
    # Replace PostgreSQL-specific types (UUID, Geography, JSONB) with SQLite-compatible types
    # Store original types for restoration
    type_replacements = []
    for table in Base.metadata.tables.values():
        for column in table.columns:
            # Replace UUID with GUID TypeDecorator for SQLite (handles UUID conversion)
            if isinstance(column.type, PostgresUUID):
                type_replacements.append((table.name, column.name, column.type))
                column.type = GUID()
            # Replace Geography (PostGIS) with TEXT for SQLite
            elif hasattr(column.type, '__class__') and 'Geography' in str(type(column.type)):
                try:
                    from geoalchemy2 import Geography
                    if isinstance(column.type, Geography):
                        type_replacements.append((table.name, column.name, column.type))
                        column.type = String()  # Use TEXT for SQLite
                except (ImportError, AttributeError):
                    pass
            # Replace JSONB with TEXT for SQLite
            elif hasattr(column.type, '__class__') and 'JSONB' in str(type(column.type)):
                try:
                    from sqlalchemy.dialects.postgresql import JSONB
                    if isinstance(column.type, JSONB):
                        type_replacements.append((table.name, column.name, column.type))
                        column.type = String()  # Use TEXT for SQLite
                except (ImportError, AttributeError):
                    pass
    
    try:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        
        async_session = async_sessionmaker(
            engine, class_=AsyncSession, expire_on_commit=False
        )
        
        async with async_session() as session:
            yield session
        
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.drop_all)
    finally:
        # Restore original types
        for table_name, col_name, original_type in type_replacements:
            table = Base.metadata.tables.get(table_name)
            if table is not None:
                col = table.columns.get(col_name)
                if col is not None:
                    col.type = original_type
    
    await engine.dispose()


@pytest.fixture(scope="function")
async def client(test_db):
    """Create a test client"""
    async def override_get_db():
        yield test_db
    
    app.dependency_overrides[get_db] = override_get_db
    
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac
    
    app.dependency_overrides.clear()
