# 概览页与仪表盘首页规范 RED 摘要

## 目标

新增 `overviewDashboardState` 的静态审计，保护概览页、仪表盘首页、管理台首页、运营看板、业务看板、指标总览、报表总览和 dashboard landing 的页面级一致性。

## RED 期望

审计应在缺少 owner、路由或 GREEN 时失败，覆盖：

- `overviewDashboardState` 及 `dashboardOwnerId`、`consoleSurface`、`layoutRegistry`、`globalFilterBinding`、`timeRangeSnapshot`、`dataSnapshot`、`moduleRegistry`、`metricCardsBinding`、`chartBinding`、`detailBinding`、`refreshPolicy`、`alertPriority`、`actionBoundary`、`permissionBoundary`、`feedbackBinding`、`responsivePolicy`、`focusAnnouncementPolicy`、`runtimeVerification`。
- 概览页和仪表盘首页默认只读展示。
- KPI、图表、明细表、导出任务、页面摘要和刷新状态共享同一业务范围时，必须引用同一 `dataSnapshot`、`timeRangeSnapshot`、权限范围和数据延迟。
- 不同模块使用不同口径、不同时间范围、不同权限范围、不同刷新时间或不同数据延迟时，差异必须在模块标题或说明中可见。
- 任一关键模块 stale、partial、permission-denied、metric-unavailable 或 refresh-error 时不得伪装全页正常。
- 重要告警、风险状态、权限原因、数据延迟、刷新失败、导出/明细入口和恢复入口不得藏在 hover、图标、装饰卡片或不可达折叠区。
- 移动端可以把模块重排、折叠或分组，但不得删除页面标题、全局筛选摘要、时间范围、KPI 口径、告警、权限原因、数据延迟、刷新状态、主要图表摘要、明细/导出入口和恢复路径。
- 导出、钻取、查看明细、订阅和跳转必须绑定当前页面级快照与权限版本。
- 无权限或权限降级不得泄露旧 KPI 名称、旧数值、旧图表 series、旧明细数量、旧导出范围、旧告警标题、旧菜单项或旧 ARIA label。
- 页面布局不能使用营销式 hero 或纯装饰大卡片承载主要工作区。

## mutation 覆盖

`ruby docs/testing/overview-dashboard-pages/overview-dashboard-pages-audit.rb --mutations` 会删除或篡改上述关键句，预期全部出现 `EXPECTED_FAIL`。

## 运行时验证边界

本 RED 仅做静态文档审计。真实浏览器、键盘、读屏、触摸、断点、权限切换、真实请求竞态和真实组件运行时均为未验证，应用到具体项目前必须另行执行。
