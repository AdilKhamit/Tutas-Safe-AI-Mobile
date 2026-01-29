#!/bin/bash
# Script to run data seeding with proper setup

echo "🌱 Tutas Ai - Data Seeding Script"
echo ""

# Check if database is accessible
echo "📡 Checking database connection..."

# Try to connect (this will fail gracefully if DB is not available)
python3 -c "
import asyncio
import asyncpg
import sys
import os

async def check_db():
    try:
        db_url = os.getenv('DATABASE_URL', 'postgresql+asyncpg://postgres:postgres@localhost:5432/tutas_ai')
        # Extract connection params
        conn = await asyncpg.connect(
            host='localhost',
            port=5432,
            user='postgres',
            password='postgres',
            database='tutas_ai'
        )
        await conn.close()
        print('✅ Database connection successful')
        return True
    except Exception as e:
        print(f'❌ Database connection failed: {e}')
        print('')
        print('💡 To start the database:')
        print('   docker-compose up -d db')
        print('')
        print('   Or ensure PostgreSQL is running locally.')
        return False

if not asyncio.run(check_db()):
    sys.exit(1)
" || exit 1

echo ""
echo "📦 Installing dependencies..."
pip3 install -q sqlalchemy asyncpg geoalchemy2 shapely 2>/dev/null || {
    echo "⚠️  Some dependencies may already be installed"
}

echo ""
echo "🚀 Running seed script..."
export PYTHONPATH=$PYTHONPATH:./backend
python3 scripts/seed_data.py
