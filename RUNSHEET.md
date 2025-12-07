# Hootsuite Intelligence Agent - Complete Setup Runsheet

**Status:** FIXED - All code issues resolved, ready for execution
**Commits:** 5dcbb89 (latest)

---

## Run These Files In This Exact Order:

### Step 1: Update Feature Views (REQUIRED)
**File:** `sql/views/hootsuite_04_create_views.sql`  
**Why:** Fixed numeric column types to FLOAT for consistent model signatures  
**Expected:** "Analytical and Feature Views Created Successfully"

### Step 2: Retrain All ML Models (REQUIRED)
**File:** `notebooks/hootsuite_ml_models.ipynb`  
**Action:** Run ALL cells (1-28)  
**Why:** Retrains models on current data with correct column types  
**Expected:** 
- "✅ Deleted existing CHURN_RISK_PREDICTOR"
- "✅ Deleted existing CAMPAIGN_ROI_PREDICTOR"  
- "✅ Deleted existing TICKET_PRIORITY_CLASSIFIER"
- All 3 models registered successfully

### Step 3: Create ML Functions
**File:** `sql/ml/hootsuite_07_ml_model_functions.sql`  
**Why:** Creates SQL functions that call the ML models  
**Expected:** "✅ All ML functions created and tested successfully!"

### Step 4: Verify ML Functions Work
**Run this SQL:**
```sql
SELECT PREDICT_CHURN_RISK(NULL) as result;
```
**Expected:** Something like "Total Customers: 100, Low Risk: 45, Medium Risk: 30, High Risk: 25"  
**If it fails:** Stop and report the error

### Step 5: Create Agent
**File:** `sql/agent/hootsuite_08_intelligence_agent.sql`  
**Why:** Creates the intelligence agent with simple, testable questions  
**Expected:** "Hootsuite Intelligence Agent created successfully"

---

## Test The Agent:

### Open the agent in Snowflake UI:
- Navigate to: Projects → AI & ML → Agents → HOOTSUITE_INTELLIGENCE_AGENT
- Or: Data > Databases > HOOTSUITE_INTELLIGENCE > ANALYTICS > Agents

### Test These Questions (Should All Return Data):

1. **"How many active customers do we have?"**
   - Expected: A count number

2. **"What is the average campaign budget?"**
   - Expected: A dollar amount

3. **"How many support tickets are currently open?"**
   - Expected: A count number

4. **"Which customers have the highest churn risk?"**
   - Expected: List of customer names with high churn scores

5. **"How many posts were published on Instagram this month?"**
   - Expected: A count number (should be > 0)

6. **"What is the average engagement rate by platform?"**
   - Expected: Table with platforms and their avg engagement rates

---

## If ANY Question Returns "No Data" or 0:

**STOP and report:**
1. The exact question that failed
2. The agent's response
3. Any SQL it generated

---

## What Was Fixed:

1. ✅ Semantic views - Added rich dimensions (churn_risk_band, follower_tier, etc.)
2. ✅ Agent questions - Simplified to basic queries like Origence
3. ✅ ML feature views - Cast all numeric columns to FLOAT for type consistency
4. ✅ Notebook - Added model deletion before registration to force retraining
5. ✅ Data generation - Has TRUNCATE to clear old data, uses last 90 days

---

## Files Changed (All Committed):
- sql/views/hootsuite_04_create_views.sql (feature views with FLOAT casting)
- sql/views/hootsuite_05_create_semantic_views.sql (rich dimensions)
- sql/agent/hootsuite_08_intelligence_agent.sql (simple questions)
- notebooks/hootsuite_ml_models.ipynb (model deletion + retraining)

**Latest Commit:** 5dcbb89

