#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/notifications-message-center-announcements.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/notifications-message-center-announcements/green-summary.md")
RED = File.join(ROOT, "docs/testing/notifications-message-center-announcements/red-summary.md")

STATE_FIELDS = %w[
  notificationOwnerId notificationIdentity recipientBoundary messageState
  deliveryChannelState announcementState clickTargetBinding preferenceState
  badgeState riskBinding permissionBoundary auditBinding resultReceipt
].freeze

OWNER_TERMS = [
  "notificationCenterState",
  "`unread`",
  "`read`",
  "`archived`",
  "`deleted`",
  "`expired`",
  "`hidden-by-permission`",
  "`unknown`",
  "`in-app`",
  "`email`",
  "`sms`",
  "`push`",
  "`webhook`",
  "`muted`",
  "`disabled`",
  "`failed`",
  "持久通知不是 Toast",
  "Toast 可以提示“有新消息”，但不能成为唯一消息记录、唯一恢复入口、唯一审计入口或唯一错误说明",
  "通知点击不是普通链接",
  "点击前必须复核权限、目标对象状态、租户/工作区、来源上下文和目标路由是否仍安全",
  "旧通知、旧点击链接、旧邮件入口、旧 Push deep link、旧公告、旧 Toast/Notification 和旧未读角标必须在权限、租户/工作区、对象状态、事件版本、投递版本、偏好版本、会话或渠道状态变化后失效或重算",
  "标记已读不等于归档",
  "归档不等于删除",
  "删除通知不等于删除目标对象",
  "关闭公告不等于已读所有相关消息",
  "未读数必须绑定 `badgeState`",
  "保存偏好成功不等于邮件、短信、Push 或 Webhook 通知真实可达",
  "系统公告、维护公告、发布公告、运营公告和强制阅读公告必须维护 `announcementState`",
  "公告 Banner、Modal、Drawer 或顶部条不能遮挡 Dialog/Drawer 底部操作、危险确认、表单错误、支付确认、导出下载、任务取消、导航返回或安全区域",
  "无权限用户不得通过通知标题、摘要、图标、未读数、分类、错误、空态、DOM/ARIA、邮件预览、短信文案、Push 文案、下载链接、点击目标或审计摘要推断对象名称、金额、成员、邮箱、发票编号、文件名、密钥、payload、内部 ID、外部对象或旧缓存",
  "全部已读、批量标记已读/未读、批量归档、删除通知、清空通知、退订通知、恢复订阅和关闭强制公告必须说明范围、数量、分类、权限版本、目标快照、请求身份、结果回执和未知结果处理",
  "确认前请求数为 0",
  "未知结果不能伪装成已读成功、归档成功、删除成功、退订成功、公告关闭成功或偏好保存成功",
  "移动端不得删除通知分类、未读/已读状态、未读角标含义、筛选、标记已读/未读、归档、退订/偏好入口、公告详情、点击恢复、权限说明、审计入口和错误恢复路径",
  "未验证"
].freeze

SKILL_TERMS = [
  "涉及通知中心、消息中心、站内信、通知、消息、公告、系统公告、运营公告、维护公告、发布公告、未读、已读、全部已读、标记已读、标记未读、归档通知、删除通知、通知设置、通知偏好、订阅偏好、邮件通知、短信通知、Push 通知、推送通知、通知入口、铃铛、消息角标、通知跳转、通知详情、退订通知",
  "notification center、message center、inbox、notification、message、announcement、system announcement、maintenance announcement、release announcement、unread、read、mark read、mark unread、mark all read、archive notification、delete notification、notification settings、notification preferences、subscription preferences、email notification、sms notification、push notification、notification bell、badge count、notification click、notification detail、unsubscribe notification",
  "必须完整读取 `references/notifications-message-center-announcements.md`"
].freeze

SUMMARY_TERMS = [
  "通知中心",
  "站内信",
  "公告",
  "未读",
  "已读",
  "通知偏好",
  "Toast",
  "权限",
  "移动端"
].freeze

EVIDENCE_TERMS = [
  "notificationCenterState",
  "notificationIdentity",
  "recipientBoundary",
  "messageState",
  "deliveryChannelState",
  "announcementState",
  "clickTargetBinding",
  "preferenceState",
  "badgeState",
  "Toast",
  "旧通知",
  "旧 Push deep link",
  "确认前请求数为 0",
  "未知结果",
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
  STATE_FIELDS.each { |field| failures << "owner: notificationCenterState missing #{field}" unless owner.include?(field) }
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures.concat(require_terms(skill, SKILL_TERMS, "skill"))
  failures.concat(require_terms(readme, SUMMARY_TERMS, "README"))
  failures.concat(require_terms(handoff, SUMMARY_TERMS, "HANDOFF"))
  failures.concat(require_terms(green, EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(red, EVIDENCE_TERMS, "RED evidence"))
  ["fex-admin", "/Users/evanqi/code/", "Ant Design", "ant-design", "shadcn", "Next.js", "Vite"].each do |term|
    failures << "owner: must stay project-agnostic, found #{term.inspect}" if owner.include?(term)
  end
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
  expect_failure("missing-owner-state") { audit(owner: owner.gsub("notificationCenterState", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("toast-as-persistent-notification") { audit(owner: owner.gsub("持久通知不是 Toast", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("toast-only-record") { audit(owner: owner.gsub("Toast 可以提示“有新消息”，但不能成为唯一消息记录、唯一恢复入口、唯一审计入口或唯一错误说明", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("notification-click-as-link") { audit(owner: owner.gsub("通知点击不是普通链接", "").gsub("点击前必须复核权限、目标对象状态、租户/工作区、来源上下文和目标路由是否仍安全", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("stale-notification-survives") { audit(owner: owner.gsub("旧通知、旧点击链接、旧邮件入口、旧 Push deep link、旧公告、旧 Toast/Notification 和旧未读角标必须在权限、租户/工作区、对象状态、事件版本、投递版本、偏好版本、会话或渠道状态变化后失效或重算", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("message-states-merged") { audit(owner: owner.gsub("标记已读不等于归档", "").gsub("归档不等于删除", "").gsub("删除通知不等于删除目标对象", "").gsub("关闭公告不等于已读所有相关消息", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("badge-state-missing") { audit(owner: owner.gsub("未读数必须绑定 `badgeState`", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("preference-as-delivery-success") { audit(owner: owner.gsub("保存偏好成功不等于邮件、短信、Push 或 Webhook 通知真实可达", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("announcement-obstructs-task") { audit(owner: owner.gsub("系统公告、维护公告、发布公告、运营公告和强制阅读公告必须维护 `announcementState`", "").gsub("公告 Banner、Modal、Drawer 或顶部条不能遮挡 Dialog/Drawer 底部操作、危险确认、表单错误、支付确认、导出下载、任务取消、导航返回或安全区域", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("permission-leakage") { audit(owner: owner.gsub("无权限用户不得通过通知标题、摘要、图标、未读数、分类、错误、空态、DOM/ARIA、邮件预览、短信文案、Push 文案、下载链接、点击目标或审计摘要推断对象名称、金额、成员、邮箱、发票编号、文件名、密钥、payload、内部 ID、外部对象或旧缓存", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("bulk-unknown-unrecoverable") { audit(owner: owner.gsub("全部已读、批量标记已读/未读、批量归档、删除通知、清空通知、退订通知、恢复订阅和关闭强制公告必须说明范围、数量、分类、权限版本、目标快照、请求身份、结果回执和未知结果处理", "").gsub("确认前请求数为 0", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("unknown-as-success") { audit(owner: owner.gsub("未知结果不能伪装成已读成功、归档成功、删除成功、退订成功、公告关闭成功或偏好保存成功", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("mobile-capabilities-removed") { audit(owner: owner.gsub("移动端不得删除通知分类、未读/已读状态、未读角标含义、筛选、标记已读/未读、归档、退订/偏好入口、公告详情、点击恢复、权限说明、审计入口和错误恢复路径", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("runtime-boundary-marked-verified") { audit(owner: owner.gsub("未验证", "已验证"), skill: skill, readme: readme, handoff: handoff, green: green.gsub("未验证", "已验证"), red: red.gsub("未验证", "已验证")) }
  expect_failure("missing-skill-route") { audit(owner: owner, skill: skill.gsub("必须完整读取 `references/notifications-message-center-announcements.md`", ""), readme: readme, handoff: handoff, green: green, red: red) }
end

puts "PASS: 通知中心、站内信与公告 owner、路由、摘要和证据符合结构化审计契约。"
