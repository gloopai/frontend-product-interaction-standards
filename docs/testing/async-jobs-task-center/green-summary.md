# 异步任务与任务中心 GREEN 证据

- `asyncJobState` 固定包含 `jobOwnerId`、`jobId`、`jobKind`、`sourceSurface`、`requestIdentity`、`inputSnapshot`、`jobPhase`、`progressState`、`resultState`、`cancelPolicy`、`retryPolicy`、`artifactState`、`notificationBinding`、`auditBinding`、`permissionBoundary` 和 `responsivePolicy`。
- 任务状态不会只绑定到按钮 loading、Toast 文案、Notification 标题、表格行文案、局部 `loading` 布尔值或任务中心的一行文本。
- 关闭 Dialog、Drawer、Toast、Notification、来源页面、浏览器 Tab 或移动端系统返回，只能表达客户端关闭或停止等待，不得伪装成服务端任务已取消。
- 取消请求已发送不等于任务已取消。
- 未知结果不得伪装成成功或失败。
- Toast 和 Notification 只能辅助提醒，不能作为唯一状态、唯一错误、唯一下载入口或唯一恢复路径。
- 领取、下载、复制、重试和分享前必须复核任务身份、权限版本、租户/工作区、有效期和请求身份。
- 部分成功说明成功、失败、跳过、冲突和未知的对象范围，并提供错误明细、重试失败项、下载结果或任务详情路径。
- 无权限状态不泄露敏感对象名称、数量、字段、文件名、错误明细、内部 ID、导出范围、提示词或旧缓存。
- 移动端不得删除任务中心入口、任务状态、进度、取消中、重试、结果领取、错误明细、未知结果说明、权限说明或恢复路径。
- 真实浏览器、触摸、键盘、屏幕阅读器、权限变化、轮询/订阅、下载、任务中心和移动端视口未实际执行时，必须标为未验证。
