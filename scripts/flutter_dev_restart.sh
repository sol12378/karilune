#!/usr/bin/env bash
# Flutter 開発サーバーをバックグラウンドで再起動する。
# ターミナルが見えない環境でも Chrome に変更を反映できる。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
LOG="/tmp/carilune_flutter.log"

if pgrep -f "flutter_tools.snapshot run -d chrome" >/dev/null 2>&1; then
  pkill -f "flutter_tools.snapshot run -d chrome" || true
  sleep 1
fi

nohup flutter run -d chrome >>"$LOG" 2>&1 &
disown 2>/dev/null || true

echo "Flutter restarted. Log: ${LOG}"
