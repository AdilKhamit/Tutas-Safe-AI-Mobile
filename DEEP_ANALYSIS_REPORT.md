# Глубокий анализ проекта Tutas Ai

**Дата:** 2025-02-05  
**Цель:** Выявить все критические проблемы, риски и рекомендации перед исправлениями.

---

## 1. Обзор архитектуры

| Компонент    | Стек              | Назначение                          |
|-------------|-------------------|-------------------------------------|
| Backend     | FastAPI, PostgreSQL, Redis, MinIO | API, аутентификация, трубы, инспекции, отчёты |
| Frontend    | React, Vite, Ant Design, Redux RTK | Веб-дашборд, админка                 |
| Mobile      | Flutter, Riverpod, Drift, GoRouter | Мобильное приложение (iOS/Android)  |
| AI Engine   | FastAPI, ML (TFLite и др.)        | Предикции, ML-модели                 |
| Инфра       | Docker Compose, Traefik           | Оркестрация, reverse proxy           |

---

## 2. Backend

### 2.1 Уже исправлено в сессии
- **email-validator:** Добавлен `pydantic = {extras = ["email"], ...}` в `pyproject.toml` — иначе падение при импорте `EmailStr` в схемах auth.

### 2.2 Конфигурация и безопасность
- **JWT / секреты:** В `core/config.py` дефолты `SECRET_KEY` и `JWT_SECRET_KEY` — "change-this-in-production". В production обязательно задавать через env (документация есть в AUTHENTICATION_SETUP.md, QUICK_AUTH_SETUP.md).
- **API Key middleware:** В development режиме (`ENVIRONMENT=development`) проверка API key отключена — корректно для локальной разработки.
- **CORS:** `allow_origins=["*"]` — для production нужно ограничить домены.

### 2.3 База данных
- **init.sql:** Таблица `users` создаётся в init. Триггер использует `EXECUTE FUNCTION` (PostgreSQL 11+); образ postgis:16 поддерживает.
- **Миграции:** Используется Alembic; создание таблиц также дублируется в `create_tables_simple.sql` и скриптах seed — стоит держать одну точку истины (Alembic или init+скрипты).
- **Регистрация пользователя:** Эндпоинт `POST /api/v1/auth/register` есть; скрипт `scripts/register_user.py` вызывает его (localhost:8000). Для мобильного теста пользователь должен быть создан до входа.

### 2.4 Зависимости
- **pyproject.toml:** Зависимости выглядят консистентно; после добавления `pydantic[email]` сборка backend в Docker проходит.

---

## 3. Frontend

### 3.1 Критично: сборка Docker падает
При `docker compose up -d` (или `docker compose build frontend`) этап `npm run build` выполняет **`tsc && vite build`**. В `tsconfig.json` в компиляцию попадает **весь каталог `src`**, включая:
- `src/pages/__tests__/AdminPanel.test.tsx`
- `src/store/api/__tests__/qrCodeApi.test.ts`
- `src/test/setup.ts`
- и др.

Итог:
1. **Типы для Vite env:** В `tutasApi.ts` используется `import.meta.env.VITE_API_KEY` и `import.meta.env.DEV`. Типы для `import.meta.env` в TypeScript не объявлены — нет `vite-env.d.ts` (или аналога), из-за чего возможны ошибки типов в строгом режиме.
2. **Тесты в production-сборке:** В тестах используются `global`, типы Redux/Thunk не совпадают с текущей версией RTK, есть неиспользуемые переменные — при компиляции `src` целиком это даёт множество TS-ошибок (TS6133, TS7053, TS2339, TS2304, TS2418, TS2719, TS2345).
3. **Строгий линтинг:** Включены `noUnusedLocals` и `noUnusedParameters` — в компонентах (DefectTrendChart, MapWidget, PipeDigitalTwin, RecentInspectionsTable, Dashboard и др.) остались неиспользуемые импорты/параметры (LineChart, AreaChart, Marker, diameter, CheckCircleOutlined, List, Avatar, FireOutlined и т.д.), что тоже ломает `tsc`.

Итог: **полный `docker compose up -d` невозможен** из-за падения сборки frontend. Для работы только мобильного приложения достаточно backend (мы уже запускали только db, redis, minio, backend).

### 3.2 Рекомендации по фронтенду
- Исключить тесты и test-утилиты из production-сборки: в `tsconfig.json` задать `"exclude": ["**/__tests__/**", "**/test/**"]` или завести отдельный `tsconfig.build.json` с таким exclude и использовать его в `npm run build`.
- Добавить `src/vite-env.d.ts` с объявлением типов для `import.meta.env` (VITE_* и т.д.).
- Либо исправить неиспользуемые импорты/параметры в компонентах, либо временно ослабить правила только для build (не рекомендуется долгосрочно).
- Типы в тестах (AdminPanel.test, qrCodeApi.test) и использование `global` привести в соответствие с текущим RTK/Vitest или не компилировать тесты в production.

---

## 4. Mobile

### 4.1 Уже исправлено в сессии
- Таймауты в AuthService (connect/receive) — логин не зависает.
- Обработка ответа логина (проверка формата, access_token).
- NSAppTransportSecurity в iOS Info.plist — разрешён HTTP к backend IP.
- Кнопка «Проверить сервер» и увеличенный таймаут проверки (10/15 с).
- Подсказки в README и в сообщениях об ошибках.

### 4.2 Конфигурация
- **.env:** В `pubspec.yaml` в assets указан `.env`; путь корректен (mobile/.env). Переменная `API_BASE_URL` должна указывать на IP хоста при запуске на устройстве (не localhost).
- **AppConfig:** Загружается в `main()` до `runApp` — порядок правильный.

### 4.3 Чужеродные файлы в репозитории
- В `mobile/lib/data/api/` и, возможно, в `mobile/lib/data/local/`, `mobile/lib/repositories/` присутствуют файлы **`__init__.py`** (Python). В Flutter-проекте они не используются и могут вводить в заблуждение или попадать в линтеры; их лучше удалить.

### 4.4 Роутинг и авторизация
- GoRouter с `refreshListenable: authRefreshNotifier` — при смене auth состояние redirect пересчитывается; после успешного логина переход на `/home` корректен.
- Onboarding и логин работают по сценарию: onboarding → login → home.

---

## 5. Docker и оркестрация

### 5.1 Текущее поведение
- **Полный старт:** `docker compose up -d` падает на этапе сборки frontend (см. раздел 3).
- **Только backend-стек:** `docker compose up -d db redis minio minio-init backend` — успешно после исправления email-validator. Backend слушает на `0.0.0.0:8000`, порт проброшен на хост.

### 5.2 Зависимости между сервисами
- backend зависит от db, redis, minio (healthcheck).
- frontend зависит только от backend (для сборки не нужен живой backend).
- traefik, ai-engine, frontend не обязательны для мобильного входа.

### 5.3 Makefile
- `make up` вызывает `docker-compose up -d` — будет падать из-за frontend. Имеет смысл добавить цель только для backend (например `up-backend`) или документировать запуск без frontend.

---

## 6. Скрипты и окружение

### 6.1 register_user.py
- Вызов: `python scripts/register_user.py <email> <password> [full_name]`.
- Обращается к `http://localhost:8000` — при запущенном backend на хосте работает. Для создания тестового пользователя (например test@tutas.ai) скрипт подходит.

### 6.2 CI (.github/workflows/ci.yml)
- **Frontend Build:** Выполняет `npm run build` в frontend — при текущем состоянии (тесты в компиляции, отсутствие vite-env.d.ts, неиспользуемые импорты) job **будет падать**.
- Backend CI использует Poetry; кэш завязан на `backend/poetry.lock` — в репозитории может быть `pyproject.toml` без lock в корне backend; нужно убедиться, что lock есть и обновлён после добавления pydantic[email].
- Docker build шаги помечены `continue-on-error: true` — падение сборки frontend не роняет весь пайплайн, но скрывает проблему.

---

## 7. Сводка приоритетов

| Приоритет | Проблема | Где | Действие |
|-----------|----------|-----|----------|
| Критично  | Frontend не собирается в Docker (tsc + тесты + import.meta.env + неиспользуемые импорты) | frontend/ | Исключить тесты из build, добавить vite-env.d.ts, исправить или исключить неиспользуемые импорты/типы |
| Критично  | Полный `docker compose up` невозможен | docker-compose, Makefile | Либо починить frontend, либо добавить профиль/цель «только backend» и документировать |
| Высокий   | CI frontend-build падает по тем же причинам | .github/workflows/ci.yml | Те же правки, что и для Docker; убрать continue-on-error с frontend build при желании строгого CI |
| Средний   | Чужеродные __init__.py в mobile (Dart) | mobile/lib | Удалить лишние .py файлы |
| Низкий    | JWT/SECRET в production только через env | backend, docs | Уже описано в AUTHENTICATION_SETUP; при деплое проверять env |
| Низкий    | CORS и API key для production | backend | Ограничить origins и настроить API_KEYS по документации |

---

## 8. Рекомендуемый порядок исправлений

1. **Frontend (сборка):**
   - Добавить `src/vite-env.d.ts` с типами для `import.meta.env`.
   - В tsconfig для build исключить `**/__tests__/**`, `**/test/**` (или отдельный tsconfig.build.json).
   - Убрать неиспользуемые импорты/параметры в компонентах и страницах, упомянутых в логе сборки (или временно ослабить noUnusedLocals/noUnusedParameters только для build — менее желательно).
   - При необходимости поправить типы в тестах или оставить их только для `vitest` (не для `tsc`).

2. **Docker/Makefile:**
   - Добавить способ запуска только backend-стека (профиль или отдельная цель), описать в README.

3. **Mobile:**
   - Удалить `__init__.py` из `mobile/lib/data/api/` (и при наличии — из других Dart-папок).

4. **CI:**
   - После исправления frontend убрать `continue-on-error` с шага frontend build (по желанию), чтобы падение сборки было видно.

После этого можно выполнять исправления по пунктам 1–4.

---

## 9. Исправления, внесённые после анализа (2025-02-05)

1. **Frontend — сборка**
   - Добавлен `frontend/src/vite-env.d.ts` с типами для `import.meta.env`.
   - Добавлен `frontend/tsconfig.build.json` с исключением `**/__tests__/**`, `**/test/**`, `**/*.test.ts`, `**/*.test.tsx`; в `package.json` скрипт build изменён на `tsc -p tsconfig.build.json && vite build`.
   - Убраны неиспользуемые импорты/переменные: DefectTrendChart (LineChart, AreaChart, data), MapWidget (Marker, приведение типов для path[0]/path[1]), PipeDigitalTwin (diameter), RecentInspectionsTable (CheckCircleOutlined, WarningOutlined), Dashboard (List, Avatar, FireOutlined, параметр i).

2. **Makefile**
   - Добавлена цель `up-backend` для запуска только db, redis, minio, minio-init, backend (для разработки мобильного приложения).

3. **Mobile**
   - Удалены лишние файлы `__init__.py` из `mobile/lib/data/api/`, `data/local/`, `data/models/`, `repositories/`.

В результате `npm run build` во frontend выполняется успешно; полный `docker compose up -d` теперь должен проходить (включая сборку frontend).
