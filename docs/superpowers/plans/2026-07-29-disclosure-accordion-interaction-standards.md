# 折叠面板与 Disclosure 交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增折叠面板与 Disclosure owner，约束 Accordion、Collapse、展开/收起面板、错误外显、权限隐藏、懒加载、展开状态持久化、嵌套折叠和移动端承载。

**Architecture:** 采用现有规范仓库模式：先写 Ruby 静态审计并确认 RED，再新增 `references/disclosure-accordions.md` 作为折叠/展开 primary owner，最后补齐 `SKILL.md` 路由、README/HANDOFF 摘要、相邻 owner 关系和 RED/GREEN 证据。审计使用 exact-term contract 与 mutation cases，确保 Accordion 不被误当成业务值、Tabs、Tree、Wizard 或表单提交。

**Tech Stack:** Markdown 规范文档、Ruby 静态审计脚本、Git。

## Global Constraints

- 只处理本 skill 仓库内的交互规范，不修改任何业务项目代码。
- 不得引用或依赖 `fex-admin`、`/Users/evanqi/code/`、`src/pages`、`Ant Design`、`ant-design`、`shadcn`、`Next.js`、`Vite`、`React`、`Vue`。
- 新 owner 必须保持框架无关、组件库无关、项目无关。
- 规范、复核文档和证据文档必须使用中文。
- 新 owner 只负责折叠/展开容器；表单、信息展示、筛选、反馈、权限、响应式、Tabs 和 Tree 仍由对应专项 owner 负责。
- 真实浏览器、键盘、屏幕阅读器、移动端、权限切换、懒加载迟到和表单提交未执行时，必须标为 `未验证`。
- 实施必须先 RED、后 GREEN；不能把未执行的验证写成已经通过。

---

## File Structure

- Create: `references/disclosure-accordions.md`
- Create: `docs/testing/disclosure-accordions/disclosure-accordions-audit.rb`
- Create: `docs/testing/disclosure-accordions/red-summary.md`
- Create: `docs/testing/disclosure-accordions/green-summary.md`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Modify: `references/forms.md`
- Modify: `references/information-display.md`
- Modify: `references/query-filters.md`
- Modify: `references/feedback-states.md`
- Modify: `references/permissions-tenancy-visibility.md`
- Modify: `references/responsive-adaptive.md`
- Modify: `references/tab-view-navigation.md`
- Modify: `references/tree-hierarchy.md`

---

### Task 1: 写失败审计并记录 RED

**Files:**
- Create: `docs/testing/disclosure-accordions/disclosure-accordions-audit.rb`
- Create: `docs/testing/disclosure-accordions/red-summary.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-disclosure-accordion-interaction-standards-design.md`
- Produces: command `ruby docs/testing/disclosure-accordions/disclosure-accordions-audit.rb`

- [ ] **Step 1: 创建审计脚本目录**

Run:

```sh
mkdir -p docs/testing/disclosure-accordions
```

- [ ] **Step 2: 创建审计脚本**

Create `docs/testing/disclosure-accordions/disclosure-accordions-audit.rb` with:

```ruby
STATE_FIELDS = %w[
  disclosureOwnerId surfaceKind itemRegistry expandedItemIds expansionPolicy
  contentState requestBinding errorVisibilityBinding permissionBoundary
  persistenceBinding focusAnnouncementPolicy responsivePolicy
].freeze

OWNER_TERMS = [
  "disclosureAccordionState",
  "展开状态不等于业务值、不等于表单提交、不等于权限事实",
  "折叠不能隐藏当前必须处理的错误、必填缺失、权限原因或恢复入口",
  "disabled、hidden、permission-denied 和 not-enabled item 不是同一状态",
  "懒加载迟到响应不得写回已收起、卸载、无权限或身份不匹配的 item",
  "嵌套折叠必须有唯一 owner 和层级边界",
  "移动端不得删除标题、当前展开状态、错误摘要、权限原因、恢复入口和核心操作",
  "触发器必须是真按钮或等价可访问控件",
  "展开状态可以作为用户偏好保存，但必须声明 `persistenceBinding`",
  "不得把展开状态写成业务字段、提交 payload、筛选条件、导出范围或权限事实",
  "URL、保存视图或本地偏好恢复展开状态前必须校验 itemRegistry 版本、权限、租户/工作区和对象状态",
  "未验证"
].freeze
```

Add route, relationship, README/HANDOFF and evidence checks mirroring the existing owner audit pattern.

Add mutation cases:

- `missing-owner-state`
- `expansion-as-business-value`
- `hidden-error`
- `states-merged`
- `late-response-writes-invalid-item`
- `nested-owner-boundary-removed`
- `mobile-core-capability-removed`
- `trigger-not-button`
- `persistence-without-binding`
- `persisted-as-payload`
- `restore-without-validation`
- `runtime-boundary-marked-verified`
- `missing-route`
- `missing-adjacent-owner-link`
- `project-specific-leakage`

- [ ] **Step 3: 运行 RED**

Run:

```sh
ruby docs/testing/disclosure-accordions/disclosure-accordions-audit.rb
```

Expected: FAIL with `missing file: .../references/disclosure-accordions.md`.

- [ ] **Step 4: 创建 RED 证据文档**

Create Chinese RED evidence covering `disclosureAccordionState`、all state fields、expandedItemIds、expansionPolicy、contentState、requestBinding、errorVisibilityBinding、permissionBoundary、persistenceBinding、responsivePolicy、未验证.

- [ ] **Step 5: 提交 RED**

Run:

```sh
git add docs/testing/disclosure-accordions/disclosure-accordions-audit.rb docs/testing/disclosure-accordions/red-summary.md
git commit -m "test: 增加折叠面板规范审计"
```

---

### Task 2: 新增 owner 文档并补相邻边界

**Files:**
- Create: `references/disclosure-accordions.md`
- Modify: `references/forms.md`
- Modify: `references/information-display.md`
- Modify: `references/query-filters.md`
- Modify: `references/feedback-states.md`
- Modify: `references/permissions-tenancy-visibility.md`
- Modify: `references/responsive-adaptive.md`
- Modify: `references/tab-view-navigation.md`
- Modify: `references/tree-hierarchy.md`

**Interfaces:**
- Consumes: Task 1 audit script
- Produces: owner terms and adjacent owner terms that satisfy the audit except route/README/HANDOFF/GREEN

- [ ] **Step 1: 新增 `references/disclosure-accordions.md`**

The file must include `disclosureAccordionState` table with all `STATE_FIELDS`, sections for semantic boundary、error visibility、permission safety、lazy loading、persistence、focus/ARIA、nested disclosure、responsive, and every `OWNER_TERMS` exact string.

- [ ] **Step 2: 补相邻 owner 边界**

Add one sentence containing `references/disclosure-accordions.md` to each target:

- `forms.md`: disclosure owner exposes hidden errors; Forms owns dirty/submit.
- `information-display.md`: read-only field semantics remain there; grouping expansion belongs to disclosure owner.
- `query-filters.md`: advanced filter disclosure cannot hide applied/draft/error state.
- `feedback-states.md`: collapsed content feedback carries via feedback owner.
- `permissions-tenancy-visibility.md`: hidden titles/summaries/old content follow permission boundary.
- `responsive-adaptive.md`: mobile disclosure conversion preserves core actions/error/recovery.
- `tab-view-navigation.md`: do not use Accordion as tab navigation.
- `tree-hierarchy.md`: do not use Accordion as selectable tree.

- [ ] **Step 3: 阶段验证并提交**

Run audit, expect GREEN missing only. Then:

```sh
git diff --check
git add references/disclosure-accordions.md references/forms.md references/information-display.md references/query-filters.md references/feedback-states.md references/permissions-tenancy-visibility.md references/responsive-adaptive.md references/tab-view-navigation.md references/tree-hierarchy.md
git commit -m "docs: 新增折叠面板规范"
```

---

### Task 3: 补路由、README、HANDOFF 和 GREEN 证据

**Files:** `SKILL.md`, `README.md`, `HANDOFF.md`, `docs/testing/disclosure-accordions/green-summary.md`

- [ ] **Step 1: 补 `SKILL.md` 路由**

Add Chinese/English trigger terms from the design doc pointing to `references/disclosure-accordions.md`.

- [ ] **Step 2: 补 README/HANDOFF**

Add summary and Chinese handoff section covering `disclosureAccordionState`, state fields, hidden-error rule, permission rule, lazy response rule and mobile rule.

- [ ] **Step 3: 创建 GREEN 证据并验证**

Create GREEN evidence mirroring RED, then run:

```sh
ruby docs/testing/disclosure-accordions/disclosure-accordions-audit.rb --mutations
git diff --check
git add SKILL.md README.md HANDOFF.md docs/testing/disclosure-accordions/green-summary.md
git commit -m "docs: 补齐折叠面板规范路由"
```

---

### Task 4: 全量验证并推送

- [ ] **Step 1: 运行专项和相邻审计**

Run:

```sh
ruby docs/testing/disclosure-accordions/disclosure-accordions-audit.rb --mutations
ruby docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb --mutations
ruby docs/testing/feedback-states/feedback-states-audit.rb --mutations
```

- [ ] **Step 2: 运行全量审计、链接和泄漏检查**

Run full audit loop, markdown link checker, `git diff --check`, and project leakage scan for the new files.

- [ ] **Step 3: 推送 main**

Run:

```sh
git status --short --branch
git push origin main
git status --short --branch
git log --oneline -8
```
