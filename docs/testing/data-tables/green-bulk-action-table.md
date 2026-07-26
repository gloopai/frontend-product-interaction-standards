# Attempt 6 GREEN：批量操作数据表格

## Spawn args

```text
task_name=attempt_6_bulk_action_table
fork_turns=none
message=Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个 bulk-action 数据表格。它要支持当前页选择，以及可选的“全部筛选结果”选择模式、排除项、筛选变化、部分成功、失败项重试和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配、选择与查询的关系，以及 disposal 后旧响应和资源如何处理；同时列出尚未通过真实运行环境验证的边界。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
```

`model` and `reasoning_effort` were not sent.

## Spawn tool return

```json
{"task_name":"/root/table_task5_green/attempt_6_bulk_action_table"}
```

## Completion envelope metadata

- Message Type: `FINAL_ANSWER`
- Recipient: `/root/table_task5_green`
- Sender: `/root/table_task5_green/attempt_6_bulk_action_table`

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个 bulk-action 数据表格。它要支持当前页选择，以及可选的“全部筛选结果”选择模式、排除项、筛选变化、部分成功、失败项重试和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配、选择与查询的关系，以及 disposal 后旧响应和资源如何处理；同时列出尚未通过真实运行环境验证的边界。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

<!-- BEGIN RAW OUTPUT -->
# Bulk-action 数据表格实现设计

## 1. 当前能力声明

本实例是具备批量操作能力的管理数据表格，当前配置固定为：

| 能力 | 当前值 |
| --- | --- |
| `capabilityTier` | `bulk-action` |
| `resolvedTier` | `bulk-action`，以当前权限解析结果为准 |
| `filteringEnabled` | `true` |
| `sortingEnabled` | `true`，单列交互排序 |
| `paginationMode` | `numbered` |
| `pageSize` | `25` |
| `pageSelectionEnabled` | `true` |
| `allFilteredSelectionEnabled` | `true` |
| `rowOperationEnabled` | `false` |
| `bulkOperationEnabled` | `true` |
| `columnVisibilityEnabled` | `false` |
| `columnPinningEnabled` | `false` |
| `columnResizeEnabled` | `false` |
| `responsivePresentation` | `table-card` |

当前实际排序为：

```text
createdAt DESC
nulls LAST
caseSensitivity: not-applicable
locale: not-applicable
naturalSort: false
稳定次序键：recordId ASC
```

筛选采用显式提交模式：

- `filterDraft` 与 `appliedFilters` 分离。
- 默认筛选为 `{ status: ["active"] }`；“重置”恢复该默认值，不是清空。
- `status`、`createdAtRange` 可写入 URL；自由文本 `keyword` 视为敏感值，不进入 URL、页面标题或分析日志。
- 已应用条件始终出现在筛选摘要中，可逐项移除。
- 筛选字段自身的校验错误归字段 owner，不写入表格查询错误。

分页依赖后端提供可靠总数。显示当前页、总页数和当前结果范围；支持直接页码及带标签、整数校验和边界校验的跳页输入。首页/末页按钮使用原生 `disabled`。筛选、排序或页大小变化后回到第 1 页；请求页失效时只恢复一次到最新有效末页。

第一版明确不支持：行内编辑、树形表格、拖拽行排序、透视表、加载更多、无限滚动、拖拽列排序和个人布局持久化。

## 2. 页面结构

桌面端从上到下为：

1. 页面标题与结果说明。
2. 筛选区及已应用条件摘要。
3. 查询状态/错误区域。
4. 选择摘要和批量工具栏；无选择时不显示空工具栏。
5. 批量确认或结果区域。
6. 数据表格。
7. 分页区。

批量确认采用表格上方的内联确认区域，不依赖弹窗。区域必须展示：

- 操作名称和风险等级。
- 预计影响数量。
- 当前选择模式。
- 已应用筛选摘要。
- 排除数量。
- 不可操作数量及原因概述。
- “取消”和明确命名的“确认执行……”按钮。

破坏性操作至少经过一次明确确认；不可逆或高影响操作使用产品配置的第二步强确认，不能由普通批量按钮直接提交。

## 3. 状态结构

四组状态必须保持正交，不得合并。

### `queryState`

```ts
{
  filterDraft,
  appliedFilters,
  sortRules,
  pagination: {
    mode: "numbered",
    page,
    totalPages,
    totalCount
  },
  pageSize: 25,
  querySnapshot,
  snapshotId,
  datasetVersion,
  requestGeneration,
  requestPhase:
    | "idle"
    | "initial-loading"
    | "ready"
    | "refreshing"
    | "initial-error"
    | "refresh-error",
  queryError,
  stale
}
```

每次请求先冻结不可变 `querySnapshot`，包含已应用筛选、完整稳定排序、页码、页大小、权限范围和数据版本，然后创建 `snapshotId` 并递增 `requestGeneration`。

查询响应只有同时满足以下条件才可提交：

```text
live
&& ownerId 匹配
&& lifecycleToken 匹配
&& requestGeneration 匹配
&& snapshotId 匹配
```

取消请求只用于节省资源，不替代提交门禁。

### `viewState`

```ts
{
  visibleColumnIds: [
    "select",
    "recordName",
    "status",
    "createdAt",
    "owner",
    "note"
  ],
  pinnedColumnIds: [],
  columnWidths: {
    select: 48,
    recordName: 240,
    status: 120,
    createdAt: 180,
    owner: 160,
    note: 320
  },
  density: "comfortable",
  rows,
  resultSummary,
  presentation: "table" | "card"
}
```

这些列状态存在，但当前没有用户列显示、固定或调宽入口。改变响应式形态不得改变查询或重新请求数据。

### `interactionState`

```ts
{
  focusIntent: {
    sourceEvent,
    recordId?,
    columnId?,
    controlId?,
    fallbackId
  },
  focusedRecordId?,
  focusedColumnId?,
  expandedRecordIds,
  selectionMode: "page" | "all-filtered",
  selectionPhase: "valid" | "pending-reconfirmation" | "invalid",
  selectionGeneration,
  pageSelectedIds,
  selectionSnapshot?
}
```

`selectionSnapshot.excludedIds` 必须是快照内部字段，不允许存在可独立漂移的同级 `excludedIds`。

### `operationState`

```ts
{
  phase:
    | "idle"
    | "confirming"
    | "submitting"
    | "in-flight"
    | "outcome-unknown"
    | "all-succeeded"
    | "partially-succeeded"
    | "all-failed"
    | "permission-conflict"
    | "dataset-version-conflict",
  operationId?,
  operationGeneration,
  operationSnapshot?,
  operationSnapshotId?,
  idempotencyKey?,
  successIds,
  failedItems: Array<{
    recordId,
    reason,
    retryable
  }>,
  conflict?,
  errorOwner?,
  recoveryAction?,
  resultFocusIntent?
}
```

### `lifecycleGuard`

生命周期不是第五组业务状态，而是独立 owner guard：

```ts
{
  ownerId,
  lifecycleToken,
  live: boolean,
  disposed: boolean,
  ownedResources
}
```

同页多表格允许 generation 数值相同，但 `ownerId + lifecycleToken` 必须隔离。

## 4. 选择与查询的关系

### 当前页模式

初始固定为 `selectionMode="page"`。

- 行复选框只能选择当前页明确可选记录的稳定 `recordId`。
- 不可选记录不进入数量和集合；禁用复选框必须关联具体原因。
- 表头复选框只代表当前页可选记录，不代表全数据集。
- 当前页已选 `0/N`：未选。
- 当前页已选 `N/N`：选中。
- 其他数量：混合态。
- 当前页没有可选记录：未选且禁用，并显示原因。

`page` 模式在以下事件提交时清除：

- 应用、移除或重置筛选。
- 提交排序。
- 翻页。
- 改变页大小。
- 权限范围变化。
- 数据版本变化。

### 全部筛选结果模式

用户必须先选择当前页，之后才显示独立入口，例如“选择全部 237 条筛选结果”。

确认后创建不可变快照：

```ts
{
  selectionSnapshotId,
  sourceQuerySnapshot,
  rangeKey,
  appliedFilters,
  permissionScope,
  datasetVersion,
  eligibleTotal,
  excludedIds: new Set(),
  selectionGeneration
}
```

界面持续显示：“全部筛选结果中已选 236 条，排除 1 条”。

取消某条记录时：

1. 递增 `selectionGeneration`。
2. 创建新的 `selectionSnapshotId`。
3. 复制原快照并向其内部 `excludedIds` 增加该 ID。
4. 原快照保持不可变。

重新选择时同样创建后继快照，仅移除对应排除 ID。显示数量为：

```text
eligibleTotal - 当前仍有效的 excludedIds 数量
```

同一范围内普通翻页保留该模式及同一个选择快照身份；每页的“全选”状态仍只按本页可选 ID 与快照内排除项计算。

查询变化规则：

| 事件 | `page` 模式 | `all-filtered` 模式 |
| --- | --- | --- |
| 普通翻页 | 清除 | 范围键、权限和版本一致时保留 |
| 筛选变化 | 清除 | 立即失效并清除 |
| 权限变化 | 清除 | 立即失效并清除 |
| 数据版本变化 | 清除 | 立即失效并清除 |
| 排序变化 | 清除 | 进入 `pending-reconfirmation` |
| 页大小变化 | 清除 | 当前产品策略同样清除，避免超出普通翻页范围静默保留 |
| 列布局/响应式形态 | 保留 | 保留，不发查询 |

待重新确认期间必须阻止批量操作。确认新范围和数量后绑定新查询快照；取消确认则清除选择。

同一范围内记录失去操作资格时，仅移除失效 ID、更新可选总数并公告一次，不应清除其他仍有效记录。

## 5. 查询、加载、错误与空状态

### 首次加载

- 没有可用结果时显示与最终结构一致的非交互骨架。
- 结果容器设置 `aria-busy="true"`。
- 骨架内不得出现可点击复选框、链接或批量操作。

### 刷新

- 保留上次成功的行、分页和焦点意图。
- `requestPhase="refreshing"`，结果容器保持 `aria-busy="true"`。
- 旧行明确标记为正在刷新，不能伪装成已匹配新条件的结果。
- 同一个仍在途的查询意图合并点击、Enter 或事件重放，不新增快照、请求或公告。
- 权限、筛选等使意图键改变时，即使旧请求仍在途，也必须接受新请求。

### 查询错误

- 首次失败：用结果区域内的错误文本和可聚焦重试按钮替代表格，进入 `initial-error`。
- 刷新失败：保留旧行和分页，进入 `refresh-error`，设置 `stale=true`，显示“数据可能已过期”和重试入口。
- 重试创建新的快照和代次。
- 查询错误只归结果 owner；不得写入筛选字段或批量结果区域。

### 空状态

必须区分：

- 有已应用筛选且结果为零：“当前条件无匹配”，提供调整或清除筛选入口。
- 默认范围本身为空：“当前数据集尚无记录”，不展示空批量工具栏。
- 当前页存在记录但没有可选项：保留数据，禁用当前页全选并说明权限或状态原因。
- 页码因数据删除失效：只恢复一次到最近有效页，并播报新位置。

## 6. 批量操作状态机

### 创建操作快照

只有非空、有效、非待确认的选择可以进入 `confirming`。

确认前创建不可变 `operationSnapshot`：

```ts
{
  ownerId,
  operationId,
  operationGeneration,
  operationType,
  selectionGeneration,
  selectionMode,
  selectedRecordIds?,        // page 模式
  allFilteredRange?,         // all-filtered 模式
  excludedIds,
  expectedCount,
  permissionScope,
  datasetVersion,
  operationSnapshotId
}
```

提交请求携带 `operationSnapshotId` 和本次尝试唯一的 `idempotencyKey`。确认后选择变化不得修改该快照。

在 `submitting` 或 `in-flight` 期间，点击、Enter、Space 和事件重放只能产生一个请求，其余记录为忽略事件。不能因为本地请求被取消或页面关闭，就把服务端工作显示为已取消。

### 操作响应门禁

操作响应只有以下六项全部匹配才可提交：

```text
live
&& ownerId
&& lifecycleToken
&& operationId
&& operationGeneration
&& operationSnapshotId
```

之后还要验证：

- `adjudicatedCount === expectedCount`。
- 成功与失败集合不重叠。
- 成功与失败身份的并集精确等于操作快照目标集合。
- 不存在重复、外部 ID 或遗漏 ID。

不完整、超量、少量、重叠或集合不一致的响应进入非终态 `outcome-unknown`。保留选择和操作快照，显示“核对操作结果”入口；在完整结果到达前不得清选择、刷新成功项或建立重试分区。

对于超大范围，后端可使用不可变选择清单/manifest 及集合摘要避免浏览器传输全部 ID，但服务端必须证明成功与失败是该 manifest 的完整、互斥分区；只有该证明通过才能进入业务终态。

### 业务终态

| 终态 | 条件 | 处理 |
| --- | --- | --- |
| 全部成功 | 成功数等于预计数，失败为零 | 选择代次仍匹配时清除完成选择；建立一次新查询快照刷新 |
| 部分成功 | 成功、失败均非空且完整分区 | 成功项不再执行；保留每个失败项原因和可重试性 |
| 全部失败 | 成功为零，失败数等于预计数 | 保留原选择和操作快照，提供重试 |
| 权限冲突 | 完整裁决后确认权限变化 | 移除越权项，显示新数量，要求重新确认；越权项不可重试 |
| 数据版本冲突 | 完整裁决后确认版本变化 | 旧快照失效，刷新数据，要求重新选择或重新确认 |
| 结果未知 | 裁决不完整或身份集合错误 | 保留全部恢复上下文，提供结果核对入口，不视为业务终态 |

部分成功后：

- 成功子集通过新查询快照刷新；只有 ID 和数据版本均可证明一致时才允许确定性本地重整。
- 刷新不得清除失败项、失败原因、可重试性、重试入口或结果摘要。
- 失败项列表允许逐项展示原因；不可重试项必须说明原因。
- “重试失败项”只选择 `retryable=true` 的失败 ID。

每次重试创建新的：

- `operationId`
- `operationGeneration`
- `operationSnapshot`
- `operationSnapshotId`
- `idempotencyKey`

已成功项和不可重试项不得进入重试请求。

## 7. 键盘操作

采用原生 `<table>`，因为本设计不需要单元格级二维导航。

- Tab/Shift+Tab 只进入真实控件，静态单元格不设 `tabindex="0"`。
- 表格不拦截方向键、Home、End、Page Up、Page Down。
- Space 切换聚焦的行复选框或当前页复选框。
- Enter/Space 激活排序、筛选、范围确认、分页、批量操作、重试和恢复按钮。
- 排序表头内部使用真实按钮；不可排序列没有按钮和 `aria-sort`。
- 当前页使用 `aria-current="page"`；分页边界使用原生 `disabled`。
- 所有核心流程必须可仅用键盘完成：筛选、排序、翻页、当前页选择、全部范围确认、批量提交和失败重试。
- 触摸、鼠标和键盘触发同一意图时必须得到相同状态转换及相同请求数量。

## 8. 焦点管理

`focusIntent` 使用稳定的 `recordId + columnId + controlId`，不能使用行索引。

- 应用筛选或排序时不抢走仍存活的触发控件焦点。
- 后台刷新后原逻辑控件仍存在时保持焦点。
- 行位置变化时恢复到同一稳定记录，不能落到原索引的另一条记录。
- 翻页响应提交后，焦点移动一次到结果摘要/标题；失效页自动恢复不得再次移动。
- 打开内联确认区时，焦点移动一次到确认区标题；取消后返回原批量操作按钮。
- 操作结果提交前记录当前目标：
  - 目标仍存活且语义未变：不移动。
  - 全部成功且目标消失：移动一次到结果摘要或批量工具栏。
  - 部分成功：移动到失败摘要或首个失败项。
  - 全部失败：移动到错误摘要或“重试失败项”。
  - 权限冲突：移动到重新确认入口。
  - 版本冲突：移动到刷新并重新选择入口。
  - `outcome-unknown`：移动到结果核对入口。
- 后续结果刷新不得造成第二次迁移。
- 焦点不得落到 `document.body`、文档根、已移除节点或另一表格的同名控件。

## 9. ARIA 与状态公告

桌面表格使用：

- 原生 `<table>`。
- 可见 `<caption>` 或 `aria-labelledby` 提供唯一名称。
- `<th scope="col">` 建立列头关联。
- 当前主排序列设置正确 `aria-sort`。
- 行复选框名称包含记录身份，例如“选择记录 ABC-123”。
- 当前页复选框名称包含范围和数量，例如“选择当前页全部 18 条可选记录”。
- 原生复选框的 `checked` 与 `indeterminate` 必须正确反映到可访问性树。
- 禁用控件通过 `aria-describedby` 关联具体原因。

结果区域、选择范围和批量结果分别声明唯一的公告 owner。每个被接受且需要用户反馈的事件只公告一次：

- 查询开始、结果数量/位置变化、查询失败。
- 进入或退出全部筛选结果范围、资格数量变化。
- 批量开始、结果未知、全部成功、部分成功、全部失败或冲突。

公告应简洁，例如“批量归档完成：18 条成功，2 条失败”，不得逐行朗读完整内容或重复完整错误。被合并、丢弃、取代或 disposal 后到达的事件不公告。

加载、过期、执行中、部分成功、失败和冲突都必须有文本或语义表达，不能只依靠颜色、位置或图标。

## 10. 桌面与移动端适配

### 桌面

- 使用原生表格。
- 选择列、记录身份和主要状态直接显示。
- 次要字段保持正常列展示。
- 页面根不产生横向滚动。

### 平板和移动端

当内容宽度不足时，以同一个 owner 将表格内容切换为卡片列表：

- 每张卡片具有包含记录身份的可访问名称。
- 字段使用明确的标签和值关联。
- 记录名称和主要状态直接显示。
- 次要字段进入具名“查看记录详情”展开区，不得无入口隐藏。
- 卡片保留等价的行复选框。
- 列表顶部提供等价的当前页三态复选框、选择摘要、全部范围入口和批量工具栏。
- 任一时刻只有一个活动数据根；不能同时保留一个可访问表格和一个可访问卡片列表。
- 断点切换保持相同 `ownerId`、查询、分页、选择快照、排除项、展开项、焦点意图和操作快照。
- 切换本身不得发查询、重放批量请求或递增操作代次。
- 精确焦点控件消失时，仅移动一次到同记录、同语义的卡片控件。

移动端还必须处理：

- 200% 缩放和系统字体放大。
- 长文本与翻译扩展。
- 低高度和横屏手机。
- 动态浏览器工具栏和虚拟键盘。
- 四向安全区域。
- 无 Hover 环境。
- 不依赖精确拖动的触摸目标和间距。

## 11. 路由卸载与 disposal

路由提交离开或表格 owner 卸载时，实例同步、幂等地进入 `disposed`，不等待动画、查询或批量操作完成。

处置流程：

1. 设置 `live=false`、`disposed=true`；重复调用不产生第二次处置。
2. 拒绝新的查询、分页、选择、批量操作、焦点和公告工作。
3. 中止或失效查询、分页恢复、重试、防抖和批量轮询。
4. 关闭该实例的详情、临时浮层并移除 ARIA 引用。
5. 失效待执行的焦点、选择协调、操作结果和公告回调。
6. 注销该实例持有的计时器、监听器、观察器和订阅。
7. 每项资源按 `ownerId` 只释放一次，不影响其他表格实例。
8. 移除该实例 DOM，不向将被删除的旧触发器返回焦点。
9. 新路由提交后，仅由新路由焦点策略把焦点移动一次到页面主标题、主内容或主要操作。

即使底层取消失败，旧回调仍必须通过查询五项门禁或操作六项门禁。任一不匹配只记录 discarded，不得写 DOM、状态、焦点或 live region。

离开页面只表示本地 owner 已处置，不能宣称服务端批处理已取消。服务端操作必须通过 `operationId` 和幂等键可核对；重新进入页面时使用新的 `ownerId` 与 `lifecycleToken`。除非产品显式声明并通过权限、版本和分页位置校验，否则不恢复查询或滚动；旧选择、排除项、权限结果、打开状态和操作快照一律不回放。

## 12. 能力边界与上线前置条件

“全部筛选结果”模式上线必须同时满足：

- 后端提供稳定记录 ID。
- 后端提供可靠 `eligibleTotal`。
- 能生成稳定 `rangeKey` 或等价选择 manifest。
- 请求冻结权限范围和数据版本。
- 服务端支持以范围快照加排除 ID 执行，不要求浏览器枚举全部选中 ID。
- 批量接口支持幂等键。
- 操作结果能证明对目标集合的完整、互斥裁决。
- 失败项至少返回稳定 ID、具体原因和可重试性。
- 权限冲突与数据版本冲突可被区分。

任一前置条件缺失时，不能用 `allSelected=true` 或模糊数量模拟能力；必须把 `allFilteredSelectionEnabled` 配置为 `false`，并同时移除入口、状态槽、handler 和请求路径，只保留当前页选择。

排除项容量应由服务端契约明确。如果达到服务端上限，界面不得静默丢弃旧排除项；应阻止继续排除、说明限制，并允许退出全部范围模式后改用当前页选择。

## 13. 尚未通过真实运行环境验证的边界

以下均为设计契约，尚未在真实浏览器、组件运行时或后端环境中验证：

- `1440×900`、`1280×720`、平板横竖屏、`390×844`、低高度和横屏手机。
- 200% 浏览器缩放、字体放大、长翻译、高对比度和 Reduced Motion。
- 动态视口、虚拟键盘、四向安全区域与触摸目标。
- Chrome、Safari、Firefox 的原生复选框混合态和焦点表现。
- NVDA、JAWS、VoiceOver 对表格关联、混合态、禁用原因及公告次数的读取。
- 全键盘流程以及鼠标、触摸、键盘的请求数等价性。
- 表格与卡片实时切换时的状态延续和单次焦点迁移。
- 快速筛选、排序、翻页、刷新及乱序响应竞态。
- 取消失败后的迟到查询、选择协调、批量结果和公告回调。
- 页码失效后的单次恢复和焦点次数。
- 大规模全部范围、排除项上限、manifest 完整性及精确总数。
- 重复提交、幂等键、部分成功、全部失败、权限冲突、版本冲突和 `outcome-unknown`。
- 路由离开时服务端任务继续执行后的结果核对。
- 同页两个表格 generation 相同情况下的 owner 隔离。
- disposal 时资源逐项只释放一次、旧 DOM/ARIA 引用归零及新路由单次聚焦。

## 14. 应用检查清单

| 规则族 | 适用性 | 正文位置或不适用依据 | 验证状态 |
| --- | --- | --- | --- |
| 能力与状态 | 适用 | 第 1、3 节 | 未验证 |
| 查询 | 适用 | 第 3、5 节 | 未验证 |
| 筛选 | 适用 | 第 1、4、5 节 | 未验证 |
| 排序 | 适用 | 第 1、4、7、9 节 | 未验证 |
| 分页 | 适用 | 第 1、4、5、7 节 | 未验证 |
| 数据状态 | 适用 | 第 5 节 | 未验证 |
| 选择 | 适用 | 第 4 节 | 未验证 |
| 单行操作 | 不适用 | `rowOperationEnabled=false`；无单行操作 DOM、状态槽、handler/事件和业务请求入口 | 未验证 |
| 批量操作 | 适用 | 第 2、3、6 节 | 未验证 |
| 基础列状态 | 适用 | 第 3 节 `viewState` | 未验证 |
| 可选列控制 | 不适用 | 三项列控制均为 `false`；无控制 DOM、交互状态、handler/事件和请求入口 | 未验证 |
| Table 语义 | 适用 | 第 7、9、10 节 | 未验证 |
| ARIA Grid 语义 | 不适用 | 无二维导航需求；无 `role="grid"` DOM、Grid 状态、键盘 handler 和相关请求入口 | 未验证 |
| 键盘 | 适用 | 第 7 节 | 未验证 |
| 焦点 | 适用 | 第 8 节 | 未验证 |
| 响应式 | 适用 | 第 10 节 | 未验证 |
| ARIA 与公告 | 适用 | 第 9 节 | 未验证 |
| disposal | 适用 | 第 11 节 | 未验证 |
| 实例隔离 | 适用 | 第 3、8、11 节 | 未验证 |
| 运行时验证边界 | 适用 | 第 13 节 | 未验证 |
<!-- END RAW OUTPUT -->
