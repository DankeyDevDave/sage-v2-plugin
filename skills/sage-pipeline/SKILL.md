---
name: sage-pipeline
description: Control the sage_v2 processing pipeline via MCP — replay, ingest, snapshot, sanitize, verify, and build handover packs. Use when asked to run the pipeline, replay processing, ingest files, or manage pipeline state.
---

Control the sage_v2 processing pipeline via the `sage-pipeline` MCP server (12 tools).

## MCP Server: `sage-pipeline`
Runs via: `python /Users/jacques/DevFolder/sage_v2/scripts/sage_pipeline_mcp.py`

## Available MCP Tools

### Pipeline State
| Tool | Description |
|---|---|
| `pipeline_status` | Current DB counts, queue state, archive file list |
| `pipeline_snapshot` | Phase 1: Capture pre-reset baseline (row counts, file hashes) |
| `pipeline_manifest` | Phase 2: Discover/load source files, return manifest |
| `pipeline_sanitize` | Phase 3: Wipe DB + processing dirs (destructive, requires `apply=True`) |
| `pipeline_verify` | Phase 4: Confirm zero-state after sanitize |

### Pipeline Execution
| Tool | Description |
|---|---|
| `pipeline_replay` | Phase 5+6: Re-ingest source files and verify row counts |
| `pipeline_run` | Run all phases end-to-end (convenience wrapper) |
| `pipeline_report` | Phase 7: Generate markdown report + diff-summary.json |

### File Ingestion
| Tool | Description |
|---|---|
| `pipeline_ingest_file` | Drop a single file into watch-folder and ingest it |

### Handover
| Tool | Description |
|---|---|
| `pipeline_build_handover` | Build a handover pack from current DB state |

## Common Workflows

### Full Pipeline Replay (clean-room reset)
```
1. pipeline_snapshot    → save current state
2. pipeline_manifest    → discover source files
3. pipeline_sanitize(apply=True) → wipe everything
4. pipeline_verify      → confirm clean slate
5. pipeline_replay      → re-ingest all files
6. pipeline_report      → compare old vs new
```

### Single File Ingestion
```
pipeline_ingest_file(path="/path/to/invoice.pdf")
```

### Quick Status Check
```
pipeline_status → see DB counts and queue state
```

### Build Handover Pack
```
pipeline_build_handover → generate from current DB
```

## Key Files
- `scripts/sage_pipeline_mcp.py` — MCP server (all 12 tools)
- `backend/core/pipeline/manager.py` — pipeline orchestration
- `backend/core/ingestion/ingester.py` — document ingestion
- `backend/core/handover/pack_builder.py` — handover pack assembly

## Data Locations
- **DB:** `backend/data/unified_processing.db` (SQLite)
- **Watch folder:** `watch-folder/` (drop files here)
- **Processing:** `processing/` (in-flight documents)
- **Archive:** `archive/` (completed documents)
- **Logs:** `logs/` (daemon and pipeline logs)
