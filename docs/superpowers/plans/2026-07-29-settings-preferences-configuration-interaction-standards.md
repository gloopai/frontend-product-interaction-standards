# 设置、偏好与配置页交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增设置、偏好与配置页 owner，约束设置作用域、草稿/生效状态、保存/取消/重置默认、危险配置、权限收敛和移动端承载。

**Architecture:** 新建 `references/settings-preferences-configuration.md` 作为唯一 owner，在 `SKILL.md` 增加路由，并在 `README.md`、`HANDOFF.md` 增加摘要入口。新增 `docs/testing/settings-preferences-configuration/` 的红绿证据和 Ruby 突变审计，沿用现有文档 owner 的静态契约模式。

**Tech Stack:** Markdown 文档、Ruby 静态审计脚本、Git。

## Global Constraints

- 不重新定义字段校验、错误摘要和表单提交细节；继续执行 `forms.md`。
- 不重新定义 Switch、Radio、Checkbox 等控件语义；继续执行 `selection-controls.md`。
- 不重新定义按钮文案、loading 和防重复；继续执行 `buttons.md`。
- 不重新定义危险操作强确认；继续执行 `risk-actions.md`。
- 不规定具体设置项、业务默认值、后端接口或存储模型。

---

### Task 1: 写失败审计

**Files:**
- Create: `docs/testing/settings-preferences-configuration/settings-preferences-configuration-audit.rb`
- Create: `docs/testing/settings-preferences-configuration/green-summary.md`
- Create: `docs/testing/settings-preferences-configuration/red-summary.md`

**Interfaces:**
- Consumes: `references/settings-preferences-configuration.md`、`SKILL.md`、`README.md`、`HANDOFF.md`。
- Produces: `ruby docs/testing/settings-preferences-configuration/settings-preferences-configuration-audit.rb --mutations` 审计入口。

- [ ] **Step 1: 创建审计脚本**

脚本必须检查 `settingsState`、`settingsOwnerId`、`settingsScope`、`draftSettings`、`savedSettings`、`effectiveSettings`、`defaultSettings`、`applyMode`、`dirtyState`、`resetPolicy`、`permissionBoundary`、`resultReceipt`，以及核心中文硬规则。

- [ ] **Step 2: 创建红绿证据**

`green-summary.md` 和 `red-summary.md` 都必须包含：`settingsState`、`settingsScope`、`draftSettings`、`effectiveSettings`、`defaultSettings`、`applyMode`、`重置默认`、`权限`、`移动端`、`未验证`。

- [ ] **Step 3: 运行 RED**

Run: `ruby docs/testing/settings-preferences-configuration/settings-preferences-configuration-audit.rb --mutations`

Expected: FAIL，提示缺少 `references/settings-preferences-configuration.md`。

---

### Task 2: 实现 owner 与路由摘要

**Files:**
- Create: `references/settings-preferences-configuration.md`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: Task 1 的审计术语。
- Produces: 可被路由触发、可被 README/HANDOFF 发现的设置配置 owner。

- [ ] **Step 1: 创建 owner 文档**

文档包含范围、非目标、相关 owner、`settingsState` 字段表、设置作用域、生效模式、保存/取消/重置、危险配置、权限收敛、异步结果、移动端、可访问性、生命周期和完成前检查。

- [ ] **Step 2: 增加 `SKILL.md` 路由**

包含 settings、preferences、configuration、config page、setting page、preference page、feature setting、notification setting、integration setting、default setting、save settings、reset defaults、inherit defaults、设置、偏好、配置页、设置页、偏好页、配置项、策略配置、通知设置、集成设置、默认设置、保存设置、重置默认、继承默认。

- [ ] **Step 3: 更新 `README.md` 和 `HANDOFF.md`**

加入当前规范列表、摘要、完整链接、目录树和交接小节。

- [ ] **Step 4: 运行 GREEN**

Run: `ruby docs/testing/settings-preferences-configuration/settings-preferences-configuration-audit.rb --mutations`

Expected: PASS，并输出所有 EXPECTED_FAIL mutation。

---

### Task 3: 全量验证、提交和推送

**Files:**
- Verify: `docs/testing/*/*-audit.rb`
- Verify: `README.md`、`HANDOFF.md`、`SKILL.md`、`references/*.md`、`docs/**/*.md`

**Interfaces:**
- Consumes: Task 1-2 的所有文件。
- Produces: 已提交且可推送的规范增量。

- [ ] **Step 1: 运行新 owner 审计**

Run: `ruby docs/testing/settings-preferences-configuration/settings-preferences-configuration-audit.rb --mutations`

Expected: PASS。

- [ ] **Step 2: 运行全量 owner 审计**

Run:

```bash
for f in docs/testing/admin-console/admin-console-audit.rb docs/testing/adoption/adoption-audit.rb docs/testing/buttons/buttons-audit.rb docs/testing/charts-visualization/charts-visualization-audit.rb docs/testing/date-time-ranges/date-time-ranges-audit.rb docs/testing/dialog-select-responsive-popup/dialog-select-responsive-popup-audit.rb docs/testing/feedback-states/feedback-states-audit.rb docs/testing/global-feedback/global-feedback-audit.rb docs/testing/information-display/information-display-audit.rb docs/testing/navigation-routing/navigation-routing-audit.rb docs/testing/overlays-menus-tooltips/overlays-menus-tooltips-audit.rb docs/testing/query-filters/query-filters-audit.rb docs/testing/record-editing-surfaces/record-editing-surfaces-audit.rb docs/testing/risk-actions/risk-actions-audit.rb docs/testing/search-command-palette/search-command-palette-audit.rb docs/testing/selection-controls/selection-controls-audit.rb docs/testing/tree-hierarchy/tree-hierarchy-audit.rb docs/testing/uploads-imports/uploads-imports-audit.rb docs/testing/wizards-steppers/wizards-steppers-audit.rb docs/testing/async-jobs-task-center/async-jobs-task-center-audit.rb docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb docs/testing/audit-log-activity-history/audit-log-activity-history-audit.rb docs/testing/status-lifecycle-transitions/status-lifecycle-transitions-audit.rb docs/testing/exports-downloads-artifacts/exports-downloads-artifacts-audit.rb docs/testing/page-toolbars-actions/page-toolbars-actions-audit.rb docs/testing/settings-preferences-configuration/settings-preferences-configuration-audit.rb; do ruby "$f" --mutations || exit 1; done
```

Expected: exit 0。

- [ ] **Step 3: 运行链接和 diff 检查**

Run:

```bash
ruby -e 'files = Dir["README.md", "HANDOFF.md", "SKILL.md", "references/*.md", "docs/**/*.md"]; missing = []; files.each do |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each do |href| next if href =~ /\Ahttps?:/; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target); end; end; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
git diff --check
git status --short --branch
```

Expected: 链接通过、无 whitespace error。

- [ ] **Step 4: 提交并推送**

Commit:

```bash
git add SKILL.md README.md HANDOFF.md references/settings-preferences-configuration.md docs/testing/settings-preferences-configuration/settings-preferences-configuration-audit.rb docs/testing/settings-preferences-configuration/green-summary.md docs/testing/settings-preferences-configuration/red-summary.md
git commit -m "docs: 新增设置偏好配置交互规范"
git push origin main
```

## Self-Review

- Spec coverage: owner、路由、摘要、红绿证据、突变审计、全量验证均有任务覆盖。
- Placeholder scan: 文件、命令、术语和提交信息均明确。
- Type consistency: `settingsState`、`settingsOwnerId`、`settingsScope`、`draftSettings`、`savedSettings`、`effectiveSettings`、`defaultSettings`、`applyMode`、`dirtyState`、`resetPolicy`、`permissionBoundary`、`resultReceipt` 在设计、计划和测试术语中一致。
