#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/optimistic-update-undo.md")
BUTTONS = File.join(ROOT, "references/buttons.md")
FORMS = File.join(ROOT, "references/forms.md")
RISK = File.join(ROOT, "references/risk-actions.md")
STATUS = File.join(ROOT, "references/status-lifecycle-transitions.md")
LIST = File.join(ROOT, "references/list-result-controls.md")
CARD = File.join(ROOT, "references/card-list-results.md")
FEEDBACK = File.join(ROOT, "references/feedback-states.md")
PERMISSIONS = File.join(ROOT, "references/permissions-tenancy-visibility.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/optimistic-update-undo/green-summary.md")
RED = File.join(ROOT, "docs/testing/optimistic-update-undo/red-summary.md")

STATE_FIELDS = %w[
  mutationOwnerId mutationSurface sourceSnapshot targetIdentity visibleProjection
  pendingMutation commitSnapshot idempotencyPolicy optimisticPolicy undoPolicy
  rollbackPolicy reconciliationPolicy permissionBoundary feedbackBinding
  responsivePolicy focusAnnouncementPolicy lifecycleDisposal runtimeVerification
].freeze

OWNER_TERMS = [
  "optimisticMutationState",
  "乐观更新不是成功回执，也不是绕过确认、权限、审计或服务端权威状态的捷径",
  "未得到服务端或权威来源确认前，乐观状态必须标记为 pending、syncing、undoable 或 queued",
  "高风险、不可逆、敏感导出、权限变更、密钥重置和强审计操作默认不得乐观完成",
  "撤销入口不得只存在于自动消失 Toast",
  "失败回滚必须基于 `sourceSnapshot`、权威刷新或 conflict payload",
  "迟到响应、重复响应或旧队列恢复不得覆盖当前对象、当前字段、当前权限或新 mutation 的可见投影",
  "权限降级、租户/工作区切换、对象删除、能力关闭、认证过期、版本冲突或 owner 卸载后，旧乐观投影、旧撤销入口、旧回滚依据、旧错误、旧成功提示、旧 aria-label、旧计时器和旧请求回调必须失效或重新证明安全",
  "未验证"
].freeze

ROUTE_TERMS = [
  "乐观更新", "乐观 UI", "先改界面", "预提交状态", "同步中", "撤销",
  "撤回", "回滚", "失败回滚", "部分回滚", "重试", "冲突恢复",
  "操作排队", "离线队列", "弱网恢复", "重复提交", "迟到响应", "幂等",
  "optimistic update", "optimistic UI", "optimistic mutation", "pending mutation",
  "syncing", "undo", "undo action", "rollback", "revert", "retry mutation",
  "queued mutation", "offline queue", "late response", "idempotency",
  "conflict recovery", "references/optimistic-update-undo.md"
].freeze

ADJACENT_TERMS = ["references/optimistic-update-undo.md", "optimistic-update-undo.md"].freeze
README_TERMS = ["乐观更新、撤销与回滚规范", "references/optimistic-update-undo.md"].freeze
HANDOFF_TERMS = [
  "### 乐观更新、撤销与回滚",
  "optimisticMutationState",
  "乐观更新不是成功回执",
  "undoPolicy",
  "references/optimistic-update-undo.md"
].freeze
EVIDENCE_TERMS = STATE_FIELDS + [
  "optimisticMutationState", "undoPolicy", "rollbackPolicy",
  "reconciliationPolicy", "idempotencyPolicy", "未验证"
]
PROJECT_BANNED_TERMS = [
  "fex-admin", "/Users/evanqi/code/", "src/pages", "Ant Design",
  "ant-design", "shadcn", "Next.js", "Vite", "React", "Vue"
].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)
  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def owner_failures(owner)
  STATE_FIELDS.reject { |field| owner.include?(field) }.map { |field| "owner: optimisticMutationState missing #{field}" } +
    require_terms(owner, OWNER_TERMS, "owner")
end

def integration_failures(texts)
  failures = []
  %w[buttons forms risk status list card feedback permissions].each do |key|
    failures.concat(require_terms(texts.fetch(key), ADJACENT_TERMS, "#{key} relationship"))
  end
  failures.concat(require_terms(texts.fetch("skill"), ROUTE_TERMS, "SKILL route"))
  failures.concat(require_terms(texts.fetch("readme"), README_TERMS, "README"))
  failures.concat(require_terms(texts.fetch("handoff"), HANDOFF_TERMS, "HANDOFF"))
  failures.concat(require_terms(texts.fetch("green"), EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(texts.fetch("red"), EVIDENCE_TERMS, "RED evidence"))
  failures
end

def project_leak_failures(texts)
  PROJECT_BANNED_TERMS.flat_map do |term|
    texts.select { |_label, text| text.include?(term) }.map { |label, _text| "#{label}: forbidden project-specific term #{term}" }
  end
end

def audit(texts)
  owner_failures(texts.fetch("owner")) +
    integration_failures(texts) +
    project_leak_failures("owner" => texts.fetch("owner"), "green" => texts.fetch("green"), "red" => texts.fetch("red"))
end

def expect_failure(name)
  failures = yield
  abort("mutation did not fail: #{name}") if failures.empty?
  puts "EXPECTED_FAIL: #{name}"
end

texts = {
  "owner" => read(OWNER),
  "buttons" => read(BUTTONS),
  "forms" => read(FORMS),
  "risk" => read(RISK),
  "status" => read(STATUS),
  "list" => read(LIST),
  "card" => read(CARD),
  "feedback" => read(FEEDBACK),
  "permissions" => read(PERMISSIONS),
  "skill" => read(SKILL),
  "readme" => read(README),
  "handoff" => read(HANDOFF),
  "green" => read(GREEN),
  "red" => read(RED)
}

failures = audit(texts)
unless failures.empty?
  warn failures.join("\n")
  exit 1
end

if ARGV.include?("--mutations")
  {
    "missing-owner-state" => texts.fetch("owner").gsub("optimisticMutationState", "optimistic-state"),
    "success-boundary-removed" => texts.fetch("owner").gsub("乐观更新不是成功回执，也不是绕过确认、权限、审计或服务端权威状态的捷径", ""),
    "pending-marker-removed" => texts.fetch("owner").gsub("未得到服务端或权威来源确认前，乐观状态必须标记为 pending、syncing、undoable 或 queued", ""),
    "high-risk-boundary-removed" => texts.fetch("owner").gsub("高风险、不可逆、敏感导出、权限变更、密钥重置和强审计操作默认不得乐观完成", ""),
    "toast-only-undo-removed" => texts.fetch("owner").gsub("撤销入口不得只存在于自动消失 Toast", ""),
    "rollback-source-removed" => texts.fetch("owner").gsub("失败回滚必须基于 `sourceSnapshot`、权威刷新或 conflict payload", ""),
    "late-response-removed" => texts.fetch("owner").gsub("迟到响应、重复响应或旧队列恢复不得覆盖当前对象、当前字段、当前权限或新 mutation 的可见投影", ""),
    "permission-cleanup-removed" => texts.fetch("owner").gsub("权限降级、租户/工作区切换、对象删除、能力关闭、认证过期、版本冲突或 owner 卸载后，旧乐观投影、旧撤销入口、旧回滚依据、旧错误、旧成功提示、旧 aria-label、旧计时器和旧请求回调必须失效或重新证明安全", ""),
    "runtime-boundary-marked-verified" => texts.fetch("owner").gsub("未验证", "已验证")
  }.each do |name, mutated_owner|
    expect_failure(name) { audit(texts.merge("owner" => mutated_owner)) }
  end

  expect_failure("missing-skill-route") do
    audit(texts.merge("skill" => texts.fetch("skill").gsub("references/optimistic-update-undo.md", "references/missing.md")))
  end

  expect_failure("missing-readme-link") do
    audit(texts.merge("readme" => texts.fetch("readme").gsub("references/optimistic-update-undo.md", "references/missing.md")))
  end

  expect_failure("missing-handoff-section") do
    audit(texts.merge("handoff" => texts.fetch("handoff").gsub("### 乐观更新、撤销与回滚", "### 乐观更新")))
  end

  expect_failure("project-leak") do
    audit(texts.merge("owner" => "#{texts.fetch("owner")}\nfex-admin\n"))
  end
end

puts "PASS: 乐观更新、撤销与回滚 owner、路由和证据符合结构化审计契约。"
