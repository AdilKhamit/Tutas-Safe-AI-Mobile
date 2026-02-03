# Backend API

FastAPI-based backend service for Pipeline Monitoring Platform.

[![Python](https://img.shields.io/badge/python-3.11-blue.svg)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-green.svg)](https://fastapi.tiangolo.com/)

---

## Table of Contents

- [Features](#features)
- [Project Structure](#project-structure)
- [Setup](#setup)
- [API Documentation](#api-documentation)
- [Development](#development)
- [Database](#database)
- [Authentication](#authentication)
- [Deployment](#deployment)

---

## Features

- ✅ **RESTful API** - Full CRUD operations for all entities
- ✅ **JWT Authentication** - Secure token-based authentication
- ✅ **PostgreSQL + PostGIS** - Geographic data support
- ✅ **TimescaleDB** - Time-series data optimization
- ✅ **PDF Generation** - Automated report generation
- ✅ **QR Code Generation** - QR codes for pipe identification
- ✅ **AI Integration** - Integration with AI Engine service
- ✅ **Async/Await** - High-performance async operations

---

## Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI app entry point
│   ├── models/              # SQLAlchemy models
│   │   ├── pipe.py
│   │   ├── inspection.py
│   │   ├── defect.py
│   │   └── user.py
│   ├── api/                 # API routers
│   │   ├── v1/
│   │   │   ├── pipes.py
│   │   │   ├── inspections.py
│   │   │   ├── defects.py
│   │   │   └── auth.py
│   ├── core/                # Core configuration
│   │   ├── config.py        # Settings
│   │   ├── security.py      # JWT and password hashing
│   │   └── dependencies.py  # Dependency injection
│   ├── schemas/             # Pydantic schemas
│   │   ├── pipe.py
│   │   ├── inspection.py
│   │   └── defect.py
│   └── services/            # Business logic
│       ├── pdf_service.py
│       └── qr_service.py
├── alembic/                 # Database migrations
├── tests/                   # Test suite
├── Dockerfile
├── pyproject.toml
└── README.md
```

---

## Setup

### Prerequisites

- Python 3.11+
- Poetry (dependency management)
- PostgreSQL 16+ with PostGIS and TimescaleDB extensions

### Installation

```bash
# Install dependencies
poetry install

# Or using pip
pip install -r requirements.txt
```

### Environment Variables

Create `.env` file:

```bash
# Database
DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost:5432/tutas_ai

# Security
SECRET_KEY=your-secret-key-here
JWT_SECRET_KEY=your-jwt-secret-key-here
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30

# API
API_KEYS=dev-api-key-12345,another-key
ENVIRONMENT=development  # or production

# Redis
REDIS_URL=redis://localhost:6379
REDIS_PASSWORD=

# MinIO
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin

# AI Engine
AI_ENGINE_URL=http://ai-engine:8001
AI_ENGINE_API_KEY=
```

### Database Setup

```bash
# Run migrations
poetry run alembic upgrade head

# Or manually create database
createdb tutas_ai
psql -d tutas_ai -c "CREATE EXTENSION postgis;"
psql -d tutas_ai -c "CREATE EXTENSION timescaledb;"
```

### Running

```bash
# Development server
poetry run uvicorn app.main:app --reload

# Production server
poetry run uvicorn app.main:app --host 0.0.0.0 --port 8000
```

---

## API Documentation

### Interactive API Docs

Once the server is running, access:
- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

### Main Endpoints

#### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login and get tokens
- `POST /api/v1/auth/refresh` - Refresh access token
- `GET /api/v1/auth/me` - Get current user info

#### Pipes
- `GET /api/v1/pipes` - List all pipes
- `GET /api/v1/pipes/{id}` - Get pipe details
- `POST /api/v1/pipes` - Create new pipe
- `PUT /api/v1/pipes/{id}` - Update pipe
- `DELETE /api/v1/pipes/{id}` - Delete pipe
- `GET /api/v1/pipes/{id}/qr` - Get QR code for pipe

#### Inspections
- `GET /api/v1/inspections` - List inspections
- `GET /api/v1/inspections/{id}` - Get inspection details
- `POST /api/v1/inspections` - Create inspection
- `PUT /api/v1/inspections/{id}` - Update inspection

#### Defects
- `GET /api/v1/defects` - List defects
- `GET /api/v1/defects/{id}` - Get defect details
- `POST /api/v1/defects` - Create defect
- `PUT /api/v1/defects/{id}` - Update defect
- `DELETE /api/v1/defects/{id}` - Delete defect

#### Reports
- `GET /api/v1/pipes/{id}/report` - Generate PDF report

### Authentication

Most endpoints require authentication. Include JWT token in header:

```bash
Authorization: Bearer <access_token>
```

For development, API key authentication is also available:

```bash
X-API-Key: dev-api-key-12345
```

---

## Development

### Code Style

We use:
- **Black** for code formatting
- **isort** for import sorting
- **mypy** for type checking
- **pylint** for linting

```bash
# Format code
black app/

# Sort imports
isort app/

# Type check
mypy app/

# Lint
pylint app/
```

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific test
pytest tests/test_pipes.py
```

### Database Migrations

```bash
# Create new migration
poetry run alembic revision --autogenerate -m "Description"

# Apply migrations
poetry run alembic upgrade head

# Rollback migration
poetry run alembic downgrade -1
```

---

## Database

### Models

- **Pipe**: Pipeline segments with geographic data
- **Inspection**: Inspection records with measurements
- **Defect**: Defect reports with photos
- **User**: User accounts for authentication

### Extensions

- **PostGIS**: Geographic data types and functions
- **TimescaleDB**: Time-series data optimization

### Connection

The app uses async SQLAlchemy with `asyncpg` driver for PostgreSQL.

---

## Authentication

### JWT Tokens

The API uses JWT (JSON Web Tokens) for authentication:

1. User logs in with email/password
2. Server returns `access_token` and `refresh_token`
3. Client includes `access_token` in `Authorization` header
4. When `access_token` expires, use `refresh_token` to get new one

### Password Hashing

Passwords are hashed using bcrypt before storage.

### Token Expiration

- **Access Token**: 30 minutes (configurable)
- **Refresh Token**: 7 days (configurable)

---

## Deployment

### Docker

```bash
# Build image
docker build -t tutas-ai-backend .

# Run container
docker run -p 8000:8000 --env-file .env tutas-ai-backend
```

### Production Considerations

1. **Security**:
   - Change all default passwords
   - Use strong JWT secret keys
   - Configure CORS appropriately
   - Enable rate limiting
   - Use HTTPS/TLS

2. **Performance**:
   - Use connection pooling
   - Enable database query caching
   - Configure Redis for session storage
   - Use CDN for static assets

3. **Monitoring**:
   - Set up logging aggregation
   - Configure health checks
   - Monitor API performance
   - Set up error tracking

For detailed deployment instructions, see [../DEPLOYMENT.md](../DEPLOYMENT.md).

---

## Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)
- [PostGIS Documentation](https://postgis.net/documentation/)
- [TimescaleDB Documentation](https://docs.timescale.com/)

---

## Support

For issues and questions:
- Check API documentation at `/docs`
- Review [Security Guidelines](../SECURITY.md)
- Contact project maintainers
