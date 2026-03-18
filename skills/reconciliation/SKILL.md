---
name: reconciliation
description: Run supplier, bank, or VAT reconciliation. Use when asked to reconcile accounts, check statements against Sage, or verify VAT returns.
---

Run reconciliation across supplier accounts, bank accounts, and VAT returns.

## Environment
```bash
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate
export SAGE_PROJECT_ROOT="$(pwd)" PYTHONPATH="$(pwd):$PYTHONPATH"
```

## Supplier Reconciliation

### Herholdts
```bash
python3 scripts/recon_herholdts.py
```

### ARB Electrical
```bash
python3 scripts/recon_arb.py
```

### Generic (via API)
```bash
curl -s http://localhost:49000/api/reconciliation/ | python3 -m json.tool
```

## Bank Reconciliation
Match bank statement transactions against Sage bank account entries:
```bash
curl -s http://localhost:49000/api/reconciliation/bank/ | python3 -m json.tool
```

## VAT Reconciliation
Cross-check VAT:
1. GL detail VAT export (from Sage) vs supplier invoices (input VAT)
2. Bank statements vs VAT payments
3. Verify 15% VAT rate applied correctly

⚠️ Known issue (JAC-113): float/Decimal type error in VAT recon. If it fires, check monetary calculations use `Decimal` not `float`.

## Key Files
- `backend/core/reconciliation/` — reconciliation engine and strategies
- `scripts/recon_herholdts.py` — Herholdts-specific
- `scripts/recon_arb.py` — ARB-specific
- `archive/vat-returns/` — archived VAT returns
- `archive/bank-statements/` — archived bank statements
- `processing/supplier-statements/` — parsed supplier statements

## Data Sources
- **Sage exports** (in `archive/sage-exports/`): supplier transactions, customer ledger, GL detail VAT, bank transactions, trial balance
- **Bank statements** (in `processing/bank-statements/`): Capitec, FNB, Nedbank PDFs
- **Supplier statements** (in `processing/supplier-statements/`): Herholdts, ARB parsed JSONs
- **Pipeline DB** (`backend/data/unified_processing.db`): all ingested and classified items
