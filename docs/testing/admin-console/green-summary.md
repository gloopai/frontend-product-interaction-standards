# 管理台 GREEN 应用总结

本次 fresh 应用输出为：

- `green-report-dashboard.md`：默认只读的运营健康仪表盘；未声明选择、行操作、批量、钻取、导出和订阅，并提供四类零值证据。
- `green-permission-risk-console.md`：成员权限更新的权限收敛、危险确认、页面内回执和审计路径。
- `green-job-audit-console.md`：导入预检查、导出鉴权、异步任务状态与审计状态区分。

生成方法：每份报告均从当前 `SKILL.md` 的管理台路由及 `references/admin-console.md` 独立应用到给定场景；未读取或引用既有 RED/GREEN 证据作为设计来源。

审计命令：

```bash
ruby docs/testing/admin-console/admin-console-audit.rb docs/testing/admin-console/green-report-dashboard.md docs/testing/admin-console/green-permission-risk-console.md docs/testing/admin-console/green-job-audit-console.md --mutations
```

结果：`PASS`，且 10 个回归变体均为 `EXPECTED_FAIL`，覆盖报表默认选择/批量、指标刷新/延迟、权限降级旧数据、Toast-only 风险结果、预检查创建任务、权限变化后旧下载链接、页面关闭取消任务、审计空态合并、Tooltip 唯一信息和移除运行时未验证边界。

已知未验证边界：未执行浏览器、AT（屏幕阅读器）、touch（触摸设备）和真实组件运行时；因此 DOM/ARIA、键盘/焦点、事件日志、实际下载拒绝和响应式断点均明确标为未验证。
