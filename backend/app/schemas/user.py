from typing import Optional

from pydantic import BaseModel, ConfigDict, EmailStr


class UserCreate(BaseModel):
    nickname: str
    email: EmailStr
    password: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserBrief(BaseModel):
    id: int
    nickname: str

    model_config = ConfigDict(from_attributes=True)


class UserOut(BaseModel):
    id: int
    nickname: str
    email: EmailStr
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    rating: float = 5.0

    model_config = ConfigDict(from_attributes=True)
