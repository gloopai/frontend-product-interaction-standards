#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/query-filters.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/query-filters/green-summary.md")
RED = File.join(ROOT, "docs/testing/query-filters/red-summary.md")

RULE_IDS = %w[
  QF-SCOPE-01 QF-SCOPE-02 QF-SCOPE-03 QF-SCOPE-04
  QF-STATE-01 QF-STATE-02 QF-STATE-03 QF-STATE-04 QF-STATE-05
  QF-APPLY-01 QF-APPLY-02 QF-APPLY-03 QF-APPLY-04 QF-APPLY-05 QF-APPLY-06
  QF-RESET-01 QF-RESET-02 QF-RESET-03 QF-RESET-04 QF-RESET-05
  QF-SUMMARY-01 QF-SUMMARY-02 QF-SUMMARY-03 QF-SUMMARY-04 QF-SUMMARY-05
  QF-URL-01 QF-URL-02 QF-URL-03 QF-URL-04 QF-URL-05
  QF-PERM-01 QF-PERM-02 QF-PERM-03 QF-PERM-04 QF-PERM-05
  QF-A11Y-01 QF-A11Y-02 QF-A11Y-03 QF-A11Y-04 QF-A11Y-05
  QF-RSP-01 QF-RSP-02 QF-RSP-03 QF-RSP-04
].freeze

STATE_FIELDS = %w[
  filterOwnerId filterDraft appliedFilters defaultFilters filterSchema queryIntent urlState requestBinding
].freeze

OWNER_TERMS = [
  "queryFilterState",
  "filterDraft` 与 `appliedFilters` 必须分离",
  "字段内部草稿不得进入 `filterDraft`、`appliedFilters`、URL 或结果摘要",
  "每个条件必须声明 `applyMode: immediate | explicit`",
  "“重置”恢复 `defaultFilters`",
  "已应用条件必须持续可见或在摘要中可发现",
  "只有明确 `urlSafe` 的已应用条件可以进入 URL",
  "不得静默忽略 URL 中的已知条件",
  "无权条件、敏感值、旧租户选项和旧 URL 状态不能继续暴露",
  "移动端不得删除核心筛选能力",
  "未验证"
].freeze

ROUTE_TERMS = [
  "查询条件",
  "筛选",
  "关键词搜索",
  "高级筛选",
  "重置筛选",
  "已应用条件",
  "URL 筛选",
  "query filter",
  "filter bar",
  "applied filters",
  "filter chips",
  "references/query-filters.md"
].freeze

README_TERMS = [
  "查询条件与筛选规范",
  "references/query-filters.md"
].freeze

HANDOFF_TERMS = [
  "### 查询条件与筛选",
  "references/query-filters.md",
  "filterDraft` 与 `appliedFilters` 必须分离",
  "敏感条件不得进入 URL"
].freeze

EVIDENCE_TERMS = [
  "filterDraft",
  "appliedFilters",
  "applyMode",
  "defaultFilters",
  "已应用条件",
  "URL",
  "sensitive",
  "移动端不得删除核心筛选能力",
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
  STATE_FIELDS.each { |field| failures << "owner: queryFilterState missing #{field}" unless owner.include?(field) }
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
  if failures.empty?
    abort("mutation did not fail: #{name}")
  end

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
  expect_failure("draft-applied-separation-removed") do
    audit(owner: owner.gsub("filterDraft` 与 `appliedFilters` 必须分离", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("select-internal-draft-enters-filters") do
    audit(owner: owner.gsub("字段内部草稿不得进入 `filterDraft`、`appliedFilters`、URL 或结果摘要", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("apply-mode-removed") do
    audit(owner: owner.gsub("每个条件必须声明 `applyMode: immediate | explicit`", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("reset-defaults-removed") do
    audit(owner: owner.gsub("“重置”恢复 `defaultFilters`", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("applied-summary-removed") do
    audit(owner: owner.gsub("已应用条件必须持续可见或在摘要中可发现", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("url-safe-rule-removed") do
    audit(owner: owner.gsub("只有明确 `urlSafe` 的已应用条件可以进入 URL", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("invalid-url-silently-ignored") do
    audit(owner: owner.gsub("不得静默忽略 URL 中的已知条件", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-cleanup-removed") do
    audit(owner: owner.gsub("无权条件、敏感值、旧租户选项和旧 URL 状态不能继续暴露", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-filter-capability-removed") do
    audit(owner: owner.gsub("移动端不得删除核心筛选能力", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("project-specific-leakage") do
    audit(owner: "#{owner}\nfex-admin\n",
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 查询条件与筛选 owner、路由、摘要和证据符合结构化审计契约。"
