# Attempt 6 GREEN：单行操作管理列表

## Spawn args

```text
task_name=attempt_6_row_action_list
fork_turns=none
model 未发送
reasoning_effort 未发送
message:
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个带 row-action 的管理列表。它使用游标分页，需要处理刷新失败、行菜单、焦点恢复、权限变化和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配，以及请求、菜单、焦点与其他资源在 disposal 时如何处理；同时列出尚未通过真实运行环境验证的边界。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
```

## Spawn tool return

```json
{"task_name":"/root/table_task5_green/attempt_6_row_action_list"}
```

## Completion envelope metadata

```text
Message Type FINAL_ANSWER
recipient /root/table_task5_green
sender /root/table_task5_green/attempt_6_row_action_list
```

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个带 row-action 的管理列表。它使用游标分页，需要处理刷新失败、行菜单、焦点恢复、权限变化和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配，以及请求、菜单、焦点与其他资源在 disposal 时如何处理；同时列出尚未通过真实运行环境验证的边界。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

<!-- BEGIN RAW OUTPUT -->
# Row-action 管理列表实现设计

## 1. 能力声明与边界

本实例采用固定的产品配置：

| 配置项 | 当前值 |
| --- | --- |
| `capabilityTier` | `row-action` |
| 初始 `resolvedTier` | `row-action`；操作权限全部撤销后降为 `display` |
| `filteringEnabled` | `false` |
| `sortingEnabled` | `false`，无交互排序，使用服务端固定稳定排序 |
| `paginationMode` | `cursor` |
| `pageSize` | `20`，固定，无页大小选择器 |
| `pageSelectionEnabled` | `false` |
| `allFilteredSelectionEnabled` | `false` |
| `rowOperationEnabled` | `true` |
| `bulkOperationEnabled` | `false` |
| `columnVisibilityEnabled` | `false` |
| `columnPinningEnabled` | `false` |
| `columnResizeEnabled` | `false` |
| `responsivePresentation` | `table-card`；列表容器小于 720 CSS px 时使用经评审的卡片映射 |

第一版提供：

- 查看详情：路由跳转。
- 复制记录 ID：本地动作。
- 重新发送通知：非破坏性异步单行操作，受权限和记录状态约束。
- 上一页、下一页游标导航、显式刷新、错误重试。

第一版不提供多选、全选、批量操作、筛选器、交互排序、页码跳转、总页数、加载更多、无限滚动、行内编辑、树形层级、拖拽排序、透视、列显示/固定/调宽控制或个人布局持久化。不得通过隐藏配置、实验入口或未声明快捷键绕过这些边界。

桌面表格字段固定为：

1. `name`：记录身份，行表头，包含详情链接。
2. `status`：文本状态。
3. `ownerName`：负责人。
4. `updatedAt`：更新时间。
5. `actions`：行菜单触发器。

移动卡片完整映射同一组字段：卡片名称为记录名称，直接显示状态、负责人和更新时间，并保留详情入口与行菜单。

## 2. 状态与 owner

必须保留以下四组状态，不得合并。

### `queryState`

至少包含：

```text
appliedFilters = {}
sortRules
pagination = {
  mode: "cursor",
  requestCursor,
  prevCursor,
  nextCursor,
  recoveryAttempted
}
pageSize = 20
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

没有筛选 UI、`filterDraft` 或筛选事件；`appliedFilters` 固定为空对象，只用于统一快照结构。

固定排序为：

```text
updatedAt DESC NULLS LAST
recordId ASC
```

其中 `updatedAt` 是时间戳，大小写、locale 和自然排序不参与；`recordId` 使用规范化小写 UUID，按 ASCII/code-point 升序，不进行数字自然分段。`recordId` 必须唯一且不可变。以上比较规则全部冻结进查询快照。

### `viewState`

至少包含：

```text
visibleColumnIds = [
  "name", "status", "ownerName", "updatedAt", "actions"
]
pinnedColumnIds = []
columnWidths
density
rows
resultSummary
presentation = "table" | "card"
```

`columnWidths` 是产品配置，不可由用户调整。响应式转换可以改变 `presentation`，但不得改变字段内容、结果或 owner。

### `interactionState`

至少包含：

```text
focusIntent = {
  sourceEvent,
  recordId?,
  columnId?,
  controlId?,
  fallbackId
}
focusedRecordId?
focusedColumnId?
openMenu = {
  recordId,
  menuId,
  triggerControlId,
  menuGeneration,
  focusedItemId
} | null
expandedRecordIds = []
```

选择模式、选择代次、`selectedIds`、全结果范围和排除项均不实例化。不得渲染选择 DOM、注册选择 handler 或发送选择请求。

### `operationState`

仅实例化单行操作：

```text
phase
operationSnapshot
operationId
operationGeneration
idempotencyKey
recordId
actionId
success
error
conflict
recoveryAction
resultFocusIntent
```

建议的 `phase`：

```text
idle
submitting
succeeded
failed
permission-conflict
dataset-version-conflict
outcome-unknown
```

该枚举属于本实例实现细节，不得放宽异步门禁、错误归属或 disposal 规则。批量操作状态槽、handler、确认面和请求均不存在。

### 独立 `lifecycleGuard`

生命周期不能作为第五组业务状态替代上述任一组：

```text
ownerId
lifecycleToken
live | disposed
announcementOwnerId
ownedResources
```

同页多个列表的 `ownerId`、`lifecycleToken`、`announcementOwnerId` 必须分别唯一；各实例的 generation 数值可以相同，但只能在各自 `ownerId + lifecycleToken` 命名空间内解释。

## 3. 查询、快照和游标分页

每次被接受的首次加载、上一页、下一页、显式刷新、重试、数据权限范围变化或失效游标恢复均执行：

1. 冻结不可变 `querySnapshot`，包含固定筛选、完整排序、分页模式、目标游标、页大小、权限范围、刷新原因和 `datasetVersion`。
2. 生成新 `snapshotId`。
3. 严格递增 `requestGeneration`。
4. 发出一次请求和一次简洁的查询开始公告。

响应只有同时满足以下五项才能提交：

```text
owner 仍为 live
ownerId 匹配
lifecycleToken 匹配
requestGeneration 等于当前代次
snapshotId 等于当前快照
```

任何一项不匹配只记录 `response-discarded`，不得写入行、游标、错误、焦点、DOM 或 live region。取消请求仅用于节省资源，不能替代提交门禁。

显式刷新先计算 `intentKey`，内容包括固定查询、当前游标、页大小、权限范围、数据版本和刷新原因：

- 同一 `intentKey` 正在请求时，点击、Enter 或事件重放合并到原请求，不创建新快照、代次、请求或公告。
- `intentKey` 变化时，即使旧请求仍在途，也建立新快照；旧响应由门禁丢弃。

游标规则：

- `prevCursor`、`nextCursor` 均视为服务端不透明值，前端不得解析或计算。
- 仅渲染“上一页”“下一页”；缺少对应游标时使用原生 `disabled`。
- 不显示总页数、随机页码、跳页、加载更多或无限滚动入口。
- 翻页、权限数据范围变化或固定排序变化均从对应合法位置重新建快照；权限数据范围变化回到初始游标。
- 当前游标失效时，仅恢复一次：使用服务端返回的最近有效位置，否则回到初始游标；重复失效响应不得形成循环。
- API 应提供不可变 `datasetVersion`。页间版本变化时立即令游标链 `stale`，停止继续导航并从初始位置重新开始。若接口不能提供一致性版本，产品不得承诺跨页无重复或遗漏。

## 4. 状态转换

| 事件 | 转换与结果 |
| --- | --- |
| 首次进入 | `idle → initial-loading → ready / initial-error` |
| 显式刷新 | `ready / refresh-error → refreshing → ready / refresh-error` |
| 同意图重复刷新 | 保持当前阶段，只记录合并，不创建新工作 |
| 上一页/下一页 | 保留当前行并进入 `refreshing`；摘要明确“正在打开上一组/下一组”，匹配响应提交后替换行 |
| 翻页失败 | 保留当前行、游标和焦点上下文，进入 `refresh-error` |
| 游标失效 | 标记 `stale`，执行一次恢复请求；成功后清除 `stale` |
| 打开菜单 | `openMenu: null → 当前 recordId/menuGeneration`，焦点进入菜单 |
| 关闭菜单 | 清理菜单状态、定位资源和 ARIA 引用；按关闭原因决定是否恢复焦点 |
| 提交单行请求 | 建立不可变操作快照，`idle → submitting`；重复触发不创建第二请求 |
| 操作成功/失败 | 写入对应行的操作 owner，不得写入 `queryError` |
| 操作权限冲突 | 不自动重试；重新解析权限并提供重新打开或核对入口 |
| 权限降级 | 原子关闭菜单、清理越权操作状态、移除菜单入口，必要时迁移焦点 |
| 路由提交或卸载 | 立即且幂等地进入 `disposed`，拒绝所有新工作 |

## 5. 加载、错误、过期与空状态

### 首次加载

无可用结果时显示与当前形态一致的不可操作骨架：

- 桌面为五列结构骨架。
- 移动端为卡片结构骨架。
- 结果容器设置 `aria-busy="true"`。
- 骨架不得包含可操作按钮、链接或假数据。

### 刷新与翻页加载

保留上次成功的行、列、游标和焦点意图，设置 `aria-busy="true"`。旧数据必须标识为正在刷新，不能伪装成已匹配新请求。

普通刷新不抢焦点；翻页响应成功后按分页焦点规则移动一次。

### 首次加载失败

进入 `initial-error`，用结果区域内的文本错误和可聚焦“重试加载列表”按钮替代空表格。重试建立新快照和代次。

### 刷新或翻页失败

进入 `refresh-error`，保持旧行、菜单上下文、游标和焦点意图，设置 `stale: true`，显示：

> 刷新失败，当前数据可能已过期。

提供“重试刷新”按钮。错误完整文本只归结果区域，不能同时复制到筛选区、Toast 和多个 live region。

### 空状态

由于本实例没有筛选，只有数据源空状态：

> 暂无可管理的记录。

可提供权限允许的“创建记录”或帮助入口。不得显示“当前筛选无匹配”。如果因读取权限范围导致零条，应显示“当前权限范围内没有可见记录”，不能伪装成普通空数据集。

## 6. 行菜单与单行操作

触发器使用真实 `<button>`，名称为“打开「记录名称」的操作菜单”，并设置：

```html
aria-haspopup="menu"
aria-expanded="true|false"
aria-controls="menu-id"  <!-- 仅菜单存在时 -->
```

菜单采用 `role="menu"`，动作采用 `role="menuitem"`。权限不足的动作不渲染；因记录状态暂不可执行但仍需解释的动作可保留为 `aria-disabled="true"`，并通过可访问说明给出原因，激活时不得调用 handler 或请求。

菜单行为：

- 点击、Enter、Space、ArrowDown 打开并聚焦第一个可用项。
- ArrowUp 打开时聚焦最后一个可用项。
- 菜单内 ArrowUp/ArrowDown 循环移动，Home/End 到首末项，支持按名称首字符定位。
- Enter/Space 执行动作。
- Escape 关闭并把焦点还给原触发器。
- Tab/Shift+Tab 关闭菜单并继续正常 Tab 顺序，不形成焦点陷阱。
- 指针点击外部时关闭；若点击目标已接收焦点，不再抢回触发器。
- 选择详情跳转时不恢复旧触发器；新路由自行管理焦点。
- 选择异步动作后关闭菜单并恢复到仍存活的行触发器；该动作在 `submitting` 时不能再次提交。

单行异步操作开始时冻结：

```text
ownerId
operationId
operationGeneration
operationSnapshotId
recordId
actionId
permissionScope/version
datasetVersion
idempotencyKey
```

操作响应必须通过：

```text
live
ownerId
lifecycleToken
operationId
operationGeneration
operationSnapshotId
```

六项完整门禁。失败信息归该记录的操作结果区域；成功、失败、权限冲突、版本冲突和结果未知各公告一次简短摘要。结果未知时不得自动重试，应保留核对入口并使用新幂等键开始后续尝试。

刷新提交后：

- 同一 `recordId` 的菜单触发器和权限语义仍存在时，可保留菜单并按稳定 ID 重新定位。
- 锚点、记录或动作语义消失时，关闭菜单一次，清除 popup/ARIA 引用，并按焦点回退策略迁移。
- 不得按旧数组索引把菜单绑定到另一条记录。

## 7. 权限变化

权限解析分为两类：

- 仅操作权限变化：重新计算 `resolvedTier` 和各行动作，不发数据查询。
- 数据可见范围变化：关闭不再合法的菜单/操作，回到初始游标并建立新查询快照。

当操作权限从 `row-action` 降为 `display` 时，必须原子完成：

1. `resolvedTier = display`。
2. 关闭当前菜单并清理菜单定位资源。
3. 使在途操作快照失效；不得宣称服务端操作已取消。
4. 移除所有操作菜单触发器和越权 action handler。
5. 保留可读结果和详情导航。
6. 若焦点位于被移除节点，迁移一次到同记录详情链接；不存在时依次选择同列最近记录、结果摘要、当前分页控件。
7. 发出一次简洁的“操作权限已更新”公告。

权限增加不主动移动焦点；新增操作在下一次打开菜单时可见。读取权限完全撤销时，不再保留表格实例，应进入 disposal 并由页面显示访问受限状态。

## 8. 焦点管理

`focusIntent` 一律使用稳定 `recordId + columnId + controlId`，不得使用行索引或 DOM 序号。

- 后台刷新：精确目标仍存活时保持焦点，不产生额外 `focus()`。
- 记录重排：继续定位同一 `recordId`，不得聚焦新索引上的其他记录。
- 精确目标消失：依次回退到同记录等价控件、同列最近记录、结果摘要、当前分页控件。
- 翻页：记录来源按钮；匹配结果提交后将焦点移动一次到可聚焦结果摘要。失效游标自动恢复不得再次移动。
- 刷新重试成功：若重试按钮随错误状态消失，移动一次到结果摘要。
- 菜单 Escape：返回原触发器。
- 菜单锚点消失或权限降级：使用记录级回退，不得恢复到 removed 节点。
- 路由卸载：绝不把焦点恢复到即将移除的旧菜单触发器。
- 最终目标必须存活、可聚焦、有可访问名称，禁止落到 `document.body`、文档根或已移除节点。

## 9. DOM、ARIA 与键盘语义

桌面形态使用原生 `<table>`，不使用 ARIA Grid：

- 表格通过页面标题或独立标题获得可区分名称。
- `name` 列使用 `<th scope="row">`；其他表头使用 `<th scope="col">`。
- 含多个独立控件时不得把整行包装成链接。
- 静态单元格不设置 `tabindex="0"`。
- 表格不拦截方向键、Home、End、Page Up 或 Page Down。
- Tab 只进入详情链接、菜单按钮、错误恢复和分页按钮，并按视觉/DOM 任务顺序前进。
- 无交互排序按钮，也不设置 `aria-sort`；结果摘要以文本说明“按最近更新时间降序排列”。

结果容器设置：

```html
aria-labelledby="list-heading"
aria-describedby="result-summary"
aria-busy="true|false"
```

使用由结果 owner 独占的 `aria-live="polite" aria-atomic="true"` 状态区。每个被接受的查询开始、结果位置变化、恢复成功或查询失败只公告一次。合并、丢弃、被取代、disposal 后到达的事件不公告。

状态、加载、过期、权限变化和错误均提供文本表达，不能只使用颜色、位置或图标。

## 10. 桌面与移动端适配

- 列表容器可用宽度不小于 720 CSS px 时使用五列原生表格。
- 小于该阈值时使用单列卡片列表；阈值属于本实例产品配置，不是共享设备断点。
- 卡片必须显示记录名称、状态、负责人、更新时间、详情入口和行菜单，不得删除低频操作。
- Table 与卡片不能同时作为两个活动数据根存在；转换保持同一 `ownerId`、请求、游标、菜单、焦点意图和操作快照。
- 断点变化自身不得重新请求、重复操作或递增操作代次。
- 打开菜单时若卡片中存在同 `recordId/controlId` 的等价触发器，重新锚定同一菜单实例；没有等价锚点时关闭一次并执行记录级焦点回退。
- 页面根不得横向溢出。若因极端翻译文本必须保留表格，则横向滚动仅发生在表格容器，并提供可感知的首尾边界和滚动方向。
- 200% 缩放、字体放大、长翻译、低高度、横屏、动态浏览器工具栏、虚拟键盘和四向安全区域下，记录身份、错误、行操作和分页仍须可达。
- 触摸目标与间距不得依赖精确点击；移动端菜单仍必须同时支持触摸和键盘。

## 11. Disposal、资源释放与实例隔离

路由提交离开或 owner 卸载时，同步、立即、幂等地进入 `disposed`，不等待菜单动画、查询或单行操作完成。进入后拒绝查询、分页、菜单、焦点、操作和公告新工作。

每项资源记录持有它的 `ownerId`，且只释放一次：

- 查询与单行操作的 `AbortController`。
- 游标恢复、重试、延迟任务和防抖调度。
- 菜单 portal、定位实例、定位更新回调和菜单动画完成处理器。
- 待执行焦点恢复、`requestAnimationFrame`、可取消计时器和公告队列。
- `ResizeObserver`、`IntersectionObserver`、容器尺寸观察器。
- document/window 的键盘、指针、滚动和 resize 监听器。
- 路由、权限和数据失效订阅。
- 当前实例的 DOM、popup 及 `aria-controls`、`aria-describedby` 引用。

不能取消的 Promise、微任务或服务端请求仍必须经过生命周期和代次门禁；迟到回调的 DOM、状态、焦点和 live-region 写入均为零。客户端 abort 不得被描述为服务端操作已取消。

旧触发器不得接收返回焦点。新路由提交后，仅由新路由自身策略移动一次焦点到页面主标题、主内容或主要操作。

返回列表的产品策略设为 `query-and-scroll`：

- 新建 `ownerId` 和 `lifecycleToken`。
- 恢复前重新校验权限范围、`datasetVersion` 和游标可用性。
- 校验通过才恢复查询位置和滚动；失败则从初始游标加载。
- 不恢复旧菜单、单行操作快照、权限结果或任何选择状态。

一个实例的 disposal 不得关闭另一实例的菜单、清空其错误、释放其资源或把焦点移到另一列表的同名控件。

## 12. 尚未通过真实运行环境验证的边界

当前仅完成设计层约束，以下均为未验证：

- 真实 API 的双向不透明游标、失效游标恢复和 `datasetVersion` 一致性。
- 请求取消失败、乱序响应、重复刷新、权限变化与路由卸载交错时的提交门禁。
- 单行动作的幂等键、结果未知、权限冲突及服务端实际完成但客户端已 disposal 的行为。
- 1440×900、1280×720、平板横竖屏、390×844、低高度横屏和动态视口。
- 200% 浏览器缩放、字体放大、长文本、国际化扩展、高对比度和 Reduced Motion。
- 触摸、鼠标、纯键盘操作，虚拟键盘及四向安全区域。
- VoiceOver/Safari、NVDA/Firefox 或等价辅助技术中的表格关联、菜单导航、公告去重和焦点恢复。
- Table/卡片实时切换期间的菜单重锚、单实例约束及焦点迁移。
- 两个同页列表的交错响应、菜单 portal、公告 owner 和资源释放隔离。
- 路由返回时权限、数据版本、游标位置和滚动恢复的真实校验。
- 菜单定位库在滚动容器、缩放、长文本和锚点移除时是否留下悬空 popup。
- disposal 重复调用后各资源释放次数是否精确为一次。

## 13. 实现检查清单

| 原子规则族 | 适用性 | 实现落点或不适用依据 | 验证状态 |
| --- | --- | --- | --- |
| 能力与状态 | 适用 | 第 1、2 节；十二项当前能力值、固定四组状态及独立 lifecycle guard | 设计覆盖；运行未验证 |
| 查询 | 适用 | 第 3、4 节；不可变快照、代次、五项提交门禁和同意图合并 | 设计覆盖；竞态未验证 |
| 筛选 | 不适用 | DOM 筛选控件=0；`filterDraft` 状态槽=0；筛选 handler=0；筛选触发请求=0；`appliedFilters` 仅固定为空对象 | 配置已声明；零入口待运行确认 |
| 排序 | 适用 | 第 2、3、9 节；固定 `updatedAt DESC NULLS LAST, recordId ASC`，无伪排序按钮 | 设计覆盖；服务端顺序未验证 |
| 分页 | 适用 | 第 3、4 节；固定 pageSize 20、不透明双向游标、边界禁用和单次恢复 | 设计覆盖；接口未验证 |
| 数据状态 | 适用 | 第 4、5 节；首次加载、刷新、过期、失败和空数据集 | 设计覆盖；运行未验证 |
| 选择 | 不适用 | 选择 DOM=0；选择状态槽=0；选择 handler/事件=0；选择请求=0 | 配置已声明；零入口待运行确认 |
| 单行操作 | 适用 | 第 6、7 节；菜单、操作快照、重复提交保护、错误与冲突恢复 | 设计覆盖；运行未验证 |
| 批量操作 | 不适用 | 批量 DOM=0；批量状态槽=0；批量 handler/事件=0；批量请求=0 | 配置已声明；零入口待运行确认 |
| 基础列状态 | 适用 | 第 2 节；稳定 columnId、固定可见列、宽度与密度状态 | 设计覆盖；渲染未验证 |
| 可选列控制 | 不适用 | 列控制 DOM=0；控制会话状态=0；显示/固定/调宽 handler=0；相关请求=0 | 配置已声明；零入口待运行确认 |
| Table 语义 | 适用 | 第 9 节；原生 table、行列 header 关联和真实控件 Tab 顺序 | 设计覆盖；可访问性树未验证 |
| ARIA Grid 语义 | 不适用 | `role=grid` DOM=0；Grid 导航状态=0；Grid 键盘 handler=0；Grid 请求=0 | 配置已声明；零入口待运行确认 |
| 键盘 | 适用 | 第 6、8、9 节；菜单、详情、重试和分页完整键盘路径 | 设计覆盖；真实键盘未验证 |
| 焦点 | 适用 | 第 7、8 节；稳定 ID、一次迁移、记录级回退和路由边界 | 设计覆盖；浏览器焦点未验证 |
| 响应式 | 适用 | 第 10 节；显式 Table/卡片映射、单 owner 和跨端能力等价 | 设计覆盖；真实视口未验证 |
| ARIA 与公告 | 适用 | 第 6、9 节；名称、状态、busy/stale 与单一公告 owner | 设计覆盖；屏幕阅读器未验证 |
| disposal | 适用 | 第 11 节；立即幂等处置、迟到回调门禁及逐资源释放 | 设计覆盖；卸载竞态未验证 |
| 实例隔离 | 适用 | 第 2、11 节；owner/token/announcement 命名空间和资源隔离 | 设计覆盖；双实例未验证 |
| 运行时验证边界 | 适用 | 第 12 节；列明浏览器、辅助技术、输入、视口、API 和竞态环境 | 未验证 |
<!-- END RAW OUTPUT -->
