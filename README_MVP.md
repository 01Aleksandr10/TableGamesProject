# TableGamesProject MVP

Рабочий MVP для поиска игроков в настольные игры.

## Что уже работает
- регистрация
- вход по email/паролю
- сохранение токена
- список встреч
- создание встречи
- вступление/выход из встречи
- профиль
- список своих встреч
- простой чат встречи

## Демо-аккаунт
- email: `alex@example.com`
- password: `123456`

## Как запустить backend
### Вариант 1: Docker
```bash
docker compose up --build
```
Backend будет на `http://localhost:8000`

### Вариант 2: локально
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

## Как запустить Flutter frontend
```bash
cd frontend
flutter pub get
flutter run
```

### Если это Android-эмулятор
По умолчанию в коде уже используется `http://10.0.2.2:8000`.

### Если нужен свой адрес API
```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_IP:8000
```

## Почему в Docker виден только backend
Это нормально для текущего MVP.
Здесь используется **SQLite**, а не отдельный PostgreSQL-контейнер.
Поэтому база данных — это **файл** `backend/tfp.db`, а не отдельный сервис в Docker Compose.

То есть в Docker у тебя и должен отображаться только сервис `backend`.
Если захочешь отдельный контейнер БД, тогда нужно переводить проект на Postgres и добавлять второй сервис в `docker-compose.yml`.
