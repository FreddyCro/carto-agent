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

向使用者回報：「正在委託 @ca-explorer 分析變更...」

委託 `@ca-explorer` subagent 分析（避免 diff 輸出佔滿主 context）：

1. 向 `@ca-explorer` 發送：分析 `git diff master...HEAD --stat` 和 `git log master..HEAD --oneline`，回傳變更摘要（涉及模組、scope、檔案數）
2. subagent 回傳精簡的變更摘要，主 context 只保留結論
3. 向使用者回報：「@ca-explorer 分析完成」+ 變更摘要

### Step 2b: 品質快照

執行 constitution file 中定義的 test 和 lint 指令，記錄當下結果：
- test：pass / fail（fail 時附失敗摘要）
- lint：clean / warnings（附數量）

結果自動填入 Step 6「測試結果」section。如果 test fail，警告使用者但不阻斷流程。

### Step 3: Tier Gate 判斷

根據變更範圍判斷 Tier：
- **Tier 1**（單檔修改、明確 bug）→ 同步 gotchas（如有 non-obvious 發現），直接到步驟 5
- **Tier 2**（跨多檔、新功能、重構、架構變更）→ 執行步驟 3b + 4

#### Step 3b: 詢問是否建立 ADR（Tier 2）

- 摘要本次變更的關鍵決策，向使用者呈現
- 詢問使用者：「這次的決策值得寫 ADR 嗎？」
- 使用者說是 → 執行步驟 4 distill
- 使用者說否 → 跳到步驟 4c 僅同步 gotchas

### Step 4: Distill（Tier 2，使用者同意時）

#### 4a. 建立 ADR

- 使用 `docs/adr/_TEMPLATE-ADR.md` 格式建立 ADR
- Status 設為 Done
- 從工作檔和 git diff 提煉：Context、Decision、Consequences、Gotchas
- ADR 只記錄 issue 沒有的實作層知識

#### 4b. 更新引用

- 更新 `docs/nodes.yaml` 中相關模組的 `refs`，加入新 ADR 引用
- 如 `docs/adr/INDEX.md` 存在，順便更新（非必要）

#### 4c. 同步 Gotchas

- 如有 non-obvious 發現或 ADR 中有 Gotchas，同步到 `docs/map/gotchas.md`

### Step 4d: Review Checklist

讀取 constitution file 的「Review Checklist」section：
- 如果 checklist 為空（無項目或全部被註解）→ 回報「執行了 0 項檢查」，繼續
- 如果有定義項目 → 委託 `@ca-explorer` 逐項檢查：
  1. 向使用者回報：「正在執行 N 項 review 檢查...」
  2. 向 `@ca-explorer` 發送：review checklist + `git diff master...HEAD`
  3. @ca-explorer 回傳每項的 pass / warning / critical
  4. 向使用者回報結果：「Review 完成：N pass / N warning / N critical」
  5. 如有 critical → 警告使用者，建議修正後再繼續（不阻斷）

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
