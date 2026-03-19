---
description: 載入模組完整開發上下文（路由 + ADR + 焦點圖）+ auto-register + 同步拓撲圖
---

## `/ca-navigate` — 節點上下文載入 + 拓撲同步

載入模組的完整開發上下文，並自動同步拓撲圖。

### 使用方式

| 用法 | 說明 |
|------|------|
| `/ca-navigate {module}` | 載入模組上下文 + auto-register + 更新拓撲圖 |
| `/ca-navigate` | 全量偵察，產生所有拓撲圖 |
| `/ca-navigate refresh` | 重新偵察全部模組，更新 nodes.yaml 和拓撲圖 |

---

### /ca-navigate {module}

#### Step 1: 查找節點

讀取 `docs/nodes.yaml`，查找目標模組。支援模糊匹配。

#### Step 2: Auto-Register（如果模組不存在）

如果目標模組不在 nodes.yaml 中，自動註冊：

1. 讀取 `docs/nodes.yaml` 的 `conventions` 區塊
   - 如果沒有 conventions → 提示使用者先執行 `/ca-scout`
2. 用 conventions 分析目標模組：
   - **path**：從 `component_patterns` 匹配目標模組的目錄路徑
   - **group**：依目錄語義和所在 package 推斷
   - **comm**：依 `comm_signals` 偵測通訊機制（type / target / description）
   - **edges**：分析 import statements 和依賴關係
   - **refs**：掃描 ADR INDEX 中是否提及此模組
3. edges 指向的模組如果也不存在 → 建立 stub（只有 path + group）
4. 將新 entry 寫入 nodes.yaml
5. 告知使用者：
   ```
   ⚡ Auto-registered: {module}
     path: {path}
     group: {group}
     comm: [{mechanisms}]
     edges: [{dependencies}]
     refs: [{references}]
   ```

#### Step 3: 同步 docs/map/

每次 `/ca-navigate` 都重新生成拓撲圖：
- `docs/map/L3-component.md` — 全貌圖
- `docs/map/L3-communication.md` — 通訊架構圖
- `docs/map/L4-infrastructure.md` — 基礎設施圖

#### Step 4: 顯示路由資訊

輸出結構化摘要：

```
📍 {module}
  Group: {group}
  Comm:  [{mechanisms}]
  Edges: [{dependencies}]
  Refs:  [{references}]
```

#### Step 5: 讀取相關知識

透過 `refs` 和模組名稱查找相關知識：

- 到 `docs/adr/INDEX.md` 搜尋相關 ADR，讀取 Decisions 和 Gotchas
- 到 `docs/map/gotchas.md` 搜尋相關記錄

#### Step 6: 輸出焦點圖

即時生成焦點圖（目標模組高亮 + edges 鄰居 + 反向 edges）。

---

### /ca-navigate（全量產生）

1. 讀取 `docs/nodes.yaml` 中所有 nodes
2. 產生 `docs/map/L3-component.md`、`L3-communication.md`、`L4-infrastructure.md`

### /ca-navigate refresh（全量重新偵察）

1. 重新掃描專案結構（同 `/ca-scout` 偵察邏輯）
2. 重新分析所有模組的 comm、edges、refs
3. 覆寫 `docs/nodes.yaml`
4. 重新產生所有拓撲圖

### Staleness Hint

每次執行 `/ca-navigate`（任何模式）時，進行輕量過時檢查：

1. 執行 `git rev-list --count HEAD` 取得目前 commit 總數
2. 檢查 `docs/nodes.yaml` 最後修改的 commit：`git log -1 --format="%H" -- docs/nodes.yaml`
3. 計算距離：`git rev-list --count {last-modify-commit}..HEAD`
4. 如距離 **≥ 50 commits** → 在輸出末尾加上提示：
   ```
   💡 nodes.yaml 已有 {N} 個 commit 未更新，建議執行 /ca-navigate refresh 重新偵察
   ```
5. 如距離 < 50 → 靜默跳過

---

### Node Schema

```yaml
- name: {module-name}
  path: {relative-path}
  group: {group-name}
  comm:
    - type: {import | rest-api | workspace-dep | event | proxy}
      target: {target-module}
      description: {描述}
  edges:
    - {dependency-module-name}
  refs:
    - {relative-path-to-related-file}
```

### Output Files

| 檔案 | 內容 |
| --- | --- |
| `docs/nodes.yaml` | 模組路由表（新增/更新 nodes） |
| `docs/map/L3-component.md` | 全貌圖（Mermaid flowchart） |
| `docs/map/L3-communication.md` | 通訊架構圖 |
| `docs/map/L4-infrastructure.md` | 基礎設施圖 |
