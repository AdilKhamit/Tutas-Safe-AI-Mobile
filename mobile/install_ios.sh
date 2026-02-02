#!/bin/bash
# Скрипт для установки приложения на iPhone

set -e

echo "📱 Установка Tutas AI Mobile на iPhone"
echo "======================================"

# Цвета
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Проверка Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Flutter не установлен${NC}"
    exit 1
fi

echo -e "\n${YELLOW}1. Проверка подключенных устройств...${NC}"
DEVICES=$(flutter devices | grep "ios" | grep -v "macos" | head -1)

if [ -z "$DEVICES" ]; then
    echo -e "${RED}✗ iPhone не подключен${NC}"
    echo "Подключите iPhone через USB и доверьте этому компьютеру"
    exit 1
fi

DEVICE_ID=$(echo "$DEVICES" | awk '{print $5}')
DEVICE_NAME=$(echo "$DEVICES" | awk '{print $1, $2, $3, $4}')

echo -e "${GREEN}✓ Найдено устройство: $DEVICE_NAME${NC}"
echo -e "${GREEN}✓ Device ID: $DEVICE_ID${NC}"

# Проверка .env файла
echo -e "\n${YELLOW}2. Проверка конфигурации...${NC}"
if [ ! -f .env ]; then
    echo -e "${YELLOW}Создание .env файла...${NC}"
    
    # Получение IP адреса
    IP_ADDRESS=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')
    
    if [ -z "$IP_ADDRESS" ]; then
        IP_ADDRESS="localhost"
    fi
    
    cat > .env << EOF
API_BASE_URL=http://$IP_ADDRESS:8000
API_KEY=dev-api-key-12345
EOF
    echo -e "${GREEN}✓ Создан .env файл с IP: $IP_ADDRESS${NC}"
else
    echo -e "${GREEN}✓ .env файл существует${NC}"
fi

# Установка зависимостей
echo -e "\n${YELLOW}3. Установка зависимостей...${NC}"
flutter pub get

# Очистка
echo -e "\n${YELLOW}4. Очистка проекта...${NC}"
flutter clean

# Сборка и установка
echo -e "\n${YELLOW}5. Сборка и установка на iPhone...${NC}"
echo -e "${YELLOW}Это может занять несколько минут...${NC}"

flutter run -d "$DEVICE_ID" --release

echo -e "\n${GREEN}✅ Установка завершена!${NC}"
echo -e "\n${YELLOW}Следующие шаги:${NC}"
echo "1. На iPhone: Settings > General > VPN & Device Management"
echo "2. Найдите приложение и нажмите 'Trust'"
echo "3. Откройте приложение и войдите:"
echo "   Email: test@tutas.ai"
echo "   Password: test123456"
