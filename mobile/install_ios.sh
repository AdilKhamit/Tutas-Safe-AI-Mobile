#!/bin/bash

# Скрипт для установки Tutas Ai Mobile на iPhone

set -e

echo "🍎 Установка Tutas Ai Mobile на iPhone"
echo ""

# Переход в директорию mobile
cd "$(dirname "$0")"

# Проверка Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter не установлен или не в PATH!"
    echo ""
    echo "Установите Flutter одним из способов:"
    echo ""
    echo "1. Автоматическая установка (рекомендуется):"
    echo "   ./setup_flutter.sh"
    echo ""
    echo "2. Через Homebrew:"
    echo "   brew install --cask flutter"
    echo ""
    echo "3. Ручная установка:"
    echo "   git clone https://github.com/flutter/flutter.git -b stable ~/flutter"
    echo "   export PATH=\"\$PATH:\$HOME/flutter/bin\""
    echo "   echo 'export PATH=\"\$PATH:\$HOME/flutter/bin\"' >> ~/.zshrc"
    echo ""
    read -p "Запустить автоматическую установку Flutter? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -f "setup_flutter.sh" ]; then
            ./setup_flutter.sh
            # Перезагрузить PATH
            source ~/.zshrc 2>/dev/null || true
        else
            echo "Скрипт setup_flutter.sh не найден"
            exit 1
        fi
    else
        exit 1
    fi
    
    # Проверка еще раз
    if ! command -v flutter &> /dev/null; then
        echo ""
        echo "⚠️  Flutter все еще не найден. Перезапустите терминал и попробуйте снова."
        exit 1
    fi
fi

# Проверка Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode не установлен!"
    echo "Установите Xcode из App Store"
    exit 1
fi

echo "📦 Проверка зависимостей..."
flutter doctor

echo ""
echo "📱 Проверка подключенных устройств..."
DEVICES=$(flutter devices | grep -i "iphone\|ios" || echo "")
if [ -z "$DEVICES" ]; then
    echo "⚠️  iPhone не обнаружен"
    echo ""
    echo "Убедитесь, что:"
    echo "1. iPhone подключен через USB"
    echo "2. На iPhone нажато 'Доверять этому компьютеру'"
    echo "3. На iPhone включен режим разработчика (Настройки > Конфиденциальность > Режим разработчика)"
    echo ""
    read -p "Продолжить установку? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo "📦 Установка зависимостей Flutter..."
flutter pub get

echo ""
echo "🔨 Создание iOS проекта (если не существует)..."
if [ ! -d "ios" ]; then
    echo "Создание iOS платформы..."
    flutter create --platforms=ios .
fi

echo ""
echo "🔧 Настройка для физического устройства..."

# Обновление IP адреса API если нужно
read -p "Использовать IP-адрес для API? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Введите IP-адрес вашего компьютера (например, 192.168.8.108): " IP_ADDRESS
    if [ -n "$IP_ADDRESS" ]; then
        echo "Использование IP: http://$IP_ADDRESS:8000"
        API_URL="http://$IP_ADDRESS:8000"
    fi
fi

echo ""
echo "🚀 Сборка и установка на iPhone..."
echo "Это может занять несколько минут..."

if [ -n "$API_URL" ]; then
    flutter run --dart-define=API_BASE_URL=$API_URL
else
    flutter run
fi

echo ""
echo "✅ Готово!"
echo ""
echo "Если установка не удалась, попробуйте:"
echo "1. Открыть ios/Runner.xcworkspace в Xcode"
echo "2. Выбрать ваше устройство в списке"
echo "3. Нажать Run (▶️)"
