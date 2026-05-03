from datetime import datetime
import enum

from sqlalchemy import Column, DateTime, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import declarative_base, relationship

Base = declarative_base()


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    nickname = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    avatar_url = Column(String, nullable=True)
    bio = Column(Text, nullable=True)
    rating = Column(Float, default=5.0)
    favorite_games_ids = Column(Text, nullable=True)  # JSON string


class Game(Base):
    __tablename__ = "games"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, unique=True, nullable=False)
    description = Column(Text, nullable=False)
    min_players = Column(Integer, nullable=False)
    max_players = Column(Integer, nullable=False)
    average_time = Column(Integer, nullable=False)
    difficulty = Column(Integer, nullable=False)
    genre = Column(String, nullable=False)


class MeetupStatus(str, enum.Enum):
    OPEN = "open"
    FULL = "full"
    CANCELLED = "cancelled"


class Meetup(Base):
    __tablename__ = "meetups"

    id = Column(Integer, primary_key=True, index=True)
    host_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    game_id = Column(Integer, ForeignKey("games.id"), nullable=False)
    date_time = Column(DateTime, nullable=False)
    location = Column(String, nullable=False)
    status = Column(String, default=MeetupStatus.OPEN.value, nullable=False)
    max_participants = Column(Integer, nullable=False)
    description = Column(Text, nullable=True)

    host = relationship("User")
    game = relationship("Game")


class Participation(Base):
    __tablename__ = "participations"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    meetup_id = Column(Integer, ForeignKey("meetups.id"), nullable=False)
    status = Column(String, default="confirmed", nullable=False)
    joined_at = Column(DateTime, default=datetime.utcnow, nullable=False)


class Message(Base):
    __tablename__ = "messages"

    id = Column(Integer, primary_key=True, index=True)
    meetup_id = Column(Integer, ForeignKey("meetups.id"), nullable=False)
    sender_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    text = Column(Text, nullable=False)
    sent_at = Column(DateTime, default=datetime.utcnow, nullable=False)
