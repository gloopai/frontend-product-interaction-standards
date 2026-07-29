#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/async-jobs-task-center.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/async-jobs-task-center/green-summary.md")
RED = File.join(ROOT, "docs/testing/async-jobs-task-center/red-summary.md")

OWNER_TERMS = [
  "asyncJobState",
  "jobOwnerId", "jobId", "jobKind", "sourceSurface", "requestIdentity", "inputSnapshot",
  "jobPhase", "progressState", "resultState", "cancelPolicy", "retryPolicy", "artifactState",
  "notificationBinding", "auditBinding", "permissionBoundary", "responsivePolicy",
  "关闭 Dialog、Drawer、Toast、Notification、来源页面、浏览器 Tab 或移动端系统返回，只能表达客户端关闭或停止等待，不得伪装成服务端任务已取消",
  "取消请求已发送不等于任务已取消",
  "未知结果不得伪装成成功或失败",
  "Toast 和 Notification 只能辅助提醒，不能作为唯一状态、唯一错误、唯一下载入口或唯一恢复路径",
  "领取、下载、复制、重试和分享前必须复核任务身份、权限版本、租户/工作区、有效期和请求身份",
  "移动端不得删除任务中心入口、任务状态、进度、取消中、重试、结果领取、错误明细、未知结果说明、权限说明或恢复路径",
  "未验证"
].freeze

ROUTE_TERMS = [
  "async job", "background task", "job center", "task center", "异步任务", "后台任务",
  "任务中心", "任务详情", "任务进度", "任务取消", "取消中", "重跑任务", "任务重试",
  "导入任务", "导出任务", "批量任务", "报表生成", "AI 生成", "同步任务",
  "结果领取", "错误明细", "未知结果", "过期任务", "job detail", "job progress",
  "cancel job", "cancelling", "rerun job", "retry job", "import job", "export job",
  "bulk job", "report generation", "AI generation", "sync job", "result artifact",
  "error report", "unknown result", "expired job", "references/async-jobs-task-center.md"
].freeze

SUMMARY_TERMS = [
  "异步任务与任务中心",
  "async job",
  "导入导出任务",
  "批量任务",
  "报表生成",
  "AI 生成",
  "同步任务",
  "任务身份",
  "取消/重试",
  "未知结果",
  "任务中心恢复",
  "结果产物",
  "权限复核",
  "references/async-jobs-task-center.md"
].freeze

EVIDENCE_TERMS = [
  "asyncJobState",
  "jobOwnerId",
  "jobId",
  "关闭 Dialog、Drawer、Toast、Notification、来源页面、浏览器 Tab 或移动端系统返回",
  "取消请求已发送不等于任务已取消",
  "未知结果不得伪装成成功或失败",
  "Toast 和 Notification 只能辅助提醒",
  "唯一状态、唯一错误、唯一下载入口或唯一恢复路径",
  "领取、下载、复制、重试和分享前必须复核任务身份、权限版本、租户/工作区、有效期和请求身份",
  "成功、失败、跳过、冲突和未知",
  "无权限状态",
  "旧缓存",
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
  terms.select { |term| text.include?(term) }.map { |term| "#{label}: forbidden project-specific term #{term}" }
end

def audit(owner:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures.concat(require_terms(skill, ROUTE_TERMS, "skill route"))
  failures.concat(require_terms(readme, SUMMARY_TERMS, "README"))
  failures.concat(require_terms(handoff, SUMMARY_TERMS, "HANDOFF"))
  failures.concat(require_terms(green, EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(red, EVIDENCE_TERMS, "RED evidence"))
  failures.concat(forbid_terms(owner, PROJECT_LEAK_TERMS, "owner"))
  failures.concat(forbid_terms(green, PROJECT_LEAK_TERMS, "GREEN evidence"))
  failures.concat(forbid_terms(red, PROJECT_LEAK_TERMS, "RED evidence"))
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
  expect_failure("close-does-not-cancel-server-job") do
    audit(owner: owner.gsub("关闭 Dialog、Drawer、Toast、Notification、来源页面、浏览器 Tab 或移动端系统返回，只能表达客户端关闭或停止等待，不得伪装成服务端任务已取消", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("cancel-request-not-cancelled") do
    audit(owner: owner.gsub("取消请求已发送不等于任务已取消", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("unknown-not-success-or-failure") do
    audit(owner: owner.gsub("未知结果不得伪装成成功或失败", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("toast-not-sole-owner") do
    audit(owner: owner.gsub("Toast 和 Notification 只能辅助提醒，不能作为唯一状态、唯一错误、唯一下载入口或唯一恢复路径", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("artifact-permission-recertification") do
    audit(owner: owner.gsub("领取、下载、复制、重试和分享前必须复核任务身份、权限版本、租户/工作区、有效期和请求身份", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-capability-preserved") do
    audit(owner: owner.gsub("移动端不得删除任务中心入口、任务状态、进度、取消中、重试、结果领取、错误明细、未知结果说明、权限说明或恢复路径", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"),
          skill: skill, readme: readme, handoff: handoff,
          green: green.gsub("未验证", "已验证"),
          red: red.gsub("未验证", "已验证"))
  end

  expect_failure("missing-route") do
    audit(owner: owner, skill: skill.gsub("references/async-jobs-task-center.md", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("project-leak") do
    audit(owner: "#{owner}\nfex-admin", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 异步任务与任务中心 owner、路由、摘要和证据符合结构化审计契约。"
