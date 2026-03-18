---
name: linear-issues
description: Manage Linear issues for sage_v2 project. Use when asked to create, update, close, or list Linear issues, check bug status, or track project work.
---

Manage Linear issues for the sage_v2 (Sage v2) project using the Linear MCP server.

## Configuration
- **Team:** `JAC` (ID: `2ed647a5-8d87-4e9e-a498-dd41738da252`)
- **Project:** `Sage v2` (ID: `dedf1e00-a36d-4a09-85ad-3616a3885620`)
- **MCP Server:** `linear` — available via the plugin's MCP config

## Available MCP Tools (via `linear` MCP server)
Use the Linear MCP tools directly — they handle authentication and API calls:
- Create issues
- Update issues (status, assignee, labels, priority)
- List issues with filters
- Add comments
- Manage project membership

## Key Labels (mutually exclusive — pick ONE per issue)
| Label | ID | Group |
|---|---|---|
| `urgent` | `ea99605e-0deb-42a5-a51d-adeeeac89613` | priority |
| `bug` | `d6b8bbd5-65ab-41b7-9d39-d335c2b31f52` | type |
| `feature` | `68e0b3bd-4e64-4b27-ae84-803dff34d86d` | type |
| `backend` | `30fe5550-b905-4f7f-8c48-7eaaafaa9662` | component |
| `pipeline` | `ed7d20ee-6fe7-41d7-9e99-5386631db158` | component |
| `frontend` | `cf25a69c-ff5d-477a-9bf7-245f08e4507c` | component |
| `maintenance` | `eca20d02-82c4-430a-a815-1acc4ad69745` | type |

## Workflow States
| State | ID |
|---|---|
| In Progress | `d5ab0f80-16c3-4189-9173-bb92069d6d95` |
| Done | `4cd2cc78-f967-4c1b-93e7-370ae993b046` |

## Priority Levels
| Priority | Meaning |
|---|---|
| 0 | Critical — security, data loss, broken builds |
| 1 | High — major features, important bugs |
| 2 | Medium — default, nice-to-have |
| 3 | Low — polish, optimization |
| 4 | Backlog — future ideas |

## Convention
- Issue titles: `<Component>: <short description>` (e.g., "Pipeline: startup scan missing CSV extension")
- Always include `## Problem`, `## Evidence`, `## Fix`, `## Files` sections in descriptions
- Link discovered issues with `discovered-from` references
- Close issues with reason when resolved

## Current Open Issues (as of 2026-03-17)
| ID | Priority | Title |
|---|---|---|
| JAC-86 | High | scan-watch-folder API: support image/PDF ingestion |
| JAC-87 | High | Support ingesting pre-extracted invoice JSON into pipeline |
| JAC-88 | High | LLM Judge: Z.AI key insufficient balance — graceful degradation |
| JAC-109 | High | Daemon: silent crash on Gemini API timeout with no recovery |
| JAC-110 | Medium | Pipeline: startup scan missing .csv/.xlsx/.xls (fix applied) |
| JAC-111 | Low | Pipeline: empty/broken PDF causes 'no pages' error |
| JAC-112 | High | LLM Judge: add supplier_transactions_report prompt template |
| JAC-113 | Medium | VAT reconciliation: float * Decimal type error |
| JAC-114 | Medium | Sentry metrics API: tags→attributes (fix applied) |
