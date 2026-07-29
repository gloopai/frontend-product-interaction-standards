#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/ordering-reordering.md")
RECORD_EDITING = File.join(ROOT, "references/record-editing-surfaces.md")
DATA_TABLES = File.join(ROOT, "references/data-tables.md")
CARD_LIST = File.join(ROOT, "references/card-list-results.md")
TOOLBARS = File.join(ROOT, "references/page-toolbars-actions.md")
BUTTONS = File.join(ROOT, "references/buttons.md")
RISK = File.join(ROOT, "references/risk-actions.md")
RESPONSIVE = File.join(ROOT, "references/responsive-adaptive.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/ordering-reordering/green-summary.md")
RED = File.join(ROOT, "docs/testing/ordering-reordering/red-summary.md")

STATE_FIELDS = %w[
  orderingOwnerId orderingSurface scopeBinding sourceSnapshot itemIdentityMap
  draftOrder committedOrderSnapshot movementPolicy inputAlternativePolicy
  submitPolicy conflictPolicy permissionBoundary feedbackBinding responsivePolicy
  focusAnnouncementPolicy lifecycleDisposal runtimeVerification
].freeze

OWNER_TERMS = [
  "orderingReorderingState",
  "排序与重排不是列表内编辑，也不是查询排序",
  "列表、表格或卡片中不得常驻排序输入、每行保存按钮或 spreadsheet-like 排序矩阵",
  "拖拽不能是唯一排序方式",
  "当前页局部重排不得伪装成全部结果、全部分组或全局顺序已更新",
  "保存前必须证明 `draftOrder` 覆盖提交范围内全部必需对象，没有重复、缺失、外部 ID 或无权限对象",
  "筛选、搜索、分页、分组、权限、租户/工作区、数据版本或对象集合变化后，旧排序草稿必须失效、刷新或要求重新确认",
  "无权限或权限降级不得泄露旧顺序、旧对象名称、旧分组、旧数量、旧拖拽 handle、旧禁用原因、旧保存按钮或旧 ARIA label",
  "未验证"
].freeze

ROUTE_TERMS = [
  "排序", "手动排序", "人工排序", "调整排序", "展示顺序", "显示顺序",
  "拖拽排序", "拖动排序", "重排", "重新排序", "上移", "下移",
  "置顶", "置底", "移到顶部", "移到底部", "排序模式", "保存顺序",
  "顺序冲突", "order", "ordering", "reorder", "reordering", "manual order",
  "custom order", "display order", "sort order", "drag reorder",
  "drag and drop reorder", "move up", "move down", "pin to top",
  "send to bottom", "save order", "references/ordering-reordering.md"
].freeze

ADJACENT_TERMS = ["references/ordering-reordering.md", "ordering-reordering.md"].freeze
README_TERMS = ["排序与重排规范", "references/ordering-reordering.md"].freeze
HANDOFF_TERMS = [
  "### 排序与重排",
  "orderingReorderingState",
  "排序与重排不是列表内编辑，也不是查询排序",
  "拖拽不能是唯一排序方式",
  "references/ordering-reordering.md"
].freeze
EVIDENCE_TERMS = STATE_FIELDS + ["orderingReorderingState", "draftOrder", "committedOrderSnapshot", "conflictPolicy", "未验证"]
PROJECT_BANNED_TERMS = ["fex-admin", "/Users/evanqi/code/", "src/pages", "Ant Design", "ant-design", "shadcn", "Next.js", "Vite", "React", "Vue"].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)
  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def owner_failures(owner)
  STATE_FIELDS.reject { |field| owner.include?(field) }.map { |field| "owner: orderingReorderingState missing #{field}" } +
    require_terms(owner, OWNER_TERMS, "owner")
end

def integration_failures(texts)
  failures = []
  %w[record_editing data_tables card_list toolbars buttons risk responsive].each do |key|
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
  "record_editing" => read(RECORD_EDITING),
  "data_tables" => read(DATA_TABLES),
  "card_list" => read(CARD_LIST),
  "toolbars" => read(TOOLBARS),
  "buttons" => read(BUTTONS),
  "risk" => read(RISK),
  "responsive" => read(RESPONSIVE),
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
    "missing-owner-state" => texts.fetch("owner").gsub("orderingReorderingState", "ordering-state"),
    "boundary-removed" => texts.fetch("owner").gsub("排序与重排不是列表内编辑，也不是查询排序", ""),
    "inline-input-ban-removed" => texts.fetch("owner").gsub("列表、表格或卡片中不得常驻排序输入、每行保存按钮或 spreadsheet-like 排序矩阵", ""),
    "drag-only-ban-removed" => texts.fetch("owner").gsub("拖拽不能是唯一排序方式", ""),
    "current-page-scope-removed" => texts.fetch("owner").gsub("当前页局部重排不得伪装成全部结果、全部分组或全局顺序已更新", ""),
    "submit-proof-removed" => texts.fetch("owner").gsub("保存前必须证明 `draftOrder` 覆盖提交范围内全部必需对象，没有重复、缺失、外部 ID 或无权限对象", ""),
    "conflict-policy-removed" => texts.fetch("owner").gsub("筛选、搜索、分页、分组、权限、租户/工作区、数据版本或对象集合变化后，旧排序草稿必须失效、刷新或要求重新确认", ""),
    "permission-leak-removed" => texts.fetch("owner").gsub("无权限或权限降级不得泄露旧顺序、旧对象名称、旧分组、旧数量、旧拖拽 handle、旧禁用原因、旧保存按钮或旧 ARIA label", ""),
    "runtime-boundary-marked-verified" => texts.fetch("owner").gsub("未验证", "已验证")
  }.each do |name, mutated_owner|
    expect_failure(name) { audit(texts.merge("owner" => mutated_owner)) }
  end

  expect_failure("missing-skill-route") do
    audit(texts.merge("skill" => texts.fetch("skill").gsub("references/ordering-reordering.md", "references/missing.md")))
  end

  expect_failure("missing-readme-link") do
    audit(texts.merge("readme" => texts.fetch("readme").gsub("references/ordering-reordering.md", "references/missing.md")))
  end

  expect_failure("missing-handoff-section") do
    audit(texts.merge("handoff" => texts.fetch("handoff").gsub("### 排序与重排", "### 排序规范")))
  end

  expect_failure("project-leak") do
    audit(texts.merge("owner" => "#{texts.fetch("owner")}\nfex-admin\n"))
  end
end

puts "PASS: 排序与重排 owner、路由和证据符合结构化审计契约。"
