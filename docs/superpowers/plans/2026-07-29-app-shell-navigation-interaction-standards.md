# App Shell Navigation Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Chinese management-console App Shell/navigation-frame interaction owner.

**Architecture:** Add one owner document, one executable audit, RED/GREEN evidence, route/summary updates, and adjacent owner links. The owner covers global frame state and delegates route semantics, permission resolution, responsive geometry, search, notifications, menus, buttons and auth to existing owners.

**Tech Stack:** Markdown documentation and Ruby audit scripts.

## Global Constraints

- 复核文档使用中文。
- 不引入具体业务项目、框架、组件库或源码路径。
- 新类别规范创建职责单一的 `references/<category>.md`，并在 `SKILL.md` 增加路由。
- 未执行真实浏览器、键盘、读屏、触摸、权限、租户切换或移动端检查时必须标为未验证。

---

### Task 1: RED audit contract

**Files:**
- Create: `docs/testing/app-shell-navigation/app-shell-navigation-audit.rb`
- Create: `docs/testing/app-shell-navigation/red-summary.md`

**Interfaces:**
- Produces: required terms for owner, routing, README/HANDOFF, adjacent links and evidence.

- [x] **Step 1: Write failing audit**

The audit fails until the owner, route, evidence and adjacent links exist.

- [x] **Step 2: Write RED evidence**

Document the missing App Shell owner and expected `appShellNavigationState`.

### Task 2: Owner and integration

**Files:**
- Create: `references/app-shell-navigation.md`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Modify: adjacent references.

**Interfaces:**
- Consumes: audit terms from Task 1.
- Produces: App Shell owner and route coverage.

- [x] **Step 1: Add owner document**

Define shell scope, state model, current navigation, workspace switch, global entries, permission cleanup, mobile shape and lifecycle.

- [x] **Step 2: Add route and summaries**

Update skill routing, README and HANDOFF.

- [x] **Step 3: Add adjacent links**

Link from navigation routing, permissions, admin console, responsive, search, notifications, menus, buttons and auth session.

### Task 3: GREEN evidence and verification

**Files:**
- Create: `docs/testing/app-shell-navigation/green-summary.md`

**Interfaces:**
- Consumes: completed owner and integrations.
- Produces: verified documentation evidence.

- [x] **Step 1: Write GREEN evidence**

Summarize state fields, integration coverage and runtime boundary.

- [ ] **Step 2: Run owner audit with mutations**

Run: `ruby docs/testing/app-shell-navigation/app-shell-navigation-audit.rb --mutations`

- [ ] **Step 3: Run full verification**

Run all repository audits, markdown link check, `git diff --check`, and project-specific leakage scan.

- [ ] **Step 4: Commit and push**

Commit message: `docs: 新增应用外框导航规范`
