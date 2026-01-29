# SQLAlchemy Models

## Структура моделей

### Base Classes (`base.py`)

- **Base**: Базовый класс для всех моделей с naming convention для PostgreSQL
- **UUIDMixin**: Миксин для UUID primary key
- **TimestampMixin**: Миксин для created_at и updated_at

### Models

1. **Pipe** (`pipes.py`)
   - Цифровой паспорт трубы
   - QR-код (уникальный индекс)
   - Геолокация через PostGIS (Geography LINESTRING и POINT)
   - Паспортные данные (производитель, материал, диаметр, толщина стенки)
   - AI поля (risk_score, predicted_lifetime_years)

2. **Inspection** (`inspections.py`)
   - Записи инспекций трубопровода
   - Тип инспекции (visual, ultrasonic, etc.)
   - Погодные условия (JSONB)
   - Оборудование (JSONB)
   - Статус и рекомендации

3. **Defect** (`defects.py`)
   - Дефекты трубопровода
   - Классификация (тип, уровень серьезности 1-5)
   - GPS координаты (Geography POINT)
   - AI детекция (ai_detected, ai_confidence)
   - Фотографии (JSONB массив)

4. **Measurement** (`measurements.py`)
   - Временные ряды измерений (TimescaleDB hypertable)
   - Тип измерения (wall_thickness, pressure, etc.)
   - Значение и единица измерения
   - Автоматическое создание hypertable через DDL event

## Использование

```python
from app.models import Base, Pipe, Inspection, Defect, Measurement
```

## Миграции

Модели готовы для создания миграций Alembic:

```bash
alembic revision --autogenerate -m "Create initial models"
alembic upgrade head
```

## TimescaleDB

Таблица `measurements` автоматически конвертируется в hypertable при создании через DDL event listener.
