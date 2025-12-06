-- ============================================================================
-- Hootsuite Intelligence Agent - Table Definitions
-- ============================================================================
-- Purpose: Create all core tables for Hootsuite platform
-- Tables: 8 core entities with proper constraints and change tracking
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE HOOTSUITE_WH;

-- ============================================================================
-- Table 1: CUSTOMERS
-- ============================================================================
CREATE OR REPLACE TABLE CUSTOMERS (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_name VARCHAR(200) NOT NULL,
    plan_type VARCHAR(50) NOT NULL,
    industry VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    employee_count NUMBER(10,0) DEFAULT 0,
    annual_revenue_millions NUMBER(15,2) DEFAULT 0,
    contract_start_date DATE NOT NULL,
    contract_renewal_date DATE NOT NULL,
    account_manager VARCHAR(100),
    churn_risk_score NUMBER(3,2) DEFAULT 0.0,
    active_status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
COMMENT = 'Hootsuite business customers';

-- ============================================================================
-- Table 2: SOCIAL_ACCOUNTS
-- ============================================================================
CREATE OR REPLACE TABLE SOCIAL_ACCOUNTS (
    account_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    platform VARCHAR(50) NOT NULL, -- Twitter, LinkedIn, Facebook, Instagram
    account_handle VARCHAR(100) NOT NULL,
    follower_count NUMBER(15,0) DEFAULT 0,
    verified_status BOOLEAN DEFAULT FALSE,
    account_created_date DATE NOT NULL,
    connection_status VARCHAR(20) DEFAULT 'CONNECTED',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
COMMENT = 'Social media accounts linked to Hootsuite';

-- ============================================================================
-- Table 3: CAMPAIGNS
-- ============================================================================
CREATE OR REPLACE TABLE CAMPAIGNS (
    campaign_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    campaign_name VARCHAR(200) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget_allocated NUMBER(15,2) DEFAULT 0,
    budget_spent NUMBER(15,2) DEFAULT 0,
    objective VARCHAR(50) NOT NULL, -- AWARENESS, CONVERSION, TRAFFIC
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
COMMENT = 'Marketing campaigns managed in Hootsuite';

-- ============================================================================
-- Table 4: POSTS
-- ============================================================================
CREATE OR REPLACE TABLE POSTS (
    post_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    account_id VARCHAR(50) NOT NULL,
    campaign_id VARCHAR(50),
    content_text VARCHAR(5000) NOT NULL,
    media_type VARCHAR(20) DEFAULT 'TEXT', -- IMAGE, VIDEO, TEXT, LINK
    scheduled_time TIMESTAMP_NTZ,
    published_time TIMESTAMP_NTZ,
    status VARCHAR(20) NOT NULL, -- SCHEDULED, PUBLISHED, FAILED
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
COMMENT = 'Social media posts created and scheduled';

-- ============================================================================
-- Table 5: ENGAGEMENT_METRICS
-- ============================================================================
CREATE OR REPLACE TABLE ENGAGEMENT_METRICS (
    metric_id VARCHAR(50) PRIMARY KEY,
    post_id VARCHAR(50) NOT NULL,
    customer_id VARCHAR(50) NOT NULL,
    likes NUMBER(10,0) DEFAULT 0,
    shares NUMBER(10,0) DEFAULT 0,
    comments NUMBER(10,0) DEFAULT 0,
    clicks NUMBER(10,0) DEFAULT 0,
    impressions NUMBER(15,0) DEFAULT 0,
    reach NUMBER(15,0) DEFAULT 0,
    engagement_rate NUMBER(5,4) DEFAULT 0,
    metric_date DATE NOT NULL,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
COMMENT = 'Performance metrics for published posts';

-- ============================================================================
-- Table 6: SUPPORT_TICKETS (Unstructured)
-- ============================================================================
CREATE OR REPLACE TABLE SUPPORT_TICKETS (
    ticket_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    issue_summary VARCHAR(200) NOT NULL,
    issue_description VARCHAR(10000) NOT NULL,
    resolution_notes VARCHAR(10000),
    priority VARCHAR(20) NOT NULL, -- LOW, MEDIUM, HIGH, URGENT
    status VARCHAR(20) DEFAULT 'OPEN',
    category VARCHAR(50) NOT NULL,
    assigned_agent VARCHAR(100),
    created_date TIMESTAMP_NTZ NOT NULL,
    closed_date TIMESTAMP_NTZ,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
COMMENT = 'Customer support tickets for Cortex Search';

-- ============================================================================
-- Table 7: KNOWLEDGE_BASE (Unstructured)
-- ============================================================================
CREATE OR REPLACE TABLE KNOWLEDGE_BASE (
    article_id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    content_text VARCHAR(16777216) NOT NULL, -- Maximize size for long articles
    category VARCHAR(100) NOT NULL,
    tags VARCHAR(500),
    author VARCHAR(100),
    publish_date DATE NOT NULL,
    last_review_date DATE NOT NULL,
    view_count NUMBER(10,0) DEFAULT 0,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
COMMENT = 'Help center articles for Cortex Search';

-- ============================================================================
-- Table 8: MARKETING_ASSETS (Unstructured)
-- ============================================================================
CREATE OR REPLACE TABLE MARKETING_ASSETS (
    asset_id VARCHAR(50) PRIMARY KEY,
    campaign_id VARCHAR(50),
    asset_name VARCHAR(200) NOT NULL,
    asset_description VARCHAR(5000) NOT NULL, -- Text description of image/video content
    asset_type VARCHAR(50) NOT NULL, -- IMAGE, VIDEO, COPY_DECK
    file_url VARCHAR(500),
    upload_date DATE NOT NULL,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
COMMENT = 'Marketing assets descriptions for Cortex Search';

-- ============================================================================
-- Confirmation
-- ============================================================================
SELECT 'All 8 Hootsuite tables created successfully with change tracking enabled' AS STATUS;

SHOW TABLES IN SCHEMA RAW;

