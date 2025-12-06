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
    orchestration: "For campaign performance questions use CampaignAnalyst. For customer health and support analysis use CustomerHealthAnalyst. For social media performance, posts, and engagement use SocialPerformanceAnalyst. For support tickets search use SupportTicketSearch. For help articles search use KnowledgeBaseSearch. For marketing assets search use MarketingAssetSearch. For ML predictions use the appropriate prediction function."
    system: "You are an expert social media intelligence agent for Hootsuite. You help analyze campaign performance, customer health, engagement metrics, and support operations. Always provide data-driven insights based on available data."
    sample_questions:
      - question: "How many active customers do we have?"
        answer: "I'll query CustomerHealthAnalyst to count customers where active_status is ACTIVE."
      - question: "What is the average campaign budget?"
        answer: "I'll use CampaignAnalyst to calculate the average budget_allocated across all campaigns."
      - question: "Which customers have the highest churn risk?"
        answer: "I'll query CustomerHealthAnalyst to find customers with high churn_risk_score, sorted by risk."
      - question: "Show me the top 5 campaigns by total engagement"
        answer: "I'll use CampaignAnalyst to rank campaigns by total likes, shares, and comments combined."
      - question: "How many posts were published on Instagram this month?"
        answer: "I'll use SocialPerformanceAnalyst to count published posts where platform is Instagram and month is current month."
      - question: "What is the average engagement rate by platform?"
        answer: "I'll query SocialPerformanceAnalyst to calculate average engagement_rate grouped by platform."
      - question: "How many support tickets are currently open?"
        answer: "I'll use CustomerHealthAnalyst to count tickets where status is OPEN."
      - question: "Which industries have the most customers?"
        answer: "I'll query CustomerHealthAnalyst to count customers grouped by industry."
      - question: "What is our post engagement rate for video vs image content?"
        answer: "I'll use SocialPerformanceAnalyst to compare average engagement_rate for VIDEO vs IMAGE media types."
      - question: "Show me customers in the Retail industry with high churn risk"
        answer: "I'll query CustomerHealthAnalyst for customers where industry is Retail and churn_risk_score is high."
      - question: "How many campaigns are currently active?"
        answer: "I'll use CampaignAnalyst to count campaigns where status is ACTIVE."
      - question: "What is the total follower count across all social accounts?"
        answer: "I'll use SocialPerformanceAnalyst to sum follower_count across all accounts."

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
