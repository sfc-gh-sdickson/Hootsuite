<img src="Snowflake_Logo.svg" width="200">

# Origence Intelligence Agent - Complete Setup Guide

**Step-by-Step Instructions for Deployment**

---

## 📋 Prerequisites

### Required Access
- ✅ Snowflake account with ACCOUNTADMIN role
- ✅ Warehouse (MEDIUM or larger recommended)
- ✅ Snowflake Notebook environment access
- ✅ CORTEX_USER database role granted

### Estimated Time
- **Total Setup**: 45-60 minutes
- Database setup: 5 minutes
- Data generation: 10-15 minutes
- ML model training: 15-20 minutes
- Agent configuration: 5 minutes
- Testing: 10 minutes

### Cost Estimate
- **One-time setup**: ~20-30 credits (MEDIUM warehouse)
- **Ongoing**: ~5-10 credits/month (depends on query volume)

---

## 🚀 Step-by-Step Setup

### Step 1: Database and Schema Setup (5 minutes)

**File**: `origence_01_database_and_schema.sql`

```bash
# Execute in Snowsight or CLI
snow sql -f origence_01_database_and_schema.sql
```

**What it creates:**
- Database: `ORIGENCE_INTELLIGENCE`
- Schemas: `RAW`, `ANALYTICS`, `ML_MODELS`
- Warehouse: `ORIGENCE_WH` (MEDIUM, auto-suspend 5min)

**Verification:**
```sql
USE DATABASE ORIGENCE_INTELLIGENCE;
SHOW SCHEMAS;
-- Should see: RAW, ANALYTICS, ML_MODELS
```

---

### Step 2: Create Tables (2 minutes)

**File**: `origence_02_create_tables.sql`

```bash
snow sql -f origence_02_create_tables.sql
```

**What it creates:**
1. CREDIT_UNIONS (1,100 rows planned)
2. MEMBERS (100,000 rows planned)
3. DEALERS (20,000 rows planned)
4. LOAN_OFFICERS (250 rows planned)
5. LOAN_APPLICATIONS (50,000 rows planned)
6. LOANS (35,000 rows planned)
7. UNDERWRITING_NOTES (15,000 rows planned)
8. LOAN_DOCUMENTS (10,000 rows planned)
9. COMPLIANCE_POLICIES (50 rows planned)

**Verification:**
```sql
USE SCHEMA RAW;
SHOW TABLES;
-- Should see all 9 tables with CHANGE_TRACKING = ON
```

---

### Step 3: Generate Synthetic Data (10-15 minutes)

**File**: `origence_03_generate_synthetic_data.sql`

⚠️ **IMPORTANT**: This step takes 10-15 minutes on MEDIUM warehouse.

```bash
# Increase warehouse size for faster generation (optional)
ALTER WAREHOUSE ORIGENCE_WH SET WAREHOUSE_SIZE = 'LARGE';

# Run data generation
snow sql -f origence_03_generate_synthetic_data.sql

# Return to MEDIUM
ALTER WAREHOUSE ORIGENCE_WH SET WAREHOUSE_SIZE = 'MEDIUM';
```

**What it generates:**
- 1,100 credit unions across all US states
- 100,000 members with realistic demographics
- 20,000 automotive dealers (CUDL certified)
- 250 loan officers
- 50,000 loan applications (auto, personal, home equity)
- 35,000 funded loans ($593B+ total volume)
- 15,000 underwriting notes (unstructured text)
- 10,000 loan documents (unstructured text)
- 50 compliance policies (unstructured text)

**Verification:**
```sql
-- Check row counts
SELECT 'CREDIT_UNIONS' AS table_name, COUNT(*) AS row_count FROM CREDIT_UNIONS
UNION ALL
SELECT 'MEMBERS', COUNT(*) FROM MEMBERS
UNION ALL
SELECT 'DEALERS', COUNT(*) FROM DEALERS
UNION ALL
SELECT 'LOAN_OFFICERS', COUNT(*) FROM LOAN_OFFICERS
UNION ALL
SELECT 'LOAN_APPLICATIONS', COUNT(*) FROM LOAN_APPLICATIONS
UNION ALL
SELECT 'LOANS', COUNT(*) FROM LOANS
UNION ALL
SELECT 'UNDERWRITING_NOTES', COUNT(*) FROM UNDERWRITING_NOTES
UNION ALL
SELECT 'LOAN_DOCUMENTS', COUNT(*) FROM LOAN_DOCUMENTS
UNION ALL
SELECT 'COMPLIANCE_POLICIES', COUNT(*) FROM COMPLIANCE_POLICIES;
```

Expected totals: **~231,450 rows**

---

### Step 4: Create Analytical and Feature Views (2 minutes)

**File**: `origence_04_create_views.sql`

```bash
snow sql -f origence_04_create_views.sql
```

**What it creates:**
- 6 analytical views (for reporting)
- 3 ML feature views (for model training)

**Analytical Views:**
1. `V_LOAN_PERFORMANCE` - Portfolio performance metrics
2. `V_CREDIT_UNION_SUMMARY` - CU-level aggregations
3. `V_MEMBER_LOAN_HISTORY` - Member lending patterns
4. `V_DEALER_PERFORMANCE` - Dealer metrics
5. `V_APPLICATION_FUNNEL` - Conversion analysis
6. `V_PORTFOLIO_RISK` - Risk metrics

**ML Feature Views:**
1. `V_LOAN_DEFAULT_FEATURES` - Features for default prediction
2. `V_LOAN_APPROVAL_FEATURES` - Features for approval prediction
3. `V_FRAUD_DETECTION_FEATURES` - Features for fraud detection

**Verification:**
```sql
USE SCHEMA ANALYTICS;
SHOW VIEWS;
-- Should see 9 views total
```

---

### Step 5: Train ML Models (15-20 minutes)

**File**: `origence_ml_models.ipynb`

1. **Upload Notebook to Snowflake:**
   - In Snowsight, go to **Projects** → **Notebooks**
   - Click **+ Notebook** → **Import .ipynb file**
   - Upload `origence_ml_models.ipynb`

2. **Configure Notebook:**
   - Database: `ORIGENCE_INTELLIGENCE`
   - Schema: `ANALYTICS`
   - Warehouse: `ORIGENCE_WH`

3. **Run All Cells:**
   - Click **Run All** or execute cells sequentially
   - Wait 15-20 minutes for training

**Models Created:**
1. `LOAN_DEFAULT_PREDICTOR` - Predicts default risk (4 classes: Low/Medium/High/Critical)
2. `LOAN_APPROVAL_PREDICTOR` - Predicts approval likelihood (3 classes: Deny/Review/Approve)
3. `FRAUD_DETECTION_MODEL` - Detects fraudulent applications (3 classes: Clean/Suspicious/HighRisk)

**Verification:**
```sql
USE SCHEMA ML_MODELS;
SHOW MODELS;
-- Should see 3 models registered
```

---

### Step 6: Create Semantic Views (2 minutes)

**File**: `origence_05_create_semantic_views.sql`

⚠️ **CRITICAL**: Syntax has been verified against Snowflake documentation.

```bash
snow sql -f origence_05_create_semantic_views.sql
```

**What it creates:**
1. `SV_LOAN_PERFORMANCE` - Loan portfolio analytics
2. `SV_MEMBER_CREDIT_PROFILE` - Member demographics and credit
3. `SV_CREDIT_UNION_METRICS` - CU performance metrics

**Verification:**
```sql
USE SCHEMA ANALYTICS;
SHOW SEMANTIC VIEWS;
-- Should see 3 semantic views

-- Test a semantic view
SELECT * FROM SEMANTIC_VIEW(
  SV_LOAN_PERFORMANCE
  DIMENSIONS loans.loan_type_dim
  METRICS loans.total_loans, loans.avg_loan_amount
) LIMIT 10;
```

---

### Step 7: Create Cortex Search Services (5-10 minutes)

**File**: `origence_06_create_cortex_search.sql`

```bash
snow sql -f origence_06_create_cortex_search.sql
```

**What it creates:**
1. `UNDERWRITING_NOTES_SEARCH` - Search underwriting notes
2. `LOAN_DOCUMENTS_SEARCH` - Search loan documentation
3. `COMPLIANCE_POLICIES_SEARCH` - Search compliance policies

**Verification:**
```sql
USE SCHEMA RAW;
SHOW CORTEX SEARCH SERVICES;
-- Should see 3 search services

-- Test a search service
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'ORIGENCE_INTELLIGENCE.RAW.UNDERWRITING_NOTES_SEARCH',
    '{"query": "credit score", "limit": 3}'
  )
)['results'];
```

---

### Step 8: Create ML Model Wrapper Functions (2 minutes)

**File**: `origence_07_model_wrapper_functions.sql`

```bash
snow sql -f origence_07_model_wrapper_functions.sql
```

**What it creates:**
1. `PREDICT_LOAN_DEFAULT_RISK(loan_type VARCHAR)` - SQL procedure
2. `PREDICT_LOAN_APPROVAL(application_status VARCHAR)` - SQL procedure
3. `DETECT_FRAUD_RISK(days_back NUMBER)` - SQL procedure

**Verification:**
```sql
USE SCHEMA ML_MODELS;
SHOW PROCEDURES;
-- Should see 3 procedures

-- Test a procedure
CALL PREDICT_LOAN_DEFAULT_RISK('AUTO_LOAN');
-- Should return JSON with risk predictions
```

---

### Step 9: Create Intelligence Agent (3 minutes)

**File**: `origence_08_intelligence_agent.sql`

```bash
snow sql -f origence_08_intelligence_agent.sql
```

**What it creates:**
- Snowflake Intelligence Agent: `ORIGENCE_LENDING_AGENT`
- Configured with:
  - 3 semantic views (for Cortex Analyst)
  - 3 Cortex Search services
  - 3 ML model tools

**Verification:**
```sql
SHOW AGENTS IN SCHEMA ANALYTICS;
-- Should see ORIGENCE_LENDING_AGENT

DESC AGENT ORIGENCE_LENDING_AGENT;
-- Review agent configuration
```

---

### Step 10: Test the Agent (10 minutes)

**Test Simple Questions:**
```sql
-- Ask the agent a question
SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
  'ORIGENCE_LENDING_AGENT',
  'How many loan applications did we receive this month?'
);
```

**Test Complex Questions:**
```sql
SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
  'ORIGENCE_LENDING_AGENT',
  'What is the month-over-month growth in loan originations by credit union tier?'
);
```

**Test ML Model Questions:**
```sql
SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
  'ORIGENCE_LENDING_AGENT',
  'Predict the default risk for auto loans in our current portfolio'
);
```

Refer to `origence_questions.md` for all 15 sample questions.

---

## ✅ Deployment Checklist

Use this checklist to track your progress:

- [ ] Step 1: Database and schemas created
- [ ] Step 2: All 9 tables created with change tracking
- [ ] Step 3: Synthetic data generated (~231K rows)
- [ ] Step 4: 9 views created (6 analytical + 3 feature)
- [ ] Step 5: 3 ML models trained and registered
- [ ] Step 6: 3 semantic views created
- [ ] Step 7: 3 Cortex Search services created
- [ ] Step 8: 3 ML wrapper procedures created
- [ ] Step 9: Intelligence Agent configured
- [ ] Step 10: Agent tested with sample questions

---

## 🔧 Troubleshooting

### Issue: Semantic View Creation Fails
**Error**: "Syntax error" or "Invalid identifier"

**Solution**:
1. Verify all table names match exactly (case-sensitive)
2. Check that column names in DIMENSIONS/METRICS exist in base tables
3. Ensure RELATIONSHIPS reference correct primary/foreign keys

### Issue: Cortex Search Service Fails
**Error**: "Change tracking not enabled"

**Solution**:
```sql
-- Enable change tracking on tables
ALTER TABLE UNDERWRITING_NOTES SET CHANGE_TRACKING = TRUE;
ALTER TABLE LOAN_DOCUMENTS SET CHANGE_TRACKING = TRUE;
ALTER TABLE COMPLIANCE_POLICIES SET CHANGE_TRACKING = TRUE;
```

### Issue: ML Model Training Fails
**Error**: "Package not found" or "Import error"

**Solution**:
1. Ensure notebook uses correct Python runtime (3.10)
2. Verify packages listed: `snowflake-ml-python`, `scikit-learn`, `pandas`
3. Check feature view exists and returns data

### Issue: Model Wrapper Function Fails
**Error**: "Model not found" or "No data returned"

**Solution**:
1. Verify model is registered: `SHOW MODELS IN SCHEMA ML_MODELS;`
2. Check feature view has data: `SELECT * FROM V_LOAN_DEFAULT_FEATURES LIMIT 10;`
3. Ensure model was registered with `target_platforms=['WAREHOUSE']`

---

## 📊 Monitoring and Maintenance

### Monitor Warehouse Usage
```sql
-- View credit consumption
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE WAREHOUSE_NAME = 'ORIGENCE_WH'
  AND START_TIME >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY START_TIME DESC;
```

### Monitor Agent Usage
```sql
-- View agent query history
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.CORTEX_ANALYST_USAGE_HISTORY
WHERE START_TIME >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY START_TIME DESC;
```

### Monitor Cortex Search Usage
```sql
-- View search service usage
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.CORTEX_SEARCH_DAILY_USAGE_HISTORY
WHERE USAGE_DATE >= DATEADD(day, -7, CURRENT_DATE())
ORDER BY USAGE_DATE DESC;
```

---

## 🎓 Next Steps

1. **Customize Semantic Views**: Add more dimensions/metrics specific to your use case
2. **Enhance ML Models**: Retrain with production data and tune hyperparameters
3. **Add More Search Services**: Index additional unstructured data sources
4. **Build Applications**: Create Streamlit apps or integrate with business tools
5. **Production Deployment**: Configure RBAC, monitoring, and alerts

---

## 📞 Support Resources

- **Snowflake Documentation**: https://docs.snowflake.com
- **Cortex Analyst Guide**: https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst
- **Cortex Search Guide**: https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search
- **Model Registry**: https://docs.snowflake.com/en/developer-guide/snowpark-ml/model-registry

---

**Version**: 1.0.0  
**Last Updated**: December 2025  
**Estimated Setup Time**: 45-60 minutes  
**Estimated Cost**: 20-30 credits (one-time setup)
