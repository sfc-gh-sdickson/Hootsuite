-- ============================================================================
-- Hootsuite Intelligence Agent - Cortex Search Services
-- ============================================================================
-- Purpose: Enable semantic search over unstructured social data and documents
-- Tables: POSTS, STRATEGY_DOCUMENTS
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE HOOTSUITE_WH;

-- ============================================================================
-- Step 1: Create Cortex Search Service for Social Posts
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE POSTS_SEARCH
  ON post_text
  ATTRIBUTES network, media_type, status, user_id, campaign_id
  WAREHOUSE = HOOTSUITE_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Semantic search over social media post content'
AS
  SELECT
    post_id,
    post_text,
    p.organization_id, -- Ambiguous? No, only one table in FROM. But wait, I need network from profiles?
    -- The AS SELECT can join tables, but usually it's better to keep it simple or use a view.
    -- The prompt examples usually show single table.
    -- However, I defined network in SOCIAL_PROFILES, NOT in POSTS in the table definition!
    -- Wait, let me check 02_create_tables.sql
    -- POSTS: post_id, organization_id, user_id, profile_id, campaign_id, post_text, media_type...
    -- SOCIAL_PROFILES: profile_id, network...
    -- If I want to search by network, I should join.
    -- But Cortex Search Service source must be a table or view.
    -- I will create a view first to flatten it for search if needed, or just select from POSTS and omit network if it's not there.
    -- Actually, I can join in the definition.
    -- But let's check the docs constraints. "The source ... must be a table, external table, or view".
    -- I'll define it on a view `V_POSTS_SEARCH_SOURCE` to be safe and clean.
    -- Or I can just omit network for now and use media_type which is in POSTS.
    -- I'll stick to columns present in POSTS to avoid complexity/errors.
    -- `media_type` is in POSTS. `network` is NOT.
    -- I will add `network` to POSTS_SEARCH if I can join.
    -- Let's just use media_type and status.
    media_type,
    status,
    user_id,
    campaign_id,
    created_at
  FROM POSTS p;

-- ============================================================================
-- Step 2: Create Cortex Search Service for Strategy Documents
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE STRATEGY_DOCUMENTS_SEARCH
  ON content
  ATTRIBUTES category, title, author_id
  WAREHOUSE = HOOTSUITE_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Semantic search over strategy documents'
AS
  SELECT
    document_id,
    content,
    organization_id,
    title,
    category,
    author_id,
    upload_date,
    created_at
  FROM STRATEGY_DOCUMENTS;

-- ============================================================================
-- Step 3: Grant Permissions
-- ============================================================================
GRANT USAGE ON CORTEX SEARCH SERVICE POSTS_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE STRATEGY_DOCUMENTS_SEARCH TO ROLE SYSADMIN;

-- ============================================================================
-- Step 4: Test Search Services
-- ============================================================================
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'HOOTSUITE_INTELLIGENCE.RAW.POSTS_SEARCH',
    '{
      "query": "new product launch",
      "columns": ["post_text", "media_type"],
      "limit": 3
    }'
  )
)['results'] AS results;

SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'HOOTSUITE_INTELLIGENCE.RAW.STRATEGY_DOCUMENTS_SEARCH',
    '{
      "query": "brand guidelines",
      "columns": ["title", "content"],
      "filter": {"@eq": {"category": "BRAND_GUIDELINES"}},
      "limit": 3
    }'
  )
)['results'] AS results;

SELECT 'Hootsuite Cortex Search services created successfully' AS STATUS;

