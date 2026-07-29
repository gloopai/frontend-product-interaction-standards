# 排序与重排交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增人工排序、拖拽重排、上移下移和顺序保存的交互规范 owner。

**Architecture:** 新增 `references/ordering-reordering.md` 作为唯一 owner，使用 `orderingReorderingState` 管理排序范围、草稿顺序、提交快照、权限、冲突、反馈和验证边界。通过独立 Ruby 审计脚本检查 owner、路由、README、HANDOFF、相邻规范引用和 RED/GREEN 证据。

**Tech Stack:** Markdown 文档、Ruby 审计脚本、Git。

## Global Constraints

- 文档和复核证据必须使用中文。
- 不引入业务项目、框架或组件库专属词。
- 真实浏览器、键盘、读屏、触摸、拖拽、权限变化、断点转换和真实数据竞态未执行时必须标为未验证。

---

### Task 1: 新增 owner 和证据

**Files:**
- Create: `references/ordering-reordering.md`
- Create: `docs/testing/ordering-reordering/red-summary.md`
- Create: `docs/testing/ordering-reordering/green-summary.md`

**Interfaces:**
- Consumes: `record-editing-surfaces.md`、`data-tables.md`、`card-list-results.md`、`page-toolbars-actions.md`、`buttons.md`、`risk-actions.md`、`responsive-adaptive.md`
- Produces: `orderingReorderingState`

- [x] 写入 RED 证据，证明旧做法缺少 owner、常驻排序输入、拖拽-only、当前页伪装全量和未验证边界。
- [x] 写入 `ordering-reordering.md`，定义状态模型、禁止项、承载面选择、草稿/提交、拖拽与键盘替代、分页筛选权限冲突、移动端和完成前检查。
- [x] 写入 GREEN 证据，列出已补齐字段和未验证运行时边界。

### Task 2: 新增审计和路由

**Files:**
- Create: `docs/testing/ordering-reordering/ordering-reordering-audit.rb`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: `orderingReorderingState`、owner 硬规则、RED/GREEN 证据
- Produces: 可执行审计入口

- [x] 审计脚本检查 owner 字段、硬规则、路由、README、HANDOFF、相邻 owner 引用和项目泄漏。
- [x] `SKILL.md` 增加中英文触发词。
- [x] `README.md` 增加摘要、完整规则链接和目录。
- [x] `HANDOFF.md` 增加交接段落和目录。

### Task 3: 相邻 owner 引用与验证

**Files:**
- Modify: `references/record-editing-surfaces.md`
- Modify: `references/data-tables.md`
- Modify: `references/card-list-results.md`
- Modify: `references/page-toolbars-actions.md`
- Modify: `references/buttons.md`
- Modify: `references/risk-actions.md`
- Modify: `references/responsive-adaptive.md`

**Interfaces:**
- Consumes: `references/ordering-reordering.md`
- Produces: 相邻规范中的明确 owner 转交关系

- [x] 补相邻 owner 引用，避免排序重排逻辑落在列表内编辑、表格查询排序或按钮本体中。
- [x] 运行 mutation 审计。
- [x] 运行全量审计、Markdown 链接检查、`git diff --check` 和项目泄漏扫描。
- [ ] 提交并推送到 `main`。
