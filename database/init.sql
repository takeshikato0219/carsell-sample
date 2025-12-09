-- Initial database setup
-- This file runs automatically when PostgreSQL container starts

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Database is ready
SELECT 'Database initialized successfully' AS status;
