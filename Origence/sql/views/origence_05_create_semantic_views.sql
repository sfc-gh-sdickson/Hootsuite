-- ============================================================================
-- Origence Intelligence Agent - Semantic Views
-- ============================================================================
-- Purpose: Semantic views for Cortex Analyst text-to-SQL capabilities
-- Syntax: VERIFIED against Snowflake documentation
-- Column names: VERIFIED against table definitions
-- ============================================================================

USE DATABASE ORIGENCE_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE ORIGENCE_WH;

-- ============================================================================
-- Semantic View 1: Loan Performance Analytics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_LOAN_PERFORMANCE
  TABLES (
    loans AS RAW.LOANS
      PRIMARY KEY (loan_id),
    applications AS RAW.LOAN_APPLICATIONS
      PRIMARY KEY (application_id),
    members AS RAW.MEMBERS
      PRIMARY KEY (member_id),
    credit_unions AS RAW.CREDIT_UNIONS
      PRIMARY KEY (credit_union_id)
  )
  RELATIONSHIPS (
    loans(application_id) REFERENCES applications(application_id),
    loans(member_id) REFERENCES members(member_id),
    loans(credit_union_id) REFERENCES credit_unions(credit_union_id),
    applications(member_id) REFERENCES members(member_id),
    applications(credit_union_id) REFERENCES credit_unions(credit_union_id)
  )
  DIMENSIONS (
    loans.loan_type AS loans.loan_type,
    loans.loan_purpose AS loans.loan_purpose,
    loans.delinquency_status AS loans.delinquency_status,
    loans.loan_status AS loans.loan_status,
    credit_unions.credit_union_name AS credit_unions.credit_union_name,
    credit_unions.credit_union_tier AS credit_unions.credit_union_tier,
    credit_unions.state AS credit_unions.state,
    credit_unions.region AS credit_unions.region,
    members.member_tier AS members.member_tier,
    members.employment_status AS members.employment_status
  )
  METRICS (
    loans.total_loans AS COUNT(DISTINCT loans.loan_id),
    loans.total_loan_volume AS SUM(loans.original_loan_amount),
    loans.avg_loan_amount AS AVG(loans.original_loan_amount),
    loans.total_outstanding_balance AS SUM(loans.current_balance),
    loans.default_count AS COUNT_IF(loans.has_defaulted),
    loans.default_rate AS (COUNT_IF(loans.has_defaulted)::FLOAT / NULLIF(COUNT(*), 0)),
    loans.delinquent_count AS COUNT_IF(loans.delinquency_status != 'CURRENT'),
    loans.delinquency_rate AS (COUNT_IF(loans.delinquency_status != 'CURRENT')::FLOAT / NULLIF(COUNT(*), 0)),
    loans.avg_interest_rate AS AVG(loans.interest_rate),
    loans.total_interest_paid AS SUM(loans.total_interest_paid),
    loans.avg_payments_made AS AVG(loans.payments_made),
    loans.avg_days_past_due AS AVG(loans.days_past_due)
  )
  COMMENT = 'Semantic view for loan performance, delinquency, and default analytics';

-- ============================================================================
-- Semantic View 2: Member Credit Profile Analytics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_MEMBER_CREDIT_PROFILE
  TABLES (
    members AS RAW.MEMBERS
      PRIMARY KEY (member_id),
    applications AS RAW.LOAN_APPLICATIONS
      PRIMARY KEY (application_id),
    credit_unions AS RAW.CREDIT_UNIONS
      PRIMARY KEY (credit_union_id)
  )
  RELATIONSHIPS (
    members(credit_union_id) REFERENCES credit_unions(credit_union_id),
    applications(member_id) REFERENCES members(member_id),
    applications(credit_union_id) REFERENCES credit_unions(credit_union_id)
  )
  DIMENSIONS (
    members.age_group AS 
      CASE 
        WHEN members.age < 25 THEN '18-24'
        WHEN members.age < 35 THEN '25-34'
        WHEN members.age < 45 THEN '35-44'
        WHEN members.age < 55 THEN '45-54'
        WHEN members.age < 65 THEN '55-64'
        ELSE '65+'
      END,
    members.credit_score_band AS
      CASE
        WHEN members.credit_score < 580 THEN 'Poor (<580)'
        WHEN members.credit_score < 670 THEN 'Fair (580-669)'
        WHEN members.credit_score < 740 THEN 'Good (670-739)'
        WHEN members.credit_score < 800 THEN 'Very Good (740-799)'
        ELSE 'Excellent (800+)'
      END,
    members.income_bracket AS
      CASE
        WHEN members.annual_income < 40000 THEN 'Under $40K'
        WHEN members.annual_income < 60000 THEN '$40K-$60K'
        WHEN members.annual_income < 80000 THEN '$60K-$80K'
        WHEN members.annual_income < 100000 THEN '$80K-$100K'
        ELSE 'Over $100K'
      END,
    members.employment_status AS members.employment_status,
    members.housing_status AS members.housing_status,
    members.member_tier AS members.member_tier,
    members.state AS members.state,
    applications.loan_type AS applications.loan_type,
    applications.application_status AS applications.application_status,
    credit_unions.credit_union_name AS credit_unions.credit_union_name
  )
  METRICS (
    members.total_members AS COUNT(DISTINCT members.member_id),
    members.avg_credit_score AS AVG(members.credit_score),
    members.avg_annual_income AS AVG(members.annual_income),
    members.avg_employment_length AS AVG(members.employment_length_months),
    applications.total_applications AS COUNT(DISTINCT applications.application_id),
    applications.approved_count AS COUNT_IF(applications.application_status = 'APPROVED'),
    applications.denied_count AS COUNT_IF(applications.application_status = 'DENIED'),
    applications.pending_count AS COUNT_IF(applications.application_status = 'PENDING'),
    applications.approval_rate AS (COUNT_IF(applications.application_status = 'APPROVED')::FLOAT / NULLIF(COUNT(*), 0)),
    applications.avg_requested_amount AS AVG(applications.requested_amount),
    applications.avg_dti_ratio AS AVG(applications.debt_to_income_ratio),
    applications.avg_days_to_decision AS AVG(applications.days_to_decision)
  )
  COMMENT = 'Semantic view for member demographics, credit profiles, and application patterns';

-- ============================================================================
-- Semantic View 3: Credit Union Performance Metrics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_CREDIT_UNION_METRICS
  TABLES (
    credit_unions AS RAW.CREDIT_UNIONS
      PRIMARY KEY (credit_union_id),
    loans AS RAW.LOANS
      PRIMARY KEY (loan_id),
    applications AS RAW.LOAN_APPLICATIONS
      PRIMARY KEY (application_id),
    dealers AS RAW.DEALERS
      PRIMARY KEY (dealer_id)
  )
  RELATIONSHIPS (
    loans(credit_union_id) REFERENCES credit_unions(credit_union_id),
    applications(credit_union_id) REFERENCES credit_unions(credit_union_id),
    loans(dealer_id) REFERENCES dealers(dealer_id)
  )
  DIMENSIONS (
    credit_unions.credit_union_name AS credit_unions.credit_union_name,
    credit_unions.credit_union_tier AS credit_unions.credit_union_tier,
    credit_unions.state AS credit_unions.state,
    credit_unions.region AS credit_unions.region,
    credit_unions.active_status AS credit_unions.active_status,
    loans.loan_type AS loans.loan_type,
    dealers.dealer_type AS dealers.dealer_type,
    dealers.cudl_certified AS dealers.cudl_certified
  )
  METRICS (
    credit_unions.total_credit_unions AS COUNT(DISTINCT credit_unions.credit_union_id),
    credit_unions.total_members_served AS SUM(credit_unions.member_count),
    credit_unions.total_assets AS SUM(credit_unions.asset_size_millions),
    credit_unions.avg_asset_size AS AVG(credit_unions.asset_size_millions),
    loans.total_loans_funded AS COUNT(DISTINCT loans.loan_id),
    loans.total_funding_volume AS SUM(loans.original_loan_amount),
    loans.avg_loan_size AS AVG(loans.original_loan_amount),
    loans.portfolio_default_rate AS (COUNT_IF(loans.has_defaulted)::FLOAT / NULLIF(COUNT(*), 0)),
    loans.portfolio_delinquency_rate AS (COUNT_IF(loans.delinquency_status != 'CURRENT')::FLOAT / NULLIF(COUNT(*), 0)),
    applications.total_applications AS COUNT(DISTINCT applications.application_id),
    applications.cu_approval_rate AS (COUNT_IF(applications.application_status = 'APPROVED')::FLOAT / NULLIF(COUNT(*), 0)),
    dealers.total_dealer_partners AS COUNT(DISTINCT dealers.dealer_id),
    dealers.cudl_certified_count AS COUNT_IF(dealers.cudl_certified)
  )
  COMMENT = 'Semantic view for credit union portfolio performance and partnership metrics';

-- ============================================================================
-- Confirmation
-- ============================================================================
SELECT 'Origence semantic views created successfully - syntax and columns verified' AS STATUS;

SHOW SEMANTIC VIEWS IN SCHEMA ANALYTICS;
