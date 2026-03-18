---
name: sage-accounting
description: Control the Sage v2 accounting system via MCP — read/write Sage data, manage invoices, journals, recons, and handover packs. Use when asked to interact with Sage, query accounting data, post journals, or manage the Sage API.
---

Control the Sage v2 accounting system via the `sage-accounting` MCP server (29 tools).

## MCP Server: `sage-accounting`
Runs via: `uv run --directory /Users/jacques/DevFolder/sage_v2 sage-accounting-mcp`

## Available MCP Tools

### Connection & Workspace
| Tool | Description |
|---|---|
| `sage_test_connection` | Test Sage v2 API connectivity |
| `accounting_workspace_snapshot` | Full snapshot of all Sage accounting tables |

### Inbox & Watch Folder
| Tool | Description |
|---|---|
| `inbox_get_artifact` | Get artifact details by ID |
| `inbox_get_stats` | Inbox statistics (counts by status) |
| `watch_folder_scan` | Scan watch-folder for new files |

### Pipeline Control
| Tool | Description |
|---|---|
| `pipeline_get_status` | Current pipeline queue state |
| `pipeline_queue_artifacts` | Queue artifacts for processing |
| `pipeline_retry_artifact` | Retry a failed artifact |
| `pipeline_cancel_artifact` | Cancel a queued artifact |

### Lifecycle & Matching
| Tool | Description |
|---|---|
| `lifecycle_get_dashboard` | Dashboard stats (transactions, exceptions, coverage) |
| `lifecycle_get_transaction` | Get transaction lifecycle details |
| `lifecycle_list_exceptions` | List matching exceptions |
| `lifecycle_run_matcher` | Trigger the 3-way matching engine |
| `lifecycle_update` | Update artifact lifecycle status |

### Reconciliation
| Tool | Description |
|---|---|
| `recon_get_run` | Get reconciliation run details |
| `recon_get_metrics` | Recon metrics summary |
| `recon_get_vat_summary` | VAT reconciliation summary for period |
| `recon_supplier` | Run supplier reconciliation |
| `recon_bank` | Run bank reconciliation |
| `recon_vat` | Run VAT reconciliation |
| `recon_exception_resolve` | Resolve a recon exception |
| `recon_match_review` | Review a match for approval/rejection |
| `recon_bulk_approve` | Bulk approve matches |
| `recon_trial_balance` | Trial balance reconciliation |

### Journals
| Tool | Description |
|---|---|
| `journals_get` | Get journal details |
| `journals_submit` | Submit journal for approval |
| `journals_approve` | Approve a journal |
| `journals_reject` | Reject a journal with reason |
| `journals_post` | Post approved journal to Sage |

### Handover
| Tool | Description |
|---|---|
| `handover_generate_period_pack` | Generate accountant handover pack for a period |

### Gmail Integration
| Tool | Description |
|---|---|
| `gmail_get_auth_status` | Check Gmail API auth status |
| `gmail_list_rules` | List email processing rules |
| `gmail_delete_rule` | Delete an email rule |

### Audit
| Tool | Description |
|---|---|
| `audit_get_entity_history` | Full change history for any entity |

## Common Workflows

### Full Period Close-Out
```
1. accounting_workspace_snapshot → baseline
2. lifecycle_run_matcher → match all
3. recon_supplier → reconcile suppliers
4. recon_bank → reconcile banks
5. recon_vat → verify VAT
6. handover_generate_period_pack → build pack
```

### Query Sage Data
Use `accounting_workspace_snapshot` or direct table queries to inspect:
- Supplier accounts (creditors)
- Customer accounts (debtors)
- Bank accounts
- Inventory
- Tax (VAT)
- General ledger

## Key Files
- `backend/mcp/server.py` — MCP server definition (all 29 tools)
- `backend/mcp/_shared.py` — shared helpers
- `backend/api/routers/` — underlying API routers
- `backend/core/sage_api/client.py` — Sage v2 API client
