# CLAUDE.md — {Project Name}

> CartoAgent constitution file（由 `/ca-scout` 從 `carto-agent.config.yaml` 生成）。
> 每次 session 自動載入。手動修改此檔案後，建議同步更新 config。

## Language

{繁體中文和英文 / English only / etc.}

## Project Identity

- **Repo 類型**: {monorepo / single-package / etc.}
- **語言框架**: {Vue 3, React, Node.js, Python, etc.}
- **Build 工具**: {Vite, Webpack, Turbopack, etc.}
- **主要 packages**:
  - `{path}/` — {description}

## Dev Commands

- **Install**: `{pnpm install / npm install / etc.}`
- **Dev**: `{pnpm dev / npm run dev / etc.}`
- **Test**: `{pnpm test / npm test / etc.}`
- **Lint**: `{pnpm lint / npm run lint / etc.}`
- **Build**: `{pnpm build / npm run build / etc.}`

## Issue Tracking

- **平台**: {gitlab / github / jira / linear / etc.}
- **Issue URL**: {https://example.com/issues/{id}}
- **Issue Template 路徑**: {.gitlab/issue_templates/ / .github/ISSUE_TEMPLATE/ / N/A}

## Coding Conventions

- **Commit Style**: {Conventional Commits (fix:, feat:, docs:, chore:) / etc.}
- **Branch 命名**: {feature/{id}-{slug} / {id}-{slug} / etc.}
- **檔案命名**: {kebab-case / camelCase / PascalCase}
- {其他專案特定 conventions...}

## Workflow Tiers

根據 task 規模選擇對應工作流，避免小 bug 承受過重的文件開銷。

### Tier 1: Quick Fix

觸發：單檔修改、明確 bug
流程：修 → test → commit
完成時（選填）：non-obvious 發現加到 docs/map/gotchas.md

### Tier 2: Medium Task

觸發：跨多檔、新模組、內部重構
流程：建 ADR-lite → 實作 → distill
完成時：更新 docs/adr/INDEX.md、同步 gotchas

### Tier 3: Full Spec

觸發：跨模組遷移、架構變更
流程：建完整 ADR → 建 PLAN.md → 實作 → distill
完成時：更新 INDEX.md、同步 gotchas、更新架構文件

### 收尾標準步驟（所有 Tier）

1. 提醒使用者 commit 並提供建議的 commit message（不自行執行 git commit）
2. 如有關聯的 issue，提醒使用者執行 /ca-close {id}

## Knowledge Rules — Single Source of Truth

| 知識類型 | Source of Truth | 其他地方 |
| --- | --- | --- |
| 模組 API | API 文件（README / JSDoc / Storybook） | map/ 不寫 |
| 跨模組依賴/通訊 | docs/map/ + nodes.yaml | API 文件不寫 |
| 架構決策 / gotchas | docs/adr/ + docs/map/gotchas.md | API 文件不寫 |

## Key Paths

- 主要模組: {src/packages/, src/modules/, packages/, etc.}
- 共用工具: {src/utils/, shared/, lib/, etc.}
- 架構文件: docs/
- 決策記錄: docs/adr/
- 拓撲地圖: docs/map/
- 節點路由表: docs/nodes.yaml
- CartoAgent Skills: .carto-agent/skills/
- Agent Skills (Claude Code): .claude/skills/