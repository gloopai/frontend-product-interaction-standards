#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

ROOT = File.expand_path('../../..', __dir__)
OWNER = File.join(ROOT, 'references/form-layout-field-groups.md')
SKILL = File.join(ROOT, 'SKILL.md')
README = File.join(ROOT, 'README.md')
HANDOFF = File.join(ROOT, 'HANDOFF.md')
GREEN = File.join(ROOT, 'docs/testing/form-layout-field-groups/green-summary.md')

CONTRACT_PATTERN = /<!-- form-layout-field-groups-audit:start -->\s*```json\s*(.*?)\s*```\s*<!-- form-layout-field-groups-audit:end -->/m

STATE_FIELDS = %w[
  formLayoutOwnerId layoutSurface fieldRegistry groupRegistry layoutMode breakpointPolicy fieldOrder
  alignmentPolicy spanPolicy densityPolicy overflowPolicy errorPlacementPolicy loadingPlaceholderPolicy
  conditionalLayoutBinding actionBarAvoidance responsivePolicy focusRestorationPolicy lifecycleDisposal
  runtimeVerification
].freeze

RULE_IDS = %w[
  FLG-SCOPE-01 FLG-ORDER-01 FLG-GROUP-01 FLG-LABEL-01 FLG-GRID-01 FLG-GRID-02
  FLG-SPAN-01 FLG-ERROR-01 FLG-DYNAMIC-01 FLG-LOADING-01 FLG-RSP-01 FLG-RSP-02
  FLG-A11Y-01 FLG-VERIFY-01
].freeze

OWNER_TERMS = [
  '本 owner 只负责表单 UI 布局与交互排列',
  '不得只用 CSS Grid',
  '视觉顺序、DOM 顺序、Tab 顺序和读屏顺序',
  '字段组必须有可见标题或等价语义',
  '不得用占位符、tooltip-only 或相邻文本替代字段 label',
  '两列/三列表单不得让跨列字段、长错误、长帮助或组合字段挤压相邻字段',
  '移动端必须转为单列或等价分组',
  'sticky/fixed footer 不得遮挡错误',
  '未执行必须标为未验证'
].freeze

ROUTE_TERMS = [
  '表单布局',
  '字段布局',
  '字段分组',
  '两列表单',
  '三列表单',
  '表单栅格',
  'label 对齐',
  '移动端表单布局',
  'form layout',
  'form grid',
  'field group',
  'two-column form',
  'responsive form',
  'references/form-layout-field-groups.md'
].freeze

ADJACENT_FILES = %w[
  references/forms.md
  references/field-guidance-help-text.md
  references/dialogs.md
  references/drawers.md
  references/page-content-layout-sections.md
  references/page-form-action-bars.md
  references/responsive-adaptive.md
  references/text-overflow-truncation.md
].freeze

PROJECT_LEAK_PATTERNS = [
  /fex-admin/i,
  %r{/Users/evanqi/code/},
  %r{src/pages},
  /Ant Design/i,
  /ant-design/i,
  /shadcn/i,
  /Next\.js/i,
  /Vite/i,
  /\bReact\b/i,
  /\bVue\b/i
].freeze

def read(path)
  File.file?(path) ? File.read(path, encoding: 'UTF-8') : ''
end

def owner_failures
  failures = []
  owner = read(OWNER)
  skill = read(SKILL)
  readme = read(README)
  handoff = read(HANDOFF)

  failures << '缺少表单布局字段分组 owner：references/form-layout-field-groups.md' if owner.empty?
  failures << 'owner 缺少 formLayoutState' unless owner.include?('formLayoutState')
  RULE_IDS.each { |id| failures << "owner 缺少规则 ID #{id}" unless owner.include?(id) }
  STATE_FIELDS.each { |field| failures << "owner 缺少 formLayoutState 字段 #{field}" unless owner.include?(field) }
  OWNER_TERMS.each { |term| failures << "owner 缺少关键约束：#{term}" unless owner.include?(term) }
  ROUTE_TERMS.each { |term| failures << "SKILL 路由缺少 #{term}" unless skill.include?(term) }
  failures << 'README 缺少表单布局字段分组摘要' unless readme.include?('表单布局、字段分组与响应式排列规范')
  failures << 'README 缺少表单布局字段分组链接' unless readme.include?('references/form-layout-field-groups.md')
  failures << 'HANDOFF 缺少表单布局字段分组交接' unless handoff.include?('### 表单布局、字段分组与响应式排列')

  ADJACENT_FILES.each do |relative|
    text = read(File.join(ROOT, relative))
    failures << "#{relative} 缺少 references/form-layout-field-groups.md 引用" unless text.include?('references/form-layout-field-groups.md')
    failures << "#{relative} 缺少 formLayoutState 边界" unless text.include?('formLayoutState')
  end

  failures
end

def extract_contract(text)
  match = text.match(CONTRACT_PATTERN)
  raise JSON::ParserError, '缺少 form-layout-field-groups-audit JSON 契约区块' unless match

  JSON.parse(match[1])
end

def contract_failures(path, contract, text)
  failures = []
  failures << "#{path}: schemaVersion 必须为 1" unless contract['schemaVersion'] == 1
  %w[
    formLayoutOwnerApplied cssGridOnlyForbidden visualDomTabScreenReaderOrderAligned fieldGroupsSemantic
    labelsHelpErrorsBound multiColumnMobileForbidden footerAvoidanceRequired dynamicLayoutRecomputed
    runtimeUnverifiedDeclared
  ].each do |key|
    failures << "#{path}: #{key} 必须为 true" unless contract[key] == true
  end
  STATE_FIELDS.each do |field|
    failures << "#{path}: formLayoutState 缺少 #{field}" unless contract.dig('formLayoutState', field) == true
  end
  %w[
    forms field-guidance-help-text dialogs drawers page-content-layout-sections
    page-form-action-bars responsive-adaptive text-overflow-truncation
  ].each do |owner|
    failures << "#{path}: 未应用组件 owner #{owner}" unless contract.dig('componentOwners', owner) == true
  end
  %w[
    css-grid-only visual-dom-order-mismatch group-without-heading placeholder-as-label
    long-error-overlaps-neighbor mobile-horizontal-form footer-covers-error dynamic-field-stale-focus
  ].each do |negative|
    failures << "#{path}: 缺少负向用例 #{negative}" unless Array(contract['negativeCases']).include?(negative)
  end
  %w[browser keyboard screenReader touch virtualKeyboard zoom lowHeight mobileViewport].each do |environment|
    failures << "#{path}: #{environment} 必须明确为未验证" unless contract.dig('runtimeVerification', environment) == false
  end
  %w[formLayoutState CSS\ Grid DOM\ 顺序 字段组 label 移动端 footer 未验证].each do |term|
    failures << "#{path}: 正文缺少 #{term}" unless text.include?(term)
  end
  failures
end

def green_failures
  text = read(GREEN)
  return ['缺少 GREEN 应用输出'] if text.empty?

  contract_failures(GREEN, extract_contract(text), text)
rescue JSON::ParserError => e
  ["#{GREEN}: JSON 审计契约无效：#{e.message}"]
end

def project_leak_failures
  paths = [
    OWNER,
    File.join(ROOT, 'docs/testing/form-layout-field-groups/red-summary.md'),
    GREEN,
    File.join(ROOT, 'docs/superpowers/specs/2026-07-29-form-layout-field-groups-interaction-standards-design.md'),
    File.join(ROOT, 'docs/superpowers/plans/2026-07-29-form-layout-field-groups-interaction-standards.md')
  ]
  failures = []
  paths.each do |path|
    text = read(path)
    PROJECT_LEAK_PATTERNS.each do |pattern|
      failures << "#{path}: 泄漏项目/框架痕迹 #{pattern.inspect}" if text.match?(pattern)
    end
  end
  failures
end

def mutate_owner(text, name)
  case name
  when 'missing-state'
    text.gsub('formLayoutState', 'layoutState')
  when 'css-grid-only-allowed'
    text.gsub('不得只用 CSS Grid', '可以只用 CSS Grid')
  when 'order-boundary-removed'
    text.gsub('视觉顺序、DOM 顺序、Tab 顺序和读屏顺序', '视觉顺序')
  when 'group-semantics-removed'
    text.gsub('字段组必须有可见标题或等价语义', '字段组可以只靠距离区分')
  when 'placeholder-label-allowed'
    text.gsub('不得用占位符、tooltip-only 或相邻文本替代字段 label', '可以用占位符替代字段 label')
  when 'multi-column-overlap-allowed'
    text.gsub('两列/三列表单不得让跨列字段、长错误、长帮助或组合字段挤压相邻字段', '两列/三列表单可以压缩字段')
  when 'mobile-column-allowed'
    text.gsub('移动端必须转为单列或等价分组', '移动端可以保留多列')
  when 'footer-overlap-allowed'
    text.gsub('sticky/fixed footer 不得遮挡错误', 'sticky/fixed footer 可以遮挡错误')
  when 'runtime-boundary-marked-verified'
    text.gsub('未执行必须标为未验证', '默认视为已验证')
  else
    text
  end
end

def mutation_failures
  original = read(OWNER)
  names = %w[
    missing-state css-grid-only-allowed order-boundary-removed group-semantics-removed
    placeholder-label-allowed multi-column-overlap-allowed mobile-column-allowed
    footer-overlap-allowed runtime-boundary-marked-verified
  ]
  names.map do |name|
    mutated = mutate_owner(original, name)
    failures = []
    failures << "#{name}: 变异未改变 owner" if mutated == original
    OWNER_TERMS.each { |term| failures << "#{name}: 未检测到关键约束缺失 #{term}" unless mutated.include?(term) }
    failures << "#{name}: 未检测到 formLayoutState 缺失" unless mutated.include?('formLayoutState')
    failures.empty? ? "#{name}: 变异未被审计检测" : nil
  end.compact
end

if ARGV.include?('--mutations')
  failures = mutation_failures
else
  failures = owner_failures + green_failures + project_leak_failures
end

if failures.empty?
  puts 'PASS: form layout field groups interaction standards audit'
else
  warn failures.join("\n")
  exit 1
end
