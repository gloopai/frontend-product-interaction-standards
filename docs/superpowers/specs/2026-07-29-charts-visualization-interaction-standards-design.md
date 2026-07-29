# 图表与可视化交互规范设计

## 背景

管理台、报表页和详情概览中经常出现折线图、柱状图、饼图、面积图、散点图、漏斗图、排行图和小型趋势图。图表很容易看起来“高级”，但如果没有口径、单位、时间范围、图例、空态、权限和交互边界，反而会比表格更误导用户。

现有规范已经覆盖：

- `admin-console.md`：报表默认只读、指标声明口径、图表/指标卡/明细共享快照。
- `information-display.md`：指标卡、状态和只读信息展示。
- `date-time-ranges.md`：报表时间范围、时区、数据延迟和刷新时间。
- `query-filters.md`：筛选草稿与已应用条件分离。
- `data-tables.md`：明细表和报表表格。

缺口在于图表自身：轴和单位是否清楚、颜色是否唯一编码、tooltip 是否承载唯一信息、图例是否可访问、series 太多如何处理、筛选联动是否绑定快照、移动端是否保留图表含义、导出是否导出当前可见数据还是全量数据。

## 目标

新增 `references/charts-visualization.md`，作为图表、可视化、报表图形、趋势图、排行图、漏斗图、饼图、柱状图、折线图、面积图、散点图、图例、坐标轴、数据标签、图表 tooltip、钻取和图表导出的唯一 owner。

该 owner 的职责是让图表作为“可解释、可追溯、可访问、权限安全的数据展示”存在，而不是仅作为装饰或库组件默认输出。

## 范围

- 折线图、柱状图、条形图、面积图、饼图、环图、散点图、气泡图、漏斗图、排行图、热力图、雷达图、小趋势图和组合图。
- 图表标题、副标题、轴、刻度、单位、图例、series、颜色、数据标签、tooltip、annotation、阈值线和参考线。
- 图表空态、无权限、数据延迟、部分数据、计算失败、加载、刷新失败和 stale 状态。
- 图表筛选联动、hover/highlight、legend toggle、drilldown、brush/zoom、导出、复制图表和查看明细。
- PC、移动端、缩放、触摸、键盘和读屏场景。

## 非目标

- 不规定具体图表库、主题或品牌视觉。
- 不负责指标口径的业务定义来源；但要求图表展示该口径或链接到口径说明。
- 不替代数据表格 owner；图表明细表仍读取 `data-tables.md`。
- 不定义复杂 BI 编辑器或图表构建器；那可以后续独立成 owner。

## 设计原则

1. **图表必须绑定数据快照**：图表必须声明数据来源、筛选快照、时间范围、权限范围、刷新时间和数据延迟。
2. **视觉编码必须可解释**：轴、单位、图例、颜色、series、排序和聚合必须有明确语义。
3. **颜色和 tooltip 不能是唯一信息来源**：颜色、hover tooltip、动态图例或细小标记不能承载唯一必读信息。
4. **交互必须显式声明能力**：drilldown、legend toggle、brush、zoom、导出、查看明细和联动筛选不是默认能力，启用时必须声明状态和恢复。
5. **移动端允许替代表达，但不能丢含义**：可以转换为摘要卡、表格、分段图或横向滚动，但必须保留标题、口径、单位、图例/series 含义、状态和恢复路径。

## 状态模型

新增 `chartState`，至少包含：

- `chartOwnerId`：图表 owner。
- `chartKind`：line、bar、stackedBar、area、pie、donut、scatter、bubble、funnel、ranking、heatmap、sparkline、combo 等。
- `dataSnapshot`：数据版本、筛选快照、时间范围、权限范围、刷新时间、数据延迟和行数/点数。
- `metricBinding`：指标名、口径、单位、聚合方式、分母、排除项和比较基准。
- `dimensionBinding`：x/y/color/size/facet 等维度字段、分组语义、排序和缺失值策略。
- `encodingPolicy`：颜色、形状、线型、堆叠、面积、大小和标签编码。
- `axisPolicy`：轴标题、刻度、单位、零基线、截断、对数轴、双轴和格式化规则。
- `legendPolicy`：图例项、可见性、toggle 行为、键盘可达性和隐藏项说明。
- `tooltipPolicy`：tooltip 内容、键盘/触摸等价路径和禁止承载唯一信息的边界。
- `interactionPolicy`：hover、selection、drilldown、brush、zoom、联动筛选、导出和查看明细能力。
- `feedbackState`：loading、empty、zero-results、partial、stale、refresh-error、permission-denied、metric-unavailable。
- `responsivePolicy`：移动端替代表达、最小可读尺寸、横向滚动、摘要和明细入口。
- `a11yPolicy`：可访问名称、文本摘要、数据表替代、键盘路径和公告策略。

## 核心规则族

### CHV-SCOPE：职责与范围

- 图表 owner 负责图表如何表达数据、状态和交互；不负责业务指标本身的定义，但必须展示或链接口径。
- 报表页中图表、指标卡、明细表和导出任务共享同一筛选/权限/时间快照时，必须引用同一快照。
- 图表不能从存在数据表或接口数据自动推导选择、钻取、导出或联动能力；能力必须显式声明。

### CHV-DATA：数据快照与口径

- 每个图表必须声明 `chartState.dataSnapshot` 与 `metricBinding`。
- 图表必须展示或可达地说明指标名、口径、单位、时间范围、时区、数据延迟、刷新时间和权限范围。
- 计算失败、数据延迟、部分数据、采样、截断和权限过滤必须可见，不得伪装成完整数据。

### CHV-ENC：视觉编码

- 颜色、面积、大小、线型、堆叠、排序和透明度必须有稳定语义，不得仅为“看起来好看”改变含义。
- 颜色不得作为唯一语义来源；状态、series、正负、风险、选中和禁用必须有文本、图例、形状、线型或标签等冗余表达。
- 多 series 图表必须有可理解图例；图例项顺序、颜色和图中编码必须一致。

### CHV-AXIS：轴、比例尺与单位

- 坐标轴必须声明字段、单位、刻度格式和排序规则。
- 非零基线、截断轴、对数轴、双轴、百分比堆叠和归一化必须显式标注，避免误导。
- 双轴图必须说明左右轴分别代表什么，并避免让不同单位的线条看似同一尺度。

### CHV-TIP：Tooltip、注释与标签

- 图表 tooltip 不能承载唯一必读信息；键盘和触摸用户必须有等价路径。
- tooltip 内容必须绑定当前数据点和快照；hover 离开、刷新、权限变化或断点转换后不得悬空。
- 参考线、阈值线、异常标记和 annotation 必须说明来源和含义。

### CHV-INTERACT：图表交互

- Hover/highlight、legend toggle、drilldown、brush、zoom、联动筛选、导出和查看明细必须在 `interactionPolicy` 中声明。
- 图表选择或缩放不得静默改变页面筛选；只有明确应用后才能影响 `appliedFilters` 或请求。
- Drilldown 必须声明目标、来源快照、权限复核和返回路径。

### CHV-STATE：空态、错误与刷新

- 图表必须区分 loading、empty、zero-results、partial、stale、refresh-error、permission-denied 和 metric-unavailable。
- 刷新失败应保留旧图并标记 stale 或 refresh-error，不得直接清空造成“没有数据”的误解。
- 无权限状态不得泄露 series 名称、数量、对象名、筛选值、内部 ID 或旧缓存。

### CHV-EXPORT：导出、复制和明细

- 图表导出必须说明导出的是当前可见数据、当前筛选全量数据、聚合后数据、原始明细还是图片。
- 导出、复制图片、复制数据和查看明细必须绑定当前 `dataSnapshot`、权限版本和请求身份。
- 敏感导出读取 `risk-actions.md`，明细表读取 `data-tables.md`。

### CHV-RSP：移动端与响应式

- 移动端可以把复杂图表转换为摘要卡、分段图、可横向滚动图、明细表或“查看完整图表”独立页。
- 移动端不得删除图表标题、口径、单位、图例/series 含义、状态说明、错误/权限说明、数据延迟、刷新时间、导出/明细入口和恢复路径。
- 小屏下 tooltip 必须有触摸和键盘等价路径；不能只依赖 hover。

### CHV-A11Y：可访问性

- 每个图表必须有可访问名称和文本摘要，说明图表展示什么、范围是什么、主要结论或当前状态是什么。
- 可交互图表必须支持键盘路径；图例 toggle、数据点焦点、drilldown、缩放和重置必须可达。
- 图表必须提供数据表替代或等价明细入口，尤其是多 series、密集点和颜色编码场景。

### CHV-LIFE：生命周期与并发

- 图表请求、刷新、联动、tooltip、动画和导出回调必须绑定 live owner、`dataSnapshot` 和权限版本。
- 迟到响应不得覆盖较新的图表、筛选、权限状态或错误。
- 未执行真实浏览器、读屏、键盘、触摸、缩放、移动端和真实数据检查时，必须标为未验证。

## 与现有 owner 的关系

- `admin-console.md` 负责报表页治理；本 owner 负责图表本身的视觉编码、交互和状态。
- `information-display.md` 负责指标卡和详情展示；本 owner 负责图表型展示。
- `date-time-ranges.md` 负责时间范围、时区、刷新时间和数据延迟；本 owner 必须读取其时间快照。
- `query-filters.md` 负责筛选草稿与已应用条件；本 owner 负责图表联动不得静默修改筛选。
- `data-tables.md` 负责明细表；本 owner 负责图表到明细的绑定和替代入口。
- `overlays-menus-tooltips.md` 负责 tooltip/浮层可达性；本 owner 补充图表 tooltip 的数据语义。

## 路由关键词

中文关键词：图表、可视化、报表图形、仪表盘图表、趋势图、折线图、柱状图、条形图、面积图、饼图、环图、散点图、气泡图、漏斗图、排行图、热力图、组合图、迷你趋势图、图例、坐标轴、数据标签、参考线、阈值线、图表 tooltip、图表钻取、图表联动、图表导出、查看明细。

English keywords: chart, visualization, data visualization, dashboard chart, report chart, line chart, bar chart, column chart, area chart, pie chart, donut chart, scatter plot, bubble chart, funnel chart, ranking chart, heatmap, combo chart, sparkline, legend, axis, data label, reference line, threshold line, chart tooltip, chart drilldown, chart interaction, chart export, view details.

## 验收设计

新增 `docs/testing/charts-visualization/charts-visualization-audit.rb`：

- 检查 owner 文件包含 `chartState` 和所有必要状态字段。
- 检查数据快照、指标口径、视觉编码、颜色非唯一语义、轴/单位/非零基线、tooltip 非唯一信息、交互显式声明、空态区分、权限安全、导出绑定、移动端不丢信息和未验证边界。
- 检查 `SKILL.md` 路由包含中英文关键词并指向 `references/charts-visualization.md`。
- 检查 `README.md` 和 `HANDOFF.md` 包含摘要与引用。
- 使用负向变异删除关键规则，确保审计失败。
- 使用项目泄漏扫描，确保 owner 不绑定具体业务项目。

## 明确非验证项

本次是规范与静态审计更新，不执行具体业务图表的浏览器、读屏、键盘、触摸、缩放、移动端、真实数据、真实权限和真实导出检查。落地到项目时，所有未实际执行的运行时检查必须标为未验证。
