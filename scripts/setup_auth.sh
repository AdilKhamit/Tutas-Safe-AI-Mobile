#!/bin/bash
# Скрипт для настройки аутентификации

set -e

echo "🔐 Настройка системы аутентификации Tutas AI"
echo "=============================================="

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Функция для генерации безопасного ключа
generate_secret_key() {
    python3 -c "import secrets; print(secrets.token_urlsafe(32))" 2>/dev/null || \
    openssl rand -hex 32
}

# 1. Создание базы данных (если не существует)
echo -e "\n${YELLOW}1. Проверка базы данных...${NC}"
if psql -lqt | cut -d \| -f 1 | grep -qw tutas_ai; then
    echo -e "${GREEN}✓ База данных tutas_ai существует${NC}"
else
    echo -e "${YELLOW}Создание базы данных tutas_ai...${NC}"
    createdb tutas_ai || {
        echo -e "${RED}✗ Ошибка создания базы данных. Убедитесь, что PostgreSQL запущен.${NC}"
        exit 1
    }
    echo -e "${GREEN}✓ База данных создана${NC}"
fi

# 2. Создание таблиц
echo -e "\n${YELLOW}2. Создание таблиц...${NC}"
if psql -d tutas_ai -f scripts/create_tables_simple.sql > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Таблицы созданы успешно${NC}"
else
    echo -e "${RED}✗ Ошибка создания таблиц${NC}"
    exit 1
fi

# 3. Создание .env файла для backend (если не существует)
echo -e "\n${YELLOW}3. Настройка переменных окружения...${NC}"
BACKEND_ENV="backend/.env"
if [ -f "$BACKEND_ENV" ]; then
    echo -e "${YELLOW}Файл $BACKEND_ENV уже существует. Пропускаем...${NC}"
else
    echo -e "${YELLOW}Создание $BACKEND_ENV...${NC}"
    
    # Генерация безопасных ключей
    SECRET_KEY=$(generate_secret_key)
    JWT_SECRET_KEY=$(generate_secret_key)
    
    cat > "$BACKEND_ENV" << EOF
# Database
DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost:5432/tutas_ai

# Redis
REDIS_URL=redis://localhost:6379/0

# MinIO
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET_PHOTOS=tutas-photos
MINIO_BUCKET_REPORTS=tutas-reports
MINIO_USE_SSL=False

# Application
ENVIRONMENT=development
LOG_LEVEL=INFO

# AI Engine
AI_ENGINE_URL=http://ai-engine:8001
AI_ENGINE_TIMEOUT=30

# Local LLM (Ollama)
OLLAMA_API_URL=http://localhost:11434/api/generate
LLM_MODEL=llama3.2

# Security - IMPORTANT: Change in production!
SECRET_KEY=$SECRET_KEY
JWT_SECRET_KEY=$JWT_SECRET_KEY
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30

# API Keys (comma-separated)
API_KEYS=dev-api-key-12345
EOF
    echo -e "${GREEN}✓ Файл $BACKEND_ENV создан${NC}"
fi

# 4. Регистрация тестового пользователя
echo -e "\n${YELLOW}4. Регистрация тестового пользователя...${NC}"
echo -e "${YELLOW}Запустите backend сервер и выполните:${NC}"
echo ""
echo "curl -X POST \"http://localhost:8000/api/v1/auth/register\" \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -d '{\"email\": \"test@tutas.ai\", \"password\": \"test123456\", \"full_name\": \"Test User\"}'"
echo ""
echo -e "${GREEN}✓ Настройка завершена!${NC}"
echo ""
echo -e "${YELLOW}Следующие шаги:${NC}"
echo "1. Запустите backend: cd backend && poetry run uvicorn app.main:app --reload"
echo "2. Зарегистрируйте пользователя (команда выше)"
echo "3. Протестируйте в мобильном приложении"
