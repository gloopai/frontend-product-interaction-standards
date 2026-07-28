# 全局反馈规范 GREEN 总结

GREEN 输出证明 Toast、Alert、Banner、Notification 和 Inline Feedback 被建模为独立 Global Feedback owner，而不是散落在 Feedback States、Admin 或 Button 文本中。审计命令：

```bash
ruby docs/testing/global-feedback/global-feedback-audit.rb --mutations
```

审计覆盖：

- `feedbackMessageState` 的 `messageId`、`channel`、`severity`、`sourceOwner`、`resultBinding`、`durationPolicy`、`dismissPolicy`、`announcementPolicy`、`dedupeKey`、`sensitiveBoundary` 和 `recoveryActions`。
- 全局反馈不能降级为 `showToast(text)`。
- 没有 `sourceOwner` 和 `resultBinding` 的消息不得承载业务结果。
- 危险操作、部分成功、权限失败和任务创建不能只用 Toast 作为唯一回执。
- 关闭 Toast 只关闭客户端消息，不取消服务端任务、请求、审计或结果状态。
- 同一 `dedupeKey` 的重复消息必须更新、合并或忽略。
- 全局反馈不得泄露无权对象名称、数量、字段、文件名、筛选值或错误明细。
- 移动端 Toast / Snackbar 不得遮挡底部主操作、安全区域或恢复入口。

浏览器、屏幕阅读器、触摸设备和真实组件运行时未执行，保持未验证。
