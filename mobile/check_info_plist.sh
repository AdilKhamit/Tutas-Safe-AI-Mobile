#!/bin/bash

# Скрипт для проверки Info.plist в собранном приложении

echo "🔍 Проверка Info.plist в собранном приложении..."
echo ""

# Путь к собранному приложению
APP_PATH="build/ios/iphoneos/Runner.app/Info.plist"

if [ ! -f "$APP_PATH" ]; then
    echo "❌ Приложение не собрано. Сначала выполните:"
    echo "   flutter build ios --debug"
    echo ""
    echo "Или проверьте исходный Info.plist:"
    echo "   cat ios/Runner/Info.plist | grep -A 1 NSCameraUsageDescription"
    exit 1
fi

echo "✅ Найден Info.plist в собранном приложении"
echo ""
echo "📋 Проверка NSCameraUsageDescription:"
echo ""

if plutil -p "$APP_PATH" | grep -i "NSCameraUsageDescription" > /dev/null; then
    echo "✅ NSCameraUsageDescription найден!"
    echo ""
    echo "Содержимое:"
    plutil -p "$APP_PATH" | grep -A 1 "NSCameraUsageDescription"
    echo ""
    echo "✅ Info.plist правильно настроен!"
else
    echo "❌ NSCameraUsageDescription НЕ найден в собранном приложении!"
    echo ""
    echo "Проверьте исходный файл:"
    cat ios/Runner/Info.plist | grep -A 1 NSCameraUsageDescription
    echo ""
    echo "Возможно нужно пересобрать приложение:"
    echo "   flutter clean"
    echo "   flutter build ios --debug"
    exit 1
fi

echo ""
echo "📋 Все разрешения в Info.plist:"
plutil -p "$APP_PATH" | grep -E "(NSCamera|NSMicrophone|NSPhoto)" | head -10
