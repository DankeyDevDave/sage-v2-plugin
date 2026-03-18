---
name: pipeline-status
description: Check sage_v2 pipeline health — processing stats, error counts, daemon status, Sentry issues. Use when asked about pipeline status, processing progress, or system health.
---

Check the health of the sage_v2 automated accounting pipeline by running these diagnostic commands:

## Environment Setup
```bash
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate
export SAGE_PROJECT_ROOT="$(pwd)" PYTHONPATH="$(pwd):$PYTHONPATH"
```

## Database State
```bash
python3 -c "
import sqlite3
conn = sqlite3.connect('backend/data/unified_processing.db')
conn.row_factory = sqlite3.Row
rows = conn.execute('SELECT status, COUNT(*) as cnt FROM processing_items WHERE is_deleted IS NOT TRUE GROUP BY status').fetchall()
for r in rows: print(f'{r[\"status\"]:15s} {r[\"cnt\"]:4d}')
print('--- by category ---')
rows = conn.execute('SELECT category, status, COUNT(*) as cnt FROM processing_items WHERE is_deleted IS NOT TRUE GROUP BY category, status ORDER BY category, status').fetchall()
for r in rows: print(f'  {r[\"category\"]:40s} {r[\"status\"]:12s} {r[\"cnt\"]:4d}')
conn.close()
"
```

## Daemon
```bash
ps aux | grep "backend.core.autonomous.daemon" | grep -v grep
```

## Sentry
```bash
sentry issue list sunlec-energy-solutions-pty-lt/sage-v2-backend --sort date --limit 5 --query "is:unresolved level:error" 2>/dev/null
```

## Stuck Items
```bash
python3 -c "
import sqlite3
conn = sqlite3.connect('backend/data/unified_processing.db')
conn.row_factory = sqlite3.Row
rows = conn.execute(\"SELECT id, subject, status, created_date FROM processing_items WHERE status='processing' ORDER BY created_date\").fetchall()
for r in rows: print(f'{r[\"id\"]:25s} {r[\"subject\"][:50]}  since {r[\"created_date\"]}')
conn.close()
"
```

Present results as a concise status card. Flag any items stuck in `processing` for more than 10 minutes.
