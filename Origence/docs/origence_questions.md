<img src="Snowflake_Logo.svg" width="200">

# Origence Intelligence Agent - Sample Questions

This document contains 15 sample questions that can be answered by the Origence Intelligence Agent, organized by complexity and capability.

---

## 🟢 Simple Questions (Direct Data Queries)

These questions query data directly from tables and views without complex joins or ML predictions.

### 1. How many loan applications did we receive this month?
**Expected Answer**: Count of applications in current month  
**Data Source**: LOAN_APPLICATIONS table  
**Query Pattern**: Simple COUNT with date filter

### 2. What is the average loan amount for auto loans?
**Expected Answer**: Average dollar amount for AUTO_LOAN type  
**Data Source**: LOANS table  
**Query Pattern**: AVG aggregation with WHERE filter

### 3. Which credit unions have the highest loan volumes?
**Expected Answer**: Top 10 credit unions by total loan count  
**Data Source**: CREDIT_UNIONS, LOANS tables  
**Query Pattern**: GROUP BY with ORDER BY

### 4. Show me the top 5 dealers by loan count
**Expected Answer**: Top 5 dealers with most loans facilitated  
**Data Source**: DEALERS, LOANS tables  
**Query Pattern**: GROUP BY, COUNT, ORDER BY with LIMIT

### 5. What is our current loan approval rate?
**Expected Answer**: Percentage of applications approved  
**Data Source**: LOAN_APPLICATIONS table  
**Query Pattern**: Conditional COUNT with ratio calculation

---

## 🟡 Complex Questions (Multi-table Analysis)

These questions require joins across multiple tables, time-series analysis, or complex aggregations.

### 6. What is the month-over-month growth in loan originations by credit union tier?
**Expected Answer**: MoM percentage change by tier (TIER_1, TIER_2, etc.)  
**Data Source**: LOANS, CREDIT_UNIONS tables  
**Query Pattern**: Window functions, LAG, date trunc, percentage calculation  
**Complexity**: Time-series analysis with grouping

### 7. Compare approval rates across different credit score bands and loan types
**Expected Answer**: Matrix of approval rates by score band x loan type  
**Data Source**: LOAN_APPLICATIONS, MEMBERS tables  
**Query Pattern**: CASE statements for binning, PIVOT or GROUP BY  
**Complexity**: Multi-dimensional aggregation

### 8. Which dealers have the highest average loan amounts and lowest default rates?
**Expected Answer**: Dealer ranking with composite scoring  
**Data Source**: DEALERS, LOANS tables  
**Query Pattern**: Multiple aggregations, JOIN, filtering, ranking  
**Complexity**: Multi-metric optimization query

### 9. Show me loan performance trends by member age group and loan purpose
**Expected Answer**: Trend analysis with demographics  
**Data Source**: LOANS, MEMBERS, LOAN_APPLICATIONS tables  
**Query Pattern**: Date aggregation, age binning, multi-level GROUP BY  
**Complexity**: Demographic segmentation with temporal dimension

### 10. What is the relationship between debt-to-income ratio and loan defaults?
**Expected Answer**: Correlation analysis or binned default rates  
**Data Source**: LOANS, LOAN_APPLICATIONS tables  
**Query Pattern**: DTI binning, default rate calculation, correlation  
**Complexity**: Statistical relationship analysis

---

## 🔴 ML Model Questions (Predictions)

These questions invoke the 3 ML models trained in the Snowflake notebook.

### 11. Predict the default risk for auto loans currently in our portfolio
**Expected Answer**: Risk distribution (Low/Medium/High/Critical counts and percentages)  
**Model**: LOAN_DEFAULT_PREDICTOR  
**Input Features**: loan_amount, term, interest_rate, credit_score, DTI, LTV, payment_history  
**Returns**: JSON with risk counts and high-risk percentage

### 12. Which loan applications in review status are most likely to be approved?
**Expected Answer**: List of application IDs with approval probability scores  
**Model**: LOAN_APPROVAL_PREDICTOR  
**Input Features**: credit_score, income, DTI, employment_length, requested_amount, collateral_value  
**Returns**: JSON with likely approvals count and approval probability distribution

### 13. Identify potentially fraudulent applications submitted in the last 30 days
**Expected Answer**: Fraud risk distribution with flagged application count  
**Model**: FRAUD_DETECTION_MODEL  
**Input Features**: application_velocity, income_to_request_ratio, employment_verification, credit_score_anomaly  
**Returns**: JSON with clean/suspicious/high-risk counts and flagged application details

### 14. What is the predicted default rate for loans with DTI greater than 40%?
**Expected Answer**: Forecasted default percentage for high-DTI segment  
**Model**: LOAN_DEFAULT_PREDICTOR (filtered input)  
**Input Features**: Same as #11, filtered WHERE DTI > 0.40  
**Returns**: JSON with predicted default rate for high-DTI cohort

### 15. Show me high-risk loans that were approved in the last quarter
**Expected Answer**: Count and characteristics of risky approved loans  
**Model**: LOAN_DEFAULT_PREDICTOR + LOAN_APPROVAL_PREDICTOR (combined)  
**Input Features**: Historical approved loans from Q4  
**Returns**: JSON with risk-approved mismatch analysis

---

## 📋 Question Categories Summary

| Category | Count | Complexity | Data Sources | ML Models |
|----------|-------|------------|--------------|-----------|
| Simple | 5 | Low | 1-2 tables | None |
| Complex | 5 | Medium-High | 2-4 tables | None |
| ML-Powered | 5 | High | 2-3 tables + Models | 1-2 models |

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
- Check time-series calculations against known values

### ML Model Questions
Test only after ML models are trained and registered.
- Require feature views to be created (04_create_views.sql)
- Require models registered in ML_MODELS schema
- Require wrapper functions created (07_create_model_wrapper_functions.sql)
- Returns JSON format responses

---

## ⚙️ Prerequisites by Question Type

### Simple Questions (1-5)
✅ Database and schema created  
✅ Tables created  
✅ Synthetic data loaded  

### Complex Questions (6-10)
✅ All Simple prerequisites  
✅ Analytical views created (optional but helpful)  

### ML Questions (11-15)
✅ All previous prerequisites  
✅ Feature views created  
✅ ML models trained via notebook  
✅ Models registered in Model Registry  
✅ Wrapper functions created  
✅ Intelligence Agent configured with model tools  

---

## 📝 Notes

- **Synthetic Data**: All questions are designed to work with the generated synthetic data
- **Semantic Views**: Questions 1-10 can leverage semantic views for natural language translation
- **ML Predictions**: Questions 11-15 require model inference and return structured JSON
- **Agent Context**: The Intelligence Agent has access to all 3 semantic views and 3 ML model tools
- **Performance**: Complex questions may require warehouse scaling for production data volumes

---

**Last Updated**: December 2025  
**Version**: 1.0.0
