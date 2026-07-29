# Secrets Credentials Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a dedicated Chinese interaction owner for API keys, secrets, tokens, credentials, reveal/copy/download behavior, rotation/revocation, old-value invalidation, audit safety, and mobile recovery.

**Architecture:** Add one owner document, `references/secrets-credentials.md`, and route it from `SKILL.md`. Add a Ruby static audit and RED/GREEN evidence under `docs/testing/secrets-credentials/`; then update README/HANDOFF summaries so the new owner is discoverable while keeping the full rule set in the owner file.

**Tech Stack:** Markdown reference documentation, Ruby static audit scripts, Git.

## Global Constraints

- Do not define secret generation algorithms, encryption, hashing, service-side storage, KMS, HSM, Secret Manager, provider APIs, brand visual tokens, icons, colors, or component-library APIs.
- Do not replace `information-display.md`, `risk-actions.md`, `auth-session-reauth.md`, `permissions-tenancy-visibility.md`, `exports-downloads-artifacts.md`, `audit-log-activity-history.md`, `global-feedback.md`, `feedback-states.md`, or `selection-controls.md`; the new owner coordinates with them.
- Secrets, tokens, credentials, API keys, Webhook secrets, Client secrets, service-account credentials, signing keys, one-time secrets, reveal/copy/download credential behavior, rotate/reset/revoke behavior, leak recovery, and old credential invalidation must be owned by `secrets-credentials.md`.
- Real values, masked values, one-time values, copied values, downloaded credential artifacts, old credentials, revoked credentials, expired credentials, leaked credentials, and unknown outcomes must remain distinct.
- Reveal must require explicit user intent and must bind `revealIntent`, `permissionBoundary`, `authBinding`, `credentialVersion`, and an expiry/cleanup policy.
- Copying a real secret must bind `copyIntent`, credential version, permission version, tenant/workspace, authentication strength, and request identity; Toast/Notification must never contain the real value or secret fragments.
- Downloading credential files or snippets must bind `downloadIntent`, credential version, file format, expiry, permission version, authentication strength, request identity, and audit.
- Rotate, reset, revoke, delete, disable, enable, and leak recovery must enter `risk-actions.md`; confirmation before request count is 0.
- Audit records must not contain the real secret, full token, recoverable fragments, download URL, signing material, or clipboard content.
- Runtime browser, system clipboard, mobile device, screen reader, real permission switch, real session expiry, real download, and real rotation task checks must be reported as **未验证** unless actually executed.

---

### Task 1: Write the failing secrets audit

**Files:**
- Create: `docs/testing/secrets-credentials/secrets-credentials-audit.rb`
- Create: `docs/testing/secrets-credentials/red-summary.md`
- Create: `docs/testing/secrets-credentials/green-summary.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-secrets-credentials-interaction-standards-design.md`
- Produces: executable command `ruby docs/testing/secrets-credentials/secrets-credentials-audit.rb --mutations`

- [ ] **Step 1: Create RED evidence summary**

Write `docs/testing/secrets-credentials/red-summary.md` with this content:

```markdown
# 密钥、令牌与敏感凭证 RED 证据摘要

这些负向场景必须被规范和审计识别为失败：

- API Key、Access Token、Webhook Secret、Client Secret、服务账号凭证或签名密钥被当成普通只读字段展示，没有 `secretCredentialState`、凭证版本或暴露策略。
- 创建一次性密钥后没有说明“一旦离开无法再次查看”，也没有安全保存、复制或下载路径。
- 真实密钥在页面加载、hover、展开详情、自动聚焦、复制失败或移动端键盘打开时自动 Reveal。
- Reveal 未绑定 `revealIntent`、`permissionBoundary`、`authBinding`、`credentialVersion` 或过期清理策略。
- 权限变化、会话过期、租户/工作区切换、路由卸载或上层模态关闭后，旧真实值、旧 Reveal 状态、旧复制按钮或旧 ARIA 引用仍可用。
- 复制脱敏值却提示“已复制密钥”，误导用户以为复制了真实值。
- Toast、Notification、Banner、审计摘要或错误信息包含真实密钥、完整 token、可复原片段、下载 URL、签名材料或剪贴板内容。
- 复制成功被当成已安全保存，且没有说明系统剪贴板、截图、录屏、键盘建议或共享设备风险。
- 下载 `.env`、JSON、证书、配置片段或服务账号凭证时缺少 `downloadIntent`、凭证版本、文件格式、有效期、权限版本、认证强度、请求身份或审计绑定。
- 旧下载链接、浏览器历史、Notification、任务入口或复制下载链接在权限变化、会话过期、凭证轮换、撤销、过期或租户切换后仍可用。
- 使用 Switch/Toggle 直接启停密钥，或点击“重置密钥”后直接生成新密钥，没有进入 `risk-actions.md` 复核影响范围。
- Rotate、Reset、Revoke、Delete、Disable、Enable 或泄露恢复确认前已经发送请求。
- 轮换、撤销、权限变化、对象删除、版本冲突或未知结果后，旧真实值、旧复制按钮、旧下载链接、旧 Toast/Notification、旧任务入口或旧审计跳转继续可用。
- 未知结果被伪装成轮换成功或撤销成功，没有检查状态、查看审计、重试或联系支持路径。
- 审计记录包含真实密钥、完整 token、可复原片段、下载 URL、签名材料或剪贴板内容。
- 移动端、低高度、虚拟键盘、安全区域、系统字体放大、浏览器 Back、WebView 返回或系统剪贴板能力变化后，Reveal、复制、下载、轮换、撤销、过期、审计或恢复入口消失。
- 真实浏览器、系统剪贴板、移动端设备、屏幕阅读器、真实权限切换、真实会话过期、真实下载或真实轮换任务没有执行时，没有标为未验证。
```

- [ ] **Step 2: Create GREEN evidence summary**

Write `docs/testing/secrets-credentials/green-summary.md` with this content:

```markdown
# 密钥、令牌与敏感凭证 GREEN 证据摘要

当前规范和审计证明以下结构已经就位：

- `secretCredentialState` 包含 `credentialOwnerId`、`credentialIdentity`、`credentialVersion`、`secretVisibilityState`、`secretValuePolicy`、`revealIntent`、`copyIntent`、`downloadIntent`、`rotationIntent`、`permissionBoundary`、`authBinding`、`auditBinding` 和 `resultReceipt`。
- 真实值、脱敏值、不可再次查看的一次性值、旧版本值、已撤销值、过期值、泄露值和未知状态分型表达。
- 一次性密钥在创建前、创建中和创建后说明“一旦离开无法再次查看”，并提供安全保存、复制或下载路径。
- Reveal 只能由明确用户意图触发，不能由 hover、自动聚焦、页面加载、展开详情、复制失败或移动端键盘打开自动触发。
- Reveal 绑定 `revealIntent`、`permissionBoundary`、`authBinding`、`credentialVersion` 和过期清理策略；权限、会话、租户/工作区、路由或模态变化后真实值立即隐藏或失效。
- 复制真实密钥绑定 `copyIntent`、当前凭证版本、权限版本、租户/工作区、认证强度和请求身份。
- Toast、Notification、Banner、审计摘要和错误信息不包含真实密钥、完整 token、可复原片段、下载 URL、签名材料或剪贴板内容。
- 复制脱敏值不会伪装成已复制真实值；真实值不可复制时说明原因和替代路径。
- 下载凭证绑定 `downloadIntent`、凭证版本、文件格式、有效期、权限版本、认证强度、请求身份和审计。
- 旧下载链接、浏览器历史、Notification、任务入口和复制下载链接在权限变化、会话过期、凭证轮换、撤销、过期或租户切换后失效或重新证明安全。
- Rotate、Reset、Revoke、Delete、Disable、Enable 和泄露恢复进入 `risk-actions.md`；确认前请求数为 0，并展示影响范围、版本、环境、调用方、恢复能力、审计回执和未知结果处理。
- 旧真实值、旧复制按钮、旧 Reveal 状态、旧 Toast/Notification、旧任务入口、旧审计跳转和旧 ARIA 引用在轮换、撤销、权限变化、租户切换、会话过期、对象删除、版本冲突或未知结果后失效或重算。
- 审计绑定存在，但审计记录不包含真实凭证值或可复原材料。
- 移动端保留 Reveal、复制、下载、轮换、撤销、过期、审计和恢复路径，并说明系统剪贴板、截图、录屏、键盘建议或共享设备风险时不包含真实值。
- 真实浏览器、系统剪贴板、移动端设备、屏幕阅读器、真实权限切换、真实会话过期、真实下载和真实轮换任务检查在本轮文档工作中仍是未验证，需要在具体页面实现时补充。
```

- [ ] **Step 3: Write Ruby audit script**

Create `docs/testing/secrets-credentials/secrets-credentials-audit.rb` with this content:

```ruby
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
```

- [ ] **Step 4: Run audit to verify RED failure**

Run:

```bash
ruby docs/testing/secrets-credentials/secrets-credentials-audit.rb --mutations
```

Expected: FAIL before `references/secrets-credentials.md`, route, README, and HANDOFF updates exist. The failure should include missing `references/secrets-credentials.md`.

### Task 2: Implement the owner and route

**Files:**
- Create: `references/secrets-credentials.md`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: audit contract from Task 1 and design spec `docs/superpowers/specs/2026-07-29-secrets-credentials-interaction-standards-design.md`
- Produces: routed owner document and discoverable Chinese summaries

- [ ] **Step 1: Create `references/secrets-credentials.md`**

Write the owner in Chinese with these exact sections:

```markdown
# 密钥、令牌与敏感凭证交互规范

适用于密钥、令牌、凭证、API Key、访问令牌、Refresh Token、Webhook Secret、Client Secret、集成凭证、服务账号、签名密钥、一次性密钥、显示密钥、Reveal、复制密钥、下载凭证、轮换密钥、重置密钥、撤销密钥和泄露恢复。本文件是前端产品交互、真实值暴露窗口、Reveal、复制、下载、轮换、撤销、旧值失效、审计不泄露、移动端恢复和验收的唯一事实来源。

本规范不定义密钥生成算法、加密方案、哈希策略、服务端存储、KMS、HSM、Secret Manager、provider API、品牌视觉 token、图标、颜色或组件库 API。普通详情字段读取 `information-display.md`；风险动作读取 `risk-actions.md`；重新认证读取 `auth-session-reauth.md`; 权限解析读取 `permissions-tenancy-visibility.md`；下载产物读取 `exports-downloads-artifacts.md`；审计证据读取 `audit-log-activity-history.md`；反馈通道读取 `global-feedback.md` 和 `feedback-states.md`；Switch/Toggle 入口读取 `selection-controls.md`。

## 范围

- API Key、Access Token、Refresh Token、Webhook Secret、OAuth Client Secret、集成凭证、下载凭证、一次性密钥、签名密钥、服务账号凭证和配置片段。
- 生成、一次性展示、Reveal、复制、下载、轮换、重置、撤销、删除、停用、启用、过期、泄露恢复和审计。
- 权限变化、会话过期、租户/工作区切换、凭证轮换、撤销、过期、对象删除、版本冲突和未知结果后的旧状态失效。

## Owner State

| 字段 | 说明 |
| --- | --- |
| `secretCredentialState` | 当前密钥、令牌与敏感凭证 owner 的总状态。 |
| `credentialOwnerId` | 当前凭证 owner 实例身份，用于绑定页面、弹层、请求、Reveal、复制、下载、轮换和审计。 |
| `credentialIdentity` | 凭证稳定身份、类型、所属对象、租户/工作区、环境、用途、作用域和归属系统。 |
| `credentialVersion` | 当前凭证版本、轮换代次、创建时间、过期时间、撤销时间和泄露恢复代次。 |
| `secretVisibilityState` | `masked`、`reveal-requested`、`revealed`、`reveal-expired`、`copy-ready`、`copied`、`download-ready`、`downloaded`、`revoked`、`rotating`、`unknown`。 |
| `secretValuePolicy` | 是否一次性可见、是否允许再次 Reveal、是否允许复制、是否允许下载、是否允许局部显示、是否需要重新认证。 |
| `revealIntent` | Reveal 的触发来源、原因、权限版本、认证强度、凭证版本和过期策略。 |
| `copyIntent` | 复制动作的目标字段、格式、权限版本、租户/工作区、认证强度、剪贴板策略和回执。 |
| `downloadIntent` | 下载 `.env`、JSON、证书、配置片段或服务账号凭证的范围、格式、有效期、权限复核和审计绑定。 |
| `rotationIntent` | Rotate、Reset、Revoke、Delete、Disable、Enable 或泄露恢复的动作类型、影响范围、回滚/恢复策略和风险 owner 绑定。 |
| `permissionBoundary` | 查看、Reveal、复制、下载、轮换、撤销和审计所需的权限版本、租户/工作区和数据范围。 |
| `authBinding` | 是否需要重新认证、当前认证强度、`authOwnerId` 和挑战结果。 |
| `auditBinding` | Reveal、复制、下载、轮换、撤销、失败、取消和未知结果的审计身份。 |
| `resultReceipt` | 成功、取消、失败、部分完成、未知、过期、权限拒绝和泄露恢复的持久回执。 |

## 密钥不是普通只读字段

密钥、令牌和敏感凭证不能只按普通详情字段展示。真实值、脱敏值、不可再次查看的一次性值、旧版本值、已撤销值、过期值、泄露值和未知状态必须明确区分。默认展示应为脱敏或安全占位。

若凭证只在创建时显示一次，页面必须在创建前、创建中和创建后明确说明“一旦离开无法再次查看”的语义，并提供安全保存、复制或下载路径。离开页面、关闭 Dialog/Drawer、刷新、路由变化或会话变化后，真实值默认不可再次恢复。

## Reveal

Reveal 真实值必须由明确用户意图触发，不能在 hover、自动聚焦、页面加载、展开详情、复制失败或移动端键盘打开时自动 Reveal。Reveal 必须绑定 `revealIntent`、`permissionBoundary`、`authBinding`、`credentialVersion` 和过期策略。

Reveal 后必须有可见过期、重新隐藏或离开清理规则。权限变化、会话过期、租户/工作区切换、路由卸载、上层模态关闭、凭证轮换、撤销、过期或对象删除时，真实值必须立即隐藏或失效，并清理旧 ARIA 引用、焦点任务、复制入口和回执。

## 复制

复制真实密钥必须绑定 `copyIntent`、当前凭证版本、权限版本、租户/工作区、认证强度和请求身份。复制成功可以用短反馈，但不能泄露真实值，不能在 Toast/Notification 中包含密钥片段，不能把复制成功当成已安全保存。

复制失败必须说明原因和替代路径，不能静默失败。复制脱敏值不得误导用户以为复制了真实值；如果真实值不可复制，按钮必须说明原因。需要提醒系统剪贴板、截图、录屏、键盘建议或共享设备风险时，说明必须持久、可访问且不包含真实值。

## 下载凭证

下载 `.env`、JSON、证书、配置片段、客户端密钥或服务账号凭证时，不得复用普通导出下载规则而缺少凭证语义。下载必须绑定 `downloadIntent`、凭证版本、文件格式、有效期、权限版本、认证强度、请求身份和审计。

旧下载链接、浏览器历史、Notification、任务入口和复制下载链接必须在权限变化、会话过期、凭证轮换、撤销、过期或租户切换后失效或重新证明安全。下载失败、过期、无权限、未知结果和泄露恢复必须有持久恢复路径。

## Rotate / Reset / Revoke

轮换、重置、撤销、删除、停用、启用或泄露恢复必须进入 `risk-actions.md`。确认前请求数为 0；确认面板必须显示影响范围、当前版本、目标版本、受影响环境、调用方、回滚/恢复能力、审计回执和未知结果处理。

不得用 Switch 直接启停密钥，不得点击“重置”后直接生成新密钥而无复核。若产品保留开关视觉，它只能作为打开风险确认承载面的入口；确认完成前旧 `committed` 状态不变。

## 旧值、未知结果和泄露恢复

密钥轮换、撤销、权限变化、租户/工作区切换、会话过期、对象删除、版本冲突或未知结果后，旧真实值、旧复制按钮、旧下载链接、旧 Reveal 状态、旧 Toast/Notification、旧任务入口、旧审计跳转和旧 ARIA 引用必须失效或重算。

未知结果不能伪装成轮换成功或撤销成功；必须提供检查状态、查看审计、重试或联系支持路径。泄露恢复必须说明当前凭证状态、建议动作、影响范围、轮换进度、旧凭证失效时间和恢复结果。

## 审计不泄露

Reveal、复制、下载、轮换、撤销、失败、取消和未知结果都需要审计绑定，但审计记录不得包含真实密钥、完整 token、可复原片段、下载 URL、签名材料或剪贴板内容。审计可记录动作、主体、目标、权限版本、凭证版本、时间、结果、IP/设备等允许字段；无权限审计仍不能泄露凭证名称、作用域、环境或存在性。

## 移动端与可访问性

移动端不得删除 Reveal、复制、下载、轮换、撤销、过期、审计和恢复路径。低高度、虚拟键盘、安全区域、系统字体放大、浏览器 Back、WebView 返回和系统分享/剪贴板能力变化后，真实值不得被固定底部、键盘、Toast 或系统浮层遮挡。

真实值、脱敏值、一次性显示、过期、复制成功、复制失败、下载过期、权限拒绝、未知结果和泄露恢复都必须有可访问名称或描述。不得只用颜色、锁图标、Tooltip、Toast 或 disabled 按钮表达。

## 完成前检查

1. 创建一次性密钥，验证创建前、创建中和创建后都说明“一旦离开无法再次查看”，并提供安全保存、复制或下载路径。
2. 对普通详情页字段，验证密钥不会按普通只读字段直接展示；真实值、脱敏值、旧版本、已撤销、过期、泄露和未知状态可区分。
3. 触发 Reveal，记录 `revealIntent`、`permissionBoundary`、`authBinding`、`credentialVersion` 和过期策略；确认 hover、自动聚焦、页面加载、展开详情、复制失败和移动端键盘打开不会自动 Reveal。
4. Reveal 后分别触发权限变化、会话过期、租户/工作区切换、路由卸载、上层模态关闭、凭证轮换、撤销、过期和对象删除；确认真实值、旧复制按钮、旧 ARIA 引用和回执失效。
5. 复制真实密钥，验证 `copyIntent`、凭证版本、权限版本、租户/工作区、认证强度和请求身份匹配；Toast/Notification 不包含真实值或片段。
6. 复制脱敏值和不可复制真实值，验证不会误导用户以为复制了真实值，并提供原因或替代路径。
7. 下载凭证文件，验证 `downloadIntent`、凭证版本、文件格式、有效期、权限版本、认证强度、请求身份和审计绑定。
8. 在权限变化、会话过期、凭证轮换、撤销、过期和租户切换后，验证旧下载链接、浏览器历史、Notification、任务入口和复制下载链接失效或重新证明安全。
9. 执行 Rotate、Reset、Revoke、Delete、Disable、Enable 和泄露恢复，验证进入 `risk-actions.md`，确认前请求数为 0，并显示影响范围、版本、环境、调用方、恢复能力、审计回执和未知结果处理。
10. 制造未知结果，验证不伪装成成功或失败，并提供检查状态、查看审计、重试或联系支持路径。
11. 检查审计记录，验证不包含真实密钥、完整 token、可复原片段、下载 URL、签名材料或剪贴板内容。
12. 在移动端、低高度、虚拟键盘、安全区域、系统字体放大、浏览器 Back、WebView 返回和系统剪贴板能力变化下，验证 Reveal、复制、下载、轮换、撤销、过期、审计和恢复路径可达。
13. 真实浏览器、系统剪贴板、移动端设备、屏幕阅读器、真实权限切换、真实会话过期、真实下载和真实轮换任务未实际执行时，报告必须标为**未验证**并列明所需环境。
```

- [ ] **Step 2: Add the route in `SKILL.md`**

Insert the route near information display, auth, risk, or permissions:

```markdown
- 涉及密钥、令牌、凭证、API Key、访问令牌、Webhook Secret、Client Secret、集成凭证、服务账号、签名密钥、一次性密钥、显示密钥、Reveal、复制密钥、下载凭证、轮换密钥、重置密钥、撤销密钥、泄露恢复，或 secret、secrets、credential、credentials、API key、access token、refresh token、webhook secret、client secret、integration credential、service account、signing key、one-time secret、reveal secret、copy secret、download credential、rotate key、reset key、revoke key、leak recovery 时，必须完整读取 `references/secrets-credentials.md`。
```

- [ ] **Step 3: Update README summary**

In `README.md`, add `密钥、令牌与敏感凭证` to the “当前规范” list sentence, add this bullet near information display/risk/auth summaries:

```markdown
- 密钥、令牌与敏感凭证规范约束 API Key、Token、Webhook Secret、Client Secret、服务账号凭证的生成后一次性展示、Reveal、复制、下载、轮换、撤销、旧值失效、审计不泄露、系统剪贴板风险和移动端恢复路径。
```

Also add a Markdown link for `密钥、令牌与敏感凭证交互规范` pointing to `references/secrets-credentials.md` in the complete rules link list.

- [ ] **Step 4: Update HANDOFF summary**

In `HANDOFF.md`, add this section near information display/risk/auth:

```markdown
### 密钥、令牌与敏感凭证

- 已定义 API Key、Access Token、Webhook Secret、Client Secret、集成凭证、服务账号、签名密钥、一次性密钥、Reveal、复制、下载、轮换、重置、撤销和泄露恢复的 owner。
- 密钥不是普通只读字段；真实值、脱敏值、一次性值、旧版本、已撤销、过期、泄露和未知状态必须区分。
- 一次性密钥必须在创建前、创建中和创建后说明“一旦离开无法再次查看”，并提供安全保存、复制或下载路径。
- Reveal 必须由明确用户意图触发，绑定 `revealIntent`、`permissionBoundary`、`authBinding`、`credentialVersion` 和过期清理策略；hover、自动聚焦、页面加载、展开详情、复制失败或移动端键盘打开不得自动 Reveal。
- 复制真实密钥必须绑定 `copyIntent`、凭证版本、权限版本、租户/工作区、认证强度和请求身份；Toast/Notification 不得包含真实值或片段。
- 下载凭证必须绑定 `downloadIntent`、凭证版本、文件格式、有效期、权限版本、认证强度、请求身份和审计；旧下载链接在权限、会话、租户、轮换、撤销或过期后失效。
- Rotate、Reset、Revoke、Delete、Disable、Enable 和泄露恢复必须进入 `risk-actions.md`；确认前请求数为 0，不能用 Switch 直接启停密钥。
- 审计记录不得包含真实密钥、完整 token、可复原片段、下载 URL、签名材料或剪贴板内容。
- 移动端不得删除 Reveal、复制、下载、轮换、撤销、过期、审计和恢复路径。
- 详细规则和可执行验收仅维护在 `references/secrets-credentials.md`，本交接不重复其状态模型或检查项。
```

- [ ] **Step 5: Run audit to verify GREEN**

Run:

```bash
ruby docs/testing/secrets-credentials/secrets-credentials-audit.rb --mutations
```

Expected: all mutation checks print `EXPECTED_FAIL`, then final PASS.

### Task 3: Verify integration and commit

**Files:**
- Inspect: all files modified by Tasks 1-2
- Modify only if checks reveal gaps: `docs/testing/secrets-credentials/secrets-credentials-audit.rb`, `references/secrets-credentials.md`, `SKILL.md`, `README.md`, `HANDOFF.md`

**Interfaces:**
- Consumes: outputs from Tasks 1-2
- Produces: pushed `main` commit containing the new owner

- [ ] **Step 1: Run focused and adjacent audits**

Run:

```bash
ruby docs/testing/secrets-credentials/secrets-credentials-audit.rb --mutations
ruby docs/testing/information-display/information-display-audit.rb --mutations
ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations
ruby docs/testing/auth-session-reauth/auth-session-reauth-audit.rb --mutations
ruby docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb --mutations
ruby docs/testing/exports-downloads-artifacts/exports-downloads-artifacts-audit.rb --mutations
ruby docs/testing/audit-log-activity-history/audit-log-activity-history-audit.rb --mutations
```

Expected: all commands exit 0.

- [ ] **Step 2: Run the full audit suite**

Run:

```bash
for f in docs/testing/admin-console/admin-console-audit.rb docs/testing/adoption/adoption-audit.rb docs/testing/buttons/buttons-audit.rb docs/testing/charts-visualization/charts-visualization-audit.rb docs/testing/date-time-ranges/date-time-ranges-audit.rb docs/testing/dialog-select-responsive-popup/dialog-select-responsive-popup-audit.rb docs/testing/feedback-states/feedback-states-audit.rb docs/testing/global-feedback/global-feedback-audit.rb docs/testing/information-display/information-display-audit.rb docs/testing/navigation-routing/navigation-routing-audit.rb docs/testing/overlays-menus-tooltips/overlays-menus-tooltips-audit.rb docs/testing/query-filters/query-filters-audit.rb docs/testing/record-editing-surfaces/record-editing-surfaces-audit.rb docs/testing/risk-actions/risk-actions-audit.rb docs/testing/search-command-palette/search-command-palette-audit.rb docs/testing/selection-controls/selection-controls-audit.rb docs/testing/tree-hierarchy/tree-hierarchy-audit.rb docs/testing/uploads-imports/uploads-imports-audit.rb docs/testing/wizards-steppers/wizards-steppers-audit.rb docs/testing/async-jobs-task-center/async-jobs-task-center-audit.rb docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb docs/testing/audit-log-activity-history/audit-log-activity-history-audit.rb docs/testing/status-lifecycle-transitions/status-lifecycle-transitions-audit.rb docs/testing/exports-downloads-artifacts/exports-downloads-artifacts-audit.rb docs/testing/page-toolbars-actions/page-toolbars-actions-audit.rb docs/testing/settings-preferences-configuration/settings-preferences-configuration-audit.rb docs/testing/auth-session-reauth/auth-session-reauth-audit.rb docs/testing/secrets-credentials/secrets-credentials-audit.rb; do ruby "$f" --mutations || exit 1; done
```

Expected: all commands exit 0.

- [ ] **Step 3: Run Markdown link and diff checks**

Run:

```bash
ruby -e 'files = Dir["README.md", "HANDOFF.md", "SKILL.md", "references/*.md", "docs/**/*.md"]; missing = []; files.each do |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each do |href| next if href =~ /\Ahttps?:/; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target); end; end; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
git diff --check
```

Expected: both commands exit 0.

- [ ] **Step 4: Review diff and commit**

Run:

```bash
git diff -- references/secrets-credentials.md SKILL.md README.md HANDOFF.md docs/testing/secrets-credentials/secrets-credentials-audit.rb docs/testing/secrets-credentials/green-summary.md docs/testing/secrets-credentials/red-summary.md
git status --short
```

Expected: only the owner, route, summaries, and audit files are modified or newly added.

Commit:

```bash
git add references/secrets-credentials.md SKILL.md README.md HANDOFF.md docs/testing/secrets-credentials/secrets-credentials-audit.rb docs/testing/secrets-credentials/green-summary.md docs/testing/secrets-credentials/red-summary.md
git commit -m "docs: 新增密钥凭证交互规范"
```

- [ ] **Step 5: Push to main**

Run:

```bash
git status --short --branch
git push origin main
git status --short --branch
git log --oneline -3
```

Expected: branch `main` is aligned with `origin/main`, and latest commit is `docs: 新增密钥凭证交互规范`.
