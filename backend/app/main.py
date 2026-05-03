from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.db.models import Base
from app.db.seed import seed_data
from app.db.session import AsyncSessionLocal, engine
from app.routers import auth, chat, games, meetups, participation, profile


@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with AsyncSessionLocal() as db:
        await seed_data(db)

    print("✅ TFP backend started. Database is ready.")
    yield


app = FastAPI(
    title="TFP — Поиск игроков в настольные игры",
    version="1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def healthcheck():
    return {"status": "ok"}


app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(games.router, prefix="/games", tags=["games"])
app.include_router(meetups.router, prefix="/meetups", tags=["meetups"])
app.include_router(participation.router, prefix="/participation", tags=["participation"])
app.include_router(chat.router, prefix="/chat", tags=["chat"])
app.include_router(profile.router, prefix="/profile", tags=["profile"])

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
