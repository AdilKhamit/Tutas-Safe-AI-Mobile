# Инструкция по запуску скрипта заполнения данных

## Требования

1. **База данных PostgreSQL** должна быть запущена
2. **База данных `tutas_ai`** должна существовать
3. **Расширения PostGIS и TimescaleDB** должны быть установлены

## Варианты запуска

### Вариант 1: Через Docker Compose (Рекомендуется)

```bash
# 1. Запустить базу данных
cd "/Users/kuralbekadilet475/Tutas Ai"
docker-compose up -d db

# 2. Подождать 10-15 секунд пока база запустится

# 3. Запустить скрипт
export PYTHONPATH=$PYTHONPATH:./backend
python3 scripts/seed_data.py
```

### Вариант 2: Локальная PostgreSQL

Если у вас установлена локальная PostgreSQL:

```bash
# 1. Создать базу данных (если не существует)
createdb tutas_ai

# 2. Включить расширения
psql -d tutas_ai -c "CREATE EXTENSION IF NOT EXISTS postgis;"
psql -d tutas_ai -c "CREATE EXTENSION IF NOT EXISTS timescaledb;"

# 3. Запустить скрипт
export PYTHONPATH=$PYTHONPATH:./backend
python3 scripts/seed_data.py
```

### Вариант 3: Использовать готовый скрипт

```bash
cd "/Users/kuralbekadilet475/Tutas Ai"
./scripts/run_seed.sh
```

## Что создаст скрипт

- ✅ 10 труб с QR-кодами PL-KAZAKHGAZ-001 до PL-KAZAKHGAZ-010
- ✅ ~600 измерений (60 на каждую трубу, 5 лет истории)
- ✅ ~200 инспекций (20 на каждую трубу)
- ✅ ~40 дефектов (3-5 на каждую трубу)
- ✅ Критические трубы: #1 и #3 (для демонстрации AI)

## Проверка результата

После успешного запуска вы увидите:

```
🚀 Starting database seeding...
📦 Creating pipes...
   ✓ Created pipe PL-KAZAKHGAZ-001 (Critical: True)
   ...
✅ Created 10 pipes
📊 Generating measurements...
✅ Generated measurements for 10 pipes
🔍 Creating inspections...
✅ Created inspections for 10 pipes
⚠️  Creating defects...
✅ Created defects for 10 pipes

🎉 Database seeding completed successfully!
```

## Устранение проблем

### Ошибка: "role postgres does not exist"
- Убедитесь, что PostgreSQL запущен
- Проверьте, что пользователь `postgres` существует
- Или измените DATABASE_URL в скрипте

### Ошибка: "database tutas_ai does not exist"
- Создайте базу: `createdb tutas_ai`
- Или используйте Docker Compose

### Ошибка: "extension postgis does not exist"
- Установите PostGIS: `CREATE EXTENSION postgis;`
- Docker образ уже включает PostGIS
