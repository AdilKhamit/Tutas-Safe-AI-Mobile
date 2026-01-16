# Backend API

FastAPI-based backend service for Pipeline Monitoring Platform.

## Setup

1. Install dependencies:
```bash
poetry install
```

2. Set environment variables (see `.env.example`)

3. Run migrations:
```bash
poetry run alembic upgrade head
```

4. Start development server:
```bash
poetry run uvicorn app.main:app --reload
```

## Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py          # FastAPI app entry point
│   ├── models/          # SQLAlchemy models
│   ├── api/             # API routers
│   ├── core/            # Core configuration
│   ├── schemas/         # Pydantic schemas
│   └── services/        # Business logic
├── alembic/             # Database migrations
├── tests/               # Test suite
├── Dockerfile
└── pyproject.toml
```
