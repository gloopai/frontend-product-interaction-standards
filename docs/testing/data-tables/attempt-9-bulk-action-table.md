# Attempt 9 Bulk Action Table Evidence

## Actual spawn args

```text
task_name=attempt9_bulk_pressure
fork_turns=none
reasoning_effort=high
canonical_task=/root/selection_generation_fix/attempt9_bulk_pressure
```

<!-- BEGIN RAW PROMPT -->
你正在独立完成一次用户式前端规范应用任务。工作目录是数据表格规范工作树。请先完整阅读 SKILL.md 和它路由的数据表格 owner，然后为一个后台用户列表设计 bulk-action 数据表格方案：启用筛选、交互排序、numbered 分页、当前页选择、全部筛选结果选择和批量停用；关闭单行操作、列显示/固定/调宽；响应式使用内部横向滚动。严格按 owner 要求输出完整中文应用报告，包括能力当前值、固定状态组、lifecycle guard、操作子槽、二十行检查清单、原子应用义务、选择代次契约、失败恢复、语义/键盘/焦点/公告/disposal/实例隔离/验证边界。不要读取历史 attempt、审计器、诊断或答案，不要修改任何文件。最终只返回报告正文。
<!-- END RAW PROMPT -->

<!-- BEGIN RAW OUTPUT -->
# 后台用户列表 bulk-action 数据表格应用报告

## 1. 场景结论与能力当前值

本实例用于后台用户列表，采用原生 `<table>`、页码分页和表格容器内部横向滚动。用户可以筛选、交互排序、选择当前页、升级为选择全部筛选结果，并批量停用用户；不提供单行操作、列显示、列固定或列调宽。

以下筛选字段、默认值、排序键、风险阈值属于本产品配置，不扩展或放宽数据表格 owner：

| 能力字段 | 当前值 |
| --- | --- |
| `capabilityTier` | `bulk-action` |
| `resolvedTier` | `bulk-action` |
| `filteringEnabled` | `enabled` |
| `sortingEnabled` | `enabled`，`single` 交互排序 |
| `paginationMode` | `numbered` |
| `pageSize` | `25`，可选 `25 / 50 / 100` |
| `pageSelectionEnabled` | `true` |
| `allFilteredSelectionEnabled` | `true` |
| `rowOperationEnabled` | `false` |
| `bulkOperationEnabled` | `true`，唯一操作为“批量停用” |
| `columnVisibilityEnabled` | `false` |
| `columnPinningEnabled` | `false` |
| `columnResizeEnabled` | `false` |
| `responsivePresentation` | `internal-horizontal-scroll`，不转换为卡片 |

稳定记录标识为不可变 `userId`。当前可见列固定为：选择、用户、邮箱、状态、角色、最近活跃时间、创建时间；没有行操作列。不可停用的用户包括当前登录用户、权限不足范围内的用户、已停用用户和受保护的最后一名组织所有者；其复选框禁用并显示具体原因。

权限变化可令 `resolvedTier` 原子降级。降级时立即移除选择列、批量工具栏及相关交互状态；若焦点位于被移除控件，只迁移一次到结果摘要或当前分页控件。

## 2. 固定状态组

本实例恰好使用以下四组业务状态；生命周期另由独立 guard 管理。

### `queryState`

包含：

- `appliedFilters`
- `sortRules`
- `pagination: { mode: "numbered", page, totalPages, total, rangeStart, rangeEnd }`
- `pageSize`
- 不可变 `querySnapshot`
- `snapshotId`
- `datasetVersion`
- `requestGeneration`
- `requestPhase: idle | initial-loading | ready | refreshing | initial-error | refresh-error`
- `queryError`
- `stale`

每次查询先冻结 `appliedFilters`、完整排序、页码位置、页大小、权限范围和 `datasetVersion`，生成新 `snapshotId`，再同步令 `requestGeneration +1`。查询响应只有同时满足：

`live + ownerId + lifecycleToken + requestGeneration + snapshotId`

才可写入行、总数、页码、错误、阶段或 `stale`。取消请求仅节省资源，不能替代门禁。

同一在途查询意图在创建快照前合并；合并事件不新增快照、代次、请求或公告。权限范围等导致 `intentKey` 改变时，即使旧请求仍在途，也接受新查询并丢弃旧响应。

### `viewState`

包含：

- `visibleColumnIds = [selection, user, email, status, roles, lastActiveAt, createdAt]`
- `pinnedColumnIds = []`
- `columnWidths`：产品固定宽度映射，仅用于布局计算，不提供用户调整入口
- `density = "normal"`
- 当前结果行
- 当前结果摘要

列显示、固定、调宽关闭不删除这些基础字段。列状态只引用稳定 `columnId`；任何展示变化均不得发查询。本方案没有列控制 DOM、状态分支、handler 或请求入口。

### `interactionState`

包含：

- `focusIntent`
- 当前焦点的 `recordId`
- 当前焦点的 `columnId`
- `expandedRowIds = []`
- 单行操作槽未实例化
- `selectionMode: page | all-filtered | pending-reconfirmation`
- `selectionGeneration`
- `selectedIds`，仅用于 `page` 模式
- 当前不可变 `selectionSnapshot`
- `selectionSnapshotId`
- 全部范围的 `rangeKey`
- `eligibleTotal`
- `displayedSelectedCount`
- 选择恢复或失效原因

`excludedIds` 只能存在于不可变 `selectionSnapshot` 内，不能作为可独立漂移的 sibling 状态。

### `operationState`

批量子槽包含：

- `phase: idle | confirming | submitting | in-flight | outcome-unknown | all-success | partial-success | all-failed | permission-conflict | dataset-version-conflict`
- 不可变 `operationSnapshot`
- `operationSnapshotId`
- `operationId`
- `operationGeneration`
- `idempotencyKey`
- `successIds`
- `failedItems`
- `conflict`
- `errorOwnerId`
- `retryableFailedIds`
- `recoveryEntry`
- `resultFocusIntent`

查询错误不写入操作槽，批量错误也不写入 `queryError`。

## 3. 独立 `lifecycleGuard`

`lifecycleGuard` 不计入上述四组状态，包含：

- 稳定且实例唯一的 `ownerId`
- 不可复用的 `lifecycleToken`
- `status: live | disposed`
- `announcementOwnerId`
- `ownedResources`

`ownedResources` 至少登记查询控制器、失效页恢复、重试、防抖、选择协调任务、操作回调、待执行焦点和公告任务、监听器、计时器、观察器、订阅及 popup 定位资源。每项资源记录所属 `ownerId`。

## 4. 操作子槽

| operationKind | currentValue | stateSlot | DOM | handler/event | request |
| --- | --- | --- | --- | --- | --- |
| `row` | `not-instantiated` | `0` | `0` | `0` | `0` |
| `bulk` | `instantiated` | `bulk.phase / operationSnapshot / operationId / operationGeneration / idempotencyKey / result sets / recoveryEntry / resultFocusIntent` | 批量工具栏、范围摘要、强确认区、执行状态区、结果及恢复区 | 选择有效后打开确认；确认、提交、重试、重新确认、结果核对 | 首次尝试至多 1；每次合法重试使用新操作身份和新幂等键 |

## 5. 筛选方案

筛选字段配置如下：

- 状态：`applyMode=immediate`，默认值 `active`，`urlSafe=true`。
- 角色：`applyMode=immediate`，默认值为空集合，`urlSafe=true`。
- 创建时间范围：`applyMode=explicit`，默认值为空，`urlSafe=true`。
- 用户关键词：`applyMode=explicit`，可输入姓名、邮箱或用户 ID；按敏感自由文本处理，`urlSafe=false`，不得进入 URL、页面标题或分析日志。

`filterDraft` 与 `appliedFilters` 分离。表格只接收字段 owner 已提交且合法的业务值，不接收输入法草稿、Select 查询词、active option 或 popup 状态。结果标题、数量、请求参数和 URL 仅反映 `appliedFilters`。

“应用”只提交合法草稿；“重置”恢复：

`{ status: "active", roles: [], createdAt: null, keyword: "" }`

只有重置结果与当前 `appliedFilters` 语义不同时才请求。每个已应用条件持续显示在有名称的筛选摘要中，并有独立移除按钮；折叠字段的已应用值也不得消失。

应用、移除或有效重置筛选时：

1. 更新可见条件摘要。
2. 页码回到第 1 页。
3. `page` 选择清除；`all-filtered` 旧范围立即失效并清除。
4. 创建新查询快照、递增请求代次并请求。
5. 字段校验错误留在字段 owner；查询错误留在结果 owner。

## 6. 排序方案

采用 `single` 交互排序。可排序列为“创建时间”和“最近活跃时间”；当前排序为：

`createdAt DESC, userId ASC`

完整比较契约为：

- 业务键：`createdAt`
- 当前方向：`DESC`
- 空值：`NULLS LAST`
- 大小写：时间戳不适用，不进行字符串大小写折叠
- locale：时间戳按 UTC epoch 数值比较，不使用 locale collation
- 自然排序：`false`
- 唯一稳定键：不可变 `userId ASC`

选择“最近活跃时间”时采用：

`lastActiveAt DESC NULLS LAST, userId ASC`

可排序表头使用真实 `<button>`；按钮名称说明下一次动作，例如“按创建时间升序排列”。原生表格只在当前主排序 `<th>` 设置正确 `aria-sort`；未排序表头不伪造该状态。Enter、Space 激活原生按钮，表格不接管方向键。

提交不同排序时回第 1 页并建立新查询快照。`page` 选择立即清除；`all-filtered` 选择进入 `pending-reconfirmation`，在用户确认新排序下的范围、数量并绑定新查询快照前，批量停用请求为 0。发出排序请求本身不抢走仍存活的排序按钮焦点。

只有全部分页绑定同一 `datasetVersion` 时才承诺跨页无重复遗漏。页间版本变化时令当前链 `stale`，停止继续导航并从第一个有效位置重新开始。

## 7. numbered 分页方案

服务端必须提供可靠总数；否则不得渲染直接页码或跳页。

界面显示：

- “第 X / Y 页”
- “显示第 A–B 条，共 N 条”
- 直接页码
- 有名称的“跳转到页”输入
- 上一页、下一页
- 页大小 `25 / 50 / 100`

当前页使用 `aria-current="page"`。首页“上一页”和末页“下一页”使用原生 `disabled`。跳页只接受规范化后的十进制整数 `1..totalPages`；空值、非整数和越界输入显示输入错误且请求为 0。合法直接页码、上一页、下一页和跳页都各建立一个新快照和一个请求。

改变页大小后回第 1 页；服务端拒绝的页大小不能成为当前值。筛选、排序和页大小变化也都回第 1 页。

数据变化使当前页超过最新末页时，只请求一次最近有效页 `max(1, latestLastPage)`；成功后由结果 owner 公告一次新位置，重复失效响应不再恢复或抢焦点。

用户翻页时记录分页来源。匹配响应提交后焦点只移动一次到结果摘要；若产品选择保留仍存活且语义未变的分页触发器，也只能保留该目标且不得二次迁移。

## 8. 数据阶段与失败恢复

- 首次加载且无结果：`initial-loading`；仅显示与最终表格结构相符的不可操作骨架，结果容器 `aria-busy="true"`。
- 已有结果刷新：`refreshing`；保留旧行、分页和焦点意图，设置 `aria-busy="true"`，但明确旧行是上次结果。
- 首次失败：`initial-error`；以结果区域内的文本错误和可聚焦重试入口替代表格。
- 刷新失败：`refresh-error`、`stale=true`；保留旧行和分页，显示“数据可能已过期”及重试入口。
- 有已应用筛选但零结果：显示“当前条件无匹配”，提供调整或清除筛选入口。
- 无有效筛选且数据源为空：显示独立“尚无用户”状态，不复用“暂无数据”。
- 重试必须创建新快照和新请求代次；迟到响应不能清除新错误或覆盖新结果。

## 9. 选择范围与转换

### 当前页选择

初始 `selectionMode="page"`。每个行复选框只以稳定 `userId` 写入选择。不可选用户不进入选择或数量，其禁用控件名称包含用户身份和不可选原因。

表头复选框只控制当前页可选用户：

- 当前页可选数为 0：`unchecked + disabled`，并显示本页无可选用户的原因。
- 已选 0：未选。
- 已选部分：混合态。
- 已选全部：选中。

名称同时说明“当前页”、已选数和可选数，例如“选择当前页可停用用户，已选 7/20”。表头永远不表示整个筛选数据集。

`page` 模式在筛选应用/移除/重置、排序提交、翻页、页大小、权限范围或数据版本变化提交时清除。

### 全部筛选结果选择

必须先完成当前页全选，才显示独立二次操作：“选择全部 237 条符合当前条件且可停用的用户”。二次确认显示可靠可选总数和已应用筛选摘要。

确认后创建不可变 `selectionSnapshot`，至少冻结：

- `selectionSnapshotId`
- 来源 `querySnapshot`
- `rangeKey`
- `appliedFilters`
- `permissionScope`
- `datasetVersion`
- `eligibleTotal`
- `excludedIds = ∅`

取消某用户时创建新的不可变后继快照，并在新快照内部加入该 `userId`；重新选择时再创建后继快照并只移除该 ID。旧快照写入始终为 0。显示数量为：

`eligibleTotal - 有效 excludedIds 数量`

普通翻页只有在 `rangeKey`、权限范围和数据版本均未变化时才保留同一选择快照身份。任一页表头仍只依据当前页可选 ID 与当前快照的 `excludedIds` 计算三态。

筛选、权限或版本变化立即使旧范围失效、阻止操作并清除；仅排序变化进入待重新确认态。同范围资格变化只移除失效 ID、更新数量并公告一次。

## 10. 选择代次契约

| 路径 | `generationEffect` | `snapshotEffect` | `commitGuard` | `mismatchEffect` |
| --- | --- | --- | --- | --- |
| 资格变化 | 接受同范围资格变化时同步令 `selectionGeneration +1`，再启动任何依赖该意图的异步工作 | 创建新的不可变后继 `selectionSnapshot`，仅反映失效稳定 ID、总数或排除项变化；旧快照写入为 `0` | 若变化经异步协调，提交必须满足 `live + ownerId + lifecycleToken + selectionGeneration` | 任一失配只记录 `selection-result-discarded`；选择写入 `0`、公告 `0` |
| 异步选择协调回调 | 选择意图被接受时先同步令 `selectionGeneration +1`，再启动异步工作；回调不得递增代次，回调代次写入为 `0` | 只有门禁匹配且转换改变范围、排除项或可选总数时才创建不可变后继；不得原地改写 | 精确使用 `live + ownerId + lifecycleToken + selectionGeneration` 四项全匹配门禁 | 任一失配只记录 `selection-result-discarded`；选择写入 `0`、公告 `0` |
| 操作结果调整当前选择 | 操作结果本身不递增选择代次；写入前比较操作快照捕获的代次与当前 `selectionGeneration` | 仅捕获代次相等时，才可按完整终态创建合法后继或清除已完成选择；旧快照不修改 | `capturedSelectionGeneration === currentSelectionGeneration`，且操作结果先通过完整六项操作门禁 | 不匹配时只写原 `operation result owner`；当前选择写入 `0`，新选择保持不变 |

## 11. 批量停用生命周期

只有非空、有效且非待重新确认的选择可开始。确认开始时创建不可变 `operationSnapshot`，冻结：

- `ownerId`
- `operationId`
- `operationGeneration`
- `operationType="deactivate-users"`
- 捕获的 `selectionGeneration`
- `selectionMode`
- 页模式稳定 `userId` 集合，或全部模式的完整范围快照及其目标身份清单
- `excludedIds`
- `expectedCount`
- `permissionScope`
- `datasetVersion`

请求携带 `operationSnapshotId` 和本次尝试唯一 `idempotencyKey`。

“停用用户”按破坏性操作处理。确认界面显示操作类型、预计影响数、已应用筛选、排除数、不可操作数和后果。所有批量停用都需显式确认；全部筛选结果或 `expectedCount >= 100` 时使用产品配置的更强确认，要求再次输入显示的影响数量。未完成相应确认时请求为 0。

`submitting` 或 `in-flight` 期间，点击、Enter、Space 和事件重放合计只允许一个请求；重复触发只记录 `operation-submit-ignored`。关闭页面不能声称服务端任务已取消。

操作响应只有以下六项同时匹配才可提交：

`live + ownerId + lifecycleToken + operationId + operationGeneration + operationSnapshotId`

随后还必须满足：

- `adjudicatedCount === expectedCount`
- 裁决身份集合精确等于操作快照目标集合
- `successIds` 与 `failedIds` 不重叠、无重复、无外部 ID、无缺项

不满足时进入非终态 `outcome-unknown`，保留操作快照、当前选择和已有失败 owner，显示结果核对入口并公告一次；不得清理选择、重整成功子集或创建冲突恢复。

完整结果处理：

- 全部成功：成功数等于预计数且失败数为 0；选择代次仍匹配时清除已完成选择，随后创建新查询快照刷新。
- 部分成功：成功、失败均非空；成功项不再重试，失败项保留稳定 ID、原因、可重试性和恢复入口。成功子集用新查询快照刷新，或在 ID 与版本可证明一致时确定性本地重整。
- 全部失败：成功数为 0；保留不可变操作快照和合法当前选择，显示完整错误与重试。
- 权限冲突：重新解析范围，移除越权项，显示新数量并要求重新确认；越权项不自动重试。
- 版本冲突：立即使旧操作快照失效，刷新数据并要求重新选择或重新确认。
- 重试：只以可重试失败项建立新的 `operationId`、代次、快照和幂等键；成功项及不可重试项请求为 0。

## 12. 语义、键盘、焦点与公告

### 语义与键盘

本场景不需要单元格级二维导航，因此使用有名称和说明的原生 `<table>`，不使用 ARIA Grid。列头采用 `<th scope="col">`，用户身份列可按需要使用 `<th scope="row">`。

静态单元格不设置 `tabindex="0"`。表格不接管方向键、Home、End、Page Up 或 Page Down。Tab 顺序只进入筛选控件、排序按钮、复选框、分页、批量确认及恢复入口，并与视觉任务顺序一致。查询、翻页、选择、范围确认、批量提交和错误恢复均具有键盘路径；鼠标、触摸和键盘触发相同意图时采用相同状态转换和重复提交保护。

### 焦点

`focusIntent` 使用稳定的 `recordId + columnId + controlId + fallbackId`，不用数组索引。

- 筛选或排序发请求时不抢仍存活的触发控件焦点。
- 刷新后原目标仍存活且语义未变时，焦点事件为 0。
- 精确目标消失时，依次尝试同记录等价控件、同列最近记录、结果摘要或当前分页控件，最多迁移一次。
- 翻页匹配响应后最多一次到结果摘要；失效页自动恢复不产生第二次迁移。
- 操作结果提交前记录当前目标和结果类型的等价目标。目标存活时不移动；消失时恰好一次移至结果摘要、失败项、重试、重新确认或结果核对入口。
- 最终目标必须存活、可聚焦、有名称，不能是 `document.body`、文档根或已移除节点。

### 公告

分别设置唯一 primary owner：

- 查询和结果变化：结果 owner。
- 选择范围和资格变化：选择 owner。
- 批量开始、异常状态和终态：操作结果 owner。

每个被接受且需要反馈的事件恰好一次简洁公告。公告只摘要数量、位置和下一步，不逐行朗读用户，不串联全部筛选条件，不重复完整错误。合并、丢弃、取代、disposal 后到达及声明为静默失效的事件公告为 0。

## 13. 响应式内部横向滚动

所有视口继续使用同一原生表格实例和 `ownerId`；不启用卡片转换。

- 横向溢出只允许出现在具可访问名称的表格滚动容器，页面根横向溢出为 0。
- 容器提供非纯颜色的首端、末端和可继续滚动方向提示，并可被键盘聚焦后使用浏览器原生横向滚动；触摸可直接横向拖动。
- 用户身份、主要状态、选择和批量工具栏必须可定位；任何字段不得仅以 `display:none`、截断、无名称图标或 Hover 隐藏。
- 断点和旋转不重建实例，不清除筛选、分页、选择、排除项、焦点意图或操作快照，不新增查询、操作请求或操作代次。
- 200% 缩放时不得形成页面与表格同时双向滚动的关键流程；筛选、摘要、分页和批量结果位于页面主纵向流中。
- 低高度、动态工具栏、虚拟键盘和四向安全区域下，筛选提交、结果、分页、确认及错误恢复都可滚动到达。
- 长姓名、长邮箱、字体放大和翻译扩展不能丢失身份、错误含义或操作名称。
- `pinnedColumnIds=[]`，不存在固定列遮挡焦点或滚动边界的问题。

## 14. disposal 与实例隔离

路由提交离开或 owner 卸载时同步且幂等进入 `disposed`，不等待请求、菜单、选择协调或批量结果。

disposal 后：

- 查询、分页、菜单、选择、焦点、操作和公告新工作接受数均为 0。
- 取消或失效查询、失效页恢复、重试、防抖、选择协调、操作、焦点和公告回调。
- 注销监听器、计时器、观察器和订阅。
- 移除本实例表格 DOM、popup 和 ARIA 引用。
- 每项资源仅由其 `ownerId` 释放一次。
- 迟到查询仍经过五项查询门禁；迟到操作仍经过同一六项操作门禁。
- 门禁失败只记录 discarded 事件，DOM、状态、焦点和 live region 写入均为 0。
- 焦点不返回即将移除的旧 trigger；新路由提交后只由新路由策略移动一次。

同页多表格实例的 `ownerId`、`lifecycleToken` 和 `announcementOwnerId` 分别唯一。各实例的请求、选择和操作代次数值可以相同，但只在 `ownerId + lifecycleToken` 命名空间内解释。一个实例的查询、选择、操作、焦点恢复或 disposal 不得写入另一实例。

返回页面恢复是产品显式策略；恢复前重新校验权限、版本和可用页码。旧选择、排除项、权限结果、打开菜单和操作快照均不回放；恢复实例使用新的 `ownerId` 和 `lifecycleToken`。

## 15. 原子应用义务

| ruleFamily | obligationKey | applicability | currentValueOrZeroEvidence | outputLocation | verificationStatus |
| --- | --- | --- | --- | --- | --- |
| 筛选 | `draft-applied-separation` | 适用 | `filterDraft` 只接收字段 owner 已提交业务值；结果与请求只读 `appliedFilters` | “筛选方案” | 静态已定义；运行时未验证 |
| 筛选 | `declared-apply-mode` | 适用 | 状态/角色为 `immediate`；创建时间/关键词为 `explicit` | “筛选方案” | 静态已定义；运行时未验证 |
| 筛选 | `default-reset` | 适用 | 重置为 `{status:active, roles:[], createdAt:null, keyword:""}`；语义未变时请求为 0 | “筛选方案” | 静态已定义；运行时未验证 |
| 筛选 | `visible-removable-applied-values` | 适用 | 每项已应用值持续显示且具有独立、有名称的移除按钮 | “筛选方案” | 静态已定义；运行时未验证 |
| 筛选 | `url-safety` | 适用 | 仅状态、角色、创建时间可入 URL；关键词不得入 URL、标题或分析日志 | “筛选方案” | 静态已定义；运行时未验证 |
| 筛选 | `field-error-owner` | 适用 | 字段校验错误归字段 owner；查询错误归结果 owner | “筛选方案” | 静态已定义；运行时未验证 |
| 筛选 | `pagination-reset` | 适用 | 应用、移除、有效重置均回第 1 页并创建新快照 | “筛选方案” | 静态已定义；运行时未验证 |
| 排序 | `actual-key-direction` | 适用 | 当前 `createdAt DESC` | “排序方案” | 静态已定义；运行时未验证 |
| 排序 | `null-order` | 适用 | `NULLS LAST` | “排序方案” | 静态已定义；运行时未验证 |
| 排序 | `case-rule` | 适用 | 时间戳比较不做字符串大小写折叠 | “排序方案” | 静态已定义；运行时未验证 |
| 排序 | `locale-rule` | 适用 | UTC epoch 数值比较，不使用 locale collation | “排序方案” | 静态已定义；运行时未验证 |
| 排序 | `natural-order-rule` | 适用 | `false` | “排序方案” | 静态已定义；运行时未验证 |
| 排序 | `unique-stable-key` | 适用 | 追加不可变且唯一的 `userId ASC` | “排序方案” | 静态已定义；运行时未验证 |
| 排序 | `interactive-dom` | 适用 | 两个可排序表头各使用真实 `<button>`；不可排序列按钮数为 0 | “排序方案” | 静态已定义；运行时未验证 |
| 排序 | `interactive-aria` | 适用 | 当前主排序 `<th>` 设置 `aria-sort`；按钮名称说明下一动作 | “排序方案” | 静态已定义；运行时未验证 |
| 排序 | `interactive-keyboard` | 适用 | Enter/Space 激活原生按钮；方向键自定义 handler 为 0 | “排序方案” | 静态已定义；运行时未验证 |
| 排序 | `interactive-focus` | 适用 | 请求不抢焦点；目标消失时仅一次等价迁移 | “排序方案” | 静态已定义；运行时未验证 |
| 排序 | `reset-to-origin` | 适用 | 提交不同排序回第 1 页并新建查询快照 | “排序方案” | 静态已定义；运行时未验证 |
| 分页 | `reliable-total-and-range` | 适用 | 服务端提供可靠 `total`；显示当前页、总页数和 A–B/N 范围 | “numbered 分页方案” | 静态已定义；运行时未验证 |
| 分页 | `direct-pages` | 适用 | 渲染合法直接页码，当前页使用 `aria-current="page"` | “numbered 分页方案” | 静态已定义；运行时未验证 |
| 分页 | `validated-jump` | 适用 | 跳页只接受 `1..totalPages` 十进制整数；非法值请求为 0 | “numbered 分页方案” | 静态已定义；运行时未验证 |
| 分页 | `native-boundaries` | 适用 | 首页上一页和末页下一页使用原生 `disabled` | “numbered 分页方案” | 静态已定义；运行时未验证 |
| 分页 | `page-size-control` | 适用 | 当前 `25`，允许 `25/50/100`；拒绝值不提交 | “numbered 分页方案” | 静态已定义；运行时未验证 |
| 分页 | `reset-to-first` | 适用 | 筛选、排序和页大小变化回第 1 页 | “numbered 分页方案” | 静态已定义；运行时未验证 |
| 分页 | `single-invalid-page-recovery` | 适用 | 只恢复一次到 `max(1, latestLastPage)`；重复失效响应不重试 | “numbered 分页方案” | 静态已定义；运行时未验证 |
| 分页 | `input-semantics` | 适用 | 分页 `<nav>`、有名称跳页输入、当前页状态和原生禁用边界 | “numbered 分页方案” | 静态已定义；运行时未验证 |
| 分页 | `single-focus-transition` | 适用 | 匹配翻页响应后最多一次到结果摘要；自动恢复额外焦点为 0 | “numbered 分页方案” | 静态已定义；运行时未验证 |

## 16. 二十行应用检查清单

| 原子规则族 | 适用性 | DOM | state | handler/event | request | 正文定位 | 验证状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 能力与状态 | 适用 | bulk 选择列、批量工具栏；无越权空结构 | 固定四组状态及独立 guard | `tier-resolved`、原子权限降级 | 仅查询/合法批量路径可请求 | “场景结论”“固定状态组” | 静态方案已定义；运行时未验证 |
| 查询 | 适用 | 结果容器暴露 busy、错误、重试 | 不可变快照、代次、六阶段、stale | 查询意图合并与五项提交门禁 | 每个接受意图 1；合并/丢弃 0 | `queryState` | 静态方案已定义；运行时未验证 |
| 筛选 | 适用 | 四类筛选及持续摘要/移除入口 | `filterDraft` 与 `appliedFilters` 分离 | immediate/explicit 应用、重置、移除 | 每个语义变化 1；非法/无变化 0 | “筛选方案” | 静态方案已定义；运行时未验证 |
| 排序 | 适用 | 两个真实排序按钮 | 单列完整稳定排序 | `sort-committed`、原生键盘激活 | 每次不同排序 1 | “排序方案” | 静态方案已定义；运行时未验证 |
| 分页 | 适用 | 页码、跳页、边界、页大小 | 唯一 `numbered` 位置语义 | 合法导航、校验、单次恢复 | 合法目标 1；边界/非法 0 | “numbered 分页方案” | 静态方案已定义；运行时未验证 |
| 数据状态 | 适用 | 骨架、旧结果、错误、重试、两类空态 | 六阶段及 `stale` | 加载、刷新、失败、重试 | 接受查询 1；旧响应 0 | “数据阶段与失败恢复” | 静态方案已定义；运行时未验证 |
| 选择 | 适用 | 行/表头复选框、范围升级、持续摘要 | page/all-filtered/pending、代次、不可变快照 | 选择、排除、重确认、四项协调门禁 | 选择本身 0；依赖协调按意图至多 1 | “选择范围”“选择代次契约” | 静态方案已定义；运行时未验证 |
| 单行操作 | 不适用 | 0 | 0 | 0 | 0 | “操作子槽”row 行 | 静态零入口契约已定义；运行时未验证 |
| 批量操作 | 适用 | 工具栏、强确认、busy、结果与恢复区 | 不可变操作快照、代次、终态/unknown | 六项门禁、重复提交保护、重试 | 每次合法尝试至多 1 | “批量停用生命周期” | 静态方案已定义；运行时未验证 |
| 基础列状态 | 适用 | 固定列集合按稳定 `columnId` 渲染 | visible/pinned/widths/density/rows/summary | 基础展示写入不改查询 | 0 | `viewState` | 静态方案已定义；运行时未验证 |
| 可选列控制 | 不适用 | 0 | 0 | 0 | 0 | “场景结论”“viewState” | 静态零入口契约已定义；运行时未验证 |
| Table 语义 | 适用 | 原生 table、th scope、可访问名称 | 原生表格语义 | 不拦截导航键 | 0 | “语义与键盘” | 静态方案已定义；运行时未验证 |
| ARIA Grid 语义 | 不适用 | 0 | 0 | 0 | 0 | “语义与键盘” | 静态零入口契约已定义；运行时未验证 |
| 键盘 | 适用 | Tab 只进入真实控件 | 原生控件状态与业务意图一致 | 查询、分页、选择、确认、恢复均可键盘完成 | 查询/操作按意图至多 1 | “语义与键盘” | 静态方案已定义；运行时未验证 |
| 焦点 | 适用 | 最终目标存活、可聚焦、有名称 | 稳定 ID `focusIntent` | 保持或单次等价迁移 | 0 | “焦点” | 静态方案已定义；运行时未验证 |
| 响应式 | 适用 | 仅表格容器横向滚动；页面根不溢出 | 同 owner、状态与快照保持 | 断点转换不重放事件 | 断点转换 0 | “响应式内部横向滚动” | 静态方案已定义；运行时未验证 |
| ARIA 与公告 | 适用 | 名称、范围、busy、stale、错误非纯颜色表达 | 三类唯一公告 owner | 接受且需反馈恰好一次；丢弃事件 0 | 0 | “语义、键盘、焦点与公告” | 静态方案已定义；运行时未验证 |
| disposal | 适用 | 仅移除本实例 DOM、popup、ARIA 引用 | `live → disposed`，幂等一次 | 取消/失效资源，迟到回调门禁丢弃 | disposal 后新请求 0 | “disposal 与实例隔离” | 静态方案已定义；运行时未验证 |
| 实例隔离 | 适用 | 同名控件仍归各自实例 | owner/token/公告 owner 唯一命名空间 | 交错响应只提交来源匹配实例 | 每实例独立计数 | “disposal 与实例隔离” | 静态方案已定义；运行时未验证 |
| 运行时验证边界 | 适用 | 尚未检查真实 DOM/可访问性树 | 尚未运行真实状态机与竞态夹具 | 尚未执行键盘、触摸、disposal 顺序 | 尚未核对真实请求计数 | “运行时验证边界” | 未验证 |

## 17. 运行时验证边界

本报告完成的是规范应用设计和静态契约，没有实现代码，也没有执行浏览器、组件运行时、屏幕阅读器、键盘、触摸、真实接口或可控竞态测试，因此不能把上述项目写成运行时通过。

实现后至少需要验证：

- `1440×900`、`1280×720`、平板横屏、平板竖屏、`390×844` 窄屏、低高度横屏手机。
- 200% 浏览器缩放、字体放大、长姓名/邮箱、国际化扩展。
- 键盘、鼠标、触摸及辅助技术可访问性树。
- 虚拟键盘、动态视口、四向安全区域、高对比度或等价可视性。
- 表格内部横向滚动首端、中间、末端；页面根横向溢出为 0。
- 查询乱序、取消后迟到响应、同键刷新合并、不同 `intentKey` 并发。
- 当前页三态、零可选页、全部范围升级、排除项不可变后继、跨页保留、筛选/权限/版本失效及排序待重确认。
- 选择四项协调门禁、操作六项门禁，以及新选择不被旧操作结果覆盖。
- 全部成功、部分成功、全部失败、权限冲突、版本冲突和 `outcome-unknown`。
- 点击、Enter、Space 与事件重放下单次批量请求。
- 路由/unmount disposal、资源逐项一次释放、迟到回调零写入。
- 同页双实例、相同 generation 标量、交错响应及返回页面新 owner/token。
- 焦点目标存活时 `focus=0`，消失时等价目标 `focus=1`，后续刷新额外迁移为 0。
- 查询、选择、批量三个公告 owner 的一次公告和 discarded/merged/disposed 公告为 0。
<!-- END RAW OUTPUT -->
