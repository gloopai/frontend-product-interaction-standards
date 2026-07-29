#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/status-lifecycle-transitions.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/status-lifecycle-transitions/green-summary.md")
RED = File.join(ROOT, "docs/testing/status-lifecycle-transitions/red-summary.md")

OWNER_TERMS = [
  "lifecycleState",
  "lifecycleOwnerId",
  "lifecycleSurface",
  "currentStatus",
  "targetStatus",
  "statusSource",
  "versionSnapshot",
  "transitionIntent",
  "transitionPolicy",
  "transitionResult",
  "permissionBoundary",
  "auditReceipt",
  "recoveryPolicy",
  "feedbackState",
  "a11yPolicy",
  "responsivePolicy",
  "状态 badge、按钮 loading、乐观 UI、Toast 文案或本地缓存不得伪装成已完成状态流转",
  "状态展示和状态变更不得共用一个含糊 status 字段",
  "没有冻结对象版本、权限版本、当前状态、目标状态、租户/工作区和请求身份，不得提交状态变更",
  "版本冲突、权限变化、租户切换、对象删除、状态已变化或业务限制变化时，旧意图必须失效",
  "transitionResult 必须区分 success、failure、partial-success、conflict、stale、unknown、queued、processing 和 cancelled-client-only",
  "无权限状态流转不得泄露当前状态、下一步动作、不可见原因、对象数量、批量影响范围、审批意见、拒绝原因、内部状态码、任务结果或旧缓存",
  "批量状态变更不得用当前页面可见行替代选择快照、筛选快照、权限版本和目标摘要",
  "移动端不得删除当前状态、状态原因、可用动作、禁用原因、确认、结果回执、审计入口或恢复路径",
  "未验证"
].freeze

ROUTE_TERMS = [
  "status lifecycle",
  "status transition",
  "record lifecycle",
  "state machine",
  "publish",
  "unpublish",
  "approve",
  "reject",
  "enable",
  "disable",
  "activate",
  "deactivate",
  "archive",
  "restore",
  "freeze",
  "unfreeze",
  "lock",
  "unlock",
  "draft",
  "published",
  "状态流转",
  "生命周期",
  "记录生命周期",
  "状态机",
  "发布",
  "下线",
  "审批",
  "审核",
  "驳回",
  "启用",
  "停用",
  "激活",
  "归档",
  "恢复",
  "冻结",
  "解冻",
  "锁定",
  "解锁",
  "草稿",
  "已发布",
  "references/status-lifecycle-transitions.md"
].freeze

SUMMARY_TERMS = [
  "状态流转与记录生命周期",
  "status lifecycle",
  "status transition",
  "record lifecycle",
  "发布/下线",
  "审批/驳回",
  "启停",
  "归档/恢复",
  "冻结/解冻",
  "锁定/解锁",
  "状态模型",
  "转换意图",
  "版本快照",
  "结果状态",
  "冲突恢复",
  "权限无泄露",
  "审计回执",
  "批量快照",
  "移动端承载",
  "references/status-lifecycle-transitions.md"
].freeze

EVIDENCE_TERMS = [
  "lifecycleState",
  "lifecycleOwnerId",
  "currentStatus",
  "versionSnapshot",
  "transitionIntent",
  "transitionPolicy",
  "transitionResult",
  "状态 badge、按钮 loading",
  "状态展示和状态变更",
  "没有冻结对象版本",
  "版本冲突、权限变化",
  "无权限状态流转",
  "批量状态变更",
  "当前页面可见行",
  "移动端",
  "未验证"
].freeze

PROJECT_LEAK_TERMS = [
  "fex-admin",
  "/Users/evanqi/code/fex-admin",
  "gloopai/story",
  "/Users/evanqi/code/gloopai/story"
].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)

  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def forbid_terms(text, terms, label)
  terms.select { |term| text.include?(term) }.map { |term| "#{label}: forbidden project leak #{term}" }
end

def audit(owner:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures.concat(require_terms(skill, ROUTE_TERMS, "SKILL route"))
  failures.concat(require_terms(readme, SUMMARY_TERMS, "README summary"))
  failures.concat(require_terms(handoff, SUMMARY_TERMS, "HANDOFF summary"))
  failures.concat(require_terms(green, EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(red, EVIDENCE_TERMS, "RED evidence"))
  failures.concat(forbid_terms(owner, PROJECT_LEAK_TERMS, "owner"))
  failures.concat(forbid_terms(readme, PROJECT_LEAK_TERMS, "README"))
  failures
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
  expect_failure("badge-not-transition") do
    audit(owner: owner.gsub("状态 badge、按钮 loading、乐观 UI、Toast 文案或本地缓存不得伪装成已完成状态流转", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("status-field-not-enough") do
    audit(owner: owner.gsub("状态展示和状态变更不得共用一个含糊 status 字段", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("version-snapshot-required") do
    audit(owner: owner.gsub("没有冻结对象版本、权限版本、当前状态、目标状态、租户/工作区和请求身份，不得提交状态变更", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("stale-intent-invalidated") do
    audit(owner: owner.gsub("版本冲突、权限变化、租户切换、对象删除、状态已变化或业务限制变化时，旧意图必须失效", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("result-states-distinct") do
    audit(owner: owner.gsub("transitionResult 必须区分 success、failure、partial-success、conflict、stale、unknown、queued、processing 和 cancelled-client-only", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-no-leakage") do
    audit(owner: owner.gsub("无权限状态流转不得泄露当前状态、下一步动作、不可见原因、对象数量、批量影响范围、审批意见、拒绝原因、内部状态码、任务结果或旧缓存", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("batch-snapshot-required") do
    audit(owner: owner.gsub("批量状态变更不得用当前页面可见行替代选择快照、筛选快照、权限版本和目标摘要", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-capability-preserved") do
    audit(owner: owner.gsub("移动端不得删除当前状态、状态原因、可用动作、禁用原因、确认、结果回执、审计入口或恢复路径", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-route") do
    audit(owner: owner, skill: skill.gsub("references/status-lifecycle-transitions.md", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("project-leak") do
    audit(owner: "#{owner}\nfex-admin", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 状态流转与记录生命周期规范符合结构化审计契约。"
