from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Meetup, MeetupStatus, Participation, User
from app.db.session import get_db
from app.routers.dependencies import get_current_user
from app.schemas.participation import ParticipationOut

router = APIRouter()


async def _update_meetup_status(db: AsyncSession, meetup: Meetup):
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


@router.post("/{meetup_id}/join", response_model=ParticipationOut)
async def join_meetup(
    meetup_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    meetup = await db.get(Meetup, meetup_id)
    if not meetup or meetup.status == MeetupStatus.CANCELLED.value:
        raise HTTPException(status_code=400, detail="Cannot join this meetup")

    existing = await db.scalar(
        select(Participation).where(
            Participation.user_id == current_user.id,
            Participation.meetup_id == meetup_id,
        )
    )
    if existing:
        raise HTTPException(status_code=400, detail="Already joined")

    count = await db.scalar(
        select(func.count(Participation.id)).where(Participation.meetup_id == meetup_id)
    )
    if (count or 0) >= meetup.max_participants:
        meetup.status = MeetupStatus.FULL.value
        await db.commit()
        raise HTTPException(status_code=400, detail="Meetup is already full")

    participation = Participation(user_id=current_user.id, meetup_id=meetup_id)
    db.add(participation)
    await db.commit()
    await db.refresh(participation)
    await _update_meetup_status(db, meetup)
    return participation


@router.delete("/{meetup_id}/leave")
async def leave_meetup(
    meetup_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    participation = await db.scalar(
        select(Participation).where(
            Participation.user_id == current_user.id,
            Participation.meetup_id == meetup_id,
        )
    )
    if not participation:
        raise HTTPException(status_code=404, detail="Not participating")

    await db.delete(participation)
    await db.commit()

    meetup = await db.get(Meetup, meetup_id)
    if meetup:
        await _update_meetup_status(db, meetup)

    return {"status": "left"}
