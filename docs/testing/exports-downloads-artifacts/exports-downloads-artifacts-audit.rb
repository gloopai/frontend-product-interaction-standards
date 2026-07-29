#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/exports-downloads-artifacts.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/exports-downloads-artifacts/green-summary.md")
RED = File.join(ROOT, "docs/testing/exports-downloads-artifacts/red-summary.md")

OWNER_TERMS = [
  "exportState",
  "artifactState",
  "downloadIntent",
  "exportOwnerId",
  "artifactOwnerId",
  "exportSurface",
  "scopeSnapshot",
  "artifactIdentity",
  "permissionBoundary",
  "expiryPolicy",
  "sensitiveFieldPolicy",
  "deliveryReceipt",
  "recoveryPolicy",
  "feedbackState",
  "a11yPolicy",
  "responsivePolicy",
  "导出范围不得读取筛选草稿、未提交时间范围、Select query、active option、当前页面可见行或旧缓存",
  "创建导出、生成文件、领取产物和下载文件不得合并成一个含糊状态",
  "下载链接不得被当作权限证明；每次下载必须复核权限、租户/工作区、有效期、请求身份和产物身份",
  "旧 Notification、旧任务入口、旧 URL、旧缓存、旧文件名或旧下载链接不得绕过权限复核",
  "Toast、Snackbar、Notification 或浏览器下载提示不得作为唯一下载入口、唯一结果回执、唯一错误说明或唯一恢复路径",
  "敏感导出、审计导出、错误明细下载和跨租户/工作区产物必须说明敏感字段、范围、有效期、权限边界和审计回执",
  "部分成功、未知、过期、无权限和文件不可用不得伪装成成功",
  "移动端不得删除导出范围、文件状态、格式、有效期、权限说明、敏感字段说明、错误明细、重新生成、任务详情、审计入口或恢复路径",
  "未验证"
].freeze

ROUTE_TERMS = [
  "export",
  "download",
  "artifact",
  "result artifact",
  "file delivery",
  "download link",
  "download URL",
  "CSV",
  "Excel",
  "PDF",
  "image export",
  "report export",
  "chart export",
  "audit export",
  "error report",
  "error detail",
  "expiry",
  "expires",
  "导出",
  "下载",
  "结果产物",
  "文件领取",
  "下载链接",
  "下载地址",
  "文件有效期",
  "过期文件",
  "重新生成",
  "错误明细",
  "报表导出",
  "图表导出",
  "审计导出",
  "图片导出",
  "references/exports-downloads-artifacts.md"
].freeze

SUMMARY_TERMS = [
  "导出、下载与结果产物交付",
  "export",
  "download",
  "artifact",
  "result artifact",
  "报表导出",
  "图表导出",
  "审计导出",
  "错误明细下载",
  "文件领取",
  "范围快照",
  "产物身份",
  "下载意图",
  "权限复核",
  "有效期",
  "敏感字段",
  "旧链接失效",
  "Toast 边界",
  "恢复路径",
  "移动端承载",
  "references/exports-downloads-artifacts.md"
].freeze

EVIDENCE_TERMS = [
  "exportState",
  "artifactState",
  "downloadIntent",
  "scopeSnapshot",
  "artifactIdentity",
  "导出范围不得读取筛选草稿",
  "创建导出、生成文件、领取产物和下载文件",
  "下载链接不得被当作权限证明",
  "旧 Notification、旧任务入口",
  "Toast、Snackbar、Notification",
  "敏感导出、审计导出、错误明细下载",
  "部分成功、未知、过期",
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
  expect_failure("scope-snapshot-required") do
    audit(owner: owner.gsub("导出范围不得读取筛选草稿、未提交时间范围、Select query、active option、当前页面可见行或旧缓存", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("creation-download-separated") do
    audit(owner: owner.gsub("创建导出、生成文件、领取产物和下载文件不得合并成一个含糊状态", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("download-permission-recertification") do
    audit(owner: owner.gsub("下载链接不得被当作权限证明；每次下载必须复核权限、租户/工作区、有效期、请求身份和产物身份", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("old-link-invalidated") do
    audit(owner: owner.gsub("旧 Notification、旧任务入口、旧 URL、旧缓存、旧文件名或旧下载链接不得绕过权限复核", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("toast-not-sole-download-owner") do
    audit(owner: owner.gsub("Toast、Snackbar、Notification 或浏览器下载提示不得作为唯一下载入口、唯一结果回执、唯一错误说明或唯一恢复路径", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("sensitive-field-disclosure") do
    audit(owner: owner.gsub("敏感导出、审计导出、错误明细下载和跨租户/工作区产物必须说明敏感字段、范围、有效期、权限边界和审计回执", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("result-states-distinct") do
    audit(owner: owner.gsub("部分成功、未知、过期、无权限和文件不可用不得伪装成成功", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-capability-preserved") do
    audit(owner: owner.gsub("移动端不得删除导出范围、文件状态、格式、有效期、权限说明、敏感字段说明、错误明细、重新生成、任务详情、审计入口或恢复路径", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-route") do
    audit(owner: owner, skill: skill.gsub("references/exports-downloads-artifacts.md", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("project-leak") do
    audit(owner: "#{owner}\nfex-admin", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 导出、下载与结果产物交付规范符合结构化审计契约。"
