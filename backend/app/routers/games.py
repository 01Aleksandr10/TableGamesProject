from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Game
from app.db.session import get_db
from app.schemas.game import GameOut

router = APIRouter()


@router.get("", response_model=list[GameOut])
@router.get("/", response_model=list[GameOut], include_in_schema=False)
async def get_all_games(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Game).order_by(Game.title))
    return result.scalars().all()
