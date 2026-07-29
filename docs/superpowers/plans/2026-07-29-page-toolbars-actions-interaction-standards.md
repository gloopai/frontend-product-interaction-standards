# 页面操作栏与列表工具栏交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增页面操作栏与列表工具栏 owner，约束管理台页面标题操作区、列表/结果工具栏、批量条、视图工具、移动端收纳和权限收敛。

**Architecture:** 新建一个职责单一的 `references/page-toolbars-actions.md`，通过 `SKILL.md` 路由触发，并在 `README.md` 与 `HANDOFF.md` 做摘要入口。新增 `docs/testing/page-toolbars-actions/` 下的红绿证据和 Ruby 静态突变审计，沿用现有 owner 的验证模式。

**Tech Stack:** Markdown 文档、Ruby 静态审计脚本、Git。

## Global Constraints

- 不重新定义单个按钮文案、loading、危险分级；这些继续归 `buttons.md` 和 `risk-actions.md`。
- 不重新定义表格能力档位、选择快照或批量终态；这些继续归 `data-tables.md`。
- 不重新定义筛选草稿/已应用、URL 恢复或字段校验；这些继续归 `query-filters.md` 与 `forms.md`。
- 不规定具体 CSS 框架、组件库、图标库或像素级样式。
- 移动端不得删除新增、刷新、错误恢复、已选摘要、批量入口、导出恢复或主要视图工具。

---

### Task 1: 写失败审计

**Files:**
- Create: `docs/testing/page-toolbars-actions/page-toolbars-actions-audit.rb`
- Create: `docs/testing/page-toolbars-actions/green-summary.md`
- Create: `docs/testing/page-toolbars-actions/red-summary.md`

**Interfaces:**
- Consumes: `references/page-toolbars-actions.md`、`SKILL.md`、`README.md`、`HANDOFF.md`。
- Produces: `ruby docs/testing/page-toolbars-actions/page-toolbars-actions-audit.rb --mutations` 审计入口。

- [ ] **Step 1: 创建审计脚本，先要求尚不存在的 owner 与摘要术语**

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/page-toolbars-actions.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/page-toolbars-actions/green-summary.md")
RED = File.join(ROOT, "docs/testing/page-toolbars-actions/red-summary.md")

OWNER_TERMS = [
  "toolbarState",
  "toolbarOwnerId",
  "primaryActionPolicy",
  "secondaryActionPolicy",
  "resultBinding",
  "selectionBinding",
  "viewToolsPolicy",
  "permissionBoundary",
  "responsivePolicy",
  "页面主操作只能有一个 primary owner",
  "不得被埋进无标签更多菜单作为唯一入口",
  "工具栏不得读取筛选草稿、旧结果、旧权限或 Select query",
  "批量操作栏只有在 Data Table 的 `resolvedTier=bulk-action` 且存在有效选择时才出现",
  "只读报表、row-action 列表、无选择状态或选择失效时不得渲染空批量条",
  "更多菜单、Tooltip、Toast 或浏览器提示不得作为唯一错误恢复、权限原因、主操作入口或导出回执",
  "权限、租户/工作区、能力开关或结果 owner 变化后，工具栏必须原子重算可见操作、禁用原因、批量条、导出入口和视图工具",
  "移动端不得删除新增、刷新、错误恢复、已选摘要、批量入口、导出恢复或主要视图工具",
  "未验证"
].freeze
```

- [ ] **Step 2: 写 `require_terms`、`audit`、`expect_failure` 和突变用例**

脚本必须检查 owner、route、README、HANDOFF、GREEN、RED，并包含以下 mutation 名称：

```ruby
"missing-owner-state"
"primary-action-hidden-in-more"
"toolbar-reads-draft-or-stale-state"
"empty-bulk-toolbar"
"menu-tooltip-toast-only"
"permission-recompute-removed"
"mobile-core-actions-removed"
"runtime-boundary-marked-verified"
"missing-route"
"project-leak"
```

- [ ] **Step 3: 创建最小红绿证据文件**

`green-summary.md` 写明合格证据；`red-summary.md` 写明必须失败场景。两者都包含：`toolbarState`、`primary owner`、`更多菜单`、`筛选草稿`、`空批量条`、`权限`、`移动端`、`未验证`。

- [ ] **Step 4: 运行 RED**

Run: `ruby docs/testing/page-toolbars-actions/page-toolbars-actions-audit.rb --mutations`

Expected: FAIL，至少报告缺少 `references/page-toolbars-actions.md` 或 owner 术语。

---

### Task 2: 实现 owner 与路由

**Files:**
- Create: `references/page-toolbars-actions.md`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: Task 1 的审计术语。
- Produces: 可被路由触发、可被 README/HANDOFF 发现的页面操作栏 owner。

- [ ] **Step 1: 创建 owner 文档**

文档包含：

- 范围与非目标；
- 与 `buttons.md`、`data-tables.md`、`query-filters.md`、`exports-downloads-artifacts.md`、`permissions-tenancy-visibility.md`、`responsive-adaptive.md` 的关系；
- `toolbarState` 字段表；
- 主操作、次要操作、结果绑定、批量条、视图工具、更多菜单、权限收敛、移动端收纳、可访问性、生命周期、完成前检查。

- [ ] **Step 2: 在 `SKILL.md` 增加路由**

路由包含中英文关键词：`page toolbar`、`action bar`、`list toolbar`、`result toolbar`、`bulk toolbar`、`view tools`、`refresh action`、`create action`、`column settings`、`density`、`view switcher`、`页面操作栏`、`列表工具栏`、`结果工具栏`、`批量操作栏`、`视图工具`、`刷新操作`、`新增操作`、`列设置`、`密度`、`视图切换`。

- [ ] **Step 3: 更新 `README.md` 摘要与链接**

把“页面操作栏与列表工具栏”加入当前规范列表、规则摘要、完整链接和目录树。

- [ ] **Step 4: 更新 `HANDOFF.md` 摘要**

新增交接小节，说明该 owner 是操作编排层，不替代按钮、表格、筛选或导出 owner。

- [ ] **Step 5: 运行 GREEN**

Run: `ruby docs/testing/page-toolbars-actions/page-toolbars-actions-audit.rb --mutations`

Expected: PASS，并输出所有 EXPECTED_FAIL mutation。

---

### Task 3: 全量验证与提交

**Files:**
- Verify: `docs/testing/*/*-audit.rb`
- Verify: `README.md`、`HANDOFF.md`、`SKILL.md`、`references/*.md`、`docs/**/*.md`

**Interfaces:**
- Consumes: Task 1-2 的所有文件。
- Produces: 已提交且可推送的规范增量。

- [ ] **Step 1: 运行页面操作栏审计**

Run: `ruby docs/testing/page-toolbars-actions/page-toolbars-actions-audit.rb --mutations`

Expected: PASS。

- [ ] **Step 2: 运行全量 owner 审计**

Run:

```bash
for f in docs/testing/admin-console/admin-console-audit.rb docs/testing/adoption/adoption-audit.rb docs/testing/buttons/buttons-audit.rb docs/testing/charts-visualization/charts-visualization-audit.rb docs/testing/date-time-ranges/date-time-ranges-audit.rb docs/testing/dialog-select-responsive-popup/dialog-select-responsive-popup-audit.rb docs/testing/feedback-states/feedback-states-audit.rb docs/testing/global-feedback/global-feedback-audit.rb docs/testing/information-display/information-display-audit.rb docs/testing/navigation-routing/navigation-routing-audit.rb docs/testing/overlays-menus-tooltips/overlays-menus-tooltips-audit.rb docs/testing/query-filters/query-filters-audit.rb docs/testing/record-editing-surfaces/record-editing-surfaces-audit.rb docs/testing/risk-actions/risk-actions-audit.rb docs/testing/search-command-palette/search-command-palette-audit.rb docs/testing/selection-controls/selection-controls-audit.rb docs/testing/tree-hierarchy/tree-hierarchy-audit.rb docs/testing/uploads-imports/uploads-imports-audit.rb docs/testing/wizards-steppers/wizards-steppers-audit.rb docs/testing/async-jobs-task-center/async-jobs-task-center-audit.rb docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb docs/testing/audit-log-activity-history/audit-log-activity-history-audit.rb docs/testing/status-lifecycle-transitions/status-lifecycle-transitions-audit.rb docs/testing/exports-downloads-artifacts/exports-downloads-artifacts-audit.rb docs/testing/page-toolbars-actions/page-toolbars-actions-audit.rb; do ruby "$f" --mutations || exit 1; done
```

Expected: exit 0。

- [ ] **Step 3: 运行 Markdown 链接检查**

Run:

```bash
ruby -e 'files = Dir["README.md", "HANDOFF.md", "SKILL.md", "references/*.md", "docs/**/*.md"]; missing = []; files.each do |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each do |href| next if href =~ /\Ahttps?:/; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target); end; end; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
```

Expected: `PASS: markdown links resolve`。

- [ ] **Step 4: 运行 diff 检查并提交**

Run: `git diff --check && git status --short --branch`

Expected: 无 whitespace error，仅本任务文件变更。

Commit:

```bash
git add SKILL.md README.md HANDOFF.md references/page-toolbars-actions.md docs/testing/page-toolbars-actions/page-toolbars-actions-audit.rb docs/testing/page-toolbars-actions/green-summary.md docs/testing/page-toolbars-actions/red-summary.md
git commit -m "docs: 新增页面操作栏交互规范"
```

## Self-Review

- Spec coverage: owner、路由、摘要、红绿证据、突变审计、全量验证均有任务覆盖。
- Placeholder scan: 本计划不使用占位符，所有文件、命令和 mutation 名称明确。
- Type consistency: `toolbarState`、`toolbarOwnerId`、`primaryActionPolicy`、`secondaryActionPolicy`、`resultBinding`、`selectionBinding`、`viewToolsPolicy`、`permissionBoundary`、`responsivePolicy` 在设计、计划和测试术语中一致。
