#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/webhooks-integrations-callbacks.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/webhooks-integrations-callbacks/green-summary.md")
RED = File.join(ROOT, "docs/testing/webhooks-integrations-callbacks/red-summary.md")

OWNER_TERMS = [
  "webhookIntegrationState",
  "`integrationOwnerId`",
  "`integrationIdentity`",
  "`configurationVersion`",
  "`endpointState`",
  "`eventSubscriptionState`",
  "`deliveryState`",
  "`secretBinding`",
  "`testDeliveryIntent`",
  "`riskBinding`",
  "`permissionBoundary`",
  "`auditBinding`",
  "`resultReceipt`",
  "`not-tested`",
  "`test-pending`",
  "`test-succeeded`",
  "`test-failed`",
  "`delivery-pending`",
  "`delivery-failed`",
  "`retrying`",
  "`disabled`",
  "`unknown`",
  "Webhook、集成连接、回调 URL、事件订阅和投递状态不能只按普通设置项展示",
  "配置草稿、已保存配置、生效配置、外部连接状态、事件订阅状态、投递状态和审计状态必须分开表达",
  "测试成功不等于配置已生效",
  "保存成功不等于外部系统可达",
  "回调 URL、Endpoint、事件订阅、环境、租户/工作区、provider 和外部系统身份必须绑定 `configurationVersion`、`integrationIdentity` 和 `permissionBoundary`",
  "编辑 endpoint 或事件订阅只改变草稿；保存前不得改变生效配置",
  "旧 endpoint、旧事件订阅、旧签名 secret、旧测试投递、旧日志入口、旧重试任务、旧复制链接和旧 Toast/Notification 必须在配置版本、权限、会话、租户/工作区、环境或外部连接状态变化后失效或重算",
  "测试连接、测试投递、验证签名和事件回放必须绑定 `testDeliveryIntent`、payload 范围、请求身份、权限版本、租户/工作区和审计身份",
  "测试动作必须说明是否会向外部系统发送真实请求、是否使用样例 payload、是否会创建外部记录、是否可重试、是否会出现在回调日志中",
  "确认前请求数为 0",
  "启用 Webhook、停用 Webhook、删除 Webhook、重置签名 secret、重试投递、事件回放、批量重试和敏感日志导出必须进入 `risk-actions.md`",
  "不得用 Switch/Toggle 直接启停 Webhook",
  "投递状态必须区分未测试、测试中、测试成功、测试失败、投递中、投递失败、重试中、已停用、未知和外部系统不可用",
  "未知结果不能伪装成保存成功、测试成功、启用成功、删除成功、重试成功或回放成功",
  "回调日志、投递日志、错误明细和审计摘要不得泄露无权限 URL、payload、header、签名、token、secret、客户数据、外部系统对象、内部 ID 或旧缓存",
  "Toast、Notification、Snackbar 或浏览器提示不能作为唯一保存回执、测试回执、投递结果、日志入口、任务入口、审计入口、错误说明或恢复路径",
  "移动端不得删除 endpoint 状态、事件订阅摘要、测试连接、测试投递、签名校验说明、启停原因、重试/回放、回调日志、错误明细、任务入口、审计入口、权限说明和恢复路径",
  "未验证"
].freeze

SKILL_TERMS = [
  "涉及 Webhook、回调、回调 URL、回调地址、集成、第三方集成、外部集成、连接配置、连接测试、测试连接、测试投递、事件订阅、订阅事件、事件回放、重试投递、投递日志、回调日志、签名密钥、签名校验、Endpoint、外部系统、集成状态、启用 Webhook、停用 Webhook、删除 Webhook",
  "webhook、webhooks、callback、callback URL、endpoint、integration、third-party integration、external integration、connection config、connection test、test delivery、event subscription、subscribed events、event replay、retry delivery、delivery log、callback log、signing secret、signature verification、external system、integration status、enable webhook、disable webhook、delete webhook",
  "必须完整读取 `references/webhooks-integrations-callbacks.md`"
].freeze

SUMMARY_TERMS = [
  "Webhook",
  "集成连接",
  "回调配置",
  "测试投递",
  "事件订阅",
  "重试投递",
  "Toast",
  "移动端"
].freeze

EVIDENCE_TERMS = [
  "webhookIntegrationState",
  "configurationVersion",
  "endpointState",
  "eventSubscriptionState",
  "deliveryState",
  "testDeliveryIntent",
  "risk-actions.md",
  "确认前请求数为 0",
  "旧 endpoint",
  "Switch",
  "payload",
  "header",
  "secret",
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
    audit(owner: owner.gsub("webhookIntegrationState", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("ordinary-setting-item") do
    audit(owner: owner.gsub("Webhook、集成连接、回调 URL、事件订阅和投递状态不能只按普通设置项展示", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("states-merged") do
    audit(owner: owner.gsub("配置草稿、已保存配置、生效配置、外部连接状态、事件订阅状态、投递状态和审计状态必须分开表达", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("test-success-as-effective") do
    audit(owner: owner.gsub("测试成功不等于配置已生效", "").gsub("保存成功不等于外部系统可达", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("endpoint-binding-missing") do
    audit(owner: owner.gsub("回调 URL、Endpoint、事件订阅、环境、租户/工作区、provider 和外部系统身份必须绑定 `configurationVersion`、`integrationIdentity` 和 `permissionBoundary`", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("endpoint-directly-effective") do
    audit(owner: owner.gsub("编辑 endpoint 或事件订阅只改变草稿；保存前不得改变生效配置", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("stale-endpoint-survives") do
    audit(owner: owner.gsub("旧 endpoint、旧事件订阅、旧签名 secret、旧测试投递、旧日志入口、旧重试任务、旧复制链接和旧 Toast/Notification 必须在配置版本、权限、会话、租户/工作区、环境或外部连接状态变化后失效或重算", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("test-delivery-intent-missing") do
    audit(owner: owner.gsub("测试连接、测试投递、验证签名和事件回放必须绑定 `testDeliveryIntent`、payload 范围、请求身份、权限版本、租户/工作区和审计身份", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("test-side-effect-undisclosed") do
    audit(owner: owner.gsub("测试动作必须说明是否会向外部系统发送真实请求、是否使用样例 payload、是否会创建外部记录、是否可重试、是否会出现在回调日志中", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("request-before-confirm") do
    audit(owner: owner.gsub("确认前请求数为 0", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("risk-action-bypassed") do
    audit(owner: owner.gsub("启用 Webhook、停用 Webhook、删除 Webhook、重置签名 secret、重试投递、事件回放、批量重试和敏感日志导出必须进入 `risk-actions.md`", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("switch-directly-toggles-webhook") do
    audit(owner: owner.gsub("不得用 Switch/Toggle 直接启停 Webhook", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("delivery-state-merged") do
    audit(owner: owner.gsub("投递状态必须区分未测试、测试中、测试成功、测试失败、投递中、投递失败、重试中、已停用、未知和外部系统不可用", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("unknown-result-as-success") do
    audit(owner: owner.gsub("未知结果不能伪装成保存成功、测试成功、启用成功、删除成功、重试成功或回放成功", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("log-leaks-payload") do
    audit(owner: owner.gsub("回调日志、投递日志、错误明细和审计摘要不得泄露无权限 URL、payload、header、签名、token、secret、客户数据、外部系统对象、内部 ID 或旧缓存", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("toast-only-receipt") do
    audit(owner: owner.gsub("Toast、Notification、Snackbar 或浏览器提示不能作为唯一保存回执、测试回执、投递结果、日志入口、任务入口、审计入口、错误说明或恢复路径", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-recovery-removed") do
    audit(owner: owner.gsub("移动端不得删除 endpoint 状态、事件订阅摘要、测试连接、测试投递、签名校验说明、启停原因、重试/回放、回调日志、错误明细、任务入口、审计入口、权限说明和恢复路径", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"), skill: skill, readme: readme, handoff: handoff,
          green: green.gsub("未验证", "已验证"), red: red.gsub("未验证", "已验证"))
  end

  expect_failure("missing-skill-route") do
    audit(owner: owner, skill: skill.gsub("必须完整读取 `references/webhooks-integrations-callbacks.md`", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: Webhook、集成连接与回调配置 owner、路由、摘要和证据符合结构化审计契约。"
