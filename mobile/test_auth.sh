#!/bin/bash
# Скрипт для тестирования аутентификации

echo "🧪 Тестирование аутентификации"
echo "================================"

API_URL="http://localhost:8000"

# Цвета
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Проверка health
echo -e "\n${YELLOW}1. Проверка health endpoint...${NC}"
HEALTH=$(curl -s "$API_URL/health")
if [[ $HEALTH == *"healthy"* ]]; then
    echo -e "${GREEN}✓ Backend работает${NC}"
else
    echo -e "${RED}✗ Backend не отвечает${NC}"
    exit 1
fi

# 2. Регистрация пользователя
echo -e "\n${YELLOW}2. Регистрация пользователя...${NC}"
REGISTER_RESPONSE=$(curl -s -X POST "$API_URL/api/v1/auth/register" \
    -H "Content-Type: application/json" \
    -d '{"email": "test@tutas.ai", "password": "test123456", "full_name": "Test User"}')

if [[ $REGISTER_RESPONSE == *"email"* ]] || [[ $REGISTER_RESPONSE == *"already registered"* ]]; then
    echo -e "${GREEN}✓ Пользователь существует или зарегистрирован${NC}"
    echo "   Response: $REGISTER_RESPONSE"
else
    echo -e "${RED}✗ Ошибка регистрации: $REGISTER_RESPONSE${NC}"
fi

# 3. Вход
echo -e "\n${YELLOW}3. Тестирование входа...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/api/v1/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"email": "test@tutas.ai", "password": "test123456"}')

if [[ $LOGIN_RESPONSE == *"access_token"* ]]; then
    echo -e "${GREEN}✓ Вход успешен${NC}"
    TOKEN=$(echo $LOGIN_RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])" 2>/dev/null)
    if [ ! -z "$TOKEN" ]; then
        echo "   Token получен: ${TOKEN:0:50}..."
    fi
else
    echo -e "${RED}✗ Ошибка входа: $LOGIN_RESPONSE${NC}"
    exit 1
fi

# 4. Проверка /me endpoint
if [ ! -z "$TOKEN" ]; then
    echo -e "\n${YELLOW}4. Проверка /me endpoint...${NC}"
    ME_RESPONSE=$(curl -s -X GET "$API_URL/api/v1/auth/me" \
        -H "Authorization: Bearer $TOKEN")
    
    if [[ $ME_RESPONSE == *"email"* ]]; then
        echo -e "${GREEN}✓ /me endpoint работает${NC}"
        echo "   User: $ME_RESPONSE"
    else
        echo -e "${RED}✗ Ошибка /me: $ME_RESPONSE${NC}"
    fi
fi

echo -e "\n${GREEN}✅ Тестирование завершено!${NC}"
echo -e "\n${YELLOW}Учетные данные для мобильного приложения:${NC}"
echo "   Email: test@tutas.ai"
echo "   Password: test123456"
