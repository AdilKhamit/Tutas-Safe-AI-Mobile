# Data Seeding Scripts

Scripts for populating the database with demonstration data.

## seed_data.py

Generates synthetic data for the Tutas Ai platform:

- **10 Pipes**: Realistic pipeline segments with Kazakhstan coordinates
- **~60 Measurements per pipe**: 5 years of historical wall thickness data
- **~20 Inspections per pipe**: Historical inspection records
- **~4 Defects per pipe**: Various defect types with severity levels

### Critical Pipes

Pipes #1 and #3 (PL-KAZAKHGAZ-001, PL-KAZAKHGAZ-003) are generated with:
- Thinner wall thickness (8-12mm)
- Higher corrosion rates (0.5-1.2 mm/year)
- More severe defects (severity 4-5)
- Accelerated degradation patterns

These pipes will trigger AI Engine to show "Critical" status.

## Usage

```bash
# Install dependencies
pip install -r scripts/requirements.txt

# Set Python path
export PYTHONPATH=$PYTHONPATH:./backend

# Run seed script
python scripts/seed_data.py
```

## Requirements

- PostgreSQL running with database `tutas_ai`
- PostGIS and TimescaleDB extensions enabled
- Python 3.11+
- Dependencies from `scripts/requirements.txt`

## Data Characteristics

### Pipes
- Materials: steel, cast_iron, ductile_iron, stainless_steel
- Diameters: 100-500mm
- Wall thickness: 8-20mm (critical pipes: 8-12mm)
- Length: 500-5000 meters
- Coordinates: Real Kazakhstan locations (Astana, Karaganda, Almaty)

### Measurements
- Type: wall_thickness
- Frequency: ~Monthly over 5 years
- Trend: Gradual corrosion with noise
- Critical pipes: Accelerated corrosion

### Inspections
- Types: visual, ultrasonic, magnetic, pressure_test
- Status: Mostly completed, some planned
- Weather conditions: Realistic Kazakhstan weather
- Equipment: Various inspection devices

### Defects
- Types: corrosion_external, corrosion_internal, crack, dent, weld_defect, coating_damage
- Severity: 1-5 (critical pipes: 4-5)
- Photos: Placeholder URLs
- GPS coordinates: Near pipe locations
