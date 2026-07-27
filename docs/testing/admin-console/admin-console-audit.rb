#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

ROOT = File.expand_path('../../..', __dir__)
OWNER = File.join(ROOT, 'references/admin-console.md')
RULE_IDS = %w[
  AC-IA-01 AC-IA-02 AC-IA-03 AC-IA-04
  AC-PERM-01 AC-PERM-02 AC-PERM-03 AC-PERM-04
  AC-RISK-01 AC-RISK-02 AC-RISK-03 AC-RISK-04
  AC-AUDIT-01 AC-AUDIT-02 AC-AUDIT-03 AC-AUDIT-04
  AC-JOB-01 AC-JOB-02 AC-JOB-03 AC-JOB-04 AC-JOB-05 AC-JOB-06
  AC-REPORT-01 AC-REPORT-02 AC-REPORT-03 AC-REPORT-04 AC-REPORT-05
  AC-FB-01 AC-FB-02 AC-FB-03 AC-FB-04
  AC-RSP-01 AC-RSP-02 AC-REPORTING-01 AC-REPORTING-02
].freeze
STATE_KEYS = %w[navigationState permissionState surfaceState riskState auditState taskState feedbackState].freeze
SURFACES = %w[overview-dashboard report record-list record-detail record-editor settings job-center audit-log].freeze
COMPONENT_OWNERS = %w[admin-console data-tables dialogs forms responsive-adaptive].freeze
COMPONENT_CONTRACTS = %w[dataTableReport dialogLifecycle formLifecycle responsiveEquivalence].freeze
COMPONENT_BODY_TERMS = {
  'dataTableReport' => %w[
    capabilityTier resolvedTier queryState viewState interactionState operationState lifecycleGuard 原子应用义务 运行时验证边界
  ],
  'formLifecycle' => %w[
    submitPhase awaiting-validation validation-aborted request-in-flight request-succeeded request-failed 等待校验期编辑策略
    submitSnapshot submitId validationGeneration asyncErrors serverErrors 错误摘要 live\ form\ session
  ],
  'dialogLifecycle' => [
    '200ms ease-out', '150ms ease-in', 'prefers-reduced-motion', 'inert', '页面滚动锁定',
    '普通关闭顺序', 'DOM 移除', '释放模态保护', '焦点返回', 'route/unmount disposal'
  ],
  'responsiveEquivalence' => [
    '1440×900', '1280×720', '平板横竖屏', '窄屏', '低高度', '200%', '虚拟键盘',
    'safe area', '断点切换', '不重建', '状态延续'
  ]
}.freeze
IDENTITY_FIELDS = %w[operationId idempotencyKey permissionVersion targetSnapshot initiator].freeze
RECEIPT_STATES = %w[success partial-success failure conflict unknown].freeze
AUDIT_STATES = %w[no-data no-permission filter-empty service-error data-delay].freeze
TASK_STATES = %w[queued running success partial-success failure cancelling cancelled unknown expired].freeze
TABLE_STATE_GROUPS = %w[queryState viewState interactionState operationState].freeze
CHECKLIST_ROWS = %w[
  能力与状态 查询 筛选 排序 分页 数据状态 选择 单行操作 批量操作 基础列状态
  可选列控制 Table语义 ARIAGrid语义 键盘 焦点 响应式 ARIA与公告 disposal 实例隔离 运行时验证边界
].freeze
DEFAULT_OUTPUTS = %w[
  docs/testing/admin-console/green-report-dashboard.md
  docs/testing/admin-console/green-permission-risk-console.md
  docs/testing/admin-console/green-job-audit-console.md
].map { |path| File.join(ROOT, path) }.freeze
CONTRACT_PATTERN = /<!-- admin-console-audit:start -->\s*```json\s*(.*?)\s*```\s*<!-- admin-console-audit:end -->/m

def extract_contract(text)
  match = text.match(CONTRACT_PATTERN)
  raise JSON::ParserError, '缺少 admin-console-audit JSON 契约区块' unless match

  JSON.parse(match[1])
end

def replace_contract(text, contract)
  replacement = "<!-- admin-console-audit:start -->\n```json\n#{JSON.pretty_generate(contract)}\n```\n<!-- admin-console-audit:end -->"
  text.sub(CONTRACT_PATTERN, replacement)
end

def checklist_rows(text)
  text.scan(/^\| ([^|]+) \| (?:适用|不适用) \|/).flatten.map do |name|
    name.strip.gsub(' ', '')
  end.select { |name| CHECKLIST_ROWS.include?(name) }
end

def contract_failures(path, contract, text)
  failures = []
  failures << "#{path}: schemaVersion 必须为 2" unless contract['schemaVersion'] == 2
  failures << "#{path}: 缺少合法 consoleSurface" unless Array(contract['consoleSurfaces']).all? { |surface| SURFACES.include?(surface) } && !Array(contract['consoleSurfaces']).empty?
  STATE_KEYS.each { |key| failures << "#{path}: 缺少状态 owner #{key}" unless Array(contract['stateOwners']).include?(key) }
  COMPONENT_OWNERS.each { |owner| failures << "#{path}: 未应用组件 owner #{owner}" unless contract.dig('componentOwners', owner) == true }
  COMPONENT_CONTRACTS.each { |key| failures << "#{path}: 未应用组件报告契约 #{key}" unless contract.dig('componentContracts', key) == true }
  COMPONENT_BODY_TERMS.each do |contract_key, terms|
    next unless contract.dig('componentContracts', contract_key) == true

    terms.each do |term|
      failures << "#{path}: #{contract_key} 缺少正文应用 #{term}" unless text.include?(term)
    end
  end

  boundary = contract.fetch('permissionBoundary', {})
  failures << "#{path}: 缺少 tenant 权限边界" unless boundary['tenantScoped'] == true
  %w[oldDataDisposition oldMenuDisposition].each do |key|
    failures << "#{path}: #{key} 必须在刷新前隐藏" unless boundary[key] == 'hide-before-refresh'
  end
  failures << "#{path}: 旧下载必须在刷新前失效" unless boundary['oldDownloadDisposition'] == 'invalidate-before-refresh'

  operations = Array(contract['riskOperations'])
  failures << "#{path}: 缺少风险操作结构" if operations.empty?
  operations.each do |operation|
    name = operation['name'] || '<unnamed>'
    IDENTITY_FIELDS.each do |field|
      failures << "#{path}: #{name} requestIdentity 缺少 #{field}" unless operation.dig('requestIdentity', field) == true
    end
    states = Array(operation.dig('resultReceipt', 'states'))
    RECEIPT_STATES.each do |state|
      failures << "#{path}: #{name} resultReceipt 缺少 #{state}" unless states.include?(state)
    end
    failures << "#{path}: #{name} 缺少审计回执" unless operation.dig('resultReceipt', 'auditReceipt') == true
    failures << "#{path}: #{name} 缺少页面内回执" unless operation.dig('resultReceipt', 'pageInline') == true
  end

  audit = contract.fetch('audit', {})
  failures << "#{path}: 缺少审计可用性" unless audit['availabilityDeclared'] == true
  failures << "#{path}: 缺少审计回执位置" unless audit['receiptLocationDeclared'] == true
  AUDIT_STATES.each { |state| failures << "#{path}: 审计缺少 #{state}" unless Array(audit['states']).include?(state) }

  feedback = contract.fetch('feedback', {})
  failures << "#{path}: Toast 被当作唯一 owner" unless feedback['toastOnly'] == false
  failures << "#{path}: Tooltip/Popover 被当作唯一 owner" unless feedback['tooltipOnly'] == false
  failures << "#{path}: 消息 primary owner 不唯一" unless feedback['primaryOwnerUnique'] == true
  %w[browser screenReader touch realComponent].each do |environment|
    failures << "#{path}: #{environment} 必须明确为未验证" unless contract.dig('runtimeVerification', environment) == false
  end

  table = contract.fetch('dataTable', {})
  failures << "#{path}: 缺少 data-table 能力档位" unless %w[display row-action bulk-action].include?(table['capabilityTier'])
  failures << "#{path}: resolvedTier 与 capabilityTier 不一致" unless table['resolvedTier'] == table['capabilityTier']
  TABLE_STATE_GROUPS.each { |group| failures << "#{path}: data-table 缺少固定状态组 #{group}" unless Array(table['fixedStateGroups']).include?(group) }
  %w[lifecycleGuard applicationChecklist atomicObligations].each { |key| failures << "#{path}: data-table 缺少 #{key}" unless table[key] == true }
  failures << "#{path}: 缺少 operationState row/bulk 子槽表" unless text.include?('| operationKind | currentValue | stateSlot | DOM | handler/event | request |')
  failures << "#{path}: 缺少原子应用义务表" unless text.include?('| ruleFamily | obligationKey | applicability | currentValueOrZeroEvidence | outputLocation | verificationStatus |')
  rows = checklist_rows(text)
  CHECKLIST_ROWS.each { |row| failures << "#{path}: 应用清单 #{row} 必须恰好一行" unless rows.count(row) == 1 }

  capabilities = contract.fetch('promptCapabilities', {})
  case contract['scenario']
  when 'report-dashboard'
    %w[kpiCards trendChart detailTable timeRangeFilter export mobile].each { |key| failures << "#{path}: 原始报表能力 #{key} 被删除" unless capabilities[key] == true }
    report = contract.fetch('report', {})
    failures << "#{path}: 报表必须默认展示型" unless report['defaultDisplayOnly'] == true
    %w[selectionEnabled rowActionsEnabled bulkEnabled].each { |key| failures << "#{path}: 报表未声明能力 #{key} 必须关闭" unless report[key] == false }
    failures << "#{path}: 原始导出入口必须保留" unless report['exportEnabled'] == true
    %w[metricDefinitionPresent refreshTimestampPresent dataLatencyPresent permissionScopePresent filterSnapshotShared].each do |key|
      failures << "#{path}: 报表缺少 #{key}" unless report[key] == true
    end
    failures << "#{path}: 报表 data-table 必须为 display" unless table['capabilityTier'] == 'display'
    failures << "#{path}: 风险导出结构缺失" unless operations.map { |operation| operation['name'] }.include?('sensitive-export')
  when 'permission-risk-console'
    %w[tenantSwitch rbacChanges userList roleDetail deleteUser bulkDeactivate permissionChange confirmationDialog mobile].each do |key|
      failures << "#{path}: 原始权限场景能力 #{key} 被删除" unless capabilities[key] == true
    end
    failures << "#{path}: 用户列表必须为 bulk-action" unless table['capabilityTier'] == 'bulk-action'
    %w[delete-user bulk-deactivate permission-change].each do |name|
      failures << "#{path}: 缺少风险操作 #{name}" unless operations.map { |operation| operation['name'] }.include?(name)
    end
  when 'job-audit-console'
    %w[csvImport fieldMapping precheck backgroundExecution errorFile sensitiveExport downloadLink cancelTask retryTask auditFilter mobile].each do |key|
      failures << "#{path}: 原始任务场景能力 #{key} 被删除" unless capabilities[key] == true
    end
    task = contract.fetch('taskContract', {})
    failures << "#{path}: 预检查失败不得创建任务" unless task['importPrecheckCreatesJob'] == false
    failures << "#{path}: 下载必须重验权限" unless task['downloadReauthorizes'] == true
    failures << "#{path}: 关闭页面不得等于取消任务" unless task['pageCloseCancelsTask'] == false
    TASK_STATES.each { |state| failures << "#{path}: 任务状态缺少 #{state}" unless Array(task['states']).include?(state) }
    %w[sensitive-export cancel-task retry-task].each do |name|
      failures << "#{path}: 缺少风险操作 #{name}" unless operations.map { |operation| operation['name'] }.include?(name)
    end
  else
    failures << "#{path}: 未知 scenario #{contract['scenario'].inspect}"
  end
  failures
end

def output_failures(path, text)
  contract_failures(path, extract_contract(text), text)
rescue JSON::ParserError => e
  ["#{path}: JSON 审计契约无效：#{e.message}"]
end

def audit(outputs)
  failures = []
  owner = File.exist?(OWNER) ? File.read(OWNER, encoding: 'UTF-8') : ''
  failures << '缺少管理台 owner：references/admin-console.md' if owner.empty?
  RULE_IDS.each { |id| failures << "owner 缺少规则 ID #{id}" unless owner.include?(id) }
  STATE_KEYS.each { |key| failures << "owner 缺少状态 owner #{key}" unless owner.include?(key) }
  SURFACES.each { |surface| failures << "owner 缺少 consoleSurface #{surface}" unless owner.include?(surface) }
  %w[operationId idempotencyKey permissionVersion targetSnapshot initiator success partial-success failure conflict unknown auditReceipt].each do |term|
    failures << "owner 缺少风险身份/回执字段 #{term}" unless owner.include?(term)
  end
  outputs.each do |path|
    unless File.file?(path)
      failures << "缺少 GREEN 应用输出：#{path}"
      next
    end
    failures.concat(output_failures(path, File.read(path, encoding: 'UTF-8')))
  end
  failures
end

def contract_control(name, source, replacements = {})
  text = File.read(source, encoding: 'UTF-8')
  replacements.each { |from, to| text = text.sub(from, to) }
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

def positive_control(name, source, from, to)
  text = File.read(source, encoding: 'UTF-8').sub(from, to)
  raise "positive control 未命中：#{name}" if text == File.read(source, encoding: 'UTF-8')

  failures = output_failures(source, text)
  if failures.empty?
    puts "EXPECTED_PASS: #{name}"
    true
  else
    puts "UNEXPECTED_FAIL: #{name}"
    failures.each { |failure| puts "- #{failure}" }
    false
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
puts 'PASS: owner 与三份 exact-prompt GREEN 应用输出符合结构化审计契约。'

if mutations
  report, permission, job = DEFAULT_OUTPUTS
  checks = [
    ['report-default-selection-bulk', report, {}, ->(c) { c['report']['selectionEnabled'] = true }],
    ['report-default-bulk', report, {}, ->(c) { c['report']['bulkEnabled'] = true }],
    ['report-export-deleted', report, {}, ->(c) { c['report']['exportEnabled'] = false }],
    ['report-metric-definition', report, {}, ->(c) { c['report']['metricDefinitionPresent'] = false }],
    ['report-refresh-timestamp', report, {}, ->(c) { c['report']['refreshTimestampPresent'] = false }],
    ['report-data-latency', report, {}, ->(c) { c['report']['dataLatencyPresent'] = false }],
    ['report-permission-scope', report, {}, ->(c) { c['report']['permissionScopePresent'] = false }],
    ['report-shared-snapshot', report, {}, ->(c) { c['report']['filterSnapshotShared'] = false }],
    ['permission-keep-old-data', permission, {}, ->(c) { c['permissionBoundary']['oldDataDisposition'] = 'keep-until-refresh' }],
    ['permission-keep-old-menu', permission, {}, ->(c) { c['permissionBoundary']['oldMenuDisposition'] = 'keep-until-refresh' }],
    ['permission-delete-removed', permission, {}, ->(c) { c['promptCapabilities']['deleteUser'] = false }],
    ['permission-bulk-deactivate-removed', permission, {}, ->(c) { c['promptCapabilities']['bulkDeactivate'] = false }],
    ['permission-role-detail-removed', permission, {}, ->(c) { c['promptCapabilities']['roleDetail'] = false }],
    ['permission-change-removed', permission, {}, ->(c) { c['promptCapabilities']['permissionChange'] = false }],
    ['import-precheck-creates-job', job, {}, ->(c) { c['taskContract']['importPrecheckCreatesJob'] = true }],
    ['export-link-survives-permission-change', job, {}, ->(c) { c['taskContract']['downloadReauthorizes'] = false }],
    ['page-close-is-task-cancel', job, {}, ->(c) { c['taskContract']['pageCloseCancelsTask'] = true }],
    ['audit-states-merged', job, {}, ->(c) { c['audit']['states'].delete('no-permission') }],
    ['tooltip-only-reason', permission, {}, ->(c) { c['feedback']['tooltipOnly'] = true }],
    ['toast-only-result', permission, {}, ->(c) { c['feedback']['toastOnly'] = true }],
    ['runtime-boundary-contradicted', report, {}, ->(c) { c['runtimeVerification']['browser'] = true }],
    ['component-data-table-missing', report, {}, ->(c) { c['componentContracts']['dataTableReport'] = false }],
    ['component-dialog-missing', permission, {}, ->(c) { c['componentContracts']['dialogLifecycle'] = false }],
    ['component-form-missing', job, {}, ->(c) { c['componentContracts']['formLifecycle'] = false }],
    ['component-responsive-missing', report, {}, ->(c) { c['componentContracts']['responsiveEquivalence'] = false }],
    ['component-lifecycle-body-deleted', permission, {'角色详情表单执行 forms owner 的完整阶段：`submitPhase` 只能在 `idle`、`awaiting-validation`、`validation-aborted`、`request-in-flight`、`request-succeeded`、`request-failed` 间转换。' => '角色详情表单遵循 forms owner。'}, ->(_c) {}],
    ['risk-identity-operation-id', permission, {}, ->(c) { c['riskOperations'][0]['requestIdentity']['operationId'] = false }],
    ['risk-identity-idempotency-key', permission, {}, ->(c) { c['riskOperations'][0]['requestIdentity']['idempotencyKey'] = false }],
    ['risk-identity-permission-version', permission, {}, ->(c) { c['riskOperations'][0]['requestIdentity']['permissionVersion'] = false }],
    ['risk-identity-target-snapshot', permission, {}, ->(c) { c['riskOperations'][0]['requestIdentity']['targetSnapshot'] = false }],
    ['risk-identity-initiator', permission, {}, ->(c) { c['riskOperations'][0]['requestIdentity']['initiator'] = false }],
    ['receipt-success', permission, {}, ->(c) { c['riskOperations'][0]['resultReceipt']['states'].delete('success') }],
    ['receipt-partial-success', permission, {}, ->(c) { c['riskOperations'][0]['resultReceipt']['states'].delete('partial-success') }],
    ['receipt-failure', permission, {}, ->(c) { c['riskOperations'][0]['resultReceipt']['states'].delete('failure') }],
    ['receipt-conflict', permission, {}, ->(c) { c['riskOperations'][0]['resultReceipt']['states'].delete('conflict') }],
    ['receipt-unknown', permission, {}, ->(c) { c['riskOperations'][0]['resultReceipt']['states'].delete('unknown') }],
    ['receipt-audit', permission, {}, ->(c) { c['riskOperations'][0]['resultReceipt']['auditReceipt'] = false }],
    ['job-task-state-cancelled', job, {}, ->(c) { c['taskContract']['states'].delete('cancelled') }],
    ['job-csv-capability-removed', job, {}, ->(c) { c['promptCapabilities']['csvImport'] = false }],
    ['report-default-selection-bulk-paraphrase', report, {'产品判断仍为报表默认展示型' => '选择和批量默认开启'}, ->(c) { c['report']['selectionEnabled'] = true; c['report']['bulkEnabled'] = true }],
    ['report-metric-metadata-negated', report, {'页面明示数据快照生成时间、最大 15 分钟延迟' => '不展示刷新时间；不说明数据延迟'}, ->(c) { c['report']['refreshTimestampPresent'] = false; c['report']['dataLatencyPresent'] = false }],
    ['permission-keep-old-data-paraphrase', permission, {'旧成员数据、旧菜单、选择、确认快照、详情表单和下载均先隐藏或安全占位' => '旧成员数据保留直到刷新完成；旧菜单、确认快照和下载入口隐藏'}, ->(c) { c['permissionBoundary']['oldDataDisposition'] = 'keep-until-refresh' }]
  ]
  controls = [
    ['toast-negated-only-error', permission, 'Toast 仅辅助', '唯一错误不能由 Toast 显示'],
    ['toast-negated-object-first-error', permission, 'Toast 仅辅助', '错误唯一不能由 Toast 显示'],
    ['toast-negated-recovery', permission, 'Toast 仅辅助', '恢复入口唯一不是通过 Toast 提供']
  ]
  negative_results = checks.map do |name, source, replacements, mutation|
    contract_control(name, source, replacements, &mutation)
  end
  positive_results = controls.map { |name, source, from, to| positive_control(name, source, from, to) }
  passed = negative_results.all? && positive_results.all?
  puts "MUTATIONS #{passed ? 'PASS' : 'FAIL'}: #{checks.length} negative mutations, #{controls.length} positive controls."
  exit(passed ? 0 : 1)
end
