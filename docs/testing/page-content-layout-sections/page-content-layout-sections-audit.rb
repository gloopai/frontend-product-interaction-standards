#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/page-content-layout-sections.md")
PAGE_HEADER = File.join(ROOT, "references/page-header-title-area.md")
TOOLBARS = File.join(ROOT, "references/page-toolbars-actions.md")
RESPONSIVE = File.join(ROOT, "references/responsive-adaptive.md")
FEEDBACK = File.join(ROOT, "references/feedback-states.md")
ADMIN = File.join(ROOT, "references/admin-console.md")
INFO = File.join(ROOT, "references/information-display.md")
FORMS = File.join(ROOT, "references/forms.md")
DATA_TABLES = File.join(ROOT, "references/data-tables.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/page-content-layout-sections/green-summary.md")
RED = File.join(ROOT, "docs/testing/page-content-layout-sections/red-summary.md")

STATE_FIELDS = %w[
  contentOwnerId contentSurface pageBinding sectionRegistry layoutGridPolicy
  scrollBoundary stickyBoundary densityPolicy contentPriority emptyLoadingErrorBinding
  ownerHandoff permissionBoundary responsivePolicy focusAnnouncementPolicy
  lifecycleDisposal runtimeVerification
].freeze

OWNER_TERMS = [
  "pageContentLayoutState",
  "页面内容区不是随意堆卡片，也不是 CSS 网格细节",
  "页面正文必须绑定当前页面 owner、标题区、工具栏、权限版本和主内容区域",
  "每个 Section、Card、分栏、列表区、表单区、图表区和信息区必须有明确 ownerHandoff",
  "主滚动只能有一个可解释 owner；不得让页面、卡片、表格、Drawer 和 Dialog 形成无声明的嵌套滚动",
  "Sticky、fixed、吸顶、底部操作、分页、工具栏、标题区和安全区域不得遮挡当前焦点、错误、状态摘要、主操作或恢复路径",
  "移动端可以重排、折叠、分组或转为单列，但不得删除页面标题、核心 Section、状态说明、权限原因、主操作、错误恢复和返回路径",
  "权限降级、租户/工作区切换、断点转换、Section 隐藏、数据刷新、路由变化或 owner 卸载后，旧 Section、旧卡片、旧滚动位置、旧 sticky 偏移、旧 ARIA 区域、旧焦点目标和旧占位必须失效或重算",
  "未验证"
].freeze

ROUTE_TERMS = [
  "页面内容区", "页面正文", "主内容区", "内容布局", "Section", "区块",
  "卡片区块", "内容卡片", "布局容器", "分栏布局", "栅格布局", "主滚动",
  "嵌套滚动", "吸顶", "sticky", "fixed", "固定栏", "内容密度",
  "页面留白", "安全区域", "移动端单列", "页面分组", "page content",
  "main content", "content layout", "content section", "section layout",
  "card section", "layout grid", "responsive layout", "main scroll",
  "nested scroll", "sticky section", "content density", "mobile single column",
  "references/page-content-layout-sections.md"
].freeze

ADJACENT_TERMS = ["references/page-content-layout-sections.md", "page-content-layout-sections.md"].freeze
README_TERMS = ["页面内容区与 Section 布局规范", "references/page-content-layout-sections.md"].freeze
HANDOFF_TERMS = [
  "### 页面内容区与 Section 布局",
  "pageContentLayoutState",
  "页面内容区不是随意堆卡片，也不是 CSS 网格细节",
  "主滚动只能有一个可解释 owner",
  "references/page-content-layout-sections.md"
].freeze
EVIDENCE_TERMS = STATE_FIELDS + ["pageContentLayoutState", "sectionRegistry", "scrollBoundary", "stickyBoundary", "ownerHandoff", "未验证"]
PROJECT_BANNED_TERMS = ["fex-admin", "/Users/evanqi/code/", "src/pages", "Ant Design", "ant-design", "shadcn", "Next.js", "Vite", "React", "Vue"].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)
  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def owner_failures(owner)
  STATE_FIELDS.reject { |field| owner.include?(field) }.map { |field| "owner: pageContentLayoutState missing #{field}" } +
    require_terms(owner, OWNER_TERMS, "owner")
end

def integration_failures(texts)
  failures = []
  %w[page_header toolbars responsive feedback admin info forms data_tables].each do |key|
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
  "page_header" => read(PAGE_HEADER),
  "toolbars" => read(TOOLBARS),
  "responsive" => read(RESPONSIVE),
  "feedback" => read(FEEDBACK),
  "admin" => read(ADMIN),
  "info" => read(INFO),
  "forms" => read(FORMS),
  "data_tables" => read(DATA_TABLES),
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
    "missing-owner-state" => texts.fetch("owner").gsub("pageContentLayoutState", "page-content-layout-state"),
    "card-pile-rule-removed" => texts.fetch("owner").gsub("页面内容区不是随意堆卡片，也不是 CSS 网格细节", ""),
    "page-binding-removed" => texts.fetch("owner").gsub("页面正文必须绑定当前页面 owner、标题区、工具栏、权限版本和主内容区域", ""),
    "handoff-removed" => texts.fetch("owner").gsub("每个 Section、Card、分栏、列表区、表单区、图表区和信息区必须有明确 ownerHandoff", ""),
    "scroll-owner-removed" => texts.fetch("owner").gsub("主滚动只能有一个可解释 owner；不得让页面、卡片、表格、Drawer 和 Dialog 形成无声明的嵌套滚动", ""),
    "sticky-boundary-removed" => texts.fetch("owner").gsub("Sticky、fixed、吸顶、底部操作、分页、工具栏、标题区和安全区域不得遮挡当前焦点、错误、状态摘要、主操作或恢复路径", ""),
    "mobile-core-removed" => texts.fetch("owner").gsub("移动端可以重排、折叠、分组或转为单列，但不得删除页面标题、核心 Section、状态说明、权限原因、主操作、错误恢复和返回路径", ""),
    "disposal-removed" => texts.fetch("owner").gsub("权限降级、租户/工作区切换、断点转换、Section 隐藏、数据刷新、路由变化或 owner 卸载后，旧 Section、旧卡片、旧滚动位置、旧 sticky 偏移、旧 ARIA 区域、旧焦点目标和旧占位必须失效或重算", ""),
    "runtime-boundary-marked-verified" => texts.fetch("owner").gsub("未验证", "已验证")
  }.each do |name, mutated_owner|
    expect_failure(name) { audit(texts.merge("owner" => mutated_owner)) }
  end

  expect_failure("missing-skill-route") do
    audit(texts.merge("skill" => texts.fetch("skill").gsub("references/page-content-layout-sections.md", "references/missing.md")))
  end

  expect_failure("missing-readme-link") do
    audit(texts.merge("readme" => texts.fetch("readme").gsub("references/page-content-layout-sections.md", "references/missing.md")))
  end

  expect_failure("missing-handoff-section") do
    audit(texts.merge("handoff" => texts.fetch("handoff").gsub("### 页面内容区与 Section 布局", "### 页面内容布局")))
  end

  expect_failure("project-leak") do
    audit(texts.merge("owner" => "#{texts.fetch("owner")}\nfex-admin\n"))
  end
end

puts "PASS: 页面内容区与 Section 布局 owner、路由和证据符合结构化审计契约。"
