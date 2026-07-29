# 字段说明、帮助文本与占位提示交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增字段说明、帮助文本与占位提示 owner，约束 label、placeholder、help text、必填/选填、单位、空值、权限原因和移动端等价路径。

**Architecture:** 新建 `references/field-guidance-help-text.md` 作为职责单一 owner；通过 `SKILL.md` 路由触发；在 forms、information-display、overlays、responsive、permissions 中建立交叉引用；用 Ruby 审计脚本验证 owner 状态、路由、摘要、相邻引用和项目无关性。

**Tech Stack:** Markdown 文档、Ruby 审计脚本、现有 docs/testing 结构、Git。

## Global Constraints

- 文档必须使用中文。
- 不得引用或依赖具体业务项目、框架或组件库。
- 不能削弱 `forms.md`、`information-display.md`、`overlays-menus-tooltips.md`、`responsive-adaptive.md` 或 `permissions-tenancy-visibility.md`。
- 真实浏览器、键盘、读屏、触摸、移动端和权限切换未执行时必须标为未验证。

---

### Task 1: RED 证据与 owner 初稿

**Files:**
- Create: `docs/testing/field-guidance-help-text/red-summary.md`
- Create: `references/field-guidance-help-text.md`

**Interfaces:**
- Consumes: existing reference owner style.
- Produces: `fieldGuidanceState` and required owner terms for audit.

- [ ] **Step 1: Write RED summary**

记录新增 owner 应覆盖的状态字段和反例关键词：`fieldGuidanceState`、`guidanceOwnerId`、`placeholderPolicy`、`helpDisclosurePolicy`、`errorRelationship`、`runtimeVerification`、`未验证`。

- [ ] **Step 2: Write owner document**

创建字段说明规范，覆盖范围、状态模型、label/placeholder/必填、帮助说明、错误关系、权限安全、响应式和完成前检查。

### Task 2: 审计脚本与 GREEN 证据

**Files:**
- Create: `docs/testing/field-guidance-help-text/field-guidance-help-text-audit.rb`
- Create: `docs/testing/field-guidance-help-text/green-summary.md`

**Interfaces:**
- Consumes: `references/field-guidance-help-text.md`.
- Produces: executable audit command `ruby docs/testing/field-guidance-help-text/field-guidance-help-text-audit.rb --mutations`.

- [ ] **Step 1: Add audit script**

脚本检查 owner 状态字段、关键硬性规则、SKILL route、README/HANDOFF 摘要、相邻 owner 引用和项目专有词泄漏。

- [ ] **Step 2: Add GREEN summary**

记录字段说明 owner 的状态模型、集成关系和未验证边界。

### Task 3: 路由、摘要与相邻 owner 集成

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Modify: `references/forms.md`
- Modify: `references/information-display.md`
- Modify: `references/overlays-menus-tooltips.md`
- Modify: `references/responsive-adaptive.md`
- Modify: `references/permissions-tenancy-visibility.md`

**Interfaces:**
- Consumes: new owner and audit terms.
- Produces: discoverable route and cross-owner handoff.

- [ ] **Step 1: Add SKILL route**

添加 label、字段说明、帮助文本、placeholder、必填/选填、单位、格式、空值说明、权限原因等关键词到 `references/field-guidance-help-text.md`。

- [ ] **Step 2: Add README and HANDOFF summary**

补使用者摘要、完整规则入口、目录树和交接摘要。

- [ ] **Step 3: Add adjacent owner links**

在 forms、information-display、overlays、responsive、permissions 中说明何时同时执行 `references/field-guidance-help-text.md`。

### Task 4: 验证、提交与推送

**Files:**
- Verify all changed files.

**Interfaces:**
- Consumes: audit scripts and git state.
- Produces: pushed `main` commit.

- [ ] **Step 1: Run targeted mutation audit**

Run: `ruby docs/testing/field-guidance-help-text/field-guidance-help-text-audit.rb --mutations`

- [ ] **Step 2: Run all audits**

Run all `docs/testing/*/*-audit.rb`, skipping only existing data-table attempts.

- [ ] **Step 3: Run link, whitespace and leak checks**

Run markdown link resolver, `git diff --check`, and project-specific leak scan.

- [ ] **Step 4: Commit and push**

Commit message: `docs: 新增字段说明帮助文本规范`; push to `main`.
