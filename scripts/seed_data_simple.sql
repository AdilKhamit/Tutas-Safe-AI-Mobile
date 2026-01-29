-- Simplified seed script without PostGIS requirements
-- Run with: psql -d tutas_ai -f scripts/seed_data_simple.sql

-- Insert 10 pipes
INSERT INTO pipes (id, qr_code, manufacturer, production_date, material, diameter_mm, wall_thickness_mm, length_meters, current_status, created_at, updated_at)
VALUES
  (gen_random_uuid(), 'PL-KAZAKHGAZ-001', 'KazakhGaz Manufacturing 1', '1994-01-15', 'steel', 300, 8.5, 2500.0, 'active', NOW(), NOW()),
  (gen_random_uuid(), 'PL-KAZAKHGAZ-002', 'KazakhGaz Manufacturing 2', '2000-03-20', 'cast_iron', 200, 16.0, 1800.0, 'active', NOW(), NOW()),
  (gen_random_uuid(), 'PL-KAZAKHGAZ-003', 'KazakhGaz Manufacturing 1', '1995-06-10', 'steel', 400, 10.0, 3200.0, 'active', NOW(), NOW()),
  (gen_random_uuid(), 'PL-KAZAKHGAZ-004', 'KazakhGaz Manufacturing 3', '2010-08-05', 'ductile_iron', 250, 18.0, 2100.0, 'active', NOW(), NOW()),
  (gen_random_uuid(), 'PL-KAZAKHGAZ-005', 'KazakhGaz Manufacturing 2', '2005-11-12', 'steel', 150, 14.0, 1500.0, 'active', NOW(), NOW()),
  (gen_random_uuid(), 'PL-KAZAKHGAZ-006', 'KazakhGaz Manufacturing 4', '2015-02-28', 'stainless_steel', 100, 20.0, 1200.0, 'active', NOW(), NOW()),
  (gen_random_uuid(), 'PL-KAZAKHGAZ-007', 'KazakhGaz Manufacturing 1', '2008-07-18', 'steel', 350, 16.0, 2800.0, 'active', NOW(), NOW()),
  (gen_random_uuid(), 'PL-KAZAKHGAZ-008', 'KazakhGaz Manufacturing 3', '2012-09-25', 'cast_iron', 180, 14.0, 1900.0, 'active', NOW(), NOW()),
  (gen_random_uuid(), 'PL-KAZAKHGAZ-009', 'KazakhGaz Manufacturing 2', '2003-04-14', 'steel', 220, 18.0, 2200.0, 'active', NOW(), NOW()),
  (gen_random_uuid(), 'PL-KAZAKHGAZ-010', 'KazakhGaz Manufacturing 5', '2018-12-01', 'ductile_iron', 120, 16.0, 1100.0, 'active', NOW(), NOW())
ON CONFLICT (qr_code) DO NOTHING;

-- Get pipe IDs for measurements and inspections
DO $$
DECLARE
  pipe1_id UUID;
  pipe2_id UUID;
  pipe3_id UUID;
  i INTEGER;
  j INTEGER;
  measurement_date TIMESTAMP;
  thickness_value NUMERIC;
BEGIN
  -- Get pipe IDs
  SELECT id INTO pipe1_id FROM pipes WHERE qr_code = 'PL-KAZAKHGAZ-001';
  SELECT id INTO pipe2_id FROM pipes WHERE qr_code = 'PL-KAZAKHGAZ-002';
  SELECT id INTO pipe3_id FROM pipes WHERE qr_code = 'PL-KAZAKHGAZ-003';

  -- Generate measurements for each pipe (60 per pipe, 5 years)
  FOR i IN 1..10 LOOP
    SELECT id INTO pipe1_id FROM pipes WHERE qr_code = 'PL-KAZAKHGAZ-' || LPAD(i::TEXT, 3, '0');
    
    FOR j IN 0..59 LOOP
      measurement_date := NOW() - INTERVAL '5 years' + (j * INTERVAL '30 days');
      -- Critical pipes (1 and 3) have higher corrosion
      IF i IN (1, 3) THEN
        thickness_value := 10.0 - (j * 0.15) + (RANDOM() * 0.5 - 0.25);
      ELSE
        thickness_value := 16.0 - (j * 0.08) + (RANDOM() * 0.3 - 0.15);
      END IF;
      
      INSERT INTO measurements (id, pipe_id, measurement_type, value, unit, measured_at, created_at)
      VALUES (gen_random_uuid(), pipe1_id, 'wall_thickness', GREATEST(thickness_value, 0.1), 'mm', measurement_date, NOW());
    END LOOP;
  END LOOP;
END $$;

-- Generate inspections (20 per pipe)
DO $$
DECLARE
  pipe_id UUID;
  i INTEGER;
  j INTEGER;
  inspection_date DATE;
BEGIN
  FOR i IN 1..10 LOOP
    SELECT id INTO pipe_id FROM pipes WHERE qr_code = 'PL-KAZAKHGAZ-' || LPAD(i::TEXT, 3, '0');
    
    FOR j IN 0..19 LOOP
      inspection_date := CURRENT_DATE - INTERVAL '5 years' + (j * INTERVAL '90 days');
      
      INSERT INTO inspections (id, pipe_id, inspection_type, scheduled_date, completed_date, status, overall_assessment, created_at, updated_at)
      VALUES (
        gen_random_uuid(),
        pipe_id,
        CASE (j % 4) WHEN 0 THEN 'visual' WHEN 1 THEN 'ultrasonic' WHEN 2 THEN 'magnetic' ELSE 'pressure_test' END,
        inspection_date,
        CASE WHEN j % 4 != 0 THEN inspection_date::TIMESTAMP ELSE NULL END,
        CASE WHEN j % 4 != 0 THEN 'completed' ELSE 'planned' END,
        CASE (j % 3) WHEN 0 THEN 'good' WHEN 1 THEN 'fair' ELSE 'poor' END,
        NOW(),
        NOW()
      );
    END LOOP;
  END LOOP;
END $$;

-- Generate defects (3-5 per pipe, more for critical pipes)
DO $$
DECLARE
  current_pipe_id UUID;
  current_inspection_id UUID;
  i INTEGER;
  j INTEGER;
  num_defects INTEGER;
  defect_types TEXT[] := ARRAY['corrosion_external', 'corrosion_internal', 'crack', 'dent', 'weld_defect', 'coating_damage'];
BEGIN
  FOR i IN 1..10 LOOP
    SELECT id INTO current_pipe_id FROM pipes WHERE qr_code = 'PL-KAZAKHGAZ-' || LPAD(i::TEXT, 3, '0');
    
    -- Critical pipes have more defects
    IF i IN (1, 3) THEN
      num_defects := 6;
    ELSE
      num_defects := 4;
    END IF;
    
    FOR j IN 1..num_defects LOOP
      -- Get a random inspection for this pipe
      SELECT id INTO current_inspection_id 
      FROM inspections 
      WHERE pipe_id = current_pipe_id 
      ORDER BY RANDOM() 
      LIMIT 1;
      
      INSERT INTO defects (
        id, pipe_id, inspection_id, defect_type, severity_level,
        length_mm, depth_mm, ai_detected, ai_confidence, photos, created_at, updated_at
      )
      VALUES (
        gen_random_uuid(),
        current_pipe_id,
        current_inspection_id,
        defect_types[1 + (j % 6)],
        CASE WHEN i IN (1, 3) THEN 4 + (j % 2) ELSE 1 + (j % 3) END,
        (10 + RANDOM() * 490)::NUMERIC(8,2),
        (0.5 + RANDOM() * 4.5)::NUMERIC(8,2),
        (j % 2 = 0),
        CASE WHEN j % 2 = 0 THEN (0.7 + RANDOM() * 0.25)::NUMERIC(3,2) ELSE NULL END,
        ('["https://placehold.co/600x400?text=Defect-' || j || '"]')::JSONB,
        NOW(),
        NOW()
      );
    END LOOP;
  END LOOP;
END $$;

SELECT '✅ Data seeding completed!' as status;
SELECT COUNT(*) as pipes_count FROM pipes;
SELECT COUNT(*) as measurements_count FROM measurements;
SELECT COUNT(*) as inspections_count FROM inspections;
SELECT COUNT(*) as defects_count FROM defects;
