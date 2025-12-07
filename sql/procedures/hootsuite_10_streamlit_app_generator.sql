-- ============================================================================
-- Hootsuite Streamlit App Generator Procedure
-- ============================================================================
-- Purpose: Generate complete Streamlit app code from chart queries
-- Returns: Full app code + deployment instructions
-- Note: Snowflake requires manual Streamlit app creation via UI
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
RETURNS TEXT
LANGUAGE SQL
AS
$$
DECLARE
    app_name VARCHAR;
    streamlit_code TEXT;
    result TEXT;
BEGIN
    -- Clean app name for Snowflake object naming
    app_name := REGEXP_REPLACE(LOWER(:CHART_TITLE), '[^a-z0-9_]', '_');
    app_name := 'HOOTSUITE_' || SUBSTR(app_name, 1, 40);
    
    -- Escape SQL for embedding
    LET sql_escaped TEXT := REPLACE(:CHART_SQL, '''', '''''');
    
    -- Generate complete Streamlit app code
    streamlit_code := 'import streamlit as st
import pandas as pd
import plotly.express as px
from snowflake.snowpark.context import get_active_session

# Page setup
st.set_page_config(page_title="' || :CHART_TITLE || '", layout="wide")
session = get_active_session()

# Header
st.title("📊 ' || :CHART_TITLE || '")
st.markdown("*Interactive analysis powered by Snowflake*")
st.markdown("---")

# Load data with caching
@st.cache_data
def load_data():
    query = """' || sql_escaped || '"""
    return session.sql(query).to_pandas()

try:
    df = load_data()
    if df.empty:
        st.warning("⚠️ No data returned from query")
        st.stop()
except Exception as e:
    st.error(f"Error: {e}")
    st.stop()

# Identify column types
numeric_cols = df.select_dtypes(include=["number"]).columns.tolist()
categorical_cols = df.select_dtypes(include=["object", "category"]).columns.tolist()

# Display data table
st.subheader("📋 Data Table")
st.dataframe(df, use_container_width=True, height=400)
st.caption(f"Total Records: {len(df):,} | Columns: {len(df.columns)}")

# Visualizations
if numeric_cols:
    st.subheader("📈 Visualizations")
    
    if categorical_cols:
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown("**Bar Chart**")
            fig_bar = px.bar(df, x=categorical_cols[0], y=numeric_cols[0], 
                           title=f"{numeric_cols[0]} by {categorical_cols[0]}")
            st.plotly_chart(fig_bar, use_container_width=True)
        
        with col2:
            if len(numeric_cols) >= 2:
                st.markdown("**Scatter Plot**")
                fig_scatter = px.scatter(df, x=numeric_cols[0], y=numeric_cols[1],
                                       title=f"{numeric_cols[1]} vs {numeric_cols[0]}")
                st.plotly_chart(fig_scatter, use_container_width=True)
            else:
                st.markdown("**Distribution**")
                fig_hist = px.histogram(df, x=numeric_cols[0], 
                                      title=f"Distribution of {numeric_cols[0]}")
                st.plotly_chart(fig_hist, use_container_width=True)
    else:
        # No categorical columns - show histograms
        for col in numeric_cols[:3]:
            fig = px.histogram(df, x=col, title=f"Distribution of {col}")
            st.plotly_chart(fig, use_container_width=True)

# Statistical analysis
if "' || :ANALYSIS_TYPE || '" == "statistical" and len(numeric_cols) > 0:
    st.subheader("📊 Statistical Analysis")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("**Descriptive Statistics**")
        st.dataframe(df[numeric_cols].describe(), use_container_width=True)
    
    with col2:
        if len(numeric_cols) > 1:
            st.markdown("**Correlation Matrix**")
            corr = df[numeric_cols].corr()
            fig = px.imshow(corr, text_auto=True, 
                          color_continuous_scale="RdBu_r",
                          title="Feature Correlations")
            st.plotly_chart(fig, use_container_width=True)

# Key metrics
if numeric_cols:
    st.subheader("🎯 Key Metrics")
    cols = st.columns(min(4, len(numeric_cols)))
    for idx, col in enumerate(numeric_cols[:4]):
        with cols[idx]:
            st.metric(label=col, 
                     value=f"{df[col].sum():,.0f}",
                     delta=f"Avg: {df[col].mean():,.2f}")

# Export functionality
st.subheader("💾 Export Data")
col1, col2 = st.columns(2)

with col1:
    csv = df.to_csv(index=False)
    st.download_button(
        label="📥 Download CSV",
        data=csv,
        file_name="' || app_name || '.csv",
        mime="text/csv",
        use_container_width=True
    )

with col2:
    json_data = df.to_json(orient="records", indent=2)
    st.download_button(
        label="📥 Download JSON",
        data=json_data,
        file_name="' || app_name || '.json",
        mime="application/json",
        use_container_width=True
    )

# Footer
st.markdown("---")
st.caption("🤖 Auto-generated by Hootsuite Intelligence Agent | Powered by Snowflake Cortex")
';

    -- Build the response with instructions
    result := '✅ STREAMLIT APP CODE GENERATED

**App Name:** ' || app_name || '
**Analysis Type:** ' || :ANALYSIS_TYPE || '

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 DEPLOYMENT INSTRUCTIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Step 1:** Go to Snowsight → Projects → Streamlit

**Step 2:** Click "+ Streamlit App"

**Step 3:** Configure:
   - Name: ' || app_name || '
   - Location: HOOTSUITE_INTELLIGENCE.ANALYTICS
   - Warehouse: HOOTSUITE_WH

**Step 4:** Copy the code below into the app editor

**Step 5:** Click "Run" to launch your app

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 STREAMLIT APP CODE (Copy everything below)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

' || streamlit_code || '

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✨ APP FEATURES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Interactive data table (' || LENGTH(:CHART_SQL) || ' char query)
✓ Dynamic visualizations (bar, scatter, histogram)
' || (CASE WHEN :ANALYSIS_TYPE = 'statistical' THEN '✓ Statistical analysis (correlations, descriptive stats)' ELSE '✓ Exploratory data analysis' END) || '
✓ Key metrics dashboard
✓ Data export (CSV, JSON)
✓ Real-time Snowflake connection

**Your app is ready to deploy!** Follow the instructions above.';

    RETURN result;

EXCEPTION
    WHEN OTHER THEN
        RETURN '❌ Error generating app: ' || :SQLCODE || ' - ' || :SQLERRM;
END;
$$;

-- ============================================================================
-- Grant Permissions
-- ============================================================================
GRANT USAGE ON PROCEDURE HOOTSUITE_INTELLIGENCE.ANALYTICS.GENERATE_STREAMLIT_FROM_CHART(TEXT, TEXT, TEXT) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE HOOTSUITE_INTELLIGENCE.ANALYTICS.GENERATE_STREAMLIT_FROM_CHART(TEXT, TEXT, TEXT) TO ROLE PUBLIC;

-- ============================================================================
-- Test Procedure (Commented out)
-- ============================================================================
-- CALL GENERATE_STREAMLIT_FROM_CHART(
--     'SELECT platform, COUNT(*) as post_count, AVG(follower_count) as avg_followers FROM HOOTSUITE_INTELLIGENCE.RAW.SOCIAL_ACCOUNTS GROUP BY platform',
--     'Platform Analysis Dashboard',
--     'exploratory'
-- );

SELECT 'Streamlit App Generator Procedure created successfully' AS STATUS;
