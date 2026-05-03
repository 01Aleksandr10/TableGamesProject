from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Game, Meetup, MeetupStatus, Participation, User
from app.db.session import get_db
from app.routers.dependencies import get_current_user
from app.schemas.meetup import MeetupCreate, MeetupOut

router = APIRouter()


async def _serialize_meetup(
    db: AsyncSession,
    meetup: Meetup,
    current_user_id: int | None = None,
) -> MeetupOut:
    count = await db.scalar(
        select(func.count(Participation.id)).where(Participation.meetup_id == meetup.id)
    )
    game = await db.get(Game, meetup.game_id)
    host = await db.get(User, meetup.host_id)
    joined = False
    if current_user_id is not None:
        joined = (
            await db.scalar(
                select(func.count(Participation.id)).where(
                    Participation.meetup_id == meetup.id,
                    Participation.user_id == current_user_id,
                )
            )
        ) > 0

    payload = {
        "id": meetup.id,
        "host_id": meetup.host_id,
        "game_id": meetup.game_id,
        "date_time": meetup.date_time,
        "location": meetup.location,
        "status": meetup.status,
        "max_participants": meetup.max_participants,
        "current_participants": count or 0,
        "description": meetup.description,
        "joined": joined,
        "game": game,
        "host": host,
    }
    return MeetupOut.model_validate(payload)


async def _refresh_meetup_status(db: AsyncSession, meetup: Meetup) -> None:
    count = await db.scalar(
        select(func.count(Participation.id)).where(Participation.meetup_id == meetup.id)
    )
    meetup.status = (
        MeetupStatus.FULL.value
        if (count or 0) >= meetup.max_participants
        else MeetupStatus.OPEN.value
    )
    db.add(meetup)
    await db.commit()
    await db.refresh(meetup)


@router.post("", response_model=MeetupOut)
@router.post("/", response_model=MeetupOut, include_in_schema=False)
async def create_meetup(
    meetup_in: MeetupCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    game = await db.get(Game, meetup_in.game_id)
    if not game:
        raise HTTPException(status_code=404, detail="Game not found")

    meetup = Meetup(**meetup_in.model_dump(), host_id=current_user.id, status=MeetupStatus.OPEN.value)
    db.add(meetup)
    await db.commit()
    await db.refresh(meetup)
    return await _serialize_meetup(db, meetup, current_user.id)


@router.get("", response_model=list[MeetupOut])
@router.get("/", response_model=list[MeetupOut], include_in_schema=False)
async def get_meetups(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Meetup).order_by(Meetup.date_time))
    meetups = result.scalars().all()
    return [await _serialize_meetup(db, meetup) for meetup in meetups]


@router.get("/{meetup_id}", response_model=MeetupOut)
async def get_meetup(meetup_id: int, db: AsyncSession = Depends(get_db)):
    meetup = await db.get(Meetup, meetup_id)
    if not meetup:
        raise HTTPException(status_code=404, detail="Meetup not found")
    return await _serialize_meetup(db, meetup)
