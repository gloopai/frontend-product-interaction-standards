#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/information-display.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/information-display/green-summary.md")
RED = File.join(ROOT, "docs/testing/information-display/red-summary.md")

RULE_IDS = %w[
  IDS-SCOPE-01 IDS-SCOPE-02 IDS-SCOPE-03 IDS-SCOPE-04 IDS-SCOPE-05
  IDS-READONLY-01 IDS-READONLY-02 IDS-READONLY-03 IDS-READONLY-04 IDS-READONLY-05
  IDS-FIELD-01 IDS-FIELD-02 IDS-FIELD-03 IDS-FIELD-04 IDS-FIELD-05
  IDS-STATUS-01 IDS-STATUS-02 IDS-STATUS-03 IDS-STATUS-04 IDS-STATUS-05
  IDS-METRIC-01 IDS-METRIC-02 IDS-METRIC-03 IDS-METRIC-04 IDS-METRIC-05
  IDS-ACTION-01 IDS-ACTION-02 IDS-ACTION-03 IDS-ACTION-04 IDS-ACTION-05
  IDS-PERM-01 IDS-PERM-02 IDS-PERM-03 IDS-PERM-04 IDS-PERM-05
  IDS-LAYOUT-01 IDS-LAYOUT-02 IDS-LAYOUT-03 IDS-LAYOUT-04 IDS-LAYOUT-05
  IDS-RSP-01 IDS-RSP-02 IDS-RSP-03 IDS-RSP-04 IDS-RSP-05
  IDS-A11Y-01 IDS-A11Y-02 IDS-A11Y-03 IDS-A11Y-04 IDS-A11Y-05
  IDS-LIFE-01 IDS-LIFE-02 IDS-LIFE-03 IDS-LIFE-04 IDS-LIFE-05
].freeze

STATE_FIELDS = %w[
  displayOwnerId subjectIdentity displaySnapshot fieldSemantics visibilityPolicy
  freshnessState statusSemantics actionBinding copyPolicy responsivePolicy
  a11yPolicy auditBinding
].freeze

OWNER_TERMS = [
  "informationDisplayState",
  "详情页不得直接内嵌 input、textarea、select、可编辑表格或行内保存按钮来完成编辑",
  "只读状态不得用 disabled 表单控件充当展示文本",
  "空值、未配置、未知、加载失败、无权限、已删除和不适用必须可区分",
  "状态标签、徽标、颜色、图标和趋势箭头不能是唯一语义来源",
  "指标卡必须声明指标名、口径、单位、时间范围、数据延迟、刷新时间和权限范围",
  "复制操作不得复制脱敏或无权限字段的真实值",
  "无权限展示不得泄露对象名称、字段值、数量、文件名、内部 ID、筛选值或旧缓存",
  "移动端不得删除字段 label、单位、状态说明、错误/权限说明、复制/恢复路径或审计入口",
  "未验证"
].freeze

ROUTE_TERMS = [
  "详情页",
  "信息展示",
  "描述列表",
  "只读字段",
  "指标卡",
  "状态标签",
  "复制字段",
  "脱敏展示",
  "detail page",
  "information display",
  "description list",
  "read-only field",
  "status badge",
  "metric card",
  "audit summary",
  "references/information-display.md"
].freeze

README_TERMS = [
  "信息展示与详情页规范",
  "信息展示与详情页交互规范",
  "references/information-display.md",
  "information-display.md"
].freeze

HANDOFF_TERMS = [
  "### 信息展示与详情页",
  "详情页不得直接内嵌 input、textarea、select、可编辑表格或行内保存按钮来完成编辑",
  "空值、未配置、未知、加载失败、无权限、已删除和不适用必须可区分",
  "移动端不得删除字段 label、单位、状态说明、错误/权限说明、复制/恢复路径或审计入口",
  "references/information-display.md"
].freeze

EVIDENCE_TERMS = [
  "informationDisplayState",
  "displayOwnerId",
  "subjectIdentity",
  "displaySnapshot",
  "fieldSemantics",
  "visibilityPolicy",
  "freshnessState",
  "statusSemantics",
  "actionBinding",
  "copyPolicy",
  "responsivePolicy",
  "a11yPolicy",
  "auditBinding",
  "disabled 表单控件",
  "唯一语义来源",
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
  STATE_FIELDS.each { |field| failures << "owner: informationDisplayState missing #{field}" unless owner.include?(field) }
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
    audit(owner: owner.gsub("informationDisplayState", "displayState"),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("inline-editing-in-detail") do
    audit(owner: owner.gsub("详情页不得直接内嵌 input、textarea、select、可编辑表格或行内保存按钮来完成编辑", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("disabled-control-as-readonly") do
    audit(owner: owner.gsub("只读状态不得用 disabled 表单控件充当展示文本", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("ambiguous-empty-values") do
    audit(owner: owner.gsub("空值、未配置、未知、加载失败、无权限、已删除和不适用必须可区分", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("status-color-only") do
    audit(owner: owner.gsub("状态标签、徽标、颜色、图标和趋势箭头不能是唯一语义来源", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("metric-semantics") do
    audit(owner: owner.gsub("指标卡必须声明指标名、口径、单位、时间范围、数据延迟、刷新时间和权限范围", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("copy-sensitive-real-value") do
    audit(owner: owner.gsub("复制操作不得复制脱敏或无权限字段的真实值", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-leakage") do
    audit(owner: owner.gsub("无权限展示不得泄露对象名称、字段值、数量、文件名、内部 ID、筛选值或旧缓存", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-information-loss") do
    audit(owner: owner.gsub("移动端不得删除字段 label、单位、状态说明、错误/权限说明、复制/恢复路径或审计入口", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-route") do
    audit(owner: owner, skill: skill.gsub("references/information-display.md", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("project-leak") do
    audit(owner: "#{owner}\nfex-admin", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "information-display audit passed"
