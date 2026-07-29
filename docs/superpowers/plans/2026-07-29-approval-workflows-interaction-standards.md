# Approval Workflows Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Chinese approval/review workflow interaction owner for high-frequency management-console approval scenarios.

**Architecture:** Add one owner document, one executable audit, RED/GREEN evidence, and lightweight route/summary/link updates. The owner delegates local concerns to existing status, risk, membership, audit, notification, form, button, table, permission and responsive owners.

**Tech Stack:** Markdown documentation plus Ruby audit scripts already used by this repository.

## Global Constraints

- 复核文档使用中文。
- 不引入具体业务项目、框架、组件库或源码路径。
- 新类别规范创建职责单一的 `references/<category>.md`，并在 `SKILL.md` 增加路由。
- 未执行真实浏览器、键盘、读屏、触摸、权限、通知、审计或移动端检查时必须标为未验证。

---

### Task 1: RED audit contract

**Files:**
- Create: `docs/testing/approval-workflows/approval-workflows-audit.rb`
- Create: `docs/testing/approval-workflows/red-summary.md`

**Interfaces:**
- Produces: audit terms for `approvalWorkflowState`, owner rules, route terms, adjacent links, README/HANDOFF entries and RED/GREEN evidence.

- [x] **Step 1: Write failing audit**

Create an audit that fails until the owner, route, summaries and adjacent links exist.

- [x] **Step 2: Write RED evidence**

Document why the current repository lacks a dedicated approval workflow owner.

### Task 2: Owner and integration

**Files:**
- Create: `references/approval-workflows.md`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Modify: adjacent owner references.

**Interfaces:**
- Consumes: audit terms from Task 1.
- Produces: approval workflow route and owner rules.

- [x] **Step 1: Add owner document**

Define scope, state model, decision intent, comments/attachments, assignment, delegation, notification, audit, permission, batch, mobile and completion checks.

- [x] **Step 2: Add route and summaries**

Update skill routing, README and HANDOFF.

- [x] **Step 3: Add adjacent links**

Link approval workflows from status lifecycle, risk actions, members/access, audit logs, notifications, buttons, forms, data tables, permissions, global feedback, responsive and admin console.

### Task 3: GREEN evidence and verification

**Files:**
- Create: `docs/testing/approval-workflows/green-summary.md`

**Interfaces:**
- Consumes: completed owner and integration changes.
- Produces: verified documentation evidence.

- [x] **Step 1: Write GREEN evidence**

Summarize state model coverage, integration coverage and runtime verification boundary.

- [ ] **Step 2: Run owner audit with mutations**

Run: `ruby docs/testing/approval-workflows/approval-workflows-audit.rb --mutations`

- [ ] **Step 3: Run full verification**

Run all repository audits, markdown link checks, `git diff --check`, and project-specific leakage scan.

- [ ] **Step 4: Commit and push**

Commit message: `docs: 新增审批工作流规范`
