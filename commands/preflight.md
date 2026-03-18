---
description: Run sage_v2 pipeline pre-flight check — validates API keys, data completeness, and generates adaptive plan
---

# /preflight

Run the sage_v2 pipeline pre-flight check to validate readiness.

## Usage
```
/preflight              # Check and report
/preflight --fix        # Auto-fix issues and report
```

## What It Does
1. Validates all API keys (Gemini, Zhipu, Sage) with real API calls
2. Checks pipeline state (failed items, stuck items)
3. Maps data completeness (bank statements, Sage exports, month coverage)
4. Generates a capability map (what the system CAN do)
5. Creates an adaptive plan (what phases are possible vs blocked)
6. With `--fix`: auto-resets failed items, disables broken LLM judge

## Environment
```bash
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate
```

## Then Run
```bash
python3 scripts/preflight.py $ARGS
```

Where `$ARGS` is `--fix` if the user requested auto-fix.

## After Running
Present the results to the user:
- Summarize blockers (if any)
- Summarize warnings
- Show capability map
- Show adaptive plan
- Recommend next steps based on results

## Exit Codes
- 0 = All clear
- 1 = Warnings (can proceed)
- 2 = Blockers (need human intervention)
