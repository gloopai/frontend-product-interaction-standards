# 页面标题区与 Page Header 交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增页面标题区与 Page Header owner，约束标题、副标题、对象身份、状态摘要、标题区操作、权限收敛和移动端标题区。

**Architecture:** 新建 `references/page-header-title-area.md` 作为职责单一 owner；通过 `SKILL.md` 路由触发；在 navigation-routing、page-toolbars-actions、information-display、app-shell-navigation、responsive-adaptive、buttons、permissions-tenancy-visibility 和 admin-console 中建立引用；用 Ruby 审计脚本验证。

**Tech Stack:** Markdown 文档、Ruby 审计脚本、现有 docs/testing 结构、Git。

## Global Constraints

- 文档必须使用中文。
- 不得引用或依赖具体业务项目、框架或组件库。
- 不得削弱导航、App Shell、按钮、工具栏、信息展示、权限和响应式 owner。
- 真实浏览器、键盘、读屏、触摸、移动端和权限/路由变化未执行时必须标为未验证。

---

### Task 1: RED 证据与 owner

**Files:**
- Create: `docs/testing/page-header-title-area/red-summary.md`
- Create: `references/page-header-title-area.md`

**Interfaces:**
- Consumes: existing reference owner style.
- Produces: `pageHeaderState` and owner rules.

- [ ] **Step 1: Write RED summary**

记录状态字段和反例关键词：`pageHeaderState`、`headerOwnerId`、`pageIdentity`、`titleBinding`、`primaryActionSlot`、`navigationBinding`、`permissionBoundary`、`runtimeVerification`、`未验证`。

- [ ] **Step 2: Write owner**

创建标题区规范，覆盖范围、状态模型、标题/副标题、操作槽、导航边界、权限安全、响应式和验收。

### Task 2: 审计和 GREEN 证据

**Files:**
- Create: `docs/testing/page-header-title-area/page-header-title-area-audit.rb`
- Create: `docs/testing/page-header-title-area/green-summary.md`

**Interfaces:**
- Consumes: owner and integrated docs.
- Produces: mutation audit command.

- [ ] **Step 1: Add audit script**

脚本检查 owner 状态、硬性规则、SKILL route、README/HANDOFF、相邻 owner 引用和项目专有词泄漏。

- [ ] **Step 2: Add GREEN summary**

记录状态模型、集成关系和未验证边界。

### Task 3: 路由和相邻引用

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Modify: `references/navigation-routing.md`
- Modify: `references/page-toolbars-actions.md`
- Modify: `references/information-display.md`
- Modify: `references/app-shell-navigation.md`
- Modify: `references/responsive-adaptive.md`
- Modify: `references/buttons.md`
- Modify: `references/permissions-tenancy-visibility.md`
- Modify: `references/admin-console.md`

**Interfaces:**
- Consumes: new owner.
- Produces: discoverable and cross-linked owner.

- [ ] **Step 1: Add SKILL route**

添加 Page Header、页面标题区、标题栏、页面标题、副标题、对象标题、状态摘要、标题区主操作等关键词。

- [ ] **Step 2: Add summaries**

补 README 和 HANDOFF。

- [ ] **Step 3: Add adjacent links**

在相邻 owner 中声明职责分界。

### Task 4: 验证、提交和推送

**Files:**
- Verify all changed files.

**Interfaces:**
- Consumes: audit scripts and git state.
- Produces: pushed `main` commit.

- [ ] **Step 1: Run targeted mutation audit**

Run: `ruby docs/testing/page-header-title-area/page-header-title-area-audit.rb --mutations`

- [ ] **Step 2: Run all audits**

Run all `docs/testing/*/*-audit.rb`, skipping existing data-table attempts.

- [ ] **Step 3: Run link, whitespace and leak checks**

Run markdown link resolver, `git diff --check`, and project-specific leak scan.

- [ ] **Step 4: Commit and push**

Commit message: `docs: 新增页面标题区规范`; push to `main`.
