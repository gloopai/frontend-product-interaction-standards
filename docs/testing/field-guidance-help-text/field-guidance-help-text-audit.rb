#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/field-guidance-help-text.md")
FORMS = File.join(ROOT, "references/forms.md")
INFO = File.join(ROOT, "references/information-display.md")
OVERLAYS = File.join(ROOT, "references/overlays-menus-tooltips.md")
RESPONSIVE = File.join(ROOT, "references/responsive-adaptive.md")
PERMISSIONS = File.join(ROOT, "references/permissions-tenancy-visibility.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/field-guidance-help-text/green-summary.md")
RED = File.join(ROOT, "docs/testing/field-guidance-help-text/red-summary.md")

STATE_FIELDS = %w[
  guidanceOwnerId guidanceSurface fieldIdentity labelPolicy requirementPolicy
  descriptionPolicy placeholderPolicy helpDisclosurePolicy unitAndFormatPolicy
  emptyValuePolicy permissionReasonPolicy errorRelationship responsivePolicy
  lifecycleDisposal runtimeVerification
].freeze

OWNER_TERMS = [
  "fieldGuidanceState",
  "字段说明不是 Tooltip，也不是 placeholder",
  "placeholder 不能替代 label、默认值、帮助说明、错误说明或空值状态",
  "必填、选填、条件必填、系统自动生成、继承默认和不可编辑必须可区分",
  "帮助说明、单位、格式、示例、来源说明、权限原因和空值原因必须有稳定 owner",
  "Hover-only 帮助在移动端、触摸、键盘和读屏下必须有等价路径",
  "错误文本不得覆盖帮助文本的唯一含义",
  "权限降级、字段隐藏、字段重排、断点转换、语言切换、校验变化或 owner 卸载后，旧 label、旧 help、旧 placeholder、旧 aria-describedby 和旧 tooltip 引用必须失效或重算",
  "未验证"
].freeze

ROUTE_TERMS = [
  "字段说明", "帮助文本", "辅助说明", "占位提示", "placeholder", "字段 label",
  "字段标题", "必填", "选填", "条件必填", "单位", "格式示例", "来源说明",
  "空值说明", "权限原因", "只读原因", "禁用原因", "Tooltip 帮助",
  "Popover 帮助", "field label", "field help", "help text", "field description",
  "hint text", "placeholder text", "required indicator", "optional indicator",
  "field unit", "format hint", "empty value reason", "disabled reason",
  "references/field-guidance-help-text.md"
].freeze

ADJACENT_TERMS = ["references/field-guidance-help-text.md", "field-guidance-help-text.md"].freeze
README_TERMS = ["字段说明、帮助文本与占位提示规范", "references/field-guidance-help-text.md"].freeze
HANDOFF_TERMS = [
  "### 字段说明、帮助文本与占位提示",
  "fieldGuidanceState",
  "字段说明不是 Tooltip，也不是 placeholder",
  "placeholder 不能替代 label、默认值、帮助说明、错误说明或空值状态",
  "references/field-guidance-help-text.md"
].freeze
EVIDENCE_TERMS = STATE_FIELDS + ["fieldGuidanceState", "placeholderPolicy", "helpDisclosurePolicy", "errorRelationship", "未验证"]
PROJECT_BANNED_TERMS = ["fex-admin", "/Users/evanqi/code/", "src/pages", "Ant Design", "ant-design", "shadcn", "Next.js", "Vite", "React", "Vue"].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)
  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def owner_failures(owner)
  STATE_FIELDS.reject { |field| owner.include?(field) }.map { |field| "owner: fieldGuidanceState missing #{field}" } +
    require_terms(owner, OWNER_TERMS, "owner")
end

def integration_failures(texts)
  failures = []
  %w[forms info overlays responsive permissions].each do |key|
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
  "forms" => read(FORMS),
  "info" => read(INFO),
  "overlays" => read(OVERLAYS),
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
    "missing-owner-state" => texts.fetch("owner").gsub("fieldGuidanceState", "field-guidance-state"),
    "tooltip-as-guidance" => texts.fetch("owner").gsub("字段说明不是 Tooltip，也不是 placeholder", ""),
    "placeholder-as-label" => texts.fetch("owner").gsub("placeholder 不能替代 label、默认值、帮助说明、错误说明或空值状态", ""),
    "requirement-policy-removed" => texts.fetch("owner").gsub("必填、选填、条件必填、系统自动生成、继承默认和不可编辑必须可区分", ""),
    "help-owner-removed" => texts.fetch("owner").gsub("帮助说明、单位、格式、示例、来源说明、权限原因和空值原因必须有稳定 owner", ""),
    "mobile-equivalent-removed" => texts.fetch("owner").gsub("Hover-only 帮助在移动端、触摸、键盘和读屏下必须有等价路径", ""),
    "error-relationship-removed" => texts.fetch("owner").gsub("错误文本不得覆盖帮助文本的唯一含义", ""),
    "disposal-removed" => texts.fetch("owner").gsub("权限降级、字段隐藏、字段重排、断点转换、语言切换、校验变化或 owner 卸载后，旧 label、旧 help、旧 placeholder、旧 aria-describedby 和旧 tooltip 引用必须失效或重算", ""),
    "runtime-boundary-marked-verified" => texts.fetch("owner").gsub("未验证", "已验证")
  }.each do |name, mutated_owner|
    expect_failure(name) { audit(texts.merge("owner" => mutated_owner)) }
  end

  expect_failure("missing-route") { audit(texts.merge("skill" => texts.fetch("skill").gsub("references/field-guidance-help-text.md", ""))) }
  expect_failure("missing-adjacent-link") { audit(texts.merge("forms" => texts.fetch("forms").gsub("references/field-guidance-help-text.md", ""))) }
  expect_failure("project-specific-leakage") { audit(texts.merge("owner" => "#{texts.fetch("owner")}\nfex-admin")) }
end

puts "PASS: 字段说明、帮助文本与占位提示 owner、路由和证据符合结构化审计契约。"
