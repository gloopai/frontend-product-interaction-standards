#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/saved-views-layout-presets.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/saved-views-layout-presets/green-summary.md")
RED = File.join(ROOT, "docs/testing/saved-views-layout-presets/red-summary.md")

STATE_FIELDS = %w[
  savedViewOwnerId viewIdentity viewScope appliedSnapshot layoutSnapshot
  draftBinding defaultPolicy sharePolicy applyIntent permissionBoundary
  resultReceipt auditBinding responsivePolicy
].freeze

OWNER_TERMS = [
  "savedViewState",
  "保存视图必须读取 `appliedSnapshot` 和明确允许持久化的 `layoutSnapshot`",
  "筛选草稿、Select query、active option、未提交日期范围、正在编辑的列拖拽、当前临时页码、展开行、hover、高亮、焦点、loading、错误状态和旧结果缓存不得进入正式保存视图",
  "保存视图前必须明确“保存已应用条件”或要求用户先应用/确认草稿",
  "应用视图必须创建 `applyIntent`",
  "Query Filters、Data Table、Toolbar、URL、结果摘要和焦点必须读取同一视图版本",
  "个人视图、团队共享视图、系统预设、个人默认、团队默认和角色默认必须分开表达",
  "共享视图不得泄露无权限字段、筛选值、对象名称、数量、列名、内部 ID、成员、客户、文件名、金额、发票、密钥、审计字段或旧缓存",
  "权限、租户/工作区、角色、字段可见性、功能开关或数据范围变化后，旧视图必须失效、过滤、降级或要求重新确认",
  "覆盖视图、删除视图、设为默认、共享给团队、取消共享、恢复默认和批量管理视图必须说明影响范围、视图版本、目标范围、权限版本、请求身份和未知结果",
  "确认前请求数为 0",
  "未知结果不能伪装成已保存、已覆盖、已删除、已共享、已设为默认或已恢复默认",
  "移动端不得删除视图切换、当前视图说明、保存视图、覆盖视图、恢复默认、权限原因、冲突恢复、错误回执和审计入口",
  "未验证"
].freeze

ROUTE_TERMS = [
  "保存视图", "视图预设", "我的视图", "个人视图", "共享视图", "团队视图",
  "默认视图", "系统视图", "保存筛选", "筛选预设", "列布局", "布局预设",
  "密度预设", "恢复默认视图", "设为默认视图", "视图切换器",
  "saved view", "view preset", "personal view", "shared view",
  "default view", "saved filter", "column layout", "layout preset",
  "density preset", "restore default view", "set default view",
  "references/saved-views-layout-presets.md"
].freeze

README_TERMS = [
  "保存视图、视图预设与个性化布局规范",
  "references/saved-views-layout-presets.md"
].freeze

HANDOFF_TERMS = [
  "### 保存视图、视图预设与个性化布局",
  "savedViewState",
  "保存视图必须读取 `appliedSnapshot`",
  "未知结果不能伪装成已保存",
  "references/saved-views-layout-presets.md"
].freeze

EVIDENCE_TERMS = [
  "savedViewState", "appliedSnapshot", "layoutSnapshot", "draftBinding",
  "defaultPolicy", "sharePolicy", "applyIntent", "permissionBoundary",
  "resultReceipt", "auditBinding", "筛选草稿", "Select query", "当前页码",
  "共享视图", "默认视图", "无权限字段", "旧视图", "未知结果",
  "恢复默认", "移动端", "未验证"
].freeze

PROJECT_BANNED_TERMS = [
  "fex-admin",
  "/Users/evanqi/code/",
  "src/pages",
  "Ant Design",
  "ant-design",
  "shadcn",
  "Next.js",
  "Vite"
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
  STATE_FIELDS.each { |field| failures << "owner: savedViewState missing #{field}" unless owner.include?(field) }
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end

def integration_failures(skill, readme, handoff, green, red)
  failures = []
  failures.concat(require_terms(skill, ROUTE_TERMS, "SKILL route"))
  failures.concat(require_terms(readme, README_TERMS, "README"))
  failures.concat(require_terms(handoff, HANDOFF_TERMS, "HANDOFF"))
  failures.concat(require_terms(green, EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(red, EVIDENCE_TERMS, "RED evidence"))
  failures
end

def project_leak_failures(owner)
  PROJECT_BANNED_TERMS.select { |term| owner.include?(term) }.map do |term|
    "owner: must stay project-agnostic, found #{term.inspect}"
  end
end

def audit(owner:, skill:, readme:, handoff:, green:, red:)
  owner_failures(owner) +
    integration_failures(skill, readme, handoff, green, red) +
    project_leak_failures(owner)
end

def expect_failure(name)
  failures = yield
  abort("mutation did not fail: #{name}") if failures.empty?

  puts "EXPECTED_FAIL: #{name}"
end

owner = read(OWNER)
skill = read(SKILL)
readme = read(README)
handoff = read(HANDOFF)
green = read(GREEN)
red = read(RED)

failures = audit(owner: owner, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
unless failures.empty?
  warn failures.join("\n")
  exit 1
end

if ARGV.include?("--mutations")
  expect_failure("missing-owner-state") do
    audit(owner: owner.gsub("savedViewState", "viewState"), skill: skill, readme: readme, handoff: handoff,
          green: green, red: red)
  end

  expect_failure("draft-saved-as-view") do
    audit(owner: owner.gsub("筛选草稿、Select query、active option、未提交日期范围、正在编辑的列拖拽、当前临时页码、展开行、hover、高亮、焦点、loading、错误状态和旧结果缓存不得进入正式保存视图", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("save-without-applied-snapshot-boundary") do
    audit(owner: owner.gsub("保存视图必须读取 `appliedSnapshot` 和明确允许持久化的 `layoutSnapshot`", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-apply-intent") do
    audit(owner: owner.gsub("应用视图必须创建 `applyIntent`", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("different-view-version-readers") do
    audit(owner: owner.gsub("Query Filters、Data Table、Toolbar、URL、结果摘要和焦点必须读取同一视图版本", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("shared-default-scope-merged") do
    audit(owner: owner.gsub("个人视图、团队共享视图、系统预设、个人默认、团队默认和角色默认必须分开表达", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("shared-view-permission-leak") do
    audit(owner: owner.gsub("共享视图不得泄露无权限字段、筛选值、对象名称、数量、列名、内部 ID、成员、客户、文件名、金额、发票、密钥、审计字段或旧缓存", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("stale-view-after-permission-change") do
    audit(owner: owner.gsub("权限、租户/工作区、角色、字段可见性、功能开关或数据范围变化后，旧视图必须失效、过滤、降级或要求重新确认", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("risk-actions-without-impact-scope") do
    audit(owner: owner.gsub("覆盖视图、删除视图、设为默认、共享给团队、取消共享、恢复默认和批量管理视图必须说明影响范围、视图版本、目标范围、权限版本、请求身份和未知结果", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("request-before-confirm") do
    audit(owner: owner.gsub("确认前请求数为 0", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("unknown-result-as-success") do
    audit(owner: owner.gsub("未知结果不能伪装成已保存、已覆盖、已删除、已共享、已设为默认或已恢复默认", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-view-capability-removed") do
    audit(owner: owner.gsub("移动端不得删除视图切换、当前视图说明、保存视图、覆盖视图、恢复默认、权限原因、冲突恢复、错误回执和审计入口", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"),
          skill: skill, readme: readme, handoff: handoff,
          green: green.gsub("未验证", "已验证"), red: red.gsub("未验证", "已验证"))
  end

  expect_failure("project-specific-leakage") do
    audit(owner: "#{owner}\nfex-admin\n", skill: skill, readme: readme, handoff: handoff,
          green: green, red: red)
  end
end

puts "PASS: 保存视图、视图预设与个性化布局 owner、路由、摘要和证据符合结构化审计契约。"
