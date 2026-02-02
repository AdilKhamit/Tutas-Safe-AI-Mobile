# 🔐 Настройка аутентификации

## Обзор

Система аутентификации использует JWT (JSON Web Tokens) для безопасной аутентификации пользователей. Backend предоставляет endpoints для регистрации, входа, выхода и обновления токенов.

## Backend Setup

### 1. Создание таблицы users

Выполните SQL скрипт для создания таблицы users:

```bash
# Используя psql
psql -d tutas_ai -f scripts/create_users_table.sql

# Или используйте обновленный скрипт со всеми таблицами
psql -d tutas_ai -f scripts/create_tables_simple.sql
```

### 2. Настройка переменных окружения

Убедитесь, что в `.env` файле backend установлены следующие переменные:

```bash
# JWT настройки
JWT_SECRET_KEY=your-secret-key-here-change-in-production
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30

# База данных
DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost:5432/tutas_ai
```

### 3. Генерация секретного ключа

Для production сгенерируйте безопасный секретный ключ:

```bash
# Python
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# OpenSSL
openssl rand -hex 32
```

### 4. API Endpoints

После запуска backend доступны следующие endpoints:

- `POST /api/v1/auth/register` - Регистрация нового пользователя
- `POST /api/v1/auth/login` - Вход и получение токенов
- `POST /api/v1/auth/logout` - Выход (клиент должен удалить токены)
- `POST /api/v1/auth/refresh` - Обновление access token
- `GET /api/v1/auth/me` - Получение информации о текущем пользователе

## Mobile App Setup

### 1. Конфигурация

Убедитесь, что в `mobile/.env` указан правильный URL API:

```bash
API_BASE_URL=http://your-server-ip:8000
API_KEY=dev-api-key-12345  # Опционально, для development
```

### 2. Использование

Приложение автоматически:
- Проверяет наличие сохраненного токена при запуске
- Перенаправляет на экран логина, если пользователь не аутентифицирован
- Добавляет токен в заголовки всех API запросов
- Обновляет токен при истечении срока действия

### 3. Регистрация пользователя

Для создания первого пользователя используйте API:

```bash
curl -X POST "http://localhost:8000/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "securepassword123",
    "full_name": "John Doe"
  }'
```

Или используйте Swagger UI: `http://localhost:8000/docs`

## Тестирование

### 1. Регистрация

```bash
curl -X POST "http://localhost:8000/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@tutas.ai",
    "password": "test123456",
    "full_name": "Test User"
  }'
```

### 2. Вход

```bash
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@tutas.ai",
    "password": "test123456"
  }'
```

Ответ:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

### 3. Использование токена

```bash
curl -X GET "http://localhost:8000/api/v1/auth/me" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 4. Обновление токена

```bash
curl -X POST "http://localhost:8000/api/v1/auth/refresh" \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "YOUR_REFRESH_TOKEN"
  }'
```

## Безопасность

### Production Checklist

- [ ] Измените `JWT_SECRET_KEY` на безопасный случайный ключ
- [ ] Установите `ENVIRONMENT=production` в `.env`
- [ ] Настройте HTTPS/TLS для API
- [ ] Ограничьте CORS origins в `main.py`
- [ ] Настройте rate limiting для auth endpoints
- [ ] Регулярно обновляйте зависимости
- [ ] Используйте сильные пароли (минимум 8 символов)
- [ ] Реализуйте блокировку аккаунта после нескольких неудачных попыток входа

## Troubleshooting

### Ошибка "Could not validate credentials"

- Проверьте, что токен не истек
- Убедитесь, что `JWT_SECRET_KEY` одинаковый на всех серверах
- Проверьте формат заголовка: `Authorization: Bearer <token>`

### Ошибка "User not found"

- Убедитесь, что пользователь зарегистрирован
- Проверьте email в базе данных

### Ошибка "Incorrect email or password"

- Проверьте правильность email и пароля
- Убедитесь, что пользователь активен (`is_active = true`)

## Дополнительные функции

### Биометрическая аутентификация

Мобильное приложение поддерживает биометрическую аутентификацию (отпечаток пальца/Face ID) для быстрого входа после первоначальной аутентификации.

### Автоматическое обновление токена

Приложение автоматически обновляет access token при истечении срока действия, используя refresh token.

### Offline режим

Приложение сохраняет токены в безопасном хранилище (`flutter_secure_storage`) и может работать в offline режиме с кэшированными данными.
