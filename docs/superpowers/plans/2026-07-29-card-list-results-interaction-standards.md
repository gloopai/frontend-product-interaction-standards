# 卡片列表与卡片式结果规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增卡片列表与卡片式结果 owner，约束卡片结构、点击区、选择/操作边界、编辑禁止、权限无泄露和移动端可达性。

**Architecture:** `references/card-list-results.md` 作为唯一 owner；相邻 references 只补转交关系；`SKILL.md` 负责触发路由；README/HANDOFF 写摘要；`docs/testing/card-list-results/card-list-results-audit.rb` 用静态条款和 mutation 测试保护关键规则。

**Tech Stack:** Markdown 文档、Ruby 标准库审计脚本、Git。

## Global Constraints

- 卡片列表必须声明记录身份、字段映射、交互区域、能力档位、权限边界和运行时验证边界。
- 整张卡片不得作为大链接包裹内部按钮、菜单、checkbox 或复制控件。
- 卡片内不得承载新增、编辑、复制创建、字段保存、行内保存或完整字段表单。
- 未实际执行真实浏览器、键盘、读屏、触摸、断点、权限切换和真实请求竞态检查时，必须标为未验证。

---

### Task 1: RED 审计

**Files:**
- Create: `docs/testing/card-list-results/card-list-results-audit.rb`
- Create: `docs/testing/card-list-results/red-summary.md`

**Interfaces:**
- Consumes: `references/card-list-results.md`、相邻 references、`SKILL.md`、`README.md`、`HANDOFF.md`
- Produces: `ruby docs/testing/card-list-results/card-list-results-audit.rb --mutations`

- [ ] **Step 1: 写失败审计**

脚本检查 `cardListResultState` 字段、卡片结构、大链接禁止、能力档位、选择边界、编辑禁止、权限无泄露、响应式保留、相邻 owner 链接和运行时未验证。

- [ ] **Step 2: 写 RED 摘要**

记录缺失 owner 时应失败的规则族，以及 mutation 覆盖。

- [ ] **Step 3: 运行 RED**

Run: `ruby docs/testing/card-list-results/card-list-results-audit.rb`
Expected: FAIL，因为 owner 和 GREEN 尚未补齐。

### Task 2: Owner 与相邻文档

**Files:**
- Create: `references/card-list-results.md`
- Modify: `references/data-tables.md`
- Modify: `references/list-result-controls.md`
- Modify: `references/page-toolbars-actions.md`
- Modify: `references/buttons.md`
- Modify: `references/overlays-menus-tooltips.md`
- Modify: `references/preview-pane.md`
- Modify: `references/record-editing-surfaces.md`
- Modify: `references/feedback-states.md`
- Modify: `references/responsive-adaptive.md`
- Modify: `references/permissions-tenancy-visibility.md`

**Interfaces:**
- Consumes: Task 1 审计和设计 spec
- Produces: `cardListResultState` owner 和相邻 owner 转交关系

- [ ] **Step 1: 写 owner**

新增 `references/card-list-results.md`，覆盖状态模型、范围排除项、卡片结构、交互区域、能力档位、选择、操作、编辑禁止、权限、反馈、响应式、可访问性和 disposal。

- [ ] **Step 2: 补相邻 owner 链接**

在相邻 references 中加入 `references/card-list-results.md` 关系。

- [ ] **Step 3: 运行审计**

Run: `ruby docs/testing/card-list-results/card-list-results-audit.rb`
Expected: FAIL，仅剩 SKILL/README/HANDOFF/GREEN 未完成。

### Task 3: 路由、摘要与 GREEN

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Create: `docs/testing/card-list-results/green-summary.md`

**Interfaces:**
- Consumes: Task 2 owner
- Produces: 完整可触发规范和通过审计证据

- [ ] **Step 1: 更新路由和摘要**

在 `SKILL.md` 加入卡片列表/卡片式结果路由；在 `README.md` 当前规范、完整规则列表和目录结构加入摘要与文件；在 `HANDOFF.md` 加入阶段性交接。

- [ ] **Step 2: 写 GREEN 摘要**

记录 `cardListResultState` 字段、关键不变量、相邻 owner 和未验证运行时。

- [ ] **Step 3: 运行全量验证**

Run: `ruby docs/testing/card-list-results/card-list-results-audit.rb --mutations`
Run: `for audit in docs/testing/*/*-audit.rb; do case "$audit" in docs/testing/data-tables/attempt-*) continue ;; esac; ruby "$audit" || exit 1; done`
Run: `ruby -e 'files = Dir["**/*.md"].reject { |f| f.start_with?(".worktrees/") }; missing = []; files.each { |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |href| next if href =~ /\A[a-z][a-z0-9+.-]*:/i; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target) } }; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'`
Run: `git diff --check`
Run: `rg -n "fex-admin|/Users/evanqi/code/|src/pages|Ant Design|ant-design|shadcn|Next.js|Vite|React|Vue" references/card-list-results.md docs/testing/card-list-results/red-summary.md docs/testing/card-list-results/green-summary.md README.md || true`

- [ ] **Step 4: Commit and push**

Run: `git add ...`
Run: `git commit -m "docs: 新增卡片列表结果规范"`
Run: `git push origin main`
