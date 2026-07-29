# 异步任务与任务中心 RED 证据

- 若缺少 `asyncJobState`，或未声明 `jobOwnerId`、`jobId`、`jobKind`、`sourceSurface`、`requestIdentity`、`inputSnapshot`、`jobPhase`、`progressState`、`resultState`、`cancelPolicy`、`retryPolicy`、`artifactState`、`notificationBinding`、`auditBinding`、`permissionBoundary` 和 `responsivePolicy`，应被判定为失败。
- 若业务任务只由按钮 loading、Toast 文案、Notification 标题、表格行文案、局部 `loading` 布尔值或任务中心的一行文本表达，应被判定为失败。
- 若关闭 Dialog、Drawer、Toast、Notification、来源页面、浏览器 Tab 或移动端系统返回被当成服务端任务已取消，应被判定为失败。
- 若删除“关闭 Dialog、Drawer、Toast、Notification、来源页面、浏览器 Tab 或移动端系统返回，只能表达客户端关闭或停止等待，不得伪装成服务端任务已取消”这条边界，应被判定为失败。
- 若取消请求已发送被展示为任务已取消，应被判定为失败；取消请求已发送不等于任务已取消。
- 若未知结果被写成成功或失败，应被判定为失败；未知结果不得伪装成成功或失败。
- 若 Toast-only 或 Notification-only 承载任务状态、错误、下载入口或恢复路径，应被判定为失败；Toast 和 Notification 只能辅助提醒，不能作为唯一状态、唯一错误、唯一下载入口或唯一恢复路径。
- 若旧下载链接、旧错误明细、旧通知或旧缓存绕过任务身份、权限版本、租户/工作区、有效期和请求身份复核，应被判定为失败；领取、下载、复制、重试和分享前必须复核任务身份、权限版本、租户/工作区、有效期和请求身份。
- 若部分成功缺少成功、失败、跳过、冲突和未知的对象范围，应被判定为失败。
- 若无权限状态泄露敏感对象名称、数量、字段、文件名、错误明细、内部 ID、导出范围、提示词或旧缓存，应被判定为失败。
- 若移动端删除任务中心入口、任务状态、进度、取消中、重试、结果领取、错误明细、未知结果说明、权限说明或恢复路径，应被判定为失败。
- 若未执行真实浏览器、触摸、键盘、屏幕阅读器、权限变化、轮询/订阅、下载、任务中心和移动端视口，却写成已验证，应被判定为失败；必须标为未验证。
