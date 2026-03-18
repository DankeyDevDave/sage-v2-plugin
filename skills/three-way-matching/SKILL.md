---
name: three-way-matching
description: Run PO ↔ Invoice ↔ Payment 3-way matching for supplier reconciliation. Use when asked to match invoices, run 3-way matching, or reconcile supplier accounts.
---

Run 3-way matching (Purchase Order ↔ Supplier Invoice ↔ Payment) for supplier reconciliation.

## Environment
```bash
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate
export SAGE_PROJECT_ROOT="$(pwd)" PYTHONPATH="$(pwd):$PYTHONPATH"
```

## Running Matching

### Via API
```bash
# List available matching endpoints
curl -s http://localhost:49000/api/v1/matching/ | python3 -m json.tool

# Run matching for a specific supplier
curl -s "http://localhost:49000/api/v1/matching/supplier/$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))' 'SUPPLIER_NAME')" | python3 -m json.tool
```

### Direct Engine
```python
from backend.core.matching.three_way_engine import ThreeWayMatchingEngine
# Engine matches PO lines to invoice lines to payment records
```

## Matching Logic
- **PO ↔ Invoice**: Match by PO number in invoice description/reference
- **Invoice ↔ Payment**: Match by invoice number in payment reference
- **Tolerance**: R0.05 or 0.1% configurable (see `backend/core/matching/tolerance.py`)
- **Date window**: Payments within 30 days of invoice date

## Key Files
- `backend/core/matching/three_way_engine.py` — main engine
- `backend/core/matching/models.py` — `Invoice`, `Payment`, `POLine` dataclasses
- `backend/core/matching/strategies/` — matching strategies
- `backend/core/matching/reporter.py` — discrepancy reporting
- `backend/core/matching/audit.py` — audit trail

## Discrepancy Types
- **Amount mismatch**: Invoice total ≠ payment amount (outside tolerance)
- **Missing PO**: Invoice has no matching PO in Sage
- **Partial payment**: Payment amount < invoice amount
- **Overpayment**: Payment amount > invoice amount
- **Unmatched**: No cross-reference found

## Output
Present matching results as a table with columns: Supplier, Invoice#, PO#, Amount, Payment, Status (matched/unmatched/discrepancy).
