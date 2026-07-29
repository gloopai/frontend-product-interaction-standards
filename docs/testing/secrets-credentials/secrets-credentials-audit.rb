#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/secrets-credentials.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/secrets-credentials/green-summary.md")
RED = File.join(ROOT, "docs/testing/secrets-credentials/red-summary.md")

OWNER_TERMS = [
  "secretCredentialState",
  "`credentialOwnerId`",
  "`credentialIdentity`",
  "`credentialVersion`",
  "`secretVisibilityState`",
  "`secretValuePolicy`",
  "`revealIntent`",
  "`copyIntent`",
  "`downloadIntent`",
  "`rotationIntent`",
  "`permissionBoundary`",
  "`authBinding`",
  "`auditBinding`",
  "`resultReceipt`",
  "`masked`",
  "`reveal-requested`",
  "`revealed`",
  "`reveal-expired`",
  "`copy-ready`",
  "`copied`",
  "`download-ready`",
  "`downloaded`",
  "`revoked`",
  "`rotating`",
  "`unknown`",
  "密钥、令牌和敏感凭证不能只按普通详情字段展示",
  "真实值、脱敏值、不可再次查看的一次性值、旧版本值、已撤销值和未知状态必须明确区分",
  "一旦离开无法再次查看",
  "Reveal 真实值必须由明确用户意图触发",
  "不能在 hover、自动聚焦、页面加载、展开详情、复制失败或移动端键盘打开时自动 Reveal",
  "Reveal 必须绑定 `revealIntent`、`permissionBoundary`、`authBinding`、`credentialVersion` 和过期策略",
  "真实值必须立即隐藏或失效",
  "复制真实密钥必须绑定 `copyIntent`、当前凭证版本、权限版本、租户/工作区、认证强度和请求身份",
  "不能在 Toast/Notification 中包含密钥片段",
  "复制脱敏值不得误导用户以为复制了真实值",
  "下载必须绑定 `downloadIntent`、凭证版本、文件格式、有效期、权限版本、认证强度、请求身份和审计",
  "旧下载链接、浏览器历史、Notification、任务入口和复制下载链接",
  "必须在权限变化、会话过期、凭证轮换、撤销、过期或租户切换后失效或重新证明安全",
  "轮换、重置、撤销、删除、停用、启用或泄露恢复必须进入 `risk-actions.md`",
  "确认前请求数为 0",
  "不得用 Switch 直接启停密钥",
  "旧真实值、旧复制按钮、旧下载链接、旧 Reveal 状态、旧 Toast/Notification、旧任务入口、旧审计跳转和旧 ARIA 引用必须失效或重算",
  "未知结果不能伪装成轮换成功或撤销成功",
  "审计记录不得包含真实密钥、完整 token、可复原片段、下载 URL、签名材料或剪贴板内容",
  "移动端不得删除 Reveal、复制、下载、轮换、撤销、过期、审计和恢复路径",
  "系统剪贴板、截图、录屏、键盘建议或共享设备风险",
  "未验证"
].freeze

SKILL_TERMS = [
  "涉及密钥、令牌、凭证、API Key、访问令牌、Webhook Secret、Client Secret、集成凭证、服务账号、签名密钥、一次性密钥、显示密钥、Reveal、复制密钥、下载凭证、轮换密钥、重置密钥、撤销密钥、泄露恢复",
  "secret、secrets、credential、credentials、API key、access token、refresh token、webhook secret、client secret、integration credential、service account、signing key、one-time secret、reveal secret、copy secret、download credential、rotate key、reset key、revoke key、leak recovery",
  "必须完整读取 `references/secrets-credentials.md`"
].freeze

SUMMARY_TERMS = [
  "密钥、令牌与敏感凭证",
  "API Key",
  "Reveal",
  "复制",
  "下载凭证",
  "Rotate",
  "Toast",
  "移动端"
].freeze

EVIDENCE_TERMS = [
  "secretCredentialState",
  "credentialVersion",
  "revealIntent",
  "copyIntent",
  "downloadIntent",
  "rotationIntent",
  "auditBinding",
  "一旦离开无法再次查看",
  "真实密钥",
  "系统剪贴板",
  "Toast",
  "旧下载链接",
  "Switch",
  "确认前请求数为 0",
  "未知结果",
  "审计记录",
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
    audit(owner: owner.gsub("secretCredentialState", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("ordinary-readonly-field") do
    audit(owner: owner.gsub("密钥、令牌和敏感凭证不能只按普通详情字段展示", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("one-time-secret-warning-missing") do
    audit(owner: owner.gsub("一旦离开无法再次查看", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("automatic-reveal-allowed") do
    audit(owner: owner.gsub("不能在 hover、自动聚焦、页面加载、展开详情、复制失败或移动端键盘打开时自动 Reveal", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("reveal-binding-missing") do
    audit(owner: owner.gsub("Reveal 必须绑定 `revealIntent`、`permissionBoundary`、`authBinding`、`credentialVersion` 和过期策略", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("copy-binding-missing") do
    audit(owner: owner.gsub("复制真实密钥必须绑定 `copyIntent`、当前凭证版本、权限版本、租户/工作区、认证强度和请求身份", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("toast-leaks-secret-fragment") do
    audit(owner: owner.gsub("不能在 Toast/Notification 中包含密钥片段", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("masked-copy-misleads-user") do
    audit(owner: owner.gsub("复制脱敏值不得误导用户以为复制了真实值", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("download-binding-missing") do
    audit(owner: owner.gsub("下载必须绑定 `downloadIntent`、凭证版本、文件格式、有效期、权限版本、认证强度、请求身份和审计", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("old-download-link-survives") do
    audit(owner: owner.gsub("必须在权限变化、会话过期、凭证轮换、撤销、过期或租户切换后失效或重新证明安全", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("rotation-bypasses-risk-owner") do
    audit(owner: owner.gsub("轮换、重置、撤销、删除、停用、启用或泄露恢复必须进入 `risk-actions.md`", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("request-before-confirm") do
    audit(owner: owner.gsub("确认前请求数为 0", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("switch-directly-toggles-secret") do
    audit(owner: owner.gsub("不得用 Switch 直接启停密钥", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("old-secret-state-survives") do
    audit(owner: owner.gsub("旧真实值、旧复制按钮、旧下载链接、旧 Reveal 状态、旧 Toast/Notification、旧任务入口、旧审计跳转和旧 ARIA 引用必须失效或重算", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("unknown-result-as-success") do
    audit(owner: owner.gsub("未知结果不能伪装成轮换成功或撤销成功", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("audit-leaks-secret") do
    audit(owner: owner.gsub("审计记录不得包含真实密钥、完整 token、可复原片段、下载 URL、签名材料或剪贴板内容", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-recovery-removed") do
    audit(owner: owner.gsub("移动端不得删除 Reveal、复制、下载、轮换、撤销、过期、审计和恢复路径", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"), skill: skill, readme: readme, handoff: handoff,
          green: green.gsub("未验证", "已验证"), red: red.gsub("未验证", "已验证"))
  end

  expect_failure("missing-skill-route") do
    audit(owner: owner, skill: skill.gsub("必须完整读取 `references/secrets-credentials.md`", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 密钥、令牌与敏感凭证 owner、路由、摘要和证据符合结构化审计契约。"
