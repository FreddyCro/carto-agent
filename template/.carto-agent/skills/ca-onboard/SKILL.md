---
description: 專案導覽 — 為新 session 或新人提供架構摘要
---

## `/ca-onboard` — 專案導覽

為新 session 或新人提供專案架構摘要。

### 使用方式

```
/ca-onboard
```

---

### Step 1: 專案概覽

讀取 constitution file，輸出：
- 專案名稱和用途
- Repo 類型和語言框架
- 主要 packages 和各自的職責
- Dev commands 快速參考

### Step 2: 架構拓撲（如有）

- 檢查 `docs/map/` 是否有拓撲文件（L3-component.md, L3-communication.md 等）
- 如有，輸出各文件的摘要
- 如有 `docs/nodes.yaml`，列出已註冊的模組數量和 groups
- 列出通訊機制（從 nodes.yaml 的 comm 欄位彙整）

### Step 3: 近期決策

- 讀取 `docs/adr/INDEX.md`
- 輸出最近 5 筆 ADR 的摘要（ID、Title、Status）
- 特別標注 In Progress 的 ADR
- 如無 ADR，說明目前尚無架構決策記錄

### Step 4: 已知陷阱

- 讀取 `docs/map/gotchas.md`
- 輸出所有已知 gotchas
- 如無 gotchas，說明目前尚無已知陷阱

### Step 5: 開發環境

- 輸出開發環境啟動方式（從 constitution file 讀取）
- 列出必要的環境需求（Docker、Node 版本等）

### Step 6: 建議入手點

- 根據使用者的問題或目標，建議從哪裡開始
- 推薦使用 `/ca-navigate {module}` 深入感興趣的模組
