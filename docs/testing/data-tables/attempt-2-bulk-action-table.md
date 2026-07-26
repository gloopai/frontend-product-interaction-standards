# Attempt 2 FAILED：批量操作数据表格

## 实际 spawn 参数

```json
{
  "task_name": "attempt_2_bulk_action_table",
  "fork_turns": "none",
  "message": "Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.\n\n请设计一个 bulk-action 数据表格。它要支持当前页选择，以及可选的“全部筛选结果”选择模式、排除项、筛选变化、部分成功、失败项重试和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配、选择与查询的关系，以及 disposal 后旧响应和资源如何处理；同时列出尚未通过真实运行环境验证的边界。\n\n请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。"
}
```

`model` 与 `reasoning_effort` 没有作为调用参数发送。

## spawn 工具返回

```json
{"task_name":"/root/table_task5_green/attempt_2_bulk_action_table"}
```

## 完成 envelope

- Message Type: `FINAL_ANSWER`
- Task name（recipient）: `/root/table_task5_green`
- Sender: `/root/table_task5_green/attempt_2_bulk_action_table`
- Payload: 以下 `BEGIN/END RAW OUTPUT` 之间的原始内容。

## 完整 Prompt

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个 bulk-action 数据表格。它要支持当前页选择，以及可选的“全部筛选结果”选择模式、排除项、筛选变化、部分成功、失败项重试和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配、选择与查询的关系，以及 disposal 后旧响应和资源如何处理；同时列出尚未通过真实运行环境验证的边界。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

## 原始完成 payload

<!-- BEGIN RAW OUTPUT -->
# Bulk-action 数据表格实现设计

## 1. 能力声明

| 配置项 | 本方案 |
| --- | --- |
| `capabilityTier` | `bulk-action` |
| `resolvedTier` | 权限允许时为 `bulk-action`；权限降低时可原子降级为 `row-action` 或 `display` |
| 分页模式 | `numbered`，依赖服务端提供可靠总数；不得与游标语义混用 |
| 当前页选择 | 启用，且为初始模式 |
| 全部筛选结果 | 可选启用；只有后端满足稳定范围、可靠可选总数、版本与完整裁决契约时开放 |
| 排除项 | 仅存在于不可变 `selectionSnapshot.excludedIds` 内 |
| 批量操作 | 启用 |
| 单行操作 | 不启用；DOM 中无行操作入口和状态 |
| 列显示、固定、调宽 | 本实例不启用；无列控制器、固定列、调整柄及相关状态 |
| 表格语义 | 原生 `<table>`，不使用 ARIA Grid |
| 移动端形态 | 保持单一表格实例，次要字段进入行详情，必要时使用受控横向滚动；不启用卡片形态 |

第一版不支持行内编辑、树表、拖拽行排序、透视、加载更多、无限滚动、列拖拽重排及个人布局持久化。高影响或不可逆、但尚未定义强确认机制的操作不得接入普通批量入口。

“全部筛选结果”需要后端同时提供：

- 稳定且不重复的记录 ID。
- 每条记录的 `eligible` 与不可选原因。
- 可靠的 `eligibleTotal`。
- 规范化筛选范围键 `rangeKey`、权限范围和不可变 `datasetVersion` 或等价服务端快照。
- 可冻结的目标清单 `targetManifestId`，以及能够精确核对目标身份集合的完整裁决账本。
- 幂等键支持、逐项成功/失败结果和可重试性。

缺少任一能力时，隐藏“选择全部筛选结果”入口，只保留当前页选择，不能退化为一个不可靠的 `allSelected=true`。

## 2. 状态与 owner

每个挂载实例创建唯一且稳定的 `ownerId`、不可复用的 `lifecycleToken`，并分离四组状态：

```ts
queryState = {
  appliedFilters,
  sortRules,
  pagination,
  pageSize,
  querySnapshot,
  snapshotId,
  datasetVersion,
  requestGeneration,
  requestPhase, // idle | initial-loading | ready | refreshing |
                // initial-error | refresh-error
  queryError,
  stale
}

viewState = {
  rows,
  resultSummary,
  displayedSnapshotId,
  expandedRecordIds
}

interactionState = {
  focusIntent,
  selectionMode,       // page | all-filtered
  selectedIds,         // 仅 page 模式
  selectionSnapshot,   // 仅 all-filtered 模式
  selectionGeneration,
  selectionPhase       // active | pending-reconfirmation
}

operationState = {
  phase,               // idle | confirming | submitting | in-flight |
                       // all-success | partial-success | all-failed |
                       // permission-conflict | version-conflict |
                       // outcome-unknown
  operationSnapshot,
  operationId,
  operationGeneration,
  idempotencyKey,
  successIds,
  failedItems,
  resultError,
  focusIntent
}
```

这些阶段名属于本实例的实现枚举，不得借此放宽后述快照、门禁、终态与恢复要求。查询错误只写入结果 owner；批量错误只写入操作结果 owner，不能用一个全局 `error` 覆盖两者。

## 3. 查询快照与提交门禁

每次应用筛选、排序、翻页、改变页大小、接受显式刷新或执行失效页恢复时：

1. 先冻结不可变 `querySnapshot`，至少包含已应用筛选、完整稳定排序、页码、页大小、权限范围、数据版本。
2. 生成新 `snapshotId`。
3. 严格递增 `requestGeneration`。
4. 再发出请求。

响应只有同时满足以下条件才能写入行、总数、分页、错误、阶段或 `stale`：

```text
live
&& ownerId 匹配
&& lifecycleToken 匹配
&& requestGeneration 匹配
&& snapshotId 匹配
```

取消请求只用于节省资源，不能替代门禁。迟到、已取消或乱序响应只记录 `response-discarded`，不得更新 DOM、状态、焦点或 live region。

相同查询意图已在途时，点击、Enter 或事件重放产生的重复刷新在创建快照前合并，不新增请求、代次或公告。权限、筛选或其他意图键发生变化时，即使旧请求仍在途，也必须接受新查询并使旧响应失效。

## 4. 选择与查询的关系

### 当前页模式

初始 `selectionMode="page"`。`selectedIds` 始终是当前页 `eligibleIds` 的子集：

- 行复选框只选择对应稳定 ID。
- 不可选行不进入集合或数量；行内显示具体原因。
- 表头复选框只控制当前页可选记录，不代表全数据集。
- 当前页全选为 `checked`，部分选择为 `mixed`，未选为 `unchecked`。
- 当前页无可选记录时，表头复选框为 `unchecked + disabled`，并提供可感知原因。
- 表头在未选或混合状态激活时选中本页所有可选项；全选状态激活时清除本页选择。

以下任何提交事件都同步清除 page 选择，并递增 `selectionGeneration`：

- 应用、移除或重置筛选。
- 提交排序。
- 翻页。
- 改变页大小。
- 权限范围或数据版本变化。

编辑筛选草稿、移动焦点、展开详情不会清除选择，也不会发查询。

### 全部筛选结果模式

只有产品配置启用且后端契约满足时提供。用户必须先完成当前页全选，随后才显示独立入口：

> 已选择当前页 20 条。选择符合当前筛选条件的全部 237 条。

确认时建立不可变 `selectionSnapshot`：

```ts
selectionSnapshot = {
  selectionSnapshotId,
  sourceQuerySnapshot,
  rangeKey,
  appliedFilters,
  permissionScope,
  datasetVersion,
  targetManifestId,
  eligibleTotal,
  excludedIds: new Set()
}
```

`excludedIds` 必须是快照内部字段。不得将其放在 sibling 状态，也不得仅保存布尔值或显示数量。

在全部模式中：

- 取消一行时创建新的不可变后继快照，只向其 `excludedIds` 增加该 ID。
- 重新选择时创建另一后继快照，只移除该 ID。
- 旧快照保持不变。
- 显示数量为 `eligibleTotal - 有效 excludedIds 数量`。
- 摘要持续显示模式、筛选范围、已选数和排除数。
- 表头仍只表达当前页：本页出现排除项时为混合态；取消本页全选会把本页所有可选 ID 加入排除项；重新全选本页会从排除项移除这些 ID。
- 同一 `rangeKey + permissionScope + datasetVersion` 下普通翻页保留同一个选择快照，不因新页面查询而重建。
- 同范围内资格变化时创建后继快照，移除失效 ID、修正总数和排除项，并由选择 owner 简短公告一次。

查询变化的处理如下：

| 查询变化 | page 模式 | all-filtered 模式 |
| --- | --- | --- |
| 普通翻页 | 清除 | 同范围、权限、版本不变时保留 |
| 应用/移除/重置筛选 | 清除 | 旧范围立即失效并清除，阻止操作 |
| 权限变化 | 清除 | 旧范围立即失效并清除 |
| 数据版本变化 | 清除 | 旧范围立即失效并清除 |
| 仅排序变化 | 清除 | 进入 `pending-reconfirmation`；确认新数量及快照前禁止操作，取消确认则清除 |
| 页大小变化 | 清除 | 只有范围、权限、版本不变且产品确认语义等价时可保留；默认清除以避免隐式扩大路径 |

每个已接受的选择意图都递增 `selectionGeneration`。异步选择协调结果至少校验 `live + ownerId + lifecycleToken + selectionGeneration`；不匹配结果不得覆盖当前选择。

## 5. 批量操作状态转换

```text
有效非空选择
  → confirming
  → submitting / in-flight
  → all-success
    | partial-success
    | all-failed
    | permission-conflict
    | version-conflict
    | outcome-unknown
```

进入确认前冻结不可变 `operationSnapshot`，至少包含：

- `ownerId`、`operationId`、`operationGeneration`、`operationSnapshotId`。
- 操作类型、选择代次和选择模式。
- page 模式的稳定 ID 集合，或 all-filtered 的完整范围快照、`targetManifestId` 与排除项。
- `expectedCount`、权限范围、数据版本。
- 本次尝试独立的幂等键。

确认区域采用表格上方的内联区域，显示操作类型、预计影响数量、筛选范围、排除数、不可操作数和风险。破坏性操作必须显式确认；未设计强确认的高影响操作不开放。

`submitting` 或 `in-flight` 时：

- 同一操作快照每次尝试最多发一个请求。
- 点击、Enter、Space 和事件重放均由状态门禁拒绝重复提交。
- 提交按钮保持在 DOM 中并暴露不可重复提交及忙碌状态；结果区域设置 `aria-busy="true"`。
- 用户后续改变页面选择不能修改已冻结的操作快照。

业务终态只有在裁决数等于 `expectedCount`，且裁决身份集合精确等于目标清单时才能提交：

- 全部成功：成功数等于预计数、失败数为零；若选择代次仍匹配才清除完成选择，并建立新查询快照刷新。
- 部分成功：成功和失败均非空、互不重叠且并集精确等于目标；成功项不再执行，失败项保留 ID、原因与可重试性。
- 全部失败：成功数为零、失败数等于预计数；保留选择与操作快照。
- 权限冲突：重新解析可操作范围，移除越权项，显示新数量并要求确认；不得自动重试越权项。
- 版本冲突：旧操作快照立即失效，刷新数据并要求重新选择或确认；不得复用旧幂等键。
- `outcome-unknown`：计数少、计数多、ID 重复/重叠、存在外部 ID、缺项，或无法完成目标身份核对时进入；它不是终态。保留选择、操作快照与已有失败 owner，只提供“核对结果/恢复”入口，完整裁决到达前不清选择、不重整成功项、不建立重试分区。

操作结果只有捕获的 `selectionGeneration` 仍等于当前代次时，才可移除成功项或清除选择；否则仅更新原操作结果 owner，不能影响用户后来建立的新选择。

部分成功后，成功子集通过新查询快照刷新；只有稳定 ID 和数据版本能够证明结果一致时才允许确定性本地重整。刷新不能清除失败项、原因、重试入口或操作结果摘要。

### 失败项重试

“重试失败项”只以 `retryable=true` 的失败 ID 建立新操作：

- 新 `operationId`。
- 新 `operationGeneration`。
- 新不可变 `operationSnapshot`。
- 新幂等键。
- 目标仅包含可重试失败项。

已成功项和不可重试项不得进入请求。旧操作或旧刷新迟到时不得覆盖新的失败集合。

操作响应统一使用六项门禁：

```text
live
&& ownerId
&& lifecycleToken
&& operationId
&& operationGeneration
&& operationSnapshotId
```

任一项不匹配，只记录 `operation-result-discarded`。

## 6. 加载、错误与空状态

| 场景 | 展现与恢复 |
| --- | --- |
| 首次加载 | 无可用结果时显示与最终列结构一致的不可操作骨架；结果容器 `aria-busy="true"`；骨架无复选框、链接或按钮 |
| 后台刷新 | 保留上次成功行、分页与焦点意图；明确标注为上次结果，不能声称已匹配新筛选；结果容器 busy |
| 首次加载失败 | 用结果区域内的文本错误和可聚焦“重试加载”替代表格；重试创建新快照和代次 |
| 刷新失败 | 保留旧行，进入 `refresh-error`，设置 `stale=true`；显示“数据可能已过期/当前条件尚未成功加载”和重试入口 |
| 筛选零结果 | 显示“当前筛选条件无匹配”，提供移除或重置筛选入口 |
| 数据源本身为空 | 独立显示“尚无数据”；不显示选择列、空批量工具栏或无意义全选 |
| 批量执行中 | 只在操作结果 owner 表达 busy；不污染查询加载状态 |
| 批量失败 | 完整错误只在操作摘要及对应失败项；查询区域不重复显示 |
| 当前页失效 | 请求最近有效页且只恢复一次；成功后播报新位置，不循环重试空页 |

## 7. DOM、键盘与 ARIA

使用原生 `<table>`：

- 以 `<caption>` 或 `aria-labelledby` 提供可区分名称。
- 表头使用 `<th scope="col">`，必要时记录身份列使用 `<th scope="row">`。
- 静态单元格不设 `tabindex="0"`。
- 不拦截方向键、Home、End、Page Up 或 Page Down。
- Tab/Shift+Tab 只进入真实复选框、排序按钮、详情按钮、分页与批量控件。
- 复选框使用 Space；按钮与分页使用 Enter/Space；鼠标、触摸和键盘必须产生相同意图与重复提交保护。
- 不支持点击任意行进行选择，避免行点击与链接、文本选择或详情入口冲突。

选择语义：

- 行复选框名称示例：“选择订单 A1024”。
- 表头复选框名称示例：“选择当前页全部 18 条可选订单，当前已选 7 条”。
- 原生复选框的混合态同时设置 DOM `indeterminate=true`，可访问性树应读取为 `mixed`。
- 不可选行显示可见原因，并以 `aria-describedby` 将原因与选择位置关联；不能只用灰色或锁图标。
- 全部模式摘要示例：“已选择当前筛选结果 236 条，排除 1 条”；筛选范围由相邻可见摘要说明，避免 live region 逐字朗读全部条件。

排序使用表头内真实按钮。只有当前主排序表头设置正确 `aria-sort`；多列排序优先级通过可访问文本表达。

结果、选择和批量操作各有唯一公告 owner：

- 查询开始、结果数量或位置变化、查询失败各简短公告一次。
- 全部范围确认、资格变化等需要反馈的选择事件公告一次；普通行复选框状态优先由原生控件自身表达。
- 批量开始、部分成功、失败、冲突和 `outcome-unknown` 各公告一次，只播报摘要，不逐行朗读。
- 同一 `errorId` 只有一个完整错误 owner 和一条完整公告路径。
- merged、discarded、superseded、disposed 或静默失效事件不公告。

## 8. 焦点管理

焦点意图以稳定 ID 保存：

```ts
{
  sourceEvent,
  recordId?,
  columnId?,
  controlId?,
  fallbackId
}
```

规则如下：

- 选择行或表头后，焦点保留在被激活的复选框；批量工具栏出现时不抢焦点。
- 打开内联确认时，将焦点一次移动到确认区域标题；Tab 按视觉顺序到取消和确认。取消后返回原批量动作按钮。
- 开始查询本身不移动筛选或排序触发器焦点。
- 用户翻页并提交匹配结果后，焦点一次移动到结果摘要/标题；失效页自动恢复不得再次抢焦点。
- 刷新后精确的 `recordId + columnId + controlId` 仍存在时保持焦点；不得按旧数组索引聚焦另一记录。
- 精确目标消失时，依次尝试同记录等价控件、同列最近记录、结果摘要/标题、分页控件。
- 操作结果提交时，当前目标仍存活、可聚焦且语义未变则不移动；目标消失时仅移动一次到该结果对应的摘要、首个失败项、重试、重新确认或结果核对入口。
- 最终目标不得是 `document.body`、文档根或已移除节点；后续成功子集刷新不得再次迁移。

## 9. 桌面与移动端

桌面端采用完整表格、上方筛选摘要、结果摘要、批量工具栏和页码区。

窄屏仍保留相同查询、选择、范围确认、危险确认、部分成功与重试能力：

- 记录身份、主要状态、行选择和主要操作直接可定位。
- 次要字段通过有名称的“查看订单 A1024 的更多字段”展开；详情保留字段标签、记录归属和确定顺序。
- 批量工具栏改为纵向布局，不使用会遮挡焦点或虚拟键盘的固定底栏。
- 必要横向滚动只发生在表格容器；页面根不横向溢出。
- 溢出容器仅在确实可滚动时成为一个有名称的焦点目标，并提供首尾边界及可滚动方向提示；静态单元格仍不加入 Tab 顺序。
- 不使用固定列；避免窄屏、200% 缩放和长文本下遮挡焦点、错误或滚动边界。
- 实时断点变化保持同一 `ownerId`、查询、分页、选择、排除项、展开状态、焦点意图及操作快照；不得重新查询、重放操作或递增操作代次。
- 200% 缩放、字体放大、长翻译、低高度、虚拟键盘、动态工具栏及四向安全区域下，筛选提交、结果、分页、批量摘要和错误恢复必须可滚动到达。
- 触摸目标不依赖精确点击；任何滑动路径均有点击和键盘替代。
- 任一时刻只有一个活动表格实例，不同时渲染桌面和移动副本。

## 10. 路由卸载、旧响应与资源释放

路由提交离开或拥有组件卸载时，同步、幂等地进入 `disposed`；不等待动画、查询或批量请求结束。

处置顺序：

1. 标记 `live=false`，使当前 `lifecycleToken` 失效。
2. 拒绝新的查询、翻页、选择、菜单、焦点、操作和公告工作。
3. 中止或失效查询、分页恢复、重试、防抖和批量轮询。
4. 关闭行详情相关 popup，取消定位回调。
5. 失效待执行的焦点、选择协调、操作结果和公告回调。
6. 注销本实例的监听器、计时器、观察器与订阅。
7. 移除本实例 DOM 和对应 ARIA 引用。
8. 按 `ownerId` 只释放自己持有的资源一次。

取消失败时，迟到响应仍必须经过查询或操作的完整提交门禁；门禁失败后的 DOM、状态、焦点和 live region 写入均为零。离开页面不等于服务端操作已取消，界面和日志不得如此宣称。

旧触发元素即将随路由移除时不返回焦点。新路由提交后，只由新路由焦点策略移动一次到页面主标题、主内容或主要操作。

返回页面默认创建全新 `ownerId + lifecycleToken`。只有产品显式声明恢复策略，且重新校验权限、数据版本和分页位置后，才能恢复查询与滚动；旧选择、排除项、权限结果、打开菜单和操作快照一律不回放。

同页多表格可以拥有相同数值的 request/selection/operation generation，但必须在各自 `ownerId + lifecycleToken` 命名空间内解释；一个实例的查询、选择、操作或 disposal 不得写入另一个实例。

## 11. 实现完成前适用性检查

| 规则族 | 结论与可观察依据 |
| --- | --- |
| 能力与状态 | 适用；实例显式声明 `bulk-action`，四组状态与权限降级路径存在 |
| 查询、筛选、排序、分页、数据状态 | 适用；唯一使用 numbered 分页，具快照、代次、门禁和分层状态 |
| 选择与批量操作 | 适用；page 与可选 all-filtered、排除项、部分成功和重试均启用 |
| 单行操作 | 不适用；配置关闭，DOM、状态和事件入口均不存在 |
| 列显示、固定、调宽 | 不适用；配置关闭，无控制器、固定样式、调整柄和状态写入 |
| 原生 Table | 适用；使用 `<table>`、header 关联和原生控件 |
| ARIA Grid | 不适用；没有单元格级二维导航需求，DOM 无 `role="grid"` |
| 焦点恢复 | 适用；按稳定记录/列/控件 ID 恢复 |
| 响应式 | 适用；同实例表格、行详情与受控横向滚动 |
| ARIA、公告与错误 owner | 适用；三类 primary owner 和单公告路径 |
| disposal 与实例隔离 | 适用；唯一 owner/token、完整门禁及逐资源释放 |
| 运行时验证边界 | 适用；以下项目在真实环境执行前不得标记通过 |

## 12. 尚未通过真实运行环境验证的边界

以下均为设计契约，尚未在真实浏览器、组件运行时、辅助技术和生产后端上验证：

- Chrome、Firefox、Safari 中原生复选框混合态、禁用原因和表头关联。
- NVDA、JAWS、VoiceOver 对表格名称、`mixed`、busy、stale、部分成功和 live region 去重的实际朗读。
- 仅键盘完成筛选、排序、分页、当前页选择、全部范围确认、批量提交和失败重试。
- 鼠标、触摸、Enter、Space 与事件重放下的单请求保护。
- 查询乱序、取消失败、选择协调迟到、六项操作门禁及 `outcome-unknown` 的真实竞态。
- 部分成功后成功子集刷新、失败 owner 保留和新重试隔离。
- 路由离开时服务端仍执行的批量工作，以及后续通过独立任务中心核对结果的产品路径。
- 后端 `eligibleTotal`、`datasetVersion`、目标 manifest、完整裁决账本和幂等键的端到端一致性。
- `1440×900`、`1280×720`、平板横竖屏、`390×844`、低高度横屏、200% 缩放、字体放大、虚拟键盘、动态视口和四向安全区域。
- 横向滚动边界提示、长文本、国际化扩展和触摸目标尺寸。
- 焦点目标在刷新、部分成功、权限降级和断点切换中存活/消失的两条分支。
- route/unmount 后计时器、监听器、观察器、订阅、popup、焦点任务和公告任务的逐项单次释放。
- 同页两个表格的交错响应、相同 generation 数值及 disposal 隔离。
- 浏览器返回时查询/滚动恢复校验，以及旧选择、排除项和操作快照不被回放。
<!-- END RAW OUTPUT -->
