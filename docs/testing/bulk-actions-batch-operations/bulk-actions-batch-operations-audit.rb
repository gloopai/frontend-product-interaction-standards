#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)

FILES = {
  owner: "references/bulk-actions-batch-operations.md",
  data_tables: "references/data-tables.md",
  card_list: "references/card-list-results.md",
  risk: "references/risk-actions.md",
  feedback: "references/feedback-states.md",
  buttons: "references/buttons.md",
  approvals: "references/approval-workflows.md",
  exports: "references/exports-downloads-artifacts.md",
  permissions: "references/permissions-tenancy-visibility.md",
  skill: "SKILL.md",
  readme: "README.md",
  handoff: "HANDOFF.md",
  green: "docs/testing/bulk-actions-batch-operations/green-summary.md",
  red: "docs/testing/bulk-actions-batch-operations/red-summary.md"
}.freeze

STATE_FIELDS = %w[
  bulkActionOwnerId
  bulkSurface
  actionKind
  selectionSnapshot
  scopeBinding
  targetIdentitySet
  eligibilityMap
  excludedTargetSet
  impactSummary
  confirmationPolicy
  requestIdentity
  executionPhase
  partialResult
  resultReceipt
  recoveryActions
  permissionBoundary
  feedbackBinding
  responsivePolicy
  focusAnnouncementPolicy
  lifecycleDisposal
  runtimeVerification
].freeze

OWNER_TERMS = [
  "bulkActionState",
  "批量操作不是“对当前可见行循环单条操作”，也不是“选择数量 + 一个按钮”",
  "批量操作必须冻结 selectionSnapshot、scopeBinding、targetIdentitySet、eligibilityMap、permissionBoundary 和 requestIdentity",
  "当前页、已选择项、全部筛选结果、跨页集合和排除项集合必须用不同 scopeBinding 表达",
  "筛选、搜索、排序、分页、权限、租户/工作区、数据版本或 eligibility 变化后，旧批量意图必须失效、刷新或重新确认",
  "部分成功必须区分成功、失败、跳过、冲突、未知和处理中对象范围",
  "批量结果不得只用 Toast 表达；必须有 resultReceipt、partialResult 和 recoveryActions",
  "无权限或权限降级不得泄露旧目标名称、数量、字段、失败明细、导出范围、内部 ID 或旧回执",
  "未验证"
].freeze

ADJACENT_TERMS = [
  "references/bulk-actions-batch-operations.md",
  "bulkActionState"
].freeze

README_TERMS = [
  "批量操作与批处理动作规范",
  "references/bulk-actions-batch-operations.md"
].freeze

HANDOFF_TERMS = [
  "### 批量操作与批处理动作",
  "bulkActionState",
  "批量操作不是“对当前可见行循环单条操作”",
  "partialResult",
  "references/bulk-actions-batch-operations.md"
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
  marker = "### 批量操作与批处理动作"
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

  %i[data_tables card_list risk feedback buttons approvals exports permissions].each do |key|
    text = read_file(key)
    ADJACENT_TERMS.each { |term| assert_includes!(text, term, FILES.fetch(key)) }
  end

  skill = read_file(:skill)
  %w[批量操作 批处理动作 bulk action apply to all filtered references/bulk-actions-batch-operations.md].each do |term|
    assert_includes!(skill, term, "SKILL route")
  end

  readme = read_file(:readme)
  README_TERMS.each { |term| assert_includes!(readme, term, "README") }

  handoff = handoff_section(read_file(:handoff))
  HANDOFF_TERMS.each { |term| assert_includes!(handoff, term, "HANDOFF") }

  %i[owner green red readme].each do |key|
    assert_not_includes!(read_file(key), LEAK_PATTERN, FILES.fetch(key))
  end
  assert_not_includes!(handoff, LEAK_PATTERN, "HANDOFF bulk section")

  puts "PASS: 批量操作与批处理动作 owner、路由和证据符合结构化审计契约。"
end

def with_mutation(name)
  mutated = false
  original_read = method(:read_file)

  define_singleton_method(:read_file) do |key|
    text = original_read.call(key)
    case name
    when "missing-owner-state"
      key == :owner ? text.gsub("bulkActionState", "removed bulk action state") : text
    when "visible-row-loop-boundary-removed"
      key == :owner ? text.gsub("批量操作不是“对当前可见行循环单条操作”，也不是“选择数量 + 一个按钮”", "") : text
    when "frozen-snapshot-removed"
      key == :owner ? text.gsub("批量操作必须冻结 selectionSnapshot、scopeBinding、targetIdentitySet、eligibilityMap、permissionBoundary 和 requestIdentity", "") : text
    when "scope-binding-removed"
      key == :owner ? text.gsub("当前页、已选择项、全部筛选结果、跨页集合和排除项集合必须用不同 scopeBinding 表达", "") : text
    when "invalidation-removed"
      key == :owner ? text.gsub("筛选、搜索、排序、分页、权限、租户/工作区、数据版本或 eligibility 变化后，旧批量意图必须失效、刷新或重新确认", "") : text
    when "partial-result-removed"
      key == :owner ? text.gsub("部分成功必须区分成功、失败、跳过、冲突、未知和处理中对象范围", "") : text
    when "toast-only-result-removed"
      key == :owner ? text.gsub("批量结果不得只用 Toast 表达；必须有 resultReceipt、partialResult 和 recoveryActions", "") : text
    when "permission-leak-removed"
      key == :owner ? text.gsub("无权限或权限降级不得泄露旧目标名称、数量、字段、失败明细、导出范围、内部 ID 或旧回执", "") : text
    when "runtime-boundary-marked-verified"
      key == :owner ? text.gsub("未验证", "已验证") : text
    when "missing-skill-route"
      key == :skill ? text.gsub("references/bulk-actions-batch-operations.md", "") : text
    when "missing-readme-link"
      key == :readme ? text.gsub("references/bulk-actions-batch-operations.md", "") : text
    when "missing-handoff-section"
      key == :handoff ? text.gsub("### 批量操作与批处理动作", "### 批处理占位") : text
    when "project-leak"
      mutated = true
      key == :owner ? "#{text}\nfex-admin\n" : text
    else
      text
    end
  end

  yield
ensure
  define_singleton_method(:read_file, original_read)
  abort("Mutation #{name} did not execute") if name == "project-leak" && !mutated
end

if ARGV.include?("--mutations")
  mutations = %w[
    missing-owner-state
    visible-row-loop-boundary-removed
    frozen-snapshot-removed
    scope-binding-removed
    invalidation-removed
    partial-result-removed
    toast-only-result-removed
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
