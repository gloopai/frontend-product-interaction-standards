# 数字、金额、比例与配额输入交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增数字型输入交互 owner，并通过路由、文档索引、相邻 owner 和审计脚本强制执行。

**Architecture:** 以 `references/numeric-amount-inputs.md` 作为唯一事实来源，`SKILL.md` 负责自动路由，`README.md`/`HANDOFF.md` 负责可发现性，相邻 owner 负责交叉转交，Ruby 审计脚本负责结构化验收和 mutation 反向检查。

**Tech Stack:** Markdown 规范文档、Ruby 审计脚本、现有 docs/testing 结构、git。

## Global Constraints

- 文档必须保持中文。
- 不得引入具体业务项目、框架、组件库或本地路径。
- 数字输入 owner 不替代 `forms.md`、`field-guidance-help-text.md`、`billing-subscription-invoices.md`、`risk-actions.md`、`permissions-tenancy-visibility.md` 或 `responsive-adaptive.md`。
- 未执行真实浏览器、键盘、读屏、移动端、输入法、粘贴、缩放、权限切换和服务端回填验证时，必须标为未验证。

---

### Task 1: 新增数字输入 owner 正文

**Files:**
- Create: `references/numeric-amount-inputs.md`

**Interfaces:**
- Consumes: 现有 owner 的转交约定。
- Produces: `numericInputState`、完成前检查、硬性禁止条款。

- [x] **Step 1: 写 owner 文档**

写入范围、状态模型、草稿/解析/提交分离、单位/倍率、精度/舍入、边界/步进、格式化/粘贴/IME、权限安全、移动端可访问性和完成前检查。

- [x] **Step 2: 自查 owner**

确认包含 `numericInputState`、`draftText`、`parsedValue`、`committedValue`、`precisionPolicy`、`rangePolicy`、`unitBinding`、`runtimeVerification` 和 `未验证`。

### Task 2: 接入路由和索引

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: Task 1 的 `references/numeric-amount-inputs.md`。
- Produces: 自动路由和人类可发现入口。

- [x] **Step 1: 更新 `SKILL.md`**

添加数字、金额、百分比、配额、阈值、预算、容量、时长、number input、currency input、percent input、quota input 等关键词路由。

- [x] **Step 2: 更新 `README.md`**

在当前规范列表、规则入口和结构树中加入数字输入规范。

- [x] **Step 3: 更新 `HANDOFF.md`**

在表单/字段说明附近加入数字输入交接摘要，并在结构树加入新文件。

### Task 3: 接入相邻 owner

**Files:**
- Modify: `references/forms.md`
- Modify: `references/field-guidance-help-text.md`
- Modify: `references/settings-preferences-configuration.md`
- Modify: `references/billing-subscription-invoices.md`
- Modify: `references/query-filters.md`
- Modify: `references/chart-visualization-builders.md`
- Modify: `references/permissions-tenancy-visibility.md`
- Modify: `references/risk-actions.md`

**Interfaces:**
- Consumes: Task 1 的 owner 路径和 `numericInputState`。
- Produces: 相邻规范中的强制转交句。

- [x] **Step 1: 在相邻 owner 中补引用**

每个文件加入 `references/numeric-amount-inputs.md` 和 `numericInputState`，说明数字型字段由数字输入 owner 负责。

### Task 4: 新增审计和证据

**Files:**
- Create: `docs/testing/numeric-amount-inputs/numeric-amount-inputs-audit.rb`
- Create: `docs/testing/numeric-amount-inputs/red-summary.md`
- Create: `docs/testing/numeric-amount-inputs/green-summary.md`

**Interfaces:**
- Consumes: Task 1-3 的文档内容。
- Produces: 可执行验收。

- [x] **Step 1: 写审计脚本**

检查 owner 字段、核心术语、路由、README、HANDOFF、相邻 owner、红绿证据和项目泄漏。

- [x] **Step 2: 写红绿证据**

红证据描述没有 owner 时会漏掉的失败；绿证据描述当前规范如何覆盖。

- [x] **Step 3: 运行审计**

运行：

```bash
ruby docs/testing/numeric-amount-inputs/numeric-amount-inputs-audit.rb --mutations
ruby docs/testing/numeric-amount-inputs/numeric-amount-inputs-audit.rb
```

预期均退出 0。

### Task 5: 全量验证与提交

**Files:**
- Modify/Create: 本计划中所有文件

**Interfaces:**
- Consumes: Task 1-4 的结果。
- Produces: 已验证并推送的提交。

- [ ] **Step 1: 运行全量审计**

```bash
for audit in docs/testing/*/*-audit.rb; do
  case "$audit" in
    docs/testing/data-tables/attempt-*) continue ;;
  esac
  ruby "$audit" || exit 1
done
```

- [ ] **Step 2: 检查链接、空白和泄漏**

运行 Markdown 链接检查、`git diff --check` 和新增文件泄漏扫描。

- [ ] **Step 3: 提交并推送**

```bash
git add ...
git commit -m "docs: 新增数字金额输入规范"
git push origin main
```

