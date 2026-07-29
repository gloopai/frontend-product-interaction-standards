#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/approval-workflows.md")
STATUS = File.join(ROOT, "references/status-lifecycle-transitions.md")
RISK = File.join(ROOT, "references/risk-actions.md")
MEMBERS = File.join(ROOT, "references/members-invitations-access.md")
FORMS = File.join(ROOT, "references/forms.md")
BUTTONS = File.join(ROOT, "references/buttons.md")
TABLES = File.join(ROOT, "references/data-tables.md")
NOTIFICATIONS = File.join(ROOT, "references/notifications-message-center-announcements.md")
AUDIT = File.join(ROOT, "references/audit-log-activity-history.md")
PERMISSIONS = File.join(ROOT, "references/permissions-tenancy-visibility.md")
GLOBAL_FEEDBACK = File.join(ROOT, "references/global-feedback.md")
RESPONSIVE = File.join(ROOT, "references/responsive-adaptive.md")
ADMIN = File.join(ROOT, "references/admin-console.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/approval-workflows/green-summary.md")
RED = File.join(ROOT, "docs/testing/approval-workflows/red-summary.md")

STATE_FIELDS = %w[
  workflowInstanceId approvalSurface approvalObjectSnapshot currentStepBinding
  approverBinding decisionIntent commentPolicy attachmentPolicy assignmentPolicy
  delegationPolicy batchApprovalSnapshot notificationBinding auditBinding
  permissionBoundary feedbackState responsivePolicy runtimeVerification
].freeze

OWNER_TERMS = [
  "approvalWorkflowState",
  "审批动作不是普通状态按钮",
  "提交审批、通过、驳回、撤回、转交、加签、委托、催办和批量审批只能读取已冻结 `decisionIntent`",
  "会签、串签、或签、多级审批和条件分支必须展示当前节点、已完成节点、待处理人、下一节点是否已知、剩余完成条件和冲突恢复",
  "审批意见不是普通备注",
  "附件上传成功不等于审批提交成功；审批提交成功不等于附件长期可下载；删除附件不等于撤回审批",
  "转交、加签、委托、代理审批和催办不是普通成员选择",
  "通知只提示待办、催办或结果，不能替代当前审批状态、审批历史、审计回执或恢复入口",
  "批量审批必须冻结 `batchApprovalSnapshot`",
  "未知结果不得伪装成审批成功、驳回成功、撤回成功、转交成功、加签成功、委托成功或催办成功",
  "无权限或权限降级不得泄露审批对象名称、申请人、审批人、代理人、意见、附件名、节点名称、节点数量、下一节点、拒绝原因、内部状态码、任务结果、通知标题、审计摘要、旧缓存或 ARIA label",
  "移动端可以把审批历史、节点详情、附件列表和批量分布折叠或转为 Drawer / Bottom Sheet / 独立页，但不得删除当前节点、审批对象摘要、审批人/候选人安全摘要、意见要求、附件状态、提交/取消、结果回执、通知关系、审计入口和恢复路径",
  "未验证"
].freeze

ROUTE_TERMS = [
  "审批", "审核", "提交审批", "提交审核", "撤回审批", "审批通过", "审核通过",
  "驳回", "拒绝", "转交", "加签", "会签", "串签", "或签",
  "委托审批", "代理审批", "催办", "审批意见", "审批备注", "审批附件",
  "审批历史", "审批节点", "待办审批", "批量审批", "approval workflow",
  "review workflow", "submit for approval", "approve", "reject", "withdraw approval",
  "delegate approval", "reassign approval", "add approver", "approval comment",
  "approval history", "approval task", "references/approval-workflows.md"
].freeze

ADJACENT_TERMS = ["references/approval-workflows.md", "approval-workflows.md"].freeze
README_TERMS = ["审批与审核工作流规范", "references/approval-workflows.md"].freeze
HANDOFF_TERMS = [
  "### 审批与审核工作流",
  "approvalWorkflowState",
  "审批动作不是普通状态按钮",
  "通知只提示待办、催办或结果，不能替代当前审批状态、审批历史、审计回执或恢复入口",
  "references/approval-workflows.md"
].freeze
EVIDENCE_TERMS = STATE_FIELDS + ["approvalWorkflowState", "decisionIntent", "batchApprovalSnapshot", "commentPolicy", "未验证"]
PROJECT_BANNED_TERMS = ["fex-admin", "/Users/evanqi/code/", "src/pages", "Ant Design", "ant-design", "shadcn", "Next.js", "Vite", "React", "Vue"].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)
  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def owner_failures(owner)
  STATE_FIELDS.reject { |field| owner.include?(field) }.map { |field| "owner: approvalWorkflowState missing #{field}" } +
    require_terms(owner, OWNER_TERMS, "owner")
end

def integration_failures(texts)
  failures = []
  %w[status risk members forms buttons tables notifications audit permissions global_feedback responsive admin].each do |key|
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
  "status" => read(STATUS),
  "risk" => read(RISK),
  "members" => read(MEMBERS),
  "forms" => read(FORMS),
  "buttons" => read(BUTTONS),
  "tables" => read(TABLES),
  "notifications" => read(NOTIFICATIONS),
  "audit" => read(AUDIT),
  "permissions" => read(PERMISSIONS),
  "global_feedback" => read(GLOBAL_FEEDBACK),
  "responsive" => read(RESPONSIVE),
  "admin" => read(ADMIN),
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
    "missing-owner-state" => texts.fetch("owner").gsub("approvalWorkflowState", "approval-workflow-state"),
    "ordinary-status-button" => texts.fetch("owner").gsub("审批动作不是普通状态按钮", ""),
    "decision-intent-removed" => texts.fetch("owner").gsub("提交审批、通过、驳回、撤回、转交、加签、委托、催办和批量审批只能读取已冻结 `decisionIntent`", ""),
    "step-visibility-removed" => texts.fetch("owner").gsub("会签、串签、或签、多级审批和条件分支必须展示当前节点、已完成节点、待处理人、下一节点是否已知、剩余完成条件和冲突恢复", ""),
    "comment-boundary-removed" => texts.fetch("owner").gsub("审批意见不是普通备注", ""),
    "attachment-boundary-removed" => texts.fetch("owner").gsub("附件上传成功不等于审批提交成功；审批提交成功不等于附件长期可下载；删除附件不等于撤回审批", ""),
    "assignment-boundary-removed" => texts.fetch("owner").gsub("转交、加签、委托、代理审批和催办不是普通成员选择", ""),
    "notification-boundary-removed" => texts.fetch("owner").gsub("通知只提示待办、催办或结果，不能替代当前审批状态、审批历史、审计回执或恢复入口", ""),
    "bulk-snapshot-removed" => texts.fetch("owner").gsub("批量审批必须冻结 `batchApprovalSnapshot`", ""),
    "unknown-mislabelled" => texts.fetch("owner").gsub("未知结果不得伪装成审批成功、驳回成功、撤回成功、转交成功、加签成功、委托成功或催办成功", ""),
    "permission-leakage-allowed" => texts.fetch("owner").gsub("无权限或权限降级不得泄露审批对象名称、申请人、审批人、代理人、意见、附件名、节点名称、节点数量、下一节点、拒绝原因、内部状态码、任务结果、通知标题、审计摘要、旧缓存或 ARIA label", ""),
    "mobile-core-removed" => texts.fetch("owner").gsub("移动端可以把审批历史、节点详情、附件列表和批量分布折叠或转为 Drawer / Bottom Sheet / 独立页，但不得删除当前节点、审批对象摘要、审批人/候选人安全摘要、意见要求、附件状态、提交/取消、结果回执、通知关系、审计入口和恢复路径", ""),
    "runtime-boundary-marked-verified" => texts.fetch("owner").gsub("未验证", "已验证")
  }.each do |name, mutated_owner|
    expect_failure(name) { audit(texts.merge("owner" => mutated_owner)) }
  end

  expect_failure("missing-route") { audit(texts.merge("skill" => texts.fetch("skill").gsub("references/approval-workflows.md", ""))) }
  expect_failure("missing-adjacent-link") { audit(texts.merge("status" => texts.fetch("status").gsub("references/approval-workflows.md", ""))) }
  expect_failure("project-specific-leakage") { audit(texts.merge("owner" => "#{texts.fetch("owner")}\nfex-admin")) }
end

puts "PASS: 审批与审核工作流 owner、路由和证据符合结构化审计契约。"
