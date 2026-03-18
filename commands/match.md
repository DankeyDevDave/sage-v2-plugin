---
description: Run 3-way matching (PO ↔ Invoice ↔ Payment) for a supplier
---

# 3-Way Matching

Run PO ↔ Invoice ↔ Payment matching for supplier reconciliation.

**Arguments:** `$ARGUMENTS` — supplier name (required)

## Run Matching

```bash
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate
export SAGE_PROJECT_ROOT="$(pwd)" PYTHONPATH="$(pwd):$PYTHONPATH"

# Via API
curl -s "http://localhost:49000/api/v1/matching/supplier/$(python3 -c 'import urllib.parse; print(urllib.parse.quote("$ARGUMENTS"))')" | python3 -m json.tool

# Or check available endpoints
curl -s http://localhost:49000/api/v1/matching/ | python3 -m json.tool
```

## Key Files
- `backend/core/matching/three_way_engine.py` — main matching engine
- `backend/core/matching/models.py` — Invoice, Payment, POLine dataclasses
- `backend/core/matching/strategies/` — matching strategies
- `backend/core/matching/tolerance.py` — amount tolerance rules

## Matching Rules
- Matches use configurable tolerance (default: R0.05 or 0.1%)
- PO number cross-referenced between invoice description and Sage PO
- Payment references matched to invoice numbers
- Date proximity checks (payment within 30 days of invoice)

## After Matching
Review results and flag discrepancies. Update Linear issues for any unmatched items.
