-- Initialize PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Initialize TimescaleDB extension (if available)
-- CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Create schema for Tutas Ai
CREATE SCHEMA IF NOT EXISTS tutas_ai;

-- Set search path
SET search_path TO tutas_ai, public;

-- Note: Tables will be created by Alembic migrations
-- This script only ensures extensions are available
