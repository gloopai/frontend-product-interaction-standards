# 详情预览面板规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增详情预览/侧边预览面板 owner，禁止预览面板退化为列表内编辑，并补齐路由、验收和交接。

**Architecture:** 以 `references/preview-pane.md` 作为唯一 owner；`SKILL.md` 负责触发路由；README/HANDOFF 只写摘要和跳转；`docs/testing/preview-pane/preview-pane-audit.rb` 用静态契约和 mutation 测试保护关键规则。

**Tech Stack:** Markdown 文档、Ruby 标准库审计脚本、Git。

## Global Constraints

- 预览面板只读，不能承载新增、编辑、删除确认、危险操作或字段保存。
- 来源列表、详情展示、编辑承载面、Drawer、导航、权限、反馈和响应式 owner 必须保持各自职责。
- 未实际执行真实浏览器、键盘、读屏、触摸、断点、权限切换和真实请求竞态检查时，必须标为未验证。

---

### Task 1: RED 审计

**Files:**
- Create: `docs/testing/preview-pane/preview-pane-audit.rb`
- Create: `docs/testing/preview-pane/red-summary.md`

**Interfaces:**
- Consumes: `references/preview-pane.md`、相邻 references、`SKILL.md`、`README.md`、`HANDOFF.md`
- Produces: 可执行命令 `ruby docs/testing/preview-pane/preview-pane-audit.rb --mutations`

- [ ] **Step 1: 写失败审计**

创建 Ruby 脚本，检查 `previewPaneState` 字段、禁止编辑规则、迟到响应门禁、权限无泄露、移动端转换、相邻 owner 链接、README/HANDOFF 摘要和 RED/GREEN 证据。

- [ ] **Step 2: 写 RED 摘要**

记录审计目标、预期失败点和运行时未验证边界。

- [ ] **Step 3: 运行 RED**

Run: `ruby docs/testing/preview-pane/preview-pane-audit.rb`
Expected: FAIL，因为 owner、路由和 GREEN 尚未存在。

- [ ] **Step 4: Commit**

Run: `git add docs/testing/preview-pane/preview-pane-audit.rb docs/testing/preview-pane/red-summary.md`
Run: `git commit -m "test: 增加详情预览面板规范审计"`

### Task 2: Owner 文档

**Files:**
- Create: `references/preview-pane.md`
- Modify: `references/data-tables.md`
- Modify: `references/information-display.md`
- Modify: `references/record-editing-surfaces.md`
- Modify: `references/drawers.md`
- Modify: `references/navigation-routing.md`
- Modify: `references/permissions-tenancy-visibility.md`
- Modify: `references/feedback-states.md`
- Modify: `references/responsive-adaptive.md`

**Interfaces:**
- Consumes: Task 1 审计字段和设计 spec
- Produces: `previewPaneState` owner 和相邻 owner 链接

- [ ] **Step 1: 写 owner**

新增 `references/preview-pane.md`，包含状态模型、范围排除项、预览目标边界、只读展示、请求门禁、权限无泄露、路由恢复、移动端转换和完成前检查。

- [ ] **Step 2: 写相邻 owner 关系**

在相邻 references 中加入 `references/preview-pane.md`，说明列表预览、只读详情和编辑边界如何转交。

- [ ] **Step 3: 运行审计**

Run: `ruby docs/testing/preview-pane/preview-pane-audit.rb`
Expected: FAIL，仅剩 SKILL/README/HANDOFF/GREEN 未完成。

- [ ] **Step 4: Commit**

Run: `git add references/preview-pane.md references/data-tables.md references/information-display.md references/record-editing-surfaces.md references/drawers.md references/navigation-routing.md references/permissions-tenancy-visibility.md references/feedback-states.md references/responsive-adaptive.md`
Run: `git commit -m "docs: 新增详情预览面板规范"`

### Task 3: 路由、摘要和 GREEN

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Create: `docs/testing/preview-pane/green-summary.md`

**Interfaces:**
- Consumes: Task 2 owner
- Produces: 完整可触发规范和通过审计证据

- [ ] **Step 1: 更新路由和摘要**

在 `SKILL.md` 加入详情预览/Preview Pane 路由；在 `README.md` 当前规范和目录结构加入摘要与文件；在 `HANDOFF.md` 加入阶段性交接。

- [ ] **Step 2: 写 GREEN 摘要**

记录 `previewPaneState` 字段、禁止项、请求门禁、权限边界、移动端策略、相邻 owner 和未验证运行时。

- [ ] **Step 3: 运行全量验证**

Run: `ruby docs/testing/preview-pane/preview-pane-audit.rb --mutations`
Run: `for audit in docs/testing/*/*-audit.rb; do case "$audit" in docs/testing/data-tables/attempt-*) continue ;; esac; ruby "$audit" || exit 1; done`
Run: `ruby -e 'files = Dir["**/*.md"].reject { |f| f.start_with?(".worktrees/") }; missing = []; files.each { |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |href| next if href =~ /\A[a-z][a-z0-9+.-]*:/i; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target) } }; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'`
Run: `git diff --check`
Run: `rg -n "fex-admin|/Users/evanqi/code/|src/pages|Ant Design|ant-design|shadcn|Next.js|Vite|React|Vue" references/preview-pane.md docs/testing/preview-pane/red-summary.md docs/testing/preview-pane/green-summary.md README.md || true`

- [ ] **Step 4: Commit and push**

Run: `git add SKILL.md README.md HANDOFF.md docs/testing/preview-pane/green-summary.md docs/superpowers/specs/2026-07-29-preview-pane-interaction-standards-design.md docs/superpowers/plans/2026-07-29-preview-pane-interaction-standards.md`
Run: `git commit -m "docs: 补齐详情预览面板规范路由"`
Run: `git push origin main`
