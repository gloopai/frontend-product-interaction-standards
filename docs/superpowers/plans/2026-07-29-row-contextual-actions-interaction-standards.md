# Row / Contextual Actions Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增行操作与上下文操作 owner，约束单条记录动作的目标冻结、菜单边界、权限、请求、结果和旧行清理。

**Architecture:** 新增一个职责单一的 Markdown owner，并在 SKILL、README、HANDOFF 和相邻 owner 中建立路由。用 Ruby 审计脚本验证 owner 术语、状态字段、相邻路由和项目词隔离。

**Tech Stack:** Markdown 文档、Ruby 结构化审计、Git。

## Global Constraints

- 文档必须使用中文。
- 不引入具体业务项目、技术栈或组件库名称。
- 未执行真实浏览器、键盘、读屏、触摸、右键、长按、虚拟列表、权限切换、移动端和缩放验证时，必须标为未验证。

---

### Task 1: Owner 文档和路由

**Files:**
- Create: `references/row-contextual-actions.md`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: 现有 `data-tables.md`、`card-list-results.md`、`buttons.md`、`overlays-menus-tooltips.md`、`permissions-tenancy-visibility.md`。
- Produces: `rowActionState` 和 `references/row-contextual-actions.md` 路由。

- [ ] **Step 1: 编写 owner**

写入 `references/row-contextual-actions.md`，包含 `rowActionState`、目标冻结、旧行防护、动作可见性、菜单边界、请求、结果、权限、移动端和完成前检查。

- [ ] **Step 2: 更新 SKILL 路由**

在 `SKILL.md` 增加行操作、记录操作、上下文操作、更多操作、row action、contextual action、context menu 等关键词，指向 `references/row-contextual-actions.md`。

- [ ] **Step 3: 更新 README 和 HANDOFF**

在 README 当前规范列表和完整规则索引中加入该 owner；在 HANDOFF 增加中文交接摘要。

### Task 2: 相邻 owner 转接

**Files:**
- Modify: `references/data-tables.md`
- Modify: `references/card-list-results.md`
- Modify: `references/buttons.md`
- Modify: `references/overlays-menus-tooltips.md`
- Modify: `references/permissions-tenancy-visibility.md`
- Modify: `references/risk-actions.md`
- Modify: `references/record-editing-surfaces.md`
- Modify: `references/preview-pane.md`
- Modify: `references/status-lifecycle-transitions.md`

**Interfaces:**
- Consumes: Task 1 的 owner 路由。
- Produces: 表格、卡片、按钮、菜单、权限、风险、编辑和预览到行操作 owner 的职责边界。

- [ ] **Step 1: 更新列表与卡片 owner**

说明表格/卡片负责记录展示和结构；行操作 owner 负责单条动作目标、权限、请求和结果。

- [ ] **Step 2: 更新入口与浮层 owner**

说明按钮和菜单只负责触发形态，动作目录和单条请求归行操作 owner。

- [ ] **Step 3: 更新风险、编辑、预览和权限 owner**

说明危险动作、编辑动作、预览动作和权限变化必须由对应 owner 与行操作 owner 共同执行。

### Task 3: 审计和验证

**Files:**
- Create: `docs/testing/row-contextual-actions/row-contextual-actions-audit.rb`
- Create: `docs/testing/row-contextual-actions/red-summary.md`
- Create: `docs/testing/row-contextual-actions/green-summary.md`

**Interfaces:**
- Consumes: Task 1 和 Task 2 的文档。
- Produces: 可重复执行的结构化审计。

- [ ] **Step 1: 写审计脚本**

审计必须检查 `rowActionState`、状态字段、核心硬规则、SKILL 路由、README、HANDOFF 和相邻 owner 转接。

- [ ] **Step 2: 写 RED/GREEN 复核**

RED 说明审计拒绝缺少目标冻结、旧行防护、菜单边界、Toast-only、权限泄露和路由；GREEN 说明最终通过条件。

- [ ] **Step 3: 跑验证**

执行：

```bash
ruby docs/testing/row-contextual-actions/row-contextual-actions-audit.rb --mutations
ruby docs/testing/row-contextual-actions/row-contextual-actions-audit.rb
for audit in docs/testing/*/*-audit.rb; do
  case "$audit" in
    docs/testing/data-tables/attempt-*) continue ;;
  esac
  ruby "$audit" || exit 1
done
ruby -e 'files = Dir["**/*.md"].reject { |f| f.start_with?(".worktrees/") }; missing = []; files.each { |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |href| next if href =~ /\A[a-z][a-z0-9+.-]*:/i; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target) } }; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
git diff --check
```

