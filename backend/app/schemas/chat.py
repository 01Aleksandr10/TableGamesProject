from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict


class MessageCreate(BaseModel):
    text: str


class MessageOut(BaseModel):
    id: int
    meetup_id: int
    sender_id: int
    text: str
    sent_at: datetime
    sender_nickname: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)
