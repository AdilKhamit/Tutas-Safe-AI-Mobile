-- Create tables without PostGIS (for local development)
-- Run with: psql -d tutas_ai -f scripts/create_tables_simple.sql

CREATE TABLE IF NOT EXISTS pipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    qr_code VARCHAR(50) UNIQUE NOT NULL,
    manufacturer VARCHAR(200),
    production_date DATE,
    material VARCHAR(100),
    diameter_mm INTEGER,
    wall_thickness_mm NUMERIC(5, 2),
    length_meters NUMERIC(8, 2),
    route_line TEXT,  -- Store as text instead of geography
    start_point TEXT,  -- Store as text instead of geography
    current_status VARCHAR(50) NOT NULL DEFAULT 'active',
    risk_score NUMERIC(3, 2),
    predicted_lifetime_years INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pipes_qr_code ON pipes(qr_code);

CREATE TABLE IF NOT EXISTS inspections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pipe_id UUID NOT NULL REFERENCES pipes(id) ON DELETE CASCADE,
    inspection_type VARCHAR(50) NOT NULL,
    scheduled_date DATE,
    completed_date TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'planned',
    weather_conditions JSONB,
    equipment_used JSONB,
    overall_assessment VARCHAR(50),
    recommendations TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_inspections_pipe_id ON inspections(pipe_id);

CREATE TABLE IF NOT EXISTS defects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inspection_id UUID REFERENCES inspections(id) ON DELETE SET NULL,
    pipe_id UUID NOT NULL REFERENCES pipes(id) ON DELETE CASCADE,
    defect_type VARCHAR(100) NOT NULL,
    severity_level INTEGER NOT NULL,
    gps_coordinates TEXT,  -- Store as text instead of geography
    location_on_pipe VARCHAR(50),
    length_mm NUMERIC(8, 2),
    depth_mm NUMERIC(8, 2),
    ai_detected BOOLEAN NOT NULL DEFAULT FALSE,
    ai_confidence NUMERIC(3, 2),
    photos JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_defects_pipe_id ON defects(pipe_id);
CREATE INDEX IF NOT EXISTS idx_defects_inspection_id ON defects(inspection_id);

CREATE TABLE IF NOT EXISTS measurements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pipe_id UUID NOT NULL REFERENCES pipes(id) ON DELETE CASCADE,
    measurement_type VARCHAR(50) NOT NULL,
    value NUMERIC(10, 4) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    measured_at TIMESTAMP NOT NULL,
    equipment_info JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_measurements_pipe_id ON measurements(pipe_id);
CREATE INDEX IF NOT EXISTS idx_measurements_measured_at ON measurements(measured_at);

-- Note: TimescaleDB hypertable creation skipped (requires extension)
-- Measurements will work as regular table, just slower for time-series queries

SELECT '✅ Tables created successfully!' as status;
