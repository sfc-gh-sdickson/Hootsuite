-- ============================================================================
-- Origence Intelligence Agent - Cortex Search Services
-- ============================================================================
-- Purpose: Enable semantic search over unstructured lending documents
-- Tables: UNDERWRITING_NOTES, LOAN_DOCUMENTS, COMPLIANCE_POLICIES
-- ============================================================================

USE DATABASE ORIGENCE_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE ORIGENCE_WH;

-- ============================================================================
-- Step 1: Verify Change Tracking (already enabled in table creation)
-- ============================================================================
SHOW TABLES LIKE 'UNDERWRITING_NOTES' IN SCHEMA RAW;
SHOW TABLES LIKE 'LOAN_DOCUMENTS' IN SCHEMA RAW;
SHOW TABLES LIKE 'COMPLIANCE_POLICIES' IN SCHEMA RAW;

-- ============================================================================
-- Step 2: Create Cortex Search Service for Underwriting Notes
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE UNDERWRITING_NOTES_SEARCH
  ON note_text
  ATTRIBUTES application_id, loan_officer_id, note_category
  WAREHOUSE = ORIGENCE_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Semantic search over underwriting decision notes and rationale'
AS
  SELECT
    note_id,
    note_text,
    application_id,
    loan_officer_id,
    note_date,
    note_category,
    created_at
  FROM UNDERWRITING_NOTES;

-- ============================================================================
-- Step 3: Create Cortex Search Service for Loan Documents
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE LOAN_DOCUMENTS_SEARCH
  ON document_text
  ATTRIBUTES loan_id, application_id, document_type, document_category
  WAREHOUSE = ORIGENCE_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Search over loan documentation, contracts, and supporting materials'
AS
  SELECT
    document_id,
    document_text,
    loan_id,
    application_id,
    document_type,
    document_category,
    upload_date,
    created_at
  FROM LOAN_DOCUMENTS;

-- ============================================================================
-- Step 4: Create Cortex Search Service for Compliance Policies
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE COMPLIANCE_POLICIES_SEARCH
  ON policy_content
  ATTRIBUTES policy_category, regulation_type, policy_title, keywords
  WAREHOUSE = ORIGENCE_WH
  TARGET_LAG = '1 day'
  COMMENT = 'Search lending policies, regulatory requirements, and compliance guidelines'
AS
  SELECT
    policy_id,
    policy_content,
    policy_title,
    policy_category,
    regulation_type,
    effective_date,
    last_review_date,
    keywords,
    created_at
  FROM COMPLIANCE_POLICIES;

-- ============================================================================
-- Step 5: Grant Usage Permissions
-- ============================================================================
GRANT USAGE ON CORTEX SEARCH SERVICE UNDERWRITING_NOTES_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE LOAN_DOCUMENTS_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE COMPLIANCE_POLICIES_SEARCH TO ROLE SYSADMIN;

-- ============================================================================
-- Step 6: Test Search Services with Sample Queries
-- ============================================================================

-- Test underwriting notes search
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'ORIGENCE_INTELLIGENCE.RAW.UNDERWRITING_NOTES_SEARCH',
    '{
      "query": "credit score verification",
      "columns": ["note_text", "note_category"],
      "limit": 3
    }'
  )
)['results'] AS results;

-- Test loan documents search
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'ORIGENCE_INTELLIGENCE.RAW.LOAN_DOCUMENTS_SEARCH',
    '{
      "query": "income verification documents",
      "columns": ["document_text", "document_type"],
      "filter": {"@eq": {"document_category": "VERIFICATION"}},
      "limit": 3
    }'
  )
)['results'] AS results;

-- Test compliance policies search
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'ORIGENCE_INTELLIGENCE.RAW.COMPLIANCE_POLICIES_SEARCH',
    '{
      "query": "fair lending regulations",
      "columns": ["policy_title", "policy_category", "regulation_type"],
      "limit": 3
    }'
  )
)['results'] AS results;

-- ============================================================================
-- Step 7: Verify Service Status
-- ============================================================================
SHOW CORTEX SEARCH SERVICES IN SCHEMA RAW;

SELECT 'Origence Cortex Search services created successfully' AS STATUS;

-- ============================================================================
-- Usage Examples for Intelligence Agent
-- ============================================================================

-- Example 1: Search underwriting notes for specific concerns
-- Query: "Find underwriting notes mentioning debt-to-income concerns"
-- Uses: UNDERWRITING_NOTES_SEARCH with query filter

-- Example 2: Search loan documents for specific verification
-- Query: "Find employment verification documents for recent applications"
-- Uses: LOAN_DOCUMENTS_SEARCH with document_type filter

-- Example 3: Search compliance policies
-- Query: "What are our policies on auto loan collateral requirements?"
-- Uses: COMPLIANCE_POLICIES_SEARCH with keyword matching

-- ============================================================================
-- Monitoring and Maintenance
-- ============================================================================

-- Check search service refresh status
SHOW DYNAMIC TABLES LIKE '%CORTEX_SEARCH%' IN SCHEMA RAW;

-- View search service details
DESC CORTEX SEARCH SERVICE UNDERWRITING_NOTES_SEARCH;
DESC CORTEX SEARCH SERVICE LOAN_DOCUMENTS_SEARCH;
DESC CORTEX SEARCH SERVICE COMPLIANCE_POLICIES_SEARCH;
