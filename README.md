<img src="Snowflake_Logo.svg" width="200">

# Hootsuite Intelligence Agent Solution

**An Enterprise-Grade AI Analytics Platform for Social Media Management**

This repository contains a complete, production-ready implementation of a **Snowflake Intelligence Agent** tailored for Hootsuite. It unifies structured analytics, unstructured data search, and machine learning predictions into a single conversational interface.

---

## 🏗 System Architecture

The solution leverages the full power of the Snowflake AI Data Cloud, integrating **Cortex Analyst** for structured queries, **Cortex Search** for vector-based document retrieval, and **Snowpark ML** for predictive modeling.

![Architecture Diagram](docs/architecture_diagram.svg)

### Key Capabilities

| Component | Technology | Functionality |
|-----------|------------|---------------|
| **Descriptive Analytics** | **Cortex Analyst** | Natural language queries over 3 Semantic Views (Campaigns, Customer Health, Social Performance). |
| **Semantic Search** | **Cortex Search** | Vector search over Support Tickets, Knowledge Base articles, and Marketing Assets. |
| **Predictive AI** | **Snowpark ML** | 3 Custom ML Models: Churn Risk Prediction, Campaign ROI Forecasting, Ticket Priority Classification. |
| **Customer Success Automation** | **Python Stored Procedures** | Automated engagement workflows with A/B testing for churn prevention, upsell campaigns, and onboarding. |
| **Streamlit App Generation** | **Python Stored Procedures** | Automatically deploys interactive Streamlit apps from any query and returns clickable link. |
| **Orchestration** | **Cortex Agents** | A unified agent that intelligently routes queries, triggers actions, and deploys apps on demand. |

---

## 📂 Repository Structure

```text
.
├── docs/
│   ├── HOOTSUITE_SETUP_GUIDE.md    # 📚 DETAILED SETUP INSTRUCTIONS
│   ├── PROJECT_SUMMARY.md          # High-level executive summary
│   ├── hootsuite_questions.md      # Test bank of sample questions
│   ├── architecture_diagram.svg    # System architecture visualization
│   └── setup_flow_diagram.svg      # Setup process visualization
├── notebooks/
│   ├── hootsuite_ml_models.ipynb   # 🐍 Python notebook for ML training
│   └── environment.yml             # Conda environment specification
├── sql/
│   ├── setup/                      # 1️⃣ Database & Table creation
│   ├── data/                       # 2️⃣ Synthetic Data Generation (~200k rows)
│   ├── views/                      # 3️⃣ Analytical & Semantic Views
│   ├── search/                     # 4️⃣ Cortex Search Services
│   ├── ml/                         # 5️⃣ SQL Wrappers for ML Models
│   ├── procedures/                 # 6️⃣ Automation (Customer Engagement + Streamlit Generator)
│   └── agent/                      # 7️⃣ Final Agent Configuration
└── README.md                       # This file
```

---

## 🚀 Getting Started

Follow the **[Detailed Setup Guide](docs/HOOTSUITE_SETUP_GUIDE.md)** for step-by-step instructions.

### Deployment Workflow

![Setup Flow](docs/setup_flow_diagram.svg)

1.  **Initialize Environment** (Files 1-2): Create database, schema, and tables.
2.  **Hydrate Data** (File 3): Generate 200,000+ rows of synthetic production-grade data.
3.  **Deploy Views** (Files 4-5): Create analytical, feature, and semantic views.
4.  **Enable Search** (File 6): Index unstructured text data using Cortex Search.
5.  **Train Models** (Notebook): Train and register ML models using Snowpark.
6.  **Create ML Functions** (File 7): Expose ML models as SQL functions.
7.  **Deploy Automation** (Files 9-10): Create customer engagement and Streamlit app generation procedures.
8.  **Launch Agent** (File 8): Compile the final Intelligence Agent with all capabilities.

---

## 💡 Example Use Cases

Once deployed, the agent can answer complex business questions and take automated actions:

**Analytics & Insights:**
*   **"Which marketing campaigns are predicted to have High ROI?"** (ML + Semantic View)
*   **"Show me the churn risk distribution for Retail customers."** (Semantic View)
*   **"Find support tickets about 'login issues' and summarize the resolutions."** (Cortex Search)
*   **"What is the average engagement rate for video posts on Instagram?"** (Semantic View)

**Automated Actions:**
*   **"Trigger engagement for customer CUST000289 with churn prevention using variant A"** (Customer Success Automation)
*   Automatically sends personalized re-engagement emails
*   Schedules account health reviews for high-risk customers
*   Logs all actions for A/B testing analysis

**Interactive App Creation:**
*   **"Create a Streamlit app to analyze engagement rates by platform"** (Streamlit Generator)
*   Automatically generates and deploys interactive Streamlit app
*   Returns clickable link to launch the app immediately
*   Includes charts, filtering, statistics, and data export

---

**Built for Hootsuite | Powered by Snowflake Cortex**
