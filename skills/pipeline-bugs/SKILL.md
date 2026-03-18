---
name: pipeline-bugs
description: Known bugs, gaps, and gotchas in the sage_v2 pipeline. Read this BEFORE running any pipeline operations to avoid hitting known issues. Use when debugging pipeline failures, planning a run, or investigating unexpected errors.
---

# sage_v2 Pipeline — Known Bugs & Gotchas

Last updated: 2026-03-18

## Critical Bugs

### 1. Pipeline Manager Missing PDF Decryption (UNFIXED)
- **Impact**: Encrypted bank statements fail when processed via pipeline manager path
- **Symptom**: Items stuck in `failed` status with "Password-protected PDF — cannot extract text"
- **Root cause**: `pipeline_manager.py` does NOT call `ensure_decrypted()` before text extraction
- **Daemon path works**: `daemon._process_bank_statement()` at line 743 DOES call `ensure_decrypted()`
- **Workaround**: 
  1. Pre-decrypt PDFs manually using `pdf_decrypt.ensure_decrypted()`
  2. Or run via daemon (which has the decrypt step)
  3. Or reset failed → copy to watch-folder → run daemon
- **Files**: `backend/core/pipeline/manager.py` (missing), `backend/core/autonomous/daemon.py:754` (has it)
- **Affected**: 13 bank statements (9 Capitec, 4 Nedbank) as of 2026-03-18

### 2. LLM Judge — Zhipu Insufficient Balance (UNFIXED)
- **Impact**: LLM judge always fails — Z.AI key has no balance for completions
- **Symptom**: Timeout errors, empty responses
- **Workaround**: `SAGE_LLM_JUDGE_ENABLED=false` in `.env`
- **Tradeoff**: No LLM validation of extracted data quality
- **Fix needed**: Add Gemini as fallback LLM judge provider

### 3. Daemon Silent Crash on Gemini Timeout (UNFIXED)
- **Impact**: Daemon process dies with no error logged, no Sentry event
- **Symptom**: Daemon PID disappears, no traceback in logs
- **Cause**: Gemini API timeout not caught — unhandled exception kills process
- **Fix needed**: Wrap Gemini calls in try/except with timeout, log error, continue to next file

### 4. LLM Judge Missing supplier_transactions_report Prompt (UNFIXED)
- **Impact**: Sage export CSVs evaluated as blank tax invoices (false positive)
- **Symptom**: `sage_data_supplier_invoice` items get `invoice_v1` prompt instead of correct template
- **Cause**: LLM judge only has `invoice_v1` prompt template
- **Fix needed**: Add `supplier_transactions_report` prompt to `backend/core/processors/validators/llm_judge/judge.py`

### 5. VAT Reconciliation — float * Decimal Type Error (UNFIXED)
- **Impact**: VAT recon crashes on type mismatch
- **Sentry**: SAGE-V2-BACKEND-74 (3 events)
- **Cause**: Some monetary values stored as float, others as Decimal
- **Fix needed**: Audit `backend/core/reconciliation/vat_recon.py` — ensure all values are `Decimal`

## Fixed Bugs (in code, committed)

### 6. Sentry Metrics API — tags→attributes ✅
- **Was**: `sentry_metrics.count(tags=...)` — wrong parameter name for SDK v2.54
- **Now**: `sentry_metrics.count(attributes=...)`
- **Files**: `backend/core/ingestion/file_watcher.py:73`, `backend/core/pipeline/manager.py:258-272`
- **Introduced in**: Commit `ba40d08`

### 7. Daemon Startup Scan Missing CSV Extensions ✅
- **Was**: `_scan_existing_files()` only checked image/PDF extensions
- **Now**: Also checks `.csv`, `.xlsx`, `.xls`
- **File**: `backend/core/autonomous/daemon.py`
- **Still needs**: DRY — source from `WatchFolderHandler.supported_extensions` instead of hardcoding

## Operational Gotchas

### Capitec Statements — Must Use Vision Parser
- Capitec PDFs use custom fonts that `pdftotext` produces garbled output from
- Text parser `capitec_statement.py` does NOT work reliably
- **Must use**: `scripts/vision_parse_capitec.py` with Gemini 2.5 Flash
- Each PDF is single-page, converted to PNG at 200 DPI

### FNB Statements — All Identical
- All 7 FNB PDFs in `processing/bank-statements/fnb/` are the same file (same SHA hash)
- Only 1 unique FNB statement exists, already processed
- Don't waste time trying to ingest duplicates

### Nedbank Statements — Duplicate Files
- Some statements have `_1` or `_2` suffixes (copies from download)
- Deduplicate by content hash before ingesting
- `_1_1` suffixes are parsed JSON copies from vision parser runs

### All Prices Must Be EXCLUSIVE of VAT
- Sage adds 15% VAT automatically
- If inclusive prices passed, Sage doubles VAT
- Pipeline schema: `total_amount` = incl VAT, `subtotal` = excl VAT
- Converter script `scripts/ingest_invoice_json.py` handles this correctly

### Supplier Names Must Be Singular
- No combined names like "Dynamics / Express"
- Must match Sage supplier master exactly
- The LLM judge (when working) catches this

### Daemon Deduplication
- Daemon skips files already ingested (checks by source_id hash)
- Safe to restart daemon — it will skip already-processed files
- BUT: items reset from `failed` → `pending` need their source files in watch-folder

### File Path Access Restrictions
- Cannot read files on `/Volumes/` directly from some code paths
- Copy images to workspace (`watch-folder/` or `processing/`) before processing

## Current State (2026-03-18)

| Category | Completed | Failed | Total |
|---|---|---|---|
| PDF invoices | 116 | 0 | 116 |
| Capitec statements | 0 | 9 | 9 |
| FNB statements | 1 | 0 | 1 |
| Nedbank statements | 0 | 4 | 4 |
| Unknown statements | 7 | 0 | 7 |
| Sage data | 2 | 0 | 2 |
| **Total** | **126** | **13** | **139** |

## Open Linear Issues

| ID | Priority | Issue |
|---|---|---|
| JAC-86 | High | scan-watch-folder API: support image/PDF ingestion |
| JAC-87 | High | Support ingesting pre-extracted invoice JSON |
| JAC-88 | High | LLM Judge: Z.AI key insufficient balance |
| JAC-109 | High | Daemon: silent crash on Gemini timeout |
| JAC-111 | Low | Pipeline: empty/broken PDF 'no pages' error |
| JAC-112 | High | LLM Judge: add supplier_transactions_report prompt |
| JAC-113 | Medium | VAT reconciliation: float * Decimal type error |
