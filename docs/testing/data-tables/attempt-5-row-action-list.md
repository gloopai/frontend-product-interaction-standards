# Attempt 5 FAILED：单行操作管理列表（原始证据）

## Spawn args

- `task_name=attempt_5_row_action_list`
- `fork_turns=none`
- `message`：见 RAW PROMPT，逐字相同
- `model`：not sent
- `reasoning_effort`：not sent

## Spawn tool return

`{"task_name":"/root/table_task5_green/attempt_5_row_action_list"}`

## Completion envelope metadata

- `Message Type FINAL_ANSWER`
- recipient `/root/table_task5_green`
- sender `/root/table_task5_green/attempt_5_row_action_list`

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个带 row-action 的管理列表。它使用游标分页，需要处理刷新失败、行菜单、焦点恢复、权限变化和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配，以及请求、菜单、焦点与其他资源在 disposal 时如何处理；同时列出尚未通过真实运行环境验证的边界。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

<!-- BEGIN RAW OUTPUT -->
# Row-action 管理列表设计说明

## 1. 能力声明与边界

当前实例采用以下固定配置：

| 能力项 | 当前值 |
| --- | --- |
| `capabilityTier` | `row-action` |
| `resolvedTier` | 当前为 `row-action`；操作权限全部失去时降为 `display`，不得升为 `bulk-action` |
| `filteringEnabled` | `false` |
| `sortingEnabled` | `false`，表示无用户可操作排序；仍采用服务端固定稳定排序 |
| `paginationMode` | `cursor` |
| `pageSize` | 固定 `25`，本版本无页大小控件 |
| `pageSelectionEnabled` | `false` |
| `allFilteredSelectionEnabled` | `false` |
| `rowOperationEnabled` | `true` |
| `bulkOperationEnabled` | `false` |
| `columnVisibilityEnabled` | `false` |
| `columnPinningEnabled` | `false` |
| `columnResizeEnabled` | `false` |
| `responsivePresentation` | `desktop-table / mobile-card` |

本版本提供：记录详情链接、行操作菜单、可幂等的单行状态操作、显式刷新、上一组/下一组游标导航、权限实时收敛、刷新失败恢复和路由卸载处置。

本版本不提供：筛选、交互排序、多选、全选、批量操作、页码/总页数/随机跳页、加载更多、无限滚动、行内编辑、树形行、行拖拽、列显示/固定/调宽、个人布局持久化。不可逆或高风险删除不直接放入本菜单；若未来启用，必须另行设计风险确认流程。

固定排序合同为：

```text
updatedAt DESC NULLS LAST,
recordId DESC
```

- `updatedAt` 是业务主键，按时间降序；字段即使当前声明非空，也固定约定 `NULLS LAST`。
- 日期时间不存在大小写、locale 或自然排序差异，这三项为 `N/A`。
- `recordId` 必须唯一、不可变，作为最终稳定次序键。
- 服务端必须按同一比较规则生成游标，并返回不可变 `datasetVersion` 或等价快照身份；否则界面不得承诺跨页绝无重复或遗漏。
- 桌面表格在“更新时间”表头设置 `aria-sort="descending"`，并显示“按更新时间降序”；不渲染伪排序按钮。

桌面与移动端断点、卡片字段映射和菜单定位算法属于本产品实现配置，不得改变上述能力、权限、请求、焦点或 disposal 约束。

## 2. 状态结构

状态严格分为以下四组，生命周期另设 guard，不能合并为一个宽泛的 `loading/error/menu` 状态。

### `queryState`

```ts
{
  appliedFilters: {}, // 固定为空
  sortRules: [
    { field: "updatedAt", direction: "desc", nulls: "last" },
    { field: "recordId", direction: "desc", unique: true, immutable: true }
  ],
  pagination: {
    mode: "cursor",
    direction: "initial" | "previous" | "next",
    cursorUsed: string | null,
    previousCursor: string | null,
    nextCursor: string | null,
    recoveryAttempted: boolean
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

筛选的 absence contract：没有 `filterDraft`、筛选 DOM、筛选 handler、筛选请求入口或 URL 筛选序列化；`appliedFilters` 仅为查询最少字段，固定为空。

### `viewState`

```ts
{
  visibleColumnIds: ["name", "status", "owner", "updatedAt", "actions"],
  pinnedColumnIds: [],
  columnWidths: { /* 产品固定宽度或响应式约束 */ },
  density: "comfortable",
  rows,
  resultSummary,
  presentation: "table" | "card"
}
```

列控制相关 DOM、状态写入口和请求入口均不存在。`name`、`status`、`actions` 是关键字段，移动端不得无入口隐藏。

### `interactionState`

```ts
{
  focusIntent: {
    sourceEvent,
    recordId?,
    columnId?,
    controlId?,
    fallbackId
  } | null,
  focusedRecordId: string | null,
  focusedColumnId: string | null,
  expandedRecordId: null,
  openRowAction: {
    recordId,
    triggerId,
    menuId,
    activeActionId,
    permissionRevision,
    menuGeneration
  } | null
}
```

本实例不建立任何选择模式、选择代次、选中 ID、全部筛选结果范围或排除项；选择列、表头复选框、选择 handler 和选择请求均必须为零。

`expandedRecordId` 固定为 `null`，当前版本没有展开行 DOM 或 handler。

### `operationState`

```ts
{
  rowOperation: {
    phase:
      | "idle"
      | "submitting"
      | "in-flight"
      | "all-success"
      | "all-failed"
      | "permission-conflict"
      | "dataset-version-conflict"
      | "outcome-unknown",
    operationId,
    operationGeneration,
    operationSnapshotId,
    operationSnapshot,
    idempotencyKey,
    errorId,
    errorOwnerId,
    retryTarget,
    resultFocusIntent
  } | null,
  bulkOperation: null
}
```

单行操作快照至少冻结：

```ts
{
  ownerId,
  lifecycleToken,
  operationId,
  operationGeneration,
  operationSnapshotId,
  recordId,
  actionId,
  permissionScope,
  permissionRevision,
  datasetVersion,
  expectedCount: 1,
  idempotencyKey
}
```

批量操作的状态槽、DOM、确认入口、handler 和请求入口均不实例化。单行操作错误属于对应记录的操作 owner，不得写入 `queryError`。

### 独立 `lifecycleGuard`

```ts
{
  ownerId,
  lifecycleToken,       // 每次挂载新建且永不复用
  status: "live" | "disposed",
  announcementOwnerId,
  ownedResources
}
```

所有 DOM ID、请求、菜单、焦点任务、公告和资源日志都以 `ownerId + lifecycleToken` 命名空间隔离。

## 3. 查询、游标与提交门禁

每次被接受的首次查询、上一组、下一组、显式刷新、重试、权限范围更新或失效游标恢复，都执行：

1. 冻结 `appliedFilters`、完整固定排序、游标方向与不透明游标、`pageSize=25`、权限范围和 `datasetVersion`，生成不可变 `querySnapshot` 与 `snapshotId`。
2. `requestGeneration` 严格加一。
3. 发出请求并由结果 owner 公告一次开始状态。
4. 响应只有同时满足以下五项才可提交：

```text
live
&& ownerId 匹配
&& lifecycleToken 匹配
&& requestGeneration 匹配
&& snapshotId 匹配
```

取消请求仅用于节省资源，不能替代提交门禁。旧请求即使取消失败并迟到，也只能记录 `response-discarded`，不得更新行、游标、错误、焦点、DOM 或 live region。

显式刷新先计算：

```text
intentKey =
  appliedFilters
+ sortRules
+ cursor position
+ pageSize
+ permissionScope
+ datasetVersion
+ refreshReason
```

同一 `intentKey` 已在途时，点击、Enter 或事件重放均合并到现有工作，不创建新快照、代次、请求或公告。不同意图不得因“已有任意请求在途”而被全局合并。

游标要求：

- 首次查询使用 `cursor=null`。
- 只保存和回传服务端给出的不透明 `previousCursor`、`nextCursor`，客户端不得解析或拼接。
- 仅显示“上一组”“下一组”；缺少对应游标时使用原生 `disabled`。
- 不显示总页数、直接页码、跳页、加载更多或无限滚动入口。
- 在途期间控件保持可感知；重复导航由意图门禁拦截，不产生第二请求。
- 服务端报告当前游标失效时，只允许按其给出的最近有效前向位置或初始游标恢复一次；成功后公告一次，重复失效响应不得循环恢复。
- 页面响应的 `datasetVersion` 与当前游标链不一致时，立即令链失效并置 `stale=true`，停止继续导航，从初始位置建立新链。

## 4. 数据状态与转换

| 事件 | 前态 | 后态与界面 |
| --- | --- | --- |
| 首次挂载 | `idle` | `initial-loading`；无可用行，显示与最终结构匹配的不可操作骨架，结果区 `aria-busy=true` |
| 首次成功且有数据 | `initial-loading` | `ready`；提交行、游标、版本和结果摘要，`stale=false` |
| 首次成功且零数据 | `initial-loading` | `ready`；显示“尚无可管理记录”，不渲染空表格框和虚假行 |
| 首次失败 | `initial-loading` | `initial-error`；结果区域显示完整文本错误和可聚焦“重试加载”按钮 |
| 显式刷新 | `ready` | `refreshing`；保留旧行、游标上下文和焦点意图，标明“正在刷新，当前显示上次结果” |
| 刷新成功 | `refreshing` | `ready`；原子提交新结果，清除 `queryError` 和 `stale` |
| 刷新失败 | `refreshing` | `refresh-error`；保留旧行、分页和焦点，`stale=true`，显示“刷新失败，数据可能已过期”及“重试刷新” |
| 上一组/下一组 | `ready` | 使用 `refreshing`；旧组暂留但明确标记正在加载目标组，匹配成功后一次替换 |
| 游标失效 | 任意查询态 | 标记链失效，只执行一次恢复请求；恢复成功不产生第二次抢焦点 |
| 普通重试 | `initial-error` / `refresh-error` | 建立新快照和新代次，分别回到 `initial-loading` / `refreshing` |
| permission scope 变化 | 任意 live 态 | 使旧快照和游标链失效，回初始游标建立新查询 |
| 路由离开/owner 卸载 | 任意 live 态 | 同步进入 `disposed`，不等待请求、菜单动画或操作结果 |

刷新失败不能清空旧行或把行操作失败伪装成查询失败。完整查询错误只由结果区域拥有并公告一次。

当前实例没有筛选，因此不存在“当前条件无匹配”分支；不得用它代替真实空数据集状态。未来启用筛选时必须另行增加筛选草稿、已应用值和“无匹配”恢复路径。

权限缩小时，任何可能已越权的可读数据必须先从 DOM 移除；只有能证明仍在新读取范围内的行才可在权限刷新期间保留。

## 5. 行结构与操作菜单

### 桌面行结构

使用原生 `<table>`：

- 表格由页面标题或独立标题通过 `aria-labelledby` 命名。
- 每行名称单元格使用 `<th scope="row">`，详情链接位于其中。
- 状态、负责人、更新时间使用普通 `<td>`。
- 操作列内使用真实 `<button>`。
- 详情链接与菜单触发器是两个独立控件；整行不得包装成大链接。
- 静态单元格不设置 `tabindex="0"`。

菜单触发器名称为“打开「记录名称」的操作菜单”，并使用：

```html
<button
  aria-haspopup="menu"
  aria-expanded="true|false"
  aria-controls="menu-id">
```

菜单未挂载时移除失效的 `aria-controls` 引用。菜单使用单一 `role="menu"`，操作项为真实按钮并具有 `role="menuitem"`。未授权操作直接不渲染；业务状态暂不可用的操作可以保留为 `aria-disabled="true"`，同时提供具体原因。

每次只允许一个行菜单打开。`openRowAction` 必须保存稳定 `recordId`、活动动作 ID 和菜单代次，不能保存数组索引。

### 菜单键盘模型

- 触发器 `Enter`、`Space` 或 `ArrowDown`：打开并聚焦第一个可用项。
- `ArrowUp`：打开并聚焦最后一个可用项。
- 菜单内 `ArrowDown/ArrowUp`：在可用项间移动。
- `Home/End`：移动到首项/末项。
- 可选实现首字母搜索，但不得改变上述基本键盘路径。
- `Enter/Space`：只激活当前项一次。
- `Escape`：关闭并仅一次返回原触发器；触发器不存在时执行记录级 fallback。
- `Tab/Shift+Tab`：关闭菜单并继续到菜单前后合理的 Tab 目标，不形成焦点陷阱。
- 指针点击外部：关闭菜单，但不得从用户刚点击的目标抢回焦点。
- 菜单打开后不得由 Table 接管方向键。

菜单为非模态 popup，不锁页面滚动，不创建遮罩或焦点陷阱。定位实现必须处理滚动容器、视口边界、缩放、长文本和安全区域；重要操作不能只通过 Hover 发现。

### 操作提交

详情/编辑类导航项关闭菜单后交给路由处理，旧页面不执行返回焦点；新路由按自身策略聚焦主标题、主内容或主要操作。

请求型单行操作：

1. 激活菜单项时记录 `focusIntent`，关闭菜单并把焦点返回仍存活的行触发器。
2. 建立不可变操作快照、唯一 `operationId`、代次和幂等键。
3. `submitting/in-flight` 期间，点击、Enter、Space 和事件重放不得产生第二请求。
4. 单行响应同时通过以下六项门禁后才能提交：

```text
live
&& ownerId
&& lifecycleToken
&& operationId
&& operationGeneration
&& operationSnapshotId
```

5. 响应还必须精确裁决快照中的唯一 `recordId`。缺项、外部 ID、重复或矛盾结果进入 `outcome-unknown`，保留快照，提供“核对最新结果”入口，不自动重试。
6. 成功后仅建立一次新查询快照刷新受影响数据。
7. 明确失败显示在该记录的操作结果 owner，并提供可用重试；重试生成全新的操作身份和幂等键。
8. 变更型请求不做无条件自动重试，也不复用旧幂等键。

如果操作结果提交后原焦点目标仍存在、可聚焦且语义未变，则不移动焦点；若行或触发器消失，只移动一次到同记录等价控件、同列相邻记录操作、操作结果摘要或结果标题，绝不落到 `body`、文档根或已移除节点。

## 6. 权限变化

权限分为表格档位权限和逐记录动作权限，均带 `permissionRevision`。

权限更新提交时必须原子执行：

1. 重新解析 `resolvedTier` 和逐记录动作集合。
2. 立即移除所有越权菜单项、触发器、重试入口和事件 handler。
3. 清理受影响的 `openRowAction`；不得只把所有项禁用后留下空菜单。
4. 若活动菜单项仍被允许，则保留菜单和活动项；若活动项消失，则移动到同菜单下一项；若无可用项，关闭菜单。
5. 若触发器仍存在，关闭后恢复到该触发器；触发器被移除时，按同记录详情链接、同列最近记录、结果摘要的顺序仅迁移一次。
6. 全部行操作权限失去时，`resolvedTier` 降为 `display`，一次性移除整个操作列/卡片操作区及相关交互状态；选择或批量结构本来就不存在。
7. 权限范围进入查询快照；范围变化使旧请求和游标链失效，并从初始游标重新同步。
8. 若当前单行操作仍在途，不得把本地权限变化宣称为服务端操作已取消。旧操作结果经门禁丢弃，界面显示一次“权限已变化，正在核对最新结果”，并以刷新结果为准。

若列表读取权限本身失去，由页面授权 owner 替换为无权限页面，并对本表执行完整 disposal；这不属于 `display` 档位。

## 7. 焦点策略

所有焦点恢复使用稳定的 `recordId + columnId + controlId`，禁止使用“原数组第 N 行”。

- 后台刷新成功后，精确目标仍存在时不产生额外 `focus()`。
- 行顺序变化时仍追踪同一 `recordId`，不得聚焦新位置上另一条记录。
- 精确目标消失时依次选择：同记录等价控件 → 同列最近记录 → 结果摘要/标题 → 当前分页控件。
- 用户触发上一组/下一组后，匹配响应提交时统一聚焦一次结果摘要；游标自动恢复不得再次聚焦。
- 分页失败时保留触发器焦点，通过 live region 公告错误；用户可继续 Tab 到重试。
- 刷新按钮触发的普通刷新不抢焦点；刷新成功若原目标消失才迁移一次。
- 从错误重试成功后，若重试按钮被移除，聚焦结果摘要一次。
- 菜单因 Escape 关闭才返回触发器；指针外点不抢回焦点。
- 权限降级、响应式转换和列/行消失均遵循相同的一次迁移规则。
- 路由 disposal 时禁止返回即将移除的旧触发器。

结果摘要使用持久稳定 ID 和 `tabindex="-1"`，只用于程序化恢复，不进入普通 Tab 顺序。

## 8. ARIA 与状态公告

- 结果区域使用 `<section aria-labelledby="list-heading">`，加载期间设置 `aria-busy="true"`。
- 首次骨架不包含可操作链接、按钮或假菜单。
- 表格、移动卡片列表、结果摘要和同页其他列表必须具有可区分名称。
- 移动卡片使用 `<ul>`/`<li>`；每张卡片由记录名称命名，每个值与“状态”“负责人”“更新时间”等字段标签关联。
- `loading`、`stale`、错误、操作执行中和权限变化必须有文本，不得只靠颜色、位置或图标。
- 查询结果 owner 是查询公告的唯一 primary owner；单行操作 owner 是该操作状态和错误的唯一 primary owner。
- 每个被接受且需要反馈的查询开始、结果变化、失败、游标恢复、操作开始和操作终态恰好公告一次。
- 合并、过期、被取代、门禁丢弃和 disposal 后到达的回调公告数必须为零。
- 公告只说简洁状态，如“正在刷新记录”“刷新失败，当前数据可能已过期”“已加载下一组 25 条”；不朗读整行、全部条件或重复完整错误。
- 同一个 `errorId` 只有一个完整文本 owner 和一条完整公告路径。
- 原生 Table 不拦截方向键、Home、End、Page Up 或 Page Down；Tab 只进入详情链接、菜单按钮、刷新、重试和分页等真实控件。
- 当前需求不成立二维单元格导航，因此不得使用 `role="grid"`。

## 9. 桌面与移动端适配

桌面使用原生 Table；当容器空间不足以同时保证记录身份、状态和操作可用时，切换为经过固定映射的卡片列表。断点由内容可用性决定，不按 User-Agent 猜测。

卡片固定展示：

1. 记录名称及详情入口；
2. 主要状态；
3. 负责人；
4. 更新时间；
5. 与桌面完全相同的行菜单。

适配要求：

- Table 与卡片任一时刻只能有一个活动数据根。
- 转换保持同一 `ownerId`，并保留查询快照、游标、行、菜单、焦点意图和在途操作；不得因断点变化新建查询或重放操作。
- 菜单 popup 作为同一 owner 的单实例存在。菜单内焦点仍存活时保持不变，并把定位锚点更新为同 `recordId` 的等价触发器；没有等价锚点时先关闭，再按记录级策略恢复。
- 若转换替换了当前聚焦触发器，恰好一次聚焦新形态的等价触发器。
- 页面根不得产生横向溢出；若映射无法完整落地，必须回退到受控表格横向滚动，不得临时隐藏字段或操作。
- 支持键盘、鼠标、触摸和辅助技术组合输入。触摸目标与间距不得依赖精确点击。
- 200% 缩放、字体放大、长翻译、低高度、横屏手机、动态工具栏、虚拟键盘及四向安全区域下，记录身份、菜单、错误、重试和分页必须仍可滚动到达。
- `prefers-reduced-motion` 下取消非必要菜单和布局动画；断点转换不得制造重复 popup、焦点任务或监听器。

## 10. Disposal 与资源归属

路由提交离开或表格 owner 卸载时，必须同步、幂等地进入 `disposed`；不等待请求完成、菜单动画、操作响应或浏览器下一帧。

每项资源都记录持有它的 `ownerId`。处置顺序为：

1. 将 `lifecycleGuard.status` 设置为 `disposed`，使所有新查询、分页、菜单、焦点、操作和公告入口立即拒绝工作。
2. `AbortController.abort()` 取消查询与单行操作传输；这只表示本地不再等待，不能宣称服务端业务已取消。
3. 失效游标恢复、重试、防抖、定时器、`requestAnimationFrame`、微任务焦点恢复和待发送公告。
4. 关闭并移除本实例菜单 popup/portal，取消定位库的 `autoUpdate`、滚动/尺寸观察和定位回调。
5. 注销键盘、指针、滚动、resize、媒体查询、权限、路由和数据订阅。
6. 断开 `ResizeObserver`、`IntersectionObserver`、`MutationObserver` 等观察器。
7. 移除该实例 DOM 和所有相关 `aria-controls`、`aria-describedby`、active 引用。
8. 每项资源只释放一次，不得影响同页其他表格或随后创建的新实例。

查询迟到回调仍执行五项查询门禁；操作迟到回调仍执行完整六项操作门禁；菜单与焦点回调至少校验 `live + ownerId + lifecycleToken + 自身代次`。任一不匹配只记录 discarded，DOM、状态、焦点和 live region 写入均为零。

旧触发器随路由移除时禁止返回焦点。新路由提交完成后，只允许新路由自身的焦点策略移动一次到页面主标题、主内容或主要操作。

返回该列表是否恢复查询与滚动位置必须另有显式 `restorePolicy`。即使启用，也必须重新校验权限、`datasetVersion` 和可用游标位置，并创建新的 `ownerId`、`lifecycleToken`；旧菜单、权限结果和操作快照不得回放。

## 11. 应用检查清单

| 规则族 | 判定 | 实现依据 |
| --- | --- | --- |
| 能力与状态 | 适用 | 明确 `row-action` 档位、十二项能力当前值、固定四组状态和独立 lifecycle guard |
| 查询 | 适用 | 不可变快照、代次、五项提交门禁、同意图合并和迟到丢弃 |
| 筛选 | 不适用 | 无筛选 DOM、`filterDraft`、handler、请求入口或 URL 序列化；`appliedFilters={}` |
| 排序 | 适用，固定排序 | `updatedAt DESC NULLS LAST, recordId DESC`；无排序按钮，表头只表达实际排序 |
| 分页 | 适用 | 唯一 `cursor` 模式、固定 25 条、不透明双向游标、方向禁用、无总页/跳页/加载更多/无限滚动、失效单次恢复 |
| 数据状态 | 适用 | 首次加载/失败、ready、refreshing、刷新失败、stale 和空数据集分别建模 |
| 选择与操作 | 部分适用 | 单行操作适用；当前页选择、全部筛选结果和批量操作的 DOM、状态、handler、请求均不存在 |
| 列 | 部分适用 | 固定列集合和跨端字段映射适用；列显示、固定、调宽控制均不存在 |
| Table/Grid 与键盘 | 适用 | 桌面原生 Table；Grid 不适用；菜单、刷新、重试和分页均有键盘路径 |
| 焦点 | 适用 | 稳定 ID、菜单返回、翻页摘要、权限降级、响应式转换和目标消失 fallback |
| 响应式 | 适用 | 单 owner 的桌面 Table/移动卡片转换，能力和操作等价 |
| ARIA/公告 | 适用 | 表格/卡片命名、表头关联、菜单语义、busy/stale 文本和一次公告 owner |
| disposal/实例隔离 | 适用 | owner/token 隔离、资源归属、幂等释放、迟到门禁和新路由独立焦点 |
| 运行时验证边界 | 适用，当前未验证 | 尚未在真实组件、浏览器、辅助技术、真实竞态和真实后端中执行 |

## 12. 尚未通过真实运行环境验证的边界

以下项目当前均为“未验证”，不得写成已通过：

- Chrome、Safari、Firefox、Edge 下原生 Table、菜单 popup、游标控件和刷新失败表现。
- VoiceOver、NVDA、JAWS、TalkBack 对表格 header、卡片标签、`aria-sort`、菜单、busy/stale 和 live region 的实际朗读。
- 纯键盘完成刷新、重试、上一组/下一组、菜单打开/导航/关闭和单行操作。
- 鼠标、触摸与键盘对同一意图是否产生完全一致的状态转换和单次请求。
- 同意图双击、Enter、Space、事件重放及乱序响应下的请求合并和重复提交保护。
- Abort 失败、旧 generation、旧 snapshot、旧 owner/token 的查询迟到回调是否确实零写入。
- 单行操作六项门禁、幂等键、权限变化中途到达、未知结果和服务端实际执行但本地已离开的情况。
- 刷新失败时旧行、游标、焦点和菜单是否完整保留；重试成功后是否仅一次迁移焦点。
- `datasetVersion` 变化、游标失效、单次恢复和无循环重试。
- 菜单打开期间逐项权限撤销、整档降级、触发器消失和空菜单清理。
- 权限读取范围缩小时，潜在越权行是否在新响应前立即从 DOM 与可访问性树移除。
- 路由提交和 owner 卸载时，请求、重试、防抖、定位、菜单、焦点、公告、监听器、计时器、观察器与订阅是否都按 owner 仅释放一次。
- 同页两个列表具有相同控件名称和相同代次数值时，资源、响应、焦点与公告是否保持实例隔离。
- 桌面 `1440×900`、`1280×720`、平板横竖屏、窄屏和低高度横屏手机的布局与任务可达性。
- Table/Card 实时切换时同 owner 保持、菜单重锚、精确焦点保留和无重复请求。
- 200% 浏览器缩放、字体放大、长文本/长翻译、高对比度、Reduced Motion、动态视口、虚拟键盘和四向安全区域。
- 菜单在滚动容器、视口边缘、缩放和触摸环境中的定位、可见范围及触摸目标。
- 每个已接受事件公告恰好一次，以及 merged、discarded、disposed 回调零公告。
- 服务端是否严格实现固定排序、不可变稳定键、游标与 `datasetVersion` 绑定、权限强制校验和幂等请求语义。

完成上线验收需要真实组件运行时、可控乱序/失败服务、真实权限推送、浏览器自动化、可访问性树检查、主流屏幕阅读器和至少一台真实触摸设备。
<!-- END RAW OUTPUT -->
