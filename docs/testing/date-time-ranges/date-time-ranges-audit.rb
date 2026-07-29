#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/date-time-ranges.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/date-time-ranges/green-summary.md")
RED = File.join(ROOT, "docs/testing/date-time-ranges/red-summary.md")

RULE_IDS = %w[
  DTR-SCOPE-01 DTR-SCOPE-02 DTR-SCOPE-03 DTR-SCOPE-04 DTR-SCOPE-05
  DTR-STATE-01 DTR-STATE-02 DTR-STATE-03 DTR-STATE-04 DTR-STATE-05
  DTR-RANGE-01 DTR-RANGE-02 DTR-RANGE-03 DTR-RANGE-04 DTR-RANGE-05
  DTR-PRESET-01 DTR-PRESET-02 DTR-PRESET-03 DTR-PRESET-04 DTR-PRESET-05
  DTR-TZ-01 DTR-TZ-02 DTR-TZ-03 DTR-TZ-04 DTR-TZ-05
  DTR-VALID-01 DTR-VALID-02 DTR-VALID-03 DTR-VALID-04 DTR-VALID-05
  DTR-URL-01 DTR-URL-02 DTR-URL-03 DTR-URL-04 DTR-URL-05
  DTR-REPORT-01 DTR-REPORT-02 DTR-REPORT-03 DTR-REPORT-04 DTR-REPORT-05
  DTR-A11Y-01 DTR-A11Y-02 DTR-A11Y-03 DTR-A11Y-04 DTR-A11Y-05
  DTR-RSP-01 DTR-RSP-02 DTR-RSP-03 DTR-RSP-04 DTR-RSP-05
  DTR-LIFE-01 DTR-LIFE-02 DTR-LIFE-03 DTR-LIFE-04 DTR-LIFE-05
].freeze

STATE_FIELDS = %w[
  dateTimeOwnerId valueKind inputMode displayTimezone storageTimezone rangeBoundary
  granularity presetPolicy relativeAnchor validationState urlSerialization
  requestBinding localePolicy
].freeze

OWNER_TERMS = [
  "dateTimeState",
  "日期时间值必须声明展示时区、存储/请求时区、边界语义和粒度",
  "不得使用含糊本地字符串",
  "范围推荐使用 `[start, end)`",
  "快捷范围必须冻结应用时的 `relativeAnchor`",
  "今天、昨天、本周、本月、近 7 天和近 30 天不得在同一已应用查询中随时间漂移",
  "displayTimezone",
  "storageTimezone",
  "DST",
  "end < start",
  "部分范围不得触发查询",
  "只有明确 `urlSafe` 的日期时间值可以进入 URL",
  "报表、导出和审计必须携带范围快照、时区、数据延迟和刷新时间",
  "移动端不得删除清空、重置、快捷范围、错误说明或时区说明",
  "未验证"
].freeze

ROUTE_TERMS = [
  "日期",
  "时间范围",
  "时区",
  "快捷时间",
  "近 7 天",
  "开始时间",
  "结束时间",
  "刷新时间",
  "data latency",
  "timezone",
  "date range",
  "last 7 days",
  "export range",
  "references/date-time-ranges.md"
].freeze

README_TERMS = [
  "日期时间与时区规范",
  "日期时间与时区交互规范",
  "references/date-time-ranges.md",
  "date-time-ranges.md"
].freeze

HANDOFF_TERMS = [
  "### 日期时间与时区",
  "日期时间值必须声明展示时区、存储/请求时区、边界语义和粒度",
  "范围推荐使用 `[start, end)`",
  "快捷范围必须冻结应用时的 `relativeAnchor`",
  "references/date-time-ranges.md"
].freeze

EVIDENCE_TERMS = [
  "dateTimeState",
  "displayTimezone",
  "storageTimezone",
  "relativeAnchor",
  "[start, end)",
  "DST",
  "urlSafe",
  "data latency",
  "移动端不得删除清空",
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
  STATE_FIELDS.each { |field| failures << "owner: dateTimeState missing #{field}" unless owner.include?(field) }
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
    audit(owner: owner.gsub("dateTimeState", "dateState"),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-timezone-contract") do
    audit(owner: owner.gsub("日期时间值必须声明展示时区、存储/请求时区、边界语义和粒度", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("ambiguous-local-string") do
    audit(owner: owner.gsub("不得使用含糊本地字符串", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("range-boundary") do
    audit(owner: owner.gsub("范围推荐使用 `[start, end)`", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("preset-anchor") do
    audit(owner: owner.gsub("快捷范围必须冻结应用时的 `relativeAnchor`", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("preset-drift") do
    audit(owner: owner.gsub("今天、昨天、本周、本月、近 7 天和近 30 天不得在同一已应用查询中随时间漂移", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("partial-range-query") do
    audit(owner: owner.gsub("部分范围不得触发查询", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("url-safe") do
    audit(owner: owner.gsub("只有明确 `urlSafe` 的日期时间值可以进入 URL", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("report-export-audit-snapshot") do
    audit(owner: owner.gsub("报表、导出和审计必须携带范围快照、时区、数据延迟和刷新时间", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-loss") do
    audit(owner: owner.gsub("移动端不得删除清空、重置、快捷范围、错误说明或时区说明", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-route") do
    audit(owner: owner, skill: skill.gsub("references/date-time-ranges.md", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("project-leak") do
    audit(owner: "#{owner}\nfex-admin", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "date-time-ranges audit passed"
