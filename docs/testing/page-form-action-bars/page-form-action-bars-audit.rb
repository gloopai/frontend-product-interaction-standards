#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/page-form-action-bars.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/page-form-action-bars/green-summary.md")
RED = File.join(ROOT, "docs/testing/page-form-action-bars/red-summary.md")

STATE_FIELDS = %w[
  actionBarOwnerId formBinding saveIntentPolicy cancelIntentPolicy
  buttonPolicy layoutBoundary permissionBoundary feedbackBinding
  focusReturnPolicy responsivePolicy
].freeze

OWNER_TERMS = [
  "formActionBarState",
  "保存、提交、应用、确认、取消、返回、关闭、放弃更改、重置、保存并返回、保存并继续和保存并新建必须是不同意图",
  "页面上存在多个保存入口时，它们必须共享同一个 Form owner、同一个 `submitSnapshot`、同一个提交门禁、同一个防重复策略和同一个结果回执",
  "sticky / fixed 保存栏必须为正文提供可验证的底部避让空间",
  "最后一个字段、字段错误、帮助文本、错误摘要、上传进度、表格分页、审计回执和恢复入口不得被保存栏遮挡",
  "保存栏展示的脏状态必须来自 Forms owner 的 dirty / pristine 计算",
  "取消、返回、关闭、浏览器 Back、Tab 切换、面包屑、菜单导航和外链必须进入 Navigation owner 的同一离开保护",
  "放弃更改必须说明会丢弃哪些草稿，并在确认前请求数为 0",
  "重置更改必须回到明确的 initial/default/server-refill 状态",
  "无权或未启用时，保存按钮的 DOM、state、handler、request 和快捷键入口为 0",
  "权限、租户/工作区、对象状态、表单版本或会话状态变化后，旧保存入口、旧快捷键、旧 loading、旧错误、旧 Toast、旧 focus target 和旧回调必须失效或重新证明安全",
  "移动端不得删除保存、取消/返回、错误摘要、权限原因、脏状态说明和恢复路径",
  "虚拟键盘出现后，当前聚焦字段、字段错误、错误摘要、保存按钮、取消/返回、提交中状态和恢复入口仍必须可见或可滚动到达",
  "未验证"
].freeze

ROUTE_TERMS = [
  "页面表单操作栏", "表单操作栏", "保存栏", "保存区", "底部操作区",
  "固定底部操作", "固定保存栏", "sticky 保存栏", "sticky footer",
  "保存按钮区", "保存并返回", "保存并继续", "保存并新建",
  "取消编辑", "放弃更改", "重置更改", "脏状态条", "未保存提示条",
  "page form action bar", "form action bar", "save bar", "save area",
  "bottom action bar", "fixed footer actions", "sticky action bar",
  "sticky footer actions", "save and return", "save and continue",
  "save and create", "cancel edit", "discard changes", "reset changes",
  "dirty bar", "unsaved changes bar",
  "references/page-form-action-bars.md"
].freeze

README_TERMS = [
  "页面级表单操作栏与保存区规范",
  "references/page-form-action-bars.md"
].freeze

HANDOFF_TERMS = [
  "### 页面级表单操作栏与保存区",
  "formActionBarState",
  "保存、提交、应用、确认、取消、返回、关闭、放弃更改、重置、保存并返回、保存并继续和保存并新建必须是不同意图",
  "移动端不得删除保存、取消/返回、错误摘要、权限原因、脏状态说明和恢复路径",
  "references/page-form-action-bars.md"
].freeze

EVIDENCE_TERMS = [
  "formActionBarState", "actionBarOwnerId", "formBinding",
  "saveIntentPolicy", "cancelIntentPolicy", "buttonPolicy",
  "layoutBoundary", "permissionBoundary", "feedbackBinding",
  "focusReturnPolicy", "responsivePolicy", "保存并返回",
  "保存并继续", "保存并新建", "放弃更改", "重置更改",
  "sticky", "fixed", "最后一个字段", "错误摘要",
  "重复请求", "dirty", "Navigation owner", "无权限",
  "DOM、state、handler、request", "虚拟键盘", "移动端", "未验证"
].freeze

PROJECT_BANNED_TERMS = [
  "fex-admin",
  "/Users/evanqi/code/",
  "src/pages",
  "Ant Design",
  "ant-design",
  "shadcn",
  "Next.js",
  "Vite"
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
  STATE_FIELDS.each { |field| failures << "owner: formActionBarState missing #{field}" unless owner.include?(field) }
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
  PROJECT_BANNED_TERMS.select { |term| owner.include?(term) }.map do |term|
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
    audit(owner: owner.gsub("formActionBarState", "actionState"),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("merged-action-intents") do
    audit(owner: owner.gsub("保存、提交、应用、确认、取消、返回、关闭、放弃更改、重置、保存并返回、保存并继续和保存并新建必须是不同意图", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("duplicate-save-requests") do
    audit(owner: owner.gsub("页面上存在多个保存入口时，它们必须共享同一个 Form owner、同一个 `submitSnapshot`、同一个提交门禁、同一个防重复策略和同一个结果回执", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("sticky-footer-overlaps-content") do
    audit(owner: owner.gsub("sticky / fixed 保存栏必须为正文提供可验证的底部避让空间", "")
                      .gsub("最后一个字段、字段错误、帮助文本、错误摘要、上传进度、表格分页、审计回执和恢复入口不得被保存栏遮挡", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("dirty-derived-from-dom") do
    audit(owner: owner.gsub("保存栏展示的脏状态必须来自 Forms owner 的 dirty / pristine 计算", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("navigation-protection-bypassed") do
    audit(owner: owner.gsub("取消、返回、关闭、浏览器 Back、Tab 切换、面包屑、菜单导航和外链必须进入 Navigation owner 的同一离开保护", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("discard-without-impact") do
    audit(owner: owner.gsub("放弃更改必须说明会丢弃哪些草稿，并在确认前请求数为 0", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("reset-as-clear-all") do
    audit(owner: owner.gsub("重置更改必须回到明确的 initial/default/server-refill 状态", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-ghost-save-button") do
    audit(owner: owner.gsub("无权或未启用时，保存按钮的 DOM、state、handler、request 和快捷键入口为 0", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("stale-save-entry-survives") do
    audit(owner: owner.gsub("权限、租户/工作区、对象状态、表单版本或会话状态变化后，旧保存入口、旧快捷键、旧 loading、旧错误、旧 Toast、旧 focus target 和旧回调必须失效或重新证明安全", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("toast-only-save-receipt") do
    audit(owner: owner.gsub("旧 Toast", "旧提示"),
          skill: skill, readme: readme, handoff: handoff, green: green.gsub("Toast", ""), red: red.gsub("Toast", ""))
  end

  expect_failure("mobile-actions-removed") do
    audit(owner: owner.gsub("移动端不得删除保存、取消/返回、错误摘要、权限原因、脏状态说明和恢复路径", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("virtual-keyboard-obscures-actions") do
    audit(owner: owner.gsub("虚拟键盘出现后，当前聚焦字段、字段错误、错误摘要、保存按钮、取消/返回、提交中状态和恢复入口仍必须可见或可滚动到达", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"),
          skill: skill, readme: readme, handoff: handoff,
          green: green.gsub("未验证", "已验证"), red: red.gsub("未验证", "已验证"))
  end

  expect_failure("project-specific-leakage") do
    audit(owner: "#{owner}\nfex-admin\n", skill: skill, readme: readme, handoff: handoff,
          green: green, red: red)
  end
end

puts "PASS: 页面级表单操作栏与保存区 owner、路由、摘要和证据符合结构化审计契约。"
