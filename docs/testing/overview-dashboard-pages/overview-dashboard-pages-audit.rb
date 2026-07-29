#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/overview-dashboard-pages.md")
ADMIN = File.join(ROOT, "references/admin-console.md")
INFO = File.join(ROOT, "references/information-display.md")
CHARTS = File.join(ROOT, "references/charts-visualization.md")
TABLES = File.join(ROOT, "references/data-tables.md")
QUERY = File.join(ROOT, "references/query-filters.md")
TIME = File.join(ROOT, "references/date-time-ranges.md")
EXPORTS = File.join(ROOT, "references/exports-downloads-artifacts.md")
FEEDBACK = File.join(ROOT, "references/feedback-states.md")
RESPONSIVE = File.join(ROOT, "references/responsive-adaptive.md")
PERMISSIONS = File.join(ROOT, "references/permissions-tenancy-visibility.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/overview-dashboard-pages/green-summary.md")
RED = File.join(ROOT, "docs/testing/overview-dashboard-pages/red-summary.md")

STATE_FIELDS = %w[
  dashboardOwnerId consoleSurface layoutRegistry globalFilterBinding timeRangeSnapshot
  dataSnapshot moduleRegistry metricCardsBinding chartBinding detailBinding
  refreshPolicy alertPriority actionBoundary permissionBoundary feedbackBinding
  responsivePolicy focusAnnouncementPolicy runtimeVerification
].freeze

OWNER_TERMS = [
  "overviewDashboardState",
  "概览页和仪表盘首页默认只读展示",
  "KPI、图表、明细表、导出任务、页面摘要和刷新状态共享同一业务范围时，必须引用同一 `dataSnapshot`、`timeRangeSnapshot`、权限范围和数据延迟",
  "不同模块使用不同口径、不同时间范围、不同权限范围、不同刷新时间或不同数据延迟时，差异必须在模块标题或说明中可见",
  "任一关键模块 stale、partial、permission-denied、metric-unavailable 或 refresh-error 时不得伪装全页正常",
  "重要告警、风险状态、权限原因、数据延迟、刷新失败、导出/明细入口和恢复入口不得藏在 hover、图标、装饰卡片或不可达折叠区",
  "移动端可以把模块重排、折叠或分组，但不得删除页面标题、全局筛选摘要、时间范围、KPI 口径、告警、权限原因、数据延迟、刷新状态、主要图表摘要、明细/导出入口和恢复路径",
  "导出、钻取、查看明细、订阅和跳转必须绑定当前页面级快照与权限版本",
  "无权限或权限降级不得泄露旧 KPI 名称、旧数值、旧图表 series、旧明细数量、旧导出范围、旧告警标题、旧菜单项或旧 ARIA label",
  "页面布局不能使用营销式 hero 或纯装饰大卡片承载主要工作区",
  "未验证"
].freeze

ROUTE_TERMS = [
  "概览页", "仪表盘首页", "管理台首页", "运营看板", "业务看板", "指标总览",
  "报表总览", "Dashboard 总览", "dashboard landing", "overview dashboard",
  "dashboard home", "overview page", "operations dashboard", "business dashboard",
  "KPI overview", "references/overview-dashboard-pages.md"
].freeze

ADJACENT_TERMS = ["references/overview-dashboard-pages.md", "overview-dashboard-pages.md"].freeze
README_TERMS = ["概览页与仪表盘首页规范", "references/overview-dashboard-pages.md"].freeze
HANDOFF_TERMS = [
  "### 概览页与仪表盘首页",
  "overviewDashboardState",
  "概览页和仪表盘首页默认只读展示",
  "页面布局不能使用营销式 hero 或纯装饰大卡片承载主要工作区",
  "references/overview-dashboard-pages.md"
].freeze
EVIDENCE_TERMS = STATE_FIELDS + ["overviewDashboardState", "dataSnapshot", "timeRangeSnapshot", "alertPriority", "未验证"]
PROJECT_BANNED_TERMS = ["fex-admin", "/Users/evanqi/code/", "src/pages", "Ant Design", "ant-design", "shadcn", "Next.js", "Vite", "React", "Vue"].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)
  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def owner_failures(owner)
  STATE_FIELDS.reject { |field| owner.include?(field) }.map { |field| "owner: overviewDashboardState missing #{field}" } +
    require_terms(owner, OWNER_TERMS, "owner")
end

def integration_failures(texts)
  failures = []
  %w[admin info charts tables query time exports feedback responsive permissions].each do |key|
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
  owner_failures(texts.fetch("owner")) +
    integration_failures(texts) +
    project_leak_failures("owner" => texts.fetch("owner"), "green" => texts.fetch("green"), "red" => texts.fetch("red"))
end

def expect_failure(name)
  failures = yield
  abort("mutation did not fail: #{name}") if failures.empty?
  puts "EXPECTED_FAIL: #{name}"
end

texts = {
  "owner" => read(OWNER),
  "admin" => read(ADMIN),
  "info" => read(INFO),
  "charts" => read(CHARTS),
  "tables" => read(TABLES),
  "query" => read(QUERY),
  "time" => read(TIME),
  "exports" => read(EXPORTS),
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
  {
    "missing-owner-state" => texts.fetch("owner").gsub("overviewDashboardState", "overview-dashboard-state"),
    "readonly-default-removed" => texts.fetch("owner").gsub("概览页和仪表盘首页默认只读展示", ""),
    "shared-snapshot-removed" => texts.fetch("owner").gsub("KPI、图表、明细表、导出任务、页面摘要和刷新状态共享同一业务范围时，必须引用同一 `dataSnapshot`、`timeRangeSnapshot`、权限范围和数据延迟", ""),
    "difference-disclosure-removed" => texts.fetch("owner").gsub("不同模块使用不同口径、不同时间范围、不同权限范围、不同刷新时间或不同数据延迟时，差异必须在模块标题或说明中可见", ""),
    "whole-page-normal-allowed" => texts.fetch("owner").gsub("任一关键模块 stale、partial、permission-denied、metric-unavailable 或 refresh-error 时不得伪装全页正常", ""),
    "alert-hidden" => texts.fetch("owner").gsub("重要告警、风险状态、权限原因、数据延迟、刷新失败、导出/明细入口和恢复入口不得藏在 hover、图标、装饰卡片或不可达折叠区", ""),
    "mobile-core-removed" => texts.fetch("owner").gsub("移动端可以把模块重排、折叠或分组，但不得删除页面标题、全局筛选摘要、时间范围、KPI 口径、告警、权限原因、数据延迟、刷新状态、主要图表摘要、明细/导出入口和恢复路径", ""),
    "action-binding-removed" => texts.fetch("owner").gsub("导出、钻取、查看明细、订阅和跳转必须绑定当前页面级快照与权限版本", ""),
    "permission-leakage-allowed" => texts.fetch("owner").gsub("无权限或权限降级不得泄露旧 KPI 名称、旧数值、旧图表 series、旧明细数量、旧导出范围、旧告警标题、旧菜单项或旧 ARIA label", ""),
    "marketing-hero-allowed" => texts.fetch("owner").gsub("页面布局不能使用营销式 hero 或纯装饰大卡片承载主要工作区", ""),
    "runtime-boundary-marked-verified" => texts.fetch("owner").gsub("未验证", "已验证")
  }.each do |name, mutated_owner|
    expect_failure(name) { audit(texts.merge("owner" => mutated_owner)) }
  end

  expect_failure("missing-route") { audit(texts.merge("skill" => texts.fetch("skill").gsub("references/overview-dashboard-pages.md", ""))) }
  expect_failure("missing-adjacent-link") { audit(texts.merge("admin" => texts.fetch("admin").gsub("references/overview-dashboard-pages.md", ""))) }
  expect_failure("project-specific-leakage") { audit(texts.merge("owner" => "#{texts.fetch("owner")}\nfex-admin")) }
end

puts "PASS: 概览页与仪表盘首页 owner、路由和证据符合结构化审计契约。"
