---
description: Check pipeline health — processing stats, errors, Sentry issues, daemon status
---

# Sage Pipeline Status

Report the current health of the sage_v2 pipeline. Run these checks and present a clean summary:

## 1. Database State

```bash
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate
export SAGE_PROJECT_ROOT="$(pwd)" PYTHONPATH="$(pwd):$PYTHONPATH"

python3 -c "
import sqlite3
conn = sqlite3.connect('backend/data/unified_processing.db')
conn.row_factory = sqlite3.Row
# Status breakdown
rows = conn.execute('SELECT status, COUNT(*) as cnt FROM processing_items WHERE is_deleted IS NOT TRUE GROUP BY status').fetchall()
for r in rows: print(f'{r[\"status\"]:15s} {r[\"cnt\"]:4d}')
# Category breakdown for completed
print('--- completed by category ---')
rows = conn.execute('SELECT category, COUNT(*) as cnt FROM processing_items WHERE status=\"completed\" AND is_deleted IS NOT TRUE GROUP BY category ORDER BY cnt DESC').fetchall()
for r in rows: print(f'  {r[\"category\"]:40s} {r[\"cnt\"]:4d}')
total = conn.execute('SELECT COUNT(*) FROM processing_items WHERE is_deleted IS NOT TRUE').fetchone()[0]
print(f'Total: {total}')
conn.close()
"
```

## 2. Daemon Status

```bash
ps aux | grep "backend.core.autonomous.daemon" | grep -v grep
```

## 3. Recent Errors (last 20 lines)

```bash
tail -20 /Users/jacques/DevFolder/sage_v2/logs/daemon_manual.log | grep -i "error\|failed\|traceback"
```

## 4. Sentry (last 5 unresolved errors)

```bash
sentry issue list sunlec-energy-solutions-pty-lt/sage-v2-backend --sort date --limit 5 --query "is:unresolved level:error" 2>/dev/null
```

## 5. Stuck Items

Check for items stuck in `processing` status for more than 10 minutes — they likely crashed.

Present results as a concise status card with emoji indicators (✅/⚠️/🔴).
