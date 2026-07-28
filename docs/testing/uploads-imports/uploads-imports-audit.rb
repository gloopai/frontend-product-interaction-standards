#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/uploads-imports.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/uploads-imports/green-summary.md")
RED = File.join(ROOT, "docs/testing/uploads-imports/red-summary.md")

RULE_IDS = %w[
  UPL-SCOPE-01 UPL-SCOPE-02 UPL-SCOPE-03 UPL-SCOPE-04
  UPL-PICK-01 UPL-PICK-02 UPL-PICK-03 UPL-PICK-04 UPL-PICK-05 UPL-PICK-06
  UPL-STATE-01 UPL-STATE-02 UPL-STATE-03 UPL-STATE-04 UPL-STATE-05
  UPL-ASYNC-01 UPL-ASYNC-02 UPL-ASYNC-03 UPL-ASYNC-04 UPL-ASYNC-05 UPL-ASYNC-06
  UPL-FORM-01 UPL-FORM-02 UPL-FORM-03 UPL-FORM-04 UPL-FORM-05 UPL-FORM-06
  IMP-FLOW-01 IMP-FLOW-02 IMP-FLOW-03 IMP-FLOW-04 IMP-FLOW-05 IMP-FLOW-06
  IMP-RESULT-01 IMP-RESULT-02 IMP-RESULT-03 IMP-RESULT-04 IMP-RESULT-05 IMP-RESULT-06
  UPL-PERM-01 UPL-PERM-02 UPL-PERM-03 UPL-PERM-04 UPL-PERM-05
  UPL-A11Y-01 UPL-A11Y-02 UPL-A11Y-03 UPL-A11Y-04 UPL-A11Y-05
  UPL-RSP-01 UPL-RSP-02 UPL-RSP-03 UPL-RSP-04
].freeze

STATE_FIELDS = %w[
  sessionId sourceOwner acceptedPolicy fileItems queuePhase requestIdentity resultOwner
].freeze

OWNER_TERMS = [
  "uploadSessionState",
  "importFlowState",
  "accept` 只能作为选择器提示，不能作为唯一校验",
  "无效文件不得进入待上传请求队列",
  "不得直接把服务端任务写成已取消",
  "重复点击、Enter、Space、触摸或事件重放",
  "预检结果必须区分",
  "部分成功不能只用 Toast 表示",
  "下载前必须复核权限",
  "拖拽上传不能是唯一入口",
  "未验证"
].freeze

ROUTE_TERMS = [
  "上传",
  "文件上传",
  "附件",
  "拖拽上传",
  "导入预检",
  "字段映射",
  "错误明细",
  "upload",
  "dropzone",
  "bulk import",
  "references/uploads-imports.md"
].freeze

README_TERMS = [
  "上传与导入规范",
  "references/uploads-imports.md"
].freeze

HANDOFF_TERMS = [
  "### 上传与导入",
  "references/uploads-imports.md",
  "accept` 只能作为选择器提示",
  "部分成功不能只靠 Toast"
].freeze

EVIDENCE_TERMS = [
  "accept",
  "重复上传",
  "服务端已取消",
  "导入预检",
  "部分成功",
  "错误明细下载",
  "拖拽上传不能是唯一入口",
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
  STATE_FIELDS.each { |field| failures << "owner: uploadSessionState missing #{field}" unless owner.include?(field) }
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
  if failures.empty?
    abort("mutation did not fail: #{name}")
  end

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
  expect_failure("accept-as-only-validation") do
    audit(owner: owner.gsub("accept` 只能作为选择器提示，不能作为唯一校验", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("invalid-files-enter-queue") do
    audit(owner: owner.gsub("无效文件不得进入待上传请求队列", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-session-identity") do
    audit(owner: owner.gsub("sessionId", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("duplicate-trigger-protection-removed") do
    audit(owner: owner.gsub("重复点击、Enter、Space、触摸或事件重放", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("client-cancel-as-server-cancel") do
    audit(owner: owner.gsub("不得直接把服务端任务写成已取消", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("import-preflight-removed") do
    audit(owner: owner.gsub("预检结果必须区分", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("toast-only-partial-success") do
    audit(owner: owner.gsub("部分成功不能只用 Toast 表示", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("download-permission-review-removed") do
    audit(owner: owner.gsub("下载前必须复核权限", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("drag-only-entry-allowed") do
    audit(owner: owner.gsub("拖拽上传不能是唯一入口", ""),
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

puts "PASS: 上传与导入 owner、路由、摘要和证据符合结构化审计契约。"
