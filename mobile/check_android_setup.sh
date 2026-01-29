#!/bin/bash
echo "🔍 Проверка настройки Android..."

# Проверка SDK
if [ -d "$HOME/Library/Android/sdk" ]; then
    echo "✅ Android SDK найден"
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"
    
    # Проверка эмуляторов
    if command -v emulator &> /dev/null; then
        echo "✅ Emulator найден"
        echo ""
        echo "Доступные эмуляторы:"
        emulator -list-avds
    else
        echo "⚠️  Emulator не найден, но SDK установлен"
    fi
else
    echo "❌ Android SDK не найден"
    echo "   Запустите Android Studio и выполните Standard установку"
fi

echo ""
echo "Проверка Flutter:"
flutter doctor | grep -A 3 "Android"
