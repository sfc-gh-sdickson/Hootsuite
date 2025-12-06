## Failure Category 19: Intelligence Agent Sample Questions Without Validation

### 19.1 "Agent cannot answer its own sample questions"

**What I did wrong:**
- Generated sample questions for the Intelligence Agent that technically had supporting data, but the agent couldn't actually answer them.
- Wrote vague orchestration instructions like "for social performance metrics use SV_SOCIAL_PERFORMANCE" without specifying available dimensions/metrics.
- Created weak sample answers like "I'll filter by platform and date" instead of explicit guidance: "I'll use SocialPerformanceAnalyst to count posts where profiles.network equals 'INSTAGRAM' and posts.published_date is in the last month."
- **CRITICAL FAILURE: Did not TEST any of the sample questions against the actual agent before delivery.**
- This violated the explicit instruction: "All questions should have valid data that provides a valid response. Only generate questions that can be answered by the synthetic data that you generate."
- The user had to discover that the agent couldn't answer basic questions like "Count Instagram posts from last month" even though all the data existed.

**What I should have done:**
- **MANDATORY: TEST EVERY SAMPLE QUESTION** - After creating the agent, test each sample question to verify the agent can actually answer it correctly.
- Write explicit orchestration instructions that detail which dimensions/metrics are available in each tool (e.g., "SocialPerformanceAnalyst includes posts.published_date for time filtering and profiles.network for platform filtering with values: FACEBOOK, TWITTER, LINKEDIN, INSTAGRAM, TIKTOK").
- Create sample answers that explicitly show tool names, dimension names, and example values the agent should use.
- Iterate: If a sample question fails, either fix the instructions OR remove the question - never ship untested questions.
- Think of sample questions as TRAINING DATA for the agent - they must be complete, correct, and validated.

**Rule:** 
1. NEVER create sample questions for an Intelligence Agent without testing them against the actual agent first.
2. Sample answers must be explicit: specify the exact tool name, dimension/metric names, and example filter values.
3. Orchestration instructions must enumerate available dimensions/metrics for each tool, not just tool names.
4. If you cannot test the agent, state this limitation explicitly and recommend the user test all sample questions before production use.
5. Having data ≠ Agent can use data. Instructions must bridge that gap.

**Impact:** Wasted user time debugging why the agent failed on questions that should have worked. Eroded trust.

---

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