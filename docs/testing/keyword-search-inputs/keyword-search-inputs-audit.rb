#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/keyword-search-inputs.md")
QUERY_FILTERS = File.join(ROOT, "references/query-filters.md")
SEARCH_COMMAND = File.join(ROOT, "references/search-command-palette.md")
FORMS = File.join(ROOT, "references/forms.md")
DATA_TABLES = File.join(ROOT, "references/data-tables.md")
BUTTONS = File.join(ROOT, "references/buttons.md")
RESPONSIVE = File.join(ROOT, "references/responsive-adaptive.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/keyword-search-inputs/green-summary.md")
RED = File.join(ROOT, "docs/testing/keyword-search-inputs/red-summary.md")

STATE_FIELDS = %w[
  keywordOwnerId surfaceKind inputDraft normalizedDraft committedKeyword
  compositionState submitPolicy debounceState clearPolicy requestBinding
  historyBinding permissionBoundary feedbackBinding responsivePolicy
].freeze

OWNER_TERMS = [
  "keywordSearchInputState",
  "输入草稿不等于已提交关键词",
  "normalizedDraft 不等于 committedKeyword",
  "composition 未结束时 Enter 不得提交",
  "没有声明时默认 `explicit`，不得输入即请求",
  "普通输入只更新 `inputDraft` 和 `normalizedDraft`",
  "IME 输入法是硬边界",
  "compositionstart 到 compositionend 之间，Enter、Space、方向键和候选选择优先归输入法",
  "不得触发搜索提交、表格请求、URL 写入、历史写入、结果清空或按钮 loading",
  "防抖请求必须绑定 `keywordOwnerId`、normalized query、权限版本、租户/工作区、route、surfaceKind 和请求代次",
  "迟到结果只能写回仍 live 且身份匹配的 owner",
  "清空草稿、清空已提交关键词、重置默认关键词、取消输入必须是不同意图",
  "清空按钮不能靠一个 `onClear` 同时猜测四种意图",
  "`inputDraft`、composition 文本、未提交 normalizedDraft、敏感自由文本、邮箱、手机号、内部 ID、令牌、密钥、个人识别信息和权限范围不得写入 URL、页面标题、日志、analytics、最近搜索或保存视图",
  "placeholder 不能是唯一 label",
  "loading、too-short、invalid、error、permission-denied、cleared 和 submitted 只能由一个 primary owner 完整播报",
  "移动端不得删除输入、清空、提交、取消/返回、错误说明、权限原因、loading、结果摘要和恢复路径",
  "虚拟键盘打开时，当前输入、清空、提交、取消、错误和结果摘要不能被固定 toolbar、底部按钮、安全区域或键盘完全遮挡",
  "未验证"
].freeze

ROUTE_TERMS = [
  "关键词搜索", "搜索输入", "搜索框", "文本搜索", "列表搜索", "表格搜索",
  "报表搜索", "局部搜索", "页面内搜索", "筛选搜索", "即时搜索", "防抖搜索",
  "搜索清空", "清空搜索", "搜索重置", "输入法搜索", "中文输入法搜索",
  "IME 搜索", "搜索建议", "搜索历史", "最近关键词", "搜索 URL",
  "keyword search", "search input", "search box", "text search", "list search",
  "table search", "report search", "local search", "in-page search",
  "filter search", "instant search", "debounced search", "search clear",
  "clear search", "reset search", "IME search", "composition search",
  "search suggestion", "search history", "recent keyword", "search URL",
  "references/keyword-search-inputs.md"
].freeze

RELATIONSHIP_TERMS = [
  "references/keyword-search-inputs.md",
  "keyword-search-inputs.md"
].freeze

README_TERMS = [
  "关键词搜索输入规范",
  "references/keyword-search-inputs.md"
].freeze

HANDOFF_TERMS = [
  "### 关键词搜索输入",
  "keywordSearchInputState",
  "输入草稿不等于已提交关键词",
  "composition 未结束时 Enter 不得提交",
  "清空草稿、清空已提交关键词、重置默认关键词、取消输入必须是不同意图",
  "移动端不得删除输入、清空、提交、取消/返回、错误说明、权限原因、loading、结果摘要和恢复路径",
  "references/keyword-search-inputs.md"
].freeze

EVIDENCE_TERMS = STATE_FIELDS + [
  "keywordSearchInputState",
  "输入草稿",
  "已提交关键词",
  "normalizedDraft",
  "committedKeyword",
  "IME",
  "composition",
  "Enter",
  "debounce",
  "防抖",
  "清空草稿",
  "清空已提交关键词",
  "重置默认关键词",
  "取消输入",
  "URL",
  "搜索历史",
  "最近关键词",
  "迟到结果",
  "primary owner",
  "虚拟键盘",
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
    failures << "owner: keywordSearchInputState missing #{field}" unless owner.include?(field)
  end
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end

def integration_failures(query_filters:, search_command:, forms:, data_tables:, buttons:, responsive:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(require_terms(query_filters, RELATIONSHIP_TERMS, "query filters relationship"))
  failures.concat(require_terms(search_command, RELATIONSHIP_TERMS, "search command relationship"))
  failures.concat(require_terms(forms, RELATIONSHIP_TERMS, "forms relationship"))
  failures.concat(require_terms(data_tables, RELATIONSHIP_TERMS, "data tables relationship"))
  failures.concat(require_terms(buttons, RELATIONSHIP_TERMS, "buttons relationship"))
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

def audit(owner:, query_filters:, search_command:, forms:, data_tables:, buttons:, responsive:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(owner_failures(owner))
  failures.concat(integration_failures(query_filters: query_filters, search_command: search_command, forms: forms,
                                       data_tables: data_tables, buttons: buttons, responsive: responsive,
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
query_filters = read(QUERY_FILTERS)
search_command = read(SEARCH_COMMAND)
forms = read(FORMS)
data_tables = read(DATA_TABLES)
buttons = read(BUTTONS)
responsive = read(RESPONSIVE)
skill = read(SKILL)
readme = read(README)
handoff = read(HANDOFF)
green = read(GREEN)
red = read(RED)

failures = audit(owner: owner, query_filters: query_filters, search_command: search_command, forms: forms,
                 data_tables: data_tables, buttons: buttons, responsive: responsive, skill: skill,
                 readme: readme, handoff: handoff, green: green, red: red)
unless failures.empty?
  warn failures.join("\n")
  exit 1
end

if ARGV.include?("--mutations")
  expect_failure("missing-owner-state") do
    audit(owner: owner.gsub("keywordSearchInputState", "keyword-search-input-state"), query_filters: query_filters,
          search_command: search_command, forms: forms, data_tables: data_tables, buttons: buttons,
          responsive: responsive, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("draft-as-committed-keyword") do
    audit(owner: owner.gsub("输入草稿不等于已提交关键词", ""), query_filters: query_filters,
          search_command: search_command, forms: forms, data_tables: data_tables, buttons: buttons,
          responsive: responsive, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("normalized-as-committed-keyword") do
    audit(owner: owner.gsub("normalizedDraft 不等于 committedKeyword", ""), query_filters: query_filters,
          search_command: search_command, forms: forms, data_tables: data_tables, buttons: buttons,
          responsive: responsive, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("composition-enter-submits") do
    audit(owner: owner.gsub("composition 未结束时 Enter 不得提交", ""), query_filters: query_filters,
          search_command: search_command, forms: forms, data_tables: data_tables, buttons: buttons,
          responsive: responsive, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("implicit-input-request") do
    audit(owner: owner.gsub("没有声明时默认 `explicit`，不得输入即请求", ""), query_filters: query_filters,
          search_command: search_command, forms: forms, data_tables: data_tables, buttons: buttons,
          responsive: responsive, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("ime-boundary-missing") do
    audit(owner: owner.gsub("IME 输入法是硬边界", "")
                      .gsub("compositionstart 到 compositionend 之间，Enter、Space、方向键和候选选择优先归输入法", "")
                      .gsub("不得触发搜索提交、表格请求、URL 写入、历史写入、结果清空或按钮 loading", ""),
          query_filters: query_filters, search_command: search_command, forms: forms, data_tables: data_tables,
          buttons: buttons, responsive: responsive, skill: skill, readme: readme, handoff: handoff, green: green,
          red: red)
  end

  expect_failure("debounce-binding-missing") do
    audit(owner: owner.gsub("防抖请求必须绑定 `keywordOwnerId`、normalized query、权限版本、租户/工作区、route、surfaceKind 和请求代次", ""),
          query_filters: query_filters, search_command: search_command, forms: forms, data_tables: data_tables,
          buttons: buttons, responsive: responsive, skill: skill, readme: readme, handoff: handoff, green: green,
          red: red)
  end

  expect_failure("late-result-writes-new-owner") do
    audit(owner: owner.gsub("迟到结果只能写回仍 live 且身份匹配的 owner", ""), query_filters: query_filters,
          search_command: search_command, forms: forms, data_tables: data_tables, buttons: buttons,
          responsive: responsive, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("clear-intents-merged") do
    audit(owner: owner.gsub("清空草稿、清空已提交关键词、重置默认关键词、取消输入必须是不同意图", ""),
          query_filters: query_filters, search_command: search_command, forms: forms, data_tables: data_tables,
          buttons: buttons, responsive: responsive, skill: skill, readme: readme, handoff: handoff, green: green,
          red: red)
  end

  expect_failure("onclear-guesses-intent") do
    audit(owner: owner.gsub("清空按钮不能靠一个 `onClear` 同时猜测四种意图", ""), query_filters: query_filters,
          search_command: search_command, forms: forms, data_tables: data_tables, buttons: buttons,
          responsive: responsive, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("sensitive-draft-written-to-url") do
    audit(owner: owner.gsub("`inputDraft`、composition 文本、未提交 normalizedDraft、敏感自由文本、邮箱、手机号、内部 ID、令牌、密钥、个人识别信息和权限范围不得写入 URL、页面标题、日志、analytics、最近搜索或保存视图", ""),
          query_filters: query_filters, search_command: search_command, forms: forms, data_tables: data_tables,
          buttons: buttons, responsive: responsive, skill: skill, readme: readme, handoff: handoff, green: green,
          red: red)
  end

  expect_failure("placeholder-only-label") do
    audit(owner: owner.gsub("placeholder 不能是唯一 label", ""), query_filters: query_filters,
          search_command: search_command, forms: forms, data_tables: data_tables, buttons: buttons,
          responsive: responsive, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("duplicate-announcement-owner") do
    audit(owner: owner.gsub("loading、too-short、invalid、error、permission-denied、cleared 和 submitted 只能由一个 primary owner 完整播报", ""),
          query_filters: query_filters, search_command: search_command, forms: forms, data_tables: data_tables,
          buttons: buttons, responsive: responsive, skill: skill, readme: readme, handoff: handoff, green: green,
          red: red)
  end

  expect_failure("mobile-core-search-actions-removed") do
    audit(owner: owner.gsub("移动端不得删除输入、清空、提交、取消/返回、错误说明、权限原因、loading、结果摘要和恢复路径", ""),
          query_filters: query_filters, search_command: search_command, forms: forms, data_tables: data_tables,
          buttons: buttons, responsive: responsive, skill: skill, readme: readme, handoff: handoff, green: green,
          red: red)
  end

  expect_failure("virtual-keyboard-obscures-search") do
    audit(owner: owner.gsub("虚拟键盘打开时，当前输入、清空、提交、取消、错误和结果摘要不能被固定 toolbar、底部按钮、安全区域或键盘完全遮挡", ""),
          query_filters: query_filters, search_command: search_command, forms: forms, data_tables: data_tables,
          buttons: buttons, responsive: responsive, skill: skill, readme: readme, handoff: handoff, green: green,
          red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"), query_filters: query_filters, search_command: search_command,
          forms: forms, data_tables: data_tables, buttons: buttons, responsive: responsive, skill: skill,
          readme: readme, handoff: handoff.gsub("未验证", "已验证"), green: green.gsub("未验证", "已验证"),
          red: red.gsub("未验证", "已验证"))
  end

  expect_failure("missing-route") do
    audit(owner: owner, query_filters: query_filters, search_command: search_command, forms: forms,
          data_tables: data_tables, buttons: buttons, responsive: responsive,
          skill: skill.gsub("references/keyword-search-inputs.md", ""), readme: readme, handoff: handoff,
          green: green, red: red)
  end

  expect_failure("missing-adjacent-owner-link") do
    audit(owner: owner, query_filters: query_filters.gsub("keyword-search-inputs.md", ""),
          search_command: search_command.gsub("keyword-search-inputs.md", ""),
          forms: forms.gsub("keyword-search-inputs.md", ""),
          data_tables: data_tables.gsub("keyword-search-inputs.md", ""),
          buttons: buttons.gsub("keyword-search-inputs.md", ""),
          responsive: responsive.gsub("keyword-search-inputs.md", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("project-specific-leakage") do
    audit(owner: "#{owner}\nfex-admin", query_filters: query_filters, search_command: search_command, forms: forms,
          data_tables: data_tables, buttons: buttons, responsive: responsive, skill: skill, readme: readme,
          handoff: handoff, green: green, red: red)
  end
end
