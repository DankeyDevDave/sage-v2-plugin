---
description: Start, stop, or restart the file watcher daemon
---

# Daemon Control

Manage the sage_v2 automation daemon.

**Arguments:** `$ARGUMENTS` — `start`, `stop`, `restart`, or `status`

## Commands

### Start
```bash
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate
export SAGE_PROJECT_ROOT="$(pwd)" PYTHONPATH="$(pwd):$PYTHONPATH"

nohup python -m backend.core.autonomous.daemon --no-orchestrator --no-gmail -v > logs/daemon_manual.log 2>&1 &
echo "Daemon PID: $!"
```

### Stop
```bash
pkill -f "backend.core.autonomous.daemon"
echo "Daemon stopped"
```

### Restart
```bash
pkill -f "backend.core.autonomous.daemon"; sleep 2
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate
export SAGE_PROJECT_ROOT="$(pwd)" PYTHONPATH="$(pwd):$PYTHONPATH"
nohup python -m backend.core.autonomous.daemon --no-orchestrator --no-gmail -v > logs/daemon_manual.log 2>&1 &
echo "Daemon restarted PID: $!"
```

### Status
```bash
ps aux | grep "backend.core.autonomous.daemon" | grep -v grep && echo "Running" || echo "Stopped"
tail -5 /Users/jacques/DevFolder/sage_v2/logs/daemon_manual.log
```

## Notes
- Daemon auto-scans watch-folder on startup (skips already-processed files)
- Supports: images (JPG/PNG), PDFs, CSVs, XLSX, JSON invoice files
- Uses Gemini vision fallback when OCR confidence < 0.55
- Known issue (JAC-109): may crash silently on Gemini timeout — monitor with `/sage-status`
