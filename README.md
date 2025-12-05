<img src="Snowflake_Logo.svg" width="200">

# Hootsuite Intelligence Agent Solution

**Social Media Management Intelligence Platform**

This solution provides a complete Snowflake Intelligence Agent implementation for Hootsuite, enabling natural language queries over social media data with ML-powered insights for engagement, churn, and timing optimization.

---

## 🎯 What This Solution Provides

- **Natural Language Queries**: Ask questions about posts, campaigns, and engagement metrics in plain English
- **ML-Powered Predictions**: 3 trained models for post engagement, churn risk, and optimal posting times
- **Unstructured Data Search**: Cortex Search over social posts and strategy documents
- **Semantic Layer**: Cortex Analyst with semantic views for accurate text-to-SQL conversion

---

## 📊 Data Model

### Core Entities
1. **ORGANIZATIONS** - Hootsuite customers (100+)
2. **USERS** - Team members (500+)
3. **SOCIAL_PROFILES** - Connected accounts (300+)
4. **CAMPAIGNS** - Marketing initiatives (200+)
5. **POSTS** - Social content (10,000+)
6. **ENGAGEMENTS** - Performance metrics (10,000+)
7. **SUPPORT_TICKETS** - Customer support interactions (2,000+)
8. **STRATEGY_DOCUMENTS** - Unstructured strategy docs (500+)

### ML Models
1. **POST_ENGAGEMENT_PREDICTOR** - Predicts engagement rate (Regression)
2. **CHURN_RISK_PREDICTOR** - Predicts organization churn probability (Classification)
3. **OPTIMAL_TIME_PREDICTOR** - Predicts best posting time by network/industry (Regression)

---

## 🚀 Setup Instructions

### Prerequisites
- Snowflake account with SYSADMIN access
- Warehouse (recommended: MEDIUM or larger for data generation)
- Snowflake Notebook environment (for ML models)

### Step 1: Database and Schema Setup
```sql
-- Run this first
snow sql -f sql/setup/hootsuite_01_database_and_schema.sql
```

Creates:
- Database: `HOOTSUITE_INTELLIGENCE`
- Schemas: `RAW`, `ANALYTICS`, `ML_MODELS`
- Warehouse: `HOOTSUITE_WH`

### Step 2: Create Tables
```sql
snow sql -f sql/setup/hootsuite_02_create_tables.sql
```

Creates 8 core tables with proper constraints.

### Step 3: Generate Synthetic Data
```sql
-- This takes 2-3 minutes
snow sql -f sql/data/hootsuite_03_generate_synthetic_data.sql
```

Generates ~20,000 rows of realistic synthetic data across all tables.

### Step 4: Create Analytical Views
```sql
snow sql -f sql/views/hootsuite_04_create_views.sql
```

Creates:
- 4 analytical views
- 3 ML feature views (for model training consistency)

### Step 5: Train ML Models
1. Upload `notebooks/hootsuite_ml_models.ipynb` to Snowflake
2. Run all cells in the notebook
3. Verify 3 models are registered in Model Registry

### Step 6: Create Semantic Views
```sql
-- IMPORTANT: Syntax verified against Snowflake docs
snow sql -f sql/views/hootsuite_05_create_semantic_views.sql
```

Creates semantic view for Cortex Analyst:
- `SV_SOCIAL_PERFORMANCE`

### Step 7: Create Cortex Search Services
```sql
snow sql -f sql/search/hootsuite_06_create_cortex_search.sql
```

Creates 2 search services:
- `POSTS_SEARCH`
- `STRATEGY_DOCUMENTS_SEARCH`

### Step 8: Create ML Model Wrapper Functions
```sql
snow sql -f sql/ml/hootsuite_07_ml_model_functions.sql
```

Creates SQL procedures to call ML models from the agent:
- `PREDICT_POST_ENGAGEMENT()`
- `PREDICT_CHURN_RISK()`
- `PREDICT_OPTIMAL_TIME()`

### Step 9: Configure Intelligence Agent
```sql
snow sql -f sql/agent/hootsuite_08_intelligence_agent.sql
```

Configures the Intelligence Agent and provides verification questions.

---

## 💬 Sample Questions

### Simple Questions (Direct Data Queries)
1. How many total posts have been published?
2. What is the total number of likes across all campaigns?
3. List the top 5 profiles by follower count.
4. What is the average engagement rate for video posts?
5. How many organizations are in the Technology industry?

### Complex Questions (Multi-table Analysis)
1. Compare the average engagement rate of Facebook vs Twitter posts for the Retail industry.
2. Which campaign had the highest total clicks?
3. What is the monthly trend of post volume for the last year?
4. List organizations with 'ENTERPRISE' plan tier that have less than 100 posts.
5. Which media type drives the highest average sentiment score?

### ML Model Questions (Predictions)
1. Predict the engagement rate for post PST00001234.
2. Is organization ORG00000001 at risk of churn?
3. When is the best time to post on LINKEDIN for the FINANCE industry?
4. Evaluate the churn risk for organization ORG00000005.
5. What is the expected engagement if I post on TWITTER for the TECHNOLOGY industry at the optimal time?

---

## 📁 File Structure

```
hootsuite/
├── README.md (this file)
├── Snowflake_Logo.svg
├── sql/
│   ├── setup/
│   │   ├── hootsuite_01_database_and_schema.sql
│   │   └── hootsuite_02_create_tables.sql
│   ├── data/
│   │   └── hootsuite_03_generate_synthetic_data.sql
│   ├── views/
│   │   ├── hootsuite_04_create_views.sql
│   │   └── hootsuite_05_create_semantic_views.sql
│   ├── search/
│   │   └── hootsuite_06_create_cortex_search.sql
│   ├── ml/
│   │   └── hootsuite_07_ml_model_functions.sql
│   └── agent/
│       └── hootsuite_08_intelligence_agent.sql
├── notebooks/
│   ├── hootsuite_ml_models.ipynb
│   └── environment.yml
└── docs/
    ├── HOOTSUITE_SETUP_GUIDE.md
    ├── hootsuite_questions.md
    └── PROJECT_SUMMARY.md
```

---

## ⚠️ Important Notes

1. **Semantic View Syntax**: All semantic view DDL has been verified against official Snowflake documentation
2. **ML Models**: Require `snowflake-ml-python` package in notebook environment
3. **Cortex Search**: Requires change tracking enabled on source tables
4. **Agent Tools**: All 3 ML models are exposed as SQL stored procedures
5. **Data Volume**: Synthetic data generation creates ~20,000+ rows

---

## 🔒 Security & Compliance

- All data is synthetic and for demonstration purposes
- Role-based access control (RBAC) configured via SYSADMIN
- Semantic models respect underlying table permissions
- Cortex Search uses owner's rights security model

---

## 📈 Cost Considerations

- **Warehouse Compute**: Data generation ~2-3 credits (MEDIUM warehouse)
- **ML Training**: ~2-5 credits
- **Cortex Search**: Per-query cost + storage
- **Intelligence Agent**: Per-message cost

---

## 🆘 Troubleshooting

### Semantic View Errors
- Verify all column names match table definitions exactly
- Use `table.semantic_name AS actual_column` syntax

### ML Model Errors
- Ensure models are registered with `target_platforms=['WAREHOUSE']`
- Verify feature view column names match model training columns exactly

### Cortex Search Errors
- Confirm change tracking is enabled on source tables
- Verify warehouse has sufficient capacity for indexing

---

## 📞 Support

For questions or issues:
1. Check the `docs/HOOTSUITE_SETUP_GUIDE.md` for detailed instructions
2. Review Snowflake documentation for syntax validation

---

**Created for**: Hootsuite
**Purpose**: Demonstrating Snowflake Intelligence Agent capabilities for social media
**Version**: 1.0.0
**Last Updated**: December 2025

