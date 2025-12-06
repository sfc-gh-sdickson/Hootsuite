-- ============================================================================
-- Hootsuite ML Model Functions
-- ============================================================================
-- Creates SQL UDF wrappers for ML model inference
-- These functions are called by the Intelligence Agent
-- Execution time: <10 seconds per function call
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA ML_MODELS;
USE WAREHOUSE HOOTSUITE_WH;

-- ============================================================================
-- Function 1: Predict Customer Churn Risk
-- ============================================================================
-- Returns: Summary string with risk distribution
-- Input: industry_filter (RETAIL, TECHNOLOGY, etc., or NULL)
-- Analyzes 100 customers from portfolio

CREATE OR REPLACE FUNCTION PREDICT_CHURN_RISK(industry_filter VARCHAR)
RETURNS VARCHAR
AS
$$
    SELECT 
        'Total Customers: ' || COUNT(*) || 
        ', Low Risk: ' || SUM(CASE WHEN pred:PREDICTED_RISK::INT = 0 THEN 1 ELSE 0 END) ||
        ', Medium Risk: ' || SUM(CASE WHEN pred:PREDICTED_RISK::INT = 1 THEN 1 ELSE 0 END) ||
        ', High Risk: ' || SUM(CASE WHEN pred:PREDICTED_RISK::INT = 2 THEN 1 ELSE 0 END)
    FROM (
        SELECT 
            CHURN_RISK_PREDICTOR!PREDICT(
                plan_type, industry, employee_count, annual_revenue_millions,
                tenure_months, social_accounts_count, total_tickets_last_90d
            ) as pred
        FROM HOOTSUITE_INTELLIGENCE.ANALYTICS.V_CHURN_RISK_FEATURES
        WHERE industry_filter IS NULL OR industry = industry_filter
        LIMIT 100
    )
$$;

-- ============================================================================
-- Function 2: Predict Campaign ROI
-- ============================================================================
-- Returns: Summary string with ROI statistics
-- Input: objective_filter (AWARENESS, CONVERSION, TRAFFIC, or NULL)
-- Analyzes 100 campaigns

CREATE OR REPLACE FUNCTION PREDICT_CAMPAIGN_ROI(objective_filter VARCHAR)
RETURNS VARCHAR
AS
$$
    SELECT 
        'Total Campaigns: ' || COUNT(*) ||
        ', Low ROI: ' || SUM(CASE WHEN pred:PREDICTED_ROI::INT = 0 THEN 1 ELSE 0 END) ||
        ', Medium ROI: ' || SUM(CASE WHEN pred:PREDICTED_ROI::INT = 1 THEN 1 ELSE 0 END) ||
        ', High ROI: ' || SUM(CASE WHEN pred:PREDICTED_ROI::INT = 2 THEN 1 ELSE 0 END)
    FROM (
        SELECT 
            CAMPAIGN_ROI_PREDICTOR!PREDICT(
                objective, budget_allocated, duration_days, num_posts, num_video_posts
            ) as pred
        FROM HOOTSUITE_INTELLIGENCE.ANALYTICS.V_CAMPAIGN_ROI_FEATURES
        WHERE objective_filter IS NULL OR objective = objective_filter
        LIMIT 100
    )
$$;

-- ============================================================================
-- Function 3: Classify Ticket Priority
-- ============================================================================
-- Returns: Summary string with priority distribution
-- Input: category_filter (ACCESS, ANALYTICS, PUBLISHING, BILLING, API, or NULL)
-- Analyzes 100 tickets

CREATE OR REPLACE FUNCTION CLASSIFY_TICKET_PRIORITY(category_filter VARCHAR)
RETURNS VARCHAR
AS
$$
    SELECT 
        'Total Tickets: ' || COUNT(*) ||
        ', Low Priority: ' || SUM(CASE WHEN pred:PREDICTED_PRIORITY::INT = 0 THEN 1 ELSE 0 END) ||
        ', Medium Priority: ' || SUM(CASE WHEN pred:PREDICTED_PRIORITY::INT = 1 THEN 1 ELSE 0 END) ||
        ', High Priority: ' || SUM(CASE WHEN pred:PREDICTED_PRIORITY::INT = 2 THEN 1 ELSE 0 END) ||
        ', Urgent Priority: ' || SUM(CASE WHEN pred:PREDICTED_PRIORITY::INT = 3 THEN 1 ELSE 0 END)
    FROM (
        SELECT 
            TICKET_PRIORITY_CLASSIFIER!PREDICT(
                category
            ) as pred
        FROM HOOTSUITE_INTELLIGENCE.ANALYTICS.V_TICKET_PRIORITY_FEATURES
        WHERE category_filter IS NULL OR category = category_filter
        LIMIT 100
    )
$$;

-- ============================================================================
-- Verification Tests
-- ============================================================================
SELECT '🔄 Testing ML functions...' as status;

SELECT PREDICT_CHURN_RISK(NULL) as churn_risk_result;
SELECT PREDICT_CAMPAIGN_ROI(NULL) as roi_result;
SELECT CLASSIFY_TICKET_PRIORITY(NULL) as priority_result;

SELECT '✅ All ML functions created and tested successfully!' as final_status;

-- ============================================================================
-- Next Step: Run sql/agent/hootsuite_08_intelligence_agent.sql
-- ============================================================================
