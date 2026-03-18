# sage-v2 Agent Plugin

This directory is an **agent plugin** for the sage_v2 accounting pipeline.

## For any agent: read `SKILL_INDEX.md` first.

That file lists all skills, MCP servers, and scripts — everything you need to work autonomously on this pipeline.

## Directory layout

```
skills/          ← UNIVERSAL — read these on any platform
mcp.json         ← UNIVERSAL — MCP server config for any MCP client
scripts/         ← Referenced by skills — python/bash automation

commands/        ← Droid only — slash command wrappers
droids/          ← Droid only — subagent definitions
hooks/           ← Droid only — lifecycle hooks
.factory-plugin/ ← Droid only — plugin manifest
```

If you're on Claude Code, Cursor, Windsurf, OpenClaw, or any other platform: use `skills/` and `mcp.json`. Ignore the Droid-specific directories.

## MCP Servers

Connect to the 4 MCP servers defined in `mcp.json`:
- `linear` — issue tracking
- `sage-accounting` — 29 Sage v2 tools
- `sage-pipeline` — 12 pipeline tools
- `sentry` — 21 monitoring tools
