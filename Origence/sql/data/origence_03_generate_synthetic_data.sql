-- ============================================================================
-- Origence Intelligence Agent - Synthetic Data Generation
-- ============================================================================
-- Purpose: Generate realistic synthetic data for credit union lending platform
-- Data Volume: ~231,450 total rows across 9 tables
-- Execution Time: 10-15 minutes on MEDIUM warehouse
-- ============================================================================

USE DATABASE ORIGENCE_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE ORIGENCE_WH;

-- ============================================================================
-- Table 1: CREDIT_UNIONS (1,100 rows)
-- ============================================================================
INSERT INTO CREDIT_UNIONS
SELECT
    'CU' || LPAD(SEQ4()::VARCHAR, 6, '0') AS credit_union_id,
    CASE MOD(SEQ4(), 20)
        WHEN 0 THEN 'Community First Credit Union - '
        WHEN 1 THEN 'Members Choice Financial - '
        WHEN 2 THEN 'United Federal Credit Union - '
        WHEN 3 THEN 'Peoples Trust Credit Union - '
        WHEN 4 THEN 'Regional Credit Union - '
        WHEN 5 THEN 'State Employees Credit Union - '
        WHEN 6 THEN 'Liberty Credit Union - '
        WHEN 7 THEN 'Alliance Federal Credit Union - '
        WHEN 8 THEN 'First Community Credit Union - '
        WHEN 9 THEN 'Prime Financial Credit Union - '
        WHEN 10 THEN 'Coastal Credit Union - '
        WHEN 11 THEN 'Mountain West Credit Union - '
        WHEN 12 THEN 'Heritage Credit Union - '
        WHEN 13 THEN 'Summit Credit Union - '
        WHEN 14 THEN 'Beacon Credit Union - '
        WHEN 15 THEN 'Pioneer Credit Union - '
        WHEN 16 THEN 'Keystone Federal Credit Union - '
        WHEN 17 THEN 'Gateway Credit Union - '
        WHEN 18 THEN 'Horizon Credit Union - '
        ELSE 'Lakeside Credit Union - '
    END || 
    CASE MOD(SEQ4(), 50)
        WHEN 0 THEN 'CA' WHEN 1 THEN 'TX' WHEN 2 THEN 'FL' WHEN 3 THEN 'NY'
        WHEN 4 THEN 'PA' WHEN 5 THEN 'IL' WHEN 6 THEN 'OH' WHEN 7 THEN 'GA'
        WHEN 8 THEN 'NC' WHEN 9 THEN 'MI' WHEN 10 THEN 'NJ' WHEN 11 THEN 'VA'
        WHEN 12 THEN 'WA' WHEN 13 THEN 'AZ' WHEN 14 THEN 'MA' WHEN 15 THEN 'TN'
        WHEN 16 THEN 'IN' WHEN 17 THEN 'MO' WHEN 18 THEN 'MD' WHEN 19 THEN 'WI'
        WHEN 20 THEN 'CO' WHEN 21 THEN 'MN' WHEN 22 THEN 'SC' WHEN 23 THEN 'AL'
        WHEN 24 THEN 'LA' WHEN 25 THEN 'KY' WHEN 26 THEN 'OR' WHEN 27 THEN 'OK'
        WHEN 28 THEN 'CT' WHEN 29 THEN 'UT' WHEN 30 THEN 'IA' WHEN 31 THEN 'NV'
        WHEN 32 THEN 'AR' WHEN 33 THEN 'MS' WHEN 34 THEN 'KS' WHEN 35 THEN 'NM'
        WHEN 36 THEN 'NE' WHEN 37 THEN 'WV' WHEN 38 THEN 'ID' WHEN 39 THEN 'HI'
        WHEN 40 THEN 'NH' WHEN 41 THEN 'ME' WHEN 42 THEN 'MT' WHEN 43 THEN 'RI'
        WHEN 44 THEN 'DE' WHEN 45 THEN 'SD' WHEN 46 THEN 'ND' WHEN 47 THEN 'AK'
        WHEN 48 THEN 'VT' WHEN 49 THEN 'WY' ELSE 'CA'
    END AS credit_union_name,
    CASE 
        WHEN SEQ4() <= 110 THEN 'TIER_1'
        WHEN SEQ4() <= 440 THEN 'TIER_2'
        WHEN SEQ4() <= 880 THEN 'TIER_3'
        ELSE 'TIER_4'
    END AS credit_union_tier,
    CASE MOD(SEQ4(), 50)
        WHEN 0 THEN 'CA' WHEN 1 THEN 'TX' WHEN 2 THEN 'FL' WHEN 3 THEN 'NY'
        WHEN 4 THEN 'PA' WHEN 5 THEN 'IL' WHEN 6 THEN 'OH' WHEN 7 THEN 'GA'
        WHEN 8 THEN 'NC' WHEN 9 THEN 'MI' WHEN 10 THEN 'NJ' WHEN 11 THEN 'VA'
        WHEN 12 THEN 'WA' WHEN 13 THEN 'AZ' WHEN 14 THEN 'MA' WHEN 15 THEN 'TN'
        WHEN 16 THEN 'IN' WHEN 17 THEN 'MO' WHEN 18 THEN 'MD' WHEN 19 THEN 'WI'
        WHEN 20 THEN 'CO' WHEN 21 THEN 'MN' WHEN 22 THEN 'SC' WHEN 23 THEN 'AL'
        WHEN 24 THEN 'LA' WHEN 25 THEN 'KY' WHEN 26 THEN 'OR' WHEN 27 THEN 'OK'
        WHEN 28 THEN 'CT' WHEN 29 THEN 'UT' WHEN 30 THEN 'IA' WHEN 31 THEN 'NV'
        WHEN 32 THEN 'AR' WHEN 33 THEN 'MS' WHEN 34 THEN 'KS' WHEN 35 THEN 'NM'
        WHEN 36 THEN 'NE' WHEN 37 THEN 'WV' WHEN 38 THEN 'ID' WHEN 39 THEN 'HI'
        WHEN 40 THEN 'NH' WHEN 41 THEN 'ME' WHEN 42 THEN 'MT' WHEN 43 THEN 'RI'
        WHEN 44 THEN 'DE' WHEN 45 THEN 'SD' WHEN 46 THEN 'ND' WHEN 47 THEN 'AK'
        WHEN 48 THEN 'VT' WHEN 49 THEN 'WY' ELSE 'CA'
    END AS state,
    CASE 
        WHEN state IN ('CA', 'WA', 'OR', 'AZ', 'NV', 'UT', 'CO', 'ID', 'MT', 'WY', 'AK', 'HI', 'NM') THEN 'WEST'
        WHEN state IN ('NY', 'PA', 'NJ', 'MA', 'CT', 'NH', 'ME', 'RI', 'VT', 'DE', 'MD') THEN 'NORTHEAST'
        WHEN state IN ('IL', 'OH', 'MI', 'WI', 'IN', 'MO', 'MN', 'IA', 'KS', 'NE', 'SD', 'ND') THEN 'MIDWEST'
        ELSE 'SOUTH'
    END AS region,
    CASE 
        WHEN SEQ4() <= 110 THEN UNIFORM(50000, 150000, RANDOM())
        WHEN SEQ4() <= 440 THEN UNIFORM(20000, 50000, RANDOM())
        WHEN SEQ4() <= 880 THEN UNIFORM(5000, 20000, RANDOM())
        ELSE UNIFORM(1000, 5000, RANDOM())
    END AS member_count,
    CASE 
        WHEN SEQ4() <= 110 THEN UNIFORM(500, 2000, RANDOM())
        WHEN SEQ4() <= 440 THEN UNIFORM(200, 500, RANDOM())
        WHEN SEQ4() <= 880 THEN UNIFORM(50, 200, RANDOM())
        ELSE UNIFORM(10, 50, RANDOM())
    END AS asset_size_millions,
    0 AS total_loans_funded,
    0 AS avg_loan_amount,
    0 AS default_rate,
    0 AS approval_rate,
    'ACTIVE' AS active_status,
    DATEADD(month, -UNIFORM(12, 360, RANDOM()), CURRENT_DATE()) AS partnership_start_date,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 1100));

SELECT 'Credit Unions: ' || COUNT(*) || ' rows inserted' AS status FROM CREDIT_UNIONS;

-- ============================================================================
-- Table 2: MEMBERS (100,000 rows)
-- ============================================================================
INSERT INTO MEMBERS
SELECT
    'MBR' || LPAD(SEQ4()::VARCHAR, 8, '0') AS member_id,
    (SELECT credit_union_id FROM CREDIT_UNIONS ORDER BY RANDOM() LIMIT 1) AS credit_union_id,
    UNIFORM(18, 80, RANDOM()) AS age,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 5 THEN UNIFORM(300, 579, RANDOM())
        WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN UNIFORM(580, 669, RANDOM())
        WHEN UNIFORM(0, 100, RANDOM()) < 50 THEN UNIFORM(670, 739, RANDOM())
        WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN UNIFORM(740, 799, RANDOM())
        ELSE UNIFORM(800, 850, RANDOM())
    END AS credit_score,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN UNIFORM(25000, 40000, RANDOM())
        WHEN UNIFORM(0, 100, RANDOM()) < 50 THEN UNIFORM(40000, 60000, RANDOM())
        WHEN UNIFORM(0, 100, RANDOM()) < 75 THEN UNIFORM(60000, 80000, RANDOM())
        WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN UNIFORM(80000, 100000, RANDOM())
        ELSE UNIFORM(100000, 200000, RANDOM())
    END AS annual_income,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'FULL_TIME'
        WHEN 2 THEN 'FULL_TIME'
        WHEN 3 THEN 'FULL_TIME'
        WHEN 4 THEN 'PART_TIME'
        ELSE 'SELF_EMPLOYED'
    END AS employment_status,
    UNIFORM(3, 480, RANDOM()) AS employment_length_months,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'OWN'
        WHEN 2 THEN 'RENT'
        WHEN 3 THEN 'MORTGAGE'
        ELSE 'RENT'
    END AS housing_status,
    CASE UNIFORM(1, 50, RANDOM())
        WHEN 1 THEN 'CA' WHEN 2 THEN 'TX' WHEN 3 THEN 'FL' WHEN 4 THEN 'NY'
        WHEN 5 THEN 'PA' WHEN 6 THEN 'IL' WHEN 7 THEN 'OH' WHEN 8 THEN 'GA'
        WHEN 9 THEN 'NC' WHEN 10 THEN 'MI' WHEN 11 THEN 'NJ' WHEN 12 THEN 'VA'
        WHEN 13 THEN 'WA' WHEN 14 THEN 'AZ' WHEN 15 THEN 'MA' WHEN 16 THEN 'TN'
        WHEN 17 THEN 'IN' WHEN 18 THEN 'MO' WHEN 19 THEN 'MD' WHEN 20 THEN 'WI'
        WHEN 21 THEN 'CO' WHEN 22 THEN 'MN' WHEN 23 THEN 'SC' WHEN 24 THEN 'AL'
        WHEN 25 THEN 'LA' ELSE 'CA'
    END AS state,
    DATEADD(month, -UNIFORM(1, 240, RANDOM()), CURRENT_DATE()) AS member_since_date,
    0 AS total_loans,
    0 AS total_loan_amount,
    UNIFORM(0, 1, RANDOM())::BOOLEAN AS has_checking,
    UNIFORM(0, 1, RANDOM())::BOOLEAN AS has_savings,
    UNIFORM(0, 1, RANDOM())::BOOLEAN AS has_credit_card,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 25 THEN 'BRONZE'
        WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'SILVER'
        WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 'GOLD'
        ELSE 'PLATINUM'
    END AS member_tier,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 100000));

SELECT 'Members: ' || COUNT(*) || ' rows inserted' AS status FROM MEMBERS;

-- ============================================================================
-- Table 3: DEALERS (20,000 rows)
-- ============================================================================
INSERT INTO DEALERS
SELECT
    'DLR' || LPAD(SEQ4()::VARCHAR, 6, '0') AS dealer_id,
    CASE MOD(SEQ4(), 20)
        WHEN 0 THEN 'Premium Auto Group - '
        WHEN 1 THEN 'Elite Motors - '
        WHEN 2 THEN 'Quality Auto Sales - '
        WHEN 3 THEN 'Prime Auto Dealership - '
        WHEN 4 THEN 'Superior Motors - '
        WHEN 5 THEN 'Classic Cars - '
        WHEN 6 THEN 'Precision Auto - '
        WHEN 7 THEN 'Reliable Motors - '
        WHEN 8 THEN 'Affordable Auto - '
        WHEN 9 THEN 'Best Buy Motors - '
        WHEN 10 THEN 'Top Choice Auto - '
        WHEN 11 THEN 'Value Auto Sales - '
        WHEN 12 THEN 'Summit Motors - '
        WHEN 13 THEN 'Prestige Auto - '
        WHEN 14 THEN 'Excellence Motors - '
        WHEN 15 THEN 'Royal Auto Group - '
        WHEN 16 THEN 'Liberty Motors - '
        WHEN 17 THEN 'Victory Auto - '
        WHEN 18 THEN 'Heritage Motors - '
        ELSE 'Freedom Auto Sales - '
    END ||
    CASE UNIFORM(1, 50, RANDOM())
        WHEN 1 THEN 'CA' WHEN 2 THEN 'TX' WHEN 3 THEN 'FL' WHEN 4 THEN 'NY'
        WHEN 5 THEN 'PA' WHEN 6 THEN 'IL' WHEN 7 THEN 'OH' WHEN 8 THEN 'GA'
        ELSE 'CA'
    END AS dealer_name,
    CASE UNIFORM(1, 6, RANDOM())
        WHEN 1 THEN 'NEW_CAR_FRANCHISE'
        WHEN 2 THEN 'USED_CAR_DEALER'
        WHEN 3 THEN 'LUXURY_DEALER'
        WHEN 4 THEN 'INDEPENDENT_DEALER'
        WHEN 5 THEN 'BUY_HERE_PAY_HERE'
        ELSE 'NEW_CAR_FRANCHISE'
    END AS dealer_type,
    CASE UNIFORM(1, 50, RANDOM())
        WHEN 1 THEN 'CA' WHEN 2 THEN 'TX' WHEN 3 THEN 'FL' WHEN 4 THEN 'NY'
        WHEN 5 THEN 'PA' WHEN 6 THEN 'IL' WHEN 7 THEN 'OH' WHEN 8 THEN 'GA'
        WHEN 9 THEN 'NC' WHEN 10 THEN 'MI' WHEN 11 THEN 'NJ' WHEN 12 THEN 'VA'
        WHEN 13 THEN 'WA' WHEN 14 THEN 'AZ' WHEN 15 THEN 'MA' WHEN 16 THEN 'TN'
        ELSE 'CA'
    END AS state,
    CASE 
        WHEN state IN ('CA', 'WA', 'AZ') THEN 'WEST'
        WHEN state IN ('NY', 'PA', 'MA', 'NJ') THEN 'NORTHEAST'
        WHEN state IN ('IL', 'OH', 'MI') THEN 'MIDWEST'
        ELSE 'SOUTH'
    END AS region,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 75 THEN TRUE ELSE FALSE END AS cudl_certified,
    0 AS total_loans_facilitated,
    0 AS avg_loan_amount,
    UNIFORM(35, 50, RANDOM()) / 10.0 AS member_satisfaction_score,
    DATEADD(month, -UNIFORM(6, 120, RANDOM()), CURRENT_DATE()) AS partnership_start_date,
    'ACTIVE' AS active_status,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 20000));

SELECT 'Dealers: ' || COUNT(*) || ' rows inserted' AS status FROM DEALERS;

-- ============================================================================
-- Table 4: LOAN_OFFICERS (250 rows)
-- ============================================================================
INSERT INTO LOAN_OFFICERS
SELECT
    'OFF' || LPAD(SEQ4()::VARCHAR, 5, '0') AS officer_id,
    CASE MOD(SEQ4(), 20)
        WHEN 0 THEN 'James Smith' WHEN 1 THEN 'Mary Johnson'
        WHEN 2 THEN 'John Williams' WHEN 3 THEN 'Patricia Brown'
        WHEN 4 THEN 'Robert Jones' WHEN 5 THEN 'Jennifer Garcia'
        WHEN 6 THEN 'Michael Miller' WHEN 7 THEN 'Linda Davis'
        WHEN 8 THEN 'William Rodriguez' WHEN 9 THEN 'Elizabeth Martinez'
        WHEN 10 THEN 'David Hernandez' WHEN 11 THEN 'Barbara Lopez'
        WHEN 12 THEN 'Richard Gonzalez' WHEN 13 THEN 'Susan Wilson'
        WHEN 14 THEN 'Joseph Anderson' WHEN 15 THEN 'Jessica Thomas'
        WHEN 16 THEN 'Thomas Taylor' WHEN 17 THEN 'Sarah Moore'
        WHEN 18 THEN 'Christopher Jackson' ELSE 'Karen Martin'
    END AS officer_name,
    (SELECT credit_union_id FROM CREDIT_UNIONS ORDER BY RANDOM() LIMIT 1) AS credit_union_id,
    DATEADD(month, -UNIFORM(12, 300, RANDOM()), CURRENT_DATE()) AS hire_date,
    FLOOR(UNIFORM(1, 25, RANDOM())) AS experience_years,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'AUTO_LOANS'
        WHEN 2 THEN 'PERSONAL_LOANS'
        WHEN 3 THEN 'MORTGAGE_LOANS'
        ELSE 'GENERAL_LENDING'
    END AS specialization,
    0 AS total_loans_processed,
    0 AS avg_approval_rate,
    0 AS avg_processing_days,
    'ACTIVE' AS active_status,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 250));

SELECT 'Loan Officers: ' || COUNT(*) || ' rows inserted' AS status FROM LOAN_OFFICERS;

-- ============================================================================
-- Table 5: LOAN_APPLICATIONS (50,000 rows)
-- ============================================================================

-- Drop temp tables if they exist from previous run
DROP TABLE IF EXISTS temp_member_pool;
DROP TABLE IF EXISTS temp_officer_pool;
DROP TABLE IF EXISTS temp_dealer_pool;

-- Create temporary staging table for random lookups
CREATE TEMPORARY TABLE temp_member_pool AS
SELECT member_id, credit_union_id, credit_score, annual_income
FROM MEMBERS
ORDER BY RANDOM()
LIMIT 50000;

CREATE TEMPORARY TABLE temp_officer_pool AS
SELECT officer_id AS loan_officer_id
FROM LOAN_OFFICERS;

CREATE TEMPORARY TABLE temp_dealer_pool AS
SELECT dealer_id
FROM DEALERS
ORDER BY RANDOM()
LIMIT 30000;

-- Generate applications with proper foreign keys
INSERT INTO LOAN_APPLICATIONS
WITH app_generator AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY SEQ4()) AS rn,
        DATEADD(day, -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS application_date,
        CASE UNIFORM(1, 5, RANDOM())
            WHEN 1 THEN 'AUTO_LOAN'
            WHEN 2 THEN 'AUTO_LOAN'
            WHEN 3 THEN 'PERSONAL_LOAN'
            WHEN 4 THEN 'HOME_EQUITY'
            ELSE 'AUTO_LOAN'
        END AS loan_type,
        UNIFORM(15, 50, RANDOM()) / 100.0 AS debt_to_income_ratio,
        CASE WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN TRUE ELSE FALSE END AS employment_verified,
        UNIFORM(0, 100, RANDOM()) AS dealer_rand
    FROM TABLE(GENERATOR(ROWCOUNT => 50000))
),
member_assignments AS (
    SELECT 
        rn,
        member_id,
        credit_union_id,
        credit_score,
        annual_income,
        ROW_NUMBER() OVER (ORDER BY rn) AS member_rn
    FROM (
        SELECT rn FROM app_generator
    ) a
    CROSS JOIN (
        SELECT member_id, credit_union_id, credit_score, annual_income,
               ROW_NUMBER() OVER (ORDER BY RANDOM()) AS pool_rn
        FROM temp_member_pool
    ) m
    WHERE a.rn = m.pool_rn
),
officer_assignments AS (
    SELECT
        rn,
        loan_officer_id,
        ROW_NUMBER() OVER (ORDER BY rn) AS officer_rn
    FROM (
        SELECT rn FROM app_generator
    ) a
    CROSS JOIN (
        SELECT loan_officer_id,
               ROW_NUMBER() OVER (ORDER BY RANDOM()) AS pool_rn
        FROM temp_officer_pool
        CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 200))
    ) o
    WHERE MOD(a.rn, 250) + 1 = MOD(o.pool_rn, 250) + 1
    QUALIFY ROW_NUMBER() OVER (PARTITION BY rn ORDER BY RANDOM()) = 1
),
dealer_assignments AS (
    SELECT
        rn,
        dealer_id,
        ROW_NUMBER() OVER (ORDER BY rn) AS dealer_rn
    FROM (
        SELECT rn FROM app_generator WHERE dealer_rand < 60
    ) a
    CROSS JOIN (
        SELECT dealer_id,
               ROW_NUMBER() OVER (ORDER BY RANDOM()) AS pool_rn
        FROM temp_dealer_pool
    ) d
    WHERE MOD(a.rn, 20000) + 1 = MOD(d.pool_rn, 20000) + 1
    QUALIFY ROW_NUMBER() OVER (PARTITION BY rn ORDER BY RANDOM()) = 1
)
SELECT
    'APP' || LPAD(ag.rn::VARCHAR, 8, '0') AS application_id,
    ma.member_id,
    ma.credit_union_id,
    oa.loan_officer_id,
    da.dealer_id,
    ag.application_date,
    ag.loan_type,
    CASE 
        WHEN ag.loan_type = 'AUTO_LOAN' THEN 'VEHICLE_PURCHASE'
        WHEN ag.loan_type = 'PERSONAL_LOAN' THEN 
            CASE UNIFORM(1, 3, RANDOM())
                WHEN 1 THEN 'DEBT_CONSOLIDATION'
                WHEN 2 THEN 'HOME_IMPROVEMENT'
                ELSE 'MAJOR_PURCHASE'
            END
        ELSE 'HOME_EQUITY_LINE'
    END AS loan_purpose,
    CASE 
        WHEN ag.loan_type = 'AUTO_LOAN' THEN UNIFORM(15000, 45000, RANDOM())
        WHEN ag.loan_type = 'PERSONAL_LOAN' THEN UNIFORM(5000, 35000, RANDOM())
        ELSE UNIFORM(20000, 100000, RANDOM())
    END AS requested_amount,
    CASE 
        WHEN ag.loan_type = 'AUTO_LOAN' THEN UNIFORM(36, 72, RANDOM())
        WHEN ag.loan_type = 'PERSONAL_LOAN' THEN UNIFORM(24, 60, RANDOM())
        ELSE UNIFORM(60, 180, RANDOM())
    END AS loan_term_months,
    UNIFORM(35, 145, RANDOM()) / 10.0 AS interest_rate,
    ma.credit_score AS credit_score_at_app,
    ma.annual_income,
    ag.debt_to_income_ratio,
    ag.employment_verified,
    CASE WHEN ag.loan_type = 'AUTO_LOAN' THEN requested_amount * UNIFORM(110, 150, RANDOM()) / 100.0 ELSE NULL END AS collateral_value,
    CASE WHEN ag.loan_type = 'AUTO_LOAN' THEN requested_amount * UNIFORM(10, 25, RANDOM()) / 100.0 ELSE 0 END AS down_payment_amount,
    CASE WHEN collateral_value IS NOT NULL AND collateral_value > 0 THEN requested_amount / collateral_value ELSE NULL END AS loan_to_value_ratio,
    CASE 
        WHEN ma.credit_score >= 740 AND ag.debt_to_income_ratio < 0.35 THEN 
            CASE UNIFORM(1, 100, RANDOM()) WHEN 1 THEN 'DENIED' WHEN 2 THEN 'PENDING' ELSE 'APPROVED' END
        WHEN ma.credit_score >= 670 THEN
            CASE UNIFORM(1, 3, RANDOM()) WHEN 1 THEN 'APPROVED' WHEN 2 THEN 'PENDING' ELSE 'DENIED' END
        ELSE 'DENIED'
    END AS application_status,
    CASE 
        WHEN application_status IN ('APPROVED', 'DENIED') THEN DATEADD(day, UNIFORM(1, 14, RANDOM()), ag.application_date)
        ELSE NULL
    END AS decision_date,
    CASE 
        WHEN application_status = 'DENIED' THEN 
            CASE UNIFORM(1, 5, RANDOM())
                WHEN 1 THEN 'Insufficient credit history'
                WHEN 2 THEN 'High debt-to-income ratio'
                WHEN 3 THEN 'Unable to verify employment'
                WHEN 4 THEN 'Low credit score'
                ELSE 'Insufficient collateral value'
            END
        WHEN application_status = 'APPROVED' THEN 'Application meets all lending criteria'
        ELSE NULL
    END AS decision_reason,
    CASE WHEN decision_date IS NOT NULL THEN DATEDIFF(day, ag.application_date, decision_date) ELSE NULL END AS days_to_decision,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM app_generator ag
JOIN member_assignments ma ON ag.rn = ma.rn
JOIN officer_assignments oa ON ag.rn = oa.rn
LEFT JOIN dealer_assignments da ON ag.rn = da.rn;

DROP TABLE temp_member_pool;
DROP TABLE temp_officer_pool;
DROP TABLE temp_dealer_pool;

SELECT 'Loan Applications: ' || COUNT(*) || ' rows inserted' AS status FROM LOAN_APPLICATIONS;

-- ============================================================================
-- Table 6: LOANS (35,000 rows - from approved applications)
-- ============================================================================
INSERT INTO LOANS
SELECT
    'LN' || LPAD(ROW_NUMBER() OVER (ORDER BY a.application_date)::VARCHAR, 8, '0') AS loan_id,
    a.application_id,
    a.member_id,
    a.credit_union_id,
    a.loan_officer_id,
    a.dealer_id,
    a.decision_date AS origination_date,
    a.loan_type,
    a.loan_purpose,
    a.requested_amount AS original_loan_amount,
    a.requested_amount * UNIFORM(70, 100, RANDOM()) / 100.0 AS current_balance,
    a.loan_term_months,
    a.interest_rate,
    (a.requested_amount * (a.interest_rate / 1200) * POWER(1 + a.interest_rate / 1200, a.loan_term_months)) / 
        (POWER(1 + a.interest_rate / 1200, a.loan_term_months) - 1) AS monthly_payment,
    FLOOR(DATEDIFF(month, a.decision_date, CURRENT_DATE())) AS payments_made,
    a.loan_term_months - FLOOR(DATEDIFF(month, a.decision_date, CURRENT_DATE())) AS payments_remaining,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 3 THEN UNIFORM(31, 90, RANDOM())
        WHEN UNIFORM(0, 100, RANDOM()) < 8 THEN UNIFORM(1, 30, RANDOM())
        ELSE 0
    END AS days_past_due,
    CASE 
        WHEN days_past_due = 0 THEN 'CURRENT'
        WHEN days_past_due <= 30 THEN '30_DAYS'
        WHEN days_past_due <= 60 THEN '60_DAYS'
        WHEN days_past_due <= 90 THEN '90_DAYS'
        ELSE 'SERIOUS_DELINQUENCY'
    END AS delinquency_status,
    CASE WHEN days_past_due > 120 AND UNIFORM(0, 100, RANDOM()) < 60 THEN TRUE ELSE FALSE END AS has_defaulted,
    CASE WHEN has_defaulted THEN DATEADD(day, UNIFORM(120, 365, RANDOM()), origination_date) ELSE NULL END AS default_date,
    monthly_payment * payments_made * 0.3 AS total_interest_paid,
    CASE 
        WHEN has_defaulted THEN 'CHARGED_OFF'
        WHEN current_balance <= 0 THEN 'PAID_OFF'
        ELSE 'ACTIVE'
    END AS loan_status,
    DATEADD(month, a.loan_term_months, a.decision_date) AS maturity_date,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM LOAN_APPLICATIONS a
WHERE a.application_status = 'APPROVED'
  AND a.decision_date IS NOT NULL
LIMIT 35000;

SELECT 'Loans: ' || COUNT(*) || ' rows inserted' AS status FROM LOANS;

-- ============================================================================
-- Table 7: UNDERWRITING_NOTES (15,000 rows)
-- ============================================================================
INSERT INTO UNDERWRITING_NOTES
SELECT
    'NOTE' || LPAD(ROW_NUMBER() OVER (ORDER BY a.application_date)::VARCHAR, 8, '0') AS note_id,
    a.application_id,
    a.loan_officer_id,
    CASE UNIFORM(1, 10, RANDOM())
        WHEN 1 THEN 'Reviewed applicant credit history. Credit score reflects strong payment history with no recent delinquencies. Employment verification completed through HR department. Debt-to-income ratio is within acceptable range for this loan type.'
        WHEN 2 THEN 'Applicant provided comprehensive documentation including pay stubs, tax returns, and bank statements. Income appears stable with consistent monthly deposits. Collateral appraisal came in at expected value. Recommend approval with standard terms.'
        WHEN 3 THEN 'Credit score indicates some payment irregularities in past 24 months. Spoke with applicant regarding previous late payments - circumstances were due to temporary job loss, now resolved. Current employment verified stable for 18 months.'
        WHEN 4 THEN 'High DTI ratio raises concerns about repayment capacity. However, strong credit history and substantial down payment mitigate risk. Applicant has significant liquid assets in savings. Approval recommended with rate adjustment for risk.'
        WHEN 5 THEN 'Applicant is existing member in good standing with checking and savings accounts. Previous auto loan paid off early with no late payments. Employment verification shows 8 years with current employer. Strong application - recommend approval at premium rate tier.'
        WHEN 6 THEN 'Documentation review reveals inconsistencies in reported income versus tax returns. Requested additional documentation from applicant. Self-employment income appears variable. Will require 3 years of tax returns before making final determination.'
        WHEN 7 THEN 'Credit report shows recent credit inquiries across multiple lenders. Discussed with applicant - shopping for best rates on planned vehicle purchase. No new debt taken on. Credit score supports approval. Normal processing recommended.'
        WHEN 8 THEN 'Collateral value assessment completed. Vehicle appraisal shows LTV ratio well within guidelines. No title issues identified. Insurance requirements discussed with member. All underwriting criteria met - recommend standard approval.'
        WHEN 9 THEN 'Applicant has thin credit file with limited payment history. However, employment is stable and income documentation is strong. Co-signer with excellent credit willing to guarantee loan. Approval recommended with co-signer requirement.'
        ELSE 'Standard application review completed. All documentation in order. Credit profile, income verification, and collateral assessment all meet lending criteria. Recommend approval at standard rates and terms for this loan category.'
    END AS note_text,
    a.application_date AS note_date,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'CREDIT_REVIEW'
        WHEN 2 THEN 'INCOME_VERIFICATION'
        WHEN 3 THEN 'COLLATERAL_ASSESSMENT'
        WHEN 4 THEN 'RISK_ASSESSMENT'
        ELSE 'GENERAL_UNDERWRITING'
    END AS note_category,
    UNIFORM(0, 1, RANDOM())::BOOLEAN AS decision_factor,
    CURRENT_TIMESTAMP() AS created_at
FROM (
    SELECT application_id, loan_officer_id, application_date
    FROM LOAN_APPLICATIONS
    ORDER BY RANDOM()
    LIMIT 15000
) a;

SELECT 'Underwriting Notes: ' || COUNT(*) || ' rows inserted' AS status FROM UNDERWRITING_NOTES;

-- ============================================================================
-- Table 8: LOAN_DOCUMENTS (10,000 rows)
-- ============================================================================
INSERT INTO LOAN_DOCUMENTS
SELECT
    'DOC' || LPAD(ROW_NUMBER() OVER (ORDER BY l.origination_date)::VARCHAR, 8, '0') AS document_id,
    l.loan_id,
    l.application_id,
    CASE UNIFORM(1, 8, RANDOM())
        WHEN 1 THEN 'PAY_STUB'
        WHEN 2 THEN 'TAX_RETURN'
        WHEN 3 THEN 'BANK_STATEMENT'
        WHEN 4 THEN 'EMPLOYMENT_LETTER'
        WHEN 5 THEN 'VEHICLE_TITLE'
        WHEN 6 THEN 'INSURANCE_PROOF'
        WHEN 7 THEN 'APPRAISAL_REPORT'
        ELSE 'LOAN_CONTRACT'
    END AS document_type,
    CASE document_type
        WHEN 'PAY_STUB' THEN 'Pay period ending date. Gross Pay: $4,250.00. Federal Tax: $637.50. State Tax: $212.50. FICA: $325.13. Net Pay: $3,075.00. Year-to-Date Gross: $51,000.00. Employer: ABC Corporation. Employee verification completed.'
        WHEN 'TAX_RETURN' THEN 'Form 1040 U.S. Individual Income Tax Return. Wages, salaries, tips: $85,000. Interest income: $1,250. Adjusted Gross Income: $89,750. Standard deduction: $12,950. Taxable income: $76,800. Total tax: $13,244.'
        WHEN 'BANK_STATEMENT' THEN 'Account statement for period. Beginning balance: $8,450.23. Total deposits: $4,250.00 (salary deposits consistent). Total withdrawals: $3,125.67. Ending balance: $9,574.56. No NSF or overdraft fees.'
        WHEN 'EMPLOYMENT_LETTER' THEN 'To Whom It May Concern: This letter confirms employment with our company. Current position: Senior Analyst. Employment status: Full-time. Base salary: $85,000 annually. Employment is in good standing.'
        WHEN 'VEHICLE_TITLE' THEN 'Certificate of Title - State DMV. Vehicle: Honda Accord. VIN: 1HGCV1F3XLA123456. Owner: Applicant Name. Lien holder: None. Odometer: 24,500 miles. Title status: Clean, no salvage or flood damage.'
        WHEN 'INSURANCE_PROOF' THEN 'Certificate of Insurance. Policy Number: AUTO-987654321. Coverage: Comprehensive and Collision. Deductible: $500. Liability limits: $100,000/$300,000. Named insured: Applicant. Loss payee: Credit Union.'
        WHEN 'APPRAISAL_REPORT' THEN 'Vehicle Appraisal Report. Vehicle condition: Excellent. Mileage: 24,500. Market value: $28,500. Wholesale value: $26,000. Retail value: $30,500. Comparable sales support valuation.'
        ELSE 'Loan Agreement effective date. Principal amount: $27,500. Interest rate: 4.99% APR. Term: 60 months. Monthly payment: $518.00. Late payment fee: $25. Prepayment allowed without penalty.'
    END AS document_text,
    CASE UNIFORM(1, 3, RANDOM())
        WHEN 1 THEN 'VERIFICATION'
        WHEN 2 THEN 'LEGAL'
        ELSE 'SUPPORTING'
    END AS document_category,
    l.origination_date AS upload_date,
    CURRENT_TIMESTAMP() AS created_at
FROM (
    SELECT loan_id, application_id, origination_date
    FROM LOANS
    ORDER BY RANDOM()
    LIMIT 10000
) l;

SELECT 'Loan Documents: ' || COUNT(*) || ' rows inserted' AS status FROM LOAN_DOCUMENTS;

-- ============================================================================
-- Table 9: COMPLIANCE_POLICIES (50 rows)
-- ============================================================================
INSERT INTO COMPLIANCE_POLICIES
SELECT
    'POLICY' || LPAD(SEQ4()::VARCHAR, 3, '0') AS policy_id,
    CASE UNIFORM(1, 10, RANDOM())
        WHEN 1 THEN 'Fair Lending Policy'
        WHEN 2 THEN 'Truth in Lending Act Compliance'
        WHEN 3 THEN 'Bank Secrecy Act and Anti-Money Laundering'
        WHEN 4 THEN 'Auto Loan Collateral Requirements'
        WHEN 5 THEN 'Debt-to-Income Ratio Guidelines'
        WHEN 6 THEN 'Credit Score Minimum Requirements'
        WHEN 7 THEN 'Employment Verification Standards'
        WHEN 8 THEN 'Privacy and Information Security'
        WHEN 9 THEN 'Adverse Action Notice Requirements'
        ELSE 'Flood Insurance Requirements'
    END AS policy_title,
    'This policy establishes standards and procedures for credit union lending operations. All lending personnel must adhere to these guidelines to ensure consistent, compliant, and fair treatment of all members. Policy requirements include documentation standards, approval workflows, exception handling procedures, and quality control measures. Regular policy review ensures alignment with regulatory requirements including Equal Credit Opportunity Act, Truth in Lending Act, Fair Housing Act, and applicable state regulations. Training on policy requirements is mandatory for all staff involved in lending operations. Violations of policy may result in disciplinary action and regulatory sanctions. The institution maintains comprehensive oversight to detect and prevent discrimination, ensure accurate disclosures, protect member privacy, and maintain portfolio quality standards.' AS policy_content,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'LENDING'
        WHEN 2 THEN 'UNDERWRITING'
        WHEN 3 THEN 'COMPLIANCE'
        ELSE 'OPERATIONS'
    END AS policy_category,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'INTERNAL_POLICY'
        WHEN 2 THEN 'NCUA_REGULATION'
        WHEN 3 THEN 'STATE_LAW'
        WHEN 4 THEN 'FEDERAL_LAW'
        ELSE 'INDUSTRY_STANDARD'
    END AS regulation_type,
    DATEADD(month, -UNIFORM(6, 48, RANDOM()), CURRENT_DATE()) AS effective_date,
    DATEADD(month, -UNIFORM(1, 12, RANDOM()), CURRENT_DATE()) AS last_review_date,
    'lending, policy, compliance, standards, procedures, regulation' AS keywords,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 50));

SELECT 'Compliance Policies: ' || COUNT(*) || ' rows inserted' AS status FROM COMPLIANCE_POLICIES;

-- ============================================================================
-- Final Summary
-- ============================================================================
SELECT 'Data Generation Complete!' AS status;

SELECT 
    'CREDIT_UNIONS' AS table_name, COUNT(*) AS row_count FROM CREDIT_UNIONS
UNION ALL
SELECT 'MEMBERS', COUNT(*) FROM MEMBERS
UNION ALL
SELECT 'DEALERS', COUNT(*) FROM DEALERS
UNION ALL
SELECT 'LOAN_OFFICERS', COUNT(*) FROM LOAN_OFFICERS
UNION ALL
SELECT 'LOAN_APPLICATIONS', COUNT(*) FROM LOAN_APPLICATIONS
UNION ALL
SELECT 'LOANS', COUNT(*) FROM LOANS
UNION ALL
SELECT 'UNDERWRITING_NOTES', COUNT(*) FROM UNDERWRITING_NOTES
UNION ALL
SELECT 'LOAN_DOCUMENTS', COUNT(*) FROM LOAN_DOCUMENTS
UNION ALL
SELECT 'COMPLIANCE_POLICIES', COUNT(*) FROM COMPLIANCE_POLICIES;
