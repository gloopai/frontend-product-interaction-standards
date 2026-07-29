# 会话、认证与重新认证交互规范设计

## 背景

管理台里“认证”经常被当成后端或网关问题，但前端交互一旦处理不好，风险会非常直接：登录过期后丢失表单上下文、重新认证后自动执行旧危险操作、权限升级复用旧缓存、SSO callback 回到错误租户、MFA 失败只弹 Toast、退出登录后旧下载链接仍可点。这类问题目前分散在权限、导航、表单、风险操作、导出和全局反馈规范里，没有一个 owner 负责“当前身份会话是否还能安全承载当前界面和动作”。

本设计新增“会话、认证与重新认证” owner。它不规定密码、OAuth、OIDC、Token、Cookie、MFA、SSO 的后端协议，也不规定具体安全算法；它只定义前端产品交互、状态边界、恢复路径、可访问反馈和验收规则。

## 目标

- 明确登录、退出登录、会话过期、登录过期、认证失败、重新认证、二次认证、MFA、SSO callback、账号切换、身份切换的前端 owner。
- 规定认证状态、权限状态、租户/工作区状态、表单脏状态和危险操作意图不能被合并成一个笼统 loading/error。
- 保证会话变化后旧页面、旧请求、旧菜单、旧权限、旧下载、旧任务入口、旧确认面板和旧草稿都安全失效或重算。
- 保证重新认证只恢复被证明安全的上下文，不自动执行旧敏感动作。
- 保证移动端、低高度、虚拟键盘、系统返回和 SSO/MFA 跳转后仍有明确恢复路径。

## 非目标

- 不定义后端鉴权协议、Token 存储策略、加密方案、MFA 供应商或 SSO IdP 配置。
- 不代替 `permissions-tenancy-visibility.md` 的权限解析、能力矩阵、租户/工作区可见性规则。
- 不代替 `risk-actions.md` 的危险操作分级、输入确认、撤销和审计回执。
- 不代替 `navigation-routing.md` 的路由返回、面包屑、Tabs、离开保护和 URL 恢复。
- 不代替 `forms.md` 的字段状态、dirty/touched、提交快照和服务端错误归属。

## Owner 边界

新增文件：`references/auth-session-reauth.md`。

建议路由关键词：

- 中文：登录、登出、退出登录、会话、会话过期、登录过期、认证、认证失败、重新认证、二次认证、多因素认证、MFA、2FA、SSO、单点登录、账号切换、身份切换、授权回调、认证回调。
- 英文：login、logout、sign in、sign out、session、session expired、token expired、authentication、auth failure、reauth、reauthentication、MFA、2FA、SSO、account switch、identity switch、auth callback、authorization callback。

该 owner 维护 `authSessionState`，至少包含：

| 字段 | 说明 |
| --- | --- |
| `authOwnerId` | 当前认证 owner 实例身份，用于绑定页面、弹层、请求和 callback。 |
| `sessionIdentity` | 当前用户、账号、组织、租户、工作区、认证时间和认证来源快照。 |
| `authLevel` | 当前认证强度，例如匿名、已登录、已 MFA、刚完成重新认证。 |
| `sessionStatus` | `authenticated`、`expiring`、`expired`、`reauth-required`、`reauth-in-progress`、`switching-identity`、`signed-out`、`unknown`。 |
| `reauthIntent` | 触发重新认证的明确意图，例如继续保存、查看敏感字段、重置密钥、敏感导出或权限升级。 |
| `reauthReason` | 用户可理解的原因，不能只有 401、403 或 provider 错误码。 |
| `returnContext` | 重新认证后可恢复的安全路由、表单、筛选、任务或动作上下文。 |
| `sensitiveActionBinding` | 被重新认证保护的敏感动作身份、目标快照、权限版本和幂等键。 |
| `permissionBoundary` | 与权限 owner 对接的权限版本、租户/工作区和能力快照。 |
| `callbackBinding` | SSO/MFA/callback 的 state、nonce、owner、returnContext 和过期策略。 |
| `recoveryPolicy` | 重新登录、重新认证、返回安全页、申请权限、切换租户或放弃草稿的恢复策略。 |
| `resultReceipt` | 成功、取消、失败、过期、权限拒绝、未知结果的持久回执或区域反馈。 |

## 核心交互规则

### 会话状态不能吞并其他状态

认证状态、权限状态、租户/工作区状态、对象状态、表单脏状态和请求状态必须分层表达。比如“登录过期导致保存失败”不能只显示一个普通表单错误；“权限升级需要重新认证”也不能伪装成无权限或禁用按钮。每个状态都要有 owner、原因、恢复动作和可访问名称。

### 登录过期必须安全恢复

会话过期时，不得直接清空页面并无条件跳到登录页。系统必须先冻结或失效不安全请求，保存允许保留的 `returnContext`，清理敏感草稿、旧下载链接、旧任务入口、旧权限菜单和旧确认面板，再提供重新登录或返回安全页路径。若当前表单有未保存内容，必须和表单/导航 owner 协作：能安全保留的草稿保留，不能保留的字段说明原因。

### 重新认证不是普通确认 Dialog

重新认证用于证明当前操作者仍具备执行某个敏感动作的资格。触发重新认证后，在挑战完成前不得发送敏感请求，也不得自动执行旧点击事件。挑战必须绑定 `reauthIntent`、`sensitiveActionBinding`、权限版本、目标快照和 returnContext。重新认证完成后，只能恢复仍然匹配当前用户、租户/工作区、权限版本、目标状态和幂等键的动作；任何一项变化都必须回到复核或重新确认。

### SSO/MFA callback 必须绑定上下文

SSO、MFA、2FA 或外部授权 callback 必须验证 `state`、`nonce`、`authOwnerId`、`returnContext`、租户/工作区和过期时间。过期 callback、重复 callback、旧标签页 callback、错误租户 callback 和已退出后的 callback 都不能恢复旧页面或执行旧动作，只能进入安全说明或重新开始。

### 账号/身份/租户切换必须原子失效

退出登录、账号切换、身份切换、租户/工作区切换和权限版本变化后，旧会话绑定的 UI 状态必须原子失效或重算，包括页面数据、导航菜单、按钮、表单字段、筛选项、下载链接、任务入口、搜索缓存、图表明细、弹层、Toast、Notification、焦点恢复和 ARIA 引用。不能先展示旧数据再慢慢刷新成新数据。

### 错误和结果必须分型

登录失败、会话过期、重新认证取消、重新认证失败、MFA 失败、SSO callback 失败、权限拒绝、租户不匹配、网络失败和未知结果不得合并成一个“操作失败”。Toast 不能作为唯一恢复路径；页面、Dialog/Drawer、表单错误摘要、区域 Alert 或安全说明页必须承载持久、可访问的原因和动作。

### 移动端不能删除认证恢复能力

移动端、低高度、虚拟键盘、WebView、系统返回、浏览器 Back 和 SSO/MFA 跳转返回后，重新登录、重新认证、返回安全页、切换租户/工作区、放弃草稿、重试 callback 和查看原因都必须可达。移动端可以用 Bottom Sheet、全屏 Drawer 或独立页承载挑战，但不能删除标题、原因、账号/租户上下文、错误、取消/返回、帮助和恢复路径。

## 与其他 owner 的关系

- `permissions-tenancy-visibility.md`：认证状态变化会触发权限重算；权限 owner 负责可见性，认证 owner 负责会话身份和重新认证边界。
- `navigation-routing.md`：认证 owner 提供安全 `returnContext`；导航 owner 负责返回策略、URL 恢复和离开保护。
- `forms.md`：认证失败后表单 owner 保留值、dirty/touched 和错误归属；认证 owner 负责重新认证或重新登录路径。
- `risk-actions.md`：敏感操作需要重新认证时，风险 owner 负责影响范围和确认；认证 owner 负责挑战、绑定和挑战后的动作恢复条件。
- `exports-downloads-artifacts.md`：下载链接和结果产物必须绑定会话、权限版本和有效期；认证 owner 负责登录过期和重新认证恢复。
- `global-feedback.md` / `feedback-states.md`：认证失败不能 Toast-only；反馈 owner 负责消息通道，认证 owner 负责原因和恢复动作对象。
- `dialogs.md` / `drawers.md` / `responsive-adaptive.md`：重新认证挑战的承载层遵守对应模态、焦点、滚动、关闭和移动端规则。

## 验收策略

新增静态审计 `docs/testing/auth-session-reauth/auth-session-reauth-audit.rb`，检查：

- `SKILL.md` 有认证/会话/重新认证路由。
- `references/auth-session-reauth.md` 存在并包含 owner state、状态枚举、恢复策略和硬性红线。
- README / HANDOFF 有中文摘要。
- RED/GREEN 证据覆盖登录过期直接跳登录、重新认证后自动执行旧敏感动作、SSO callback 未绑定 state/nonce、账号切换保留旧缓存、Toast-only 认证失败、移动端删除恢复路径等负例。
- mutation 模式删除任一关键规则会失败。

运行时真实浏览器、真实 SSO/MFA provider、触摸设备、屏幕阅读器和真实网络中断未执行时，必须标为**未验证**，不能把静态审计写成运行时通过。

## 设计取舍

推荐新增独立 owner，而不是把规则继续分散到权限、导航和风险规范中。原因是认证状态是横切边界：它会同时影响权限、路由、表单、导出、任务、反馈和危险动作。如果没有单独 owner，项目实现很容易把“401、403、重新登录、重新认证、权限升级、租户切换”混成一个错误处理分支。独立 owner 能把会话身份、挑战意图、returnContext 和旧状态失效责任钉住，再由其他 owner 各管自己的局部语义。
