# 图表与可视化创作配置交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增图表创建、编辑、可视化配置、报表图表配置、仪表盘图表配置、图表构建器和图表配置向导的独立交互 owner，并用静态审计防止预览即保存、保存即发布、图形类型切换静默丢配置、保存读取草稿/旧缓存、只校验可见面板、旧权限泄漏和移动端能力删减。

**Architecture:** 以 `references/chart-visualization-builders.md` 作为图表配置器专属 owner，`SKILL.md` 负责触发路由，`README.md` 与 `HANDOFF.md` 只保留中文摘要和 owner 路径。`docs/testing/chart-visualization-builders/chart-visualization-builders-audit.rb` 检查 owner、路由、摘要、RED/GREEN 证据和 mutation；它不替代 `charts-visualization.md` 的图表展示，也不替代 `complex-editors-builders.md` 的通用编辑器生命周期，而是定义图表配置器自己的草稿、预览、校验、保存、发布、权限和响应式边界。

**Tech Stack:** Markdown reference documentation, Ruby static audit, Git.

## Global Constraints

- 每个图表配置器必须声明 `chartBuilderState`，并包含 `chartBuilderOwnerId`、`sourceConfigSnapshot`、`dataSourceBinding`、`metricDraft`、`dimensionDraft`、`encodingDraft`、`interactionDraft`、`filterBindingDraft`、`previewState`、`validationState`、`savePolicy`、`publishPolicy`、`permissionBoundary` 和 `responsivePolicy`。
- 指标选择、维度选择、聚合方式、图形类型、编码、筛选绑定、钻取、导出和明细能力的编辑只能写入对应草稿字段。
- 预览成功不等于保存成功；保存成功不等于发布成功；发布请求发送不等于仪表盘或外部嵌入已生效；加入仪表盘请求发送不等于仪表盘已更新。
- 每种图形类型必须声明可接受的指标数量、维度数量、字段类型、时间轴要求、是否允许多 series、是否允许堆叠、是否允许百分比、是否允许双轴和是否需要分母。
- 切换图形类型时，不能静默删除不兼容配置；必须展示迁移摘要、待修复项、保留项、丢弃项和撤销/取消路径。
- 不能让“预览能画出来”替代配置合法性。
- 保存时不得读取 Select query、active option、筛选草稿、hover 字段、预览高亮、当前可见结果或旧缓存。
- 配置器必须校验完整配置，而不是只校验当前可见面板。
- 预览图表本身必须执行 `charts-visualization.md` 的展示规则。
- 权限、租户/工作区、数据源版本、字段版本、指标口径、来源配置版本、发布版本、仪表盘版本或会话状态变化后，旧字段列表、旧预览、旧保存按钮、旧发布按钮、旧导出配置、旧钻取目标、旧颜色映射、旧复制内容、旧焦点目标和旧 ARIA 引用必须失效或重新证明安全。
- 无权或未启用时，数据源选择、字段选择、指标选择、预览、保存、发布、复制、导出、钻取配置、加入仪表盘和查看明细配置的 DOM、state、handler、request 和快捷键入口为 0。
- 移动端不得删除数据源说明、指标配置、维度配置、图形类型、预览、完整校验、错误定位、保存草稿、发布/加入仪表盘、权限原因、版本冲突、恢复路径和离开保护。
- 真实浏览器、真实图表库、真实数据源、真实预览、真实权限切换、键盘、触摸、读屏和移动端视口未执行时，必须标为“未验证”。

---

## File Structure

- Create: `references/chart-visualization-builders.md`  
  图表配置器专属 owner，定义范围、`chartBuilderState`、草稿/预览/保存/发布分层、图形类型兼容、数据源/指标/维度边界、预览可信边界、完整校验、权限清理、移动端承载、与其他 owner 的关系和完成前检查。
- Modify: `references/charts-visualization.md`  
  增加与图表配置器 owner 的关系说明，声明图表展示继续由本文件负责，配置创作读取新 owner。
- Modify: `references/complex-editors-builders.md`  
  增加与图表配置器 owner 的关系说明，声明通用复杂编辑器规则继续兼容执行，图表配置专属规则读取新 owner。
- Modify: `SKILL.md`  
  增加图表创建、编辑、配置、图表构建器、指标配置、维度配置、聚合配置、图形类型切换、图表预览、保存/发布图表等中英文路由。
- Modify: `README.md`  
  增加中文摘要与 `references/chart-visualization-builders.md` 路径，目录结构中列出新 owner。
- Modify: `HANDOFF.md`  
  增加中文交接摘要，说明 owner 边界、状态字段、预览/保存/发布分层、图形类型兼容、完整校验、权限清理、移动端和未验证边界。
- Create: `docs/testing/chart-visualization-builders/chart-visualization-builders-audit.rb`  
  静态审计 owner、路由、摘要、RED/GREEN 证据和 mutation。
- Create: `docs/testing/chart-visualization-builders/red-summary.md`  
  记录应被审计识别为失败的负向场景。
- Create: `docs/testing/chart-visualization-builders/green-summary.md`  
  记录当前规范已经证明的结构性行为。

---

### Task 1: Write the failing chart builder audit

**Files:**
- Create: `docs/testing/chart-visualization-builders/chart-visualization-builders-audit.rb`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-chart-visualization-builders-interaction-standards-design.md`
- Produces: command `ruby docs/testing/chart-visualization-builders/chart-visualization-builders-audit.rb`

- [ ] **Step 1: Add the audit skeleton**

Create the Ruby audit with these paths:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/chart-visualization-builders.md")
CHARTS = File.join(ROOT, "references/charts-visualization.md")
EDITORS = File.join(ROOT, "references/complex-editors-builders.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/chart-visualization-builders/green-summary.md")
RED = File.join(ROOT, "docs/testing/chart-visualization-builders/red-summary.md")
```

- [ ] **Step 2: Define required state fields**

The audit must require these `chartBuilderState` fields:

```ruby
STATE_FIELDS = %w[
  chartBuilderOwnerId sourceConfigSnapshot dataSourceBinding metricDraft
  dimensionDraft encodingDraft interactionDraft filterBindingDraft
  previewState validationState savePolicy publishPolicy permissionBoundary
  responsivePolicy
].freeze
```

- [ ] **Step 3: Define required owner terms**

The audit must fail unless the owner includes all of these exact terms:

```ruby
OWNER_TERMS = [
  "chartBuilderState",
  "指标选择、维度选择、聚合方式、图形类型、编码、筛选绑定、钻取、导出和明细能力的编辑只能写入对应草稿字段",
  "预览成功不等于保存成功",
  "保存成功不等于发布成功",
  "发布请求发送不等于仪表盘或外部嵌入已生效",
  "加入仪表盘请求发送不等于仪表盘已更新",
  "每种图形类型必须声明可接受的指标数量、维度数量、字段类型、时间轴要求、是否允许多 series、是否允许堆叠、是否允许百分比、是否允许双轴和是否需要分母",
  "切换图形类型时，不能静默删除不兼容配置",
  "必须展示迁移摘要、待修复项、保留项、丢弃项和撤销/取消路径",
  "不能让“预览能画出来”替代配置合法性",
  "数据源字段列表必须绑定数据集版本、权限范围、字段类型和刷新时间",
  "保存时不得读取 Select query、active option、筛选草稿、hover 字段、预览高亮、当前可见结果或旧缓存",
  "预览必须声明读取的是当前草稿、已保存配置还是已发布配置",
  "预览图表本身必须执行 `charts-visualization.md` 的展示规则",
  "配置器必须校验完整配置，而不是只校验当前可见面板",
  "折叠面板、隐藏字段、高级配置、钻取目标、导出范围、tooltip 字段、颜色映射、双轴、Top N、权限不可见字段、旧数据源字段和旧图表类型残留都必须进入 `validationState`",
  "权限、租户/工作区、数据源版本、字段版本、指标口径、来源配置版本、发布版本、仪表盘版本或会话状态变化后，旧字段列表、旧预览、旧保存按钮、旧发布按钮、旧导出配置、旧钻取目标、旧颜色映射、旧复制内容、旧焦点目标和旧 ARIA 引用必须失效或重新证明安全",
  "无权或未启用时，数据源选择、字段选择、指标选择、预览、保存、发布、复制、导出、钻取配置、加入仪表盘和查看明细配置的 DOM、state、handler、request 和快捷键入口为 0",
  "移动端不得删除数据源说明、指标配置、维度配置、图形类型、预览、完整校验、错误定位、保存草稿、发布/加入仪表盘、权限原因、版本冲突、恢复路径和离开保护",
  "未验证"
].freeze
```

- [ ] **Step 4: Define route, relationship and summary terms**

The audit must require `SKILL.md` to route at least these terms:

```ruby
ROUTE_TERMS = [
  "图表创建", "创建图表", "新建图表", "编辑图表", "图表配置",
  "可视化配置", "图表构建器", "可视化构建器", "报表图表配置",
  "仪表盘图表配置", "图表配置向导", "指标配置", "维度配置",
  "聚合配置", "图形类型切换", "图表预览", "保存图表", "发布图表",
  "加入仪表盘", "复制图表配置", "导出图表配置", "图表字段映射",
  "图表钻取配置", "图表联动配置", "chart builder", "visualization builder",
  "chart creation", "create chart", "edit chart", "chart config",
  "chart configuration", "visualization config", "report chart config",
  "dashboard chart config", "chart setup", "chart wizard", "metric config",
  "dimension config", "aggregation config", "chart type switch",
  "chart preview", "save chart", "publish chart", "add to dashboard",
  "copy chart config", "export chart config", "chart field mapping",
  "chart drilldown config", "chart interaction config",
  "references/chart-visualization-builders.md"
].freeze
```

The audit must require the adjacent owners to mention the new owner path:

```ruby
RELATIONSHIP_TERMS = [
  "references/chart-visualization-builders.md",
  "chart-visualization-builders.md"
].freeze
```

The audit must require README and HANDOFF to include:

```ruby
README_TERMS = [
  "图表与可视化创作配置规范",
  "references/chart-visualization-builders.md"
].freeze

HANDOFF_TERMS = [
  "### 图表与可视化创作配置",
  "chartBuilderState",
  "预览成功不等于保存成功",
  "切换图形类型时，不能静默删除不兼容配置",
  "移动端不得删除数据源说明、指标配置、维度配置、图形类型、预览、完整校验、错误定位、保存草稿、发布/加入仪表盘、权限原因、版本冲突、恢复路径和离开保护",
  "references/chart-visualization-builders.md"
].freeze
```

- [ ] **Step 5: Define evidence and leakage terms**

The audit must require both evidence files to contain:

```ruby
EVIDENCE_TERMS = [
  "chartBuilderState", "chartBuilderOwnerId", "sourceConfigSnapshot",
  "dataSourceBinding", "metricDraft", "dimensionDraft", "encodingDraft",
  "interactionDraft", "filterBindingDraft", "previewState",
  "validationState", "savePolicy", "publishPolicy", "permissionBoundary",
  "responsivePolicy", "预览成功", "保存成功", "发布请求发送",
  "加入仪表盘", "图形类型", "静默删除", "迁移摘要", "预览能画出来",
  "Select query", "active option", "筛选草稿", "完整配置",
  "当前可见面板", "charts-visualization.md", "旧字段列表",
  "旧预览", "旧保存按钮", "旧发布按钮", "DOM、state、handler、request 和快捷键入口为 0",
  "移动端", "未验证"
].freeze

PROJECT_BANNED_TERMS = [
  "fex-admin",
  "/Users/evanqi/code/",
  "src/pages",
  "Ant Design",
  "ant-design",
  "shadcn",
  "Next.js",
  "Vite",
  "ECharts",
  "Recharts",
  "Highcharts"
].freeze
```

- [ ] **Step 6: Implement audit helpers and mutations**

Use the same helper shape as existing audits:

```ruby
def read(path)
  abort("missing file: #{path}") unless File.file?(path)

  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def owner_failures(owner)
  failures = []
  STATE_FIELDS.each { |field| failures << "owner: chartBuilderState missing #{field}" unless owner.include?(field) }
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end
```

Add `integration_failures`, `project_leak_failures`, `audit` and `expect_failure` helpers matching other audits, then add `--mutations` cases named exactly:

```ruby
missing-owner-state
preview-as-save
save-as-publish
publish-request-as-effective
dashboard-add-as-effective
chart-type-compatibility-missing
chart-type-switch-silent-loss
preview-render-as-valid
data-source-version-missing
save-reads-control-draft
preview-boundary-missing
preview-chart-display-owner-missing
visible-panel-only-validation
stale-config-survives
permission-zero-entry-missing
mobile-core-builder-actions-removed
runtime-boundary-marked-verified
missing-route
missing-adjacent-owner-link
project-specific-leakage
```

- [ ] **Step 7: Run audit to verify RED**

Run:

```bash
ruby docs/testing/chart-visualization-builders/chart-visualization-builders-audit.rb
```

Expected: FAIL because `references/chart-visualization-builders.md`, RED/GREEN evidence, route, README, HANDOFF and adjacent owner links do not yet satisfy the new contract.

### Task 2: Implement the owner and integration

**Files:**
- Create: `references/chart-visualization-builders.md`
- Modify: `references/charts-visualization.md`
- Modify: `references/complex-editors-builders.md`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Create: `docs/testing/chart-visualization-builders/red-summary.md`
- Create: `docs/testing/chart-visualization-builders/green-summary.md`

**Interfaces:**
- Consumes: failing audit from Task 1
- Produces: passing owner, route, adjacent owner links, README/HANDOFF summaries, and evidence files

- [ ] **Step 1: Add `references/chart-visualization-builders.md`**

The owner must include these sections:

```markdown
# 图表与可视化创作配置交互规范

## 范围与非目标
## `chartBuilderState`
## 草稿、预览、保存和发布分层
## 图形类型与字段兼容性
## 数据源、指标和维度边界
## 预览可信边界
## 完整校验和错误定位
## 权限、版本和旧配置清理
## 移动端和响应式承载
## 与其他 owner 的关系
## 完成前检查
## 参考资料
```

The file must include the exact state field names and exact owner sentences from Task 1.

- [ ] **Step 2: Add adjacent owner relationship notes**

Add to `references/charts-visualization.md` near its scope or owner relationship section:

```markdown
图表创建、编辑、配置、指标/维度/聚合配置、图形类型切换、图表预览、保存图表、发布图表、加入仪表盘和图表构建器场景还必须执行 `references/chart-visualization-builders.md`；本文件继续负责预览图表和已发布图表的展示语义。
```

Add to `references/complex-editors-builders.md` near non-goals or owner relationships:

```markdown
图表配置器、可视化构建器、报表图表配置和仪表盘图表配置还必须执行 `references/chart-visualization-builders.md`；本文件继续提供通用复杂编辑器生命周期，不能降低图表配置器 owner 的专属规则。
```

- [ ] **Step 3: Add route in `SKILL.md`**

Insert a routing bullet near `charts-visualization.md` and `complex-editors-builders.md` routes:

```markdown
- 涉及图表创建、创建图表、新建图表、编辑图表、图表配置、可视化配置、图表构建器、可视化构建器、报表图表配置、仪表盘图表配置、图表配置向导、指标配置、维度配置、聚合配置、图形类型切换、图表预览、保存图表、发布图表、加入仪表盘、复制图表配置、导出图表配置、图表字段映射、图表钻取配置、图表联动配置，或 chart builder、visualization builder、chart creation、create chart、edit chart、chart config、chart configuration、visualization config、report chart config、dashboard chart config、chart setup、chart wizard、metric config、dimension config、aggregation config、chart type switch、chart preview、save chart、publish chart、add to dashboard、copy chart config、export chart config、chart field mapping、chart drilldown config、chart interaction config 时，必须完整读取 `references/chart-visualization-builders.md`。
```

- [ ] **Step 4: Update README summary and owner path**

Add one summary bullet:

```markdown
- 图表与可视化创作配置规范约束 chartBuilderState、数据源/指标/维度/编码草稿、图形类型兼容、预览快照、完整校验、保存/发布边界、旧配置失效和移动端配置承载，避免预览即保存、保存即发布、图形类型切换静默丢配置、保存读取 Select query 或筛选草稿。
```

Add the full rules path:

```markdown
图表与可视化创作配置规范：`references/chart-visualization-builders.md`
```

Add `chart-visualization-builders.md` to the `references/` tree.

- [ ] **Step 5: Update HANDOFF summary**

Add a section:

```markdown
### 图表与可视化创作配置

- 已定义图表创建、图表编辑、可视化配置、报表图表配置、仪表盘图表配置、图表构建器和图表配置向导的首版 owner。
- `chartBuilderState` 必须声明 `chartBuilderOwnerId`、`sourceConfigSnapshot`、`dataSourceBinding`、`metricDraft`、`dimensionDraft`、`encodingDraft`、`interactionDraft`、`filterBindingDraft`、`previewState`、`validationState`、`savePolicy`、`publishPolicy`、`permissionBoundary` 和 `responsivePolicy`。
- 预览成功不等于保存成功；保存成功不等于发布成功；发布请求发送不等于仪表盘或外部嵌入已生效；加入仪表盘请求发送不等于仪表盘已更新。
- 切换图形类型时，不能静默删除不兼容配置；必须展示迁移摘要、待修复项、保留项、丢弃项和撤销/取消路径。
- 保存时不得读取 Select query、active option、筛选草稿、hover 字段、预览高亮、当前可见结果或旧缓存。
- 移动端不得删除数据源说明、指标配置、维度配置、图形类型、预览、完整校验、错误定位、保存草稿、发布/加入仪表盘、权限原因、版本冲突、恢复路径和离开保护。
- 详细规则和可执行验收仅维护在 `references/chart-visualization-builders.md`，本交接不重复其状态模型或检查项。
```

Add `chart-visualization-builders.md` to the top structure tree and remove or adjust “图表与可视化创作” from future recommendations once the owner is implemented.

- [ ] **Step 6: Add RED evidence**

Create `docs/testing/chart-visualization-builders/red-summary.md` with these negative cases:

```markdown
# 图表与可视化创作配置 RED 证据摘要

- 缺少 `chartBuilderState`，或者缺少 `chartBuilderOwnerId`、`sourceConfigSnapshot`、`dataSourceBinding`、`metricDraft`、`dimensionDraft`、`encodingDraft`、`interactionDraft`、`filterBindingDraft`、`previewState`、`validationState`、`savePolicy`、`publishPolicy`、`permissionBoundary`、`responsivePolicy`。
- 指标、维度、聚合、图形类型、编码、筛选绑定、钻取、导出或明细能力直接写入已保存配置，而不是写入草稿。
- 预览成功被当成保存成功，保存成功被当成发布成功，发布请求发送被当成仪表盘或外部嵌入已生效，加入仪表盘请求发送被当成仪表盘已更新。
- 图形类型没有声明指标数量、维度数量、字段类型、时间轴、多 series、堆叠、百分比、双轴或分母兼容规则。
- 切换图形类型静默删除不兼容配置，没有迁移摘要、待修复项、保留项、丢弃项和撤销/取消路径。
- 预览能画出来就允许保存，没有执行图表配置合法性校验。
- 数据源字段列表没有绑定数据集版本、权限范围、字段类型或刷新时间。
- 保存读取 Select query、active option、筛选草稿、hover 字段、预览高亮、当前可见结果或旧缓存。
- 预览没有声明读取当前草稿、已保存配置还是已发布配置，或者没有说明样本/全量/聚合/权限过滤边界。
- 预览图表没有执行 `charts-visualization.md` 的展示规则。
- 只校验当前可见面板，遗漏折叠面板、隐藏字段、高级配置、钻取目标、导出范围、tooltip 字段、颜色映射、双轴、Top N、权限不可见字段、旧数据源字段或旧图表类型残留。
- 权限、租户/工作区、数据源版本、字段版本、指标口径、来源配置版本、发布版本、仪表盘版本或会话状态变化后，旧字段列表、旧预览、旧保存按钮、旧发布按钮、旧导出配置、旧钻取目标、旧颜色映射、旧复制内容、旧焦点目标或旧 ARIA 引用继续生效。
- 无权或未启用时，数据源选择、字段选择、指标选择、预览、保存、发布、复制、导出、钻取配置、加入仪表盘或查看明细配置仍保留 DOM、state、handler、request 或快捷键入口。
- 移动端删除数据源说明、指标配置、维度配置、图形类型、预览、完整校验、错误定位、保存草稿、发布/加入仪表盘、权限原因、版本冲突、恢复路径或离开保护。
- 真实浏览器、真实图表库、真实数据源、真实预览、真实权限切换、键盘、触摸、读屏和移动端视口未执行时，不能写成已验证，必须标为未验证。
```

- [ ] **Step 7: Add GREEN evidence**

Create `docs/testing/chart-visualization-builders/green-summary.md` with the positive evidence corresponding to every RED case and this command line:

```markdown
对应静态审计入口：`ruby docs/testing/chart-visualization-builders/chart-visualization-builders-audit.rb --mutations`。
```

- [ ] **Step 8: Run focused audit to verify GREEN**

Run:

```bash
ruby docs/testing/chart-visualization-builders/chart-visualization-builders-audit.rb --mutations
```

Expected: every named mutation prints `EXPECTED_FAIL: <name>`, then the audit prints a PASS line for chart visualization builders.

### Task 3: Verify adjacent owner boundaries and repository health

**Files:**
- No new files.
- Read and verify: `references/charts-visualization.md`, `references/complex-editors-builders.md`, `references/forms.md`, `references/query-filters.md`, `references/date-time-ranges.md`, `references/data-tables.md`, `references/risk-actions.md`, `references/permissions-tenancy-visibility.md`, `references/exports-downloads-artifacts.md`, `references/responsive-adaptive.md`

**Interfaces:**
- Consumes: implemented owner and audit from Task 2
- Produces: verified working tree ready to commit

- [ ] **Step 1: Run adjacent executable audits**

Run:

```bash
ruby docs/testing/charts-visualization/charts-visualization-audit.rb --mutations
ruby docs/testing/complex-editors-builders/complex-editors-builders-audit.rb --mutations
ruby docs/testing/query-filters/query-filters-audit.rb --mutations
ruby docs/testing/date-time-ranges/date-time-ranges-audit.rb --mutations
ruby docs/testing/data-tables/attempt-10-selection-event-audit.rb
ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations
ruby docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb --mutations
ruby docs/testing/exports-downloads-artifacts/exports-downloads-artifacts-audit.rb --mutations
```

Expected: all listed audits exit 0. Data tables uses its known-good Attempt 10 executable audit for current contract stability; do not run historical attempt audits as if they were current owner checks.

- [ ] **Step 2: Run full owner audit collection**

Run the known-good collection command that skips historical data-table attempts:

```bash
for audit in docs/testing/*/*-audit.rb; do
  case "$audit" in
    docs/testing/data-tables/attempt-*) continue ;;
  esac
  ruby "$audit" || exit 1
done
```

Expected: exit 0 and includes the new chart visualization builders audit PASS line.

- [ ] **Step 3: Verify Markdown links**

Run:

```bash
ruby -e 'files = Dir["**/*.md"].reject { |f| f.start_with?(".worktrees/") }; missing = []; files.each { |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |href| next if href =~ /\A[a-z][a-z0-9+.-]*:/i; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target) } }; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
```

Expected: `PASS: markdown links resolve`.

- [ ] **Step 4: Verify formatting and project-agnostic boundaries**

Run:

```bash
git diff --check
rg -n "fex-admin|/Users/evanqi/code/|src/pages|Ant Design|ant-design|shadcn|Next.js|Vite|ECharts|Recharts|Highcharts" references/chart-visualization-builders.md docs/testing/chart-visualization-builders README.md || true
```

Expected: `git diff --check` exits 0. The project-specific scan must not find those terms in the new owner or evidence files. The audit file may include these strings only inside `PROJECT_BANNED_TERMS` and mutation inputs; do not copy them into owner, README summary or evidence prose.

- [ ] **Step 5: Inspect final diff**

Run:

```bash
git diff --stat
git diff -- references/chart-visualization-builders.md references/charts-visualization.md references/complex-editors-builders.md docs/testing/chart-visualization-builders SKILL.md README.md HANDOFF.md | sed -n '1,320p'
```

Expected: diff contains only this owner, adjacent owner relationship notes, routing, summaries, evidence and audit changes.

### Task 4: Commit and push implementation

**Files:**
- Stage: `SKILL.md`, `README.md`, `HANDOFF.md`, `references/chart-visualization-builders.md`, `references/charts-visualization.md`, `references/complex-editors-builders.md`, `docs/testing/chart-visualization-builders`

**Interfaces:**
- Consumes: verified green state from Task 3
- Produces: pushed `main` commit

- [ ] **Step 1: Read completion skills before claiming done**

Read and follow:

```bash
sed -n '1,220p' /Users/evanqi/.codex/plugins/cache/openai-curated-remote/superpowers/6.2.0/skills/verification-before-completion/SKILL.md
sed -n '1,260p' /Users/evanqi/.codex/plugins/cache/openai-curated-remote/superpowers/6.2.0/skills/finishing-a-development-branch/SKILL.md
```

- [ ] **Step 2: Stage files**

Run:

```bash
git add SKILL.md README.md HANDOFF.md references/chart-visualization-builders.md references/charts-visualization.md references/complex-editors-builders.md docs/testing/chart-visualization-builders
```

- [ ] **Step 3: Commit**

Run:

```bash
git commit -m "docs: 新增图表可视化配置规范"
```

- [ ] **Step 4: Push**

Run:

```bash
git push origin main
```

- [ ] **Step 5: Confirm final state**

Run:

```bash
git status --short --branch
git log --oneline -1
```

Expected: `main...origin/main` with no uncommitted files and the latest commit is `docs: 新增图表可视化配置规范`.

## Self-Review

- Spec coverage: Task 1 covers executable audit design; Task 2 covers owner, adjacent owner links, routing, README, HANDOFF and RED/GREEN evidence; Task 3 covers adjacent owner boundaries, full owner collection, Markdown links, formatting and project-agnostic constraints; Task 4 covers verified commit and push.
- Scope check: This plan implements one owner only: chart visualization builders. It does not implement runtime UI components, BI engine behavior, data modeling, SQL editing, chart rendering libraries or business-project adoption.
- Type/name consistency: The plan uses one owner file name `references/chart-visualization-builders.md`, one audit directory `docs/testing/chart-visualization-builders`, one state name `chartBuilderState`, and the same fourteen state fields in Global Constraints, Task 1 and Task 2.
