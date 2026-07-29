#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/trash-restore-retention.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/trash-restore-retention/green-summary.md")
RED = File.join(ROOT, "docs/testing/trash-restore-retention/red-summary.md")

STATE_FIELDS = %w[
  trashOwnerId objectIdentity lifecycleKind deletedState sourceSnapshot
  retentionPolicy restorePolicy purgePolicy visibilityPolicy availabilityMap
  permissionBoundary requestIdentity resultReceipt auditBinding feedbackBinding
  navigationBinding responsivePolicy lifecycleDisposal runtimeVerification
].freeze

OWNER_TERMS = [
  "trashRestoreState",
  "删除不是一个按钮点击，也不是一个 Toast",
  "删除、归档、禁用和永久删除不是同一件事",
  "Toast 撤销不等于完整恢复能力",
  "恢复入口可以在回收站、已删除视图、详情页、审计详情、任务结果或权限允许的全局搜索中出现",
  "保留期必须用绝对时间、展示时区和规则来源表达",
  "legal hold 或合规冻结优先于用户删除和到期清理",
  "旧列表行、旧详情、旧预览、旧下载链接、旧复制链接、旧菜单项、旧批量选择、旧导出范围、旧搜索结果、旧 URL、旧 Toast/Notification、旧 aria-label 和旧焦点目标必须失效或重算",
  "无权限状态不得泄露已删除对象名称、数量、字段、文件名、路径、删除原因、操作者、删除时间、保留期、恢复状态、内部 ID、旧 URL、旧 aria-label、旧 tooltip、旧错误明细或旧缓存",
  "Toast、Notification 或 Snackbar 不能作为唯一审计回执、唯一恢复入口、唯一失败说明或唯一未知结果处理",
  "移动端不得删除回收站入口",
  "未验证"
].freeze

ROUTE_TERMS = [
  "删除后恢复",
  "软删除",
  "回收站",
  "永久删除",
  "保留期",
  "法律保留",
  "trash",
  "soft delete",
  "restore",
  "permanent delete",
  "retention",
  "legal hold",
  "references/trash-restore-retention.md"
].freeze

README_TERMS = [
  "回收站、软删除、归档恢复与保留期规范",
  "references/trash-restore-retention.md",
  "trashRestoreState"
].freeze

HANDOFF_TERMS = [
  "### 回收站、软删除、归档恢复与保留期",
  "trashRestoreState",
  "删除不是一个按钮点击，也不是一个 Toast",
  "references/trash-restore-retention.md"
].freeze

ADJACENT_FILES = %w[
  references/risk-actions.md
  references/status-lifecycle-transitions.md
  references/row-contextual-actions.md
  references/bulk-actions-batch-operations.md
  references/list-result-controls.md
  references/empty-first-run-zero-results.md
  references/permissions-tenancy-visibility.md
  references/audit-log-activity-history.md
  references/async-jobs-task-center.md
  references/global-feedback.md
].freeze

EVIDENCE_TERMS = [
  "trashRestoreState",
  "soft delete",
  "archive",
  "disable",
  "permanent delete",
  "legal hold",
  "Toast",
  "保留期",
  "旧列表",
  "无权限",
  "未验证"
].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)

  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label} missing required term: #{term}" }
end

def owner_failures(owner)
  failures = []
  STATE_FIELDS.each { |field| failures << "owner missing trashRestoreState field: #{field}" unless owner.include?(field) }
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end

def adjacent_failures
  ADJACENT_FILES.flat_map do |relative|
    text = read(File.join(ROOT, relative))
    failures = []
    failures << "#{relative} missing references/trash-restore-retention.md" unless text.include?("references/trash-restore-retention.md")
    failures << "#{relative} missing trashRestoreState" unless text.include?("trashRestoreState")
    failures
  end
end

def integration_failures(skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(require_terms(skill, ROUTE_TERMS, "SKILL route"))
  failures.concat(require_terms(readme, README_TERMS, "README"))
  failures.concat(require_terms(handoff, HANDOFF_TERMS, "HANDOFF"))
  failures.concat(require_terms(green, EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(red, EVIDENCE_TERMS, "RED evidence"))
  failures.concat(adjacent_failures)
  failures
end

def project_leak_failures(*texts)
  banned_terms = ["fex-admin", "/Users/evanqi/code/", "src/pages", "Ant Design", "ant-design", "shadcn", "Next.js", "Vite", "React", "Vue"]
  texts.each_with_index.flat_map do |text, index|
    banned_terms.select { |term| text.include?(term) }.map { |term| "checked text #{index} contains project-specific leak: #{term}" }
  end
end

def audit(owner:, skill:, readme:, handoff:, green:, red:)
  owner_failures(owner) +
    integration_failures(skill: skill, readme: readme, handoff: handoff, green: green, red: red) +
    project_leak_failures(owner, green, red)
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
  expect_failure("missing-state") do
    audit(owner: owner.gsub("trashRestoreState", "trashState"), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("toast-delete-boundary-removed") do
    audit(owner: owner.gsub("删除不是一个按钮点击，也不是一个 Toast", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("lifecycle-distinction-removed") do
    audit(owner: owner.gsub("删除、归档、禁用和永久删除不是同一件事", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("toast-undo-treated-as-restore") do
    audit(owner: owner.gsub("Toast 撤销不等于完整恢复能力", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("retention-proof-removed") do
    audit(owner: owner.gsub("保留期必须用绝对时间、展示时区和规则来源表达", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("legal-hold-removed") do
    audit(owner: owner.gsub("legal hold 或合规冻结优先于用户删除和到期清理", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("stale-entry-cleanup-removed") do
    audit(owner: owner.gsub("旧列表行、旧详情、旧预览、旧下载链接、旧复制链接、旧菜单项、旧批量选择、旧导出范围、旧搜索结果、旧 URL、旧 Toast/Notification、旧 aria-label 和旧焦点目标必须失效或重算", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("permission-leak-allowed") do
    audit(owner: owner.gsub("无权限状态不得泄露已删除对象名称、数量、字段、文件名、路径、删除原因、操作者、删除时间、保留期、恢复状态、内部 ID、旧 URL、旧 aria-label、旧 tooltip、旧错误明细或旧缓存", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("toast-only-allowed") do
    audit(owner: owner.gsub("Toast、Notification 或 Snackbar 不能作为唯一审计回执、唯一恢复入口、唯一失败说明或唯一未知结果处理", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("mobile-entry-removed") do
    audit(owner: owner.gsub("移动端不得删除回收站入口", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("missing-skill-route") do
    audit(owner: owner, skill: skill.gsub("references/trash-restore-retention.md", ""), readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("missing-readme-link") do
    audit(owner: owner, skill: skill, readme: readme.gsub("references/trash-restore-retention.md", ""), handoff: handoff, green: green, red: red)
  end
  expect_failure("missing-handoff-section") do
    audit(owner: owner, skill: skill, readme: readme, handoff: handoff.gsub("### 回收站、软删除、归档恢复与保留期", ""), green: green, red: red)
  end
  expect_failure("project-leak") do
    audit(owner: "#{owner}\nfex-admin\n", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 回收站、软删除、归档恢复与保留期 owner、路由和证据符合结构化审计契约。"

