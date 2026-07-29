#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/risk-actions.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/risk-actions/green-summary.md")
RED = File.join(ROOT, "docs/testing/risk-actions/red-summary.md")

RULE_IDS = %w[
  RA-SCOPE-01 RA-SCOPE-02 RA-SCOPE-03 RA-SCOPE-04
  RA-STATE-01 RA-STATE-02 RA-STATE-03 RA-STATE-04 RA-STATE-05
  RA-LEVEL-01 RA-LEVEL-02 RA-LEVEL-03 RA-LEVEL-04 RA-LEVEL-05
  RA-CONFIRM-01 RA-CONFIRM-02 RA-CONFIRM-03 RA-CONFIRM-04 RA-CONFIRM-05 RA-CONFIRM-06
  RA-UNDO-01 RA-UNDO-02 RA-UNDO-03 RA-UNDO-04 RA-UNDO-05
  RA-CANCEL-01 RA-CANCEL-02 RA-CANCEL-03 RA-CANCEL-04 RA-CANCEL-05
  RA-BULK-01 RA-BULK-02 RA-BULK-03 RA-BULK-04 RA-BULK-05
  RA-PERM-01 RA-PERM-02 RA-PERM-03 RA-PERM-04 RA-PERM-05
  RA-AUDIT-01 RA-AUDIT-02 RA-AUDIT-03 RA-AUDIT-04 RA-AUDIT-05
  RA-A11Y-01 RA-A11Y-02 RA-A11Y-03 RA-A11Y-04 RA-A11Y-05
  RA-RSP-01 RA-RSP-02 RA-RSP-03 RA-RSP-04
].freeze

STATE_FIELDS = %w[
  riskActionId riskLevel actionObject impactScope confirmationPolicy confirmationEvidence
  requestIdentity executionPhase undoPolicy cancelPolicy resultReceipt auditBinding recoveryActions
].freeze

OWNER_TERMS = [
  "riskActionState",
  "危险操作不得只靠颜色、图标、Tooltip 或按钮位置表达风险",
  "二次确认不得只有“确定 / 取消”“是 / 否”“提交 / 返回”等裸词",
  "未满足 `confirmationPolicy` 前，请求数必须为 0",
  "撤销不是 Toast 装饰；必须声明撤销窗口、对象、服务端结果和窗口结束后的持久状态",
  "已发送请求不得因为关闭确认、Escape、路由离开、客户端取消或 Toast 消失而写成“已取消”",
  "取消请求已发送不等于服务端已取消",
  "未知结果不得伪装成成功或失败",
  "批量危险操作必须冻结选择快照、筛选快照、权限版本、目标数量、目标摘要和影响范围",
  "权限、租户/工作区、角色、目标版本或筛选范围变化后，旧确认、旧目标快照、旧撤销入口和旧结果回执必须失效或重新证明安全",
  "移动端不得删除危险确认、影响范围、撤销/恢复入口、取消中状态、未知结果说明或审计回执",
  "未验证"
].freeze

ROUTE_TERMS = [
  "危险操作",
  "风险操作",
  "二次确认",
  "输入确认",
  "重置密钥",
  "撤销",
  "取消任务",
  "批量删除",
  "权限变更",
  "敏感导出",
  "未知结果",
  "审计回执",
  "danger action",
  "destructive action",
  "typed confirm",
  "bulk delete",
  "unknown result",
  "audit receipt",
  "references/risk-actions.md"
].freeze

README_TERMS = [
  "危险操作与恢复规范",
  "references/risk-actions.md"
].freeze

HANDOFF_TERMS = [
  "### 危险操作与恢复",
  "references/risk-actions.md",
  "confirmationPolicy",
  "未知结果不得伪装成成功或失败"
].freeze

EVIDENCE_TERMS = [
  "riskActionState",
  "riskLevel",
  "impactScope",
  "confirmationPolicy",
  "requestIdentity",
  "undoPolicy",
  "cancelPolicy",
  "resultReceipt",
  "auditBinding",
  "typed-confirm",
  "Toast",
  "未知结果",
  "批量危险操作",
  "移动端不得删除危险确认",
  "未验证"
].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)

  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def owner_failures(owner)
  failures = []
  RULE_IDS.each { |id| failures << "owner: missing rule id #{id}" unless owner.include?(id) }
  STATE_FIELDS.each { |field| failures << "owner: riskActionState missing #{field}" unless owner.include?(field) }
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end

def integration_failures(skill, readme, handoff, green, red)
  failures = []
  failures.concat(require_terms(skill, ROUTE_TERMS, "SKILL route"))
  failures.concat(require_terms(readme, README_TERMS, "README"))
  failures.concat(require_terms(handoff, HANDOFF_TERMS, "HANDOFF"))
  failures.concat(require_terms(green, EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(red, EVIDENCE_TERMS, "RED evidence"))
  failures
end

def project_leak_failures(owner)
  banned_terms = [
    "fex-admin",
    "/Users/evanqi/code/",
    "src/pages",
    "Ant Design",
    "ant-design",
    "shadcn",
    "Next.js",
    "Vite"
  ]

  banned_terms.select { |term| owner.include?(term) }.map do |term|
    "owner: must stay project-agnostic, found #{term.inspect}"
  end
end

def audit(owner:, skill:, readme:, handoff:, green:, red:)
  owner_failures(owner) +
    integration_failures(skill, readme, handoff, green, red) +
    project_leak_failures(owner)
end

def expect_failure(name)
  failures = yield
  abort("mutation did not fail: #{name}") if failures.empty?

  puts "EXPECTED_FAIL: #{name}"
end

owner = read(OWNER)
skill = read(SKILL)
readme = read(README)
handoff = read(HANDOFF)
green = read(GREEN)
red = read(RED)

failures = audit(owner: owner, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
unless failures.empty?
  warn failures.join("\n")
  exit 1
end

if ARGV.include?("--mutations")
  expect_failure("color-only-risk-communication") do
    audit(owner: owner.gsub("危险操作不得只靠颜色、图标、Tooltip 或按钮位置表达风险", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("naked-confirm-labels") do
    audit(owner: owner.gsub("二次确认不得只有“确定 / 取消”“是 / 否”“提交 / 返回”等裸词", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("request-before-confirmation") do
    audit(owner: owner.gsub("未满足 `confirmationPolicy` 前，请求数必须为 0", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("toast-only-undo") do
    audit(owner: owner.gsub("撤销不是 Toast 装饰；必须声明撤销窗口、对象、服务端结果和窗口结束后的持久状态", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("client-close-as-cancel") do
    audit(owner: owner.gsub("已发送请求不得因为关闭确认、Escape、路由离开、客户端取消或 Toast 消失而写成“已取消”", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("cancel-request-as-server-cancel") do
    audit(owner: owner.gsub("取消请求已发送不等于服务端已取消", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("unknown-result-boundary") do
    audit(owner: owner.gsub("未知结果不得伪装成成功或失败", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("bulk-snapshot-removed") do
    audit(owner: owner.gsub("批量危险操作必须冻结选择快照、筛选快照、权限版本、目标数量、目标摘要和影响范围", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-revalidation-removed") do
    audit(owner: owner.gsub("权限、租户/工作区、角色、目标版本或筛选范围变化后，旧确认、旧目标快照、旧撤销入口和旧结果回执必须失效或重新证明安全", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-risk-confirmation-removed") do
    audit(owner: owner.gsub("移动端不得删除危险确认、影响范围、撤销/恢复入口、取消中状态、未知结果说明或审计回执", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("project-specific-leakage") do
    audit(owner: "#{owner}\nfex-admin\n",
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 危险操作与恢复 owner、路由、摘要和证据符合结构化审计契约。"
