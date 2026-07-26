# Attempt 7：批量操作数据表格

spawn args: `task_name=attempt_7_bulk_action_table`, `fork_turns=none`, model/reasoning_effort not sent

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个 bulk-action 数据表格。它要支持当前页选择，以及可选的“全部筛选结果”选择模式、排除项、筛选变化、部分成功、失败项重试和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配、选择与查询的关系，以及 disposal 后旧响应和资源如何处理；同时列出尚未通过真实运行环境验证的边界。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

spawn tool return: `{"task_name":"/root/table_task5_takeover/attempt_7_bulk_action_table"}`

completion metadata: Message Type `FINAL_ANSWER`, recipient `/root/table_task5_takeover`, sender `/root/table_task5_takeover/attempt_7_bulk_action_table`

<!-- BEGIN RAW OUTPUT -->
# Bulk-action 数据表格实现说明

## 1. 能力声明与边界

本实例固定声明：

| 能力 | 当前值 |
| --- | --- |
| `capabilityTier` | `bulk-action` |
| `resolvedTier` | `bulk-action`；权限降级时可变为 `row-action` 或 `display` |
| `filteringEnabled` | `true`，显式应用 |
| `sortingEnabled` | `true`，单列业务排序 |
| `paginationMode` | `numbered` |
| `pageSize` | `25` |
| `pageSelectionEnabled` | `true` |
| `allFilteredSelectionEnabled` | `true`，但必须满足下述服务端前提；否则整个能力关闭 |
| `rowOperationEnabled` | `false` |
| `bulkOperationEnabled` | `true` |
| `columnVisibilityEnabled` | `false` |
| `columnPinningEnabled` | `false` |
| `columnResizeEnabled` | `false` |
| `responsivePresentation` | 保持原生 Table，以受控横向滚动适配窄屏，不转换为卡片 |

默认排序为 `updatedAt DESC NULLS LAST, recordId ASC`；大小写按 Unicode case-fold 规则、文本比较使用 `zh-CN` locale，`recordId` 是唯一、不可变的稳定次序键。若业务不能接受这组排序，必须用另一组完整、确定且包含唯一稳定键的配置整体替换，不能仅依赖数据库偶然顺序。

“全部筛选结果”只有在服务端同时提供以下能力时启用：

- 每条记录有跨分页稳定且不可复用的 `recordId`。
- 查询返回可靠的 `eligibleTotal`、权限范围标识和不可变 `datasetVersion` 或等价服务端快照。
- 服务端能按冻结筛选范围加 `excludedIds` 原子解析目标集合。
- 批量端点支持幂等键、权限与版本复核、逐项裁决或可核对的目标集合令牌。
- 可以区分成功、失败、不可重试、权限冲突、版本冲突和结果未知。

任一条件缺失时，`allFilteredSelectionEnabled=false`；DOM 中不出现入口，不建立相关状态槽、handler 或请求。当前页选择仍可保留。

首版不支持行内编辑、Shift 连续范围选择、任意跨页手工累积、无限滚动、加载更多、拖拽排序、离线队列、自动重试和客户端推测批量成功。服务端始终是记录资格、权限和最终执行结果的权威。

## 2. 状态所有权

四组状态必须分开维护，不能合并成一个 `loading`、`selected` 或 `error`。

### `queryState`

至少包含：

```text
appliedFilters
sortRules
pagination
pageSize
querySnapshot
snapshotId
datasetVersion
requestGeneration
requestPhase
queryError
stale
```

`requestPhase` 为：

```text
idle
initial-loading
ready
refreshing
initial-error
refresh-error
```

每次应用筛选、排序、翻页、改变页大小或接受刷新时，先冻结不可变 `querySnapshot`，内容至少包括已应用筛选、完整稳定排序、页码、页大小、权限范围和数据版本，再创建新的 `snapshotId` 并递增 `requestGeneration`。

查询响应只有同时满足以下条件才可提交：

```text
live
ownerId 匹配
lifecycleToken 匹配
requestGeneration 匹配
snapshotId 匹配
```

取消请求只用于节省资源，不代替该门禁。

### `viewState`

始终包含：

```text
visibleColumnIds
pinnedColumnIds
columnWidths
density
rows
resultSummary
```

本实例没有用户列控制，因此 `visibleColumnIds` 来自固定配置，`pinnedColumnIds=[]`，`columnWidths` 只保存系统布局值；不得渲染列显示、固定或调宽入口，也不得注册对应 handler。

### `interactionState`

至少包含：

```text
focusIntent
focusedRecordId
focusedColumnId
expandedRecordIds
selectionMode
selectedIds
selectionGeneration
selectionSnapshot
```

`selectionMode` 仅为 `page | all-filtered`。不得以单一 `allSelected=true` 表示全部筛选结果。

全部筛选结果的不可变 `selectionSnapshot` 至少冻结：

```text
selectionSnapshotId
sourceQuerySnapshotId
rangeKey
appliedFilters
permissionScope
datasetVersion
eligibleTotal
excludedIds
selectionGeneration
```

`excludedIds` 是快照内部字段，不得作为可独立漂移的 sibling 状态。

### `operationState`

至少包含：

```text
phase
operationId
operationGeneration
operationSnapshot
idempotencyKey
successIds
failedItems
conflicts
resultSummary
resultFocusIntent
```

`phase` 为：

```text
idle
confirming
submitting
in-flight
all-succeeded
partially-succeeded
all-failed
permission-conflict
version-conflict
outcome-unknown
```

其中 `outcome-unknown` 不是业务终态，禁止据此清理选择或直接重试。

### `lifecycleGuard`

生命周期不计入上述四组，单独维护：

```text
ownerId
lifecycleToken
live | disposed
ownedResources
```

同页多个表格的 generation 数值可以相同，但只能在各自 `ownerId + lifecycleToken` 命名空间内解释。

## 3. 选择模型及其与查询的关系

### 当前页选择

初始为 `selectionMode=page`、`selectedIds=[]`。

- 行复选框只选择当前页中明确可选记录的稳定 ID。
- 不可选记录不得进入 ID 集合或计数；复选框禁用，并显示、关联不可选原因。
- 表头复选框永远只表示当前页可选记录：
  - 全部已选：checked。
  - 部分已选：mixed。
  - 有可选项但未选：unchecked。
  - 当前页无可选项：unchecked 且 disabled，并提供持续可见的原因。
- 点击表头复选框只增删当前页可选记录，不代表整个查询集合。

`page` 模式在以下任一事件提交时立即清空：

- 应用、移除或重置筛选。
- 提交排序。
- 翻页。
- 改变页大小。
- 权限范围或数据版本改变。

只编辑尚未应用的筛选草稿不影响选择，也不创建查询。

### 提升为全部筛选结果

只有当前页已完成选择后，才显示独立范围提示，例如：

> 已选择本页 25 条。选择当前筛选条件下全部 1,284 条可操作记录。

用户显式确认后：

1. 建立不可变 `selectionSnapshot`。
2. 冻结已应用筛选、范围键、权限范围、数据版本和可靠 `eligibleTotal`。
3. 初始化 `excludedIds=[]`。
4. 切换到 `all-filtered`。
5. 持续显示“已选 1,284 条，排除 0 条”和可清除入口。

普通翻页只有在范围键、权限范围和数据版本都不变时才保留该模式。每页表头仍只反映该页记录结合 `excludedIds` 后的三态。

在 `all-filtered` 模式中：

- 取消某行：递增 `selectionGeneration`，创建后继快照，将 ID 加入新快照的 `excludedIds`。
- 重新选择：递增代次，创建后继快照，仅从新快照排除集合中移除该 ID。
- 可见选中数为 `eligibleTotal - 有效 excludedIds 数量`。
- 旧快照保持不可变，写入次数必须为 0。

### 查询变化处理

| 变化 | `page` 模式 | `all-filtered` 模式 |
| --- | --- | --- |
| 编辑未应用筛选草稿 | 保留 | 保留 |
| 应用/移除/重置筛选 | 立即清空 | 立即失效并清空 |
| 普通翻页 | 清空 | 范围、权限、版本一致时保留 |
| 页大小变化 | 清空 | 清空并重新选择 |
| 排序提交 | 清空 | 进入“待重新确认”；确认新范围和数量前禁止操作，取消则清空 |
| 权限范围变化 | 清空 | 立即失效并清空 |
| 数据版本变化 | 清空 | 立即失效并清空 |
| 同范围记录资格变化 | 移除失效 ID | 移除失效排除/目标、更新总数并公告一次 |

应用新筛选后，旧行若在刷新期间保留，必须标明“上一查询结果，正在加载新条件”，并禁用基于旧行建立选择；不得把旧结果伪装为已匹配新筛选。

### 选择代次契约

| 路径 | `generationEffect` | `snapshotEffect` | `commitGuard` | `mismatchEffect` |
| --- | --- | --- | --- | --- |
| 资格变化 | `selectionGeneration +1` | 创建新的不可变后继 `selectionSnapshot`；旧快照写入为 0 | 当前 live owner、范围键、权限范围和数据版本均仍适用 | 失效结果不得提交，旧快照和当前选择写入均为 0 |
| 异步选择协调回调 | 不自行改变；仅提交创建时捕获的代次结果 | 只有匹配结果可成为当前快照 | `live + ownerId + lifecycleToken + selectionGeneration` 全部匹配 | 只记录 `selection-result-discarded`，选择写入为 0 |
| 操作结果调整当前选择 | 仅在捕获代次等于当前代次时按意图递增 | 匹配时创建移除成功项后的后继状态，不原地修改操作快照 | 捕获的 `selectionGeneration === 当前 selectionGeneration` | 只写 operation result owner；选择写入为 0 |

## 4. 批量操作与结果恢复

非空、有效、非待重新确认且非 stale 的选择才能进入确认。确认面板使用表格内联区域，不另建 Modal，内容包括：

- 操作名称与风险等级。
- 预计影响数量。
- 已应用筛选摘要。
- 排除项数量。
- 当前不可操作项数量。
- 取消和明确确认入口。

破坏性操作必须二次确认；不可逆或高影响操作还需与风险相称的强确认，例如输入操作名称或重新认证。确认字段必须有可见标签和错误关联。

开始执行时建立不可变 `operationSnapshot`，冻结：

```text
ownerId
operationId
operationGeneration
operationType
selectionGeneration
selectionMode
selectedIds 或完整 selectionSnapshot
excludedIds
expectedCount
permissionScope
datasetVersion
operationSnapshotId
```

每次尝试使用新幂等键。同一操作处于 `submitting` 或 `in-flight` 时，点击、Enter、Space 或事件重放都不得创建第二请求。

响应只有同时满足以下六项才可进入裁决：

```text
live
ownerId
lifecycleToken
operationId
operationGeneration
operationSnapshotId
```

此外必须满足：

- `adjudicatedCount === expectedCount`。
- 成功和失败集合不重叠、无重复、无外部 ID。
- 两集合并集精确等于操作快照目标集合或服务端冻结集合令牌对应的集合。

否则进入 `outcome-unknown`：保留操作快照、选择和已有失败信息，显示“核对执行结果”入口；禁止选择清理、成功子集重整和直接重试。网络断开且无法确定服务端是否执行，也按 `outcome-unknown` 处理，不得伪装成全部失败。

终态处理：

- **全部成功**：成功数等于预计数且失败为零。只有选择代次仍匹配时清除本次完成项；随后创建新查询快照刷新，并公告一次。
- **部分成功**：成功与失败均非空。成功项不得再次执行；选择代次匹配时仅从当前选择移除成功项。操作结果区保留每个失败 ID、具体原因、是否可重试和恢复入口；刷新成功子集，但不得清除失败摘要。
- **全部失败**：成功为零且失败数等于预计数。选择代次匹配时保留原选择，操作快照始终保留。
- **权限冲突**：重新解析可操作范围，移除越权项并要求用户确认新数量；不得自动重试越权项。
- **版本冲突**：使旧操作快照失效，刷新数据，要求重新选择或重新确认；不得自动复用旧幂等键。

“重试失败项”必须创建新的 `operationId`、`operationGeneration`、不可变快照和幂等键，只包含明确标记为可重试的失败 ID。已成功项和不可重试项的重试请求数必须为 0。若结果未知，必须先通过状态查询或同一幂等语义完成核对，不能盲目建立新重试。

## 5. 加载、错误与空状态

查询、选择和批量操作分别拥有自己的错误与公告通道，不得互相覆盖。

- **首次加载**：无可用行时显示与最终列结构相符的不可操作骨架；结果容器 `aria-busy="true"`，骨架不包含复选框、按钮或假数据。
- **刷新**：保留上次成功行、分页和焦点意图，结果容器 busy。若当前选择仍可能受版本变化影响，保留其可见摘要但禁用新批量提交并说明“正在核对数据”。
- **首次加载失败**：以结果区域内的文本错误和可聚焦“重试加载”替代表格。
- **刷新失败**：保留旧行和分页，设置 `stale=true`，显示“数据可能已过期”；保留选择用于恢复，但禁止开始新的批量操作，直到成功刷新或用户清除选择。
- **筛选零结果**：显示“当前筛选条件无匹配结果”，提供调整或清除筛选入口。
- **空数据集**：显示与权限和能力匹配的独立空状态，不使用含糊的“暂无数据”。
- **操作失败**：只显示在批量结果摘要及对应失败项，不写入 `queryError`，也不清空查询结果或筛选。
- 同一完整错误只有一个 primary owner 和一条完整公告路径。

## 6. 键盘、焦点与 ARIA

### 语义与键盘

使用原生 `<table>`，不使用 `role="grid"`：

- 表格由 `<caption>` 或 `aria-labelledby` 提供可区分名称。
- 表头使用 `<th scope="col">`，必要的行标题使用 `<th scope="row">`。
- 静态单元格不设置 `tabindex="0"`。
- Table 不接管方向键、Home、End、Page Up 或 Page Down。
- Tab 只进入真实复选框、排序按钮、筛选控件、分页和批量操作。
- Space 切换复选框；Enter/Space 激活按钮；Shift+Tab 按视觉与 DOM 逆序返回。
- 禁止用整行点击替代复选框，也不实现未声明的 Shift 范围选择。

行复选框名称应包含记录身份，例如“选择记录：订单 1024”。表头复选框名称应包含范围和数量，例如“选择当前页，已选 3 条，共 18 条可选”。原生复选框用 `checked` 与 `indeterminate` 表达三态；不可选原因通过稳定的 `aria-describedby` 指向可见文本。

不要在整行重复设置 `aria-selected`；本实例的选择 owner 是复选框。批量工具栏使用具名称的 `region`，持续显示模式、总选中数、排除数和不可操作数。

结果容器查询期间设置 `aria-busy`。不得把整个表格设为 live region。查询、选择范围和操作结果各有唯一公告 owner：

- 查询开始、结果数量/位置变化、失败各简短公告一次。
- 切换全部范围、资格数量变化各简短公告一次。
- 批量开始及最终状态各简短公告一次。
- 部分成功只公告汇总，如“18 条成功，2 条失败”，不逐行朗读。
- 被合并、丢弃、取代或 disposal 后到达的事件公告数为 0。

### 焦点规则

- 勾选、取消或切换表头三态不移动焦点。
- 打开内联确认后，焦点移动一次到确认标题或首个强确认字段；取消后返回原批量按钮，前提是目标仍存活。
- 应用筛选或排序发请求时不抢走仍存活的触发控件焦点。
- 用户翻页且新结果提交后，焦点移动一次到结果摘要/标题；自动失效页恢复不得再次抢焦点。
- 操作结果提交后，原焦点仍存活、可聚焦且语义未变时不移动。目标消失时仅一次移到结果摘要、首个失败项、重试按钮、重新确认或结果核对入口。
- 恢复焦点使用 `recordId + columnId + controlId`，不得使用数组索引。
- 任何最终目标必须存活、有名称且与事件相关；不得落到 `document.body`、文档根或已移除节点。
- 迟到查询、操作、动画和排队任务不得夺取焦点。

## 7. 桌面与移动端

桌面使用完整表格、内联筛选区、选择摘要和批量工具栏。窄屏仍保持同一 Table 实例：

- 筛选区可折叠为页面内区域，但已应用条件摘要和独立移除入口持续可见。
- 表格仅在具名称的表格容器内横向滚动；页面根不得横向溢出，也不引入第二个纵向滚动区。
- 选择列、记录身份、主要状态和主要操作按最前优先级排列；次要字段通过横向滚动访问，不得以 `display:none` 删除。
- 容器以阴影、文字或等价非颜色单一方式提示当前仍可横向滚动的方向。
- 批量摘要和确认区在文档流内重排为单列，不使用会遮挡焦点或虚拟键盘的固定底栏。
- 所有触摸目标建议至少 `44×44 CSS px`，并保留键盘替代路径。
- 旋转、改变断点或输入方式时保持同一 `ownerId`，保留查询、分页、选择、排除项、操作快照和焦点意图；不得新增查询、重放批量操作或重建代次。
- 支持 200% 缩放、字体放大、长文本、低高度、动态视口、虚拟键盘和四向安全区域。关键流程不得同时要求页面和表格双向滚动。

## 8. 路由卸载与 disposal

路由提交离开或表格 owner 卸载时，立即进入 `disposed`，不等待动画、查询或批量结果。disposal 幂等，同一实例只记录一次。

必须取消或失效：

- 查询请求、分页恢复、刷新、重试和防抖。
- 行菜单、popup、定位和动画完成回调。
- 选择协调、操作结果、live-region 公告和排队焦点任务。
- 计时器、DOM/窗口监听器、观察器、订阅和 AbortController。
- 该实例创建的临时 DOM、ARIA 引用和资源句柄。

每项资源记录所属 `ownerId`，只释放一次且只释放本实例资源。旧实例不能清理新路由或同页其他表格的选择、错误、公告、滚动和焦点。

取消只是资源优化。所有迟到响应仍必须执行完整提交门禁；失败时只记录 `query-response-discarded`、`selection-result-discarded` 或 `operation-result-discarded`，DOM、状态、焦点和 live-region 写入均为 0。

路由离开不代表服务端批量任务已取消。若服务端已经接受操作，必须凭 `operationId` 和幂等键在任务中心或重新进入后的状态查询中核对；不得在旧组件中显示“已取消”。

旧触发器随路由移除时不得返回焦点。新路由提交后，仅由新路由策略移动一次到主标题、主内容或首个主要操作。

返回页面是否恢复查询和滚动位置由产品显式配置；恢复前重新校验权限、数据版本和有效页码。旧选择、排除项、权限结果、菜单和操作快照一律不回放；新实例必须使用新的 `ownerId` 和 `lifecycleToken`。

## 9. 尚未通过真实运行环境验证的边界

以下均为设计契约，尚未声明为运行时通过：

- Chrome、Firefox、Safari、Edge 下的原生复选框混合态、表格 header 关联和 disabled 原因读取。
- NVDA + Firefox/Chrome、JAWS + Chrome、VoiceOver + Safari/iOS、TalkBack + Android 的名称、状态、公告去重和焦点恢复。
- 纯键盘、鼠标、触摸以及输入方式中途切换。
- `1440×900`、`1280×720`、平板横竖屏、窄屏和低高度横屏手机。
- 200% 缩放、系统字体放大、长文本、国际化扩展、高对比度、Reduced Motion、动态浏览器工具栏、虚拟键盘和四向安全区域。
- 真实横向滚动边界、焦点环可见性和页面根无横向溢出。
- 快速筛选、排序、翻页、刷新造成的乱序响应，以及取消后仍迟到的响应。
- 可靠 `eligibleTotal`、权限漂移、资格变化、数据版本变化和全部范围的服务端原子解析。
- 重复点击、Enter、Space、事件重放下的请求 exactly-once 与幂等性。
- 全部成功、部分成功、全部失败、权限冲突、版本冲突、重复/缺失/外部 ID 和 `outcome-unknown`。
- 仅重试可重试失败项且绝不再次执行成功项或不可重试项。
- 查询、操作、重试、popup、计时器、观察器和排队焦点均待处理时的 route/unmount disposal。
- 两个同页表格 generation 数值相同、响应交错及其中一个 disposal 时的实例隔离。
- 浏览器硬卸载、断网及服务端任务继续执行后的状态核对路径。

## 10. 完成前应用检查清单

| 原子规则族 | 适用性 | 验证状态 | 定位或零值依据 |
| --- | --- | --- | --- |
| 能力与状态 | 适用 | 静态设计已定义；运行时未验证 | 第 1、2 节 |
| 查询 | 适用 | 静态设计已定义；运行时未验证 | `querySnapshot` 与五项响应门禁 |
| 筛选 | 适用 | 静态设计已定义；运行时未验证 | 草稿/已应用值分离、显式应用、筛选变化矩阵 |
| 排序 | 适用 | 静态设计已定义；运行时未验证 | 固定完整排序、分页复位、全部范围重新确认 |
| 分页 | 适用 | 静态设计已定义；运行时未验证 | 唯一 numbered 模式、pageSize 25、边界与焦点策略 |
| 数据状态 | 适用 | 静态设计已定义；运行时未验证 | 第 5 节 |
| 选择 | 适用 | 静态设计已定义；运行时未验证 | 第 3 节及唯一选择代次契约表 |
| 单行操作 | 不适用 | 配置边界待实现核验 | 不渲染 DOM；不建立状态槽、handler、事件或请求入口 |
| 批量操作 | 适用 | 静态设计已定义；运行时未验证 | 第 4 节 |
| 基础列状态 | 适用 | 静态设计已定义；运行时未验证 | `viewState` 固定字段 |
| 可选列控制 | 不适用 | 配置边界待实现核验 | 显示、固定、调宽入口及对应状态写入、handler、请求均为 0 |
| Table 语义 | 适用 | 静态设计已定义；运行时未验证 | 原生 `<table>`、caption、`th` 关联 |
| ARIA Grid 语义 | 不适用 | DOM 边界待实现核验 | 不渲染 `role=grid`，无 roving tabindex 或 Grid 键盘 handler |
| 键盘 | 适用 | 运行时未验证 | 第 6 节 |
| 焦点 | 适用 | 运行时未验证 | 稳定 ID 焦点意图及一次迁移规则 |
| 响应式 | 适用 | 运行时未验证 | 第 7 节 |
| ARIA 与公告 | 适用 | 辅助技术未验证 | 第 6 节唯一 owner 与公告去重 |
| disposal | 适用 | 运行时未验证 | 第 8 节 |
| 实例隔离 | 适用 | 运行时未验证 | `ownerId + lifecycleToken` 命名空间及资源归属 |
| 运行时验证边界 | 适用 | 未验证 | 第 9 节所列浏览器、设备、辅助技术与真实服务端场景 |
<!-- END RAW OUTPUT -->
