from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Message, Meetup, User
from app.db.session import get_db
from app.routers.dependencies import get_current_user
from app.schemas.chat import MessageCreate, MessageOut

router = APIRouter()


@router.get("/{meetup_id}/messages", response_model=list[MessageOut])
async def get_messages(meetup_id: int, db: AsyncSession = Depends(get_db)):
    meetup = await db.get(Meetup, meetup_id)
    if not meetup:
        raise HTTPException(status_code=404, detail="Meetup not found")

    result = await db.execute(
        select(Message).where(Message.meetup_id == meetup_id).order_by(Message.sent_at)
    )
    messages = result.scalars().all()

    output: list[MessageOut] = []
    for message in messages:
        sender = await db.get(User, message.sender_id)
        output.append(
            MessageOut.model_validate(
                {
                    "id": message.id,
                    "meetup_id": message.meetup_id,
                    "sender_id": message.sender_id,
                    "text": message.text,
                    "sent_at": message.sent_at,
                    "sender_nickname": sender.nickname if sender else None,
                }
            )
        )
    return output


@router.post("/{meetup_id}/messages", response_model=MessageOut)
async def send_message(
    meetup_id: int,
    msg: MessageCreate,
    current_user=Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    meetup = await db.get(Meetup, meetup_id)
    if not meetup:
        raise HTTPException(status_code=404, detail="Meetup not found")

    message = Message(meetup_id=meetup_id, sender_id=current_user.id, text=msg.text.strip())
    if not message.text:
        raise HTTPException(status_code=400, detail="Message cannot be empty")

    db.add(message)
    await db.commit()
    await db.refresh(message)
    return MessageOut.model_validate(
        {
            "id": message.id,
            "meetup_id": message.meetup_id,
            "sender_id": message.sender_id,
            "text": message.text,
            "sent_at": message.sent_at,
            "sender_nickname": current_user.nickname,
        }
    )
