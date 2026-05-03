from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Meetup, Participation, User
from app.db.session import get_db
from app.routers.dependencies import get_current_user
from app.routers.meetups import _serialize_meetup
from app.schemas.meetup import MeetupOut
from app.schemas.user import UserOut

router = APIRouter()


@router.get("/me", response_model=UserOut)
async def get_profile(current_user: User = Depends(get_current_user)):
    return current_user


@router.get("/my-meetups", response_model=list[MeetupOut])
async def get_my_meetups(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    hosted = (
        await db.execute(select(Meetup).where(Meetup.host_id == current_user.id))
    ).scalars().all()
    joined_ids = (
        await db.execute(
            select(Participation.meetup_id).where(Participation.user_id == current_user.id)
        )
    ).scalars().all()
    joined = []
    if joined_ids:
        joined = (
            await db.execute(select(Meetup).where(Meetup.id.in_(joined_ids)))
        ).scalars().all()

    by_id = {meetup.id: meetup for meetup in [*hosted, *joined]}
    items = sorted(by_id.values(), key=lambda m: m.date_time)
    return [await _serialize_meetup(db, meetup, current_user.id) for meetup in items]
