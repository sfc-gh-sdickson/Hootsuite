<img src="../Snowflake_Logo.svg" width="200">

# Hootsuite Intelligence Agent Setup Guide

This guide provides step-by-step instructions to deploy the Snowflake Intelligence Agent for Hootsuite.

## Prerequisites

- Snowflake Account with `SYSADMIN` role access.
- Snowflake Notebooks enabled.
- Cortex Search and Cortex Analyst enabled in your region.
- Python 3.10+ (for local notebook execution if not using Snowflake Notebooks).

## Step 1: Database and Schema Setup

Run the following SQL scripts in order to establish the environment and data structures.

1.  **Setup Database & Schemas**:
    ```sql
    -- Run sql/setup/hootsuite_01_database_and_schema.sql
    ```
2.  **Create Tables**:
    ```sql
    -- Run sql/setup/hootsuite_02_create_tables.sql
    ```

## Step 2: Data Generation

Generate synthetic data to populate the tables. This script handles `UNIFORM` distributions and ensures referential integrity.

1.  **Generate Data**:
    ```sql
    -- Run sql/data/hootsuite_03_generate_synthetic_data.sql
    ```
    *Estimated time: 2-3 minutes on MEDIUM warehouse.*

## Step 3: Analytical & Feature Views

Create the views used for analytics and Machine Learning.

1.  **Create Views**:
    ```sql
    -- Run sql/views/hootsuite_04_create_views.sql
    ```

## Step 4: Semantic Models (Cortex Analyst)

Create the Semantic Views that enable natural language querying.

1.  **Create Semantic Views**:
    ```sql
    -- Run sql/views/hootsuite_05_create_semantic_views.sql
    ```
    *Verification: Ensure `SV_SOCIAL_PERFORMANCE` is created successfully.*

## Step 5: Cortex Search (Unstructured Data)

Enable semantic search on posts and strategy documents.

1.  **Create Search Services**:
    ```sql
    -- Run sql/search/hootsuite_06_create_cortex_search.sql
    ```

## Step 6: Machine Learning Models

Train and register the ML models using Snowflake Notebooks.

1.  **Import Notebook**:
    - Import `notebooks/hootsuite_ml_models.ipynb` into Snowflake Notebooks.
    - Add the packages listed in `notebooks/environment.yml` (`snowflake-ml-python`, `xgboost`, etc.).
2.  **Run Notebook**:
    - Execute all cells to train and register:
        - `POST_ENGAGEMENT_PREDICTOR`
        - `CHURN_RISK_PREDICTOR`
        - `OPTIMAL_TIME_PREDICTOR`

## Step 7: ML Model Wrappers (Agent Tools)

Expose the registered models as SQL Stored Procedures for the Agent.

1.  **Create Procedures**:
    ```sql
    -- Run sql/ml/hootsuite_07_ml_model_functions.sql
    ```

## Step 8: Verification & Agent Testing

Verify the setup using the sample questions and agent configuration.

1.  **Review Agent Configuration**:
    - Check `sql/agent/hootsuite_08_intelligence_agent.sql` for sample questions and verification queries.

## Validation Checklist

- [ ] **Data**: Tables populated (`SELECT COUNT(*) FROM RAW.POSTS` > 0).
- [ ] **Views**: `ANALYTICS.V_POST_ENGAGEMENT_FEATURES` returns rows.
- [ ] **Semantic View**: `SV_SOCIAL_PERFORMANCE` exists and columns map correctly.
- [ ] **Search**: `SNOWFLAKE.CORTEX.SEARCH_PREVIEW` returns results.
- [ ] **ML**: `SHOW PROCEDURES IN SCHEMA ML_MODELS` lists 3 procedures.

## Common Issues & Fixes

- **"Invalid Identifier" in Semantic View**: Ensure the syntax is `table.semantic_name AS actual_column`.
- **"Model not found"**: Ensure the notebook ran successfully and `registry.log_model` was called.
- **"Search Service not found"**: Ensure you are in the correct schema (`RAW`) and role (`SYSADMIN`).

