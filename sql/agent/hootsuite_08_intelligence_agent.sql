-- ============================================================================
-- Hootsuite Intelligence Agent - Agent Configuration
-- ============================================================================
-- Purpose: Create Snowflake Intelligence Agent with semantic views and ML tools
-- Agent: HOOTSUITE_SOCIAL_AGENT
-- Tools: Semantic views + Cortex Search services + ML model procedures
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE HOOTSUITE_WH;

-- ============================================================================
-- Create Cortex Agent
-- ============================================================================
CREATE OR REPLACE AGENT HOOTSUITE_AGENT
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
    response: "You are a helpful social media intelligence assistant for Hootsuite. Provide clear, accurate answers about posts, engagements, campaigns, and user data. When using ML predictions, clearly explain the predicted metrics (e.g., engagement rate) or risk levels. Always cite data sources."
    orchestration: "For social media performance questions use SV_SOCIAL_PERFORMANCE. For post content search use POSTS_SEARCH. For strategy document search use STRATEGY_DOCUMENTS_SEARCH. For ML predictions use the appropriate prediction procedure (PredictPostEngagement, PredictChurnRisk, PredictOptimalTime)."
    system: "You are an expert social media analyst for Hootsuite. You help analyze post performance, engagement metrics, customer churn risk, and optimal posting times. Always provide data-driven insights."
    sample_questions:
      - question: "How many total posts have been published?"
        answer: "I'll query the social performance data to get the count of published posts."
      - question: "What is the total number of likes across all campaigns?"
        answer: "I'll calculate the total likes metric from the engagement data."
      - question: "List the top 5 profiles by follower count."
        answer: "I'll rank social profiles by follower count and show the top 5."
      - question: "What is the average engagement rate for video posts?"
        answer: "I'll calculate the average engagement rate specifically for posts with video media type."
      - question: "Compare the average engagement rate of Facebook vs Twitter posts for the Retail industry."
        answer: "I'll aggregate engagement rates by network for the Retail industry to compare them."
      - question: "Which campaign had the highest total clicks?"
        answer: "I'll analyze campaign data to identify the one with the maximum total clicks."
      - question: "What is the monthly trend of post volume for the last year?"
        answer: "I'll segment post counts by month for the past year to show the trend."
      - question: "Predict the engagement rate for post PST00001234."
        answer: "I'll use the post engagement prediction model to forecast the engagement rate for this specific post."
      - question: "Is organization ORG00000001 at risk of churn?"
        answer: "I'll use the churn risk prediction model to assess the risk level for this organization."
      - question: "When is the best time to post on LINKEDIN for the FINANCE industry?"
        answer: "I'll use the optimal time prediction model to find the best day and hour for this network and industry."
      - question: "Find posts about 'new product launch'."
        answer: "I'll search the unstructured post content for mentions of 'new product launch'."
      - question: "What are the brand guidelines for logo usage?"
        answer: "I'll search the strategy documents for brand guidelines related to logo usage."

  tools:
    # Semantic View for Cortex Analyst (Text-to-SQL)
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "SocialPerformanceAnalyst"
        description: "Analyzes social media posts, engagements, campaigns, organizations, and profiles. Use for questions about post counts, likes, shares, comments, clicks, impressions, engagement rates, follower counts, and campaign budgets."
    
    # Cortex Search Services
    - tool_spec:
        type: "cortex_search"
        name: "PostsSearch"
        description: "Searches unstructured social media post content. Use when users ask to find specific posts, search for keywords in posts, or analyze post text sentiment/topics."
    
    - tool_spec:
        type: "cortex_search"
        name: "StrategyDocumentsSearch"
        description: "Searches unstructured strategy documents and guidelines. Use when users ask about brand guidelines, content strategies, campaign briefs, or internal documentation."
    
    # ML Model Procedure Resources
    - tool_spec:
        type: "cortex_tool"
        name: "PredictPostEngagement"
        description: "Predicts the engagement rate for a specific post. Returns the predicted rate. Use when users ask to predict engagement, forecast performance, or score a post. Input: POST_ID."
        input_schema:
          type: "object"
          properties:
            POST_ID_INPUT:
              type: "string"
              description: "The ID of the post to predict (e.g., 'PST00001234')"
          required: ["POST_ID_INPUT"]

    - tool_spec:
        type: "cortex_tool"
        name: "PredictChurnRisk"
        description: "Predicts the churn risk for a customer organization. Returns HIGH RISK or LOW RISK. Use when users ask about churn, customer retention risk, or organization health. Input: ORGANIZATION_ID."
        input_schema:
          type: "object"
          properties:
            ORGANIZATION_ID_INPUT:
              type: "string"
              description: "The ID of the organization to analyze (e.g., 'ORG00000001')"
          required: ["ORGANIZATION_ID_INPUT"]

    - tool_spec:
        type: "cortex_tool"
        name: "PredictOptimalTime"
        description: "Predicts the optimal posting times (day of week and hour) for a given network and industry. Returns top 3 times. Use when users ask when to post, best time to post, or scheduling optimization. Input: NETWORK, INDUSTRY."
        input_schema:
          type: "object"
          properties:
            NETWORK_INPUT:
              type: "string"
              description: "Social network (e.g., 'LINKEDIN', 'TWITTER', 'FACEBOOK')"
            INDUSTRY_INPUT:
              type: "string"
              description: "Industry vertical (e.g., 'Finance', 'Retail', 'Technology')"
          required: ["NETWORK_INPUT", "INDUSTRY_INPUT"]

  tool_resources:
    # Semantic View Resources
    SocialPerformanceAnalyst:
      semantic_view: "HOOTSUITE_INTELLIGENCE.ANALYTICS.SV_SOCIAL_PERFORMANCE"

    # Cortex Search Resources
    PostsSearch:
      name: "HOOTSUITE_INTELLIGENCE.RAW.POSTS_SEARCH"
      max_results: "10"
      title_column: "post_id"
      id_column: "post_id"

    StrategyDocumentsSearch:
      name: "HOOTSUITE_INTELLIGENCE.RAW.STRATEGY_DOCUMENTS_SEARCH"
      max_results: "5"
      title_column: "title"
      id_column: "document_id"

    # ML Model Procedure Resources
    PredictPostEngagement:
      function: "HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_POST_ENGAGEMENT"

    PredictChurnRisk:
      function: "HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_CHURN_RISK"

    PredictOptimalTime:
      function: "HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_OPTIMAL_TIME"
  $$;

-- ============================================================================
-- Grant Permissions
-- ============================================================================
GRANT USAGE ON AGENT HOOTSUITE_AGENT TO ROLE SYSADMIN;
GRANT USAGE ON AGENT HOOTSUITE_AGENT TO ROLE PUBLIC;

-- ============================================================================
-- Verification
-- ============================================================================
SHOW AGENTS IN SCHEMA ANALYTICS;

DESC AGENT HOOTSUITE_AGENT;

SELECT 'Hootsuite Intelligence Agent created successfully' AS STATUS;
