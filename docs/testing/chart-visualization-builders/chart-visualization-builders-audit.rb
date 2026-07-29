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

STATE_FIELDS = %w[
  chartBuilderOwnerId sourceConfigSnapshot dataSourceBinding metricDraft
  dimensionDraft encodingDraft interactionDraft filterBindingDraft
  previewState validationState savePolicy publishPolicy permissionBoundary
  responsivePolicy
].freeze

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

RELATIONSHIP_TERMS = [
  "references/chart-visualization-builders.md",
  "chart-visualization-builders.md"
].freeze

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

def integration_failures(charts:, editors:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(require_terms(charts, RELATIONSHIP_TERMS, "charts relationship"))
  failures.concat(require_terms(editors, RELATIONSHIP_TERMS, "editors relationship"))
  failures.concat(require_terms(skill, ROUTE_TERMS, "SKILL route"))
  failures.concat(require_terms(readme, README_TERMS, "README"))
  failures.concat(require_terms(handoff, HANDOFF_TERMS, "HANDOFF"))
  failures.concat(require_terms(green, EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(red, EVIDENCE_TERMS, "RED evidence"))
  failures
end

def project_leak_failures(texts)
  PROJECT_BANNED_TERMS.flat_map do |term|
    texts.select { |label, text| text.include?(term) }.map { |label, _text| "#{label}: forbidden project-specific term #{term}" }
  end
end

def audit(owner:, charts:, editors:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(owner_failures(owner))
  failures.concat(integration_failures(charts: charts, editors: editors, skill: skill, readme: readme,
                                       handoff: handoff, green: green, red: red))
  failures.concat(project_leak_failures("owner" => owner, "green" => green, "red" => red))
  failures
end

def expect_failure(name)
  failures = yield
  abort("mutation did not fail: #{name}") if failures.empty?

  puts "EXPECTED_FAIL: #{name}"
end

owner = read(OWNER)
charts = read(CHARTS)
editors = read(EDITORS)
skill = read(SKILL)
readme = read(README)
handoff = read(HANDOFF)
green = read(GREEN)
red = read(RED)

failures = audit(owner: owner, charts: charts, editors: editors, skill: skill, readme: readme,
                 handoff: handoff, green: green, red: red)
unless failures.empty?
  warn failures.join("\n")
  exit 1
end

if ARGV.include?("--mutations")
  expect_failure("missing-owner-state") do
    audit(owner: owner.gsub("chartBuilderState", "chart-builder-state"), charts: charts, editors: editors,
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("preview-as-save") do
    audit(owner: owner.gsub("预览成功不等于保存成功", ""), charts: charts, editors: editors,
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("save-as-publish") do
    audit(owner: owner.gsub("保存成功不等于发布成功", ""), charts: charts, editors: editors,
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("publish-request-as-effective") do
    audit(owner: owner.gsub("发布请求发送不等于仪表盘或外部嵌入已生效", ""), charts: charts, editors: editors,
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("dashboard-add-as-effective") do
    audit(owner: owner.gsub("加入仪表盘请求发送不等于仪表盘已更新", ""), charts: charts, editors: editors,
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("chart-type-compatibility-missing") do
    audit(owner: owner.gsub("每种图形类型必须声明可接受的指标数量、维度数量、字段类型、时间轴要求、是否允许多 series、是否允许堆叠、是否允许百分比、是否允许双轴和是否需要分母", ""),
          charts: charts, editors: editors, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("chart-type-switch-silent-loss") do
    audit(owner: owner.gsub("切换图形类型时，不能静默删除不兼容配置", "")
                      .gsub("必须展示迁移摘要、待修复项、保留项、丢弃项和撤销/取消路径", ""),
          charts: charts, editors: editors, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("preview-render-as-valid") do
    audit(owner: owner.gsub("不能让“预览能画出来”替代配置合法性", ""), charts: charts, editors: editors,
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("data-source-version-missing") do
    audit(owner: owner.gsub("数据源字段列表必须绑定数据集版本、权限范围、字段类型和刷新时间", ""),
          charts: charts, editors: editors, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("save-reads-control-draft") do
    audit(owner: owner.gsub("保存时不得读取 Select query、active option、筛选草稿、hover 字段、预览高亮、当前可见结果或旧缓存", ""),
          charts: charts, editors: editors, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("preview-boundary-missing") do
    audit(owner: owner.gsub("预览必须声明读取的是当前草稿、已保存配置还是已发布配置", ""),
          charts: charts, editors: editors, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("preview-chart-display-owner-missing") do
    audit(owner: owner.gsub("预览图表本身必须执行 `charts-visualization.md` 的展示规则", ""),
          charts: charts, editors: editors, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("visible-panel-only-validation") do
    audit(owner: owner.gsub("配置器必须校验完整配置，而不是只校验当前可见面板", "")
                      .gsub("折叠面板、隐藏字段、高级配置、钻取目标、导出范围、tooltip 字段、颜色映射、双轴、Top N、权限不可见字段、旧数据源字段和旧图表类型残留都必须进入 `validationState`", ""),
          charts: charts, editors: editors, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("stale-config-survives") do
    audit(owner: owner.gsub("权限、租户/工作区、数据源版本、字段版本、指标口径、来源配置版本、发布版本、仪表盘版本或会话状态变化后，旧字段列表、旧预览、旧保存按钮、旧发布按钮、旧导出配置、旧钻取目标、旧颜色映射、旧复制内容、旧焦点目标和旧 ARIA 引用必须失效或重新证明安全", ""),
          charts: charts, editors: editors, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-zero-entry-missing") do
    audit(owner: owner.gsub("无权或未启用时，数据源选择、字段选择、指标选择、预览、保存、发布、复制、导出、钻取配置、加入仪表盘和查看明细配置的 DOM、state、handler、request 和快捷键入口为 0", ""),
          charts: charts, editors: editors, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-core-builder-actions-removed") do
    audit(owner: owner.gsub("移动端不得删除数据源说明、指标配置、维度配置、图形类型、预览、完整校验、错误定位、保存草稿、发布/加入仪表盘、权限原因、版本冲突、恢复路径和离开保护", ""),
          charts: charts, editors: editors, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"), charts: charts, editors: editors, skill: skill,
          readme: readme, handoff: handoff.gsub("未验证", "已验证"),
          green: green.gsub("未验证", "已验证"), red: red.gsub("未验证", "已验证"))
  end

  expect_failure("missing-route") do
    audit(owner: owner, charts: charts, editors: editors, skill: skill.gsub("references/chart-visualization-builders.md", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-adjacent-owner-link") do
    audit(owner: owner, charts: charts.gsub("chart-visualization-builders.md", ""),
          editors: editors.gsub("chart-visualization-builders.md", ""), skill: skill, readme: readme,
          handoff: handoff, green: green, red: red)
  end

  expect_failure("project-specific-leakage") do
    audit(owner: "#{owner}\nfex-admin", charts: charts, editors: editors, skill: skill, readme: readme,
          handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 图表与可视化创作配置规范符合结构化审计契约。"
