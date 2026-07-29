# 图表与可视化规范 GREEN 摘要

当前 GREEN 状态要求：

- `references/charts-visualization.md` 已定义 `chartState`，并覆盖 `chartOwnerId`、`chartKind`、`dataSnapshot`、`metricBinding`、`dimensionBinding`、`encodingPolicy`、`axisPolicy`、`legendPolicy`、`tooltipPolicy`、`interactionPolicy`、`feedbackState`、`responsivePolicy` 和 `a11yPolicy`。
- 每个图表必须声明 `chartState.dataSnapshot` 与 `metricBinding`。
- 图表必须展示或可达地说明指标名、口径、单位、时间范围、时区、数据延迟、刷新时间和权限范围。
- 颜色不得作为唯一语义来源；图表 tooltip 不能承载唯一必读信息。
- 坐标轴必须声明字段、单位、刻度格式和排序规则；非零基线、截断轴、对数轴、双轴、百分比堆叠和归一化必须显式标注。
- Hover/highlight、legend toggle、drilldown、brush、zoom、联动筛选、导出和查看明细必须在 `interactionPolicy` 中声明。
- 图表必须区分 loading、empty、zero-results、partial、stale、refresh-error、permission-denied 和 metric-unavailable。
- 无权限状态不得泄露 series 名称、数量、对象名、筛选值、内部 ID 或旧缓存。
- 移动端不得删除图表标题、口径、单位、图例/series 含义、状态说明、错误/权限说明、数据延迟、刷新时间、导出/明细入口和恢复路径。
- `SKILL.md`、`README.md` 和 `HANDOFF.md` 均已接入 `references/charts-visualization.md`。
- 本次是文档和静态审计更新，真实浏览器、读屏、键盘、触摸、缩放、移动端、真实数据、真实权限和真实导出检查仍标为未验证。

审计命令：

```bash
ruby docs/testing/charts-visualization/charts-visualization-audit.rb --mutations
```
