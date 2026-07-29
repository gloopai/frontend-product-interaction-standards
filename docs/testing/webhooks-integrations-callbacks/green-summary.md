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

