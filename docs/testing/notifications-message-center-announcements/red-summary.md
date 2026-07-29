# 通知中心、站内信与公告 RED 证据

## RED 场景

审计器先在缺少正式 owner 的仓库状态下运行：

```sh
ruby docs/testing/notifications-message-center-announcements/notifications-message-center-announcements-audit.rb
```

预期失败：

```text
missing file: /Users/evanqi/.codex/skills/frontend-product-interaction-standards/references/notifications-message-center-announcements.md
```

该 RED 证明审计会阻止只写设计稿、不新增正式 `references/notifications-message-center-announcements.md` 的状态。

## 覆盖的失败模式

- 缺少 `notificationCenterState`、`notificationIdentity`、`recipientBoundary`、`messageState`、`deliveryChannelState`、`announcementState`、`clickTargetBinding`、`preferenceState`、`badgeState` 等核心状态字段。
- 把持久通知降级成 Toast，或让 Toast 作为唯一消息记录、唯一恢复入口、唯一审计入口或唯一错误说明。
- 旧通知、旧 Push deep link、旧邮件入口、旧点击目标、旧公告、旧 Toast/Notification 和旧未读角标在权限、租户/工作区、会话或对象变化后继续生效。
- 标记已读、归档、删除通知、关闭公告和删除目标对象混成一个状态。
- 偏好保存被伪装成邮件、短信、Push 或 Webhook 投递成功。
- 公告遮挡 Dialog/Drawer 底部操作、危险确认、表单错误、支付确认、导出下载、任务取消、导航返回或安全区域。
- 批量全部已读、批量归档、删除通知、清空通知、退订通知、恢复订阅或关闭强制公告绕过 `risk-actions.md`，或没有确认前请求数为 0。
- 未知结果被伪装成已读成功、归档成功、删除成功、退订成功、公告关闭成功或偏好保存成功。
- 移动端删除通知分类、未读/已读、偏好入口、公告详情、点击恢复、权限说明、审计入口或错误恢复路径。
- 将浏览器、移动端、屏幕阅读器、真实邮件/短信/Push/Webhook 投递、真实系统通知 deep link、真实权限切换、真实会话过期、真实公告展示、真实偏好保存和真实审计写入写成已验证；这些运行时边界必须保持未验证。

## RED 断言关键词

审计器要求 RED 证据包含 `notificationCenterState`、`notificationIdentity`、`recipientBoundary`、`messageState`、`deliveryChannelState`、`announcementState`、`clickTargetBinding`、`preferenceState`、`badgeState`、Toast、旧通知、旧 Push deep link、确认前请求数为 0、未知结果、移动端和未验证。
