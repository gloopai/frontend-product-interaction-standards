# Attempt 5 GREEN：只读展示型报表

## Spawn 参数

- `task_name=attempt_5_display_report`
- `fork_turns=none`
- `model` 未发送
- `reasoning_effort` 未发送
- `message`：

```text
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个只读数据报表。它需要支持筛选、稳定排序、页码分页和长内容；还必须能在浏览器 200% 缩放及移动端查看。请说明该报表的能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端行为，以及哪些结论尚未通过真实运行环境验证。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
```

## Spawn 工具返回

```json
{"task_name":"/root/table_task5_green/attempt_5_display_report"}
```

## Completion envelope

- `Message Type FINAL_ANSWER`
- recipient `/root/table_task5_green`
- sender `/root/table_task5_green/attempt_5_display_report`

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个只读数据报表。它需要支持筛选、稳定排序、页码分页和长内容；还必须能在浏览器 200% 缩放及移动端查看。请说明该报表的能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端行为，以及哪些结论尚未通过真实运行环境验证。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

<!-- BEGIN RAW OUTPUT -->
# 只读数据报表交互设计说明

## 1. 能力声明与边界

本实例固定为只读展示档位：

| 能力 | 当前值 |
|---|---|
| `capabilityTier` | `display` |
| `resolvedTier` | `display` |
| `filteringEnabled` | `enabled` |
| `sortingEnabled` | `enabled`，单列交互排序 |
| `paginationMode` | `numbered` |
| `pageSize` | `25`，可选 `25 / 50 / 100` |
| `pageSelectionEnabled` | `false` |
| `allFilteredSelectionEnabled` | `false` |
| `rowOperationEnabled` | `false` |
| `bulkOperationEnabled` | `false` |
| `columnVisibilityEnabled` | `false` |
| `columnPinningEnabled` | `false` |
| `columnResizeEnabled` | `false` |
| `responsivePresentation` | `table-to-card` |

报表支持查询、筛选、排序、页码分页、刷新、查看完整长文本和跨端阅读。不提供选择列、全选、批量工具栏、行内编辑、单行操作、树形层级、透视、拖拽行/列排序、加载更多、无限滚动、个人列布局、导出或数据修改入口。上述禁用能力不得残留隐藏 DOM、状态槽、事件处理器或请求入口。

示例字段映射为 `recordId`、`name`、`status`、`reportDate`、`amount`、`note`。业务可替换字段标签和状态枚举，但不得改变稳定排序、字段关联、焦点恢复和跨端信息等价要求。

## 2. 页面结构

自上而下为：

1. 页面标题与报表用途说明。
2. 筛选区。
3. 已应用条件摘要。
4. 结果摘要、刷新状态及查询错误。
5. 桌面原生数据表格或窄屏卡片列表，任一时刻只存在一个活动数据根。
6. 页码分页、跳页和页大小控件。

筛选区当前使用：

- 关键词：自由文本。
- 状态：有限选项的原生 `<select>`。
- 日期范围：开始日期、结束日期。
- “应用筛选”和“重置为默认”按钮。

所有筛选采用 `applyMode: explicit`。默认值为：

```text
keyword = ""
status = "all"
startDate = null
endDate = null
```

关键词可能含敏感信息，不写入 URL、页面标题或分析日志；状态和 ISO 日期仅在产品明确标记 `urlSafe` 后才可写入 URL。

## 3. 状态结构

实现必须保留以下四组正交状态。

### `queryState`

至少包含：

- `appliedFilters`
- `sortRules`
- `pagination: { mode: "numbered", page, totalPages, totalCount }`
- `pageSize`
- 不可变 `querySnapshot`
- `snapshotId`
- `datasetVersion`
- `requestGeneration`
- `requestPhase`
- `queryError`
- `stale`

`requestPhase` 明确区分：

```text
idle
initial-loading
ready
refreshing
initial-error
refresh-error
```

### `viewState`

至少包含：

- `visibleColumnIds`
- `pinnedColumnIds`，本实例恒为空
- `columnWidths`，来自产品固定配置，不提供用户调宽
- `density`
- 当前结果行
- 结果摘要
- 当前呈现形态 `table | cards`

即使列控制能力关闭，这些展示字段仍需存在，不能与查询状态合并。

### `interactionState`

至少包含：

- `focusIntent`
- 当前 `recordId`
- 当前 `columnId`
- 当前 `controlId`
- `expandedContentIds`

选择、行菜单、单行操作相关字段不实例化；对应 DOM、状态槽、事件处理器和请求入口均为零。

### `operationState`

本实例不实例化单行或批量操作内容。不得存在操作快照、幂等键、操作错误、确认入口、成功/失败状态或操作请求。

### 独立生命周期门禁

四组状态之外设置 `lifecycleGuard`：

```text
ownerId
lifecycleToken
phase: live | disposed
ownedResources
```

路由提交离开或 owner 卸载时同步进入 `disposed`，取消或失效请求、重试、防抖、公告及待执行焦点任务，移除本实例 DOM 和 ARIA 引用。迟到响应必须同时校验 `live`、`ownerId`、`lifecycleToken`、`requestGeneration` 和 `snapshotId`；任一不匹配均静默丢弃，不更新 DOM、状态、焦点或 live region。

## 4. 查询、筛选、排序与分页

### 查询快照

每次合法查询前冻结：

```text
appliedFilters
完整 sortRules
pagination mode/page
pageSize
permissionScope
datasetVersion
snapshotId
requestGeneration
```

应用筛选、移除已应用条件、有效重置、改变排序、翻页、改变页大小、接受刷新或恢复失效页都会建立新快照并递增代次。编辑筛选草稿、展开长文本、切换桌面/移动呈现均不发查询。

同一查询意图正在执行时，重复点击、Enter 或事件重放合并到现有请求；查询条件、权限或刷新原因不同则形成新意图。取消旧请求只用于节省资源，不能替代响应提交门禁。

### 筛选

`filterDraft` 与 `appliedFilters` 分离：

- 输入和修改字段只更新草稿，不改变结果标题、数量、URL或请求。
- “应用筛选”先校验日期范围。开始日期晚于结束日期时不发请求，显示字段组错误，并将焦点移动到可聚焦错误摘要或首个错误字段。
- 合法应用后更新 `appliedFilters`、回到第 1 页、立即更新已应用条件摘要并发起查询。
- 每个已应用条件持续显示，具有“移除状态筛选”等具体名称的独立移除按钮。
- “重置”恢复声明的默认值，而非笼统清空；重置结果与当前条件语义相同时不发请求。
- 字段格式与日期范围错误归筛选字段或字段组；网络、权限和查询错误归结果区域，不得混写或重复完整错误。

### 稳定排序

当前默认实际排序为：

```text
reportDate DESC NULLS LAST
recordId ASC
```

其中 `recordId` 是不可变且全局唯一的稳定次序键，始终追加在业务排序键后。

可交互排序列为名称、统计日期、金额；采用单列模式，新列排序替换旧业务排序，但仍追加 `recordId ASC`。比较规则固定为：

- 空值统一 `NULLS LAST`。
- 文本按 `zh-CN` locale、忽略大小写、启用数字自然排序。
- 日期按时间值比较。
- 金额按数值比较。
- 每次排序提交回到第 1 页并创建新快照。

可排序表头使用真实 `<button>`；按钮名称说明下一动作，例如“按金额升序排序”。原生表格只在当前主排序列设置正确的 `aria-sort`。不可排序列没有排序按钮和 `aria-sort`。

服务端必须为分页链返回一致的不可变 `datasetVersion`。只有全部页面绑定同一版本时，才能承诺跨页无重复、无遗漏。版本变化时立即标记 `stale`，停止继续分页并从第 1 页重新查询。若服务端不能提供版本或等价快照能力，只能保证单次响应内顺序确定，不得承诺跨页零重复遗漏。

### 页码分页

页码模式以服务端可靠总数为前提。若总数不可靠，必须重新评审为游标分页，不能虚构总页数。

分页区必须显示：

- 当前结果范围，如“第 26–50 条，共 237 条”。
- 当前页和总页数。
- 首页、上一页、直接页码、下一页、末页。
- 带标签的跳页输入。
- 带标签的页大小控件。

当前页使用 `aria-current="page"`。边界按钮使用原生 `disabled`。跳页仅接受 `1..totalPages` 的整数；非法值显示输入错误且不发请求。改变页大小回到第 1 页。

若数据变化使当前页超过最新末页，只向最近有效页发起一次恢复请求；不得循环重试。恢复成功后简短公告新位置，焦点只按原翻页意图移动一次。

## 5. 主要状态转换

| 事件 | 状态和界面结果 |
|---|---|
| 初次进入 | `initial-loading`；无可用数据时显示结构匹配但不可操作的骨架 |
| 编辑筛选字段 | 只改 `filterDraft`；表格和页码保持不变 |
| 应用非法筛选 | 不发请求；字段 owner 显示错误并进入错误导航 |
| 应用、移除或有效重置筛选 | 更新摘要，页码归 1，创建查询快照，进入 `refreshing` 或 `initial-loading` |
| 提交新排序 | 更新完整稳定排序，页码归 1，创建新快照 |
| 翻页 | 记录分页来源，创建目标页快照；成功后一次性聚焦结果摘要 |
| 改变页大小 | 页码归 1，创建新快照 |
| 刷新已有结果 | 保留旧行、页码和焦点意图，进入 `refreshing`、`stale=false`、`aria-busy=true` |
| 刷新失败 | 保留旧结果，进入 `refresh-error`、`stale=true` |
| 数据版本变化 | 当前分页链失效，显示数据已变化，停止继续导航并从第 1 页重新开始 |
| 响应迟到或身份不匹配 | 静默丢弃，不改变任何用户可见状态 |
| 桌面/卡片形态切换 | 保持同一 owner、查询、页码、筛选草稿、已应用条件、展开项和焦点意图；不发请求 |
| 路由离开或卸载 | 立即 `disposed`，失效所有回调和本实例资源 |

## 6. 加载、错误和空状态

### 首次加载

没有可用结果时显示与最终列或卡片结构对应的骨架。结果容器设置 `aria-busy="true"`；骨架不含按钮、链接、复选框或可聚焦假数据。

### 后台刷新

保留上次成功的结果、当前页和焦点意图，显示“正在更新”状态并设置 `aria-busy="true"`。旧结果应明确为上次成功结果，不能伪装成已匹配新筛选的响应。

### 首次加载失败

进入 `initial-error`，以结果区域内的错误说明和可聚焦“重试加载报表”按钮替代不可用表格，不渲染空壳表格。重试创建新快照和新代次。

### 刷新失败

进入 `refresh-error`，保留旧结果与分页，并显示“更新失败，当前数据可能已过期”和重试入口。不得清空当前结果或将焦点移回页面顶部。

### 空状态

- 有非默认已应用筛选且结果为零：显示“当前筛选条件无匹配结果”，提供“调整筛选”和“清除筛选”入口。
- 默认条件下数据源为空：显示“当前报表尚无数据”。
- 两者不得共用含糊的“暂无数据”。

查询开始、结果数量或位置变化、失效页恢复、查询失败分别由结果 owner 简洁公告一次。同一完整错误不得同时由字段、结果摘要和全局 live region 重复播报。

## 7. 长内容处理

桌面表格中：

- 单元格允许换行，使用 `overflow-wrap:anywhere` 处理长单词和长标识。
- 名称、记录标识、状态和错误含义不得仅靠省略号截断。
- `note` 等长文本默认显示合理行数，并提供真实按钮“展开记录 R123 的备注全文”。
- 按钮使用 `aria-expanded` 和 `aria-controls`；完整文本在同一单元格内展开，不使用仅 Hover 的 Tooltip，也不依赖 `title` 属性。
- 展开与收起不发查询，焦点保持在触发按钮。

移动卡片中使用相同内容状态；长文本和次要字段通过“显示全部字段”展开。所有收纳字段仍有字段标签、记录归属和确定顺序。

## 8. 桌面、200% 缩放与移动端

### 桌面

表格容器使用原生 `<table>`。筛选区可多列排列，结果和分页保持页面主滚动关系。若内容确需横向滚动，只允许表格容器横向滚动，页面根不得横向溢出；容器需提供可感知的左右边界和滚动方向提示。

### 200% 缩放

响应断点以表格容器可用空间为依据，当前产品配置为容器宽度 `≤ 720 CSS px` 时切换卡片，不使用设备名称或 User-Agent。该阈值属于产品配置，可在真实内容适配测试后调整，但不得降低字段、操作或错误可达性。

200% 缩放下：

- 页面根只纵向滚动，不产生水平溢出。
- 若表格无法在单一容器中保持可用，则切换卡片，避免用户同时处理页面和表格的双向滚动。
- 筛选、结果、分页和错误恢复均可滚动到可视区域。
- 固定页头、浮动区域或虚拟键盘不得遮挡当前焦点、错误或分页控件。

### 移动端

移动端采用卡片列表，而非删减列的“精简表格”：

- 卡片名称为“报表记录 `{recordId}`，`{name}`”。
- 卡片头直接展示记录身份和状态。
- 日期、金额等主要字段直接展示。
- 备注及其他次要字段由“显示全部字段”展开，使用 `<dl><dt><dd>` 保持标签和值的关联。
- 筛选区改为单列，可放入有名称的行内 disclosure：“筛选，已应用 N 项”；不使用未声明的 Drawer。
- 页码可显示首页、末页、当前页附近的直接页码，并始终保留上一页、下一页和跳页输入，不能因窄屏删除随机跳页能力。
- Table 与卡片不得同时作为两个活动实例存在。断点转换不重建 owner、不重复请求、不改变页码或已应用筛选。

需处理低高度横屏、动态浏览器工具栏、虚拟键盘和四向安全区域；主要控件应留出安全区内边距，触摸目标不得依赖精确点击。

## 9. 键盘与焦点管理

采用原生 Table，不使用 ARIA Grid，因为本报表没有单元格选择或二维键盘导航需求。

键盘规则：

- Tab 只进入筛选字段、应用/重置按钮、排序按钮、长文本展开按钮、重试和分页控件。
- 静态单元格不设置 `tabindex="0"`。
- 表格不接管方向键、Home、End、Page Up 或 Page Down。
- 原生按钮用 Enter/Space 激活；原生输入和 `<select>` 保持平台默认键盘行为。
- 排序、筛选、跳页、刷新、错误重试和长文本展开均可纯键盘完成。
- 移动卡片与桌面表格的同一业务意图产生相同状态转换和请求数量。

焦点规则：

- 编辑或应用筛选、提交排序时，请求开始不抢走仍存活的触发控件焦点。
- 筛选校验失败时，焦点移动一次到错误摘要或首个错误字段。
- 用户翻页成功后，焦点移动一次到结果摘要/标题；失效页自动恢复不得再次抢焦点。
- 后台刷新后，原 `recordId + columnId + controlId` 仍存在时保持焦点。
- 精确目标消失时依次选择：同记录等价控件、同字段最近记录、结果摘要、当前分页控件。
- 桌面表格与移动卡片转换时，精确逻辑目标存在则保持；否则仅一次移动到相同 `recordId + columnId` 的卡片控件。
- 焦点不得落到 `document.body`、文档根、已移除节点或另一报表实例的同名控件。
- 路由离开时不向即将移除的旧触发器返回焦点；新页面自行聚焦主标题或主内容。

## 10. ARIA 与语义

桌面模式：

- 使用有可访问名称的原生 `<table>`。
- 使用 `<caption>` 或 `aria-labelledby` 关联报表标题，并通过 `aria-describedby` 关联结果摘要。
- 列表头使用 `<th scope="col">`；需要行标题时使用 `<th scope="row">`。
- 当前主排序表头设置 `aria-sort="ascending|descending"`。
- 结果容器在查询期间设置 `aria-busy="true"`。

卡片模式：

- 卡片集合使用有名称的列表语义。
- 每张卡片使用记录级标题作为 `aria-labelledby`。
- 字段标签和值采用 `<dl>/<dt>/<dd>` 或等价明确关联。
- 展开按钮提供记录身份、动作名称、`aria-expanded` 和有效 `aria-controls`。

其他语义：

- 筛选字段都有可见 `<label>`。
- 字段错误使用 `aria-invalid="true"` 和指向存活错误文本的 `aria-describedby`。
- 筛选错误摘要可程序聚焦，并提供返回具体字段的链接。
- 分页使用 `<nav aria-label="报表分页">`，当前页使用 `aria-current="page"`。
- 加载、过期、错误和空状态都有文本表达，不能只使用颜色或图标。
- 结果 owner 使用单一 `role="status"` / `aria-live="polite"` 通道发布简洁状态；被合并、丢弃、取代或 disposal 后到达的事件不公告。

## 11. 运行环境验证边界

本文为实现设计，以下结论尚未通过真实运行环境验证，不得视为已通过：

- Chrome、Firefox、Safari、Edge 在 200% 浏览器缩放下的实际回流与溢出。
- `1440×900`、`1280×720`、平板横竖屏、`390×844` 窄屏及低高度横屏手机。
- iOS Safari、Android Chrome 的动态工具栏、虚拟键盘和四向安全区域。
- 键盘完整路径、焦点事件次数及断点切换中的焦点保持。
- NVDA/Firefox、JAWS/Chrome、VoiceOver/Safari 的表头关联、排序状态、结果公告与卡片字段关联。
- 触摸目标尺寸、长按误触和触摸/鼠标/键盘请求次数一致性。
- 200% 字体、长中文、长英文单词、长记录 ID 和国际化文本扩展。
- 请求乱序、取消失败、重复触发、路由卸载及同页多报表实例隔离。
- 服务端 `totalCount` 是否可靠、`datasetVersion` 是否真正不可变，以及跨页稳定排序是否无重复遗漏。
- Table/Card 切换是否保持同一 owner 且不会重复请求、重复公告或遗留 ARIA 引用。

实现完成后需在上述浏览器、设备、输入方式、辅助技术和可控乱序请求环境中逐项验证并保存证据。

## 12. 完成前应用检查清单

| 规则族 | 结论 | 实现判据 |
|---|---|---|
| 能力与状态 | 适用 | `display` 档位及十二项能力当前值明确；固定四组状态和独立 lifecycle guard 完整 |
| 查询 | 适用 | 不可变快照、代次、owner/token 门禁、同意图合并、迟到响应丢弃均实现 |
| 筛选 | 适用 | draft/applied 分离、显式应用、默认重置、分页复位、条件摘要/移除、URL 安全和字段错误 owner 完整 |
| 排序 | 适用 | 当前业务键、方向、空值、大小写、locale/自然排序和 `recordId` 稳定键均写入快照 |
| 分页 | 适用 | 唯一使用 numbered；可靠总数、范围、直接页码、跳页校验、边界禁用、页大小、回第 1 页和单次失效恢复完整 |
| 数据状态 | 适用 | 首次加载、刷新、首次错误、刷新错误、筛选零结果、空数据集和 stale 可区分 |
| 选择与批量操作 | 不适用 | 选择 DOM、状态槽、handler、公告和请求入口均不存在 |
| 单行操作 | 不适用 | 行操作 DOM、状态槽、handler 和请求入口均不存在 |
| 列控制 | 不适用 | 不提供隐藏、固定、调宽或拖拽入口；展示状态字段仍保留 |
| Table/Grid 与键盘 | Table 适用，Grid 不适用 | 根为原生 table；无 `role=grid`、活动单元格状态或自定义方向键 handler |
| 焦点 | 适用 | 使用稳定 record/column/control ID；每个意图最多一次最终焦点迁移 |
| 响应式 | 适用 | 明确 Table/Card 映射；同一 owner；能力、字段、错误和分页无删除 |
| ARIA 与公告 | 适用 | 名称、表头、排序、busy、分页、错误关联及唯一公告 owner 完整 |
| Disposal 与实例隔离 | 适用 | owner/token/resource 隔离；卸载后迟到写入、焦点和公告均为零 |
| 运行时验证边界 | 适用，当前未验证 | 按第 11 节在真实浏览器、设备、辅助技术和乱序请求环境执行 |
<!-- END RAW OUTPUT -->
