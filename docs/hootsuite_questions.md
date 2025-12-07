<img src="../Snowflake_Logo.svg" width="200">

# Hootsuite Intelligence Agent - Sample Questions

This document contains sample questions that can be answered by the Hootsuite Intelligence Agent, organized by complexity and capability.

## 1. Simple Questions (Data Lookup & Aggregation)
*Target: Semantic Views (Cortex Analyst)*

1.  **"How many active customers do we have in the Retail industry?"**
    *   *Data Source*: `SV_CUSTOMER_HEALTH_ANALYTICS`
    *   *Intent*: Basic filtering and counting.
2.  **"What is the total budget allocated to Awareness campaigns?"**
    *   *Data Source*: `SV_CAMPAIGN_ANALYTICS`
    *   *Intent*: Summation with a filter.
3.  **"Show me the top 5 social accounts by follower count."**
    *   *Data Source*: `SV_SOCIAL_PERFORMANCE`
    *   *Intent*: Ranking and sorting.
4.  **"List all open support tickets with Urgent priority."**
    *   *Data Source*: `SV_CUSTOMER_HEALTH_ANALYTICS`
    *   *Intent*: Filtering on multiple columns.
5.  **"Count the number of posts published on Instagram last month."**
    *   *Data Source*: `SV_SOCIAL_PERFORMANCE`
    *   *Intent*: Date-based filtering and counting.

## 2. Complex Questions (Multi-Table Analysis)
*Target: Semantic Views (Cortex Analyst)*

1.  **"Compare the average engagement rate of Video vs. Image posts for Technology customers."**
    *   *Data Source*: `SV_SOCIAL_PERFORMANCE`
    *   *Intent*: Aggregation by dimension (Media Type) filtered by joined dimension (Industry).
2.  **"What is the churn risk distribution for Enterprise customers compared to Professional plans?"**
    *   *Data Source*: `SV_CUSTOMER_HEALTH_ANALYTICS`
    *   *Intent*: Grouping by plan type and calculating average risk.
3.  **"Which campaign objective yields the highest ROI based on click-through rates?"**
    *   *Data Source*: `SV_CAMPAIGN_ANALYTICS`
    *   *Intent*: Calculated metric comparison across objectives.
4.  **"Correlate the number of open support tickets with customer churn risk scores."**
    *   *Data Source*: `SV_CUSTOMER_HEALTH_ANALYTICS`
    *   *Intent*: Analyzing relationship between two metrics.
5.  **"Identify the regions with the highest revenue but also highest churn risk."**
    *   *Data Source*: `SV_CUSTOMER_HEALTH_ANALYTICS`
    *   *Intent*: Multi-metric ranking and tradeoff analysis.

## 3. Machine Learning & Search Questions
*Target: Cortex Search & ML Functions*

1.  **"Predict the churn risk for all customers in the Manufacturing industry."**
    *   *Tool*: `PredictChurnRisk` (ML)
    *   *Intent*: Predictive inference on a subset of data.
2.  **"Forecast the ROI for our active Conversion campaigns."**
    *   *Tool*: `PredictCampaignROI` (ML)
    *   *Intent*: Outcome prediction for active entities.
3.  **"Classify the priority of tickets related to 'Billing' issues."**
    *   *Tool*: `ClassifyTicketPriority` (ML)
    *   *Intent*: Classification of text/category data.
4.  **"Find support tickets related to 'login failure' and their resolution notes."**
    *   *Tool*: `SupportTicketSearch` (Cortex Search)
    *   *Intent*: Semantic search over unstructured text.
5.  **"Search for help articles about setting up 'Instagram Business' accounts."**
    *   *Tool*: `KnowledgeBaseSearch` (Cortex Search)
    *   *Intent*: Knowledge retrieval.

## 4. Automated Actions & Workflows
*Target: Customer Engagement Automation Procedure*

1.  **"Trigger engagement for customer CUST000289 with churn prevention using variant A"**
    *   *Tool*: `TriggerCustomerEngagement` (Python Stored Procedure)
    *   *Intent*: Execute automated customer success workflow
    *   *Actions Taken*:
        - Analyzes customer risk score and account health
        - Sends personalized re-engagement email (high-touch or automated based on variant)
        - Schedules priority account review for high-risk customers
        - Logs actions for A/B testing analysis
    *   *Returns*: JSON summary with customer details, actions performed, and variant used

2.  **"Trigger upsell engagement for customer CUST000125 using variant B"**
    *   *Tool*: `TriggerCustomerEngagement`
    *   *Intent*: Execute upsell campaign with automated strategy
    *   *Engagement Type*: UPSELL (instead of CHURN_PREVENTION)
    *   *A/B Variant*: B (automated tips and self-service resources)

3.  **"Which customers have the highest churn risk?"**
    *   *Follow-up*: Use this to identify at-risk customers, then trigger engagement workflows
    *   *Workflow*: Analytics → Identify Risk → Trigger Automation

