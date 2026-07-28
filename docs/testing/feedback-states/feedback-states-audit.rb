#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/feedback-states.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/feedback-states/green-summary.md")
RED = File.join(ROOT, "docs/testing/feedback-states/red-summary.md")

RULE_IDS = %w[
  FS-SCOPE-01 FS-SCOPE-02 FS-SCOPE-03 FS-SCOPE-04
  FS-STATE-01 FS-STATE-02 FS-STATE-03 FS-STATE-04 FS-STATE-05
  FS-LOAD-01 FS-LOAD-02 FS-LOAD-03 FS-LOAD-04 FS-LOAD-05
  FS-EMPTY-01 FS-EMPTY-02 FS-EMPTY-03 FS-EMPTY-04 FS-EMPTY-05
  FS-ERROR-01 FS-ERROR-02 FS-ERROR-03 FS-ERROR-04 FS-ERROR-05 FS-ERROR-06
  FS-RECOVERY-01 FS-RECOVERY-02 FS-RECOVERY-03 FS-RECOVERY-04 FS-RECOVERY-05
  FS-PERM-01 FS-PERM-02 FS-PERM-03 FS-PERM-04 FS-PERM-05
  FS-A11Y-01 FS-A11Y-02 FS-A11Y-03 FS-A11Y-04 FS-A11Y-05
  FS-RSP-01 FS-RSP-02 FS-RSP-03 FS-RSP-04
].freeze

STATE_FIELDS = %w[
  ownerId surfaceKind phase dataPresence errorKind permissionScope stale partial
  messageOwner recoveryActions announcementPolicy sensitiveBoundary
].freeze

OWNER_TERMS = [
  "feedbackState",
  "不能只散落在 `loading`、`error`、`empty` 三个布尔值里",
  "Skeleton 不得包含可操作假数据",
  "空状态不能用“暂无数据”糊住所有情况",
  "Toast 不能作为唯一错误或结果回执",
  "刷新失败时保留旧内容",
  "无权状态不得泄露对象名称、数量、字段",
  "移动端不得删除主要恢复入口",
  "未验证"
].freeze

ROUTE_TERMS = [
  "空状态",
  "暂无数据",
  "筛选无结果",
  "骨架屏",
  "错误状态",
  "刷新失败",
  "过期数据",
  "empty state",
  "zero results",
  "skeleton",
  "stale data",
  "references/feedback-states.md"
].freeze

README_TERMS = [
  "反馈状态与状态承载规范",
  "references/feedback-states.md"
].freeze

HANDOFF_TERMS = [
  "### 反馈状态与状态承载",
  "references/feedback-states.md",
  "Toast 不能作为唯一错误或结果回执",
  "无权状态不得泄露对象名称"
].freeze

EVIDENCE_TERMS = [
  "feedbackState",
  "loading",
  "error",
  "empty",
  "Skeleton",
  "暂无数据",
  "Toast",
  "刷新失败时保留旧内容",
  "无权状态不得泄露对象名称",
  "移动端不得删除主要恢复入口",
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
  STATE_FIELDS.each { |field| failures << "owner: feedbackState missing #{field}" unless owner.include?(field) }
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
  banned_terms = ["fex-admin", "/Users/evanqi/code/", "src/pages", "Ant Design", "ant-design", "shadcn", "Next.js", "Vite"]
  banned_terms.select { |term| owner.include?(term) }.map { |term| "owner: must stay project-agnostic, found #{term.inspect}" }
end

def audit(owner:, skill:, readme:, handoff:, green:, red:)
  owner_failures(owner) + integration_failures(skill, readme, handoff, green, red) + project_leak_failures(owner)
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
  expect_failure("state-model-removed") do
    audit(owner: owner.gsub("不能只散落在 `loading`、`error`、`empty` 三个布尔值里", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("skeleton-fake-actions-allowed") do
    audit(owner: owner.gsub("Skeleton 不得包含可操作假数据", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("empty-state-distinction-removed") do
    audit(owner: owner.gsub("空状态不能用“暂无数据”糊住所有情况", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("toast-only-allowed") do
    audit(owner: owner.gsub("Toast 不能作为唯一错误或结果回执", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("refresh-failure-clears-content") do
    audit(owner: owner.gsub("刷新失败时保留旧内容", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("permission-leakage-allowed") do
    audit(owner: owner.gsub("无权状态不得泄露对象名称、数量、字段", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("mobile-recovery-removed") do
    audit(owner: owner.gsub("移动端不得删除主要恢复入口", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("project-specific-leakage") do
    audit(owner: "#{owner}\nfex-admin\n", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 反馈状态 owner、路由、摘要和证据符合结构化审计契约。"
