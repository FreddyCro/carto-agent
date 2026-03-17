---
description: 查看架構拓撲圖（唯讀，不寫入任何檔案）
---

## `/ca-map` — 架構拓撲圖查看

查看現有拓撲圖。此命令為**唯讀**，不寫入任何檔案。如需產生或更新拓撲圖，請使用 `/ca-navigate`。

### 使用方式

| 用法 | 說明 | 來源 |
|------|------|------|
| `/ca-map` | 全貌圖 | 讀取 `docs/map/L3-component.md` |
| `/ca-map {module}` | 焦點圖：目標模組 + 直接相依 | 從 nodes.yaml 即時計算 |
| `/ca-map comm` | 通訊架構圖 | 讀取 `docs/map/L3-communication.md` |
| `/ca-map group {group}` | 群組內部圖 | 從 nodes.yaml 即時計算 |
| `/ca-map infra` | 基礎設施圖 | 讀取 `docs/map/L4-infrastructure.md` |

---

### /ca-map（全貌圖）

1. 讀取 `docs/map/L3-component.md`
2. 輸出完整內容（包含 mermaid block）
3. 如檔案不存在，提示使用者先執行 `/ca-navigate` 產生

### /ca-map {module}（焦點圖）

從 nodes.yaml 即時計算，只包含：

1. **目標模組**本身
2. **出邊（depends on）**：目標模組的 `edges` 列出的所有模組
3. **入邊（depended by）**：所有 `edges` 包含目標模組的其他模組

生成規則：
- **目標模組上色**：如果 `{module}` 存在於 nodes.yaml，使用 `style {node} fill:#ff6b6b,color:#fff` 標示
- 如果 `{module}` 不在 nodes.yaml 中，提示使用者該模組尚未註冊，建議執行 `/ca-navigate {module}`
- 出邊用實線箭頭：`target --> dep`
- 入邊用反向實線箭頭：`upstream --> target`
- 每個節點標注 group 和 comm（如有）
- 不按 group 分 subgraph，改用扁平佈局讓焦點清晰
- 同時輸出模組摘要：name、path、group、comm、edges、refs

### /ca-map comm（通訊架構圖）

1. 讀取 `docs/map/L3-communication.md`
2. 輸出完整內容
3. 如檔案不存在，提示使用者先執行 `/ca-navigate`

### /ca-map group {group}（群組內部圖）

1. 從 `docs/nodes.yaml` 篩選指定 group 的 nodes
2. 即時生成群組內部依賴圖
3. 對外 edges 用淺色標示

### /ca-map infra（基礎設施圖）

1. 讀取 `docs/map/L4-infrastructure.md`
2. 輸出完整內容
3. 如檔案不存在，提示使用者先執行 `/ca-navigate`
