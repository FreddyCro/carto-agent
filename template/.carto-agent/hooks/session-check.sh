#!/usr/bin/env bash
# CartoAgent Session Check
# 每次 session 開始時執行，檢查未關閉工作檔和 nodes.yaml 過時狀態。
# 只在發現問題時輸出提醒，無問題則靜默。

set -euo pipefail

DOCS_TMP="docs/tmp"
NODES_YAML="docs/nodes.yaml"
STALENESS_THRESHOLD=50

output=""

# ─── Check 1: 未關閉的工作檔 ───
if [ -d "$DOCS_TMP" ]; then
  work_files=$(find "$DOCS_TMP" -maxdepth 1 -name "*.md" ! -name "draft.md" 2>/dev/null || true)
  if [ -n "$work_files" ]; then
    file_list=$(echo "$work_files" | xargs -I{} basename {} | head -5 | tr '\n' ', ' | sed 's/,$//')
    output+="⚠️ 未關閉的工作檔: ${file_list}"$'\n'
    output+="  👉 繼續工作或執行 /ca-close {id} 收尾"$'\n'
  fi
fi

# ─── Check 2: nodes.yaml 過時檢查 ───
if [ -f "$NODES_YAML" ] && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  last_commit=$(git log -1 --format="%H" -- "$NODES_YAML" 2>/dev/null || true)
  if [ -n "$last_commit" ]; then
    distance=$(git rev-list --count "${last_commit}..HEAD" 2>/dev/null || echo "0")
    if [ "$distance" -ge "$STALENESS_THRESHOLD" ]; then
      output+="💡 nodes.yaml 已有 ${distance} 個 commit 未更新"$'\n'
      output+="  👉 建議執行 /ca-navigate refresh 重新偵察"$'\n'
    fi
  fi
fi

# ─── 輸出結果（只在有問題時） ───
if [ -n "$output" ]; then
  echo "── CartoAgent Session Check ──"
  echo "$output"
fi
