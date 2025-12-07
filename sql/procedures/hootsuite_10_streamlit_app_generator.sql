-- ============================================================================
-- Hootsuite Streamlit App Generator Procedure
-- ============================================================================
-- Purpose: Automatically generate, deploy, and return clickable link to Streamlit app
-- Uses CREATE STREAMLIT AS $code$ with single $ delimiter
-- ============================================================================

USE DATABASE HOOTSUITE_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE HOOTSUITE_WH;

-- ============================================================================
-- Streamlit App Generator Procedure  
-- ============================================================================
CREATE OR REPLACE PROCEDURE GENERATE_STREAMLIT_FROM_CHART(
    CHART_SQL TEXT,
    CHART_TITLE TEXT,
    ANALYSIS_TYPE TEXT
)
RETURNS VARIANT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'main' 
AS $$
import json

def main(session, CHART_SQL, CHART_TITLE, ANALYSIS_TYPE):
    # Generate the complete Streamlit app code
    streamlit_code = f'''import streamlit as st
import pandas as pd
import plotly.express as px
from snowflake.snowpark.context import get_active_session

session = get_active_session()
st.set_page_config(page_title="Generated Analysis App", layout="wide")
st.title("🚀 Auto-Generated Data Analysis App")

@st.cache_data
def load_data():
    return session.sql("""{CHART_SQL}""").to_pandas()

df = load_data()

col1, col2 = st.columns(2)
with col1:
    st.subheader("Raw Data")
    st.dataframe(df, use_container_width=True)
    
with col2:
    st.subheader("Quick Stats") 
    numeric_cols = df.select_dtypes(include=['number']).columns
    if len(numeric_cols) > 0:
        st.metric("Total Rows", len(df))
        st.metric("Avg " + numeric_cols[0], round(df[numeric_cols[0]].mean(), 2))

# Auto-generate charts based on data types
categorical_cols = df.select_dtypes(include=['object']).columns.tolist()
numeric_cols = df.select_dtypes(include=['number']).columns.tolist()

if len(categorical_cols) > 0 and len(numeric_cols) > 0:
    st.subheader("📊 Auto-Generated Visualizations")
    
    tab1, tab2 = st.tabs(["Bar Chart", "Distribution"])
    
    with tab1:
        fig_bar = px.bar(df, x=categorical_cols[0], y=numeric_cols[0])
        st.plotly_chart(fig_bar, use_container_width=True)
    
    with tab2:
        fig_hist = px.histogram(df, x=numeric_cols[0])
        st.plotly_chart(fig_hist, use_container_width=True)

# Interactive filtering
st.subheader("🔍 Interactive Filtering")
for col in categorical_cols:
    unique_vals = df[col].unique()
    if len(unique_vals) <= 10:
        selected = st.multiselect(f"Filter {{col}}", unique_vals, default=unique_vals)
        if selected:
            df = df[df[col].isin(selected)]
            st.dataframe(df, use_container_width=True)

if st.button("🔄 Refresh Data"):
    st.cache_data.clear()
    st.rerun()
'''
    
    # Create the Streamlit app directly using the new syntax
    clean_app_name = CHART_TITLE.replace(' ', '_').replace('-', '_').upper()
    clean_app_name = ''.join(c if c.isalnum() or c == '_' else '' for c in clean_app_name)
    clean_app_name = f"HOOTSUITE_{clean_app_name}"[:50]
    
    try:
        # Use the new CREATE STREAMLIT without stage requirement
        create_sql = f"""
        CREATE OR REPLACE STREAMLIT HOOTSUITE_INTELLIGENCE.ANALYTICS.{clean_app_name}
        MAIN_FILE = 'app.py'  
        QUERY_WAREHOUSE = 'HOOTSUITE_WH'
        TITLE = '{CHART_TITLE} - Auto Generated'
        AS
        ${streamlit_code}$
        """
        
        session.sql(create_sql).collect()
        
        # Get the app URL
        account_info = session.sql("SELECT CURRENT_ACCOUNT() as acct, CURRENT_REGION() as reg").collect()[0]
        account = account_info['ACCT']
        region = account_info['REG']
        app_url = f"https://app.snowflake.com/{region}/{account}/#/streamlit-apps/HOOTSUITE_INTELLIGENCE.ANALYTICS.{clean_app_name}"
        
        return {
            "status": "success",
            "app_name": clean_app_name,
            "app_url": app_url,
            "message": f"✅ Streamlit app '{clean_app_name}' deployed successfully!",
            "button_text": f"🚀 Launch {CHART_TITLE}",
            "button_url": app_url
        }
        
    except Exception as e:
        return {
            "status": "error", 
            "message": f"❌ Deployment failed: {str(e)}",
            "code": streamlit_code
        }
$$;

-- ============================================================================
-- Grant Permissions
-- ============================================================================
GRANT USAGE ON PROCEDURE HOOTSUITE_INTELLIGENCE.ANALYTICS.GENERATE_STREAMLIT_FROM_CHART(TEXT, TEXT, TEXT) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE HOOTSUITE_INTELLIGENCE.ANALYTICS.GENERATE_STREAMLIT_FROM_CHART(TEXT, TEXT, TEXT) TO ROLE PUBLIC;
GRANT CREATE STREAMLIT ON SCHEMA HOOTSUITE_INTELLIGENCE.ANALYTICS TO ROLE SYSADMIN;
GRANT CREATE STREAMLIT ON SCHEMA HOOTSUITE_INTELLIGENCE.ANALYTICS TO ROLE PUBLIC;

-- ============================================================================
-- Test Procedure (Commented out)
-- ============================================================================
-- CALL GENERATE_STREAMLIT_FROM_CHART(
--     'SELECT platform, COUNT(*) as post_count FROM HOOTSUITE_INTELLIGENCE.RAW.SOCIAL_ACCOUNTS GROUP BY platform',
--     'Platform Analysis Dashboard',
--     'exploratory'
-- );

SELECT 'Streamlit App Generator Procedure created successfully' AS STATUS;
