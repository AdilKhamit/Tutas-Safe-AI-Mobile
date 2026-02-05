#!/usr/bin/env bash
# Запуск бэкенда на Mac (не в Docker), чтобы он был доступен по IP с телефона.
# Сначала поднимите только БД и сервисы: docker compose up -d db redis minio minio-init
# Затем запустите этот скрипт из корня проекта: ./scripts/run_backend_local.sh

set -e
cd "$(dirname "$0")/.."

echo "Остановка контейнера backend (освобождаем порт 8000)..."
docker compose stop backend 2>/dev/null || true

echo "Запуск бэкенда на хосте (0.0.0.0:8000) — доступен с телефона по IP Mac..."
# Use DATABASE_URL from backend/.env (Docker db via host IP when Mac has local postgres)
export DATABASE_URL="${DATABASE_URL:-postgresql+asyncpg://postgres:postgres@localhost:5432/tutas_ai}"
export REDIS_URL="${REDIS_URL:-redis://:redis_password@localhost:6379/0}"
export MINIO_ENDPOINT="${MINIO_ENDPOINT:-localhost:9000}"
export MINIO_ACCESS_KEY="${MINIO_ACCESS_KEY:-minioadmin}"
export MINIO_SECRET_KEY="${MINIO_SECRET_KEY:-minioadmin}"
export MINIO_BUCKET_PHOTOS="${MINIO_BUCKET_PHOTOS:-tutas-photos}"
export MINIO_BUCKET_REPORTS="${MINIO_BUCKET_REPORTS:-tutas-reports}"
export MINIO_USE_SSL="${MINIO_USE_SSL:-false}"
export ENVIRONMENT="${ENVIRONMENT:-development}"
export LOG_LEVEL="${LOG_LEVEL:-INFO}"

cd backend
if command -v poetry &>/dev/null; then
  poetry run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
elif command -v uv &>/dev/null; then
  uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
else
  echo ""
  echo "Установите Poetry и зависимости:"
  echo "  pip install poetry"
  echo "  cd backend && poetry install"
  echo "Затем снова: ./scripts/run_backend_local.sh"
  echo ""
  exit 1
fi
