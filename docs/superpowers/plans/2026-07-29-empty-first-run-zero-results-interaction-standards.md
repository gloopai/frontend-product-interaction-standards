# Empty / First Run / Zero Results Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增空态、无结果与首次使用引导 owner，避免管理台把所有空态都写成“暂无数据”。

**Architecture:** 新增一个职责单一的 Markdown owner，并在 SKILL、README、HANDOFF 和相邻 owner 中建立路由。用 Ruby 审计脚本验证 owner 术语、状态字段、相邻路由和项目词隔离。

**Tech Stack:** Markdown 文档、Ruby 结构化审计、Git。

## Global Constraints

- 文档必须使用中文。
- 不引入具体业务项目、技术栈或组件库名称。
- 未执行真实浏览器、键盘、读屏、触摸、筛选变化、权限切换、路由恢复、移动端和缩放验证时，必须标为未验证。

---

### Task 1: Owner 文档和路由

**Files:**
- Create: `references/empty-first-run-zero-results.md`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: 现有 `feedback-states.md`、`list-result-controls.md`、`query-filters.md`、`buttons.md`、`permissions-tenancy-visibility.md`。
- Produces: `emptyStateDecision` 和 `references/empty-first-run-zero-results.md` 路由。

- [ ] **Step 1: 编写 owner**

写入 `references/empty-first-run-zero-results.md`，包含 `emptyStateDecision`、空态原因、CTA、筛选恢复、权限无泄露、移动端和完成前检查。

- [ ] **Step 2: 更新 SKILL 路由**

在 `SKILL.md` 增加空态、无结果、首次使用、zero results、first run、empty CTA 等关键词，指向 `references/empty-first-run-zero-results.md`。

- [ ] **Step 3: 更新 README 和 HANDOFF**

在 README 当前规范列表和完整规则索引中加入该 owner；在 HANDOFF 增加中文交接摘要。

### Task 2: 相邻 owner 转接

**Files:**
- Modify: `references/feedback-states.md`
- Modify: `references/list-result-controls.md`
- Modify: `references/page-content-layout-sections.md`
- Modify: `references/buttons.md`
- Modify: `references/permissions-tenancy-visibility.md`
- Modify: `references/query-filters.md`
- Modify: `references/data-tables.md`
- Modify: `references/card-list-results.md`

**Interfaces:**
- Consumes: Task 1 的 owner 路由。
- Produces: 高频列表、页面、按钮、权限、筛选和结果 owner 到空态 owner 的职责边界。

- [ ] **Step 1: 更新反馈和结果 owner**

在反馈状态、列表结果控制和页面内容布局中转接空态原因、CTA 和恢复路径。

- [ ] **Step 2: 更新交互入口 owner**

在按钮、筛选、表格和卡片中说明创建、清筛选、重置筛选、零结果和首次使用引导的边界。

- [ ] **Step 3: 更新权限 owner**

明确权限空态必须执行无泄露，不能把权限不可见写成真实没有数据。

### Task 3: 审计和验证

**Files:**
- Create: `docs/testing/empty-first-run-zero-results/empty-first-run-zero-results-audit.rb`
- Create: `docs/testing/empty-first-run-zero-results/red-summary.md`
- Create: `docs/testing/empty-first-run-zero-results/green-summary.md`

**Interfaces:**
- Consumes: Task 1 和 Task 2 的文档。
- Produces: 可重复执行的结构化审计。

- [ ] **Step 1: 写审计脚本**

审计必须检查 `emptyStateDecision`、状态字段、核心硬规则、SKILL 路由、README、HANDOFF 和相邻 owner 转接。

- [ ] **Step 2: 写 RED/GREEN 复核**

RED 说明审计拒绝单一“暂无数据”、zeroResults 给创建入口、权限泄露和缺少路由；GREEN 说明最终通过条件。

- [ ] **Step 3: 跑验证**

执行：

```bash
ruby docs/testing/empty-first-run-zero-results/empty-first-run-zero-results-audit.rb --mutations
ruby docs/testing/empty-first-run-zero-results/empty-first-run-zero-results-audit.rb
for audit in docs/testing/*/*-audit.rb; do
  case "$audit" in
    docs/testing/data-tables/attempt-*) continue ;;
  esac
  ruby "$audit" || exit 1
done
ruby -e 'files = Dir["**/*.md"].reject { |f| f.start_with?(".worktrees/") }; missing = []; files.each { |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |href| next if href =~ /\A[a-z][a-z0-9+.-]*:/i; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target) } }; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
git diff --check
```

