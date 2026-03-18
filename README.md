# sage-v2 — Agent Plugin for Sage v2 Pipeline

Automated accounting pipeline plugin for [Sage v2](https://www.sage.com/za/) financial close-out. Ingests documents, runs OCR/vision extraction, 3-way matching, reconciliation, and generates accountant handover packs.

**Works with any agent platform** — Claude Code, Cursor, Windsurf, OpenClaw, Droid, or raw shell. The `skills/` directory is the universal knowledge layer. Everything else is optional wiring.

## Quick Start (any platform)

```bash
# 1. Set up environment
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate
export SAGE_PROJECT_ROOT="$(pwd)" PYTHONPATH="$(pwd):$PYTHONPATH"

# 2. Run preflight — ALWAYS do this first
python3 scripts/preflight.py --fix

# 3. Read the skills that match your task
#    Each skill is a self-contained markdown file in skills/
#    Read the relevant ones and follow their instructions

# 4. Work through the pipeline using MCP tools + bash + scripts
```

## Skills (universal — any agent, any platform)

The `skills/` directory is the **primary interface**. Every skill is a self-contained markdown file with everything an agent needs: context, commands, code paths, gotchas, and step-by-step procedures.

| Skill | When to Read |
|---|---|
| `preflight` | **Before anything else** — validates API keys, data, capabilities, generates adaptive plan |
| `pipeline-bugs` | **Before any pipeline work** — known bugs, gaps, workarounds |
| `pipeline-status` | Checking pipeline health, processing progress |
| `document-ingestion` | Ingesting documents (bank statements, invoices, exports, JSON) |
| `bank-statements` | SA bank statement specifics — decryption, Capitec vision, per-bank handling |
| `invoice-vision` | Extracting data from invoice images (OCR + Gemini) |
| `three-way-matching` | PO ↔ Invoice ↔ Payment matching |
| `reconciliation` | Supplier, bank, and VAT reconciliation |
| `handover-pack` | Building accountant handover packs |
| `sage-accounting` | Sage v2 API reference (via MCP tools) |
| `sage-pipeline` | Pipeline control reference (via MCP tools) |
| `sentry-monitoring` | Error monitoring and debugging |
| `linear-issues` | Issue tracking (Linear) |

**How skills work on different platforms:**

| Platform | How it discovers skills |
|---|---|
| **Droid** | Auto-loaded via plugin manifest — agent reads them on demand |
| **Claude Code** | Point `CLAUDE.md` at `skills/` or copy to `.clinerules` |
| **Cursor** | Add `skills/` to `.cursor/rules/` or reference in `.cursorrules` |
| **Windsurf** | Reference in `.windsurfrules` |
| **OpenClaw/Hermes** | Copy to `~/.hermes/skills/sage-v2/` or `~/.openclaw/skills/` |
| **Raw shell** | `cat skills/preflight/SKILL.md` — read the markdown, follow the steps |

Skills never reference a specific platform. They reference:
- Filesystem paths (`/Users/jacques/DevFolder/sage_v2/...`)
- MCP tools by server name + tool name (`sage-accounting.create_invoice`)
- CLI tools (`sentry`, `sqlite3`, `python3 scripts/...`)
- Scripts (`scripts/preflight.py`, `scripts/ingest_invoice_json.py`)

## MCP Servers (any MCP-compatible client)

Four MCP servers are configured in `mcp.json`. Any MCP client can connect to them:

| Server | Purpose | Tools |
|---|---|---|
| `linear` | Issue tracking (JAC project) | CRUD issues, comments, project management |
| `sage-accounting` | Sage v2 API control | 29 tools — invoices, journals, recons, matching, handover, audit |
| `sage-pipeline` | Pipeline orchestration | 12 tools — replay, ingest, snapshot, sanitize, verify, report |
| `sentry` | Error monitoring & debugging | 21 tools — issues, events, traces, Seer AI, docs search |

**Connecting from any MCP client:**

```json
{
  "mcpServers": {
    "linear": {
      "command": "/opt/homebrew/bin/linear-mcp",
      "env": { "LINEAR_API_KEY": "<your-key>" }
    },
    "sage-accounting": {
      "command": "uv",
      "args": ["run", "--directory", "/Users/jacques/DevFolder/sage_v2", "sage-accounting-mcp"]
    },
    "sage-pipeline": {
      "command": "/Users/jacques/DevFolder/sage_v2/.venv/bin/python",
      "args": ["/Users/jacques/DevFolder/sage_v2/scripts/sage_pipeline_mcp.py"]
    },
    "sentry": {
      "command": "/opt/homebrew/bin/sentry-mcp",
      "args": ["--access-token", "<your-token>", "--experimental"]
    }
  }
}
```

See `mcp.json` for the full config with env var placeholders.

## Droid Integration (optional)

If you're running on [Droid](https://github.com/DankeyDevDave/droid), the plugin auto-registers:

- **7 slash commands** (`/sage-status`, `/sage-ingest`, `/sage-daemon`, `/sage-match`, `/sage-recon`, `/sage-handover`, `/preflight`) — thin wrappers that load the corresponding skill
- **1 subagent** (`night-shift-operator`) — autonomous overnight pipeline run
- **1 hook** (`check-env.sh`) — warns when editing `.env` files

```bash
# Install for Droid
droid plugin marketplace add /Users/jacques/DevFolder/sage-v2-marketplace
droid plugin install sage-v2@sage-v2-marketplace
droid plugin update sage-v2@sage-v2-marketplace
```

**Commands are just skill sugar.** `/sage-status` loads `skills/pipeline-status/SKILL.md`. `/preflight --fix` loads `skills/preflight/SKILL.md` and runs the fix. On non-Droid platforms, just read the skill directly — same knowledge, same steps.

## Prerequisites

- Python 3.12+ with venv at `/Users/jacques/DevFolder/sage_v2/.venv`
- SQLite DB at `backend/data/unified_processing.db`
- `uv` installed (for sage-accounting MCP)
- `linear-mcp` at `/opt/homebrew/bin/linear-mcp`
- `sentry` CLI at `~/.local/bin/sentry` (authenticated)
- API keys in `.env` (never committed):
  - `LINEAR_API_KEY` — Linear issue tracking
  - `SENTRY_AUTH_TOKEN` — Sentry MCP server auth (`sentry auth token`)
  - `SAGE_GEMINI_API_KEY` — Gemini vision (primary LLM)
  - `SAGE_ZHIPU_API_KEY` — Z.AI (NO BALANCE — do not rely on)
  - `SAGE_API_KEY` — Sage v2 API
  - `SAGE_SENTRY_DSN` — Sentry error tracking

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Any Agent Platform                        │
│            (Claude Code, Cursor, Droid, etc.)               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   skills/ ← Universal knowledge layer (read these)          │
│   ├── preflight/          Validate before running            │
│   ├── pipeline-bugs/      Known issues + workarounds         │
│   ├── bank-statements/    Per-bank decryption + parsing      │
│   ├── document-ingestion/ Ingest any document type           │
│   ├── invoice-vision/     OCR + Gemini extraction            │
│   ├── three-way-matching/ PO ↔ Invoice ↔ Payment            │
│   ├── reconciliation/     Supplier + Bank + VAT              │
│   ├── handover-pack/      Accountant pack builder            │
│   ├── sage-accounting/    Sage v2 MCP tool reference         │
│   ├── sage-pipeline/      Pipeline MCP tool reference        │
│   ├── sentry-monitoring/  Error monitoring                  │
│   ├── pipeline-status/    Health check                       │
│   └── linear-issues/      Issue tracking                    │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│   MCP Servers ← Universal tool layer (connect any client)    │
│   ├── linear              Issue tracking                     │
│   ├── sage-accounting     29 Sage v2 tools                   │
│   ├── sage-pipeline       12 pipeline tools                  │
│   └── sentry              21 monitoring tools                │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│   scripts/ ← Automation layer (bash/python)                  │
│   ├── preflight.py        Pre-flight validation              │
│   ├── ingest_invoice_json.py  JSON → pipeline converter      │
│   ├── import_bank_statements.py  Batch bank import           │
│   ├── vision_parse_capitec.py  Gemini vision for Capitec     │
│   └── sage_pipeline_mcp.py  Pipeline MCP server             │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   sage_v2 Pipeline (Python backend)                          │
│     Documents → Watch Folder → Daemon                        │
│        ↓                                                     │
│     Pipeline Manager                                         │
│       ├── Extract (OCR + Gemini Vision)                      │
│       ├── Classify (ML + LLM)                                │
│       ├── Validate (schema + rules)                          │
│       └── Judge (SARS compliance)                            │
│              ↓                                               │
│     Processing Items (SQLite DB)                             │
│              ↓                                               │
│     3-Way Matching (PO ↔ Invoice ↔ Payment)                 │
│              ↓                                               │
│     Reconciliation (Supplier + Bank + VAT)                   │
│              ↓                                               │
│     Handover Pack Builder                                    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Critical Rules

1. **All prices EXCLUSIVE of VAT** — Sage adds 15% automatically
2. **Supplier names SINGULAR** — no combined names
3. **Z.AI has NO BALANCE** — use Gemini as primary LLM
4. **Git push is MANDATORY** — never leave work unpushed
5. **Never commit `.env`** — contains API keys
6. **Run preflight first** — know what's possible before starting

## License

MIT
