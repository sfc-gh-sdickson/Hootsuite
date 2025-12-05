-- ============================================================================
-- Hootsuite Intelligence Agent - Table Definitions
-- ============================================================================
-- Purpose: Define table structures for Hootsuite social media platform
-- Schema: RAW
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA RAW;

-- ============================================================================
-- Table 1: ORGANIZATIONS (Customers)
-- ============================================================================
CREATE OR REPLACE TABLE ORGANIZATIONS (
    organization_id VARCHAR(10) PRIMARY KEY,
    organization_name VARCHAR(100),
    industry VARCHAR(50),
    plan_tier VARCHAR(20), -- PROFESSIONAL, TEAM, BUSINESS, ENTERPRISE
    subscription_start_date DATE,
    country VARCHAR(50),
    employee_count INT,
    is_active BOOLEAN,
    created_at TIMESTAMP_NTZ,
    last_updated TIMESTAMP_NTZ
) COMMENT = 'Hootsuite customer organizations and subscription details';

-- ============================================================================
-- Table 2: USERS (Team Members)
-- ============================================================================
CREATE OR REPLACE TABLE USERS (
    user_id VARCHAR(10) PRIMARY KEY,
    organization_id VARCHAR(10) REFERENCES ORGANIZATIONS(organization_id),
    full_name VARCHAR(100),
    email VARCHAR(100),
    role VARCHAR(30), -- ADMIN, EDITOR, VIEWER
    last_login_date TIMESTAMP_NTZ,
    is_active BOOLEAN,
    created_at TIMESTAMP_NTZ,
    last_updated TIMESTAMP_NTZ
) COMMENT = 'Individual users within organizations';

-- ============================================================================
-- Table 3: SOCIAL_PROFILES (Connected Accounts)
-- ============================================================================
CREATE OR REPLACE TABLE SOCIAL_PROFILES (
    profile_id VARCHAR(10) PRIMARY KEY,
    organization_id VARCHAR(10) REFERENCES ORGANIZATIONS(organization_id),
    network VARCHAR(20), -- FACEBOOK, TWITTER, LINKEDIN, INSTAGRAM, TIKTOK
    profile_name VARCHAR(100),
    follower_count INT,
    is_verified BOOLEAN,
    connected_date DATE,
    created_at TIMESTAMP_NTZ,
    last_updated TIMESTAMP_NTZ
) COMMENT = 'Social media profiles connected to Hootsuite';

-- ============================================================================
-- Table 4: CAMPAIGNS (Marketing Initiatives)
-- ============================================================================
CREATE OR REPLACE TABLE CAMPAIGNS (
    campaign_id VARCHAR(10) PRIMARY KEY,
    organization_id VARCHAR(10) REFERENCES ORGANIZATIONS(organization_id),
    campaign_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    budget_amount DECIMAL(12, 2),
    status VARCHAR(20), -- PLANNED, ACTIVE, COMPLETED, PAUSED
    description VARCHAR(500),
    created_at TIMESTAMP_NTZ,
    last_updated TIMESTAMP_NTZ
) COMMENT = 'Marketing campaigns grouping multiple posts';

-- ============================================================================
-- Table 5: POSTS (Content)
-- ============================================================================
CREATE OR REPLACE TABLE POSTS (
    post_id VARCHAR(12) PRIMARY KEY,
    organization_id VARCHAR(10) REFERENCES ORGANIZATIONS(organization_id),
    user_id VARCHAR(10) REFERENCES USERS(user_id),
    profile_id VARCHAR(10) REFERENCES SOCIAL_PROFILES(profile_id),
    campaign_id VARCHAR(10) REFERENCES CAMPAIGNS(campaign_id),
    post_text VARCHAR, -- Unstructured content
    media_type VARCHAR(20), -- IMAGE, VIDEO, LINK, TEXT
    scheduled_time TIMESTAMP_NTZ,
    published_time TIMESTAMP_NTZ,
    status VARCHAR(20), -- DRAFT, SCHEDULED, PUBLISHED, FAILED
    sentiment_score FLOAT, -- Pre-calculated or ML inferred
    created_at TIMESTAMP_NTZ,
    last_updated TIMESTAMP_NTZ
) COMMENT = 'Social media posts created and published via Hootsuite';

-- ============================================================================
-- Table 6: ENGAGEMENTS (Analytics)
-- ============================================================================
CREATE OR REPLACE TABLE ENGAGEMENTS (
    engagement_id VARCHAR(12) PRIMARY KEY,
    post_id VARCHAR(12) REFERENCES POSTS(post_id),
    likes INT,
    shares INT,
    comments INT,
    clicks INT,
    impressions INT,
    reach INT,
    engagement_rate FLOAT,
    recorded_date DATE,
    created_at TIMESTAMP_NTZ
) COMMENT = 'Performance metrics for published posts';

-- ============================================================================
-- Table 7: SUPPORT_TICKETS (For Churn Prediction)
-- ============================================================================
CREATE OR REPLACE TABLE SUPPORT_TICKETS (
    ticket_id VARCHAR(10) PRIMARY KEY,
    organization_id VARCHAR(10) REFERENCES ORGANIZATIONS(organization_id),
    user_id VARCHAR(10) REFERENCES USERS(user_id),
    issue_category VARCHAR(50), -- BILLING, TECHNICAL, FEATURE_REQUEST
    priority VARCHAR(10), -- LOW, MEDIUM, HIGH, URGENT
    status VARCHAR(20), -- OPEN, IN_PROGRESS, RESOLVED, CLOSED
    created_date TIMESTAMP_NTZ,
    resolved_date TIMESTAMP_NTZ,
    satisfaction_score INT, -- 1-5
    created_at TIMESTAMP_NTZ
) COMMENT = 'Customer support tickets and resolution details';

-- ============================================================================
-- Table 8: STRATEGY_DOCUMENTS (Unstructured for Search)
-- ============================================================================
CREATE OR REPLACE TABLE STRATEGY_DOCUMENTS (
    document_id VARCHAR(10) PRIMARY KEY,
    organization_id VARCHAR(10) REFERENCES ORGANIZATIONS(organization_id),
    title VARCHAR(200),
    content VARCHAR, -- Full text content
    category VARCHAR(50), -- CONTENT_STRATEGY, BRAND_GUIDELINES, CAMPAIGN_BRIEF
    author_id VARCHAR(10),
    upload_date DATE,
    created_at TIMESTAMP_NTZ,
    last_updated TIMESTAMP_NTZ
) COMMENT = 'Unstructured strategy documents and guidelines';

-- ============================================================================
-- Confirmation
-- ============================================================================
SELECT 'Hootsuite tables created successfully' AS STATUS;
SHOW TABLES IN SCHEMA RAW;

