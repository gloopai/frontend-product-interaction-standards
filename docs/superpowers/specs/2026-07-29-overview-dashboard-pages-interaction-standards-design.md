# 概览页与仪表盘首页交互规范设计

## 背景

管理台首页、业务概览页、运营看板和报表仪表盘通常把 KPI 卡片、图表、趋势、明细表、任务状态、筛选时间范围、刷新、导出和异常告警放在同一页。现有规范分别覆盖指标卡、图表、表格、日期范围、反馈和管理台治理，但缺少一个页面级 owner 来保证这些模块读同一份已应用快照。

缺少页面级 owner 时，最容易出现：KPI 是今天、图表是近 7 天、明细表是旧筛选；刷新失败只让某个图表 stale，页面仍写“实时”；移动端删掉口径/延迟/告警；导出读取了当前可见图表但文件里用另一个范围；无权限用户还能看到旧指标标题、旧图例或旧总数。

## 推荐方案

新增 `overviewDashboardState` owner，覆盖概览页、管理台首页、仪表盘首页、运营看板、业务看板、指标总览、报表总览和 dashboard landing。

它不替代局部 owner：KPI 字段继续读 `information-display.md`，图表读 `charts-visualization.md`，明细表读 `data-tables.md`，筛选和时间范围读 `query-filters.md` / `date-time-ranges.md`，导出读 `exports-downloads-artifacts.md`。本 owner 负责页面级布局、共享快照、模块一致性、刷新策略、告警优先级、权限收敛和移动端保真。

## 状态模型

`overviewDashboardState` 至少包含：

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

## 硬性规则

1. 概览页和仪表盘首页默认只读展示；选择、行操作、批量、编辑、订阅和导出都必须显式声明，不能从存在图表、卡片或明细表自动推导。
2. KPI、图表、明细表、导出任务、页面摘要和刷新状态共享同一业务范围时，必须引用同一 `dataSnapshot`、`timeRangeSnapshot`、权限范围和数据延迟。
3. 不同模块使用不同口径、不同时间范围、不同权限范围、不同刷新时间或不同数据延迟时，差异必须在模块标题或说明中可见。
4. 页面级“实时”“已刷新”“暂无异常”“总览正常”等文案必须读取所有关键模块的状态；任一关键模块 stale、partial、permission-denied、metric-unavailable 或 refresh-error 时不得伪装全页正常。
5. 重要告警、风险状态、权限原因、数据延迟、刷新失败、导出/明细入口和恢复入口不得藏在 hover、图标、装饰卡片或不可达折叠区。
6. 移动端可以把模块重排、折叠或分组，但不得删除页面标题、全局筛选摘要、时间范围、KPI 口径、告警、权限原因、数据延迟、刷新状态、主要图表摘要、明细/导出入口和恢复路径。
7. 导出、钻取、查看明细、订阅和跳转必须绑定当前页面级快照与权限版本；旧快照、旧权限或迟到请求不得写回当前模块。
8. 无权限或权限降级不得泄露旧 KPI 名称、旧数值、旧图表 series、旧明细数量、旧导出范围、旧告警标题、旧菜单项或旧 ARIA label。
9. 页面布局不能使用营销式 hero 或纯装饰大卡片承载主要工作区；管理台概览优先扫描、比较、诊断和恢复。
10. 未执行真实浏览器、键盘、读屏、触摸、断点、权限切换和真实数据竞态检查时，必须标为未验证。

## 验收边界

首版验收使用 Ruby 静态审计和 mutation 测试，覆盖 owner 状态、只读默认、共享快照、口径差异说明、页面级状态、告警可达、移动端保留、导出/钻取绑定、权限无泄露、相邻 owner 链接、README/HANDOFF 和运行时未验证声明。
