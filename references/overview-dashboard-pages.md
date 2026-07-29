# 概览页与仪表盘首页交互规范

适用于概览页、仪表盘首页、管理台首页、运营看板、业务看板、指标总览、报表总览、Dashboard 总览、overview dashboard、dashboard home、overview page、operations dashboard、business dashboard、KPI overview 和 dashboard landing。

本文件是页面级总览 owner。它负责 KPI、图表、明细表、筛选、时间范围、刷新、导出、告警、权限和移动端布局之间的共享快照与一致性。它不替代局部 owner：指标卡和只读信息读取 `references/information-display.md`；图表读取 `references/charts-visualization.md`；明细表读取 `references/data-tables.md`；筛选读取 `references/query-filters.md`；时间范围读取 `references/date-time-ranges.md`；导出读取 `references/exports-downloads-artifacts.md`；反馈读取 `references/feedback-states.md`；权限读取 `references/permissions-tenancy-visibility.md`；响应式读取 `references/responsive-adaptive.md`；管理台跨页面治理读取 `references/admin-console.md`。

## 范围与排除项

概览页和仪表盘首页默认只读展示。选择、行操作、批量、编辑、订阅和导出都必须显式声明，不能从存在图表、卡片或明细表自动推导。

本 owner 不覆盖图表配置器、报表构建器、拖拽布局编辑器、BI 自助分析器、营销落地页、静态首页或纯装饰 hero。配置和构建读取 `chart-visualization-builders.md` 或复杂编辑器 owner。

## `overviewDashboardState`

每个概览页必须声明 `overviewDashboardState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `dashboardOwnerId` | 当前概览页或仪表盘首页 owner。 |
| `consoleSurface` | `overview-dashboard`、`report-overview`、`operations-dashboard`、`business-dashboard` 或产品声明的页面 surface。 |
| `layoutRegistry` | 模块布局、优先级、折叠、分组、移动端顺序、固定区域和不可隐藏模块。 |
| `globalFilterBinding` | 已应用筛选、筛选草稿 owner、筛选摘要、URL 安全和恢复策略。 |
| `timeRangeSnapshot` | 当前已应用时间范围、时区、粒度、relativeAnchor、刷新时间和数据延迟。 |
| `dataSnapshot` | 页面级数据版本、权限范围、请求代次、模块共享范围、stale/partial 状态和生成时间。 |
| `moduleRegistry` | KPI、图表、明细、告警、任务、导出、说明、空态和恢复模块的身份、owner 和依赖快照。 |
| `metricCardsBinding` | 指标卡 owner、口径、单位、比较对象、权限范围、刷新状态和点击能力。 |
| `chartBinding` | 图表 owner、数据快照、图例/series、钻取、tooltip、导出和明细入口。 |
| `detailBinding` | 明细表、卡片列表、任务列表或审计摘要的 owner、分页、排序、权限和来源快照。 |
| `refreshPolicy` | 页面刷新、模块刷新、自动刷新、刷新合并、失败、stale 和公告策略。 |
| `alertPriority` | 告警、风险、权限、数据延迟、计算失败、部分数据和未知结果的优先级。 |
| `actionBoundary` | 导出、钻取、查看明细、订阅、跳转、编辑入口和危险操作的页面级快照绑定。 |
| `permissionBoundary` | KPI、图表 series、明细数量、导出范围、告警、菜单、旧缓存和 ARIA label 的无泄露边界。 |
| `feedbackBinding` | loading、empty、zero-results、partial、stale、refresh-error、permission-denied、metric-unavailable 和恢复入口。 |
| `responsivePolicy` | 移动端模块顺序、折叠、摘要、完整图入口、明细入口、安全区域、200% 缩放和低高度策略。 |
| `focusAnnouncementPolicy` | 进入页面、筛选应用、刷新、错误、权限收敛、钻取返回和移动端折叠的焦点与公告策略。 |
| `runtimeVerification` | 真实浏览器、键盘、读屏、触摸、断点、权限切换和真实数据竞态验证状态；未执行必须标为未验证。 |

不得只用 `dashboardData`、`stats`、`widgets`、`cards`、`charts`、`loading` 或单个接口响应替代 `overviewDashboardState`。

## 页面级快照与模块一致性

KPI、图表、明细表、导出任务、页面摘要和刷新状态共享同一业务范围时，必须引用同一 `dataSnapshot`、`timeRangeSnapshot`、权限范围和数据延迟。

| 规则 ID | 规则 |
| --- | --- |
| `ODP-SNAP-01` | 页面应用筛选、时间范围、租户/工作区或权限后，必须创建页面级 `dataSnapshot` 和 `timeRangeSnapshot`，再分发给模块。 |
| `ODP-SNAP-02` | 不同模块使用不同口径、不同时间范围、不同权限范围、不同刷新时间或不同数据延迟时，差异必须在模块标题或说明中可见。 |
| `ODP-SNAP-03` | 模块局部刷新不得静默改写页面摘要、导出范围、全局状态或其他模块快照。 |
| `ODP-SNAP-04` | 迟到响应只有匹配 `dashboardOwnerId`、模块 owner、请求代次、`dataSnapshot`、`timeRangeSnapshot`、权限版本和租户/工作区时才可提交。 |
| `ODP-SNAP-05` | 图表、指标卡和明细表从不同请求返回时，必须展示快照差异、等待一致快照或标记 partial/stale；不得静默呈现互相矛盾的数据。 |

## 只读默认与能力声明

| 规则 ID | 规则 |
| --- | --- |
| `ODP-CAP-01` | 概览页和仪表盘首页默认只读展示。 |
| `ODP-CAP-02` | 选择、行操作、批量、编辑、订阅、钻取、导出、查看明细和跳转都必须显式声明；未声明时 DOM、state、handler 和 request 均为 0。 |
| `ODP-CAP-03` | 导出、钻取、查看明细、订阅和跳转必须绑定当前页面级快照与权限版本。 |
| `ODP-CAP-04` | 编辑入口必须转交记录编辑承载面或配置 owner；不得在概览页指标卡、图表卡、明细区域或告警卡内直接编辑字段。 |
| `ODP-CAP-05` | 页面布局不能使用营销式 hero 或纯装饰大卡片承载主要工作区；管理台概览优先扫描、比较、诊断和恢复。 |

## 页面级状态与告警

任一关键模块 stale、partial、permission-denied、metric-unavailable 或 refresh-error 时不得伪装全页正常。

| 规则 ID | 规则 |
| --- | --- |
| `ODP-STATE-01` | 页面级 loading、ready、partial、stale、refresh-error、permission-denied、metric-unavailable 和 unknown 必须由 `feedbackBinding` 统一解释。 |
| `ODP-STATE-02` | 页面级“实时”“已刷新”“暂无异常”“总览正常”等文案必须读取所有关键模块状态。 |
| `ODP-STATE-03` | 重要告警、风险状态、权限原因、数据延迟、刷新失败、导出/明细入口和恢复入口不得藏在 hover、图标、装饰卡片或不可达折叠区。 |
| `ODP-STATE-04` | 告警优先级必须声明；阻断权限/安全状态优先于普通空态，计算失败优先于无数据，未知结果不得伪装成功。 |
| `ODP-STATE-05` | Toast 不能作为页面级错误、刷新失败、导出结果、权限降级或恢复路径的唯一反馈。 |

## 权限与无泄露

无权限或权限降级不得泄露旧 KPI 名称、旧数值、旧图表 series、旧明细数量、旧导出范围、旧告警标题、旧菜单项或旧 ARIA label。

| 规则 ID | 规则 |
| --- | --- |
| `ODP-PERM-01` | 权限待解析时显示安全骨架或泛化说明，不得短暂闪现旧指标、旧图表、旧明细或旧告警。 |
| `ODP-PERM-02` | 权限降级、租户切换、角色变化、数据范围变化或能力关闭后，旧模块 DOM、state、handler、request、导出、菜单、tooltip、复制和 ARIA 引用必须失效。 |
| `ODP-PERM-03` | 无权限说明可以提供申请权限、切换工作区、重新认证或返回路径，但不得包含未授权对象、指标、series、数量或范围。 |

## 响应式与移动端

移动端可以把模块重排、折叠或分组，但不得删除页面标题、全局筛选摘要、时间范围、KPI 口径、告警、权限原因、数据延迟、刷新状态、主要图表摘要、明细/导出入口和恢复路径。

| 规则 ID | 规则 |
| --- | --- |
| `ODP-RSP-01` | 移动端模块顺序必须按任务优先级声明，不得按桌面栅格顺序机械堆叠。 |
| `ODP-RSP-02` | KPI、图表和明细可折叠，但默认态必须保留页面标题、全局筛选摘要、时间范围、关键 KPI、重要告警、权限/错误摘要和恢复入口。 |
| `ODP-RSP-03` | 复杂图表可转摘要 + 查看完整图/明细页，但图表口径、单位、series 含义、数据延迟、刷新时间和错误状态必须可达。 |
| `ODP-RSP-04` | 200% 缩放、字体放大、低高度、虚拟键盘、四向 safe area 和长文本下，刷新、筛选摘要、导出/明细、告警和恢复入口不得被固定区遮挡。 |

## 可访问性与生命周期

| 规则 ID | 规则 |
| --- | --- |
| `ODP-A11Y-01` | 页面、筛选摘要、刷新状态、KPI 区、图表区、明细区、告警区和操作区必须有可区分可访问名称。 |
| `ODP-A11Y-02` | 页面刷新、筛选应用、局部失败、权限降级、告警出现和钻取返回必须由唯一 owner 公告，避免重复播报。 |
| `ODP-A11Y-03` | 钻取、查看明细、导出、刷新、恢复和切换模块必须有键盘路径和单次焦点迁移。 |
| `ODP-LIFE-01` | route/unmount、权限收敛、筛选变化、时间范围变化和断点转换必须失效旧请求、tooltip、导出回执、菜单、焦点任务和公告回调。 |
| `ODP-LIFE-02` | 旧模块迟到回调不得写回新页面、新权限、新快照或其他模块。 |
| `ODP-LIFE-03` | 未实际执行浏览器、键盘、读屏、触摸、断点、真实数据竞态和权限切换检查时，必须标为未验证。 |

## 可执行验收检查

1. **状态模型**：记录 `overviewDashboardState` 全字段。
2. **只读默认**：未声明选择、行操作、批量、编辑、订阅、钻取、导出、查看明细和跳转时，DOM/state/handler/request 均为 0。
3. **共享快照**：KPI、图表、明细、导出任务、页面摘要和刷新状态共享业务范围时，引用同一 `dataSnapshot`、`timeRangeSnapshot`、权限范围和数据延迟。
4. **差异说明**：任一模块不同口径、时间范围、权限范围、刷新时间或数据延迟时，模块标题或说明可见差异。
5. **页面级状态**：任一关键模块 stale、partial、permission-denied、metric-unavailable 或 refresh-error 时，页面不得显示全页正常。
6. **告警可达**：重要告警、风险状态、权限原因、数据延迟、刷新失败、导出/明细入口和恢复入口不只存在于 hover、图标、装饰卡片或不可达折叠区。
7. **权限无泄露**：无权限或权限降级时旧 KPI 名称、旧数值、旧图表 series、旧明细数量、旧导出范围、旧告警标题、旧菜单项和旧 ARIA label 均不暴露。
8. **移动端保真**：移动端不删除页面标题、全局筛选摘要、时间范围、KPI 口径、告警、权限原因、数据延迟、刷新状态、主要图表摘要、明细/导出入口和恢复路径。
9. **生命周期**：筛选、时间范围、权限、刷新和 route/unmount 后，迟到响应不得写回新页面或新快照。
10. **运行时报告边界**：真实浏览器、键盘、读屏、触摸、断点、权限切换、真实数据竞态和真实组件运行时未执行时，最终报告必须逐项标为未验证。

## 完成前检查

- 是否声明 `overviewDashboardState` 及全部必要字段。
- 是否保持概览页和仪表盘首页默认只读，并显式声明所有能力。
- 是否让共享业务范围的 KPI、图表、明细、导出和页面摘要读取同一快照。
- 是否在口径、范围、权限、刷新时间或延迟不同时可见说明差异。
- 是否防止关键模块失败时全页伪装正常。
- 是否保证告警、权限、延迟、刷新失败、明细/导出和恢复入口可达。
- 是否防止旧权限、旧快照和迟到响应泄露或写回。
- 是否在移动端保留核心摘要、口径、告警、状态、明细/导出和恢复。
- 未实际执行运行时检查时，是否明确标为未验证。
