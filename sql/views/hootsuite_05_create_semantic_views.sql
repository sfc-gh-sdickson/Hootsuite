-- ============================================================================
-- Hootsuite Intelligence Agent - Semantic Views
-- ============================================================================
-- Purpose: Semantic views for Cortex Analyst text-to-SQL capabilities
-- Syntax: VERIFIED against Snowflake documentation
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE HOOTSUITE_WH;

-- ============================================================================
-- Semantic View 1: Campaign Performance Analytics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_CAMPAIGN_ANALYTICS
  TABLES (
    campaigns AS RAW.CAMPAIGNS
      PRIMARY KEY (campaign_id),
    posts AS RAW.POSTS
      PRIMARY KEY (post_id),
    metrics AS RAW.ENGAGEMENT_METRICS
      PRIMARY KEY (metric_id)
  )
  RELATIONSHIPS (
    posts(campaign_id) REFERENCES campaigns(campaign_id),
    metrics(post_id) REFERENCES posts(post_id)
  )
  DIMENSIONS (
    campaigns.campaign_name AS campaigns.campaign_name,
    campaigns.objective AS campaigns.objective,
    campaigns.status AS campaigns.status,
    campaigns.start_date AS campaigns.start_date,
    campaigns.end_date AS campaigns.end_date,
    posts.media_type AS posts.media_type,
    posts.published_date AS posts.published_time::DATE
  )
  METRICS (
    campaigns.total_budget AS SUM(campaigns.budget_allocated),
    campaigns.total_spend AS SUM(campaigns.budget_spent),
    metrics.total_impressions AS SUM(metrics.impressions),
    metrics.total_clicks AS SUM(metrics.clicks),
    metrics.total_engagement AS SUM(metrics.likes + metrics.shares + metrics.comments),
    metrics.avg_engagement_rate AS AVG(metrics.engagement_rate)
  )
  COMMENT = 'Semantic view for campaign performance, budget, and engagement metrics';

-- ============================================================================
-- Semantic View 2: Customer Health & Churn Analysis
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_CUSTOMER_HEALTH_ANALYTICS
  TABLES (
    customers AS RAW.CUSTOMERS
      PRIMARY KEY (customer_id),
    tickets AS RAW.SUPPORT_TICKETS
      PRIMARY KEY (ticket_id)
  )
  RELATIONSHIPS (
    tickets(customer_id) REFERENCES customers(customer_id)
  )
  DIMENSIONS (
    customers.customer_name AS customers.customer_name,
    customers.industry AS customers.industry,
    customers.plan_type AS customers.plan_type,
    customers.region AS customers.region,
    customers.active_status AS customers.active_status,
    tickets.priority AS tickets.priority,
    tickets.category AS tickets.category,
    tickets.status AS tickets.status,
    tickets.created_date AS tickets.created_date::DATE
  )
  METRICS (
    customers.total_customers AS COUNT(DISTINCT customers.customer_id),
    customers.avg_churn_risk AS AVG(customers.churn_risk_score),
    customers.total_revenue AS SUM(customers.annual_revenue_millions),
    tickets.total_tickets AS COUNT(DISTINCT tickets.ticket_id),
    tickets.open_tickets AS COUNT_IF(tickets.status = 'OPEN'),
    tickets.avg_resolution_time_hours AS AVG(TIMESTAMPDIFF(hour, tickets.created_date, tickets.closed_date))
  )
  COMMENT = 'Semantic view for customer health, churn risk, and support ticket analysis';

-- ============================================================================
-- Semantic View 3: Social Account & Platform Performance
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_SOCIAL_PERFORMANCE
  TABLES (
    accounts AS RAW.SOCIAL_ACCOUNTS
      PRIMARY KEY (account_id),
    customers AS RAW.CUSTOMERS
      PRIMARY KEY (customer_id),
    posts AS RAW.POSTS
      PRIMARY KEY (post_id),
    metrics AS RAW.ENGAGEMENT_METRICS
      PRIMARY KEY (metric_id)
  )
  RELATIONSHIPS (
    accounts(customer_id) REFERENCES customers(customer_id),
    posts(account_id) REFERENCES accounts(account_id),
    metrics(post_id) REFERENCES posts(post_id)
  )
  DIMENSIONS (
    accounts.platform AS accounts.platform,
    accounts.verified_status AS accounts.verified_status,
    customers.industry AS customers.industry,
    posts.media_type AS posts.media_type,
    posts.status AS posts.status,
    posts.published_date AS posts.published_time::DATE
  )
  METRICS (
    accounts.total_followers AS SUM(accounts.follower_count),
    accounts.avg_followers AS AVG(accounts.follower_count),
    posts.total_posts AS COUNT(DISTINCT posts.post_id),
    metrics.total_reach AS SUM(metrics.reach),
    metrics.total_likes AS SUM(metrics.likes),
    metrics.total_shares AS SUM(metrics.shares)
  )
  COMMENT = 'Semantic view for social media platform performance and audience growth';

SELECT 'Semantic Views Created Successfully' AS STATUS;
SHOW SEMANTIC VIEWS IN SCHEMA ANALYTICS;
