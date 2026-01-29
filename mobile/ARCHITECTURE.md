# Offline-First Architecture

## Принципы

1. **Local-First**: Все данные сохраняются в локальную БД сразу
2. **Background Sync**: Синхронизация происходит в фоне при наличии интернета
3. **Conflict Resolution**: Ручное разрешение конфликтов через UI

## Поток данных

### Сохранение дефекта

```
User Input → DefectRepository.saveDefect()
  → LocalDefects.insert() with syncStatus = Pending
  → ✅ Success (offline ready)
```

### Синхронизация

```
syncPendingDefects()
  → Get all Pending defects
  → For each defect:
    → POST to /api/v1/defects
    → Success (200/201): Update syncStatus = Synced
    → Conflict (409): Update syncStatus = Conflict, save serverVersionJson
    → Error: Update syncStatus = Failed
```

### Разрешение конфликтов

```
Conflict Detected
  → UI показывает локальную и серверную версии
  → User выбирает:
    → acceptServerVersion(): Заменить локальную версией сервера
    → keepLocalVersion(): Оставить локальную, повторить синхронизацию
```

## Структура данных

### LocalDefects Table

- `id`: UUID (Primary Key)
- `pipeId`: Связь с трубой
- `inspectionId`: Связь с инспекцией (nullable)
- `defectType`: Тип дефекта
- `severity`: Уровень серьезности (1-5)
- `gpsCoordinates`: JSON координаты
- `photos`: JSON массив путей к файлам
- `syncStatus`: Статус синхронизации (0-3)
- `serverVersionJson`: JSON серверной версии при конфликте

### Sync Status Values

- `0` (Pending): Ожидает синхронизации
- `1` (Synced): Успешно синхронизировано
- `2` (Failed): Ошибка синхронизации
- `3` (Conflict): Конфликт с сервером

## API Integration

### ConflictException

Когда сервер возвращает 409 Conflict:
- API Client выбрасывает `ConflictException`
- Repository ловит исключение
- Сохраняет `serverVersionJson` в локальную БД
- Устанавливает `syncStatus = Conflict`

### Error Handling

- Network errors → `syncStatus = Failed`
- Server errors (5xx) → `syncStatus = Failed`
- Client errors (4xx, except 409) → `syncStatus = Failed`
- 409 Conflict → `syncStatus = Conflict` + save server version
