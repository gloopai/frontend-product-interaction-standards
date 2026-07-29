#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

ROOT = File.expand_path('../../..', __dir__)
OWNER = File.join(ROOT, 'references/entity-resource-pickers.md')
SKILL = File.join(ROOT, 'SKILL.md')
README = File.join(ROOT, 'README.md')
HANDOFF = File.join(ROOT, 'HANDOFF.md')
GREEN = File.join(ROOT, 'docs/testing/entity-resource-pickers/green-summary.md')

CONTRACT_PATTERN = /<!-- entity-resource-pickers-audit:start -->\s*```json\s*(.*?)\s*```\s*<!-- entity-resource-pickers-audit:end -->/m

STATE_FIELDS = %w[
  pickerOwnerId pickerSurface entityKind selectionMode committedSelection draftSelection queryState
  candidateResults recentAndSuggested identityResolution availabilityMap permissionBoundary scopeBinding
  bindingPolicy validationBinding requestIdentity feedbackBinding responsivePolicy focusAnnouncementPolicy
  lifecycleDisposal runtimeVerification
].freeze

RULE_IDS = %w[
  ERP-SCOPE-01 ERP-SCOPE-02 ERP-STATE-01 ERP-STATE-02 ERP-PERM-01 ERP-PERM-02
  ERP-VALID-01 ERP-VALID-02 ERP-ASYNC-01 ERP-BIND-01 ERP-FEED-01 ERP-RSP-01
  ERP-RSP-02 ERP-A11Y-01 ERP-VERIFY-01
].freeze

OWNER_TERMS = [
  '对象选择器不是普通 Select',
  'display label 不是对象身份',
  '最近、收藏、推荐',
  '跨租户、跨工作区、跨账号、跨项目',
  '无权限状态不得泄露对象名称',
  '已失效对象、已删除对象、无权限对象、不可绑定对象、重复对象、只读对象和未知对象',
  'Toast 不能作为唯一选择失败',
  '移动端不得删除搜索',
  '未执行必须标为未验证'
].freeze

ROUTE_TERMS = %w[
  对象选择器 资源选择器 成员选择器 用户选择器 负责人选择 审批人选择 关联对象
  entity\ picker resource\ picker object\ picker user\ picker member\ picker principal\ picker
  references/entity-resource-pickers.md
].freeze

ADJACENT_FILES = %w[
  references/selects-comboboxes.md
  references/multi-select-tag-inputs.md
  references/forms.md
  references/permissions-tenancy-visibility.md
  references/members-invitations-access.md
  references/approval-workflows.md
  references/record-editing-surfaces.md
  references/tree-hierarchy.md
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

  failures << '缺少对象资源选择器 owner：references/entity-resource-pickers.md' if owner.empty?
  failures << 'owner 缺少 entityResourcePickerState' unless owner.include?('entityResourcePickerState')
  RULE_IDS.each { |id| failures << "owner 缺少规则 ID #{id}" unless owner.include?(id) }
  STATE_FIELDS.each { |field| failures << "owner 缺少 entityResourcePickerState 字段 #{field}" unless owner.include?(field) }
  OWNER_TERMS.each { |term| failures << "owner 缺少关键约束：#{term}" unless owner.include?(term) }
  ROUTE_TERMS.each { |term| failures << "SKILL 路由缺少 #{term}" unless skill.include?(term) }
  failures << 'README 缺少对象资源选择器摘要' unless readme.include?('对象、资源与成员选择器规范')
  failures << 'README 缺少对象资源选择器链接' unless readme.include?('references/entity-resource-pickers.md')
  failures << 'HANDOFF 缺少对象资源选择器交接' unless handoff.include?('### 对象、资源与成员选择器')

  ADJACENT_FILES.each do |relative|
    text = read(File.join(ROOT, relative))
    failures << "#{relative} 缺少 references/entity-resource-pickers.md 引用" unless text.include?('references/entity-resource-pickers.md')
    failures << "#{relative} 缺少 entityResourcePickerState 边界" unless text.include?('entityResourcePickerState')
  end

  failures
end

def extract_contract(text)
  match = text.match(CONTRACT_PATTERN)
  raise JSON::ParserError, '缺少 entity-resource-pickers-audit JSON 契约区块' unless match

  JSON.parse(match[1])
end

def replace_contract(text, contract)
  replacement = "<!-- entity-resource-pickers-audit:start -->\n```json\n#{JSON.pretty_generate(contract)}\n```\n<!-- entity-resource-pickers-audit:end -->"
  text.sub(CONTRACT_PATTERN, replacement)
end

def contract_failures(path, contract, text)
  failures = []
  failures << "#{path}: schemaVersion 必须为 1" unless contract['schemaVersion'] == 1
  %w[
    entityResourcePickerOwnerApplied labelIsNotIdentity draftAndCommittedSeparated
    candidateSourcesSeparated crossScopeProofRequired permissionLeakForbidden invalidStatesSeparated
    staleRequestDiscarded toastOnlyForbidden mobileCoreActionsReachable
  ].each do |key|
    failures << "#{path}: #{key} 必须为 true" unless contract[key] == true
  end
  STATE_FIELDS.each do |field|
    failures << "#{path}: entityResourcePickerState 缺少 #{field}" unless contract.dig('entityResourcePickerState', field) == true
  end
  %w[
    selects-comboboxes multi-select-tag-inputs forms permissions-tenancy-visibility
    members-invitations-access approval-workflows tree-hierarchy
  ].each do |owner|
    failures << "#{path}: 未应用组件 owner #{owner}" unless contract.dig('componentOwners', owner) == true
  end
  %w[
    ordinary-select-only label-as-identity recent-search-cache-submit cross-scope-without-proof
    permission-leak-old-cache invalid-states-collapsed toast-only-picker-failure mobile-apply-cancel-removed
  ].each do |negative|
    failures << "#{path}: 缺少负向用例 #{negative}" unless Array(contract['negativeCases']).include?(negative)
  end
  %w[browser keyboard screenReader touch permissionSwitch mobileViewport].each do |environment|
    failures << "#{path}: #{environment} 必须明确为未验证" unless contract.dig('runtimeVerification', environment) == false
  end
  %w[entityResourcePickerState display\ label 旧搜索结果 跨租户 无权限状态 Toast 移动端 未验证].each do |term|
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
    File.join(ROOT, 'docs/testing/entity-resource-pickers/red-summary.md'),
    GREEN,
    File.join(ROOT, 'docs/superpowers/specs/2026-07-29-entity-resource-pickers-interaction-standards-design.md'),
    File.join(ROOT, 'docs/superpowers/plans/2026-07-29-entity-resource-pickers-interaction-standards.md')
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
    text.gsub('entityResourcePickerState', 'entityPickerState')
  when 'ordinary-select-boundary-removed'
    text.gsub('对象选择器不是普通 Select', '对象选择器可以复用普通 Select')
  when 'label-identity-collapsed'
    text.gsub('display label 不是对象身份', 'display label 可以作为对象身份')
  when 'recent-results-collapsed'
    text.gsub('最近、收藏、推荐', '候选')
  when 'cross-scope-proof-removed'
    text.gsub('跨租户、跨工作区、跨账号、跨项目', '跨范围')
  when 'permission-leak-allowed'
    text.gsub('无权限状态不得泄露对象名称', '无权限状态可以展示对象名称')
  when 'invalid-state-collapsed'
    text.gsub('已失效对象、已删除对象、无权限对象、不可绑定对象、重复对象、只读对象和未知对象', '异常对象')
  when 'toast-only-allowed'
    text.gsub('Toast 不能作为唯一选择失败', 'Toast 可以作为唯一选择失败')
  when 'runtime-boundary-marked-verified'
    text.gsub('未执行必须标为未验证', '默认视为已验证')
  else
    text
  end
end

def mutation_failures
  original = read(OWNER)
  names = %w[
    missing-state ordinary-select-boundary-removed label-identity-collapsed recent-results-collapsed
    cross-scope-proof-removed permission-leak-allowed invalid-state-collapsed toast-only-allowed
    runtime-boundary-marked-verified
  ]
  names.map do |name|
    mutated = mutate_owner(original, name)
    failures = []
    failures << "#{name}: 变异未改变 owner" if mutated == original
    OWNER_TERMS.each { |term| failures << "#{name}: 未检测到关键约束缺失 #{term}" unless mutated.include?(term) }
    failures << "#{name}: 未检测到 entityResourcePickerState 缺失" unless mutated.include?('entityResourcePickerState')
    failures.empty? ? "#{name}: 变异未被审计检测" : nil
  end.compact
end

if ARGV.include?('--mutations')
  failures = mutation_failures
else
  failures = owner_failures + green_failures + project_leak_failures
end

if failures.empty?
  puts 'PASS: entity resource pickers interaction standards audit'
else
  warn failures.join("\n")
  exit 1
end
