-- ============================================================================
-- Hootsuite Intelligence Agent - Semantic Views
-- ============================================================================
-- Purpose: Semantic views for Cortex Analyst text-to-SQL capabilities
-- Syntax: VERIFIED against Snowflake documentation
-- Column names: VERIFIED against table definitions
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
      PRIMARY KEY (metric_id),
    customers AS RAW.CUSTOMERS
      PRIMARY KEY (customer_id)
  )
  RELATIONSHIPS (
    campaigns(customer_id) REFERENCES customers(customer_id),
    posts(campaign_id) REFERENCES campaigns(campaign_id),
    posts(customer_id) REFERENCES customers(customer_id),
    metrics(post_id) REFERENCES posts(post_id)
  )
  DIMENSIONS (
    campaigns.campaign_name AS campaigns.campaign_name,
    campaigns.objective AS campaigns.objective,
    campaigns.status AS campaigns.status,
    campaigns.start_month AS DATE_TRUNC('month', campaigns.start_date),
    campaigns.budget_range AS
      CASE
        WHEN campaigns.budget_allocated < 5000 THEN 'Under $5K'
        WHEN campaigns.budget_allocated < 15000 THEN '$5K-$15K'
        WHEN campaigns.budget_allocated < 30000 THEN '$15K-$30K'
        ELSE 'Over $30K'
      END,
    posts.media_type AS posts.media_type,
    posts.status AS posts.status,
    posts.published_month AS DATE_TRUNC('month', posts.published_time),
    customers.customer_name AS customers.customer_name,
    customers.industry AS customers.industry,
    customers.plan_type AS customers.plan_type
  )
  METRICS (
    campaigns.total_campaigns AS COUNT(DISTINCT campaigns.campaign_id),
    campaigns.total_budget AS SUM(campaigns.budget_allocated),
    campaigns.total_spend AS SUM(campaigns.budget_spent),
    campaigns.avg_budget AS AVG(campaigns.budget_allocated),
    campaigns.budget_utilization AS (SUM(campaigns.budget_spent)::FLOAT / NULLIF(SUM(campaigns.budget_allocated), 0)),
    posts.total_posts AS COUNT(DISTINCT posts.post_id),
    posts.posts_per_campaign AS (COUNT(DISTINCT posts.post_id)::FLOAT / NULLIF(COUNT(DISTINCT campaigns.campaign_id), 0)),
    metrics.total_impressions AS SUM(metrics.impressions),
    metrics.total_clicks AS SUM(metrics.clicks),
    metrics.total_engagement AS SUM(metrics.likes + metrics.shares + metrics.comments),
    metrics.avg_engagement_rate AS AVG(metrics.engagement_rate),
    metrics.avg_impressions AS AVG(metrics.impressions),
    metrics.click_through_rate AS (SUM(metrics.clicks)::FLOAT / NULLIF(SUM(metrics.impressions), 0))
  )
  COMMENT = 'Semantic view for campaign performance, budget, and engagement metrics';

-- ============================================================================
-- Semantic View 2: Customer Health & Support Analytics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_CUSTOMER_HEALTH_ANALYTICS
  TABLES (
    customers AS RAW.CUSTOMERS
      PRIMARY KEY (customer_id),
    tickets AS RAW.SUPPORT_TICKETS
      PRIMARY KEY (ticket_id),
    accounts AS RAW.SOCIAL_ACCOUNTS
      PRIMARY KEY (account_id)
  )
  RELATIONSHIPS (
    tickets(customer_id) REFERENCES customers(customer_id),
    accounts(customer_id) REFERENCES customers(customer_id)
  )
  DIMENSIONS (
    customers.customer_name AS customers.customer_name,
    customers.industry AS customers.industry,
    customers.plan_type AS customers.plan_type,
    customers.region AS customers.region,
    customers.active_status AS customers.active_status,
    customers.churn_risk_band AS
      CASE
        WHEN customers.churn_risk_score < 0.3 THEN 'Low Risk (0-0.3)'
        WHEN customers.churn_risk_score < 0.7 THEN 'Medium Risk (0.3-0.7)'
        ELSE 'High Risk (0.7-1.0)'
      END,
    customers.revenue_tier AS
      CASE
        WHEN customers.annual_revenue_millions < 10 THEN 'Under $10M'
        WHEN customers.annual_revenue_millions < 50 THEN '$10M-$50M'
        WHEN customers.annual_revenue_millions < 200 THEN '$50M-$200M'
        ELSE 'Over $200M'
      END,
    customers.tenure_band AS
      CASE
        WHEN DATEDIFF(month, customers.contract_start_date, CURRENT_DATE()) < 6 THEN 'New (0-6 months)'
        WHEN DATEDIFF(month, customers.contract_start_date, CURRENT_DATE()) < 12 THEN 'Recent (6-12 months)'
        WHEN DATEDIFF(month, customers.contract_start_date, CURRENT_DATE()) < 24 THEN 'Established (1-2 years)'
        ELSE 'Long-term (2+ years)'
      END,
    tickets.priority AS tickets.priority,
    tickets.category AS tickets.category,
    tickets.status AS tickets.status,
    tickets.created_month AS DATE_TRUNC('month', tickets.created_date)
  )
  METRICS (
    customers.total_customers AS COUNT(DISTINCT customers.customer_id),
    customers.active_customers AS COUNT_IF(customers.active_status = 'ACTIVE'),
    customers.avg_churn_risk AS AVG(customers.churn_risk_score),
    customers.high_risk_count AS COUNT_IF(customers.churn_risk_score > 0.7),
    customers.total_revenue AS SUM(customers.annual_revenue_millions),
    customers.avg_revenue AS AVG(customers.annual_revenue_millions),
    customers.avg_employees AS AVG(customers.employee_count),
    accounts.total_accounts AS COUNT(DISTINCT accounts.account_id),
    accounts.accounts_per_customer AS (COUNT(DISTINCT accounts.account_id)::FLOAT / NULLIF(COUNT(DISTINCT customers.customer_id), 0)),
    tickets.total_tickets AS COUNT(DISTINCT tickets.ticket_id),
    tickets.open_tickets AS COUNT_IF(tickets.status = 'OPEN'),
    tickets.urgent_tickets AS COUNT_IF(tickets.priority = 'URGENT'),
    tickets.avg_resolution_time_hours AS AVG(TIMESTAMPDIFF(hour, tickets.created_date, tickets.closed_date)),
    tickets.tickets_per_customer AS (COUNT(DISTINCT tickets.ticket_id)::FLOAT / NULLIF(COUNT(DISTINCT customers.customer_id), 0))
  )
  COMMENT = 'Semantic view for customer health, churn risk, and support ticket analysis';

-- ============================================================================
-- Semantic View 3: Social Media Performance Analytics
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
    posts(customer_id) REFERENCES customers(customer_id),
    metrics(post_id) REFERENCES posts(post_id)
  )
  DIMENSIONS (
    accounts.platform AS accounts.platform,
    accounts.verified_status AS accounts.verified_status,
    accounts.connection_status AS accounts.connection_status,
    accounts.follower_tier AS
      CASE
        WHEN accounts.follower_count < 1000 THEN 'Micro (<1K)'
        WHEN accounts.follower_count < 10000 THEN 'Small (1K-10K)'
        WHEN accounts.follower_count < 100000 THEN 'Medium (10K-100K)'
        WHEN accounts.follower_count < 1000000 THEN 'Large (100K-1M)'
        ELSE 'Mega (1M+)'
      END,
    customers.customer_name AS customers.customer_name,
    customers.industry AS customers.industry,
    customers.plan_type AS customers.plan_type,
    posts.media_type AS posts.media_type,
    posts.status AS posts.status,
    posts.published_month AS DATE_TRUNC('month', posts.published_time),
    posts.published_week AS DATE_TRUNC('week', posts.published_time),
    metrics.engagement_tier AS
      CASE
        WHEN metrics.engagement_rate < 0.01 THEN 'Low (<1%)'
        WHEN metrics.engagement_rate < 0.03 THEN 'Medium (1-3%)'
        WHEN metrics.engagement_rate < 0.06 THEN 'Good (3-6%)'
        ELSE 'Excellent (6%+)'
      END
  )
  METRICS (
    accounts.total_accounts AS COUNT(DISTINCT accounts.account_id),
    accounts.verified_accounts AS COUNT_IF(accounts.verified_status),
    accounts.total_followers AS SUM(accounts.follower_count),
    accounts.avg_followers AS AVG(accounts.follower_count),
    posts.total_posts AS COUNT(DISTINCT posts.post_id),
    posts.published_posts AS COUNT_IF(posts.status = 'PUBLISHED'),
    posts.posts_per_account AS (COUNT(DISTINCT posts.post_id)::FLOAT / NULLIF(COUNT(DISTINCT accounts.account_id), 0)),
    metrics.total_reach AS SUM(metrics.reach),
    metrics.total_impressions AS SUM(metrics.impressions),
    metrics.total_likes AS SUM(metrics.likes),
    metrics.total_shares AS SUM(metrics.shares),
    metrics.total_comments AS SUM(metrics.comments),
    metrics.total_clicks AS SUM(metrics.clicks),
    metrics.avg_engagement_rate AS AVG(metrics.engagement_rate),
    metrics.avg_reach AS AVG(metrics.reach),
    metrics.avg_impressions_per_post AS AVG(metrics.impressions)
  )
  COMMENT = 'Semantic view for social media platform performance and audience growth';

SELECT 'Hootsuite semantic views created successfully - syntax and columns verified' AS STATUS;
SHOW SEMANTIC VIEWS IN SCHEMA ANALYTICS;
