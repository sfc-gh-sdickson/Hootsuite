-- ============================================================================
-- Hootsuite Intelligence Agent - Semantic Views
-- ============================================================================
-- Purpose: Semantic views for Cortex Analyst text-to-SQL capabilities
-- Syntax: VERIFIED against Snowflake documentation
-- Rule: TABLE.SEMANTIC_NAME AS ACTUAL_COLUMN
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE HOOTSUITE_WH;

-- ============================================================================
-- Semantic View 1: Social Media Performance
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_SOCIAL_PERFORMANCE
  TABLES (
    posts AS RAW.POSTS
      PRIMARY KEY (post_id),
    engagements AS RAW.ENGAGEMENTS
      PRIMARY KEY (engagement_id),
    profiles AS RAW.SOCIAL_PROFILES
      PRIMARY KEY (profile_id),
    organizations AS RAW.ORGANIZATIONS
      PRIMARY KEY (organization_id),
    campaigns AS RAW.CAMPAIGNS
      PRIMARY KEY (campaign_id)
  )
  RELATIONSHIPS (
    posts(post_id) REFERENCES engagements(post_id),
    posts(profile_id) REFERENCES profiles(profile_id),
    posts(organization_id) REFERENCES organizations(organization_id),
    posts(campaign_id) REFERENCES campaigns(campaign_id),
    profiles(organization_id) REFERENCES organizations(organization_id),
    campaigns(organization_id) REFERENCES organizations(organization_id)
  )
  DIMENSIONS (
    posts.media_type AS posts.media_type,
    posts.status AS posts.status,
    posts.published_date AS posts.published_time::DATE,
    profiles.network AS profiles.network,
    profiles.profile_name AS profiles.profile_name,
    profiles.is_verified AS profiles.is_verified,
    organizations.organization_name AS organizations.organization_name,
    organizations.industry AS organizations.industry,
    organizations.plan_tier AS organizations.plan_tier,
    organizations.country AS organizations.country,
    campaigns.campaign_name AS campaigns.campaign_name,
    campaigns.campaign_status AS campaigns.status
  )
  METRICS (
    posts.total_posts AS COUNT(DISTINCT posts.post_id),
    posts.avg_sentiment AS AVG(posts.sentiment_score),
    engagements.total_likes AS SUM(engagements.likes),
    engagements.total_shares AS SUM(engagements.shares),
    engagements.total_comments AS SUM(engagements.comments),
    engagements.total_clicks AS SUM(engagements.clicks),
    engagements.total_impressions AS SUM(engagements.impressions),
    engagements.avg_engagement_rate AS AVG(engagements.engagement_rate),
    profiles.total_followers AS SUM(profiles.follower_count),
    campaigns.total_budget AS SUM(campaigns.budget_amount)
  )
  COMMENT = 'Semantic view for social media performance, engagement, and campaign analytics';

-- ============================================================================
-- Confirmation
-- ============================================================================
SELECT 'Hootsuite semantic views created successfully' AS STATUS;
SHOW SEMANTIC VIEWS IN SCHEMA ANALYTICS;

