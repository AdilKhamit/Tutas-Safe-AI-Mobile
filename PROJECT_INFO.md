# Tutas Ai - Project Information

## Структура проекта

```
Tutas Ai/
├── docker-compose.yaml      # Docker Compose конфигурация
├── .env.example             # Пример переменных окружения
├── .gitignore               # Git ignore правила
├── README.md                # Основная документация
├── PROJECT_INFO.md          # Этот файл
│
├── backend/                 # FastAPI Backend
│   ├── Dockerfile
│   ├── pyproject.toml
│   ├── poetry.lock
│   ├── README.md
│   └── app/
│       ├── __init__.py
│       ├── main.py
│       ├── models/          # SQLAlchemy модели
│       ├── api/             # API роутеры
│       ├── core/            # Конфигурация
│       ├── schemas/         # Pydantic схемы
│       └── services/        # Бизнес-логика
│
├── frontend/                # React приложение (будущее)
├── mobile/                  # Flutter приложение (будущее)
├── ai_engine/               # ML сервисы (будущее)
│
└── infra/                   # Инфраструктура
    └── db/
        └── init.sql         # Инициализация БД (PostGIS, TimescaleDB)
```

## Сервисы Docker

- **tutas_ai_db** - PostgreSQL 16 + PostGIS + TimescaleDB
- **tutas_ai_redis** - Redis 7 для кэширования и очередей
- **tutas_ai_minio** - MinIO S3-совместимое хранилище
- **tutas_ai_traefik** - Reverse Proxy
- **tutas_ai_backend** - FastAPI Backend

## Быстрый старт

```bash
cd "Tutas Ai"
cp .env.example .env
docker-compose up -d
```

## Порты

- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Traefik Dashboard: http://localhost:8080
- MinIO Console: http://localhost:9001
- PostgreSQL: localhost:5432

## База данных

- Имя БД: `tutas_ai`
- Схема: `tutas_ai`
- Расширения: PostGIS, TimescaleDB

## MinIO Buckets

- `tutas-photos` - Фотографии дефектов
- `tutas-reports` - Отчеты
- `tutas-models` - ML модели


