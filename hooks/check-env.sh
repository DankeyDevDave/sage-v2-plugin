#!/usr/bin/env bash
# Warn if editing .env files (contains secrets)
FILE="$1"
if echo "$FILE" | grep -q "\.env"; then
  echo "⚠️  Warning: Editing .env file — contains API keys and secrets. Never commit .env files."
fi
