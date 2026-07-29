#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/auth-session-reauth.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/auth-session-reauth/green-summary.md")
RED = File.join(ROOT, "docs/testing/auth-session-reauth/red-summary.md")

OWNER_TERMS = [
  "authSessionState",
  "`authOwnerId`",
  "`sessionIdentity`",
  "`authLevel`",
  "`sessionStatus`",
  "`reauthIntent`",
  "`reauthReason`",
  "`returnContext`",
  "`sensitiveActionBinding`",
  "`permissionBoundary`",
  "`callbackBinding`",
  "`recoveryPolicy`",
  "`resultReceipt`",
  "`authenticated`",
  "`expiring`",
  "`expired`",
  "`reauth-required`",
  "`reauth-in-progress`",
  "`switching-identity`",
  "`signed-out`",
  "`unknown`",
  "认证状态、权限状态、租户/工作区状态、对象状态、表单脏状态、请求状态和敏感动作意图必须分层表达",
  "不得直接清空页面并无条件跳到登录页",
  "先冻结或失效不安全请求",
  "清理敏感草稿、旧下载链接、旧任务入口、旧权限菜单和旧确认面板",
  "挑战完成前不得发送敏感请求",
  "不得自动执行旧点击事件",
  "当前用户、租户/工作区、权限版本、目标状态和幂等键",
  "`state`、`nonce`、`authOwnerId`、`returnContext`、租户/工作区和过期时间",
  "旧标签页 callback、重复 callback、过期 callback、错误租户 callback 和已退出后的 callback",
  "只能进入安全说明或重新开始",
  "旧会话绑定的 UI 状态必须原子失效或重算",
  "页面数据、导航菜单、按钮、表单字段、筛选项、下载链接、任务入口、搜索缓存、图表明细、弹层、Toast、Notification、焦点恢复和 ARIA 引用",
  "登录失败、会话过期、重新认证取消、重新认证失败、MFA 失败、SSO callback 失败、权限拒绝、租户不匹配、网络失败和未知结果不得合并",
  "Toast 不能作为唯一恢复路径",
  "移动端不得删除重新登录、重新认证、返回安全页、切换租户/工作区、放弃草稿、重试 callback 和查看原因",
  "未验证"
].freeze

SKILL_TERMS = [
  "涉及登录、登出、退出登录、会话、会话过期、登录过期、认证、认证失败、重新认证、二次认证、多因素认证、MFA、2FA、SSO、单点登录、账号切换、身份切换、授权回调、认证回调",
  "login、logout、sign in、sign out、session、session expired、token expired、authentication、auth failure、reauth、reauthentication、MFA、2FA、SSO、account switch、identity switch、auth callback、authorization callback",
  "必须完整读取 `references/auth-session-reauth.md`"
].freeze

SUMMARY_TERMS = [
  "会话、认证与重新认证",
  "登录过期",
  "重新认证",
  "SSO/MFA callback",
  "账号切换",
  "Toast-only",
  "移动端"
].freeze

EVIDENCE_TERMS = [
  "authSessionState",
  "returnContext",
  "sensitiveActionBinding",
  "callbackBinding",
  "state",
  "nonce",
  "旧标签页 callback",
  "旧下载链接",
  "旧任务入口",
  "旧权限菜单",
  "旧确认面板",
  "敏感请求发送数为 0",
  "Toast",
  "移动端",
  "未验证"
].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)

  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def audit(owner:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures.concat(require_terms(skill, SKILL_TERMS, "skill"))
  failures.concat(require_terms(readme, SUMMARY_TERMS, "README"))
  failures.concat(require_terms(handoff, SUMMARY_TERMS, "HANDOFF"))
  failures.concat(require_terms(green, EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(red, EVIDENCE_TERMS, "RED evidence"))
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
  expect_failure("missing-owner-state") do
    audit(owner: owner.gsub("authSessionState", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("session-status-merged") do
    audit(owner: owner.gsub("认证状态、权限状态、租户/工作区状态、对象状态、表单脏状态、请求状态和敏感动作意图必须分层表达", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("expired-login-clears-context") do
    audit(owner: owner.gsub("不得直接清空页面并无条件跳到登录页", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("unsafe-requests-not-frozen") do
    audit(owner: owner.gsub("先冻结或失效不安全请求", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("reauth-sends-request-before-challenge") do
    audit(owner: owner.gsub("挑战完成前不得发送敏感请求", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("reauth-auto-executes-old-click") do
    audit(owner: owner.gsub("不得自动执行旧点击事件", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("reauth-binding-missing") do
    audit(owner: owner.gsub("当前用户、租户/工作区、权限版本、目标状态和幂等键", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("callback-binding-missing") do
    audit(owner: owner.gsub("`state`、`nonce`、`authOwnerId`、`returnContext`、租户/工作区和过期时间", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("old-callback-restores-page") do
    audit(owner: owner.gsub("只能进入安全说明或重新开始", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("identity-switch-keeps-old-state") do
    audit(owner: owner.gsub("旧会话绑定的 UI 状态必须原子失效或重算", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("auth-errors-merged") do
    audit(owner: owner.gsub("登录失败、会话过期、重新认证取消、重新认证失败、MFA 失败、SSO callback 失败、权限拒绝、租户不匹配、网络失败和未知结果不得合并", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("toast-only-auth-failure") do
    audit(owner: owner.gsub("Toast 不能作为唯一恢复路径", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-recovery-removed") do
    audit(owner: owner.gsub("移动端不得删除重新登录、重新认证、返回安全页、切换租户/工作区、放弃草稿、重试 callback 和查看原因", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"), skill: skill, readme: readme, handoff: handoff,
          green: green.gsub("未验证", "已验证"), red: red.gsub("未验证", "已验证"))
  end

  expect_failure("missing-skill-route") do
    audit(owner: owner, skill: skill.gsub("必须完整读取 `references/auth-session-reauth.md`", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 会话、认证与重新认证 owner、路由、摘要和证据符合结构化审计契约。"
