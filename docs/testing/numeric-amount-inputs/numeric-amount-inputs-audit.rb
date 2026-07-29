#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/numeric-amount-inputs.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/numeric-amount-inputs/green-summary.md")
RED = File.join(ROOT, "docs/testing/numeric-amount-inputs/red-summary.md")

STATE_FIELDS = %w[
  numericOwnerId fieldIdentity valueKind draftText parsedValue committedValue
  displayFormat unitBinding precisionPolicy rangePolicy stepperPolicy
  normalizationPolicy validationBinding submitSnapshotPolicy permissionBoundary
  feedbackBinding responsivePolicy focusAnnouncementPolicy lifecycleDisposal
  runtimeVerification
].freeze

OWNER_TERMS = [
  "numericInputState",
  "数字字段不是普通文本框加 `type=number`",
  "不得只用 `Number(value)`、`parseFloat`、`input[type=number]`",
  "必须把 `draftText`、`parsedValue` 和 `committedValue` 分开",
  "空值、0、负数和非法值不是同一件事",
  "金额必须声明币种；百分比必须声明提交的是",
  "单位切换不是视觉格式切换",
  "展示保留两位不等于提交也保留两位",
  "默认禁止鼠标滚轮在聚焦数字输入时改值",
  "IME composition 未结束时，不得触发提交",
  "无权限状态不得泄露金额、余额、额度、用量、阈值、单价、套餐限制、历史值、旧 aria-label 或错误明细",
  "移动端不得删除单位、币种、错误、边界说明、清空、恢复、保存、取消、只读原因或权限说明",
  "未验证"
].freeze

ROUTE_TERMS = [
  "数字输入",
  "金额输入",
  "百分比",
  "配额",
  "预算上限",
  "number input",
  "currency input",
  "percent input",
  "quota input",
  "numeric stepper",
  "references/numeric-amount-inputs.md"
].freeze

README_TERMS = [
  "数字、金额、比例与配额输入规范",
  "references/numeric-amount-inputs.md",
  "numericInputState"
].freeze

HANDOFF_TERMS = [
  "### 数字、金额、比例与配额输入",
  "numericInputState",
  "数字字段不是普通文本框加 `type=number`",
  "references/numeric-amount-inputs.md"
].freeze

ADJACENT_FILES = %w[
  references/forms.md
  references/field-guidance-help-text.md
  references/settings-preferences-configuration.md
  references/billing-subscription-invoices.md
  references/query-filters.md
  references/chart-visualization-builders.md
  references/permissions-tenancy-visibility.md
  references/risk-actions.md
].freeze

EVIDENCE_TERMS = [
  "numericInputState",
  "draftText",
  "parsedValue",
  "committedValue",
  "Number(value)",
  "parseFloat",
  "input[type=number]",
  "IME",
  "无权限",
  "移动端",
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
  STATE_FIELDS.each { |field| failures << "owner missing numericInputState field: #{field}" unless owner.include?(field) }
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end

def adjacent_failures
  ADJACENT_FILES.flat_map do |relative|
    text = read(File.join(ROOT, relative))
    failures = []
    failures << "#{relative} missing references/numeric-amount-inputs.md" unless text.include?("references/numeric-amount-inputs.md")
    failures << "#{relative} missing numericInputState" unless text.include?("numericInputState")
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
    audit(owner: owner.gsub("numericInputState", "numericState"), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("type-number-boundary-removed") do
    audit(owner: owner.gsub("数字字段不是普通文本框加 `type=number`", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("number-parse-boundary-removed") do
    audit(owner: owner.gsub("不得只用 `Number(value)`、`parseFloat`、`input[type=number]`", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("draft-parse-commit-collapsed") do
    audit(owner: owner.gsub("必须把 `draftText`、`parsedValue` 和 `committedValue` 分开", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("empty-zero-negative-invalid-collapsed") do
    audit(owner: owner.gsub("空值、0、负数和非法值不是同一件事", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("unit-switch-visual-only") do
    audit(owner: owner.gsub("单位切换不是视觉格式切换", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("precision-boundary-removed") do
    audit(owner: owner.gsub("展示保留两位不等于提交也保留两位", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("wheel-misinput-allowed") do
    audit(owner: owner.gsub("默认禁止鼠标滚轮在聚焦数字输入时改值", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("ime-boundary-removed") do
    audit(owner: owner.gsub("IME composition 未结束时，不得触发提交", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("permission-leak-allowed") do
    audit(owner: owner.gsub("无权限状态不得泄露金额、余额、额度、用量、阈值、单价、套餐限制、历史值、旧 aria-label 或错误明细", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("mobile-requirements-removed") do
    audit(owner: owner.gsub("移动端不得删除单位、币种、错误、边界说明、清空、恢复、保存、取消、只读原因或权限说明", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("missing-skill-route") do
    audit(owner: owner, skill: skill.gsub("references/numeric-amount-inputs.md", ""), readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("missing-readme-link") do
    audit(owner: owner, skill: skill, readme: readme.gsub("references/numeric-amount-inputs.md", ""), handoff: handoff, green: green, red: red)
  end
  expect_failure("missing-handoff-section") do
    audit(owner: owner, skill: skill, readme: readme, handoff: handoff.gsub("### 数字、金额、比例与配额输入", ""), green: green, red: red)
  end
  expect_failure("project-leak") do
    audit(owner: "#{owner}\nfex-admin\n", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 数字、金额、比例与配额输入 owner、路由和证据符合结构化审计契约。"

