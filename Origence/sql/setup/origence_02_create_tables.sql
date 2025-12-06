-- ============================================================================
-- Origence Intelligence Agent - Table Definitions
-- ============================================================================
-- Purpose: Create all core tables for credit union lending platform
-- Tables: 9 core entities with proper constraints and change tracking
-- ============================================================================

USE DATABASE ORIGENCE_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE ORIGENCE_WH;

-- ============================================================================
-- Table 1: CREDIT_UNIONS
-- ============================================================================
CREATE OR REPLACE TABLE CREDIT_UNIONS (
    credit_union_id VARCHAR(50) PRIMARY KEY,
    credit_union_name VARCHAR(200) NOT NULL,
    credit_union_tier VARCHAR(20) NOT NULL,
    state VARCHAR(2) NOT NULL,
    region VARCHAR(50) NOT NULL,
    member_count NUMBER(10,0) NOT NULL,
    asset_size_millions NUMBER(15,2) NOT NULL,
    total_loans_funded NUMBER(15,2) DEFAULT 0,
    avg_loan_amount NUMBER(12,2) DEFAULT 0,
    default_rate NUMBER(5,4) DEFAULT 0,
    approval_rate NUMBER(5,4) DEFAULT 0,
    active_status VARCHAR(20) DEFAULT 'ACTIVE',
    partnership_start_date DATE NOT NULL,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
COMMENT = 'Credit union partners - 1,100+ credit unions using Origence platform';

-- ============================================================================
-- Table 2: MEMBERS
-- ============================================================================
CREATE OR REPLACE TABLE MEMBERS (
    member_id VARCHAR(50) PRIMARY KEY,
    credit_union_id VARCHAR(50) NOT NULL,
    age NUMBER(3,0) NOT NULL,
    credit_score NUMBER(3,0) NOT NULL,
    annual_income NUMBER(12,2) NOT NULL,
    employment_status VARCHAR(50) NOT NULL,
    employment_length_months NUMBER(4,0) NOT NULL,
    housing_status VARCHAR(20) NOT NULL,
    state VARCHAR(2) NOT NULL,
    member_since_date DATE NOT NULL,
    total_loans NUMBER(2,0) DEFAULT 0,
    total_loan_amount NUMBER(12,2) DEFAULT 0,
    has_checking BOOLEAN DEFAULT FALSE,
    has_savings BOOLEAN DEFAULT FALSE,
    has_credit_card BOOLEAN DEFAULT FALSE,
    member_tier VARCHAR(20) NOT NULL,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
COMMENT = 'Credit union members - 66M+ members represented';

-- ============================================================================
-- Table 3: DEALERS
-- ============================================================================
CREATE OR REPLACE TABLE DEALERS (
    dealer_id VARCHAR(50) PRIMARY KEY,
    dealer_name VARCHAR(200) NOT NULL,
    dealer_type VARCHAR(50) NOT NULL,
    state VARCHAR(2) NOT NULL,
    region VARCHAR(50) NOT NULL,
    cudl_certified BOOLEAN DEFAULT FALSE,
    total_loans_facilitated NUMBER(10,0) DEFAULT 0,
    avg_loan_amount NUMBER(12,2) DEFAULT 0,
    member_satisfaction_score NUMBER(3,1) DEFAULT 0,
    partnership_start_date DATE NOT NULL,
    active_status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
COMMENT = 'Automotive dealerships - 20,000+ dealers on CUDL platform';

-- ============================================================================
-- Table 4: LOAN_OFFICERS
-- ============================================================================
CREATE OR REPLACE TABLE LOAN_OFFICERS (
    officer_id VARCHAR(50) PRIMARY KEY,
    officer_name VARCHAR(200) NOT NULL,
    credit_union_id VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    experience_years NUMBER(2,0) NOT NULL,
    specialization VARCHAR(50) NOT NULL,
    total_loans_processed NUMBER(10,0) DEFAULT 0,
    avg_approval_rate NUMBER(5,4) DEFAULT 0,
    avg_processing_days NUMBER(4,1) DEFAULT 0,
    active_status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
COMMENT = 'Loan officers processing applications';

-- ============================================================================
-- Table 5: LOAN_APPLICATIONS
-- ============================================================================
CREATE OR REPLACE TABLE LOAN_APPLICATIONS (
    application_id VARCHAR(50) PRIMARY KEY,
    member_id VARCHAR(50) NOT NULL,
    credit_union_id VARCHAR(50) NOT NULL,
    loan_officer_id VARCHAR(50),
    dealer_id VARCHAR(50),
    application_date DATE NOT NULL,
    loan_type VARCHAR(50) NOT NULL,
    loan_purpose VARCHAR(100) NOT NULL,
    requested_amount NUMBER(12,2) NOT NULL,
    loan_term_months NUMBER(3,0) NOT NULL,
    interest_rate NUMBER(5,3),
    credit_score_at_app NUMBER(3,0) NOT NULL,
    annual_income NUMBER(12,2) NOT NULL,
    debt_to_income_ratio NUMBER(5,3) NOT NULL,
    employment_verified BOOLEAN DEFAULT FALSE,
    collateral_value NUMBER(12,2),
    down_payment_amount NUMBER(12,2) DEFAULT 0,
    loan_to_value_ratio NUMBER(5,3),
    application_status VARCHAR(50) NOT NULL,
    decision_date DATE,
    decision_reason VARCHAR(500),
    days_to_decision NUMBER(4,0),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
COMMENT = 'Loan applications - consumer and auto loan applications';

-- ============================================================================
-- Table 6: LOANS
-- ============================================================================
CREATE OR REPLACE TABLE LOANS (
    loan_id VARCHAR(50) PRIMARY KEY,
    application_id VARCHAR(50) NOT NULL,
    member_id VARCHAR(50) NOT NULL,
    credit_union_id VARCHAR(50) NOT NULL,
    loan_officer_id VARCHAR(50),
    dealer_id VARCHAR(50),
    origination_date DATE NOT NULL,
    loan_type VARCHAR(50) NOT NULL,
    loan_purpose VARCHAR(100) NOT NULL,
    original_loan_amount NUMBER(12,2) NOT NULL,
    current_balance NUMBER(12,2) NOT NULL,
    loan_term_months NUMBER(3,0) NOT NULL,
    interest_rate NUMBER(5,3) NOT NULL,
    monthly_payment NUMBER(10,2) NOT NULL,
    payments_made NUMBER(3,0) DEFAULT 0,
    payments_remaining NUMBER(3,0) NOT NULL,
    days_past_due NUMBER(4,0) DEFAULT 0,
    delinquency_status VARCHAR(50) DEFAULT 'CURRENT',
    has_defaulted BOOLEAN DEFAULT FALSE,
    default_date DATE,
    total_interest_paid NUMBER(12,2) DEFAULT 0,
    loan_status VARCHAR(50) DEFAULT 'ACTIVE',
    maturity_date DATE NOT NULL,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
COMMENT = 'Funded loans - $593B+ total funding';

-- ============================================================================
-- Table 7: UNDERWRITING_NOTES (Unstructured)
-- ============================================================================
CREATE OR REPLACE TABLE UNDERWRITING_NOTES (
    note_id VARCHAR(50) PRIMARY KEY,
    application_id VARCHAR(50) NOT NULL,
    loan_officer_id VARCHAR(50) NOT NULL,
    note_text VARCHAR(10000) NOT NULL,
    note_date DATE NOT NULL,
    note_category VARCHAR(100) NOT NULL,
    decision_factor BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
COMMENT = 'Unstructured underwriting decision notes for Cortex Search';

-- ============================================================================
-- Table 8: LOAN_DOCUMENTS (Unstructured)
-- ============================================================================
CREATE OR REPLACE TABLE LOAN_DOCUMENTS (
    document_id VARCHAR(50) PRIMARY KEY,
    loan_id VARCHAR(50),
    application_id VARCHAR(50),
    document_type VARCHAR(100) NOT NULL,
    document_text VARCHAR(10000) NOT NULL,
    document_category VARCHAR(100) NOT NULL,
    upload_date DATE NOT NULL,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
COMMENT = 'Unstructured loan documentation for Cortex Search';

-- ============================================================================
-- Table 9: COMPLIANCE_POLICIES (Unstructured)
-- ============================================================================
CREATE OR REPLACE TABLE COMPLIANCE_POLICIES (
    policy_id VARCHAR(50) PRIMARY KEY,
    policy_title VARCHAR(500) NOT NULL,
    policy_content VARCHAR(10000) NOT NULL,
    policy_category VARCHAR(100) NOT NULL,
    regulation_type VARCHAR(100) NOT NULL,
    effective_date DATE NOT NULL,
    last_review_date DATE NOT NULL,
    keywords VARCHAR(500),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
COMMENT = 'Compliance and regulatory policies for Cortex Search';

-- ============================================================================
-- Confirmation
-- ============================================================================
SELECT 'All 9 Origence tables created successfully with change tracking enabled' AS STATUS;

SHOW TABLES IN SCHEMA RAW;
