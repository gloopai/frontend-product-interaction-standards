#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/settings-preferences-configuration.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/settings-preferences-configuration/green-summary.md")
RED = File.join(ROOT, "docs/testing/settings-preferences-configuration/red-summary.md")

OWNER_TERMS = [
  "settingsState",
  "settingsOwnerId",
  "settingsScope",
  "draftSettings",
  "savedSettings",
  "effectiveSettings",
  "defaultSettings",
  "applyMode",
  "dirtyState",
  "resetPolicy",
  "permissionBoundary",
  "resultReceipt",
  "设置项必须声明作用域和生效模式",
  "`draftSettings` 不得伪装成 `effectiveSettings`",
  "保存、取消、恢复保存值、重置默认、继承默认和清空自定义是不同意图",
  "高风险设置必须进入 `risk-actions.md`，保存前请求数为 0",
  "权限、租户/工作区、角色、对象状态或配置版本变化后，旧草稿、旧默认值、旧禁用原因、旧保存按钮和旧集成状态必须原子收敛",
  "部分成功、失败、冲突和未知结果不得伪装成成功",
  "移动端不得删除保存/取消、脏状态、作用域说明、默认值说明、继承说明、危险确认、错误摘要、审计回执或恢复路径",
  "未验证"
].freeze

ROUTE_TERMS = [
  "settings",
  "preferences",
  "configuration",
  "config page",
  "setting page",
  "preference page",
  "feature setting",
  "notification setting",
  "integration setting",
  "default setting",
  "save settings",
  "reset defaults",
  "inherit defaults",
  "设置",
  "偏好",
  "配置页",
  "设置页",
  "偏好页",
  "配置项",
  "策略配置",
  "通知设置",
  "集成设置",
  "默认设置",
  "保存设置",
  "重置默认",
  "继承默认",
  "references/settings-preferences-configuration.md"
].freeze

SUMMARY_TERMS = [
  "设置、偏好与配置页",
  "settingsState",
  "settingsScope",
  "draftSettings",
  "effectiveSettings",
  "defaultSettings",
  "applyMode",
  "重置默认",
  "权限收敛",
  "移动端承载",
  "references/settings-preferences-configuration.md"
].freeze

EVIDENCE_TERMS = [
  "settingsState",
  "settingsScope",
  "draftSettings",
  "effectiveSettings",
  "defaultSettings",
  "applyMode",
  "重置默认",
  "权限",
  "移动端",
  "未验证"
].freeze

PROJECT_LEAK_TERMS = [
  "fex-admin",
  "/Users/evanqi/code/fex-admin",
  "gloopai/story",
  "token-api",
  "dev-ops"
].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)

  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def audit(owner:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures.concat(require_terms(skill, ROUTE_TERMS, "route"))
  failures.concat(require_terms(readme, SUMMARY_TERMS, "README"))
  failures.concat(require_terms(handoff, SUMMARY_TERMS, "HANDOFF"))
  failures.concat(require_terms(green, EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(red, EVIDENCE_TERMS, "RED evidence"))

  project_leaks = PROJECT_LEAK_TERMS.select { |term| owner.include?(term) || readme.include?(term) }
  failures << "project leak: #{project_leaks.join(', ')}" unless project_leaks.empty?
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
  expect_failure("missing-settings-state") do
    audit(owner: owner.gsub("settingsState", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-settings-scope") do
    audit(owner: owner.gsub("设置项必须声明作用域和生效模式", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("draft-pretends-effective") do
    audit(owner: owner.gsub("`draftSettings` 不得伪装成 `effectiveSettings`", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("reset-intents-merged") do
    audit(owner: owner.gsub("保存、取消、恢复保存值、重置默认、继承默认和清空自定义是不同意图", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("risk-settings-bypass-risk-owner") do
    audit(owner: owner.gsub("高风险设置必须进入 `risk-actions.md`，保存前请求数为 0", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-recompute-removed") do
    audit(owner: owner.gsub("权限、租户/工作区、角色、对象状态或配置版本变化后，旧草稿、旧默认值、旧禁用原因、旧保存按钮和旧集成状态必须原子收敛", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("result-states-merged") do
    audit(owner: owner.gsub("部分成功、失败、冲突和未知结果不得伪装成成功", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-core-settings-removed") do
    audit(owner: owner.gsub("移动端不得删除保存/取消、脏状态、作用域说明、默认值说明、继承说明、危险确认、错误摘要、审计回执或恢复路径", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-route") do
    audit(owner: owner, skill: skill.gsub("references/settings-preferences-configuration.md", ""), readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("project-leak") do
    audit(owner: "#{owner}\nfex-admin", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 设置、偏好与配置页规范符合结构化审计契约。"
