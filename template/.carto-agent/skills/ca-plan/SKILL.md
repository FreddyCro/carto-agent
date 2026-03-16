---
description: 統一工作流入口（Tier 1-3 routing）
---

## `/ca-plan` — 統一工作流入口

所有開發任務從 `/ca-plan` 進入，根據子指令和 issue 內容自動分流到對應 Tier。

### 使用方式

| 指令 | Tier | 說明 |
| --- | --- | --- |
| `/ca-plan bug {id}` | 1 | Quick Fix，有 ticket |
| `/ca-plan bug` | 1 | Quick Fix，無 ticket |
| `/ca-plan {id}` | 2/3 | 規劃工作流，有 ticket |
| `/ca-plan` | 2/3 | 規劃工作流，無 ticket |

---

### Step 1: 建立工作檔案

- 有 issue ID → 建立 `docs/tmp/{issue-id}.md`，預填 issue URL（從 constitution file 的 Issue URL 格式）
- 請使用者將 issue 內容貼入該檔案
- 無 ticket 且非 bug → 建立 `docs/tmp/draft.md` 請使用者描述需求
- 無 ticket 且為 bug → 跳過此步驟

### Step 2: 架構定位

- 從 issue 描述或 branch 名稱辨識目標模組
- 讀取 `docs/nodes.yaml`，查找該模組
- 如不存在 → 依 `/ca-navigate` auto-register 邏輯註冊
- 輸出結構化摘要：
  ```
  📍 {module}
    Group: {group}
    Comm:  [{mechanisms}]
    Edges: [{dependencies}]
    Refs:  [{references}]
  ```
- 提示：`👉 需要焦點圖？執行 /ca-map {module}`

### Step 3: Tier Gate

| 條件 | 分流 |
| --- | --- |
| 子指令為 `bug` | → Tier 1 |
| 讀 issue 內容：單檔修改、明確 bug | → Tier 1（建議使用者確認） |
| 跨多檔、新模組、內部重構 | → Tier 2（ADR-lite） |
| 跨模組遷移、架構變更 | → Tier 3（完整 ADR + PLAN.md） |

### Step 4: 查歷史知識

- 讀取 `docs/adr/INDEX.md`，找相關模組的歷史 ADR
- 讀取 `docs/map/gotchas.md`，檢查是否有已知陷阱
- 如果有相關 ADR，讀取其 Decisions 和 Gotchas
- 如有 `docs/map/` 拓撲文件，查找相關模組上下文

### Step 5: 規劃/定位（依 Tier 分流）

**Tier 1 — 定位問題**
- 根據使用者描述找到相關檔案
- 開始修復，遵循 constitution file 中的 Coding Conventions

**Tier 2 — ADR-lite**
- 建立 ADR（使用 `docs/adr/_TEMPLATE-ADR.md` 格式）
- ADR 只記錄 issue 沒有的實作決策
- 呈現影響的檔案、關鍵決策、風險，供使用者審閱

**Tier 3 — 完整 ADR + PLAN.md**
- 建完整 ADR（同 Tier 2）
- 建立 `docs/tmp/{ticket-id}-PLAN.md`（使用 `docs/adr/_TEMPLATE-PLAN.md` 格式）
- 呈現供審閱

### Step 6: 實作

- 遵循 constitution file 中的 Coding Conventions
- 遵循 constitution file 中的 Key Paths 尋找正確的檔案位置

### Step 7: 驗證

- 執行 constitution file 中定義的 test 指令
- 執行 constitution file 中定義的 lint 指令
- 如修改涉及互動行為且有 e2e 指令，提醒使用者執行
- 列出建議的手動驗證案例

### Step 8: 收尾

- 按 constitution file 中「收尾標準步驟」執行
- Tier 1（可選）：non-obvious 發現加到 `docs/map/gotchas.md`
- Tier 2/3（必要）：
  - 檢查 ADR 是否需要根據實作結果更新
  - 更新 `docs/adr/INDEX.md`
  - 同步新 gotchas 到 `docs/map/gotchas.md`
  - 更新 PLAN.md 中的 Verification checkbox（Tier 3）
