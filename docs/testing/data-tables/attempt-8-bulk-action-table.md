# Attempt 8 Bulk Action Table Evidence

## Actual spawn args

```text
task_name=attempt_8_bulk_action_table
fork_turns=none
model/reasoning_effort not sent
```

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个 bulk-action 数据表格。它要支持当前页选择，以及可选的“全部筛选结果”选择模式、排除项、筛选变化、部分成功、失败项重试和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配、选择与查询的关系，以及 disposal 后旧响应和资源如何处理；同时列出尚未通过真实运行环境验证的边界。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

## Exact spawn tool return

```json
{"task_name":"/root/table_task5_final_takeover/attempt_8_bulk_action_table"}
```

## Completion metadata

```text
Message Type FINAL_ANSWER
recipient /root/table_task5_final_takeover
sender /root/table_task5_final_takeover/attempt_8_bulk_action_table
```

<!-- BEGIN RAW OUTPUT -->
# Bulk-action 数据表格实现设计

## 1. 能力声明

本实例采用原生 Table，支持筛选、排序、页码分页、当前页选择和“全部筛选结果”选择；不提供单行操作、ARIA Grid 或用户可配置列。

| 配置项 | 当前值 |
| --- | --- |
| `capabilityTier` | `bulk-action` |
| `resolvedTier` | `bulk-action`；权限降级时可变为 `row-action` 或 `display` |
| `filteringEnabled` | `true` |
| `sortingEnabled` | `true`，单列交互排序 |
| `paginationMode` | `numbered` |
| `pageSize` | `20` |
| `pageSelectionEnabled` | `true` |
| `allFilteredSelectionEnabled` | `true` |
| `rowOperationEnabled` | `false` |
| `bulkOperationEnabled` | `true` |
| `columnVisibilityEnabled` | `false` |
| `columnPinningEnabled` | `false` |
| `columnResizeEnabled` | `false` |
| `responsivePresentation` | `table-scroll`，不转换为卡片 |

当前产品配置：

- 筛选采用显式“应用”模式；默认条件为 `{status: "active"}`。
- 当前排序为 `displayName ASC`，空值在末尾，忽略大小写，使用 `zh-CN` locale、自然数字顺序；最后追加不可变唯一键 `recordId ASC`。
- 页码分页依赖服务端可靠总数；当前页大小为 20。
- 记录身份、状态和批量选择列必须保持直接可定位。

## 2. 能力边界与服务端契约

“全部筛选结果”只能在后端同时具备下列能力时启用：

- 每条记录有不会因排序、分页或刷新变化的稳定 `recordId`。
- 查询响应提供可靠的 `total`、`eligibleTotal`、逐行 `eligible` 及不可选原因。
- 查询范围可规范化为稳定 `rangeKey`，并冻结 `appliedFilters`、权限范围和 `datasetVersion`。
- 服务端能建立不可变的目标清单或 `rangeManifestId`，使全量范围的实际记录集合可审计。
- 批量接口接受页内稳定 ID，或接受 `rangeManifestId + excludedIds`。
- 请求支持幂等键，并返回可证明完整的逐项裁决集合或等价的不可变裁决清单。
- 部分成功时能区分成功、可重试失败、不可重试失败、权限冲突和数据版本冲突。
- 排除项不能静默截断；若数量超过请求限制，必须使用服务端排除集合引用，或阻止提交并说明恢复方式。

缺少任一项时：

- 当前页选择仍可使用。
- “选择全部筛选结果”入口不得渲染。
- 后端无法证明裁决集合完整时，结果只能进入 `outcome-unknown`，不能宣称全部成功、部分成功或全部失败。

选择范围只代表确认时的筛选结果，不自动包含之后新出现的匹配记录。路由离开只处置本地实例，不代表服务端任务已取消。

首版不包含行内编辑、树表、拖拽排序、透视表、加载更多、无限滚动、拖拽调整列顺序和个人列布局持久化。

## 3. 状态归属

必须保留以下四组正交状态，禁止合并为一个通用 `loading/error/selected` 状态。

### `queryState`

包含：

- `appliedFilters`
- `sortRules`
- `pagination: {mode: "numbered", page, pageCount, total}`
- `pageSize`
- 不可变 `querySnapshot`
- `snapshotId`
- `datasetVersion`
- `requestGeneration`
- `requestPhase`
- `queryError`
- `stale`

`requestPhase` 至少为：

`idle | initial-loading | ready | refreshing | initial-error | refresh-error`

每次查询先冻结筛选、完整排序、分页位置、页大小、权限范围和数据版本，再生成新 `snapshotId` 并令 `requestGeneration +1`。

### `viewState`

包含：

- `visibleColumnIds`
- `pinnedColumnIds=[]`
- `columnWidths`，仅保存产品配置宽度
- `density`
- `rows`
- `resultSummary`

虽然列控制关闭，这些基础展示字段仍存在；列变化不得发查询。

### `interactionState`

包含：

- `focusIntent: {sourceEvent, recordId?, columnId?, controlId?, fallbackId}`
- 当前焦点的 `recordId`、`columnId`
- `expandedRowIds=[]`
- 行菜单状态未实例化
- `selectionMode: page | all-filtered`
- `selectionStatus: ready | resolving-range | pending-reconfirmation`
- `selectedIds`
- `selectionGeneration`
- 当前不可变 `selectionSnapshot`
- 当前页 `eligibleIds`
- 可见已选数、排除数和不可选数

`excludedIds` 只能存在于 `selectionSnapshot` 内部，不能成为独立、可漂移的同级状态。

### `operationState`

包含：

- `phase`
- `operationId`
- `operationGeneration`
- 不可变 `operationSnapshot`
- `operationSnapshotId`
- `idempotencyKey`
- `successIds`
- `failedItems`
- `retryableFailedIds`
- `nonRetryableFailedIds`
- 冲突类型
- `outcomeUnknownReason`
- 操作结果 primary owner
- 恢复入口和结果焦点意图

| operationKind | currentValue | stateSlot | DOM | handler/event | request |
| --- | --- | --- | --- | --- | --- |
| row | not-instantiated | 0 | 0 | 0 | 0 |
| bulk | enabled | `phase/operationId/operationGeneration/operationSnapshot/idempotencyKey/results/recovery` | 批量工具栏、确认 Dialog、操作结果区、失败项列表 | `bulk-intent/confirm/submit/retry/reconcile` | 批量执行、失败项重试、结果核对请求 |

### `lifecycleGuard`

生命周期不是第五组业务状态，单独维护：

```text
{
  ownerId,
  lifecycleToken,
  status: live | disposed,
  announcementOwnerIds,
  ownedResources
}
```

每个请求、计时器、监听器、观察器、订阅、Dialog、弹层、焦点任务和公告任务都记录其 `ownerId`。

## 4. 选择与查询的关系

### 当前页模式

初始模式固定为 `page`：

- `selectedIds` 只能是当前页 `eligibleIds` 的子集。
- 表头复选框只控制当前页可选记录，绝不表示整个数据集。
- 当前页全选、部分选择、未选择分别对应选中、混合、未选状态。
- 当前页没有可选记录时，表头复选框保持未选且原生禁用，并关联具体原因。
- 不可选行不进入选择数量；其禁用复选框必须说明权限、状态或锁定原因。
- 筛选、排序、翻页、页大小、权限或数据版本变化一经提交，立即清除页内选择。

### 全部筛选结果模式

仅当用户先通过表头选中当前页全部可选记录后，显示独立操作：

> 选择全部 237 条可操作的筛选结果

入口和确认界面同时展示：

- 筛选结果总数与可操作总数。
- 当前已应用筛选摘要。
- 当前权限范围和数据版本。
- 当前不可操作数量。
- 用户排除数量。

确认成功后建立不可变快照：

```text
selectionSnapshot = {
  selectionSnapshotId,
  sourceQuerySnapshot,
  rangeKey,
  appliedFilters,
  permissionScope,
  datasetVersion,
  eligibleTotal,
  rangeManifestId,
  excludedIds: Set<recordId>
}
```

可见选择数量为：

```text
selectedCount = eligibleTotal - validExcludedIds.size
```

取消某行选择时创建新的后继快照，将该 ID 加入内部 `excludedIds`；恢复选择时同样创建后继快照并只移除该 ID。任何旧快照都不可原地修改。

普通翻页在 `rangeKey + permissionScope + datasetVersion` 均未变化时保留同一全量选择快照。每页表头三态仍只根据当前页 `eligibleIds` 与快照内的 `excludedIds` 计算。

### 筛选、排序和范围变化

- 应用、移除或重置筛选：新筛选立即使旧全部范围失效，禁止批量操作并清除选择。
- 权限范围或数据版本变化：立即清除旧范围；不得仅更新显示数量后继续执行。
- 仅排序变化：进入 `pending-reconfirmation`，批量按钮不可用；新查询完成后必须重新展示范围与数量，用户确认后绑定新查询快照。
- 普通翻页：全量范围保持；页内模式清除。
- 页大小变化：本产品配置选择清除当前选择并回到第一页，避免在未重新展示范围时继续执行。
- 同范围内资格变化：只调整失效记录，更新可操作总数并公告一次，不清除其他有效选择。

### 选择代次契约

| 路径 | `generationEffect` | `snapshotEffect` | `commitGuard` | `mismatchEffect` |
| --- | --- | --- | --- | --- |
| 资格变化 | `selectionGeneration +1` | 创建新的不可变后继 `selectionSnapshot`；旧快照写入为 0 | live owner 且变化属于当前范围、权限、版本和代次 | 记录失效结果；选择、DOM、焦点和公告写入为 0 |
| 异步选择协调回调 | 只有接受结果后按对应选择意图递增 | 需要改变范围、总数或排除项时创建后继快照 | `live + ownerId + lifecycleToken + selectionGeneration` 全部匹配 | 只记录 `selection-result-discarded`；选择写入为 0 |
| 操作结果调整当前选择 | 不创建新的用户选择意图代次 | 只有捕获代次匹配时才可生成清理后的后继选择 | 捕获的 `selectionGeneration === 当前 selectionGeneration` | 只写原 operation result owner；当前选择写入为 0 |

## 5. 主要状态转换

### 查询

| 事件 | 转换 |
| --- | --- |
| 首次进入 | `idle → initial-loading → ready | initial-error` |
| 应用筛选 | 更新 `appliedFilters`，清选择，回第 1 页，建立新查询快照 |
| 提交排序 | 更新完整排序，处理选择，回第 1 页，建立新快照 |
| 翻页 | 建立目标页快照；页内选择清除 |
| 修改页大小 | 校验允许值，回第 1 页，清选择，建立新快照 |
| 显式刷新 | 相同在途查询意图合并；不同意图建立新快照 |
| 刷新失败 | 保留旧行，进入 `refresh-error`，`stale=true` |
| 无效末页 | 只恢复一次到最新有效末页，不循环重试 |

查询响应必须同时满足：

```text
live
&& ownerId 匹配
&& lifecycleToken 匹配
&& requestGeneration 匹配
&& snapshotId 匹配
```

取消请求只用于节省资源，不能替代上述门禁。

### 批量操作

局部 `phase` 枚举是本产品实现配置：

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

只有非空、有效且不处于待重新确认状态的选择可以进入 `confirming`。

提交前冻结：

```text
operationSnapshot = {
  ownerId,
  operationId,
  operationGeneration,
  operationType,
  capturedSelectionGeneration,
  selectionMode,
  selectedRecordIds | selectionSnapshot,
  excludedIds,
  expectedCount,
  permissionScope,
  datasetVersion,
  operationSnapshotId
}
```

一次尝试使用一个新 `idempotencyKey`。处于 `submitting/in-flight` 时，点击、Enter、Space 或事件重放都只能记录 `operation-submit-ignored`，不得产生第二请求。

## 6. 确认、部分成功和失败重试

### 确认 Dialog

破坏性操作必须显式确认；高影响或不可逆操作使用更强确认，例如输入影响数量或指定确认短语。确认内容必须显示：

- 操作名称。
- 预计影响数量。
- 已应用筛选范围。
- 排除数量。
- 不可操作数量。
- 不可逆性、权限或版本风险。

Dialog 使用原生 `<dialog>` 或 `role="dialog" aria-modal="true"`：

- 遮罩点击不关闭。
- 标题、右上角关闭、取消和确认均有可访问名称。
- `Tab/Shift+Tab` 限制在 Dialog 内。
- 破坏性场景初始焦点置于取消按钮或标题，不默认聚焦危险操作。
- `Escape` 在未提交且无未保存风险时关闭最上层 Dialog。
- 外框不滚动，只允许内容区滚动，标题和操作区固定。
- 打开为 `200ms ease-out` 淡入并由 `scale(.96)` 到 `scale(1)`；关闭为 `150ms ease-in`；Reduced Motion 下取消缩放并缩短至不超过 50ms。
- 取消或关闭后恢复到批量操作触发器。
- 确认后，Dialog 完成关闭和清理，再将焦点一次移动到内联操作状态区；操作状态区随后拥有业务结果。
- 路由卸载期间不播放退出动画，也不返回焦点。

### 结果裁决

任何业务终态前必须同时通过：

```text
live
+ ownerId
+ lifecycleToken
+ operationId
+ operationGeneration
+ operationSnapshotId
```

并验证：

```text
adjudicatedCount === expectedCount
且裁决身份集合 === 操作快照目标集合
```

全量范围可以通过不可变目标清单和裁决清单验证集合相等，但不能仅比较数量。

终态规则：

- `all-success`：全部成功、失败为 0；代次匹配时清除已完成选择，并建立一个新查询快照刷新。
- `partial-success`：成功和失败均非空、互不相交、并集完整；成功项不得重试，失败项保留稳定 ID、原因和可重试性。
- `all-failed`：成功为 0；保留原操作快照，选择代次匹配时保留选择。
- `permission-conflict`：重新解析范围，移除越权项并要求用户确认新数量；越权项不自动重试。
- `dataset-version-conflict`：旧操作快照失效，刷新数据并要求重新选择或重新确认。
- `outcome-unknown`：数量、集合、重复项、外部 ID 或缺项不一致；保留选择和快照，提供“核对操作结果”，不得执行任何成功清理或重试分区。

### 部分成功后的刷新与重试

部分成功后：

1. 使用新查询快照刷新成功子集；只有在稳定 ID 和数据版本可证明一致时才允许确定性本地重整。
2. 刷新过程中操作结果摘要、失败项、失败原因、可重试性和重试入口持续保留。
3. “重试失败项”只取 `retryableFailedIds`。
4. 新重试生成新的 `operationId`、`operationGeneration`、`operationSnapshotId` 和 `idempotencyKey`。
5. 已成功项和不可重试失败项的重试请求必须为 0。
6. 重试后某项成功，只移除该项；不得清除仍失败或不可重试的项目。

## 7. 加载、错误和空状态

| 场景 | 呈现与恢复 |
| --- | --- |
| 首次加载 | 无可用数据时显示与最终列结构一致的不可操作骨架；结果容器 `aria-busy="true"` |
| 刷新 | 保留上次成功行、分页与焦点意图；显示“正在更新，以下为上一结果”，不能把旧行标成已匹配新条件 |
| 初次查询失败 | 结果区域以文本错误和可聚焦“重试加载”替代表格 |
| 刷新失败 | 保留旧表格，显示“数据可能已过期”，`stale=true`，提供重试 |
| 筛选零结果 | 显示“当前条件无匹配”，提供调整、单独移除或重置筛选 |
| 空数据集 | 显示独立空数据集状态，不提供无意义的全选或批量工具栏 |
| 全量范围解析失败 | 保留当前页选择；错误归选择 owner，提供“重试选择全部结果” |
| 批量操作进行中 | 批量工具栏和结果区表达执行中；所有提交入口阻止重复请求 |
| 批量失败 | 错误归批量结果 owner；失败项展示具体原因和适合的恢复入口 |
| `outcome-unknown` | 不宣称成功或失败；提供核对入口，并保留操作快照 |

筛选字段错误由字段 owner 管理：

- `filterDraft` 与 `appliedFilters` 分离。
- 只有字段 owner 提交的合法业务值可进入表格草稿。
- 字段错误紧邻字段，使用 `aria-invalid` 和 `aria-describedby`。
- 非法草稿不创建查询。
- “重置”恢复 `{status:"active"}`，不是含糊地清空全部条件。
- 已应用条件持续显示为可单独移除的摘要项。
- 仅 `status` 等声明为 `urlSafe` 的值进入 URL；账号、人员标识和敏感自由文本不得进入 URL、页面标题或分析日志。

## 8. DOM、键盘、焦点和 ARIA

### Table 语义

使用原生 `<table>`：

- 通过 `<caption>` 或 `aria-labelledby` 提供“可批量处理记录”名称。
- `<th scope="col">` 建立列关联；必要时使用行表头表达记录身份。
- 不添加 `role="grid"`。
- 静态单元格不设置 `tabindex="0"`。
- 不接管方向键、Home、End、Page Up 或 Page Down。
- `Tab` 只进入复选框、排序按钮、分页按钮、批量操作和恢复入口。

### 键盘

- `Space` 切换聚焦的原生复选框。
- `Enter/Space` 激活“选择全部筛选结果”、排序、分页、批量确认和重试按钮。
- 表头全选、行选择、范围确认、批量提交和失败重试均可完全用键盘完成。
- 排序按钮使用 Enter/Space；新排序回第 1 页。
- 页码按钮、跳页输入和页大小控件使用各自原生键盘语义。
- 禁止使用 Hover、长按、拖动或滑动作为唯一入口。

### 选择语义

优先使用原生 `<input type="checkbox">`：

- 表头混合态设置 DOM `indeterminate=true`；自绘实现才使用 `aria-checked="mixed"`。
- 表头名称示例：“选择当前页可操作记录，已选 7，共 20”。
- 行复选框名称示例：“选择记录 ACME-1024”。
- 不可选行使用原生 `disabled`，并通过存活说明节点关联具体原因。
- 全量摘要示例：“已选择全部 237 条可操作结果，排除 2 条，实际将处理 235 条”。

### 公告

使用三个互不重复的 primary owner：

- 查询结果 owner：查询开始、结果数量或位置变化、失败、失效页恢复。
- 选择 owner：全量范围确认、资格变化、范围失效或待重新确认。
- 操作结果 owner：批量开始、全部成功、部分成功、失败、冲突和未知结果。

每个被接受且需要反馈的事件只公告一次简洁摘要。被合并、丢弃、取代或 disposal 后到达的事件不公告。完整错误只由一个 owner 呈现和播报。

### 焦点

- 编辑筛选、应用筛选和提交排序时，请求本身不抢焦点。
- 刷新后精确 `recordId + columnId + controlId` 仍存在时保持焦点。
- 目标消失时按顺序迁移一次：同记录等价控件 → 同列最近记录 → 结果摘要/标题 → 分页控件。
- 翻页匹配响应后聚焦结果摘要一次；无效页自动恢复不能再次抢焦点。
- 操作结果提交后，原目标仍存活且语义不变时保持焦点；目标消失时移动一次到结果摘要、失败项、重试或重新确认入口。
- 最终焦点不得落到 `document.body`、文档根或已移除节点。

## 9. 桌面与移动端适配

### 桌面

- 筛选区、已应用条件摘要、结果摘要、批量工具栏和分页保持明确层级。
- 表格宽度不足时，仅表格容器横向滚动；页面根不得横向溢出。
- 选择列和记录身份列位于最左侧，主要状态和主要操作优先呈现。
- 横向滚动区域提供首尾阴影或文字提示，且键盘可滚动到全部内容。

### 平板与移动端

本实例不转换为卡片，以避免未经评审的字段映射改变表格语义：

- 筛选字段重排为单列；已应用条件摘要保持可见、可移除。
- 批量摘要与操作按钮纵向排列，不使用无名称的省略号入口。
- 表格放入独立横向滚动容器；关键选择、记录身份和主要状态位于最前列。
- 记录身份和批量操作无需横向滚动到最右端即可完成。
- Dialog 在窄屏采用接近全宽的模态布局，仍保持固定标题/操作区和单独内容滚动，不改变为未声明的 Drawer。
- 触摸目标按至少 44 CSS px 的产品阈值实现，并留出防误触间距。
- 处理动态视口、虚拟键盘和四向安全区域；批量摘要、错误和确认按钮不得被遮挡。
- 浏览器 200% 缩放下，关键批量流程不能同时依赖页面和表格的双向滚动。
- 实时断点变化保持同一 `ownerId`、查询、选择、排除项、操作快照与焦点意图；不得重放查询或批量请求。

## 10. Route/unmount disposal

路由提交离开或拥有表格的组件卸载时，同步执行幂等 `dispose()`：

1. 将 `status` 设为 `disposed`，使旧 `lifecycleToken` 永久失效。
2. 拒绝查询、翻页、选择、范围确认、焦点、操作、重试和公告新工作。
3. 中止或失效查询、分页恢复、选择协调、批量请求轮询、重试和防抖。
4. 清理当前实例的 Dialog、弹层、定位任务、计时器、监听器、观察器和订阅。
5. 失效排队中的焦点与 live-region 回调。
6. 移除本实例 DOM、popup 和 ARIA 引用。
7. 每项资源只由其 `ownerId` 释放一次，不影响其他存活表格或新路由。
8. 不运行普通 Dialog 关闭动画，不把焦点返回即将移除的旧触发器。
9. 新路由提交后，只由新路由焦点策略聚焦一次主标题、主内容或主要操作。

旧响应仍必须经过完整门禁：

- 查询：`live + ownerId + lifecycleToken + requestGeneration + snapshotId`
- 选择：`live + ownerId + lifecycleToken + selectionGeneration`
- 操作：`live + ownerId + lifecycleToken + operationId + operationGeneration + operationSnapshotId`

任一项不匹配时只记录对应 `*-discarded`；DOM、状态、焦点和 live region 写入均为 0。Abort 成功与否不影响正确性，也不得把本地处置记录成服务端业务已取消。

返回页面时只有显式 `restorePolicy` 才可恢复查询和滚动位置，并需重新验证权限、数据版本和分页位置。不得恢复旧选择、排除项、权限结果、Dialog、菜单或操作快照；新实例必须使用新的 `ownerId` 和 `lifecycleToken`。

## 11. 原子应用义务

| ruleFamily | obligationKey | applicability | currentValueOrZeroEvidence | outputLocation | verificationStatus |
| --- | --- | --- | --- | --- | --- |
| 筛选 | `draft-applied-separation` | 适用 | `filterDraft` 只接收字段已提交值；结果、URL 和请求只读取 `appliedFilters` | §4、§7 | 设计已定义；运行时未验证 |
| 筛选 | `declared-apply-mode` | 适用 | 当前实例为 `explicit`，仅“应用筛选”提交查询 | §1、§7 | 设计已定义；运行时未验证 |
| 筛选 | `default-reset` | 适用 | 重置到 `{status:"active"}`；语义未变化时请求数为 0 | §7 | 设计已定义；运行时未验证 |
| 筛选 | `visible-removable-applied-values` | 适用 | 每个已应用条件持续显示且有独立移除按钮 | §7、§9 | 设计已定义；运行时未验证 |
| 筛选 | `url-safety` | 适用 | 仅声明为 `urlSafe` 的状态等条件进入 URL；人员标识和敏感文本为 0 | §7 | 设计已定义；运行时未验证 |
| 筛选 | `field-error-owner` | 适用 | 字段错误归字段 owner，并使用 `aria-invalid/describedby`；不写 `queryError` | §7 | 设计已定义；运行时未验证 |
| 筛选 | `pagination-reset` | 适用 | 应用、移除或有效重置后回第 1 页并创建新查询快照 | §4、§5 | 设计已定义；运行时未验证 |
| 排序 | `actual-key-direction` | 适用 | 当前业务排序为 `displayName ASC` | §1 | 设计已定义；运行时未验证 |
| 排序 | `null-order` | 适用 | `NULLS LAST` | §1 | 设计已定义；运行时未验证 |
| 排序 | `case-rule` | 适用 | 大小写不敏感比较 | §1 | 设计已定义；运行时未验证 |
| 排序 | `locale-rule` | 适用 | `zh-CN` locale | §1 | 设计已定义；运行时未验证 |
| 排序 | `natural-order-rule` | 适用 | 开启自然数字排序，如“项目 2”在“项目 10”之前 | §1 | 设计已定义；运行时未验证 |
| 排序 | `unique-stable-key` | 适用 | 最后追加不可变 `recordId ASC` | §1、§5 | 设计已定义；运行时未验证 |
| 排序 | `interactive-dom` | 适用 | 可排序表头内使用真实 `<button>`；不可排序列按钮数为 0 | §8 | 设计已定义；运行时未验证 |
| 排序 | `interactive-aria` | 适用 | 主排序表头设置正确 `aria-sort`，按钮名称包含下一动作 | §8 | 设计已定义；运行时未验证 |
| 排序 | `interactive-keyboard` | 适用 | Enter/Space 提交排序，不接管方向键 | §8 | 设计已定义；运行时未验证 |
| 排序 | `interactive-focus` | 适用 | 请求不抢焦点；目标移除后仅一次迁移 | §8 | 设计已定义；运行时未验证 |
| 排序 | `reset-to-origin` | 适用 | 提交不同排序后回第 1 页并建立新快照 | §4、§5 | 设计已定义；运行时未验证 |
| 分页 | `reliable-total-and-range` | 适用 | 服务端提供可靠 `total/pageCount`，显示当前页、总页和结果范围 | §1、§2、§5 | 设计已定义；运行时未验证 |
| 分页 | `direct-pages` | 适用 | 提供直接页码；当前页使用 `aria-current="page"` | §8 | 设计已定义；运行时未验证 |
| 分页 | `validated-jump` | 适用 | 跳页只接受 `1..pageCount` 整数；非法值请求为 0 | §5、§8 | 设计已定义；运行时未验证 |
| 分页 | `native-boundaries` | 适用 | 首页“上一页”和末页“下一页”使用原生 `disabled` | §8 | 设计已定义；运行时未验证 |
| 分页 | `page-size-control` | 适用 | 页大小当前为 20，仅接受配置允许值 | §1、§5 | 设计已定义；运行时未验证 |
| 分页 | `reset-to-first` | 适用 | 筛选、排序、页大小变化回第 1 页 | §5 | 设计已定义；运行时未验证 |
| 分页 | `single-invalid-page-recovery` | 适用 | 当前页失效时只恢复一次到最新有效末页 | §5、§7 | 设计已定义；运行时未验证 |
| 分页 | `input-semantics` | 适用 | 页码按钮、跳页输入和页大小控件均使用原生输入语义及可访问名称 | §8 | 设计已定义；运行时未验证 |
| 分页 | `single-focus-transition` | 适用 | 匹配响应后聚焦结果摘要一次；自动恢复不产生第二次焦点 | §8 | 设计已定义；运行时未验证 |

## 12. 实现验收清单

| 原子规则族 | 适用性 | DOM | state | handler/event | request | 正文定位 | 验证状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 能力与状态 | 适用 | Table、筛选、选择列、批量工具栏 | 固定四组状态和独立 lifecycle guard | tier 解析与状态 owner 事件 | 查询、范围解析、批量请求 | §1–§3 | 未验证：需真实组件运行时 |
| 查询 | 适用 | 结果区、摘要、重试入口 | 快照、代次、phase、stale | query intent/response/discard | 查询端点 | §3、§5、§7 | 未验证：需可控乱序响应 |
| 筛选 | 适用 | 字段、应用、重置、条件摘要 | draft/applied/字段错误 | apply/remove/reset | 合法提交后查询 | §1、§4、§7 | 未验证：需真实字段与 URL |
| 排序 | 适用 | 表头排序按钮 | 完整稳定排序规则 | sort-committed | 排序后查询 | §1、§5、§8 | 未验证：需实际排序数据 |
| 分页 | 适用 | 页码、跳页、页大小 | numbered/page/pageCount | page-change/recovery | 合法页查询 | §1、§5、§8 | 未验证：需可靠总数后端 |
| 数据状态 | 适用 | 骨架、旧结果、错误、空状态 | requestPhase/queryError/stale | retry/refresh | 查询与重试 | §7 | 未验证：需加载失败和空数据夹具 |
| 选择 | 适用 | 表头/行复选框、范围摘要 | page/all-filtered/快照/代次 | select/exclude/reconfirm | 范围解析请求 | §4 | 未验证：需真实可选性和竞态 |
| 单行操作 | 不适用 | 0 | 0 | 0 | 0 | §1、§3 的 row absence contract | 设计声明；需运行时确认零入口 |
| 批量操作 | 适用 | 工具栏、确认 Dialog、结果和失败项 | operationSnapshot/phase/results | confirm/submit/retry/reconcile | 批量、重试、核对 | §3、§5、§6 | 未验证：需真实部分成功接口 |
| 基础列状态 | 适用 | 稳定列和表头关联 | visible/pinned/widths/density | 产品配置写入 | 0 独立请求 | §3、§8 | 未验证：需浏览器布局检查 |
| 可选列控制 | 不适用 | 0 | 0 | 0 | 0 | §1 的三个列控制关闭值 | 设计声明；需运行时确认零入口 |
| Table 语义 | 适用 | 原生 `<table>/<th>` | 表头关联和排序状态 | 原生键盘事件 | 0 独立请求 | §8 | 未验证：需可访问性树 |
| ARIA Grid 语义 | 不适用 | 0 | 0 | 0 | 0 | §1、§8 明确不使用 Grid | 设计声明；需运行时确认无 Grid role |
| 键盘 | 适用 | 原生复选框、按钮、输入 | 与指针共用意图状态 | Tab/Space/Enter/Escape | 复用查询或操作请求门禁 | §6、§8 | 未验证：需全键盘走查 |
| 焦点 | 适用 | 摘要、结果、错误和恢复目标 | focusIntent/稳定 ID | focus restore/migrate | 0 独立请求 | §6、§8、§10 | 未验证：需真实 focus 事件日志 |
| 响应式 | 适用 | 桌面表格、移动滚动容器、窄屏 Dialog | 同 owner 和业务状态 | breakpoint/viewport | 转换自身请求为 0 | §9 | 未验证：需多视口和实机 |
| ARIA 与公告 | 适用 | 名称、busy、mixed、live regions | 三类 announcement owner | accepted-only announcement | 0 独立请求 | §7、§8 | 未验证：需屏幕阅读器 |
| disposal | 适用 | 移除本实例 DOM、popup、引用 | disposed/token invalid | dispose/resource-release | 新请求为 0；旧请求失效 | §10 | 未验证：需 route/unmount 竞态 |
| 实例隔离 | 适用 | 每实例独立根节点和引用 | ownerId/token 命名空间 | 交错响应与释放日志 | 仅来源实例可提交 | §10 | 未验证：需同页双实例 |
| 运行时验证边界 | 适用 | 需浏览器、设备和辅助技术检查 | 需真实后端与竞态状态 | 需输入、焦点、路由日志 | 需真实查询和批量接口 | §13 | 未验证 |

## 13. 尚未通过真实运行环境验证的边界

以下均为设计要求，尚不能标记为运行时通过：

- Chrome、Safari、Firefox 下原生 Table、Dialog、混合态复选框和横向滚动行为。
- NVDA、JAWS、VoiceOver、TalkBack 对表头范围、禁用原因、`aria-busy`、混合态和三类公告 owner 的实际朗读。
- 仅键盘完成筛选、排序、分页、当前页全选、全量范围确认、批量提交和失败重试。
- 鼠标、触摸、Enter、Space 与事件重放是否都命中同一防重复提交门禁。
- `1440×900`、`1280×720`、平板横竖屏、`390×844` 窄屏、低高度横屏手机及 200% 缩放。
- 系统字体放大、长记录名、长错误、长翻译文本、高对比度和 Reduced Motion。
- 虚拟键盘、动态浏览器工具栏和四向 safe-area 下焦点、错误及主要操作是否被遮挡。
- 服务端总数、可操作总数、稳定 ID、`datasetVersion`、`rangeManifestId` 和范围规范化是否真实可靠。
- 大量排除项的传输上限、服务端排除集合实现和性能。
- 全量目标清单与裁决清单是否能证明集合精确相等，而不是只比较计数。
- 请求乱序、取消失败、旧筛选响应、旧选择协调结果和旧批量结果的迟到提交门禁。
- 部分成功刷新后失败项、原因、重试 owner 和焦点是否完整保留。
- 幂等键在点击、键盘重复触发、网络重试和服务端重复投递下是否真正 exactly-once。
- 权限缩小、数据版本冲突、结果集合缺项和 `outcome-unknown` 的真实恢复路径。
- 路由提交、浏览器返回、owner 卸载及同页双实例下的 disposal、资源释放计数和实例隔离。
- 旧请求在 disposal 后到达时，DOM、状态、焦点、公告及新路由写入是否全部为 0。
<!-- END RAW OUTPUT -->
