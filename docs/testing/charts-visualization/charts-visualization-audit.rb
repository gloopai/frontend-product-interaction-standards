#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/charts-visualization.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/charts-visualization/green-summary.md")
RED = File.join(ROOT, "docs/testing/charts-visualization/red-summary.md")

RULE_IDS = %w[
  CHV-SCOPE-01 CHV-SCOPE-02 CHV-SCOPE-03 CHV-SCOPE-04 CHV-SCOPE-05
  CHV-DATA-01 CHV-DATA-02 CHV-DATA-03 CHV-DATA-04 CHV-DATA-05
  CHV-ENC-01 CHV-ENC-02 CHV-ENC-03 CHV-ENC-04 CHV-ENC-05
  CHV-AXIS-01 CHV-AXIS-02 CHV-AXIS-03 CHV-AXIS-04 CHV-AXIS-05
  CHV-TIP-01 CHV-TIP-02 CHV-TIP-03 CHV-TIP-04 CHV-TIP-05
  CHV-INTERACT-01 CHV-INTERACT-02 CHV-INTERACT-03 CHV-INTERACT-04 CHV-INTERACT-05
  CHV-STATE-01 CHV-STATE-02 CHV-STATE-03 CHV-STATE-04 CHV-STATE-05
  CHV-EXPORT-01 CHV-EXPORT-02 CHV-EXPORT-03 CHV-EXPORT-04 CHV-EXPORT-05
  CHV-RSP-01 CHV-RSP-02 CHV-RSP-03 CHV-RSP-04 CHV-RSP-05
  CHV-A11Y-01 CHV-A11Y-02 CHV-A11Y-03 CHV-A11Y-04 CHV-A11Y-05
  CHV-LIFE-01 CHV-LIFE-02 CHV-LIFE-03 CHV-LIFE-04 CHV-LIFE-05
].freeze

STATE_FIELDS = %w[
  chartOwnerId chartKind dataSnapshot metricBinding dimensionBinding encodingPolicy
  axisPolicy legendPolicy tooltipPolicy interactionPolicy feedbackState responsivePolicy
  a11yPolicy
].freeze

OWNER_TERMS = [
  "chartState",
  "每个图表必须声明 `chartState.dataSnapshot` 与 `metricBinding`",
  "图表必须展示或可达地说明指标名、口径、单位、时间范围、时区、数据延迟、刷新时间和权限范围",
  "颜色不得作为唯一语义来源",
  "图表 tooltip 不能承载唯一必读信息",
  "坐标轴必须声明字段、单位、刻度格式和排序规则",
  "非零基线、截断轴、对数轴、双轴、百分比堆叠和归一化必须显式标注",
  "Hover/highlight、legend toggle、drilldown、brush、zoom、联动筛选、导出和查看明细必须在 `interactionPolicy` 中声明",
  "图表必须区分 loading、empty、zero-results、partial、stale、refresh-error、permission-denied 和 metric-unavailable",
  "无权限状态不得泄露 series 名称、数量、对象名、筛选值、内部 ID 或旧缓存",
  "移动端不得删除图表标题、口径、单位、图例/series 含义、状态说明、错误/权限说明、数据延迟、刷新时间、导出/明细入口和恢复路径",
  "未验证"
].freeze

ROUTE_TERMS = [
  "图表",
  "可视化",
  "图例",
  "坐标轴",
  "图表 tooltip",
  "图表钻取",
  "图表导出",
  "chart",
  "data visualization",
  "line chart",
  "bar chart",
  "legend",
  "axis",
  "chart tooltip",
  "chart drilldown",
  "chart export",
  "references/charts-visualization.md"
].freeze

README_TERMS = [
  "图表与可视化规范",
  "图表与可视化交互规范",
  "references/charts-visualization.md",
  "charts-visualization.md"
].freeze

HANDOFF_TERMS = [
  "### 图表与可视化",
  "每个图表必须声明 `chartState.dataSnapshot` 与 `metricBinding`",
  "颜色不得作为唯一语义来源",
  "图表 tooltip 不能承载唯一必读信息",
  "references/charts-visualization.md"
].freeze

EVIDENCE_TERMS = [
  "chartState",
  "chartOwnerId",
  "chartKind",
  "dataSnapshot",
  "metricBinding",
  "dimensionBinding",
  "encodingPolicy",
  "axisPolicy",
  "legendPolicy",
  "tooltipPolicy",
  "interactionPolicy",
  "feedbackState",
  "responsivePolicy",
  "a11yPolicy",
  "颜色不得作为唯一语义来源",
  "图表 tooltip 不能承载唯一必读信息",
  "未验证"
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
  RULE_IDS.each { |id| failures << "owner: missing rule id #{id}" unless owner.include?(id) }
  STATE_FIELDS.each { |field| failures << "owner: chartState missing #{field}" unless owner.include?(field) }
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end

def integration_failures(skill, readme, handoff, green, red)
  failures = []
  failures.concat(require_terms(skill, ROUTE_TERMS, "SKILL route"))
  failures.concat(require_terms(readme, README_TERMS, "README"))
  failures.concat(require_terms(handoff, HANDOFF_TERMS, "HANDOFF"))
  failures.concat(require_terms(green, EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(red, EVIDENCE_TERMS, "RED evidence"))
  failures
end

def project_leak_failures(owner)
  banned_terms = [
    "fex-admin",
    "/Users/evanqi/code/",
    "src/pages",
    "Ant Design",
    "ant-design",
    "shadcn",
    "Next.js",
    "Vite"
  ]

  banned_terms.select { |term| owner.include?(term) }.map do |term|
    "owner: must stay project-agnostic, found #{term.inspect}"
  end
end

def audit(owner:, skill:, readme:, handoff:, green:, red:)
  owner_failures(owner) +
    integration_failures(skill, readme, handoff, green, red) +
    project_leak_failures(owner)
end

def expect_failure(name)
  failures = yield
  abort("mutation did not fail: #{name}") if failures.empty?

  puts "EXPECTED_FAIL: #{name}"
end

owner = read(OWNER)
skill = read(SKILL)
readme = read(README)
handoff = read(HANDOFF)
green = read(GREEN)
red = read(RED)

failures = audit(owner: owner, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
unless failures.empty?
  warn failures.join("\n")
  exit 1
end

if ARGV.include?("--mutations")
  expect_failure("missing-owner-state") do
    audit(owner: owner.gsub("chartState", "visualState"),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-data-snapshot") do
    audit(owner: owner.gsub("每个图表必须声明 `chartState.dataSnapshot` 与 `metricBinding`", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-metric-context") do
    audit(owner: owner.gsub("图表必须展示或可达地说明指标名、口径、单位、时间范围、时区、数据延迟、刷新时间和权限范围", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("color-only-semantics") do
    audit(owner: owner.gsub("颜色不得作为唯一语义来源", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("tooltip-only-information") do
    audit(owner: owner.gsub("图表 tooltip 不能承载唯一必读信息", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("axis-semantics") do
    audit(owner: owner.gsub("坐标轴必须声明字段、单位、刻度格式和排序规则", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("misleading-scale") do
    audit(owner: owner.gsub("非零基线、截断轴、对数轴、双轴、百分比堆叠和归一化必须显式标注", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("interaction-policy") do
    audit(owner: owner.gsub("Hover/highlight、legend toggle、drilldown、brush、zoom、联动筛选、导出和查看明细必须在 `interactionPolicy` 中声明", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("state-distinction") do
    audit(owner: owner.gsub("图表必须区分 loading、empty、zero-results、partial、stale、refresh-error、permission-denied 和 metric-unavailable", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-leakage") do
    audit(owner: owner.gsub("无权限状态不得泄露 series 名称、数量、对象名、筛选值、内部 ID 或旧缓存", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-chart-loss") do
    audit(owner: owner.gsub("移动端不得删除图表标题、口径、单位、图例/series 含义、状态说明、错误/权限说明、数据延迟、刷新时间、导出/明细入口和恢复路径", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-route") do
    audit(owner: owner, skill: skill.gsub("references/charts-visualization.md", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("project-leak") do
    audit(owner: "#{owner}\nfex-admin", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "charts-visualization audit passed"
