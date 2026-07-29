# 列表结果控制交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增列表结果控制 owner，约束分页、页大小、排序、刷新、自动刷新、结果摘要、请求快照、迟到响应、总数可信度、URL 恢复、权限和移动端承载。

**Architecture:** 采用现有规范仓库模式：先写 Ruby 静态审计并确认 RED，再新增 `references/list-result-controls.md` 作为结果控制 primary owner，最后补齐 `SKILL.md` 路由、README/HANDOFF 摘要、相邻 owner 关系和 RED/GREEN 证据。审计使用 exact-term contract 与 mutation cases，确保列表结果控制不会被误塞进 data-tables、query-filters、feedback-states 或 page toolbar。

**Tech Stack:** Markdown 规范文档、Ruby 静态审计脚本、Git。

## Global Constraints

- 只处理本 skill 仓库内的交互规范，不修改任何业务项目代码。
- 不得引用或依赖 `fex-admin`、`/Users/evanqi/code/`、`src/pages`、`Ant Design`、`ant-design`、`shadcn`、`Next.js`、`Vite`、`React`、`Vue`。
- 新 owner 必须保持框架无关、组件库无关、项目无关。
- 规范、复核文档和证据文档必须使用中文。
- 新 owner 只负责已应用查询快照驱动的结果控制；表格列/选择/批量仍由 `references/data-tables.md` 负责，筛选草稿仍由 `references/query-filters.md` 负责，关键词输入草稿仍由 `references/keyword-search-inputs.md` 负责，通用反馈仍由 `references/feedback-states.md` 负责。
- 真实浏览器、移动端、触摸、虚拟键盘、屏幕阅读器、权限切换、网络迟到和数据版本变化未执行时，必须标为 `未验证`。
- 实施必须先 RED、后 GREEN；不能把未执行的验证写成已通过。

---

## File Structure

- Create: `references/list-result-controls.md`
  - 列表结果控制 primary owner，覆盖分页、游标、页大小、排序、刷新、自动刷新、结果摘要、迟到响应、总数可信度、URL 恢复、权限和移动端承载。
- Create: `docs/testing/list-result-controls/list-result-controls-audit.rb`
  - 新 owner 的 exact-term contract、路由检查、相邻 owner 检查、证据检查、项目泄漏检查和 mutation suite。
- Create: `docs/testing/list-result-controls/red-summary.md`
  - 记录新增 owner 前的 RED 结果，必须覆盖 evidence terms。
- Create: `docs/testing/list-result-controls/green-summary.md`
  - 记录新增 owner 后的 GREEN 结果，必须覆盖 evidence terms。
- Modify: `SKILL.md`
  - 新增列表结果控制路由。
- Modify: `README.md`
  - 新增规范总览摘要和 owner 引用。
- Modify: `HANDOFF.md`
  - 新增中文阶段性交接摘要。
- Modify: `references/data-tables.md`
  - 明确表格列、选择、批量归 data-tables；分页、排序、刷新和结果摘要同时执行 `references/list-result-controls.md`。
- Modify: `references/query-filters.md`
  - 明确 list-result-controls 只读取 `appliedFilters`，不得读取 `filterDraft`。
- Modify: `references/keyword-search-inputs.md`
  - 明确 list-result-controls 只读取 `committedKeyword`，不得读取 `inputDraft` 或 composition 文本。
- Modify: `references/page-toolbars-actions.md`
  - 明确刷新、导出、视图工具等入口读取 list-result-controls 的当前范围和快照。
- Modify: `references/feedback-states.md`
  - 明确结果 loading、refresh-error、stale、empty 和 zero-results 的状态来源由 list-result-controls 提供。
- Modify: `references/saved-views-layout-presets.md`
  - 明确保存视图只能持久化已提交且安全的结果控制。
- Modify: `references/exports-downloads-artifacts.md`
  - 明确导出读取 list-result-controls 的结果范围快照，但生命周期归导出 owner。
- Modify: `references/responsive-adaptive.md`
  - 明确移动端分页、排序、刷新、结果摘要和恢复入口不得被删除或遮挡。

---

### Task 1: 写失败审计并记录 RED

**Files:**
- Create: `docs/testing/list-result-controls/list-result-controls-audit.rb`
- Create: `docs/testing/list-result-controls/red-summary.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-list-result-controls-interaction-standards-design.md`
- Produces: command `ruby docs/testing/list-result-controls/list-result-controls-audit.rb`

- [ ] **Step 1: 创建审计脚本目录**

Run:

```sh
mkdir -p docs/testing/list-result-controls
```

- [ ] **Step 2: 创建审计脚本**

Create `docs/testing/list-result-controls/list-result-controls-audit.rb` with Ruby constants for:

```ruby
STATE_FIELDS = %w[
  resultControlsOwnerId surfaceKind appliedQueryBinding querySnapshot requestGeneration
  requestPhase sortState paginationState refreshState resultSummary selectionImpact
  urlHistoryBinding permissionBoundary feedbackBinding responsivePolicy
].freeze

OWNER_TERMS = [
  "listResultControlsState",
  "结果控制只能读取已应用查询，不得读取筛选草稿或搜索输入草稿",
  "排序变化、页大小变化和有效筛选/关键词变化必须建立新 `querySnapshot`",
  "迟到响应不得覆盖当前 owner、当前代次或当前快照不匹配的结果",
  "页码分页和游标分页不得在同一快照内混用",
  "总数不可靠时不得展示精确总页数、随机跳页或“全部 N 条”的承诺",
  "刷新保留旧结果并标记 refreshing/stale，不得把旧结果伪装成新响应",
  "响应只有同时满足当前 owner live、`resultControlsOwnerId` 相同、`requestGeneration` 相同、`querySnapshot` 身份相同、权限/租户仍匹配时，才可写入结果、分页、总数、错误、loading 或结果摘要",
  "提交不同排序时，页码分页回到第 1 页，游标分页回到初始游标，并创建新快照",
  "改变页大小必须回到第一个有效位置并创建新快照",
  "服务端拒绝的页大小不能成为当前值",
  "同一 in-flight 且同键的刷新可以合并；不同键刷新必须新建代次",
  "刷新失败不能清空已有结果；首次加载失败才可替代结果区域",
  "只有已提交且 `urlSafe` 的排序、分页、页大小和查询条件可以写 URL",
  "旧 URL、浏览器返回和保存视图恢复必须先校验版本、权限、租户/工作区、页大小合法性、排序字段合法性和分页模式",
  "移动端不得删除排序、分页、刷新、结果摘要、错误说明、权限原因、过期说明和恢复路径",
  "底部分页、固定工具栏、虚拟键盘和 safe-area 不能完全遮挡当前页、下一页、刷新、错误和结果摘要",
  "未验证"
].freeze
```

Add `ROUTE_TERMS` for all Chinese/English trigger words from the design doc plus `references/list-result-controls.md`.

Add relationship terms requiring `references/list-result-controls.md` or `list-result-controls.md` in:

```ruby
DATA_TABLES
QUERY_FILTERS
KEYWORD_SEARCH
PAGE_TOOLBARS
FEEDBACK_STATES
SAVED_VIEWS
EXPORTS
RESPONSIVE
```

Add project banned terms exactly:

```ruby
PROJECT_BANNED_TERMS = [
  "fex-admin",
  "/Users/evanqi/code/",
  "src/pages",
  "Ant Design",
  "ant-design",
  "shadcn",
  "Next.js",
  "Vite",
  "React",
  "Vue"
].freeze
```

The script must expose `audit(...)`, run normally with exit 1 when terms are missing, and support `--mutations` with expected failures for:

- `missing-owner-state`
- `reads-filter-draft`
- `reads-input-draft`
- `sort-without-new-snapshot`
- `page-size-without-new-snapshot`
- `late-response-overwrites-current`
- `mixed-pagination-mode`
- `unreliable-total-precise-pages`
- `refresh-clears-old-result`
- `weak-response-guard`
- `sort-does-not-reset-position`
- `rejected-page-size-committed`
- `refresh-dedup-global`
- `url-restore-without-validation`
- `mobile-controls-removed`
- `keyboard-obscures-pagination`
- `runtime-boundary-marked-verified`
- `missing-route`
- `missing-adjacent-owner-link`
- `project-specific-leakage`

- [ ] **Step 3: 运行 RED**

Run:

```sh
ruby docs/testing/list-result-controls/list-result-controls-audit.rb
```

Expected: FAIL with `missing file: .../references/list-result-controls.md`.

- [ ] **Step 4: 创建 RED 证据文档**

Create `docs/testing/list-result-controls/red-summary.md` containing:

```md
# 列表结果控制规范 RED 复核

## 结论

RED 通过：新增审计在 owner 文件缺失时失败，证明当前仓库还没有独立的列表结果控制 owner。

## 执行命令

`ruby docs/testing/list-result-controls/list-result-controls-audit.rb`

## 期望失败

`missing file: .../references/list-result-controls.md`

## 覆盖点

- listResultControlsState
- resultControlsOwnerId、appliedQueryBinding、querySnapshot、requestGeneration、requestPhase
- sortState、paginationState、refreshState、resultSummary、selectionImpact
- urlHistoryBinding、permissionBoundary、feedbackBinding、responsivePolicy
- 已应用查询、筛选草稿、搜索输入草稿
- 排序变化、页大小变化、querySnapshot
- 迟到响应、owner live、requestGeneration
- 页码分页、游标分页、总数不可靠
- refreshing、stale、刷新失败、旧结果
- URL、浏览器返回、保存视图恢复
- 移动端、虚拟键盘、safe-area
- 未验证

## 未验证

真实浏览器、移动端、触摸、虚拟键盘、屏幕阅读器、权限切换、网络迟到和数据版本变化尚未执行；这些必须在业务项目接入时继续标为未验证。
```

- [ ] **Step 5: 提交 RED**

Run:

```sh
git add docs/testing/list-result-controls/list-result-controls-audit.rb docs/testing/list-result-controls/red-summary.md
git commit -m "test: 增加列表结果控制规范审计"
```

---

### Task 2: 新增 owner 文档并补相邻边界

**Files:**
- Create: `references/list-result-controls.md`
- Modify: `references/data-tables.md`
- Modify: `references/query-filters.md`
- Modify: `references/keyword-search-inputs.md`
- Modify: `references/page-toolbars-actions.md`
- Modify: `references/feedback-states.md`
- Modify: `references/saved-views-layout-presets.md`
- Modify: `references/exports-downloads-artifacts.md`
- Modify: `references/responsive-adaptive.md`

**Interfaces:**
- Consumes: Task 1 audit script
- Produces: owner terms and relationship terms that satisfy the audit except route/README/HANDOFF/GREEN

- [ ] **Step 1: 新增 `references/list-result-controls.md`**

The file must include sections:

```md
# 列表结果控制交互规范

适用于列表结果、结果控制、结果摘要、分页、页码、游标分页、上一页、下一页、跳页、页大小、每页数量、排序、列表排序、表格排序、刷新、自动刷新、结果刷新、过期数据、数据版本、迟到响应、请求代次和总数不可靠。

本文件是已应用查询快照驱动的结果控制 primary owner。表格列、选择、批量和 ARIA Grid 继续执行 [数据表格交互规范](data-tables.md)；筛选草稿和已应用条件继续执行 [查询条件与筛选交互规范](query-filters.md)；关键词输入草稿和 IME composition 继续执行 [关键词搜索输入交互规范](keyword-search-inputs.md)；状态反馈继续执行 [反馈状态交互规范](feedback-states.md)。
```

Add `listResultControlsState` table with all `STATE_FIELDS`, then exact rule sections for:

- state model and owner boundary
- querySnapshot and response guard
- sortState
- paginationState
- refreshState and stale
- resultSummary and total reliability
- urlHistoryBinding restore validation
- permissionBoundary
- feedbackBinding
- responsivePolicy
- completion checks with `未验证`

The owner text must include every `OWNER_TERMS` exact string.

- [ ] **Step 2: 补 `references/data-tables.md` 边界**

Add near the top:

```md
列表、表格和报表的分页、页大小、排序提交、刷新、自动刷新、结果摘要、迟到响应、数据版本和总数可信度必须同时执行 `references/list-result-controls.md`；Data Table owner 继续负责列、行、选择、全选、批量操作和 ARIA Grid，不得直接读取筛选草稿或搜索输入草稿来改写结果控制。
```

- [ ] **Step 3: 补 `references/query-filters.md` 边界**

Add:

```md
结果分页、排序、刷新和结果摘要由 `references/list-result-controls.md` 读取已应用查询快照；query-filters 只输出 `appliedFilters`，不得让结果控制读取 `filterDraft` 或字段内部草稿。
```

- [ ] **Step 4: 补 `references/keyword-search-inputs.md` 边界**

Add:

```md
列表结果控制由 `references/list-result-controls.md` 读取 `committedKeyword`；不得读取 `inputDraft`、`normalizedDraft` 或 composition 文本来翻页、排序、刷新、写 URL 或更新结果摘要。
```

- [ ] **Step 5: 补工具栏、反馈、保存视图、导出、响应式边界**

Add one sentence containing `references/list-result-controls.md` to each target:

- `page-toolbars-actions.md`: refresh/export/view entries read result controls snapshot.
- `feedback-states.md`: result state source comes from result controls.
- `saved-views-layout-presets.md`: persisted pagination/sort/page size must be committed and safe.
- `exports-downloads-artifacts.md`: export scope reads result controls snapshot.
- `responsive-adaptive.md`: mobile pagination/sort/refresh/summary/recovery must be preserved.

- [ ] **Step 6: 阶段验证并提交**

Run:

```sh
ruby docs/testing/list-result-controls/list-result-controls-audit.rb
```

Expected: FAIL only because route/README/HANDOFF/GREEN are still missing.

Run:

```sh
git diff --check
git add references/list-result-controls.md references/data-tables.md references/query-filters.md references/keyword-search-inputs.md references/page-toolbars-actions.md references/feedback-states.md references/saved-views-layout-presets.md references/exports-downloads-artifacts.md references/responsive-adaptive.md
git commit -m "docs: 新增列表结果控制规范"
```

---

### Task 3: 补路由、README、HANDOFF 和 GREEN 证据

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Create: `docs/testing/list-result-controls/green-summary.md`

**Interfaces:**
- Consumes: Task 2 owner and audit script
- Produces: complete GREEN audit

- [ ] **Step 1: 补 `SKILL.md` 路由**

Add route:

```md
- 涉及列表结果、结果控制、结果摘要、分页、页码、游标分页、上一页、下一页、跳页、页大小、每页数量、排序、列表排序、表格排序、刷新、自动刷新、结果刷新、过期数据、数据版本、迟到响应、请求代次、总数不可靠，或 list result、result controls、result summary、pagination、page number、cursor pagination、previous page、next page、jump page、page size、per page、sorting、list sorting、table sorting、refresh、auto refresh、result refresh、stale data、dataset version、late response、request generation、unreliable total 时，必须完整读取 `references/list-result-controls.md`。
```

- [ ] **Step 2: 补 `README.md`**

Add a summary bullet:

```md
- `references/list-result-controls.md`：列表结果控制规范，覆盖分页、页大小、排序、刷新、自动刷新、结果摘要、请求快照、迟到响应、总数可信度、URL 恢复、权限和移动端承载。
```

- [ ] **Step 3: 补 `HANDOFF.md`**

Add section:

```md
### 列表结果控制

- 已定义列表结果、结果控制、结果摘要、分页、页码、游标分页、页大小、排序、刷新、自动刷新、过期数据、数据版本、迟到响应、请求代次和总数不可靠的首版 owner。
- `listResultControlsState` 必须声明 `resultControlsOwnerId`、`surfaceKind`、`appliedQueryBinding`、`querySnapshot`、`requestGeneration`、`requestPhase`、`sortState`、`paginationState`、`refreshState`、`resultSummary`、`selectionImpact`、`urlHistoryBinding`、`permissionBoundary`、`feedbackBinding` 和 `responsivePolicy`。
- 结果控制只能读取已应用查询，不得读取筛选草稿或搜索输入草稿。
- 排序变化、页大小变化和有效筛选/关键词变化必须建立新 `querySnapshot`；迟到响应不得覆盖当前 owner、当前代次或当前快照不匹配的结果。
- 页码分页和游标分页不得在同一快照内混用；总数不可靠时不得展示精确总页数、随机跳页或“全部 N 条”的承诺。
- 移动端不得删除排序、分页、刷新、结果摘要、错误说明、权限原因、过期说明和恢复路径。
- 详细规则和可执行验收仅维护在 [列表结果控制交互规范](references/list-result-controls.md)，本交接不重复其状态模型或检查项。
```

- [ ] **Step 4: 创建 GREEN 证据**

Create `docs/testing/list-result-controls/green-summary.md` with:

```md
# 列表结果控制规范 GREEN 复核

## 结论

GREEN 通过：已新增 `references/list-result-controls.md`，并补齐路由、README、HANDOFF、相邻 owner 边界和 mutation 审计。

## 执行命令

`ruby docs/testing/list-result-controls/list-result-controls-audit.rb --mutations`

## 覆盖点

- listResultControlsState
- resultControlsOwnerId、surfaceKind、appliedQueryBinding、querySnapshot、requestGeneration、requestPhase
- sortState、paginationState、refreshState、resultSummary、selectionImpact
- urlHistoryBinding、permissionBoundary、feedbackBinding、responsivePolicy
- 已应用查询、筛选草稿、搜索输入草稿
- 排序变化、页大小变化、有效筛选/关键词变化
- 迟到响应、owner live、requestGeneration、querySnapshot
- 页码分页、游标分页、总数不可靠、精确总页数
- refreshing、stale、刷新失败、旧结果
- URL、浏览器返回、保存视图恢复
- 移动端、虚拟键盘、safe-area
- 未验证

## 未验证

真实浏览器、移动端、触摸、虚拟键盘、屏幕阅读器、权限切换、网络迟到和数据版本变化尚未执行；这些必须在业务项目接入时继续标为未验证。
```

- [ ] **Step 5: GREEN 验证并提交**

Run:

```sh
ruby docs/testing/list-result-controls/list-result-controls-audit.rb --mutations
git diff --check
git add SKILL.md README.md HANDOFF.md docs/testing/list-result-controls/green-summary.md
git commit -m "docs: 补齐列表结果控制规范路由"
```

---

### Task 4: 全量验证并推送

**Files:**
- No new files unless verification exposes a defect.

**Interfaces:**
- Consumes: Tasks 1-3 commits
- Produces: pushed `main`

- [ ] **Step 1: 运行专项审计**

Run:

```sh
ruby docs/testing/list-result-controls/list-result-controls-audit.rb --mutations
```

Expected: all mutation cases print `EXPECTED_FAIL`.

- [ ] **Step 2: 运行相邻 owner 审计**

Run:

```sh
ruby docs/testing/data-tables/attempt-6-application-audit.rb
ruby docs/testing/query-filters/query-filters-audit.rb --mutations
ruby docs/testing/keyword-search-inputs/keyword-search-inputs-audit.rb --mutations
ruby docs/testing/page-toolbars-actions/page-toolbars-actions-audit.rb --mutations
ruby docs/testing/feedback-states/feedback-states-audit.rb --mutations
ruby docs/testing/saved-views-layout-presets/saved-views-layout-presets-audit.rb --mutations
ruby docs/testing/exports-downloads-artifacts/exports-downloads-artifacts-audit.rb --mutations
```

Expected: all commands exit 0.

- [ ] **Step 3: 运行全量审计**

Run:

```sh
for audit in docs/testing/*/*-audit.rb; do
  case "$audit" in
    docs/testing/data-tables/attempt-*) continue ;;
  esac
  ruby "$audit" || exit 1
done
```

Expected: all audits exit 0.

- [ ] **Step 4: 运行链接、diff 和泄漏检查**

Run:

```sh
ruby -e 'files = Dir["**/*.md"].reject { |f| f.start_with?(".worktrees/") }; missing = []; files.each { |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |href| next if href =~ /\A[a-z][a-z0-9+.-]*:/i; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target) } }; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
git diff --check
rg -n "fex-admin|/Users/evanqi/code/|src/pages|Ant Design|ant-design|shadcn|Next.js|Vite|React|Vue" references/list-result-controls.md docs/testing/list-result-controls/red-summary.md docs/testing/list-result-controls/green-summary.md README.md || true
```

Expected: markdown pass; diff check no output; leakage scan no output for new files.

- [ ] **Step 5: 推送 main**

Run:

```sh
git status --short --branch
git push origin main
git status --short --branch
git log --oneline -5
```

Expected: `main...origin/main` clean after push.
