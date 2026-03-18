---
name: sentry-monitoring
description: Monitor sage_v2 via Sentry — check issues, logs, traces, and errors. Use when asked about Sentry, errors, monitoring, or observability.
---

Monitor the sage_v2 pipeline via Sentry CLI.

## Configuration
- **Org:** `sunlec-energy-solutions-pty-lt`
- **Project:** `sage-v2-backend`
- **CLI:** `sentry` (installed at `~/.local/bin/sentry`)
- **Auth:** Already authenticated (token expires 2026-04-16)

## Common Commands

### Recent Unresolved Errors
```bash
sentry issue list sunlec-energy-solutions-pty-lt/sage-v2-backend --sort date --limit 10 --query "is:unresolved level:error"
```

### All Recent Issues
```bash
sentry issue list sunlec-energy-solutions-pty-lt/sage-v2-backend --sort date --limit 10
```

### View Specific Issue
```bash
sentry issue view ISSUE_ID
```

### AI Root Cause Analysis
```bash
sentry issue explain ISSUE_ID
```

### Solution Plan
```bash
sentry issue plan ISSUE_ID
```

### Error Logs
```bash
sentry log list sunlec-energy-solutions-pty-lt/sage-v2-backend -q 'level:error' --limit 20
```

### Stream Error Logs
```bash
sentry log list sunlec-energy-solutions-pty-lt/sage-v2-backend -f -q 'level:error'
```

### Traces
```bash
sentry trace list sunlec-energy-solutions-pty-lt/sage-v2-backend --limit 10
```

### Resolve an Issue
```bash
sentry api /issues/ISSUE_ID/ --method PUT --field status=resolved
```

## Known Issues (as of 2026-03-17)
| Sentry ID | Issue | Status |
|---|---|---|
| SAGE-V2-BACKEND-3V | TypeError: count() got unexpected keyword 'tags' | Fix applied (tags→attributes) |
| SAGE-V2-BACKEND-74 | VAT recon: float * Decimal type error | Open (JAC-113) |
| SAGE-V2-BACKEND-73 | Empty PDF: document has no pages | Open (JAC-111) |
| SAGE-V2-BACKEND-75 | New file detected: SupplierTransactionsReport-5.csv | Info (resolved) |
