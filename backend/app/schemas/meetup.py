from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict

from .game import GameOut
from .user import UserBrief


class MeetupCreate(BaseModel):
    game_id: int
    date_time: datetime
    location: str
    max_participants: int = 6
    description: Optional[str] = None


class MeetupOut(BaseModel):
    id: int
    host_id: int
    game_id: int
    date_time: datetime
    location: str
    status: str
    max_participants: int
    current_participants: int = 0
    description: Optional[str] = None
    game: Optional[GameOut] = None
    host: Optional[UserBrief] = None
    joined: bool = False

    model_config = ConfigDict(from_attributes=True)
