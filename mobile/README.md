# Tutas AI Mobile Application

Flutter mobile application with offline-first architecture for pipeline monitoring and defect reporting.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Installation](#installation)
- [Configuration](#configuration)
- [Development](#development)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

---

## Features

- ✅ **Offline-First Architecture** - Works without internet connection
- ✅ **JWT Authentication** - Secure login with refresh tokens
- ✅ **QR Code Scanner** - Scan pipe QR codes for quick access
- ✅ **Defect Reporting** - Report defects with photos and metadata
- ✅ **Auto-Sync** - Automatic synchronization when connection restored
- ✅ **Conflict Resolution** - Handle sync conflicts with server
- ✅ **Network Status** - Real-time connectivity monitoring
- ✅ **Image Caching** - Efficient image loading and caching
- ✅ **Biometric Authentication** - Fingerprint/Face ID support

---

## Architecture

### Offline-First Design

The app follows a **local-first** approach:

1. **Local-First**: All data is saved to local SQLite database (Drift) immediately
2. **Background Sync**: Synchronization happens in background when online
3. **Conflict Resolution**: Manual resolution UI for server conflicts

### Data Flow

```
User Input → DefectRepository.saveDefect()
  → LocalDefects.insert() with syncStatus = Pending
  → ✅ Success (offline ready)

syncPendingDefects()
  → Get all Pending defects
  → For each defect:
    → POST to /api/v1/defects
    → Success (200/201): Update syncStatus = Synced
    → Conflict (409): Update syncStatus = Conflict, save serverVersionJson
    → Error: Update syncStatus = Failed
```

### Sync Status Values

- `0` (Pending): Waiting to be synced
- `1` (Synced): Successfully synced with server
- `2` (Failed): Sync failed (retry later)
- `3` (Conflict): Server version conflicts with local

### Project Structure

```
lib/
├── data/
│   ├── local/
│   │   └── database.dart      # Drift database schema
│   ├── models/
│   │   └── defect_dto.dart    # DTO and mappers
│   └── api/
│       └── api_client.dart    # HTTP client with conflict handling
├── repositories/
│   └── defect_repository.dart # Business logic and sync
├── ui/
│   ├── screens/               # Screen widgets
│   └── widgets/               # Reusable widgets
├── core/
│   ├── services/             # Core services (auth, connectivity)
│   └── providers/            # Riverpod providers
└── main.dart
```

For detailed architecture documentation, see [ARCHITECTURE.md](ARCHITECTURE.md).

---

## Installation

### Prerequisites

- Flutter 3.0+ installed
- Android Studio / Xcode (for iOS)
- Physical device or emulator

### Quick Start

```bash
cd mobile
flutter pub get
flutter run
```

### Android Installation

#### Build APK

```bash
cd mobile
flutter pub get
flutter build apk --release
```

APK file location: `build/app/outputs/flutter-apk/app-release.apk`

#### Install on Device

**Option 1: Via USB**
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Option 2: Manual**
1. Copy APK to device
2. Enable "Install from unknown sources" in settings
3. Open APK file and install

### iOS Installation

#### Via Xcode (Recommended)

```bash
cd mobile
open ios/Runner.xcworkspace
```

In Xcode:
1. Select your device
2. Configure signing (Team selection)
3. Click Run (▶️)

#### Via Flutter CLI

```bash
cd mobile
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

**Important for physical iPhone:**
- Use your computer's IP address instead of `localhost`
- Ensure iPhone and computer are on same Wi-Fi network
- Enable "Developer Mode" on iPhone

For detailed installation instructions, see [INSTALL.md](INSTALL.md).

---

## Configuration

### Environment Variables

Create `.env` file in `mobile/` directory:

```bash
API_BASE_URL=http://your-server-ip:8000
API_KEY=dev-api-key-12345  # Optional for development
```

**Important:**
- For physical device: Use your computer's IP address (e.g., `http://192.168.1.100:8000`)
- For Android emulator: Use `http://10.0.2.2:8000`
- For iOS simulator: Use `http://localhost:8000`

### Finding Your IP Address

**macOS/Linux:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Windows:**
```cmd
ipconfig
```

### Permissions

The app requests the following permissions:

**Android:**
- Camera (for QR scanning and photo capture)
- Storage (for saving photos)
- Internet (for synchronization)

**iOS:**
- Camera (for QR scanning and photo capture)
- Photo Library (for accessing photos)

Permissions are requested automatically when needed.

---

## Development

### Setup

```bash
cd mobile
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Code Generation

After adding dependencies, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `database.g.dart` - Drift database code
- `defect_dto.g.dart` - JSON serialization code

### Running

```bash
# Development mode
flutter run

# Release mode
flutter run --release

# Specific device
flutter run -d <device-id>
```

### Dependencies

Key dependencies:
- **Drift**: Local SQLite database
- **Riverpod**: Dependency injection and state management
- **Dio**: HTTP client for API calls
- **GoRouter**: Navigation
- **flutter_secure_storage**: Secure token storage
- **connectivity_plus**: Network status monitoring
- **cached_network_image**: Image caching

---

## Testing

### Unit Tests

```bash
flutter test
```

### Widget Tests

```bash
flutter test test/widget/
```

### Integration Tests

```bash
flutter test integration_test/
```

### Test Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

For detailed testing documentation, see [test/README.md](test/README.md).

---

## Troubleshooting

### Connection Issues

**Problem:** "Cannot connect to server"

**Solutions:**
1. Verify backend is running: `make up` or `docker-compose up`
2. Check API URL in `.env` file
3. Ensure device and computer are on same network
4. Check firewall settings (port 8000)

### QR Code Issues

**Problem:** QR code not recognized

**Solutions:**
1. Verify QR code format: `PL-{COMPANY}-{UUID}`
2. Ensure pipe exists in database
3. Check API connection
4. Review logs for errors

For detailed QR troubleshooting, see [QR_CODE_TROUBLESHOOTING.md](QR_CODE_TROUBLESHOOTING.md).

### Build Issues

**Android:**
```bash
flutter clean
flutter pub get
flutter build apk --release
```

**iOS:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

### Installation Issues

**Android:**
- Enable "Install from unknown sources"
- Check APK file integrity

**iOS:**
- Verify signing certificate
- Trust developer in device settings
- Ensure Bundle ID is unique

---

## Usage Examples

### Save Defect (Offline)

```dart
final repository = ref.read(defectRepositoryProvider);
await repository.saveDefect(DefectDto(
  pipeId: 'pipe-uuid',
  defectType: 'corrosion',
  severity: 3,
  photos: ['/path/to/photo.jpg'],
));
```

### Sync Pending Defects

```dart
final result = await repository.syncPendingDefects();
print('Synced: ${result.synced}, Failed: ${result.failed}, Conflicts: ${result.conflicts}');
```

### Resolve Conflict

```dart
// Accept server version
await repository.acceptServerVersion(defectId);

// Or keep local version (retry sync)
await repository.keepLocalVersion(defectId);
```

---

## Additional Resources

- [Architecture Documentation](ARCHITECTURE.md) - Detailed architecture overview
- [Installation Guide](INSTALL.md) - Complete installation instructions
- [QR Code Troubleshooting](QR_CODE_TROUBLESHOOTING.md) - QR scanning issues
- [Quick Start Guide](QUICK_START.md) - Quick setup guide

---

## Support

For issues and questions:
- Check [Troubleshooting](#troubleshooting) section
- Review component-specific documentation
- Contact project maintainers

---

## License

Proprietary Software. Developed for Tutas Safe AI.
