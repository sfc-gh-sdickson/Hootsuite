-- ============================================================================
-- Hootsuite Intelligence Agent - Synthetic Data Generation
-- ============================================================================
-- Purpose: Generate realistic synthetic data for Hootsuite platform
-- Data Volume: ~200k+ total rows across 8 tables
-- Execution Time: 10-15 minutes on MEDIUM warehouse
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE HOOTSUITE_WH;

-- ============================================================================
-- Table 1: CUSTOMERS (5,000 rows)
-- ============================================================================
INSERT INTO CUSTOMERS
SELECT
    'CUST' || LPAD(SEQ4()::VARCHAR, 6, '0') AS customer_id,
    CASE MOD(SEQ4(), 20)
        WHEN 0 THEN 'Acme Corp - '
        WHEN 1 THEN 'Global Tech - '
        WHEN 2 THEN 'Innovate Solutions - '
        WHEN 3 THEN 'Blue Sky Media - '
        WHEN 4 THEN 'Urban Outfitters - '
        WHEN 5 THEN 'Green Energy Co - '
        WHEN 6 THEN 'Starlight Entertainment - '
        WHEN 7 THEN 'Oceanic Airlines - '
        WHEN 8 THEN 'Cyberdyne Systems - '
        WHEN 9 THEN 'Wayne Enterprises - '
        WHEN 10 THEN 'Stark Industries - '
        WHEN 11 THEN 'Umbrella Corp - '
        WHEN 12 THEN 'Massive Dynamic - '
        WHEN 13 THEN 'Hooli - '
        WHEN 14 THEN 'Pied Piper - '
        WHEN 15 THEN 'Soylent Corp - '
        WHEN 16 THEN 'Initech - '
        WHEN 17 THEN 'Dunder Mifflin - '
        WHEN 18 THEN 'Aperture Science - '
        ELSE 'Black Mesa - '
    END || LPAD(SEQ4()::VARCHAR, 4, '0') AS customer_name,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'PROFESSIONAL'
        WHEN 2 THEN 'TEAM'
        WHEN 3 THEN 'BUSINESS'
        ELSE 'ENTERPRISE'
    END AS plan_type,
    CASE UNIFORM(1, 10, RANDOM())
        WHEN 1 THEN 'RETAIL'
        WHEN 2 THEN 'TECHNOLOGY'
        WHEN 3 THEN 'FINANCE'
        WHEN 4 THEN 'HEALTHCARE'
        WHEN 5 THEN 'EDUCATION'
        WHEN 6 THEN 'GOVERNMENT'
        WHEN 7 THEN 'NON_PROFIT'
        WHEN 8 THEN 'ENTERTAINMENT'
        WHEN 9 THEN 'REAL_ESTATE'
        ELSE 'MANUFACTURING'
    END AS industry,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'NA'
        WHEN 2 THEN 'EMEA'
        WHEN 3 THEN 'APAC'
        ELSE 'LATAM'
    END AS region,
    UNIFORM(10, 5000, RANDOM()) AS employee_count,
    UNIFORM(1, 500, RANDOM()) AS annual_revenue_millions,
    DATEADD(month, -UNIFORM(1, 60, RANDOM()), CURRENT_DATE()) AS contract_start_date,
    DATEADD(year, 1, contract_start_date) AS contract_renewal_date,
    'Account Manager ' || UNIFORM(1, 20, RANDOM()) AS account_manager,
    UNIFORM(0, 100, RANDOM()) / 100.0 AS churn_risk_score,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN 'ACTIVE' ELSE 'CHURNED' END AS active_status,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 5000));

SELECT 'Customers: ' || COUNT(*) || ' rows inserted' AS status FROM CUSTOMERS;

-- ============================================================================
-- Table 2: SOCIAL_ACCOUNTS (15,000 rows - ~3 per customer)
-- ============================================================================
INSERT INTO SOCIAL_ACCOUNTS
SELECT
    'ACC' || LPAD(SEQ4()::VARCHAR, 8, '0') AS account_id,
    (SELECT customer_id FROM CUSTOMERS ORDER BY RANDOM() LIMIT 1) AS customer_id,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'TWITTER'
        WHEN 2 THEN 'LINKEDIN'
        WHEN 3 THEN 'FACEBOOK'
        ELSE 'INSTAGRAM'
    END AS platform,
    '@handle_' || SEQ4() AS account_handle,
    UNIFORM(100, 1000000, RANDOM()) AS follower_count,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN TRUE ELSE FALSE END AS verified_status,
    DATEADD(day, -UNIFORM(100, 2000, RANDOM()), CURRENT_DATE()) AS account_created_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'CONNECTED' ELSE 'DISCONNECTED' END AS connection_status,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 15000));

SELECT 'Social Accounts: ' || COUNT(*) || ' rows inserted' AS status FROM SOCIAL_ACCOUNTS;

-- ============================================================================
-- Table 3: CAMPAIGNS (10,000 rows)
-- ============================================================================
INSERT INTO CAMPAIGNS
SELECT
    'CMP' || LPAD(SEQ4()::VARCHAR, 8, '0') AS campaign_id,
    (SELECT customer_id FROM CUSTOMERS ORDER BY RANDOM() LIMIT 1) AS customer_id,
    'Campaign ' || SEQ4() || ' - ' || 
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'Summer Sale'
        WHEN 2 THEN 'Product Launch'
        WHEN 3 THEN 'Brand Awareness'
        WHEN 4 THEN 'Holiday Special'
        ELSE 'Webinar Series'
    END AS campaign_name,
    DATEADD(day, -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS start_date,
    DATEADD(day, UNIFORM(14, 90, RANDOM()), start_date) AS end_date,
    UNIFORM(1000, 50000, RANDOM()) AS budget_allocated,
    budget_allocated * UNIFORM(50, 100, RANDOM()) / 100.0 AS budget_spent,
    CASE UNIFORM(1, 3, RANDOM())
        WHEN 1 THEN 'AWARENESS'
        WHEN 2 THEN 'CONVERSION'
        ELSE 'TRAFFIC'
    END AS objective,
    CASE 
        WHEN end_date < CURRENT_DATE() THEN 'COMPLETED'
        WHEN start_date > CURRENT_DATE() THEN 'SCHEDULED'
        ELSE 'ACTIVE'
    END AS status,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 10000));

SELECT 'Campaigns: ' || COUNT(*) || ' rows inserted' AS status FROM CAMPAIGNS;

-- ============================================================================
-- Table 4: POSTS (100,000 rows)
-- ============================================================================
-- Generate posts linked to customers, accounts, and optionally campaigns
INSERT INTO POSTS
WITH post_gen AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY SEQ4()) AS rn,
        DATEADD(minute, -UNIFORM(0, 525600, RANDOM()), CURRENT_TIMESTAMP()) AS scheduled_time,
        CASE UNIFORM(1, 4, RANDOM())
            WHEN 1 THEN 'IMAGE'
            WHEN 2 THEN 'VIDEO'
            WHEN 3 THEN 'LINK'
            ELSE 'TEXT'
        END AS media_type,
        UNIFORM(1, 100, RANDOM()) AS campaign_rand
    FROM TABLE(GENERATOR(ROWCOUNT => 100000))
)
SELECT
    'PST' || LPAD(p.rn::VARCHAR, 8, '0') AS post_id,
    sa.customer_id,
    sa.account_id,
    CASE WHEN p.campaign_rand < 40 THEN (SELECT campaign_id FROM CAMPAIGNS c WHERE c.customer_id = sa.customer_id LIMIT 1) ELSE NULL END AS campaign_id,
    CASE p.media_type
        WHEN 'IMAGE' THEN 'Check out our latest photo! #image #content'
        WHEN 'VIDEO' THEN 'Watch this video to learn more about our features. #video #demo'
        WHEN 'LINK' THEN 'Read our new blog post here: https://bit.ly/example #blog #link'
        ELSE 'Exciting news coming soon! Stay tuned. #update #announcement'
    END AS content_text,
    p.media_type,
    p.scheduled_time,
    CASE WHEN p.scheduled_time < CURRENT_TIMESTAMP() THEN p.scheduled_time ELSE NULL END AS published_time,
    CASE 
        WHEN p.scheduled_time < CURRENT_TIMESTAMP() THEN 'PUBLISHED'
        ELSE 'SCHEDULED'
    END AS status,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM post_gen p
JOIN (SELECT account_id, customer_id, ROW_NUMBER() OVER (ORDER BY RANDOM()) as rn FROM SOCIAL_ACCOUNTS) sa
ON MOD(p.rn, 15000) + 1 = sa.rn; -- Rough distribution across accounts

SELECT 'Posts: ' || COUNT(*) || ' rows inserted' AS status FROM POSTS;

-- ============================================================================
-- Table 5: ENGAGEMENT_METRICS (100,000 rows - 1 per post)
-- ============================================================================
INSERT INTO ENGAGEMENT_METRICS
SELECT
    'MET' || LPAD(SEQ4()::VARCHAR, 8, '0') AS metric_id,
    post_id,
    customer_id,
    UNIFORM(0, 500, RANDOM()) AS likes,
    UNIFORM(0, 100, RANDOM()) AS shares,
    UNIFORM(0, 50, RANDOM()) AS comments,
    UNIFORM(0, 200, RANDOM()) AS clicks,
    UNIFORM(100, 10000, RANDOM()) AS impressions,
    impressions * UNIFORM(50, 90, RANDOM()) / 100.0 AS reach,
    (likes + shares + comments + clicks) / NULLIF(impressions, 0) AS engagement_rate,
    published_time::DATE AS metric_date,
    CURRENT_TIMESTAMP() AS created_at
FROM POSTS
WHERE status = 'PUBLISHED';

SELECT 'Engagement Metrics: ' || COUNT(*) || ' rows inserted' AS status FROM ENGAGEMENT_METRICS;

-- ============================================================================
-- Table 6: SUPPORT_TICKETS (20,000 rows)
-- ============================================================================
INSERT INTO SUPPORT_TICKETS
SELECT
    'TKT' || LPAD(SEQ4()::VARCHAR, 8, '0') AS ticket_id,
    (SELECT customer_id FROM CUSTOMERS ORDER BY RANDOM() LIMIT 1) AS customer_id,
    CASE UNIFORM(1, 6, RANDOM())
        WHEN 1 THEN 'Cannot login to dashboard'
        WHEN 2 THEN 'Analytics report not loading'
        WHEN 3 THEN 'Post failed to publish to Instagram'
        WHEN 4 THEN 'Billing inquiry regarding invoice'
        WHEN 5 THEN 'Need help adding team member'
        ELSE 'API connection timeout'
    END AS issue_summary,
    'I am experiencing an issue with ' || issue_summary || '. I have tried clearing cache and restarting but the problem persists. Please assist.' AS issue_description,
    CASE UNIFORM(1, 3, RANDOM())
        WHEN 1 THEN 'Resolved by resetting user permissions.'
        WHEN 2 THEN 'Escalated to engineering team for bug fix.'
        ELSE NULL
    END AS resolution_notes,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'LOW'
        WHEN 2 THEN 'MEDIUM'
        WHEN 3 THEN 'HIGH'
        ELSE 'URGENT'
    END AS priority,
    CASE WHEN resolution_notes IS NOT NULL THEN 'CLOSED' ELSE 'OPEN' END AS status,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'ACCESS'
        WHEN 2 THEN 'ANALYTICS'
        WHEN 3 THEN 'PUBLISHING'
        WHEN 4 THEN 'BILLING'
        ELSE 'API'
    END AS category,
    'Agent ' || UNIFORM(1, 50, RANDOM()) AS assigned_agent,
    DATEADD(day, -UNIFORM(0, 90, RANDOM()), CURRENT_TIMESTAMP()) AS created_date,
    CASE WHEN status = 'CLOSED' THEN DATEADD(hour, UNIFORM(1, 72, RANDOM()), created_date) ELSE NULL END AS closed_date,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 20000));

SELECT 'Support Tickets: ' || COUNT(*) || ' rows inserted' AS status FROM SUPPORT_TICKETS;

-- ============================================================================
-- Table 7: KNOWLEDGE_BASE (100 rows)
-- ============================================================================
INSERT INTO KNOWLEDGE_BASE
SELECT
    'KB' || LPAD(SEQ4()::VARCHAR, 4, '0') AS article_id,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'How to Connect Social Accounts'
        WHEN 2 THEN 'Troubleshooting Instagram Publishing'
        WHEN 3 THEN 'Understanding Analytics Reports'
        WHEN 4 THEN 'Managing Team Permissions'
        ELSE 'Billing and Invoices Guide'
    END || ' - ' || SEQ4() AS title,
    'This article explains how to resolve common issues. First, ensure your browser is updated. Steps: 1. Go to settings. 2. Select the option. 3. Save changes. If issues persist, contact support. Key concepts included: authentication, tokens, permissions.' AS content_text,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'SETUP'
        WHEN 2 THEN 'TROUBLESHOOTING'
        WHEN 3 THEN 'ANALYTICS'
        ELSE 'ACCOUNT'
    END AS category,
    'guide, help, tutorial, settings' AS tags,
    'Content Team' AS author,
    DATEADD(month, -UNIFORM(1, 24, RANDOM()), CURRENT_DATE()) AS publish_date,
    DATEADD(day, -UNIFORM(0, 30, RANDOM()), CURRENT_DATE()) AS last_review_date,
    UNIFORM(100, 5000, RANDOM()) AS view_count,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 100));

SELECT 'Knowledge Base: ' || COUNT(*) || ' rows inserted' AS status FROM KNOWLEDGE_BASE;

-- ============================================================================
-- Table 8: MARKETING_ASSETS (5,000 rows)
-- ============================================================================
INSERT INTO MARKETING_ASSETS
SELECT
    'AST' || LPAD(SEQ4()::VARCHAR, 6, '0') AS asset_id,
    (SELECT campaign_id FROM CAMPAIGNS ORDER BY RANDOM() LIMIT 1) AS campaign_id,
    'Asset_' || SEQ4() AS asset_name,
    CASE UNIFORM(1, 3, RANDOM())
        WHEN 1 THEN 'High resolution image of product being used in lifestyle setting. Shows happy customers outdoors.'
        WHEN 2 THEN 'Video tutorial demonstrating new features. Includes screen recording and voiceover.'
        ELSE 'Copy deck for email marketing campaign. Includes subject lines, body text, and CTAs.'
    END AS asset_description,
    CASE UNIFORM(1, 3, RANDOM())
        WHEN 1 THEN 'IMAGE'
        WHEN 2 THEN 'VIDEO'
        ELSE 'COPY_DECK'
    END AS asset_type,
    'https://assets.hootsuite.com/files/' || asset_id AS file_url,
    DATEADD(day, -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS upload_date,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 5000));

SELECT 'Marketing Assets: ' || COUNT(*) || ' rows inserted' AS status FROM MARKETING_ASSETS;

-- ============================================================================
-- Final Summary
-- ============================================================================
SELECT 'Data Generation Complete!' AS status;

SELECT 'CUSTOMERS', COUNT(*) FROM CUSTOMERS
UNION ALL
SELECT 'SOCIAL_ACCOUNTS', COUNT(*) FROM SOCIAL_ACCOUNTS
UNION ALL
SELECT 'CAMPAIGNS', COUNT(*) FROM CAMPAIGNS
UNION ALL
SELECT 'POSTS', COUNT(*) FROM POSTS
UNION ALL
SELECT 'ENGAGEMENT_METRICS', COUNT(*) FROM ENGAGEMENT_METRICS
UNION ALL
SELECT 'SUPPORT_TICKETS', COUNT(*) FROM SUPPORT_TICKETS
UNION ALL
SELECT 'KNOWLEDGE_BASE', COUNT(*) FROM KNOWLEDGE_BASE
UNION ALL
SELECT 'MARKETING_ASSETS', COUNT(*) FROM MARKETING_ASSETS;
