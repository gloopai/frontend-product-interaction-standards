#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/tab-view-navigation.md")
NAVIGATION = File.join(ROOT, "references/navigation-routing.md")
SELECTION = File.join(ROOT, "references/selection-controls.md")
FORMS = File.join(ROOT, "references/forms.md")
PERMISSIONS = File.join(ROOT, "references/permissions-tenancy-visibility.md")
RESPONSIVE = File.join(ROOT, "references/responsive-adaptive.md")
FEEDBACK = File.join(ROOT, "references/feedback-states.md")
TOOLBARS = File.join(ROOT, "references/page-toolbars-actions.md")
SAVED_VIEWS = File.join(ROOT, "references/saved-views-layout-presets.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/tab-view-navigation/green-summary.md")
RED = File.join(ROOT, "docs/testing/tab-view-navigation/red-summary.md")

STATE_FIELDS = %w[
  tabOwnerId surfaceKind tabRegistry activeTabId pendingTabIntent panelState
  requestBinding urlHistoryBinding permissionBoundary dirtyBoundary
  focusAnnouncementPolicy responsivePolicy
].freeze

OWNER_TERMS = [
  "tabViewState",
  "Tabs 只能用于同一资源或同一任务上下文",
  "激活 tab 不等于提交表单、不等于保存视图、不等于切换租户/工作区",
  "disabled tab、hidden tab、permission-denied tab 和 not-enabled tab 不是同一状态",
  "旧 tab 请求不得写回新 active tab 或无权限 panel",
  "Tab 切换必须经过同一未保存保护管线",
  "移动端改变承载形态不得改变 `activeTabId`、URL、权限和 dirty 语义",
  "Tab 切换先创建 `pendingTabIntent`",
  "写 URL 的 tab 必须只写稳定 `tabId`",
  "浏览器 Back/Forward、URL 恢复、保存视图恢复和默认 tab 恢复必须先校验 tabRegistry 版本、权限、租户/工作区、对象状态和 tab 是否仍启用",
  "懒加载请求必须绑定 `tabOwnerId`、`activeTabId`、目标 `tabId`、对象 ID、权限版本、租户/工作区、route 和请求代次",
  "用户确认放弃前不得卸载 panel、发起新 tab 请求或改变 URL",
  "未启用表示 DOM、state、handler、request 和 URL 入口均为 0",
  "无权限不得泄露 tab 标题、数量、对象名、错误明细、旧内容或内部 ID",
  "移动端不得删除当前 tab、可用 tab、禁用原因、权限原因、错误状态、未保存保护、返回路径和恢复入口",
  "转换为 Select 或 Drawer 时仍是页面内 tab view，不得变成字段选择",
  "未验证"
].freeze

ROUTE_TERMS = [
  "Tabs", "标签页", "页签", "TabList", "TabPanel", "当前标签", "默认标签",
  "禁用标签", "隐藏标签", "权限标签", "页面内视图切换", "对象详情标签",
  "设置页标签", "报表标签", "列表状态标签", "移动端标签", "横向滚动标签",
  "tabs", "tab view", "tab navigation", "tablist", "tabpanel", "active tab",
  "default tab", "disabled tab", "hidden tab", "permission tab", "page tabs",
  "record tabs", "settings tabs", "report tabs", "status tabs", "mobile tabs",
  "scrollable tabs", "references/tab-view-navigation.md"
].freeze

RELATIONSHIP_TERMS = [
  "references/tab-view-navigation.md",
  "tab-view-navigation.md"
].freeze

README_TERMS = [
  "Tab 视图导航规范",
  "references/tab-view-navigation.md"
].freeze

HANDOFF_TERMS = [
  "### Tab 视图导航",
  "tabViewState",
  "Tabs 只能用于同一资源或同一任务上下文",
  "激活 tab 不等于提交表单、不等于保存视图、不等于切换租户/工作区",
  "旧 tab 请求不得写回新 active tab 或无权限 panel",
  "Tab 切换必须经过同一未保存保护管线",
  "移动端改变承载形态不得改变 `activeTabId`、URL、权限和 dirty 语义",
  "references/tab-view-navigation.md"
].freeze

EVIDENCE_TERMS = STATE_FIELDS + [
  "tabViewState",
  "activeTabId",
  "pendingTabIntent",
  "panelState",
  "requestBinding",
  "dirtyBoundary",
  "permissionBoundary",
  "responsivePolicy",
  "URL",
  "懒加载",
  "未保存保护",
  "移动端",
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
    failures << "owner: tabViewState missing #{field}" unless owner.include?(field)
  end
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end

def integration_failures(navigation:, selection:, forms:, permissions:, responsive:, feedback:, toolbars:, saved_views:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(require_terms(navigation, RELATIONSHIP_TERMS, "navigation relationship"))
  failures.concat(require_terms(selection, RELATIONSHIP_TERMS, "selection relationship"))
  failures.concat(require_terms(forms, RELATIONSHIP_TERMS, "forms relationship"))
  failures.concat(require_terms(permissions, RELATIONSHIP_TERMS, "permissions relationship"))
  failures.concat(require_terms(responsive, RELATIONSHIP_TERMS, "responsive relationship"))
  failures.concat(require_terms(feedback, RELATIONSHIP_TERMS, "feedback relationship"))
  failures.concat(require_terms(toolbars, RELATIONSHIP_TERMS, "toolbars relationship"))
  failures.concat(require_terms(saved_views, RELATIONSHIP_TERMS, "saved views relationship"))
  failures.concat(require_terms(skill, ROUTE_TERMS, "SKILL route"))
  failures.concat(require_terms(readme, README_TERMS, "README"))
  failures.concat(require_terms(handoff, HANDOFF_TERMS, "HANDOFF"))
  failures.concat(require_terms(green, EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(red, EVIDENCE_TERMS, "RED evidence"))
  failures
end

def project_leak_failures(texts)
  PROJECT_BANNED_TERMS.flat_map do |term|
    texts.select { |label, text| text.include?(term) }.map { |label, _text| "#{label}: forbidden project-specific term #{term}" }
  end
end

def audit(owner:, navigation:, selection:, forms:, permissions:, responsive:, feedback:, toolbars:, saved_views:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(owner_failures(owner))
  failures.concat(integration_failures(navigation: navigation, selection: selection, forms: forms,
                                       permissions: permissions, responsive: responsive, feedback: feedback,
                                       toolbars: toolbars, saved_views: saved_views, skill: skill,
                                       readme: readme, handoff: handoff, green: green, red: red))
  failures.concat(project_leak_failures("owner" => owner, "green" => green, "red" => red))
  failures
end

def expect_failure(name)
  failures = yield
  abort("mutation did not fail: #{name}") if failures.empty?

  puts "EXPECTED_FAIL: #{name}"
end

owner = read(OWNER)
navigation = read(NAVIGATION)
selection = read(SELECTION)
forms = read(FORMS)
permissions = read(PERMISSIONS)
responsive = read(RESPONSIVE)
feedback = read(FEEDBACK)
toolbars = read(TOOLBARS)
saved_views = read(SAVED_VIEWS)
skill = read(SKILL)
readme = read(README)
handoff = read(HANDOFF)
green = read(GREEN)
red = read(RED)

failures = audit(owner: owner, navigation: navigation, selection: selection, forms: forms,
                 permissions: permissions, responsive: responsive, feedback: feedback,
                 toolbars: toolbars, saved_views: saved_views, skill: skill, readme: readme,
                 handoff: handoff, green: green, red: red)
unless failures.empty?
  warn failures.join("\n")
  exit 1
end

if ARGV.include?("--mutations")
  mutation_cases = {
    "missing-owner-state" => owner.gsub("tabViewState", "tab-view-state"),
    "tabs-cross-resource" => owner.gsub("Tabs 只能用于同一资源或同一任务上下文", ""),
    "active-tab-submits-form" => owner.gsub("激活 tab 不等于提交表单、不等于保存视图、不等于切换租户/工作区", ""),
    "tab-states-merged" => owner.gsub("disabled tab、hidden tab、permission-denied tab 和 not-enabled tab 不是同一状态", ""),
    "late-request-writes-active" => owner.gsub("旧 tab 请求不得写回新 active tab 或无权限 panel", ""),
    "dirty-guard-removed" => owner.gsub("Tab 切换必须经过同一未保存保护管线", ""),
    "mobile-conversion-changes-active" => owner.gsub("移动端改变承载形态不得改变 `activeTabId`、URL、权限和 dirty 语义", ""),
    "pending-intent-missing" => owner.gsub("Tab 切换先创建 `pendingTabIntent`", ""),
    "url-writes-title" => owner.gsub("写 URL 的 tab 必须只写稳定 `tabId`", ""),
    "url-restore-without-validation" => owner.gsub("浏览器 Back/Forward、URL 恢复、保存视图恢复和默认 tab 恢复必须先校验 tabRegistry 版本、权限、租户/工作区、对象状态和 tab 是否仍启用", ""),
    "lazy-request-weak-binding" => owner.gsub("懒加载请求必须绑定 `tabOwnerId`、`activeTabId`、目标 `tabId`、对象 ID、权限版本、租户/工作区、route 和请求代次", ""),
    "unmount-before-discard-confirm" => owner.gsub("用户确认放弃前不得卸载 panel、发起新 tab 请求或改变 URL", ""),
    "not-enabled-still-has-entry" => owner.gsub("未启用表示 DOM、state、handler、request 和 URL 入口均为 0", ""),
    "permission-leakage" => owner.gsub("无权限不得泄露 tab 标题、数量、对象名、错误明细、旧内容或内部 ID", ""),
    "mobile-tab-capability-removed" => owner.gsub("移动端不得删除当前 tab、可用 tab、禁用原因、权限原因、错误状态、未保存保护、返回路径和恢复入口", ""),
    "select-conversion-as-field" => owner.gsub("转换为 Select 或 Drawer 时仍是页面内 tab view，不得变成字段选择", ""),
    "runtime-boundary-marked-verified" => owner.gsub("未验证", "已验证")
  }

  mutation_cases.each do |name, mutated_owner|
    expect_failure(name) do
      audit(owner: mutated_owner, navigation: navigation, selection: selection, forms: forms,
            permissions: permissions, responsive: responsive, feedback: feedback, toolbars: toolbars,
            saved_views: saved_views, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
    end
  end

  expect_failure("missing-route") do
    audit(owner: owner, navigation: navigation, selection: selection, forms: forms, permissions: permissions,
          responsive: responsive, feedback: feedback, toolbars: toolbars, saved_views: saved_views,
          skill: skill.gsub("references/tab-view-navigation.md", ""), readme: readme, handoff: handoff,
          green: green, red: red)
  end

  expect_failure("missing-adjacent-owner-link") do
    audit(owner: owner, navigation: navigation.gsub("references/tab-view-navigation.md", ""),
          selection: selection, forms: forms, permissions: permissions, responsive: responsive,
          feedback: feedback, toolbars: toolbars, saved_views: saved_views, skill: skill, readme: readme,
          handoff: handoff, green: green, red: red)
  end

  expect_failure("project-specific-leakage") do
    audit(owner: "#{owner}\nfex-admin", navigation: navigation, selection: selection, forms: forms,
          permissions: permissions, responsive: responsive, feedback: feedback, toolbars: toolbars,
          saved_views: saved_views, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end
