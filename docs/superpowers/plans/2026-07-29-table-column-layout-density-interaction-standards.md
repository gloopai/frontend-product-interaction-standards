# 表格列设置、列布局与密度交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增表格列布局与密度 owner，约束列显隐、顺序、宽度、固定、密度、持久化和权限收敛。

**Architecture:** 以 `references/table-column-layout-density.md` 为唯一事实来源，`SKILL.md` 负责关键词路由，`README.md`/`HANDOFF.md` 负责可发现性，相邻 owner 负责交叉转交，Ruby 审计脚本负责结构化验收和 mutation 反向检查。

**Tech Stack:** Markdown 规范文档、Ruby 审计脚本、现有 docs/testing 结构、git。

## Global Constraints

- 文档必须保持中文。
- 不得引入具体业务项目、框架、组件库或本地路径。
- 本 owner 不替代 `data-tables.md`、`saved-views-layout-presets.md`、`page-toolbars-actions.md`、`permissions-tenancy-visibility.md` 或 `text-overflow-truncation.md`。
- 未执行真实浏览器、键盘、读屏、触摸、拖拽、横向滚动、固定列、缩放、移动端、权限切换和视图恢复验证时，必须标为未验证。

---

### Task 1: 新增 owner 正文

**Files:**
- Create: `references/table-column-layout-density.md`

**Interfaces:**
- Produces: `tableColumnLayoutState`、列布局/密度/持久化/权限收敛规则。

- [x] **Step 1: 写 owner 文档**

覆盖范围、状态模型、草稿/应用/持久化分离、列可见性、顺序、宽度、固定列、密度、重置、保存视图、移动端和完成前检查。

### Task 2: 接入路由和索引

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: `references/table-column-layout-density.md`。
- Produces: 自动路由和人类可发现入口。

- [ ] **Step 1: 更新 `SKILL.md`**

加入列设置、列显示/隐藏、列宽、固定列、密度、column settings、column visibility、column resize、pinned column、table density 等关键词。

- [ ] **Step 2: 更新 `README.md` 和 `HANDOFF.md`**

加入当前规范、结构树和中文交接摘要。

### Task 3: 接入相邻 owner

**Files:**
- Modify: `references/data-tables.md`
- Modify: `references/saved-views-layout-presets.md`
- Modify: `references/page-toolbars-actions.md`
- Modify: `references/permissions-tenancy-visibility.md`
- Modify: `references/text-overflow-truncation.md`
- Modify: `references/list-result-controls.md`

**Interfaces:**
- Produces: 相邻 owner 中的 `references/table-column-layout-density.md` 和 `tableColumnLayoutState` 转交。

- [ ] **Step 1: 补转交句**

确保每个相邻 owner 明确列布局与密度由本 owner 负责。

### Task 4: 新增审计和证据

**Files:**
- Create: `docs/testing/table-column-layout-density/table-column-layout-density-audit.rb`
- Create: `docs/testing/table-column-layout-density/red-summary.md`
- Create: `docs/testing/table-column-layout-density/green-summary.md`

**Interfaces:**
- Consumes: owner、路由、索引和相邻 owner。
- Produces: 可执行验收。

- [ ] **Step 1: 写审计脚本**

检查状态字段、核心术语、路由、索引、相邻引用、红绿证据和泄漏。

- [ ] **Step 2: 跑单项与 mutation**

```bash
ruby docs/testing/table-column-layout-density/table-column-layout-density-audit.rb --mutations
ruby docs/testing/table-column-layout-density/table-column-layout-density-audit.rb
```

### Task 5: 全量验证与提交

**Files:**
- Modify/Create: 本计划中所有文件

**Interfaces:**
- Produces: 已验证并推送的提交。

- [ ] **Step 1: 运行全量审计、链接、空白和泄漏检查**

- [ ] **Step 2: 提交并推送**

提交信息：`docs: 新增表格列布局密度规范`

