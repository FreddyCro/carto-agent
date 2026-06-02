---
name: ca-close
description: Issue 收尾 — distill 知識 + 生成結構化 issue comment
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
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
- **Tier 1**（單檔修改、明確 bug）→ 詢問是否做 code review（步驟 3b，opt-in）→ 同步 gotchas（如有 non-obvious 發現），直接到步驟 5
- **Tier 2**（跨多檔、新功能、重構、架構變更）→ 執行步驟 3b + 3c + 4

#### Step 3b: Code Review（自動化輔助）

> 在 distill 之前先讓 agent 對 diff 做一輪 review。findings 餵進 ADR / gotchas 的草稿；🔴 必修項目觸發回退到 `/ca-plan` 修正後重新進入 close。

**Tier 1**：opt-in，詢問使用者「要不要做一次 code review？(y/N)」。預設跳過。

**Tier 2**：強制執行。

執行方式（agent-agnostic）：

對 `git diff master...HEAD` 進行 code review，重點檢查：

- **正確性**：邏輯錯誤、邊界條件、null / undefined 處理
- **安全性**：注入風險、敏感資訊洩漏、權限檢查缺失
- **一致性**：是否符合 constitution file 的 Coding Conventions
- **架構契合度**：是否違反 nodes.yaml 中該模組的 edges / comm 約束
- **可維護性**：命名、過度抽象、重複邏輯

輸出格式：
```
🔎 Code Review 結果

🔴 必修 (Must fix):
  - {file}:{line} — {issue}

🟡 建議 (Should consider):
  - {file}:{line} — {issue}

🟢 觀察 (Nit):
  - {file}:{line} — {issue}
```

> Claude Code 使用者可改用 `/review` 或 `/security-review` skill 加速。其他 agent 直接以自然語言請 agent 執行上述 review。

**回退機制（feedback loop）**：

- 若有 🔴 必修項目 → 向使用者呈現清單，詢問：「要先修正再回來 close 嗎？(Y/n)」
  - Y（預設）→ 中止 /ca-close，提示使用者：「請執行 `/ca-plan {issue-id}` 從 Step 6 接續修正」，回退到實作階段
  - n → 記錄到「待辦清單」section（在 Step 6 comment 中），繼續流程
- 🟡 / 🟢 → 直接餵進後續 ADR Gotchas / gotchas.md 草稿，不阻斷流程

#### Step 3c: 詢問是否建立 ADR（Tier 2）

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

### Step 7b: Human Checkpoint — Q3: 我願意為它負責嗎？

> commit 建議前攔截 — 過了這個點就影響團隊：MR review、CI 資源、branch。

向使用者提示：

```
🔐 Q3: 你願意為這段 code 負責嗎？

Push 後就進入 CI pipeline，對團隊宣告「我背書」。

問自己:
  - 如果上線後出問題，我知道從哪裡開始 debug 嗎？
  - 這段 code 的 rollback 計畫是什麼？
  - 我能跟其他工程師解釋這個改動嗎？

→ 如果答案是「不確定」→ 退回 Q1，重新理解。
```

### Step 8: 收尾

- 按 constitution file 收尾標準步驟執行
- 輸出完整 comment 的 markdown codeblock，方便使用者複製
- 提醒使用者用完後可刪除 `docs/tmp/{issue-id}.md`
