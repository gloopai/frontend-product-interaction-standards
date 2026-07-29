#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/page-toolbars-actions.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/page-toolbars-actions/green-summary.md")
RED = File.join(ROOT, "docs/testing/page-toolbars-actions/red-summary.md")

OWNER_TERMS = [
  "toolbarState",
  "toolbarOwnerId",
  "primaryActionPolicy",
  "secondaryActionPolicy",
  "resultBinding",
  "selectionBinding",
  "viewToolsPolicy",
  "permissionBoundary",
  "responsivePolicy",
  "页面主操作只能有一个 primary owner",
  "不得被埋进无标签更多菜单作为唯一入口",
  "工具栏不得读取筛选草稿、旧结果、旧权限或 Select query",
  "批量操作栏只有在 Data Table 的 `resolvedTier=bulk-action` 且存在有效选择时才出现",
  "只读报表、row-action 列表、无选择状态或选择失效时不得渲染空批量条",
  "更多菜单、Tooltip、Toast 或浏览器提示不得作为唯一错误恢复、权限原因、主操作入口或导出回执",
  "权限、租户/工作区、能力开关或结果 owner 变化后，工具栏必须原子重算可见操作、禁用原因、批量条、导出入口和视图工具",
  "移动端不得删除新增、刷新、错误恢复、已选摘要、批量入口、导出恢复或主要视图工具",
  "未验证"
].freeze

ROUTE_TERMS = [
  "page toolbar",
  "action bar",
  "list toolbar",
  "result toolbar",
  "bulk toolbar",
  "view tools",
  "refresh action",
  "create action",
  "column settings",
  "density",
  "view switcher",
  "页面操作栏",
  "列表工具栏",
  "结果工具栏",
  "批量操作栏",
  "视图工具",
  "刷新操作",
  "新增操作",
  "列设置",
  "密度",
  "视图切换",
  "references/page-toolbars-actions.md"
].freeze

SUMMARY_TERMS = [
  "页面操作栏与列表工具栏",
  "toolbarState",
  "页面主操作",
  "结果绑定",
  "批量操作栏",
  "视图工具",
  "更多菜单",
  "权限收敛",
  "移动端收纳",
  "references/page-toolbars-actions.md"
].freeze

EVIDENCE_TERMS = [
  "toolbarState",
  "primary owner",
  "更多菜单",
  "筛选草稿",
  "空批量条",
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
  expect_failure("missing-owner-state") do
    audit(owner: owner.gsub("toolbarState", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("primary-action-hidden-in-more") do
    audit(owner: owner.gsub("不得被埋进无标签更多菜单作为唯一入口", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("toolbar-reads-draft-or-stale-state") do
    audit(owner: owner.gsub("工具栏不得读取筛选草稿、旧结果、旧权限或 Select query", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("empty-bulk-toolbar") do
    audit(owner: owner.gsub("只读报表、row-action 列表、无选择状态或选择失效时不得渲染空批量条", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("menu-tooltip-toast-only") do
    audit(owner: owner.gsub("更多菜单、Tooltip、Toast 或浏览器提示不得作为唯一错误恢复、权限原因、主操作入口或导出回执", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-recompute-removed") do
    audit(owner: owner.gsub("权限、租户/工作区、能力开关或结果 owner 变化后，工具栏必须原子重算可见操作、禁用原因、批量条、导出入口和视图工具", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-core-actions-removed") do
    audit(owner: owner.gsub("移动端不得删除新增、刷新、错误恢复、已选摘要、批量入口、导出恢复或主要视图工具", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-route") do
    audit(owner: owner, skill: skill.gsub("references/page-toolbars-actions.md", ""), readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("project-leak") do
    audit(owner: "#{owner}\nfex-admin", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 页面操作栏与列表工具栏规范符合结构化审计契约。"
