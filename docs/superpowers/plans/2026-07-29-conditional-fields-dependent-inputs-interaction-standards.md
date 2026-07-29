# Conditional Fields / Dependent Inputs Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增条件字段与依赖输入 owner，约束字段联动、清值、条件必填、候选失效、提交快照和权限无泄露。

**Architecture:** 新增一个职责单一的 Markdown owner，并在 SKILL、README、HANDOFF 和相邻 owner 中建立路由。用 Ruby 审计脚本验证 owner 术语、状态字段、相邻路由和项目词隔离。

**Tech Stack:** Markdown 文档、Ruby 结构化审计、Git。

## Global Constraints

- 文档必须使用中文。
- 不引入具体业务项目、技术栈或组件库名称。
- 未执行真实浏览器、键盘、读屏、触摸、IME、异步迟到、权限切换、移动端和缩放验证时，必须标为未验证。

---

### Task 1: Owner 文档和路由

**Files:**
- Create: `references/conditional-fields-dependent-inputs.md`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: 现有 `forms.md`、`field-guidance-help-text.md`、`selects-comboboxes.md`、`query-filters.md`、`settings-preferences-configuration.md` 和 `permissions-tenancy-visibility.md`。
- Produces: `fieldDependencyState` 和 `references/conditional-fields-dependent-inputs.md` 路由。

- [ ] **Step 1: 编写 owner**

写入 `references/conditional-fields-dependent-inputs.md`，包含 `fieldDependencyState`、显隐/禁用/只读语义、上游变化、清值、候选失效、条件必填、自动填充、权限、移动端和完成前检查。

- [ ] **Step 2: 更新 SKILL 路由**

在 `SKILL.md` 增加条件字段、依赖字段、字段联动、条件显示、条件必填、dependent field、conditional field 等关键词，指向 `references/conditional-fields-dependent-inputs.md`。

- [ ] **Step 3: 更新 README 和 HANDOFF**

在 README 当前规范列表和完整规则索引中加入该 owner；在 HANDOFF 增加中文交接摘要。

### Task 2: 相邻 owner 转接

**Files:**
- Modify: `references/forms.md`
- Modify: `references/field-guidance-help-text.md`
- Modify: `references/selects-comboboxes.md`
- Modify: `references/multi-select-tag-inputs.md`
- Modify: `references/query-filters.md`
- Modify: `references/settings-preferences-configuration.md`
- Modify: `references/permissions-tenancy-visibility.md`
- Modify: `references/tree-hierarchy.md`

**Interfaces:**
- Consumes: Task 1 的 owner 路由。
- Produces: 表单、字段说明、选择器、筛选、设置、权限和树形级联到条件字段 owner 的职责边界。

- [ ] **Step 1: 更新表单与字段说明 owner**

说明字段值、dirty、提交和错误仍归表单；条件显隐、条件必填、清值、说明变化和依赖图归条件字段 owner。

- [ ] **Step 2: 更新输入与筛选 owner**

说明 Select、多选、树形和筛选 owner 负责自身控件会话，条件字段 owner 负责上游变化后的下游策略。

- [ ] **Step 3: 更新设置与权限 owner**

说明设置页和权限变化下，旧字段、旧候选、旧错误和旧提交 payload 必须收敛。

### Task 3: 审计和验证

**Files:**
- Create: `docs/testing/conditional-fields-dependent-inputs/conditional-fields-dependent-inputs-audit.rb`
- Create: `docs/testing/conditional-fields-dependent-inputs/red-summary.md`
- Create: `docs/testing/conditional-fields-dependent-inputs/green-summary.md`

**Interfaces:**
- Consumes: Task 1 和 Task 2 的文档。
- Produces: 可重复执行的结构化审计。

- [ ] **Step 1: 写审计脚本**

审计必须检查 `fieldDependencyState`、状态字段、核心硬规则、SKILL 路由、README、HANDOFF 和相邻 owner 转接。

- [ ] **Step 2: 写 RED/GREEN 复核**

RED 说明审计拒绝缺少依赖 owner、隐藏值静默提交、条件必填缺失、候选失效缺失和权限泄露；GREEN 说明最终通过条件。

- [ ] **Step 3: 跑验证**

执行：

```bash
ruby docs/testing/conditional-fields-dependent-inputs/conditional-fields-dependent-inputs-audit.rb --mutations
ruby docs/testing/conditional-fields-dependent-inputs/conditional-fields-dependent-inputs-audit.rb
for audit in docs/testing/*/*-audit.rb; do
  case "$audit" in
    docs/testing/data-tables/attempt-*) continue ;;
  esac
  ruby "$audit" || exit 1
done
ruby -e 'files = Dir["**/*.md"].reject { |f| f.start_with?(".worktrees/") }; missing = []; files.each { |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |href| next if href =~ /\A[a-z][a-z0-9+.-]*:/i; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target) } }; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
git diff --check
```

