#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/page-header-title-area.md")
NAVIGATION = File.join(ROOT, "references/navigation-routing.md")
TOOLBARS = File.join(ROOT, "references/page-toolbars-actions.md")
INFO = File.join(ROOT, "references/information-display.md")
APP_SHELL = File.join(ROOT, "references/app-shell-navigation.md")
RESPONSIVE = File.join(ROOT, "references/responsive-adaptive.md")
BUTTONS = File.join(ROOT, "references/buttons.md")
PERMISSIONS = File.join(ROOT, "references/permissions-tenancy-visibility.md")
ADMIN = File.join(ROOT, "references/admin-console.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/page-header-title-area/green-summary.md")
RED = File.join(ROOT, "docs/testing/page-header-title-area/red-summary.md")

STATE_FIELDS = %w[
  headerOwnerId headerSurface pageIdentity titleBinding subtitlePolicy
  contextBinding statusSummary primaryActionSlot secondaryActionSlot
  navigationBinding permissionBoundary responsivePolicy focusAnnouncementPolicy
  lifecycleDisposal runtimeVerification
].freeze

OWNER_TERMS = [
  "pageHeaderState",
  "页面标题区不是装饰，也不是 App Shell 的一部分",
  "标题区必须绑定当前页面 owner、URL、权限版本和业务范围",
  "标题、对象名、状态、数量、时间范围、租户/工作区和权限说明必须来自同一有效快照；不得混用旧标题和新内容",
  "标题区主操作只能作为入口，必须转交按钮、工具栏、表单、记录编辑、风险操作、审批、导出、异步任务或对应业务 owner",
  "面包屑、返回和路由来源仍归导航 owner；标题区只能展示或转交，不能把返回写成裸 `history.back()`",
  "权限降级、租户/工作区切换、对象切换、路由变化、视图切换、远程标题失败、菜单配置变化或断点转换后，旧标题、旧副标题、旧数量、旧状态、旧操作、旧 tooltip、旧 `document.title`、旧 ARIA label、旧 DOM 和旧焦点目标必须失效或重算",
  "移动端可以压缩标题区、折叠副标题、收纳次要操作或把更多操作放入 Action Sheet / Drawer，但不得删除页面身份、主要状态、权限说明、主操作入口、返回/恢复路径和运行时未验证声明",
  "未验证"
].freeze

ROUTE_TERMS = [
  "Page Header", "页面标题区", "页面头部", "标题栏", "页面标题", "副标题",
  "对象标题", "详情标题", "列表标题", "设置页标题", "报表标题", "审批页标题",
  "任务页标题", "状态摘要", "标题区主操作", "标题区次要操作", "标题区返回区域",
  "标题区权限说明", "标题区刷新状态", "移动端标题区", "page header",
  "page title", "title area", "header actions", "header primary action",
  "object title", "status summary", "mobile page header",
  "references/page-header-title-area.md"
].freeze

ADJACENT_TERMS = ["references/page-header-title-area.md", "page-header-title-area.md"].freeze
README_TERMS = ["页面标题区与 Page Header 规范", "references/page-header-title-area.md"].freeze
HANDOFF_TERMS = [
  "### 页面标题区与 Page Header",
  "pageHeaderState",
  "页面标题区不是装饰，也不是 App Shell 的一部分",
  "标题区主操作只能作为入口",
  "references/page-header-title-area.md"
].freeze
EVIDENCE_TERMS = STATE_FIELDS + ["pageHeaderState", "titleBinding", "primaryActionSlot", "navigationBinding", "未验证"]
PROJECT_BANNED_TERMS = ["fex-admin", "/Users/evanqi/code/", "src/pages", "Ant Design", "ant-design", "shadcn", "Next.js", "Vite", "React", "Vue"].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)
  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def owner_failures(owner)
  STATE_FIELDS.reject { |field| owner.include?(field) }.map { |field| "owner: pageHeaderState missing #{field}" } +
    require_terms(owner, OWNER_TERMS, "owner")
end

def integration_failures(texts)
  failures = []
  %w[navigation toolbars info app_shell responsive buttons permissions admin].each do |key|
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
  "navigation" => read(NAVIGATION),
  "toolbars" => read(TOOLBARS),
  "info" => read(INFO),
  "app_shell" => read(APP_SHELL),
  "responsive" => read(RESPONSIVE),
  "buttons" => read(BUTTONS),
  "permissions" => read(PERMISSIONS),
  "admin" => read(ADMIN),
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
    "missing-owner-state" => texts.fetch("owner").gsub("pageHeaderState", "page-header-state"),
    "decorative-header" => texts.fetch("owner").gsub("页面标题区不是装饰，也不是 App Shell 的一部分", ""),
    "identity-binding-removed" => texts.fetch("owner").gsub("标题区必须绑定当前页面 owner、URL、权限版本和业务范围", ""),
    "snapshot-consistency-removed" => texts.fetch("owner").gsub("标题、对象名、状态、数量、时间范围、租户/工作区和权限说明必须来自同一有效快照；不得混用旧标题和新内容", ""),
    "action-owner-removed" => texts.fetch("owner").gsub("标题区主操作只能作为入口，必须转交按钮、工具栏、表单、记录编辑、风险操作、审批、导出、异步任务或对应业务 owner", ""),
    "navigation-boundary-removed" => texts.fetch("owner").gsub("面包屑、返回和路由来源仍归导航 owner；标题区只能展示或转交，不能把返回写成裸 `history.back()`", ""),
    "disposal-removed" => texts.fetch("owner").gsub("权限降级、租户/工作区切换、对象切换、路由变化、视图切换、远程标题失败、菜单配置变化或断点转换后，旧标题、旧副标题、旧数量、旧状态、旧操作、旧 tooltip、旧 `document.title`、旧 ARIA label、旧 DOM 和旧焦点目标必须失效或重算", ""),
    "mobile-core-removed" => texts.fetch("owner").gsub("移动端可以压缩标题区、折叠副标题、收纳次要操作或把更多操作放入 Action Sheet / Drawer，但不得删除页面身份、主要状态、权限说明、主操作入口、返回/恢复路径和运行时未验证声明", ""),
    "runtime-boundary-marked-verified" => texts.fetch("owner").gsub("未验证", "已验证")
  }.each do |name, mutated_owner|
    expect_failure(name) { audit(texts.merge("owner" => mutated_owner)) }
  end

  expect_failure("missing-route") { audit(texts.merge("skill" => texts.fetch("skill").gsub("references/page-header-title-area.md", ""))) }
  expect_failure("missing-adjacent-link") { audit(texts.merge("navigation" => texts.fetch("navigation").gsub("references/page-header-title-area.md", ""))) }
  expect_failure("project-specific-leakage") { audit(texts.merge("owner" => "#{texts.fetch("owner")}\nfex-admin")) }
end

puts "PASS: 页面标题区与 Page Header owner、路由和证据符合结构化审计契约。"
