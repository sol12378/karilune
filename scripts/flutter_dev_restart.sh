#!/usr/bin/env bash
# Flutter Web 開発サーバーを localhost で再起動する。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
LOG="/tmp/carilune_flutter.log"
PORT="${FLUTTER_WEB_PORT:-8080}"
HOST="${FLUTTER_WEB_HOST:-localhost}"

if pgrep -f "flutter_tools.snapshot run" >/dev/null 2>&1; then
  pkill -f "flutter_tools.snapshot run" || true
  sleep 1
fi

nohup flutter run -d web-server \
  --web-port="$PORT" \
  --web-hostname="$HOST" \
  >>"$LOG" 2>&1 &
disown 2>/dev/null || true

echo "Flutter web-server restarted."
echo "URL: http://${HOST}:${PORT}"
echo "Log: ${LOG}"
