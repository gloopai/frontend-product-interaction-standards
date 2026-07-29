#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

ROOT = File.expand_path('../../..', __dir__)
OWNER = File.join(ROOT, 'references/transfer-assignment-lists.md')
SKILL = File.join(ROOT, 'SKILL.md')
README = File.join(ROOT, 'README.md')
HANDOFF = File.join(ROOT, 'HANDOFF.md')
GREEN = File.join(ROOT, 'docs/testing/transfer-assignment-lists/green-summary.md')

CONTRACT_PATTERN = /<!-- transfer-assignment-lists-audit:start -->\s*```json\s*(.*?)\s*```\s*<!-- transfer-assignment-lists-audit:end -->/m

STATE_FIELDS = %w[
  transferOwnerId assignmentSurface subjectBinding candidateScope initialAssignedSet draftAssignedSet
  sourceVisibleSet targetVisibleSet selectionBuckets moveIntent eligibilityMap permissionBoundary
  requestIdentity diffSummary validationBinding savePolicy feedbackBinding responsivePolicy
  focusAnnouncementPolicy lifecycleDisposal runtimeVerification
].freeze

RULE_IDS = %w[
  ATL-SCOPE-01 ATL-STATE-01 ATL-STATE-02 ATL-ID-01 ATL-MOVE-01 ATL-MOVE-02
  ATL-PERM-01 ATL-PERM-02 ATL-TREE-01 ATL-SAVE-01 ATL-SAVE-02 ATL-ASYNC-01
  ATL-RSP-01 ATL-RSP-02 ATL-A11Y-01 ATL-VERIFY-01
].freeze

OWNER_TERMS = [
  '穿梭框不是两个普通 Select',
  '移动不等于保存',
  '勾选不等于移动',
  '搜索命中不等于已分配',
  '当前页全选、全部筛选结果、全部候选',
  '无权限状态不得泄露资源名称',
  '无权限、只读、锁定、继承、已删除、失效、重复和未知',
  '半选只表达派生覆盖状态',
  'Toast 不能作为唯一回执',
  '移动端不得删除候选搜索',
  '未执行必须标为未验证'
].freeze

ROUTE_TERMS = [
  '穿梭框',
  '权限分配',
  '资源分配',
  '菜单授权',
  '角色授权',
  '数据范围授权',
  'dual listbox',
  'transfer list',
  'assignment list',
  'permission assignment',
  'resource assignment',
  'references/transfer-assignment-lists.md'
].freeze

ADJACENT_FILES = %w[
  references/entity-resource-pickers.md
  references/multi-select-tag-inputs.md
  references/tree-hierarchy.md
  references/data-tables.md
  references/bulk-actions-batch-operations.md
  references/forms.md
  references/permissions-tenancy-visibility.md
  references/members-invitations-access.md
  references/risk-actions.md
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

  failures << '缺少穿梭框分配 owner：references/transfer-assignment-lists.md' if owner.empty?
  failures << 'owner 缺少 assignmentTransferState' unless owner.include?('assignmentTransferState')
  RULE_IDS.each { |id| failures << "owner 缺少规则 ID #{id}" unless owner.include?(id) }
  STATE_FIELDS.each { |field| failures << "owner 缺少 assignmentTransferState 字段 #{field}" unless owner.include?(field) }
  OWNER_TERMS.each { |term| failures << "owner 缺少关键约束：#{term}" unless owner.include?(term) }
  ROUTE_TERMS.each { |term| failures << "SKILL 路由缺少 #{term}" unless skill.include?(term) }
  failures << 'README 缺少穿梭框分配摘要' unless readme.include?('穿梭框、分配列表与授权资源选择规范')
  failures << 'README 缺少穿梭框分配链接' unless readme.include?('references/transfer-assignment-lists.md')
  failures << 'HANDOFF 缺少穿梭框分配交接' unless handoff.include?('### 穿梭框、分配列表与授权资源选择')

  ADJACENT_FILES.each do |relative|
    text = read(File.join(ROOT, relative))
    failures << "#{relative} 缺少 references/transfer-assignment-lists.md 引用" unless text.include?('references/transfer-assignment-lists.md')
    failures << "#{relative} 缺少 assignmentTransferState 边界" unless text.include?('assignmentTransferState')
  end

  failures
end

def extract_contract(text)
  match = text.match(CONTRACT_PATTERN)
  raise JSON::ParserError, '缺少 transfer-assignment-lists-audit JSON 契约区块' unless match

  JSON.parse(match[1])
end

def contract_failures(path, contract, text)
  failures = []
  failures << "#{path}: schemaVersion 必须为 1" unless contract['schemaVersion'] == 1
  %w[
    assignmentTransferOwnerApplied moveIsNotSave checkIsNotMove visibleSelectionScopeSeparated
    draftAndInitialSeparated permissionLeakForbidden lockedInheritedStatesSeparated
    treeHalfCheckedNotSubmitValue staleRequestDiscarded toastOnlyForbidden mobileCoreActionsReachable
  ].each do |key|
    failures << "#{path}: #{key} 必须为 true" unless contract[key] == true
  end
  STATE_FIELDS.each do |field|
    failures << "#{path}: assignmentTransferState 缺少 #{field}" unless contract.dig('assignmentTransferState', field) == true
  end
  %w[
    entity-resource-pickers multi-select-tag-inputs tree-hierarchy data-tables
    bulk-actions-batch-operations forms permissions-tenancy-visibility risk-actions responsive-adaptive
  ].each do |owner|
    failures << "#{path}: 未应用组件 owner #{owner}" unless contract.dig('componentOwners', owner) == true
  end
  %w[
    two-selects-only selected-keys-only move-as-save visible-page-as-all permission-leak-old-assigned
    locked-inherited-collapsed tree-half-checked-submit toast-only-save-result mobile-diff-summary-removed
  ].each do |negative|
    failures << "#{path}: 缺少负向用例 #{negative}" unless Array(contract['negativeCases']).include?(negative)
  end
  %w[browser keyboard screenReader touch permissionSwitch lateRequest bulkScope mobileViewport].each do |environment|
    failures << "#{path}: #{environment} 必须明确为未验证" unless contract.dig('runtimeVerification', environment) == false
  end
  %w[assignmentTransferState 移动不等于保存 勾选不等于移动 当前页全选 无权限 Toast 未验证].each do |term|
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
    File.join(ROOT, 'docs/testing/transfer-assignment-lists/red-summary.md'),
    GREEN,
    File.join(ROOT, 'docs/superpowers/specs/2026-07-29-transfer-assignment-lists-interaction-standards-design.md'),
    File.join(ROOT, 'docs/superpowers/plans/2026-07-29-transfer-assignment-lists-interaction-standards.md')
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
    text.gsub('assignmentTransferState', 'transferState')
  when 'ordinary-selects-allowed'
    text.gsub('穿梭框不是两个普通 Select', '穿梭框可以是两个普通 Select')
  when 'move-as-save-allowed'
    text.gsub('移动不等于保存', '移动就是保存')
  when 'check-as-move-allowed'
    text.gsub('勾选不等于移动', '勾选就是移动')
  when 'search-hit-as-assigned'
    text.gsub('搜索命中不等于已分配', '搜索命中就是已分配')
  when 'select-all-collapsed'
    text.gsub('当前页全选、全部筛选结果、全部候选', '全选')
  when 'permission-leak-allowed'
    text.gsub('无权限状态不得泄露资源名称', '无权限状态可以展示资源名称')
  when 'locked-inherited-collapsed'
    text.gsub('无权限、只读、锁定、继承、已删除、失效、重复和未知', '不可用')
  when 'half-checked-submit'
    text.gsub('半选只表达派生覆盖状态', '半选可以提交')
  when 'toast-only-allowed'
    text.gsub('Toast 不能作为唯一回执', 'Toast 可以作为唯一回执')
  when 'runtime-boundary-marked-verified'
    text.gsub('未执行必须标为未验证', '默认视为已验证')
  else
    text
  end
end

def mutation_failures
  original = read(OWNER)
  names = %w[
    missing-state ordinary-selects-allowed move-as-save-allowed check-as-move-allowed
    search-hit-as-assigned select-all-collapsed permission-leak-allowed locked-inherited-collapsed
    half-checked-submit toast-only-allowed runtime-boundary-marked-verified
  ]
  names.map do |name|
    mutated = mutate_owner(original, name)
    failures = []
    failures << "#{name}: 变异未改变 owner" if mutated == original
    OWNER_TERMS.each { |term| failures << "#{name}: 未检测到关键约束缺失 #{term}" unless mutated.include?(term) }
    failures << "#{name}: 未检测到 assignmentTransferState 缺失" unless mutated.include?('assignmentTransferState')
    failures.empty? ? "#{name}: 变异未被审计检测" : nil
  end.compact
end

if ARGV.include?('--mutations')
  failures = mutation_failures
else
  failures = owner_failures + green_failures + project_leak_failures
end

if failures.empty?
  puts 'PASS: transfer assignment lists interaction standards audit'
else
  warn failures.join("\n")
  exit 1
end
