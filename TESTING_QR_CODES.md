# Полное тестирование QR-кодов

Этот документ описывает полный набор тестов для функциональности QR-кодов в системе Tutas AI.

## 📋 Содержание

1. [Обзор тестов](#обзор-тестов)
2. [Быстрый старт](#быстрый-старт)
3. [Детальное описание тестов](#детальное-описание-тестов)
4. [Запуск тестов](#запуск-тестов)
5. [Устранение неполадок](#устранение-неполадок)

---

## Обзор тестов

### ✅ Что тестируется

1. **Генерация QR-кодов**
   - Создание QR-кодов в правильном формате
   - Сохранение QR-кодов как изображений
   - Валидация формата QR-кодов

2. **Backend API**
   - GET `/api/v1/pipes/qr/{qr_code}` - Получение трубы по QR-коду
   - GET `/api/v1/pipes/qr-code/{qr_code}/image` - Генерация изображения QR-кода
   - GET `/api/v1/pipes/{pipe_id}/qr-code` - Получение QR-кода по ID трубы
   - POST `/api/v1/pipes` - Создание трубы с QR-кодом

3. **Валидация формата**
   - Проверка формата `PL-{COMPANY}-{UUID}`
   - Извлечение названия компании
   - Извлечение UUID

4. **Интеграционные тесты**
   - Полный flow сканирования QR-кода
   - Создание трубы → Сканирование → Получение данных

5. **Мобильное приложение**
   - Валидация формата QR-кодов
   - Извлечение данных из QR-кода
   - Структура QR-кода

---

## Быстрый старт

### 1. Запуск всех тестов одной командой

```bash
# Из корня проекта
./scripts/run_all_qr_tests.sh
```

### 2. Запуск Python интеграционных тестов

```bash
# Убедитесь, что backend запущен
make up

# Запустите тесты
python3 scripts/test_qr_codes.py
```

### 3. Запуск Backend API тестов

```bash
cd backend
pytest tests/ -v
```

### 4. Запуск мобильных тестов

```bash
cd mobile
flutter test integration_test/qr_scan_flow_test.dart
```

---

## Детальное описание тестов

### 1. Тесты генерации QR-кодов

**Файл:** `scripts/generate_qr.py`

**Что тестируется:**
- Генерация QR-кода в формате `PL-{COMPANY}-{UUID}`
- Создание PNG изображения
- Сохранение файла в директорию `qr_codes/`

**Запуск:**
```bash
python3 scripts/generate_qr.py TEST
```

**Ожидаемый результат:**
- QR-код в формате `PL-TEST-{uuid}`
- Файл `qr_codes/qr_TEST_{uuid}.png` создан

---

### 2. Backend API тесты

**Файлы:**
- `backend/tests/test_qr_code_api.py` - API endpoint тесты
- `backend/tests/test_qr_code_validation.py` - Валидация формата

#### Тесты API endpoints

**GET `/api/v1/pipes/qr/{qr_code}`**
- ✅ Успешное получение трубы по QR-коду
- ✅ Возврат mock данных для несуществующих QR-кодов
- ✅ Валидация формата QR-кода
- ✅ Извлечение названия компании

**GET `/api/v1/pipes/qr-code/{qr_code}/image`**
- ✅ Генерация PNG изображения QR-кода
- ✅ Кастомный размер изображения
- ✅ Правильный Content-Type

**GET `/api/v1/pipes/{pipe_id}/qr-code`**
- ✅ Получение QR-кода по ID трубы
- ✅ Обработка несуществующей трубы (404)

**POST `/api/v1/pipes`**
- ✅ Создание трубы с автогенерацией QR-кода
- ✅ Создание трубы с кастомным QR-кодом

#### Тесты валидации

**Формат QR-кода:**
- ✅ Валидные форматы: `PL-COMPANY-UUID`
- ✅ Невалидные форматы отклоняются
- ✅ Извлечение названия компании
- ✅ Извлечение UUID

**Запуск:**
```bash
cd backend
pytest tests/test_qr_code_api.py -v
pytest tests/test_qr_code_validation.py -v
```

---

### 3. Python интеграционные тесты

**Файл:** `scripts/test_qr_codes.py`

**Что тестируется:**
1. Генерация QR-кодов
2. Валидация формата
3. Проверка здоровья backend
4. GET pipe by QR code
5. Создание трубы с QR-кодом
6. Генерация изображения QR-кода
7. Полный flow сканирования

**Запуск:**
```bash
# С backend
python3 scripts/test_qr_codes.py --api-url http://localhost:8000

# Без backend (только валидация)
python3 scripts/test_qr_codes.py
```

**Пример вывода:**
```
============================================================
QR CODE COMPREHENSIVE TEST SUITE
============================================================

TEST 1: QR Code Generation
✅ PASS: QR Code Generation
   Generated: PL-TEST-123e4567-e89b-12d3-a456-426614174000

TEST 2: QR Code Format Validation
✅ PASS: Valid QR: PL-COMPANY-123e4567-e89b-12d3...
...

TEST SUMMARY
============================================================
✅ Passed: 15
❌ Failed: 0
📊 Total:  15
============================================================

🎉 All tests passed!
```

---

### 4. Мобильные интеграционные тесты

**Файл:** `mobile/integration_test/qr_scan_flow_test.dart`

**Что тестируется:**
- Запуск приложения
- Валидация формата QR-кодов
- Извлечение названия компании
- Валидация структуры QR-кода
- Обработка UUID формата

**Запуск:**
```bash
cd mobile
flutter test integration_test/qr_scan_flow_test.dart
```

**Примечание:** Полное тестирование сканирования QR-кодов с камерой требует:
- Физическое устройство или эмулятор с доступом к камере
- Разрешения камеры
- Тестовые QR-коды

---

## Запуск тестов

### Вариант 1: Все тесты одной командой

```bash
./scripts/run_all_qr_tests.sh
```

Этот скрипт:
1. Проверяет статус backend
2. Тестирует генерацию QR-кодов
3. Запускает backend API тесты (если доступны)
4. Запускает Python интеграционные тесты
5. Запускает мобильные тесты (если доступны)

### Вариант 2: Пошаговый запуск

#### Шаг 1: Запустите backend

```bash
make up
# или
docker-compose up -d
```

#### Шаг 2: Запустите Python тесты

```bash
python3 scripts/test_qr_codes.py
```

#### Шаг 3: Запустите Backend API тесты

```bash
cd backend
pytest tests/ -v
```

#### Шаг 4: Запустите мобильные тесты

```bash
cd mobile
flutter test integration_test/qr_scan_flow_test.dart
```

---

## Устранение неполадок

### Backend не запущен

**Проблема:** `Connection refused` или `Cannot connect to backend`

**Решение:**
```bash
# Запустите backend
make up

# Проверьте статус
curl http://localhost:8000/health
```

### pytest не найден

**Проблема:** `pytest: command not found`

**Решение:**
```bash
cd backend
poetry install --with dev
# или
pip install pytest pytest-asyncio httpx
```

### Flutter не найден

**Проблема:** `flutter: command not found`

**Решение:**
- Установите Flutter SDK
- Добавьте в PATH
- Или пропустите мобильные тесты (они опциональны)

### Ошибки в тестах

**Проблема:** Тесты падают с ошибками

**Решение:**
1. Проверьте, что все зависимости установлены
2. Убедитесь, что backend запущен
3. Проверьте логи:
   ```bash
   docker-compose logs backend
   ```

### Проблемы с базой данных в тестах

**Проблема:** Ошибки подключения к БД в тестах

**Решение:**
- Backend тесты используют in-memory SQLite
- Убедитесь, что `aiosqlite` установлен:
  ```bash
  pip install aiosqlite
  ```

---

## Структура тестов

```
.
├── backend/
│   └── tests/
│       ├── __init__.py
│       ├── conftest.py              # Pytest fixtures
│       ├── test_qr_code_api.py      # API endpoint тесты
│       ├── test_qr_code_validation.py # Валидация формата
│       └── README.md
├── mobile/
│   └── integration_test/
│       └── qr_scan_flow_test.dart   # Мобильные тесты
├── scripts/
│   ├── test_qr_codes.py             # Python интеграционные тесты
│   └── run_all_qr_tests.sh          # Скрипт запуска всех тестов
└── TESTING_QR_CODES.md              # Этот файл
```

---

## Примеры использования

### Создание тестовой трубы и проверка

```bash
# 1. Создайте тестовую трубу
python3 scripts/create_test_pipe.py --company TEST

# 2. Получите QR-код из ответа
# 3. Протестируйте получение по QR-коду
curl http://localhost:8000/api/v1/pipes/qr/PL-TEST-{uuid}

# 4. Сгенерируйте изображение QR-кода
curl http://localhost:8000/api/v1/pipes/qr-code/PL-TEST-{uuid}/image -o qr.png
```

### Полный цикл тестирования

```bash
# 1. Запустите все тесты
./scripts/run_all_qr_tests.sh

# 2. Если все прошло, создайте тестовую трубу
python3 scripts/create_test_pipe.py

# 3. Сгенерируйте QR-код
python3 scripts/generate_qr.py COMPANY

# 4. Отсканируйте QR-код в мобильном приложении
```

---

## Дополнительные ресурсы

- [QR_CODE_TROUBLESHOOTING.md](mobile/QR_CODE_TROUBLESHOOTING.md) - Решение проблем с QR-кодами
- [Backend Tests README](backend/tests/README.md) - Документация backend тестов
- [Integration Tests README](mobile/integration_test/README.md) - Документация интеграционных тестов

---

## Поддержка

Если у вас возникли проблемы с тестами:

1. Проверьте этот документ
2. Проверьте логи: `docker-compose logs`
3. Убедитесь, что все сервисы запущены: `docker-compose ps`
4. Проверьте формат QR-кодов: должен быть `PL-{COMPANY}-{UUID}`
