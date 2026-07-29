# 通知中心、站内信与公告 GREEN 证据

## GREEN 场景

正式实现新增：

- `references/notifications-message-center-announcements.md`
- `SKILL.md` 路由
- `README.md` 中文摘要
- `HANDOFF.md` 中文交接摘要
- `docs/testing/notifications-message-center-announcements/notifications-message-center-announcements-audit.rb`

运行：

```sh
ruby docs/testing/notifications-message-center-announcements/notifications-message-center-announcements-audit.rb
```

预期通过：

```text
PASS: 通知中心、站内信与公告 owner、路由、摘要和证据符合结构化审计契约。
```

## GREEN 覆盖

- `notificationCenterState` 包含 `notificationOwnerId`、`notificationIdentity`、`recipientBoundary`、`messageState`、`deliveryChannelState`、`announcementState`、`clickTargetBinding`、`preferenceState`、`badgeState`、`riskBinding`、`permissionBoundary`、`auditBinding` 和 `resultReceipt`。
- `messageState` 明确 `unread`、`read`、`archived`、`deleted`、`expired`、`hidden-by-permission` 和 `unknown`，避免已读、归档、删除、过期、权限隐藏和未知结果混淆。
- `deliveryChannelState` 明确 `in-app`、`email`、`sms`、`push`、`webhook`、`muted`、`disabled`、`failed` 和 `unknown`，避免偏好保存伪装成真实渠道投递成功。
- 持久通知不是 Toast；Toast 不能作为唯一消息记录、唯一恢复入口、唯一审计入口或唯一错误说明。
- 旧通知、旧点击链接、旧邮件入口、旧 Push deep link、旧公告、旧 Toast/Notification 和旧未读角标在权限、租户/工作区、对象状态、事件版本、投递版本、偏好版本、会话或渠道状态变化后必须失效或重算。
- `clickTargetBinding` 要求通知点击前复核权限、目标对象状态、租户/工作区、来源上下文和目标路由。
- `announcementState` 要求公告范围、生效时间、过期时间、可关闭策略、显示频率和遮挡边界明确，且不得遮挡关键操作和安全区域。
- 批量全部已读、批量归档、删除通知、清空通知、退订通知、恢复订阅和关闭强制公告绑定 `risk-actions.md`；高影响动作确认前请求数为 0。
- 未知结果不能伪装成已读成功、归档成功、删除成功、退订成功、公告关闭成功或偏好保存成功。
- 移动端不得删除通知分类、未读/已读状态、未读角标含义、筛选、标记已读/未读、归档、退订/偏好入口、公告详情、点击恢复、权限说明、审计入口和错误恢复路径。

## 未验证边界

本次只做文档和静态审计。浏览器、移动端设备、屏幕阅读器、真实邮件/短信/Push/Webhook 投递、真实系统通知 deep link、真实权限切换、真实会话过期、真实公告展示、真实偏好保存和真实审计写入均未执行，必须在业务项目运行时验证中继续标为未验证。
