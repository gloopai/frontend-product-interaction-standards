#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/copy-clipboard.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/copy-clipboard/green-summary.md")
RED = File.join(ROOT, "docs/testing/copy-clipboard/red-summary.md")

STATE_FIELDS = %w[
  copyOwnerId copyIntent sourceBinding valuePolicy sensitiveBoundary
  clipboardCapability linkBinding resultReceipt auditBinding focusReturn disposalState
].freeze

OWNER_TERMS = [
  "copyActionState",
  "`copy-ready`",
  "`copying`",
  "`copied`",
  "`failed`",
  "`denied`",
  "`expired`",
  "`stale`",
  "`unknown`",
  "复制必须绑定当前快照",
  "每个业务复制按钮、菜单项或快捷动作都必须创建 `copyIntent`",
  "不得读取旧 DOM、旧缓存、旧请求结果、隐藏字段、旧权限字段、旧下载 URL、旧邀请链接或旧审计详情",
  "复制脱敏值必须明确告诉用户复制的是脱敏值或安全摘要，不能误导用户以为复制了真实值",
  "Toast、Notification、Tooltip、ARIA label、审计摘要和错误说明不得包含真实密钥、token 片段、完整下载 URL、邀请 token、签名材料、payload、无权限字段或可复原敏感内容",
  "复制链接不是权限证明",
  "旧复制链接、旧浏览器历史、旧 Toast/Notification、旧菜单项和旧 DOM 属性必须在权限变化、会话过期、租户/工作区切换、对象删除、任务过期、文件过期、邀请撤销、凭证轮换或链接版本变化后失效或重新证明安全",
  "复制成功只表示写入系统剪贴板成功，不代表用户已经安全保存、链接已经被使用、邀请已经发送、文件已经下载、任务已经完成、字段已经更新或审计已经导出",
  "复制失败不能静默吞掉",
  "复制按钮、图标按钮、菜单项和快捷操作必须有动作对象和可访问名称",
  "复制成功、失败、权限拒绝、过期和未知结果必须由唯一 owner 公告",
  "移动端、低高度、虚拟键盘、安全区域、WebView、系统分享面板、系统剪贴板限制和 200% 缩放下，不得删除核心复制入口、复制失败原因、敏感警示、权限说明或替代路径",
  "未验证"
].freeze

SKILL_TERMS = [
  "涉及复制、复制字段、复制值、复制文本、复制 ID、复制编号、复制错误编号、复制链接、复制邀请链接、复制下载链接、复制地址、复制 URL、复制配置、复制片段、复制命令、复制审计字段、复制数据、复制图片、复制脱敏值、复制真实值、剪贴板、系统剪贴板、一键复制、复制失败",
  "copy、clipboard、copy field、copy value、copy text、copy id、copy identifier、copy error code、copy link、copy invite link、copy download link、copy URL、copy address、copy config、copy snippet、copy command、copy audit field、copy data、copy image、copy masked value、copy real value、copy to clipboard、clipboard failure",
  "必须完整读取 `references/copy-clipboard.md`"
].freeze

SUMMARY_TERMS = [
  "复制",
  "剪贴板",
  "复制链接",
  "脱敏值",
  "真实值",
  "Toast",
  "权限",
  "移动端"
].freeze

EVIDENCE_TERMS = [
  "copyActionState",
  "copyIntent",
  "sourceBinding",
  "valuePolicy",
  "sensitiveBoundary",
  "clipboardCapability",
  "linkBinding",
  "resultReceipt",
  "旧 DOM",
  "旧复制链接",
  "脱敏值",
  "Toast",
  "复制失败",
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
  STATE_FIELDS.each { |field| failures << "owner: copyActionState missing #{field}" unless owner.include?(field) }
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
  expect_failure("missing-owner-state") { audit(owner: owner.gsub("copyActionState", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("copy-intent-missing") { audit(owner: owner.gsub("每个业务复制按钮、菜单项或快捷动作都必须创建 `copyIntent`", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("stale-dom-copy") { audit(owner: owner.gsub("不得读取旧 DOM、旧缓存、旧请求结果、隐藏字段、旧权限字段、旧下载 URL、旧邀请链接或旧审计详情", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("masked-value-misleads") { audit(owner: owner.gsub("复制脱敏值必须明确告诉用户复制的是脱敏值或安全摘要，不能误导用户以为复制了真实值", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("toast-leaks-secret") { audit(owner: owner.gsub("Toast、Notification、Tooltip、ARIA label、审计摘要和错误说明不得包含真实密钥、token 片段、完整下载 URL、邀请 token、签名材料、payload、无权限字段或可复原敏感内容", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("copy-link-as-permission") { audit(owner: owner.gsub("复制链接不是权限证明", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("stale-link-survives") { audit(owner: owner.gsub("旧复制链接、旧浏览器历史、旧 Toast/Notification、旧菜单项和旧 DOM 属性必须在权限变化、会话过期、租户/工作区切换、对象删除、任务过期、文件过期、邀请撤销、凭证轮换或链接版本变化后失效或重新证明安全", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("copy-success-as-business-complete") { audit(owner: owner.gsub("复制成功只表示写入系统剪贴板成功，不代表用户已经安全保存、链接已经被使用、邀请已经发送、文件已经下载、任务已经完成、字段已经更新或审计已经导出", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("clipboard-failure-silent") { audit(owner: owner.gsub("复制失败不能静默吞掉", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("a11y-object-missing") { audit(owner: owner.gsub("复制按钮、图标按钮、菜单项和快捷操作必须有动作对象和可访问名称", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("duplicate-announcement") { audit(owner: owner.gsub("复制成功、失败、权限拒绝、过期和未知结果必须由唯一 owner 公告", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("mobile-copy-removed") { audit(owner: owner.gsub("移动端、低高度、虚拟键盘、安全区域、WebView、系统分享面板、系统剪贴板限制和 200% 缩放下，不得删除核心复制入口、复制失败原因、敏感警示、权限说明或替代路径", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red) }
  expect_failure("runtime-boundary-marked-verified") { audit(owner: owner.gsub("未验证", "已验证"), skill: skill, readme: readme, handoff: handoff, green: green.gsub("未验证", "已验证"), red: red.gsub("未验证", "已验证")) }
  expect_failure("missing-skill-route") { audit(owner: owner, skill: skill.gsub("必须完整读取 `references/copy-clipboard.md`", ""), readme: readme, handoff: handoff, green: green, red: red) }
end

puts "PASS: 复制与剪贴板 owner、路由、摘要和证据符合结构化审计契约。"
