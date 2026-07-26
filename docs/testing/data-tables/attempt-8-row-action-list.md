# Attempt 8 Row Action List Evidence

## Actual spawn args

```text
task_name=attempt_8_row_action_list
fork_turns=none
model/reasoning_effort not sent
```

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个带 row-action 的管理列表。它使用游标分页，需要处理刷新失败、行菜单、焦点恢复、权限变化和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配，以及请求、菜单、焦点与其他资源在 disposal 时如何处理；同时列出尚未通过真实运行环境验证的边界。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

## Exact spawn tool return

```json
{"task_name":"/root/table_task5_final_takeover/attempt_8_row_action_list"}
```

## Completion metadata

```text
Message Type FINAL_ANSWER
recipient /root/table_task5_final_takeover
sender /root/table_task5_final_takeover/attempt_8_row_action_list
```

<!-- BEGIN RAW OUTPUT -->
# Row-action 管理列表实现设计

## 1. 能力声明与边界

本实例是带单行操作的管理列表，不具备选择或批量处理能力。

| 能力字段 | 当前值 |
| --- | --- |
| `capabilityTier` | `row-action` |
| `resolvedTier` | `row-action`；权限降级后允许变为 `display` |
| `filteringEnabled` | `false` |
| `sortingEnabled` | `false`；无交互排序，查询始终使用固定稳定排序 |
| `paginationMode` | `cursor` |
| `pageSize` | `25`，固定且须经服务端接受 |
| `pageSelectionEnabled` | `false` |
| `allFilteredSelectionEnabled` | `false` |
| `rowOperationEnabled` | `true` |
| `bulkOperationEnabled` | `false` |
| `columnVisibilityEnabled` | `false` |
| `columnPinningEnabled` | `false` |
| `columnResizeEnabled` | `false` |
| `responsivePresentation` | `table-to-card-enabled`，使用已评审的完整字段映射 |

当前行级能力：

- 记录名称是独立的详情链接。
- 行菜单提供“复制记录 ID”和具幂等语义的“重新校验”。
- 不启用删除、批量处理、行内编辑或需要确认弹窗的高风险操作；后续增加此类操作前必须另行定义风险确认与结果恢复契约。
- 含多个控件的整行不能包装成大链接。
- 第一版不提供筛选、交互排序、页码、跳页、加载更多、无限滚动、选择、全选、批量工具栏、列显隐、列固定、调宽、拖拽排序和个人布局持久化。

固定排序必须由前后端共同采用：

```text
name ASC
NULLS LAST
Unicode case-fold，大小写不敏感
locale = zh-CN-u-co-pinyin
naturalOrder = false
稳定次序键 = recordId ASC
```

以上完整比较规则必须冻结到每个查询快照。只有所有页面属于同一 `datasetVersion` 或等价服务端快照时，才能承诺跨页无重复、无遗漏。

## 2. 固定状态结构

| 状态组 | 当前结构与写入边界 |
| --- | --- |
| `queryState` | `appliedFilters={}`、固定 `sortRules`、`pagination={mode:"cursor", origin, currentCursor, prevCursor, nextCursor, pendingDirection, recoveryAttemptedForSnapshot}`、`pageSize=25`、不可变 `querySnapshot`、`snapshotId`、可选 `datasetVersion`、`requestGeneration`、`requestPhase`、`queryError`、`stale`、当前权限范围。只有查询 owner 写入。`appliedFilters={}` 只是查询身份的固定基线，不建立筛选交互状态。 |
| `viewState` | `visibleColumnIds`、`pinnedColumnIds=[]`、固定 `columnWidths`、`density`、当前结果行、结果摘要、当前 `table/card` 展示形态。列 ID 和记录 ID 均使用稳定业务标识。 |
| `interactionState` | `focusIntent={sourceEvent,recordId?,columnId?,controlId?,fallbackId}`、当前稳定 `recordId/columnId/controlId`、`openRowAction={recordId,menuId,triggerControlId,menuGeneration,phase}`、菜单活动项。选择相关字段为 `not-instantiated`；选择 DOM、状态槽、handler 和请求入口均为 0。 |
| `operationState` | `rowOperation={phase,operationId,operationGeneration,operationSnapshotId,recordId,recordVersion,actionId,permissionScope,datasetVersion,idempotencyKey,errorId,result,focusIntent}`；批量操作为 `not-instantiated`。行操作错误不得写入 `queryError`。 |

`requestPhase` 至少包含：

```text
idle
initial-loading
ready
refreshing
initial-error
refresh-error
```

游标恢复、权限重校验等可以作为 `pagination` 或 `rowOperation` 的局部子状态，但不得替代或合并上述阶段。

### operationState 操作子槽

| operationKind | currentValue | stateSlot | DOM | handler/event | request |
| --- | --- | --- | --- | --- | --- |
| row | enabled | `operationState.rowOperation`，含不可变操作快照、操作代次、幂等键、错误 owner 和焦点意图 | 行菜单、行操作结果或恢复入口 | 打开、关闭、激活、重试、权限失效、结果提交 | “重新校验”每次有效尝试最多 1 个请求；详情导航和复制 ID 不创建行操作请求 |
| bulk | not-instantiated | 0 | 0 | 0 | 0 |

## 3. 独立生命周期门禁

`lifecycleGuard` 位于四组业务状态之外，不得作为第五个状态组替代任何固定状态组：

```text
ownerId              每个表格实例唯一
lifecycleToken        每次挂载生成且不可复用
announcementOwnerId  每个实例唯一
live                  true | false
disposed              幂等终态标记
ownedResources        AbortController、portal、菜单定位任务、监听器、
                      计时器、观察器、订阅、待执行焦点和公告任务
```

同页实例的 generation 数字允许相同；所有代次都必须在 `ownerId + lifecycleToken` 命名空间内解释。

## 4. 查询、游标与竞态提交

每次被接受的首次加载、翻页、页大小改变、显式刷新、权限范围改变或失效游标恢复均执行：

1. 冻结不可变 `querySnapshot`，至少包含固定排序、`paginationMode=cursor`、当前位置、不透明方向游标、`pageSize=25`、权限范围、适用的 `datasetVersion` 和请求原因。
2. 生成新的 `snapshotId`。
3. `requestGeneration` 严格加一。
4. 发出请求并捕获 `ownerId`、`lifecycleToken`、generation 和 snapshot。
5. 响应只有同时满足以下五项才可写入行、游标、错误、阶段、版本或 `stale`：

```text
live
ownerId
lifecycleToken
requestGeneration
snapshotId
```

任一失配只记录 `response-discarded`，DOM、状态、焦点和 live region 写入均为 0。中止请求只用于节省资源，不能代替提交门禁。

### 显式刷新合并

刷新前用以下内容形成 `intentKey`：

```text
固定排序 + 当前游标位置 + pageSize + 权限范围 + datasetVersion + refreshReason
```

同键刷新仍在途时，点击、Enter 或事件重放合并到现有工作，不创建快照、代次、请求或重复公告。权限范围等内容改变形成新键时，即使旧刷新仍在途，也必须接受新刷新；旧响应随后由门禁丢弃。

### 游标规则

- 游标完全不透明，客户端不得解析、拼接或推导。
- 只渲染“上一页”和“下一页”；缺少对应游标时使用原生 `disabled`。
- 不显示总页数、随机页码、跳页、加载更多或无限滚动入口。
- 结果摘要只描述“本批次 25 条”或实际返回条数，不虚构全局序号范围。
- 翻页响应提交后焦点只移动一次到结果摘要或标题；失效游标自动恢复不得再次抢焦点。
- 排序、页大小或查询范围改变时回到初始游标。
- 当前游标失效时，只接受服务端返回的最近有效前向位置；没有安全恢复位置时回到初始游标。
- 每个失败快照最多自动恢复一次；再次失效进入 `refresh-error`，不得循环请求。
- 页间 `datasetVersion` 改变时立即使当前游标链失效、标记 `stale`、停止继续导航并从初始位置建立新链。
- 服务端不提供一致性版本时，界面不得承诺跨页零重复遗漏；检测到数据边界变化后采用同一失效重启路径。

## 5. 查询状态转换

| 事件 | 前置状态 | 转换与可见结果 |
| --- | --- | --- |
| 首次加载 | `idle` 且无可用行 | `initial-loading`；显示结构匹配但不可操作的骨架，结果容器 `aria-busy=true` |
| 首次成功 | `initial-loading` | `ready`；提交行、双向游标和版本，解除 busy |
| 首次失败 | `initial-loading` | `initial-error`；不渲染空表格，结果区域显示完整错误和可聚焦“重试加载” |
| 显式刷新 | 有上次成功结果 | `refreshing`；保留上次成功的行、游标上下文和焦点意图，设置 busy |
| 刷新成功 | `refreshing` | `ready`、`stale=false`；只提交匹配快照的新结果 |
| 刷新失败 | `refreshing` | `refresh-error`、`stale=true`；保留旧行、分页和焦点，显示“数据可能已过期”及重试入口 |
| 上一页/下一页 | 对应游标存在 | 建立新快照；当前批次保持可读且 busy；匹配响应提交后替换结果并执行一次分页焦点策略 |
| 游标失效 | 未对该快照恢复过 | 用服务端恢复游标或初始游标建立一个新快照；成功后简短公告一次 |
| 重试 | `initial-error` 或 `refresh-error` | 建立新 generation 和 snapshot；旧失败响应无权清除新状态 |
| 权限范围改变 | 任意 live 状态 | 原子重算 `resolvedTier` 和行权限；使用新权限建立查询快照，旧权限响应失效 |
| disposal | 任意状态 | 立即 `live=false, disposed=true`；不再进入任何查询阶段 |

显式刷新不会移动仍存活的焦点。刷新失败也不移动焦点。

## 6. 加载、错误和空状态

- 首次加载：仅显示不可操作骨架；骨架中的按钮、链接和菜单触发器数量必须为 0。
- 首次错误：结果区域取代表格，包含文本错误和重试按钮。
- 刷新中：旧行继续显示但明确标记“正在刷新”，不能伪装成新响应。
- 刷新错误：保留旧行并显示持久的过期提示、错误摘要和重试入口。
- 数据源为空：显示“当前管理范围内尚无记录”。
- 权限范围为空：显示“当前权限下没有可查看的记录”，不能与数据源为空共用含糊文案。
- 本实例没有筛选，因此不渲染“当前筛选无匹配”状态或清除筛选入口。
- 查询错误的 primary owner 是结果区域。
- 行操作错误的 primary owner 是对应行操作结果；若该行已消失，则迁移到带记录身份的页面级操作结果摘要。
- 同一个 `errorId` 只能有一个完整错误 owner 和一条完整公告路径。

## 7. 行菜单与单行操作

### 菜单结构

- 每行最多一个菜单触发器，使用真实 `<button type="button">`。
- 可访问名称包含记录身份，例如“打开‘华东仓库’的操作菜单”。
- 触发器使用 `aria-haspopup="menu"`、`aria-expanded`；只有 popup 存在时才设置有效的 `aria-controls`。
- 菜单使用单一 `role="menu"` 根和真实可聚焦的 `role="menuitem"`。
- 菜单由 `aria-labelledby` 关联触发器，不使用悬空 `aria-owns`。
- 权限不允许的操作不渲染。因临时记录状态不可用但需要解释的操作可保留为 `aria-disabled="true"`，名称或说明必须包含原因，激活请求为 0。
- 任一时刻每个表格实例最多一个打开菜单。

### 菜单状态转换

| 事件 | 转换 | 焦点结果 |
| --- | --- | --- |
| Enter、Space、ArrowDown 打开 | `closed → open` | 聚焦第一个可用菜单项 |
| ArrowUp 打开 | `closed → open` | 聚焦最后一个可用菜单项 |
| 菜单内 ArrowDown/ArrowUp | 保持 `open` | 在菜单项间移动；每键最多一个目标 |
| Home/End | 保持 `open` | 首项/末项 |
| 激活可用项 | `open → closed`，创建对应意图 | 菜单关闭后先回到仍存活触发器；后续结果提交再按稳定目标规则处理 |
| Escape | `open → closed` | 触发器存活时仅恢复一次 |
| Tab/Shift+Tab | `open → closed` | 不设焦点陷阱，让浏览器继续到正常前后控件 |
| 指针点击外部 | `open → closed` | 不抢走用户刚点击目标的焦点 |
| 权限移除当前项 | 更新菜单 | 优先移动到同菜单下一个可用项；无可用项则关闭并执行记录级 fallback |
| 锚点因结果或断点变化消失 | 关闭一次 | 当前焦点在菜单内时迁移到等价记录控制器，否则不抢焦点 |
| disposal | 立即失效并移除 | 不返回旧触发器 |

菜单 portal、浮层定位、滚动和尺寸监听均携带 `ownerId`、`lifecycleToken`、`menuGeneration`、`recordId` 和 `triggerControlId`。任一项不匹配的定位回调不得写 DOM。

### 行操作请求

“重新校验”开始时建立不可变 `operationSnapshot`：

```text
ownerId
operationId
operationGeneration
operationSnapshotId
recordId
recordVersion
actionId
permissionScope
datasetVersion
idempotencyKey
focusIntent
```

提交要求当前 owner live，动作仍获授权且记录状态允许。点击、Enter、Space 和事件重放在同一尝试中最多产生一个请求。

行操作结果只有以下六项全部匹配才能提交：

```text
live
ownerId
lifecycleToken
operationId
operationGeneration
operationSnapshotId
```

结果处理：

- 成功：显示一次简洁结果反馈，并建立一个新查询快照刷新受影响数据。
- 普通失败：保留记录身份、具体原因和有名称的重试入口；重试生成新的操作 ID、代次、快照和幂等键。
- 权限冲突：移除越权入口，不自动重试，刷新新权限范围。
- 版本冲突：旧操作快照失效，刷新记录并要求用户重新发起。
- 服务端结果缺少目标身份、重复、矛盾或无法确认：进入 `outcome-unknown`，保留快照并提供“核对记录状态”入口，不能宣称成功或失败。
- disposal 或权限重校验期间到达的迟到结果只记录 discarded，不得写入新页面或新操作状态。

## 8. 权限变化

权限变化是安全边界，必须作为一个原子提交处理：

1. 计算新的权限范围和 `resolvedTier`。
2. 移除新权限下不可见的记录、字段和操作；无法同步判断仍可见性的旧结果先隐藏，不能在等待刷新时继续泄露。
3. 关闭受影响行菜单，失效其定位和菜单回调。
4. 未提交的越权行意图直接失效，请求数为 0。
5. 已在途操作进入“权限已变化，结果需重新核对”，使旧操作 generation 失配；可 best-effort abort，但不得声称服务端已取消。
6. 使用新权限范围建立查询快照和新 generation；旧权限响应全部丢弃。
7. 若 `row-action → display`，一次性移除操作列、菜单、行操作入口及其交互状态，不留下空列、空工具栏、禁用但无恢复路径的控件或悬空 ARIA 引用。

若焦点目标被移除，依次选择：

1. 同记录仍获授权的详情链接；
2. 同记录第一个获授权控件；
3. 结果摘要；
4. 当前可用分页控件。

全程最多发生一次最终焦点移动，不得落到 `body`、文档根或 removed 节点。

## 9. 通用焦点恢复

所有焦点恢复使用稳定的 `recordId + columnId + controlId`，禁止使用数组索引或第几个 DOM 子节点。

- 后台刷新后精确目标仍存活、可聚焦且语义未变：焦点保持不变，`focus` 调用数为 0。
- 同记录目标改变：移动一次到同记录等价控件。
- 记录消失：移动到同列最近记录的等价控件。
- 同列也不存在：移动到结果摘要或标题。
- 翻页：匹配响应后移动一次到结果摘要；失效游标恢复不再移动。
- 行操作成功导致当前行消失：优先同操作列最近记录，其次结果摘要。
- 刷新失败：保留原目标，不移动。
- 菜单关闭：仅 Escape、动作激活或锚点消失等明确路径执行对应恢复；外部点击不抢焦点。
- 任何后续刷新不得在已经完成 fallback 后进行第二次迁移。
- 路由离开时禁止返回旧触发器；新路由提交后由新路由自身聚焦一次主标题、主内容或主要操作。

## 10. DOM、键盘与 ARIA

### 桌面表格

- 使用原生 `<table>`，不使用 ARIA Grid。
- 通过 `<caption>` 或 `aria-labelledby` 提供可区分名称。
- 列标题使用 `<th scope="col">`；记录身份列可使用 `<th scope="row">`。
- 操作列表头具有文本名称“操作”。
- 静态单元格不设置 `tabindex="0"`。
- 表格不接管方向键、Home、End、Page Up 或 Page Down。
- Tab 只进入详情链接、菜单按钮、分页和错误恢复等真实控件，顺序与视觉任务顺序一致。

### 分页

- 使用 `<nav aria-label="记录分页">`。
- “上一页”和“下一页”均为真实按钮，可访问名称包含方向。
- 缺失方向游标时使用原生 `disabled`。
- 当前正在请求通过结果容器 `aria-busy` 和可见状态文本表达，不通过伪造页码表达。
- 相同待处理分页意图的重复激活不产生第二请求。

### 状态与公告

- 结果容器在初始加载和刷新期间设置 `aria-busy="true"`。
- `stale` 必须有“数据可能已过期”的可见文本，不能只靠颜色或图标。
- 查询结果 owner 使用一个 `role="status" aria-live="polite" aria-atomic="true"` 的简洁公告通道。
- 每个被接受的查询开始、改变结果位置或数量的响应、失败和成功游标恢复各公告一次。
- 行操作使用独立 operation owner；查询和行操作不得重复播报同一完整错误。
- 菜单打开不额外通过 live region 播报，焦点和 `aria-expanded` 已提供状态。
- merged、discarded、superseded、disposed 以及仅需静默失效的事件公告数为 0。
- 公告不得串读整行、全部数据或完整游标。

## 11. 桌面、平板与移动端

当前完整映射如下：

| 逻辑字段 | 桌面 Table | 窄屏 Card |
| --- | --- | --- |
| 记录身份 | 行标题及详情链接 | 卡片标题及详情链接，同时作为卡片可访问名称 |
| 状态 | 独立状态列 | 标题区域内带文本的状态 |
| 所有者 | 所有者列 | “所有者”标签和值 |
| 更新时间 | 更新时间列 | “更新时间”标签和值 |
| 行操作 | 操作列菜单按钮 | 卡片底部同一逻辑菜单按钮 |

实现要求：

- 断点由内容可用性决定；初始配置可使用容器宽度约 720px 作为候选值，但必须经长文本和缩放验证后确定。
- 任一时刻只有一个活动 Table 或 Card 列表根，不能同时保留两个可访问实例。
- 切换形态保持同一 `ownerId`、查询、游标、结果、菜单、焦点意图和在途操作，不创建请求、不重放操作、不增加操作代次。
- 卡片使用列表语义；每张卡片具有包含记录身份的可访问名称，每个字段值都与可见字段标签关联。
- 菜单 portal 能找到等价卡片锚点时保持同一菜单实例并重新定位；不存在等价锚点时关闭一次并恢复到记录级目标。
- 桌面需要横向滚动时只允许表格容器滚动，页面根不得横向溢出；首尾边界和仍可滚动方向应可感知。
- 200% 缩放下优先转换为卡片，避免页面和表格同时双向滚动。
- 长名称、字体放大和翻译文本允许换行，不得截断记录身份、错误含义或操作名称。
- 低高度、横屏、动态浏览器工具栏和虚拟键盘下，结果、分页、菜单和错误恢复入口均可滚动到可视区域。
- 使用四向 safe-area inset，聚焦控件和主要操作不得被遮挡。
- 关键触摸目标采用至少 44×44 CSS px 的产品目标，并保留足够间距；不存在只能 Hover、长按、拖动或精确点击才能完成的任务。
- `prefers-reduced-motion` 下关闭非必要过渡；菜单正确性不得依赖动画完成。

## 12. Disposal 与资源释放

路由提交离开或 owner 卸载时，同步、幂等地执行：

1. 原子设置 `live=false`、`disposed=true`；重复调用不产生第二次 disposal。
2. 立即拒绝新的查询、翻页、菜单、焦点、行操作和公告工作。
3. abort 当前查询和行操作请求；取消或失效游标恢复、重试、防抖和延迟刷新。
4. 关闭菜单且不等待退出动画；移除 portal、popup、`aria-controls` 等实例引用。
5. 取消菜单定位的 `requestAnimationFrame`、浮层定位器和 resize/scroll 回调。
6. 失效待执行的焦点恢复、公告、操作结果和 DOM 提交任务。
7. 清理当前 owner 持有的事件监听器、计时器、观察器、订阅和缓存引用。
8. 移除当前实例 DOM；每项资源以 `ownerId` 核对并只释放一次，不得触碰同页其他实例。
9. 不把焦点返回即将移除的旧 trigger。
10. 不把本地 abort 或页面离开记录成“服务端操作已取消”。

即使 abort 失败，所有迟到回调仍必须经过各自完整提交门禁。门禁失败后的 DOM、state、focus 和 live-region 写入均为 0。

返回列表时，只有产品明确配置恢复策略才能恢复查询和滚动位置；恢复前重新校验权限、数据版本和游标位置。新实例使用新的 `ownerId` 和 `lifecycleToken`，旧菜单、权限结果和操作快照不得回放。

## 13. 完成前应用检查清单

| 原子规则族 | 适用性 | DOM | state | handler/event | request | 正文定位 | 验证状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 能力与状态 | 适用 | Table/Card、详情链接、行菜单 | 固定四组状态与独立 lifecycleGuard | 能力解析、状态归属 | 按能力门禁 | 第 1–3 节 | 设计已定义；运行时未验证 |
| 查询 | 适用 | 结果容器、刷新与重试入口 | snapshot、generation、phase、stale | 加载、刷新、重试、权限更新 | 五项门禁 | 第 4–5 节 | 设计已定义；真实竞态未验证 |
| 筛选 | 不适用 | 0 | 0 | 0 | 0 | 第 1、2 节的 absence contract | 未验证零入口 |
| 排序 | 适用 | 静态列标题；交互排序控件为 0 | 固定稳定 `sortRules` | 交互排序事件为 0 | 每个查询携带固定排序 | 第 1、4 节 | 后端比较语义未验证 |
| 分页 | 适用 | 上一页、下一页、结果摘要 | 不透明双向游标和单次恢复标记 | 方向导航、失效恢复 | 每个有效导航一个快照请求 | 第 4–5 节 | 真实游标服务未验证 |
| 数据状态 | 适用 | 骨架、错误、过期、空状态 | 六类 requestPhase、queryError、stale | 重试与结果提交 | 重试建立新请求 | 第 5–6 节 | 运行时未验证 |
| 选择 | 不适用 | 0 | 0 | 0 | 0 | 第 1、2 节的 absence contract | 未验证零入口 |
| 单行操作 | 适用 | 行菜单、行结果和恢复入口 | rowOperation 快照与代次 | 打开、关闭、提交、重试、失效 | 六项操作门禁 | 第 7–8 节 | 真实权限与操作竞态未验证 |
| 批量操作 | 不适用 | 0 | 0 | 0 | 0 | operationState 子槽表 | 未验证零入口 |
| 基础列状态 | 适用 | 稳定列和响应式字段映射 | visibleColumnIds、pinnedColumnIds、columnWidths、density | 展示形态转换 | 0 个展示变化请求 | 第 2、11 节 | 多视口未验证 |
| 可选列控制 | 不适用 | 0 | 0 | 0 | 0 | 第 1 节能力声明 | 未验证零入口 |
| Table 语义 | 适用 | 原生 table、th、caption | 当前 presentation | 原生控件事件 | 仅真实业务动作请求 | 第 10 节 | 可访问性树未验证 |
| ARIA Grid 语义 | 不适用 | 0 | 0 | 0 | 0 | 第 1、10 节 | 未验证零入口 |
| 键盘 | 适用 | 可聚焦链接、按钮、菜单项 | 菜单活动项、焦点意图 | Tab、Enter、Space、方向键、Home、End、Escape | 重复激活保护 | 第 7、9、10 节 | 实机键盘未验证 |
| 焦点 | 适用 | 稳定逻辑目标和 fallback | focusIntent | 刷新、翻页、权限、菜单、结果恢复 | 0 个焦点请求 | 第 8–9 节 | 浏览器焦点时序未验证 |
| 响应式 | 适用 | 单一 Table 或 Card 根 | presentation 与等价目标映射 | 断点和输入方式变化 | 断点切换请求增量 0 | 第 11 节 | 视口、缩放、触摸未验证 |
| ARIA 与公告 | 适用 | 名称、busy、stale、status、menu | announcementOwnerId | 已接受事件单次公告 | 公告不创建业务请求 | 第 10 节 | 屏幕阅读器未验证 |
| disposal | 适用 | 移除本实例 DOM、popup、ARIA 引用 | live/disposed 和 ownedResources | abort、失效、注销、释放 | disposal 后新请求 0 | 第 12 节 | route/unmount 竞态未验证 |
| 实例隔离 | 适用 | 各实例独立根和 portal | ownerId+lifecycleToken 命名空间 | 交错回调和资源释放 | 只向来源实例提交 | 第 3、12 节 | 双实例运行未验证 |
| 运行时验证边界 | 适用 | 真实 DOM 与可访问性树待测 | 真实状态日志待测 | 键盘、触摸、路由、竞态待测 | 受控响应顺序待测 | 第 15 节 | 未验证 |

## 14. 原子应用义务

| ruleFamily | obligationKey | applicability | currentValueOrZeroEvidence | outputLocation | verificationStatus |
| --- | --- | --- | --- | --- | --- |
| filtering | draft-applied-separation | 不适用 | DOM=0;state=0;handler/event=0;request=0 | 第 1–2 节 | 未验证零入口 |
| filtering | declared-apply-mode | 不适用 | DOM=0;state=0;handler/event=0;request=0 | 第 1–2 节 | 未验证零入口 |
| filtering | default-reset | 不适用 | DOM=0;state=0;handler/event=0;request=0 | 第 1–2 节 | 未验证零入口 |
| filtering | visible-removable-applied-values | 不适用 | DOM=0;state=0;handler/event=0;request=0 | 第 1–2 节 | 未验证零入口 |
| filtering | url-safety | 不适用 | DOM=0;state=0;handler/event=0;request=0 | 第 1–2 节 | 未验证零入口 |
| filtering | field-error-owner | 不适用 | DOM=0;state=0;handler/event=0;request=0 | 第 1–2 节 | 未验证零入口 |
| filtering | pagination-reset | 不适用 | DOM=0;state=0;handler/event=0;request=0 | 第 1–2 节 | 未验证零入口 |
| sorting | actual-key-direction | 适用 | `name ASC` | 第 1、4 节 | 后端未验证 |
| sorting | null-order | 适用 | `NULLS LAST` | 第 1、4 节 | 后端未验证 |
| sorting | case-rule | 适用 | Unicode case-fold，大小写不敏感 | 第 1、4 节 | 后端未验证 |
| sorting | locale-rule | 适用 | `zh-CN-u-co-pinyin` | 第 1、4 节 | 后端未验证 |
| sorting | natural-order-rule | 适用 | `naturalOrder=false`，按 locale 词法比较 | 第 1、4 节 | 后端未验证 |
| sorting | unique-stable-key | 适用 | `recordId ASC`，唯一且不可变 | 第 1、4 节 | 数据约束未验证 |
| sorting | interactive-dom | 不适用 | DOM=0;state=0;handler/event=0;request=0 | 第 1、10 节 | 未验证零入口 |
| sorting | interactive-aria | 不适用 | DOM=0;state=0;handler/event=0;request=0 | 第 1、10 节 | 未验证零入口 |
| sorting | interactive-keyboard | 不适用 | DOM=0;state=0;handler/event=0;request=0 | 第 1、10 节 | 未验证零入口 |
| sorting | interactive-focus | 不适用 | DOM=0;state=0;handler/event=0;request=0 | 第 1、10 节 | 未验证零入口 |
| sorting | reset-to-origin | 不适用 | DOM=0;state=0;handler/event=0;request=0 | 第 1、4 节 | 未验证零入口 |
| cursor | opaque-bidirectional-cursors | 适用 | 保存服务端不透明 `prevCursor/nextCursor`，客户端不解析 | 第 4 节 | 真实接口未验证 |
| cursor | missing-direction-disabled | 适用 | 缺少方向游标时对应按钮原生 disabled，请求数 0 | 第 4、10 节 | DOM 未验证 |
| cursor | forbidden-numbered-and-stream-entries | 适用 | 页码、跳页、加载更多、无限滚动 DOM/state/handler/request 均为 0 | 第 1、4 节 | 未验证零入口 |
| cursor | origin-and-single-recovery | 适用 | 范围改变回初始游标；每个失败快照最多恢复一次 | 第 4–5 节 | 真实失效响应未验证 |
| cursor | input-semantics | 适用 | 原生上一页/下一页按钮；鼠标、触摸、键盘产生同一意图 | 第 4、10 节 | 输入方式未验证 |
| cursor | single-focus-transition | 适用 | 匹配翻页响应后到结果摘要一次；自动恢复额外焦点为 0 | 第 5、9 节 | 焦点时序未验证 |

## 15. 尚未通过真实运行环境验证的边界

以下均为未验证，不能作为已通过结论：

- Chrome、Safari、Firefox、Edge 中菜单 portal、触发器卸载、原生 disabled 和路由提交的真实焦点时序。
- NVDA + Chrome、JAWS + Edge、VoiceOver + Safari/iOS、TalkBack + Chrome 下的 Table/Card 名称、表头关联、菜单键盘模型、busy/stale 状态和公告去重。
- 纯键盘完成详情导航、菜单打开、菜单导航、Escape、Tab 离开、翻页、刷新失败重试及权限降级恢复。
- 鼠标、触摸与键盘重复触发同一查询或行操作时，请求数是否仍严格为 1。
- `1440×900`、`1280×720`、平板横竖屏、`390×844`、低高度横屏手机以及真实内容断点下的 Table/Card 等价性。
- 200% 浏览器缩放、200% 字体、长中文/英文/无空格文本、国际化扩展、高对比度和 Reduced Motion。
- iOS 安全区域、动态工具栏、虚拟键盘打开/关闭后的滚动可达性和菜单定位。
- 查询乱序返回、abort 失败、同键刷新合并、不同权限键刷新并发以及旧响应静默丢弃。
- 菜单打开期间记录删除、权限撤销、Table/Card 转换和锚点消失时是否只关闭或迁移一次。
- 行操作在途期间权限改变、记录版本冲突、结果未知、重试和幂等键处理。
- 游标仅有单向、双向、完全缺失、重复失效及服务端恢复游标不可用的场景。
- `datasetVersion` 改变或服务端不提供一致性快照时的游标链失效行为。
- route commit 与 owner unmount 时同时挂起查询、操作、重试、菜单定位、焦点、公告、计时器、观察器和订阅的完整 disposal。
- 两个同页列表具有相同 generation 数值时，owner/token、popup、焦点和资源释放是否完全隔离。
- 后端是否真实保证 `pageSize=25`、固定排序比较规则、稳定且唯一的 `recordId`、不透明双向游标、权限版本和行操作幂等性。
<!-- END RAW OUTPUT -->
