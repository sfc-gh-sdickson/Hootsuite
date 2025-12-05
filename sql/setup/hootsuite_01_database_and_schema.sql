-- ============================================================================
-- Hootsuite Intelligence Agent - Database and Schema Setup
-- ============================================================================
-- Purpose: Create database, schemas, and warehouse for Hootsuite intelligence platform
-- ============================================================================

-- ============================================================================
-- Step 1: Create Database
-- ============================================================================
CREATE DATABASE IF NOT EXISTS HOOTSUITE_INTELLIGENCE
  COMMENT = 'Hootsuite social media management intelligence platform';

USE DATABASE HOOTSUITE_INTELLIGENCE;

-- ============================================================================
-- Step 2: Create Schemas
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS RAW
  COMMENT = 'Raw data tables for organizations, users, posts, and engagements';

CREATE SCHEMA IF NOT EXISTS ANALYTICS
  COMMENT = 'Analytical views, semantic views, and feature engineering';

CREATE SCHEMA IF NOT EXISTS ML_MODELS
  COMMENT = 'ML model registry and prediction functions';

-- ============================================================================
-- Step 3: Create Warehouse
-- ============================================================================
CREATE WAREHOUSE IF NOT EXISTS HOOTSUITE_WH
  WITH WAREHOUSE_SIZE = 'MEDIUM'
  AUTO_SUSPEND = 300
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = FALSE
  COMMENT = 'Warehouse for Hootsuite operations and analytics';

USE WAREHOUSE HOOTSUITE_WH;

-- ============================================================================
-- Step 4: Grant Permissions
-- ============================================================================
GRANT USAGE ON DATABASE HOOTSUITE_INTELLIGENCE TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA RAW TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA ANALYTICS TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA ML_MODELS TO ROLE SYSADMIN;
GRANT USAGE ON WAREHOUSE HOOTSUITE_WH TO ROLE SYSADMIN;

-- ============================================================================
-- Confirmation
-- ============================================================================
SELECT 'Hootsuite database, schemas, and warehouse created successfully' AS STATUS;

SHOW DATABASES LIKE 'HOOTSUITE%';
SHOW SCHEMAS IN DATABASE HOOTSUITE_INTELLIGENCE;
SHOW WAREHOUSES LIKE 'HOOTSUITE%';

