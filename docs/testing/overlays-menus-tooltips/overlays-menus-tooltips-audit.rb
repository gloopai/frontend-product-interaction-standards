#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/overlays-menus-tooltips.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/overlays-menus-tooltips/green-summary.md")
RED = File.join(ROOT, "docs/testing/overlays-menus-tooltips/red-summary.md")

RULE_IDS = %w[
  OMT-SCOPE-01 OMT-SCOPE-02 OMT-SCOPE-03 OMT-SCOPE-04
  OMT-STATE-01 OMT-STATE-02 OMT-STATE-03 OMT-STATE-04 OMT-STATE-05
  OMT-CHOICE-01 OMT-CHOICE-02 OMT-CHOICE-03 OMT-CHOICE-04 OMT-CHOICE-05
  OMT-TRIGGER-01 OMT-TRIGGER-02 OMT-TRIGGER-03 OMT-TRIGGER-04 OMT-TRIGGER-05
  OMT-CONTENT-01 OMT-CONTENT-02 OMT-CONTENT-03 OMT-CONTENT-04 OMT-CONTENT-05
  OMT-MENU-01 OMT-MENU-02 OMT-MENU-03 OMT-MENU-04 OMT-MENU-05
  OMT-LAYOUT-01 OMT-LAYOUT-02 OMT-LAYOUT-03 OMT-LAYOUT-04 OMT-LAYOUT-05
  OMT-PERM-01 OMT-PERM-02 OMT-PERM-03 OMT-PERM-04 OMT-PERM-05
  OMT-A11Y-01 OMT-A11Y-02 OMT-A11Y-03 OMT-A11Y-04 OMT-A11Y-05
  OMT-RSP-01 OMT-RSP-02 OMT-RSP-03 OMT-RSP-04 OMT-RSP-05
  OMT-LIFE-01 OMT-LIFE-02 OMT-LIFE-03 OMT-LIFE-04 OMT-LIFE-05
].freeze

STATE_FIELDS = %w[
  overlayId overlayKind triggerOwner contentOwner openState placementPolicy interactionMode
  dismissPolicy focusPolicy itemStates responsivePolicy disposalLog
].freeze

OWNER_TERMS = [
  "overlayState",
  "Tooltip、Popover、Menu、Dropdown Menu、Context Menu、Action Sheet 和 mobile Drawer",
  "重要信息不得仅依赖 Hover、Tooltip、Popover 临时可见状态或 Context Menu",
  "Tooltip / Popover 不得承载唯一必读权限原因、错误、确认后果、危险操作、结果回执、审计凭证或恢复入口",
  "更多菜单不得成为隐藏权限原因、错误、确认后果或唯一恢复入口的地方",
  "Context Menu 可以作为效率入口，但不能是唯一入口",
  "菜单项不能只有“操作”“更多”“处理”“查看”等裸词；必须描述动作对象",
  "禁用菜单项、禁用按钮和只读能力的原因必须可发现、可访问，且不能只存在于 hover tooltip",
  "危险菜单项必须保留风险标记、影响范围、确认策略、请求身份、结果回执和审计回执，并进入 `risk-actions.md`",
  "非模态浮层不得被父容器、滚动区、固定列、固定页脚、`overflow` 或 `transform` 裁切",
  "打开的菜单、Popover 和 Tooltip 在 route/unmount、权限变化、断点转换或 trigger 消失后不得悬空",
  "移动端不得删除菜单入口、禁用原因、危险确认、错误恢复或权限说明",
  "未验证"
].freeze

ROUTE_TERMS = [
  "Tooltip",
  "Popover",
  "Dropdown",
  "Dropdown Menu",
  "Context Menu",
  "更多菜单",
  "操作菜单",
  "Hover 帮助",
  "Action Sheet",
  "tooltip",
  "popover",
  "dropdown menu",
  "context menu",
  "more actions",
  "action sheet",
  "references/overlays-menus-tooltips.md"
].freeze

README_TERMS = [
  "浮层菜单与提示规范",
  "references/overlays-menus-tooltips.md"
].freeze

HANDOFF_TERMS = [
  "### 浮层菜单与提示",
  "references/overlays-menus-tooltips.md",
  "overlay",
  "Tooltip / Popover 不得承载唯一必读权限原因"
].freeze

EVIDENCE_TERMS = [
  "overlayState",
  "overlayKind",
  "Tooltip",
  "Popover",
  "Menu",
  "Context Menu",
  "Action Sheet",
  "Hover",
  "Portal",
  "risk-actions.md",
  "route/unmount",
  "移动端不得删除菜单入口",
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
  STATE_FIELDS.each { |field| failures << "owner: overlayState missing #{field}" unless owner.include?(field) }
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
  expect_failure("hover-only-critical-information") do
    audit(owner: owner.gsub("重要信息不得仅依赖 Hover、Tooltip、Popover 临时可见状态或 Context Menu", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("tooltip-popover-only-required-info") do
    audit(owner: owner.gsub("Tooltip / Popover 不得承载唯一必读权限原因、错误、确认后果、危险操作、结果回执、审计凭证或恢复入口", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("menu-hidden-critical-content") do
    audit(owner: owner.gsub("更多菜单不得成为隐藏权限原因、错误、确认后果或唯一恢复入口的地方", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("context-menu-only-action") do
    audit(owner: owner.gsub("Context Menu 可以作为效率入口，但不能是唯一入口", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("naked-menu-labels") do
    audit(owner: owner.gsub("菜单项不能只有“操作”“更多”“处理”“查看”等裸词；必须描述动作对象", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("tooltip-only-disabled-reason") do
    audit(owner: owner.gsub("禁用菜单项、禁用按钮和只读能力的原因必须可发现、可访问，且不能只存在于 hover tooltip", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("danger-menu-risk-owner") do
    audit(owner: owner.gsub("危险菜单项必须保留风险标记、影响范围、确认策略、请求身份、结果回执和审计回执，并进入 `risk-actions.md`", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("overlay-clipping") do
    audit(owner: owner.gsub("非模态浮层不得被父容器、滚动区、固定列、固定页脚、`overflow` 或 `transform` 裁切", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("stale-overlay-disposal") do
    audit(owner: owner.gsub("打开的菜单、Popover 和 Tooltip 在 route/unmount、权限变化、断点转换或 trigger 消失后不得悬空", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-equivalent-path") do
    audit(owner: owner.gsub("移动端不得删除菜单入口、禁用原因、危险确认、错误恢复或权限说明", ""),
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

puts "PASS: 浮层菜单与提示 owner、路由、摘要和证据符合结构化审计契约。"
