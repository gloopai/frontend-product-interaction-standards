#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/navigation-routing.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/navigation-routing/green-summary.md")
RED = File.join(ROOT, "docs/testing/navigation-routing/red-summary.md")

RULE_IDS = %w[
  NAV-SCOPE-01 NAV-SCOPE-02 NAV-SCOPE-03 NAV-SCOPE-04
  NAV-STATE-01 NAV-STATE-02 NAV-STATE-03 NAV-STATE-04 NAV-STATE-05
  NAV-RETURN-01 NAV-RETURN-02 NAV-RETURN-03 NAV-RETURN-04 NAV-RETURN-05 NAV-RETURN-06
  NAV-BLOCK-01 NAV-BLOCK-02 NAV-BLOCK-03 NAV-BLOCK-04 NAV-BLOCK-05
  NAV-STRUCT-01 NAV-STRUCT-02 NAV-STRUCT-03 NAV-STRUCT-04 NAV-STRUCT-05
  NAV-HISTORY-01 NAV-HISTORY-02 NAV-HISTORY-03 NAV-HISTORY-04 NAV-HISTORY-05
  NAV-PERM-01 NAV-PERM-02 NAV-PERM-03 NAV-PERM-04 NAV-PERM-05
  NAV-A11Y-01 NAV-A11Y-02 NAV-A11Y-03 NAV-A11Y-04 NAV-A11Y-05
  NAV-RSP-01 NAV-RSP-02 NAV-RSP-03 NAV-RSP-04
].freeze

STATE_FIELDS = %w[
  routeOwnerId currentLocation sourceContext returnPolicy historyIntent permissionVersion
  dirtyBlockers focusRestoreTarget disposalLog
].freeze

OWNER_TERMS = [
  "navigationState",
  "返回不得直接等同于 `history.back()`",
  "sourceContext",
  "returnPolicy",
  "浏览器 Back/Forward、面包屑、Tabs、菜单导航、关闭容器和外部链接都必须经过同一离开保护管线",
  "面包屑表示层级路径，不表示最近历史",
  "Tabs 只用于同一资源或同一任务上下文",
  "旧导航上下文、旧面包屑标签、旧记录名、旧返回目标、旧 URL 参数和旧焦点目标都必须重新证明安全",
  "route/unmount 后的迟到回调不得写回",
  "移动端不得删除返回、当前位置、未保存保护、权限说明或恢复路径",
  "未验证"
].freeze

ROUTE_TERMS = [
  "导航",
  "返回",
  "面包屑",
  "浏览器返回",
  "路由切换",
  "未保存离开",
  "返回列表",
  "Tabs",
  "navigation",
  "browser back",
  "route change",
  "unsaved leave",
  "references/navigation-routing.md"
].freeze

README_TERMS = [
  "导航与路由规范",
  "references/navigation-routing.md"
].freeze

HANDOFF_TERMS = [
  "### 导航与路由",
  "references/navigation-routing.md",
  "history.back()",
  "dirty blockers"
].freeze

EVIDENCE_TERMS = [
  "navigationState",
  "sourceContext",
  "returnPolicy",
  "history.back()",
  "dirtyBlockers",
  "面包屑",
  "Tabs",
  "权限",
  "route/unmount",
  "移动端不得删除返回",
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
  STATE_FIELDS.each { |field| failures << "owner: navigationState missing #{field}" unless owner.include?(field) }
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
  expect_failure("history-back-as-return-model") do
    audit(owner: owner.gsub("返回不得直接等同于 `history.back()`", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("source-context-removed") do
    audit(owner: owner.gsub("sourceContext", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("return-policy-removed") do
    audit(owner: owner.gsub("returnPolicy", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("leave-protection-pipeline-removed") do
    audit(owner: owner.gsub("浏览器 Back/Forward、面包屑、Tabs、菜单导航、关闭容器和外部链接都必须经过同一离开保护管线", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("breadcrumb-boundary-removed") do
    audit(owner: owner.gsub("面包屑表示层级路径，不表示最近历史", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("tabs-boundary-removed") do
    audit(owner: owner.gsub("Tabs 只用于同一资源或同一任务上下文", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-revalidation-removed") do
    audit(owner: owner.gsub("旧导航上下文、旧面包屑标签、旧记录名、旧返回目标、旧 URL 参数和旧焦点目标都必须重新证明安全", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("late-route-callback-removed") do
    audit(owner: owner.gsub("route/unmount 后的迟到回调不得写回", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-back-protection-removed") do
    audit(owner: owner.gsub("移动端不得删除返回、当前位置、未保存保护、权限说明或恢复路径", ""),
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

puts "PASS: 导航与路由 owner、路由、摘要和证据符合结构化审计契约。"
