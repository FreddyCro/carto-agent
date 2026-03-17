---
description: ADR 生命週期管理（distill / review / check）
---

## `/ca-spec` — ADR 生命週期管理

根據子命令執行對應操作。如果沒有子命令，顯示可用選項。

### 使用方式

| 用法 | 說明 |
|------|------|
| `/ca-spec distill` | 將 active PLAN.md distill 為 completed ADR |
| `/ca-spec review` | 列出所有 ADR |
| `/ca-spec check {module}` | 模組知識全面審計 |

---

### /ca-spec distill

1. 從工作檔（`docs/tmp/` 中的 PLAN.md 或工作紀錄）提取：實作層決策 + gotchas
2. 寫入或更新對應的 ADR（使用 `docs/adr/_TEMPLATE-ADR.md` 格式，10-15 行）
3. 更新 `docs/adr/INDEX.md`
4. 將新 gotchas 同步到 `docs/map/gotchas.md`
5. 如果是 Tier 2，加入 Architecture section（Mermaid 圖）
6. 主動追問不足的資訊：
   - 「你考慮過哪些替代方案？」
   - 「這個決策有什麼負面後果或已知限制？」
   - 「有哪些 non-obvious 的發現（gotchas）？」

### /ca-spec review

1. 讀取 `docs/adr/INDEX.md`
2. 以表格呈現所有 ADR 的 ID、Title、Status、Components

### /ca-spec check {module}

分三個 Phase 遞進分析：

**Phase 1 — 已記錄知識**
1. 搜尋 `docs/adr/` 中提到該模組的 ADR
2. 讀取 `docs/map/gotchas.md` 中該模組的 gotchas
3. 彙整呈現已知的架構決策和陷阱

**Phase 2 — 程式碼推斷**
1. 讀取模組目錄下的檔案，分析架構決策和特殊 pattern
2. 讀取測試檔案了解邊界案例
3. 比對 Phase 1，標出「程式碼有但 ADR 沒記錄」的決策

**Phase 3 — 歷史 gap 分析**
1. 從 git log 搜尋該模組相關的 commit 和 issue 引用
2. 分類 bug pattern
3. 比對 Phase 1+2，識別缺少記錄的 pattern
4. 輸出建議：補充哪些 ADR 或 gotchas
