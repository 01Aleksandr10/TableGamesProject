from datetime import datetime

from pydantic import BaseModel, ConfigDict


class ParticipationOut(BaseModel):
    id: int
    user_id: int
    meetup_id: int
    status: str
    joined_at: datetime

    model_config = ConfigDict(from_attributes=True)
