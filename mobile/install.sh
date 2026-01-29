#!/bin/bash

# Скрипт для быстрой установки Tutas Ai Mobile на телефон

set -e

echo "🚀 Установка Tutas Ai Mobile"
echo ""

# Проверка Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter не установлен!"
    echo "Установите Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Переход в директорию mobile
cd "$(dirname "$0")"

echo "📦 Установка зависимостей..."
flutter pub get

echo ""
echo "🔨 Сборка APK..."
flutter build apk --release

echo ""
echo "✅ APK собран: build/app/outputs/flutter-apk/app-release.apk"
echo ""

# Проверка подключения устройства
if command -v adb &> /dev/null; then
    DEVICE=$(adb devices | grep -v "List" | grep "device" | head -1)
    if [ -n "$DEVICE" ]; then
        echo "📱 Обнаружено устройство: $DEVICE"
        read -p "Установить на устройство? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "📲 Установка на устройство..."
            adb install -r build/app/outputs/flutter-apk/app-release.apk
            echo "✅ Установка завершена!"
        fi
    else
        echo "⚠️  Устройство не обнаружено через ADB"
        echo "Подключите телефон через USB и включите режим отладки"
    fi
else
    echo "⚠️  ADB не установлен"
    echo "Установите Android SDK Platform Tools"
fi

echo ""
echo "📋 Следующие шаги:"
echo "1. Если устройство не подключено, скопируйте APK на телефон:"
echo "   build/app/outputs/flutter-apk/app-release.apk"
echo "2. Откройте APK на телефоне и установите"
echo "3. Включите 'Установка из неизвестных источников' если потребуется"
echo ""
echo "📖 Подробные инструкции: см. INSTALL.md"
