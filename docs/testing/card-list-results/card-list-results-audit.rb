#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/card-list-results.md")
DATA_TABLES = File.join(ROOT, "references/data-tables.md")
LIST_CONTROLS = File.join(ROOT, "references/list-result-controls.md")
TOOLBARS = File.join(ROOT, "references/page-toolbars-actions.md")
BUTTONS = File.join(ROOT, "references/buttons.md")
OVERLAYS = File.join(ROOT, "references/overlays-menus-tooltips.md")
PREVIEW = File.join(ROOT, "references/preview-pane.md")
RECORD_EDITING = File.join(ROOT, "references/record-editing-surfaces.md")
FEEDBACK = File.join(ROOT, "references/feedback-states.md")
RESPONSIVE = File.join(ROOT, "references/responsive-adaptive.md")
PERMISSIONS = File.join(ROOT, "references/permissions-tenancy-visibility.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/card-list-results/green-summary.md")
RED = File.join(ROOT, "docs/testing/card-list-results/red-summary.md")

STATE_FIELDS = %w[
  cardListOwnerId surfaceKind capabilityTier sourceBinding cardIdentityMap
  fieldMapping interactionZones selectionBinding actionBinding requestBinding
  permissionBoundary feedbackBinding responsivePolicy focusKeyboardPolicy
  runtimeVerification
].freeze

OWNER_TERMS = [
  "cardListResultState",
  "卡片列表不是营销卡片墙",
  "整张卡片不得包成一个大链接再在内部塞按钮、菜单、checkbox 或复制控件",
  "打开详情区、选择区和操作区必须是独立交互区域",
  "`capabilityTier` 只能是 `display`、`item-action` 或 `selection-action`",
  "只有 `selection-action` 可以渲染选择与批量操作",
  "选择状态必须读取稳定记录 ID，不得用当前数组索引或 DOM 顺序",
  "卡片内不得承载新增、编辑、复制创建、单元格编辑、字段保存、行内保存或完整字段表单",
  "重要字段、权限原因、错误状态、恢复入口和主要操作不得只靠 hover、右键、隐藏菜单、图标、颜色、封面图或截断文本表达",
  "移动端、200% 缩放、低高度、长标题、翻译扩展和字体放大不得删除记录身份、主状态、错误/权限说明、选择摘要、主要操作、分页/刷新和恢复入口",
  "迟到响应不得写回新卡片、新权限或已卸载列表",
  "无权限或权限降级不得泄露旧标题、旧封面、旧缩略图、旧标签、旧状态、旧数量、旧文件名、旧菜单项、旧错误或旧 ARIA label",
  "未验证"
].freeze

ROUTE_TERMS = [
  "卡片列表", "卡片式结果", "资源卡片", "模板卡片", "应用卡片", "内容卡片",
  "项目卡片", "卡片网格", "移动端结果卡片", "卡片操作区", "卡片选择",
  "card list", "card results", "result cards", "resource cards", "template cards",
  "app cards", "content cards", "project cards", "card grid", "mobile cards",
  "kanban-lite", "references/card-list-results.md"
].freeze

ADJACENT_TERMS = [
  "references/card-list-results.md",
  "card-list-results.md"
].freeze

README_TERMS = [
  "卡片列表与卡片式结果规范",
  "references/card-list-results.md"
].freeze

HANDOFF_TERMS = [
  "### 卡片列表与卡片式结果",
  "cardListResultState",
  "卡片列表不是营销卡片墙",
  "整张卡片不得包成一个大链接再在内部塞按钮、菜单、checkbox 或复制控件",
  "卡片内不得承载新增、编辑、复制创建、单元格编辑、字段保存、行内保存或完整字段表单",
  "references/card-list-results.md"
].freeze

EVIDENCE_TERMS = STATE_FIELDS + [
  "cardListResultState",
  "cardIdentityMap",
  "fieldMapping",
  "interactionZones",
  "selectionBinding",
  "actionBinding",
  "requestBinding",
  "permissionBoundary",
  "feedbackBinding",
  "responsivePolicy",
  "focusKeyboardPolicy",
  "未验证"
].freeze

PROJECT_BANNED_TERMS = [
  "fex-admin",
  "/Users/evanqi/code/",
  "src/pages",
  "Ant Design",
  "ant-design",
  "shadcn",
  "Next.js",
  "Vite",
  "React",
  "Vue"
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
  STATE_FIELDS.each do |field|
    failures << "owner: cardListResultState missing #{field}" unless owner.include?(field)
  end
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end

def integration_failures(texts)
  failures = []
  %w[data_tables list_controls toolbars buttons overlays preview record_editing feedback responsive permissions].each do |key|
    failures.concat(require_terms(texts.fetch(key), ADJACENT_TERMS, "#{key} relationship"))
  end
  failures.concat(require_terms(texts.fetch("skill"), ROUTE_TERMS, "SKILL route"))
  failures.concat(require_terms(texts.fetch("readme"), README_TERMS, "README"))
  failures.concat(require_terms(texts.fetch("handoff"), HANDOFF_TERMS, "HANDOFF"))
  failures.concat(require_terms(texts.fetch("green"), EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(texts.fetch("red"), EVIDENCE_TERMS, "RED evidence"))
  failures
end

def project_leak_failures(texts)
  PROJECT_BANNED_TERMS.flat_map do |term|
    texts.select { |_label, text| text.include?(term) }.map { |label, _text| "#{label}: forbidden project-specific term #{term}" }
  end
end

def audit(texts)
  failures = []
  failures.concat(owner_failures(texts.fetch("owner")))
  failures.concat(integration_failures(texts))
  failures.concat(project_leak_failures("owner" => texts.fetch("owner"), "green" => texts.fetch("green"), "red" => texts.fetch("red")))
  failures
end

def expect_failure(name)
  failures = yield
  abort("mutation did not fail: #{name}") if failures.empty?

  puts "EXPECTED_FAIL: #{name}"
end

texts = {
  "owner" => read(OWNER),
  "data_tables" => read(DATA_TABLES),
  "list_controls" => read(LIST_CONTROLS),
  "toolbars" => read(TOOLBARS),
  "buttons" => read(BUTTONS),
  "overlays" => read(OVERLAYS),
  "preview" => read(PREVIEW),
  "record_editing" => read(RECORD_EDITING),
  "feedback" => read(FEEDBACK),
  "responsive" => read(RESPONSIVE),
  "permissions" => read(PERMISSIONS),
  "skill" => read(SKILL),
  "readme" => read(README),
  "handoff" => read(HANDOFF),
  "green" => read(GREEN),
  "red" => read(RED)
}

failures = audit(texts)
unless failures.empty?
  warn failures.join("\n")
  exit 1
end

if ARGV.include?("--mutations")
  mutation_cases = {
    "missing-owner-state" => texts.fetch("owner").gsub("cardListResultState", "card-list-result-state"),
    "marketing-card-wall" => texts.fetch("owner").gsub("卡片列表不是营销卡片墙", ""),
    "whole-card-link-allowed" => texts.fetch("owner").gsub("整张卡片不得包成一个大链接再在内部塞按钮、菜单、checkbox 或复制控件", ""),
    "zones-merged" => texts.fetch("owner").gsub("打开详情区、选择区和操作区必须是独立交互区域", ""),
    "capability-tier-removed" => texts.fetch("owner").gsub("`capabilityTier` 只能是 `display`、`item-action` 或 `selection-action`", ""),
    "selection-tier-removed" => texts.fetch("owner").gsub("只有 `selection-action` 可以渲染选择与批量操作", ""),
    "index-selection-allowed" => texts.fetch("owner").gsub("选择状态必须读取稳定记录 ID，不得用当前数组索引或 DOM 顺序", ""),
    "inline-editing-allowed" => texts.fetch("owner").gsub("卡片内不得承载新增、编辑、复制创建、单元格编辑、字段保存、行内保存或完整字段表单", ""),
    "hover-only-allowed" => texts.fetch("owner").gsub("重要字段、权限原因、错误状态、恢复入口和主要操作不得只靠 hover、右键、隐藏菜单、图标、颜色、封面图或截断文本表达", ""),
    "mobile-core-removed" => texts.fetch("owner").gsub("移动端、200% 缩放、低高度、长标题、翻译扩展和字体放大不得删除记录身份、主状态、错误/权限说明、选择摘要、主要操作、分页/刷新和恢复入口", ""),
    "late-response-allowed" => texts.fetch("owner").gsub("迟到响应不得写回新卡片、新权限或已卸载列表", ""),
    "permission-leakage-allowed" => texts.fetch("owner").gsub("无权限或权限降级不得泄露旧标题、旧封面、旧缩略图、旧标签、旧状态、旧数量、旧文件名、旧菜单项、旧错误或旧 ARIA label", ""),
    "runtime-boundary-marked-verified" => texts.fetch("owner").gsub("未验证", "已验证")
  }

  mutation_cases.each do |name, mutated_owner|
    expect_failure(name) { audit(texts.merge("owner" => mutated_owner)) }
  end

  expect_failure("missing-route") do
    audit(texts.merge("skill" => texts.fetch("skill").gsub("references/card-list-results.md", "")))
  end

  expect_failure("missing-adjacent-link") do
    audit(texts.merge("buttons" => texts.fetch("buttons").gsub("references/card-list-results.md", "")))
  end

  expect_failure("project-specific-leakage") do
    audit(texts.merge("owner" => "#{texts.fetch("owner")}\nfex-admin"))
  end
end

puts "PASS: 卡片列表与卡片式结果 owner、路由和证据符合结构化审计契约。"
