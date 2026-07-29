#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/list-result-controls.md")
DATA_TABLES = File.join(ROOT, "references/data-tables.md")
QUERY_FILTERS = File.join(ROOT, "references/query-filters.md")
KEYWORD_SEARCH = File.join(ROOT, "references/keyword-search-inputs.md")
PAGE_TOOLBARS = File.join(ROOT, "references/page-toolbars-actions.md")
FEEDBACK_STATES = File.join(ROOT, "references/feedback-states.md")
SAVED_VIEWS = File.join(ROOT, "references/saved-views-layout-presets.md")
EXPORTS = File.join(ROOT, "references/exports-downloads-artifacts.md")
RESPONSIVE = File.join(ROOT, "references/responsive-adaptive.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/list-result-controls/green-summary.md")
RED = File.join(ROOT, "docs/testing/list-result-controls/red-summary.md")

STATE_FIELDS = %w[
  resultControlsOwnerId surfaceKind appliedQueryBinding querySnapshot requestGeneration
  requestPhase sortState paginationState refreshState resultSummary selectionImpact
  urlHistoryBinding permissionBoundary feedbackBinding responsivePolicy
].freeze

OWNER_TERMS = [
  "listResultControlsState",
  "结果控制只能读取已应用查询，不得读取筛选草稿或搜索输入草稿",
  "排序变化、页大小变化和有效筛选/关键词变化必须建立新 `querySnapshot`",
  "迟到响应不得覆盖当前 owner、当前代次或当前快照不匹配的结果",
  "页码分页和游标分页不得在同一快照内混用",
  "总数不可靠时不得展示精确总页数、随机跳页或“全部 N 条”的承诺",
  "刷新保留旧结果并标记 refreshing/stale，不得把旧结果伪装成新响应",
  "响应只有同时满足当前 owner live、`resultControlsOwnerId` 相同、`requestGeneration` 相同、`querySnapshot` 身份相同、权限/租户仍匹配时，才可写入结果、分页、总数、错误、loading 或结果摘要",
  "提交不同排序时，页码分页回到第 1 页，游标分页回到初始游标，并创建新快照",
  "改变页大小必须回到第一个有效位置并创建新快照",
  "服务端拒绝的页大小不能成为当前值",
  "同一 in-flight 且同键的刷新可以合并；不同键刷新必须新建代次",
  "刷新失败不能清空已有结果；首次加载失败才可替代结果区域",
  "只有已提交且 `urlSafe` 的排序、分页、页大小和查询条件可以写 URL",
  "旧 URL、浏览器返回和保存视图恢复必须先校验版本、权限、租户/工作区、页大小合法性、排序字段合法性和分页模式",
  "移动端不得删除排序、分页、刷新、结果摘要、错误说明、权限原因、过期说明和恢复路径",
  "底部分页、固定工具栏、虚拟键盘和 safe-area 不能完全遮挡当前页、下一页、刷新、错误和结果摘要",
  "未验证"
].freeze

ROUTE_TERMS = [
  "列表结果", "结果控制", "结果摘要", "分页", "页码", "游标分页", "上一页",
  "下一页", "跳页", "页大小", "每页数量", "排序", "列表排序", "表格排序",
  "刷新", "自动刷新", "结果刷新", "过期数据", "数据版本", "迟到响应",
  "请求代次", "总数不可靠",
  "list result", "result controls", "result summary", "pagination", "page number",
  "cursor pagination", "previous page", "next page", "jump page", "page size",
  "per page", "sorting", "list sorting", "table sorting", "refresh", "auto refresh",
  "result refresh", "stale data", "dataset version", "late response",
  "request generation", "unreliable total", "references/list-result-controls.md"
].freeze

RELATIONSHIP_TERMS = [
  "references/list-result-controls.md",
  "list-result-controls.md"
].freeze

README_TERMS = [
  "列表结果控制规范",
  "references/list-result-controls.md"
].freeze

HANDOFF_TERMS = [
  "### 列表结果控制",
  "listResultControlsState",
  "结果控制只能读取已应用查询，不得读取筛选草稿或搜索输入草稿",
  "排序变化、页大小变化和有效筛选/关键词变化必须建立新 `querySnapshot`",
  "迟到响应不得覆盖当前 owner、当前代次或当前快照不匹配的结果",
  "页码分页和游标分页不得在同一快照内混用",
  "总数不可靠时不得展示精确总页数、随机跳页或“全部 N 条”的承诺",
  "移动端不得删除排序、分页、刷新、结果摘要、错误说明、权限原因、过期说明和恢复路径",
  "references/list-result-controls.md"
].freeze

EVIDENCE_TERMS = STATE_FIELDS + [
  "listResultControlsState",
  "已应用查询",
  "筛选草稿",
  "搜索输入草稿",
  "排序变化",
  "页大小变化",
  "有效筛选/关键词变化",
  "querySnapshot",
  "迟到响应",
  "owner live",
  "requestGeneration",
  "页码分页",
  "游标分页",
  "总数不可靠",
  "精确总页数",
  "refreshing",
  "stale",
  "刷新失败",
  "旧结果",
  "URL",
  "浏览器返回",
  "保存视图恢复",
  "移动端",
  "虚拟键盘",
  "safe-area",
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
    failures << "owner: listResultControlsState missing #{field}" unless owner.include?(field)
  end
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end

def integration_failures(data_tables:, query_filters:, keyword_search:, page_toolbars:, feedback_states:, saved_views:, exports:, responsive:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(require_terms(data_tables, RELATIONSHIP_TERMS, "data tables relationship"))
  failures.concat(require_terms(query_filters, RELATIONSHIP_TERMS, "query filters relationship"))
  failures.concat(require_terms(keyword_search, RELATIONSHIP_TERMS, "keyword search relationship"))
  failures.concat(require_terms(page_toolbars, RELATIONSHIP_TERMS, "page toolbars relationship"))
  failures.concat(require_terms(feedback_states, RELATIONSHIP_TERMS, "feedback states relationship"))
  failures.concat(require_terms(saved_views, RELATIONSHIP_TERMS, "saved views relationship"))
  failures.concat(require_terms(exports, RELATIONSHIP_TERMS, "exports relationship"))
  failures.concat(require_terms(responsive, RELATIONSHIP_TERMS, "responsive relationship"))
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

def audit(owner:, data_tables:, query_filters:, keyword_search:, page_toolbars:, feedback_states:, saved_views:, exports:, responsive:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(owner_failures(owner))
  failures.concat(integration_failures(data_tables: data_tables, query_filters: query_filters, keyword_search: keyword_search,
                                       page_toolbars: page_toolbars, feedback_states: feedback_states,
                                       saved_views: saved_views, exports: exports, responsive: responsive,
                                       skill: skill, readme: readme, handoff: handoff, green: green, red: red))
  failures.concat(project_leak_failures("owner" => owner, "green" => green, "red" => red))
  failures
end

def expect_failure(name)
  failures = yield
  abort("mutation did not fail: #{name}") if failures.empty?

  puts "EXPECTED_FAIL: #{name}"
end

owner = read(OWNER)
data_tables = read(DATA_TABLES)
query_filters = read(QUERY_FILTERS)
keyword_search = read(KEYWORD_SEARCH)
page_toolbars = read(PAGE_TOOLBARS)
feedback_states = read(FEEDBACK_STATES)
saved_views = read(SAVED_VIEWS)
exports = read(EXPORTS)
responsive = read(RESPONSIVE)
skill = read(SKILL)
readme = read(README)
handoff = read(HANDOFF)
green = read(GREEN)
red = read(RED)

failures = audit(owner: owner, data_tables: data_tables, query_filters: query_filters, keyword_search: keyword_search,
                 page_toolbars: page_toolbars, feedback_states: feedback_states, saved_views: saved_views,
                 exports: exports, responsive: responsive, skill: skill, readme: readme, handoff: handoff,
                 green: green, red: red)
unless failures.empty?
  warn failures.join("\n")
  exit 1
end

if ARGV.include?("--mutations")
  mutation_cases = {
    "missing-owner-state" => owner.gsub("listResultControlsState", "list-result-controls-state"),
    "reads-filter-draft" => owner.gsub("结果控制只能读取已应用查询，不得读取筛选草稿或搜索输入草稿", ""),
    "reads-input-draft" => owner.gsub("搜索输入草稿", "搜索草稿"),
    "sort-without-new-snapshot" => owner.gsub("排序变化、页大小变化和有效筛选/关键词变化必须建立新 `querySnapshot`", ""),
    "page-size-without-new-snapshot" => owner.gsub("改变页大小必须回到第一个有效位置并创建新快照", ""),
    "late-response-overwrites-current" => owner.gsub("迟到响应不得覆盖当前 owner、当前代次或当前快照不匹配的结果", ""),
    "mixed-pagination-mode" => owner.gsub("页码分页和游标分页不得在同一快照内混用", ""),
    "unreliable-total-precise-pages" => owner.gsub("总数不可靠时不得展示精确总页数、随机跳页或“全部 N 条”的承诺", ""),
    "refresh-clears-old-result" => owner.gsub("刷新保留旧结果并标记 refreshing/stale，不得把旧结果伪装成新响应", ""),
    "weak-response-guard" => owner.gsub("响应只有同时满足当前 owner live、`resultControlsOwnerId` 相同、`requestGeneration` 相同、`querySnapshot` 身份相同、权限/租户仍匹配时，才可写入结果、分页、总数、错误、loading 或结果摘要", ""),
    "sort-does-not-reset-position" => owner.gsub("提交不同排序时，页码分页回到第 1 页，游标分页回到初始游标，并创建新快照", ""),
    "rejected-page-size-committed" => owner.gsub("服务端拒绝的页大小不能成为当前值", ""),
    "refresh-dedup-global" => owner.gsub("同一 in-flight 且同键的刷新可以合并；不同键刷新必须新建代次", ""),
    "url-restore-without-validation" => owner.gsub("旧 URL、浏览器返回和保存视图恢复必须先校验版本、权限、租户/工作区、页大小合法性、排序字段合法性和分页模式", ""),
    "mobile-controls-removed" => owner.gsub("移动端不得删除排序、分页、刷新、结果摘要、错误说明、权限原因、过期说明和恢复路径", ""),
    "keyboard-obscures-pagination" => owner.gsub("底部分页、固定工具栏、虚拟键盘和 safe-area 不能完全遮挡当前页、下一页、刷新、错误和结果摘要", ""),
    "runtime-boundary-marked-verified" => owner.gsub("未验证", "已验证")
  }

  mutation_cases.each do |name, mutated_owner|
    expect_failure(name) do
      audit(owner: mutated_owner, data_tables: data_tables, query_filters: query_filters,
            keyword_search: keyword_search, page_toolbars: page_toolbars, feedback_states: feedback_states,
            saved_views: saved_views, exports: exports, responsive: responsive, skill: skill, readme: readme,
            handoff: handoff, green: green, red: red)
    end
  end

  expect_failure("missing-route") do
    audit(owner: owner, data_tables: data_tables, query_filters: query_filters, keyword_search: keyword_search,
          page_toolbars: page_toolbars, feedback_states: feedback_states, saved_views: saved_views,
          exports: exports, responsive: responsive, skill: skill.gsub("references/list-result-controls.md", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-adjacent-owner-link") do
    audit(owner: owner, data_tables: data_tables.gsub("references/list-result-controls.md", ""),
          query_filters: query_filters, keyword_search: keyword_search, page_toolbars: page_toolbars,
          feedback_states: feedback_states, saved_views: saved_views, exports: exports, responsive: responsive,
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("project-specific-leakage") do
    audit(owner: "#{owner}\nfex-admin", data_tables: data_tables, query_filters: query_filters,
          keyword_search: keyword_search, page_toolbars: page_toolbars, feedback_states: feedback_states,
          saved_views: saved_views, exports: exports, responsive: responsive, skill: skill, readme: readme,
          handoff: handoff, green: green, red: red)
  end
end
