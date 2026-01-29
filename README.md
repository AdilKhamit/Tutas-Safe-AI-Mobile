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

### 4. Access Services

| Service | URL | Credentials |
| --- | --- | --- |
| **Web Portal** | `http://localhost` | N/A (Demo Mode) |
| **API Docs** | `http://localhost:8000/docs` | N/A |
| **MinIO Console** | `http://localhost:9001` | admin / password |

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

**Быстрая установка (Android):**
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

**Важно для физического устройства:**
1. Узнайте IP-адрес вашего компьютера:
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   # Или на Windows: ipconfig
   ```

2. Обновите IP-адрес API в `mobile/lib/repositories/defect_repository.dart`:
   - Замените `localhost` на IP вашего компьютера (например, `192.168.1.100`)
   - Или используйте переменную окружения: `flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000`

3. Убедитесь, что телефон и компьютер в одной Wi-Fi сети

📖 **Подробные инструкции:** см. [mobile/INSTALL.md](mobile/INSTALL.md)

---

## 🛠 Management Commands

We provide a `Makefile` to simplify daily operations:

* `make up` - Start system
* `make down` - Stop system
* `make logs` - View real-time logs
* `make restart` - Restart all services
* `make clean` - Clean temporary files

---

## 🤖 AI Features

The **AI Engine** (`/ai_engine`) provides:

1. **Lifetime Prediction:** Extrapolates wall thickness degradation for 5 years.
2. **Risk Assessment:** Calculates failure probability using Normal Distribution CDF.
3. **Smart Intervals:** Computes dynamic confidence intervals based on historical data variance (MSE).

---

---

## 📊 Project Status

**Current Version: MVP (Minimum Viable Product)**

This is a **production-ready prototype** with strong architecture and core functionality, but some features are still in development:

### ✅ Completed Features

- **Backend API**: Full CRUD operations, PDF generation, AI integration
- **AI Engine**: Linear Regression model with confidence intervals and failure probability
- **Mobile App**: QR scanner, offline-first data sync, defect reporting
- **Frontend Dashboard**: Interactive maps, statistics, charts
- **Infrastructure**: Docker Compose, database seeding, CI/CD pipeline

### 🚧 In Progress / Known Limitations

- **Authentication**: JWT infrastructure exists but login/register endpoints not implemented
- **Mobile Camera**: Photo capture for defects is placeholder (TODO)
- **Frontend Integration**: Some components use mock data as fallback
- **Tests**: Test suite structure exists but needs expansion

### 🎯 Production Readiness

- **For Demo/Presentation**: ✅ Ready (all core features work)
- **For Enterprise Production**: ⚠️ Requires authentication, testing, and camera implementation

---

## 🔒 Security

**IMPORTANT:** Before deploying to production:
1. Change all default passwords and secrets
2. Generate secure API keys
3. Review [SECURITY.md](SECURITY.md) for best practices
4. Never commit `.env` files to version control

## 📚 Documentation

- [Deployment Guide](DEPLOYMENT.md) - Production deployment instructions
- [Security Guidelines](SECURITY.md) - Security best practices
- [Mobile App Installation](mobile/INSTALL.md) - Mobile app setup
- [QR Code Troubleshooting](mobile/QR_CODE_TROUBLESHOOTING.md) - QR scanning issues

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
