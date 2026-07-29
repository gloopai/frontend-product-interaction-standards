# Billing Subscription Invoices Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a dedicated Chinese interaction owner for billing, plans, subscriptions, trials, usage/quota, payment methods, invoices, receipts, refunds, pricing snapshots, stale invoice invalidation, audit safety, Toast boundaries, and mobile recovery.

**Architecture:** Add one owner document, `references/billing-subscription-invoices.md`, and route it from `SKILL.md`. Add a Ruby static audit and RED/GREEN evidence under `docs/testing/billing-subscription-invoices/`; then update README/HANDOFF summaries so the new owner is discoverable while keeping the full rule set in the owner file.

**Tech Stack:** Markdown reference documentation, Ruby static audit scripts, Git.

## Global Constraints

- Do not define payment gateways, card validation, tax calculation, pricing strategy, currency conversion, accounting rules, invoice law, refund policy, subscription engines, metering backends, billing sync jobs, fraud rules, tax ID validation, acquiring channels, provider APIs, concrete plan names, prices, coupon rules, quota models, invoice templates, tax rates, supported currencies, country/region compliance copy, or brand visuals.
- Do not replace `settings-preferences-configuration.md`, `risk-actions.md`, `exports-downloads-artifacts.md`, `async-jobs-task-center.md`, `audit-log-activity-history.md`, `permissions-tenancy-visibility.md`, `data-tables.md`, `auth-session-reauth.md`, `feedback-states.md`, or `global-feedback.md`; the new owner coordinates with them.
- Billing, bill, invoice, receipt, subscription, plan, pricing, trial, renewal, cancel subscription, upgrade plan, downgrade plan, change plan, payment method, payment state, usage, quota, credit, balance, coupon, discount, tax, refund, billing cycle, auto renew, billing history, and statement must be owned by `billing-subscription-invoices.md`.
- Plan display state, confirmation state, payment state, subscription effective state, entitlement effective state, usage/quota state, invoice artifact state, and audit state must remain distinct.
- Plan changes, checkout/payment requests, invoice downloads, refunds, cancellation, downgrades, and quota purchases must bind current billing account, tenant/workspace, subscription version, pricing snapshot, permission version, request identity, result receipt, and audit binding.
- Cancel subscription, cancel auto-renewal, downgrade plan, delete payment method, request refund, revoke refund, clear balance, buy large quota, and billing-cycle changes that charge immediately or remove entitlements must enter `risk-actions.md`; confirmation before request count is 0.
- Logs, feedback, invoice lists, billing history, and audit summaries must not leak unauthorized billing account, payment method, amount, tax ID, address, email, invoice number, provider object, internal ID, or stale cache.
- Runtime browser, mobile device, screen reader, real payment provider, real payment additional authentication, real invoice download, real refund/cancel/downgrade task, real permission switch, real session expiry, real billing sync, and real audit write checks must be reported as **未验证** unless actually executed.

---

### Task 1: Write the failing billing/subscription/invoices audit

**Files:**
- Create: `docs/testing/billing-subscription-invoices/billing-subscription-invoices-audit.rb`
- Create: `docs/testing/billing-subscription-invoices/red-summary.md`
- Create: `docs/testing/billing-subscription-invoices/green-summary.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-billing-subscription-invoices-interaction-standards-design.md`
- Produces: executable command `ruby docs/testing/billing-subscription-invoices/billing-subscription-invoices-audit.rb --mutations`

- [ ] **Step 1: Create RED evidence summary**

Write `docs/testing/billing-subscription-invoices/red-summary.md` with this content:

```markdown
# 计费、套餐、订阅与发票 RED 证据摘要

这些负向场景必须被规范和审计识别为失败：

- 计费、套餐、订阅、付款方式、用量额度或发票被当成普通设置项展示，没有 `billingSubscriptionState`、订阅版本、价格快照、支付状态、发票状态或用量口径。
- 套餐展示状态、确认状态、支付状态、订阅生效状态、权益生效状态、用量状态、发票产物状态和审计状态被合并成一个普通 saved/success/loading 状态。
- 付款方式保存成功被写成支付成功，支付成功被写成订阅已生效，订阅已生效被写成所有权益、用量额度、发票和审计都已更新。
- 套餐卡、确认页、支付请求、审计记录和结果回执没有绑定同一个 `pricingSnapshot`。
- 升级、降级、切换账期、应用优惠、购买额度、取消续费或恢复订阅前没有展示当前套餐、目标套餐、账期、生效时间、权益变化、数据保留、额度变化、费用变化和未知结果处理。
- 旧价格、旧优惠、旧估算、旧套餐卡片或旧确认面板在价格版本、权限、租户/工作区、订阅版本、优惠状态或会话变化后仍可用。
- `paymentState`、订阅状态、`entitlementState`、`usageQuotaState` 和 `invoiceState` 被混成一个普通 loading 或成功 Toast。
- 未知结果被伪装成支付成功、订阅成功、取消成功、降级成功、退款成功、发票已生成或额度已到账。
- 取消订阅、取消自动续费、降级套餐、删除付款方式、申请退款、撤销退款、清空余额、购买大额额度或高影响账期切换没有进入 `risk-actions.md`。
- 确认前请求数为 0 这条约束缺失，导致取消、降级、退款、删除付款方式、购买额度或账期切换确认前已经发送请求。
- 使用 Switch/Toggle 直接取消订阅、开启/关闭自动续费、删除付款方式或切换高影响账期。
- 发票、收据、账单明细、对账单、消费记录或税务资料下载没有执行 `exports-downloads-artifacts.md`，或把下载链接当成权限证明。
- 旧发票链接、旧收据链接、旧账单导出任务、旧浏览器历史、旧 Notification、旧复制链接或旧 Toast/Notification 在权限变化、会话过期、租户/工作区切换、发票状态变化、退款、作废、重新开票或对象删除后仍可用。
- 用量、额度、余额、抵扣、试用剩余额度、超额状态或消费记录没有声明计量周期、刷新时间、数据延迟、估算/最终状态、单位、权限范围和适用套餐。
- 用量条被当成实时额度证明，延迟、估算、部分同步失败或未知结果不可见。
- 无权限用户可通过套餐卡、价格、折扣、税费、发票列表、支付错误、用量条、账单历史、DOM/ARIA、Toast、Notification、下载链接或审计摘要推断账单主体、付款方式、金额、税号、地址、邮箱、发票编号、内部 ID、支付 provider 对象或旧缓存。
- Toast、Notification、Snackbar 或浏览器提示成为唯一支付失败、支付未知、取消订阅、降级、退款、发票生成失败、发票下载失败、用量同步失败、权限拒绝或部分成功恢复路径。
- 移动端、低高度、虚拟键盘、安全区域、系统字体放大、浏览器 Back、WebView 返回、支付额外认证跳转或触摸长按后，当前套餐、目标套餐、金额、币种、账期、税费/折扣摘要、权益变化、用量口径、额度状态、付款方式状态、支付失败恢复、取消/降级影响范围、发票下载、账单历史、审计入口、权限说明或恢复路径消失。
- 真实浏览器、移动端设备、屏幕阅读器、真实支付 provider、真实支付额外认证、真实发票下载、真实退款/取消/降级任务、真实权限切换、真实会话过期、真实账单同步或真实审计写入没有执行时，没有标为未验证。
```

- [ ] **Step 2: Create GREEN evidence summary**

Write `docs/testing/billing-subscription-invoices/green-summary.md` with this content:

```markdown
# 计费、套餐、订阅与发票 GREEN 证据摘要

当前规范和审计证明以下结构已经就位：

- `billingSubscriptionState` 包含 `billingOwnerId`、`billingAccountIdentity`、`subscriptionVersion`、`pricingSnapshot`、`entitlementState`、`usageQuotaState`、`paymentState`、`invoiceState`、`billingChangeIntent`、`riskBinding`、`permissionBoundary`、`auditBinding` 和 `resultReceipt`。
- 计费、套餐、订阅、付款方式、用量额度和发票不能只按普通设置项展示。
- 套餐展示状态、确认状态、支付状态、订阅生效状态、权益生效状态、用量状态、发票产物状态和审计状态分开表达。
- 付款方式保存成功不等于支付成功，支付成功不等于订阅已生效，订阅已生效不等于所有权益、用量额度、发票和审计都已更新。
- 套餐卡、确认页、支付请求、审计记录和结果回执绑定同一个 `pricingSnapshot`。
- 切换套餐、升级、降级、切换月付/年付、应用优惠、购买额度、取消续费或恢复订阅前展示当前套餐、目标套餐、账期、生效时间、权益变化、数据保留、额度变化、费用变化和未知结果处理。
- 旧价格、旧优惠、旧估算、旧套餐卡片和旧确认面板在价格版本、权限、租户/工作区、订阅版本、优惠状态或会话变化后失效或重算。
- `paymentState`、订阅状态、`entitlementState`、`usageQuotaState` 和 `invoiceState` 分开表达。
- 未知结果不会伪装成支付成功、订阅成功、取消成功、降级成功、退款成功、发票已生成或额度已到账。
- 取消订阅、取消自动续费、降级套餐、删除付款方式、申请退款、撤销退款、清空余额、购买大额额度和高影响账期切换进入 `risk-actions.md`；确认前请求数为 0。
- Switch/Toggle 不能直接取消订阅、开启/关闭自动续费、删除付款方式或切换高影响账期。
- 发票、收据、账单明细、对账单、消费记录和税务资料下载执行 `exports-downloads-artifacts.md`，下载链接不是权限证明。
- 旧发票链接、旧收据链接、旧账单导出任务、旧浏览器历史、旧 Notification、旧复制链接和旧 Toast/Notification 在权限变化、会话过期、租户/工作区切换、发票状态变化、退款、作废、重新开票或对象删除后失效或重新证明安全。
- 用量、额度、余额、抵扣、试用剩余额度、超额状态和消费记录声明计量周期、刷新时间、数据延迟、估算/最终状态、单位、权限范围和适用套餐。
- 用量条不能作为实时额度证明；延迟、估算、部分同步失败或未知结果可见。
- 无权限用户不能通过套餐卡、价格、折扣、税费、发票列表、支付错误、用量条、账单历史、DOM/ARIA、Toast、Notification、下载链接或审计摘要推断账单主体、付款方式、金额、税号、地址、邮箱、发票编号、内部 ID、支付 provider 对象或旧缓存。
- Toast、Notification、Snackbar 和浏览器提示不能作为唯一支付失败、支付未知、取消订阅、降级、退款、发票生成失败、发票下载失败、用量同步失败、权限拒绝或部分成功恢复路径。
- 移动端保留当前套餐、目标套餐、金额、币种、账期、税费/折扣摘要、权益变化、用量口径、额度状态、付款方式状态、支付失败恢复、取消/降级影响范围、发票下载、账单历史、审计入口、权限说明和恢复路径。
- 真实浏览器、移动端设备、屏幕阅读器、真实支付 provider、真实支付额外认证、真实发票下载、真实退款/取消/降级任务、真实权限切换、真实会话过期、真实账单同步和真实审计写入检查在本轮文档工作中仍是未验证，需要在具体页面实现时补充。
```

- [ ] **Step 3: Write Ruby audit script**

Create `docs/testing/billing-subscription-invoices/billing-subscription-invoices-audit.rb`. It must:

- read `references/billing-subscription-invoices.md`, `SKILL.md`, `README.md`, `HANDOFF.md`, and both evidence summaries;
- require owner terms including `billingSubscriptionState`, every owner state field, payment and invoice state values, ordinary-setting prohibition, separated state model, pricing snapshot binding, payment/subscription/entitlement separation, risk action routing, confirmation-before-request count 0, Switch/Toggle prohibition, invoice download owner binding, stale invoice invalidation, usage/quota semantics, no-leakage, Toast boundary, mobile recovery, and `未验证`;
- require billing/subscription/invoice route terms in `SKILL.md`;
- require Chinese summary terms in `README.md` and `HANDOFF.md`;
- require evidence terms in RED/GREEN;
- support `--mutations` with deletions for at least:
  - `missing-owner-state`
  - `ordinary-setting-item`
  - `states-merged`
  - `payment-method-as-payment-success`
  - `pricing-snapshot-missing`
  - `plan-change-impact-missing`
  - `stale-price-survives`
  - `payment-state-merged`
  - `unknown-result-as-success`
  - `risk-action-bypassed`
  - `request-before-confirm`
  - `switch-directly-toggles-subscription`
  - `invoice-download-bypasses-export-owner`
  - `stale-invoice-link-survives`
  - `usage-quota-semantics-missing`
  - `usage-bar-as-real-time-proof`
  - `permission-leaks-billing`
  - `toast-only-receipt`
  - `mobile-recovery-removed`
  - `runtime-boundary-marked-verified`
  - `missing-skill-route`

- [ ] **Step 4: Run audit to verify RED failure**

Run:

```bash
ruby docs/testing/billing-subscription-invoices/billing-subscription-invoices-audit.rb --mutations
```

Expected: FAIL before `references/billing-subscription-invoices.md`, route, README, and HANDOFF updates exist. The failure should include missing `references/billing-subscription-invoices.md`.

### Task 2: Implement the owner and route

**Files:**
- Create: `references/billing-subscription-invoices.md`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: audit contract from Task 1 and design spec `docs/superpowers/specs/2026-07-29-billing-subscription-invoices-interaction-standards-design.md`
- Produces: routed owner document and discoverable Chinese summaries

- [ ] **Step 1: Create owner document**

Write `references/billing-subscription-invoices.md` in Chinese. It must include sections:

- `# 计费、套餐、订阅与发票交互规范`
- `## 范围`
- `## Owner State`
- `## Billing 不是普通设置项`
- `## 价格、账期和权益快照`
- `## 支付、订阅和权益状态`
- `## 取消、降级、退款和付款方式`
- `## 发票、收据和账单下载`
- `## 用量、额度和余额`
- `## 权限、审计与反馈不泄露`
- `## 移动端与可访问性`
- `## 完成前检查`

The owner must include the exact audit anchor phrases listed in Task 1 and in the design spec’s “核心规则”.

- [ ] **Step 2: Add SKILL route**

Add one route in `SKILL.md`:

```markdown
- 涉及计费、账单、套餐、订阅、试用、续费、取消订阅、升级套餐、降级套餐、切换套餐、付款方式、支付方式、支付失败、支付成功、发票、收据、账单明细、用量、额度、余额、抵扣、优惠券、折扣、税费、退款、开票、重新开票、账单周期、月付、年付、自动续费、取消续费、账单历史、消费记录，或 billing、bill、invoice、receipt、subscription、plan、pricing、trial、renewal、cancel subscription、upgrade plan、downgrade plan、change plan、payment method、card、payment failed、payment succeeded、usage、quota、credit、balance、coupon、discount、tax、refund、billing cycle、monthly、annual、auto renew、billing history、statement 时，必须完整读取 `references/billing-subscription-invoices.md`。
```

- [ ] **Step 3: Add README and HANDOFF summaries**

Add a Chinese summary to `README.md` and a Chinese handoff note to `HANDOFF.md` mentioning 计费, 套餐, 订阅, 发票, 支付, 用量, 额度, 退款, Toast, and 移动端.

- [ ] **Step 4: Run audit to verify GREEN**

Run:

```bash
ruby docs/testing/billing-subscription-invoices/billing-subscription-invoices-audit.rb --mutations
```

Expected: PASS with every mutation printing `EXPECTED_FAIL`.

### Task 3: Verify adjacent owners and repository integration

**Files:**
- Inspect: `references/billing-subscription-invoices.md`
- Inspect: `SKILL.md`
- Inspect: `README.md`
- Inspect: `HANDOFF.md`
- Inspect: `docs/testing/billing-subscription-invoices/*`

**Interfaces:**
- Consumes: outputs from Tasks 1-2
- Produces: final verification evidence and commit-ready tree

- [ ] **Step 1: Run adjacent audits**

Run:

```bash
ruby docs/testing/settings-preferences-configuration/settings-preferences-configuration-audit.rb --mutations
ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations
ruby docs/testing/exports-downloads-artifacts/exports-downloads-artifacts-audit.rb --mutations
ruby docs/testing/async-jobs-task-center/async-jobs-task-center-audit.rb --mutations
ruby docs/testing/audit-log-activity-history/audit-log-activity-history-audit.rb --mutations
ruby docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb --mutations
ruby docs/testing/data-tables/admin-console-audit.rb --mutations
ruby docs/testing/auth-session-reauth/auth-session-reauth-audit.rb --mutations
ruby docs/testing/global-feedback/global-feedback-audit.rb --mutations
ruby docs/testing/feedback-states/feedback-states-audit.rb --mutations
```

Expected: each audit passes with expected mutation output. If `docs/testing/data-tables/admin-console-audit.rb` does not exist, use `docs/testing/admin-console/admin-console-audit.rb --mutations` as the admin/data-table integration check.

- [ ] **Step 2: Run full audit chain**

Run all existing `docs/testing/*/*-audit.rb` scripts with `--mutations`, including the new billing audit.

Expected: each audit exits 0 and mutation output shows expected failures.

- [ ] **Step 3: Run repository hygiene checks**

Run:

```bash
ruby -e 'files = Dir["README.md", "HANDOFF.md", "SKILL.md", "references/*.md", "docs/**/*.md"]; missing = []; files.each do |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each do |href| next if href =~ /\Ahttps?:/; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" if !File.exist?(target); end; end; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
git diff --check
git status --short
```

Expected: Markdown links resolve, whitespace check exits 0, and only intended files are modified before staging.

- [ ] **Step 4: Commit and push**

Run:

```bash
git add docs/superpowers/plans/2026-07-29-billing-subscription-invoices-interaction-standards.md docs/testing/billing-subscription-invoices/billing-subscription-invoices-audit.rb docs/testing/billing-subscription-invoices/red-summary.md docs/testing/billing-subscription-invoices/green-summary.md references/billing-subscription-invoices.md SKILL.md README.md HANDOFF.md
git commit -m "docs: 新增计费订阅发票规范"
git push origin main
```

Expected: commit and push succeed on `main`.
