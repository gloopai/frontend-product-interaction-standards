# Attempt 6 GREEN：只读展示型报表

## Spawn 参数

- `task_name=attempt_6_display_report`
- `fork_turns=none`
- `model` 未发送
- `reasoning_effort` 未发送

原始 `message`：

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个只读数据报表。它需要支持筛选、稳定排序、页码分页和长内容；还必须能在浏览器 200% 缩放及移动端查看。请说明该报表的能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端行为，以及哪些结论尚未通过真实运行环境验证。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

精确 spawn tool return：

```json
{"task_name":"/root/table_task5_green/attempt_6_display_report"}
```

## Completion envelope

- `Message Type FINAL_ANSWER`
- recipient `/root/table_task5_green`
- sender `/root/table_task5_green/attempt_6_display_report`

<!-- BEGIN RAW OUTPUT -->
# 只读数据报表实施设计

## 1. 产品定位与能力声明

该实例是只读展示型报表，用户只能改变查询条件、排序、分页和内容展开状态，不得修改业务记录。

| 能力 | 当前值 |
| --- | --- |
| `capabilityTier` | `display` |
| `resolvedTier` | `display` |
| `filteringEnabled` | `true` |
| `sortingEnabled` | `true`，单列交互排序 |
| `paginationMode` | `numbered` |
| `pageSize` | `25`，可选 `25 / 50 / 100` |
| `pageSelectionEnabled` | `false` |
| `allFilteredSelectionEnabled` | `false` |
| `rowOperationEnabled` | `false` |
| `bulkOperationEnabled` | `false` |
| `columnVisibilityEnabled` | `false` |
| `columnPinningEnabled` | `false` |
| `columnResizeEnabled` | `false` |
| `responsivePresentation` | `table-to-cards` |

`table-to-cards` 是本报表的产品配置值，不是共享枚举：宽屏使用原生表格，容器空间不足或浏览器 200% 缩放导致表格不可重排时使用经过评审的等价卡片映射。转换不改变数据、权限、查询、分页或风险语义。

## 2. 能力边界

首版提供：

- 已提交筛选条件、稳定单列排序、可靠总数下的页码分页。
- 初次查询、刷新、重试、过期、无匹配、空数据集和失效页恢复。
- 长标题、长备注、长单词、字体放大和翻译扩展。
- 宽屏表格与窄屏卡片的单实例响应式转换。
- 键盘、鼠标、触摸和辅助技术访问。

首版不提供：

- 行内编辑、整行跳转、单行或批量业务操作。
- 行选择、表头全选、全部筛选结果选择。
- ARIA Grid、单元格级二维导航、树表、透视表。
- 加载更多、无限滚动、拖拽行排序或列排序。
- 用户列显示、固定、调宽、列顺序调整和个人布局持久化。
- 导出、订阅或保存报表视图。

这些未启用能力不得留下隐藏按钮、空工具栏、状态槽、快捷键 handler 或请求入口。

## 3. 数据与页面结构

### 3.1 列模型

使用稳定 `columnId`：

1. `recordId`：记录唯一标识，`requiredVisible`。
2. `title`：记录标题，`requiredVisible`。
3. `status`：文本状态，不只以颜色表示。
4. `createdAt`：创建时间。
5. `amount`：金额，显示币种和本地化格式。
6. `ownerName`：归属人。
7. `notes`：可能很长的说明。

宽屏列宽来自静态产品配置，不能由用户调整。`recordId`、`title`、`status` 是关键字段；移动卡片中直接展示，其余字段进入同卡片的具名详情区，不得无入口隐藏。

### 3.2 长内容

- `recordId`、状态、错误和控件名称不得省略关键含义。
- 标题允许自然换行；连续长单词使用 `overflow-wrap:anywhere`，不得撑破页面。
- 备注默认显示三行预览，并提供真实按钮“展开记录 R123 的备注全文”。按钮使用 `aria-expanded` 和 `aria-controls`；展开后显示完整文本，收起不发请求。
- 不以 Hover、`title` 属性或仅视觉省略号作为读取全文的唯一方式。
- 不设固定行高；字体放大或翻译扩展时允许行、卡片自然增高。
- 展开状态以稳定 `recordId` 保存；响应式转换后继续保留。

## 4. 筛选、排序与分页

### 4.1 筛选

默认条件：

```text
dateRange = 最近 30 天
status = 全部
keyword = 空
```

具体字段：

- `status` 使用原生 `<select>`，`applyMode=immediate`；只有提交的新值与当前已应用值语义不同时发查询。
- `dateRange` 使用开始、结束日期字段，`applyMode=explicit`。
- `keyword` 使用文本输入，`applyMode=explicit`；按“应用筛选”后才生效。
- 日期和关键词共用明确的“应用筛选”按钮；Enter 提交同一意图，不产生重复请求。
- “重置”恢复上述默认条件，而不是无条件清空。
- 所有已应用条件持续显示为具名摘要，可分别移除；移动端筛选区折叠时摘要仍在结果区上方可见。
- 应用、移除或有效重置条件后回到第 1 页。
- `dateRange`、`status` 标记为 `urlSafe`；自由文本 `keyword` 不写入 URL、页面标题或分析日志。
- 开始日期晚于结束日期时不发查询。完整错误归日期字段组，字段设置 `aria-invalid` 并关联错误文本；可聚焦错误摘要只提供汇总和导航，不重复播报完整错误。
- 表格 owner 只接收字段已经提交且合法的业务值；输入草稿、焦点、原生 Select 的临时导航状态不进入 `appliedFilters`。

### 4.2 稳定排序

排序模式为 `single`。当前实际排序规则为：

```text
createdAt DESC
nulls = LAST
caseSensitivity = not-applicable
locale = und
natural = false
recordId ASC  // 唯一、不可变的稳定次序键
```

可排序列及比较规则：

- `createdAt`：时间戳排序，空值末尾。
- `amount`：数值排序，空值末尾。
- `status`：按产品声明的状态序号排序，空值末尾。
- `title`：Unicode NFC 规范化后使用 `zh-CN` locale、大小写不敏感、自然排序，空值末尾。
- 所有业务排序最后都追加 `recordId ASC`。

可排序表头内使用真实按钮；不可排序列不渲染按钮或 `aria-sort`。原生表格只有当前主排序表头设置 `aria-sort`，按钮名称说明下一动作，如“按创建时间升序排序”。提交不同排序后回到第 1 页，焦点仍保留在存活的排序按钮。

稳定比较器保证同一数据版本内次序确定。只有各页绑定同一 `datasetVersion` 或服务端快照时，才能承诺跨页无重复、无遗漏；服务端不提供一致性版本时不得作此承诺。

### 4.3 页码分页

- API 必须返回可靠 `totalCount`；若总数不可靠，不得虚构页码或总页数，也不得静默切换为游标分页。
- 显示“第 X 页，共 Y 页；当前显示 A–B 条，共 N 条”。
- 提供上一页、下一页、首尾及当前页附近的直接页码；当前页使用 `aria-current="page"`。
- 提供有可见标签的跳页输入。仅接受 `1..totalPages` 的整数；非法值显示字段错误、保留输入并且请求数为 0。
- 首页“上一页”和末页“下一页”使用原生 `disabled`。
- 页大小控件使用原生 Select，显示当前值；未声明或服务端拒绝的值不得成为当前页大小。
- 改变页大小、筛选或排序均回到第 1 页。
- 若数据变化使当前页超过最新末页，仅请求一次 `max(1, latestTotalPages)`；成功后公告新位置，不循环恢复。

## 5. 状态结构

实现必须恰好按以下四组管理表格状态，不能合并为单一 `loading/error`。

### `queryState`

至少包含：

```text
filterForm
filterDraft
appliedFilters
sortRules
pagination = { mode: "numbered", page }
pageSize
querySnapshot
snapshotId
datasetVersion?
requestGeneration
requestPhase
queryError
stale
```

`filterForm` 内保存字段值、初始值、`touched`、派生 `dirty`、错误可见性和校验代次；字段错误仍由字段 owner 管理。

`requestPhase` 取值为：

```text
idle
initial-loading
ready
refreshing
initial-error
refresh-error
```

每次合法查询先冻结不可变 `querySnapshot`：

```text
appliedFilters
完整 sortRules
paginationMode 与 page
pageSize
permissionScope
datasetVersion?
```

随后生成新 `snapshotId` 并严格增加 `requestGeneration`。响应只有同时满足以下条件才能提交：

```text
owner live
ownerId 匹配
lifecycleToken 匹配
requestGeneration 匹配
snapshotId 匹配
```

取消旧请求只用于节省资源，不能替代提交门禁。

### `viewState`

至少包含：

```text
visibleColumnIds
pinnedColumnIds = []
columnWidths
density = "comfortable"
currentRows
resultSummary
responsivePresentation
```

全部列由产品配置可见；没有用户列控制器。`pinnedColumnIds` 固定为空，避免缩放或长内容下固定列遮挡焦点。列宽和密度变化不会发查询。

### `interactionState`

包含：

```text
focusIntent
currentFocusRecordId?
currentFocusColumnId?
currentFocusControlId?
expandedRecordIds
```

选择、全部筛选结果范围、行菜单和操作交互子状态均未实例化：对应 DOM、状态、handler 和请求入口均为 0。

### `operationState`

单行和批量业务操作均未实例化：不创建操作阶段、快照、幂等键、成功/失败集合或恢复请求；对应 DOM、状态、handler 和请求入口均为 0。

### 独立生命周期门禁

生命周期不是第五个状态组。单独维护：

```text
ownerId
lifecycleToken
phase = live | disposed
ownedResources
```

`ownedResources` 包括查询控制器、监听器、观察器、计时器、待执行焦点和公告任务。每个表格实例拥有不同的 `ownerId`、`lifecycleToken` 和公告 owner。

## 6. 状态转换

| 事件 | 状态与请求 |
| --- | --- |
| 首次进入 | `idle → initial-loading → ready / initial-error` |
| 编辑显式筛选草稿 | 只更新 `filterDraft` 和字段状态，不查询 |
| 提交合法显式筛选 | 更新 `appliedFilters`，回第 1 页，建立新快照 |
| 提交即时状态筛选 | 合法值发生语义变化后立即应用并回第 1 页 |
| 移除或重置筛选 | 更新摘要，回第 1 页；语义无变化则不请求 |
| 提交排序 | 替换业务排序，追加稳定键，回第 1 页 |
| 翻页 | 保留筛选和排序，建立目标页新快照 |
| 改变页大小 | 接受合法值，回第 1 页 |
| 显式刷新 | 保留当前页；相同在途查询意图合并，不建立第二快照 |
| 展开或收起长内容 | 只改 `expandedRecordIds`，不查询 |
| 响应式转换 | 保留同一 owner 和全部状态，不查询、不重置分页 |
| 路由离开或卸载 | 同步进入 `disposed`，后续工作全部拒绝 |

更晚返回但门禁不匹配的响应只记录为 discarded，不更新 DOM、状态、焦点或 live region。

## 7. 加载、错误、空状态

### 首次加载

- 无可用结果时显示与最终表格或卡片结构相符的不可操作骨架。
- 结果容器设置 `aria-busy="true"`。
- 骨架不包含链接、排序按钮、展开按钮或分页假数据。

### 后台刷新

- 保留上次成功行、分页和焦点意图。
- 设置 `requestPhase=refreshing`、`aria-busy=true`，并显示“正在刷新，当前显示上次结果”。
- 旧行不得被标示为已经匹配新提交的条件。

### 初次错误

- 使用结果区内的文本错误和可聚焦“重试加载报表”按钮替代不可用表格。
- 重试创建新快照和新请求代次。
- 重试成功后若按钮被移除，焦点一次移动到结果摘要。

### 刷新错误

- 保留旧行和分页，设置 `refresh-error`、`stale=true`。
- 显示“刷新失败，当前数据可能已过期”和重试入口。
- 不清空表格，不把查询错误归到筛选字段。

### 空状态

- 有非默认已应用条件且结果为零：显示“当前筛选条件无匹配记录”，提供调整筛选和清除筛选入口。
- 无有效筛选且数据源为空：显示“当前数据集尚无记录”。
- 两种状态使用不同文案和恢复入口，不能共用“暂无数据”。

### 数据版本变化

页间 `datasetVersion` 不一致时：

1. 标记 `stale=true`。
2. 停止继续导航或组合不同版本页面。
3. 显示数据已变化的文本状态。
4. 从第 1 页建立一个新分页链；该恢复最多执行一次。

## 8. 键盘与焦点管理

- 原生 Table 不接管方向键、Home、End、Page Up 或 Page Down。
- Tab 只进入真实控件：筛选字段、应用/重置、条件移除、排序按钮、备注展开按钮、分页和错误恢复；静态单元格不设置 `tabindex="0"`。
- 原生按钮支持 Enter 和 Space；筛选表单的 Enter 与点击“应用筛选”产生同一意图和同一请求数。
- 原生 Select、日期输入和文本输入保留浏览器键盘语义。
- 应用筛选和提交排序时，请求开始不抢走仍存活的触发器焦点。
- 用户翻页且匹配响应提交后，焦点一次移动到结果标题或结果摘要；自动失效页恢复不得产生第二次移动。
- 刷新后使用稳定 `recordId + columnId + controlId` 恢复焦点，不使用行数组索引。
- 精确目标消失时依次选择：同记录等价控件、同列最近记录、结果摘要、当前分页控件。不得落到 `body`、文档根或已移除节点。
- 展开备注后焦点留在展开按钮；收起时按钮仍存活，不产生额外焦点移动。
- 表格转卡片时，逻辑控件仍存在则保留焦点；不存在时只移动一次到同记录的等价控件。没有等价目标时移至结果摘要。

## 9. ARIA 与状态公告

### 宽屏表格

- 使用原生 `<table>`、具名 `<caption>`，例如“记录数据报表”。
- 使用 `<thead>`、`<tbody>` 和 `<th scope="col">`；如有行标题，使用 `<th scope="row">`。
- 表格通过 `aria-describedby` 关联结果范围、已应用筛选和刷新状态摘要。
- 只在当前主排序表头设置 `aria-sort`。

### 移动卡片

- 使用具名 `<ul>` 或等价列表；每条记录是 `<li><article>`。
- 卡片名称包含记录身份；字段用 `<dl><dt><dd>` 或等价标签关系。
- 表格与卡片不能同时作为两个活动数据根存在；转换时卸载旧呈现并在同一 owner 下提交新呈现。
- 卡片保留全部字段、备注展开和相同分页能力。

### 控件与公告

- 筛选、排序、条件移除、分页和展开按钮的名称同时说明对象与动作。
- 分页容器使用 `<nav aria-label="报表分页">`。
- 加载、过期、错误和空状态均有文本，不只使用颜色或图标。
- 结果 owner 使用一个简洁的 `aria-live="polite"` 状态通道：
  - 每个被接受的查询开始公告一次。
  - 改变结果数量或位置的响应公告一次。
  - 失效页成功恢复公告一次。
  - 被接受的查询失败公告一次。
- 合并、丢弃、取代或 disposal 后到达的事件不公告。
- 同一完整错误只由一个 primary owner 呈现；字段、结果摘要和全局 live region 不重复朗读。

## 10. 桌面、200% 缩放与移动端

- 以容器可用空间和内容需求决定呈现，不使用设备名称或 User-Agent。
- 产品配置以约 `56rem` 的可用容器宽度作为初始转换点；最终应由真实长文本测试校准，但不得改变等价能力约束。
- 宽屏使用表格；容器低于阈值、200% 缩放或字体放大使表格无法无损重排时切换为卡片。
- 200% 缩放下不得要求用户同时管理页面和表格的双向滚动。完整卡片映射是主要回流方案；页面根不得产生横向溢出。
- 桌面筛选可多列排列；窄屏改为单列正常文档流。可使用原生 `<details>` 收纳筛选区，但外部始终显示已应用条件和数量。
- 移动卡片直接展示身份、标题和状态；时间、金额、归属人和备注位于有名称的详情区域。
- 分页控件允许换行；首末页、当前页附近的直接页码、跳页和页大小均保留。不得以“移动端精简”为由删除跳页或筛选恢复。
- 触摸目标最小采用 `44×44 CSS px`，相邻目标保留足够间距。
- 不使用固定底部工具栏；低高度、横屏手机和虚拟键盘出现时，筛选提交、结果、分页和重试仍可通过主页面滚动到达。
- 页面内边距纳入四向 `safe-area-inset-*`；动态视口变化不得遮挡焦点或分页控件。
- 断点转换保留查询、分页、展开状态和焦点意图，不产生新请求。
- 返回页面采用 `url-only` 恢复策略：只恢复 URL 安全的筛选、排序、页码和页大小；不恢复关键词或滚动位置。恢复实例使用新的 `ownerId` 和 `lifecycleToken`，并重新校验权限、数据版本和页码有效性。

## 11. Disposal 与实例隔离

路由提交离开或 owner 卸载时：

1. 同步且幂等地进入 `disposed`，不等待请求或视觉动画。
2. 取消或失效查询、重试、观察器、监听器、计时器、焦点与公告任务。
3. 移除本实例 DOM 和 ARIA 引用。
4. 不把焦点返回即将移除的筛选、排序或分页控件。
5. 迟到回调仍经过完整门禁，失败后不得写入 DOM、状态、焦点或 live region。
6. 每项资源只由其 `ownerId` 释放一次，不影响同页其他报表。
7. 新路由提交后，只由新路由自身把焦点移动到页面标题、主内容或主要操作。

## 12. 尚未通过真实运行环境验证的结论

本说明是静态设计，未提供已运行组件，因此以下全部为“未验证”：

- Chrome、Edge、Firefox、Safari 下的真实 DOM、样式、分页与焦点行为。
- `1440×900`、`1280×720`、平板横竖屏、`390×844`、窄屏和低高度横屏手机。
- 浏览器 200% 缩放、200% 字体、长中文、长英文单词和双倍翻译文本。
- iOS/Android 虚拟键盘、动态浏览器工具栏和四向安全区域。
- 键盘完整任务、鼠标、触摸目标及不同输入方式请求数一致性。
- NVDA/Firefox、JAWS/Edge、VoiceOver/Safari 的表头关联、`aria-sort`、卡片标签、公告次数和焦点恢复。
- 慢网、乱序响应、取消失败、重复刷新、版本变化和失效页单次恢复。
- 断点切换发生在查询中、焦点位于展开按钮时的单实例转换。
- API 的可靠总数、排序比较规则、唯一 `recordId` 和 `datasetVersion` 契约。

完成实现后必须保存上述环境、视口、输入方式、事件日志和可访问性树证据；未运行项目不能记为通过。

## 13. 完成前应用检查清单

| 原子规则族 | 适用性 | 当前结论或可观察依据 | 正文位置 | 验证状态 |
| --- | --- | --- | --- | --- |
| 能力与状态 | 适用 | `display` 档位、十二项能力当前值和固定四组状态已声明 | 1、5 | 未验证 |
| 查询 | 适用 | 不可变快照、请求代次及五项响应门禁已定义 | 5、6 | 未验证 |
| 筛选 | 适用 | 草稿/已应用值、提交模式、默认重置、分页复位、摘要移除、URL 安全和字段错误 owner 均已定义 | 4.1 | 未验证 |
| 排序 | 适用 | 当前业务键、方向、空值、大小写、locale、自然排序和唯一稳定键已定义 | 4.2 | 未验证 |
| 分页 | 适用 | 唯一 `numbered` 模式、可靠总数、直接页码、校验跳页、边界禁用、页大小和单次恢复已定义 | 4.3 | 未验证 |
| 数据状态 | 适用 | 首次加载、刷新、初错、刷新错、过期和两类空状态已定义 | 7 | 未验证 |
| 选择 | 不适用 | 选择 DOM=0；选择子状态=0；选择 handler/事件=0；选择请求=0 | 2、5 | 未验证 |
| 单行操作 | 不适用 | 单行操作 DOM=0；操作子状态=0；操作 handler/事件=0；操作请求=0 | 2、5 | 未验证 |
| 批量操作 | 不适用 | 批量 DOM=0；批量状态=0；批量 handler/事件=0；批量请求=0 | 2、5 | 未验证 |
| 基础列状态 | 适用 | 稳定列 ID、可见列、空固定列、静态宽度、密度和当前结果均已定义 | 3、5 | 未验证 |
| 可选列控制 | 不适用 | 列控制 DOM=0；可选控制子状态=0；调整/固定/显示 handler=0；相关请求=0 | 1、2、5 | 未验证 |
| Table 语义 | 适用 | 原生 Table、caption、scope、排序表头和静态单元格规则已定义 | 9 | 未验证 |
| ARIA Grid 语义 | 不适用 | `role=grid` DOM=0；活动单元格状态=0；Grid 键盘 handler=0；相关请求=0 | 2、8 | 未验证 |
| 键盘 | 适用 | 筛选、排序、翻页、展开和错误恢复的键盘路径已定义 | 8 | 未验证 |
| 焦点 | 适用 | 稳定 ID 恢复、分页焦点、目标消失回退和响应式迁移已定义 | 8 | 未验证 |
| 响应式 | 适用 | 表格/卡片等价、200% 回流、长内容、移动端和安全区域已定义 | 3、10 | 未验证 |
| ARIA 与公告 | 适用 | 名称、状态、结果 owner、单次公告和错误归属已定义 | 9 | 未验证 |
| disposal | 适用 | 同步幂等处置、资源失效、迟到回调门禁已定义 | 11 | 未验证 |
| 实例隔离 | 适用 | owner、token、公告 owner 和资源释放均按实例隔离 | 5、11 | 未验证 |
| 运行时验证边界 | 适用 | 已逐项列明浏览器、设备、辅助技术、竞态和 API 环境缺口 | 12 | 未验证 |
<!-- END RAW OUTPUT -->
