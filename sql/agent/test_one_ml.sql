-- ============================================================================
-- Hootsuite Intelligence Agent - Agent Configuration (With 1 ML Tool - Testing)
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
    orchestration: "For campaign performance questions use SV_CAMPAIGN_ANALYTICS. For customer health analysis use SV_CUSTOMER_HEALTH_ANALYTICS. For social performance metrics use SV_SOCIAL_PERFORMANCE."
    system: "You are an expert social media intelligence agent for Hootsuite."
    sample_questions:
      - question: "Show me the top 5 social accounts by follower count."
        answer: "I'll query social accounts and rank by followers."

  tools:
    # Semantic Views
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "CampaignAnalyst"
        description: "Analyzes marketing campaign performance."
    
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "CustomerHealthAnalyst"
        description: "Analyzes customer health metrics."
    
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "SocialPerformanceAnalyst"
        description: "Analyzes social media performance."

    # Cortex Search
    - tool_spec:
        type: "cortex_search"
        name: "SupportTicketSearch"
        description: "Searches support tickets."

    - tool_spec:
        type: "cortex_search"
        name: "KnowledgeBaseSearch"
        description: "Searches help articles."

    - tool_spec:
        type: "cortex_search"
        name: "MarketingAssetSearch"
        description: "Searches marketing assets."

    # Testing: Add ONLY churn predictor
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
    CampaignAnalyst:
      semantic_view: "HOOTSUITE_INTELLIGENCE.ANALYTICS.SV_CAMPAIGN_ANALYTICS"
    
    CustomerHealthAnalyst:
      semantic_view: "HOOTSUITE_INTELLIGENCE.ANALYTICS.SV_CUSTOMER_HEALTH_ANALYTICS"
    
    SocialPerformanceAnalyst:
      semantic_view: "HOOTSUITE_INTELLIGENCE.ANALYTICS.SV_SOCIAL_PERFORMANCE"

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
      function: "HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_CHURN_RISK"
  $$;

GRANT USAGE ON AGENT HOOTSUITE_INTELLIGENCE_AGENT TO ROLE SYSADMIN;

SELECT 'Test agent with 1 ML function created' AS STATUS;

