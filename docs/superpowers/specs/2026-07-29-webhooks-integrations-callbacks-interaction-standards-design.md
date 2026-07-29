# Webhook、集成连接与回调配置交互规范设计

## 背景

管理台常见 Webhook、第三方集成、回调 URL、事件订阅、连接测试、签名密钥、重试策略、启停开关和投递日志。它们经常被做成普通设置页：一个 URL 输入框、几个 Checkbox、一个“保存”、一个“测试发送”、一个 Switch。这个做法很容易出问题：测试投递可能真的触发外部系统；事件订阅草稿可能被误认为已生效；旧 URL 或旧签名 secret 在保存失败、权限切换、租户切换后继续可用；失败日志可能泄露 payload、header、token 或客户数据；Webhook 被 Switch 直接停用/启用但没有影响范围确认；移动端把重试、日志、恢复、禁用原因藏没了。

现有规范已覆盖一部分边界：

- `settings-preferences-configuration.md` 负责普通设置页、草稿/保存/生效值和配置作用域。
- `secrets-credentials.md` 负责 Webhook Secret、Client Secret、API Key、Reveal、复制、轮换和审计不泄露。
- `risk-actions.md` 负责启停、删除、重置、重试、敏感导出等风险确认和未知结果。
- `async-jobs-task-center.md` 负责后台投递任务、重试任务、任务中心恢复和未知结果。
- `audit-log-activity-history.md` 负责审计证据、回执和无权限审计不泄露。
- `permissions-tenancy-visibility.md` 负责权限、租户/工作区、旧入口失效和无泄露。
- `feedback-states.md` / `global-feedback.md` 负责错误、部分成功、Toast 边界和恢复入口。

缺口是：没有 owner 负责“外部连接配置 + 事件订阅 + 投递/回调状态 + 旧 endpoint/secret 失效”。这会导致项目只按普通设置保存，忽略真实外部副作用和回调证据。

## 目标

- 新增“Webhook、集成连接与回调配置” owner，覆盖 Webhook endpoint、回调 URL、事件订阅、签名校验、连接测试、测试投递、启用/停用、删除、重试、回放、回调日志、集成状态和恢复路径。
- 明确配置草稿、已保存配置、生效配置、外部系统连接状态、事件订阅状态、投递状态和审计状态的区别。
- 规定保存、测试、启停、删除、重置 secret、重试投递和回放事件的权限、租户/工作区、配置版本、请求身份、风险确认和审计绑定。
- 规定旧 endpoint、旧事件订阅、旧签名 secret、旧测试投递、旧日志入口、旧重试任务和旧 Toast/Notification 在配置版本、权限、租户、会话或外部连接状态变化后失效或重算。
- 规定无权限和日志查看不得泄露 URL、payload、header、签名、token、客户数据、内部 ID 或外部系统对象。
- 规定移动端不得删除测试连接、启停原因、重试/回放、回调日志、签名校验说明、错误恢复和审计入口。

## 非目标

- 不定义 Webhook 协议、签名算法、后端投递系统、队列、重试调度器、第三方 OAuth 流程、provider API、具体事件 schema、payload 格式或密钥生成算法。
- 不替代 `settings-preferences-configuration.md` 的普通设置页草稿/保存模型；本 owner 只负责外部连接副作用与回调状态。
- 不替代 `secrets-credentials.md` 的真实 secret 展示、复制、下载、轮换和泄露恢复。
- 不替代 `async-jobs-task-center.md` 的任务中心与异步任务生命周期。
- 不替代 `audit-log-activity-history.md` 的审计证据模型。
- 不定义品牌视觉 token、图标、颜色、provider 名称或项目特定事件名称。

## 推荐方案

推荐新增独立 owner：`references/webhooks-integrations-callbacks.md`。

备选方案：

1. **放入设置规范。** 优点是集成页面通常长得像设置页；缺点是普通设置 owner 不足以表达测试投递、外部副作用、投递日志和旧 endpoint/secret 失效。
2. **放入密钥凭证规范。** 优点是 Webhook 常带 secret；缺点是密钥 owner 只应该管真实值暴露窗口，不应该管事件订阅、投递状态和外部连接恢复。
3. **独立 Webhook/集成 owner 协调相邻规范。** 推荐。该 owner 维护连接配置、事件订阅、投递状态和外部副作用；普通字段仍读设置 owner，secret 读密钥 owner，风险动作读风险 owner，投递任务读异步任务 owner，日志读审计 owner。

选择独立 owner 的理由：Webhook/集成事故通常发生在“配置看似保存成功，但外部连接/事件订阅/投递任务/日志回执并不一致”。独立 owner 可以把配置版本、事件版本、endpoint 版本、secret 版本、投递身份和审计回执绑定到一条状态链。

## Owner 边界

建议新增文件：`references/webhooks-integrations-callbacks.md`。

建议路由关键词：

- 中文：Webhook、回调、回调 URL、回调地址、集成、第三方集成、外部集成、连接配置、连接测试、测试连接、测试投递、事件订阅、订阅事件、事件回放、重试投递、投递日志、回调日志、签名密钥、签名校验、Endpoint、外部系统、集成状态、启用 Webhook、停用 Webhook、删除 Webhook。
- 英文：webhook、webhooks、callback、callback URL、endpoint、integration、third-party integration、external integration、connection config、connection test、test delivery、event subscription、subscribed events、event replay、retry delivery、delivery log、callback log、signing secret、signature verification、external system、integration status、enable webhook、disable webhook、delete webhook。

该 owner 维护 `webhookIntegrationState`，至少包含：

| 字段 | 说明 |
| --- | --- |
| `integrationOwnerId` | 当前 Webhook/集成 owner 稳定身份，绑定页面、表单、测试、投递、日志、请求和审计。 |
| `integrationIdentity` | 集成、Webhook、Endpoint、provider、租户/工作区、环境、外部系统和用途身份。 |
| `configurationVersion` | 当前配置版本、草稿版本、保存版本、生效版本和外部连接版本。 |
| `endpointState` | 回调 URL、协议校验、域名/路径、TLS/证书提示、脱敏策略和旧 endpoint 失效策略。 |
| `eventSubscriptionState` | 已订阅事件、草稿事件、事件版本、依赖资源、权限范围和生效状态。 |
| `deliveryState` | `not-tested`、`test-pending`、`test-succeeded`、`test-failed`、`delivery-pending`、`delivery-failed`、`retrying`、`disabled`、`unknown`。 |
| `secretBinding` | 签名 secret、Webhook Secret、Reveal、复制、轮换和泄露恢复的 `secrets-credentials.md` 绑定。 |
| `testDeliveryIntent` | 测试连接、测试投递或验证签名的触发来源、请求身份、payload 范围和副作用说明。 |
| `riskBinding` | 启用、停用、删除、重置 secret、重试投递、事件回放或敏感日志导出的风险 owner 绑定。 |
| `permissionBoundary` | 查看、编辑、测试、启停、删除、查看日志、重试、回放和审计所需的权限版本与范围。 |
| `auditBinding` | 保存配置、测试投递、启停、删除、重试、回放、失败、未知和日志查看的审计身份。 |
| `resultReceipt` | 保存成功、测试成功、失败、部分成功、未知、权限拒绝、外部系统不可用和审计回执。 |

## 核心规则

### Webhook 不是普通设置项

Webhook、集成连接、回调 URL、事件订阅和投递状态不能只按普通设置项展示。配置草稿、已保存配置、生效配置、外部连接状态、事件订阅状态、投递状态和审计状态必须分开表达。测试成功不等于配置已生效；保存成功不等于外部系统可达；启用成功不等于历史投递已恢复。

### Endpoint 与事件订阅必须有版本边界

回调 URL、Endpoint、事件订阅、环境、租户/工作区、provider 和外部系统身份必须绑定 `configurationVersion`、`integrationIdentity` 和 `permissionBoundary`。编辑 endpoint 或事件订阅只改变草稿；保存前不得改变生效配置。旧 endpoint、旧事件订阅、旧签名 secret、旧测试投递、旧日志入口、旧重试任务、旧复制链接和旧 Toast/Notification 必须在配置版本、权限、会话、租户/工作区、环境或外部连接状态变化后失效或重算。

### 测试连接和测试投递有副作用

测试连接、测试投递、验证签名和事件回放必须绑定 `testDeliveryIntent`、payload 范围、请求身份、权限版本、租户/工作区和审计身份。测试动作必须说明是否会向外部系统发送真实请求、是否使用样例 payload、是否会创建外部记录、是否可重试、是否会出现在回调日志中。确认前请求数为 0；不能把测试按钮当成普通刷新按钮。

### 启停、删除、重置 secret、重试和回放是风险操作

启用 Webhook、停用 Webhook、删除 Webhook、重置签名 secret、重试投递、事件回放、批量重试和敏感日志导出必须进入 `risk-actions.md`。影响范围必须说明事件类型、环境、调用方、外部系统、失败窗口、重试次数、幂等风险、审计回执和未知结果处理。不得用 Switch/Toggle 直接启停 Webhook；若保留开关视觉，它只能打开风险确认承载面。

### 投递状态和日志不能伪装成功

投递状态必须区分未测试、测试中、测试成功、测试失败、投递中、投递失败、重试中、已停用、未知和外部系统不可用。未知结果不能伪装成保存成功、测试成功、启用成功、删除成功、重试成功或回放成功；必须提供检查状态、查看投递日志、进入任务中心、重试或联系支持路径。

回调日志、投递日志、错误明细和审计摘要不得泄露无权限 URL、payload、header、签名、token、secret、客户数据、外部系统对象、内部 ID 或旧缓存。需要展示 payload 时必须有脱敏、权限复核、范围说明和审计回执。

### Toast 和 Notification 不能是唯一回执

保存、测试、启停、删除、重试、回放、签名校验失败、外部系统不可用、部分成功和未知结果不能只靠 Toast、Notification、Snackbar 或浏览器提示表达。页面内必须有配置状态、投递状态、日志入口、任务入口、审计入口或恢复路径。

### 移动端能力不能丢

移动端不得删除 endpoint 状态、事件订阅摘要、测试连接、测试投递、签名校验说明、启停原因、重试/回放、回调日志、错误明细、任务入口、审计入口、权限说明和恢复路径。低高度、虚拟键盘、安全区域、系统字体放大、浏览器 Back、WebView 返回和触摸长按后，保存/取消、测试结果、错误摘要和风险确认仍必须可达。

## 与其他 owner 的关系

- `settings-preferences-configuration.md`：负责普通字段、草稿/保存/生效值、脏状态和设置页离开保护；本 owner 负责外部连接副作用、投递状态和旧 endpoint/事件失效。
- `secrets-credentials.md`：负责签名 secret、Webhook Secret、Reveal、复制、轮换、撤销和审计不泄露；本 owner 只绑定 secret 版本和配置影响范围。
- `risk-actions.md`：负责启停、删除、重置 secret、重试、回放、敏感日志导出的确认和未知结果。
- `async-jobs-task-center.md`：负责后台投递、重试、回放、批量任务、任务中心恢复和结果领取。
- `audit-log-activity-history.md`：负责保存、测试、启停、删除、重试、回放、查看日志的审计证据。
- `permissions-tenancy-visibility.md`：负责无权限、租户/工作区切换、旧入口失效和无泄露。
- `global-feedback.md` / `feedback-states.md`：负责反馈通道、错误承载和恢复入口；本 owner 规定 Toast/Notification 不得成为唯一回执。

## 验收策略

后续实现新增静态审计 `docs/testing/webhooks-integrations-callbacks/webhooks-integrations-callbacks-audit.rb`，检查：

- `SKILL.md` 有 Webhook、回调、Endpoint、集成、连接测试、事件订阅、测试投递、重试投递、回调日志、签名校验等路由。
- `references/webhooks-integrations-callbacks.md` 存在并包含 `webhookIntegrationState`、endpoint/version、event subscription、test delivery intent、risk binding、secret binding、旧 endpoint/事件/日志失效、投递状态、日志不泄露、Toast 边界、移动端恢复和未验证边界。
- README / HANDOFF 有中文摘要。
- RED/GREEN 证据覆盖普通设置项、测试成功伪装生效、保存成功伪装可达、测试投递无副作用说明、Switch 直接启停、旧 endpoint 继续可用、日志泄露 payload/header/secret、Toast-only 成功、未知结果伪装成功、移动端删除恢复路径等负例。
- mutation 模式删除任一关键规则会失败。

运行时真实浏览器、移动端设备、屏幕阅读器、真实外部 endpoint、真实测试投递、真实重试/回放任务、真实权限切换、真实会话过期、真实 secret 轮换和真实审计写入未执行时，必须标为**未验证**，不能把静态审计写成运行时通过。

## 设计取舍

这个 owner 的边界有意停在前端产品交互层：不定义签名算法、不定义重试调度、不定义 provider API，也不替具体项目命名事件。它强制前端证明每一次保存、测试、启停、重试、回放和日志查看都绑定配置版本、权限版本、租户/工作区、请求身份、外部副作用说明和审计回执。这样能防住管理台里最常见的 Webhook/集成事故：看起来保存了、测试了、启用了，但真实外部连接状态和用户看到的回执并不一致。
