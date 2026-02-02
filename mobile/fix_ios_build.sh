#!/bin/bash

# Скрипт для исправления ошибки "Command PhaseScriptExecution failed with a nonzero exit code"

set -e

# Установка UTF-8 кодировки для CocoaPods
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo "🔧 Исправление ошибки PhaseScriptExecution..."

cd "$(dirname "$0")"

# 1. Очистка Flutter кэша
echo "📦 Очистка Flutter кэша..."
flutter clean

# 2. Удаление папки build
echo "🗑️  Удаление папки build..."
rm -rf build/

# 3. Очистка iOS кэша
echo "🍎 Очистка iOS кэша..."
cd ios
rm -rf Pods/
rm -rf Podfile.lock
rm -rf .symlinks/
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies

# 4. Получение зависимостей Flutter
echo "📥 Получение зависимостей Flutter..."
cd ..
flutter pub get

# 5. Установка CocoaPods зависимостей
echo "📦 Установка CocoaPods зависимостей..."
cd ios
pod deintegrate || true
pod cache clean --all || true
pod install --repo-update

# 6. Очистка Xcode DerivedData
echo "🧹 Очистка Xcode DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# 7. Проверка Podfile
echo "✅ Проверка Podfile..."
if [ ! -f "Podfile" ]; then
    echo "❌ Podfile не найден!"
    exit 1
fi

# 8. Проверка Info.plist
echo "✅ Проверка Info.plist..."
if [ ! -f "Runner/Info.plist" ]; then
    echo "❌ Info.plist не найден!"
    exit 1
fi

cd ..

echo ""
echo "✅ Очистка завершена!"
echo ""
echo "📱 Теперь попробуйте собрать проект:"
echo "   1. Откройте Xcode: open ios/Runner.xcworkspace"
echo "   2. Или через Flutter: flutter build ios"
echo ""
