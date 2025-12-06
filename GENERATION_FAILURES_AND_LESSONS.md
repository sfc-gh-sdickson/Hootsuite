## Failure Category 17: Snowpark ML Case Sensitivity
  17|
  18|### 17.1 KeyError in Feature Engineering Pipelines
  19|
  20|**What I did wrong:**
  21|- Defined Snowpark ML pipelines (OrdinalEncoder, OneHotEncoder) using mixed-case or assumed-lowercase column names (e.g., `'Objective'`).
  22|- Failed to recall that Snowflake unquoted identifiers are implicitly **UPPERCASE**.
  23|- This caused `KeyError: 'OBJECTIVE'` during the `fit()` phase because the dataframe from Snowflake contained `OBJECTIVE`, but the encoder was looking for something else (or vice-versa if I passed lowercase).
  24|
  25|**What I should have done:**
  26|- Always treat Snowflake column names as **UPPERCASE** in Python lists unless they were explicitly created with double quotes.
  27|- Verify the schema of the input DataFrame (`df.columns`) before defining the pipeline.
  28|- Use uppercase string literals for all `input_cols` and `label_cols` parameters in Snowpark ML estimators.
  29|
  30|**Rule:** When defining Snowpark ML pipelines on Snowflake data, ALL column name references must be UPPERCASE (e.g., `input_cols=["CATEGORY"]`, not `["Category"]`).
  31|
  32|---