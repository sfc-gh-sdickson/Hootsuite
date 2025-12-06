## Failure Category 15: Agent Tool Type Validation Failure
  15|
  16|### 15.1 "Tool type function is not valid" Persistent Error
  17|
  18|**What I did wrong:**
  19|- Received error `Tool type function is not valid` from Snowflake Cortex Agent.
  20|- Tried guessing alternate types: `cortex_tool`, `tool`, `cortex_function`.
  21|- Failed to trust the working example initially, then failed to realize the environment might be the issue when the code matched exactly.
  22|
  23|**What I should have done:**
  24|- If code matches a working example exactly but fails with a validation error, the issue is likely:
  25|  1. A very subtle typo/indentation issue.
  26|  2. An environment version mismatch (feature not enabled in the current account).
  27|  3. A state issue (cached definition).
  28|- Do NOT frantically guess random string values (`cortex_tool`).
  29|- Do strict char-by-char comparison with `diff`.
  30|
  31|**Rule:** For Snowflake Agent DDL, the `tool_spec` type for a user-defined function is typically `"function"`. If this fails, verify the Snowflake account version and feature enablement status before changing code.
  32|
  33|---