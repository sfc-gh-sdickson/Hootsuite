-- ============================================================================
-- Origence Intelligence Agent - Agent Configuration
-- ============================================================================
-- Purpose: Create Snowflake Intelligence Agent with semantic views and ML tools
-- Agent: ORIGENCE_LENDING_AGENT
-- Tools: 3 semantic views + 3 Cortex Search services + 3 ML model procedures
-- ============================================================================

USE DATABASE ORIGENCE_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE ORIGENCE_WH;

-- ============================================================================
-- Create Cortex Agent
-- ============================================================================
CREATE OR REPLACE AGENT ORIGENCE_LENDING_AGENT
  COMMENT = 'Origence credit union lending intelligence agent with ML predictions and semantic search'
  PROFILE = '{"display_name": "Origence Lending Assistant", "avatar": "lending-icon.png", "color": "blue"}'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration:
    budget:
      seconds: 60
      tokens: 32000

  instructions:
    response: "You are a helpful lending intelligence assistant. Provide clear, accurate answers about loans, credit unions, and member data. When using ML predictions, explain the risk levels clearly. Always cite data sources."
    orchestration: "For loan performance questions use SV_LOAN_PERFORMANCE. For member credit analysis use SV_MEMBER_CREDIT_PROFILE. For credit union metrics use SV_CREDIT_UNION_METRICS. For underwriting notes search use UNDERWRITING_NOTES_SEARCH. For loan documents search use LOAN_DOCUMENTS_SEARCH. For compliance policies search use COMPLIANCE_POLICIES_SEARCH. For ML predictions use the appropriate prediction procedure."
    system: "You are an expert lending intelligence agent for Origence, a Credit Union Service Organization (CUSO) serving 1,100+ credit unions with $593B+ in loan funding. You help analyze loan performance, member credit profiles, fraud detection, and compliance. Always provide data-driven insights."
    sample_questions:
      - question: "How many loan applications did we receive this month?"
        answer: "I'll query the loan applications data to get the count for the current month."
      - question: "What is the average loan amount for auto loans?"
        answer: "I'll calculate the average loan amount for auto loan type from the loans data."
      - question: "Which credit unions have the highest loan volumes?"
        answer: "I'll analyze loan volumes by credit union and show the top performers."
      - question: "Show me the top 5 dealers by loan count"
        answer: "I'll query dealer data and rank by total loan count, showing the top 5."
      - question: "What is our current loan approval rate?"
        answer: "I'll calculate the percentage of approved applications from total applications."
      - question: "What is the month-over-month growth in loan originations by credit union tier?"
        answer: "I'll analyze loan origination trends by tier and calculate MoM growth rates."
      - question: "Compare approval rates across different credit score bands and loan types"
        answer: "I'll segment approvals by credit score ranges and loan types to show approval rate patterns."
      - question: "Which dealers have the highest average loan amounts and lowest default rates?"
        answer: "I'll analyze dealer performance across multiple metrics to identify top performers."
      - question: "Show me loan performance trends by member age group and loan purpose"
        answer: "I'll segment loan performance by member demographics and loan purpose."
      - question: "What is the relationship between debt-to-income ratio and loan defaults?"
        answer: "I'll analyze default rates across different DTI ranges to show the correlation."
      - question: "Predict the default risk for auto loans currently in our portfolio"
        answer: "I'll use the loan default prediction model to analyze auto loans and provide risk distribution."
      - question: "Which loan applications in review status are most likely to be approved?"
        answer: "I'll use the loan approval predictor to score applications in review status."
      - question: "Identify potentially fraudulent applications submitted in the last 30 days"
        answer: "I'll use the fraud detection model to analyze recent applications and flag suspicious ones."
      - question: "What is the predicted default rate for loans with DTI greater than 40%?"
        answer: "I'll use the default predictor on high-DTI loans to forecast default risk."
      - question: "Show me high-risk loans that were approved in the last quarter"
        answer: "I'll combine approval and default predictions to identify risky approved loans."

  tools:
    # Semantic Views for Cortex Analyst (Text-to-SQL)
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "LoanPerformanceAnalyst"
        description: "Analyzes loan portfolio performance, delinquency rates, default rates, and loan status. Use for questions about loan performance, risk, defaults, delinquencies, and portfolio metrics."
    
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "MemberCreditAnalyst"
        description: "Analyzes member demographics, credit profiles, and loan application patterns. Use for questions about member credit scores, income levels, debt-to-income ratios, approval rates, and application trends."
    
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "CreditUnionMetricsAnalyst"
        description: "Analyzes credit union portfolio performance, dealer partnerships, and lending metrics. Use for questions about credit union performance, dealer loan volumes, partnership metrics, and regional analysis."

    # Cortex Search Services
    - tool_spec:
        type: "cortex_search"
        name: "UnderwritingNotesSearch"
        description: "Searches unstructured underwriting decision notes and rationale. Use when users ask about underwriting decisions, credit analysis, risk assessment notes, or decision factors."

    - tool_spec:
        type: "cortex_search"
        name: "LoanDocumentsSearch"
        description: "Searches loan documentation including contracts, verification documents, and supporting materials. Use when users ask about loan documents, verification, contracts, or documentation."

    - tool_spec:
        type: "cortex_search"
        name: "CompliancePoliciesSearch"
        description: "Searches compliance policies, regulatory requirements, and lending guidelines. Use when users ask about policies, regulations, compliance requirements, or lending standards."

    # ML Model Procedures
    - tool_spec:
        type: "function"
        name: "PredictLoanDefaultRisk"
        description: "Predicts default risk for loans in the portfolio. Returns risk distribution (low/medium/high/critical). Use when users ask to predict defaults, assess loan risk, or identify high-risk loans. Input: loan_type filter (AUTO_LOAN, PERSONAL_LOAN, HOME_EQUITY) or NULL for all loans."
        input_schema:
          type: "object"
          properties:
            loan_type_filter:
              type: "string"
              description: "Filter by loan type: AUTO_LOAN, PERSONAL_LOAN, HOME_EQUITY, or NULL for all"
          required: []

    - tool_spec:
        type: "function"
        name: "PredictLoanApproval"
        description: "Predicts approval likelihood for loan applications. Returns distribution of likely deny/review/approve. Use when users ask about approval predictions, application likelihood, or approval forecasts. Input: application status filter (PENDING, APPROVED, DENIED) or NULL."
        input_schema:
          type: "object"
          properties:
            application_status_filter:
              type: "string"
              description: "Filter by application status: PENDING, APPROVED, DENIED, or NULL for all"
          required: []

    - tool_spec:
        type: "function"
        name: "DetectFraudRisk"
        description: "Detects potentially fraudulent loan applications. Returns clean/suspicious/high-risk distribution and flagged application IDs. Use when users ask about fraud detection, suspicious applications, or fraud risk. Input: number of days to look back (default 30)."
        input_schema:
          type: "object"
          properties:
            days_back:
              type: "number"
              description: "Number of days to analyze (default 30)"
          required: []

  tool_resources:
    # Semantic View Resources
    LoanPerformanceAnalyst:
      semantic_view: "ORIGENCE_INTELLIGENCE.ANALYTICS.SV_LOAN_PERFORMANCE"
    
    MemberCreditAnalyst:
      semantic_view: "ORIGENCE_INTELLIGENCE.ANALYTICS.SV_MEMBER_CREDIT_PROFILE"
    
    CreditUnionMetricsAnalyst:
      semantic_view: "ORIGENCE_INTELLIGENCE.ANALYTICS.SV_CREDIT_UNION_METRICS"

    # Cortex Search Resources
    UnderwritingNotesSearch:
      name: "ORIGENCE_INTELLIGENCE.RAW.UNDERWRITING_NOTES_SEARCH"
      max_results: "10"
      title_column: "note_category"
      id_column: "note_id"

    LoanDocumentsSearch:
      name: "ORIGENCE_INTELLIGENCE.RAW.LOAN_DOCUMENTS_SEARCH"
      max_results: "10"
      title_column: "document_type"
      id_column: "document_id"

    CompliancePoliciesSearch:
      name: "ORIGENCE_INTELLIGENCE.RAW.COMPLIANCE_POLICIES_SEARCH"
      max_results: "5"
      title_column: "policy_title"
      id_column: "policy_id"

    # ML Model Procedure Resources
    PredictLoanDefaultRisk:
      function: "ORIGENCE_INTELLIGENCE.ML_MODELS.PREDICT_LOAN_DEFAULT_RISK"

    PredictLoanApproval:
      function: "ORIGENCE_INTELLIGENCE.ML_MODELS.PREDICT_LOAN_APPROVAL"

    DetectFraudRisk:
      function: "ORIGENCE_INTELLIGENCE.ML_MODELS.DETECT_FRAUD_RISK"
  $$;

-- ============================================================================
-- Grant Permissions
-- ============================================================================
GRANT USAGE ON AGENT ORIGENCE_LENDING_AGENT TO ROLE SYSADMIN;
GRANT USAGE ON AGENT ORIGENCE_LENDING_AGENT TO ROLE PUBLIC;

-- ============================================================================
-- Verification
-- ============================================================================
SHOW AGENTS IN SCHEMA ANALYTICS;

DESC AGENT ORIGENCE_LENDING_AGENT;

SELECT 'Origence Intelligence Agent created successfully' AS STATUS;

-- ============================================================================
-- Test Agent (Basic Query)
-- ============================================================================

/*
-- Test simple question
SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
  'ORIGENCE_INTELLIGENCE.ANALYTICS.ORIGENCE_LENDING_AGENT',
  'How many loans do we have in our portfolio?'
);

-- Test complex question
SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
  'ORIGENCE_INTELLIGENCE.ANALYTICS.ORIGENCE_LENDING_AGENT',
  'What is the default rate by credit union tier?'
);

-- Test ML prediction
SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
  'ORIGENCE_INTELLIGENCE.ANALYTICS.ORIGENCE_LENDING_AGENT',
  'Predict the default risk for auto loans'
);

-- Test search
SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
  'ORIGENCE_INTELLIGENCE.ANALYTICS.ORIGENCE_LENDING_AGENT',
  'Find underwriting notes about credit score concerns'
);
*/

-- ============================================================================
-- Notes
-- ============================================================================
-- The agent has 9 tools configured:
--   - 3 Semantic Views (Cortex Analyst for text-to-SQL)
--   - 3 Cortex Search Services (for unstructured data)
--   - 3 ML Model Procedures (for predictions)
--
-- Sample questions are in origence_questions.md
-- Setup guide is in ORIGENCE_SETUP_GUIDE.md
-- ============================================================================
