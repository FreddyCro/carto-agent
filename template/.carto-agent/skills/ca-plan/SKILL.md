---
name: ca-plan
description: 統一工作流入口（Tier 1-2 routing）
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, TodoWrite, AskUserQuestion
---

## `/ca-plan` — 統一工作流入口

所有開發任務從 `/ca-plan` 進入，根據子指令和 issue 內容自動分流到對應 Tier。

### Workflow 狀態列

每個 Step 開始時，輸出一行狀態列讓使用者掌握整體進度：

```
⚡ [✅ 建檔] → [🔄 偵察] → [⏳ 分流] → [⏳ 釐清] → [⏳ 規劃] → [⏳ 實作] → [⏳ 驗證] → [⏳ 收尾]
```

> 「釐清」僅在 Tier 2 觸發；Tier 1 直接從「分流」進「實作」。

符號說明：✅ 完成 / 🔄 進行中 / ⏳ 待執行

委託 subagent 時，在狀態列下方加一行細節：
```
🔍 ca-explorer: {正在做的事}
⚙️ ca-worker: {正在做的事}
```

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

### Step 4: 釐清與方案（Tier 2 only）

> **不可跳過。** 在投入 PLAN.md 與 worktree 前，先把模糊處問清楚、把方向選定。改方向在這裡只是改文字，到實作後才改成本最高。
>
> Tier 1 跳過此步驟，直接進 Step 5。

**4a. 釐清 ambiguity**

根據 Step 2 的架構摘要和 issue 內容，整理出**未明確的決策點**，向使用者提問。重點涵蓋：

- **Edge case**：邊界條件、空值 / 大量資料 / 並發情境如何處理？
- **Error handling**：失敗時的預期行為（throw / fallback / 靜默）？
- **Scope 邊界**：哪些明確「不做」？是否觸及 nodes.yaml 中的相鄰模組？
- **相容性**：是否需向後相容？影響現有 API / 資料格式嗎？

用 `AskUserQuestion` 列出問題（Claude Code）；其他 agent 以條列問題請使用者回答。**收齊答案才進 4b。** 若使用者答「你決定」，則記錄你的假設，供 Step 5b 覆核。

**4b. 提出 2-3 個方案 + 推薦**

針對核心實作方向，列出 2-3 個方案，每個附 trade-off，並標記推薦：

```
方案比較：

A.（推薦）{方案名}
   - 做法：{一句話}
   - 優點：{...}
   - 取捨：{成本 / 風險 / 限制}

B. {方案名}
   - 做法 / 優點 / 取捨：{...}

C. {方案名}（如有）
   - ...

→ 推薦 A，因為 {貼合本專案 context 的理由}。
```

請使用者選定方案（可選 A/B/C 或提出調整）。**選定的方案會寫進 PLAN.md 的 Decision，並在 /ca-close 寫 ADR 時直接填入 Alternatives 欄位**——釐清與比較的成本不會白費。

### Step 5: 規劃/定位（依 Tier 分流）

**Tier 1 — 定位問題**
- 根據使用者描述找到相關檔案
- 開始修復，遵循 constitution file 中的 Coding Conventions

**Tier 2 — PLAN.md**
- 建立 `docs/tmp/{ticket-id}-PLAN.md`（使用 `docs/adr/_TEMPLATE-PLAN.md` 格式）
- 將 Step 4b 選定的方案寫入 Decision，未選中的方案連同取捨填入 Alternatives 欄位
- 將 Step 4a 收齊的釐清結論（edge case / error handling / scope 邊界）反映到 Task 與 Verification
- 呈現影響的檔案、關鍵決策、風險，供使用者審閱

### Step 5b: Human Checkpoint — Q1: 我理解這段程式碼嗎？

> 派工前攔截 — 攔截成本最低的點，改方向只是改文字。

向使用者提示：

```
🧠 Q1: 你理解這段規劃嗎？

Tier 2: 讀 PLAN.md，能解釋每個決策的 why 嗎？
  - 為什麼選這個方案而不是替代方案？
  - Agent 引入了哪些你不熟悉的 pattern？
  - 這個改動跟現有架構如何互動？

Tier 1: 讀修復方向，能解釋改了什麼、為什麼嗎？
  - 這個 fix 的 side effect 是什麼？
  - 為什麼改這裡就能修好？

→ 如果無法解釋，退回重新理解再繼續。
```

確認理解後，明確徵求派工批准：

```
✅ 確認方向正確、批准進入實作？(Y/n)

  - Tier 2：批准後才組裝 context card 派工 @ca-worker
  - 如要調整方案，現在回 Step 4 重選成本最低
```

**收到明確批准（Y）才進入 Step 6**。未獲批准前不得派工或動 code。若使用者已在 Step 4b 選定方案，可將該選定視為批准，但仍需在此回報「即將依方案 {X} 派工」並給一次喊停的機會。

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

### Step 7b: Human Checkpoint — Q2: 風險在哪？

> 驗證通過後攔截 — 最後的低成本修正機會，commit 前改 code 很容易。

自動驗證都過了，向使用者提示評估 prod 風險：

```
⚠️ Q2: 風險在哪？

環境差異:
  - 這段 code 在 prod 環境會怎麼跑？
  - 有沒有 CI 測不到的環境因素（browser / CDN / 第三方整合）？

Agent 假設:
  - Agent 是否假設了某些條件（同步執行、特定 API、特定版本）？
  - 是否有未驗證的隱含假設？

爆炸半徑:
  - 只影響單一模組？還是跨模組連鎖（檢查 nodes.yaml edges）？
  - 改了 shared util？downstream 影響範圍？

→ 如果風險值得記錄 → /ca-close 時 opt-in ADR
```

### Step 8: 收尾

- 按 constitution file 中「收尾標準步驟」執行
- Tier 1（可選）：non-obvious 發現加到 `docs/map/gotchas.md`
- Tier 2：
  - 同步新 gotchas 到 `docs/map/gotchas.md`
  - 更新 PLAN.md 中的 Verification checkbox
