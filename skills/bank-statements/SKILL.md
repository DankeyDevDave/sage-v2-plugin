---
name: bank-statements
description: Process, decrypt, parse, and ingest South African bank statements. Covers Capitec, FNB, Nedbank, Standard Bank. Handles encrypted PDFs, custom fonts, and vision-based extraction. Use when ingesting bank statements, dealing with encrypted PDFs, or parsing bank statement formats.
---

# Bank Statement Processing for sage_v2

## Quick Reference

| Bank | Encrypted? | Password | Text Parser | Vision Fallback |
|---|---|---|---|---|
| Capitec | ✅ Yes | Account number (from filename) | `capitec_statement.py` | **Required** (custom fonts) |
| FNB | ❌ No | N/A | `fnb_statement.py` | No |
| Nedbank | ✅ Yes | Account number (from filename) | `nedbank_statement.py` | Available |
| Standard Bank | ✅ Yes | Account number (from filename) | `standardbank_statement.py` | Available |

## Known Account Numbers

```python
# backend/core/parsers/pdf_password.py — KNOWN_ACCOUNTS
"5064" → "1051435064"  # Capitec
"7417" → "10197877417"  # Standard Bank
"3624" → "63012703624"  # FNB (usually not encrypted)
"5396" → "1255485396"  # Nedbank
```

## Processing Pipeline

### Daemon Path (WORKS — has decryption)
```
daemon._process_bank_statement() → ensure_decrypted() → parser → queue
```
- `backend/core/autonomous/daemon.py` line 743
- Calls `ensure_decrypted()` before parsing
- Uses `pdf_password.py` to auto-detect password from filename

### Pipeline Manager Path (BUG — missing decryption)
```
pipeline_manager._extract_text() → pdftotext → FAILS on encrypted PDFs
```
- `backend/core/pipeline/manager.py`
- **Does NOT call `ensure_decrypted()`** — encrypted PDFs fail with "Password-protected PDF"
- Items stuck in `failed` status (13 items as of 2026-03-18)
- **Workaround**: Reset to pending, run daemon (which has decryption), OR pre-decrypt manually

### Manual Decryption
```bash
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate
export SAGE_PROJECT_ROOT="$(pwd)"
export PYTHONPATH="$(pwd):$PYTHONPATH"

# Decrypt all Capitec statements
python3 -c "
from backend.core.parsers.pdf_decrypt import ensure_decrypted
from pathlib import Path
for f in sorted(Path('processing/bank-statements/capitec').glob('*.pdf')):
    result, was_decrypted = ensure_decrypted(f)
    if was_decrypted: print(f'Decrypted: {f.name}')
    else: print(f'OK: {f.name}')
"
```

### Capitec Vision Parser (REQUIRED)
Capitec uses custom fonts that `pdftotext` garbles completely. Must use Gemini vision.

```bash
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate

# Parse all Capitec statements via Gemini vision
python3 scripts/vision_parse_capitec.py \
  --input processing/bank-statements/capitec/ \
  --output processing/bank-statements/capitec/parsed/ \
  --model gemini-2.5-flash
```

Script: `scripts/vision_parse_capitec.py`
- Converts each PDF page to PNG (200 DPI)
- Sends to Gemini with structured extraction prompt
- Outputs JSON with transactions, balances, dates
- Handles single-page and multi-page statements

### Batch Ingest Script
```bash
# Import all bank statements into pipeline
python3 scripts/import_bank_statements.py \
  --dir processing/bank-statements/ \
  --recursive
```

Script: `scripts/import_bank_statements.py`

## Decrypt → Parse → Import Workflow

For encrypted bank statements that failed in the pipeline:

```bash
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate
export SAGE_PROJECT_ROOT="$(pwd)"
export PYTHONPATH="$(pwd):$PYTHONPATH"

# Step 1: Reset failed items
python3 -c "
import sqlite3
conn = sqlite3.connect('backend/data/unified_processing.db')
conn.execute(\"UPDATE processing_items SET status='pending', error_message=NULL, error_count=0 WHERE status='failed' AND category LIKE 'pdf_statement_%'\")
print(conn.execute('SELECT changes()').fetchone()[0], 'items reset')
conn.close()
"

# Step 2: Decrypt all PDFs in place
python3 -c "
from backend.core.parsers.pdf_decrypt import ensure_decrypted
from pathlib import Path
for bank in ['capitec','nedbank']:
    for f in sorted(Path(f'processing/bank-statements/{bank}').glob('*.pdf')):
        result, was = ensure_decrypted(f)
        if was: print(f'✅ Decrypted {f.name}')
"

# Step 3: Vision-parse Capitec (required due to custom fonts)
python3 scripts/vision_parse_capitec.py \
  --input processing/bank-statements/capitec/ \
  --output processing/bank-statements/capitec/parsed/

# Step 4: Parse Nedbank (pdftotext works after decryption)
python3 -c "
from backend.core.parsers.nedbank_statement import parse_nedbank_statement
from pathlib import Path, json
for f in sorted(Path('processing/bank-statements/nedbank').glob('*.pdf')):
    try:
        result = parse_nedbank_statement(str(f))
        out = Path('processing/bank-statements/nedbank/parsed') / f'{f.stem}.json'
        out.parent.mkdir(exist_ok=True)
        out.write_text(json.dumps(result, indent=2, default=str))
        print(f'✅ {f.name}')
    except Exception as e:
        print(f'❌ {f.name}: {e}')
"

# Step 5: Copy to watch-folder for daemon ingestion
cp processing/bank-statements/capitec/*.pdf watch-folder/
cp processing/bank-statements/nedbank/*.pdf watch-folder/

# Step 6: Run daemon
python -m backend.core.autonomous.daemon --no-orchestrator --no-gmail -v
```

## Checking Statement Coverage

```bash
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate

python3 -c "
import sqlite3, json
conn = sqlite3.connect('backend/data/unified_processing.db')
conn.row_factory = sqlite3.Row

print('=== Bank Statements in Pipeline ===')
for r in conn.execute('''
    SELECT category, status, COUNT(*) as cnt
    FROM processing_items
    WHERE category LIKE '%statement%'
    AND is_deleted IS NOT TRUE
    GROUP BY category, status
    ORDER BY category, status
''').fetchall():
    print(f'  {r[\"category\"]:40s} {r[\"status\"]:12s} {r[\"cnt\"]:3d}')

print()
print('=== Available Statement Files ===')
from pathlib import Path
for bank in ['capitec','fnb','nedbank']:
    pdfs = list(Path(f'processing/bank-statements/{bank}').glob('*.pdf'))
    jsons = list(Path(f'processing/bank-statements/{bank}/parsed').glob('*.json')) if Path(f'processing/bank-statements/{bank}/parsed').exists() else []
    print(f'  {bank:12s} {len(pdfs)} PDFs, {len(jsons)} parsed JSONs')
conn.close()
"
```

## Key Files

| File | Purpose |
|---|---|
| `backend/core/parsers/pdf_password.py` | Auto-detect bank passwords from filenames |
| `backend/core/parsers/pdf_decrypt.py` | `ensure_decrypted()` — decrypt PDFs using qpdf |
| `backend/core/parsers/capitec_statement.py` | Capitec text parser (garbled — use vision instead) |
| `backend/core/parsers/fnb_statement.py` | FNB text parser |
| `backend/core/parsers/nedbank_statement.py` | Nedbank text parser |
| `backend/core/parsers/standardbank_statement.py` | Standard Bank text parser |
| `scripts/vision_parse_capitec.py` | Gemini vision Capitec parser (the working one) |
| `scripts/import_bank_statements.py` | Batch bank statement import |
| `backend/core/autonomous/daemon.py:743` | Daemon bank statement handler (has decrypt) |
| `backend/core/pipeline/manager.py` | Pipeline manager (BUG: missing decrypt) |
