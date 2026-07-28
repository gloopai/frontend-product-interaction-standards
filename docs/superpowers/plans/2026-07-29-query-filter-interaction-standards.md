# Query Filter Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a first-class query condition and filter bar interaction owner to the frontend product interaction standards Skill.

**Architecture:** Create one focused reference file for query/filter behavior, route it from `SKILL.md`, summarize it from README/HANDOFF, and add a Ruby audit plus RED/GREEN evidence. The owner defines how users form reproducible query intent, while existing Data Table, Form, Select, Button, Dialog/Drawer, Admin Console, and Responsive owners keep their current responsibilities.

**Tech Stack:** Markdown reference documentation, Ruby static audit, Git.

## Global Constraints

- The new owner must be project-agnostic and must not include business-project-specific pages, modules, routes, frameworks, or component libraries.
- Detailed rules live only in `references/query-filters.md`; `SKILL.md`, README, and HANDOFF only route or summarize.
- Query/filter rules are hard acceptance criteria when their route triggers.
- Runtime browser, screen reader, touch-device, and real-component checks must be marked unverified unless actually executed.
- Do not modify business repositories in this plan.

---

### Task 1: Add Query Filter owner

**Files:**
- Create: `references/query-filters.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-query-filter-interaction-standards-design.md`
- Produces: rule families `QF-SCOPE-*`, `QF-STATE-*`, `QF-APPLY-*`, `QF-RESET-*`, `QF-SUMMARY-*`, `QF-URL-*`, `QF-PERM-*`, `QF-A11Y-*`, `QF-RSP-*`

- [ ] **Step 1: Write the owner file**

Create `references/query-filters.md` with these sections:

```markdown
# 查询条件与筛选交互规范

## 范围
## 与组件 owner 的关系
## 场景与状态模型
## QF-SCOPE 范围和术语
## QF-STATE 查询条件状态
## QF-APPLY 应用模式、请求意图和防重复
## QF-RESET 默认值、重置、清空和单项移除
## QF-SUMMARY 已应用条件摘要、chips 和折叠筛选
## QF-URL URL 同步、返回恢复和敏感值
## QF-PERM 权限、租户和管理台安全
## QF-A11Y 可访问性
## QF-RSP 响应式与移动端
## 可执行验收检查
```

- [ ] **Step 2: Include required state contract**

Ensure `queryFilterState` contains `filterOwnerId`, `filterDraft`, `appliedFilters`, `defaultFilters`, `filterSchema`, `queryIntent`, `urlState`, and `requestBinding`.

- [ ] **Step 3: Include hard prohibitions**

Owner must prohibit: draft directly changing results or URL, internal Select query entering filters, missing `applyMode`, reset meaning clear-all, hidden applied filters with no summary, sensitive URL serialization, silently ignoring invalid URL filters, stale permission values, and mobile deletion of filter capabilities.

- [ ] **Step 4: Commit task output**

Commit message:

```bash
git add references/query-filters.md
git commit -m "docs: 新增查询条件与筛选交互规范"
```

### Task 2: Route and summarize the new owner

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: `references/query-filters.md`
- Produces: automatic routing from query/filter/search keywords to the owner

- [ ] **Step 1: Update `SKILL.md` routing**

Add a route requiring complete reading of `references/query-filters.md` for Chinese and English query/filter keywords:

```markdown
- 涉及查询条件、筛选、过滤、搜索、关键词搜索、高级筛选、更多筛选、筛选条件、查询条件区、筛选区、重置筛选、清空筛选、已应用条件、筛选标签、URL 筛选，或 query filter、filters、filter bar、search filter、keyword search、advanced filters、filter drawer、applied filters、filter chips、reset filters、clear filters、URL filters 时，必须完整读取 `references/query-filters.md`。
```

- [ ] **Step 2: Update README summary**

Add one bullet to “当前规范” and include the README link text `查询条件与筛选交互规范` pointing to `references/query-filters.md` in the complete-rules sentence.

- [ ] **Step 3: Update HANDOFF summary**

Add a short “查询条件与筛选” subsection under “已完成规范” and add `references/query-filters.md` to the current structure.

- [ ] **Step 4: Commit task output**

Commit message:

```bash
git add SKILL.md README.md HANDOFF.md
git commit -m "docs: 接入查询条件与筛选规范路由"
```

### Task 3: Add audit and evidence

**Files:**
- Create: `docs/testing/query-filters/query-filters-audit.rb`
- Create: `docs/testing/query-filters/red-summary.md`
- Create: `docs/testing/query-filters/green-summary.md`

**Interfaces:**
- Consumes: `references/query-filters.md`, `SKILL.md`, `README.md`, `HANDOFF.md`
- Produces: command `ruby docs/testing/query-filters/query-filters-audit.rb --mutations`

- [ ] **Step 1: Write the Ruby audit**

The audit must verify:

```ruby
REQUIRED_OWNER_TERMS = [
  "queryFilterState",
  "filterOwnerId",
  "filterDraft",
  "appliedFilters",
  "defaultFilters",
  "filterSchema",
  "queryIntent",
  "urlState",
  "requestBinding",
  "filterDraft` 与 `appliedFilters` 必须分离",
  "字段内部草稿不得进入 `filterDraft`、`appliedFilters`、URL 或结果摘要",
  "每个条件必须声明 `applyMode: immediate | explicit`",
  "“重置”恢复 `defaultFilters`",
  "已应用条件必须持续可见或在摘要中可发现",
  "只有明确 `urlSafe` 的已应用条件可以进入 URL",
  "不得静默忽略 URL 中的已知条件",
  "无权条件、敏感值、旧租户选项和旧 URL 状态不能继续暴露",
  "移动端不得删除核心筛选能力",
  "未验证"
]
```

It must also verify route and README/HANDOFF links.

- [ ] **Step 2: Add mutation checks**

The `--mutations` mode must fail when removing draft/applied separation, Select internal draft exclusion, apply mode, reset default semantics, applied summary, URL-safe rule, invalid URL handling, permission cleanup, mobile capability, and runtime unverified disclosure.

- [ ] **Step 3: Add RED/GREEN summaries**

`red-summary.md` lists the negative cases. `green-summary.md` lists the behaviors proved by the current owner and audit.

- [ ] **Step 4: Commit task output**

Commit message:

```bash
git add docs/testing/query-filters
git commit -m "test: 增加查询条件与筛选规范审计"
```

### Task 4: Verify final integration

**Files:**
- Inspect all modified files.

**Interfaces:**
- Consumes: all outputs from Tasks 1-3
- Produces: final local verification evidence

- [ ] **Step 1: Run query/filter audit**

Run:

```bash
ruby docs/testing/query-filters/query-filters-audit.rb --mutations
```

Expected: all mutation checks print expected failures and final pass.

- [ ] **Step 2: Run existing high-overlap audits**

Run:

```bash
ruby docs/testing/uploads-imports/uploads-imports-audit.rb --mutations
ruby docs/testing/buttons/buttons-audit.rb --mutations
ruby docs/testing/record-editing-surfaces/record-editing-surfaces-audit.rb --mutations
ruby docs/testing/admin-console/admin-console-audit.rb --mutations
```

Expected: each audit passes with its expected mutation output.

- [ ] **Step 3: Run Markdown link and whitespace checks**

Run repository Markdown relative-link check and:

```bash
git diff --check
```

Expected: both pass.

- [ ] **Step 4: Commit remaining verification-only edits if any**

If Task 4 caused documentation changes, commit them with:

```bash
git add <changed-files>
git commit -m "docs: 完成查询条件与筛选规范验证"
```

If there are no file changes, do not create an empty commit.
