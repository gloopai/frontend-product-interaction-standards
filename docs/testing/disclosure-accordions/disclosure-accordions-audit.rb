#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/disclosure-accordions.md")
FORMS = File.join(ROOT, "references/forms.md")
INFO = File.join(ROOT, "references/information-display.md")
QUERY = File.join(ROOT, "references/query-filters.md")
FEEDBACK = File.join(ROOT, "references/feedback-states.md")
PERMISSIONS = File.join(ROOT, "references/permissions-tenancy-visibility.md")
RESPONSIVE = File.join(ROOT, "references/responsive-adaptive.md")
TABS = File.join(ROOT, "references/tab-view-navigation.md")
TREE = File.join(ROOT, "references/tree-hierarchy.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/disclosure-accordions/green-summary.md")
RED = File.join(ROOT, "docs/testing/disclosure-accordions/red-summary.md")

STATE_FIELDS = %w[
  disclosureOwnerId surfaceKind itemRegistry expandedItemIds expansionPolicy
  contentState requestBinding errorVisibilityBinding permissionBoundary
  persistenceBinding focusAnnouncementPolicy responsivePolicy
].freeze

OWNER_TERMS = [
  "disclosureAccordionState",
  "展开状态不等于业务值、不等于表单提交、不等于权限事实",
  "折叠不能隐藏当前必须处理的错误、必填缺失、权限原因或恢复入口",
  "disabled、hidden、permission-denied 和 not-enabled item 不是同一状态",
  "懒加载迟到响应不得写回已收起、卸载、无权限或身份不匹配的 item",
  "嵌套折叠必须有唯一 owner 和层级边界",
  "移动端不得删除标题、当前展开状态、错误摘要、权限原因、恢复入口和核心操作",
  "触发器必须是真按钮或等价可访问控件",
  "展开状态可以作为用户偏好保存，但必须声明 `persistenceBinding`",
  "不得把展开状态写成业务字段、提交 payload、筛选条件、导出范围或权限事实",
  "URL、保存视图或本地偏好恢复展开状态前必须校验 itemRegistry 版本、权限、租户/工作区和对象状态",
  "未验证"
].freeze

ROUTE_TERMS = [
  "Accordion", "Collapse", "Disclosure", "折叠面板", "折叠区块", "展开收起",
  "展开面板", "收起面板", "详情折叠", "设置折叠", "高级筛选折叠",
  "错误详情折叠", "移动端折叠", "嵌套折叠",
  "accordion", "collapse", "disclosure", "expand collapse", "expandable panel",
  "collapsible panel", "collapsible section", "details disclosure",
  "settings accordion", "filter accordion", "error details", "mobile accordion",
  "nested accordion", "references/disclosure-accordions.md"
].freeze

RELATIONSHIP_TERMS = [
  "references/disclosure-accordions.md",
  "disclosure-accordions.md"
].freeze

README_TERMS = [
  "折叠面板与 Disclosure 规范",
  "references/disclosure-accordions.md"
].freeze

HANDOFF_TERMS = [
  "### 折叠面板与 Disclosure",
  "disclosureAccordionState",
  "展开状态不等于业务值、不等于表单提交、不等于权限事实",
  "折叠不能隐藏当前必须处理的错误、必填缺失、权限原因或恢复入口",
  "懒加载迟到响应不得写回已收起、卸载、无权限或身份不匹配的 item",
  "移动端不得删除标题、当前展开状态、错误摘要、权限原因、恢复入口和核心操作",
  "references/disclosure-accordions.md"
].freeze

EVIDENCE_TERMS = STATE_FIELDS + [
  "disclosureAccordionState",
  "expandedItemIds",
  "expansionPolicy",
  "contentState",
  "requestBinding",
  "errorVisibilityBinding",
  "permissionBoundary",
  "persistenceBinding",
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
    failures << "owner: disclosureAccordionState missing #{field}" unless owner.include?(field)
  end
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end

def integration_failures(forms:, info:, query:, feedback:, permissions:, responsive:, tabs:, tree:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(require_terms(forms, RELATIONSHIP_TERMS, "forms relationship"))
  failures.concat(require_terms(info, RELATIONSHIP_TERMS, "information relationship"))
  failures.concat(require_terms(query, RELATIONSHIP_TERMS, "query filters relationship"))
  failures.concat(require_terms(feedback, RELATIONSHIP_TERMS, "feedback relationship"))
  failures.concat(require_terms(permissions, RELATIONSHIP_TERMS, "permissions relationship"))
  failures.concat(require_terms(responsive, RELATIONSHIP_TERMS, "responsive relationship"))
  failures.concat(require_terms(tabs, RELATIONSHIP_TERMS, "tabs relationship"))
  failures.concat(require_terms(tree, RELATIONSHIP_TERMS, "tree relationship"))
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

def audit(owner:, forms:, info:, query:, feedback:, permissions:, responsive:, tabs:, tree:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(owner_failures(owner))
  failures.concat(integration_failures(forms: forms, info: info, query: query, feedback: feedback,
                                       permissions: permissions, responsive: responsive, tabs: tabs,
                                       tree: tree, skill: skill, readme: readme, handoff: handoff,
                                       green: green, red: red))
  failures.concat(project_leak_failures("owner" => owner, "green" => green, "red" => red))
  failures
end

def expect_failure(name)
  failures = yield
  abort("mutation did not fail: #{name}") if failures.empty?

  puts "EXPECTED_FAIL: #{name}"
end

owner = read(OWNER)
forms = read(FORMS)
info = read(INFO)
query = read(QUERY)
feedback = read(FEEDBACK)
permissions = read(PERMISSIONS)
responsive = read(RESPONSIVE)
tabs = read(TABS)
tree = read(TREE)
skill = read(SKILL)
readme = read(README)
handoff = read(HANDOFF)
green = read(GREEN)
red = read(RED)

failures = audit(owner: owner, forms: forms, info: info, query: query, feedback: feedback,
                 permissions: permissions, responsive: responsive, tabs: tabs, tree: tree,
                 skill: skill, readme: readme, handoff: handoff, green: green, red: red)
unless failures.empty?
  warn failures.join("\n")
  exit 1
end

if ARGV.include?("--mutations")
  mutation_cases = {
    "missing-owner-state" => owner.gsub("disclosureAccordionState", "disclosure-accordion-state"),
    "expansion-as-business-value" => owner.gsub("展开状态不等于业务值、不等于表单提交、不等于权限事实", ""),
    "hidden-error" => owner.gsub("折叠不能隐藏当前必须处理的错误、必填缺失、权限原因或恢复入口", ""),
    "states-merged" => owner.gsub("disabled、hidden、permission-denied 和 not-enabled item 不是同一状态", ""),
    "late-response-writes-invalid-item" => owner.gsub("懒加载迟到响应不得写回已收起、卸载、无权限或身份不匹配的 item", ""),
    "nested-owner-boundary-removed" => owner.gsub("嵌套折叠必须有唯一 owner 和层级边界", ""),
    "mobile-core-capability-removed" => owner.gsub("移动端不得删除标题、当前展开状态、错误摘要、权限原因、恢复入口和核心操作", ""),
    "trigger-not-button" => owner.gsub("触发器必须是真按钮或等价可访问控件", ""),
    "persistence-without-binding" => owner.gsub("展开状态可以作为用户偏好保存，但必须声明 `persistenceBinding`", ""),
    "persisted-as-payload" => owner.gsub("不得把展开状态写成业务字段、提交 payload、筛选条件、导出范围或权限事实", ""),
    "restore-without-validation" => owner.gsub("URL、保存视图或本地偏好恢复展开状态前必须校验 itemRegistry 版本、权限、租户/工作区和对象状态", ""),
    "runtime-boundary-marked-verified" => owner.gsub("未验证", "已验证")
  }

  mutation_cases.each do |name, mutated_owner|
    expect_failure(name) do
      audit(owner: mutated_owner, forms: forms, info: info, query: query, feedback: feedback,
            permissions: permissions, responsive: responsive, tabs: tabs, tree: tree, skill: skill,
            readme: readme, handoff: handoff, green: green, red: red)
    end
  end

  expect_failure("missing-route") do
    audit(owner: owner, forms: forms, info: info, query: query, feedback: feedback,
          permissions: permissions, responsive: responsive, tabs: tabs, tree: tree,
          skill: skill.gsub("references/disclosure-accordions.md", ""), readme: readme,
          handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-adjacent-owner-link") do
    audit(owner: owner, forms: forms.gsub("references/disclosure-accordions.md", ""), info: info,
          query: query, feedback: feedback, permissions: permissions, responsive: responsive,
          tabs: tabs, tree: tree, skill: skill, readme: readme, handoff: handoff,
          green: green, red: red)
  end

  expect_failure("project-specific-leakage") do
    audit(owner: "#{owner}\nfex-admin", forms: forms, info: info, query: query, feedback: feedback,
          permissions: permissions, responsive: responsive, tabs: tabs, tree: tree, skill: skill,
          readme: readme, handoff: handoff, green: green, red: red)
  end
end
