<img src="../Snowflake_Logo.svg" width="200">

# Hootsuite Intelligence Agent - Setup Guide

## Overview
This solution builds a Snowflake Intelligence Agent for Hootsuite that combines:
1.  **3 Semantic Views** (Cortex Analyst) for querying structured analytics.
2.  **3 Cortex Search Services** for searching unstructured text (tickets, articles, assets).
3.  **3 Machine Learning Models** for predictive insights.

## Prerequisites
*   Snowflake Account (Enterprise or higher recommended)
*   `SYSADMIN` role access
*   Snowflake Notebooks enabled

## Setup Steps

### 1. Database & Tables
Run the following scripts in order to setup the foundation:
1.  `sql/setup/hootsuite_01_database_and_schema.sql` - Creates DB `HOOTSUITE_INTELLIGENCE`.
2.  `sql/setup/hootsuite_02_create_tables.sql` - Creates 8 core tables with change tracking.
3.  `sql/data/hootsuite_03_generate_synthetic_data.sql` - Generates ~200k rows of synthetic data.

### 2. Views & Search Services
Run these scripts to enable analytics and search:
1.  `sql/views/hootsuite_04_create_views.sql` - Creates analytical and ML feature views.
2.  `sql/views/hootsuite_05_create_semantic_views.sql` - Creates Semantic Views for Cortex Analyst.
3.  `sql/search/hootsuite_06_create_cortex_search.sql` - Creates 3 Cortex Search Services.

### 3. Machine Learning
1.  Upload `notebooks/hootsuite_ml_models.ipynb` and `notebooks/environment.yml` to a Snowflake Notebook.
2.  Run the notebook to train and register the 3 ML models.
3.  Run `sql/ml/hootsuite_07_ml_model_functions.sql` to create the SQL wrapper functions.

### 4. Create Agent
1.  Run `sql/agent/hootsuite_08_intelligence_agent.sql` to compile the final agent.

## Validation Questions

### Simple Questions
1.  "How many active customers do we have in the Retail industry?" (Uses `CustomerHealthAnalyst`)
2.  "What is the total budget allocated to Awareness campaigns?" (Uses `CampaignAnalyst`)
3.  "Show me the top 5 social accounts by follower count." (Uses `SocialPerformanceAnalyst`)
4.  "List all open support tickets with Urgent priority." (Uses `CustomerHealthAnalyst` or Search)
5.  "Count the number of posts published on Instagram last month." (Uses `SocialPerformanceAnalyst`)

### Complex Questions
1.  "Compare the average engagement rate of Video vs. Image posts for Technology customers." (Uses `SocialPerformanceAnalyst`)
2.  "What is the churn risk distribution for Enterprise customers compared to Professional plans?" (Uses `CustomerHealthAnalyst`)
3.  "Which campaign objective yields the highest ROI based on click-through rates?" (Uses `CampaignAnalyst`)
4.  "Correlate the number of open support tickets with customer churn risk scores." (Uses `CustomerHealthAnalyst`)
5.  "Identify the regions with the highest revenue but also highest churn risk." (Uses `CustomerHealthAnalyst`)

### ML Model Questions
1.  "Predict the churn risk for all customers in the Manufacturing industry." (Uses `PredictChurnRisk`)
2.  "Forecast the ROI for our active Conversion campaigns." (Uses `PredictCampaignROI`)
3.  "Classify the priority of tickets related to 'Billing' issues." (Uses `ClassifyTicketPriority`)
4.  "What is the predicted risk profile for customers with less than 6 months tenure?" (Uses `PredictChurnRisk`)
5.  "Predict priority for tickets regarding 'API connection' issues." (Uses `ClassifyTicketPriority`)

### Search Questions
1.  "Find support tickets related to 'login failure' and their resolution notes." (Uses `SupportTicketSearch`)
2.  "Search for help articles about setting up 'Instagram Business' accounts." (Uses `KnowledgeBaseSearch`)
3.  "Find marketing assets that are 'video tutorials' for product launches." (Uses `AssetSearch`)

