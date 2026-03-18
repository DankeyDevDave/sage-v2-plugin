---
description: Generate accountant handover pack for period-end close-out
---

# Handover Pack Generation

Assemble the accountant handover pack from reconciliation data.

**Arguments:** `$ARGUMENTS` — optional period (e.g., `2026-02` or `feb-2026`)

## Generate Pack

```bash
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate
export SAGE_PROJECT_ROOT="$(pwd)" PYTHONPATH="$(pwd):$PYTHONPATH"

# Via API
curl -s "http://localhost:49000/api/handover/" | python3 -m json.tool

# Or use the pack builder directly
python3 -c "
from backend.core.handover.pack_builder import HandoverPackBuilder
from backend.core.database.session import get_async_session_maker
import asyncio

async def build():
    session_maker = get_async_session_maker()
    builder = HandoverPackBuilder(session_maker)
    # Check builder methods and run
    print(dir(builder))

asyncio.run(build())
"
```

## Pack Contents
The handover pack should include:
1. **Trial balance** — from Sage export
2. **Reconciliation reports** — supplier + bank reconciliations
3. **3-way matching reports** — PO ↔ Invoice ↔ Payment discrepancies
4. **VAT return** — verified against GL detail
5. **Supporting documents** — invoices, statements, bank docs

## Key Files
- `backend/core/handover/pack_builder.py` — pack assembly
- `backend/core/handover/assessment_generator.py` — assessment reports
- `backend/core/handover/assessment_models.py` — assessment data models

## Prerequisites
- All bank statements ingested and classified
- Supplier invoices matched against Sage creditor ledger
- VAT reconciliation complete
- Bank reconciliation complete
