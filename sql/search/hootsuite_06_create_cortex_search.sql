-- ============================================================================
-- Hootsuite Intelligence Agent - Cortex Search Services
-- ============================================================================
-- Purpose: Enable semantic search over unstructured support and knowledge data
-- Tables: SUPPORT_TICKETS, KNOWLEDGE_BASE, MARKETING_ASSETS
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE HOOTSUITE_WH;

-- ============================================================================
-- Service 1: Support Tickets Search
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE SUPPORT_TICKETS_SEARCH
  ON issue_description
  ATTRIBUTES priority, category, status, customer_id
  WAREHOUSE = HOOTSUITE_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Search support tickets for similar issues and resolutions'
AS
  SELECT
    ticket_id,
    issue_description,
    issue_summary,
    resolution_notes,
    priority,
    category,
    status,
    customer_id,
    created_at
  FROM SUPPORT_TICKETS;

-- ============================================================================
-- Service 2: Knowledge Base Search
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE KNOWLEDGE_BASE_SEARCH
  ON content_text
  ATTRIBUTES category, tags, author
  WAREHOUSE = HOOTSUITE_WH
  TARGET_LAG = '1 day'
  COMMENT = 'Search help center articles and documentation'
AS
  SELECT
    article_id,
    content_text,
    title,
    category,
    tags,
    author,
    created_at
  FROM KNOWLEDGE_BASE;

-- ============================================================================
-- Service 3: Marketing Assets Search
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE MARKETING_ASSETS_SEARCH
  ON asset_description
  ATTRIBUTES asset_type, campaign_id
  WAREHOUSE = HOOTSUITE_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Search marketing assets by visual description and type'
AS
  SELECT
    asset_id,
    asset_description,
    asset_name,
    asset_type,
    campaign_id,
    file_url,
    created_at
  FROM MARKETING_ASSETS;

-- ============================================================================
-- Grant Permissions
-- ============================================================================
GRANT USAGE ON CORTEX SEARCH SERVICE SUPPORT_TICKETS_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE KNOWLEDGE_BASE_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE MARKETING_ASSETS_SEARCH TO ROLE SYSADMIN;

SELECT 'Cortex Search Services Created Successfully' AS STATUS;
SHOW CORTEX SEARCH SERVICES IN SCHEMA RAW;
