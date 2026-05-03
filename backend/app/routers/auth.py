from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import create_access_token, get_password_hash, verify_password
from app.db.models import User
from app.db.session import get_db
from app.schemas.base import Token
from app.schemas.user import UserCreate, UserLogin, UserOut

router = APIRouter()


@router.post("/register", response_model=UserOut)
async def register(user: UserCreate, db: AsyncSession = Depends(get_db)):
    existing = await db.scalar(
        select(User).where(or_(User.email == user.email, User.nickname == user.nickname))
    )
    if existing:
        raise HTTPException(status_code=400, detail="Email or nickname already registered")

    new_user = User(
        nickname=user.nickname.strip(),
        email=user.email.lower().strip(),
        hashed_password=get_password_hash(user.password),
    )
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)
    return new_user


@router.post("/login", response_model=Token)
async def login(user_in: UserLogin, db: AsyncSession = Depends(get_db)):
    user = await db.scalar(select(User).where(User.email == user_in.email.lower().strip()))
    if not user or not verify_password(user_in.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Incorrect email or password")

    access_token = create_access_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer"}
