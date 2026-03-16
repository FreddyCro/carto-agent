---
description: 偵察 codebase，建立 conventions 並 seed 代表性節點到 nodes.yaml（CartoAgent 初始化入口）
---

## `/ca-scout` — CartoAgent 偵察 + 初始化

初始化 CartoAgent：讀取 config、偵察 codebase、生成 constitution file、建立 nodes.yaml。

### 使用方式

| 用法 | 說明 |
|------|------|
| `/ca-scout` | 完整流程：config → preflight → discover → seed → visualize |
| `/ca-scout --dry-run` | 只 discover + 展示結果，不寫入 |
| `/ca-scout --full` | seed 所有模組（跳過 group 推斷，全標 unclassified） |

---

### Step 0: 讀取 Config

1. 讀取 `carto-agent.config.yaml`
   - 如不存在 → 進入互動模式，一問一答收集專案資訊，生成 config 檔
2. 根據 `agent.type` 決定 constitution file：
   - `claude-code` → `CLAUDE.md`
   - `cursor` → `.cursorrules`
   - `windsurf` → `.windsurfrules`
   - `generic` → `AGENT.md`
3. 生成 constitution file（從 config 填入模板，包含 Project Identity / Dev Commands / Coding Conventions / Workflow Tiers / Knowledge Rules / Key Paths）
4. 如果是 `claude-code`，將 `.carto-agent/skills/` 下的 skills 複製到 `.claude/skills/`（Claude Code 要求 skills 在 `.claude/skills/` 下）

### Step 1: Preflight

檢查 CA 骨架檔案，不存在則自動建立空殼：
- `docs/nodes.yaml`
- `docs/map/gotchas.md`
- `docs/adr/INDEX.md`
- `docs/adr/_TEMPLATE-ADR.md`
- `docs/adr/_TEMPLATE-PLAN.md`

輸出 preflight 結果清單（✅ 已存在 / 🔧 已建立）。

---

### Step 2: Discover

分三個 Phase。

#### Phase A — Conventions

讀取 `docs/nodes.yaml`。有 `conventions` 區塊則直接使用，沒有則推斷：

1. 依序讀取 constitution file → `README.md` → `package.json` → `tsconfig.json` → 目錄結構
2. 推斷：
   - `component_patterns`（glob）— 模組所在的目錄 pattern
   - `infra_patterns` — 基礎設施檔案 pattern
   - `comm_signals` — 通訊機制偵測規則（detect 方式 + pattern）
   - `adr_path` / `adr_index` — ADR 文件路徑
   - `groups` — 可用的 group 分類
3. 輸出推斷結果請使用者確認，確認後寫入 nodes.yaml

#### Phase B — 模組掃描

用 conventions patterns 掃描所有模組，對每個模組建立 entry：
- **name**: 模組名稱
- **path**: 相對路徑
- **group**: 所屬分組
- **comm**: 通訊機制（依 `comm_signals` 偵測）
  - type: 通訊類型（import / rest-api / workspace-dep / event / proxy）
  - target: 目標模組
  - description: 描述
- **edges**: 依賴的其他模組
- **refs**: 相關參考檔案

#### Phase C — Group + Edge 推斷

（`--full` 模式跳過，group 全標 `unclassified`）

- **Group**：依目錄語義和 import 類型推斷
- **Edge**：分析 import statements、event patterns、依賴關係

---

### Step 3: Seed

- **預設**：挑 3-5 個代表性模組（通訊最多 / ADR 最多 / 核心模組 / 簡單模組）+ 相關 infra
- **`--full`**：seed 全部
- **`--dry-run`**：只輸出統計

顯示變更摘要請使用者確認後寫入 `docs/nodes.yaml`。

---

### Step 4: Visualize

輸出 seed 結果的 mermaid 拓撲圖（按 group 分 subgraph + edges）+ 統計摘要 + 下一步建議。

建議使用者：
- `/ca-navigate {module}` 深入特定模組
- `/ca-map` 查看全貌圖

---

### 準確度

| 項目 | 準確度 | 修正時機 |
|------|--------|---------|
| path | ~100% | 目錄掃描 |
| comm | ~85% | `/ca-plan` 工作時 |
| refs | ~90% | `/ca-spec` 修正 |
| group | ~70% | 手動修正 |
| edges | ~50% | `/ca-plan` 深度工作時 |

錯誤是安全的：「只加不刪」政策 + 單調修正。
