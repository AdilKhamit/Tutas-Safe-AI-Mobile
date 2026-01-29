# API Layer

## Structure

- `deps.py` - Dependency Injection для FastAPI (database sessions)
- `routes/` - API роутеры
  - `pipes.py` - Роутер для работы с трубами

## Endpoints

### GET `/api/v1/pipes/qr/{qr_code}`

Получить информацию о трубе по QR-коду.

**Использование:**
```bash
curl http://localhost:8000/api/v1/pipes/qr/PL-COMPANY-12345
```

**Response:**
```json
{
  "id": "uuid",
  "qr_code": "PL-COMPANY-12345",
  "manufacturer": "Company Name",
  "material": "steel",
  "current_status": "active",
  "risk_score": 0.75,
  "predicted_lifetime_years": 25,
  "location": null,
  "next_inspection_date": null
}
```

**Errors:**
- `404 Not Found` - Труба с указанным QR-кодом не найдена

## Dependency Injection

Все эндпоинты используют `get_db()` для получения асинхронной сессии БД.
