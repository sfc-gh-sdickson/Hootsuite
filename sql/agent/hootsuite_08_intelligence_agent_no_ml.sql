-- ============================================================================
-- Hootsuite Intelligence Agent - Agent Configuration (No ML Tools - Testing)
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE HOOTSUITE_WH;

CREATE OR REPLACE AGENT HOOTSUITE_INTELLIGENCE_AGENT
  COMMENT = 'Hootsuite social media intelligence agent'
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
    response: "You are a helpful social media intelligence assistant. Provide clear, accurate answers about customers, campaigns, and engagement data."
    orchestration: "For campaign performance questions use SV_CAMPAIGN_ANALYTICS. For customer health analysis use SV_CUSTOMER_HEALTH_ANALYTICS. For social performance metrics use SV_SOCIAL_PERFORMANCE. For support tickets search use SUPPORT_TICKETS_SEARCH. For help articles search use KNOWLEDGE_BASE_SEARCH. For marketing assets search use MARKETING_ASSETS_SEARCH."
    system: "You are an expert social media intelligence agent for Hootsuite. You help analyze campaign performance, customer health, engagement metrics, and support operations."
    sample_questions:
      - question: "How many active customers do we have in the Retail industry?"
        answer: "I'll query the customer data to count active Retail customers."
      - question: "What is the total budget allocated to Awareness campaigns?"
        answer: "I'll sum the budget for all Awareness objective campaigns."
      - question: "Show me the top 5 social accounts by follower count."
        answer: "I'll query social accounts and rank by followers."

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

    # ML Model - Testing ONE function
    - tool_spec:
        type: "function"
        name: "PredictChurnRisk"
        description: "Predicts customer churn risk."
        input_schema:
          type: "object"
          properties:
            industry_filter:
              type: "string"
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

    PredictChurnRisk:
      procedure: "HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_CHURN_RISK"
  $$;

GRANT USAGE ON AGENT HOOTSUITE_INTELLIGENCE_AGENT TO ROLE SYSADMIN;

SELECT 'Hootsuite Intelligence Agent created successfully (without ML tools for testing)' AS STATUS;

