# 管理台 GREEN 应用总结

三份输出使用 Task 1 原始提示的完整能力范围，不通过删除用户要求换取通过：

- `green-report-dashboard.md`：保留 KPI 卡片、趋势图、明细表、时间范围筛选、导出入口和移动端查看。报表仍默认展示型，选择/行操作/批量不启用；显式要求的导出按风险、权限、审计与任务契约治理。
- `green-permission-risk-console.md`：保留租户切换、RBAC 变化、用户列表、角色详情、删除用户、批量停用、权限变更、确认 Dialog、结果提示和移动端使用。
- `green-job-audit-console.md`：保留 CSV 导入、字段映射、预检查、后台执行、错误文件、敏感导出/下载、取消、重试、审计筛选和移动端查看。

每份报告都显式应用 `admin-console`、`data-tables`、`dialogs`、`forms` 和 `responsive-adaptive` owner，并在文首提供 `admin-console-audit` JSON 结构化契约。审计器以该契约判定能力、权限收敛、风险请求身份、结果回执、审计状态、任务状态、反馈 owner 与运行时边界，不再从整篇中文自由文本猜测语义。

审计命令：

```bash
ruby docs/testing/admin-console/admin-console-audit.rb docs/testing/admin-console/green-report-dashboard.md docs/testing/admin-console/green-permission-risk-console.md docs/testing/admin-console/green-job-audit-console.md --mutations
```

当前结果：`PASS`；41 个负向变异均为 `EXPECTED_FAIL`，3 个否定语义正向对照均为 `EXPECTED_PASS`。负向变异包括原始能力被删除、报表误开选择/批量、口径/刷新/延迟缺失、旧权限数据保留、导入预检查误创建任务、下载不重验、页面关闭等于取消、审计状态合并、组件 owner 契约缺失、五个 `requestIdentity` 字段或五类互斥结果/审计回执缺失，以及三个审查指定的同义违规改写。

官方 `quick_validate.py` 尚未进入实际 Skill 校验：当前解释器在导入依赖时终止，错误为 `ModuleNotFoundError: No module named 'yaml'`。按任务约束未安装依赖，不得把该项记为通过。

已知未验证边界：未执行浏览器、AT（屏幕阅读器）、touch（触摸设备）和真实组件运行时；DOM/ARIA、键盘/焦点、事件日志、真实下载拒绝、竞态门禁和响应式断点均为未验证。
