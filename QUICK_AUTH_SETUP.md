# 🚀 Быстрая настройка аутентификации

## Вариант 1: Использование Docker Compose (Рекомендуется)

### 1. Запустите все сервисы

```bash
docker-compose up -d
```

Это автоматически:
- Создаст базу данных PostgreSQL
- Создаст таблицу users
- Запустит backend на порту 8000

### 2. Зарегистрируйте первого пользователя

```bash
# Используя Python скрипт
python3 scripts/register_user.py test@tutas.ai test123456 "Test User"

# Или используя curl
curl -X POST "http://localhost:8000/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email": "test@tutas.ai", "password": "test123456", "full_name": "Test User"}'
```

### 3. Протестируйте вход

```bash
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "test@tutas.ai", "password": "test123456"}'
```

## Вариант 2: Локальная установка

### 1. Настройка базы данных и окружения

```bash
# Запустите скрипт автоматической настройки
./scripts/setup_auth.sh
```

Скрипт автоматически:
- Создаст базу данных `tutas_ai` (если не существует)
- Создаст все необходимые таблицы
- Создаст `.env` файл с безопасными ключами

### 2. Запустите backend

```bash
cd backend
poetry install
poetry run uvicorn app.main:app --reload
```

### 3. Зарегистрируйте пользователя

```bash
# Используя Python скрипт
python3 scripts/register_user.py test@tutas.ai test123456 "Test User"

# Или используя curl
curl -X POST "http://localhost:8000/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email": "test@tutas.ai", "password": "test123456", "full_name": "Test User"}'
```

## Тестирование в мобильном приложении

### 1. Настройте .env файл мобильного приложения

Создайте `mobile/.env`:

```bash
API_BASE_URL=http://your-server-ip:8000
API_KEY=dev-api-key-12345
```

**Важно:** Замените `your-server-ip` на реальный IP адрес вашего сервера. Для эмулятора Android используйте `10.0.2.2`, для iOS симулятора используйте `localhost`.

### 2. Запустите мобильное приложение

```bash
cd mobile
flutter pub get
flutter run
```

### 3. Войдите в приложение

- Email: `test@tutas.ai`
- Password: `test123456`

## Production настройка

### 1. Создайте production конфигурацию

```bash
./scripts/setup_production.sh
```

Это создаст `backend/.env.production` с:
- Безопасными JWT ключами
- Безопасными API ключами
- Production настройками

### 2. Обновите production переменные

Отредактируйте `backend/.env.production` и измените:
- `DATABASE_URL` - на production базу данных
- `REDIS_URL` и `REDIS_PASSWORD` - на production Redis
- `MINIO_*` - на production MinIO настройки
- `ENVIRONMENT=production`

### 3. Используйте production конфигурацию

```bash
# Вариант 1: Символическая ссылка
ln -sf .env.production backend/.env

# Вариант 2: Переменная окружения
export ENV_FILE=backend/.env.production
```

### 4. Настройте HTTPS

Для production рекомендуется использовать:
- **Traefik** (уже настроен в docker-compose.yaml) с Let's Encrypt
- **Nginx** как reverse proxy
- **Cloudflare** для SSL

Обновите `docker-compose.yaml`:
- Установите `DOMAIN=your-domain.com`
- Установите `ACME_EMAIL=your-email@example.com`
- Traefik автоматически получит SSL сертификаты

## Проверка работы

### 1. Проверьте API документацию

Откройте в браузере: `http://localhost:8000/docs`

### 2. Проверьте health endpoint

```bash
curl http://localhost:8000/health
```

### 3. Проверьте аутентификацию

```bash
# Регистрация
curl -X POST "http://localhost:8000/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email": "test@tutas.ai", "password": "test123456", "full_name": "Test User"}'

# Вход
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "test@tutas.ai", "password": "test123456"}'

# Получение информации о пользователе (нужен токен)
curl -X GET "http://localhost:8000/api/v1/auth/me" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Troubleshooting

### База данных не создается

```bash
# Проверьте, что PostgreSQL запущен
psql --version

# Создайте базу данных вручную
createdb tutas_ai

# Запустите скрипт создания таблиц
psql -d tutas_ai -f scripts/create_tables_simple.sql
```

### Backend не запускается

```bash
# Проверьте зависимости
cd backend
poetry install

# Проверьте .env файл
cat .env

# Запустите с отладкой
poetry run uvicorn app.main:app --reload --log-level debug
```

### Мобильное приложение не подключается

1. Проверьте, что backend доступен по указанному IP
2. Проверьте firewall настройки
3. Для Android эмулятора используйте `10.0.2.2` вместо `localhost`
4. Для iOS симулятора используйте `localhost` или `127.0.0.1`

## Дополнительная информация

Подробная документация: [AUTHENTICATION_SETUP.md](./AUTHENTICATION_SETUP.md)
