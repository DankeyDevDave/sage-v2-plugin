---
name: sentry-monitoring
description: Monitor sage_v2 via Sentry — check issues, events, traces, errors, and performance. Use when asked about Sentry, errors, monitoring, observability, or debugging pipeline failures.
---

Monitor the sage_v2 pipeline via Sentry MCP server and CLI.

## MCP Server: `sentry`
This skill uses the official `@sentry/mcp-server` (21 tools) for rich interactive debugging.

### Available MCP Tools
| Tool | Description |
|---|---|
| `find_organizations` | List accessible Sentry organizations |
| `find_projects` | List projects in an org |
| `find_teams` | List teams in an org |
| `find_releases` | List releases for a project |
| `find_dsns` | Find DSNs for a project |
| `get_issue_details` | Get full issue details with stacktrace and context |
| `get_issue_tag_values` | Get tag values for an issue |
| `get_event_attachment` | Get event attachments (screenshots, logs, etc.) |
| `get_trace_details` | Get distributed trace with span tree |
| `get_profile` | Get performance profile data |
| `get_profile` | Get Sentry resource by URL |
| `update_issue` | Update issue status, assignee, labels |
| `search_docs` | Search Sentry documentation |
| `create_project` | Create a new Sentry project |
| `create_team` | Create a new Sentry team |
| `create_dsn` | Create a new DSN |
| `update_project` | Update project settings |
| `analyze_issue_with_seer` | AI root cause analysis (Seer) |
| `get_doc` | Get a specific Sentry doc page |
| `whoami` | Show authenticated user |

## Configuration
- **Org:** `sunlec-energy-solutions-pty-lt`
- **Project:** `sage-v2-backend`
- **MCP Server:** `sentry` — configured in mcp.json (any MCP client)
- **CLI:** `sentry` at `~/.local/bin/sentry` — fallback for scripted queries
- **Auth:** Already authenticated (token expires 2026-04-16)

## Common Workflows

### Check for New Errors
Use MCP: `find_projects` → filter by org → `get_issue_details` on unresolved issues
Or CLI fallback:
```bash
sentry issue list sunlec-energy-solutions-pty-lt/sage-v2-backend --sort date --limit 10 --query "is:unresolved level:error" 2>/dev/null
```

### Debug a Specific Error
Use MCP: `get_issue_details` → full stacktrace, breadcrumbs, tags, context
```
get_issue_details(issue_id="SAGE-V2-BACKEND-3V")
```

### AI Root Cause Analysis
Use MCP: `analyze_issue_with_seer` — Sentry's Seer AI analyzes the issue
```
analyze_issue_with_seer(issue_id="SAGE-V2-BACKEND-3V")
```

### Stream Error Logs (CLI only)
```bash
sentry log list sunlec-energy-solutions-pty-lt/sage-v2-backend -f -q 'level:error'
```

### View Trace (MCP)
```
get_trace_details(trace_id="...")
```

### Resolve an Issue
Use MCP: `update_issue` with status=resolved
Or CLI:
```bash
sentry api /issues/ISSUE_ID/ --method PUT --field status=resolved
```

## Known Issues (as of 2026-03-17)
| Sentry ID | Issue | Status |
|---|---|---|
| SAGE-V2-BACKEND-3V | TypeError: count() got unexpected keyword 'tags' | Fix applied |
| SAGE-V2-BACKEND-74 | VAT recon: float * Decimal type error | Open (JAC-113) |
| SAGE-V2-BACKEND-73 | Empty PDF: document has no pages | Open (JAC-111) |

## Key Files
- `backend/core/ingestion/file_watcher.py` — Sentry metrics in file watcher
- `backend/core/pipeline/manager.py` — Sentry metrics in pipeline
- `.env` — `SAGE_SENTRY_DSN` for SDK auto-instrumentation
