#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/search-command-palette.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/search-command-palette/green-summary.md")
RED = File.join(ROOT, "docs/testing/search-command-palette/red-summary.md")

OWNER_TERMS = [
  "searchCommandState",
  "searchOwnerId", "surfaceKind", "queryDraft", "submittedQuery", "resultSnapshot",
  "resultGroups", "activeResult", "selectionState", "commandBinding", "permissionBoundary",
  "rankingPolicy", "historyPolicy", "shortcutPolicy", "feedbackState", "responsivePolicy", "a11yPolicy",
  "搜索草稿、active result、hover suggestion 和最近搜索高亮不得触发导航、命令执行或请求副作用",
  "只有明确提交搜索或激活结果后，才能改变导航、执行命令或写入已提交查询",
  "会修改数据、权限、导出、任务、密钥或外部系统的命令必须进入 `risk-actions.md`",
  "结果分组必须声明来源、对象类型、排序依据、权限边界和可执行动作",
  "无权限结果不得泄露对象名称、数量、字段、摘要片段、文件名、内部 ID 或旧缓存",
  "搜索结果必须区分 loading、empty、zero-results、partial、stale、error 和 permission-denied",
  "搜索历史、最近搜索和保存搜索必须声明存储范围、清除路径、权限复核和敏感查询策略",
  "移动端不得删除查询输入、提交、清空、结果分组、错误/权限说明、最近/保存搜索入口或恢复路径",
  "AI / 自然语言搜索不得把建议答案、候选结果、可执行命令和已执行结果混为一谈",
  "未验证"
].freeze

ROUTE_TERMS = [
  "全局搜索", "全站搜索", "站内搜索", "命令面板", "快速跳转", "搜索建议",
  "最近搜索", "保存搜索", "结果分组", "命令执行", "自然语言搜索", "AI 搜索",
  "global search", "command palette", "quick switcher", "action search", "AI search",
  "references/search-command-palette.md"
].freeze

SUMMARY_TERMS = [
  "搜索与命令面板",
  "全局搜索",
  "命令面板",
  "快速跳转",
  "结果分组",
  "权限无泄露",
  "最近/保存搜索",
  "AI 搜索边界",
  "references/search-command-palette.md"
].freeze

EVIDENCE_TERMS = [
  "searchCommandState",
  "搜索草稿",
  "active result",
  "hover suggestion",
  "最近搜索高亮",
  "请求副作用",
  "明确提交搜索",
  "结果分组",
  "risk-actions.md",
  "无权限结果",
  "loading、empty、zero-results、partial、stale、error 和 permission-denied",
  "搜索历史、最近搜索和保存搜索",
  "移动端不得删除查询输入",
  "AI search",
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
  expect_failure("draft-active-no-side-effect") do
    audit(owner: owner.gsub("搜索草稿、active result、hover suggestion 和最近搜索高亮不得触发导航、命令执行或请求副作用", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("submit-before-navigation-command") do
    audit(owner: owner.gsub("只有明确提交搜索或激活结果后，才能改变导航、执行命令或写入已提交查询", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("risk-command-owner") do
    audit(owner: owner.gsub("会修改数据、权限、导出、任务、密钥或外部系统的命令必须进入 `risk-actions.md`", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-no-leakage") do
    audit(owner: owner.gsub("无权限结果不得泄露对象名称、数量、字段、摘要片段、文件名、内部 ID 或旧缓存", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("result-states-distinct") do
    audit(owner: owner.gsub("搜索结果必须区分 loading、empty、zero-results、partial、stale、error 和 permission-denied", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("history-sensitive-policy") do
    audit(owner: owner.gsub("搜索历史、最近搜索和保存搜索必须声明存储范围、清除路径、权限复核和敏感查询策略", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-capability-preserved") do
    audit(owner: owner.gsub("移动端不得删除查询输入、提交、清空、结果分组、错误/权限说明、最近/保存搜索入口或恢复路径", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("ai-boundary") do
    audit(owner: owner.gsub("AI / 自然语言搜索不得把建议答案、候选结果、可执行命令和已执行结果混为一谈", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"),
          skill: skill, readme: readme, handoff: handoff,
          green: green.gsub("未验证", "已验证"),
          red: red.gsub("未验证", "已验证"))
  end

  expect_failure("missing-route") do
    audit(owner: owner, skill: skill.gsub("references/search-command-palette.md", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("project-leak") do
    audit(owner: "#{owner}\nfex-admin", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 搜索与命令面板 owner、路由、摘要和证据符合结构化审计契约。"
