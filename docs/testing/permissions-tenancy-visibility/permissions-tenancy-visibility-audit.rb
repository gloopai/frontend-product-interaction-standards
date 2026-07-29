#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/permissions-tenancy-visibility.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/permissions-tenancy-visibility/green-summary.md")
RED = File.join(ROOT, "docs/testing/permissions-tenancy-visibility/red-summary.md")

OWNER_TERMS = [
  "permissionVisibilityState",
  "permissionOwnerId", "principalSnapshot", "resourceSnapshot", "capabilityMatrix", "visibilityState",
  "reasonState", "dataBoundary", "actionBoundary", "cacheBoundary", "focusBoundary", "a11yBoundary", "responsivePolicy",
  "隐藏、禁用、只读、未启用和无权限不是同一件事",
  "未启用表示产品或配置没有启用该能力，DOM、state、handler 和 request 入口均为 0",
  "权限、租户/工作区、角色、认证状态、对象状态、权限版本或资源版本变化后，必须原子重算",
  "旧可见数据、旧菜单、旧按钮、旧确认、旧下载链接、旧任务入口、旧错误明细、旧搜索结果、旧表单草稿、旧图表明细和旧 ARIA label 不得继续暴露",
  "无权限状态不得泄露对象名称、数量、字段、文件名、路径、父子关系、导出范围、错误明细、任务结果、搜索摘要、内部 ID、图标、排序位置、旧缓存或旧可访问名称",
  "移动端不得删除权限说明、只读原因、禁用原因、申请权限、切换租户/工作区、安全占位、重新认证或恢复路径",
  "未验证"
].freeze

ROUTE_TERMS = [
  "permission", "permissions", "role", "RBAC", "ABAC", "tenant", "workspace",
  "权限", "角色", "权限矩阵", "能力开关", "租户", "工作区", "权限降级", "权限升级",
  "权限版本", "无权限", "只读", "隐藏入口", "禁用原因", "申请权限", "可见性",
  "权限泄露", "旧缓存", "旧菜单", "旧下载链接", "permission denied", "read only",
  "read-only", "hidden by permission", "disabled by permission", "permission version",
  "capability matrix", "feature flag", "visibility", "access control", "stale permission",
  "permission leakage", "references/permissions-tenancy-visibility.md"
].freeze

SUMMARY_TERMS = [
  "权限、租户与可见性",
  "RBAC",
  "ABAC",
  "角色",
  "能力开关",
  "租户/工作区切换",
  "权限降级",
  "隐藏/禁用/只读/未启用语义",
  "原子收敛",
  "无泄露",
  "请求绑定",
  "移动端权限恢复",
  "references/permissions-tenancy-visibility.md"
].freeze

EVIDENCE_TERMS = [
  "permissionVisibilityState",
  "permissionOwnerId",
  "principalSnapshot",
  "resourceSnapshot",
  "capabilityMatrix",
  "隐藏、禁用、只读、未启用和无权限不是同一件事",
  "DOM、state、handler 和 request 入口均为 0",
  "必须原子重算",
  "旧可见数据、旧菜单、旧按钮、旧确认、旧下载链接",
  "旧 ARIA label",
  "无权限状态不得泄露对象名称",
  "旧缓存",
  "移动端",
  "未验证"
].freeze

PROJECT_LEAK_TERMS = [
  "fex-admin",
  "/Users/evanqi/code/fex-admin",
  "gloopai/story",
  "/Users/evanqi/code/gloopai/story"
].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)

  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def forbid_terms(text, terms, label)
  terms.select { |term| text.include?(term) }.map { |term| "#{label}: forbidden project-specific term #{term}" }
end

def audit(owner:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures.concat(require_terms(skill, ROUTE_TERMS, "skill route"))
  failures.concat(require_terms(readme, SUMMARY_TERMS, "README"))
  failures.concat(require_terms(handoff, SUMMARY_TERMS, "HANDOFF"))
  failures.concat(require_terms(green, EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(red, EVIDENCE_TERMS, "RED evidence"))
  failures.concat(forbid_terms(owner, PROJECT_LEAK_TERMS, "owner"))
  failures.concat(forbid_terms(green, PROJECT_LEAK_TERMS, "GREEN evidence"))
  failures.concat(forbid_terms(red, PROJECT_LEAK_TERMS, "RED evidence"))
  failures
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
  expect_failure("semantic-distinction") do
    audit(owner: owner.gsub("隐藏、禁用、只读、未启用和无权限不是同一件事", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("not-enabled-zero-evidence") do
    audit(owner: owner.gsub("未启用表示产品或配置没有启用该能力，DOM、state、handler 和 request 入口均为 0", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("atomic-recomputation") do
    audit(owner: owner.gsub("权限、租户/工作区、角色、认证状态、对象状态、权限版本或资源版本变化后，必须原子重算", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("stale-exposure-cleanup") do
    audit(owner: owner.gsub("旧可见数据、旧菜单、旧按钮、旧确认、旧下载链接、旧任务入口、旧错误明细、旧搜索结果、旧表单草稿、旧图表明细和旧 ARIA label 不得继续暴露", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-no-leakage") do
    audit(owner: owner.gsub("无权限状态不得泄露对象名称、数量、字段、文件名、路径、父子关系、导出范围、错误明细、任务结果、搜索摘要、内部 ID、图标、排序位置、旧缓存或旧可访问名称", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-capability-preserved") do
    audit(owner: owner.gsub("移动端不得删除权限说明、只读原因、禁用原因、申请权限、切换租户/工作区、安全占位、重新认证或恢复路径", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"),
          skill: skill, readme: readme, handoff: handoff,
          green: green.gsub("未验证", "已验证"),
          red: red.gsub("未验证", "已验证"))
  end

  expect_failure("missing-route") do
    audit(owner: owner, skill: skill.gsub("references/permissions-tenancy-visibility.md", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("project-leak") do
    audit(owner: "#{owner}\nfex-admin", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 权限、租户与可见性 owner、路由、摘要和证据符合结构化审计契约。"
