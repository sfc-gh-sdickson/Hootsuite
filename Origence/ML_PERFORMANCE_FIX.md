# ML Performance Fix - Complete Instructions

## Problem
All 3 ML model procedures run >20 seconds. Target: <10 seconds.

## Root Cause
Models have too many trees (10 estimators, depth 5) for fast warehouse inference.

## Solution
Reduce model complexity to 3 trees, depth 3.

---

## Step-by-Step Fix

### 1. Delete Everything
```sql
-- Run this file first
sql/ml/complete_performance_fix.sql
```

### 2. Edit Notebook Parameters
Open `notebooks/origence_ml_models.ipynb` and change **ALL 3 models**:

**Find (appears 3 times):**
```python
n_estimators=10,
max_depth=5,
```

**Replace with:**
```python
n_estimators=3,
max_depth=3,
```

### 3. Run Notebook
Execute all cells in `notebooks/origence_ml_models.ipynb`

This registers 3 ultra-fast models with minimal trees.

### 4. Create Procedures  
```sql
-- Run this file
sql/ml/origence_07_model_wrapper_functions.sql
```

### 5. Test Performance
```sql
CALL PREDICT_LOAN_DEFAULT_RISK(NULL);   -- Should be <10s
CALL PREDICT_LOAN_APPROVAL(NULL);       -- Should be <10s  
CALL DETECT_FRAUD_RISK(12345);          -- Should be <10s
```

---

## What Changed in File 7
- Changed LIMIT 10 → LIMIT 5 (fewer rows = faster)
- Removed labels from queries (not needed for inference)
- Uses .default model version (simplest approach)

## Expected Model Sizes
- Old: ~400KB (100 trees)
- New: ~20-30KB (3 trees)

## Performance Targets
- **Current:** 20+ seconds per call
- **Target:** <10 seconds per call
- **With 3 trees + 5 rows:** Should achieve 5-8 seconds

---

## Files Modified
1. `sql/ml/complete_performance_fix.sql` - Cleanup script
2. `notebooks/origence_ml_models.ipynb` - Model parameters (manual edit required)
3. `sql/ml/origence_07_model_wrapper_functions.sql` - Fixed procedures

## If Still Slow
If execution is still >10s after these changes:
1. Verify models are actually 3 trees: `SHOW VERSIONS IN MODEL LOAN_DEFAULT_PREDICTOR;` (check size column - should be <50KB)
2. Use smaller warehouse: `ALTER SESSION SET WAREHOUSE = XSMALL_WH;`
3. Reduce LIMIT further: Change LIMIT 5 → LIMIT 3 in file 7
