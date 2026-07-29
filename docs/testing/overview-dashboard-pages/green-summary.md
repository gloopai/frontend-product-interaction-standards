# 概览页与仪表盘首页规范 GREEN 复核

本轮 GREEN 复核确认新增 `references/overview-dashboard-pages.md` 作为概览页、仪表盘首页、管理台首页、运营看板、业务看板、指标总览、报表总览和 dashboard landing 的页面级 owner。

## 状态模型覆盖

`overviewDashboardState` 已要求声明以下字段：

- `dashboardOwnerId`
- `consoleSurface`
- `layoutRegistry`
- `globalFilterBinding`
- `timeRangeSnapshot`
- `dataSnapshot`
- `moduleRegistry`
- `metricCardsBinding`
- `chartBinding`
- `detailBinding`
- `refreshPolicy`
- `alertPriority`
- `actionBoundary`
- `permissionBoundary`
- `feedbackBinding`
- `responsivePolicy`
- `focusAnnouncementPolicy`
- `runtimeVerification`

其中 `dataSnapshot`、`timeRangeSnapshot` 和 `alertPriority` 是本轮审计重点：它们分别约束页面级数据版本、时间范围与数据延迟，以及告警、权限、失败和未知结果的呈现优先级。

## 集成关系覆盖

已把概览页 owner 与高频相邻规范建立关系，避免仪表盘首页只拼 KPI、图表和表格却没有页面级约束：

- `references/admin-console.md`
- `references/information-display.md`
- `references/charts-visualization.md`
- `references/data-tables.md`
- `references/query-filters.md`
- `references/date-time-ranges.md`
- `references/exports-downloads-artifacts.md`
- `references/feedback-states.md`
- `references/responsive-adaptive.md`
- `references/permissions-tenancy-visibility.md`

## 入口与交接覆盖

`SKILL.md` 已补充概览页、仪表盘首页、管理台首页、运营看板、业务看板、指标总览、报表总览、Dashboard 总览和英文 dashboard 关键词的路由。

`README.md` 已补充“概览页与仪表盘首页规范”和 `references/overview-dashboard-pages.md` 的入口说明。

`HANDOFF.md` 已补充“概览页与仪表盘首页”交接摘要，并链接 `references/overview-dashboard-pages.md`。

## 验证边界

本轮 GREEN 复核只验证规范结构、路由、交叉引用和可执行审计契约；真实浏览器、键盘、读屏、触摸、断点、权限切换和真实数据竞态未执行，仍必须在具体项目落地时标为未验证。
