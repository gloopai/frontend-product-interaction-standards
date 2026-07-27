#!/usr/bin/env ruby
# frozen_string_literal: true

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
DEFAULT_OUTPUTS = %w[
  docs/testing/admin-console/green-report-dashboard.md
  docs/testing/admin-console/green-permission-risk-console.md
  docs/testing/admin-console/green-job-audit-console.md
].map { |path| File.join(ROOT, path) }.freeze

def zero_evidence_for?(text, label)
  start = text.index(label)
  return false unless start

  block = text[start...(text.index("\n", start) || text.length)]
  block.match?(/DOM=0/) && block.match?(/state=0/) && block.match?(/handler\/event=0/) && block.match?(/request=0/)
end

def toast_is_unique_owner?(text)
  text.split(/[。！\n]/).any? do |sentence|
    sentence.match?(
      /唯一(?:的)?(?:回执|错误|恢复入口).*?(?:由|在|通过|仅).*?Toast|(?:回执|错误|恢复入口)唯一(?!\s*(?:不能|不是|不应|不得)(?:由|在|通过|仅)).*?(?:由|在|通过|仅).*?Toast|Toast.*?(?:(?<!不)(?<!能)是|为|作为|提供|显示).*?唯一(?:的)?(?:回执|错误|恢复入口)|(?:回执|错误|恢复入口|结果)(?:仅|只).*?Toast/
    )
  end
end

def runtime_boundary_unverified?(text)
  environments = [/浏览器/, /AT(?:（屏幕阅读器）)?/, /touch(?:（触摸设备）)?/, /真实组件运行时/]
  environments.all? do |environment|
    negative = text.match?(/#{environment.source}[^。！\n]{0,100}(?:未执行|未验证)/)
    positive = text.match?(/#{environment.source}[^。！\n]{0,100}(?:已执行|已验证|已运行|验证已完成)/) ||
               text.match?(/(?:已对|已|已经)[^。！\n]{0,20}#{environment.source}[^。！\n]{0,40}(?:执行验证|完成验证|验证已完成)/)
    negative && !positive
  end
end

def output_failures(path, text)
  failures = []
  failures << "#{path}: 缺少 consoleSurface 声明" unless text.match?(/consoleSurface:\s*(?:overview-dashboard|report|record-list|record-detail|record-editor|settings|job-center|audit-log)/)
  STATE_KEYS.each { |key| failures << "#{path}: 缺少状态 owner #{key}" unless text.include?(key) }
  failures << "#{path}: 缺少权限/租户安全边界" unless text.match?(/permissionState/) && text.match?(/tenant|租户/) && text.match?(/旧.*(?:隐藏|安全占位|不保留)/)
  failures << "#{path}: 缺少风险声明或对应区块的四类零值证据" unless text.match?(/riskLevel.*impactScope.*confirmationPolicy.*requestIdentity.*resultReceipt/m) || zero_evidence_for?(text, '风险操作零值证据')
  failures << "#{path}: 缺少审计可用性和回执位置或对应区块的四类零值证据" unless (text.match?(/审计可用性/) && text.match?(/审计.*(?:位置|回执)/)) || zero_evidence_for?(text, '审计零值证据')
  failures << "#{path}: 缺少导入/导出/任务能力或对应区块的四类零值证据" unless text.match?(/导入.*导出.*(?:任务|taskState)/m) || zero_evidence_for?(text, '任务零值证据')
  failures << "#{path}: Toast 被当作唯一回执、错误或恢复入口" if toast_is_unique_owner?(text)
  failures << "#{path}: Tooltip/Popover 承载唯一必读内容" if text.match?(/唯一.*仅在 (?:Tooltip|Popover)|(?:Tooltip|Popover) 是唯一/)
  failures << "#{path}: 每个运行时环境均须明确未执行/未验证，且不能与已执行声明矛盾" unless runtime_boundary_unverified?(text)

  case File.basename(path)
  when 'green-report-dashboard.md'
    failures << "#{path}: 报表未明确默认只读" unless text.include?('默认只读展示')
    failures << "#{path}: 报表启用了未显式声明的选择/批量" if text.include?('默认启用选择和批量')
    failures << "#{path}: 报表缺少对应区块的四类只读零值证据" unless zero_evidence_for?(text, '只读零值证据')
    %w[口径 时间范围 刷新时间 数据延迟 权限范围 过滤条件].each { |term| failures << "#{path}: 报表缺少 #{term}" unless text.include?(term) }
  when 'green-permission-risk-console.md'
    failures << "#{path}: 权限更新仍可能暴露旧数据" unless text.match?(/旧.*(?:隐藏|安全占位|不保留)/)
    failures << "#{path}: 风险结果缺少页面内回执" unless text.match?(/页面内.*回执|回执.*页面内/)
  when 'green-job-audit-console.md'
    failures << "#{path}: 导入预检查失败错误地创建任务" unless text.include?('预检查失败不创建执行任务')
    failures << "#{path}: 导出权限变化后未拒绝下载" unless text.include?('权限变化、链接过期或身份不匹配时拒绝下载')
    failures << "#{path}: 页面关闭被写成任务取消" unless text.include?('关闭页面不等于取消')
    failures << "#{path}: 审计状态被合并为空态" if text.include?('合并为一个空态')
    %w[无数据 无权限 筛选无结果 审计服务不可用 数据延迟].each { |term| failures << "#{path}: 审计缺少 #{term} 区分" unless text.include?(term) }
  end
  failures
end

def audit(outputs)
  failures = []
  owner = File.exist?(OWNER) ? File.read(OWNER, encoding: 'UTF-8') : ''
  failures << '缺少管理台 owner：references/admin-console.md' if owner.empty?
  RULE_IDS.each { |id| failures << "owner 缺少规则 ID #{id}" unless owner.include?(id) }
  STATE_KEYS.each { |key| failures << "owner 缺少状态 owner #{key}" unless owner.include?(key) }
  SURFACES.each { |surface| failures << "owner 缺少 consoleSurface #{surface}" unless owner.include?(surface) }
  %w[DOM state handler request Toast Tooltip 未验证].each { |term| failures << "owner 缺少报告契约关键字 #{term}" unless owner.include?(term) }
  outputs.each do |path|
    unless File.file?(path)
      failures << "缺少 GREEN 应用输出：#{path}"
      next
    end
    failures.concat(output_failures(path, File.read(path, encoding: 'UTF-8')))
  end
  failures
end

def mutation(name, source, replacement)
  mutated = File.read(source, encoding: 'UTF-8').sub(replacement.fetch(:from), replacement.fetch(:to))
  raise "mutation 未命中：#{name}" if mutated == File.read(source, encoding: 'UTF-8')

  failures = output_failures(source, mutated)
  if failures.empty?
    puts "UNEXPECTED_PASS: #{name}"
    false
  else
    puts "EXPECTED_FAIL: #{name}"
    true
  end
end

def positive_control(name, source, replacement)
  mutated = File.read(source, encoding: 'UTF-8').sub(replacement.fetch(:from), replacement.fetch(:to))
  raise "positive control 未命中：#{name}" if mutated == File.read(source, encoding: 'UTF-8')

  failures = output_failures(source, mutated)
  if failures.empty?
    puts "EXPECTED_PASS: #{name}"
    true
  else
    puts "UNEXPECTED_FAIL: #{name}"
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
puts 'PASS: owner 与三份 GREEN 应用输出符合审计契约。'

if mutations
  report, permission, job = DEFAULT_OUTPUTS
  checks = [
    ['report-default-selection-bulk', report, { from: '未显式声明选择、行操作、批量、钻取、导出或订阅', to: '默认启用选择和批量' }],
    ['report-metric-refresh-delay', report, { from: '刷新时间显示为数据快照生成时间；数据延迟显示为最多 15 分钟；', to: '' }],
    ['permission-keep-old-data', permission, { from: '旧成员数据、选择、菜单、确认快照和下载入口立即隐藏或安全占位', to: '旧成员数据保留直到刷新完成' }],
    ['risk-toast-only', permission, { from: '风险操作不以 Toast-only 结束', to: '风险操作结果仅 Toast-only' }],
    ['import-precheck-creates-job', job, { from: '预检查失败不创建执行任务', to: '预检查失败创建执行任务' }],
    ['export-link-survives-permission-change', job, { from: '权限变化、链接过期或身份不匹配时拒绝下载', to: '权限变化后下载链接保持有效' }],
    ['page-close-is-task-cancel', job, { from: '关闭页面不等于取消', to: '关闭页面等于取消' }],
    ['audit-states-merged', job, { from: '不合并为空态', to: '合并为一个空态' }],
    ['tooltip-only-reason', permission, { from: 'Tooltip/Popover 不承载唯一权限原因、错误或确认后果', to: '唯一权限原因仅在 Tooltip' }],
    ['runtime-boundary-removed', report, { from: '浏览器、AT（屏幕阅读器）、touch（触摸设备）和真实组件运行时均未执行，DOM/ARIA、事件日志、键盘路径和断点行为均标记为未验证；不将上述推断写成运行时事实。', to: '浏览器、AT、touch 与真实组件运行时已全部验证。' }],
    ['risk-zero-evidence-borrowed', report, { from: 'request=0（无风险请求）', to: 'request=1（错误的风险请求）' }],
    ['toast-unique-error', permission, { from: 'Toast 仅辅助，Tooltip', to: '唯一错误由 Toast 显示，Tooltip' }],
    ['runtime-boundary-contradicted', report, { from: '均未执行，DOM/ARIA', to: '均已执行，DOM/ARIA' }],
    ['toast-object-first-error', permission, { from: 'Toast 仅辅助，Tooltip', to: '错误唯一由 Toast 显示，Tooltip' }],
    ['toast-object-first-recovery', permission, { from: 'Toast 仅辅助，Tooltip', to: '恢复入口唯一通过 Toast 提供，Tooltip' }],
    ['runtime-status-first-contradicted', report, { from: '均未执行，DOM/ARIA', to: '均未执行，DOM/ARIA；已对浏览器执行验证' }]
  ]
  controls = [
    ['toast-negated-object-first-error', permission, { from: 'Toast 仅辅助，Tooltip', to: '错误唯一不能由 Toast 显示，Tooltip' }],
    ['toast-negated-object-first-recovery', permission, { from: 'Toast 仅辅助，Tooltip', to: '恢复入口唯一不是通过 Toast 提供，Tooltip' }]
  ]
  passed = checks.map { |name, source, replacement| mutation(name, source, replacement) }.all? &&
           controls.map { |name, source, replacement| positive_control(name, source, replacement) }.all?
  exit(passed ? 0 : 1)
end
