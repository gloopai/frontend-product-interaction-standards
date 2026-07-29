#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/tree-hierarchy.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/tree-hierarchy/green-summary.md")
RED = File.join(ROOT, "docs/testing/tree-hierarchy/red-summary.md")

OWNER_TERMS = [
  "treeHierarchyState",
  "treeOwnerId", "nodeIdentity", "treeDataSnapshot", "expandedNodeIds", "activeNodeId",
  "selectedNodeIds", "checkedNodeState", "cascadePolicy", "filterState", "loadState",
  "permissionBoundary", "commitMode", "feedbackState", "a11yPolicy", "responsivePolicy",
  "展开、active、hover、filter match、visible descendants、indeterminate、partial loaded 和 optimistic preview 不得伪装成已提交选择",
  "节点必须有稳定业务 ID、节点类型、父子关系、路径版本和权限版本",
  "半选只表达派生状态，不是业务提交值",
  "`indeterminate` / half-checked / partial selected 不能提交给后端",
  "懒加载未完成、过滤后仅展示部分节点、权限未知或存在 disabled 后代时，不能把“全选当前可见”伪装成“全选全部后代”",
  "无权限节点不得泄露节点名称、数量、路径、父子关系、图标、类型、内部 ID、排序位置、子节点是否存在或旧缓存",
  "移动端不得删除搜索、展开、返回上级、路径摘要、已选摘要、清空、应用、错误说明、权限说明或恢复路径",
  "未验证"
].freeze

ROUTE_TERMS = [
  "Tree", "Tree View", "Tree Select", "Tree Grid", "Cascader", "树形结构", "树形选择",
  "级联选择", "层级选择", "组织树", "部门树", "权限树", "菜单树", "分类树", "资源目录树",
  "地区级联", "父子级联", "半选", "懒加载节点", "树节点搜索", "tree", "tree view",
  "tree select", "tree grid", "cascader", "hierarchy", "hierarchical select", "cascade select",
  "organization tree", "permission tree", "menu tree", "category tree", "lazy tree", "half checked",
  "references/tree-hierarchy.md"
].freeze

SUMMARY_TERMS = [
  "树形结构与级联",
  "Tree",
  "Tree Select",
  "Cascader",
  "组织树",
  "权限树",
  "菜单树",
  "分类树",
  "半选",
  "懒加载",
  "权限无泄露",
  "references/tree-hierarchy.md"
].freeze

EVIDENCE_TERMS = [
  "treeHierarchyState",
  "treeOwnerId",
  "nodeIdentity",
  "展开、active、hover、filter match、visible descendants、indeterminate、partial loaded 和 optimistic preview",
  "稳定业务 ID、节点类型、父子关系、路径版本和权限版本",
  "半选只表达派生状态，不是业务提交值",
  "`indeterminate` / half-checked / partial selected 不能提交给后端",
  "全选当前可见",
  "全选全部后代",
  "无权限节点",
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
  expect_failure("visual-state-not-committed") do
    audit(owner: owner.gsub("展开、active、hover、filter match、visible descendants、indeterminate、partial loaded 和 optimistic preview 不得伪装成已提交选择", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("stable-node-identity") do
    audit(owner: owner.gsub("节点必须有稳定业务 ID、节点类型、父子关系、路径版本和权限版本", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("half-check-not-business-value") do
    audit(owner: owner.gsub("半选只表达派生状态，不是业务提交值", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("indeterminate-not-submitted") do
    audit(owner: owner.gsub("`indeterminate` / half-checked / partial selected 不能提交给后端", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("visible-all-not-descendants") do
    audit(owner: owner.gsub("懒加载未完成、过滤后仅展示部分节点、权限未知或存在 disabled 后代时，不能把“全选当前可见”伪装成“全选全部后代”", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-no-leakage") do
    audit(owner: owner.gsub("无权限节点不得泄露节点名称、数量、路径、父子关系、图标、类型、内部 ID、排序位置、子节点是否存在或旧缓存", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-capability-preserved") do
    audit(owner: owner.gsub("移动端不得删除搜索、展开、返回上级、路径摘要、已选摘要、清空、应用、错误说明、权限说明或恢复路径", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"),
          skill: skill, readme: readme, handoff: handoff,
          green: green.gsub("未验证", "已验证"),
          red: red.gsub("未验证", "已验证"))
  end

  expect_failure("missing-route") do
    audit(owner: owner, skill: skill.gsub("references/tree-hierarchy.md", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("project-leak") do
    audit(owner: "#{owner}\nfex-admin", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 树形结构与级联 owner、路由、摘要和证据符合结构化审计契约。"
