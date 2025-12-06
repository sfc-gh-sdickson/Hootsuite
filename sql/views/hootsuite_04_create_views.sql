-- ============================================================================
-- Hootsuite Intelligence Agent - Analytical and Feature Views
-- ============================================================================
-- Purpose: Create analytical views for reporting and ML feature views for model training
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE HOOTSUITE_WH;

-- ============================================================================
-- ANALYTICAL VIEWS
-- ============================================================================

-- View 1: Campaign Performance ROI
CREATE OR REPLACE VIEW V_CAMPAIGN_PERFORMANCE AS
SELECT 
    c.campaign_id,
    c.campaign_name,
    c.customer_id,
    c.objective,
    c.budget_allocated,
    c.budget_spent,
    c.status,
    COUNT(DISTINCT p.post_id) as total_posts,
    SUM(m.impressions) as total_impressions,
    SUM(m.clicks) as total_clicks,
    SUM(m.likes + m.shares + m.comments) as total_engagements,
    CASE 
        WHEN c.budget_spent > 0 THEN (SUM(m.clicks) / c.budget_spent) * 100 
        ELSE 0 
    END as calculated_roi_percent
FROM RAW.CAMPAIGNS c
LEFT JOIN RAW.POSTS p ON c.campaign_id = p.campaign_id
LEFT JOIN RAW.ENGAGEMENT_METRICS m ON p.post_id = m.post_id
GROUP BY c.campaign_id, c.campaign_name, c.customer_id, c.objective, c.budget_allocated, c.budget_spent, c.status;

-- View 2: Customer Health360
CREATE OR REPLACE VIEW V_CUSTOMER_HEALTH_360 AS
SELECT
    c.customer_id,
    c.customer_name,
    c.plan_type,
    c.industry,
    c.annual_revenue_millions,
    c.churn_risk_score,
    COUNT(DISTINCT sa.account_id) as connected_accounts,
    COUNT(DISTINCT t.ticket_id) as total_tickets,
    COUNT(DISTINCT CASE WHEN t.status = 'OPEN' THEN t.ticket_id END) as open_tickets,
    MAX(t.created_date) as last_ticket_date,
    AVG(CASE WHEN t.priority = 'URGENT' THEN 1 ELSE 0 END) as urgent_ticket_ratio
FROM RAW.CUSTOMERS c
LEFT JOIN RAW.SOCIAL_ACCOUNTS sa ON c.customer_id = sa.customer_id
LEFT JOIN RAW.SUPPORT_TICKETS t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.customer_name, c.plan_type, c.industry, c.annual_revenue_millions, c.churn_risk_score;

-- View 3: Social Channel Engagement
CREATE OR REPLACE VIEW V_CHANNEL_ENGAGEMENT AS
SELECT
    sa.platform,
    sa.account_id,
    c.industry,
    DATE_TRUNC('month', m.metric_date) as month,
    AVG(m.engagement_rate) as avg_engagement_rate,
    SUM(m.impressions) as total_impressions,
    SUM(m.reach) as total_reach
FROM RAW.SOCIAL_ACCOUNTS sa
JOIN RAW.CUSTOMERS c ON sa.customer_id = c.customer_id
JOIN RAW.POSTS p ON sa.account_id = p.account_id
JOIN RAW.ENGAGEMENT_METRICS m ON p.post_id = m.post_id
GROUP BY sa.platform, sa.account_id, c.industry, DATE_TRUNC('month', m.metric_date);

-- ============================================================================
-- ML FEATURE VIEWS
-- ============================================================================

-- Feature View 1: Churn Risk Prediction Features
CREATE OR REPLACE VIEW V_CHURN_RISK_FEATURES AS
SELECT
    c.customer_id,
    c.plan_type,
    c.industry,
    c.employee_count,
    c.annual_revenue_millions,
    DATEDIFF(month, c.contract_start_date, CURRENT_DATE()) as tenure_months,
    COUNT(DISTINCT sa.account_id) as social_accounts_count,
    COUNT(DISTINCT t.ticket_id) as total_tickets_last_90d,
    AVG(CASE WHEN t.priority = 'URGENT' THEN 1.0 ELSE 0.0 END) as urgent_ticket_rate,
    -- Label Generation
    CASE 
        WHEN c.churn_risk_score > 0.7 THEN 2 -- High Risk
        WHEN c.churn_risk_score > 0.3 THEN 1 -- Medium Risk
        ELSE 0 -- Low Risk
    END as churn_risk_label
FROM RAW.CUSTOMERS c
LEFT JOIN RAW.SOCIAL_ACCOUNTS sa ON c.customer_id = sa.customer_id
LEFT JOIN RAW.SUPPORT_TICKETS t ON c.customer_id = t.customer_id AND t.created_date >= DATEADD(day, -90, CURRENT_DATE())
GROUP BY c.customer_id, c.plan_type, c.industry, c.employee_count, c.annual_revenue_millions, c.contract_start_date, c.churn_risk_score;

-- Feature View 2: Campaign ROI Prediction Features
CREATE OR REPLACE VIEW V_CAMPAIGN_ROI_FEATURES AS
SELECT
    c.campaign_id,
    c.objective,
    c.budget_allocated,
    DATEDIFF(day, c.start_date, c.end_date) as duration_days,
    COUNT(DISTINCT p.post_id) as num_posts,
    COUNT(DISTINCT CASE WHEN p.media_type = 'VIDEO' THEN p.post_id END) as num_video_posts,
    -- Label Generation
    CASE 
        WHEN (SUM(m.clicks) / NULLIF(c.budget_allocated, 0)) > 0.05 THEN 2 -- High ROI
        WHEN (SUM(m.clicks) / NULLIF(c.budget_allocated, 0)) > 0.01 THEN 1 -- Medium ROI
        ELSE 0 -- Low ROI
    END as roi_label
FROM RAW.CAMPAIGNS c
JOIN RAW.POSTS p ON c.campaign_id = p.campaign_id
LEFT JOIN RAW.ENGAGEMENT_METRICS m ON p.post_id = m.post_id
WHERE c.budget_allocated > 0
GROUP BY c.campaign_id, c.objective, c.budget_allocated, c.start_date, c.end_date;

-- Feature View 3: Ticket Priority Classification Features
CREATE OR REPLACE VIEW V_TICKET_PRIORITY_FEATURES AS
SELECT
    ticket_id,
    issue_summary,
    category,
    CASE 
        WHEN priority = 'URGENT' THEN 3
        WHEN priority = 'HIGH' THEN 2
        WHEN priority = 'MEDIUM' THEN 1
        ELSE 0 -- LOW
    END as priority_label
FROM RAW.SUPPORT_TICKETS;

SELECT 'Analytical and Feature Views Created Successfully' as status;
