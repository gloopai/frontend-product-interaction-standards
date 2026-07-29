#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)

FILES = {
  owner: "references/row-contextual-actions.md",
  data_tables: "references/data-tables.md",
  card_list: "references/card-list-results.md",
  buttons: "references/buttons.md",
  overlays: "references/overlays-menus-tooltips.md",
  permissions: "references/permissions-tenancy-visibility.md",
  risk: "references/risk-actions.md",
  editing: "references/record-editing-surfaces.md",
  preview: "references/preview-pane.md",
  lifecycle: "references/status-lifecycle-transitions.md",
  skill: "SKILL.md",
  readme: "README.md",
  handoff: "HANDOFF.md",
  green: "docs/testing/row-contextual-actions/green-summary.md",
  red: "docs/testing/row-contextual-actions/red-summary.md"
}.freeze

STATE_FIELDS = %w[
  rowActionOwnerId
  actionSurface
  recordIdentity
  sourceSnapshot
  actionCatalog
  availabilityMap
  disabledReasonPolicy
  triggerPolicy
  requestIdentity
  resultReceipt
  riskHandoff
  editSurfaceHandoff
  navigationBinding
  permissionBoundary
  feedbackBinding
  responsivePolicy
  focusAnnouncementPolicy
  lifecycleDisposal
  runtimeVerification
].freeze

OWNER_TERMS = [
  "rowActionState",
  "行操作不是“在当前行 DOM 上挂一个按钮”",
  "不得在请求发送时重新读取当前 hover row、当前 active row、虚拟列表 DOM、菜单闭包里的旧 record 或 rowIndex",
  "虚拟行复用不得让旧菜单项操作新记录",
  "visible、hidden-by-permission、disabled-by-state、disabled-by-permission、read-only 和 not-applicable 不是同一件事",
  "更多菜单可以收纳低频动作，但不能隐藏唯一的危险确认、权限原因、错误恢复或核心任务入口",
  "Toast 不能作为唯一结果回执、唯一错误说明、唯一审计凭证或唯一恢复入口",
  "无权限或权限降级不得泄露记录名称、字段值、状态、动作数量、菜单项、禁用原因、文件名、错误明细、审计摘要、内部 ID、旧 aria-label、旧 tooltip 或旧菜单缓存",
  "未验证"
].freeze

ADJACENT_TERMS = [
  "references/row-contextual-actions.md",
  "rowActionState"
].freeze

README_TERMS = [
  "行操作与上下文操作规范",
  "references/row-contextual-actions.md"
].freeze

HANDOFF_TERMS = [
  "### 行操作与上下文操作",
  "rowActionState",
  "行操作不是“在当前行 DOM 上挂一个按钮”",
  "虚拟行复用",
  "references/row-contextual-actions.md"
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
  marker = "### 行操作与上下文操作"
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

  %i[data_tables card_list buttons overlays permissions risk editing preview lifecycle].each do |key|
    text = read_file(key)
    ADJACENT_TERMS.each { |term| assert_includes!(text, term, FILES.fetch(key)) }
  end

  skill = read_file(:skill)
  ["行操作", "记录操作", "上下文操作", "更多操作", "row action", "contextual action", "context menu", "references/row-contextual-actions.md"].each do |term|
    assert_includes!(skill, term, "SKILL route")
  end

  readme = read_file(:readme)
  README_TERMS.each { |term| assert_includes!(readme, term, "README") }

  handoff = handoff_section(read_file(:handoff))
  HANDOFF_TERMS.each { |term| assert_includes!(handoff, term, "HANDOFF") }

  %i[owner green red readme].each do |key|
    assert_not_includes!(read_file(key), LEAK_PATTERN, FILES.fetch(key))
  end
  assert_not_includes!(handoff, LEAK_PATTERN, "HANDOFF row action section")

  puts "PASS: 行操作与上下文操作 owner、路由和证据符合结构化审计契约。"
end

def with_mutation(name)
  original_read = method(:read_file)

  define_singleton_method(:read_file) do |key|
    text = original_read.call(key)
    case name
    when "missing-owner-state"
      key == :owner ? text.gsub("rowActionState", "removed row action state") : text
    when "dom-button-boundary-removed"
      key == :owner ? text.gsub("行操作不是“在当前行 DOM 上挂一个按钮”", "") : text
    when "stale-row-source-removed"
      key == :owner ? text.gsub("不得在请求发送时重新读取当前 hover row、当前 active row、虚拟列表 DOM、菜单闭包里的旧 record 或 rowIndex", "") : text
    when "virtual-row-removed"
      key == :owner ? text.gsub("虚拟行复用不得让旧菜单项操作新记录", "") : text
    when "availability-distinction-removed"
      key == :owner ? text.gsub("visible、hidden-by-permission、disabled-by-state、disabled-by-permission、read-only 和 not-applicable 不是同一件事", "") : text
    when "menu-boundary-removed"
      key == :owner ? text.gsub("更多菜单可以收纳低频动作，但不能隐藏唯一的危险确认、权限原因、错误恢复或核心任务入口", "") : text
    when "toast-boundary-removed"
      key == :owner ? text.gsub("Toast 不能作为唯一结果回执、唯一错误说明、唯一审计凭证或唯一恢复入口", "") : text
    when "permission-leak-removed"
      key == :owner ? text.gsub("无权限或权限降级不得泄露记录名称、字段值、状态、动作数量、菜单项、禁用原因、文件名、错误明细、审计摘要、内部 ID、旧 aria-label、旧 tooltip 或旧菜单缓存", "") : text
    when "runtime-boundary-marked-verified"
      key == :owner ? text.gsub("未验证", "已验证") : text
    when "missing-skill-route"
      key == :skill ? text.gsub("references/row-contextual-actions.md", "") : text
    when "missing-readme-link"
      key == :readme ? text.gsub("references/row-contextual-actions.md", "") : text
    when "missing-handoff-section"
      key == :handoff ? text.gsub("### 行操作与上下文操作", "### 行操作占位") : text
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
    dom-button-boundary-removed
    stale-row-source-removed
    virtual-row-removed
    availability-distinction-removed
    menu-boundary-removed
    toast-boundary-removed
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

