# 概览页与仪表盘首页规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增概览页与仪表盘首页 owner，约束页面级共享快照、只读默认、模块状态一致性、权限无泄露和移动端保真。

**Architecture:** `references/overview-dashboard-pages.md` 作为页面级 owner；相邻 references 补转交关系；`SKILL.md` 负责触发路由；README/HANDOFF 写摘要；`docs/testing/overview-dashboard-pages/overview-dashboard-pages-audit.rb` 保护关键条款。

**Tech Stack:** Markdown 文档、Ruby 标准库审计脚本、Git。

## Global Constraints

- 概览页和仪表盘首页默认只读展示，能力必须显式声明。
- KPI、图表、明细、导出和页面摘要共享同一业务范围时，必须引用同一页面级快照。
- 移动端不得删除页面标题、筛选摘要、时间范围、口径、告警、权限、延迟、刷新、明细/导出和恢复路径。
- 未实际执行真实浏览器、键盘、读屏、触摸、断点、权限切换和真实请求竞态检查时，必须标为未验证。

---

### Task 1: RED 审计

**Files:**
- Create: `docs/testing/overview-dashboard-pages/overview-dashboard-pages-audit.rb`
- Create: `docs/testing/overview-dashboard-pages/red-summary.md`

**Interfaces:**
- Consumes: owner、相邻 references、SKILL、README、HANDOFF、GREEN/RED
- Produces: `ruby docs/testing/overview-dashboard-pages/overview-dashboard-pages-audit.rb --mutations`

- [ ] **Step 1: 写审计脚本**

检查 `overviewDashboardState` 字段、只读默认、共享快照、差异说明、页面级状态、告警可达、移动端保留、导出/钻取绑定、权限无泄露、相邻 owner 和运行时未验证。

- [ ] **Step 2: 写 RED 摘要**

记录缺失 owner 时应失败的条款和 mutation 覆盖。

### Task 2: Owner 与相邻文档

**Files:**
- Create: `references/overview-dashboard-pages.md`
- Modify: `references/admin-console.md`
- Modify: `references/information-display.md`
- Modify: `references/charts-visualization.md`
- Modify: `references/data-tables.md`
- Modify: `references/query-filters.md`
- Modify: `references/date-time-ranges.md`
- Modify: `references/exports-downloads-artifacts.md`
- Modify: `references/feedback-states.md`
- Modify: `references/responsive-adaptive.md`
- Modify: `references/permissions-tenancy-visibility.md`

**Interfaces:**
- Consumes: Task 1 审计
- Produces: `overviewDashboardState` owner 和相邻 owner 链接

- [ ] **Step 1: 写 owner**

新增 `references/overview-dashboard-pages.md`。

- [ ] **Step 2: 补相邻 owner**

在相邻 references 加入 `references/overview-dashboard-pages.md` 与 `overview-dashboard-pages.md`。

### Task 3: 路由、摘要、验证和提交

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Create: `docs/testing/overview-dashboard-pages/green-summary.md`

**Interfaces:**
- Consumes: Task 2 owner
- Produces: 可触发规范、GREEN 证据、提交并推送

- [ ] **Step 1: 更新路由和摘要**

补 SKILL/README/HANDOFF。

- [ ] **Step 2: 运行验证**

Run: `ruby docs/testing/overview-dashboard-pages/overview-dashboard-pages-audit.rb --mutations`
Run: `for audit in docs/testing/*/*-audit.rb; do case "$audit" in docs/testing/data-tables/attempt-*) continue ;; esac; ruby "$audit" || exit 1; done`
Run: `ruby -e 'files = Dir["**/*.md"].reject { |f| f.start_with?(".worktrees/") }; missing = []; files.each { |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |href| next if href =~ /\A[a-z][a-z0-9+.-]*:/i; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target) } }; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'`
Run: `git diff --check`
Run: `rg -n "fex-admin|/Users/evanqi/code/|src/pages|Ant Design|ant-design|shadcn|Next.js|Vite|React|Vue" references/overview-dashboard-pages.md docs/testing/overview-dashboard-pages/red-summary.md docs/testing/overview-dashboard-pages/green-summary.md README.md || true`

- [ ] **Step 3: Commit and push**

Run: `git add ...`
Run: `git commit -m "docs: 新增概览仪表盘页面规范"`
Run: `git push origin main`
