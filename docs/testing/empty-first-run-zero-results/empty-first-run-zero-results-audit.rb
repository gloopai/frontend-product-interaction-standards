#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)

FILES = {
  owner: "references/empty-first-run-zero-results.md",
  feedback: "references/feedback-states.md",
  list_controls: "references/list-result-controls.md",
  page_content: "references/page-content-layout-sections.md",
  buttons: "references/buttons.md",
  permissions: "references/permissions-tenancy-visibility.md",
  query_filters: "references/query-filters.md",
  data_tables: "references/data-tables.md",
  card_list: "references/card-list-results.md",
  skill: "SKILL.md",
  readme: "README.md",
  handoff: "HANDOFF.md",
  green: "docs/testing/empty-first-run-zero-results/green-summary.md",
  red: "docs/testing/empty-first-run-zero-results/red-summary.md"
}.freeze

STATE_FIELDS = %w[
  emptyStateOwnerId
  emptySurface
  emptyReason
  dataScopeSnapshot
  querySnapshot
  permissionBoundary
  capabilityPolicy
  contentPolicy
  primaryActionPolicy
  secondaryActionPolicy
  recoveryPolicy
  illustrationPolicy
  feedbackBinding
  resultOwnerBinding
  responsivePolicy
  focusAnnouncementPolicy
  lifecycleDisposal
  runtimeVerification
].freeze

OWNER_TERMS = [
  "emptyStateDecision",
  "空状态不是“没有数据”的单一文案",
  "必须区分 firstRunEmpty、trueEmpty、zeroResults、permissionEmpty、errorEmpty、loadingEmpty、archivedEmpty、notConfiguredEmpty 和 readOnlyEmpty",
  "zeroResults 的主恢复通常是清空筛选、调整关键词、重置时间范围或返回默认视图",
  "创建入口不得出现在只读报表、权限不足、能力未启用、租户/工作区不可写、对象类型不可创建或筛选无结果但真实数据范围未知的场景",
  "清空筛选和重置筛选不是同一件事",
  "权限不可见不等于没有数据",
  "无权限时不得泄露对象名称、数量、字段、筛选值、状态分布、归档数量、文件名、成员、金额、内部 ID、错误明细、旧搜索结果或旧可访问名称",
  "未验证"
].freeze

ADJACENT_TERMS = [
  "references/empty-first-run-zero-results.md",
  "emptyStateDecision"
].freeze

README_TERMS = [
  "空态、无结果与首次使用引导规范",
  "references/empty-first-run-zero-results.md"
].freeze

HANDOFF_TERMS = [
  "### 空态、无结果与首次使用引导",
  "emptyStateDecision",
  "空状态不是“没有数据”的单一文案",
  "zeroResults",
  "references/empty-first-run-zero-results.md"
].freeze

LEAK_PATTERN = /(fex-admin|\/Users\/evanqi\/code\/|src\/pages|Ant Design|ant-design|shadcn|Next\.js|Vite|React|Vue)/

def read_file(key)
  path = File.join(ROOT, FILES.fetch(key))
  abort("Missing file: #{FILES.fetch(key)}") unless File.exist?(path)
  File.read(path, encoding: "UTF-8")
end

def assert_includes!(text, term, label)
  abort("#{label} missing required term: #{term}") unless text.include?(term)
end

def assert_not_includes!(text, pattern, label)
  match = text.match(pattern)
  abort("#{label} contains project-specific leak: #{match[0]}") if match
end

def handoff_section(text)
  marker = "### 空态、无结果与首次使用引导"
  start = text.index(marker)
  abort("HANDOFF missing required section: #{marker}") unless start
  rest = text[start..]
  finish = rest.index(/\n### /, marker.length)
  finish ? rest[0...finish] : rest
end

def run_audit
  owner = read_file(:owner)
  OWNER_TERMS.each { |term| assert_includes!(owner, term, "owner") }
  STATE_FIELDS.each { |term| assert_includes!(owner, term, "owner state") }

  %i[feedback list_controls page_content buttons permissions query_filters data_tables card_list].each do |key|
    text = read_file(key)
    ADJACENT_TERMS.each { |term| assert_includes!(text, term, FILES.fetch(key)) }
  end

  skill = read_file(:skill)
  %w[空态 无结果 首次使用 zero\ results first\ run empty\ CTA references/empty-first-run-zero-results.md].each do |term|
    assert_includes!(skill, term.gsub("\\ ", " "), "SKILL route")
  end

  readme = read_file(:readme)
  README_TERMS.each { |term| assert_includes!(readme, term, "README") }

  handoff = handoff_section(read_file(:handoff))
  HANDOFF_TERMS.each { |term| assert_includes!(handoff, term, "HANDOFF") }

  %i[owner green red readme].each do |key|
    assert_not_includes!(read_file(key), LEAK_PATTERN, FILES.fetch(key))
  end
  assert_not_includes!(handoff, LEAK_PATTERN, "HANDOFF empty section")

  puts "PASS: 空态、无结果与首次使用引导 owner、路由和证据符合结构化审计契约。"
end

def with_mutation(name)
  original_read = method(:read_file)

  define_singleton_method(:read_file) do |key|
    text = original_read.call(key)
    case name
    when "missing-owner-state"
      key == :owner ? text.gsub("emptyStateDecision", "removed empty decision") : text
    when "single-no-data-boundary-removed"
      key == :owner ? text.gsub("空状态不是“没有数据”的单一文案", "") : text
    when "reason-taxonomy-removed"
      key == :owner ? text.gsub("必须区分 firstRunEmpty、trueEmpty、zeroResults、permissionEmpty、errorEmpty、loadingEmpty、archivedEmpty、notConfiguredEmpty 和 readOnlyEmpty", "") : text
    when "zero-results-recovery-removed"
      key == :owner ? text.gsub("zeroResults 的主恢复通常是清空筛选、调整关键词、重置时间范围或返回默认视图", "") : text
    when "create-cta-guard-removed"
      key == :owner ? text.gsub("创建入口不得出现在只读报表、权限不足、能力未启用、租户/工作区不可写、对象类型不可创建或筛选无结果但真实数据范围未知的场景", "") : text
    when "clear-reset-distinction-removed"
      key == :owner ? text.gsub("清空筛选和重置筛选不是同一件事", "") : text
    when "permission-empty-boundary-removed"
      key == :owner ? text.gsub("权限不可见不等于没有数据", "") : text
    when "permission-leak-removed"
      key == :owner ? text.gsub("无权限时不得泄露对象名称、数量、字段、筛选值、状态分布、归档数量、文件名、成员、金额、内部 ID、错误明细、旧搜索结果或旧可访问名称", "") : text
    when "runtime-boundary-marked-verified"
      key == :owner ? text.gsub("未验证", "已验证") : text
    when "missing-skill-route"
      key == :skill ? text.gsub("references/empty-first-run-zero-results.md", "") : text
    when "missing-readme-link"
      key == :readme ? text.gsub("references/empty-first-run-zero-results.md", "") : text
    when "missing-handoff-section"
      key == :handoff ? text.gsub("### 空态、无结果与首次使用引导", "### 空态占位") : text
    when "project-leak"
      key == :owner ? "#{text}\nfex-admin\n" : text
    else
      text
    end
  end

  yield
ensure
  define_singleton_method(:read_file, original_read)
end

if ARGV.include?("--mutations")
  mutations = %w[
    missing-owner-state
    single-no-data-boundary-removed
    reason-taxonomy-removed
    zero-results-recovery-removed
    create-cta-guard-removed
    clear-reset-distinction-removed
    permission-empty-boundary-removed
    permission-leak-removed
    runtime-boundary-marked-verified
    missing-skill-route
    missing-readme-link
    missing-handoff-section
    project-leak
  ]

  mutations.each do |mutation|
    begin
      with_mutation(mutation) { run_audit }
    rescue SystemExit => e
      raise if e.success?
      next
    end

    abort("Mutation survived: #{mutation}")
  end

  puts "PASS: mutation checks failed as expected."
else
  run_audit
end

