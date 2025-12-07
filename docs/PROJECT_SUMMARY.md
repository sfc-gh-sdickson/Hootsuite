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

### 4. Customer Success Automation (Python Stored Procedures)
The agent can trigger **Automated Engagement Workflows**:
*   **Churn Prevention**: Automatically sends personalized re-engagement emails to at-risk customers.
*   **Account Reviews**: Schedules priority reviews for high-risk or high-value accounts.
*   **A/B Testing**: Supports variant testing (high-touch vs. automated strategies).
*   **Action Tracking**: Logs all engagement activities to a results table for analysis.
*   **Integration Ready**: Designed to connect with external email/calendar APIs.

## Architecture Highlights
*   **Synthetic Data Generation**: Creates ~200k rows of realistic Hootsuite data (Customers, Posts, Tickets, etc.).
*   **Snowflake Notebooks**: Python-based ML training pipeline using Snowpark ML.
*   **Customer Success Automation**: Python stored procedures that trigger real-world actions (emails, scheduling, logging).
*   **A/B Testing Framework**: Built-in experimentation with variant tracking and results analysis.
*   **Top-Level Agent**: A unified `HOOTSUITE_INTELLIGENCE_AGENT` that orchestrates tools and triggers automated actions based on user intent.
*   **Strict SQL Syntax**: All code verified against Snowflake standards (Change Tracking, NTZ Timestamps, etc.).

## Business Value

**For Customer Success Teams:**
- Automatically identify and engage at-risk customers
- Prioritize account reviews based on data-driven risk scores
- Test different engagement strategies with A/B testing
- Track engagement effectiveness with automated logging

**For Marketing Teams:**
- Predict campaign ROI before launch
- Analyze engagement patterns across platforms and content types
- Optimize posting strategies based on historical performance

**For Support Operations:**
- Automatically classify ticket priority for faster triage
- Search historical resolutions for similar issues
- Correlate support volume with customer health metrics

