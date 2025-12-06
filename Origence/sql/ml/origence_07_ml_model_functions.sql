-- ============================================================================
-- Origence ML Model Functions - Complete Setup
-- ============================================================================
-- Creates SQL UDF wrappers for ML model inference
-- These functions are called by the Intelligence Agent
-- Execution time: <10 seconds per function call
-- ============================================================================

USE DATABASE ORIGENCE_INTELLIGENCE;
USE SCHEMA ML_MODELS;
USE WAREHOUSE ORIGENCE_WH;

-- ============================================================================
-- Function 1: Predict Loan Default Risk
-- ============================================================================
-- Returns: Summary string with risk distribution
-- Input: loan_type_filter (AUTO_LOAN, PERSONAL_LOAN, HOME_EQUITY, or NULL)
-- Analyzes 100 loans from portfolio

CREATE OR REPLACE FUNCTION PREDICT_LOAN_DEFAULT_RISK(loan_type_filter VARCHAR)
RETURNS VARCHAR
AS
$$
    SELECT 
        'Total Loans: ' || COUNT(*) || 
        ', Low Risk: ' || SUM(CASE WHEN pred:PREDICTED_RISK::INT = 0 THEN 1 ELSE 0 END) ||
        ', Medium Risk: ' || SUM(CASE WHEN pred:PREDICTED_RISK::INT = 1 THEN 1 ELSE 0 END) ||
        ', High Risk: ' || SUM(CASE WHEN pred:PREDICTED_RISK::INT = 2 THEN 1 ELSE 0 END) ||
        ', Critical Risk: ' || SUM(CASE WHEN pred:PREDICTED_RISK::INT = 3 THEN 1 ELSE 0 END)
    FROM (
        SELECT 
            LOAN_DEFAULT_PREDICTOR!PREDICT(
                loan_type, original_loan_amount, loan_term_months, interest_rate,
                payments_made, days_past_due, credit_score, annual_income, age,
                debt_to_income_ratio, loan_to_value_ratio, is_cudl_dealer,
                loan_age_months, loan_to_income_ratio
            ) as pred
        FROM ORIGENCE_INTELLIGENCE.ANALYTICS.V_LOAN_DEFAULT_FEATURES
        WHERE loan_type_filter IS NULL OR loan_type = loan_type_filter
        LIMIT 100
    )
$$;

-- ============================================================================
-- Function 2: Predict Loan Approval
-- ============================================================================
-- Returns: Summary string with approval statistics
-- Input: application_status_filter (PENDING, APPROVED, DENIED, or NULL)
-- Analyzes 100 loan applications

CREATE OR REPLACE FUNCTION PREDICT_LOAN_APPROVAL(application_status_filter VARCHAR)
RETURNS VARCHAR
AS
$$
    SELECT 
        'Total Applications: ' || COUNT(*) ||
        ', Approved: ' || SUM(CASE WHEN pred:PREDICTED_APPROVAL::INT = 1 THEN 1 ELSE 0 END) ||
        ', Denied: ' || SUM(CASE WHEN pred:PREDICTED_APPROVAL::INT = 0 THEN 1 ELSE 0 END) ||
        ', Approval Rate: ' || ROUND(SUM(CASE WHEN pred:PREDICTED_APPROVAL::INT = 1 THEN 1 ELSE 0 END)::FLOAT / COUNT(*) * 100, 1) || '%'
    FROM (
        SELECT 
            LOAN_APPROVAL_PREDICTOR!PREDICT(
                loan_type, requested_amount, loan_term_months, credit_score_at_app, 
                annual_income, debt_to_income_ratio, loan_to_value_ratio,
                employment_verified, employment_length_months, age, is_cudl_dealer,
                loan_to_income_ratio
            ) as pred
        FROM ORIGENCE_INTELLIGENCE.ANALYTICS.V_LOAN_APPROVAL_FEATURES
        LIMIT 100
    )
$$;

-- ============================================================================
-- Function 3: Detect Fraud Risk
-- ============================================================================
-- Returns: Summary string with fraud risk distribution
-- Input: days_back (number of days to analyze, default 30)
-- Analyzes 100 recent applications

CREATE OR REPLACE FUNCTION DETECT_FRAUD_RISK(days_back NUMBER)
RETURNS VARCHAR
AS
$$
    SELECT 
        'Total Applications: ' || COUNT(*) ||
        ', Clean: ' || SUM(CASE WHEN pred:PREDICTED_FRAUD_RISK::INT = 0 THEN 1 ELSE 0 END) ||
        ', Suspicious: ' || SUM(CASE WHEN pred:PREDICTED_FRAUD_RISK::INT = 1 THEN 1 ELSE 0 END) ||
        ', High Risk: ' || SUM(CASE WHEN pred:PREDICTED_FRAUD_RISK::INT = 2 THEN 1 ELSE 0 END)
    FROM (
        SELECT 
            FRAUD_DETECTION_MODEL!PREDICT(
                loan_type, requested_amount, credit_score_at_app, annual_income,
                debt_to_income_ratio, employment_verified, employment_length_months,
                application_velocity, income_to_request_ratio, credit_score_change,
                high_loan_to_income_flag, high_dti_flag, income_verification_mismatch
            ) as pred
        FROM ORIGENCE_INTELLIGENCE.ANALYTICS.V_FRAUD_DETECTION_FEATURES
        LIMIT 100
    )
$$;

-- ============================================================================
-- Verification Tests
-- ============================================================================
SELECT '🔄 Testing ML functions...' as status;

SELECT PREDICT_LOAN_DEFAULT_RISK(NULL) as default_risk_result;
SELECT PREDICT_LOAN_APPROVAL(NULL) as approval_result;
SELECT DETECT_FRAUD_RISK(30) as fraud_result;

SELECT '✅ All ML functions created and tested successfully!' as final_status;

-- ============================================================================
-- Next Step: Run sql/agent/origence_08_intelligence_agent.sql
-- ============================================================================
