# sage-v2 — Droid Plugin

Automated accounting pipeline plugin for [Sage v2](https://www.sage.com/za/) financial close-out. Ingests documents, runs OCR/vision extraction, 3-way matching, reconciliation, and generates accountant handover packs.

## Installation

```bash
# Local development
droid plugin marketplace add /Users/jacques/DevFolder/sage-v2-marketplace
droid plugin install sage-v2@sage-v2-marketplace

# Re-install after changes
droid plugin update sage-v2@sage-v2-marketplace
```

## MCP Servers (auto-configured)

The plugin bundles four MCP servers that are automatically available when installed:

| Server | Purpose | Tools |
|---|---|---|
| `linear` | Issue tracking (JAC project) | Create/update/close issues, comments, project management |
| `sage-accounting` | Sage v2 API control | 29 tools — invoices, journals, recons, matching, handover, audit |
| `sage-pipeline` | Pipeline orchestration | 12 tools — replay, ingest, snapshot, sanitize, verify, report |
| `sentry` | Error monitoring & debugging | 21 tools — issues, events, traces, Seer AI, docs search |

### MCP Server Details

**Linear** — `/opt/homebrew/bin/linear-mcp`
- Team: `JAC` (`2ed647a5-8d87-4e9e-a498-dd41738da252`)
- Project: Sage v2 (`dedf1e00-a36d-4a09-85ad-3616a3885620`)
- Requires: `LINEAR_API_KEY` env var

**sage-accounting** — `uv run --directory sage_v2 sage-accounting-mcp`
- Full Sage v2 read/write access
- Supplier/customer/bank/inventory/GL queries
- Journal submission, approval, posting workflow
- 3-way matching, reconciliation, VAT
- Handover pack generation
- Gmail integration for invoice scanning
- Audit trail for all changes

**sage-pipeline** — `python scripts/sage_pipeline_mcp.py`
- Pipeline status and queue management
- Clean-room replay (snapshot → sanitize → replay → report)
- Single file ingestion
- Handover pack builder

**sentry** — `sentry-mcp --access-token <token> --experimental`
- Official `@sentry/mcp-server` (npm)
- Issue details, event attachments, trace analysis
- AI root cause analysis (Seer)
- Performance profiles, release tracking
- Doc search, project/team management
- Org: `sunlec-energy-solutions-pty-lt`, Project: `sage-v2-backend`
- Requires: `SENTRY_AUTH_TOKEN` env var

## Commands (slash-invoked)

| Command | Description |
|---|---|
| `/sage-status` | Pipeline health — processing stats, errors, Sentry, daemon |
| `/sage-ingest <file\|dir>` | Ingest bank statements, invoices, exports, or JSON |
| `/sage-daemon <start\|stop\|restart\|status>` | Control the file watcher daemon |
| `/sage-match <supplier>` | Run 3-way PO ↔ Invoice ↔ Payment matching |
| `/sage-recon <supplier\|bank\|vat>` | Run supplier, bank, or VAT reconciliation |
| `/sage-handover [period]` | Generate accountant handover pack |

## Skills (auto-invoked by model)

| Skill | When Used |
|---|---|
| `pipeline-status` | Checking pipeline health, processing progress |
| `document-ingestion` | Ingesting documents into pipeline |
| `three-way-matching` | Running supplier matching |
| `reconciliation` | Reconciling accounts |
| `handover-pack` | Building accountant packs |
| `sentry-monitoring` | Checking errors, debugging, AI root cause analysis (MCP + CLI) |
| `invoice-vision` | Extracting data from invoice images (OCR + Gemini) |
| `linear-issues` | Creating/updating/closing Linear issues |
| `sage-accounting` | Controlling Sage v2 via MCP (invoices, journals, recons) |
| `sage-pipeline` | Pipeline replay, ingest, snapshot, sanitize, verify |

## Droids (subagents)

| Droid | Purpose |
|---|---|
| `night-shift-operator` | Autonomous unattended pipeline run — ingestion through handover pack |

### Using the Night Shift Operator
```
/droid night-shift-operator Run the full financial year close-out pipeline overnight
```

## Hooks

| Hook | Trigger | Description |
|---|---|---|
| `check-env.sh` | PostToolUse on Write/Edit | Warns when editing `.env` files (contains secrets) |

## Prerequisites

- Python 3.12+ with venv at `/Users/jacques/DevFolder/sage_v2/.venv`
- SQLite DB at `backend/data/unified_processing.db`
- `uv` installed (for sage-accounting MCP)
- `linear-mcp` installed at `/opt/homebrew/bin/linear-mcp`
- `sentry` CLI installed and authenticated (`~/.local/bin/sentry`)
- API keys in `.env` (never committed):
  - `LINEAR_API_KEY` — Linear issue tracking
  - `SENTRY_AUTH_TOKEN` — Sentry MCP server auth (get via `sentry auth token`)
  - `SAGE_GEMINI_API_KEY` — Gemini vision (primary LLM)
  - `SAGE_ZHIPU_API_KEY` — Z.AI (NO BALANCE — do not rely on)
  - `SAGE_API_KEY` — Sage v2 API
  - `SAGE_SENTRY_DSN` — Sentry error tracking

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Droid Plugin                            │
├──────────┬──────────┬──────────┬──────────┬────────────────┤
│  Linear  │  Sentry  │   Sage   │ Pipeline │    Daemon      │
│   MCP    │   MCP    │ Acc. MCP │   MCP    │   Control      │
│  (issues)│ (21 tools│ (29 tools│ (12 tools│ (start/stop/   │
│          |  errors, │ invoices,│ replay,  │  restart)      │
│          │  traces, │ journals,│ ingest,  │                │
│          │  Seer AI)│ recons)  │ report)  │                │
├──────────┴──────────┴──────────┴──────────┴────────────────┤
│              sage_v2 Pipeline                        │
│                                                      │
│  Documents → Watch Folder → Daemon                   │
│     ↓                                                │
│  Pipeline Manager                                    │
│     ├── Extract (OCR + Gemini Vision)                │
│     ├── Classify (ML + LLM)                          │
│     ├── Validate (schema + rules)                    │
│     └── Judge (SARS compliance)                      │
│              ↓                                       │
│  Processing Items (SQLite DB)                        │
│              ↓                                       │
│  3-Way Matching (PO ↔ Invoice ↔ Payment)            │
│              ↓                                       │
│  Reconciliation (Supplier + Bank + VAT)              │
│              ↓                                       │
│  Handover Pack Builder                               │
└─────────────────────────────────────────────────────┘
```

## Critical Rules

1. **All prices EXCLUSIVE of VAT** — Sage adds 15% automatically
2. **Supplier names SINGULAR** — no combined names
3. **Z.AI has NO BALANCE** — use Gemini as primary LLM
4. **Git push is MANDATORY** — never leave work unpushed
5. **Never commit `.env`** — contains API keys

## Project Structure

```
sage_v2/
├── backend/
│   ├── mcp/
│   │   └── server.py          # sage-accounting MCP (29 tools)
│   ├── api/routers/           # REST API routes
│   ├── core/
│   │   ├── autonomous/        # Daemon + scheduler
│   │   ├── config/            # Settings (.env SAGE_ prefix)
│   │   ├── database/          # SQLite ORM models
│   │   ├── handover/          # Pack builder + assessment
│   │   ├── ingestion/         # File watcher + ingester
│   │   ├── matching/          # 3-way matching engine
│   │   ├── parsers/           # OCR, vision, Sage export, invoice
│   │   ├── pipeline/          # Pipeline manager
│   │   ├── reconciliation/    # Recon engine
│   │   └── validators/        # LLM judge
│   └── data/
│       └── unified_processing.db
├── scripts/
│   └── sage_pipeline_mcp.py   # sage-pipeline MCP (12 tools)
├── watch-folder/              # Drop files here
├── processing/                # In-flight documents
├── archive/                   # Processed documents
├── logs/                      # Daemon logs
└── .env                       # Secrets (never commit)
```

## License

MIT
