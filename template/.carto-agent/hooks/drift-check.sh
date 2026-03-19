#!/usr/bin/env bash
# CartoAgent Drift Check
# 比對 carto-agent.config.yaml 中 key_paths.modules 的實際目錄
# 與 nodes.yaml 已登記的模組，找出未登記模組。
# 差異 > 3 時輸出提醒，≤ 3 靜默。

set -euo pipefail

CONFIG="carto-agent.config.yaml"
NODES_YAML="docs/nodes.yaml"
DRIFT_THRESHOLD=3

if [ ! -f "$CONFIG" ] || [ ! -f "$NODES_YAML" ]; then
  exit 0
fi

# 從 nodes.yaml 提取已登記的模組名稱
registered=$(grep -E "^\s+-?\s*name:" "$NODES_YAML" 2>/dev/null | sed 's/.*name:\s*//' | tr -d '"' | tr -d "'" || true)

# 從 config 提取 modules 路徑（簡易 YAML 解析）
in_modules=false
module_paths=()
while IFS= read -r line; do
  if echo "$line" | grep -qE "^\s*modules:"; then
    in_modules=true
    continue
  fi
  if $in_modules; then
    if echo "$line" | grep -qE "^\s*-\s"; then
      path=$(echo "$line" | sed 's/.*-\s*//' | tr -d '[]"' | tr -d "'")
      module_paths+=("$path")
    else
      in_modules=false
    fi
  fi
done < "$CONFIG"

if [ ${#module_paths[@]} -eq 0 ]; then
  exit 0
fi

# 掃描實際目錄，找出模組名稱
unregistered=()
for mod_path in "${module_paths[@]}"; do
  if [ ! -d "$mod_path" ]; then
    continue
  fi
  for dir in "$mod_path"*/; do
    [ -d "$dir" ] || continue
    mod_name=$(basename "$dir")
    if ! echo "$registered" | grep -qx "$mod_name"; then
      unregistered+=("$mod_name")
    fi
  done
done

count=${#unregistered[@]}

if [ "$count" -gt "$DRIFT_THRESHOLD" ]; then
  echo "⚠️ Drift detected: ${count} 個模組尚未登記在 nodes.yaml"
  # 最多顯示 5 個
  for mod in "${unregistered[@]:0:5}"; do
    echo "  - ${mod}"
  done
  if [ "$count" -gt 5 ]; then
    echo "  ... 還有 $((count - 5)) 個"
  fi
  echo "  👉 建議執行 /ca-navigate refresh 重新偵察"
fi
