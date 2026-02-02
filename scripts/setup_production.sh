#!/bin/bash
# Скрипт для настройки production окружения

set -e

echo "🚀 Настройка Production окружения"
echo "=================================="

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

BACKEND_ENV="backend/.env.production"

echo -e "\n${YELLOW}Создание production конфигурации...${NC}"

# Генерация безопасных ключей
SECRET_KEY=$(generate_secret_key)
JWT_SECRET_KEY=$(generate_secret_key)
API_KEY_1=$(generate_secret_key | cut -c1-32)
API_KEY_2=$(generate_secret_key | cut -c1-32)

cat > "$BACKEND_ENV" << EOF
# Database - ИЗМЕНИТЕ НА ВАШИ ДАННЫЕ!
DATABASE_URL=postgresql+asyncpg://postgres:CHANGE_PASSWORD@localhost:5432/tutas_ai

# Redis - ИЗМЕНИТЕ НА ВАШИ ДАННЫЕ!
REDIS_URL=redis://localhost:6379/0
REDIS_PASSWORD=CHANGE_PASSWORD

# MinIO - ИЗМЕНИТЕ НА ВАШИ ДАННЫЕ!
MINIO_ENDPOINT=your-minio-server.com:9000
MINIO_ACCESS_KEY=CHANGE_ACCESS_KEY
MINIO_SECRET_KEY=CHANGE_SECRET_KEY
MINIO_BUCKET_PHOTOS=tutas-photos
MINIO_BUCKET_REPORTS=tutas-reports
MINIO_USE_SSL=True

# Application
ENVIRONMENT=production
LOG_LEVEL=WARNING

# AI Engine
AI_ENGINE_URL=http://ai-engine:8001
AI_ENGINE_TIMEOUT=30

# Local LLM (Ollama) - отключено в production
OLLAMA_API_URL=http://localhost:11434/api/generate
LLM_MODEL=llama3.2

# Security - СГЕНЕРИРОВАНЫ АВТОМАТИЧЕСКИ
SECRET_KEY=$SECRET_KEY
JWT_SECRET_KEY=$JWT_SECRET_KEY
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30

# API Keys (comma-separated) - СГЕНЕРИРОВАНЫ АВТОМАТИЧЕСКИ
API_KEYS=$API_KEY_1,$API_KEY_2
EOF

echo -e "${GREEN}✓ Production конфигурация создана: $BACKEND_ENV${NC}"
echo ""
echo -e "${YELLOW}⚠️  ВАЖНО:${NC}"
echo "1. Измените DATABASE_URL на ваши production данные"
echo "2. Измените REDIS_URL и REDIS_PASSWORD"
echo "3. Измените MINIO настройки"
echo "4. Сохраните API_KEYS в безопасном месте"
echo "5. НЕ коммитьте этот файл в git!"
echo ""
echo -e "${YELLOW}Для использования в production:${NC}"
echo "export ENV_FILE=backend/.env.production"
echo "или"
echo "ln -sf .env.production backend/.env"
