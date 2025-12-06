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
| **Orchestration** | **Cortex Agents** | A unified agent that intelligently routes queries to the correct tool or model. |

---

## 📂 Repository Structure

```text
.
├── docs/
│   ├── HOOTSUITE_SETUP_GUIDE.md    # 📚 DETAILED SETUP INSTRUCTIONS
│   ├── PROJECT_SUMMARY.md          # High-level executive summary
│   ├── hootsuite_questions.md      # Test bank of 15 sample questions
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
│   └── agent/                      # 6️⃣ Final Agent Configuration
└── README.md                       # This file
```

---

## 🚀 Getting Started

Follow the **[Detailed Setup Guide](docs/HOOTSUITE_SETUP_GUIDE.md)** for step-by-step instructions.

### Deployment Workflow

![Setup Flow](docs/setup_flow_diagram.svg)

1.  **Initialize Environment**: Create database, schema, and tables.
2.  **Hydrate Data**: Generate 200,000+ rows of synthetic production-grade data.
3.  **Deploy Semantic Layer**: Create views optimized for LLM understanding.
4.  **Enable Search**: Index unstructured text data using Cortex Search.
5.  **Train Models**: Train and register ML models using Snowpark.
6.  **Launch Agent**: Compile the final Intelligence Agent.

---

## 💡 Example Use Cases

Once deployed, the agent can answer complex business questions:

*   **"Which marketing campaigns are predicted to have High ROI?"** (ML + Semantic View)
*   **"Show me the churn risk distribution for Retail customers."** (Semantic View)
*   **"Find support tickets about 'login issues' and summarize the resolutions."** (Cortex Search)
*   **"What is the average engagement rate for video posts on Instagram?"** (Semantic View)

---

**Built for Hootsuite | Powered by Snowflake Cortex**
