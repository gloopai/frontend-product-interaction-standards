# 反馈状态规范 GREEN 总结

GREEN 输出证明页面/区域状态被建模为独立 Feedback States owner，而不是散落在 Data Table、Form、Button、Upload/Import 或 Admin 文本中。审计命令：

```bash
ruby docs/testing/feedback-states/feedback-states-audit.rb --mutations
```

审计覆盖：

- `feedbackState` 的 `ownerId`、`surfaceKind`、`phase`、`dataPresence`、`errorKind`、`permissionScope`、`stale`、`partial`、`messageOwner`、`recoveryActions`、`announcementPolicy` 和 `sensitiveBoundary`。
- 反馈状态不能只散落在 `loading`、`error`、`empty` 三个布尔值里。
- Skeleton 不得包含可操作假数据。
- 空状态不能用“暂无数据”糊住所有情况。
- Toast 不能作为唯一错误或结果回执。
- 刷新失败时保留旧内容并标记 stale。
- 无权状态不得泄露对象名称、数量、字段、文件名、筛选值或错误明细。
- 移动端不得删除主要恢复入口。
- 通用 owner 保持项目无关，不包含业务项目专属名称、页面、模块或组件库。

浏览器、屏幕阅读器、触摸设备和真实组件运行时未执行，保持未验证。
