-- ============================================================================
-- Hootsuite Intelligence Agent - Agent Setup and Verification
-- ============================================================================
-- Purpose: Define sample questions and verify Agent capabilities
-- ============================================================================

-- ============================================================================
-- 1. Simple Questions (Answerable by SV_SOCIAL_PERFORMANCE)
-- ============================================================================
/*
1. "How many total posts have been published?"
   - Verification: SELECT total_posts FROM SV_SOCIAL_PERFORMANCE;

2. "What is the total number of likes across all campaigns?"
   - Verification: SELECT SUM(total_likes) FROM SV_SOCIAL_PERFORMANCE;

3. "List the top 5 profiles by follower count."
   - Verification: SELECT profile_name, total_followers FROM SV_SOCIAL_PERFORMANCE ORDER BY total_followers DESC LIMIT 5;

4. "What is the average engagement rate for video posts?"
   - Verification: SELECT avg_engagement_rate FROM SV_SOCIAL_PERFORMANCE WHERE media_type = 'VIDEO';

5. "How many organizations are in the Technology industry?"
   - Verification: SELECT COUNT(DISTINCT organization_name) FROM SV_SOCIAL_PERFORMANCE WHERE industry = 'Technology';
*/

-- ============================================================================
-- 2. Complex Questions (Answerable by SV_SOCIAL_PERFORMANCE)
-- ============================================================================
/*
1. "Compare the average engagement rate of Facebook vs Twitter posts for the Retail industry."
   - Verification: 
     SELECT network, avg_engagement_rate 
     FROM SV_SOCIAL_PERFORMANCE 
     WHERE industry = 'Retail' AND network IN ('FACEBOOK', 'TWITTER') 
     GROUP BY network;

2. "Which campaign had the highest total clicks?"
   - Verification: 
     SELECT campaign_name, total_clicks 
     FROM SV_SOCIAL_PERFORMANCE 
     ORDER BY total_clicks DESC LIMIT 1;

3. "What is the monthly trend of post volume for the last year?"
   - Verification:
     SELECT DATE_TRUNC('month', published_date) as month, SUM(total_posts)
     FROM SV_SOCIAL_PERFORMANCE
     GROUP BY 1 ORDER BY 1;

4. "List organizations with 'ENTERPRISE' plan tier that have less than 100 posts."
   - Verification:
     SELECT organization_name
     FROM SV_SOCIAL_PERFORMANCE
     WHERE plan_tier = 'ENTERPRISE'
     GROUP BY organization_name
     HAVING SUM(total_posts) < 100;

5. "Which media type drives the highest average sentiment score?"
   - Verification:
     SELECT media_type, avg_sentiment
     FROM SV_SOCIAL_PERFORMANCE
     GROUP BY media_type
     ORDER BY avg_sentiment DESC LIMIT 1;
*/

-- ============================================================================
-- 3. ML Model Questions (Answerable by Stored Procedures)
-- ============================================================================
/*
1. "Predict the engagement rate for post PST00001234."
   - Tool: CALL HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_POST_ENGAGEMENT('PST00001234');

2. "Is organization ORG00000001 at risk of churn?"
   - Tool: CALL HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_CHURN_RISK('ORG00000001');

3. "When is the best time to post on LINKEDIN for the FINANCE industry?"
   - Tool: CALL HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_OPTIMAL_TIME('LINKEDIN', 'Finance');

4. "Evaluate the churn risk for organization ORG00000005."
   - Tool: CALL HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_CHURN_RISK('ORG00000005');

5. "What is the expected engagement if I post on TWITTER for the TECHNOLOGY industry at the optimal time?"
   - Tool: CALL HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_OPTIMAL_TIME('TWITTER', 'Technology');
   - (Agent interprets result to find max score)
*/

-- ============================================================================
-- 4. Cortex Search Questions (Answerable by Search Services)
-- ============================================================================
/*
1. "Find posts about 'new product launch'."
   - Service: POSTS_SEARCH
   
2. "What are the brand guidelines for logo usage?"
   - Service: STRATEGY_DOCUMENTS_SEARCH (Filter: category='BRAND_GUIDELINES')

3. "Search for campaign briefs targeting Gen Z."
   - Service: STRATEGY_DOCUMENTS_SEARCH

4. "Find video posts with high positive sentiment."
   - Service: POSTS_SEARCH (Attribute filter: media_type='VIDEO') - *Note: Sentiment not indexed as attribute in search service definition, strictly text search + attributes defined.*
*/

SELECT 'Agent configuration and questions documentation created.' AS STATUS;

