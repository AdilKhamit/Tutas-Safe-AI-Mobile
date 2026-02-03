# Tutas Safe AI Platform

**Enterprise-Grade Pipeline Monitoring & Predictive Analytics System**

Tutas Safe AI is a comprehensive digital ecosystem for industrial pipeline inspection. It combines mobile defect detection, AI-driven lifetime forecasting (5-year horizon), and an interactive web dashboard for real-time decision making.

[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.11-blue.svg)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-green.svg)](https://fastapi.tiangolo.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![React](https://img.shields.io/badge/React-18-blue.svg)](https://reactjs.org/)

---

## Table of Contents

- [System Architecture](#system-architecture)
- [Quick Start](#quick-start)
- [Components](#components)
- [Development](#development)
- [Deployment](#deployment)
- [Security](#security)
- [Documentation](#documentation)
- [Contributing](#contributing)

---

## System Architecture

The platform follows a microservices architecture:

- **Backend:** Python 3.11, FastAPI (High-performance Async API)
- **Database:** PostgreSQL 16 + PostGIS (Geo) + TimescaleDB (Time-series)
- **AI Engine:** Hybrid Model (Prophet + LSTM) for predictive analytics
- **Frontend:** React 18, TypeScript, Ant Design, Leaflet Maps
- **Mobile:** Flutter (Offline-first architecture with Drift DB)
- **Infrastructure:** Docker Compose, Nginx, Traefik, Redis, MinIO

### Architecture Diagram

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Mobile    │────▶│   Backend   │────▶│  Database   │
│  (Flutter)  │     │  (FastAPI)  │     │ (PostgreSQL)│
└─────────────┘     └─────────────┘     └─────────────┘
                            │
                            ▼
                    ┌─────────────┐
                    │  AI Engine  │
                    │ (Prophet +  │
                    │    LSTM)    │
                    └─────────────┘
                            │
                            ▼
                    ┌─────────────┐
                    │   Frontend  │
                    │   (React)   │
                    └─────────────┘
```

---

## Quick Start

### Prerequisites

- Docker & Docker Compose 2.0+
- Make (optional, for convenience)
- 4GB+ RAM available
- 10GB+ disk space

### 1. Configure Environment

```bash
cp .env.example .env
# Edit .env and change all default passwords and secrets!
```

**⚠️ Security Warning:** The default credentials are for development only. **MUST be changed in production!** See [SECURITY.md](SECURITY.md) for details.

### 2. Build & Launch

```bash
make build
make up
```

*Wait ~30 seconds for the database to initialize.*

### 3. Seed Demo Data

Populate the database with demo data (10 pipes, 5 years of measurements, AI predictions):

```bash
make seed
```

### 4. Setup Authentication

Create users table and register first user:

```bash
# Option 1: Using setup script
./scripts/setup_auth.sh

# Option 2: Using Python script
python3 scripts/register_user.py test@tutas.ai test123456 "Test User"
```

**Default Test Credentials:**
- Email: `test@tutas.ai`
- Password: `test123456`

### 5. Access Services

| Service | URL | Credentials |
| --- | --- | --- |
| **Web Portal** | `http://localhost:3000` | N/A |
| **API Docs** | `http://localhost:8000/docs` | N/A |
| **API Health** | `http://localhost:8000/health` | N/A |
| **MinIO Console** | `http://localhost:9001` | minioadmin / minioadmin |
| **Traefik Dashboard** | `http://localhost:8080` | N/A |

---

## Components

### Backend API

FastAPI-based backend service providing RESTful API for pipeline management.

**Features:**
- Full CRUD operations for pipes, inspections, defects
- JWT-based authentication
- PDF report generation
- QR code generation
- Integration with AI Engine

**Documentation:** [backend/README.md](backend/README.md)

### AI Engine

ML prediction service using hybrid model (Prophet + LSTM) for 5-year lifetime forecasting.

**Features:**
- Time series forecasting with Prophet
- Non-linear pattern learning with LSTM
- Confidence intervals and risk assessment
- Status classification (Ok/Warning/Critical)

**Documentation:** [ai_engine/README.md](ai_engine/README.md)

### Frontend Dashboard

React-based web portal for real-time monitoring and management.

**Features:**
- Interactive maps with Leaflet
- Real-time statistics and charts
- Defect trend analysis
- Responsive design

**Documentation:** [frontend/README.md](frontend/README.md)

### Mobile Application

Flutter mobile app with offline-first architecture for field engineers.

**Features:**
- Offline-first with local SQLite database
- QR code scanner for quick pipe access
- Defect reporting with photo capture
- Auto-sync with conflict resolution
- JWT authentication with secure storage

**Documentation:** [mobile/README.md](mobile/README.md)

---

## Development

### Management Commands

We provide a `Makefile` to simplify daily operations:

**Basic Commands:**
- `make up` - Start all services
- `make down` - Stop all services
- `make restart` - Restart all services
- `make logs` - View real-time logs
- `make status` - Show project status

**Database Commands:**
- `make seed` - Seed database with demo data
- `make shell-db` - Open PostgreSQL shell

**Build Commands:**
- `make build` - Build all Docker images
- `make rebuild` - Rebuild all images (no cache)
- `make clean` - Clean temporary files

Run `make help` to see all available commands.

### Development Setup

#### Backend

```bash
cd backend
poetry install
poetry run uvicorn app.main:app --reload
```

#### Frontend

```bash
cd frontend
npm install
npm run dev
```

#### Mobile

```bash
cd mobile
flutter pub get
flutter run
```

---

## Deployment

For production deployment, see [DEPLOYMENT.md](DEPLOYMENT.md).

**Key considerations:**
- Change all default passwords
- Configure SSL/TLS
- Set up monitoring and logging
- Configure backup strategy
- Review security settings

---

## Security

**IMPORTANT:** Before deploying to production:

1. Change all default passwords and secrets
2. Generate secure API keys
3. Review [SECURITY.md](SECURITY.md) for best practices
4. Never commit `.env` files to version control
5. Configure CORS appropriately
6. Enable rate limiting

---

## Documentation

### Getting Started
- [Quick Start Guide](#quick-start) - This file
- [Deployment Guide](DEPLOYMENT.md) - Production deployment
- [Security Guidelines](SECURITY.md) - Security best practices

### Authentication
- [Authentication Setup](AUTHENTICATION_SETUP.md) - Complete authentication guide
- [Quick Auth Setup](QUICK_AUTH_SETUP.md) - Quick start for authentication

### Components
- [Backend API](backend/README.md) - Backend documentation
- [AI Engine](ai_engine/README.md) - AI Engine documentation
- [Frontend](frontend/README.md) - Frontend documentation
- [Mobile App](mobile/README.md) - Mobile app documentation

### Mobile App
- [Mobile Architecture](mobile/ARCHITECTURE.md) - Architecture overview
- [Mobile Installation](mobile/INSTALL.md) - Installation guide
- [QR Code Troubleshooting](mobile/QR_CODE_TROUBLESHOOTING.md) - QR scanning issues

### Scripts
- [Scripts Documentation](scripts/README.md) - Utility scripts

---

## Project Status

**Current Version: MVP (Minimum Viable Product)**

This is a **production-ready prototype** with strong architecture and core functionality.

### ✅ Completed Features

- **Backend API**: Full CRUD operations, PDF generation, AI integration
- **Authentication**: JWT-based authentication with refresh tokens
- **AI Engine**: Hybrid model (Prophet + LSTM) with confidence intervals
- **Mobile App**: Offline-first architecture, QR scanner, defect reporting
- **Frontend Dashboard**: Interactive maps, statistics, charts
- **Infrastructure**: Docker Compose, database seeding

### 🚧 Known Limitations

- Test coverage needs expansion
- Push notifications not yet implemented
- Analytics integration pending

---

## Contributing

This is a proprietary project. For contributions, please contact the maintainers.

---

## License

Proprietary Software. Developed for Tutas Safe AI.

---

## Acknowledgments

Built with:
- [FastAPI](https://fastapi.tiangolo.com/) - Modern Python web framework
- [Flutter](https://flutter.dev/) - Cross-platform mobile framework
- [React](https://reactjs.org/) - Frontend library
- [PostgreSQL](https://www.postgresql.org/) - Database
- [Docker](https://www.docker.com/) - Containerization

---

## Support

For issues and questions:
- Check [Documentation](#documentation) section
- Review component-specific README files
- Contact project maintainers
