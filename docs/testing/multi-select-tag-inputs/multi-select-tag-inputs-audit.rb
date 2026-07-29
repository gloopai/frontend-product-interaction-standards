#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/multi-select-tag-inputs.md")
SELECTS = File.join(ROOT, "references/selects-comboboxes.md")
SELECTION = File.join(ROOT, "references/selection-controls.md")
FILTERS = File.join(ROOT, "references/query-filters.md")
MEMBERS = File.join(ROOT, "references/members-invitations-access.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/multi-select-tag-inputs/green-summary.md")
RED = File.join(ROOT, "docs/testing/multi-select-tag-inputs/red-summary.md")

STATE_FIELDS = %w[
  multiValueOwnerId valueKind committedValues draftTokens queryState
  candidateOptions creationPolicy pastePolicy commitPolicy
  validationState permissionBoundary feedbackBinding responsivePolicy
].freeze

OWNER_TERMS = [
  "multiValueInputState",
  "多值输入不能只维护一个数组",
  "已提交值、当前草稿 tokens、输入 query、active option、候选列表、创建候选和粘贴候选必须分别可观察",
  "只有符合 `commitPolicy` 的明确提交动作，才允许把合法 `draftTokens` 写入已提交值",
  "不得因为按 Enter 就把任意 query 提交为业务值",
  "创建标签不等于已提交字段",
  "服务端创建成功不等于表单保存、筛选应用或设置生效",
  "Backspace 在 query 非空时只编辑 query",
  "第一次 Backspace 只能高亮最后一个可删除 token，第二次明确删除该 token",
  "批量粘贴不能直接提交",
  "重复判断必须基于稳定业务键，而不是显示标签",
  "迟到结果只能写回仍 live 且身份匹配的 `multiValueOwnerId` 和草稿代次",
  "旧搜索结果、旧创建结果、旧校验错误、旧 active option、旧焦点目标和旧 ARIA 引用必须失效或重新证明安全",
  "无权或未启用时，搜索、候选列表、选择、创建、粘贴、删除、清空、重排、提交、快捷键和请求入口的 DOM、state、handler、request 和快捷键入口为 0",
  "orphaned invalid",
  "同一完整消息不能同时由字段、chip、Toast 和全局 live region 重复播报",
  "移动端不得删除已选摘要、搜索、候选列表、创建入口、粘贴解析、重复/无效项说明、删除 token、清空、应用/取消、字段错误、权限原因、重试、恢复和离开保护",
  "未验证"
].freeze

ROUTE_TERMS = [
  "多选 Select", "多选选择器", "多选下拉", "标签输入", "标签选择", "标签创建", "创建标签",
  "可创建选项", "自由文本标签", "Token 输入", "收件人输入", "邮箱标签", "手机号标签",
  "成员多选", "角色多选", "用户多选", "分类标签", "批量粘贴", "粘贴多个值",
  "已选标签", "删除标签", "清空标签", "拖拽排序标签", "chip", "chips", "tokenized input",
  "multi-select", "multiselect", "multiple select", "multi select dropdown", "tag input",
  "tags input", "tag selector", "create tag", "creatable option", "free text tag",
  "token input", "tokenized input", "chips input", "recipient input", "email chips",
  "phone chips", "member multi-select", "user multi-select", "role multi-select",
  "category tags", "paste tokens", "bulk paste", "selected chips", "remove chip",
  "clear tags", "reorder tags", "references/multi-select-tag-inputs.md"
].freeze

RELATIONSHIP_TERMS = [
  "references/multi-select-tag-inputs.md",
  "multi-select-tag-inputs.md"
].freeze

README_TERMS = [
  "多选、标签输入与 Tokenized Input 规范",
  "references/multi-select-tag-inputs.md"
].freeze

HANDOFF_TERMS = [
  "### 多选、标签输入与 Tokenized Input",
  "multiValueInputState",
  "创建标签不等于已提交字段",
  "服务端创建成功不等于表单保存、筛选应用或设置生效",
  "移动端不得删除已选摘要、搜索、候选列表、创建入口、粘贴解析、重复/无效项说明、删除 token、清空、应用/取消、字段错误、权限原因、重试、恢复和离开保护",
  "references/multi-select-tag-inputs.md"
].freeze

EVIDENCE_TERMS = STATE_FIELDS + [
  "query",
  "active option",
  "创建标签",
  "服务端创建成功",
  "Backspace",
  "批量粘贴",
  "稳定业务键",
  "迟到结果",
  "旧搜索结果",
  "orphaned invalid",
  "DOM、state、handler、request 和快捷键入口为 0",
  "primary owner",
  "移动端",
  "未验证"
]

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
    failures << "owner: multiValueInputState missing #{field}" unless owner.include?(field)
  end
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end

def integration_failures(selects:, selection:, filters:, members:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(require_terms(selects, RELATIONSHIP_TERMS, "selects relationship"))
  failures.concat(require_terms(selection, RELATIONSHIP_TERMS, "selection relationship"))
  failures.concat(require_terms(filters, RELATIONSHIP_TERMS, "filters relationship"))
  failures.concat(require_terms(members, RELATIONSHIP_TERMS, "members relationship"))
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

def audit(owner:, selects:, selection:, filters:, members:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(owner_failures(owner))
  failures.concat(integration_failures(selects: selects, selection: selection, filters: filters, members: members,
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
selects = read(SELECTS)
selection = read(SELECTION)
filters = read(FILTERS)
members = read(MEMBERS)
skill = read(SKILL)
readme = read(README)
handoff = read(HANDOFF)
green = read(GREEN)
red = read(RED)

failures = audit(owner: owner, selects: selects, selection: selection, filters: filters, members: members,
                 skill: skill, readme: readme, handoff: handoff, green: green, red: red)
unless failures.empty?
  warn failures.join("\n")
  exit 1
end

if ARGV.include?("--mutations")
  expect_failure("missing-owner-state") do
    audit(owner: owner.gsub("multiValueInputState", "multi-value-input-state"), selects: selects, selection: selection,
          filters: filters, members: members, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("query-as-committed-value") do
    audit(owner: owner.gsub("多值输入不能只维护一个数组", ""), selects: selects, selection: selection,
          filters: filters, members: members, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("enter-commits-arbitrary-query") do
    audit(owner: owner.gsub("不得因为按 Enter 就把任意 query 提交为业务值", ""), selects: selects,
          selection: selection, filters: filters, members: members, skill: skill, readme: readme,
          handoff: handoff, green: green, red: red)
  end

  expect_failure("create-tag-as-field-submit") do
    audit(owner: owner.gsub("创建标签不等于已提交字段", ""), selects: selects, selection: selection,
          filters: filters, members: members, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("server-create-as-save") do
    audit(owner: owner.gsub("服务端创建成功不等于表单保存、筛选应用或设置生效", ""), selects: selects,
          selection: selection, filters: filters, members: members, skill: skill, readme: readme,
          handoff: handoff, green: green, red: red)
  end

  expect_failure("backspace-deletes-token-immediately") do
    audit(owner: owner.gsub("第一次 Backspace 只能高亮最后一个可删除 token，第二次明确删除该 token", ""),
          selects: selects, selection: selection, filters: filters, members: members, skill: skill, readme: readme,
          handoff: handoff, green: green, red: red)
  end

  expect_failure("bulk-paste-direct-submit") do
    audit(owner: owner.gsub("批量粘贴不能直接提交", ""), selects: selects, selection: selection,
          filters: filters, members: members, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("duplicate-by-label-only") do
    audit(owner: owner.gsub("重复判断必须基于稳定业务键，而不是显示标签", ""), selects: selects,
          selection: selection, filters: filters, members: members, skill: skill, readme: readme,
          handoff: handoff, green: green, red: red)
  end

  expect_failure("late-result-writes-new-draft") do
    audit(owner: owner.gsub("迟到结果只能写回仍 live 且身份匹配的 `multiValueOwnerId` 和草稿代次", ""),
          selects: selects, selection: selection, filters: filters, members: members, skill: skill, readme: readme,
          handoff: handoff, green: green, red: red)
  end

  expect_failure("stale-async-state-survives") do
    audit(owner: owner.gsub("旧搜索结果、旧创建结果、旧校验错误、旧 active option、旧焦点目标和旧 ARIA 引用必须失效或重新证明安全", ""),
          selects: selects, selection: selection, filters: filters, members: members, skill: skill, readme: readme,
          handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-zero-entry-missing") do
    audit(owner: owner.gsub("DOM、state、handler、request 和快捷键入口为 0", ""), selects: selects,
          selection: selection, filters: filters, members: members, skill: skill, readme: readme,
          handoff: handoff, green: green, red: red)
  end

  expect_failure("orphaned-invalid-silently-cleared") do
    audit(owner: owner.gsub("orphaned invalid", ""), selects: selects, selection: selection, filters: filters,
          members: members, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("duplicate-announcement-owner") do
    audit(owner: owner.gsub("同一完整消息不能同时由字段、chip、Toast 和全局 live region 重复播报", ""),
          selects: selects, selection: selection, filters: filters, members: members, skill: skill, readme: readme,
          handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-core-multivalue-actions-removed") do
    audit(owner: owner.gsub("移动端不得删除已选摘要、搜索、候选列表、创建入口、粘贴解析、重复/无效项说明、删除 token、清空、应用/取消、字段错误、权限原因、重试、恢复和离开保护", ""),
          selects: selects, selection: selection, filters: filters, members: members, skill: skill, readme: readme,
          handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"), selects: selects, selection: selection, filters: filters,
          members: members, skill: skill, readme: readme, handoff: handoff.gsub("未验证", "已验证"),
          green: green.gsub("未验证", "已验证"), red: red.gsub("未验证", "已验证"))
  end

  expect_failure("missing-route") do
    audit(owner: owner, selects: selects, selection: selection, filters: filters, members: members,
          skill: skill.gsub("multi-select", ""), readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-adjacent-owner-link") do
    audit(owner: owner, selects: selects.gsub("multi-select-tag-inputs.md", ""),
          selection: selection.gsub("multi-select-tag-inputs.md", ""),
          filters: filters.gsub("multi-select-tag-inputs.md", ""),
          members: members.gsub("multi-select-tag-inputs.md", ""), skill: skill, readme: readme,
          handoff: handoff, green: green, red: red)
  end

  expect_failure("project-specific-leakage") do
    audit(owner: "#{owner}\nfex-admin", selects: selects, selection: selection, filters: filters, members: members,
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end
