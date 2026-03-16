---
description: Issue 收尾 — distill 知識 + 生成結構化 issue comment
---

## `/ca-close` — Issue 收尾

開發完成後，分析本次修改，distill 知識並生成可直接貼到 issue tracker 的結構化 comment。

### 使用方式

```
/ca-close {issue-id}
```

---

### Step 1: 讀取工作檔

- 讀取 `docs/tmp/{issue-id}.md` 或 `docs/tmp/PLAN-{issue-id}.md`
- 如不存在，提示使用者先描述變更內容

### Step 2: 分析變更

- 執行 `git diff master...HEAD --stat` 查看變更檔案統計
- 執行 `git log master..HEAD --oneline` 查看 commit 歷史
- 分析變更涉及的模組和 scope

### Step 3: Tier Gate 判斷

根據變更範圍判斷 Tier：
- **Tier 1**（單檔修改、明確 bug）→ 跳過 distill，直接到步驟 5
- **Tier 2+**（跨多檔、新功能、重構）→ 執行步驟 4 distill

### Step 4: Distill（Tier 2+ 限定）

#### 4a. 建立 ADR

- 使用 `docs/adr/_TEMPLATE-ADR.md` 格式建立 ADR
- Status 設為 Done
- 從工作檔和 git diff 提煉：Context、Decision、Consequences、Gotchas
- ADR 只記錄 issue 沒有的實作層知識

#### 4b. 更新 INDEX

- 在 `docs/adr/INDEX.md` 新增此 ADR

#### 4c. 同步 Gotchas

- 如 ADR 中有 Gotchas，同步到 `docs/map/gotchas.md`

### Step 5: 讀取 Issue Template（如有）

- 檢查 constitution file 中是否定義了 issue template 路徑
- 如有，讀取對應模板作為 section 骨架參考
- 如無，使用預設格式

### Step 6: 生成結構化 Comment

將以下內容寫入 `docs/tmp/{issue-id}.md`：

```markdown
## 變更摘要

{一段描述本次變更的核心內容，用功能面描述}

## 變更檔案

{從 git diff --stat 產生的檔案變更列表}

## 實作細節

{關鍵的實作決策和技術細節}

## 測試結果

{test/lint 執行結果}

## 注意事項

{部署注意事項、已知限制、後續 TODO}
```

如有 issue template，必須保留 template 中的每一個 section，逐一填入開發結果。

### Step 7: 流程回饋

僅在有值得記錄的發現時：
- 回顧本次開發流程，檢查是否有 skill 或 constitution file 可改善之處
- 如有建議，向使用者提出
- 沒有發現就跳過

### Step 8: 收尾

- 按 constitution file 收尾標準步驟執行
- 輸出完整 comment 的 markdown codeblock，方便使用者複製
- 提醒使用者用完後可刪除 `docs/tmp/{issue-id}.md`
