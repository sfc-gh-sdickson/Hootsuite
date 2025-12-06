<img src="../Snowflake_Logo.svg" width="200">

# Hootsuite Intelligence Agent - Project Summary

## Project Overview
This project establishes a **Snowflake Intelligence Agent** for **Hootsuite**, a leading social media management platform. The agent empowers business users to ask natural language questions about customer health, campaign performance, and social media metrics, leveraging both structured data and unstructured content.

## Key Capabilities

### 1. Descriptive Analytics (Cortex Analyst)
Users can query structured data via **3 Semantic Views**:
*   **Campaign Performance**: ROI, budget utilization, and objective tracking.
*   **Customer Health**: Churn risk scores, revenue, and support ticket volume.
*   **Social Performance**: Engagement rates, follower growth, and platform metrics.

### 2. Predictive Intelligence (Snowflake ML)
The solution includes **3 Machine Learning Models** trained inside Snowflake:
*   **Churn Risk Predictor**: Identifies customers at risk of leaving based on usage and support history.
*   **Campaign ROI Forecaster**: Predicts the success likelihood of marketing campaigns.
*   **Ticket Priority Classifier**: Automatically triages support tickets based on urgency and category.

### 3. Semantic Search (Cortex Search)
Users can search unstructured data via **3 Cortex Search Services**:
*   **Support Tickets**: Retrieval of historical issues and resolutions.
*   **Knowledge Base**: Access to help articles and documentation.
*   **Marketing Assets**: Searchable descriptions of creative assets (images/videos).

## Architecture Highlights
*   **Synthetic Data Generation**: Creates ~200k rows of realistic Hootsuite data (Customers, Posts, Tickets, etc.).
*   **Snowflake Notebooks**: Python-based ML training pipeline using Snowpark ML.
*   **Top-Level Agent**: A unified `HOOTSUITE_INTELLIGENCE_AGENT` that orchestrates tools based on user intent.
*   **Strict SQL Syntax**: All code verified against Snowflake standards (Change Tracking, NTZ Timestamps, etc.).

