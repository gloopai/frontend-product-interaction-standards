# Attempt 5 FAILED：批量操作数据表格（原始证据）

## Spawn arguments

- `task_name=attempt_5_bulk_action_table`
- `fork_turns=none`
- `model` was not sent.
- `reasoning_effort` was not sent.
- Exact `message`:

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个 bulk-action 数据表格。它要支持当前页选择，以及可选的“全部筛选结果”选择模式、排除项、筛选变化、部分成功、失败项重试和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配、选择与查询的关系，以及 disposal 后旧响应和资源如何处理；同时列出尚未通过真实运行环境验证的边界。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

## Spawn tool return

`{"task_name":"/root/table_task5_green/attempt_5_bulk_action_table"}`

## Completion envelope metadata

- `Message Type FINAL_ANSWER`
- recipient `/root/table_task5_green`
- sender `/root/table_task5_green/attempt_5_bulk_action_table`

<!-- BEGIN RAW OUTPUT -->
# Bulk-action 数据表格实现设计

## 1. 能力声明与边界

本实例的当前配置如下：

| 能力项 | 当前值 |
|---|---|
| `capabilityTier` | `bulk-action` |
| `resolvedTier` | `bulk-action`；权限解析后可原子降级为 `row-action` 或 `display` |
| `filteringEnabled` | `true` |
| `sortingEnabled` | `true`，单列交互排序 |
| `paginationMode` | `numbered` |
| `pageSize` | `25`，允许值为 `25 / 50 / 100` |
| `pageSelectionEnabled` | `true` |
| `allFilteredSelectionEnabled` | `true` |
| `rowOperationEnabled` | `false` |
| `bulkOperationEnabled` | `true` |
| `columnVisibilityEnabled` | `false` |
| `columnPinningEnabled` | `false` |
| `columnResizeEnabled` | `false` |
| `responsivePresentation` | `table-to-cards`：宽屏原生 Table，窄屏使用经过显式字段映射的卡片列表 |

以下能力不在本版范围内：行内编辑、树形表格、拖拽行排序、透视表、加载更多、无限滚动、拖拽列排序和个人布局持久化。对应 DOM、状态槽、handler 和请求入口都不得存在。

“全部筛选结果”依赖后端同时提供稳定记录 ID、可靠的可选总数、不可变 `datasetVersion` 或等价服务端范围令牌、确定性排序、幂等批量接口以及逐项裁决结果。任一能力缺失时，必须把 `allFilteredSelectionEnabled` 解析为 `false`，仅保留当前页选择，不能用客户端遍历分页模拟“全部”。

本设计中的断点、批量动作清单、风险等级和列映射属于本产品实例配置；它们不得改变下述快照、提交门禁、错误归属和 disposal 规则。

## 2. 固定状态结构

实现只能使用以下四组业务状态；生命周期另由独立 guard 管理。

### `queryState`

至少包含：

```ts
type QueryState = {
  filterDraft: FilterValues
  appliedFilters: FilterValues
  sortRules: SortRule[]
  pagination: {
    mode: 'numbered'
    page: number
    totalPages?: number
    totalCount?: number
  }
  pageSize: 25 | 50 | 100
  querySnapshot?: QuerySnapshot
  snapshotId?: string
  datasetVersion?: string
  requestGeneration: number
  requestPhase:
    | 'idle'
    | 'initial-loading'
    | 'ready'
    | 'refreshing'
    | 'initial-error'
    | 'refresh-error'
  queryError?: QueryError
  stale: boolean
}
```

每次查询前冻结不可变 `querySnapshot`，内容至少包括：

```ts
{
  snapshotId,
  appliedFilters,
  sortRules,
  paginationMode: 'numbered',
  page,
  pageSize,
  permissionScope,
  datasetVersion,
  requestGeneration
}
```

查询响应只有同时匹配 `live`、`ownerId`、`lifecycleToken`、`requestGeneration` 和 `snapshotId` 才能提交。

### `viewState`

始终包含：

```ts
type ViewState = {
  visibleColumnIds: string[]
  pinnedColumnIds: []                 // 当前能力关闭
  columnWidths: Record<string, number> // 产品默认值，只读
  density: 'comfortable'
  rows: Row[]
  resultSummary: ResultSummary
}
```

关键身份列、主要状态列和批量选择入口固定可见。由于列显隐、固定和调宽均关闭，不渲染相应控制器，不注册 handler，也不因列状态发查询。

### `interactionState`

```ts
type InteractionState = {
  focusIntent?: {
    sourceEvent: string
    recordId?: string
    columnId?: string
    controlId?: string
    fallbackId: string
  }
  focusedRecordId?: string
  focusedColumnId?: string
  expandedRecordIds: Set<string>
  openRowOperation: undefined // 单行操作未实例化
  selectionMode: 'page' | 'all-filtered'
  selectedIds: Set<string>    // 仅 page 模式使用
  selectionGeneration: number
  selectionSnapshot?: SelectionSnapshot
  selectionValidity: 'valid' | 'pending-reconfirmation' | 'invalid'
}
```

`excludedIds` 只能位于不可变 `selectionSnapshot` 内部，不得作为同级状态：

```ts
type SelectionSnapshot = Readonly<{
  selectionSnapshotId: string
  sourceQuerySnapshot: QuerySnapshot
  filterScopeKey: string
  appliedFilters: FilterValues
  permissionScope: PermissionScope
  datasetVersion: string
  eligibleTotal: number
  excludedIds: ReadonlySet<string>
}>
```

### `operationState`

```ts
type OperationState = {
  phase:
    | 'idle'
    | 'confirming'
    | 'submitting'
    | 'in-flight'
    | 'all-success'
    | 'partial-success'
    | 'all-failed'
    | 'permission-conflict'
    | 'dataset-version-conflict'
    | 'outcome-unknown'
  operationId?: string
  operationGeneration: number
  operationSnapshot?: OperationSnapshot
  idempotencyKey?: string
  successIds: Set<string>
  failedItems: Array<{
    recordId: string
    reason: string
    retryable: boolean
  }>
  conflict?: OperationConflict
  operationError?: OperationError
  resultFocusIntent?: FocusIntent
}
```

单行操作未启用，因此没有单行操作状态、DOM、事件或请求入口。批量错误只写 `operationState`，不能写入 `queryError`。

### 独立 `lifecycleGuard`

```ts
type LifecycleGuard = {
  ownerId: string
  lifecycleToken: string
  live: boolean
  disposed: boolean
  ownedResources: Set<OwnedResource>
}
```

它不属于上述四组状态。每个资源都记录持有者 `ownerId`，并且只能释放一次。

## 3. 查询、筛选、排序和分页

### 筛选

筛选字段 owner 管理自己的 `value / initialValue / touched / dirty / syncErrors / asyncErrors / serverErrors / errorVisible / validationGeneration`。表格只接收字段已经校验并提交的业务值；搜索文本、候选项、高亮项和未提交 popup 草稿不能进入 `filterDraft` 或查询参数。

本实例配置：

- `status`：`applyMode: immediate`，仅在合法业务值提交后应用。
- `keyword`、日期范围等复合条件：`applyMode: explicit`，点击“应用筛选”后才从 `filterDraft` 写入 `appliedFilters`。
- `defaultFilters = { status: 'active', keyword: '', dateRange: null }`。
- “重置”恢复 `defaultFilters`，语义未变化时不发请求。
- 每个已应用条件持续显示为带名称的摘要项，并提供独立移除按钮；折叠的筛选控件不能让已应用条件从摘要消失。
- 只有显式标记 `urlSafe` 的枚举条件进入 URL。关键词、账号、个人识别信息和所有 `sensitive` 条件不得进入 URL、标题或分析日志。
- 字段错误归字段 owner；多字段校验失败可由筛选表单错误摘要导航到字段，但不能写成查询错误。

应用、移除或有效重置筛选时：

1. 更新 `appliedFilters` 和可见筛选摘要；
2. 页码回到第 1 页；
3. 创建新 `querySnapshot` 并递增 `requestGeneration`；
4. 清除 page 选择；
5. 立即使旧 all-filtered 范围失效并清除；
6. 旧查询响应只能被门禁丢弃。

### 排序

当前实际排序为：

```ts
[
  {
    key: 'updatedAt',
    direction: 'desc',
    nulls: 'last',
    caseMode: 'not-applicable',
    locale: 'not-applicable',
    natural: false
  },
  {
    key: 'recordId',
    direction: 'asc',
    stableTieBreaker: true
  }
]
```

`recordId` 必须唯一、不可变。若用户改为字符串列排序，该列的产品配置固定为大小写不敏感、`zh-CN-u-kn-true` locale、自然数字排序；这些比较规则必须随业务键一起进入快照。

可排序表头使用真实按钮。原生表格只在当前主排序表头设置正确的 `aria-sort`；不可排序列不显示排序按钮，也不设置 `aria-sort`。

提交新排序后页码回第 1 页并创建新查询：

- page 模式立即清除选择；
- all-filtered 模式进入 `pending-reconfirmation`，批量操作被阻止；
- 界面显示新排序下的范围与数量，用户确认后建立绑定新查询快照的新选择快照；
- 用户取消重新确认则清除选择。

### 页码分页

总数可靠时显示当前页、总页数和结果范围，提供上一页、下一页、直接页码及有标签的跳页输入。当前页用 `aria-current="page"`；首页和末页边界使用原生 `disabled`。越界或非法页码不得发请求。

改变 `pageSize` 时回第 1 页。服务端拒绝的页大小不能成为当前值。

当删除或数据变化导致当前页超过最新末页时，只请求一次最近有效页且不小于 1；恢复成功后播报一次新位置，重复的失效响应不能形成循环请求。

用户翻页时记录来源。匹配响应提交后，焦点移动一次到结果摘要或标题；若分页触发器仍存活且产品明确选择保留它，则不移动。自动失效页恢复不得造成第二次焦点跳转。

## 4. 选择与查询范围的关系

### 当前页模式

初始 `selectionMode` 必须是 `page`。

- 行复选框只使用稳定 `recordId`。
- `selectedIds` 始终是当前页 `eligibleIds` 的子集。
- 不可选行不进入选择或数量；禁用复选框通过 `aria-describedby` 说明权限、状态或业务规则原因。
- 表头复选框只控制当前页可选记录，不能代表全数据集。
- 当前页全选为 checked，部分选择为 mixed，零选择为 unchecked。
- 当前页没有可选记录时，表头复选框为 unchecked、原生禁用，并显示“本页没有可选记录”的具体原因。
- 应用/移除/重置筛选、排序、翻页、改变页大小、权限范围变化或数据版本变化一旦提交，page 选择立即清除。
- 同查询刷新若仍是相同范围和版本，只保留仍存在且仍可选的当前页 ID；资格失效的 ID 被移除并由选择 owner 简短公告一次。

### 提升为全部筛选结果

只有先完成当前页选择后，才显示独立入口，例如“选择全部 237 条符合当前筛选的记录”。入口和确认界面必须同时显示：

- 全部可选数量；
- 已应用筛选摘要；
- 当前权限范围；
- 排除项数量；
- 当前动作下不可操作项数量。

用户确认后创建 `selectionSnapshot`，其中 `excludedIds` 初始化为空集合。不能以 `allSelected=true` 或一个数量代替快照。

在 all-filtered 模式下：

- 取消某行时，创建新的不可变后继快照，把该 ID 加入快照内部 `excludedIds`。
- 重新选择该行时，创建另一后继快照，只移除该 ID。
- 先前快照不可原地修改。
- 可见已选数量为 `eligibleTotal - 有效 excludedIds 数量`。
- 表头三态始终只根据当前页可选 ID 与当前快照排除项计算。
- 表头从 checked 切换为取消时，把当前页所有可选 ID 作为一次选择意图批量加入排除集合；反向操作则批量移除这些 ID。
- 同范围普通翻页保留同一个 `selectionSnapshotId`，不重新确认，也不重复播报范围。
- 筛选、权限范围或 `datasetVersion` 变化时立即使旧范围失效、阻止操作并清除。
- 仅排序变化时进入待重新确认态。
- 同范围内资格变化只移除失效 ID、更新数量并创建后继快照。

每个被接受的选择意图使 `selectionGeneration` 恰好加一。异步资格协调结果至少校验 `live + ownerId + lifecycleToken + selectionGeneration`；失配结果只记录 `selection-result-discarded`，不得更新选择或公告。

`querySnapshot`、`selectionSnapshot` 和 `operationSnapshot` 必须分离：

- 查询快照描述本次取数位置；
- 选择快照描述用户确认的业务范围；
- 操作快照描述一次已经确认并准备执行的目标。

普通翻页可以创建新查询快照，但只要范围键、权限和版本未变，all-filtered 选择快照保持不变。任何查询响应都不能自行重写选择。

当 `stale=true` 时可保留可见选择以便用户理解上下文，但批量提交必须被阻止，直至刷新成功并重新确认适用范围。

## 5. 批量操作状态转换

批量操作只允许从非空、有效且非待确认的选择开始。

```text
idle
  → confirming
  → submitting
  → in-flight
  → all-success
    | partial-success
    | all-failed
    | permission-conflict
    | dataset-version-conflict
    | outcome-unknown
```

开始确认时建立不可变 `operationSnapshot`：

```ts
{
  ownerId,
  operationId,
  operationGeneration,
  operationType,
  selectionGeneration,
  selectionMode,
  selectedRecordIdsOrSelectionSnapshot,
  excludedIds,
  expectedCount,
  targetManifestIdOrDigest,
  permissionScope,
  datasetVersion,
  operationSnapshotId
}
```

全量范围过大时，可使用服务端签发的不可变目标 manifest/token，但服务端必须能证明最终裁决身份集合与该 manifest 精确一致；只返回计数不足以形成业务终态。

确认界面采用页面内非模态确认区域，位于批量工具栏之后，避免新增浮层生命周期。触发后原按钮焦点保持；区域有标题、范围摘要、风险说明、确认和取消按钮，可按正常 Tab 顺序进入。破坏性动作必须显式确认；不可逆或高影响动作使用更强确认。确认界面必须显示操作类型、预计影响数量、筛选范围、排除数和不可操作数。

进入 `submitting` 或 `in-flight` 后：

- 同一快照每次尝试只生成一个请求；
- 点击、Enter、Space 和事件重放均由同一 guard 拦截；
- 提交控件保持可聚焦并以 `aria-disabled="true"` 和可见执行中文本表达状态，handler 必须真正拒绝重复提交；
- 请求携带新的 `idempotencyKey`；
- 本地离开页面不能宣称服务端操作已经取消。

操作响应提交前，必须同时满足：

```text
live
+ ownerId
+ lifecycleToken
+ operationId
+ operationGeneration
+ operationSnapshotId
```

随后还必须满足：

- `adjudicatedCount === expectedCount`；
- 裁决身份集合与操作快照目标集合精确相等；
- 成功与失败集合不重叠、无重复、无外部 ID、无缺项。

否则进入非终态 `outcome-unknown`，保留操作快照、当前选择和已有失败项，显示“核对操作结果”入口；在完整结果通过门禁前不得清选择、重整成功项或划分重试集合。

### 全部成功

仅当成功数等于 `expectedCount` 且失败数为 0：

- 进入 `all-success`；
- 仅当捕获的 `selectionGeneration` 仍是当前代次时清除已完成选择；
- 若用户已建立新选择，不得修改新选择；
- 创建新查询快照刷新受影响数据；
- 公告一次完成数量。

### 部分成功

必须同时有成功项和失败项：

- 成功项不得再次执行；
- 仅在选择代次匹配时从当前选择移除成功项；
- 失败项保留稳定 ID、具体原因和 `retryable`；
- 成功子集通过新查询快照刷新；只有 ID 和数据版本均可证明一致时才允许确定性本地重整；
- 刷新不得清除失败摘要、失败原因、重试入口或失败焦点意图。

### 全部失败

成功数为 0 且失败数等于 `expectedCount` 时进入 `all-failed`：

- 选择代次匹配时保留原选择；
- 始终保留不可变操作快照；
- 完整错误只由操作结果 owner 呈现；
- 显示匹配错误类型的恢复入口。

### 权限或版本冲突

权限冲突与普通失败分开：

- 重新解析可操作范围；
- 移除越权项；
- 显示新数量并要求重新确认；
- 越权项不得自动重试。

数据版本冲突：

- 立即使旧操作快照失效；
- 刷新受影响数据；
- 要求重新选择或重新确认；
- 不得复用旧幂等键。

### 失败项重试

“重试失败项”只能从 `retryable=true` 的失败项建立：

- 新 `operationId`；
- 新 `operationGeneration`；
- 新不可变操作快照；
- 新 `idempotencyKey`。

已成功项和不可重试项的重试请求数必须为 0。旧操作或旧重试迟到结果只能被丢弃，不能覆盖当前失败集合。

## 6. 加载、错误和空状态

| 状态 | 呈现与恢复 |
|---|---|
| 首次加载 | 没有可用结果时显示与最终列结构一致的不可操作骨架；结果容器 `aria-busy="true"`，不渲染假复选框或假按钮 |
| 刷新 | 保留上次成功的行、分页和焦点意图；标记 `refreshing` 与 `aria-busy="true"`；旧行明确表示为旧结果，不能伪装成已匹配新条件 |
| 首次失败 | 进入 `initial-error`；结果区用文本错误和可聚焦重试按钮替代表格；重试创建新代次 |
| 刷新失败 | 保留旧行与分页，进入 `refresh-error`，设置 `stale=true`，显示“数据可能已过期”和重试入口 |
| 筛选零结果 | 显示“当前条件无匹配”，提供调整或清除筛选入口 |
| 数据源为空 | 显示独立的空数据集状态，说明当前没有可管理记录；不能复用“暂无数据” |
| 当前页无可选项 | 表头选择控件 unchecked 且 disabled，并说明具体原因；不显示空批量工具栏 |
| 操作执行中 | 操作结果区域显示动作、范围和进度状态；不恢复为可提交 |
| 部分成功 | 显示成功/失败数量、失败项原因和仅针对可重试失败项的入口 |
| 结果未知 | 显示核对入口，不把不完整结果归类为成功或失败 |

相同 in-flight 查询意图在创建新快照前合并，不新增请求、代次或公告；权限、版本、筛选或其他意图键发生变化时，即使旧请求仍在途，也必须创建新请求。

查询错误归结果 owner；筛选字段错误归字段；批量错误归操作结果 owner。每个 `errorId` 只能有一个完整消息 primary owner。

## 7. 键盘、焦点和 ARIA

### 语义

本实例没有单元格级二维导航需求，因此宽屏使用原生 `<table>`，禁止仅为样式添加 `role="grid"`。

- 表格通过 `<caption>` 或 `aria-labelledby` 获得可区分名称。
- 列头使用 `<th scope="col">`，需要时记录身份单元格使用 `<th scope="row">`。
- 静态单元格不设置 `tabindex="0"`。
- Table 不接管方向键、Home、End、Page Up 或 Page Down。
- Tab 只进入真实复选框、排序按钮、筛选、分页和批量操作控件，顺序与视觉任务顺序一致。

### 选择控件

- 行复选框名称示例：“选择记录 ACME-1042”；all-filtered 排除态可命名为“重新包含记录 ACME-1042”。
- 表头名称示例：“选择当前页 18 条可选记录，已选 7 条”。
- 混合态必须在可访问性树中暴露为 mixed。
- 禁用原因通过存活的描述节点关联，不只靠 Tooltip。
- 范围摘要持续显示“全部筛选结果 236 条已选，1 条已排除”。

### 公告 owner

设置三个独立且具唯一 ID 的 `role="status" aria-live="polite"` 区域：

- 查询 owner：查询开始、结果数量/位置变化、失效页恢复、查询失败；
- 选择 owner：全部范围确认、资格变化、需要用户处理的范围失效；
- 操作 owner：批量开始、部分成功、失败、冲突和结果未知。

每个被接受且需要反馈的事件只公告一次。merged、discarded、superseded、disposed 和静默失效事件不公告；不逐行朗读全部记录或全部筛选条件。

### 焦点规则

焦点恢复使用稳定的 `recordId + columnId + controlId`，不使用行索引。

- 筛选、排序发请求时，仍存活的触发器不失焦。
- 刷新后精确控件仍存在时保持焦点；消失时依次尝试同记录等价控件、同列最近记录、结果摘要/标题、当前分页控件。
- 翻页响应提交后只移动一次到结果摘要/标题，或按显式策略保留仍有效的分页触发器。
- 操作终态提交前记录当前焦点。目标仍存活、可聚焦且语义未变时不移动；目标消失时只移动一次到结果摘要、首个失败项、重试、重新确认或结果核对入口。
- 最终目标不能是 `document.body`、文档根或已移除节点。
- 后续刷新不能再产生第二次迁移。
- 高对比度、Reduced Motion 和非颜色表达下仍必须看见焦点与状态。

## 8. 桌面与移动端

### 桌面和平板横屏

- 筛选区、已应用条件摘要、结果摘要、批量工具栏、原生表格和分页按任务顺序排列。
- 表格容器可在确有必要时横向滚动；页面根不能产生横向溢出。
- 容器需通过边缘阴影加文本或等价非纯颜色方式表达仍可滚动方向。
- 本实例不固定列，避免固定列遮挡焦点、错误或滚动边界。

### 窄屏和手机

使用经过评审的显式卡片映射：

- 每张卡片以记录名称和稳定 ID 组成可访问名称；
- 直接显示记录身份、主要状态和主要操作信息；
- 次要字段进入有名称的“查看记录详情”区域，并以字段标签和值的确定顺序呈现；
- 卡片保留行复选框、不可选原因和排除态；
- 列表头提供与桌面表头等价的“选择本页可选记录”控件；
- 全部筛选结果提升、范围摘要、确认、部分失败和重试能力不得删除；
- 分页仍是页码模式，不改成加载更多或无限滚动。

Table 与卡片在任一时刻只能有一个活动数据根。实时断点切换保持同一 `ownerId`，并原样保留查询、分页、选择、排除项、展开项、焦点意图和在途操作；不能新增查询、重放操作或重建操作代次。精确焦点目标消失时，只移动一次到语义等价控件。

在低高度、动态视口和虚拟键盘场景，筛选提交、结果、分页、批量摘要与错误恢复都必须能滚动到可视区域。移动端底部动作区若采用 sticky，必须包含四向 safe-area 内边距，且不得遮挡焦点、错误或最后一张卡片。触摸目标不得依赖精确点击，任何滑动或拖动都必须有点击和键盘替代。

浏览器 200% 缩放时，关键流程不得同时要求页面和表格双向滚动。长文本、字体放大和翻译扩展不能截断掉记录身份、错误含义或操作名称。

## 9. 路由卸载、旧响应和资源处置

路由提交离开或 owner 卸载时，实例同步且幂等地进入 `disposed`，不等待请求、菜单动画或批量结果：

1. 设置 `live=false`、`disposed=true`；
2. 拒绝新的查询、翻页、菜单、选择、焦点、操作和公告工作；
3. 取消或失效查询、分页恢复、失败重试、防抖和操作轮询；
4. 关闭并移除本实例菜单、popup 及其定位任务；
5. 失效排队的焦点、选择协调、操作结果和 live-region 回调；
6. 注销本实例持有的监听器、计时器、`requestAnimationFrame`、观察器和订阅；
7. 移除本实例 DOM 和 ARIA 引用；
8. 每项资源按 `ownerId` 释放一次，不得影响同页其他表格。

取消请求仅用于节省资源。任何迟到回调仍必须执行完整提交门禁；只要一项不匹配，就只记录 `response-discarded`、`selection-result-discarded` 或 `operation-result-discarded`，且 DOM、状态、焦点和 live region 写入均为 0。

路由离开不等于服务端批量操作已取消。若服务端工作可能继续，后续只能通过新的页面实例和显式“查询操作结果”流程按操作 ID 获取状态，不能让旧回调复活旧 owner。

旧触发器随路由移除时不得恢复焦点。新路由提交后，只由新路由自己的策略移动一次到页面主标题、主内容或主要操作。

返回页面时：

- 是否恢复查询和滚动位置由显式 `restorePolicy` 决定；
- 恢复前重新校验权限、数据版本和分页位置；
- 使用全新的 `ownerId` 和 `lifecycleToken`；
- 不恢复旧选择、排除项、权限结果、菜单或操作快照。

同页多个表格的 generation 数值可以相同，但必须在 `ownerId + lifecycleToken` 命名空间内解释；一个实例的响应和 disposal 不能修改另一个实例。

## 10. 实现完成前应用检查清单

| 规则族 | 结论 | 实现判据 |
|---|---|---|
| 能力与状态 | 适用 | `bulk-action` 当前值、固定四组状态及独立 lifecycle guard 均已实现 |
| 查询 | 适用 | 每个查询有不可变快照、代次和五项提交门禁 |
| 筛选 | 适用 | draft/applied、apply mode、默认重置、分页复位、持续摘要、URL 安全和字段错误 owner 均分离 |
| 排序 | 适用 | 当前比较值为 `updatedAt DESC NULLS LAST, recordId ASC`；交互按钮、ARIA、回第 1 页和选择转换完整 |
| 分页 | 适用 | 仅 numbered；可靠总数、范围、直接页码、校验跳页、原生边界禁用、页大小和单次失效恢复完整 |
| 数据状态 | 适用 | 首载、刷新、首错、刷新错、筛选零结果、空数据集和 stale 分支彼此独立 |
| 选择与批量操作 | 适用 | page、all-filtered、内部 exclusions、部分成功、重试、冲突及 unknown 均有快照和门禁 |
| 单行操作 | 不适用 | `rowOperationEnabled=false`；无 DOM、状态槽、handler 和请求入口 |
| 列 | 部分适用 | 稳定列 ID 与固定展示字段适用；显隐、固定、调宽子能力关闭且无对应入口或事件 |
| Table / Grid 与键盘 | 适用 | 原生 Table 和卡片等价适用；无二维单元格需求，因此 ARIA Grid 不适用 |
| 焦点 | 适用 | 稳定 ID 恢复、结果提交迁移、终态迁移和路由焦点策略均已定义 |
| 响应式 | 适用 | 单实例 Table/Card 转换，能力、选择、操作和恢复语义跨端一致 |
| ARIA 与公告 | 适用 | 名称、header 关联、三态选择、busy/stale/冲突状态及唯一公告 owner 完整 |
| disposal 与实例隔离 | 适用 | owner/token 门禁、资源一次释放、迟到回调零写入和返回恢复边界完整 |
| 运行时验证边界 | 适用；当前未验证 | 必须在下列真实环境完成验证后才能标记通过 |

## 11. 尚未通过真实运行环境验证的边界

以下项目当前全部为“未验证”，不能仅凭本设计说明视为通过：

- Chrome、Safari、Firefox 中原生表格、动态 mixed 复选框、`aria-busy`、禁用原因和焦点保持行为。
- NVDA + Firefox、JAWS + Chrome、VoiceOver + Safari 下表格表头关联、选择范围、三态、状态公告去重和卡片字段标签。
- 仅键盘完成筛选、排序、翻页、当前页选择、全部范围确认、批量确认、部分失败和失败项重试。
- 触摸、鼠标、Enter、Space 和事件重放是否都只产生一次查询或批量请求。
- `1440×900`、`1280×720`、平板横/竖屏、`390×844` 窄屏和低高度横屏手机中的能力等价。
- Table 与卡片使用同一选择夹具和批量操作夹具时，快照、确认等级、请求数、终态和失败恢复是否完全一致。
- 200% 浏览器缩放、系统字体放大、长翻译、长单词、高对比度和 Reduced Motion。
- 动态浏览器工具栏、虚拟键盘开关及四向 safe-area 下，焦点、错误和主要操作是否无遮挡。
- 表格横向滚动边界、页面根溢出和关键任务是否出现双向滚动。
- 快速筛选、排序、翻页、刷新响应乱序时，旧响应是否始终零写入。
- 真实服务端的稳定 ID、可靠总数、`datasetVersion`、目标 manifest、幂等键、逐项裁决和结果核对能力。
- 部分成功后成功子集刷新是否保留全部失败项、原因、可重试性和焦点。
- 计数相等但身份集合缺项、外部 ID、重复或重叠时，是否稳定进入 `outcome-unknown`。
- 权限缩小、数据版本冲突和同范围资格变化的真实竞态。
- route commit、owner unmount、取消失败和迟到回调同时发生时的零 DOM/state/focus/live-region 写入。
- 计时器、观察器、订阅、菜单定位、请求和公告资源是否按实例各释放一次且无泄漏。
- 同页两个表格 generation 相同、响应交错和其中一个实例 disposal 时的命名空间隔离。
- 浏览器返回后的查询/滚动恢复校验，以及旧选择、排除项、菜单和操作快照不被回放。
<!-- END RAW OUTPUT -->
