# Changelog

All notable changes to CartoAgent will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/).

---

## [0.7.0] - 2026-06-11

### PLAN 自我審查 + ca-worker 審卡

啟發自 obra/superpowers 的 brainstorming / writing-plans / executing-plans 三段式工作流。CA 的 Tier 2 鏈原本只有一道人類閘門（Step 5b 派工批准）和一個 feedback loop（/ca-close review → 實作，最貴的回退點）；本次在更便宜的位置補上兩個自動閘門：agent 呈計畫前先自查、worker 開工前先質疑。

參考：[Superpowers (obra)](https://github.com/obra/superpowers) — brainstorming / writing-plans / executing-plans

### Added
- `/ca-plan` Step 5a — PLAN 自我審查（Tier 2 only）：placeholder 殘留 / 前後矛盾 / 釐清結論遺漏 / scope 漂移，自行修正後才進 Step 5b
- `/ca-plan` Step 5 — 禁止 placeholder 規則：Task 寫到對 codebase 零熟悉的執行者可獨立完成
- `ca-worker` 工作流程加入「審卡」步驟：開工前批判性審查 context card，有 gap 回報 BLOCKED 不開工；規則新增「先質疑再動手」
- `_TEMPLATE-PLAN.md` Sprint section 加入 Task 撰寫標準提示

### Changed
- `/ca-plan` Step 6 BLOCKED 處理分流：審卡發現計畫 gap → 回 Step 4/5 修正後重派；其他阻塞照舊
- README Tier 分流圖更新：Tier 2 鏈呈現 自我審查（自迴圈）→ Q1 派工批准 → 審卡（回退釐清）三層閘門

### 設計決策
- **兩個新閘門都是 agent 自動執行，不增加人類互動** — 自我審查無發現一行帶過、審卡無 gap 直接開工，Tier 2 小任務不付額外等待
- **回退點往便宜處搬** — 自我審查在「改文字」階段攔、審卡在「派工前」攔，與既有原則（改方向在規劃階段成本最低）同向
- **不抄 superpowers 的強制 TDD 與 2-5 分鐘粒度** — 前者綁定開發方法論違反 agent-agnostic，後者由 PLAN 模板的 Sprint/Task 結構自然約束
- **Tier Gate 維持 CA 特色** — superpowers 所有任務走完整流程，CA 保留 Tier 1 免規劃通道

---

## [0.6.0] - 2026-06-09

### Clarifying Questions + 方案比較閘門

啟發自 Anthropic feature-dev plugin 的 Discovery / Clarifying Questions / Architecture Design 階段。CA 既有流程從 C4 定位直接進 PLAN.md，缺一個「規劃前釐清模糊處、比較方案」的閘門；Tier 2 任務尤其容易在 worker 投入 worktree 後才發現方向錯。

參考：[feature-dev plugin (claude-plugins-official)](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/feature-dev)

### Added
- `/ca-plan` Step 4 — 釐清與方案（Tier 2 only，標記不可跳過）
  - 4a 釐清 ambiguity（edge case / error handling / scope 邊界 / 相容性）
  - 4b 提出 2-3 個方案 + trade-off + 推薦，使用者選定後寫進 PLAN
- `_TEMPLATE-PLAN.md` 新增 Clarifications 與 Alternatives 欄位，選定方案直通 /ca-close 的 ADR Alternatives
- `/ca-plan` Workflow 狀態列加入「釐清」階段（Tier 1 跳過）

### Changed
- `/ca-plan` Step 5b 收尾從「理解確認」改為明確派工批准（Y/n）——理解 ≠ 批准，未獲批准不得派工

### 設計決策
- **釐清 + 方案併成單一 Step** — 兩者同屬「規劃前的方向收斂」，合併避免多一個停頓點
- **不抄 feature-dev 的 confidence 門檻** — CA 既有 🔴🟡🟢 嚴重度分級已是 noise filter，再加信心門檻冗餘
- **approval gate 換框而非新增** — Step 5b 本就 wait，只把語意從「你懂嗎」補成「你批准嗎」，零新增流程

---

## [0.5.0] - 2026-04-01

### Human Checkpoint: 部署前三問

AI Agent 產出的程式碼能通過 CI，但「綠色」不代表「安全」。嵌入三個 mental checkpoint 到工作流的自然停頓點，確保人類判斷介入。

參考：[Agent Responsibly (Vercel Blog)](https://vercel.com/blog/agent-responsibly)

### Added
- `/ca-plan` Step 5b — Q1: 我理解這段程式碼嗎？（派工前攔截）
- `/ca-plan` Step 7b — Q2: 風險在哪？（驗證通過後攔截）
- `/ca-close` Step 7b — Q3: 我願意為它負責嗎？（commit 建議前攔截）
- README「Human Checkpoint: 部署前三問」section
- Constitution file 收尾步驟補充三問提醒

### 設計決策
- **Mental checkpoint > 自動化 gate** — 三問的價值在人類思考，強制回答會退化成 rubber stamp
- **嵌在既有停頓點 > 新增步驟** — 不額外加流程，在已有的 plan review / verification / close 加上意識提醒
- **不可逆程度遞增** — Q1（改文字） → Q2（改 code） → Q3（影響團隊），對應越來越難回頭的動作

---

## [0.4.0] - 2026-03-20

### Workflow 狀態列 + Inspirations

### Added
- `/ca-plan` Workflow 狀態列 — 每個 Step 轉換時輸出一行 progress bar（✅/🔄/⏳），subagent 互動時加一行細節
- README Inspirations section — 記錄 CA 的設計靈感來源（C4 Model、Spec Kit、ADR、xyflow、Orchestrator-Worker、Unix Philosophy、Mermaid、Claude Code）

### 設計決策
- **Terminal 狀態列 > Mermaid 寫檔** — CA workflow 是線性序列，不需要複雜的流程圖；Terminal 直接印零 I/O 成本，使用者不需開 Markdown Preview
- **不加獨立 subagent** — 狀態回報是 DECIDES（主代理）的附帶行為，不需要第 3 個 subagent

---

## [0.3.0] - 2026-03-19

### 輕量化 + 現代化平衡

從「過度設計」和「2026 趨勢」兩個角度體檢後的調整。

### Added
- `/ca-close` Step 2b 品質快照 — 收尾時自動跑 test/lint，結果填入 issue comment
- `/ca-close` Step 4d Review Checklist — 從 constitution file 讀取使用者自訂的 review 項目，預設空（0 項檢查）
- Constitution file「Git Automation」section — commit/branch 自動化程度可選（suggest-only / auto）
- Constitution file「Review Checklist」section — 使用者自訂 review 項目（空 = 跳過）
- `write-guard.sh.example` — 選用的 PreToolUse 寫入護欄
- `/ca-plan` + `/ca-close` subagent 狀態回報指示 — 主代理在派工/完成時向使用者回報進度
- `/ca-plan` Step 2 drift 自動修復 — ≤3 個自動 register，>3 個引導 /ca-scout
- README nodes.yaml 完整 Schema 參考（collapsible）

### Changed
- Drift 偵測從兩層改為單層 — 移除 PostToolUse hook，只保留 /ca-plan Step 2 的 @ca-explorer drift check
- nodes.yaml schema 註解從 35 行精簡為 12 行（完整 schema 移至 README）
- config 新增 `git_automation` 區塊（commit: suggest-only, branch: manual）

### Removed
- `drift-check.sh` PostToolUse hook — drift 偵測統一由 ca-plan Step 2 @ca-explorer 執行，時機更好（開始工作前而非讀檔時）

---

## [0.2.0] - 2026-03-19

### Subagent 架構 — Orchestrator-Worker 模式

CartoAgent 引入 subagent 分工，從 SDLC 角色分析得出 2 個 subagent 為最適配置：

- **@ca-explorer (READS)** — 唯讀架構查詢 subagent（haiku 模型），負責模組定位、ADR/gotchas 歷史知識查詢、drift 偵測。低成本高頻呼叫，研究過程不佔主 context。
- **@ca-worker (WRITES)** — Tier 2 實作委託 subagent（主對話模型），在 worktree 隔離環境中接收 context card 獨立完成 code 修改，回報 DONE/FAIL/BLOCKED 三態結果。

核心理念：**主代理的 context 是最珍貴的資源。** 規劃需要連續的 session context（DECIDES），但查詢（READS）和實作（WRITES）是可分解的。

### Added

- `ca-worker.md` — Tier 2 實作 subagent（context card 驅動、File Scope 約束、test/lint 必驗證）
- `/ca-plan` Step 6 Tier 2 分流 — 主代理組裝 context card → 派 @ca-worker → 收結果驗證
- README Subagent 架構段落 + 設計原則第 8 條「Context 保護」

### Changed

- `/ca-plan` Step 7 依 Tier 分流驗證邏輯（Tier 1 主代理跑 test、Tier 2 檢查 ca-worker 回報）
- PLAN.md 加入 SDLC 角色分析（DECIDES/READS/WRITES）和 2-subagent 理由

### Phase 1-3 回顧（0.1.0 → 0.2.0 期間完成）

- Phase 1: CLAUDE.md 瘦身（Dev Commands 引用 package.json、Key Paths 引用 config）
- Phase 2: Hooks 導入（session-check.sh、drift-check.sh、settings.json hooks 設定）
- Phase 3: ca-explorer subagent（唯讀架構查詢、/ca-plan + /ca-close 委託）

---

## [0.1.0] - 2026-03-16

- 初始化專案：closed-loop workflow、7 個 ca-\* skills、nodes.yaml 架構索引、Tier 分流、agent-agnostic 設計
