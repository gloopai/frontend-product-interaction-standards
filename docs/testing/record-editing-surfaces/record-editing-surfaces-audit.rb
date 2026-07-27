#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

ROOT = File.expand_path('../../..', __dir__)
OWNER = File.join(ROOT, 'references/record-editing-surfaces.md')
SKILL = File.join(ROOT, 'SKILL.md')
README = File.join(ROOT, 'README.md')
HANDOFF = File.join(ROOT, 'HANDOFF.md')
DEFAULT_OUTPUTS = [
  'docs/testing/record-editing-surfaces/green-record-editor.md'
].map { |path| File.join(ROOT, path) }.freeze

RULE_IDS = %w[
  RES-SCOPE-01 RES-SCOPE-02 RES-SCOPE-03 RES-SCOPE-04 RES-SCOPE-05 RES-SCOPE-06 RES-SCOPE-07
  RES-CHOICE-01 RES-CHOICE-02 RES-CHOICE-03 RES-CHOICE-04
  RES-LIST-01 RES-LIST-02 RES-LIST-03 RES-LIST-04 RES-LIST-05 RES-LIST-06
  RES-FORM-01 RES-FORM-02 RES-FORM-03 RES-FORM-04
  RES-AUDIT-01 RES-AUDIT-02 RES-AUDIT-03 RES-AUDIT-04
  RES-RSP-01 RES-RSP-02 RES-RSP-03
].freeze

FORBIDDEN_TERMS = %w[
  常驻可编辑列表 表格编辑矩阵 单元格编辑 spreadsheet-like input textarea select combobox 排序输入 每行“保存”按钮
].freeze

STATE_FIELDS = %w[
  surfaceId mode surfaceType sourceListSnapshot recordIdentity permissionVersion formSessionId returnStrategy runtimeVerification
].freeze

SURFACE_TYPES = %w[dialog drawer page].freeze
CONTRACT_PATTERN = /<!-- record-editing-surfaces-audit:start -->\s*```json\s*(.*?)\s*```\s*<!-- record-editing-surfaces-audit:end -->/m

def extract_contract(text)
  match = text.match(CONTRACT_PATTERN)
  raise JSON::ParserError, '缺少 record-editing-surfaces-audit JSON 契约区块' unless match

  JSON.parse(match[1])
end

def replace_contract(text, contract)
  replacement = "<!-- record-editing-surfaces-audit:start -->\n```json\n#{JSON.pretty_generate(contract)}\n```\n<!-- record-editing-surfaces-audit:end -->"
  text.sub(CONTRACT_PATTERN, replacement)
end

def owner_failures
  failures = []
  owner = File.exist?(OWNER) ? File.read(OWNER, encoding: 'UTF-8') : ''
  skill = File.exist?(SKILL) ? File.read(SKILL, encoding: 'UTF-8') : ''
  readme = File.exist?(README) ? File.read(README, encoding: 'UTF-8') : ''
  handoff = File.exist?(HANDOFF) ? File.read(HANDOFF, encoding: 'UTF-8') : ''

  failures << '缺少记录编辑承载面 owner：references/record-editing-surfaces.md' if owner.empty?
  RULE_IDS.each { |id| failures << "owner 缺少规则 ID #{id}" unless owner.include?(id) }
  STATE_FIELDS.each { |field| failures << "owner 缺少 editSurfaceState 字段 #{field}" unless owner.include?(field) }
  FORBIDDEN_TERMS.each { |term| failures << "owner 缺少禁止项 #{term}" unless owner.include?(term) }
  %w[Dialog Drawer 独立页 forms.md dialogs.md drawers.md data-tables.md responsive-adaptive.md admin-console.md].each do |term|
    failures << "owner 缺少关联 owner #{term}" unless owner.include?(term)
  end

  %w[记录编辑承载面 新增记录 编辑记录 列表内编辑 行内编辑 内嵌表单].each do |term|
    failures << "SKILL 路由缺少 #{term}" unless skill.include?(term)
  end
  failures << 'README 缺少记录编辑承载面摘要' unless readme.include?('记录新增/编辑承载面')
  failures << 'README 缺少 owner 链接' unless readme.include?('references/record-editing-surfaces.md')
  failures << 'HANDOFF 缺少记录编辑承载面交接' unless handoff.include?('记录新增/编辑承载面')

  failures
end

def contract_failures(path, contract, text)
  failures = []
  failures << "#{path}: schemaVersion 必须为 1" unless contract['schemaVersion'] == 1
  failures << "#{path}: 必须声明 recordEditingSurface 适用" unless contract['recordEditingSurface'] == true
  failures << "#{path}: 必须禁止列表内编辑" unless contract['inlineEditingForbidden'] == true
  failures << "#{path}: 必须禁止常驻可编辑列表" unless contract['persistentEditableListForbidden'] == true
  failures << "#{path}: 必须禁止每行保存按钮" unless contract['rowSaveButtonsForbidden'] == true
  failures << "#{path}: 必须禁止单元格字段控件" unless contract['cellFieldControlsForbidden'] == true
  failures << "#{path}: 必须声明列表行只读" unless contract['listRowsReadOnly'] == true
  failures << "#{path}: 必须按 page/drawer/dialog 顺序选择" unless contract['choiceOrder'] == %w[page drawer dialog]
  failures << "#{path}: 缺少合法承载面" unless SURFACE_TYPES.include?(contract.dig('editSurfaceState', 'surfaceType'))
  STATE_FIELDS.each { |field| failures << "#{path}: editSurfaceState 缺少 #{field}" unless contract.dig('editSurfaceState', field) == true || contract.dig('editSurfaceState', field).is_a?(String) }
  %w[forms dialogs drawers data-tables responsive-adaptive admin-console].each do |owner|
    failures << "#{path}: 未应用组件 owner #{owner}" unless contract.dig('componentOwners', owner) == true
  end
  %w[permission dataVersion recordVisibility focusTarget].each do |check|
    failures << "#{path}: 返回列表缺少复核 #{check}" unless Array(contract['returnRevalidation']).include?(check)
  end
  %w[expanded-row-form inline-cell-input row-save-button editable-sort-input report-auto-edit-action].each do |mutation|
    failures << "#{path}: 缺少负向用例 #{mutation}" unless Array(contract['negativeCases']).include?(mutation)
  end
  %w[browser screenReader touch realComponent].each do |environment|
    failures << "#{path}: #{environment} 必须明确为未验证" unless contract.dig('runtimeVerification', environment) == false
  end
  %w[editSurfaceState sourceListSnapshot returnStrategy 运行时验证边界].each do |term|
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
puts 'PASS: 记录编辑承载面 owner 与 GREEN 应用输出符合结构化审计契约。'

if mutations
  source = DEFAULT_OUTPUTS.first
  checks = [
    ['inline-editing-allowed', ->(c) { c['inlineEditingForbidden'] = false }],
    ['persistent-editable-list-allowed', ->(c) { c['persistentEditableListForbidden'] = false }],
    ['row-save-buttons-allowed', ->(c) { c['rowSaveButtonsForbidden'] = false }],
    ['cell-field-controls-allowed', ->(c) { c['cellFieldControlsForbidden'] = false }],
    ['list-rows-not-readonly', ->(c) { c['listRowsReadOnly'] = false }],
    ['wrong-choice-order', ->(c) { c['choiceOrder'] = %w[dialog drawer page] }],
    ['missing-source-list-snapshot', ->(c) { c['editSurfaceState'].delete('sourceListSnapshot') }],
    ['missing-permission-return-check', ->(c) { c['returnRevalidation'].delete('permission') }],
    ['missing-row-save-negative-case', ->(c) { c['negativeCases'].delete('row-save-button') }],
    ['runtime-browser-marked-verified', ->(c) { c['runtimeVerification']['browser'] = true }]
  ]

  all_expected = checks.all? { |name, mutation| contract_control(name, source, &mutation) }
  exit(all_expected ? 0 : 1)
end

