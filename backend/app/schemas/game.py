from pydantic import BaseModel, ConfigDict


class GameOut(BaseModel):
    id: int
    title: str
    description: str
    min_players: int
    max_players: int
    average_time: int
    difficulty: int
    genre: str

    model_config = ConfigDict(from_attributes=True)
