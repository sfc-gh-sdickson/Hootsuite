## Failure Category 18: Snowflake Notebook Package Conflicts
  18|
  19|### 18.1 "One or more package conflicts were detected"
  20|
  21|**What I did wrong:**
  22|- Tried to manually pin "compatible" versions (e.g., `scikit-learn=1.3.0`, `pandas=2.1.4`) based on external documentation or search results.
  23|- The specific combination of pinned versions conflicted with the underlying Snowflake runtime environment or other implicit dependencies.
  24|- This caused repeated failures where the UDF creation failed due to "Packages not found" or "Package conflicts".
  25|
  26|**What I should have done:**
  27|- **TRUST THE SOLVER:** For Snowflake Notebooks, specify *only* the package names (e.g., `- scikit-learn`, `- pandas`) without version numbers in `environment.yml`.
  28|- Let the Snowflake server-side Conda environment resolve the best compatible versions for the current runtime.
  29|- Only pin versions if absolutely critical for code behavior (and verified to exist in that specific runtime).
  30|
  31|**Rule:** In `environment.yml` for Snowflake Notebooks, list package names WITHOUT version numbers to avoid conflicts.
  32|
  33|---