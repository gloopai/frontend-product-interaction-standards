#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/global-feedback.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/global-feedback/green-summary.md")
RED = File.join(ROOT, "docs/testing/global-feedback/red-summary.md")

RULE_IDS = %w[
  GF-SCOPE-01 GF-SCOPE-02 GF-SCOPE-03 GF-SCOPE-04
  GF-STATE-01 GF-STATE-02 GF-STATE-03 GF-STATE-04
  GF-CHANNEL-01 GF-CHANNEL-02 GF-CHANNEL-03 GF-CHANNEL-04 GF-CHANNEL-05
  GF-TOAST-01 GF-TOAST-02 GF-TOAST-03 GF-TOAST-04 GF-TOAST-05
  GF-LIFE-01 GF-LIFE-02 GF-LIFE-03 GF-LIFE-04
  GF-STACK-01 GF-STACK-02 GF-STACK-03 GF-STACK-04
  GF-RECOVERY-01 GF-RECOVERY-02 GF-RECOVERY-03 GF-RECOVERY-04
  GF-PERM-01 GF-PERM-02 GF-PERM-03 GF-PERM-04
  GF-A11Y-01 GF-A11Y-02 GF-A11Y-03 GF-A11Y-04 GF-A11Y-05
].freeze

STATE_FIELDS = %w[
  messageId channel severity sourceOwner resultBinding durationPolicy dismissPolicy
  announcementPolicy dedupeKey sensitiveBoundary recoveryActions
].freeze

OWNER_TERMS = [
  "feedbackMessageState",
  "全局反馈不能降级为 `showToast(text)`",
  "没有 `sourceOwner` 和 `resultBinding` 的消息不得承载业务结果",
  "危险操作不能只用 Toast 作为唯一回执",
  "部分成功、部分失败、未知结果、冲突和需要检查状态的异步任务不能只用 Toast 作为唯一回执",
  "权限失败、认证失败、网络失败和服务不可用不能只用 Toast 表示",
  "导入导出任务、错误明细下载、长耗时任务和可取消任务不能只在自动消失 Toast 中呈现",
  "关闭 Toast 只关闭客户端消息",
  "同一 `dedupeKey` 的重复消息必须更新、合并或忽略",
  "全局反馈不得泄露无权对象名称",
  "移动端 Toast / Snackbar 不得遮挡底部主操作",
  "未验证"
].freeze

ROUTE_TERMS = ["Toast", "全局提示", "通知", "Alert", "Banner", "Snackbar", "操作回执", "toast", "notification", "global feedback", "references/global-feedback.md"].freeze
README_TERMS = ["全局反馈与通知规范", "references/global-feedback.md"].freeze
HANDOFF_TERMS = ["### 全局反馈与通知", "references/global-feedback.md", "showToast(text)", "不能只用 Toast 作为唯一回执"].freeze
EVIDENCE_TERMS = ["feedbackMessageState", "showToast(text)", "sourceOwner", "resultBinding", "Toast", "dedupeKey", "sensitiveBoundary", "移动端 Toast", "未验证"].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)

  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def audit(owner:, skill:, readme:, handoff:, green:, red:)
  failures = []
  RULE_IDS.each { |id| failures << "owner: missing rule id #{id}" unless owner.include?(id) }
  STATE_FIELDS.each { |field| failures << "owner: feedbackMessageState missing #{field}" unless owner.include?(field) }
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures.concat(require_terms(skill, ROUTE_TERMS, "SKILL route"))
  failures.concat(require_terms(readme, README_TERMS, "README"))
  failures.concat(require_terms(handoff, HANDOFF_TERMS, "HANDOFF"))
  failures.concat(require_terms(green, EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(red, EVIDENCE_TERMS, "RED evidence"))
  ["fex-admin", "/Users/evanqi/code/", "src/pages", "Ant Design", "ant-design", "shadcn", "Next.js", "Vite"].each do |term|
    failures << "owner: must stay project-agnostic, found #{term.inspect}" if owner.include?(term)
  end
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
  expect_failure("show-toast-model") { audit(owner: owner.gsub("全局反馈不能降级为 `showToast(text)`", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("result-binding-removed") { audit(owner: owner.gsub("没有 `sourceOwner` 和 `resultBinding` 的消息不得承载业务结果", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("danger-toast-only") { audit(owner: owner.gsub("危险操作不能只用 Toast 作为唯一回执", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("partial-toast-only") { audit(owner: owner.gsub("部分成功、部分失败、未知结果、冲突和需要检查状态的异步任务不能只用 Toast 作为唯一回执", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("permission-toast-only") { audit(owner: owner.gsub("权限失败、认证失败、网络失败和服务不可用不能只用 Toast 表示", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("task-auto-toast-only") { audit(owner: owner.gsub("导入导出任务、错误明细下载、长耗时任务和可取消任务不能只在自动消失 Toast 中呈现", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("toast-close-as-cancel") { audit(owner: owner.gsub("关闭 Toast 只关闭客户端消息", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("dedupe-removed") { audit(owner: owner.gsub("同一 `dedupeKey` 的重复消息必须更新、合并或忽略", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("sensitive-leakage") { audit(owner: owner.gsub("全局反馈不得泄露无权对象名称", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("mobile-obstruction") { audit(owner: owner.gsub("移动端 Toast / Snackbar 不得遮挡底部主操作", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("runtime-boundary-marked-verified") { audit(owner: owner.gsub("未验证", "已验证"), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
end

puts "PASS: 全局反馈 owner、路由、摘要和证据符合结构化审计契约。"
