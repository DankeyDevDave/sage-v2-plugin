---
description: Run supplier or bank reconciliation
---

# Reconciliation

Run reconciliation for suppliers or bank accounts.

**Arguments:** `$ARGUMENTS` — `supplier <name>` or `bank <account>` or `vat`

## Supplier Reconciliation
```bash
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate
export SAGE_PROJECT_ROOT="$(pwd)" PYTHONPATH="$(pwd):$PYTHONPATH"

# Herholdts
python3 scripts/recon_herholdts.py

# ARB
python3 scripts/recon_arb.py

# Generic — via API
curl -s "http://localhost:49000/api/reconciliation/" | python3 -m json.tool
```

## VAT Reconciliation
- Input: GL detail VAT export + bank statements + supplier invoices
- Watch for float/Decimal type errors (JAC-113)
- Verify VAT returns match Sage exports

## Bank Reconciliation
Match bank statement transactions against Sage bank account entries:
```bash
# Via API
curl -s "http://localhost:49000/api/reconciliation/bank/" | python3 -m json.tool
```

## Key Files
- `backend/core/reconciliation/` — reconciliation engine
- `scripts/recon_herholdts.py` — Herholdts-specific recon
- `scripts/recon_arb.py` — ARB-specific recon
- `archive/vat-returns/` — archived VAT returns for reference
