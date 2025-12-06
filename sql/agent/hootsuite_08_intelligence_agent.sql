-- ============================================================================
-- Hootsuite Intelligence Agent - Agent Setup and Verification
-- ============================================================================
-- Purpose: Verify the capabilities of the Intelligence Agent components
-- Components Verified: Semantic Views, Cortex Search, ML Functions
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE HOOTSUITE_WH;

-- ============================================================================
-- 1. Simple Questions (Verification of Semantic View Access)
-- ============================================================================

-- Q1: "How many total posts have been published?"
SELECT total_posts 
FROM SV_SOCIAL_PERFORMANCE;

-- Q2: "What is the total number of likes across all campaigns?"
SELECT SUM(total_likes) 
FROM SV_SOCIAL_PERFORMANCE;

-- Q3: "List the top 5 profiles by follower count."
SELECT profile_name, total_followers 
FROM SV_SOCIAL_PERFORMANCE 
ORDER BY total_followers DESC 
LIMIT 5;

-- Q4: "What is the average engagement rate for video posts?"
SELECT avg_engagement_rate 
FROM SV_SOCIAL_PERFORMANCE 
WHERE media_type = 'VIDEO';

-- Q5: "How many organizations are in the Technology industry?"
SELECT COUNT(DISTINCT organization_name) 
FROM SV_SOCIAL_PERFORMANCE 
WHERE industry = 'Technology';

-- ============================================================================
-- 2. Complex Questions (Verification of Relationships & Aggregation)
-- ============================================================================

-- Q1: "Compare the average engagement rate of Facebook vs Twitter posts for the Retail industry."
SELECT network, avg_engagement_rate 
FROM SV_SOCIAL_PERFORMANCE 
WHERE industry = 'Retail' AND network IN ('FACEBOOK', 'TWITTER') 
GROUP BY network;

-- Q2: "Which campaign had the highest total clicks?"
SELECT campaign_name, total_clicks 
FROM SV_SOCIAL_PERFORMANCE 
ORDER BY total_clicks DESC 
LIMIT 1;

-- Q3: "What is the monthly trend of post volume for the last year?"
SELECT DATE_TRUNC('month', published_date) as month, SUM(total_posts)
FROM SV_SOCIAL_PERFORMANCE
GROUP BY 1 
ORDER BY 1;

-- Q4: "List organizations with 'ENTERPRISE' plan tier that have less than 100 posts."
SELECT organization_name
FROM SV_SOCIAL_PERFORMANCE
WHERE plan_tier = 'ENTERPRISE'
GROUP BY organization_name
HAVING SUM(total_posts) < 100;

-- Q5: "Which media type drives the highest average sentiment score?"
SELECT media_type, avg_sentiment
FROM SV_SOCIAL_PERFORMANCE
GROUP BY media_type
ORDER BY avg_sentiment DESC 
LIMIT 1;

-- ============================================================================
-- 3. ML Model Questions (Verification of Tool Functions)
-- ============================================================================

-- Q1: "Predict the engagement rate for post PST00001234."
CALL HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_POST_ENGAGEMENT('PST00001234');

-- Q2: "Is organization ORG00000001 at risk of churn?"
CALL HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_CHURN_RISK('ORG00000001');

-- Q3: "When is the best time to post on LINKEDIN for the FINANCE industry?"
CALL HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_OPTIMAL_TIME('LINKEDIN', 'Finance');

-- Q4: "Evaluate the churn risk for organization ORG00000005."
CALL HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_CHURN_RISK('ORG00000005');

-- Q5: "What is the expected engagement if I post on TWITTER for the TECHNOLOGY industry at the optimal time?"
-- Agent would first call PREDICT_OPTIMAL_TIME, then parse results.
CALL HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_OPTIMAL_TIME('TWITTER', 'Technology');

-- ============================================================================
-- 4. Cortex Search Questions (Verification of Search Services)
-- ============================================================================

-- Q1: "Find posts about 'new product launch'."
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'HOOTSUITE_INTELLIGENCE.RAW.POSTS_SEARCH',
    '{
      "query": "new product launch",
      "columns": ["post_text", "media_type"],
      "limit": 3
    }'
  )
)['results'] AS search_results;

-- Q2: "What are the brand guidelines for logo usage?"
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'HOOTSUITE_INTELLIGENCE.RAW.STRATEGY_DOCUMENTS_SEARCH',
    '{
      "query": "logo usage",
      "columns": ["title", "content"],
      "filter": {"@eq": {"category": "BRAND_GUIDELINES"}},
      "limit": 3
    }'
  )
)['results'] AS search_results;

-- Q3: "Search for campaign briefs targeting Gen Z."
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'HOOTSUITE_INTELLIGENCE.RAW.STRATEGY_DOCUMENTS_SEARCH',
    '{
      "query": "Gen Z target audience",
      "columns": ["title", "content"],
      "filter": {"@eq": {"category": "CAMPAIGN_BRIEF"}},
      "limit": 3
    }'
  )
)['results'] AS search_results;

-- Q4: "Find video posts with high positive sentiment."
-- Note: 'sentiment_score' is numeric and usually requires range filtering which Cortex Search 
-- supports if indexed as an attribute. In our setup, we didn't add sentiment_score to attributes 
-- to keep it simple, but we can filter by media_type='VIDEO'.
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'HOOTSUITE_INTELLIGENCE.RAW.POSTS_SEARCH',
    '{
      "query": "positive feedback",
      "columns": ["post_text", "status"],
      "filter": {"@eq": {"media_type": "VIDEO"}},
      "limit": 3
    }'
  )
)['results'] AS search_results;

SELECT 'Agent capabilities verification complete.' AS STATUS;
