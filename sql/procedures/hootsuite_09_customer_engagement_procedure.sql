-- ============================================================================
-- Hootsuite Customer Engagement Automation Procedure
-- ============================================================================
-- Purpose: Trigger automated customer success workflows for at-risk customers
-- Includes: Email campaigns, account health checks, and engagement tracking
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE HOOTSUITE_WH;

-- ============================================================================
-- Create Results Tracking Table
-- ============================================================================
CREATE TABLE IF NOT EXISTS CUSTOMER_ENGAGEMENT_RESULTS (
    result_id VARCHAR(50) DEFAULT UUID_STRING(),
    customer_id VARCHAR(50) NOT NULL,
    engagement_type VARCHAR(50) NOT NULL,
    ab_test_variant VARCHAR(10),
    email_sent BOOLEAN DEFAULT FALSE,
    account_review_scheduled BOOLEAN DEFAULT FALSE,
    churn_risk_score FLOAT,
    executed_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (result_id)
) COMMENT = 'Tracks customer engagement automation results and A/B testing';

-- ============================================================================
-- Customer Engagement Automation Function (converted from procedure for agent compatibility)
-- ============================================================================
CREATE OR REPLACE FUNCTION TRIGGER_CUSTOMER_ENGAGEMENT(
    CUSTOMER_ID STRING,
    ENGAGEMENT_TYPE STRING,
    AB_TEST_VARIANT STRING
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python', 'requests')
HANDLER = 'main'
AS $$
import requests
import json

def main(session, CUSTOMER_ID, ENGAGEMENT_TYPE, AB_TEST_VARIANT):
    """
    Trigger automated customer engagement workflows
    
    Args:
        CUSTOMER_ID: Customer identifier
        ENGAGEMENT_TYPE: Type of engagement (CHURN_PREVENTION, UPSELL, ONBOARDING)
        AB_TEST_VARIANT: A/B test variant (A or B)
    
    Returns:
        Summary of actions taken
    """
    
    # 1. Fetch customer data and risk assessment
    customer_query = f"""
        SELECT 
            c.customer_id,
            c.customer_name,
            c.industry,
            c.plan_type,
            c.churn_risk_score,
            c.annual_revenue_millions,
            COUNT(DISTINCT sa.account_id) as connected_accounts,
            COUNT(DISTINCT t.ticket_id) as open_tickets
        FROM HOOTSUITE_INTELLIGENCE.RAW.CUSTOMERS c
        LEFT JOIN HOOTSUITE_INTELLIGENCE.RAW.SOCIAL_ACCOUNTS sa 
            ON c.customer_id = sa.customer_id
        LEFT JOIN HOOTSUITE_INTELLIGENCE.RAW.SUPPORT_TICKETS t 
            ON c.customer_id = t.customer_id AND t.status = 'OPEN'
        WHERE c.customer_id = '{CUSTOMER_ID}'
        GROUP BY c.customer_id, c.customer_name, c.industry, c.plan_type, 
                 c.churn_risk_score, c.annual_revenue_millions
    """
    
    customer_data = session.sql(customer_query).collect()
    
    if not customer_data:
        return f"ERROR: Customer {CUSTOMER_ID} not found"
    
    customer = customer_data[0]
    
    # 2. A/B Testing Logic - Determine engagement strategy
    if AB_TEST_VARIANT == 'A':
        email_template = 'high_touch_personalized'
        offer_type = 'premium_training_session'
        priority = 'high'
    else:
        email_template = 'automated_tips'
        offer_type = 'self_service_resources'
        priority = 'medium'
    
    # 3. Determine actions based on engagement type and risk
    email_sent = False
    review_scheduled = False
    actions_taken = []
    
    # High churn risk customers get immediate attention
    if customer['CHURN_RISK_SCORE'] > 0.7:
        email_sent = True
        review_scheduled = True
        actions_taken.append('High-risk customer: Email + Account Review')
        
        # Simulate email service call
        email_payload = {
            'to': f"{customer['CUSTOMER_NAME'].lower().replace(' ', '.')}@company.com",
            'template': email_template,
            'personalization': {
                'customer_name': customer['CUSTOMER_NAME'],
                'industry': customer['INDUSTRY'],
                'offer_type': offer_type,
                'churn_risk': f"{customer['CHURN_RISK_SCORE']:.2f}",
                'connected_accounts': customer['CONNECTED_ACCOUNTS']
            }
        }
        actions_taken.append(f"Email queued: {email_template}")
        
    # Medium risk or upsell opportunities
    elif customer['CHURN_RISK_SCORE'] > 0.3 or engagement_type == 'UPSELL':
        email_sent = True
        actions_taken.append('Medium-risk customer: Email sent')
        
    # Schedule account review for high-value or high-risk customers
    if customer['CHURN_RISK_SCORE'] > 0.7 or customer['ANNUAL_REVENUE_MILLIONS'] > 100:
        review_scheduled = True
        calendar_payload = {
            'customer_id': CUSTOMER_ID,
            'priority': priority,
            'suggested_times': ['next_business_day'],
            'csm_assignment': 'auto_assign',
            'reason': f"Churn Risk: {customer['CHURN_RISK_SCORE']:.2f}, Open Tickets: {customer['OPEN_TICKETS']}"
        }
        actions_taken.append(f"Account review scheduled: Priority {priority}")
    
    # 4. Log engagement results for tracking and A/B testing analysis
    log_query = f"""
        INSERT INTO HOOTSUITE_INTELLIGENCE.ANALYTICS.CUSTOMER_ENGAGEMENT_RESULTS 
        (customer_id, engagement_type, ab_test_variant, email_sent, 
         account_review_scheduled, churn_risk_score, executed_at)
        VALUES (
            '{CUSTOMER_ID}', 
            '{ENGAGEMENT_TYPE}', 
            '{AB_TEST_VARIANT}',
            {email_sent},
            {review_scheduled},
            {customer['CHURN_RISK_SCORE']},
            CURRENT_TIMESTAMP()
        )
    """
    session.sql(log_query).collect()
    
    # 5. Return summary
    summary = {
        'customer_id': CUSTOMER_ID,
        'customer_name': customer['CUSTOMER_NAME'],
        'churn_risk_score': float(customer['CHURN_RISK_SCORE']),
        'variant': AB_TEST_VARIANT,
        'email_sent': email_sent,
        'account_review_scheduled': review_scheduled,
        'actions': actions_taken
    }
    
    return json.dumps(summary, indent=2)
$$;

-- ============================================================================
-- Grant Permissions
-- ============================================================================
GRANT USAGE ON FUNCTION HOOTSUITE_INTELLIGENCE.ANALYTICS.TRIGGER_CUSTOMER_ENGAGEMENT(STRING, STRING, STRING) TO ROLE SYSADMIN;
GRANT USAGE ON FUNCTION HOOTSUITE_INTELLIGENCE.ANALYTICS.TRIGGER_CUSTOMER_ENGAGEMENT(STRING, STRING, STRING) TO ROLE PUBLIC;

-- ============================================================================
-- Test Function (Commented out)
-- ============================================================================
-- SELECT customer_id FROM HOOTSUITE_INTELLIGENCE.RAW.CUSTOMERS WHERE churn_risk_score > 0.7 LIMIT 1;
-- SELECT TRIGGER_CUSTOMER_ENGAGEMENT('CUST000001', 'CHURN_PREVENTION', 'A');

SELECT 'Customer Engagement Function created successfully' AS STATUS;

