# 乐观更新、撤销与回滚交互规范实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增乐观更新、撤销与回滚交互规范，统一管理 pending mutation、撤销窗口、失败回滚、迟到响应和权威结果合并。

**Architecture:** 新增一个职责单一的 reference owner，并通过 `SKILL.md`、`README.md`、`HANDOFF.md` 和相邻 owner 建立路由。使用 RED/GREEN 文档和 Ruby 审计脚本验证 owner、路由、证据和项目无关性。

**Tech Stack:** Markdown 规范文档、Ruby 静态审计、Git。

## Global Constraints

- 全部新增复核文档使用中文。
- 不引入具体项目名、目录、框架、组件库或技术栈绑定。
- 不把未执行的真实浏览器、移动端、键盘、读屏、弱网、离线、权限变化和迟到响应验证写成已通过。

---

### Task 1: 新增 owner 与设计证据

**Files:**
- Create: `references/optimistic-update-undo.md`
- Create: `docs/superpowers/specs/2026-07-29-optimistic-update-undo-interaction-standards-design.md`
- Create: `docs/testing/optimistic-update-undo/red-summary.md`
- Create: `docs/testing/optimistic-update-undo/green-summary.md`

**Interfaces:**
- Produces: `optimisticMutationState`、`undoPolicy`、`rollbackPolicy`、`reconciliationPolicy`、`idempotencyPolicy`、`runtimeVerification`。

- [x] **Step 1: 写 RED 证据**

记录当前缺口：没有独立 `optimisticMutationState`，乐观 UI 可能伪装成功，撤销只存在 Toast，回滚可能依赖 DOM 或旧缓存。

- [x] **Step 2: 写 owner 正文**

定义状态模型、乐观边界、撤销/回滚、权威结果、迟到响应、权限安全、移动端和完成前检查。

- [x] **Step 3: 写 GREEN 证据**

列明新增 owner、状态字段、硬禁止、相邻 owner 接入和未验证边界。

### Task 2: 接入路由和相邻 owner

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Modify: `references/buttons.md`
- Modify: `references/forms.md`
- Modify: `references/risk-actions.md`
- Modify: `references/status-lifecycle-transitions.md`
- Modify: `references/list-result-controls.md`
- Modify: `references/card-list-results.md`
- Modify: `references/feedback-states.md`
- Modify: `references/permissions-tenancy-visibility.md`

**Interfaces:**
- Consumes: `references/optimistic-update-undo.md`
- Produces: 自动路由和相邻 owner 边界引用。

- [x] **Step 1: 补 SKILL 路由**

加入乐观更新、撤销、回滚、离线队列、迟到响应、幂等等关键词。

- [x] **Step 2: 补 README/HANDOFF 摘要**

让使用者能从首页和交接文档找到 owner。

- [x] **Step 3: 补相邻 owner 引用**

在按钮、表单、风险、状态流转、列表结果、卡片、反馈和权限规范中引用新 owner。

### Task 3: 新增审计并验证

**Files:**
- Create: `docs/testing/optimistic-update-undo/optimistic-update-undo-audit.rb`

**Interfaces:**
- Consumes: owner、路由、README、HANDOFF、相邻 owner 和 RED/GREEN 证据。
- Produces: `PASS: 乐观更新、撤销与回滚 owner、路由和证据符合结构化审计契约。`

- [x] **Step 1: 写审计脚本**

审计状态字段、关键硬禁止、路由关键词、相邻引用、README/HANDOFF 摘要、证据字段和项目泄露。

- [x] **Step 2: 运行专项 mutation 审计**

Run: `ruby docs/testing/optimistic-update-undo/optimistic-update-undo-audit.rb --mutations`

- [x] **Step 3: 运行全量审计、链接检查和 diff 检查**

Run: 全量 `docs/testing/*/*-audit.rb`、Markdown 链接解析、`git diff --check` 和项目泄露扫描。
