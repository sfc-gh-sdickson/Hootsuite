<img src="../Snowflake_Logo.svg" width="200">

# Hootsuite Intelligence Agent - Setup Guide

This guide provides comprehensive, step-by-step instructions to deploy the complete Hootsuite Intelligence Agent solution.

---

## 📋 Prerequisites

Before starting, ensure you have:

1.  **Snowflake Account**: Enterprise Edition or higher (required for Cortex features).
2.  **Permissions**: Access to a role with `SYSADMIN` privileges (or equivalent ability to create databases, warehouses, and integration objects).
3.  **Snowflake Notebooks**: Enabled in your Snowflake account.
4.  **Anaconda**: Enabled in your Snowflake account (for ML packages).

---

## 🛠️ Deployment Flow

Follow these steps sequentially to build the entire platform.

![Setup Flow](setup_flow_diagram.svg)

---

### Phase 1: Foundation (Database & Data)

#### Step 1: Initialize Database & Schema
Create the core container for the application.
*   **Script**: `sql/setup/hootsuite_01_database_and_schema.sql`
*   **Action**: Run all queries.
*   **Verification**:
    ```sql
    SHOW SCHEMAS IN DATABASE HOOTSUITE_INTELLIGENCE;
    -- Should list: RAW, ANALYTICS, ML_MODELS
    ```

#### Step 2: Create Tables
Define the schema for Customers, Campaigns, Posts, Tickets, etc.
*   **Script**: `sql/setup/hootsuite_02_create_tables.sql`
*   **Action**: Run all queries.
*   **Verification**:
    ```sql
    SHOW TABLES IN SCHEMA HOOTSUITE_INTELLIGENCE.RAW;
    -- Should list 8 tables
    ```

#### Step 3: Generate Synthetic Data
Populate the tables with ~200,000 rows of realistic test data.
*   **Script**: `sql/data/hootsuite_03_generate_synthetic_data.sql`
*   **Action**: Run all queries. *Note: This may take 5-10 minutes on a Medium warehouse.*
*   **Verification**:
    ```sql
    SELECT COUNT(*) FROM HOOTSUITE_INTELLIGENCE.RAW.POSTS;
    -- Should return ~100,000
    ```

---

### Phase 2: Intelligence Layer (Views & Search)

#### Step 4: Create Analytical & Feature Views
Create standard views for reporting and ML feature engineering.
*   **Script**: `sql/views/hootsuite_04_create_views.sql`
*   **Action**: Run all queries.

#### Step 5: Create Semantic Views (Cortex Analyst)
Create the semantic layer that allows the LLM to understand your data structure.
*   **Script**: `sql/views/hootsuite_05_create_semantic_views.sql`
*   **Action**: Run all queries.
*   **Verification**:
    ```sql
    SHOW SEMANTIC VIEWS IN SCHEMA HOOTSUITE_INTELLIGENCE.ANALYTICS;
    -- Should list 3 views
    ```

#### Step 6: Create Cortex Search Services
Enable vector search on unstructured text fields.
*   **Script**: `sql/search/hootsuite_06_create_cortex_search.sql`
*   **Action**: Run all queries.
*   **Verification**:
    ```sql
    SHOW CORTEX SEARCH SERVICES IN SCHEMA HOOTSUITE_INTELLIGENCE.RAW;
    -- Should list 3 services
    ```

---

### Phase 3: Predictive Modeling (Machine Learning)

#### Step 7: Train ML Models
Train the Churn, ROI, and Priority models using Snowpark.
1.  Open **Snowflake Notebooks** in the UI.
2.  Create a new Notebook.
3.  **Import Files**:
    *   Upload `notebooks/hootsuite_ml_models.ipynb`
    *   Upload `notebooks/environment.yml`
4.  **Run All Cells**: Execute the notebook to train and register the models in the Model Registry.
5.  **Verification**: Look for "Successfully registered" messages in the notebook output.

#### Step 8: Create ML SQL Functions
Expose the trained models as SQL functions for the Agent to call.
*   **Script**: `sql/ml/hootsuite_07_ml_model_functions.sql`
*   **Action**: Run all queries.
*   **Verification**:
    ```sql
    SELECT HOOTSUITE_INTELLIGENCE.ML_MODELS.PREDICT_CHURN_RISK('RETAIL');
    -- Should return a prediction summary string
    ```

---

### Phase 4: Customer Success Automation (New Feature)

#### Step 9: Deploy Customer Engagement Automation
Create automated workflows for customer success team with A/B testing capabilities.
*   **Script**: `sql/procedures/hootsuite_09_customer_engagement_procedure.sql`
*   **Action**: Run all queries.
*   **What it does**: 
    *   Creates a tracking table for engagement results
    *   Deploys a Python stored procedure that triggers automated email campaigns
    *   Schedules account reviews for high-risk customers
    *   Supports A/B testing with different engagement strategies
*   **Verification**:
    ```sql
    -- Test the procedure directly
    CALL HOOTSUITE_INTELLIGENCE.ANALYTICS.TRIGGER_CUSTOMER_ENGAGEMENT('CUST000001', 'CHURN_PREVENTION', 'A');
    -- Should return JSON with engagement actions taken
    
    -- Verify tracking table exists
    SELECT * FROM HOOTSUITE_INTELLIGENCE.ANALYTICS.CUSTOMER_ENGAGEMENT_RESULTS LIMIT 5;
    ```

---

### Phase 5: Orchestration (The Agent)

#### Step 10: Configure Intelligence Agent
Assemble all tools (including automation) into the final conversational agent.
*   **Script**: `sql/agent/hootsuite_08_intelligence_agent.sql`
*   **Action**: Run all queries.
*   **Verification**:
    ```sql
    SHOW AGENTS IN SCHEMA HOOTSUITE_INTELLIGENCE.ANALYTICS;
    -- Should list HOOTSUITE_INTELLIGENCE_AGENT
    
    DESC AGENT HOOTSUITE_INTELLIGENCE_AGENT;
    -- Should show 10 tools including TriggerCustomerEngagement
    ```

---

## 🧪 Testing & Validation

Once deployed, use **Cortex Copilot** or the **Snowsight AI Interface** to test the agent.

Refer to `docs/hootsuite_questions.md` for a curated list of questions to validate all capabilities, including:
*   Data Aggregation (Semantic Views)
*   Predictive Inference (ML Models)
*   Document Search (Cortex Search)
*   Automated Actions (Customer Engagement)

**Example Test Queries:**

*Analytics:*
> "Predict the churn risk for Enterprise customers in the Retail industry and find any recent support tickets related to billing issues."

*Automation:*
> "Trigger engagement for customer CUST000289 with churn prevention using variant A"

This will:
- Analyze customer risk (churn score 1.0 = high risk)
- Queue personalized email (high_touch_personalized template)
- Schedule priority account review
- Log all actions to CUSTOMER_ENGAGEMENT_RESULTS table

---

## 🆘 Troubleshooting

### Common Issues

*   **Data Generation Errors**: If `POSTS` generation fails, ensure you are using the latest version of script `03` which includes TRUNCATE statements and uses temp tables for random distribution.

*   **ML Model Not Found**: Ensure you ran the Notebook **before** running script `07`. If you regenerate data (File 3), you MUST retrain all models by re-running the entire notebook.

*   **ML Type Mismatch Errors**: If you see "Numeric value 'X' is not recognized" or "Invalid argument types", this means:
    - Models were trained on old data with different values
    - Solution: Re-run the entire notebook to retrain models on current data

*   **Agent "Tool Not Found"**: Verify that the Semantic Views and Search Services exist and the Agent has `USAGE` permissions on them (handled in the scripts, but double-check roles).

*   **Automation Procedure Errors**: 
    - Ensure File 9 (`hootsuite_09_customer_engagement_procedure.sql`) was run successfully
    - Verify procedure exists: `SHOW PROCEDURES LIKE 'TRIGGER_CUSTOMER_ENGAGEMENT'`
    - Test directly before testing through agent: `CALL TRIGGER_CUSTOMER_ENGAGEMENT('CUST000001', 'CHURN_PREVENTION', 'A')`
    - Customer ID must exist in the data - use valid customer IDs from: `SELECT customer_id FROM RAW.CUSTOMERS LIMIT 10`

### Execution Order Issues

**If you make any changes to data or views, follow this order:**

1. File 3 (Data) → Regenerate data
2. File 4 (Views) → Recreate feature views
3. Notebook (All cells) → Retrain ALL ML models
4. File 7 (ML Functions) → Recreate functions
5. File 5 (Semantic Views) → Recreate semantic layer
6. File 9 (Automation) → Recreate procedure
7. File 10 (Agent) → Recreate agent

**Skipping steps will cause type mismatches and "function not found" errors.**
