-- ============================================================================
-- Origence Intelligence Agent - Database and Schema Setup
-- ============================================================================
-- Purpose: Create database, schemas, and warehouse for Origence lending platform
-- ============================================================================

-- ============================================================================
-- Step 1: Create Database
-- ============================================================================
CREATE DATABASE IF NOT EXISTS ORIGENCE_INTELLIGENCE
  COMMENT = 'Origence credit union lending intelligence platform';

USE DATABASE ORIGENCE_INTELLIGENCE;

-- ============================================================================
-- Step 2: Create Schemas
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS RAW
  COMMENT = 'Raw data tables for loans, members, credit unions, and dealers';

CREATE SCHEMA IF NOT EXISTS ANALYTICS
  COMMENT = 'Analytical views, semantic views, and feature engineering';

CREATE SCHEMA IF NOT EXISTS ML_MODELS
  COMMENT = 'ML model registry and prediction functions';

-- ============================================================================
-- Step 3: Create Warehouse
-- ============================================================================
CREATE WAREHOUSE IF NOT EXISTS ORIGENCE_WH
  WITH WAREHOUSE_SIZE = 'MEDIUM'
  AUTO_SUSPEND = 300
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = FALSE
  COMMENT = 'Warehouse for Origence lending operations and analytics';

USE WAREHOUSE ORIGENCE_WH;

-- ============================================================================
-- Step 4: Grant Permissions
-- ============================================================================
GRANT USAGE ON DATABASE ORIGENCE_INTELLIGENCE TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA RAW TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA ANALYTICS TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA ML_MODELS TO ROLE SYSADMIN;
GRANT USAGE ON WAREHOUSE ORIGENCE_WH TO ROLE SYSADMIN;

-- ============================================================================
-- Confirmation
-- ============================================================================
SELECT 'Origence database, schemas, and warehouse created successfully' AS STATUS;

SHOW DATABASES LIKE 'ORIGENCE%';
SHOW SCHEMAS IN DATABASE ORIGENCE_INTELLIGENCE;
SHOW WAREHOUSES LIKE 'ORIGENCE%';
