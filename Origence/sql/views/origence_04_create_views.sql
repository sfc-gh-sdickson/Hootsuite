-- ============================================================================
-- Origence Intelligence Agent - Analytical and Feature Views
-- ============================================================================
-- Purpose: Create analytical views for reporting and ML feature views for model training
-- Views: 6 analytical + 3 ML feature views
-- ============================================================================

USE DATABASE ORIGENCE_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE ORIGENCE_WH;

-- ============================================================================
-- ANALYTICAL VIEWS (For Business Intelligence and Reporting)
-- ============================================================================

-- ============================================================================
-- View 1: Loan Performance Summary
-- ============================================================================
CREATE OR REPLACE VIEW V_LOAN_PERFORMANCE AS
SELECT
    l.loan_id,
    l.loan_type,
    l.loan_purpose,
    l.origination_date,
    l.original_loan_amount,
    l.current_balance,
    l.interest_rate,
    l.loan_term_months,
    l.payments_made,
    l.payments_remaining,
    l.days_past_due,
    l.delinquency_status,
    l.has_defaulted,
    l.loan_status,
    cu.credit_union_name,
    cu.credit_union_tier,
    cu.region,
    m.credit_score,
    m.annual_income,
    m.member_tier,
    d.dealer_name,
    d.cudl_certified,
    DATEDIFF(month, l.origination_date, CURRENT_DATE()) AS months_since_origination,
    l.original_loan_amount - l.current_balance AS principal_paid,
    CASE 
        WHEN l.has_defaulted THEN 'DEFAULT'
        WHEN l.days_past_due > 90 THEN 'SERIOUS_DELINQUENCY'
        WHEN l.days_past_due > 30 THEN 'EARLY_DELINQUENCY'
        WHEN l.loan_status = 'PAID_OFF' THEN 'PAID_OFF'
        ELSE 'PERFORMING'
    END AS risk_category
FROM RAW.LOANS l
INNER JOIN RAW.CREDIT_UNIONS cu ON l.credit_union_id = cu.credit_union_id
INNER JOIN RAW.MEMBERS m ON l.member_id = m.member_id
LEFT JOIN RAW.DEALERS d ON l.dealer_id = d.dealer_id;

-- ============================================================================
-- View 2: Credit Union Summary Metrics
-- ============================================================================
CREATE OR REPLACE VIEW V_CREDIT_UNION_SUMMARY AS
SELECT
    cu.credit_union_id,
    cu.credit_union_name,
    cu.credit_union_tier,
    cu.state,
    cu.region,
    cu.member_count,
    cu.asset_size_millions,
    COUNT(DISTINCT l.loan_id) AS total_loans,
    SUM(l.original_loan_amount) AS total_loan_volume,
    AVG(l.original_loan_amount) AS avg_loan_amount,
    SUM(l.current_balance) AS current_portfolio_balance,
    COUNT(DISTINCT CASE WHEN l.has_defaulted THEN l.loan_id END) AS default_count,
    COUNT(DISTINCT CASE WHEN l.has_defaulted THEN l.loan_id END)::FLOAT / NULLIF(COUNT(DISTINCT l.loan_id), 0) AS default_rate,
    COUNT(DISTINCT CASE WHEN l.delinquency_status != 'CURRENT' THEN l.loan_id END)::FLOAT / NULLIF(COUNT(DISTINCT l.loan_id), 0) AS delinquency_rate,
    COUNT(DISTINCT a.application_id) AS total_applications,
    COUNT(DISTINCT CASE WHEN a.application_status = 'APPROVED' THEN a.application_id END) AS approved_applications,
    COUNT(DISTINCT CASE WHEN a.application_status = 'APPROVED' THEN a.application_id END)::FLOAT / NULLIF(COUNT(DISTINCT a.application_id), 0) AS approval_rate,
    AVG(a.days_to_decision) AS avg_days_to_decision
FROM RAW.CREDIT_UNIONS cu
LEFT JOIN RAW.LOANS l ON cu.credit_union_id = l.credit_union_id
LEFT JOIN RAW.LOAN_APPLICATIONS a ON cu.credit_union_id = a.credit_union_id
GROUP BY 
    cu.credit_union_id, cu.credit_union_name, cu.credit_union_tier,
    cu.state, cu.region, cu.member_count, cu.asset_size_millions;

-- ============================================================================
-- View 3: Member Loan History
-- ============================================================================
CREATE OR REPLACE VIEW V_MEMBER_LOAN_HISTORY AS
SELECT
    m.member_id,
    m.age,
    m.credit_score,
    m.annual_income,
    m.employment_status,
    m.member_tier,
    m.state,
    cu.credit_union_name,
    cu.credit_union_tier,
    COUNT(DISTINCT l.loan_id) AS total_loans,
    SUM(l.original_loan_amount) AS lifetime_loan_volume,
    AVG(l.interest_rate) AS avg_interest_rate,
    MAX(l.origination_date) AS most_recent_loan_date,
    COUNT(DISTINCT CASE WHEN l.has_defaulted THEN l.loan_id END) AS lifetime_defaults,
    COUNT(DISTINCT CASE WHEN l.loan_status = 'PAID_OFF' THEN l.loan_id END) AS paid_off_loans,
    COUNT(DISTINCT CASE WHEN l.days_past_due > 0 THEN l.loan_id END) AS loans_with_late_payments,
    COUNT(DISTINCT a.application_id) AS total_applications,
    COUNT(DISTINCT CASE WHEN a.application_status = 'DENIED' THEN a.application_id END) AS denied_applications
FROM RAW.MEMBERS m
INNER JOIN RAW.CREDIT_UNIONS cu ON m.credit_union_id = cu.credit_union_id
LEFT JOIN RAW.LOANS l ON m.member_id = l.member_id
LEFT JOIN RAW.LOAN_APPLICATIONS a ON m.member_id = a.member_id
GROUP BY 
    m.member_id, m.age, m.credit_score, m.annual_income, m.employment_status,
    m.member_tier, m.state, cu.credit_union_name, cu.credit_union_tier;

-- ============================================================================
-- View 4: Dealer Performance Metrics
-- ============================================================================
CREATE OR REPLACE VIEW V_DEALER_PERFORMANCE AS
SELECT
    d.dealer_id,
    d.dealer_name,
    d.dealer_type,
    d.state,
    d.region,
    d.cudl_certified,
    COUNT(DISTINCT l.loan_id) AS total_loans_facilitated,
    SUM(l.original_loan_amount) AS total_loan_volume,
    AVG(l.original_loan_amount) AS avg_loan_amount,
    COUNT(DISTINCT l.credit_union_id) AS credit_union_partners,
    COUNT(DISTINCT CASE WHEN l.has_defaulted THEN l.loan_id END) AS default_count,
    COUNT(DISTINCT CASE WHEN l.has_defaulted THEN l.loan_id END)::FLOAT / NULLIF(COUNT(DISTINCT l.loan_id), 0) AS default_rate,
    AVG(l.interest_rate) AS avg_interest_rate,
    d.member_satisfaction_score
FROM RAW.DEALERS d
LEFT JOIN RAW.LOANS l ON d.dealer_id = l.dealer_id
GROUP BY 
    d.dealer_id, d.dealer_name, d.dealer_type, d.state, d.region,
    d.cudl_certified, d.member_satisfaction_score;

-- ============================================================================
-- View 5: Application Funnel Analysis
-- ============================================================================
CREATE OR REPLACE VIEW V_APPLICATION_FUNNEL AS
SELECT
    a.application_id,
    a.application_date,
    a.loan_type,
    a.loan_purpose,
    a.requested_amount,
    a.application_status,
    a.decision_date,
    a.days_to_decision,
    a.credit_score_at_app,
    a.debt_to_income_ratio,
    a.employment_verified,
    m.age,
    m.annual_income,
    m.member_tier,
    cu.credit_union_name,
    cu.credit_union_tier,
    cu.region,
    d.dealer_name,
    d.cudl_certified,
    CASE 
        WHEN a.application_status = 'APPROVED' THEN 1 
        ELSE 0 
    END AS is_approved,
    CASE 
        WHEN a.application_status = 'DENIED' THEN 1 
        ELSE 0 
    END AS is_denied,
    CASE 
        WHEN l.loan_id IS NOT NULL THEN 1 
        ELSE 0 
    END AS is_funded
FROM RAW.LOAN_APPLICATIONS a
INNER JOIN RAW.MEMBERS m ON a.member_id = m.member_id
INNER JOIN RAW.CREDIT_UNIONS cu ON a.credit_union_id = cu.credit_union_id
LEFT JOIN RAW.DEALERS d ON a.dealer_id = d.dealer_id
LEFT JOIN RAW.LOANS l ON a.application_id = l.application_id;

-- ============================================================================
-- View 6: Portfolio Risk Summary
-- ============================================================================
CREATE OR REPLACE VIEW V_PORTFOLIO_RISK AS
SELECT
    l.loan_type,
    cu.credit_union_tier,
    cu.region,
    COUNT(DISTINCT l.loan_id) AS total_loans,
    SUM(l.current_balance) AS total_outstanding_balance,
    AVG(l.interest_rate) AS avg_interest_rate,
    COUNT(DISTINCT CASE WHEN l.delinquency_status = 'CURRENT' THEN l.loan_id END) AS current_loans,
    COUNT(DISTINCT CASE WHEN l.delinquency_status = '30_DAYS' THEN l.loan_id END) AS dpd_30_loans,
    COUNT(DISTINCT CASE WHEN l.delinquency_status = '60_DAYS' THEN l.loan_id END) AS dpd_60_loans,
    COUNT(DISTINCT CASE WHEN l.delinquency_status = '90_DAYS' THEN l.loan_id END) AS dpd_90_loans,
    COUNT(DISTINCT CASE WHEN l.has_defaulted THEN l.loan_id END) AS defaulted_loans,
    COUNT(DISTINCT CASE WHEN l.has_defaulted THEN l.loan_id END)::FLOAT / NULLIF(COUNT(DISTINCT l.loan_id), 0) AS default_rate,
    SUM(CASE WHEN l.has_defaulted THEN l.current_balance ELSE 0 END) AS total_charged_off_balance
FROM RAW.LOANS l
INNER JOIN RAW.CREDIT_UNIONS cu ON l.credit_union_id = cu.credit_union_id
GROUP BY l.loan_type, cu.credit_union_tier, cu.region;

SELECT '6 analytical views created successfully' AS status;

-- ============================================================================
-- ML FEATURE VIEWS (For Model Training - Single Source of Truth)
-- ============================================================================

-- ============================================================================
-- ML Feature View 1: Loan Default Prediction Features
-- ============================================================================
CREATE OR REPLACE VIEW V_LOAN_DEFAULT_FEATURES AS
SELECT
    l.loan_id,
    l.loan_type,
    l.original_loan_amount,
    l.loan_term_months,
    l.interest_rate,
    l.payments_made,
    l.days_past_due,
    m.credit_score,
    m.annual_income,
    m.age,
    a.debt_to_income_ratio,
    COALESCE(a.loan_to_value_ratio, 0) AS loan_to_value_ratio,
    CASE WHEN d.cudl_certified THEN 1 ELSE 0 END AS is_cudl_dealer,
    DATEDIFF(month, l.origination_date, CURRENT_DATE()) AS loan_age_months,
    l.original_loan_amount / NULLIF(m.annual_income, 0) AS loan_to_income_ratio,
    CASE 
        WHEN l.has_defaulted THEN 3
        WHEN l.days_past_due > 90 THEN 2
        WHEN l.days_past_due > 30 THEN 1
        ELSE 0
    END AS default_risk_label
FROM RAW.LOANS l
INNER JOIN RAW.MEMBERS m ON l.member_id = m.member_id
INNER JOIN RAW.LOAN_APPLICATIONS a ON l.application_id = a.application_id
LEFT JOIN RAW.DEALERS d ON l.dealer_id = d.dealer_id
WHERE l.loan_status IN ('ACTIVE', 'CHARGED_OFF');

-- ============================================================================
-- ML Feature View 2: Loan Approval Prediction Features
-- ============================================================================
CREATE OR REPLACE VIEW V_LOAN_APPROVAL_FEATURES AS
SELECT
    a.application_id,
    a.loan_type,
    a.requested_amount,
    a.loan_term_months,
    a.credit_score_at_app,
    a.annual_income,
    a.debt_to_income_ratio,
    COALESCE(a.loan_to_value_ratio, 0) AS loan_to_value_ratio,
    CASE WHEN a.employment_verified THEN 1 ELSE 0 END AS employment_verified,
    m.employment_length_months,
    m.age,
    CASE WHEN d.cudl_certified THEN 1 ELSE 0 END AS is_cudl_dealer,
    a.requested_amount / NULLIF(a.annual_income, 0) AS loan_to_income_ratio,
    CASE 
        WHEN a.application_status = 'APPROVED' THEN 2
        WHEN a.application_status = 'PENDING' THEN 1
        WHEN a.application_status = 'DENIED' THEN 0
        ELSE 1
    END AS approval_label
FROM RAW.LOAN_APPLICATIONS a
INNER JOIN RAW.MEMBERS m ON a.member_id = m.member_id
LEFT JOIN RAW.DEALERS d ON a.dealer_id = d.dealer_id
WHERE a.application_status IN ('APPROVED', 'DENIED', 'PENDING');

-- ============================================================================
-- ML Feature View 3: Fraud Detection Features
-- ============================================================================
CREATE OR REPLACE VIEW V_FRAUD_DETECTION_FEATURES AS
WITH member_app_velocity AS (
    SELECT 
        member_id,
        COUNT(*) AS apps_last_30_days
    FROM RAW.LOAN_APPLICATIONS
    WHERE application_date >= DATEADD(day, -30, CURRENT_DATE())
    GROUP BY member_id
)
SELECT
    a.application_id,
    a.loan_type,
    a.requested_amount,
    a.credit_score_at_app,
    a.annual_income,
    a.debt_to_income_ratio,
    CASE WHEN a.employment_verified THEN 1 ELSE 0 END AS employment_verified,
    m.employment_length_months,
    COALESCE(v.apps_last_30_days, 0) AS application_velocity,
    a.requested_amount / NULLIF(a.annual_income, 0) AS income_to_request_ratio,
    ABS(m.credit_score - a.credit_score_at_app) AS credit_score_change,
    CASE 
        WHEN a.requested_amount / NULLIF(a.annual_income, 0) > 0.8 THEN 1 
        ELSE 0 
    END AS high_loan_to_income_flag,
    CASE 
        WHEN a.debt_to_income_ratio > 0.5 THEN 1 
        ELSE 0 
    END AS high_dti_flag,
    CASE 
        WHEN NOT a.employment_verified AND a.annual_income > 100000 THEN 1 
        ELSE 0 
    END AS income_verification_mismatch,
    CASE
        WHEN COALESCE(v.apps_last_30_days, 0) > 3 
             OR (a.requested_amount / NULLIF(a.annual_income, 0) > 0.8 AND NOT a.employment_verified)
             OR (a.debt_to_income_ratio > 0.5 AND a.credit_score_at_app < 600)
        THEN 2
        WHEN COALESCE(v.apps_last_30_days, 0) > 1 
             OR a.requested_amount / NULLIF(a.annual_income, 0) > 0.6
             OR NOT a.employment_verified
        THEN 1
        ELSE 0
    END AS fraud_risk_label
FROM RAW.LOAN_APPLICATIONS a
INNER JOIN RAW.MEMBERS m ON a.member_id = m.member_id
LEFT JOIN member_app_velocity v ON a.member_id = v.member_id;

SELECT '3 ML feature views created successfully' AS status;

-- ============================================================================
-- Confirmation and Verification
-- ============================================================================
SHOW VIEWS IN SCHEMA ANALYTICS;

SELECT 'All analytical and ML feature views created successfully!' AS status;

-- Test feature views have data
SELECT 'V_LOAN_DEFAULT_FEATURES' AS view_name, COUNT(*) AS row_count FROM V_LOAN_DEFAULT_FEATURES
UNION ALL
SELECT 'V_LOAN_APPROVAL_FEATURES', COUNT(*) FROM V_LOAN_APPROVAL_FEATURES
UNION ALL
SELECT 'V_FRAUD_DETECTION_FEATURES', COUNT(*) FROM V_FRAUD_DETECTION_FEATURES;
