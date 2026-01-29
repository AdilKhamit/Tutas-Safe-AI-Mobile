#!/bin/bash

# Скрипт для создания manifest.plist для OTA установки
# Использование: ./create_manifest.sh [IPA_URL] [BUNDLE_ID] [VERSION] [TITLE]

set -e

# Параметры
IPA_URL=${1:-"https://your-server.com/tutas_ai_mobile.ipa"}
BUNDLE_ID=${2:-"com.example.tutasAiMobile"}
VERSION=${3:-"1.0.0"}
TITLE=${4:-"Tutas Ai Mobile"}

MANIFEST_FILE="manifest.plist"

cat > "$MANIFEST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>items</key>
    <array>
        <dict>
            <key>assets</key>
            <array>
                <dict>
                    <key>kind</key>
                    <string>software-package</string>
                    <key>url</key>
                    <string>${IPA_URL}</string>
                </dict>
            </array>
            <key>metadata</key>
            <dict>
                <key>bundle-identifier</key>
                <string>${BUNDLE_ID}</string>
                <key>bundle-version</key>
                <string>${VERSION}</string>
                <key>kind</key>
                <string>software</string>
                <key>title</key>
                <string>${TITLE}</string>
            </dict>
        </dict>
    </array>
</dict>
</plist>
EOF

echo "✅ manifest.plist создан!"
echo "📄 Файл: ${MANIFEST_FILE}"
echo ""
echo "🔗 Ссылка для установки:"
echo "itms-services://?action=download-manifest&url=https://your-server.com/${MANIFEST_FILE}"
echo ""
echo "⚠️  Замените 'your-server.com' на ваш реальный сервер!"
