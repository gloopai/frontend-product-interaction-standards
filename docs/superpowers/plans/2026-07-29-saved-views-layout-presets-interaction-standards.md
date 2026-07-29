# 保存视图与布局预设交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增保存视图、视图预设、个人/共享/默认视图、保存筛选和布局预设的独立交互 owner，并用静态审计防止草稿误保存、权限泄露、默认范围混淆、未知结果伪成功和移动端能力丢失。

**Architecture:** 以 `references/saved-views-layout-presets.md` 作为唯一 owner，`SKILL.md` 负责路由触发，`README.md` 与 `HANDOFF.md` 只保留中文摘要和 owner 链接。`docs/testing/saved-views-layout-presets/saved-views-layout-presets-audit.rb` 检查 owner、路由、摘要、RED/GREEN 证据和 mutation，避免把保存视图散落到 Data Table、Query Filters、Toolbar 或 Settings 里。

**Tech Stack:** Markdown reference documentation, Ruby static audit, Git.

## Global Constraints

- 保存视图只能保存已应用快照和明确允许持久化的布局快照，不能保存筛选草稿、Select query、active option、未提交日期范围、临时列拖拽、当前页码、展开行、hover、高亮、焦点、loading、错误状态或旧结果缓存。
- 应用视图必须冻结 `applyIntent`，并让 Query Filters、Data Table、Toolbar、URL、结果摘要和焦点读取同一视图版本。
- 个人视图、共享视图、团队视图、系统预设、个人默认、团队默认和角色默认必须分开表达。
- 共享视图不得泄露无权限字段、筛选值、对象名称、数量、列名、内部 ID、成员、客户、文件名、金额、发票、密钥、审计字段或旧缓存。
- 覆盖视图、删除视图、设为默认、共享给团队、取消共享、恢复默认和批量管理视图必须说明影响范围、版本、权限、请求身份和未知结果；高影响动作进入 `risk-actions.md`。
- 移动端不得删除视图切换、当前视图说明、保存视图、覆盖视图、恢复默认、权限原因、冲突恢复、错误回执或审计入口。
- 运行时浏览器、真实移动端、屏幕阅读器、真实权限/租户切换、真实 URL 恢复、真实多人共享、真实默认冲突、真实审计写入和真实表格/筛选联动未执行时，必须标为“未验证”。

---

## File Structure

- Create: `references/saved-views-layout-presets.md`  
  独立 owner，定义适用范围、`savedViewState`、保存/应用/共享/默认/恢复/删除规则、权限与风险、移动端和验收边界。
- Modify: `SKILL.md`  
  增加保存视图、视图预设、个人/共享/默认视图、保存筛选、列布局、布局预设、密度预设等中英文路由。
- Modify: `README.md`  
  增加中文摘要与 `references/saved-views-layout-presets.md` 链接。
- Modify: `HANDOFF.md`  
  增加中文交接摘要，说明当前 owner 边界、风险和后续验证边界。
- Create: `docs/testing/saved-views-layout-presets/saved-views-layout-presets-audit.rb`  
  静态审计 owner、路由、摘要、RED/GREEN 证据和 mutation。
- Create: `docs/testing/saved-views-layout-presets/red-summary.md`  
  记录应被审计识别为失败的负向场景。
- Create: `docs/testing/saved-views-layout-presets/green-summary.md`  
  记录当前规范已经证明的结构性行为。

---

### Task 1: Write the failing saved views audit

**Files:**
- Create: `docs/testing/saved-views-layout-presets/saved-views-layout-presets-audit.rb`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-saved-views-layout-presets-interaction-standards-design.md`
- Produces: command `ruby docs/testing/saved-views-layout-presets/saved-views-layout-presets-audit.rb`

- [ ] **Step 1: Add the audit skeleton**

Create a Ruby audit that reads these paths and aborts if any required file is missing:

```ruby
ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/saved-views-layout-presets.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/saved-views-layout-presets/green-summary.md")
RED = File.join(ROOT, "docs/testing/saved-views-layout-presets/red-summary.md")
```

- [ ] **Step 2: Define required owner state fields**

The audit must require these `savedViewState` fields:

```ruby
STATE_FIELDS = %w[
  savedViewOwnerId viewIdentity viewScope appliedSnapshot layoutSnapshot
  draftBinding defaultPolicy sharePolicy applyIntent permissionBoundary
  resultReceipt auditBinding responsivePolicy
].freeze
```

- [ ] **Step 3: Define required owner terms**

The audit must fail unless the owner includes all of these terms:

```ruby
OWNER_TERMS = [
  "savedViewState",
  "保存视图必须读取 `appliedSnapshot` 和明确允许持久化的 `layoutSnapshot`",
  "筛选草稿、Select query、active option、未提交日期范围、正在编辑的列拖拽、当前临时页码、展开行、hover、高亮、焦点、loading、错误状态和旧结果缓存不得进入正式保存视图",
  "保存视图前必须明确“保存已应用条件”或要求用户先应用/确认草稿",
  "应用视图必须创建 `applyIntent`",
  "Query Filters、Data Table、Toolbar、URL、结果摘要和焦点必须读取同一视图版本",
  "个人视图、团队共享视图、系统预设、个人默认、团队默认和角色默认必须分开表达",
  "共享视图不得泄露无权限字段、筛选值、对象名称、数量、列名、内部 ID、成员、客户、文件名、金额、发票、密钥、审计字段或旧缓存",
  "权限、租户/工作区、角色、字段可见性、功能开关或数据范围变化后，旧视图必须失效、过滤、降级或要求重新确认",
  "覆盖视图、删除视图、设为默认、共享给团队、取消共享、恢复默认和批量管理视图必须说明影响范围、视图版本、目标范围、权限版本、请求身份和未知结果",
  "确认前请求数为 0",
  "未知结果不能伪装成已保存、已覆盖、已删除、已共享、已设为默认或已恢复默认",
  "移动端不得删除视图切换、当前视图说明、保存视图、覆盖视图、恢复默认、权限原因、冲突恢复、错误回执和审计入口",
  "未验证"
].freeze
```

- [ ] **Step 4: Define required route and summary terms**

The audit must require `SKILL.md` to route at least these terms:

```ruby
ROUTE_TERMS = [
  "保存视图", "视图预设", "我的视图", "个人视图", "共享视图", "团队视图",
  "默认视图", "系统视图", "保存筛选", "筛选预设", "列布局", "布局预设",
  "密度预设", "恢复默认视图", "设为默认视图", "视图切换器",
  "saved view", "view preset", "personal view", "shared view",
  "default view", "saved filter", "column layout", "layout preset",
  "density preset", "restore default view", "set default view",
  "references/saved-views-layout-presets.md"
].freeze
```

The audit must require README and HANDOFF to include:

```ruby
README_TERMS = [
  "保存视图、视图预设与个性化布局规范",
  "references/saved-views-layout-presets.md"
].freeze

HANDOFF_TERMS = [
  "### 保存视图、视图预设与个性化布局",
  "savedViewState",
  "保存视图必须读取 `appliedSnapshot`",
  "未知结果不能伪装成已保存",
  "references/saved-views-layout-presets.md"
].freeze
```

- [ ] **Step 5: Define RED/GREEN evidence terms**

The audit must require both evidence files to contain:

```ruby
EVIDENCE_TERMS = [
  "savedViewState", "appliedSnapshot", "layoutSnapshot", "draftBinding",
  "defaultPolicy", "sharePolicy", "applyIntent", "permissionBoundary",
  "resultReceipt", "auditBinding", "筛选草稿", "Select query", "当前页码",
  "共享视图", "默认视图", "无权限字段", "旧视图", "未知结果",
  "恢复默认", "移动端", "未验证"
].freeze
```

- [ ] **Step 6: Run audit to verify RED**

Run:

```bash
ruby docs/testing/saved-views-layout-presets/saved-views-layout-presets-audit.rb
```

Expected: FAIL because `references/saved-views-layout-presets.md`, RED/GREEN evidence, route, README, and HANDOFF integration do not yet satisfy the new contract.

### Task 2: Implement the owner and integration

**Files:**
- Create: `references/saved-views-layout-presets.md`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Create: `docs/testing/saved-views-layout-presets/red-summary.md`
- Create: `docs/testing/saved-views-layout-presets/green-summary.md`

**Interfaces:**
- Consumes: failing audit from Task 1
- Produces: passing owner, route, README/HANDOFF summaries, and evidence files

- [ ] **Step 1: Add `references/saved-views-layout-presets.md`**

The owner must include sections for:

```markdown
# 保存视图、视图预设与个性化布局交互规范

## 范围与非目标
## `savedViewState`
## 保存快照与草稿边界
## 应用视图与结果联动
## 个人、共享、团队与默认视图
## 覆盖、删除、共享与恢复默认
## 权限、租户、字段可见性与旧视图失效
## 移动端与响应式承载
## 与其他 owner 的关系
## 完成前检查
## 参考资料
```

- [ ] **Step 2: Add route in `SKILL.md`**

Insert a routing bullet after the page toolbar route or before settings route, containing the Chinese and English route terms from Task 1 and the action:

```markdown
必须完整读取 `references/saved-views-layout-presets.md`
```

- [ ] **Step 3: Update README summary and owner link**

Add one summary bullet explaining saved views and add the `保存视图、视图预设与个性化布局交互规范` link pointing to `references/saved-views-layout-presets.md` to the complete rules paragraph.

- [ ] **Step 4: Update HANDOFF summary**

Add a Chinese section `### 保存视图、视图预设与个性化布局` that names `savedViewState`, applied snapshot boundaries, shared/default separation, unknown result handling, mobile capability preservation, and the owner link.

- [ ] **Step 5: Add RED evidence**

Create `docs/testing/saved-views-layout-presets/red-summary.md` with negative cases:

```markdown
# 保存视图、视图预设与个性化布局 RED 证据摘要

- 保存了筛选草稿、Select query、active option 或未提交日期范围。
- 保存了当前页码、展开行、hover、高亮、焦点、loading、错误状态或旧结果缓存。
- 应用视图没有 `applyIntent`，Query Filters、Data Table、Toolbar、URL、结果摘要和焦点读取了不同视图版本。
- 个人视图、共享视图、团队默认、个人默认和系统预设混在同一个状态里。
- 共享视图泄露无权限字段、筛选值、对象名称、数量、列名、内部 ID、成员、客户、文件名、金额、发票、密钥、审计字段或旧缓存。
- 权限、租户/工作区、角色、字段可见性、功能开关或数据范围变化后，旧视图仍可应用。
- 覆盖、删除、共享、设默认或恢复默认没有影响范围、权限版本、请求身份和未知结果恢复。
- 未知结果被写成已保存、已覆盖、已删除、已共享、已设为默认或已恢复默认。
- 移动端删除视图切换、当前视图说明、保存视图、覆盖视图、恢复默认、权限原因、冲突恢复、错误回执或审计入口。
- 真实浏览器、移动端、屏幕阅读器、权限/租户切换、URL 恢复、多人共享、默认冲突、审计写入和表格/筛选联动未执行时，不能写成已验证，必须标为未验证。
```

- [ ] **Step 6: Add GREEN evidence**

Create `docs/testing/saved-views-layout-presets/green-summary.md` with the positive evidence corresponding to every RED case and the static audit command:

```markdown
对应静态审计入口：`ruby docs/testing/saved-views-layout-presets/saved-views-layout-presets-audit.rb --mutations`。
```

### Task 3: Add mutation checks and verify GREEN

**Files:**
- Modify: `docs/testing/saved-views-layout-presets/saved-views-layout-presets-audit.rb`

**Interfaces:**
- Consumes: owner and evidence from Task 2
- Produces: mutation-sensitive audit

- [ ] **Step 1: Add `--mutations` mode**

The audit must call `expect_failure(name) { ... }` for these mutations:

```ruby
[
  "missing-owner-state",
  "draft-saved-as-view",
  "save-without-applied-snapshot-boundary",
  "missing-apply-intent",
  "different-view-version-readers",
  "shared-default-scope-merged",
  "shared-view-permission-leak",
  "stale-view-after-permission-change",
  "risk-actions-without-impact-scope",
  "request-before-confirm",
  "unknown-result-as-success",
  "mobile-view-capability-removed",
  "runtime-boundary-marked-verified",
  "project-specific-leakage"
]
```

- [ ] **Step 2: Verify the focused audit**

Run:

```bash
ruby docs/testing/saved-views-layout-presets/saved-views-layout-presets-audit.rb --mutations
```

Expected: each mutation prints `EXPECTED_FAIL` and the command exits 0 with a final PASS.

- [ ] **Step 3: Verify adjacent owner audits**

Run:

```bash
ruby docs/testing/query-filters/query-filters-audit.rb --mutations
ruby docs/testing/page-toolbars-actions/page-toolbars-actions-audit.rb --mutations
ruby docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb --mutations
ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations
```

Expected: all pass, because saved views depends on their owner boundaries without weakening them.

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

Expected: only the saved views plan, owner, audit, evidence, route, README, and HANDOFF changes are present.

- [ ] **Step 2: Commit**

Run:

```bash
git add docs/superpowers/plans/2026-07-29-saved-views-layout-presets-interaction-standards.md references/saved-views-layout-presets.md SKILL.md README.md HANDOFF.md docs/testing/saved-views-layout-presets
git commit -m "docs: 新增保存视图布局预设规范"
```

Expected: commit succeeds.

- [ ] **Step 3: Push**

Run:

```bash
git push origin main
```

Expected: `main` pushes to origin successfully.
