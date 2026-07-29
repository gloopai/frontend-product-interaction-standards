#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/members-invitations-access.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/members-invitations-access/green-summary.md")
RED = File.join(ROOT, "docs/testing/members-invitations-access/red-summary.md")

OWNER_TERMS = [
  "membershipAccessState",
  "`membershipOwnerId`",
  "`principalSnapshot`",
  "`memberIdentity`",
  "`membershipStatus`",
  "`invitationState`",
  "`roleAssignmentState`",
  "`accessChangeIntent`",
  "`permissionBoundary`",
  "`authBinding`",
  "`riskBinding`",
  "`auditBinding`",
  "`resultReceipt`",
  "`active`",
  "`invited`",
  "`invite-expired`",
  "`invite-revoked`",
  "`disabled`",
  "`removed`",
  "`owner-transfer-required`",
  "`external`",
  "`unknown`",
  "成员、邀请和角色不能只按普通用户行展示",
  "成员状态、邀请状态、角色状态、权限状态和认证状态必须分开表达",
  "邀请成员必须绑定 `invitationState`、目标邮箱/账号、租户/工作区、角色、邀请人、有效期、权限版本和审计身份",
  "旧邀请链接、旧邮件入口、旧复制链接、旧 Toast、旧任务入口和浏览器历史",
  "必须在撤销、过期、角色变更、租户/工作区切换、权限变化、会话过期或重复邀请后失效或重新证明安全",
  "重新发送邀请不得创建重复成员或绕过权限复核",
  "无权限用户不得通过邀请错误、搜索结果、邮箱补全、列表数量或审计摘要推断成员是否存在",
  "角色 Select 只能编辑 `roleAssignmentState` 草稿",
  "确认前不得改变已生效角色，不得发起真实请求",
  "保存角色变更必须读取当前成员版本、角色版本、权限版本、租户/工作区、操作者身份和目标角色快照",
  "提升为管理员、降低管理员、修改外部成员权限、跨租户/工作区授权、批量角色变更、影响自身权限或影响最后 owner 的操作必须进入 `risk-actions.md`",
  "移除成员、禁用成员、启用成员、恢复成员、转移 owner、移除最后管理员、移除自己、禁用自己、批量移除或批量禁用都必须进入 `risk-actions.md`",
  "不能用 Switch/Toggle 直接启停成员",
  "确认前请求数为 0",
  "旧成员列表、旧角色 Select、旧邀请链接、旧菜单、旧按钮、旧确认面板、旧 Toast/Notification、旧审计跳转、旧焦点目标和旧 ARIA 引用必须失效或重算",
  "迟到请求、缓存回放、浏览器 Back、任务中心回调、邮件链接 callback 和审计跳转只有在 `membershipOwnerId`、租户/工作区、成员版本、权限版本和请求身份仍匹配时才能写回",
  "未知结果不能伪装成角色变更成功、邀请成功、撤销成功、移除成功或禁用成功",
  "Toast、Notification、Banner 只能辅助提示",
  "不能作为唯一结果回执、唯一邀请恢复入口、唯一审计入口、唯一错误说明或唯一权限原因",
  "移动端不得删除邀请成员、成员状态、角色说明、角色变更确认、撤销邀请、重新发送邀请、禁用原因、移除/恢复路径、转移 owner、审计入口、权限说明和错误恢复",
  "未验证"
].freeze

SKILL_TERMS = [
  "涉及成员、团队成员、工作区成员、组织成员、用户管理、账号管理、邀请成员、邀请链接、重新发送邀请、撤销邀请、接受邀请、拒绝邀请、邀请过期、角色、角色变更、权限角色、成员角色、Owner、转移 Owner、管理员、外部成员、访客、移除成员、禁用成员、启用成员、恢复成员、成员状态、成员审计",
  "member、members、team member、workspace member、organization member、user management、account management、invite member、invitation、invite link、resend invite、revoke invite、accept invite、decline invite、expired invite、role、role change、member role、owner、transfer owner、admin、external member、guest、remove member、disable member、enable member、restore member、member status、membership audit",
  "必须完整读取 `references/members-invitations-access.md`"
].freeze

SUMMARY_TERMS = [
  "成员、邀请与团队访问管理",
  "邀请成员",
  "邀请链接",
  "角色变更",
  "转移 Owner",
  "Toast",
  "移动端"
].freeze

EVIDENCE_TERMS = [
  "membershipAccessState",
  "membershipOwnerId",
  "invitationState",
  "roleAssignmentState",
  "risk-actions.md",
  "auth-session-reauth.md",
  "确认前请求数为 0",
  "旧邀请链接",
  "Switch",
  "成员姓名",
  "邮箱",
  "未知结果",
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
    audit(owner: owner.gsub("membershipAccessState", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("ordinary-user-row") do
    audit(owner: owner.gsub("成员、邀请和角色不能只按普通用户行展示", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("status-merged") do
    audit(owner: owner.gsub("成员状态、邀请状态、角色状态、权限状态和认证状态必须分开表达", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("invitation-binding-missing") do
    audit(owner: owner.gsub("邀请成员必须绑定 `invitationState`、目标邮箱/账号、租户/工作区、角色、邀请人、有效期、权限版本和审计身份", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("old-invite-link-survives") do
    audit(owner: owner.gsub("必须在撤销、过期、角色变更、租户/工作区切换、权限变化、会话过期或重复邀请后失效或重新证明安全", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("resend-duplicates-member") do
    audit(owner: owner.gsub("重新发送邀请不得创建重复成员或绕过权限复核", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-leaks-member") do
    audit(owner: owner.gsub("无权限用户不得通过邀请错误、搜索结果、邮箱补全、列表数量或审计摘要推断成员是否存在", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("role-select-direct-submit") do
    audit(owner: owner.gsub("角色 Select 只能编辑 `roleAssignmentState` 草稿", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("role-save-binding-missing") do
    audit(owner: owner.gsub("保存角色变更必须读取当前成员版本、角色版本、权限版本、租户/工作区、操作者身份和目标角色快照", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("admin-role-change-bypasses-risk") do
    audit(owner: owner.gsub("提升为管理员、降低管理员、修改外部成员权限、跨租户/工作区授权、批量角色变更、影响自身权限或影响最后 owner 的操作必须进入 `risk-actions.md`", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("member-remove-bypasses-risk") do
    audit(owner: owner.gsub("移除成员、禁用成员、启用成员、恢复成员、转移 owner、移除最后管理员、移除自己、禁用自己、批量移除或批量禁用都必须进入 `risk-actions.md`", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("switch-directly-toggles-member") do
    audit(owner: owner.gsub("不能用 Switch/Toggle 直接启停成员", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("request-before-confirm") do
    audit(owner: owner.gsub("确认前请求数为 0", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("stale-member-state-survives") do
    audit(owner: owner.gsub("旧成员列表、旧角色 Select、旧邀请链接、旧菜单、旧按钮、旧确认面板、旧 Toast/Notification、旧审计跳转、旧焦点目标和旧 ARIA 引用必须失效或重算", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("late-callback-writes-back") do
    audit(owner: owner.gsub("迟到请求、缓存回放、浏览器 Back、任务中心回调、邮件链接 callback 和审计跳转只有在 `membershipOwnerId`、租户/工作区、成员版本、权限版本和请求身份仍匹配时才能写回", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("unknown-result-as-success") do
    audit(owner: owner.gsub("未知结果不能伪装成角色变更成功、邀请成功、撤销成功、移除成功或禁用成功", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("toast-only-receipt") do
    audit(owner: owner.gsub("不能作为唯一结果回执、唯一邀请恢复入口、唯一审计入口、唯一错误说明或唯一权限原因", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-recovery-removed") do
    audit(owner: owner.gsub("移动端不得删除邀请成员、成员状态、角色说明、角色变更确认、撤销邀请、重新发送邀请、禁用原因、移除/恢复路径、转移 owner、审计入口、权限说明和错误恢复", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"), skill: skill, readme: readme, handoff: handoff,
          green: green.gsub("未验证", "已验证"), red: red.gsub("未验证", "已验证"))
  end

  expect_failure("missing-skill-route") do
    audit(owner: owner, skill: skill.gsub("必须完整读取 `references/members-invitations-access.md`", ""), readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 成员、邀请与团队访问管理 owner、路由、摘要和证据符合结构化审计契约。"
