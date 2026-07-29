#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/selection-controls.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/selection-controls/green-summary.md")
RED = File.join(ROOT, "docs/testing/selection-controls/red-summary.md")

OWNER_TERMS = [
  "selectionControlState",
  "controlOwnerId", "controlKind", "optionSet", "draftValue", "committedValue", "commitMode",
  "indeterminateState", "permissionState", "riskPolicy", "feedbackState", "a11yPolicy", "responsivePolicy",
  "`draftValue` 与 `committedValue` 必须分离",
  "Hover、focus、active、pressed visual、disabled、indeterminate 和 optimistic preview 不得伪装成已提交业务值",
  "Switch/Toggle 只能表达可逆、低风险且文案能明确表达开/关后果的设置",
  "危险启停、权限变更、敏感导出、任务取消/重跑、密钥、外部系统影响和不可逆状态必须进入 `risk-actions.md`",
  "确认完成前请求数为 0，且开关状态不得提前翻转为成功",
  "三态 checkbox 的 `indeterminateState` 不能作为可提交业务值",
  "Radio Group、Checkbox Group、Toggle Group 和 Segmented Control 必须有组 label 或等价可访问名称",
  "禁用选项必须保留可发现原因",
  "移动端不得删除选项、禁用原因、错误说明、保存/取消、恢复路径或当前已选摘要",
  "未验证"
].freeze

ROUTE_TERMS = [
  "Checkbox", "Checkbox Group", "Radio", "Radio Group", "Switch", "Toggle",
  "Toggle Group", "Segmented Control", "三态 checkbox", "复选框", "开关", "分段控件",
  "checkbox", "radio group", "switch", "toggle group", "segmented control", "tri-state checkbox",
  "references/selection-controls.md"
].freeze

SUMMARY_TERMS = [
  "选择控件与开关",
  "Checkbox",
  "Radio",
  "Switch",
  "Toggle",
  "Segmented Control",
  "三态 checkbox",
  "草稿/提交分离",
  "风险转交",
  "禁用原因",
  "references/selection-controls.md"
].freeze

EVIDENCE_TERMS = [
  "selectionControlState",
  "draftValue",
  "committedValue",
  "Hover、focus、active、pressed visual、disabled、indeterminate",
  "Switch/Toggle",
  "risk-actions.md",
  "确认完成前请求数为 0",
  "indeterminateState",
  "组 label",
  "禁用选项必须保留可发现原因",
  "移动端不得删除选项",
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
  expect_failure("draft-committed-separation") do
    audit(owner: owner.gsub("`draftValue` 与 `committedValue` 必须分离", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("visual-state-not-committed") do
    audit(owner: owner.gsub("Hover、focus、active、pressed visual、disabled、indeterminate 和 optimistic preview 不得伪装成已提交业务值", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("risk-switch-owner") do
    audit(owner: owner.gsub("危险启停、权限变更、敏感导出、任务取消/重跑、密钥、外部系统影响和不可逆状态必须进入 `risk-actions.md`", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("request-before-confirmation") do
    audit(owner: owner.gsub("确认完成前请求数为 0，且开关状态不得提前翻转为成功", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("indeterminate-not-committed") do
    audit(owner: owner.gsub("三态 checkbox 的 `indeterminateState` 不能作为可提交业务值", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("group-label-required") do
    audit(owner: owner.gsub("Radio Group、Checkbox Group、Toggle Group 和 Segmented Control 必须有组 label 或等价可访问名称", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("disabled-reason-required") do
    audit(owner: owner.gsub("禁用选项必须保留可发现原因", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-capability-preserved") do
    audit(owner: owner.gsub("移动端不得删除选项、禁用原因、错误说明、保存/取消、恢复路径或当前已选摘要", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"),
          skill: skill, readme: readme, handoff: handoff,
          green: green.gsub("未验证", "已验证"),
          red: red.gsub("未验证", "已验证"))
  end

  expect_failure("missing-route") do
    audit(owner: owner, skill: skill.gsub("references/selection-controls.md", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("project-leak") do
    audit(owner: "#{owner}\nfex-admin", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 选择控件与开关 owner、路由、摘要和证据符合结构化审计契约。"
