#!/usr/bin/env bash
# ローカルプレビューサーバー（Chrome の file:// 制限を回避）
cd "$(dirname "$0")"
PORT="${1:-8765}"
echo ""
echo "  カリルネ HTMLモック"
echo "  → http://localhost:${PORT}"
echo ""
echo "  ブラウザで上記 URL を開いてください（Ctrl+C で停止）"
echo ""
python3 -m http.server "$PORT"
