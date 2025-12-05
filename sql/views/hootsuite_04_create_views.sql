-- ============================================================================
-- Hootsuite Intelligence Agent - Analytical and Feature Views
-- ============================================================================
-- Purpose: Create views for analysis and ML feature engineering
-- Schema: ANALYTICS
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE HOOTSUITE_WH;

-- ============================================================================
-- View 1: V_POST_PERFORMANCE_ANALYTICS
-- Purpose: General analytics on post performance
-- ============================================================================
CREATE OR REPLACE VIEW V_POST_PERFORMANCE_ANALYTICS AS
SELECT
    p.post_id,
    p.organization_id,
    o.organization_name,
    p.network,
    p.media_type,
    p.published_time,
    e.likes,
    e.shares,
    e.comments,
    e.clicks,
    e.impressions,
    e.engagement_rate,
    sp.follower_count,
    c.campaign_name
FROM RAW.POSTS p
JOIN RAW.ENGAGEMENTS e ON p.post_id = e.post_id
JOIN RAW.ORGANIZATIONS o ON p.organization_id = o.organization_id
JOIN RAW.SOCIAL_PROFILES sp ON p.profile_id = sp.profile_id
LEFT JOIN RAW.CAMPAIGNS c ON p.campaign_id = c.campaign_id;

-- ============================================================================
-- View 2: V_POST_ENGAGEMENT_FEATURES
-- Purpose: Features for predicting post engagement
-- Model: PREDICT_POST_ENGAGEMENT
-- ============================================================================
CREATE OR REPLACE VIEW V_POST_ENGAGEMENT_FEATURES AS
SELECT
    p.post_id,
    -- Features
    sp.follower_count,
    CASE WHEN sp.is_verified THEN 1 ELSE 0 END AS is_verified,
    DATEDIFF(hour, p.scheduled_time, p.published_time) AS delay_hours,
    p.media_type, -- Categorical, needs encoding
    EXTRACT(hour from p.published_time) AS hour_of_day,
    EXTRACT(dayofweek from p.published_time) AS day_of_week,
    p.sentiment_score,
    -- Target
    e.engagement_rate
FROM RAW.POSTS p
JOIN RAW.ENGAGEMENTS e ON p.post_id = e.post_id
JOIN RAW.SOCIAL_PROFILES sp ON p.profile_id = sp.profile_id
WHERE p.status = 'PUBLISHED';

-- ============================================================================
-- View 3: V_CHURN_RISK_FEATURES
-- Purpose: Features for predicting organization churn risk
-- Model: PREDICT_CHURN_RISK
-- ============================================================================
CREATE OR REPLACE VIEW V_CHURN_RISK_FEATURES AS
SELECT
    o.organization_id,
    -- Features
    o.employee_count,
    DATEDIFF(day, o.subscription_start_date, CURRENT_DATE()) AS subscription_days,
    o.plan_tier, -- Categorical
    COUNT(DISTINCT u.user_id) AS active_users_count,
    COUNT(DISTINCT st.ticket_id) AS support_tickets_count,
    COALESCE(AVG(st.satisfaction_score), 3.0) AS avg_satisfaction_score, -- Fill nulls
    -- Target (1 if inactive/churned, 0 if active)
    CASE WHEN o.is_active THEN 0 ELSE 1 END AS is_churned
FROM RAW.ORGANIZATIONS o
LEFT JOIN RAW.USERS u ON o.organization_id = u.organization_id AND u.is_active = TRUE
LEFT JOIN RAW.SUPPORT_TICKETS st ON o.organization_id = st.organization_id
GROUP BY 
    o.organization_id, 
    o.employee_count, 
    o.subscription_start_date, 
    o.plan_tier, 
    o.is_active;

-- ============================================================================
-- View 4: V_OPTIMAL_TIME_FEATURES
-- Purpose: Features for predicting optimal posting time
-- Model: PREDICT_OPTIMAL_TIME
-- ============================================================================
CREATE OR REPLACE VIEW V_OPTIMAL_TIME_FEATURES AS
SELECT
    p.post_id,
    -- Features
    o.industry, -- Categorical
    p.network, -- Categorical
    EXTRACT(hour from p.published_time) AS hour_of_day,
    EXTRACT(dayofweek from p.published_time) AS day_of_week,
    -- Target
    e.engagement_rate
FROM RAW.POSTS p
JOIN RAW.ENGAGEMENTS e ON p.post_id = e.post_id
JOIN RAW.ORGANIZATIONS o ON p.organization_id = o.organization_id
JOIN RAW.SOCIAL_PROFILES sp ON p.profile_id = sp.profile_id -- Network comes from profile in tables? No, POSTS has network... wait check POSTS table
-- POSTS table definition: profile_id REFERENCES SOCIAL_PROFILES. POSTS doesn't have network column?
-- Let's check 02_create_tables.sql content I wrote.
-- POSTS table: post_id, organization_id, user_id, profile_id, campaign_id, post_text, media_type, ...
-- SOCIAL_PROFILES table: profile_id, network, ...
-- So I need to join SOCIAL_PROFILES to get network.
;

-- Wait, I need to correct V_OPTIMAL_TIME_FEATURES because I was commenting in the SQL.
-- Let's rewrite V_OPTIMAL_TIME_FEATURES correctly.

CREATE OR REPLACE VIEW V_OPTIMAL_TIME_FEATURES AS
SELECT
    p.post_id,
    -- Features
    o.industry,
    sp.network,
    EXTRACT(hour from p.published_time) AS hour_of_day,
    EXTRACT(dayofweek from p.published_time) AS day_of_week,
    -- Target
    e.engagement_rate
FROM RAW.POSTS p
JOIN RAW.ENGAGEMENTS e ON p.post_id = e.post_id
JOIN RAW.ORGANIZATIONS o ON p.organization_id = o.organization_id
JOIN RAW.SOCIAL_PROFILES sp ON p.profile_id = sp.profile_id;

-- ============================================================================
-- Confirmation
-- ============================================================================
SELECT 'Analytical and Feature Views created successfully' AS STATUS;
SHOW VIEWS IN SCHEMA ANALYTICS;

