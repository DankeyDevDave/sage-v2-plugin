# sage-v2 Plugin — Skill Index

This file is the entry point for any agent on any platform. Read this first, then read the specific skills you need.

## How This Works

This plugin is a **knowledge + tools package** for the sage_v2 accounting pipeline. It works on any agent platform:

- **Droid**: Skills auto-load via plugin manifest
- **Claude Code**: Reference `skills/` in `CLAUDE.md`
- **Cursor/Windsurf**: Reference in `.cursorrules` / `.windsurfrules`
- **OpenClaw/Hermes**: Copy to `~/.hermes/skills/sage-v2/`
- **Any agent**: Just read the markdown files — they're self-contained

Each skill in `skills/` is a standalone markdown file with everything needed:
context, commands, code paths, gotchas, and step-by-step procedures.

## When to Read What

### Starting a pipeline run or debugging readiness?
→ Read `skills/preflight/SKILL.md` first. Then `skills/pipeline-bugs/SKILL.md`.

### Ingesting documents?
→ Read `skills/document-ingestion/SKILL.md`. If bank statements, also `skills/bank-statements/SKILL.md`. If invoice images, also `skills/invoice-vision/SKILL.md`.

### Checking what's been processed?
→ Read `skills/pipeline-status/SKILL.md`.

### Running matching or reconciliation?
→ Read `skills/three-way-matching/SKILL.md` and `skills/reconciliation/SKILL.md`.

### Building an accountant handover pack?
→ Read `skills/handover-pack/SKILL.md`.

### Debugging errors?
→ Read `skills/sentry-monitoring/SKILL.md` and `skills/pipeline-bugs/SKILL.md`.

### Tracking work?
→ Read `skills/linear-issues/SKILL.md`.

### Using Sage v2 or Pipeline MCP tools?
→ Read `skills/sage-accounting/SKILL.md` or `skills/sage-pipeline/SKILL.md`.

## All Skills

| # | Skill | Purpose |
|---|---|---|
| 1 | `preflight` | Validate API keys, data completeness, capabilities. Generate adaptive plan. **Run before anything.** |
| 2 | `pipeline-bugs` | Known bugs, gaps, workarounds. Prevents hitting solved problems. |
| 3 | `pipeline-status` | Check processing stats, queue state, error summary. |
| 4 | `document-ingestion` | Ingest any document type: bank statements, invoices, exports, JSON. |
| 5 | `bank-statements` | SA bank specifics: Capitec/Nedbank/FNB decryption, Capitec vision parser, account numbers. |
| 6 | `invoice-vision` | Extract structured data from invoice images using OCR + Gemini vision. |
| 7 | `three-way-matching` | Match PO ↔ Invoice ↔ Payment for supplier reconciliation. |
| 8 | `reconciliation` | Supplier, bank, and VAT reconciliation procedures. |
| 9 | `handover-pack` | Generate accountant handover pack for period-end close-out. |
| 10 | `sage-accounting` | Reference for sage-accounting MCP tools (29 tools). |
| 11 | `sage-pipeline` | Reference for sage-pipeline MCP tools (12 tools). |
| 12 | `sentry-monitoring` | Error monitoring via Sentry MCP (21 tools) + CLI. |
| 13 | `linear-issues` | Create/update/close Linear issues for work tracking. |

## MCP Servers

Four MCP servers provide tools. Any MCP-compatible client can connect:

| Server | Tools | Use For |
|---|---|---|
| `linear` | Issue CRUD | Tracking work, filing bugs |
| `sage-accounting` | 29 tools | Sage v2 read/write: invoices, journals, recons, matching, handover |
| `sage-pipeline` | 12 tools | Pipeline control: replay, ingest, snapshot, verify, report |
| `sentry` | 21 tools | Error monitoring: issues, events, traces, Seer AI root cause |

Config in `mcp.json`. Requires env vars: `LINEAR_API_KEY`, `SENTRY_AUTH_TOKEN`.

## Scripts

Key automation scripts in `/Users/jacques/DevFolder/sage_v2/scripts/`:

| Script | Purpose |
|---|---|
| `preflight.py` | Pre-flight validation (always run first) |
| `ingest_invoice_json.py` | Convert pre-extracted JSON → pipeline schema |
| `import_bank_statements.py` | Batch import bank statements |
| `vision_parse_capitec.py` | Gemini vision parser for Capitec statements |
| `sage_pipeline_mcp.py` | Pipeline MCP server |

## Project Location

`/Users/jacques/DevFolder/sage_v2`

```bash
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate
export SAGE_PROJECT_ROOT="$(pwd)" PYTHONPATH="$(pwd):$PYTHONPATH"
```

## Non-Droid Platforms

If you're not on Droid, ignore `commands/`, `droids/`, and `hooks/` — those are Droid-specific adapters. Everything you need is in `skills/` and `mcp.json`.
