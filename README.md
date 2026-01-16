# Tutas Ai

Enterprise-Grade Pipeline Monitoring and Inspection System

## Architecture

Monorepo structure with microservices:
- `/backend` - FastAPI backend service
- `/frontend` - React web application
- `/mobile` - Flutter mobile application
- `/ai_engine` - ML prediction services
- `/infra` - Docker and infrastructure configurations

## Quick Start

1. Copy environment variables:
```bash
cp .env.example .env
```

2. Update `.env` with your configuration

3. Start services:
```bash
docker-compose up -d
```

4. Access services:
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Traefik Dashboard: http://localhost:8080
- MinIO Console: http://localhost:9001
- PostgreSQL: localhost:5432

## Services

- **PostgreSQL 16** with PostGIS and TimescaleDB
- **Redis 7** for caching and queues
- **MinIO** for S3-compatible object storage
- **Traefik** as reverse proxy
- **FastAPI Backend** on Python 3.11

## Development

### Backend
```bash
cd backend
poetry install
poetry run uvicorn app.main:app --reload
```

## License

Proprietary - Tutas Ai
