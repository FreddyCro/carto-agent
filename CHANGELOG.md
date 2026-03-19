# Changelog

All notable changes to CartoAgent will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/).

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
