# Webhooks Integrations Callbacks Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a dedicated Chinese interaction owner for Webhook endpoints, callback URLs, integrations, connection tests, test deliveries, event subscriptions, signing verification, enable/disable/delete/retry/replay, delivery logs, stale endpoint invalidation, audit safety, and mobile recovery.

**Architecture:** Add one owner document, `references/webhooks-integrations-callbacks.md`, and route it from `SKILL.md`. Add a Ruby static audit and RED/GREEN evidence under `docs/testing/webhooks-integrations-callbacks/`; then update README/HANDOFF summaries so the new owner is discoverable while keeping the full rule set in the owner file.

**Tech Stack:** Markdown reference documentation, Ruby static audit scripts, Git.

## Global Constraints

- Do not define Webhook protocols, signing algorithms, backend delivery systems, queues, retry schedulers, third-party OAuth flows, provider APIs, concrete event schema, payload formats, secret generation algorithms, brand tokens, icons, colors, provider names, or project-specific event names.
- Do not replace `settings-preferences-configuration.md`, `secrets-credentials.md`, `risk-actions.md`, `async-jobs-task-center.md`, `audit-log-activity-history.md`, `permissions-tenancy-visibility.md`, `feedback-states.md`, or `global-feedback.md`; the new owner coordinates with them.
- Webhook endpoint, callback URL, integration, connection config, test delivery, event subscription, event replay, retry delivery, delivery log, callback log, signing verification, and stale endpoint invalidation must be owned by `webhooks-integrations-callbacks.md`.
- Configuration draft, saved configuration, effective configuration, external connection state, event subscription state, delivery state, and audit state must remain distinct.
- Test connection, test delivery, signature verification, and event replay must bind `testDeliveryIntent`; testing may send real requests to external systems and must disclose side effects.
- Enable Webhook, disable Webhook, delete Webhook, reset signing secret, retry delivery, event replay, batch retry, and sensitive log export must enter `risk-actions.md`; confirmation before request count is 0.
- Logs, feedback, and audit summaries must not leak unauthorized URL, payload, header, signature, token, secret, customer data, external objects, internal IDs, or stale cache.
- Runtime browser, mobile device, screen reader, real external endpoint, real test delivery, real retry/replay task, real permission switch, real session expiry, real secret rotation, and real audit write checks must be reported as **未验证** unless actually executed.

---

### Task 1: Write the failing Webhook/integration audit

**Files:**
- Create: `docs/testing/webhooks-integrations-callbacks/webhooks-integrations-callbacks-audit.rb`
- Create: `docs/testing/webhooks-integrations-callbacks/red-summary.md`
- Create: `docs/testing/webhooks-integrations-callbacks/green-summary.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-webhooks-integrations-callbacks-interaction-standards-design.md`
- Produces: executable command `ruby docs/testing/webhooks-integrations-callbacks/webhooks-integrations-callbacks-audit.rb --mutations`

- [ ] **Step 1: Create RED evidence summary**

Write `docs/testing/webhooks-integrations-callbacks/red-summary.md` with this content:

```markdown
# Webhook、集成连接与回调配置 RED 证据摘要

这些负向场景必须被规范和审计识别为失败：

- Webhook、集成连接、回调 URL、事件订阅或投递状态被当成普通设置项展示，没有 `webhookIntegrationState`、配置版本、endpoint 状态或外部连接状态。
- 配置草稿、已保存配置、生效配置、外部连接状态、事件订阅状态、投递状态和审计状态被合并成一个普通 saved 状态。
- 测试成功被写成配置已生效，保存成功被写成外部系统可达，启用成功被写成历史投递已恢复。
- 回调 URL、Endpoint、事件订阅、环境、租户/工作区、provider 或外部系统身份没有绑定 `configurationVersion`、`integrationIdentity` 和 `permissionBoundary`。
- 编辑 endpoint 或事件订阅直接改变生效配置，保存前已经发送真实请求或改变外部连接。
- 旧 endpoint、旧事件订阅、旧签名 secret、旧测试投递、旧日志入口、旧重试任务、旧复制链接或旧 Toast/Notification 在配置版本、权限、会话、租户/工作区、环境或外部连接状态变化后仍可用。
- 测试连接、测试投递、验证签名或事件回放没有绑定 `testDeliveryIntent`、payload 范围、请求身份、权限版本、租户/工作区或审计身份。
- 测试动作没有说明是否会向外部系统发送真实请求、是否使用样例 payload、是否会创建外部记录、是否可重试或是否会出现在回调日志中。
- 确认前请求数为 0 这条约束缺失，导致测试、启停、删除、重试或回放确认前已经发送请求。
- 启用 Webhook、停用 Webhook、删除 Webhook、重置签名 secret、重试投递、事件回放、批量重试或敏感日志导出没有进入 `risk-actions.md`。
- 使用 Switch/Toggle 直接启停 Webhook。
- 投递状态没有区分 `not-tested`、`test-pending`、`test-succeeded`、`test-failed`、`delivery-pending`、`delivery-failed`、`retrying`、`disabled`、`unknown` 和外部系统不可用。
- 未知结果被伪装成保存成功、测试成功、启用成功、删除成功、重试成功或回放成功。
- 回调日志、投递日志、错误明细、Toast、Notification、Banner 或审计摘要泄露无权限 URL、payload、header、签名、token、secret、客户数据、外部系统对象、内部 ID 或旧缓存。
- Toast、Notification、Snackbar 或浏览器提示成为唯一保存回执、测试回执、投递结果、日志入口、任务入口、审计入口、错误说明或恢复路径。
- 移动端、低高度、虚拟键盘、安全区域、系统字体放大、浏览器 Back、WebView 返回或触摸长按后，endpoint 状态、事件订阅摘要、测试连接、测试投递、签名校验说明、启停原因、重试/回放、回调日志、错误明细、任务入口、审计入口、权限说明或恢复路径消失。
- 真实浏览器、移动端设备、屏幕阅读器、真实外部 endpoint、真实测试投递、真实重试/回放任务、真实权限切换、真实会话过期、真实 secret 轮换或真实审计写入没有执行时，没有标为未验证。
```

- [ ] **Step 2: Create GREEN evidence summary**

Write `docs/testing/webhooks-integrations-callbacks/green-summary.md` with this content:

```markdown
# Webhook、集成连接与回调配置 GREEN 证据摘要

当前规范和审计证明以下结构已经就位：

- `webhookIntegrationState` 包含 `integrationOwnerId`、`integrationIdentity`、`configurationVersion`、`endpointState`、`eventSubscriptionState`、`deliveryState`、`secretBinding`、`testDeliveryIntent`、`riskBinding`、`permissionBoundary`、`auditBinding` 和 `resultReceipt`。
- Webhook、集成连接、回调 URL、事件订阅和投递状态不能只按普通设置项展示。
- 配置草稿、已保存配置、生效配置、外部连接状态、事件订阅状态、投递状态和审计状态分开表达。
- 测试成功不等于配置已生效，保存成功不等于外部系统可达，启用成功不等于历史投递已恢复。
- 回调 URL、Endpoint、事件订阅、环境、租户/工作区、provider 和外部系统身份绑定 `configurationVersion`、`integrationIdentity` 和 `permissionBoundary`。
- 编辑 endpoint 或事件订阅只改变草稿；保存前不得改变生效配置。
- 旧 endpoint、旧事件订阅、旧签名 secret、旧测试投递、旧日志入口、旧重试任务、旧复制链接和旧 Toast/Notification 在配置版本、权限、会话、租户/工作区、环境或外部连接状态变化后失效或重算。
- 测试连接、测试投递、验证签名和事件回放绑定 `testDeliveryIntent`、payload 范围、请求身份、权限版本、租户/工作区和审计身份。
- 测试动作说明是否会向外部系统发送真实请求、是否使用样例 payload、是否会创建外部记录、是否可重试、是否会出现在回调日志中。
- 启用 Webhook、停用 Webhook、删除 Webhook、重置签名 secret、重试投递、事件回放、批量重试和敏感日志导出进入 `risk-actions.md`；确认前请求数为 0。
- Switch/Toggle 不能直接启停 Webhook；若保留开关视觉，只能作为打开风险确认承载面的入口。
- 投递状态区分 `not-tested`、`test-pending`、`test-succeeded`、`test-failed`、`delivery-pending`、`delivery-failed`、`retrying`、`disabled`、`unknown` 和外部系统不可用。
- 未知结果不会伪装成保存成功、测试成功、启用成功、删除成功、重试成功或回放成功。
- 回调日志、投递日志、错误明细和审计摘要不泄露无权限 URL、payload、header、签名、token、secret、客户数据、外部系统对象、内部 ID 或旧缓存。
- Toast、Notification、Snackbar 和浏览器提示不能作为唯一保存回执、测试回执、投递结果、日志入口、任务入口、审计入口、错误说明或恢复路径。
- 移动端保留 endpoint 状态、事件订阅摘要、测试连接、测试投递、签名校验说明、启停原因、重试/回放、回调日志、错误明细、任务入口、审计入口、权限说明和恢复路径。
- 真实浏览器、移动端设备、屏幕阅读器、真实外部 endpoint、真实测试投递、真实重试/回放任务、真实权限切换、真实会话过期、真实 secret 轮换和真实审计写入检查在本轮文档工作中仍是未验证，需要在具体页面实现时补充。
```

- [ ] **Step 3: Write Ruby audit script**

Create `docs/testing/webhooks-integrations-callbacks/webhooks-integrations-callbacks-audit.rb`. It must:

- read `references/webhooks-integrations-callbacks.md`, `SKILL.md`, `README.md`, `HANDOFF.md`, and both evidence summaries;
- require owner terms including `webhookIntegrationState`, every owner state field, every delivery state value, ordinary-setting prohibition, separated state model, endpoint/version binding, stale endpoint invalidation, `testDeliveryIntent`, side-effect disclosure, `risk-actions.md`, confirmation-before-request count 0, Switch/Toggle prohibition, unknown-result boundary, no-leakage logs, Toast boundary, mobile recovery, and `未验证`;
- require Webhook/callback/integration route terms in `SKILL.md`;
- require Chinese summary terms in `README.md` and `HANDOFF.md`;
- require evidence terms in RED/GREEN;
- support `--mutations` with deletions for at least:
  - `missing-owner-state`
  - `ordinary-setting-item`
  - `states-merged`
  - `test-success-as-effective`
  - `endpoint-binding-missing`
  - `endpoint-directly-effective`
  - `stale-endpoint-survives`
  - `test-delivery-intent-missing`
  - `test-side-effect-undisclosed`
  - `request-before-confirm`
  - `risk-action-bypassed`
  - `switch-directly-toggles-webhook`
  - `delivery-state-merged`
  - `unknown-result-as-success`
  - `log-leaks-payload`
  - `toast-only-receipt`
  - `mobile-recovery-removed`
  - `runtime-boundary-marked-verified`
  - `missing-skill-route`

- [ ] **Step 4: Run audit to verify RED failure**

Run:

```bash
ruby docs/testing/webhooks-integrations-callbacks/webhooks-integrations-callbacks-audit.rb --mutations
```

Expected: FAIL before `references/webhooks-integrations-callbacks.md`, route, README, and HANDOFF updates exist. The failure should include missing `references/webhooks-integrations-callbacks.md`.

### Task 2: Implement the owner and route

**Files:**
- Create: `references/webhooks-integrations-callbacks.md`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: audit contract from Task 1 and design spec `docs/superpowers/specs/2026-07-29-webhooks-integrations-callbacks-interaction-standards-design.md`
- Produces: routed owner document and discoverable Chinese summaries

- [ ] **Step 1: Create owner document**

Write `references/webhooks-integrations-callbacks.md` in Chinese. It must include sections:

- `# Webhook、集成连接与回调配置交互规范`
- `## 范围`
- `## Owner State`
- `## Webhook 不是普通设置项`
- `## Endpoint 与事件订阅版本边界`
- `## 测试连接、测试投递和签名验证`
- `## 启停、删除、重置 secret、重试和回放`
- `## 投递状态、日志和未知结果`
- `## 审计、权限和反馈不泄露`
- `## 移动端与可访问性`
- `## 完成前检查`

The owner must include the exact audit anchor phrases listed in Task 1 and in the design spec’s “核心规则”.

- [ ] **Step 2: Add SKILL route**

Add one route in `SKILL.md`:

```markdown
- 涉及 Webhook、回调、回调 URL、回调地址、集成、第三方集成、外部集成、连接配置、连接测试、测试连接、测试投递、事件订阅、订阅事件、事件回放、重试投递、投递日志、回调日志、签名密钥、签名校验、Endpoint、外部系统、集成状态、启用 Webhook、停用 Webhook、删除 Webhook，或 webhook、webhooks、callback、callback URL、endpoint、integration、third-party integration、external integration、connection config、connection test、test delivery、event subscription、subscribed events、event replay、retry delivery、delivery log、callback log、signing secret、signature verification、external system、integration status、enable webhook、disable webhook、delete webhook 时，必须完整读取 `references/webhooks-integrations-callbacks.md`。
```

- [ ] **Step 3: Add README and HANDOFF summaries**

Add a Chinese summary to `README.md` and a Chinese handoff note to `HANDOFF.md` mentioning Webhook, 集成连接, 回调配置, 测试投递, 事件订阅, 重试投递, Toast, and 移动端.

- [ ] **Step 4: Run audit to verify GREEN**

Run:

```bash
ruby docs/testing/webhooks-integrations-callbacks/webhooks-integrations-callbacks-audit.rb --mutations
```

Expected: PASS with every mutation printing `EXPECTED_FAIL`.

### Task 3: Verify adjacent owners and repository integration

**Files:**
- Inspect: `references/webhooks-integrations-callbacks.md`
- Inspect: `SKILL.md`
- Inspect: `README.md`
- Inspect: `HANDOFF.md`
- Inspect: `docs/testing/webhooks-integrations-callbacks/*`

**Interfaces:**
- Consumes: outputs from Tasks 1-2
- Produces: final verification evidence and commit-ready tree

- [ ] **Step 1: Run adjacent audits**

Run:

```bash
ruby docs/testing/settings-preferences-configuration/settings-preferences-configuration-audit.rb --mutations
ruby docs/testing/secrets-credentials/secrets-credentials-audit.rb --mutations
ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations
ruby docs/testing/async-jobs-task-center/async-jobs-task-center-audit.rb --mutations
ruby docs/testing/audit-log-activity-history/audit-log-activity-history-audit.rb --mutations
ruby docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb --mutations
ruby docs/testing/global-feedback/global-feedback-audit.rb --mutations
ruby docs/testing/feedback-states/feedback-states-audit.rb --mutations
```

Expected: each audit passes with expected mutation output.

- [ ] **Step 2: Run full audit chain**

Run all existing `docs/testing/*/*-audit.rb` scripts with `--mutations`, including the new Webhook audit.

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
git add docs/superpowers/plans/2026-07-29-webhooks-integrations-callbacks-interaction-standards.md docs/testing/webhooks-integrations-callbacks/webhooks-integrations-callbacks-audit.rb docs/testing/webhooks-integrations-callbacks/red-summary.md docs/testing/webhooks-integrations-callbacks/green-summary.md references/webhooks-integrations-callbacks.md SKILL.md README.md HANDOFF.md
git commit -m "docs: 新增 Webhook 集成回调规范"
git push origin main
```

Expected: commit and push succeed on `main`.
