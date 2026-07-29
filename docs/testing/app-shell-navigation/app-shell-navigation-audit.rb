#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/app-shell-navigation.md")
NAVIGATION = File.join(ROOT, "references/navigation-routing.md")
PERMISSIONS = File.join(ROOT, "references/permissions-tenancy-visibility.md")
ADMIN = File.join(ROOT, "references/admin-console.md")
RESPONSIVE = File.join(ROOT, "references/responsive-adaptive.md")
SEARCH = File.join(ROOT, "references/search-command-palette.md")
NOTIFICATIONS = File.join(ROOT, "references/notifications-message-center-announcements.md")
OVERLAYS = File.join(ROOT, "references/overlays-menus-tooltips.md")
BUTTONS = File.join(ROOT, "references/buttons.md")
AUTH = File.join(ROOT, "references/auth-session-reauth.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/app-shell-navigation/green-summary.md")
RED = File.join(ROOT, "docs/testing/app-shell-navigation/red-summary.md")

STATE_FIELDS = %w[
  shellOwnerId shellSurface navigationRegistry currentNavBinding workspaceTenantBinding
  globalEntryRegistry userMenuBinding permissionBoundary responsivePolicy
  focusAnnouncementPolicy lifecycleDisposal runtimeVerification
].freeze

OWNER_TERMS = [
  "appShellNavigationState",
  "App Shell 不是普通页面，也不是一组静态链接",
  "App Shell 可以跨页面存活，但不得吞掉页面 owner",
  "当前导航项必须绑定当前页面 owner、URL、权限版本和父级路径；不得只靠路径字符串或菜单 key 高亮",
  "全局搜索、通知、帮助、任务中心、审计和创建入口只作为入口；不能替代对应 owner 的状态、结果、审计或恢复路径",
  "租户、工作区、组织和账号切换不是普通 Select",
  "权限降级、租户切换、工作区切换、会话变化、角色变化、功能关闭或菜单配置变化后，旧菜单、旧 badge、旧 tooltip、旧快捷键、旧搜索入口、旧通知入口、旧用户菜单、旧 DOM 和旧 ARIA 引用必须失效或重算",
  "移动端可以把侧边导航转为 Drawer、Bottom Sheet、全屏导航页或分组菜单，但不得删除当前位置、主导航、工作区/租户切换、用户菜单、全局搜索入口、通知入口、权限说明、返回/恢复路径和退出路径",
  "未验证"
].freeze

ROUTE_TERMS = [
  "App Shell", "应用外框", "管理台外框", "全局导航", "侧边导航", "顶部导航",
  "主导航", "导航栏", "侧边栏", "折叠菜单", "Logo/Home 入口",
  "当前导航项", "用户菜单", "账号菜单", "租户切换", "工作区切换", "组织切换",
  "全局搜索入口", "通知入口", "帮助入口", "移动端导航 Drawer", "移动端菜单",
  "app shell", "application shell", "global navigation", "side navigation",
  "top navigation", "sidebar navigation", "workspace switcher", "tenant switcher",
  "organization switcher", "user menu", "account menu", "mobile navigation drawer",
  "navigation shell", "references/app-shell-navigation.md"
].freeze

ADJACENT_TERMS = ["references/app-shell-navigation.md", "app-shell-navigation.md"].freeze
README_TERMS = ["管理台 App Shell 与导航外框规范", "references/app-shell-navigation.md"].freeze
HANDOFF_TERMS = [
  "### 管理台 App Shell 与导航外框",
  "appShellNavigationState",
  "App Shell 不是普通页面，也不是一组静态链接",
  "租户、工作区、组织和账号切换不是普通 Select",
  "references/app-shell-navigation.md"
].freeze
EVIDENCE_TERMS = STATE_FIELDS + ["appShellNavigationState", "navigationRegistry", "workspaceTenantBinding", "globalEntryRegistry", "未验证"]
PROJECT_BANNED_TERMS = ["fex-admin", "/Users/evanqi/code/", "src/pages", "Ant Design", "ant-design", "shadcn", "Next.js", "Vite", "React", "Vue"].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)
  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def owner_failures(owner)
  STATE_FIELDS.reject { |field| owner.include?(field) }.map { |field| "owner: appShellNavigationState missing #{field}" } +
    require_terms(owner, OWNER_TERMS, "owner")
end

def integration_failures(texts)
  failures = []
  %w[navigation permissions admin responsive search notifications overlays buttons auth].each do |key|
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
  "permissions" => read(PERMISSIONS),
  "admin" => read(ADMIN),
  "responsive" => read(RESPONSIVE),
  "search" => read(SEARCH),
  "notifications" => read(NOTIFICATIONS),
  "overlays" => read(OVERLAYS),
  "buttons" => read(BUTTONS),
  "auth" => read(AUTH),
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
    "missing-owner-state" => texts.fetch("owner").gsub("appShellNavigationState", "app-shell-navigation-state"),
    "ordinary-page-shell" => texts.fetch("owner").gsub("App Shell 不是普通页面，也不是一组静态链接", ""),
    "page-owner-boundary-removed" => texts.fetch("owner").gsub("App Shell 可以跨页面存活，但不得吞掉页面 owner", ""),
    "current-nav-binding-removed" => texts.fetch("owner").gsub("当前导航项必须绑定当前页面 owner、URL、权限版本和父级路径；不得只靠路径字符串或菜单 key 高亮", ""),
    "global-entry-boundary-removed" => texts.fetch("owner").gsub("全局搜索、通知、帮助、任务中心、审计和创建入口只作为入口；不能替代对应 owner 的状态、结果、审计或恢复路径", ""),
    "workspace-switcher-plain-select" => texts.fetch("owner").gsub("租户、工作区、组织和账号切换不是普通 Select", ""),
    "permission-cleanup-removed" => texts.fetch("owner").gsub("权限降级、租户切换、工作区切换、会话变化、角色变化、功能关闭或菜单配置变化后，旧菜单、旧 badge、旧 tooltip、旧快捷键、旧搜索入口、旧通知入口、旧用户菜单、旧 DOM 和旧 ARIA 引用必须失效或重算", ""),
    "mobile-core-removed" => texts.fetch("owner").gsub("移动端可以把侧边导航转为 Drawer、Bottom Sheet、全屏导航页或分组菜单，但不得删除当前位置、主导航、工作区/租户切换、用户菜单、全局搜索入口、通知入口、权限说明、返回/恢复路径和退出路径", ""),
    "runtime-boundary-marked-verified" => texts.fetch("owner").gsub("未验证", "已验证")
  }.each do |name, mutated_owner|
    expect_failure(name) { audit(texts.merge("owner" => mutated_owner)) }
  end

  expect_failure("missing-route") { audit(texts.merge("skill" => texts.fetch("skill").gsub("references/app-shell-navigation.md", ""))) }
  expect_failure("missing-adjacent-link") { audit(texts.merge("navigation" => texts.fetch("navigation").gsub("references/app-shell-navigation.md", ""))) }
  expect_failure("project-specific-leakage") { audit(texts.merge("owner" => "#{texts.fetch("owner")}\nfex-admin")) }
end

puts "PASS: 管理台 App Shell 与导航外框 owner、路由和证据符合结构化审计契约。"
