---
description: 統一工作流入口（Tier 1-2 routing）
---

## `/ca-plan` — 統一工作流入口

所有開發任務從 `/ca-plan` 進入，根據子指令和 issue 內容自動分流到對應 Tier。

### 使用方式

| 指令 | Tier | 說明 |
| --- | --- | --- |
| `/ca-plan bug {id}` | 1 | Quick Fix，有 ticket |
| `/ca-plan bug` | 1 | Quick Fix，無 ticket |
| `/ca-plan {id}` | 2 | 規劃工作流，有 ticket |
| `/ca-plan` | 2 | 規劃工作流，無 ticket |

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
- **Drift Check**：讀取 constitution file 中的 `key_paths.modules`，用 glob 掃描實際目錄，與 nodes.yaml 已登記的模組比對：
  - 如有 **3 個以上未登記模組** → 輸出提醒：
    ```
    ⚠️ Drift detected: {N} 個模組尚未登記在 nodes.yaml
      {列出未登記模組名稱，最多顯示 5 個}
      👉 建議執行 /ca-navigate refresh 重新偵察
    ```
  - 如差異 ≤ 3 → 靜默跳過，不打擾使用者
- 輸出結構化摘要：
  ```
  📍 {module}
    Group: {group}
    Comm:  [{mechanisms}]
    Edges: [{dependencies}]
    Refs:  [{references}]
  ```
- 提示：
  ```
  👉 想看這個模組在架構中的位置？執行 /ca-map {module}
  👉 想看全貌圖？執行 /ca-map
  ```

### Step 3: Tier Gate

| 條件 | 分流 |
| --- | --- |
| 子指令為 `bug` | → Tier 1 |
| 讀 issue 內容：單檔修改、明確 bug | → Tier 1（建議使用者確認） |
| 其他（跨多檔、新模組、重構、架構變更） | → Tier 2 |

### Step 4: 查歷史知識

- 讀取 `docs/nodes.yaml` 中目標模組的 `refs`，找相關 ADR
- 如 refs 有 ADR 引用，讀取對應 ADR 檔案的 Decisions 和 Gotchas
- 讀取 `docs/map/gotchas.md`，檢查是否有已知陷阱
- 如有 `docs/map/` 拓撲文件，查找相關模組上下文

### Step 5: 規劃/定位（依 Tier 分流）

**Tier 1 — 定位問題**
- 根據使用者描述找到相關檔案
- 開始修復，遵循 constitution file 中的 Coding Conventions

**Tier 2 — PLAN.md**
- 建立 `docs/tmp/{ticket-id}-PLAN.md`（使用 `docs/adr/_TEMPLATE-PLAN.md` 格式）
- 呈現影響的檔案、關鍵決策、風險，供使用者審閱

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
- Tier 2：
  - 同步新 gotchas 到 `docs/map/gotchas.md`
  - 更新 PLAN.md 中的 Verification checkbox
