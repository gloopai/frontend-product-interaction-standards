#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/audit-log-activity-history.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/audit-log-activity-history/green-summary.md")
RED = File.join(ROOT, "docs/testing/audit-log-activity-history/red-summary.md")

OWNER_TERMS = [
  "auditLogState",
  "auditOwnerId",
  "auditSurface",
  "eventIdentity",
  "actorSnapshot",
  "targetSnapshot",
  "actionSnapshot",
  "timeSemantics",
  "integrityState",
  "permissionBoundary",
  "filterSnapshot",
  "exportState",
  "feedbackState",
  "a11yPolicy",
  "responsivePolicy",
  "审计记录不是普通列表行，也不是 Toast 成功文案",
  "缺少证据身份的操作历史只能作为普通活动提示，不能写成审计日志",
  "审计日志必须区分事件发生时间、审计写入时间、展示时区、存储时区、筛选范围、数据延迟和刷新时间",
  "无权限审计不得泄露主体名称、目标名称、字段名、旧值、新值、数量、文件名、IP、设备、地理位置、错误明细、内部 ID、请求参数、导出范围、任务结果或旧缓存",
  "审计缺口、延迟、重复、顺序未决、来源不可用和修正记录必须明确说明，不能伪装成完整日志",
  "审计导出、复制、跳转、查看详情、查看关联任务、查看风险回执和追溯链路必须复核权限、租户/工作区、筛选快照、时间范围、敏感字段和请求身份",
  "移动端不得删除筛选、时间范围、时区说明、数据延迟、审计详情、追溯路径、导出权限说明、无权限说明或恢复路径",
  "未验证"
].freeze

ROUTE_TERMS = [
  "audit log",
  "activity log",
  "operation history",
  "event log",
  "change history",
  "audit detail",
  "audit export",
  "audit receipt",
  "traceability",
  "operation record",
  "login log",
  "access log",
  "timeline",
  "审计日志",
  "操作历史",
  "活动记录",
  "事件日志",
  "变更记录",
  "审计详情",
  "审计导出",
  "审计回执",
  "追溯链路",
  "操作记录",
  "登录日志",
  "访问日志",
  "时间线",
  "references/audit-log-activity-history.md"
].freeze

SUMMARY_TERMS = [
  "审计日志与操作历史",
  "audit log",
  "activity log",
  "operation history",
  "事件日志",
  "变更记录",
  "时间线",
  "证据身份",
  "主体/目标/动作快照",
  "时间语义",
  "完整性状态",
  "权限无泄露",
  "审计导出复核",
  "移动端追溯",
  "references/audit-log-activity-history.md"
].freeze

EVIDENCE_TERMS = [
  "auditLogState",
  "auditOwnerId",
  "eventIdentity",
  "actorSnapshot",
  "targetSnapshot",
  "actionSnapshot",
  "timeSemantics",
  "审计记录不是普通列表行",
  "缺少证据身份",
  "审计日志必须区分事件发生时间",
  "无权限审计不得泄露主体名称",
  "审计缺口、延迟、重复、顺序未决",
  "不能伪装成完整日志",
  "审计导出、复制、跳转",
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
  expect_failure("evidence-identity-required") do
    audit(owner: owner.gsub("缺少证据身份的操作历史只能作为普通活动提示，不能写成审计日志", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("ordinary-table-not-audit") do
    audit(owner: owner.gsub("审计记录不是普通列表行，也不是 Toast 成功文案", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("time-semantics-distinct") do
    audit(owner: owner.gsub("审计日志必须区分事件发生时间、审计写入时间、展示时区、存储时区、筛选范围、数据延迟和刷新时间", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-no-leakage") do
    audit(owner: owner.gsub("无权限审计不得泄露主体名称、目标名称、字段名、旧值、新值、数量、文件名、IP、设备、地理位置、错误明细、内部 ID、请求参数、导出范围、任务结果或旧缓存", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("integrity-gap-not-complete") do
    audit(owner: owner.gsub("审计缺口、延迟、重复、顺序未决、来源不可用和修正记录必须明确说明，不能伪装成完整日志", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("export-recertification") do
    audit(owner: owner.gsub("审计导出、复制、跳转、查看详情、查看关联任务、查看风险回执和追溯链路必须复核权限、租户/工作区、筛选快照、时间范围、敏感字段和请求身份", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-capability-preserved") do
    audit(owner: owner.gsub("移动端不得删除筛选、时间范围、时区说明、数据延迟、审计详情、追溯路径、导出权限说明、无权限说明或恢复路径", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-route") do
    audit(owner: owner, skill: skill.gsub("references/audit-log-activity-history.md", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("project-leak") do
    audit(owner: "#{owner}\nfex-admin", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 审计日志与操作历史规范符合结构化审计契约。"
