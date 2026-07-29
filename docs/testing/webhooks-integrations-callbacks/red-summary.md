# Webhook、集成连接与回调配置 RED 证据摘要

这些负向场景必须被规范和审计识别为失败：

- Webhook、集成连接、回调 URL、事件订阅或投递状态被当成普通设置项展示，没有 `webhookIntegrationState`、`endpointState`、`eventSubscriptionState`、`deliveryState`、配置版本、endpoint 状态或外部连接状态。
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
