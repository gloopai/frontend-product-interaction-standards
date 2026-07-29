# Auth Session Reauth Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a dedicated Chinese interaction owner for management-console authentication session, login expiry, reauthentication, MFA/SSO callback, logout, and account/identity switching behavior.

**Architecture:** Add one focused owner document, `references/auth-session-reauth.md`, and route it from `SKILL.md`. Add a static Ruby audit with RED/GREEN evidence under `docs/testing/auth-session-reauth/`, then update README/HANDOFF summaries so the new owner is discoverable without duplicating the full rules.

**Tech Stack:** Markdown reference documentation, Ruby static audit scripts, Git.

## Global Constraints

- Do not define backend authentication protocols, token storage, encryption, MFA provider behavior, or SSO IdP configuration.
- Do not replace `permissions-tenancy-visibility.md`, `navigation-routing.md`, `forms.md`, `risk-actions.md`, `exports-downloads-artifacts.md`, `global-feedback.md`, `feedback-states.md`, `dialogs.md`, `drawers.md`, or `responsive-adaptive.md`; the new owner coordinates with them.
- Authentication state, permission state, tenant/workspace state, object state, form dirty state, request state, and sensitive action intent must remain separately owned and visible.
- Reauthentication must not send sensitive requests before the challenge is complete, and must not auto-execute old sensitive actions after callback unless identity, tenant/workspace, permission version, target state, and idempotency binding still match.
- Session changes must atomically invalidate or recompute old page data, requests, menus, permissions, download links, task entries, confirmations, notifications, focus targets, ARIA references, and unsafe drafts.
- Toast-only authentication failure, bare 401/403, provider-code-only errors, and mobile recovery-path deletion are forbidden.
- Runtime browser, real SSO/MFA provider, touch device, screen reader, WebView/system back, and real network interruption checks must be reported as **未验证** unless actually executed.

---

### Task 1: Write the failing owner audit

**Files:**
- Create: `docs/testing/auth-session-reauth/auth-session-reauth-audit.rb`
- Create: `docs/testing/auth-session-reauth/red-summary.md`
- Create: `docs/testing/auth-session-reauth/green-summary.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-auth-session-reauth-interaction-standards-design.md`
- Produces: executable command `ruby docs/testing/auth-session-reauth/auth-session-reauth-audit.rb --mutations`

- [ ] **Step 1: Create RED and GREEN evidence summaries**

Write `docs/testing/auth-session-reauth/red-summary.md` with these failure cases:

```markdown
# 会话、认证与重新认证 RED 证据摘要

这些负向场景必须被规范和审计识别为失败：

- 登录过期后直接清空页面并跳到登录页，没有安全 `returnContext`、草稿说明、重新登录或返回安全页路径。
- 会话过期、认证失败、权限拒绝、租户不匹配、网络失败和未知结果被合并成一个普通“操作失败”。
- 重新认证被当成普通确认 Dialog；挑战完成前已经发送敏感请求。
- 重新认证完成后自动执行旧敏感动作，而没有重新校验当前用户、租户/工作区、权限版本、目标状态和幂等键。
- SSO/MFA callback 未绑定 `state`、`nonce`、`authOwnerId`、`returnContext`、租户/工作区和过期时间。
- 旧标签页 callback、重复 callback、过期 callback、错误租户 callback 或已退出后的 callback 恢复旧页面或执行旧动作。
- 退出登录、账号切换、身份切换或租户/工作区切换后，旧页面数据、旧菜单、旧按钮、旧权限、旧下载链接、旧任务入口、旧确认面板、旧 Toast/Notification、旧焦点或旧 ARIA 引用仍可用。
- 权限升级、认证过期和租户切换后继续使用旧请求、旧幂等键、旧权限缓存或旧敏感字段。
- 认证失败只用 Toast、裸 401/403、provider 错误码或灰色按钮表达，没有持久、可访问、绑定动作对象的恢复路径。
- 移动端、低高度、虚拟键盘、WebView、系统返回或 SSO/MFA 跳转返回后，重新登录、重新认证、返回安全页、切换租户/工作区、放弃草稿、重试 callback 或查看原因入口消失。
- 真实浏览器、真实 SSO/MFA provider、触摸设备、屏幕阅读器、WebView/system back 或真实网络中断没有执行时，被报告成已验证。
```

Write `docs/testing/auth-session-reauth/green-summary.md` with these required positive behaviors:

```markdown
# 会话、认证与重新认证 GREEN 证据摘要

当前规范和审计证明以下结构已经就位：

- `authSessionState` 包含 `authOwnerId`、`sessionIdentity`、`authLevel`、`sessionStatus`、`reauthIntent`、`reauthReason`、`returnContext`、`sensitiveActionBinding`、`permissionBoundary`、`callbackBinding`、`recoveryPolicy` 和 `resultReceipt`。
- 会话状态、权限状态、租户/工作区状态、对象状态、表单脏状态、请求状态和敏感动作意图分层表达，不合并成笼统 loading/error。
- 登录过期和会话过期先冻结或失效不安全请求，保存允许保留的安全 `returnContext`，清理敏感草稿、旧下载链接、旧任务入口、旧权限菜单和旧确认面板，再提供重新登录或返回安全页路径。
- 重新认证挑战绑定 `reauthIntent`、`sensitiveActionBinding`、权限版本、目标快照、幂等键和 `returnContext`；挑战完成前敏感请求发送数为 0。
- 重新认证完成后只恢复仍匹配当前用户、租户/工作区、权限版本、目标状态和幂等键的动作；不匹配时回到复核或重新确认。
- SSO/MFA callback 验证 `state`、`nonce`、`authOwnerId`、`returnContext`、租户/工作区和过期时间；旧、重复、过期、错误租户和已退出 callback 只能进入安全说明或重新开始。
- 退出登录、账号切换、身份切换、租户/工作区切换和权限版本变化后，旧 UI 状态、请求、菜单、下载、任务、弹层、消息、焦点和 ARIA 引用原子失效或重算。
- 登录失败、会话过期、重新认证取消、重新认证失败、MFA 失败、SSO callback 失败、权限拒绝、租户不匹配、网络失败和未知结果分型呈现。
- Toast 不是认证失败或重新认证恢复的唯一承载；页面、Dialog/Drawer、表单错误摘要、区域 Alert 或安全说明页承载持久可访问恢复路径。
- 移动端不得删除重新登录、重新认证、返回安全页、切换租户/工作区、放弃草稿、重试 callback 和查看原因入口。
- 真实浏览器、真实 SSO/MFA provider、触摸设备、屏幕阅读器、WebView/system back 和真实网络中断检查在本轮文档工作中仍是未验证，需要在具体页面实现时补充。
```

- [ ] **Step 2: Write the Ruby audit script**

Create `docs/testing/auth-session-reauth/auth-session-reauth-audit.rb` with this complete content:

```ruby
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
```

- [ ] **Step 3: Run audit to verify RED failure**

Run:

```bash
ruby docs/testing/auth-session-reauth/auth-session-reauth-audit.rb --mutations
```

Expected: FAIL before the owner, route, README, and HANDOFF updates exist. The failure should include missing `references/auth-session-reauth.md`.

### Task 2: Implement the owner and route

**Files:**
- Create: `references/auth-session-reauth.md`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: audit contract from Task 1 and design spec `docs/superpowers/specs/2026-07-29-auth-session-reauth-interaction-standards-design.md`
- Produces: routed owner document and discoverable Chinese summaries

- [ ] **Step 1: Create `references/auth-session-reauth.md`**

Write the owner in Chinese with these sections:

```markdown
# 会话、认证与重新认证交互规范

适用于登录、登出、退出登录、会话、会话过期、登录过期、认证、认证失败、重新认证、二次认证、多因素认证、MFA、2FA、SSO、单点登录、账号切换、身份切换、授权回调和认证回调。本文件是前端产品交互、认证状态边界、重新认证恢复、callback 绑定、旧会话失效、移动端恢复和验收的唯一事实来源。

本规范不定义后端认证协议、Token 存储、加密方案、MFA 供应商或 SSO IdP 配置。权限解析读取 `permissions-tenancy-visibility.md`，路由返回读取 `navigation-routing.md`，表单失败恢复读取 `forms.md`，敏感动作确认读取 `risk-actions.md`，下载产物领取读取 `exports-downloads-artifacts.md`，反馈通道读取 `global-feedback.md` 和 `feedback-states.md`，挑战承载层读取 `dialogs.md`、`drawers.md` 和 `responsive-adaptive.md`。

## 范围

- 登录、重新登录、退出登录、会话过期、登录过期、认证失败、重新认证、二次认证、MFA、2FA、SSO callback 和外部授权 callback。
- 账号切换、身份切换、租户/工作区切换后与会话身份绑定的旧状态失效。
- 敏感字段查看、重置密钥、敏感导出、权限升级、危险操作和高风险设置保存前的重新认证挑战。
- 认证失败、权限拒绝、租户不匹配、网络失败和未知结果的恢复路径。

## Owner State

| 字段 | 说明 |
| --- | --- |
| `authSessionState` | 当前认证会话 owner 的总状态。 |
| `authOwnerId` | 当前认证 owner 实例身份，用于绑定页面、弹层、请求、callback 和恢复动作。 |
| `sessionIdentity` | 当前用户、账号、组织、租户、工作区、认证时间、认证来源和设备/标签页上下文快照。 |
| `authLevel` | 当前认证强度，例如匿名、已登录、已 MFA、刚完成重新认证。 |
| `sessionStatus` | `authenticated`、`expiring`、`expired`、`reauth-required`、`reauth-in-progress`、`switching-identity`、`signed-out`、`unknown`。 |
| `reauthIntent` | 触发重新认证的明确意图，例如继续保存、查看敏感字段、重置密钥、敏感导出、权限升级或高风险设置保存。 |
| `reauthReason` | 用户可理解的原因；不得只有 401、403、provider error 或内部错误码。 |
| `returnContext` | 重新认证后可恢复的安全路由、表单、筛选、任务、下载或动作上下文。 |
| `sensitiveActionBinding` | 被重新认证保护的敏感动作身份、动作类型、目标快照、权限版本、资源版本和幂等键。 |
| `permissionBoundary` | 与权限 owner 对接的权限版本、租户/工作区、角色、能力和数据范围快照。 |
| `callbackBinding` | SSO/MFA/callback 的 `state`、`nonce`、`authOwnerId`、`returnContext`、租户/工作区和过期时间。 |
| `recoveryPolicy` | 重新登录、重新认证、返回安全页、申请权限、切换租户/工作区、放弃草稿、重试 callback 或联系支持的恢复策略。 |
| `resultReceipt` | 成功、取消、失败、过期、权限拒绝、租户不匹配和未知结果的持久回执或区域反馈。 |

## 状态分层

认证状态、权限状态、租户/工作区状态、对象状态、表单脏状态、请求状态和敏感动作意图必须分层表达。`sessionStatus` 只说明当前会话是否可用于继续承载页面和动作；权限 owner 决定可见性；表单 owner 决定 dirty/touched 和错误；风险 owner 决定敏感动作确认；导航 owner 决定 URL 和返回路径。

登录过期导致保存失败时，不得只显示普通表单错误；权限升级需要重新认证时，不得伪装成无权限、禁用按钮或普通确认；租户不匹配时，不得显示被拒绝资源名称、数量、字段、文件名或内部 ID。

## 登录过期与安全恢复

会话过期、登录过期或 token expired 时，不得直接清空页面并无条件跳到登录页。系统必须先冻结或失效不安全请求，保存允许保留的安全 `returnContext`，清理敏感草稿、旧下载链接、旧任务入口、旧权限菜单和旧确认面板，再提供重新登录、重新认证、返回安全页、申请权限、切换租户/工作区或放弃草稿路径。

允许保留的上下文必须经过安全裁剪：路由可以保留到安全页面或当前对象的安全占位；筛选可以保留不含敏感值的部分；表单草稿只能保留不泄露敏感字段且当前产品允许恢复的字段；下载链接、敏感字段明文、密钥、导出错误明细和旧任务结果默认失效。

## 重新认证与敏感动作绑定

重新认证不是普通确认 Dialog。触发重新认证后，挑战完成前不得发送敏感请求，敏感请求发送数为 0；也不得自动执行旧点击事件、旧提交、旧下载或旧批量动作。挑战必须绑定 `reauthIntent`、`sensitiveActionBinding`、权限版本、目标快照、资源版本、幂等键和 `returnContext`。

重新认证完成后，只能恢复仍然匹配当前用户、租户/工作区、权限版本、目标状态和幂等键的动作。当前用户、租户/工作区、权限版本、对象状态、资源版本、目标快照、幂等键或 returnContext 任一不匹配，都必须回到复核、重新确认、安全说明或重新开始；不得继续旧请求。

## SSO、MFA 与 callback

SSO、MFA、2FA 或外部授权 callback 必须验证 `state`、`nonce`、`authOwnerId`、`returnContext`、租户/工作区和过期时间。旧标签页 callback、重复 callback、过期 callback、错误租户 callback 和已退出后的 callback 都不能恢复旧页面或执行旧动作，只能进入安全说明或重新开始。

callback 失败必须分型展示：用户取消、挑战失败、过期、provider 不可用、网络失败、租户不匹配、权限拒绝和未知结果不得合并。恢复动作必须明确是重新开始 SSO/MFA、返回安全页、切换账号、切换租户/工作区、申请权限还是联系支持。

## 退出登录、账号切换和身份切换

退出登录、账号切换、身份切换、租户/工作区切换和权限版本变化后，旧会话绑定的 UI 状态必须原子失效或重算。失效范围包括页面数据、导航菜单、按钮、表单字段、筛选项、下载链接、任务入口、搜索缓存、图表明细、弹层、Toast、Notification、焦点恢复和 ARIA 引用。

不得先展示旧数据再慢慢刷新成新身份数据。无法立即证明安全的内容先隐藏、失效或替换为安全占位；旧请求、旧幂等键、旧 callback、旧重试、旧防抖、旧下载和旧任务动作必须取消或失效。认证升级也必须重新解析权限和数据范围，不能直接复用升级前旧缓存。

## 错误、反馈和恢复

登录失败、会话过期、重新认证取消、重新认证失败、MFA 失败、SSO callback 失败、权限拒绝、租户不匹配、网络失败和未知结果不得合并成一个“操作失败”。每个失败必须有可见原因、可访问名称、恢复动作对象和 owner。

Toast 不能作为唯一恢复路径。需要用户处理的认证失败必须在页面、安全说明、Dialog/Drawer、表单错误摘要、区域 Alert 或持久通知中呈现；Toast 可以提示状态，但必须指向持久位置或具体恢复入口。裸 401、403、provider error、灰色按钮、锁图标和 hover tooltip 不能是唯一说明。

## 移动端与跨端恢复

移动端不得删除重新登录、重新认证、返回安全页、切换租户/工作区、放弃草稿、重试 callback 和查看原因。低高度、虚拟键盘、WebView、系统返回、浏览器 Back、动态 viewport、四向 safe area、200% 缩放和 SSO/MFA 跳转返回后，这些恢复路径仍必须可达。

移动端可以用 Bottom Sheet、全屏 Drawer 或独立页承载认证挑战，但不能删除标题、原因、账号/租户上下文、错误、取消/返回、帮助和恢复路径。承载层必须执行 Dialog/Drawer/Responsive owner 的遮罩、背景隔离、页面滚动锁、焦点、关闭、动画和 disposal 规则。

## 完成前检查

1. 登录过期时，验证不安全请求冻结或失效，安全 `returnContext` 保留，敏感草稿、旧下载链接、旧任务入口、旧权限菜单和旧确认面板清理，并提供重新登录或返回安全页。
2. 对有 dirty 表单的登录过期，验证可安全保留的草稿保留，不可保留字段说明原因；重新登录后不自动提交旧表单。
3. 对敏感字段查看、重置密钥、敏感导出、权限升级和高风险设置保存触发重新认证，记录挑战完成前敏感请求发送数为 0。
4. 重新认证完成后，分别改变当前用户、租户/工作区、权限版本、目标状态、资源版本、幂等键和 returnContext；验证任一不匹配都回到复核、重新确认或安全说明。
5. 对 SSO/MFA callback，验证 `state`、`nonce`、`authOwnerId`、`returnContext`、租户/工作区和过期时间；旧、重复、过期、错误租户和已退出 callback 不能恢复旧页面或执行旧动作。
6. 退出登录、账号切换、身份切换和租户/工作区切换后，验证页面数据、菜单、按钮、表单字段、筛选项、下载、任务、搜索、图表、弹层、消息、焦点和 ARIA 引用原子失效或重算。
7. 分别构造登录失败、会话过期、重新认证取消、重新认证失败、MFA 失败、SSO callback 失败、权限拒绝、租户不匹配、网络失败和未知结果，验证原因、恢复动作和 owner 不合并。
8. 验证认证失败不是 Toast-only、裸 401/403、provider-code-only、灰色按钮、锁图标或 hover-only；持久恢复入口可见、可聚焦、有可访问名称。
9. 在移动端、低高度、虚拟键盘、WebView、系统返回、浏览器 Back、动态 viewport、四向 safe area 和 200% 缩放下验证恢复路径可达。
10. 真实浏览器、真实 SSO/MFA provider、触摸设备、屏幕阅读器、WebView/system back 和真实网络中断未实际执行时，报告必须标为**未验证**并列明所需环境。
```

- [ ] **Step 2: Add the route in `SKILL.md`**

Insert a new route near the permissions/navigation/risk routes:

```markdown
- 涉及登录、登出、退出登录、会话、会话过期、登录过期、认证、认证失败、重新认证、二次认证、多因素认证、MFA、2FA、SSO、单点登录、账号切换、身份切换、授权回调、认证回调，或 login、logout、sign in、sign out、session、session expired、token expired、authentication、auth failure、reauth、reauthentication、MFA、2FA、SSO、account switch、identity switch、auth callback、authorization callback 时，必须完整读取 `references/auth-session-reauth.md`。
```

- [ ] **Step 3: Update README summary**

In `README.md`, add `会话、认证与重新认证` to the “当前规范” list sentence, add a bullet:

```markdown
- 会话、认证与重新认证规范约束登录过期、重新认证、MFA/SSO callback、退出登录、账号/身份/租户切换、旧状态失效、Toast-only 禁止和移动端恢复路径，避免旧敏感动作、旧下载链接、旧权限缓存或错误 callback 被继续使用。
```

Also add the Markdown link text for `会话、认证与重新认证交互规范` pointing to `references/auth-session-reauth.md` to the complete rules link list.

- [ ] **Step 4: Update HANDOFF summary**

In `HANDOFF.md`, add a section near permissions/navigation/risk:

```markdown
### 会话、认证与重新认证

- 已定义登录、登出、会话过期、登录过期、认证失败、重新认证、二次认证、MFA、SSO callback、账号切换、身份切换和授权回调的 owner。
- 认证状态、权限状态、租户/工作区状态、对象状态、表单脏状态、请求状态和敏感动作意图必须分层表达，不能合并成一个普通 loading/error。
- 登录过期不得直接清空页面并无条件跳登录页；必须冻结或失效不安全请求，保存安全 `returnContext`，清理敏感草稿、旧下载链接、旧任务入口、旧权限菜单和旧确认面板，再提供恢复路径。
- 重新认证不是普通确认 Dialog；挑战完成前敏感请求发送数为 0，完成后只有当前用户、租户/工作区、权限版本、目标状态和幂等键仍匹配时才可恢复动作。
- SSO/MFA callback 必须绑定 `state`、`nonce`、`authOwnerId`、`returnContext`、租户/工作区和过期时间；旧、重复、过期、错误租户和已退出 callback 只能进入安全说明或重新开始。
- 退出登录、账号切换、身份切换和租户/工作区切换后，旧页面数据、菜单、按钮、下载、任务、弹层、消息、焦点和 ARIA 引用原子失效或重算。
- Toast-only、裸 401/403、provider-code-only、灰色按钮、锁图标和 hover-only 都不能作为认证失败或重新认证恢复的唯一说明。
- 移动端不得删除重新登录、重新认证、返回安全页、切换租户/工作区、放弃草稿、重试 callback 和查看原因。
```

- [ ] **Step 5: Run audit to verify GREEN**

Run:

```bash
ruby docs/testing/auth-session-reauth/auth-session-reauth-audit.rb --mutations
```

Expected: all mutation checks print `EXPECTED_FAIL`, then final PASS.

### Task 3: Verify integration and commit

**Files:**
- Inspect: all files modified by Tasks 1-2
- Modify only if checks reveal gaps: `docs/testing/auth-session-reauth/auth-session-reauth-audit.rb`, `references/auth-session-reauth.md`, `SKILL.md`, `README.md`, `HANDOFF.md`

**Interfaces:**
- Consumes: outputs from Tasks 1-2
- Produces: pushed `main` commit containing the new owner

- [ ] **Step 1: Run focused and adjacent audits**

Run:

```bash
ruby docs/testing/auth-session-reauth/auth-session-reauth-audit.rb --mutations
ruby docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb --mutations
ruby docs/testing/navigation-routing/navigation-routing-audit.rb --mutations
ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations
ruby docs/testing/global-feedback/global-feedback-audit.rb --mutations
```

Expected: all commands exit 0.

- [ ] **Step 2: Run the full audit suite**

Run:

```bash
for f in docs/testing/admin-console/admin-console-audit.rb docs/testing/adoption/adoption-audit.rb docs/testing/buttons/buttons-audit.rb docs/testing/charts-visualization/charts-visualization-audit.rb docs/testing/date-time-ranges/date-time-ranges-audit.rb docs/testing/dialog-select-responsive-popup/dialog-select-responsive-popup-audit.rb docs/testing/feedback-states/feedback-states-audit.rb docs/testing/global-feedback/global-feedback-audit.rb docs/testing/information-display/information-display-audit.rb docs/testing/navigation-routing/navigation-routing-audit.rb docs/testing/overlays-menus-tooltips/overlays-menus-tooltips-audit.rb docs/testing/query-filters/query-filters-audit.rb docs/testing/record-editing-surfaces/record-editing-surfaces-audit.rb docs/testing/risk-actions/risk-actions-audit.rb docs/testing/search-command-palette/search-command-palette-audit.rb docs/testing/selection-controls/selection-controls-audit.rb docs/testing/tree-hierarchy/tree-hierarchy-audit.rb docs/testing/uploads-imports/uploads-imports-audit.rb docs/testing/wizards-steppers/wizards-steppers-audit.rb docs/testing/async-jobs-task-center/async-jobs-task-center-audit.rb docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb docs/testing/audit-log-activity-history/audit-log-activity-history-audit.rb docs/testing/status-lifecycle-transitions/status-lifecycle-transitions-audit.rb docs/testing/exports-downloads-artifacts/exports-downloads-artifacts-audit.rb docs/testing/page-toolbars-actions/page-toolbars-actions-audit.rb docs/testing/settings-preferences-configuration/settings-preferences-configuration-audit.rb docs/testing/auth-session-reauth/auth-session-reauth-audit.rb; do ruby "$f" --mutations || exit 1; done
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
git diff -- references/auth-session-reauth.md SKILL.md README.md HANDOFF.md docs/testing/auth-session-reauth/auth-session-reauth-audit.rb docs/testing/auth-session-reauth/green-summary.md docs/testing/auth-session-reauth/red-summary.md
git status --short
```

Expected: only the owner, route, summaries, and audit files are modified or newly added.

Commit:

```bash
git add references/auth-session-reauth.md SKILL.md README.md HANDOFF.md docs/testing/auth-session-reauth/auth-session-reauth-audit.rb docs/testing/auth-session-reauth/green-summary.md docs/testing/auth-session-reauth/red-summary.md
git commit -m "docs: 新增会话认证交互规范"
```

- [ ] **Step 5: Push to main**

Run:

```bash
git status --short --branch
git push origin main
git status --short --branch
git log --oneline -3
```

Expected: branch `main` is aligned with `origin/main`, and latest commit is `docs: 新增会话认证交互规范`.
