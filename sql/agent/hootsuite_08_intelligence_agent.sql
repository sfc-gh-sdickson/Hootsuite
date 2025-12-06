-- ============================================================================
-- Hootsuite Intelligence Agent - Agent Configuration
-- ============================================================================
-- Purpose: Create Snowflake Intelligence Agent with semantic views and ML tools
-- Agent: HOOTSUITE_INTELLIGENCE_AGENT
-- Tools: 3 semantic views + 3 Cortex Search services + 3 ML model procedures
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE HOOTSUITE_WH;

-- ============================================================================
-- Create Cortex Agent
-- ============================================================================
CREATE OR REPLACE AGENT HOOTSUITE_INTELLIGENCE_AGENT
  COMMENT = 'Hootsuite social media intelligence agent with ML predictions and semantic search'
  PROFILE = '{"display_name": "Hootsuite Intelligence Assistant", "avatar": "hootsuite-icon.png", "color": "blue"}'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration:
    budget:
      seconds: 60
      tokens: 32000

  instructions:
    response: "You are a helpful social media intelligence assistant. Provide clear, accurate answers about customers, campaigns, and engagement data. When using ML predictions, explain the risk levels clearly. Always cite data sources."
    orchestration: "For campaign performance questions use SV_CAMPAIGN_ANALYTICS. For customer health analysis use SV_CUSTOMER_HEALTH_ANALYTICS. For social performance metrics use SV_SOCIAL_PERFORMANCE. For support tickets search use SUPPORT_TICKETS_SEARCH. For help articles search use KNOWLEDGE_BASE_SEARCH. For marketing assets search use MARKETING_ASSETS_SEARCH. For ML predictions use the appropriate prediction procedure."
    system: "You are an expert social media intelligence agent for Hootsuite. You help analyze campaign performance, customer health, engagement metrics, and support operations. Always provide data-driven insights."
    sample_questions:
      - question: "How many active customers do we have in the Retail industry?"
        answer: "I'll query the customer data to count active Retail customers."
      - question: "What is the total budget allocated to Awareness campaigns?"
        answer: "I'll sum the budget for all Awareness objective campaigns."
      - question: "Show me the top 5 social accounts by follower count."
        answer: "I'll query social accounts and rank by followers."
      - question: "List all open support tickets with Urgent priority."
        answer: "I'll filter tickets by status and priority."
      - question: "Count the number of posts published on Instagram last month."
        answer: "I'll filter posts by platform and date."
      - question: "Compare the average engagement rate of Video vs. Image posts for Technology customers."
        answer: "I'll segment engagement by media type and industry."
      - question: "What is the churn risk distribution for Enterprise customers compared to Professional plans?"
        answer: "I'll analyze churn scores grouped by plan type."
      - question: "Which campaign objective yields the highest ROI based on click-through rates?"
        answer: "I'll calculate ROI metrics by campaign objective."
      - question: "Correlate the number of open support tickets with customer churn risk scores."
        answer: "I'll analyze the relationship between tickets and churn risk."
      - question: "Identify the regions with the highest revenue but also highest churn risk."
        answer: "I'll rank regions by revenue and churn risk."
      - question: "Predict the churn risk for all customers in the Manufacturing industry."
        answer: "I'll use the churn prediction model filtered by Manufacturing."
      - question: "Forecast the ROI for our active Conversion campaigns."
        answer: "I'll use the ROI predictor on Conversion campaigns."
      - question: "Classify the priority of tickets related to Billing issues."
        answer: "I'll use the priority classifier filtered by Billing category."
      - question: "What is the predicted risk profile for customers with less than 6 months tenure?"
        answer: "I'll use the churn predictor on customers with short tenure."
      - question: "Find support tickets related to login failure and their resolution notes."
        answer: "I'll search the support tickets for login-related issues."

  tools:
    # Semantic Views for Cortex Analyst (Text-to-SQL)
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "CampaignAnalyst"
        description: "Analyzes marketing campaign performance, budget, ROI, and engagement metrics. Use for questions about campaign performance, budget utilization, impressions, clicks, and engagement."
    
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "CustomerHealthAnalyst"
        description: "Analyzes customer demographics, churn risk, revenue, and support ticket patterns. Use for questions about customer health, churn risk, revenue, support tickets, and customer segmentation."
    
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "SocialPerformanceAnalyst"
        description: "Analyzes social media platform performance, follower growth, engagement rates, and post metrics. Use for questions about social platform stats, engagement, followers, and post performance."

    # Cortex Search Services
    - tool_spec:
        type: "cortex_search"
        name: "SupportTicketSearch"
        description: "Searches unstructured support ticket descriptions and resolutions. Use when users ask about support issues, ticket history, or resolution patterns."

    - tool_spec:
        type: "cortex_search"
        name: "KnowledgeBaseSearch"
        description: "Searches help center articles and documentation. Use when users ask about help articles, tutorials, or how-to guides."

    - tool_spec:
        type: "cortex_search"
        name: "MarketingAssetSearch"
        description: "Searches marketing asset descriptions and creative content. Use when users ask about marketing assets, creative materials, or visual content."

    # ML Model Procedures
    - tool_spec:
        type: "generic"
        name: "PredictChurnRisk"
        description: "Predicts churn risk for customers. Returns risk distribution (low/medium/high). Use when users ask to predict churn, assess customer retention risk, or identify at-risk customers. Input: industry filter or NULL for all customers."
        input_schema:
          type: "object"
          properties:
            industry_filter:
              type: "string"
              description: "Filter by industry type or NULL for all"
          required: []

    - tool_spec:
        type: "generic"
        name: "PredictCampaignROI"
        description: "Predicts campaign ROI likelihood. Returns distribution of low/medium/high ROI. Use when users ask about campaign ROI predictions, campaign success forecasts, or ROI assessment. Input: objective filter (AWARENESS, CONVERSION, TRAFFIC) or NULL."
        input_schema:
          type: "object"
          properties:
            objective_filter:
              type: "string"
              description: "Filter by campaign objective: AWARENESS, CONVERSION, TRAFFIC, or NULL for all"
          required: []

    - tool_spec:
        type: "generic"
        name: "ClassifyTicketPriority"
        description: "Classifies support ticket priority. Returns priority distribution. Use when users ask about ticket priority classification, urgency assessment, or support triage. Input: category filter or NULL."
        input_schema:
          type: "object"
          properties:
            category_filter:
              type: "string"
              description: "Filter by ticket category or NULL for all"
          required: []

  tool_resources:
    # Semantic View Resources
    CampaignAnalyst:
      semantic_view: "HOOTSUITE_INTELLIGENCE.ANALYTICS.SV_CAMPAIGN_ANALYTICS"
    
    CustomerHealthAnalyst:
      semantic_view: "HOOTSUITE_INTELLIGENCE.ANALYTICS.SV_CUSTOMER_HEALTH_ANALYTICS"
    
    SocialPerformanceAnalyst:
      semantic_view: "HOOTSUITE_INTELLIGENCE.ANALYTICS.SV_SOCIAL_PERFORMANCE"

    # Cortex Search Resources
    SupportTicketSearch:
      name: "HOOTSUITE_INTELLIGENCE.RAW.SUPPORT_TICKETS_SEARCH"
      max_results: "10"
      title_column: "issue_summary"
      id_column: "ticket_id"

    KnowledgeBaseSearch:
      name: "HOOTSUITE_INTELLIGENCE.RAW.KNOWLEDGE_BASE_SEARCH"
      max_results: "5"
      title_column: "title"
      id_column: "article_id"

    MarketingAssetSearch:
      name: "HOOTSUITE_INTELLIGENCE.RAW.MARKETING_ASSETS_SEARCH"
      max_results: "10"
      title_column: "asset_name"
      id_column: "asset_id"

    # ML Model Procedure Resources
    PredictChurnRisk:
      type: "function"
      identifier: "HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_CHURN_RISK"
      execution_environment:
        type: "warehouse"
        warehouse: "HOOTSUITE_WH"
        query_timeout: 60

    PredictCampaignROI:
      type: "function"
      identifier: "HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_CAMPAIGN_ROI"
      execution_environment:
        type: "warehouse"
        warehouse: "HOOTSUITE_WH"
        query_timeout: 60

    ClassifyTicketPriority:
      type: "function"
      identifier: "HOOTSUITE_INTELLIGENCE.ML_MODELS.CLASSIFY_TICKET_PRIORITY"
      execution_environment:
        type: "warehouse"
        warehouse: "HOOTSUITE_WH"
        query_timeout: 60
  $$;

-- ============================================================================
-- Grant Permissions
-- ============================================================================
GRANT USAGE ON AGENT HOOTSUITE_INTELLIGENCE_AGENT TO ROLE SYSADMIN;
GRANT USAGE ON AGENT HOOTSUITE_INTELLIGENCE_AGENT TO ROLE PUBLIC;

-- ============================================================================
-- Verification
-- ============================================================================
SHOW AGENTS IN SCHEMA ANALYTICS;

DESC AGENT HOOTSUITE_INTELLIGENCE_AGENT;

SELECT 'Hootsuite Intelligence Agent created successfully' AS STATUS;
