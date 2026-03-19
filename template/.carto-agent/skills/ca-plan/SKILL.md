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

### Step 2: 架構定位 + 查歷史知識

向使用者回報：「正在委託 @ca-explorer 定位架構...」

委託 `@ca-explorer` subagent 執行以下查詢（研究過程不佔主 context）：

1. 從 issue 描述或 branch 名稱辨識目標模組名稱
2. 向 `@ca-explorer` 發送：`模組定位 {module}` + `查歷史 {module}`
3. 如模組不存在於 nodes.yaml → 依 `/ca-navigate` auto-register 邏輯註冊後重新查詢
4. **Drift Check**：向 `@ca-explorer` 發送 `drift check`
5. **Drift 自動修復**：如 drift check 回傳未登記模組清單：
   - ≤ 3 個 → 依 `/ca-navigate` auto-register 邏輯自動註冊，在摘要中提示已處理
   - \> 3 個 → 列出清單，建議使用者執行 `/ca-scout --full` 重新掃描

subagent 會回傳結構化摘要，直接輸出給使用者：
  ```
  📍 {module}
    path:  {path}
    group: {group}
    comm:  [{mechanisms}]
    edges: [{dependencies}]

  📚 相關 ADR:
    - ADR-{id}: {title} — {decision 摘要}

  ⚠️ 已知 gotchas:
    - {gotcha 摘要}
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

### Step 5: 規劃/定位（依 Tier 分流）

**Tier 1 — 定位問題**
- 根據使用者描述找到相關檔案
- 開始修復，遵循 constitution file 中的 Coding Conventions

**Tier 2 — PLAN.md**
- 建立 `docs/tmp/{ticket-id}-PLAN.md`（使用 `docs/adr/_TEMPLATE-PLAN.md` 格式）
- 呈現影響的檔案、關鍵決策、風險，供使用者審閱

### Step 6: 實作（依 Tier 分流）

**Tier 1 — 主代理直接修**
- 遵循 constitution file 中的 Coding Conventions
- 遵循 constitution file 中的 Key Paths 尋找正確的檔案位置

**Tier 2 — 委託 @ca-worker**

向使用者回報：「正在組裝 context card，準備委託 @ca-worker 實作...」

主代理組裝 context card，委託 `@ca-worker` subagent 在 worktree 隔離環境中實作：

1. 組裝 context card：
   ```markdown
   ## Goal
   {從 PLAN.md 摘要本次任務目標}

   ## Task
   {PLAN.md 中的 checklist，逐步列出}

   ## File Scope
   {PLAN.md Key Files 中列出的檔案路徑}

   ## Architecture Context
   {Step 2 @ca-explorer 回傳的模組摘要：edges、comm、相關 ADR}

   ## Conventions
   {從 constitution file 提取：commit style、file naming、test/lint 指令}

   ## Verification
   {PLAN.md Verification section 的檢查項目}
   ```

2. 派工給 `@ca-worker`（isolation: worktree）
3. 向使用者回報：「@ca-worker 正在 worktree 中實作，請稍候...」
4. 收到回報後，向使用者回報結果並處理：
   - **DONE** → 「@ca-worker 完成：{修改的檔案數} 個檔案，test {pass/fail}」→ 進入 Step 7
   - **FAIL** → 「@ca-worker 失敗：{原因摘要}」→ 決定調整 card 重派或主代理接手
   - **BLOCKED** → 「@ca-worker 被阻塞：{問題}」→ 處理阻塞，解除後重派

### Step 7: 驗證

**Tier 1**
- 執行 constitution file 中定義的 test 指令
- 執行 constitution file 中定義的 lint 指令

**Tier 2**
- 檢查 @ca-worker 回報的 test/lint 結果
- 如 ca-worker 回報 pass，主代理做 sanity check（抽檢關鍵檔案）
- 如修改涉及互動行為且有 e2e 指令，提醒使用者執行
- 列出建議的手動驗證案例

### Step 8: 收尾

- 按 constitution file 中「收尾標準步驟」執行
- Tier 1（可選）：non-obvious 發現加到 `docs/map/gotchas.md`
- Tier 2：
  - 同步新 gotchas 到 `docs/map/gotchas.md`
  - 更新 PLAN.md 中的 Verification checkbox
