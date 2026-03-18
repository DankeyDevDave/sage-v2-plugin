---
name: preflight
description: Pre-flight check for the sage_v2 pipeline. Validates API keys, data completeness, pipeline state, and generates an adaptive plan. ALWAYS run this before starting any pipeline work. Use when starting a pipeline run, debugging blockers, or planning a night shift.
---

# sage_v2 Pipeline Preflight

**Always run preflight BEFORE starting any pipeline work.** This tells you what the system can do, what's broken, and what data is missing — so you never hit blockers by surprise.

## Quick Start
```bash
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate
python3 scripts/preflight.py              # Check and report
python3 scripts/preflight.py --fix        # Auto-fix + report
python3 scripts/preflight.py --fix --json # Machine-readable for agents
```

## What It Checks

### Environment
- ✅ Virtual environment exists
- ✅ Database exists and accessible
- ✅ .env file configured

### API Keys (actually validates, not just checks existence)
- **Gemini** — makes a real API call to verify key works and model is available
- **Zhipu** — checks balance via billing API (detects "insufficient balance")
- **Sage** — checks key is set
- **LLM Judge** — checks if enabled and whether it can actually work

### Pipeline State
- Failed items (auto-fixable: reset to pending)
- Stuck processing items (auto-fixable: reset to pending)
- Total completed/pending counts

### Data Completeness
- Bank statement coverage per bank (Capitec, FNB, Nedbank, Standard Bank)
- Sage export types present (trial balance, supplier ledger, customer ledger, GL detail, bank txns)
- Months of Sage data coverage (flags if < 12 for full year)
- Files on disk not yet ingested

## Exit Codes
- `0` — All clear, ready to run
- `1` — Warnings (can proceed with limitations)
- `2` — Blockers (cannot proceed without human intervention)

## Auto-Fix (`--fix`)
When run with `--fix`, the script automatically:
1. Resets all failed items to `pending` (encrypted PDFs, errors, etc.)
2. Resets all stuck `processing` items to `pending`
3. Disables LLM judge if Zhipu has no balance

## Output Sections

### Capability Map
Shows what the system CAN do:
```
CAPABILITIES:
  ✅ vision_extraction     — Gemini vision works
  ❌ llm_judge            — Z.AI no balance / disabled
  ✅ pdf_decryption       — Pipeline handles encrypted PDFs
  ✅ bank_statement_parsing — Text + vision fallback
  ✅ invoice_parsing      — Vision extraction for scanned invoices
  ✅ sage_export_parsing  — CSV parsers ready
  ✅ three_way_matching   — Matching engine available
```

### Adaptive Plan
Generated based on capabilities and data gaps:
```
ADAPTIVE PLAN:
  Phase 1: Housekeeping ✅
  Phase 2: Decrypt & Parse Bank Statements ✅
  Phase 3: Run Daemon for Backlog ✅
  Phase 4: 3-Way Matching 🚫 BLOCKED (missing Sage exports)
  Phase 5: Reconciliation 🚫 BLOCKED (missing Sage data)
  Phase 6: Handover Pack ✅ (partial — flag gaps)
```

### Data Gaps
Lists what's missing with fix instructions:
```
DATA GAPS:
  ⚠️ No sage_data_customer_invoice exported from Sage
  ⚠️ No sage_data_bank_transactions exported from Sage
  ℹ️ 9 Capitec PDFs on disk but not yet ingested
```

## Integration with Night Shift

The night-shift operator runs preflight as Phase 0:
```bash
# Phase 0: Know what's possible
python3 scripts/preflight.py --fix --json > /tmp/preflight_result.json

# Read the result to adapt the plan
# If Phase 4/5 are blocked, skip to Phase 6 with partial data
# If Capitec statements need ingesting, add that to Phase 2
```

## Key: This Prevents Wasted Time

Without preflight, the agent discovers blockers by hitting them:
- Spends 2 hours trying to process encrypted PDFs → fails
- Spends 1 hour building Capitec vision parser → discovers API key invalid
- Starts reconciliation → discovers Sage exports missing
- Daemon crashes → no watchdog, 14 min of work lost

With preflight, the agent knows everything upfront in 10 seconds:
- "13 encrypted PDFs — pipeline now handles this, just reset them"
- "Gemini works, Z.AI no balance — vision yes, LLM judge no"
- "Phase 4/5 blocked — skip to partial handover pack"
- "Set up daemon watchdog before starting"
