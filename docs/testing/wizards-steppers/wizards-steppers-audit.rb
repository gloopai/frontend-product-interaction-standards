#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/wizards-steppers.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/wizards-steppers/green-summary.md")
RED = File.join(ROOT, "docs/testing/wizards-steppers/red-summary.md")

RULE_IDS = %w[
  WIZ-SCOPE-01 WIZ-SCOPE-02 WIZ-SCOPE-03 WIZ-SCOPE-04 WIZ-SCOPE-05
  WIZ-STEP-01 WIZ-STEP-02 WIZ-STEP-03 WIZ-STEP-04 WIZ-STEP-05
  WIZ-NAV-01 WIZ-NAV-02 WIZ-NAV-03 WIZ-NAV-04 WIZ-NAV-05
  WIZ-DRAFT-01 WIZ-DRAFT-02 WIZ-DRAFT-03 WIZ-DRAFT-04 WIZ-DRAFT-05
  WIZ-VALID-01 WIZ-VALID-02 WIZ-VALID-03 WIZ-VALID-04 WIZ-VALID-05
  WIZ-REVIEW-01 WIZ-REVIEW-02 WIZ-REVIEW-03 WIZ-REVIEW-04 WIZ-REVIEW-05
  WIZ-RESULT-01 WIZ-RESULT-02 WIZ-RESULT-03 WIZ-RESULT-04 WIZ-RESULT-05
  WIZ-PERM-01 WIZ-PERM-02 WIZ-PERM-03 WIZ-PERM-04 WIZ-PERM-05
  WIZ-RSP-01 WIZ-RSP-02 WIZ-RSP-03 WIZ-RSP-04 WIZ-RSP-05
  WIZ-A11Y-01 WIZ-A11Y-02 WIZ-A11Y-03 WIZ-A11Y-04 WIZ-A11Y-05
  WIZ-LIFE-01 WIZ-LIFE-02 WIZ-LIFE-03 WIZ-LIFE-04 WIZ-LIFE-05
].freeze

STATE_FIELDS = %w[
  wizardOwnerId flowKind stepRegistry currentStepId stepStates stepDrafts
  committedStepValues crossStepValidation progressPolicy reviewSnapshot
  submitSnapshot asyncTaskBinding exitPolicy responsivePolicy a11yPolicy
].freeze

OWNER_TERMS = [
  "wizardState",
  "每个步骤必须有稳定 ID、标题、进入条件、完成条件和错误归属",
  "上一步、下一步、跳过、直接跳转、保存草稿、取消和完成必须是不同意图",
  "`stepDrafts`、`committedStepValues`、`reviewSnapshot` 和 `submitSnapshot` 必须分离",
  "恢复草稿必须重新校验权限、依赖、选项有效性、文件引用、时间范围和业务版本",
  "上游步骤变化后，依赖它的后续步骤、预检、预览、费用、权限、导出范围和确认摘要必须失效或重算",
  "最终提交只能读取仍有效的 `reviewSnapshot` / `submitSnapshot`，不得读取正在编辑的草稿",
  "完成状态必须区分成功、部分成功、失败、冲突、未知、异步处理中、已取消和过期",
  "取消客户端流程不等于取消服务端任务",
  "移动端不得删除步骤标题、当前进度、步骤错误、上一步、下一步、保存/放弃草稿、复核页、取消路径、结果回执或恢复入口",
  "未验证"
].freeze

ROUTE_TERMS = [
  "分步流程",
  "配置向导",
  "步骤条",
  "保存草稿",
  "恢复草稿",
  "复核页",
  "wizard",
  "stepper",
  "multi-step form",
  "save draft",
  "resume draft",
  "review step",
  "cross-step validation",
  "references/wizards-steppers.md"
].freeze

README_TERMS = [
  "分步流程与配置向导规范",
  "分步流程与配置向导交互规范",
  "references/wizards-steppers.md",
  "wizards-steppers.md"
].freeze

HANDOFF_TERMS = [
  "### 分步流程与配置向导",
  "每个步骤必须有稳定 ID、标题、进入条件、完成条件和错误归属",
  "`stepDrafts`、`committedStepValues`、`reviewSnapshot` 和 `submitSnapshot` 必须分离",
  "取消客户端流程不等于取消服务端任务",
  "references/wizards-steppers.md"
].freeze

EVIDENCE_TERMS = [
  "wizardState",
  "wizardOwnerId",
  "flowKind",
  "stepRegistry",
  "currentStepId",
  "stepStates",
  "stepDrafts",
  "committedStepValues",
  "crossStepValidation",
  "progressPolicy",
  "reviewSnapshot",
  "submitSnapshot",
  "asyncTaskBinding",
  "exitPolicy",
  "responsivePolicy",
  "a11yPolicy",
  "取消客户端流程不等于取消服务端任务",
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
  STATE_FIELDS.each { |field| failures << "owner: wizardState missing #{field}" unless owner.include?(field) }
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
  expect_failure("missing-owner-state") do
    audit(owner: owner.gsub("wizardState", "flowState"),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-step-contract") do
    audit(owner: owner.gsub("每个步骤必须有稳定 ID、标题、进入条件、完成条件和错误归属", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("merged-navigation-intents") do
    audit(owner: owner.gsub("上一步、下一步、跳过、直接跳转、保存草稿、取消和完成必须是不同意图", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("snapshot-separation") do
    audit(owner: owner.gsub("`stepDrafts`、`committedStepValues`、`reviewSnapshot` 和 `submitSnapshot` 必须分离", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("resume-draft-revalidation") do
    audit(owner: owner.gsub("恢复草稿必须重新校验权限、依赖、选项有效性、文件引用、时间范围和业务版本", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("downstream-invalidation") do
    audit(owner: owner.gsub("上游步骤变化后，依赖它的后续步骤、预检、预览、费用、权限、导出范围和确认摘要必须失效或重算", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("submit-reads-draft") do
    audit(owner: owner.gsub("最终提交只能读取仍有效的 `reviewSnapshot` / `submitSnapshot`，不得读取正在编辑的草稿", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("result-state-merged") do
    audit(owner: owner.gsub("完成状态必须区分成功、部分成功、失败、冲突、未知、异步处理中、已取消和过期", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("client-cancel-as-server-cancel") do
    audit(owner: owner.gsub("取消客户端流程不等于取消服务端任务", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-flow-loss") do
    audit(owner: owner.gsub("移动端不得删除步骤标题、当前进度、步骤错误、上一步、下一步、保存/放弃草稿、复核页、取消路径、结果回执或恢复入口", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-route") do
    audit(owner: owner, skill: skill.gsub("references/wizards-steppers.md", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("project-leak") do
    audit(owner: "#{owner}\nfex-admin", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "wizards-steppers audit passed"
