#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/billing-subscription-invoices.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/billing-subscription-invoices/green-summary.md")
RED = File.join(ROOT, "docs/testing/billing-subscription-invoices/red-summary.md")

OWNER_TERMS = [
  "billingSubscriptionState",
  "`billingOwnerId`",
  "`billingAccountIdentity`",
  "`subscriptionVersion`",
  "`pricingSnapshot`",
  "`entitlementState`",
  "`usageQuotaState`",
  "`paymentState`",
  "`invoiceState`",
  "`billingChangeIntent`",
  "`riskBinding`",
  "`permissionBoundary`",
  "`auditBinding`",
  "`resultReceipt`",
  "`not-started`",
  "`payment-method-draft`",
  "`payment-method-saved`",
  "`payment-pending`",
  "`payment-succeeded`",
  "`payment-failed`",
  "`requires-action`",
  "`unknown`",
  "`not-generated`",
  "`generating`",
  "`ready`",
  "`downloaded`",
  "`voided`",
  "`refunded`",
  "`expired`",
  "`unavailable`",
  "计费、套餐、订阅、付款方式、用量额度和发票不能只按普通设置项展示",
  "套餐展示状态、确认状态、支付状态、订阅生效状态、权益生效状态、用量状态、发票产物状态和审计状态必须分开表达",
  "付款方式保存成功不等于支付成功",
  "支付成功不等于订阅已生效",
  "订阅已生效不等于所有权益、用量额度、发票和审计都已更新",
  "套餐卡、确认页、支付请求、审计记录和结果回执必须绑定同一个 `pricingSnapshot`",
  "切换套餐、升级、降级、切换月付/年付、应用优惠、购买额度、取消续费或恢复订阅前，必须展示当前套餐、目标套餐、账期、生效时间、权益变化、数据保留、额度变化、费用变化和未知结果处理",
  "旧价格、旧优惠、旧估算、旧套餐卡片和旧确认面板在价格版本、权限、租户/工作区、订阅版本、优惠状态或会话变化后必须失效或重算",
  "`paymentState`、订阅状态、`entitlementState`、`usageQuotaState` 和 `invoiceState` 必须分开",
  "未知结果不能伪装成支付成功、订阅成功、取消成功、降级成功、退款成功、发票已生成或额度已到账",
  "取消订阅、取消自动续费、降级套餐、删除付款方式、申请退款、撤销退款、清空余额、购买大额额度、切换账期产生即时收费或失去权益的操作必须进入 `risk-actions.md`",
  "确认前请求数为 0",
  "不得用 Switch/Toggle 直接取消订阅、开启/关闭自动续费、删除付款方式或切换高影响账期",
  "发票、收据、账单明细、对账单、消费记录和税务资料下载必须执行 `exports-downloads-artifacts.md`",
  "下载链接不是权限证明",
  "旧发票链接、旧收据链接、旧账单导出任务、旧浏览器历史、旧 Notification、旧复制链接和旧 Toast/Notification 必须在权限变化、会话过期、租户/工作区切换、发票状态变化、退款、作废、重新开票或对象删除后失效或重新证明安全",
  "用量、额度、余额、抵扣、试用剩余额度、超额状态和消费记录必须声明计量周期、刷新时间、数据延迟、估算/最终状态、单位、权限范围和适用套餐",
  "用量条不能作为实时额度证明",
  "无权限用户不得通过套餐卡、价格、折扣、税费、发票列表、支付错误、用量条、账单历史、DOM/ARIA、Toast、Notification、下载链接或审计摘要推断账单主体、付款方式、金额、税号、地址、邮箱、发票编号、内部 ID、支付 provider 对象或旧缓存",
  "Toast、Notification、Snackbar 或浏览器提示不能作为唯一支付失败、支付未知、取消订阅、降级、退款、发票生成失败、发票下载失败、用量同步失败、权限拒绝或部分成功恢复路径",
  "移动端不得删除当前套餐、目标套餐、金额、币种、账期、税费/折扣摘要、权益变化、用量口径、额度状态、付款方式状态、支付失败恢复、取消/降级影响范围、发票下载、账单历史、审计入口、权限说明和恢复路径",
  "未验证"
].freeze

SKILL_TERMS = [
  "涉及计费、账单、套餐、订阅、试用、续费、取消订阅、升级套餐、降级套餐、切换套餐、付款方式、支付方式、支付失败、支付成功、发票、收据、账单明细、用量、额度、余额、抵扣、优惠券、折扣、税费、退款、开票、重新开票、账单周期、月付、年付、自动续费、取消续费、账单历史、消费记录",
  "billing、bill、invoice、receipt、subscription、plan、pricing、trial、renewal、cancel subscription、upgrade plan、downgrade plan、change plan、payment method、card、payment failed、payment succeeded、usage、quota、credit、balance、coupon、discount、tax、refund、billing cycle、monthly、annual、auto renew、billing history、statement",
  "必须完整读取 `references/billing-subscription-invoices.md`"
].freeze

SUMMARY_TERMS = [
  "计费",
  "套餐",
  "订阅",
  "发票",
  "支付",
  "用量",
  "额度",
  "退款",
  "Toast",
  "移动端"
].freeze

EVIDENCE_TERMS = [
  "billingSubscriptionState",
  "subscriptionVersion",
  "pricingSnapshot",
  "paymentState",
  "invoiceState",
  "usageQuotaState",
  "risk-actions.md",
  "exports-downloads-artifacts.md",
  "确认前请求数为 0",
  "Switch",
  "旧发票链接",
  "用量条",
  "实时额度证明",
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
    audit(owner: owner.gsub("billingSubscriptionState", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("ordinary-setting-item") do
    audit(owner: owner.gsub("计费、套餐、订阅、付款方式、用量额度和发票不能只按普通设置项展示", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("states-merged") do
    audit(owner: owner.gsub("套餐展示状态、确认状态、支付状态、订阅生效状态、权益生效状态、用量状态、发票产物状态和审计状态必须分开表达", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("payment-method-as-payment-success") do
    audit(owner: owner.gsub("付款方式保存成功不等于支付成功", "").gsub("支付成功不等于订阅已生效", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("pricing-snapshot-missing") do
    audit(owner: owner.gsub("套餐卡、确认页、支付请求、审计记录和结果回执必须绑定同一个 `pricingSnapshot`", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("plan-change-impact-missing") do
    audit(owner: owner.gsub("切换套餐、升级、降级、切换月付/年付、应用优惠、购买额度、取消续费或恢复订阅前，必须展示当前套餐、目标套餐、账期、生效时间、权益变化、数据保留、额度变化、费用变化和未知结果处理", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("stale-price-survives") do
    audit(owner: owner.gsub("旧价格、旧优惠、旧估算、旧套餐卡片和旧确认面板在价格版本、权限、租户/工作区、订阅版本、优惠状态或会话变化后必须失效或重算", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("payment-state-merged") do
    audit(owner: owner.gsub("`paymentState`、订阅状态、`entitlementState`、`usageQuotaState` 和 `invoiceState` 必须分开", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("unknown-result-as-success") do
    audit(owner: owner.gsub("未知结果不能伪装成支付成功、订阅成功、取消成功、降级成功、退款成功、发票已生成或额度已到账", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("risk-action-bypassed") do
    audit(owner: owner.gsub("取消订阅、取消自动续费、降级套餐、删除付款方式、申请退款、撤销退款、清空余额、购买大额额度、切换账期产生即时收费或失去权益的操作必须进入 `risk-actions.md`", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("request-before-confirm") do
    audit(owner: owner.gsub("确认前请求数为 0", ""), skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("switch-directly-toggles-subscription") do
    audit(owner: owner.gsub("不得用 Switch/Toggle 直接取消订阅、开启/关闭自动续费、删除付款方式或切换高影响账期", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("invoice-download-bypasses-export-owner") do
    audit(owner: owner.gsub("发票、收据、账单明细、对账单、消费记录和税务资料下载必须执行 `exports-downloads-artifacts.md`", "")
                      .gsub("下载链接不是权限证明", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("stale-invoice-link-survives") do
    audit(owner: owner.gsub("旧发票链接、旧收据链接、旧账单导出任务、旧浏览器历史、旧 Notification、旧复制链接和旧 Toast/Notification 必须在权限变化、会话过期、租户/工作区切换、发票状态变化、退款、作废、重新开票或对象删除后失效或重新证明安全", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("usage-quota-semantics-missing") do
    audit(owner: owner.gsub("用量、额度、余额、抵扣、试用剩余额度、超额状态和消费记录必须声明计量周期、刷新时间、数据延迟、估算/最终状态、单位、权限范围和适用套餐", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("usage-bar-as-real-time-proof") do
    audit(owner: owner.gsub("用量条不能作为实时额度证明", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-leaks-billing") do
    audit(owner: owner.gsub("无权限用户不得通过套餐卡、价格、折扣、税费、发票列表、支付错误、用量条、账单历史、DOM/ARIA、Toast、Notification、下载链接或审计摘要推断账单主体、付款方式、金额、税号、地址、邮箱、发票编号、内部 ID、支付 provider 对象或旧缓存", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("toast-only-receipt") do
    audit(owner: owner.gsub("Toast、Notification、Snackbar 或浏览器提示不能作为唯一支付失败、支付未知、取消订阅、降级、退款、发票生成失败、发票下载失败、用量同步失败、权限拒绝或部分成功恢复路径", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-recovery-removed") do
    audit(owner: owner.gsub("移动端不得删除当前套餐、目标套餐、金额、币种、账期、税费/折扣摘要、权益变化、用量口径、额度状态、付款方式状态、支付失败恢复、取消/降级影响范围、发票下载、账单历史、审计入口、权限说明和恢复路径", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"), skill: skill, readme: readme, handoff: handoff,
          green: green.gsub("未验证", "已验证"), red: red.gsub("未验证", "已验证"))
  end

  expect_failure("missing-skill-route") do
    audit(owner: owner, skill: skill.gsub("必须完整读取 `references/billing-subscription-invoices.md`", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 计费、套餐、订阅与发票 owner、路由、摘要和证据符合结构化审计契约。"
