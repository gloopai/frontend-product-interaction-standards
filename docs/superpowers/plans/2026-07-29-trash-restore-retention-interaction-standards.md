# 回收站、软删除、归档恢复与保留期交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增删除后生命周期 owner，约束回收站、软删除、恢复、永久删除、保留期、权限和审计。

**Architecture:** 以 `references/trash-restore-retention.md` 为唯一事实来源，`SKILL.md` 负责关键词路由，`README.md`/`HANDOFF.md` 负责可发现性，相邻 owner 负责交叉转交，Ruby 审计脚本负责结构化验收和 mutation 反向检查。

**Tech Stack:** Markdown 规范文档、Ruby 审计脚本、现有 docs/testing 结构、git。

## Global Constraints

- 文档必须保持中文。
- 不得引入具体业务项目、框架、组件库或本地路径。
- 本 owner 不替代 `risk-actions.md`、`status-lifecycle-transitions.md`、`row-contextual-actions.md`、`bulk-actions-batch-operations.md`、`permissions-tenancy-visibility.md`、`audit-log-activity-history.md` 或 `async-jobs-task-center.md`。
- 未执行真实浏览器、键盘、读屏、移动端、权限切换、迟到响应、保留期到期、批量部分成功和审计追溯验证时，必须标为未验证。

---

### Task 1: 新增 owner 正文

**Files:**
- Create: `references/trash-restore-retention.md`

**Interfaces:**
- Produces: `trashRestoreState`、恢复/保留期/永久删除/旧入口清理规则。

- [x] **Step 1: 写 owner 文档**

覆盖范围、状态模型、删除/归档/禁用/永久删除语义、回收站、恢复入口、保留期、永久删除、列表搜索导出收敛、权限审计、批量任务、移动端和完成前检查。

### Task 2: 接入路由和索引

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: `references/trash-restore-retention.md`。
- Produces: 自动路由和人类可发现入口。

- [ ] **Step 1: 更新 `SKILL.md`**

加入删除后恢复、软删除、回收站、归档恢复、永久删除、保留期、legal hold、trash、restore、soft delete、retention 等关键词。

- [ ] **Step 2: 更新 `README.md` 和 `HANDOFF.md`**

加入当前规范、完整规则列表、结构树和中文交接摘要。

### Task 3: 接入相邻 owner

**Files:**
- Modify: `references/risk-actions.md`
- Modify: `references/status-lifecycle-transitions.md`
- Modify: `references/row-contextual-actions.md`
- Modify: `references/bulk-actions-batch-operations.md`
- Modify: `references/list-result-controls.md`
- Modify: `references/empty-first-run-zero-results.md`
- Modify: `references/permissions-tenancy-visibility.md`
- Modify: `references/audit-log-activity-history.md`
- Modify: `references/async-jobs-task-center.md`
- Modify: `references/global-feedback.md`

**Interfaces:**
- Produces: 相邻 owner 中的 `references/trash-restore-retention.md` 和 `trashRestoreState` 转交。

- [ ] **Step 1: 补转交句**

确保每个相邻 owner 明确删除后生命周期由本 owner 负责。

### Task 4: 新增审计和证据

**Files:**
- Create: `docs/testing/trash-restore-retention/trash-restore-retention-audit.rb`
- Create: `docs/testing/trash-restore-retention/red-summary.md`
- Create: `docs/testing/trash-restore-retention/green-summary.md`

**Interfaces:**
- Consumes: owner、路由、索引和相邻 owner。
- Produces: 可执行验收。

- [ ] **Step 1: 写审计脚本**

检查状态字段、核心术语、路由、索引、相邻引用、红绿证据和泄漏。

- [ ] **Step 2: 跑单项与 mutation**

```bash
ruby docs/testing/trash-restore-retention/trash-restore-retention-audit.rb --mutations
ruby docs/testing/trash-restore-retention/trash-restore-retention-audit.rb
```

### Task 5: 全量验证与提交

**Files:**
- Modify/Create: 本计划中所有文件

**Interfaces:**
- Produces: 已验证并推送的提交。

- [ ] **Step 1: 运行全量审计、链接、空白和泄漏检查**

- [ ] **Step 2: 提交并推送**

提交信息：`docs: 新增回收站恢复保留规范`

