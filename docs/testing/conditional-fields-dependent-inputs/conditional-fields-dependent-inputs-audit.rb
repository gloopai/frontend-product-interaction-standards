#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)

FILES = {
  owner: "references/conditional-fields-dependent-inputs.md",
  forms: "references/forms.md",
  field_guidance: "references/field-guidance-help-text.md",
  selects: "references/selects-comboboxes.md",
  multi_select: "references/multi-select-tag-inputs.md",
  query_filters: "references/query-filters.md",
  settings: "references/settings-preferences-configuration.md",
  permissions: "references/permissions-tenancy-visibility.md",
  tree: "references/tree-hierarchy.md",
  skill: "SKILL.md",
  readme: "README.md",
  handoff: "HANDOFF.md",
  green: "docs/testing/conditional-fields-dependent-inputs/green-summary.md",
  red: "docs/testing/conditional-fields-dependent-inputs/red-summary.md"
}.freeze

STATE_FIELDS = %w[
  dependencyOwnerId
  dependencySurface
  dependencyGraph
  upstreamSnapshot
  downstreamPolicy
  visibilityPolicy
  requirementPolicy
  valueRetentionPolicy
  validationPolicy
  candidatePolicy
  derivedValuePolicy
  submitSnapshotPolicy
  permissionBoundary
  feedbackBinding
  responsivePolicy
  focusAnnouncementPolicy
  lifecycleDisposal
  runtimeVerification
].freeze

OWNER_TERMS = [
  "fieldDependencyState",
  "字段联动不是 `if value then show field` 的临时 UI 逻辑",
  "hidden-by-condition、hidden-by-permission、disabled-by-condition、disabled-by-permission、read-only 和 not-applicable 不是同一件事",
  "上游字段变化后，所有受影响下游字段必须按 `downstreamPolicy` 原子进入保留、清空、失效、重算、禁用、只读或隐藏状态",
  "隐藏字段的旧值不得静默提交",
  "级联 Select、远程候选和异步校验必须绑定 `upstreamSnapshot`、权限版本、租户/工作区和请求代次",
  "条件必填必须在字段 label、帮助文本、错误摘要和提交前校验中一致表达",
  "自动填充、派生值、默认值、继承值和用户输入必须在状态中可区分",
  "无权限时不得泄露字段名称、字段值、候选项、字段数量、条件表达式、默认值、继承来源、错误原因、内部 ID、上游对象、下游对象或旧可访问名称",
  "未验证"
].freeze

ADJACENT_TERMS = [
  "references/conditional-fields-dependent-inputs.md",
  "fieldDependencyState"
].freeze

README_TERMS = [
  "条件字段与依赖输入规范",
  "references/conditional-fields-dependent-inputs.md"
].freeze

HANDOFF_TERMS = [
  "### 条件字段与依赖输入",
  "fieldDependencyState",
  "字段联动不是 `if value then show field` 的临时 UI 逻辑",
  "隐藏字段的旧值不得静默提交",
  "references/conditional-fields-dependent-inputs.md"
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
  marker = "### 条件字段与依赖输入"
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

  %i[forms field_guidance selects multi_select query_filters settings permissions tree].each do |key|
    text = read_file(key)
    ADJACENT_TERMS.each { |term| assert_includes!(text, term, FILES.fetch(key)) }
  end

  skill = read_file(:skill)
  ["条件字段", "依赖字段", "字段联动", "条件显示", "条件必填", "dependent field", "conditional field", "references/conditional-fields-dependent-inputs.md"].each do |term|
    assert_includes!(skill, term, "SKILL route")
  end

  readme = read_file(:readme)
  README_TERMS.each { |term| assert_includes!(readme, term, "README") }

  handoff = handoff_section(read_file(:handoff))
  HANDOFF_TERMS.each { |term| assert_includes!(handoff, term, "HANDOFF") }

  %i[owner green red readme].each do |key|
    assert_not_includes!(read_file(key), LEAK_PATTERN, FILES.fetch(key))
  end
  assert_not_includes!(handoff, LEAK_PATTERN, "HANDOFF conditional section")

  puts "PASS: 条件字段与依赖输入 owner、路由和证据符合结构化审计契约。"
end

def with_mutation(name)
  original_read = method(:read_file)

  define_singleton_method(:read_file) do |key|
    text = original_read.call(key)
    case name
    when "missing-owner-state"
      key == :owner ? text.gsub("fieldDependencyState", "removed dependency state") : text
    when "ui-if-boundary-removed"
      key == :owner ? text.gsub("字段联动不是 `if value then show field` 的临时 UI 逻辑", "") : text
    when "visibility-distinction-removed"
      key == :owner ? text.gsub("hidden-by-condition、hidden-by-permission、disabled-by-condition、disabled-by-permission、read-only 和 not-applicable 不是同一件事", "") : text
    when "downstream-policy-removed"
      key == :owner ? text.gsub("上游字段变化后，所有受影响下游字段必须按 `downstreamPolicy` 原子进入保留、清空、失效、重算、禁用、只读或隐藏状态", "") : text
    when "hidden-submit-removed"
      key == :owner ? text.gsub("隐藏字段的旧值不得静默提交", "") : text
    when "candidate-snapshot-removed"
      key == :owner ? text.gsub("级联 Select、远程候选和异步校验必须绑定 `upstreamSnapshot`、权限版本、租户/工作区和请求代次", "") : text
    when "required-consistency-removed"
      key == :owner ? text.gsub("条件必填必须在字段 label、帮助文本、错误摘要和提交前校验中一致表达", "") : text
    when "derived-value-removed"
      key == :owner ? text.gsub("自动填充、派生值、默认值、继承值和用户输入必须在状态中可区分", "") : text
    when "permission-leak-removed"
      key == :owner ? text.gsub("无权限时不得泄露字段名称、字段值、候选项、字段数量、条件表达式、默认值、继承来源、错误原因、内部 ID、上游对象、下游对象或旧可访问名称", "") : text
    when "runtime-boundary-marked-verified"
      key == :owner ? text.gsub("未验证", "已验证") : text
    when "missing-skill-route"
      key == :skill ? text.gsub("references/conditional-fields-dependent-inputs.md", "") : text
    when "missing-readme-link"
      key == :readme ? text.gsub("references/conditional-fields-dependent-inputs.md", "") : text
    when "missing-handoff-section"
      key == :handoff ? text.gsub("### 条件字段与依赖输入", "### 条件字段占位") : text
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
    ui-if-boundary-removed
    visibility-distinction-removed
    downstream-policy-removed
    hidden-submit-removed
    candidate-snapshot-removed
    required-consistency-removed
    derived-value-removed
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

