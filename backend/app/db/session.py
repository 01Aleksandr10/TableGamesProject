from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.core.config import settings


def _normalize_database_url(raw_url: str) -> str:
    if raw_url.startswith("postgresql://"):
        return raw_url.replace("postgresql://", "postgresql+asyncpg://", 1)
    if raw_url.startswith("sqlite://") and "+aiosqlite" not in raw_url:
        return raw_url.replace("sqlite://", "sqlite+aiosqlite://", 1)
    return raw_url


DATABASE_URL = _normalize_database_url(settings.DATABASE_URL)
engine_kwargs = {"echo": False, "future": True}
if DATABASE_URL.startswith("sqlite+aiosqlite://"):
    engine_kwargs["connect_args"] = {"check_same_thread": False}

engine = create_async_engine(DATABASE_URL, **engine_kwargs)
AsyncSessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)


async def get_db():
    async with AsyncSessionLocal() as session:
        yield session
