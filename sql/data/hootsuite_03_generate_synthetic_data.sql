-- ============================================================================
-- Hootsuite Intelligence Agent - Synthetic Data Generation
-- ============================================================================
-- Purpose: Generate realistic synthetic data for Hootsuite platform
-- Tables: ORGANIZATIONS, USERS, SOCIAL_PROFILES, CAMPAIGNS, POSTS, ENGAGEMENTS, SUPPORT_TICKETS, STRATEGY_DOCUMENTS
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE HOOTSUITE_WH;

-- ============================================================================
-- Table 1: ORGANIZATIONS (100 rows)
-- ============================================================================
INSERT INTO ORGANIZATIONS
SELECT
    'ORG' || LPAD(SEQ4()::VARCHAR, 6, '0') AS organization_id,
    'Organization ' || SEQ4() AS organization_name,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'Retail'
        WHEN 1 THEN 'Technology'
        WHEN 2 THEN 'Healthcare'
        WHEN 3 THEN 'Finance'
        ELSE 'Education'
    END AS industry,
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 'PROFESSIONAL'
        WHEN 1 THEN 'TEAM'
        WHEN 2 THEN 'BUSINESS'
        ELSE 'ENTERPRISE'
    END AS plan_tier,
    DATEADD(day, -UNIFORM(1, 1000, RANDOM()), CURRENT_DATE()) AS subscription_start_date,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'USA'
        WHEN 1 THEN 'Canada'
        WHEN 2 THEN 'UK'
        WHEN 3 THEN 'Australia'
        ELSE 'Germany'
    END AS country,
    UNIFORM(10, 5000, RANDOM()) AS employee_count,
    CASE WHEN UNIFORM(1, 100, RANDOM()) > 10 THEN TRUE ELSE FALSE END AS is_active,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 100));

SELECT 'ORGANIZATIONS: ' || COUNT(*) || ' rows inserted' AS status FROM ORGANIZATIONS;

-- ============================================================================
-- Table 2: USERS (500 rows)
-- ============================================================================
INSERT INTO USERS
SELECT
    'USR' || LPAD(SEQ4()::VARCHAR, 6, '0') AS user_id,
    (SELECT organization_id FROM ORGANIZATIONS ORDER BY RANDOM() LIMIT 1) AS organization_id,
    'User ' || SEQ4() AS full_name,
    'user' || SEQ4() || '@example.com' AS email,
    CASE MOD(SEQ4(), 3)
        WHEN 0 THEN 'ADMIN'
        WHEN 1 THEN 'EDITOR'
        ELSE 'VIEWER'
    END AS role,
    DATEADD(hour, -UNIFORM(1, 1000, RANDOM()), CURRENT_TIMESTAMP()) AS last_login_date,
    CASE WHEN UNIFORM(1, 100, RANDOM()) > 5 THEN TRUE ELSE FALSE END AS is_active,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 500));

SELECT 'USERS: ' || COUNT(*) || ' rows inserted' AS status FROM USERS;

-- ============================================================================
-- Table 3: SOCIAL_PROFILES (300 rows)
-- ============================================================================
INSERT INTO SOCIAL_PROFILES
SELECT
    'PRF' || LPAD(SEQ4()::VARCHAR, 6, '0') AS profile_id,
    (SELECT organization_id FROM ORGANIZATIONS ORDER BY RANDOM() LIMIT 1) AS organization_id,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'FACEBOOK'
        WHEN 1 THEN 'TWITTER'
        WHEN 2 THEN 'LINKEDIN'
        WHEN 3 THEN 'INSTAGRAM'
        ELSE 'TIKTOK'
    END AS network,
    'Profile ' || SEQ4() AS profile_name,
    UNIFORM(100, 1000000, RANDOM()) AS follower_count,
    CASE WHEN UNIFORM(1, 100, RANDOM()) > 80 THEN TRUE ELSE FALSE END AS is_verified,
    DATEADD(day, -UNIFORM(1, 500, RANDOM()), CURRENT_DATE()) AS connected_date,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 300));

SELECT 'SOCIAL_PROFILES: ' || COUNT(*) || ' rows inserted' AS status FROM SOCIAL_PROFILES;

-- ============================================================================
-- Table 4: CAMPAIGNS (200 rows)
-- ============================================================================
INSERT INTO CAMPAIGNS
SELECT
    'CMP' || LPAD(SEQ4()::VARCHAR, 6, '0') AS campaign_id,
    (SELECT organization_id FROM ORGANIZATIONS ORDER BY RANDOM() LIMIT 1) AS organization_id,
    'Campaign ' || SEQ4() AS campaign_name,
    DATEADD(day, -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS start_date,
    DATEADD(day, UNIFORM(1, 30, RANDOM()), CURRENT_DATE()) AS end_date,
    UNIFORM(1000, 50000, RANDOM()) AS budget_amount,
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 'PLANNED'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'COMPLETED'
        ELSE 'PAUSED'
    END AS status,
    'Description for campaign ' || SEQ4() AS description,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 200));

SELECT 'CAMPAIGNS: ' || COUNT(*) || ' rows inserted' AS status FROM CAMPAIGNS;

-- ============================================================================
-- Table 5: POSTS (10,000 rows)
-- ============================================================================
-- Create temporary tables for random selection to avoid correlated subqueries in GENERATOR
CREATE TEMPORARY TABLE temp_users AS SELECT user_id, organization_id FROM USERS;
CREATE TEMPORARY TABLE temp_profiles AS SELECT profile_id, organization_id, network FROM SOCIAL_PROFILES;
CREATE TEMPORARY TABLE temp_campaigns AS SELECT campaign_id, organization_id FROM CAMPAIGNS;

INSERT INTO POSTS
WITH post_gen AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY SEQ4()) AS rn,
        UNIFORM(1, 500, RANDOM()) AS user_idx,
        UNIFORM(1, 300, RANDOM()) AS profile_idx,
        UNIFORM(1, 200, RANDOM()) AS campaign_idx
    FROM TABLE(GENERATOR(ROWCOUNT => 10000))
),
users_numbered AS (
    SELECT user_id, organization_id, ROW_NUMBER() OVER (ORDER BY RANDOM()) AS idx FROM temp_users
),
profiles_numbered AS (
    SELECT profile_id, organization_id, network, ROW_NUMBER() OVER (ORDER BY RANDOM()) AS idx FROM temp_profiles
),
campaigns_numbered AS (
    SELECT campaign_id, organization_id, ROW_NUMBER() OVER (ORDER BY RANDOM()) AS idx FROM temp_campaigns
)
SELECT
    'PST' || LPAD(pg.rn::VARCHAR, 8, '0') AS post_id,
    u.organization_id, -- Use user's org to ensure consistency
    u.user_id,
    p.profile_id,
    c.campaign_id,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'Exciting news! We are launching a new product next week. Stay tuned for updates! #launch #newproduct'
        WHEN 2 THEN 'Check out our latest blog post on industry trends. Link in bio. #insights #industry'
        WHEN 3 THEN 'We love our customers! Thank you for your continued support. #customerlove #thankyou'
        WHEN 4 THEN 'Join us for a webinar on social media best practices. Register now! #webinar #learning'
        ELSE 'Happy Friday! What are your plans for the weekend? #weekendvibes #friday'
    END AS post_text,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'IMAGE'
        WHEN 2 THEN 'VIDEO'
        WHEN 3 THEN 'LINK'
        ELSE 'TEXT'
    END AS media_type,
    DATEADD(minute, UNIFORM(1, 10000, RANDOM()), DATEADD(day, -365, CURRENT_TIMESTAMP())) AS scheduled_time,
    scheduled_time AS published_time,
    'PUBLISHED' AS status,
    UNIFORM(0, 100, RANDOM()) / 100.0 AS sentiment_score,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM post_gen pg
LEFT JOIN users_numbered u ON MOD(pg.user_idx, 500) + 1 = u.idx
LEFT JOIN profiles_numbered p ON MOD(pg.profile_idx, 300) + 1 = p.idx
LEFT JOIN campaigns_numbered c ON MOD(pg.campaign_idx, 200) + 1 = c.idx
-- Fallback for unmatched joins to avoid NULLs in NOT NULL columns if any
WHERE u.user_id IS NOT NULL; 

SELECT 'POSTS: ' || COUNT(*) || ' rows inserted' AS status FROM POSTS;

-- ============================================================================
-- Table 6: ENGAGEMENTS (10,000 rows - 1:1 with Posts for simplicity)
-- ============================================================================
INSERT INTO ENGAGEMENTS
SELECT
    'ENG' || LPAD(ROW_NUMBER() OVER (ORDER BY post_id)::VARCHAR, 8, '0') AS engagement_id,
    post_id,
    UNIFORM(0, 1000, RANDOM()) AS likes,
    UNIFORM(0, 200, RANDOM()) AS shares,
    UNIFORM(0, 100, RANDOM()) AS comments,
    UNIFORM(0, 500, RANDOM()) AS clicks,
    UNIFORM(100, 10000, RANDOM()) AS impressions,
    UNIFORM(50, 5000, RANDOM()) AS reach,
    (likes + shares + comments + clicks)::FLOAT / NULLIF(impressions, 0) AS engagement_rate,
    published_time::DATE AS recorded_date,
    CURRENT_TIMESTAMP() AS created_at
FROM POSTS;

SELECT 'ENGAGEMENTS: ' || COUNT(*) || ' rows inserted' AS status FROM ENGAGEMENTS;

-- ============================================================================
-- Table 7: SUPPORT_TICKETS (2,000 rows)
-- ============================================================================
INSERT INTO SUPPORT_TICKETS
SELECT
    'TKT' || LPAD(SEQ4()::VARCHAR, 6, '0') AS ticket_id,
    (SELECT organization_id FROM ORGANIZATIONS ORDER BY RANDOM() LIMIT 1) AS organization_id,
    (SELECT user_id FROM USERS ORDER BY RANDOM() LIMIT 1) AS user_id,
    CASE MOD(SEQ4(), 3)
        WHEN 0 THEN 'BILLING'
        WHEN 1 THEN 'TECHNICAL'
        ELSE 'FEATURE_REQUEST'
    END AS issue_category,
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 'LOW'
        WHEN 1 THEN 'MEDIUM'
        WHEN 2 THEN 'HIGH'
        ELSE 'URGENT'
    END AS priority,
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 'OPEN'
        WHEN 1 THEN 'IN_PROGRESS'
        WHEN 2 THEN 'RESOLVED'
        ELSE 'CLOSED'
    END AS status,
    DATEADD(day, -UNIFORM(1, 365, RANDOM()), CURRENT_TIMESTAMP()) AS created_date,
    DATEADD(hour, UNIFORM(1, 72, RANDOM()), created_date) AS resolved_date,
    UNIFORM(1, 5, RANDOM()) AS satisfaction_score,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 2000));

SELECT 'SUPPORT_TICKETS: ' || COUNT(*) || ' rows inserted' AS status FROM SUPPORT_TICKETS;

-- ============================================================================
-- Table 8: STRATEGY_DOCUMENTS (500 rows)
-- ============================================================================
INSERT INTO STRATEGY_DOCUMENTS
SELECT
    'DOC' || LPAD(SEQ4()::VARCHAR, 6, '0') AS document_id,
    (SELECT organization_id FROM ORGANIZATIONS ORDER BY RANDOM() LIMIT 1) AS organization_id,
    'Strategy Document ' || SEQ4() AS title,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'Comprehensive content strategy for Q1. Focus on video content and user engagement.'
        WHEN 1 THEN 'Brand guidelines 2024. Use official logo and color palette #000000 and #FFFFFF.'
        WHEN 2 THEN 'Campaign brief for Summer Sale. Target audience: Gen Z. Key channels: TikTok, Instagram.'
        WHEN 3 THEN 'Crisis management protocol. In case of negative PR, follow these steps immediately.'
        ELSE 'Influencer outreach plan. Identify key opinion leaders in the tech space and engage.'
    END AS content,
    CASE MOD(SEQ4(), 3)
        WHEN 0 THEN 'CONTENT_STRATEGY'
        WHEN 1 THEN 'BRAND_GUIDELINES'
        ELSE 'CAMPAIGN_BRIEF'
    END AS category,
    (SELECT user_id FROM USERS ORDER BY RANDOM() LIMIT 1) AS author_id,
    DATEADD(day, -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS upload_date,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 500));

SELECT 'STRATEGY_DOCUMENTS: ' || COUNT(*) || ' rows inserted' AS status FROM STRATEGY_DOCUMENTS;

-- Clean up
DROP TABLE IF EXISTS temp_users;
DROP TABLE IF EXISTS temp_profiles;
DROP TABLE IF EXISTS temp_campaigns;

SELECT 'Data Generation Complete' AS STATUS;

