# CartoAgent 優化計畫

> 原則：script > md > prompt — 能不佔 context 就不佔。
> 方向：漸進式採用 Orchestrator-Worker 模式，主代理逐步退出實作。

---

## 已完成

- [x] nodes.yaml schema 完整化 — 加入必填/選填標示、值域定義、conventions schema
- [x] Drift Detection — hooks + subagent 兩層偵測

### Phase 1: CLAUDE.md 瘦身

- [x] Dev Commands 精簡（引用 package.json）
- [x] Key Paths 精簡（引用 config）
- [x] Knowledge Rules 保留內嵌（3 行不值得外拆）

### Phase 2: Hooks 導入

- [x] session-check.sh（未關閉工作檔 + staleness）
- [x] drift-check.sh（模組漂移偵測）
- [x] .claude/settings.json hooks 設定
- [x] skill prompt 中的機械性檢查改為呼叫 script

### Phase 3: ca-explorer subagent

- [x] 唯讀架構查詢 subagent（haiku 模型）
- [x] /ca-plan 架構定位 + 歷史知識查詢委託 @ca-explorer
- [x] /ca-close 變更分析委託 @ca-explorer

---

## Phase 4: Orchestrator-Worker 分工

> 參考：Anthropic Orchestrator-Worker Pattern、DDD coordinator 模式、Agent Teams Lite
>
> 核心理念：主代理的 context 是最珍貴的資源。
> 規劃需要連續的 session context，但實作是可分解的 — 交給 subagent 做。

### SDLC 角色分析 — 為什麼是 2 個 subagent

從 SDLC 角度拆解 AI agent 的工作為三種角色：

| 角色 | 職責 | 對應 | 為什麼不能合併 |
|------|------|------|----------------|
| **DECIDES** | 理解需求、規劃、決策、與使用者對話 | 主代理 | 需要完整 session context |
| **READS** | 架構查詢、歷史知識、code review | @ca-explorer | 唯讀、低成本模型（haiku）、可頻繁呼叫 |
| **WRITES** | 實作 code、修改檔案、跑 test | @ca-worker | 需要寫入權限、worktree 隔離、高品質模型 |

**為什麼不是 1 個 subagent？**
- READS 和 WRITES 的模型需求不同（haiku vs 主模型）、權限不同（唯讀 vs 讀寫）、隔離需求不同（無 vs worktree）
- 合併會失去 ca-explorer 低成本高頻呼叫的優勢

**為什麼不是 3 個（加 ca-reviewer）？**
- Code review 本質是 READS — ca-explorer 用不同 prompt 即可執行 review
- 獨立 reviewer 增加使用者心智負擔（多一個要理解的元件），收益不明顯

### 設計原則

1. **使用者體驗不變** — 仍然只有 `/ca-plan` + `/ca-close`，分工是內部實作細節
2. **Tier 決定分工深度** — Tier 1 不需要 orchestrator 開銷，Tier 2 才啟用
3. **2 subagent = 最小 SDLC 覆蓋** — READS + WRITES 分離，主代理專注 DECIDES
4. **失敗安全** — subagent 失敗時主代理可以接手，不會卡住

### 4a. ca-worker subagent — Tier 2 實作委託

目標：Tier 2 的 PLAN.md 確認後，主代理不再親自寫 code，改為逐步委託 ca-worker。

- [x] 建立 `.carto-agent/agents/ca-worker.md`
  - tools: Read, Grep, Glob, Edit, Write, Bash
  - model: 繼承主對話模型（不降級，實作品質不能打折）
  - isolation: worktree（git worktree 隔離，不影響主分支）
  - maxTurns: 30
- [x] ca-worker 的 system prompt 設計：
  - 輸入：接收 context card（見 4b）
  - 輸出：DONE / FAIL / BLOCKED 三態回報
  - 約束：只修改 context card 指定的檔案範圍
  - 約束：遵循 constitution file 的 Coding Conventions
  - 約束：完成後必須執行 test + lint 並回報結果
- [x] `/ca-plan` Tier 2 流程調整：
  - Step 5（PLAN.md）不變 — 主代理建立計畫，使用者審閱
  - Step 6（實作）改為：主代理組裝 context card → 派 ca-worker → 收結果
  - Step 7（驗證）不變 — 主代理驗證 ca-worker 的產出
  - Step 8（收尾）不變

### 4b. Context Card 設計

> 借鏡 DDD 的 worker context card — 讓 subagent 不需要問主代理就能獨立完成。

每次派工時，主代理組裝一張 context card 給 ca-worker：

```markdown
## Goal
{從 PLAN.md 摘要本次任務目標}

## Task
{具體的實作步驟 checklist，從 PLAN.md 對應段落}

## File Scope
{允許修改的檔案路徑列表}

## Architecture Context
{從 @ca-explorer 查詢結果：目標模組的 edges、comm、相關 ADR 摘要}

## Conventions
{從 constitution file 提取：commit style、file naming、test/lint 指令}

## Verification
{完成後必須執行的驗證步驟}
```

- [x] 定義 context card 格式
- [x] `/ca-plan` Step 6 加入 context card 組裝邏輯
- [ ] 驗證：ca-worker 拿到 card 後能獨立完成任務，不需要回問

### 4c. Tier 分工矩陣

| | Tier 1: Quick Fix | Tier 2: Planned Task |
|---|---|---|
| **架構定位** | @ca-explorer | @ca-explorer |
| **規劃** | 主代理直接定位 | 主代理建 PLAN.md |
| **實作** | 主代理直接修 | @ca-worker（worktree 隔離） |
| **驗證** | 主代理跑 test | 主代理驗證 ca-worker 產出 |
| **收尾** | 主代理 | 主代理 |

Tier 1 不委託實作的原因：
- 單檔修改，context 消耗小
- 派 subagent 的啟動延遲反而比直接修還慢
- Quick Fix 的核心價值是「快」

### 4d. 失敗處理

- ca-worker 回報 DONE → 主代理驗證 test 結果，通過則合併 worktree
- ca-worker 回報 FAIL → 主代理讀取失敗原因，決定：
  - 調整 context card 重新派工
  - 或主代理自己接手完成
- ca-worker 回報 BLOCKED → 主代理處理阻塞（如需要使用者決策），解除後重新派工

### 4e. 效益預估

| 指標 | 現在（Phase 3） | Phase 4 完成後 |
|------|----------------|---------------|
| 主對話 context 消耗 | 規劃 + 實作 + 驗證 | 規劃 + 驗證（實作在 subagent） |
| Tier 2 大功能的降智風險 | 高（實作過程吃 context） | 低（實作隔離在 worktree） |
| 使用者需要記的指令 | /ca-plan + /ca-close | /ca-plan + /ca-close（不變） |

---

## 不做的事

- **自動觸發 skill** — 兩個指令已夠直覺，過度自動化降低掌控感
- **強制 TDD** — 維持 Tier 分流彈性
- **獨立 ca-reviewer subagent** — code review 本質是 READS，ca-explorer 用不同 prompt 即可執行，獨立 reviewer 增加元件數但收益不明顯
- **雙重審查** — DDD 的 Gemini+Claude 模式太重，單次 review 夠用
- **並行 worker** — DDD 的 🔀 並行標記 + 多 worktree 並行對中小專案過重，等有實際需求再考慮
- **MCP Server** — subagent 方案更輕量
- **Sprint 文件結構** — DDD 的 spec/tasks/works 對 CartoAgent 太重，維持 PLAN.md + ADR
