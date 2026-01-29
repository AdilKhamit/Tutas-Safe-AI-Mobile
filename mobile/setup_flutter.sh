#!/bin/bash

# Скрипт для установки Flutter на macOS

set -e

echo "📦 Установка Flutter для iOS разработки"
echo ""

# Проверка macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Этот скрипт предназначен для macOS"
    exit 1
fi

# Проверка Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "⚠️  Xcode не установлен!"
    echo ""
    echo "Для iOS разработки необходим Xcode:"
    echo "1. Откройте App Store"
    echo "2. Найдите 'Xcode'"
    echo "3. Установите Xcode (это займет время, ~12GB)"
    echo "4. После установки выполните: sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
    echo ""
    read -p "Продолжить установку Flutter? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Проверка Homebrew
if ! command -v brew &> /dev/null; then
    echo "📦 Установка Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo ""
echo "Выберите способ установки Flutter:"
echo "1) Через Homebrew (рекомендуется, быстрее)"
echo "2) Ручная установка (скачать и распаковать)"
read -p "Ваш выбор (1 или 2): " choice

if [ "$choice" == "1" ]; then
    echo ""
    echo "📦 Установка Flutter через Homebrew..."
    brew install --cask flutter
    
    # Flutter будет в /opt/homebrew/bin/flutter или /usr/local/bin/flutter
    FLUTTER_PATH=$(which flutter 2>/dev/null || echo "")
    
    if [ -z "$FLUTTER_PATH" ]; then
        # Попробуем добавить в PATH
        if [ -f "/opt/homebrew/bin/flutter" ]; then
            FLUTTER_PATH="/opt/homebrew/bin/flutter"
            echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
        elif [ -f "/usr/local/bin/flutter" ]; then
            FLUTTER_PATH="/usr/local/bin/flutter"
        fi
    fi
    
else
    echo ""
    echo "📥 Ручная установка Flutter..."
    
    FLUTTER_DIR="$HOME/flutter"
    
    if [ -d "$FLUTTER_DIR" ]; then
        echo "⚠️  Flutter уже установлен в $FLUTTER_DIR"
        read -p "Переустановить? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$FLUTTER_DIR"
        else
            FLUTTER_PATH="$FLUTTER_DIR/bin/flutter"
        fi
    fi
    
    if [ ! -d "$FLUTTER_DIR" ]; then
        echo "Скачивание Flutter SDK..."
        cd "$HOME"
        git clone https://github.com/flutter/flutter.git -b stable
        
        FLUTTER_PATH="$FLUTTER_DIR/bin/flutter"
        
        # Добавить в PATH
        if ! grep -q "flutter/bin" ~/.zshrc 2>/dev/null; then
            echo '' >> ~/.zshrc
            echo '# Flutter' >> ~/.zshrc
            echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.zshrc
        fi
    fi
fi

echo ""
echo "✅ Flutter установлен!"
echo ""

# Добавить в текущую сессию
if [ -n "$FLUTTER_PATH" ]; then
    export PATH="$(dirname $FLUTTER_PATH):$PATH"
fi

# Проверка установки
if command -v flutter &> /dev/null; then
    echo "🔍 Проверка установки Flutter..."
    flutter --version
    
    echo ""
    echo "🔧 Настройка Flutter для iOS..."
    flutter doctor
    
    echo ""
    echo "✅ Готово!"
    echo ""
    echo "⚠️  Важно: Перезапустите терминал или выполните:"
    echo "   source ~/.zshrc"
    echo ""
    echo "Затем запустите: ./install_ios.sh"
else
    echo "❌ Flutter не найден после установки"
    echo "Попробуйте перезапустить терминал или выполните:"
    echo "   source ~/.zshrc"
    echo "   flutter --version"
fi
