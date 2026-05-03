from datetime import datetime, timedelta

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import get_password_hash
from app.db.models import Game, Meetup, Message, Participation, User


async def seed_data(db: AsyncSession):
    if (await db.execute(select(Game))).scalars().first() is None:
        games = [
            Game(title="Колонизаторы (Catan)", description="Классика стратегии", min_players=3, max_players=4, average_time=90, difficulty=3, genre="Стратегия"),
            Game(title="Билет на поезд", description="Семейная классика", min_players=2, max_players=5, average_time=60, difficulty=2, genre="Семейная"),
            Game(title="Дюна: Империя", description="Эпическая стратегия", min_players=1, max_players=4, average_time=120, difficulty=5, genre="Стратегия"),
            Game(title="7 Чудес", description="Карточный драфт", min_players=3, max_players=7, average_time=45, difficulty=3, genre="Стратегия"),
            Game(title="Пандемия", description="Кооперативная игра", min_players=2, max_players=4, average_time=60, difficulty=4, genre="Кооператив"),
        ]
        db.add_all(games)
        await db.commit()

    if (await db.execute(select(User))).scalars().first() is None:
        users = [
            User(nickname="Алексей_Кот", email="alex@example.com", hashed_password=get_password_hash("123456"), rating=5.0, bio="Люблю стратегические игры"),
            User(nickname="Маша_Игрок", email="masha@example.com", hashed_password=get_password_hash("123456"), rating=4.8, bio="Обожаю семейные и кооперативные игры"),
            User(nickname="Дмитрий_Мастер", email="dima@example.com", hashed_password=get_password_hash("123456"), rating=5.0, bio="Провожу длинные игровые вечера"),
        ]
        db.add_all(users)
        await db.commit()

    if (await db.execute(select(Meetup))).scalars().first() is None:
        meetups = [
            Meetup(host_id=1, game_id=1, date_time=datetime.utcnow() + timedelta(hours=3), location="Москва, парк Горького", max_participants=4, description="Ищем 2 игроков в Catan! Новички welcome."),
            Meetup(host_id=2, game_id=2, date_time=datetime.utcnow() + timedelta(hours=5), location="Онлайн (Discord)", max_participants=5, description="Билет на поезд — вечерняя партия"),
            Meetup(host_id=1, game_id=3, date_time=datetime.utcnow() + timedelta(days=1, hours=2), location="Санкт-Петербург, Лофт на Невском", max_participants=4, description="Дюна: Империя — большая партия"),
        ]
        db.add_all(meetups)
        await db.commit()

    if (await db.execute(select(Participation))).scalars().first() is None:
        participations = [
            Participation(user_id=2, meetup_id=1),
            Participation(user_id=3, meetup_id=1),
        ]
        db.add_all(participations)
        await db.commit()

    if (await db.execute(select(Message))).scalars().first() is None:
        messages = [
            Message(meetup_id=1, sender_id=1, text="Привет! Возьмём ещё двух игроков на сегодня."),
            Message(meetup_id=1, sender_id=2, text="Я с удовольствием присоединюсь."),
        ]
        db.add_all(messages)
        await db.commit()

    print("✅ Seed data loaded successfully!")
