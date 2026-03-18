---
description: Ingest files into the pipeline — bank statements, supplier invoices, Sage exports, JSON invoices
---

# Ingest Files into Pipeline

Ingest the specified files into the sage_v2 processing pipeline.

**Arguments:** `$ARGUMENTS` — file path, directory, or glob pattern

## How to Ingest

### Bank Statements (PDF)
```bash
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate
export SAGE_PROJECT_ROOT="$(pwd)" PYTHONPATH="$(pwd):$PYTHONPATH"

# Copy to watch-folder and let daemon pick it up
cp "$FILE" watch-folder/

# Or use the batch import script
python3 scripts/import_bank_statements.py --dir "$DIR" --recursive
```

### Supplier Invoices (Image or PDF)
```bash
# Copy to watch-folder/supplier-invoices/<SupplierName>/
cp "$FILE" "watch-folder/supplier-invoices/<SupplierName>/"

# Or drop JSON directly (pre-extracted invoices)
python3 scripts/ingest_invoice_json.py "$FILE" --supplier "<SupplierName>"
```

### Sage Exports (CSV)
```bash
# Copy to watch-folder root or processing/sage-exports/
cp "$FILE" watch-folder/
```

### Dry Run First
Always try with `--dry-run` if available to preview what will be ingested:
```bash
python3 scripts/ingest_invoice_json.py "$FILE" --dry-run
```

## Verification
After ingestion, verify the item was created:
```bash
python3 -c "
import sqlite3
conn = sqlite3.connect('backend/data/unified_processing.db')
conn.row_factory = sqlite3.Row
rows = conn.execute('SELECT id, subject, category, status, created_date FROM processing_items ORDER BY created_date DESC LIMIT 5').fetchall()
for r in rows:
    print(f'{r[\"status\"]:12s} {r[\"category\"]:30s} {r[\"subject\"][:50]}')
conn.close()
"
```

## Constraints
- All prices must be **exclusive of VAT** (Sage adds 15% automatically)
- Supplier names must be singular (no combined names like "Dynamics / Express")
- JSON invoices must match `InvoiceMetadata` schema (ISO dates YYYY-MM-DD)
