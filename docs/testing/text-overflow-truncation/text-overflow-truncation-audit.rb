#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/text-overflow-truncation.md")
INFO = File.join(ROOT, "references/information-display.md")
FIELD = File.join(ROOT, "references/field-guidance-help-text.md")
RESPONSIVE = File.join(ROOT, "references/responsive-adaptive.md")
OVERLAYS = File.join(ROOT, "references/overlays-menus-tooltips.md")
DATA_TABLES = File.join(ROOT, "references/data-tables.md")
CARD_LIST = File.join(ROOT, "references/card-list-results.md")
BUTTONS = File.join(ROOT, "references/buttons.md")
FEEDBACK = File.join(ROOT, "references/feedback-states.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/text-overflow-truncation/green-summary.md")
RED = File.join(ROOT, "docs/testing/text-overflow-truncation/red-summary.md")

STATE_FIELDS = %w[
  textOwnerId textSurface sourceBinding contentIdentity displayPolicy
  truncationPolicy fullTextAccessPolicy copyPolicy tooltipPopoverBoundary
  lineWrapPolicy measurementPolicy permissionBoundary responsivePolicy
  focusAnnouncementPolicy lifecycleDisposal runtimeVerification
].freeze

OWNER_TERMS = [
  "textOverflowState",
  "文本截断不是内容删除，也不是 hover tooltip 的同义词",
  "省略号、line clamp、max-width、title 属性或 Tooltip 不得作为查看完整内容的唯一方式",
  "被截断内容必须声明 `fullTextAccessPolicy`；重要身份、状态、错误、金额、权限原因、主操作文案和恢复路径不得只显示省略号",
  "只有装饰性或已由同屏等价文本完整表达的内容可以无恢复路径截断",
  "长 ID、代码、JSON、URL、邮箱、文件名、路径、错误详情和审计字段必须提供换行、展开、复制或专用查看方式",
  "移动端不得依赖 hover、title 属性或精确指针查看全文",
  "权限降级、语言切换、数据刷新、断点转换、字体放大或 owner 卸载后，旧全文、旧 title、旧 tooltip、旧复制值、旧 aria-label、旧测量结果和旧展开状态必须失效或重算",
  "未验证"
].freeze

ROUTE_TERMS = [
  "文本溢出", "文本截断", "省略号", "截断", "折行", "换行", "自动换行",
  "多行截断", "单行截断", "查看全文", "展开全文", "收起全文", "复制全文",
  "长文本", "长标题", "长字段", "长状态", "长错误", "长按钮文案",
  "代码换行", "JSON 展示", "URL 换行", "文件名截断", "路径截断",
  "text overflow", "text truncation", "ellipsis", "truncate", "line clamp",
  "line-clamp", "wrap text", "word break", "show more", "read more",
  "full text", "long text", "long title", "long label", "long error",
  "copy full text", "references/text-overflow-truncation.md"
].freeze

ADJACENT_TERMS = ["references/text-overflow-truncation.md", "text-overflow-truncation.md"].freeze
README_TERMS = ["文本溢出与截断规范", "references/text-overflow-truncation.md"].freeze
HANDOFF_TERMS = [
  "### 文本溢出与截断",
  "textOverflowState",
  "文本截断不是内容删除，也不是 hover tooltip 的同义词",
  "fullTextAccessPolicy",
  "references/text-overflow-truncation.md"
].freeze
EVIDENCE_TERMS = STATE_FIELDS + [
  "textOverflowState", "truncationPolicy", "fullTextAccessPolicy",
  "tooltipPopoverBoundary", "未验证"
]
PROJECT_BANNED_TERMS = [
  "fex-admin", "/Users/evanqi/code/", "src/pages", "Ant Design",
  "ant-design", "shadcn", "Next.js", "Vite", "React", "Vue"
].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)
  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def owner_failures(owner)
  STATE_FIELDS.reject { |field| owner.include?(field) }.map { |field| "owner: textOverflowState missing #{field}" } +
    require_terms(owner, OWNER_TERMS, "owner")
end

def integration_failures(texts)
  failures = []
  %w[info field responsive overlays data_tables card_list buttons feedback].each do |key|
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
  "info" => read(INFO),
  "field" => read(FIELD),
  "responsive" => read(RESPONSIVE),
  "overlays" => read(OVERLAYS),
  "data_tables" => read(DATA_TABLES),
  "card_list" => read(CARD_LIST),
  "buttons" => read(BUTTONS),
  "feedback" => read(FEEDBACK),
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
    "missing-owner-state" => texts.fetch("owner").gsub("textOverflowState", "text-overflow-state"),
    "boundary-removed" => texts.fetch("owner").gsub("文本截断不是内容删除，也不是 hover tooltip 的同义词", ""),
    "tooltip-only-removed" => texts.fetch("owner").gsub("省略号、line clamp、max-width、title 属性或 Tooltip 不得作为查看完整内容的唯一方式", ""),
    "full-text-policy-removed" => texts.fetch("owner").gsub("被截断内容必须声明 `fullTextAccessPolicy`；重要身份、状态、错误、金额、权限原因、主操作文案和恢复路径不得只显示省略号", ""),
    "decorative-exception-removed" => texts.fetch("owner").gsub("只有装饰性或已由同屏等价文本完整表达的内容可以无恢复路径截断", ""),
    "structured-long-content-removed" => texts.fetch("owner").gsub("长 ID、代码、JSON、URL、邮箱、文件名、路径、错误详情和审计字段必须提供换行、展开、复制或专用查看方式", ""),
    "mobile-hover-removed" => texts.fetch("owner").gsub("移动端不得依赖 hover、title 属性或精确指针查看全文", ""),
    "disposal-removed" => texts.fetch("owner").gsub("权限降级、语言切换、数据刷新、断点转换、字体放大或 owner 卸载后，旧全文、旧 title、旧 tooltip、旧复制值、旧 aria-label、旧测量结果和旧展开状态必须失效或重算", ""),
    "runtime-boundary-marked-verified" => texts.fetch("owner").gsub("未验证", "已验证")
  }.each do |name, mutated_owner|
    expect_failure(name) { audit(texts.merge("owner" => mutated_owner)) }
  end

  expect_failure("missing-skill-route") do
    audit(texts.merge("skill" => texts.fetch("skill").gsub("references/text-overflow-truncation.md", "references/missing.md")))
  end

  expect_failure("missing-readme-link") do
    audit(texts.merge("readme" => texts.fetch("readme").gsub("references/text-overflow-truncation.md", "references/missing.md")))
  end

  expect_failure("missing-handoff-section") do
    audit(texts.merge("handoff" => texts.fetch("handoff").gsub("### 文本溢出与截断", "### 文本截断")))
  end

  expect_failure("project-leak") do
    audit(texts.merge("owner" => "#{texts.fetch("owner")}\nfex-admin\n"))
  end
end

puts "PASS: 文本溢出与截断 owner、路由和证据符合结构化审计契约。"
