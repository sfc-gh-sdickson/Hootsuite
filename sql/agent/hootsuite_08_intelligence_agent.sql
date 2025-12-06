-- ============================================================================
-- Hootsuite Intelligence Agent - Agent Configuration
-- ============================================================================
-- Agent: HOOTSUITE_INTELLIGENCE_AGENT
-- Tools: 3 Semantic Views, 3 Cortex Search, 3 ML Models
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE HOOTSUITE_WH;

CREATE OR REPLACE AGENT HOOTSUITE_INTELLIGENCE_AGENT
  COMMENT = 'Hootsuite intelligence agent for customer, campaign, and support analytics'
  PROFILE = '{"display_name": "Hootsuite AI", "avatar": "owl-icon.png", "color": "blue"}'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration:
    budget:
      seconds: 60
      tokens: 32000

  instructions:
    response: "You are a Hootsuite business intelligence expert. Provide data-driven answers about customers, campaigns, and support. Use specific metrics."
    orchestration: "For campaign ROI use SV_CAMPAIGN_ANALYTICS. For customer churn/health use SV_CUSTOMER_HEALTH_ANALYTICS. For social stats use SV_SOCIAL_PERFORMANCE. For ticket search use SUPPORT_TICKETS_SEARCH. For help articles use KNOWLEDGE_BASE_SEARCH. For asset search use MARKETING_ASSETS_SEARCH. For predictions use the specific ML function."
    system: "You help Hootsuite teams analyze business performance."
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
    # Semantic Views
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "CampaignAnalyst"
        description: "Analyzes marketing campaign performance, ROI, and budget."
    
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "CustomerHealthAnalyst"
        description: "Analyzes customer churn risk, revenue, and health metrics."
    
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "SocialPerformanceAnalyst"
        description: "Analyzes social media engagement and platform stats."

    # Cortex Search
    - tool_spec:
        type: "cortex_search"
        name: "SupportTicketSearch"
        description: "Search customer support tickets for issues."

    - tool_spec:
        type: "cortex_search"
        name: "KnowledgeBaseSearch"
        description: "Search help articles and documentation."

    - tool_spec:
        type: "cortex_search"
        name: "AssetSearch"
        description: "Search marketing assets descriptions."

    # ML Models
    - tool_spec:
        type: "function"
        name: "PredictChurnRisk"
        description: "Predict customer churn risk distribution. Input: industry_filter or NULL."
        input_schema:
          type: "object"
          properties:
            industry_filter:
              type: "string"
          required: []

    - tool_spec:
        type: "function"
        name: "PredictCampaignROI"
        description: "Predict campaign ROI distribution. Input: objective_filter or NULL."
        input_schema:
          type: "object"
          properties:
            objective_filter:
              type: "string"
          required: []

    - tool_spec:
        type: "function"
        name: "ClassifyTicketPriority"
        description: "Classify support ticket priority. Input: category_filter or NULL."
        input_schema:
          type: "object"
          properties:
            category_filter:
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

    AssetSearch:
      name: "HOOTSUITE_INTELLIGENCE.RAW.MARKETING_ASSETS_SEARCH"
      max_results: "10"
      title_column: "asset_name"
      id_column: "asset_id"

    PredictChurnRisk:
      function: "HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_CHURN_RISK"
    
    PredictCampaignROI:
      function: "HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_CAMPAIGN_ROI"
    
    ClassifyTicketPriority:
      function: "HOOTSUITE_INTELLIGENCE.ML_MODELS.CLASSIFY_TICKET_PRIORITY"
  $$;

GRANT USAGE ON AGENT HOOTSUITE_INTELLIGENCE_AGENT TO ROLE SYSADMIN;
