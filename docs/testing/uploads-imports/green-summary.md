# 上传与导入规范 GREEN 总结

GREEN 输出证明上传与导入被建模为独立 Upload / Import owner，而不是散落在 Form、Button、Dialog、Table 或 Admin 文本中。审计命令：

```bash
ruby docs/testing/uploads-imports/uploads-imports-audit.rb --mutations
```

审计覆盖：

- `uploadSessionState` 的 `sessionId`、`sourceOwner`、`acceptedPolicy`、`fileItems`、`queuePhase`、`requestIdentity` 和 `resultOwner`。
- 浏览器 `accept` 只能作为选择器提示，不能作为唯一校验。
- 无效文件不得进入待上传请求队列。
- 重复点击、Enter、Space、触摸或事件重放不得产生重复上传或重复导入。
- 客户端取消、关闭容器或离开页面不得直接写成服务端已取消。
- 导入预检必须区分格式错误、字段缺失、字段映射、重复数据、权限不可执行、警告和可继续风险。
- 部分成功不能只用 Toast 表示，必须有结果明细和恢复入口。
- 错误明细下载必须复核权限、租户/工作区、任务身份和文件有效期。
- 拖拽上传不能是唯一入口，移动端也必须保留核心恢复路径。
- 通用 owner 保持项目无关，不包含业务项目专属名称、页面、模块或组件库。

浏览器、屏幕阅读器、触摸设备和真实组件运行时未执行，保持未验证。
