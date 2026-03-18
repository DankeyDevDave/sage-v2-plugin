---
name: document-ingestion
description: Ingest documents into the sage_v2 pipeline — bank statements, supplier invoices, Sage exports, JSON invoices. Use when asked to ingest, import, or process documents.
---

Ingest documents into the sage_v2 processing pipeline.

## Environment
```bash
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate
export SAGE_PROJECT_ROOT="$(pwd)" PYTHONPATH="$(pwd):$PYTHONPATH"
```

## Ingestion Methods

### Bank Statements (PDF)
```bash
# Copy to watch-folder — daemon auto-processes
cp FILE.pdf watch-folder/

# Or batch import
python3 scripts/import_bank_statements.py --dir DIR/ --recursive
```

### Supplier Invoices (Image/PDF)
```bash
# Copy to supplier-specific subfolder
cp FILE.jpg "watch-folder/supplier-invoices/<SupplierName>/"
```

### Pre-Extracted Invoice JSON
```bash
# Convert and ingest
python3 scripts/ingest_invoice_json.py FILE.json --supplier "<SupplierName>"

# Dry run first
python3 scripts/ingest_invoice_json.py FILE.json --dry-run
```

### Sage Exports (CSV)
```bash
cp EXPORT.csv watch-folder/
```

## Critical Constraints
- **All prices exclusive of VAT** — Sage adds 15% automatically. Inclusive prices cause doubled VAT.
- **Supplier names singular** — no combined names (e.g., use "ACDC Express" not "Dynamics / Express")
- **Invoice dates ISO format** — YYYY-MM-DD
- **JSON schema** must match `InvoiceMetadata` dataclass: `total_amount` (incl VAT), `subtotal` (excl VAT), `line_items` with `line_total`/`tax_amount`

## Verification
After ingestion, check the item appeared:
```bash
python3 -c "
import sqlite3
conn = sqlite3.connect('backend/data/unified_processing.db')
conn.row_factory = sqlite3.Row
rows = conn.execute('SELECT id, subject, category, status FROM processing_items ORDER BY created_date DESC LIMIT 5').fetchall()
for r in rows: print(f'{r[\"status\"]:12s} {r[\"category\"]:30s} {r[\"subject\"][:50]}')
conn.close()
"
```
