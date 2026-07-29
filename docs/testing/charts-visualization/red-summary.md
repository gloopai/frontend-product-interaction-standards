# 图表与可视化规范 RED 摘要

本审计覆盖 `chartState`、`chartOwnerId`、`chartKind`、`dataSnapshot`、`metricBinding`、`dimensionBinding`、`encodingPolicy`、`axisPolicy`、`legendPolicy`、`tooltipPolicy`、`interactionPolicy`、`feedbackState`、`responsivePolicy`、`a11yPolicy`、颜色不得作为唯一语义来源、图表 tooltip 不能承载唯一必读信息和运行时检查未验证边界。

负向变异会删除或替换以下关键约束，并要求审计失败：

- 删除 `chartState` 或必要状态字段。
- 删除“每个图表必须声明 `chartState.dataSnapshot` 与 `metricBinding`”。
- 删除“图表必须展示或可达地说明指标名、口径、单位、时间范围、时区、数据延迟、刷新时间和权限范围”。
- 删除“颜色不得作为唯一语义来源”。
- 删除“图表 tooltip 不能承载唯一必读信息”。
- 删除“坐标轴必须声明字段、单位、刻度格式和排序规则”。
- 删除“非零基线、截断轴、对数轴、双轴、百分比堆叠和归一化必须显式标注”。
- 删除“Hover/highlight、legend toggle、drilldown、brush、zoom、联动筛选、导出和查看明细必须在 `interactionPolicy` 中声明”。
- 删除“图表必须区分 loading、empty、zero-results、partial、stale、refresh-error、permission-denied 和 metric-unavailable”。
- 删除“无权限状态不得泄露 series 名称、数量、对象名、筛选值、内部 ID 或旧缓存”。
- 删除“移动端不得删除图表标题、口径、单位、图例/series 含义、状态说明、错误/权限说明、数据延迟、刷新时间、导出/明细入口和恢复路径”。
- 把“未验证”改成“已验证”。
- 删除 `SKILL.md` 中指向 `references/charts-visualization.md` 的路由。
- 注入 `fex-admin` 等项目专属词。

这些 RED 变异确保图表规范不会退回到无快照、无口径、颜色唯一语义、tooltip 唯一信息、误导性轴、隐式交互、状态混淆、权限泄漏或移动端信息缩水。
