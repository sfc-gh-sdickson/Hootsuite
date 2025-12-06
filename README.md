# Hootsuite Intelligence Agent Solution

**An AI-Powered Analytics Solution for Social Media Management**

This solution provides a complete Snowflake Intelligence Agent implementation for **Hootsuite**, enabling natural language queries over customer, campaign, and social data with ML-powered insights.

## Repository Structure

```
.
├── docs/
│   ├── HOOTSUITE_SETUP_GUIDE.md    # Step-by-step installation instructions
│   ├── PROJECT_SUMMARY.md          # High-level overview of capabilities
│   └── hootsuite_questions.md      # Sample questions for testing
├── notebooks/
│   ├── hootsuite_ml_models.ipynb   # Snowpark ML training notebook
│   └── environment.yml             # Conda environment dependencies
├── sql/
│   ├── agent/                      # Agent DDL and configuration
│   ├── data/                       # Synthetic data generation
│   ├── ml/                         # SQL wrappers for ML models
│   ├── search/                     # Cortex Search Service setup
│   ├── setup/                      # Database and Table DDL
│   └── views/                      # Semantic, Analytical, and Feature views
└── README.md                       # This file
```

## Quick Start

1.  **Setup Database**: Run `sql/setup/` scripts to create the schema and tables.
2.  **Generate Data**: Run `sql/data/hootsuite_03_generate_synthetic_data.sql`.
3.  **Deploy Analytics**: Run `sql/views/` scripts to create Semantic Views.
4.  **Train Models**: Upload and run the notebook in `notebooks/`.
5.  **Configure Agent**: Run `sql/agent/hootsuite_08_intelligence_agent.sql`.

For detailed instructions, please refer to [docs/HOOTSUITE_SETUP_GUIDE.md](docs/HOOTSUITE_SETUP_GUIDE.md).

## Features

*   **3 Semantic Views** for structured data analysis.
*   **3 Cortex Search Services** for unstructured document retrieval.
*   **3 Machine Learning Models** for predictive analytics.
*   **Synthetic Data Generator** for realistic testing.

