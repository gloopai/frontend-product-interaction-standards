# Webhook、集成连接与回调配置交互规范

适用于管理台中的 Webhook endpoint、回调 URL、第三方集成、外部系统连接、事件订阅、连接测试、测试投递、签名校验、启用/停用、删除、重试投递、事件回放、投递日志和回调日志。本文件是外部连接配置、副作用说明、投递状态、旧 endpoint 失效和回调恢复路径的唯一事实来源。

普通设置字段、草稿/保存/生效值仍执行 [设置、偏好与配置页交互规范](settings-preferences-configuration.md)；Webhook Secret、签名密钥、Reveal、复制和轮换仍执行 [密钥、令牌与敏感凭证交互规范](secrets-credentials.md)；启停、删除、重置 secret、重试、回放和敏感日志导出仍执行 [危险操作与恢复交互规范](risk-actions.md)；后台投递、重试、回放任务仍执行 [异步任务与任务中心交互规范](async-jobs-task-center.md)；审计证据仍执行 [审计日志与操作历史交互规范](audit-log-activity-history.md)。兼容规则全部执行。

## 范围

本 owner 负责 Webhook、集成连接和回调配置的前端产品交互边界：哪些配置只是草稿，哪些配置已经保存，哪些配置已对外部系统生效，测试连接是否有外部副作用，投递日志是否可查看，旧 endpoint、旧事件订阅、旧签名 secret、旧测试投递、旧日志入口和旧 Toast/Notification 何时失效。

本 owner 不定义 Webhook 协议、签名算法、后端投递系统、队列、重试调度器、第三方 OAuth 流程、provider API、具体事件 schema、payload 格式或密钥生成算法，也不定义品牌视觉 token、图标、颜色、provider 名称或项目特定事件名称。

## Owner State

每个 Webhook 或外部集成配置必须维护 `webhookIntegrationState`。状态至少包含：

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

## Webhook 不是普通设置项

Webhook、集成连接、回调 URL、事件订阅和投递状态不能只按普通设置项展示。配置草稿、已保存配置、生效配置、外部连接状态、事件订阅状态、投递状态和审计状态必须分开表达。

测试成功不等于配置已生效。保存成功不等于外部系统可达。启用成功不等于历史投递已恢复。界面必须把“字段已保存”“外部连接已测试”“事件订阅已生效”“投递正在进行”“重试任务已创建”“审计已写入”拆成可识别状态，不能合并成一个绿色成功文案。

## Endpoint 与事件订阅版本边界

回调 URL、Endpoint、事件订阅、环境、租户/工作区、provider 和外部系统身份必须绑定 `configurationVersion`、`integrationIdentity` 和 `permissionBoundary`。

编辑 endpoint 或事件订阅只改变草稿；保存前不得改变生效配置。保存时必须说明影响范围：环境、订阅事件、外部系统、签名 secret 版本、测试状态、历史投递和后续投递。保存失败时，生效配置和外部连接状态保持旧版本，并在界面内说明草稿未生效。

旧 endpoint、旧事件订阅、旧签名 secret、旧测试投递、旧日志入口、旧重试任务、旧复制链接和旧 Toast/Notification 必须在配置版本、权限、会话、租户/工作区、环境或外部连接状态变化后失效或重算。浏览器 Back、任务中心返回、审计跳转、Notification 点击和缓存恢复都必须重新核对 `integrationOwnerId`、`configurationVersion`、`permissionBoundary` 和请求身份后才允许写回。

## 测试连接、测试投递和签名验证

测试连接、测试投递、验证签名和事件回放必须绑定 `testDeliveryIntent`、payload 范围、请求身份、权限版本、租户/工作区和审计身份。测试动作必须说明是否会向外部系统发送真实请求、是否使用样例 payload、是否会创建外部记录、是否可重试、是否会出现在回调日志中。

测试连接不是普通刷新按钮。测试前必须展示目标 endpoint、环境、事件类型或样例 payload 范围、可能的外部副作用、权限范围和审计说明。确认前请求数为 0；用户确认前不得发送真实请求、不得改变外部连接状态、不得创建测试投递日志，也不得写入成功 Toast。

测试失败后，错误说明必须留在页面内，并提供可恢复路径：修改 endpoint、查看签名说明、查看投递日志、重试测试、进入任务中心或查看审计。Toast、Notification、Snackbar 或浏览器提示不能替代这些入口。

## 启停、删除、重置 secret、重试和回放

启用 Webhook、停用 Webhook、删除 Webhook、重置签名 secret、重试投递、事件回放、批量重试和敏感日志导出必须进入 `risk-actions.md`。影响范围必须说明事件类型、环境、调用方、外部系统、失败窗口、重试次数、幂等风险、审计回执和未知结果处理。

不得用 Switch/Toggle 直接启停 Webhook。若保留开关视觉，它只能作为打开风险确认承载面的入口；确认通过前不得发送请求，也不得把视觉开关位置当成已生效状态。

重试投递和事件回放必须说明是否会再次调用外部系统、是否可能创建重复外部记录、是否基于旧 payload、是否使用当前签名 secret、是否受当前权限和租户/工作区约束。批量重试必须绑定快照和结果回执，不能读取当前过滤草稿或旧选择。

## 投递状态、日志和未知结果

投递状态必须区分未测试、测试中、测试成功、测试失败、投递中、投递失败、重试中、已停用、未知和外部系统不可用。`deliveryState` 的 `not-tested`、`test-pending`、`test-succeeded`、`test-failed`、`delivery-pending`、`delivery-failed`、`retrying`、`disabled` 和 `unknown` 不能合并成一个普通 badge 或 loading。

未知结果不能伪装成保存成功、测试成功、启用成功、删除成功、重试成功或回放成功。未知结果必须提供检查状态、查看投递日志、进入任务中心、重试、查看审计或联系支持路径，并说明当前配置是否已生效、外部系统是否可能收到请求、是否存在重复投递风险。

回调日志、投递日志、错误明细和审计摘要不得泄露无权限 URL、payload、header、签名、token、secret、客户数据、外部系统对象、内部 ID 或旧缓存。需要展示 payload 时必须有脱敏、权限复核、范围说明和审计回执；无权限用户不能通过错误文案、数量、DOM/ARIA、复制按钮、下载入口或旧缓存推断敏感内容。

## 审计、权限和反馈不泄露

保存配置、测试投递、启停、删除、重试、回放、查看日志、下载敏感日志和签名校验失败必须绑定 `auditBinding`。审计摘要必须说明动作、主体、目标、环境、配置版本、权限版本、请求身份和结果状态，但不得暴露无权限 payload、header、signature、token、secret 或外部对象详情。

权限、租户/工作区、会话、账号、身份、配置版本、事件订阅版本或外部连接状态变化后，旧菜单、旧按钮、旧日志入口、旧重试入口、旧确认面板、旧 Toast/Notification、旧审计跳转、旧焦点目标和旧 ARIA 引用必须失效或重算。

Toast、Notification、Snackbar 或浏览器提示不能作为唯一保存回执、测试回执、投递结果、日志入口、任务入口、审计入口、错误说明或恢复路径。它们只能作为辅助反馈，并必须指向页面内或任务中心内的持久状态。

## 移动端与可访问性

移动端不得删除 endpoint 状态、事件订阅摘要、测试连接、测试投递、签名校验说明、启停原因、重试/回放、回调日志、错误明细、任务入口、审计入口、权限说明和恢复路径。

低高度、虚拟键盘、安全区域、系统字体放大、浏览器 Back、WebView 返回和触摸长按后，保存/取消、测试结果、错误摘要、风险确认、日志入口、任务入口和审计入口仍必须可达。复杂配置可以进入 Drawer、Bottom Sheet、分步配置或独立页，但不得删除核心状态和恢复路径。

键盘和屏幕阅读器必须能区分配置草稿、已保存配置、生效配置、外部连接状态、事件订阅状态、投递状态和审计状态。状态变更应使用页面内文本和可访问状态消息，不能只靠颜色、图标、Toast 或位置表达。

## 完成前检查

- 检查 Webhook、集成连接、回调 URL、事件订阅和投递状态是否没有被当作普通设置项。
- 检查配置草稿、已保存配置、生效配置、外部连接状态、事件订阅状态、投递状态和审计状态是否分开表达。
- 检查测试成功、保存成功、启用成功和历史投递恢复是否没有被互相替代。
- 检查 endpoint、事件订阅、环境、租户/工作区、provider、外部系统身份、权限版本和配置版本是否绑定。
- 检查旧 endpoint、旧事件订阅、旧签名 secret、旧测试投递、旧日志入口、旧重试任务、旧复制链接和旧 Toast/Notification 是否在版本、权限、会话、租户/工作区、环境或外部连接状态变化后失效或重算。
- 检查测试连接、测试投递、验证签名和事件回放是否绑定 `testDeliveryIntent`，并说明真实请求、样例 payload、外部记录、重试和日志副作用。
- 检查启用、停用、删除、重置 secret、重试、回放、批量重试和敏感日志导出是否进入 `risk-actions.md`，且确认前请求数为 0。
- 检查 Switch/Toggle 是否没有直接启停 Webhook。
- 检查投递状态和未知结果是否有独立表达、恢复路径、任务入口和审计入口。
- 检查回调日志、投递日志、错误明细、Toast、Notification、Banner 和审计摘要是否没有泄露无权限 URL、payload、header、签名、token、secret、客户数据、外部系统对象、内部 ID 或旧缓存。
- 检查移动端、低高度、虚拟键盘、安全区域、系统字体放大、浏览器 Back、WebView 返回和触摸长按后，核心状态、测试、日志、任务、审计、权限说明和恢复路径仍可达。
- 真实浏览器、移动端设备、屏幕阅读器、真实外部 endpoint、真实测试投递、真实重试/回放任务、真实权限切换、真实会话过期、真实 secret 轮换和真实审计写入未实际执行时，必须明确标为**未验证**，并列出所需验证。
