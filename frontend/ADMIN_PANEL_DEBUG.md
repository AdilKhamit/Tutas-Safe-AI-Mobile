# Диагностика админ-панели

## Проверка доступа

1. Откройте браузер и перейдите по адресу: `http://localhost:3000/admin`
   - Или `http://localhost/admin` если используете Docker

2. Откройте консоль браузера (F12) и проверьте:
   - Есть ли ошибки в консоли?
   - Появляется ли сообщение "AdminPanel mounted"?
   - Какие данные приходят от API?

## Возможные проблемы

### 1. Страница не загружается (404)
- Проверьте, что роутинг настроен правильно в `App.tsx`
- Убедитесь, что сервер разработки запущен: `npm run dev`

### 2. Ошибка загрузки данных
- Проверьте, что backend запущен на порту 8000
- Проверьте proxy настройки в `vite.config.ts`
- Убедитесь, что API endpoint `/api/v1/pipes` доступен

### 3. Ошибка создания трубы
- Проверьте консоль браузера для деталей ошибки
- Убедитесь, что backend endpoint `POST /api/v1/pipes` работает
- Проверьте формат данных в запросе

## Тестирование API напрямую

```bash
# Проверка получения всех труб
curl http://localhost:8000/api/v1/pipes

# Создание новой трубы
curl -X POST http://localhost:8000/api/v1/pipes \
  -H "Content-Type: application/json" \
  -d '{
    "company": "TEST",
    "manufacturer": "Test Manufacturer",
    "material": "Steel",
    "diameter_mm": 100,
    "wall_thickness_mm": 5.0,
    "length_meters": 100.0
  }'
```

## Проверка роутинга

В консоли браузера должно быть:
```
AdminPanel mounted
Pipes data: [...]
Loading: false
Error: undefined
```

Если видите ошибки, проверьте:
1. Запущен ли backend
2. Правильно ли настроен proxy
3. Есть ли CORS ошибки
