<img src="../Snowflake_Logo.svg" width="200">

# Hootsuite Intelligence Agent - Sample Questions

This document contains 15 sample questions that can be answered by the Hootsuite Intelligence Agent, organized by complexity and capability.

---

## 🟢 Simple Questions (Direct Data Queries)

These questions query data directly from tables and views without complex joins or ML predictions.

### 1. How many total posts have been published?
**Expected Answer**: Count of posts with 'PUBLISHED' status
**Data Source**: SV_SOCIAL_PERFORMANCE (POSTS table)
**Query Pattern**: Simple COUNT

### 2. What is the total number of likes across all campaigns?
**Expected Answer**: Sum of likes
**Data Source**: SV_SOCIAL_PERFORMANCE (ENGAGEMENTS table)
**Query Pattern**: SUM aggregation

### 3. List the top 5 profiles by follower count.
**Expected Answer**: Top 5 profiles with most followers
**Data Source**: SV_SOCIAL_PERFORMANCE (SOCIAL_PROFILES table)
**Query Pattern**: ORDER BY DESC LIMIT 5

### 4. What is the average engagement rate for video posts?
**Expected Answer**: Average rate for MEDIA_TYPE = 'VIDEO'
**Data Source**: SV_SOCIAL_PERFORMANCE
**Query Pattern**: AVG aggregation with WHERE filter

### 5. How many organizations are in the Technology industry?
**Expected Answer**: Count of organizations
**Data Source**: SV_SOCIAL_PERFORMANCE (ORGANIZATIONS table)
**Query Pattern**: COUNT DISTINCT with WHERE filter

---

## 🟡 Complex Questions (Multi-table Analysis)

These questions require joins across multiple tables, time-series analysis, or complex aggregations.

### 6. Compare the average engagement rate of Facebook vs Twitter posts for the Retail industry.
**Expected Answer**: Comparison table of avg rates by network
**Data Source**: SV_SOCIAL_PERFORMANCE
**Query Pattern**: GROUP BY network, filter by Industry, AVG metric
**Complexity**: Multi-dimensional aggregation

### 7. Which campaign had the highest total clicks?
**Expected Answer**: Campaign name with most clicks
**Data Source**: SV_SOCIAL_PERFORMANCE
**Query Pattern**: GROUP BY campaign, SUM clicks, ORDER BY DESC LIMIT 1
**Complexity**: Aggregation and Ranking

### 8. What is the monthly trend of post volume for the last year?
**Expected Answer**: Time-series of post counts by month
**Data Source**: SV_SOCIAL_PERFORMANCE
**Query Pattern**: Date truncation, GROUP BY date
**Complexity**: Time-series analysis

### 9. List organizations with 'ENTERPRISE' plan tier that have less than 100 posts.
**Expected Answer**: List of organization names
**Data Source**: SV_SOCIAL_PERFORMANCE
**Query Pattern**: GROUP BY organization, HAVING count < 100
**Complexity**: Conditional aggregation (HAVING clause)

### 10. Which media type drives the highest average sentiment score?
**Expected Answer**: Media type (e.g., VIDEO, IMAGE)
**Data Source**: SV_SOCIAL_PERFORMANCE
**Query Pattern**: GROUP BY media_type, AVG sentiment, ORDER BY DESC LIMIT 1
**Complexity**: Aggregation optimization

---

## 🔴 ML Model Questions (Predictions)

These questions invoke the 3 ML models trained in the Snowflake notebook.

### 11. Predict the engagement rate for post PST00001234.
**Expected Answer**: Predicted engagement rate (float)
**Model**: POST_ENGAGEMENT_PREDICTOR
**Input Features**: follower_count, is_verified, delay_hours, hour_of_day, day_of_week, sentiment_score, media_type
**Returns**: JSON with predicted rate

### 12. Is organization ORG00000001 at risk of churn?
**Expected Answer**: Risk classification (HIGH RISK / LOW RISK)
**Model**: CHURN_RISK_PREDICTOR
**Input Features**: employee_count, subscription_days, active_users_count, support_tickets_count, avg_satisfaction_score, plan_tier
**Returns**: JSON with churn prediction

### 13. When is the best time to post on LINKEDIN for the FINANCE industry?
**Expected Answer**: Top 3 optimal time slots (Day + Hour)
**Model**: OPTIMAL_TIME_PREDICTOR
**Input Features**: Network (LINKEDIN), Industry (FINANCE), generated time slots
**Returns**: JSON list of optimal times

### 14. Evaluate the churn risk for organization ORG00000005.
**Expected Answer**: Risk classification
**Model**: CHURN_RISK_PREDICTOR
**Input Features**: Organization metrics
**Returns**: JSON prediction

### 15. What is the expected engagement if I post on TWITTER for the TECHNOLOGY industry at the optimal time?
**Expected Answer**: Max predicted engagement rate
**Model**: OPTIMAL_TIME_PREDICTOR
**Input Features**: Network, Industry, generated times
**Returns**: JSON with score (Agent logic finds max)

---

## 📋 Question Categories Summary

| Category | Count | Complexity | Data Sources | ML Models |
|----------|-------|------------|--------------|-----------|
| Simple | 5 | Low | 1 table | None |
| Complex | 5 | Medium-High | 2-4 tables | None |
| ML-Powered | 5 | High | 2-3 tables + Models | 3 models |

---

## 🎯 Testing Instructions

### Simple Questions
Test these first to verify basic data access and semantic view functionality.
- All should complete in < 5 seconds
- Verify result counts match synthetic data volumes

### Complex Questions
Test after simple questions succeed.
- May take 10-30 seconds depending on data volume
- Verify logical correctness of multi-table joins

### ML Model Questions
Test only after ML models are trained and registered.
- Require feature views to be created
- Require models registered in ML_MODELS schema
- Require wrapper functions created
- Returns JSON format responses

---

## ⚙️ Prerequisites by Question Type

### Simple Questions (1-5)
✅ Database and schema created
✅ Tables created
✅ Synthetic data loaded

### Complex Questions (6-10)
✅ All Simple prerequisites
✅ Semantic views created

### ML Questions (11-15)
✅ All previous prerequisites
✅ Feature views created
✅ ML models trained via notebook
✅ Models registered in Model Registry
✅ Wrapper functions created
✅ Intelligence Agent configured with model tools

---

**Last Updated**: December 2025
**Version**: 1.0.0

