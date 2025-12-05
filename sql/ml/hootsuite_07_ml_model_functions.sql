-- ============================================================================
-- Hootsuite Intelligence Agent - ML Model Wrapper Functions
-- ============================================================================
-- Purpose: Create SQL stored procedures to expose ML models to the Agent
-- Rule: Use LANGUAGE SQL and MODEL object syntax
-- Rule: Parameters must match Agent Tool inputs
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA ML_MODELS;
USE WAREHOUSE HOOTSUITE_WH;

-- ============================================================================
-- 1. Predict Post Engagement
-- ============================================================================
CREATE OR REPLACE PROCEDURE PREDICT_POST_ENGAGEMENT(POST_ID_INPUT VARCHAR)
RETURNS STRING
LANGUAGE SQL
AS $$
DECLARE
    result_json STRING;
BEGIN
    WITH predictions AS (
        WITH m AS MODEL HOOTSUITE_INTELLIGENCE.ML_MODELS.POST_ENGAGEMENT_PREDICTOR
        SELECT
            post_id,
            m!PREDICT(
                follower_count, 
                is_verified, 
                delay_hours, 
                hour_of_day, 
                day_of_week, 
                sentiment_score, 
                media_type
            ):output_feature_0::FLOAT AS predicted_engagement_rate
        FROM HOOTSUITE_INTELLIGENCE.ANALYTICS.V_POST_ENGAGEMENT_FEATURES
        WHERE post_id = :POST_ID_INPUT
    )
    SELECT 
        OBJECT_CONSTRUCT(
            'post_id', post_id, 
            'predicted_engagement_rate', predicted_engagement_rate,
            'analysis', 'Predicted engagement rate is ' || TO_VARCHAR(predicted_engagement_rate, '990.99')
        )::STRING 
    INTO result_json
    FROM predictions;
    
    RETURN result_json;
END;
$$;

-- ============================================================================
-- 2. Predict Churn Risk
-- ============================================================================
CREATE OR REPLACE PROCEDURE PREDICT_CHURN_RISK(ORGANIZATION_ID_INPUT VARCHAR)
RETURNS STRING
LANGUAGE SQL
AS $$
DECLARE
    result_json STRING;
BEGIN
    WITH predictions AS (
        WITH m AS MODEL HOOTSUITE_INTELLIGENCE.ML_MODELS.CHURN_RISK_PREDICTOR
        SELECT
            organization_id,
            -- Classifier returns label, we might want probability if available, usually class_1_probability
            -- Default predict returns label. Let's assume label for now.
            m!PREDICT(
                employee_count, 
                subscription_days, 
                active_users_count, 
                support_tickets_count, 
                avg_satisfaction_score, 
                plan_tier
            ):output_feature_0::INT AS is_churned
        FROM HOOTSUITE_INTELLIGENCE.ANALYTICS.V_CHURN_RISK_FEATURES
        WHERE organization_id = :ORGANIZATION_ID_INPUT
    )
    SELECT 
        OBJECT_CONSTRUCT(
            'organization_id', organization_id, 
            'churn_risk_prediction', CASE WHEN is_churned = 1 THEN 'HIGH RISK' ELSE 'LOW RISK' END
        )::STRING 
    INTO result_json
    FROM predictions;
    
    RETURN result_json;
END;
$$;

-- ============================================================================
-- 3. Predict Optimal Posting Time
-- ============================================================================
CREATE OR REPLACE PROCEDURE PREDICT_OPTIMAL_TIME(NETWORK_INPUT VARCHAR, INDUSTRY_INPUT VARCHAR)
RETURNS STRING
LANGUAGE SQL
AS $$
DECLARE
    result_json STRING;
BEGIN
    WITH generated_times AS (
        -- Generate 24 hours * 7 days
        SELECT
            SEQ4() % 24 AS hour_of_day,
            FLOOR(SEQ4() / 24) + 1 AS day_of_week,
            UPPER(:NETWORK_INPUT) AS network,
            INITCAP(:INDUSTRY_INPUT) AS industry
        FROM TABLE(GENERATOR(ROWCOUNT => 168))
        WHERE day_of_week <= 7
    ),
    predictions AS (
        WITH m AS MODEL HOOTSUITE_INTELLIGENCE.ML_MODELS.OPTIMAL_TIME_PREDICTOR
        SELECT
            day_of_week,
            hour_of_day,
            m!PREDICT(
                industry, 
                network, 
                hour_of_day, 
                day_of_week
            ):output_feature_0::FLOAT AS predicted_score
        FROM generated_times
    ),
    top_times AS (
        SELECT 
            day_of_week,
            hour_of_day,
            predicted_score
        FROM predictions
        ORDER BY predicted_score DESC
        LIMIT 3
    )
    SELECT 
        TO_JSON(ARRAY_AGG(OBJECT_CONSTRUCT(
            'day_of_week', CASE day_of_week 
                WHEN 1 THEN 'Sunday' WHEN 2 THEN 'Monday' WHEN 3 THEN 'Tuesday' 
                WHEN 4 THEN 'Wednesday' WHEN 5 THEN 'Thursday' WHEN 6 THEN 'Friday' ELSE 'Saturday' END,
            'hour_of_day', hour_of_day,
            'predicted_score', predicted_score
        )))::STRING
    INTO result_json
    FROM top_times;
    
    RETURN result_json;
END;
$$;

-- ============================================================================
-- Confirmation
-- ============================================================================
SELECT 'ML model wrapper functions created successfully' AS STATUS;
SHOW PROCEDURES IN SCHEMA ML_MODELS;

