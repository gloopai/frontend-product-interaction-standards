#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/table-column-layout-density.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/table-column-layout-density/green-summary.md")
RED = File.join(ROOT, "docs/testing/table-column-layout-density/red-summary.md")

STATE_FIELDS = %w[
  columnLayoutOwnerId tableBinding columnRegistry draftLayout appliedLayout
  persistedLayout densityPolicy widthPolicy pinningPolicy orderingPolicy
  resetPolicy persistencePolicy permissionBoundary feedbackBinding responsivePolicy
  focusAnnouncementPolicy lifecycleDisposal runtimeVerification
].freeze

OWNER_TERMS = [
  "tableColumnLayoutState",
  "表格列配置不是“把列数组存到 localStorage”",
  "不得只用列数组、localStorage、CSS class、组件库默认 column picker、隐藏 DOM、媒体查询或保存视图名称替代",
  "必须区分 `draftLayout`、`appliedLayout` 和 `persistedLayout`",
  "保存视图不是应用列草稿",
  "列隐藏不是字段无权限",
  "无权限列不得出现在列设置面板、列数量、列顺序、已隐藏列表、保存视图字段、导出字段、ARIA label、Tooltip、旧布局、URL 或本地缓存中",
  "列顺序必须基于稳定列 ID",
  "固定列不得遮挡中间列内容、Tooltip、Dropdown、Dialog/Drawer 内浮层、焦点环或移动端安全区域",
  "密度切换不能只改行高",
  "紧凑模式不得删除状态、错误、单位、禁用原因、行操作、选择摘要或恢复入口",
  "重置当前草稿、恢复当前表格默认、恢复个人默认、恢复团队默认、恢复系统默认和清空本地临时布局是不同意图",
  "未验证"
].freeze

ROUTE_TERMS = [
  "列设置",
  "列显示",
  "列隐藏",
  "列宽调整",
  "固定列",
  "列密度",
  "column settings",
  "column visibility",
  "column resize",
  "pinned column",
  "table density",
  "references/table-column-layout-density.md"
].freeze

README_TERMS = [
  "表格列设置、列布局与密度规范",
  "references/table-column-layout-density.md",
  "tableColumnLayoutState"
].freeze

HANDOFF_TERMS = [
  "### 表格列设置、列布局与密度",
  "tableColumnLayoutState",
  "表格列配置不是“把列数组存到 localStorage”",
  "references/table-column-layout-density.md"
].freeze

ADJACENT_FILES = %w[
  references/data-tables.md
  references/saved-views-layout-presets.md
  references/page-toolbars-actions.md
  references/permissions-tenancy-visibility.md
  references/text-overflow-truncation.md
  references/list-result-controls.md
].freeze

EVIDENCE_TERMS = [
  "tableColumnLayoutState",
  "draftLayout",
  "appliedLayout",
  "persistedLayout",
  "localStorage",
  "column picker",
  "稳定列 ID",
  "无权限列",
  "紧凑",
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
  STATE_FIELDS.each { |field| failures << "owner missing tableColumnLayoutState field: #{field}" unless owner.include?(field) }
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end

def adjacent_failures
  ADJACENT_FILES.flat_map do |relative|
    text = read(File.join(ROOT, relative))
    failures = []
    failures << "#{relative} missing references/table-column-layout-density.md" unless text.include?("references/table-column-layout-density.md")
    failures << "#{relative} missing tableColumnLayoutState" unless text.include?("tableColumnLayoutState")
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
    audit(owner: owner.gsub("tableColumnLayoutState", "columnLayoutState"), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("local-storage-boundary-removed") do
    audit(owner: owner.gsub("表格列配置不是“把列数组存到 localStorage”", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("default-picker-boundary-removed") do
    audit(owner: owner.gsub("不得只用列数组、localStorage、CSS class、组件库默认 column picker、隐藏 DOM、媒体查询或保存视图名称替代", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("draft-apply-persist-collapsed") do
    audit(owner: owner.gsub("必须区分 `draftLayout`、`appliedLayout` 和 `persistedLayout`", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("saved-view-draft-boundary-removed") do
    audit(owner: owner.gsub("保存视图不是应用列草稿", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("permission-hidden-collapsed") do
    audit(owner: owner.gsub("列隐藏不是字段无权限", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("permission-leak-allowed") do
    audit(owner: owner.gsub("无权限列不得出现在列设置面板、列数量、列顺序、已隐藏列表、保存视图字段、导出字段、ARIA label、Tooltip、旧布局、URL 或本地缓存中", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("stable-column-id-removed") do
    audit(owner: owner.gsub("列顺序必须基于稳定列 ID", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("fixed-column-overlap-allowed") do
    audit(owner: owner.gsub("固定列不得遮挡中间列内容、Tooltip、Dropdown、Dialog/Drawer 内浮层、焦点环或移动端安全区域", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("density-only-row-height") do
    audit(owner: owner.gsub("密度切换不能只改行高", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("compact-removes-state") do
    audit(owner: owner.gsub("紧凑模式不得删除状态、错误、单位、禁用原因、行操作、选择摘要或恢复入口", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("reset-intents-collapsed") do
    audit(owner: owner.gsub("重置当前草稿、恢复当前表格默认、恢复个人默认、恢复团队默认、恢复系统默认和清空本地临时布局是不同意图", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("missing-skill-route") do
    audit(owner: owner, skill: skill.gsub("references/table-column-layout-density.md", ""), readme: readme, handoff: handoff, green: green, red: red)
  end
  expect_failure("missing-readme-link") do
    audit(owner: owner, skill: skill, readme: readme.gsub("references/table-column-layout-density.md", ""), handoff: handoff, green: green, red: red)
  end
  expect_failure("missing-handoff-section") do
    audit(owner: owner, skill: skill, readme: readme, handoff: handoff.gsub("### 表格列设置、列布局与密度", ""), green: green, red: red)
  end
  expect_failure("project-leak") do
    audit(owner: "#{owner}\nfex-admin\n", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 表格列设置、列布局与密度 owner、路由和证据符合结构化审计契约。"

