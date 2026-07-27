# 管理台完整治理 RED 总结

三份基线均在 `references/admin-console.md` 尚不存在的前提下生成；下列引用对应保留的缺陷，而非建议实现。

## 报表/仪表盘

- 报表默认能力：`red-report-dashboard.md:9` 未经产品声明即加入复选框、批量导出、批量标记、批量发送提醒和行级编辑/删除。
- 指标口径：`red-report-dashboard.md:17` 明确省略统计口径、更新时间、时区、数据延迟和权限范围。
- 空态：`red-report-dashboard.md:19` 将无权限、筛选无结果、未同步和服务报错复用为同一“暂无数据”空态。
- 导出：`red-report-dashboard.md:25` 的导出未声明敏感字段、筛选快照、请求身份和下载时的权限复核；`red-report-dashboard.md:25` 还让租户或角色变化后的链接继续可用。

## 权限/风险操作

- 权限/租户变化：`red-permission-risk-console.md:9` 在新租户接口返回前保留旧数据、菜单、选择和确认框；`red-permission-risk-console.md:15` 保留旧下载链接。
- 权限不足：`red-permission-risk-console.md:13` 的禁用删除按钮泄露张敏、关联项目数量，角色抽屉也泄露角色名和成员数量。
- 风险操作：`red-permission-risk-console.md:19` 仅以 Toast 告知危险操作成功/失败，未留页面内回执或明确审计路径。
- 取消边界：`red-permission-risk-console.md:21` 把关闭确认框、离开页面乃至已发请求一律写成“已取消/取消成功”。

## 导入导出/任务/审计

- 导入：`red-job-audit-console.md:7` 在预检查发现错误后仍创建“待处理”执行任务。
- 导出：`red-job-audit-console.md:13` 的下载链接可转交且不随权限/租户/字段权限变化失效；`red-job-audit-console.md:15` 也省略快照、请求身份和权限范围。
- 异步任务：`red-job-audit-console.md:19` 把关闭页面、切换 Tab 和发送取消请求直接表述为任务已取消或已停止，未等待服务端确认。
- 审计日志：`red-job-audit-console.md:25` 将无权限、无数据、筛选无结果、服务故障和同步延迟混成同一空态。

## 需要 owner 关闭的分歧

- 报表默认展示，不自动推导选择或批量。
- 权限和租户变化必须先安全降级再刷新。
- 风险操作必须有页面内回执和审计路径，Toast 不能是唯一结果。
- 导入导出和异步任务必须有快照、权限、进度、结果和恢复。
- 审计日志空态必须区分无权限、无数据、筛选无结果、服务失败和延迟。
