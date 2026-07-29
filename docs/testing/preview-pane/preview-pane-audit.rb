#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/preview-pane.md")
DATA_TABLES = File.join(ROOT, "references/data-tables.md")
INFO = File.join(ROOT, "references/information-display.md")
RECORD_EDITING = File.join(ROOT, "references/record-editing-surfaces.md")
DRAWERS = File.join(ROOT, "references/drawers.md")
NAVIGATION = File.join(ROOT, "references/navigation-routing.md")
PERMISSIONS = File.join(ROOT, "references/permissions-tenancy-visibility.md")
FEEDBACK = File.join(ROOT, "references/feedback-states.md")
RESPONSIVE = File.join(ROOT, "references/responsive-adaptive.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/preview-pane/green-summary.md")
RED = File.join(ROOT, "docs/testing/preview-pane/red-summary.md")

STATE_FIELDS = %w[
  previewOwnerId surfaceKind sourceBinding activePreviewTarget pendingPreviewIntent
  previewSnapshot requestBinding permissionBoundary displayBinding actionBoundary
  urlHistoryBinding focusReturnPolicy responsivePolicy runtimeVerification
].freeze

OWNER_TERMS = [
  "previewPaneState",
  "预览目标不等于表格选择、不等于 hover、不等于 focus、不等于 active row，也不等于编辑目标",
  "预览面板不得渲染 input、textarea、select、combobox、日期选择器、单元格编辑、行内保存按钮或任何完整字段编辑表单",
  "编辑入口只能转交记录编辑承载面",
  "迟到预览响应只有同时匹配 `previewOwnerId`、owner live、请求代次、预览目标、租户/工作区和权限版本时才可提交",
  "无权限、权限降级、租户切换、记录删除或来源范围失效时，不得泄露对象名称、字段、数量、文件名、内部 ID、旧标题、旧错误或旧复制内容",
  "关闭预览不等于清空表格选择、不等于取消服务端任务、不等于提交表单、不等于路由返回",
  "移动端可以把桌面侧边预览转换为底部 Drawer、全屏 Drawer 或独立详情页",
  "不得删除返回列表、当前预览目标、安全标题、权限原因、错误状态、主要只读信息和恢复入口",
  "未验证"
].freeze

ROUTE_TERMS = [
  "详情预览", "侧边预览", "预览面板", "行预览", "记录预览", "快速查看",
  "主从预览", "只读预览", "preview pane", "detail preview", "side preview",
  "row preview", "record preview", "quick view", "master detail",
  "master-detail", "read-only preview", "references/preview-pane.md"
].freeze

ADJACENT_TERMS = [
  "references/preview-pane.md",
  "preview-pane.md"
].freeze

README_TERMS = [
  "详情预览面板规范",
  "references/preview-pane.md"
].freeze

HANDOFF_TERMS = [
  "### 详情预览面板",
  "previewPaneState",
  "预览目标不等于表格选择、不等于 hover、不等于 focus、不等于 active row，也不等于编辑目标",
  "预览面板不得渲染 input、textarea、select、combobox、日期选择器、单元格编辑、行内保存按钮或任何完整字段编辑表单",
  "迟到预览响应只有同时匹配",
  "移动端可以把桌面侧边预览转换为底部 Drawer、全屏 Drawer 或独立详情页",
  "references/preview-pane.md"
].freeze

EVIDENCE_TERMS = STATE_FIELDS + [
  "previewPaneState",
  "sourceBinding",
  "activePreviewTarget",
  "pendingPreviewIntent",
  "previewSnapshot",
  "requestBinding",
  "permissionBoundary",
  "displayBinding",
  "actionBoundary",
  "urlHistoryBinding",
  "focusReturnPolicy",
  "responsivePolicy",
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
    failures << "owner: previewPaneState missing #{field}" unless owner.include?(field)
  end
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end

def integration_failures(texts)
  failures = []
  %w[data_tables info record_editing drawers navigation permissions feedback responsive].each do |key|
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
  "info" => read(INFO),
  "record_editing" => read(RECORD_EDITING),
  "drawers" => read(DRAWERS),
  "navigation" => read(NAVIGATION),
  "permissions" => read(PERMISSIONS),
  "feedback" => read(FEEDBACK),
  "responsive" => read(RESPONSIVE),
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
    "missing-owner-state" => texts.fetch("owner").gsub("previewPaneState", "preview-pane-state"),
    "preview-equals-selection" => texts.fetch("owner").gsub("预览目标不等于表格选择、不等于 hover、不等于 focus、不等于 active row，也不等于编辑目标", ""),
    "editable-controls-allowed" => texts.fetch("owner").gsub("预览面板不得渲染 input、textarea、select、combobox、日期选择器、单元格编辑、行内保存按钮或任何完整字段编辑表单", ""),
    "edit-not-delegated" => texts.fetch("owner").gsub("编辑入口只能转交记录编辑承载面", ""),
    "late-response-guard-removed" => texts.fetch("owner").gsub("迟到预览响应只有同时匹配 `previewOwnerId`、owner live、请求代次、预览目标、租户/工作区和权限版本时才可提交", ""),
    "permission-leakage-allowed" => texts.fetch("owner").gsub("无权限、权限降级、租户切换、记录删除或来源范围失效时，不得泄露对象名称、字段、数量、文件名、内部 ID、旧标题、旧错误或旧复制内容", ""),
    "close-preview-overloaded" => texts.fetch("owner").gsub("关闭预览不等于清空表格选择、不等于取消服务端任务、不等于提交表单、不等于路由返回", ""),
    "mobile-conversion-removed" => texts.fetch("owner").gsub("移动端可以把桌面侧边预览转换为底部 Drawer、全屏 Drawer 或独立详情页", ""),
    "mobile-core-data-removed" => texts.fetch("owner").gsub("不得删除返回列表、当前预览目标、安全标题、权限原因、错误状态、主要只读信息和恢复入口", ""),
    "runtime-boundary-marked-verified" => texts.fetch("owner").gsub("未验证", "已验证")
  }

  mutation_cases.each do |name, mutated_owner|
    expect_failure(name) { audit(texts.merge("owner" => mutated_owner)) }
  end

  expect_failure("missing-route") do
    audit(texts.merge("skill" => texts.fetch("skill").gsub("references/preview-pane.md", "")))
  end

  expect_failure("missing-adjacent-link") do
    audit(texts.merge("data_tables" => texts.fetch("data_tables").gsub("references/preview-pane.md", "")))
  end

  expect_failure("project-specific-leakage") do
    audit(texts.merge("owner" => "#{texts.fetch("owner")}\nfex-admin"))
  end
end

puts "PASS: 详情预览面板 owner、路由和证据符合结构化审计契约。"
