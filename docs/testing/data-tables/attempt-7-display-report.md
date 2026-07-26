# Attempt 7：只读展示型报表

- spawn args: `task_name=attempt_7_display_report`, `fork_turns=none`, model/reasoning_effort not sent

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个只读数据报表。它需要支持筛选、稳定排序、页码分页和长内容；还必须能在浏览器 200% 缩放及移动端查看。请说明该报表的能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端行为，以及哪些结论尚未通过真实运行环境验证。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

- spawn tool return: `{"task_name":"/root/table_task5_takeover/attempt_7_display_report"}`
- completion metadata: Message Type `FINAL_ANSWER`, recipient `/root/table_task5_takeover`, sender `/root/table_task5_takeover/attempt_7_display_report`

<!-- BEGIN RAW OUTPUT -->
# 只读数据报表实现设计

## 1. 能力声明与边界

本实例固定为只读展示档位，权限变化不得把它升级为可操作表格。

| 配置项 | 当前值 |
| --- | --- |
| `capabilityTier` | `display` |
| `resolvedTier` | `display` |
| `filteringEnabled` | `enabled` |
| `sortingEnabled` | `enabled`，单列交互式排序 |
| `paginationMode` | `numbered` |
| `pageSize` | `25` |
| `pageSelectionEnabled` | `false` |
| `allFilteredSelectionEnabled` | `false` |
| `rowOperationEnabled` | `false` |
| `bulkOperationEnabled` | `false` |
| `columnVisibilityEnabled` | `false` |
| `columnPinningEnabled` | `false` |
| `columnResizeEnabled` | `false` |
| `responsivePresentation` | `enabled: table-card` |

能力边界如下：

- 只提供筛选、排序、显式刷新、页码分页和数据阅读。
- 不提供行跳转、行详情、行内编辑、选择、全选、批量操作、导出、树形层级、透视、拖拽排序、加载更多、无限滚动、列显示控制、固定列、调宽和布局持久化。
- 长内容直接完整显示，不以仅 Hover 可见的 Tooltip、无入口截断或省略号代替正文。
- 每页最多 25 条，不启用虚拟滚动，避免动态行高与辅助技术读取范围冲突。
- 后端若不能提供可靠总数，不得继续伪装为页码分页；应进入查询错误状态，不能静默切换为游标分页。
- 后端若不能提供一致的 `datasetVersion` 或等价快照，只能保证单次响应内顺序稳定，不能承诺跨页绝无重复或遗漏。

## 2. 页面结构

按以下顺序组织页面，视觉顺序与 DOM、键盘顺序一致：

1. 报表标题、数据更新时间和“刷新报表”按钮。
2. 筛选区域。
3. 已应用筛选摘要。
4. 当前排序摘要。
5. 查询状态公告与结果摘要。
6. 桌面表格或窄屏卡片列表，任一时刻只能存在一个活动数据根。
7. 页码、页大小和跳页区域。

建议字段映射固定为：

| `columnId` | 字段 | 用途 |
| --- | --- | --- |
| `recordId` | 记录编号 | 唯一、不可变记录身份 |
| `name` | 名称 | 主要身份信息 |
| `status` | 状态 | 主要状态 |
| `updatedAt` | 更新时间 | 默认排序字段 |
| `amount` | 金额 | 数值字段 |
| `description` | 说明 | 可能包含长文本、长单词和多语言内容 |

`recordId`、`name`、`status` 为关键字段；桌面和移动端都必须直接定位。其余字段也不得消失，移动端全部映射进卡片。

## 3. 固定状态模型

### `queryState`

至少包含：

```text
filterDraft
appliedFilters
sortRules
pagination: { mode: "numbered", page, totalPages, totalCount }
pageSize
querySnapshot
snapshotId
datasetVersion
requestGeneration
requestPhase
queryError
stale
```

`requestPhase` 只能使用：

```text
idle
initial-loading
ready
refreshing
initial-error
refresh-error
```

`filterDraft` 是筛选字段已提交业务值的投影；字段内部的 `value`、`initialValue`、`touched`、`dirty`、校验代次和字段错误仍归筛选字段 owner。

### `viewState`

固定包含：

```text
visibleColumnIds:
  [recordId, name, status, updatedAt, amount, description]
pinnedColumnIds: []
columnWidths: 当前展示形态对应的静态宽度映射
density: "comfortable"
rows
resultSummary
presentation: "table" | "card"
```

没有列控制器，但这些基础列状态仍必须存在。列宽只由响应式配置决定，不允许用户拖动改变。

### `interactionState`

至少包含：

```text
focusIntent: {
  sourceEvent,
  recordId?,
  columnId?,
  controlId?,
  fallbackId
}
focusedRecordId?
focusedColumnId?
focusedControlId?
sortPanelExpanded
```

本实例不实例化行详情、行菜单或选择状态：

- DOM 中无选择列、复选框、行操作按钮或批量工具栏。
- 状态中无 `selectionMode`、`selectionGeneration`、`selectionSnapshot`、操作菜单状态。
- 无相关 handler、事件或请求入口。

`sortPanelExpanded` 仅是移动端内联排序区域的展示细节，不改变排序提交、请求或快照语义。

### `operationState`

单行和批量操作均未实例化：

```text
singleOperation: not-instantiated
bulkOperation: not-instantiated
```

不得创建操作阶段、操作快照、幂等键、成功项、失败项、冲突或重试入口；对应 DOM、状态槽、handler 和请求数均为零。

### 独立 `lifecycleGuard`

生命周期不计入上述四组状态：

```text
ownerId
lifecycleToken
live | disposed
announcementOwnerId
ownedResources: {
  queryAbortControllers,
  validationJobs,
  scheduledFocusTasks,
  announcementTasks,
  containerObservers,
  eventSubscriptions
}
```

同页多个报表的 `ownerId`、`lifecycleToken`、`announcementOwnerId` 必须分别唯一。

## 4. 筛选设计

采用显式应用模式，默认条件为：

```text
defaultFilters = {
  keyword: "",
  statuses: []
}
```

筛选字段：

- “关键词”：原生搜索输入框，提交值去除首尾空白、保留内部空白，最多 100 个字符。
- “状态”：使用带 `<legend>` 的原生复选框组；空数组表示全部状态。
- “应用筛选”：仅在当前业务值通过同步校验后提交。
- “重置筛选”：恢复 `defaultFilters`，不是含糊地清空任意字段。

状态与转换：

- 字段值只写入 `filterDraft`；结果数量、URL、请求参数和已应用条件摘要只读取 `appliedFilters`。
- 首次应用前，未离焦字段不提前显示错误；离焦后显示本字段错误。
- 点击“应用筛选”时验证全部字段。存在错误则查询请求数为零，显示可聚焦错误摘要，并聚焦摘要或首个错误字段。
- 字段错误紧邻字段，由字段作为完整错误的唯一 owner；字段设置 `aria-invalid="true"`，并以存活的 `aria-describedby` 关联错误。
- 合法应用、移除条件或有效重置均把页码恢复到第 1 页，然后建立新查询快照。
- 草稿与已应用值不同时显示“筛选条件有未应用修改”，但旧结果不得被描述为已符合草稿。
- 已应用条件持续显示为有名称的摘要项，并提供“移除状态：警告”等明确按钮。移除某项时，只把该字段草稿同步为默认业务值，其他未应用草稿保持不变。
- `statuses` 可标记为 `urlSafe`；`keyword` 按可能含账号、编号或个人信息处理，不进入 URL、标题或分析日志。
- 重置后的语义值与当前 `appliedFilters` 相同时不发请求。

## 5. 稳定排序

本实例使用单列交互式排序，当前实际排序为：

```text
updatedAt DESC NULLS LAST
recordId ASC
```

具体比较契约：

- 可排序字段：`updatedAt`、`name`、`amount`。
- 不可排序字段：`recordId`、`status`、`description`。
- 每个业务排序之后始终追加唯一、不可变的 `recordId ASC`，且不向用户提供移除稳定键的入口。
- 空值无论升序或降序均为 `NULLS LAST`。
- `updatedAt` 按 UTC 时间戳比较。
- `amount` 按服务端十进制定点数比较，不按格式化字符串比较。
- `name` 使用与 `zh-CN-u-kn-true` 等价的自然排序，大小写不敏感、数字片段按数值比较。
- 前后端必须使用语义一致的比较规则；不能让浏览器排序和服务端分页排序采用不同 collation。
- 用户提交新排序时，页码回到第 1 页，再创建查询快照。
- 桌面表头使用真实 `<button>`；名称表达下一动作，例如“按名称升序排列”。
- 仅当前业务排序表头设置 `aria-sort="ascending|descending"`；不可排序列没有按钮，也不设置 `aria-sort`。
- 移动卡片模式使用内联“排序方式”区域，提供与桌面完全等价的字段和方向选项；选择一个组合后立即提交一次排序。
- 请求开始不抢走仍存活的排序按钮焦点。

跨页一致性必须依赖服务端快照：

- 第一页接受后保存其 `datasetVersion`。
- 后续页请求携带该版本。
- 页间版本不一致时标记 `stale: true`，停止继续导航，回到第 1 页重新建立分页链。
- 服务端不提供版本能力时，界面不得声称跨页零重复、零遗漏。

## 6. 页码分页

固定使用 `numbered`，默认 `pageSize=25`，可选页大小为 25、50、100。

界面必须同时提供：

- 当前页、总页数、可靠总数和当前结果范围，例如“第 2/10 页，显示第 26–50 条，共 238 条”。
- 首页、上一页、当前页附近的直接页码、下一页、末页。
- 第一页与最后一页始终显示；中间省略号只是文本，不可聚焦。
- 当前页使用 `aria-current="page"`。
- 首页的首页/上一页按钮、末页的下一页/末页按钮使用原生 `disabled`。
- 有标签的跳页输入框；只接受 `1…totalPages` 的整数。非法值显示字段错误且不发请求。
- 页大小使用原生单选组，名称为“每页显示条数”，当前值可读取。

转换规则：

- 合法翻页建立新快照，但不改变筛选和排序。
- 筛选、排序、页大小变化均回到第 1 页。
- 页大小被服务端拒绝时保留旧值，拒绝值不得成为当前页大小。
- 数据变化导致当前页超过最新末页时，只请求一次最近有效页，且页码不小于 1。
- 恢复成功只公告一次新位置，不允许在无效页循环重试。
- 匹配的翻页响应提交后，焦点移动一次到结果摘要；自动恢复不得再产生第二次焦点移动。

## 7. 查询快照与竞态门禁

每次被接受的查询意图先冻结不可变 `querySnapshot`：

```text
{
  appliedFilters,
  sortRules,
  paginationMode: "numbered",
  page,
  pageSize,
  permissionScope,
  datasetVersion?,
  localeAndCollation,
  reason
}
```

随后生成新 `snapshotId`，并将 `requestGeneration` 严格加一。

响应必须同时满足以下条件才能提交：

```text
live
ownerId 匹配
lifecycleToken 匹配
requestGeneration 等于当前代次
snapshotId 等于当前快照
```

任一项不匹配，只记录 `response-discarded`；不得写入行、总数、错误、分页、焦点或公告。取消旧请求只用于节省资源，不能替代该门禁。

显式刷新使用筛选、排序、页码、页大小、权限范围、数据版本和刷新原因组成 `intentKey`：

- 相同 `intentKey` 已在途时，重复点击、Enter 或事件重放合并到当前请求，不新建快照、代次、请求或开始公告。
- `intentKey` 变化时，即使旧请求仍在途，也必须接受新意图并建立新快照。
- 旧请求随后返回时按门禁丢弃。

## 8. 状态转换

| 事件 | 转换与界面结果 |
| --- | --- |
| 首次进入且无结果 | `idle → initial-loading`；显示与当前展示形态相符的不可操作骨架，结果容器 `aria-busy="true"` |
| 首次成功 | `initial-loading → ready`；提交行、总数、版本和摘要，清除 busy |
| 已有结果刷新 | `ready → refreshing`；保留旧行、分页和焦点意图，标明“正在刷新，当前为上次结果” |
| 刷新成功 | `refreshing → ready`；原子替换结果，`stale=false` |
| 首次失败 | `initial-loading → initial-error`；用结果区错误与重试入口替代不可用表格/卡片 |
| 刷新失败 | `refreshing → refresh-error`；保留旧结果和分页，`stale=true`，显示“数据可能已过期” |
| 应用/移除/重置筛选 | 更新 `appliedFilters`，页码归 1，建立新快照 |
| 提交排序 | 更新完整稳定排序，页码归 1，建立新快照 |
| 翻页 | 保留筛选和排序，建立目标页快照 |
| 改变页大小 | 服务端允许后更新值，页码归 1，建立新快照 |
| 页间版本不一致 | 当前分页链失效，`stale=true`，停止导航，从第 1 页重建 |
| 当前页失效 | 单次请求最近有效页，成功后单次公告和单次焦点处理 |
| 路由离开或 owner 卸载 | 立即进入 `disposed`，拒绝所有新工作并失效迟到回调 |

## 9. 加载、错误与空状态

### 首次加载

- 结果区按桌面表格或移动卡片的最终结构显示骨架。
- 骨架中不得放置可操作的假按钮、假链接或假数据。
- 筛选区保持可用，但新查询取代旧查询时仍按代次门禁处理。

### 刷新

- 保留上次成功结果、页码、滚动位置和焦点意图。
- 结果区设置 `aria-busy="true"`。
- 可见文字明确说明当前内容是上次结果，不能把旧行标记成已匹配新筛选。

### 初次错误

- 结果区显示错误标题、简洁说明和“重试加载报表”按钮。
- 不渲染空表格或空卡片来伪装可用结果。
- 重试建立新快照和新请求代次。

### 刷新错误

- 不清空旧结果和分页。
- 显示“刷新失败，当前显示的数据可能已过期”及“重新刷新”按钮。
- 完整查询错误只归结果 owner，不复制到筛选字段或全局提示。

### 空状态

必须区分：

- `appliedFilters` 非默认且结果为零：显示“当前筛选条件无匹配”，提供“调整筛选”和“清除筛选”入口。
- 默认条件下数据源为零：显示“当前报表尚无数据”，不暗示筛选有误。
- 零结果时分页显示总数 0，所有翻页入口禁用，不虚构“第 1/1 页”。

## 10. DOM、ARIA 与状态公告

桌面使用原生表格：

```html
<table>
  <caption>只读数据报表结果</caption>
  <thead>
    <tr>
      <th scope="col">...</th>
    </tr>
  </thead>
  <tbody>...</tbody>
</table>
```

要求：

- 表格通过标题和结果摘要获得可区分的可访问名称/说明。
- 所有列使用 `<th scope="col">`；如记录身份需要作为行标题，可将名称单元格使用 `<th scope="row">`。
- 不使用 `role="grid"`。
- 静态单元格不设置 `tabindex="0"`。
- 状态、过期、错误和空结果均有文本，不只依赖颜色或图标。

移动端数据根使用有名称的列表：

```html
<ul aria-label="只读数据报表结果">
  <li>
    <article aria-labelledby="record-{recordId}-name">
      <h3 id="record-{recordId}-name">名称与记录编号</h3>
      <dl>字段标签和值</dl>
    </article>
  </li>
</ul>
```

每个字段值必须能解析到对应 `<dt>` 标签；卡片可访问名称包含记录身份。

查询公告由结果 owner 的唯一 live region 负责，置于 `aria-busy` 结果容器之外：

- 接受查询：“正在更新报表。”
- 结果位置或数量变化：“已显示第 2 页，第 26–50 条，共 238 条。”
- 查询失败：“报表加载失败，可使用重试按钮。”
- 失效页恢复：“当前页已失效，已返回第 4 页。”
- 零结果：“当前筛选条件无匹配。”

同一事件只公告一次。被合并、被取代、门禁丢弃或 disposal 后到达的事件不公告；不朗读整行内容、全部筛选条件或重复完整错误。

## 11. 键盘与焦点

### 键盘路径

- `Tab`/`Shift+Tab` 依次进入筛选字段、应用/重置、排序按钮、刷新、重试和分页控件。
- `Enter` 激活应用筛选、跳页、刷新、排序和分页按钮。
- `Space` 保持原生按钮、复选框和单选框语义。
- 原生 Table 不接管方向键、Home、End、Page Up、Page Down。
- 静态数据单元格和卡片正文不进入 Tab 顺序。
- Hover 不承担发现字段、错误、排序或分页的唯一职责。

### 焦点规则

`focusIntent` 使用稳定的 `recordId + columnId + controlId`，不得使用数组索引恢复焦点。

- 筛选、排序和刷新请求开始时不抢走仍存活的触发控件焦点。
- 结果刷新后，精确目标仍存活且语义未变时保持焦点，不因记录换了数组位置而聚焦另一记录。
- 目标消失时依次尝试同记录等价控件、同列最近记录、结果摘要、当前分页控件；只移动一次。
- 翻页成功后统一聚焦结果摘要，使键盘和屏幕阅读器用户从新页起点继续阅读。
- 初次后台加载不自动抢焦点；失败由 live region 公告。若用户触发的操作移除了焦点目标，才聚焦错误标题或重试按钮一次。
- 桌面表头排序按钮在切换为卡片时消失，焦点移动一次到移动端对应排序选项；反向转换采用同样规则。
- 最终焦点不得落到 `document.body`、文档根或已移除节点。
- 固定区域、虚拟键盘和安全区域不得遮住焦点环。

## 12. 长内容、200% 缩放与移动端

### 桌面

- 数据容器宽度大于 `72rem` 时使用表格；该阈值是当前实现配置，应以内容可用性复核，不依赖设备型号或 User-Agent。
- 列宽使用百分比或弹性布局，表头和值均允许换行。
- `description` 使用 `white-space: normal` 和 `overflow-wrap: anywhere`；长单词、URL、编号和翻译扩展不得撑破页面。
- 不使用固定列、固定表头或单元格内部滚动区。
- 金额和时间保持可辨认格式，但不能以截断隐藏关键位数。

### 200% 缩放与窄屏

- 容器宽度不超过 `72rem` 时切换为卡片，因此常见桌面在 200% 缩放后不需要同时进行页面纵向和表格横向滚动。
- 筛选区改为单列，应用和重置按钮允许换行，不固定在可能遮挡内容的底栏。
- 排序改为有名称的内联排序区域；字段和方向能力与桌面一致。
- 分页控件允许多行换行，仍保留首页、上一页、直接页码、下一页、末页、总数、范围、页大小和跳页。
- 页面根不得产生横向溢出；所有 flex/grid 子项设置可收缩边界，不能靠 `overflow-x: hidden` 裁掉内容。
- 使用四向 `safe-area-inset-*` 作为页面内边距补充。
- 动态浏览器工具栏或虚拟键盘出现后，筛选提交、结果、分页、错误和重试仍能滚动进入可视区域。
- 关键触摸目标采用至少 44×44 CSS px 的目标区域和可分辨间距。
- 断点切换保持同一 `ownerId`、查询、筛选草稿、已应用条件、排序、页码、数据、焦点意图和在途请求；转换自身不得发查询。
- 任一时刻只能有一个活动 Table 或卡片列表根，不能把两个根同时留在可访问性树中。

## 13. Disposal、返回恢复与实例隔离

路由提交离开或报表 owner 卸载时：

- 同步且幂等地进入 `disposed`，不等待请求或动画。
- 取消或失效查询、页恢复、筛选校验、排队焦点、公告任务、观察器和订阅。
- 删除本实例的数据根、状态公告和 ARIA 引用。
- 迟到响应仍执行完整提交门禁，不能写 DOM、状态、焦点或 live region。
- 实例只能释放自己 `ownerId` 持有的资源一次，不能影响同页其他报表。
- 不把本地取消描述成服务端已取消成功。
- 不把焦点返回即将移除的旧触发器；新路由提交后由新路由自行聚焦主标题或主要内容。

返回策略采用 `restorePolicy=query-and-scroll`：

- 使用会话内存恢复已应用筛选、排序、页大小、目标页和滚动位置；敏感关键词不得进入 URL、标题或分析日志。
- 恢复前重新校验权限范围、数据版本和有效页码。
- 使用全新的 `ownerId` 与 `lifecycleToken`。
- 权限、版本或页码校验失败时不回放旧结果，按最新有效范围重新查询。
- 不恢复已打开的响应式排序区域或任何旧异步任务。

## 14. 尚未通过真实运行环境验证的结论

以下均为实现契约，当前不得写成已经通过：

- Chrome、Firefox、Safari、Edge 在 100% 与 200% 缩放下的实际重排、溢出和焦点遮挡。
- `1440×900`、`1280×720`、平板横竖屏、`390×844`、窄屏低高度及手机横屏下的表格/卡片转换。
- 系统字体放大、超长中文、无空格长单词、长 URL、金额和国际化文本扩展。
- iOS/Android 动态工具栏、虚拟键盘和四向安全区域。
- 仅键盘完成筛选、排序、翻页、跳页、刷新和错误恢复，以及每条焦点迁移是否严格为零次或一次。
- NVDA/Firefox、JAWS/Chrome、VoiceOver/Safari、TalkBack/Chrome 对表头关联、`aria-sort`、卡片字段标签、`aria-busy`、错误关联和状态公告的实际读取。
- 高对比度、强制颜色模式、触摸目标和键盘焦点可见性。
- 真实 API 是否提供可靠 `totalCount`、一致 `datasetVersion`、相同 collation、不可变唯一 `recordId` 和页失效恢复信息。
- 快速筛选、连续排序、翻页、重复刷新、迟到响应、取消失败、路由卸载和同页多实例交错返回时的门禁与隔离。
- 跨页零重复、零遗漏只能在真实后端快照能力确认并运行分页完整性检查后成立。

## 15. 实现交付核对表

| 原子规则族 | 适用性 | 实现定位或不适用依据 | 验证状态 |
| --- | --- | --- | --- |
| 能力与状态 | 适用 | 见“能力声明与边界”“固定状态模型” | 未验证 |
| 查询 | 适用 | 见“查询快照与竞态门禁”“状态转换” | 未验证 |
| 筛选 | 适用 | 见“筛选设计”；草稿、应用、重置、URL、字段错误和分页复位均已定义 | 未验证 |
| 排序 | 适用 | 见“稳定排序”；实际键、方向、空值、大小写、locale、自然排序和稳定键均已定义 | 未验证 |
| 分页 | 适用 | 见“页码分页”；可靠总数、页码、跳页、边界、页大小、复位和单次恢复均已定义 | 未验证 |
| 数据状态 | 适用 | 见“加载、错误与空状态” | 未验证 |
| 选择 | 不适用 | DOM 无选择列/复选框；状态槽未实例化；无选择 handler/事件；无选择请求入口 | 未验证 |
| 单行操作 | 不适用 | DOM 无行链接、操作按钮或菜单；状态槽未实例化；无单行 handler/事件；无单行请求入口 | 未验证 |
| 批量操作 | 不适用 | DOM 无批量工具栏或确认入口；状态槽未实例化；无批量 handler/事件；无批量请求入口 | 未验证 |
| 基础列状态 | 适用 | 见 `viewState` 的可见列、空固定列、静态宽度、密度和结果摘要 | 未验证 |
| 可选列控制 | 不适用 | DOM 无列控制/固定/调宽入口；无相应可变状态槽；无列控制 handler/事件；不触发查询 | 未验证 |
| Table 语义 | 适用 | 见“DOM、ARIA 与状态公告”的原生 `<table>` 契约 | 未验证 |
| ARIA Grid 语义 | 不适用 | DOM 无 `role="grid"`；无活动单元格状态；无二维键盘 handler；无 Grid 请求入口 | 未验证 |
| 键盘 | 适用 | 见“键盘与焦点” | 未验证 |
| 焦点 | 适用 | 见 `focusIntent` 与“焦点规则” | 未验证 |
| 响应式 | 适用 | 见“长内容、200% 缩放与移动端” | 未验证 |
| ARIA 与公告 | 适用 | 见“DOM、ARIA 与状态公告” | 未验证 |
| disposal | 适用 | 见“Disposal、返回恢复与实例隔离” | 未验证 |
| 实例隔离 | 适用 | 见独立 `lifecycleGuard`、唯一 owner 和资源归属规则 | 未验证 |
| 运行时验证边界 | 适用 | 见“尚未通过真实运行环境验证的结论” | 未验证 |
<!-- END RAW OUTPUT -->
