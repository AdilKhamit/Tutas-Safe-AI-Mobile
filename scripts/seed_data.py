"""
Data Seeding Script for Tutas Ai Platform
Generates synthetic data for demonstration purposes
"""
import asyncio
import random
import uuid
from datetime import datetime, timedelta, date
from decimal import Decimal
from typing import List

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy import select, func, text
from geoalchemy2 import WKTElement
from shapely.geometry import LineString, Point

# Import models
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent / "backend"))

from app.models.base import Base
from app.models.pipes import Pipe
from app.models.inspections import Inspection
from app.models.defects import Defect
from app.models.measurements import Measurement

# Database URL
# Can be overridden with environment variable
import os
import getpass

# Try to detect current PostgreSQL user
current_user = getpass.getuser()
default_url = f"postgresql+asyncpg://{current_user}@localhost:5432/tutas_ai"

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    default_url
)

# Kazakhstan coordinates (Astana, Karaganda region)
KAZAKHSTAN_COORDINATES = [
    # Astana area
    (71.4304, 51.1694),  # Astana center
    (71.4500, 51.1800),
    (71.4100, 51.1600),
    (71.4700, 51.1900),
    # Karaganda area
    (73.1024, 49.8014),  # Karaganda center
    (73.1200, 49.8200),
    (73.0900, 49.7900),
    (73.1300, 49.8300),
    # Almaty area
    (76.9124, 43.2220),  # Almaty center
    (76.9300, 43.2400),
]

# Materials
MATERIALS = ["steel", "cast_iron", "ductile_iron", "stainless_steel"]
DIAMETERS = [100, 150, 200, 250, 300, 400, 500]  # mm
WALL_THICKNESSES = [8.0, 10.0, 12.0, 14.0, 16.0, 18.0, 20.0]  # mm

# Defect types
DEFECT_TYPES = [
    "corrosion_external",
    "corrosion_internal",
    "crack",
    "dent",
    "weld_defect",
    "coating_damage",
]


def create_engine_and_session():
    """Create database engine and session"""
    engine = create_async_engine(DATABASE_URL, echo=False)
    async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    return engine, async_session


async def check_existing_data(session: AsyncSession) -> bool:
    """Check if data already exists"""
    result = await session.execute(select(func.count(Pipe.id)))
    count = result.scalar()
    return count > 0


async def create_pipe(
    session: AsyncSession,
    qr_code: str,
    index: int,
    is_critical: bool = False,
    use_postgis: bool = True,
) -> Pipe:
    """Create a pipe with realistic data"""
    # Select coordinates for this pipe
    start_idx = index % len(KAZAKHSTAN_COORDINATES)
    end_idx = (index + 1) % len(KAZAKHSTAN_COORDINATES)
    
    start_lon, start_lat = KAZAKHSTAN_COORDINATES[start_idx]
    end_lon, end_lat = KAZAKHSTAN_COORDINATES[end_idx]
    
    # Create LineString for route
    if use_postgis:
        line_string = LineString([(start_lon, start_lat), (end_lon, end_lat)])
        route_wkt = WKTElement(line_string.wkt, srid=4326)
        
        # Create start point
        point = Point(start_lon, start_lat)
        start_point_wkt = WKTElement(point.wkt, srid=4326)
    else:
        # Without PostGIS, set to None (will be handled by model)
        route_wkt = None
        start_point_wkt = None
    
    # Material and dimensions
    material = random.choice(MATERIALS)
    diameter = random.choice(DIAMETERS)
    
    # Wall thickness - critical pipes have thinner walls
    if is_critical:
        wall_thickness = random.choice([8.0, 10.0, 12.0])
    else:
        wall_thickness = random.choice([14.0, 16.0, 18.0, 20.0])
    
    # Production date (10-30 years ago)
    years_ago = random.randint(10, 30)
    production_date = date.today() - timedelta(days=years_ago * 365)
    
    # Length in meters
    length = random.uniform(500, 5000)
    
    pipe = Pipe(
        qr_code=qr_code,
        manufacturer=f"KazakhGaz Manufacturing {random.randint(1, 5)}",
        production_date=production_date,
        material=material,
        diameter_mm=diameter,
        wall_thickness_mm=Decimal(str(wall_thickness)),
        length_meters=Decimal(str(round(length, 2))),
        route_line=route_wkt,
        start_point=start_point_wkt,
        current_status="active",
        risk_score=None,  # Will be calculated by AI
        predicted_lifetime_years=None,
    )
    
    session.add(pipe)
    await session.flush()
    await session.refresh(pipe)
    
    return pipe


async def generate_measurements(
    session: AsyncSession,
    pipe: Pipe,
    is_critical: bool = False,
):
    """Generate historical measurements for a pipe"""
    if not pipe.wall_thickness_mm:
        return
    
    current_thickness = float(pipe.wall_thickness_mm)
    
    # Corrosion rate (mm/year)
    if is_critical:
        # Critical pipes: high corrosion rate
        base_rate = random.uniform(0.5, 1.2)
    else:
        # Normal pipes: moderate corrosion rate
        base_rate = random.uniform(0.1, 0.4)
    
    # Generate measurements for last 5 years
    end_date = datetime.now()
    start_date = end_date - timedelta(days=5 * 365)
    
    # Number of measurements (approximately monthly)
    num_measurements = 60
    
    measurements = []
    for i in range(num_measurements):
        # Calculate date
        days_offset = (i / num_measurements) * (end_date - start_date).days
        measured_at = start_date + timedelta(days=days_offset)
        
        # Calculate thickness with corrosion trend
        years_elapsed = (end_date - measured_at).days / 365.0
        thickness = current_thickness + (base_rate * years_elapsed)
        
        # Add noise (±5%)
        noise = random.uniform(-0.05, 0.05)
        thickness = thickness * (1 + noise)
        
        # Ensure positive
        thickness = max(0.1, thickness)
        
        measurement = Measurement(
            pipe_id=pipe.id,
            measurement_type="wall_thickness",
            value=Decimal(str(round(thickness, 4))),
            unit="mm",
            measured_at=measured_at,
            equipment_info={
                "device": f"UT-{random.randint(100, 999)}",
                "operator": f"Operator-{random.randint(1, 10)}",
            },
        )
        measurements.append(measurement)
    
    session.add_all(measurements)
    await session.flush()


async def create_inspections(
    session: AsyncSession,
    pipe: Pipe,
    num_inspections: int = 20,
):
    """Create historical inspections"""
    inspections = []
    
    # Generate inspections over last 5 years
    end_date = datetime.now()
    start_date = end_date - timedelta(days=5 * 365)
    
    for i in range(num_inspections):
        # Random date in range
        days_offset = random.uniform(0, (end_date - start_date).days)
        inspection_date = start_date + timedelta(days=days_offset)
        
        inspection_type = random.choice(["visual", "ultrasonic", "magnetic", "pressure_test"])
        status = random.choice(["completed", "completed", "completed", "planned"])  # Mostly completed
        
        completed_date = inspection_date if status == "completed" else None
        
        inspection = Inspection(
            pipe_id=pipe.id,
            inspection_type=inspection_type,
            scheduled_date=inspection_date.date(),
            completed_date=completed_date,
            status=status,
            weather_conditions={
                "temperature": random.randint(-20, 35),
                "wind_speed": random.uniform(0, 15),
                "precipitation": random.choice(["none", "light", "moderate"]),
            },
            equipment_used=[
                f"Device-{random.randint(1, 5)}",
                f"Tool-{random.randint(1, 10)}",
            ],
            overall_assessment=random.choice(["good", "fair", "poor"]),
            recommendations=random.choice([
                "Continue monitoring",
                "Schedule maintenance",
                "Replace section",
                None,
            ]),
        )
        inspections.append(inspection)
    
    session.add_all(inspections)
    await session.flush()
    
    return inspections


async def create_defects(
    session: AsyncSession,
    pipe: Pipe,
    inspections: List[Inspection],
    is_critical: bool = False,
):
    """Create defects for a pipe"""
    num_defects = random.randint(3, 5) if not is_critical else random.randint(5, 8)
    
    defects = []
    for i in range(num_defects):
        # Select random inspection or None
        inspection = random.choice(inspections) if inspections else None
        
        # Defect type
        defect_type = random.choice(DEFECT_TYPES)
        
        # Severity - critical pipes have more severe defects
        if is_critical:
            severity = random.choice([4, 5, 5, 5])  # Mostly critical
        else:
            severity = random.randint(1, 3)
        
        # GPS coordinates (near pipe start point)
        if pipe.start_point:
            # Extract coordinates from WKT (simplified)
            start_lon, start_lat = KAZAKHSTAN_COORDINATES[0]  # Use first coordinate as base
            # Add small offset
            gps_lon = start_lon + random.uniform(-0.01, 0.01)
            gps_lat = start_lat + random.uniform(-0.01, 0.01)
            
            point = Point(gps_lon, gps_lat)
            gps_wkt = WKTElement(point.wkt, srid=4326)
        else:
            gps_wkt = None
        
        # Photos
        num_photos = random.randint(1, 3)
        photos = [
            f"https://placehold.co/600x400?text=Defect-{i+1}-Photo-{photo_idx+1}"
            for photo_idx in range(num_photos)
        ]
        
        defect = Defect(
            inspection_id=inspection.id if inspection else None,
            pipe_id=pipe.id,
            defect_type=defect_type,
            severity_level=severity,
            gps_coordinates=gps_wkt,
            location_on_pipe=f"{random.randint(1, 12)} часов",
            length_mm=Decimal(str(random.uniform(10, 500))),
            depth_mm=Decimal(str(random.uniform(0.5, 5.0))),
            ai_detected=random.choice([True, False]),
            ai_confidence=Decimal(str(random.uniform(0.7, 0.95))) if random.choice([True, False]) else None,
            photos=photos,
        )
        defects.append(defect)
    
    session.add_all(defects)
    await session.flush()


async def seed_database():
    """Main seeding function"""
    print("🚀 Starting database seeding...")
    
    engine, async_session = create_engine_and_session()
    
    # Create extensions first
    print("📋 Creating database extensions...")
    async with engine.begin() as conn:
        # Try to create PostGIS extension
        postgis_available = False
        try:
            await conn.execute(
                text("CREATE EXTENSION IF NOT EXISTS postgis;")
            )
            print("   ✓ PostGIS extension created")
            postgis_available = True
        except Exception as e:
            print(f"   ⚠️  PostGIS extension: {str(e)[:60]}...")
            print("   💡 PostGIS not available. Will use simplified coordinates.")
            # Continue without PostGIS - we'll handle it in create_pipe
        
        # Try to create TimescaleDB extension
        try:
            await conn.execute(
                text("CREATE EXTENSION IF NOT EXISTS timescaledb;")
            )
            print("   ✓ TimescaleDB extension created")
        except Exception as e:
            print(f"   ⚠️  TimescaleDB extension: {str(e)[:60]}...")
            print("   💡 TimescaleDB is required for time-series data. Using Docker is recommended.")
            # Don't raise - measurements can work without TimescaleDB (just slower)
    
    # Create tables if they don't exist
    print("📋 Creating database tables...")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    print("✅ Tables created")
    
    async with async_session() as session:
        # Check if data exists
        try:
            if await check_existing_data(session):
                print("⚠️  Data already exists. Skipping seeding.")
                print("   To re-seed, clear the database first.")
                return
        except Exception as e:
            # If tables don't exist yet, continue
            print(f"   Note: {str(e)[:50]}... (will create tables)")
        
        print("📦 Creating pipes...")
        pipes = []
        
        # Create 10 pipes
        for i in range(10):
            qr_code = f"PL-KAZAKHGAZ-{str(i+1).zfill(3)}"
            
            # Pipes 1 and 3 are critical
            is_critical = (i == 0 or i == 2)
            
            pipe = await create_pipe(session, qr_code, i, is_critical=is_critical, use_postgis=postgis_available)
            pipes.append((pipe, is_critical))
            print(f"   ✓ Created pipe {qr_code} (Critical: {is_critical})")
        
        await session.commit()
        print(f"✅ Created {len(pipes)} pipes")
        
        # Generate measurements
        print("📊 Generating measurements...")
        for pipe, is_critical in pipes:
            await generate_measurements(session, pipe, is_critical=is_critical)
            await session.commit()
        print(f"✅ Generated measurements for {len(pipes)} pipes")
        
        # Create inspections
        print("🔍 Creating inspections...")
        all_inspections = []
        for pipe, _ in pipes:
            inspections = await create_inspections(session, pipe, num_inspections=20)
            all_inspections.append((pipe, inspections))
            await session.commit()
        print(f"✅ Created inspections for {len(pipes)} pipes")
        
        # Create defects
        print("⚠️  Creating defects...")
        for pipe, inspections in all_inspections:
            is_critical = any(p[1] for p in pipes if p[0].id == pipe.id)
            await create_defects(session, pipe, inspections, is_critical=is_critical)
            await session.commit()
        print(f"✅ Created defects for {len(pipes)} pipes")
        
        print("\n🎉 Database seeding completed successfully!")
        print(f"   - {len(pipes)} pipes")
        print(f"   - ~{len(pipes) * 60} measurements")
        print(f"   - ~{len(pipes) * 20} inspections")
        print(f"   - ~{len(pipes) * 4} defects")
        print("\n💡 Note: AI predictions will be generated on first API call.")
    
    await engine.dispose()


if __name__ == "__main__":
    asyncio.run(seed_database())
