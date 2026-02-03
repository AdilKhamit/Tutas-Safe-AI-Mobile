# Mobile App Installation Guide

Complete installation guide for Tutas AI mobile application on Android and iOS devices.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Android Installation](#android-installation)
- [iOS Installation](#ios-installation)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### For Android
- Android 5.0 (API 21) or higher
- Developer mode enabled
- Allow installation from unknown sources

### For iOS
- iOS 12.0 or higher
- Mac with Xcode (for building)
- Apple Developer account (for physical device installation)

---

## Android Installation

### Method 1: Build APK (Recommended)

#### Step 1: Build APK

```bash
cd mobile

# Install dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Or build debug APK (smaller size)
flutter build apk --debug
```

APK file location: `build/app/outputs/flutter-apk/app-release.apk`

#### Step 2: Transfer APK to Device

**Option A: Via USB**
```bash
# Connect device via USB
# Enable USB debugging in developer settings

# Install directly
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Option B: Via Cloud/Email**
1. Upload `app-release.apk` to Google Drive / Dropbox
2. Download on device
3. Install via file manager

#### Step 3: Install on Device

1. Open file manager on device
2. Find downloaded APK file
3. Tap to install
4. If prompted "Install from unknown sources":
   - Tap "Settings"
   - Enable "Allow from this source"
   - Return and tap "Install"
5. Open "Tutas AI" app after installation

### Method 2: Via USB (Development)

```bash
cd mobile
flutter pub get

# Connect device via USB
# Enable USB debugging

# Run app
flutter run

# Or install only
flutter install
```

### Method 3: Via Android Studio

1. Open project in Android Studio
2. Select device from toolbar
3. Click Run (▶️)
4. App will install and launch

---

## iOS Installation

### Method 1: Via Xcode (Recommended)

#### Step 1: Open Project in Xcode

```bash
cd mobile
open ios/Runner.xcworkspace
```

**IMPORTANT:** Open `.xcworkspace`, not `.xcodeproj`!

#### Step 2: Configure Signing

1. Select **Runner** project in left panel
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Select your development team
5. Ensure **Bundle Identifier** is unique (e.g., `com.yourname.tutasAiMobile`)

#### Step 3: Select Device

1. In Xcode toolbar, select your device
2. Ensure device is unlocked and trusted

#### Step 4: Build and Install

1. Click **Run** (▶️) or press `Cmd+R`
2. If prompted to trust - click **Trust**
3. On iPhone: **Settings > General > VPN & Device Management** > Trust developer

#### Step 5: Launch App

After installation, app will appear on home screen.

### Method 2: Via Flutter CLI

#### Prerequisites

1. Ensure device is connected and trusted:
   ```bash
   flutter devices
   ```

2. Set UTF-8 encoding:
   ```bash
   export LANG=en_US.UTF-8
   export LC_ALL=en_US.UTF-8
   ```

#### Installation

```bash
cd mobile

# Clean and prepare
flutter clean
flutter pub get
cd ios && pod install && cd ..

# Run on device
flutter run
```

### Method 3: Build IPA File

If you need to create installation file:

```bash
cd mobile

# Build IPA
flutter build ipa

# File location:
# build/ios/ipa/tutas_ai_mobile.ipa
```

Then install via:
- **Xcode** (Window > Devices and Simulators > + > select IPA)
- **Apple Configurator 2**
- **TestFlight** (for beta testing)

---

## Configuration

### API Endpoint Setup

Before installation, ensure app is configured with correct API endpoint.

#### Create .env File

Create `.env` file in `mobile/` directory:

```bash
API_BASE_URL=http://your-server-ip:8000
API_KEY=dev-api-key-12345  # Optional for development
```

#### Finding Your IP Address

**macOS/Linux:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Windows:**
```cmd
ipconfig
```

Look for IP address in local network (usually starts with `192.168.` or `10.0.`)

#### Important Notes

**For Physical Device:**
- Use your computer's IP address instead of `localhost`
- Ensure device and computer are on same Wi-Fi network
- Example: `http://192.168.1.100:8000`

**For Android Emulator:**
- Use `http://10.0.2.2:8000`

**For iOS Simulator:**
- Use `http://localhost:8000`

### Permissions

The app requests the following permissions:

**Android:**
- **Camera**: For QR code scanning and photo capture
- **Storage**: For saving defect photos
- **Internet**: For synchronization

**iOS:**
- **Camera**: For QR code scanning and photo capture
- **Photo Library**: For accessing photos

Permissions are requested automatically when needed.

---

## Troubleshooting

### Connection Issues

**Problem:** "Cannot connect to server"

**Solutions:**
1. Verify backend is running: `make up` or `docker-compose up`
2. Check API URL in `.env` file
3. Ensure device and computer are on same network
4. Check firewall settings (port 8000 should be open)

### Installation Issues

**Android:**
- Enable "Install from unknown sources" in settings
- Verify APK file integrity (rebuild if needed)
- Check device storage space

**iOS:**
- Verify signing certificate in Xcode
- Trust developer in device settings (Settings > General > VPN & Device Management)
- Ensure Bundle ID is unique
- Check device is unlocked

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

### Camera Issues

**Problem:** Camera not working

**Solutions:**
1. Grant camera permission when prompted
2. Restart app
3. Check permissions in device settings
4. Verify camera hardware is working

### QR Code Issues

**Problem:** QR code not recognized

**Solutions:**
1. Verify QR code format: `PL-{COMPANY}-{UUID}`
2. Ensure pipe exists in database
3. Check API connection
4. Review app logs for errors

For detailed QR troubleshooting, see [QR_CODE_TROUBLESHOOTING.md](QR_CODE_TROUBLESHOOTING.md).

---

## Verification

After installation, verify:

1. ✅ App appears on home screen
2. ✅ App launches without errors
3. ✅ Can login: `test@tutas.ai` / `test123456`
4. ✅ QR scanner works
5. ✅ Can create defects with photos
6. ✅ Data syncs with server

---

## Quick Installation (One Command)

**Android:**
```bash
cd mobile && flutter pub get && flutter build apk --release && adb install build/app/outputs/flutter-apk/app-release.apk
```

**iOS:**
```bash
cd mobile && flutter pub get && flutter build ios && flutter install
```

---

## Updating App

To update installed app:

1. Build new version APK/IPA
2. Install over old version (data will be preserved)
3. Or uninstall old app and install new one

```bash
# Android
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk

# iOS
flutter build ios
flutter install
```

---

## Additional Resources

- [Mobile README](README.md) - Complete mobile app documentation
- [Architecture Guide](ARCHITECTURE.md) - Architecture overview
- [QR Troubleshooting](QR_CODE_TROUBLESHOOTING.md) - QR scanning issues

---

## Support

For issues and questions:
- Check [Troubleshooting](#troubleshooting) section
- Review [Mobile README](README.md)
- Contact project maintainers
