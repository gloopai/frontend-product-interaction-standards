# Attempt 7：单行操作管理列表

- Spawn args: `task_name=attempt_7_row_action_list`, `fork_turns=none`, model/reasoning_effort not sent
- Spawn tool return: `{"task_name":"/root/table_task5_takeover/attempt_7_row_action_list"}`
- Completion metadata: Message Type `FINAL_ANSWER`, recipient `/root/table_task5_takeover`, sender `/root/table_task5_takeover/attempt_7_row_action_list`

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个带 row-action 的管理列表。它使用游标分页，需要处理刷新失败、行菜单、焦点恢复、权限变化和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配，以及请求、菜单、焦点与其他资源在 disposal 时如何处理；同时列出尚未通过真实运行环境验证的边界。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

<!-- BEGIN RAW OUTPUT -->
## 1. 实例与能力边界

本实例固定声明为单行操作型管理列表：

| 配置 | 当前值 |
| --- | --- |
| `capabilityTier` | `row-action` |
| `resolvedTier` | `row-action`；权限整体撤销后降为 `display` |
| `filteringEnabled` | `false` |
| `sortingEnabled` | `false`，无用户可操作排序；查询仍使用固定稳定排序 |
| `paginationMode` | `cursor` |
| `pageSize` | `25`，本版固定，无页大小控件 |
| `pageSelectionEnabled` | `false` |
| `allFilteredSelectionEnabled` | `false` |
| `rowOperationEnabled` | `true` |
| `bulkOperationEnabled` | `false` |
| `columnVisibilityEnabled` | `false` |
| `columnPinningEnabled` | `false` |
| `columnResizeEnabled` | `false` |
| `responsivePresentation` | `table-to-card`，显式启用并使用固定字段映射 |

本版包含：

- 记录详情链接；
- 行操作菜单；
- 非破坏性异步单行操作，例如“重新同步”；
- 显式刷新；
- 不透明双向游标的上一页、下一页导航；
- 权限动态降级、刷新失败恢复、焦点恢复和路由卸载处置。

本版不包含筛选、多选、全选、批量工具栏、交互排序、行内编辑、树表、拖拽排序、随机跳页、总页数、加载更多、无限滚动、列显示/固定/调宽控制和个人布局持久化。破坏性单行操作也不在本版内；后续增加时必须另行定义风险确认流程。

固定查询排序为：

1. `updatedAt DESC NULLS LAST`；
2. `recordId ASC`，作为唯一、不可变稳定键。

`updatedAt` 为时间类型，大小写和自然排序不适用；`recordId` 持久化为规范化小写 UUID，按二进制/ASCII 顺序比较，locale 使用 `und`，不启用自然排序。桌面表头“更新时间”设置 `aria-sort="descending"`，但不渲染排序按钮；表格说明补充“相同更新时间按记录编号升序”。排序没有 DOM 控件、键盘 handler 或焦点入口。

## 2. 状态归属

四组状态不得合并写入。

### `queryState`

```text
appliedFilters: {}
sortRules
pagination: {
  mode: "cursor",
  committedPosition,
  previousCursor?,
  nextCursor?
}
pageSize: 25
querySnapshot
snapshotId
displayedSnapshotId
datasetVersion?
requestGeneration
requestPhase
requestReason
queryError
stale
```

`querySnapshot` 冻结已应用条件、完整稳定排序、目标游标、方向、页大小、权限范围、适用的数据版本和刷新原因。目标游标只在响应成功后提交到 `pagination`，请求失败时继续保留上次成功位置。`displayedSnapshotId` 明确标识当前行来自哪个成功快照，旧行不得伪装成新响应。

筛选能力关闭：`appliedFilters` 固定为空对象；`filterDraft`、筛选 DOM、应用/重置 handler、筛选请求入口均不实例化。游标令牌不得写入 URL、标题或分析日志。

### `viewState`

```text
visibleColumnIds: ["record", "status", "updatedAt", "actions"]
pinnedColumnIds: []
columnWidths: 固定产品配置
density: "comfortable"
rows
resultSummary
presentation: "table" | "card"
```

基础列状态始终存在，但没有用户列偏好、拖拽状态或列控制请求。记录身份、状态和操作属于必需内容，不能无入口隐藏。

### `interactionState`

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
openRowMenu?: {
  recordId,
  triggerControlId,
  menuId,
  menuGeneration,
  permittedActionIds
}
```

选择、全选、全部筛选结果、排除项及选择代次均不实例化；对应 DOM、状态槽、事件 handler 和请求入口均为零。行展开能力也不启用。

### `operationState`

```text
phase:
  idle | submitting | in-flight | success |
  failure | permission-conflict | outcome-unknown
operationId?
operationGeneration
operationSnapshot?
operationSnapshotId?
idempotencyKey?
recordId?
actionId?
errorOwner?
retryIntent?
resultFocusIntent?
```

单行操作快照冻结 `ownerId`、`recordId`、`actionId`、记录版本、权限版本、数据版本、操作 ID、操作代次和预计目标。重复点击、Enter、Space 或事件重放不能创建第二个请求。

批量操作状态不实例化；不存在批量快照、批量 handler、批量请求和批量 DOM。

### `lifecycleGuard`

生命周期是四组状态之外的独立 guard：

```text
ownerId
lifecycleToken
phase: "live" | "disposed"
ownedResources
```

`ownerId` 在实例存活期间稳定；`lifecycleToken` 不复用。

## 3. 查询、游标与状态转换

查询响应只有同时满足以下条件才可写入行、游标、错误、阶段或公告：

```text
live
&& ownerId 匹配
&& lifecycleToken 匹配
&& requestGeneration 匹配
&& snapshotId 匹配
```

`AbortController` 只用于节省资源，不能代替提交门禁。

| 事件 | 状态转换与界面行为 |
| --- | --- |
| 首次进入 | `idle → initial-loading`；无可用数据时显示结构匹配的骨架，结果区 `aria-busy="true"`，骨架无可操作假控件 |
| 首次成功且有记录 | `initial-loading → ready`；提交行、本页游标和数据版本 |
| 首次成功且为空 | `initial-loading → ready`；显示“当前权限范围内暂无记录”和刷新入口 |
| 首次失败 | `initial-loading → initial-error`；用结果区文本错误和可聚焦“重试加载”替代不可用表格 |
| 显式刷新 | `ready/refresh-error → refreshing`；保留上次成功行、已提交游标和焦点意图，结果区保持 `aria-busy="true"` |
| 同一刷新意图重复触发 | 合并到当前请求；不增加快照、代次、请求或开始公告 |
| 刷新成功 | `refreshing → ready`；提交新行和游标，`stale=false` |
| 刷新失败 | `refreshing → refresh-error`；旧行、分页和焦点保持，`stale=true`，显示“刷新失败，当前显示的是上次成功数据”及重试入口 |
| 上一页/下一页 | 用对应不透明游标建立新快照；请求期间保留当前页，成功后才提交新位置 |
| 翻页失败 | 保持原页面及原游标，进入 `refresh-error`，消息说明“未能打开下一页/上一页，仍显示当前页” |
| 重试 | 建立新快照、新 `snapshotId` 和新请求代次，不复用失败响应 |
| 数据版本变化 | 当前游标链立即失效并标记 `stale`，停止继续导航，从初始游标重新查询 |
| 无效游标 | 只执行一次服务端建议的最近有效前向位置恢复；无建议则回初始游标，成功后公告一次，不循环重试 |

分页区只提供“上一页”和“下一页”。缺少相应游标时使用原生 `disabled`。不得显示总页数、页码、跳页、加载更多或无限滚动。结果摘要显示“本页 25 条”或实际返回数量，不虚构总数。

显式刷新、权限变化和游标恢复分别形成不同 `intentKey`；不能因为任意查询在途而阻止不同意图的新请求。

## 4. 行菜单与单行操作

每个有可用行操作的记录显示真实 `<button>`：

```html
<button
  aria-label="打开“记录名称”的操作菜单"
  aria-haspopup="menu"
  aria-expanded="false|true"
  aria-controls="menu-id">
```

菜单使用单一 `role="menu"`，项目使用 `role="menuitem"`。未经授权的动作不渲染，而不是仅以禁用状态泄露。因记录状态暂时不可用的已授权动作可以设置 `aria-disabled="true"`，同时在项目文本中给出原因。

键盘模型：

- `Enter`、`Space` 或点击触发器：打开菜单并聚焦第一个可用项目；
- `ArrowDown`：打开并聚焦第一项；`ArrowUp`：打开并聚焦最后一项；
- 菜单内 `ArrowUp/ArrowDown` 循环移动，`Home/End` 到首末项，并支持文本首字母查找；
- `Enter` 或 `Space` 激活当前项目；
- `Escape` 关闭并返回原触发器；
- `Tab/Shift+Tab` 关闭菜单并按页面顺序离开，不形成焦点陷阱；
- 指针点击外部关闭时，不抢回用户已经移动到的新焦点；
- 路由型菜单项激活后不返回旧触发器，由新路由负责聚焦。

启动“重新同步”时关闭菜单，建立不可变操作快照和新幂等键。`submitting/in-flight` 期间重复触发只记录忽略事件。操作响应使用：

```text
live
+ ownerId
+ lifecycleToken
+ operationId
+ operationGeneration
+ operationSnapshotId
```

六项完整门禁。失配结果只记为 discarded，对 DOM、状态、焦点和公告写入均为零。

操作错误只归受影响记录的操作反馈区，不写入 `queryError`。可重试失败使用新的操作 ID、代次、快照和幂等键。权限冲突单独进入 `permission-conflict`，重新解析权限后由用户决定后续动作，不自动重试，也不复用旧幂等键。结果不完整或无法确认服务端终态时进入 `outcome-unknown`，保留快照并提供“核对结果/刷新记录”入口。

## 5. 权限变化

权限更新按以下顺序原子提交：

1. 重新计算列表读取范围、`resolvedTier` 和各记录允许的动作；
2. 立即移除越权菜单项；
3. 若菜单当前焦点项被移除但还有允许项，聚焦最近的允许项一次；
4. 若菜单已无项目，关闭菜单；触发器仍存在时返回触发器，否则执行记录级焦点迁移；
5. 若全部行操作权限撤销，`resolvedTier` 降为 `display`，一次性移除所有菜单触发器和单行操作入口；
6. 权限范围变化建立新查询快照并回初始游标。

只撤销操作权限而读取范围未变时可以保留行。读取范围缩小或无法证明旧行仍可见时，立即清除未获授权的旧数据，不采用通常的“保留旧行刷新”策略，随后进入无可用结果的加载状态。

权限变化发生在单行操作在途时，不把本地撤权解释成服务端取消。响应仍经完整门禁裁决，但绝不能恢复已撤销的入口。

## 6. 焦点策略

所有恢复均使用稳定的 `recordId + columnId + controlId`，不得使用行索引或 DOM 序号。

通用回退顺序：

1. 同一记录的等价控件；
2. 同一列的下一条记录；
3. 同一列的上一条记录；
4. 结果摘要或标题；
5. 当前分页控件。

最终目标必须存活、可聚焦、有名称，不能是 `document.body`、文档根或已移除节点。

具体约束：

- 后台刷新、刷新失败和操作反馈不抢走仍存活的焦点；
- 行排序位置变化时按 `recordId` 找回原控件，不能落到相同索引的另一记录；
- 用户翻页成功后，焦点只移动一次到带 `tabindex="-1"` 的结果摘要；无效游标自动恢复不产生第二次迁移；
- 行操作导致记录消失时，聚焦下一行同列操作按钮，其次上一行，再到结果摘要；
- 权限降级移除菜单触发器时，优先聚焦同记录详情链接；
- `Escape` 关闭菜单返回触发器；pointer 外部关闭不覆盖新焦点；
- 路由卸载和 disposal 绝不把焦点返回即将移除的触发器。

## 7. Table、ARIA 与公告

桌面使用原生 `<table>`，不使用 ARIA Grid：

- 表格提供 `<caption>` 或 `aria-labelledby + aria-describedby`；
- 列头使用 `<th scope="col">`；
- 记录名称单元格使用 `<th scope="row">`，详情链接只包装名称，不包装整行；
- 操作列标题为“操作”；
- 静态单元格不设置 `tabindex`；
- 表格不接管方向键、Home、End、Page Up 或 Page Down；
- Tab 顺序只进入详情链接、刷新、菜单触发器、重试和分页按钮。

结果区域设置可区分的名称，例如“账号管理列表结果”。加载、刷新中、数据过期、错误和操作执行中都使用可见文本及 ARIA 状态，不只依赖颜色或图标。

查询公告由该实例唯一的 `announcementOwnerId` 管理：

- 每个被接受的查询开始公告一次；
- 结果数量或位置发生变化时公告一次；
- 刷新失败公告一次；
- 成功的无效游标恢复公告一次；
- 被合并、丢弃、取代或 disposal 后到达的事件不公告。

完整错误只在其 primary owner 出现一次；live region 仅播报简洁摘要，不重复朗读整行、全部数据或同一完整错误。

## 8. 桌面与移动端适配

桌面和平板横屏使用原生 Table；空间不足时切换为卡片列表。卡片映射固定为：

- 卡片可访问名称：记录名称与记录编号；
- 直接显示：名称、状态、更新时间；
- 操作：与桌面相同的详情入口和行菜单；
- 每个字段值与可见字段标签关联。

任一时刻只能存在一个活动数据根，Table 和卡片不能同时作为两个可交互实例。断点切换保持同一 `ownerId`、查询、游标、旧数据、刷新状态、操作快照和焦点意图，不发新请求、不重放操作。

打开菜单时切换形态：

- 新形态存在同记录等价锚点：保留同一菜单实例并重新定位；
- 无等价锚点：关闭菜单并执行一次记录级焦点迁移；
- 不允许遗留 portal、悬空 `aria-controls` 或重复菜单。

页面根不得横向溢出。若中间宽度仍采用 Table，横向滚动只发生于结果容器，操作和记录身份必须可到达。移动端不依赖 Hover、长按或滑动发现操作；触摸、鼠标和键盘触发同一意图时必须得到相同状态及重复请求保护。

布局需支持低高度、动态浏览器工具栏、虚拟键盘、四向安全区域、长翻译、字体放大和 200% 浏览器缩放；焦点、错误、分页和主要操作不能被固定区域遮挡。

## 9. Disposal 与实例隔离

路由提交离开或 owner 卸载时，同步且幂等地执行：

1. 将 `lifecycleGuard.phase` 置为 `disposed`，只记录一次；
2. 立即拒绝新的查询、翻页、菜单、操作、焦点和公告工作；
3. abort 查询及单行操作请求，但不宣称服务端工作已取消；
4. 取消失效游标恢复、重试、防抖和节流任务；
5. 关闭行菜单并移除 popup/portal、定位回调和 ARIA 引用，不等待关闭动画；
6. 失效排队中的微任务、`requestAnimationFrame` 焦点、公告和操作结果回调；
7. 注销 router、权限、网络、媒体查询订阅，以及 scroll/resize/keyboard/pointer 监听；
8. 释放 timeout、interval、ResizeObserver、IntersectionObserver、菜单定位器和动画完成回调；
9. 移除当前实例 DOM；
10. 每项资源按 `ownerId` 只释放一次。

所有迟到回调仍执行完整门禁；失败后只能记录对应 discarded 事件，DOM、状态、焦点和 live region 写入必须为零。一个列表的 disposal 不得关闭或清理另一列表的菜单、请求、错误或焦点。

旧触发器不接收返回焦点。新路由提交后，只由新路由自己的策略聚焦一次到主标题、主内容或主要操作。

本实例明确声明：返回列表时不恢复旧游标、菜单、操作状态或滚动位置；创建新的 `ownerId` 和 `lifecycleToken`，从初始游标重新查询。

## 10. 真实运行环境尚未验证的边界

以下内容仍需在真实实现中验证，当前不能视为已经通过：

- 真实游标 API 的上一页/下一页令牌、缺失方向、过期游标和单次恢复；
- `datasetVersion` 跨页一致性，以及数据变化时是否确实无重复或遗漏；
- 刷新、连续翻页、权限推送和单行操作交错返回的竞态；
- Abort 失败后迟到查询、操作和菜单定位回调的零写入门禁；
- 服务端幂等键、权限冲突和 `outcome-unknown` 恢复契约；
- Chrome、Safari、Firefox 中原生 Table、portal 菜单和滚动容器组合；
- NVDA、JAWS、VoiceOver 对表格标题、`aria-sort`、菜单和 live region 的实际朗读；
- 纯键盘完成刷新、翻页、菜单、重试，以及菜单项或整行动态消失时的焦点恢复；
- `1440×900`、`1280×720`、平板横竖屏、窄屏手机和低高度横屏手机；
- 200% 缩放、字体放大、长翻译、高对比度、Reduced Motion；
- 触摸目标、虚拟键盘、动态视口和四向安全区域；
- Table/卡片实时切换期间打开菜单、刷新在途和操作在途的单实例保持；
- 路由卸载时每类资源释放一次、旧回调零写入及新路由仅一次聚焦；
- 同页两个实例使用相同代次数值时的 `ownerId + lifecycleToken` 隔离。

## 11. 应用检查清单

| 原子规则族 | 适用性 | 验证状态 | 正文定位或零值证据 |
| --- | --- | --- | --- |
| 能力与状态 | 适用 | 设计已定义；运行时未验证 | 第 1、2 节 |
| 查询 | 适用 | 设计已定义；运行时未验证 | 第 3 节的快照与五项提交门禁 |
| 筛选 | 不适用 | 零入口约束已定义 | 无筛选 DOM；仅固定空 `appliedFilters`，无 `filterDraft`；无 handler；无筛选请求 |
| 排序 | 适用 | 设计已定义；运行时未验证 | 第 1、7 节的固定稳定排序、`aria-sort` 及无交互契约 |
| 分页 | 适用 | 设计已定义；运行时未验证 | 第 3 节的唯一 cursor 模式和固定 `pageSize=25` |
| 数据状态 | 适用 | 设计已定义；运行时未验证 | 第 3 节的加载、错误、过期和空状态 |
| 选择 | 不适用 | 零入口约束已定义 | 无选择 DOM、状态槽、事件 handler 或请求 |
| 单行操作 | 适用 | 设计已定义；运行时未验证 | 第 4、5 节 |
| 批量操作 | 不适用 | 零入口约束已定义 | 无批量 DOM、状态槽、handler 或请求 |
| 基础列状态 | 适用 | 设计已定义；运行时未验证 | 第 2 节 `viewState` |
| 可选列控制 | 不适用 | 零入口约束已定义 | 无列控制 DOM、偏好/拖拽状态、handler 或请求 |
| Table 语义 | 适用 | 设计已定义；辅助技术未验证 | 第 7 节 |
| ARIA Grid 语义 | 不适用 | 零入口约束已定义 | 无 `role="grid"`、活动单元格状态、Grid 键盘 handler 或请求 |
| 键盘 | 适用 | 设计已定义；真实键盘未验证 | 第 4、6、7 节 |
| 焦点 | 适用 | 设计已定义；真实焦点事件未验证 | 第 6 节 |
| 响应式 | 适用 | 设计已定义；真实视口未验证 | 第 8 节 |
| ARIA 与公告 | 适用 | 设计已定义；读屏未验证 | 第 4、7 节 |
| disposal | 适用 | 设计已定义；真实卸载竞态未验证 | 第 9 节 |
| 实例隔离 | 适用 | 设计已定义；多实例运行时未验证 | 第 9 节 |
| 运行时验证边界 | 适用 | 未验证 | 第 10 节列出的真实 API、浏览器、辅助技术、输入和视口环境 |
<!-- END RAW OUTPUT -->
