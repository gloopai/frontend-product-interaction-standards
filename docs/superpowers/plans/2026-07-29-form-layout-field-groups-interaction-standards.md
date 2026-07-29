# Form Layout Field Groups Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Chinese UI interaction-standard owner for form layout, field groups and responsive field arrangement.

**Architecture:** Create a dedicated reference owner, wire it into routing and adjacent UI owners, then guard it with a Ruby audit and red/green summaries.

**Tech Stack:** Markdown documentation and Ruby audit scripts.

## Global Constraints

- 文档必须使用中文。
- 只处理 UI 与交互布局，不处理权限业务或权限矩阵。
- 不处理任何具体业务项目实现。
- 组件库 Form、Grid、Form.Item、span、labelCol 或 wrapperCol 默认行为不能降低本规范。
- 真实浏览器、键盘、读屏、触摸、虚拟键盘、缩放、低高度和移动端视口未执行时必须标为未验证。

---

### Task 1: Owner reference

**Files:**
- Create: `references/form-layout-field-groups.md`

**Interfaces:**
- Produces: `formLayoutState`
- Consumes: `references/forms.md`, `references/field-guidance-help-text.md`, `references/dialogs.md`, `references/drawers.md`, `references/page-content-layout-sections.md`, `references/page-form-action-bars.md`, `references/responsive-adaptive.md`, `references/text-overflow-truncation.md`

- [x] **Step 1: Write scope, boundaries, state fields, core rules, recommended layouts, mobile behavior and audit checklist.**
- [x] **Step 2: Include hard prohibitions for CSS-grid-only state, label/DOM/order mismatch, multi-column mobile forms, footer-over-error and screenshot-only layout validation.**
- [x] **Step 3: State runtime verification boundaries as unverified unless actually tested.**

### Task 2: Routing and adjacent owners

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Modify: adjacent UI references that participate in form layout scenarios

**Interfaces:**
- Consumes: `formLayoutState`
- Produces: route keywords and cross-owner handoff

- [x] **Step 1: Add Chinese and English route keywords.**
- [x] **Step 2: Add README summary and link.**
- [x] **Step 3: Add HANDOFF summary.**
- [x] **Step 4: Add adjacent owner references requiring `references/form-layout-field-groups.md` and `formLayoutState`.**

### Task 3: Audit

**Files:**
- Create: `docs/testing/form-layout-field-groups/form-layout-field-groups-audit.rb`
- Create: `docs/testing/form-layout-field-groups/red-summary.md`
- Create: `docs/testing/form-layout-field-groups/green-summary.md`

**Interfaces:**
- Consumes: owner, route, README, HANDOFF and adjacent references
- Produces: executable audit

- [x] **Step 1: Validate owner terms, rule IDs and state fields.**
- [x] **Step 2: Validate route, README, HANDOFF and adjacent references.**
- [x] **Step 3: Validate GREEN contract and negative cases.**
- [x] **Step 4: Validate mutations and project leak patterns.**

### Task 4: Verification and commit

**Files:**
- Verify all changed files

**Interfaces:**
- Consumes: all docs and audits
- Produces: committed and pushed `main`

- [ ] **Step 1: Run mutation audit and normal audit.**
- [ ] **Step 2: Run all existing audit scripts.**
- [ ] **Step 3: Run Markdown link validation.**
- [ ] **Step 4: Run `git diff --check`.**
- [ ] **Step 5: Run project leak scan.**
- [ ] **Step 6: Stage, commit and push to `main`.**
