# 页面级表单操作栏与保存区交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增页面级表单操作栏、保存栏、sticky footer、底部操作区、保存并返回、保存并继续、放弃更改、重置更改和脏状态条的独立交互 owner，并用静态审计防止意图混用、重复提交、底部遮挡、移动端键盘遮挡、权限幽灵按钮和 Toast-only 回执。

**Architecture:** 以 `references/page-form-action-bars.md` 作为唯一 owner，`SKILL.md` 负责路由触发，`README.md` 与 `HANDOFF.md` 只保留中文摘要和 owner 链接。`docs/testing/page-form-action-bars/page-form-action-bars-audit.rb` 检查 owner、路由、摘要、RED/GREEN 证据和 mutation；它不替代 Forms、Buttons、Navigation、Permissions、Feedback、Risk 或 Responsive，而是编排页面级保存区如何读取这些 owner。

**Tech Stack:** Markdown reference documentation, Ruby static audit, Git.

## Global Constraints

- 保存、提交、应用、确认、取消、返回、关闭、放弃更改、重置、保存并返回、保存并继续和保存并新建必须是不同意图。
- 页面上存在多个保存入口时，它们必须共享同一个 Form owner、同一个 `submitSnapshot`、同一个提交门禁、同一个防重复策略和同一个结果回执。
- sticky / fixed 保存栏必须为正文提供可验证的底部避让空间；最后一个字段、字段错误、帮助文本、错误摘要、上传进度、表格分页、审计回执和恢复入口不得被保存栏遮挡。
- 保存栏展示的脏状态必须来自 Forms owner 的 dirty / pristine 计算，不能从按钮禁用、字段 DOM、URL、Toast 或本地缓存推断。
- 取消、返回、关闭、浏览器 Back、Tab 切换、面包屑、菜单导航和外链必须进入 Navigation owner 的同一离开保护。
- 只读、无权限、未启用、对象锁定、审批中、归档、会话过期或能力关闭时，保存区必须原子重算；无权或未启用时保存按钮 DOM、state、handler、request 和快捷键入口为 0，或显示安全只读说明。
- 移动端不得删除保存、取消/返回、错误摘要、权限原因、脏状态说明和恢复路径；底部固定区必须处理 `safe-area-inset-bottom`、动态视口、虚拟键盘、横屏低高度、系统字体放大、200% 缩放和触摸目标。
- 运行时真实浏览器、移动端设备、屏幕阅读器、真实虚拟键盘、真实表单提交、真实权限切换、真实离开保护、真实 sticky 布局和真实焦点恢复未执行时，必须标为“未验证”。

---

## File Structure

- Create: `references/page-form-action-bars.md`  
  独立 owner，定义适用范围、`formActionBarState`、操作意图、布局避让、dirty/离开保护、权限收敛、移动端和完成前检查。
- Modify: `SKILL.md`  
  增加页面表单操作栏、保存栏、底部操作区、sticky footer、保存并返回、放弃更改、重置更改等中英文路由。
- Modify: `README.md`  
  增加中文摘要与 `references/page-form-action-bars.md` 链接。
- Modify: `HANDOFF.md`  
  增加中文交接摘要，说明 owner 边界、状态字段、红线和后续验证边界。
- Create: `docs/testing/page-form-action-bars/page-form-action-bars-audit.rb`  
  静态审计 owner、路由、摘要、RED/GREEN 证据和 mutation。
- Create: `docs/testing/page-form-action-bars/red-summary.md`  
  记录应被审计识别为失败的负向场景。
- Create: `docs/testing/page-form-action-bars/green-summary.md`  
  记录当前规范已经证明的结构性行为。

---

### Task 1: Write the failing page form action bars audit

**Files:**
- Create: `docs/testing/page-form-action-bars/page-form-action-bars-audit.rb`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-page-form-action-bars-interaction-standards-design.md`
- Produces: command `ruby docs/testing/page-form-action-bars/page-form-action-bars-audit.rb`

- [ ] **Step 1: Add the audit skeleton**

Create a Ruby audit that reads these paths and aborts if any required file is missing:

```ruby
ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/page-form-action-bars.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/page-form-action-bars/green-summary.md")
RED = File.join(ROOT, "docs/testing/page-form-action-bars/red-summary.md")
```

- [ ] **Step 2: Define required owner state fields**

The audit must require these `formActionBarState` fields:

```ruby
STATE_FIELDS = %w[
  actionBarOwnerId formBinding saveIntentPolicy cancelIntentPolicy
  buttonPolicy layoutBoundary permissionBoundary feedbackBinding
  focusReturnPolicy responsivePolicy
].freeze
```

- [ ] **Step 3: Define required owner terms**

The audit must fail unless the owner includes all of these terms:

```ruby
OWNER_TERMS = [
  "formActionBarState",
  "保存、提交、应用、确认、取消、返回、关闭、放弃更改、重置、保存并返回、保存并继续和保存并新建必须是不同意图",
  "页面上存在多个保存入口时，它们必须共享同一个 Form owner、同一个 `submitSnapshot`、同一个提交门禁、同一个防重复策略和同一个结果回执",
  "sticky / fixed 保存栏必须为正文提供可验证的底部避让空间",
  "最后一个字段、字段错误、帮助文本、错误摘要、上传进度、表格分页、审计回执和恢复入口不得被保存栏遮挡",
  "保存栏展示的脏状态必须来自 Forms owner 的 dirty / pristine 计算",
  "取消、返回、关闭、浏览器 Back、Tab 切换、面包屑、菜单导航和外链必须进入 Navigation owner 的同一离开保护",
  "放弃更改必须说明会丢弃哪些草稿，并在确认前请求数为 0",
  "重置更改必须回到明确的 initial/default/server-refill 状态",
  "无权或未启用时，保存按钮的 DOM、state、handler、request 和快捷键入口为 0",
  "权限、租户/工作区、对象状态、表单版本或会话状态变化后，旧保存入口、旧快捷键、旧 loading、旧错误、旧 Toast、旧 focus target 和旧回调必须失效或重新证明安全",
  "移动端不得删除保存、取消/返回、错误摘要、权限原因、脏状态说明和恢复路径",
  "虚拟键盘出现后，当前聚焦字段、字段错误、错误摘要、保存按钮、取消/返回、提交中状态和恢复入口仍必须可见或可滚动到达",
  "未验证"
].freeze
```

- [ ] **Step 4: Define route and summary terms**

The audit must require `SKILL.md` to route at least these terms:

```ruby
ROUTE_TERMS = [
  "页面表单操作栏", "表单操作栏", "保存栏", "保存区", "底部操作区",
  "固定底部操作", "固定保存栏", "sticky 保存栏", "sticky footer",
  "保存按钮区", "保存并返回", "保存并继续", "保存并新建",
  "取消编辑", "放弃更改", "重置更改", "脏状态条", "未保存提示条",
  "page form action bar", "form action bar", "save bar", "save area",
  "bottom action bar", "fixed footer actions", "sticky action bar",
  "sticky footer actions", "save and return", "save and continue",
  "save and create", "cancel edit", "discard changes", "reset changes",
  "dirty bar", "unsaved changes bar",
  "references/page-form-action-bars.md"
].freeze
```

The audit must require README and HANDOFF to include:

```ruby
README_TERMS = [
  "页面级表单操作栏与保存区规范",
  "references/page-form-action-bars.md"
].freeze

HANDOFF_TERMS = [
  "### 页面级表单操作栏与保存区",
  "formActionBarState",
  "保存、提交、应用、确认、取消、返回、关闭、放弃更改、重置、保存并返回、保存并继续和保存并新建必须是不同意图",
  "移动端不得删除保存、取消/返回、错误摘要、权限原因、脏状态说明和恢复路径",
  "references/page-form-action-bars.md"
].freeze
```

- [ ] **Step 5: Define RED/GREEN evidence terms**

The audit must require both evidence files to contain:

```ruby
EVIDENCE_TERMS = [
  "formActionBarState", "actionBarOwnerId", "formBinding",
  "saveIntentPolicy", "cancelIntentPolicy", "buttonPolicy",
  "layoutBoundary", "permissionBoundary", "feedbackBinding",
  "focusReturnPolicy", "responsivePolicy", "保存并返回",
  "保存并继续", "保存并新建", "放弃更改", "重置更改",
  "sticky", "fixed", "最后一个字段", "错误摘要",
  "重复请求", "dirty", "Navigation owner", "无权限",
  "DOM、state、handler、request", "虚拟键盘", "移动端", "未验证"
].freeze
```

- [ ] **Step 6: Run audit to verify RED**

Run:

```bash
ruby docs/testing/page-form-action-bars/page-form-action-bars-audit.rb
```

Expected: FAIL because `references/page-form-action-bars.md`, RED/GREEN evidence, route, README, and HANDOFF integration do not yet satisfy the new contract.

### Task 2: Implement the owner and integration

**Files:**
- Create: `references/page-form-action-bars.md`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Create: `docs/testing/page-form-action-bars/red-summary.md`
- Create: `docs/testing/page-form-action-bars/green-summary.md`

**Interfaces:**
- Consumes: failing audit from Task 1
- Produces: passing owner, route, README/HANDOFF summaries, and evidence files

- [ ] **Step 1: Add `references/page-form-action-bars.md`**

The owner must include sections for:

```markdown
# 页面级表单操作栏与保存区交互规范

## 范围与非目标
## `formActionBarState`
## 操作意图与多入口提交
## Sticky / fixed 布局避让
## 脏状态、取消、返回与离开保护
## 权限、只读与旧入口清理
## 移动端、虚拟键盘与响应式承载
## 与其他 owner 的关系
## 完成前检查
## 参考资料
```

- [ ] **Step 2: Add route in `SKILL.md`**

Insert a routing bullet near the Forms / Buttons / Navigation routes, containing the Chinese and English route terms from Task 1 and the action:

```markdown
必须完整读取 `references/page-form-action-bars.md`
```

- [ ] **Step 3: Update README summary and owner link**

Add one summary bullet explaining page form action bars and add the `页面级表单操作栏与保存区交互规范` link pointing to `references/page-form-action-bars.md` to the complete rules paragraph.

- [ ] **Step 4: Update HANDOFF summary**

Add a Chinese section `### 页面级表单操作栏与保存区` that names `formActionBarState`, operation intent separation, sticky/fixed bottom avoidance, shared submit owner, dirty/navigation linkage, permission cleanup, mobile virtual keyboard handling, and the owner link.

- [ ] **Step 5: Add RED evidence**

Create `docs/testing/page-form-action-bars/red-summary.md` with negative cases:

```markdown
# 页面级表单操作栏与保存区 RED 证据摘要

- 缺少 `formActionBarState`，或者缺少 `actionBarOwnerId`、`formBinding`、`saveIntentPolicy`、`cancelIntentPolicy`、`buttonPolicy`、`layoutBoundary`、`permissionBoundary`、`feedbackBinding`、`focusReturnPolicy`、`responsivePolicy`。
- 保存、提交、应用、确认、取消、返回、关闭、放弃更改、重置、保存并返回、保存并继续和保存并新建混用同一个意图。
- 顶部保存、底部保存、快捷键保存和移动端保存各自发送重复请求。
- sticky / fixed 保存栏遮挡最后一个字段、字段错误、帮助文本、错误摘要、上传进度、表格分页、审计回执或恢复入口。
- 保存栏从按钮 disabled、字段 DOM、URL、Toast 或本地缓存推断 dirty。
- 取消、返回、关闭、浏览器 Back、Tab 切换、面包屑、菜单导航或外链绕过 Navigation owner 的同一离开保护。
- 放弃更改没有说明会丢弃哪些草稿，或确认前请求数不是 0。
- 重置更改被实现成清空全部字段，而不是回到明确 initial/default/server-refill 状态。
- 无权限、只读或未启用时仍保留无原因的 disabled 幽灵保存按钮，且 DOM、state、handler、request 或快捷键入口不是 0。
- 保存成功只显示 Toast，没有页面内结果回执、状态更新、焦点恢复或恢复路径。
- 移动端删除保存、取消/返回、错误摘要、权限原因、脏状态说明或恢复路径。
- 虚拟键盘出现后，当前聚焦字段、字段错误、错误摘要、保存按钮、取消/返回、提交中状态或恢复入口不可见且不可滚动到达。
- 真实浏览器、移动端、屏幕阅读器、虚拟键盘、表单提交、权限切换、离开保护、sticky 布局和焦点恢复未执行时，不能写成已验证，必须标为未验证。
```

- [ ] **Step 6: Add GREEN evidence**

Create `docs/testing/page-form-action-bars/green-summary.md` with the positive evidence corresponding to every RED case and the static audit command:

```markdown
对应静态审计入口：`ruby docs/testing/page-form-action-bars/page-form-action-bars-audit.rb --mutations`。
```

### Task 3: Add mutation checks and verify GREEN

**Files:**
- Modify: `docs/testing/page-form-action-bars/page-form-action-bars-audit.rb`

**Interfaces:**
- Consumes: owner and evidence from Task 2
- Produces: mutation-sensitive audit

- [ ] **Step 1: Add `--mutations` mode**

The audit must call `expect_failure(name) { ... }` for these mutations:

```ruby
[
  "missing-owner-state",
  "merged-action-intents",
  "duplicate-save-requests",
  "sticky-footer-overlaps-content",
  "dirty-derived-from-dom",
  "navigation-protection-bypassed",
  "discard-without-impact",
  "reset-as-clear-all",
  "permission-ghost-save-button",
  "stale-save-entry-survives",
  "toast-only-save-receipt",
  "mobile-actions-removed",
  "virtual-keyboard-obscures-actions",
  "runtime-boundary-marked-verified",
  "project-specific-leakage"
]
```

- [ ] **Step 2: Verify the focused audit**

Run:

```bash
ruby docs/testing/page-form-action-bars/page-form-action-bars-audit.rb --mutations
```

Expected: each mutation prints `EXPECTED_FAIL` and the command exits 0 with a final PASS.

- [ ] **Step 3: Verify adjacent owner audits**

Run:

```bash
ruby docs/testing/forms/forms-audit.rb --mutations
ruby docs/testing/buttons/buttons-audit.rb --mutations
ruby docs/testing/navigation-routing/navigation-routing-audit.rb --mutations
ruby docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb --mutations
ruby docs/testing/global-feedback/global-feedback-audit.rb --mutations
ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations
```

Expected: all pass, because page form action bars depend on their owner boundaries without weakening them.

- [ ] **Step 4: Verify formal owner audit collection**

Run the current known-good collection, excluding historical `docs/testing/data-tables/attempt-*` audits:

```bash
for audit in docs/testing/*/*-audit.rb; do
  case "$audit" in
    docs/testing/data-tables/attempt-*) continue ;;
  esac
  ruby "$audit" || exit 1
done
```

Expected: every included audit exits 0.

- [ ] **Step 5: Verify Markdown links and whitespace**

Run:

```bash
ruby -e 'files = Dir["**/*.md"].reject { |f| f.start_with?(".worktrees/") }; missing = []; files.each { |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |href| next if href =~ /\A[a-z][a-z0-9+.-]*:/i; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target) } }; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
git diff --check
```

Expected: link check prints `PASS: markdown links resolve`; `git diff --check` produces no output.

### Task 4: Commit and push

**Files:**
- Stage all files modified or created in Tasks 1-3.

**Interfaces:**
- Consumes: passing verification from Task 3
- Produces: pushed commit on `main`

- [ ] **Step 1: Review status**

Run:

```bash
git status --short --branch
```

Expected: only the page form action bars plan, owner, audit, evidence, route, README, and HANDOFF changes are present.

- [ ] **Step 2: Commit**

Run:

```bash
git add docs/superpowers/plans/2026-07-29-page-form-action-bars-interaction-standards.md references/page-form-action-bars.md SKILL.md README.md HANDOFF.md docs/testing/page-form-action-bars
git commit -m "docs: 新增页面表单操作栏规范"
```

Expected: commit succeeds.

- [ ] **Step 3: Push**

Run:

```bash
git push origin main
```

Expected: `main` pushes to origin successfully.
