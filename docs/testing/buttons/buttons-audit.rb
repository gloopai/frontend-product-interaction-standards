#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

ROOT = File.expand_path('../../..', __dir__)
OWNER = File.join(ROOT, 'references/buttons.md')
SKILL = File.join(ROOT, 'SKILL.md')
README = File.join(ROOT, 'README.md')
HANDOFF = File.join(ROOT, 'HANDOFF.md')
DEFAULT_OUTPUTS = [
  'docs/testing/buttons/green-business-buttons.md'
].map { |path| File.join(ROOT, path) }.freeze

RULE_IDS = %w[
  BTN-SCOPE-01 BTN-SCOPE-02 BTN-SCOPE-03
  BTN-LABEL-01 BTN-LABEL-02 BTN-LABEL-03
  BTN-HIER-01 BTN-HIER-02
  BTN-STATE-01 BTN-STATE-02
  BTN-ASYNC-01 BTN-ASYNC-02
  BTN-DANGER-01 BTN-DANGER-02
  BTN-PERM-01 BTN-PERM-02
  BTN-GROUP-01 BTN-GROUP-02
  BTN-A11Y-01 BTN-A11Y-02
  BTN-RSP-01 BTN-RSP-02
].freeze

STATE_FIELDS = %w[
  buttonId actionKind hierarchy availability disabledReasonOwner asyncPhase requestIdentity resultOwner accessibleName
].freeze

NEGATIVE_CASES = %w[
  div-fake-button icon-button-no-accessible-name loading-spinner-only two-primary-buttons-one-task
  danger-color-only disabled-reason-tooltip-only bulk-action-no-selection-snapshot
  cancel-sent-task-as-client-only mobile-core-action-removed
].freeze

CONTRACT_PATTERN = /<!-- buttons-audit:start -->\s*```json\s*(.*?)\s*```\s*<!-- buttons-audit:end -->/m

def extract_contract(text)
  match = text.match(CONTRACT_PATTERN)
  raise JSON::ParserError, '缺少 buttons-audit JSON 契约区块' unless match

  JSON.parse(match[1])
end

def replace_contract(text, contract)
  replacement = "<!-- buttons-audit:start -->\n```json\n#{JSON.pretty_generate(contract)}\n```\n<!-- buttons-audit:end -->"
  text.sub(CONTRACT_PATTERN, replacement)
end

def owner_failures
  failures = []
  owner = File.exist?(OWNER) ? File.read(OWNER, encoding: 'UTF-8') : ''
  skill = File.exist?(SKILL) ? File.read(SKILL, encoding: 'UTF-8') : ''
  readme = File.exist?(README) ? File.read(README, encoding: 'UTF-8') : ''
  handoff = File.exist?(HANDOFF) ? File.read(HANDOFF, encoding: 'UTF-8') : ''

  failures << '缺少按钮 owner：references/buttons.md' if owner.empty?
  RULE_IDS.each { |id| failures << "owner 缺少规则 ID #{id}" unless owner.include?(id) }
  STATE_FIELDS.each { |field| failures << "owner 缺少 buttonActionState 字段 #{field}" unless owner.include?(field) }
  %w[原生 `<button>` 图标按钮 loading 危险 权限 tooltip buttonActionState].each do |term|
    failures << "owner 缺少按钮关键术语 #{term}" unless owner.include?(term)
  end
  %w[按钮 图标按钮 保存按钮 删除按钮 loading\ 按钮 button group references/buttons.md].each do |term|
    failures << "SKILL 路由缺少 #{term}" unless skill.include?(term)
  end
  failures << 'README 缺少按钮摘要' unless readme.include?('按钮规范首版')
  failures << 'README 缺少按钮链接' unless readme.include?('references/buttons.md')
  failures << 'HANDOFF 缺少按钮交接' unless handoff.include?('### 按钮')
  failures
end

def contract_failures(path, contract, text)
  failures = []
  failures << "#{path}: schemaVersion 必须为 1" unless contract['schemaVersion'] == 1
  %w[
    buttonOwnerApplied nativeButtonRequired fakeButtonForbidden iconButtonAccessibleNameRequired loadingNamePreserved
    singlePrimaryPerTaskArea tooltipOnlyDisabledReasonForbidden dangerRequiresConfirmationAndReceipt
    bulkButtonRequiresSnapshotAndPermission sentTaskCancelNotClientOnly mobileCoreActionsReachable
  ].each do |key|
    failures << "#{path}: #{key} 必须为 true" unless contract[key] == true
  end
  STATE_FIELDS.each { |field| failures << "#{path}: buttonActionState 缺少 #{field}" unless contract.dig('buttonActionState', field) == true }
  %w[forms dialogs drawers data-tables admin-console record-editing-surfaces responsive-adaptive].each do |owner|
    failures << "#{path}: 未应用组件 owner #{owner}" unless contract.dig('componentOwners', owner) == true
  end
  NEGATIVE_CASES.each { |name| failures << "#{path}: 缺少负向用例 #{name}" unless Array(contract['negativeCases']).include?(name) }
  %w[browser screenReader touch realComponent].each do |environment|
    failures << "#{path}: #{environment} 必须明确为未验证" unless contract.dig('runtimeVerification', environment) == false
  end
  %w[buttonActionState requestIdentity resultOwner 运行时验证边界].each do |term|
    failures << "#{path}: 正文缺少 #{term}" unless text.include?(term)
  end
  failures
end

def output_failures(path, text)
  contract_failures(path, extract_contract(text), text)
rescue JSON::ParserError => e
  ["#{path}: JSON 审计契约无效：#{e.message}"]
end

def audit(outputs)
  failures = owner_failures
  outputs.each do |path|
    unless File.file?(path)
      failures << "缺少 GREEN 应用输出：#{path}"
      next
    end
    failures.concat(output_failures(path, File.read(path, encoding: 'UTF-8')))
  end
  failures
end

def contract_control(name, source)
  text = File.read(source, encoding: 'UTF-8')
  contract = extract_contract(text)
  yield(contract)
  failures = output_failures(source, replace_contract(text, contract))
  if failures.empty?
    puts "UNEXPECTED_PASS: #{name}"
    false
  else
    puts "EXPECTED_FAIL: #{name}"
    true
  end
end

mutations = ARGV.delete('--mutations')
outputs = ARGV.empty? ? DEFAULT_OUTPUTS : ARGV.map { |path| File.expand_path(path) }
failures = audit(outputs)
unless failures.empty?
  puts "FAIL: #{failures.length} 项"
  failures.each { |failure| puts "- #{failure}" }
  exit 1
end
puts 'PASS: Button owner 与 GREEN 应用输出符合结构化审计契约。'

if mutations
  source = DEFAULT_OUTPUTS.first
  checks = [
    ['fake-button-allowed', ->(c) { c['fakeButtonForbidden'] = false }],
    ['icon-name-missing', ->(c) { c['iconButtonAccessibleNameRequired'] = false }],
    ['loading-name-lost', ->(c) { c['loadingNamePreserved'] = false }],
    ['multiple-primary-allowed', ->(c) { c['singlePrimaryPerTaskArea'] = false }],
    ['tooltip-only-disabled-reason', ->(c) { c['tooltipOnlyDisabledReasonForbidden'] = false }],
    ['danger-receipt-missing', ->(c) { c['dangerRequiresConfirmationAndReceipt'] = false }],
    ['bulk-snapshot-missing', ->(c) { c['bulkButtonRequiresSnapshotAndPermission'] = false }],
    ['sent-task-client-cancel', ->(c) { c['sentTaskCancelNotClientOnly'] = false }],
    ['mobile-core-action-removed', ->(c) { c['mobileCoreActionsReachable'] = false }],
    ['runtime-browser-marked-verified', ->(c) { c['runtimeVerification']['browser'] = true }]
  ]
  all_expected = checks.all? { |name, mutation| contract_control(name, source, &mutation) }
  exit(all_expected ? 0 : 1)
end

