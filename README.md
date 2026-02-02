# Tutas Safe AI Platform 🚀

**Enterprise-Grade Pipeline Monitoring & Predictive Analytics System**

Tutas Safe AI is a comprehensive digital ecosystem for industrial pipeline inspection. It combines mobile defect detection, AI-driven lifetime forecasting (5-year horizon), and an interactive web dashboard for real-time decision making.

[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.11-blue.svg)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-green.svg)](https://fastapi.tiangolo.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![React](https://img.shields.io/badge/React-18-blue.svg)](https://reactjs.org/)

---

## 🏗 System Architecture

The platform follows a microservices architecture:

* **Backend:** Python 3.11, FastAPI (High-performance Async API)
* **Database:** PostgreSQL 16 + PostGIS (Geo) + TimescaleDB (Time-series)
* **AI Engine:** Scikit-learn Linear Regression (Trend analysis & Confidence Intervals)
* **Frontend:** React 18, TypeScript, Ant Design, Leaflet Maps
* **Mobile:** Flutter (Offline-first architecture with Drift DB)
* **Infrastructure:** Docker Compose, Nginx, Traefik, Redis, MinIO

---

## 🚀 Quick Start (Production)

Follow these steps to deploy the system in 5 minutes.

### Prerequisites
* Docker & Docker Compose
* Make (optional, for convenience)

### 1. Configure Environment
Copy the example environment file:
```bash
cp .env.example .env
# Edit .env and change all default passwords and secrets!
```

**⚠️ Security Warning:** The default credentials are for development only. **MUST be changed in production!** See [SECURITY.md](SECURITY.md) for details.

### 2. Build & Launch

Use the Makefile to build and start all services:

```bash
make build
make up
```

*Wait ~30 seconds for the database to initialize.*

### 3. Seed Demo Data (Critical for Demo!)

Populate the empty database with 10 pipes, 5 years of measurement history, and AI predictions:

```bash
make seed
```

*Output should show: "✅ Created 10 pipes", "Generated measurements", etc.*

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

See [QUICK_AUTH_SETUP.md](QUICK_AUTH_SETUP.md) for detailed instructions.

### 5. Access Services

| Service | URL | Credentials |
| --- | --- | --- |
| **Web Portal** | `http://localhost:3000` | N/A (Demo Mode) |
| **API Docs** | `http://localhost:8000/docs` | N/A |
| **API Health** | `http://localhost:8000/health` | N/A |
| **MinIO Console** | `http://localhost:9001` | minioadmin / minioadmin |
| **Traefik Dashboard** | `http://localhost:8080` | N/A |

---

## 📱 Mobile App

### Development

To run the engineer's mobile application:

```bash
cd mobile
flutter pub get
flutter run
```

### Installation on Phone

#### Android Installation

**Быстрая установка:**
```bash
cd mobile
./install.sh
```

**Или вручную:**
```bash
cd mobile
flutter pub get
flutter build apk --release
# APK будет в: build/app/outputs/flutter-apk/app-release.apk
```

#### iOS Installation

**Через Xcode (Рекомендуется):**
```bash
cd mobile
open ios/Runner.xcworkspace
# В Xcode: выберите устройство и нажмите Run (▶️)
```

**Через Flutter CLI:**
```bash
cd mobile
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

📖 **Подробные инструкции:**
- Android: [mobile/INSTALL.md](mobile/INSTALL.md)
- iOS: [mobile/INSTALL_TO_IPHONE.md](mobile/INSTALL_TO_IPHONE.md)

### Mobile App Features

- ✅ **JWT Authentication** - Secure login with refresh tokens
- ✅ **Offline-First Architecture** - Works without internet connection
- ✅ **QR Code Scanner** - Scan pipe QR codes for quick access
- ✅ **Defect Reporting** - Report defects with photos and metadata
- ✅ **Auto-Sync** - Automatic synchronization when connection restored
- ✅ **Conflict Resolution** - Handle sync conflicts with server
- ✅ **Network Status** - Real-time connectivity monitoring
- ✅ **Image Caching** - Efficient image loading and caching

**Важно для физического устройства:**
1. Узнайте IP-адрес вашего компьютера:
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   # Или на Windows: ipconfig
   ```

2. Создайте `.env` файл в `mobile/`:
   ```bash
   API_BASE_URL=http://your-computer-ip:8000
   ```

3. Убедитесь, что телефон и компьютер в одной Wi-Fi сети

---

## 🛠 Management Commands

We provide a `Makefile` to simplify daily operations:

### Basic Commands
* `make up` - Start all services in background
* `make down` - Stop all services
* `make restart` - Restart all services
* `make logs` - View real-time logs from all services
* `make logs-backend` - View backend logs only
* `make logs-frontend` - View frontend logs only
* `make logs-db` - View database logs only

### Database Commands
* `make seed` - Seed database with demo data
* `make seed-simple` - Seed database using SQL script (alternative)

### Build Commands
* `make build` - Build all Docker images
* `make rebuild` - Rebuild all Docker images (no cache)
* `make clean` - Clean temporary files
* `make clean-all` - Clean everything including Docker volumes

### Utility Commands
* `make init` - Initialize project (copy .env, build, start, seed)
* `make status` - Show project status and access URLs
* `make health` - Check health of all services
* `make check` - Check if all services are running
* `make shell-backend` - Open shell in backend container
* `make shell-db` - Open PostgreSQL shell

Run `make help` to see all available commands.

---

## 🤖 AI Features

The **AI Engine** (`/ai_engine`) provides advanced predictive analytics:

1. **Lifetime Prediction:** Extrapolates wall thickness degradation for 5 years using Linear Regression
2. **Risk Assessment:** Calculates failure probability using Normal Distribution CDF
3. **Smart Intervals:** Computes dynamic confidence intervals based on historical data variance (MSE)
4. **Trend Analysis:** Identifies degradation patterns and predicts future measurements
5. **Confidence Scoring:** Provides confidence levels for predictions based on data quality

### AI Model Details

- **Algorithm:** Scikit-learn Linear Regression
- **Input:** Historical wall thickness measurements
- **Output:** 5-year forecast with confidence intervals
- **Risk Calculation:** Normal distribution-based failure probability

---

---

## 📊 Project Status

**Current Version: MVP (Minimum Viable Product)**

This is a **production-ready prototype** with strong architecture and core functionality, but some features are still in development:

### ✅ Completed Features

- **Backend API**: Full CRUD operations, PDF generation, AI integration
- **Authentication**: ✅ Complete JWT-based authentication with login, register, refresh tokens, and user management
- **AI Engine**: Linear Regression model with confidence intervals and failure probability
- **Mobile App**: 
  - ✅ QR scanner with improved scanning
  - ✅ Offline-first architecture with Drift DB
  - ✅ Defect reporting with photo support
  - ✅ JWT authentication with secure token storage
  - ✅ Auto-sync with conflict resolution
  - ✅ Network status monitoring
  - ✅ Image caching and optimization
  - ✅ iOS and Android support
- **Frontend Dashboard**: Interactive maps, statistics, charts
- **Infrastructure**: Docker Compose, database seeding, CI/CD pipeline

### 🚧 In Progress / Known Limitations

- **Mobile Camera**: Photo capture works but could be enhanced with better UI
- **Frontend Integration**: Some components use mock data as fallback
- **Tests**: Test suite structure exists but needs expansion
- **Push Notifications**: Not yet implemented
- **Analytics**: Not yet integrated

### 🎯 Production Readiness

- **For Demo/Presentation**: ✅ Ready (all core features work)
- **For Enterprise Production**: ⚠️ Requires comprehensive testing, push notifications, and analytics integration

---

## 🔒 Security

**IMPORTANT:** Before deploying to production:
1. Change all default passwords and secrets
2. Generate secure API keys
3. Review [SECURITY.md](SECURITY.md) for best practices
4. Never commit `.env` files to version control

## 📚 Documentation

### Authentication
- [Authentication Complete](AUTHENTICATION_COMPLETE.md) - Authentication system overview
- [Quick Auth Setup](QUICK_AUTH_SETUP.md) - Quick start for authentication
- [Authentication Setup](AUTHENTICATION_SETUP.md) - Complete authentication guide

### Mobile App
- [Mobile Installation (Android)](mobile/INSTALL.md) - Android installation guide
- [Mobile Installation (iOS)](mobile/INSTALL_TO_IPHONE.md) - iOS installation guide
- [Mobile Architecture](mobile/ARCHITECTURE.md) - Mobile app architecture
- [QR Code Troubleshooting](mobile/QR_CODE_TROUBLESHOOTING.md) - QR scanning issues
- [Mobile Quick Start](mobile/QUICK_START.md) - Mobile app quick start

### Deployment & Infrastructure
- [Deployment Guide](DEPLOYMENT.md) - Production deployment instructions
- [Security Guidelines](SECURITY.md) - Security best practices
- [Project Info](PROJECT_INFO.md) - Project structure and information

### AI & Backend
- [Ollama Setup](backend/OLLAMA_SETUP.md) - Ollama AI setup
- [LLama Setup](LLAMA_SETUP.md) - LLama model setup

## 🤝 Contributing

This is a proprietary project. For contributions, please contact the maintainers.

## 📄 License

Proprietary Software. Developed for Tutas Safe AI.

## 🙏 Acknowledgments

Built with:
- [FastAPI](https://fastapi.tiangolo.com/) - Modern Python web framework
- [Flutter](https://flutter.dev/) - Cross-platform mobile framework
- [React](https://reactjs.org/) - Frontend library
- [PostgreSQL](https://www.postgresql.org/) - Database
- [Docker](https://www.docker.com/) - Containerization
