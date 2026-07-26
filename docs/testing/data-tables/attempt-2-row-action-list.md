# Attempt 2 FAILED：单行操作管理列表

## 实际 spawn 参数

```json
{
  "task_name": "attempt_2_row_action_list",
  "fork_turns": "none",
  "message": "Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.\n\n请设计一个带 row-action 的管理列表。它使用游标分页，需要处理刷新失败、行菜单、焦点恢复、权限变化和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配，以及请求、菜单、焦点与其他资源在 disposal 时如何处理；同时列出尚未通过真实运行环境验证的边界。\n\n请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。"
}
```

`model` 与 `reasoning_effort` 没有作为调用参数发送。

## spawn 工具返回

```json
{"task_name":"/root/table_task5_green/attempt_2_row_action_list"}
```

## 完成 envelope

- Message Type: `FINAL_ANSWER`
- Task name（recipient）: `/root/table_task5_green`
- Sender: `/root/table_task5_green/attempt_2_row_action_list`
- Payload: 以下 `BEGIN/END RAW OUTPUT` 之间的原始内容。

## 完整 Prompt

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个带 row-action 的管理列表。它使用游标分页，需要处理刷新失败、行菜单、焦点恢复、权限变化和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配，以及请求、菜单、焦点与其他资源在 disposal 时如何处理；同时列出尚未通过真实运行环境验证的边界。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

## 原始完成 payload

<!-- BEGIN RAW OUTPUT -->
# 管理列表交互设计

## 1. 能力声明与边界

| 项目 | 设计结论 |
| --- | --- |
| `capabilityTier` | `row-action` |
| `resolvedTier` | 有单行操作权限时为 `row-action`；操作权限全部撤销时原子降级为 `display` |
| 分页 | 唯一采用 `cursor` 游标分页 |
| 行能力 | 独立详情链接、行操作菜单、单行异步操作 |
| 选择与批量 | 不启用行选择、表头全选、“全部筛选结果”和批量工具栏 |
| 排序 | 使用服务端固定稳定排序；首版不提供交互式排序 |
| 筛选 | 首版不提供筛选控件，`appliedFilters` 固定为空对象 |
| 页大小 | 固定为 25，不提供页大小选择器 |
| 列能力 | 首版不提供列隐藏、固定、调宽和顺序调整 |
| 响应式 | 桌面为原生 Table；窄屏按显式字段映射转为卡片列表 |
| 恢复策略 | 返回列表可恢复查询位置和滚动，但须重新校验权限、数据版本和游标；不恢复菜单、旧权限或操作状态 |

首版明确不包含：行内编辑、树表、拖拽排序、透视、随机跳页、虚构总页数、加载更多、无限滚动、多行选择和批量操作。整行不得包装成一个大链接；记录详情链接和行内按钮必须是相互独立的控件。

行动作由配置注册表声明稳定 `actionId`、可访问名称、权限条件、业务可用条件、风险等级、确认策略、请求策略和结果后的焦点策略。权限控制决定动作是否存在；业务状态暂不可用时可以保留为可感知的不可用项并说明原因。首版同一表格最多执行一个前台行变更操作，避免交错提交和焦点竞争；详情导航不受此限制。

## 2. 状态归属

每个挂载实例生成不可复用的 `ownerId` 和 `lifecycleToken`。

```text
lifecycleState
  ownerId
  lifecycleToken
  live: true | false
  phase: live | disposed

queryState
  appliedFilters: {}
  sortRules: [业务排序键, 唯一稳定记录键]
  pagination:
    mode: cursor
    currentCursor
    prevCursor
    nextCursor
    recoveryAttempted
  pageSize: 25
  querySnapshot
  snapshotId
  requestGeneration
  requestPhase:
    idle | initial-loading | ready | refreshing |
    initial-error | refresh-error
  queryError
  stale
  datasetVersion?
  permissionScope

viewState
  rows
  resultSummary
  presentation: table | cards
  expandedRecordIds

interactionState
  focusIntent:
    sourceEvent
    recordId?
    columnId?
    controlId?
    fallbackId
  menu:
    phase: closed | open
    menuId?
    menuGeneration
    recordId?
    triggerId?
    permittedActionIds

operationState
  phase:
    idle | confirming | submitting | succeeded | failed |
    permission-conflict | version-conflict | outcome-unknown
  operationId
  operationGeneration
  operationSnapshotId
  operationSnapshot
  idempotencyKey
  error
  resultFocusIntent
```

查询、展示、交互和操作状态分别由对应 owner 写入。查询失败不得写成行操作错误，行操作失败也不得把整张表置为查询错误。DOM 引用只能作为短生命周期定位资源；业务状态与焦点恢复必须使用稳定的 `recordId`、`columnId`、`controlId`，不能保存行数组索引。

## 3. 查询与游标分页

每次有效查询先冻结不可变 `querySnapshot`，至少包含：

```text
ownerId
lifecycleToken
snapshotId
requestGeneration
appliedFilters
完整稳定排序及空值/区域规则
pagination.mode = cursor
目标方向和服务端游标
pageSize
permissionScope
datasetVersion（服务端支持时）
queryIntentKey
```

随后才递增 `requestGeneration` 并发出请求。响应只有同时满足以下条件才能提交：

- owner 仍为 live；
- `ownerId` 相同；
- `lifecycleToken` 相同；
- `requestGeneration` 等于当前代次；
- `snapshotId` 等于当前查询快照。

取消请求只用于节省资源，不能替代提交门禁。任何迟到或失配响应只记录为 discarded，不得更新行、游标、错误、焦点、菜单或公告。

分页只显示“上一页”和“下一页”：

- 只使用服务端返回的 `prevCursor`、`nextCursor`；
- 缺少对应游标时使用原生 `disabled`；
- 不显示总页数、随机页码或跳页输入；
- 导航请求在途时防止复用旧游标重复导航；
- 成功提交后更新当前页的双向游标，不自行推导服务端游标；
- 翻页前记录焦点来源，成功后一次性把焦点移到结果摘要或标题；
- 导航失败保留当前行和当前游标，显示刷新型错误，不把用户留在空白页。

固定排序必须在业务排序键后追加不重复、不可变的记录键。只有服务端提供一致的 `datasetVersion` 或等价快照时，才能承诺跨页无重复、无遗漏。版本变化时当前游标链立即失效，停止继续导航，从初始游标重新查询。服务端不提供版本能力时，产品不得承诺严格跨页完整性。

服务端判断当前游标失效时，应返回最近有效的前向位置；客户端只自动恢复一次。没有有效回退位置则回到初始游标。重复送达同一失效结果不得形成恢复循环。

## 4. 状态转换

| 事件 | 转换与副作用 |
| --- | --- |
| 首次挂载 | `idle → initial-loading`；建立快照并请求；无可用结果时仅显示不可操作骨架 |
| 首次成功 | `initial-loading → ready`；提交行和游标，`stale=false` |
| 首次失败 | `initial-loading → initial-error`；用错误与重试入口替代表格 |
| 显式刷新 | `ready/refresh-error → refreshing`；保留旧行、游标和焦点意图，`aria-busy=true` |
| 刷新成功 | `refreshing → ready`；替换匹配快照的结果，清除 stale |
| 刷新失败 | `refreshing → refresh-error`；保留旧结果，`stale=true`，显示“数据可能已过期”和重试 |
| 同意图重复刷新 | 在创建新快照前合并；不新增请求、代次、快照或开始公告 |
| 不同意图查询 | 新建快照并递增代次；旧响应即使随后成功也丢弃 |
| 上一页/下一页 | 建立含目标游标的新快照；成功后更新游标并执行一次结果焦点迁移 |
| 游标失效 | 自动恢复一次；成功后简短公告恢复位置，不产生第二次焦点迁移 |
| 打开菜单 | `closed → open`；绑定稳定 `recordId` 和 `menuGeneration` |
| 关闭菜单 | `open → closed`；根据关闭原因决定是否恢复触发器焦点 |
| 提交行动作 | 冻结操作快照；`confirming → submitting → 业务结果` |
| 权限变化 | 重新解析 `resolvedTier` 和动作集合，清理越权状态；需要时建立新查询快照 |
| 路由离开/owner 卸载 | 任意 live 状态同步进入 `disposed`，之后不可再接受新工作 |

显式刷新意图键由当前游标位置、稳定排序、页大小、权限范围、数据版本和刷新原因组成。同一在途意图合并；权限范围等任一字段变化后必须形成新意图，即使旧请求仍在途也不能被全局合并。

## 5. 加载、错误、过期与空状态

### 首次加载

没有可用结果时显示与最终列结构相符的骨架，结果容器设置 `aria-busy="true"`。骨架中不得出现可聚焦链接、按钮、菜单触发器或可操作假数据。

### 首次加载失败

进入 `initial-error`，保留列表标题和结果区域，在原结果位置显示：

- 简洁错误摘要；
- 必要的可感知详情；
- 可聚焦“重试加载列表”按钮。

此时不渲染空表格。重试必须建立新快照和新代次。

### 刷新中

继续显示上次成功的行、列、游标和焦点上下文，结果容器设置 busy。旧行必须明确属于上次成功结果，不能伪装成新响应。

### 刷新失败

继续显示旧行和分页，进入 `refresh-error`、`stale=true`。错误区明确写明“数据可能已过期”，并提供“重新刷新”入口。查询错误只由结果区域拥有和公告，不在全局 Toast、行菜单和结果摘要中重复完整文案。

过期状态下：

- 详情和只读导航仍可使用；
- 变更型行动作只有在操作快照包含记录版本且后端强制校验版本时才可执行；
- 缺少可靠版本校验时，变更项显示为不可用，并通过 `aria-describedby` 说明需先刷新。

### 空状态

无筛选配置下返回零记录时显示独立的空数据集状态，例如“列表中还没有记录”。只有用户另有创建权限且产品显式配置创建入口时才展示创建操作；`row-action` 档位本身不推导创建权限。

若未来启用筛选，必须另行区分“数据源为空”和“当前条件无匹配”，后者提供调整或清除筛选入口，不能复用含糊的“暂无数据”。

当前游标因删除而失效不属于空数据集，必须先执行一次游标恢复。

## 6. 行菜单与单行操作

每条记录在独立操作列或卡片操作区提供真实 `<button>`：

```html
<button
  aria-label="打开「记录名称」的更多操作"
  aria-haspopup="menu"
  aria-expanded="false"
  aria-controls="menu-id">
</button>
```

`aria-controls` 只在对应菜单 DOM 存在时引用有效 ID。不能只用无名称的省略号图标，也不能依赖 Hover 或长按打开。

同一表格同时最多有一个活动菜单。打开另一行菜单时直接转移到新菜单，不把焦点抢回旧触发器。菜单使用 `role="menu"`，命令使用 `role="menuitem"`；导航动作可以使用带 `role="menuitem"` 的链接，变更动作使用按钮语义。

菜单关闭原因决定焦点行为：

- `Escape`：关闭并一次性返回原触发器；
- 选择只读或导航动作：进入目标流程，导航时不返回即将卸载的触发器；
- 选择直接变更动作：关闭后返回仍存活的触发器，再进入提交状态；
- 进入风险确认流程：焦点交由确认流程 owner；
- `Tab` / `Shift+Tab`：关闭菜单，并按文档顺序继续到菜单外下一或上一焦点目标；
- 点击外部可聚焦控件：关闭菜单，不抢回触发器焦点；
- 锚点移除、权限撤销或无等价响应式锚点：按记录级 fallback 恢复；
- route/unmount disposal：不恢复旧触发器。

菜单定位、翻转、尺寸观察和锚点更新均携带 `ownerId + lifecycleToken + menuGeneration`。刷新或断点变化后只允许按 `recordId + triggerId` 重新绑定仍存在的锚点，不能继续使用断开的 DOM 引用。

行动作开始时建立不可变操作快照，至少冻结：

```text
ownerId、lifecycleToken
operationId、operationGeneration、operationSnapshotId
recordId、actionId
recordVersion / datasetVersion
permissionScope
风险与确认结果
请求参数摘要
idempotencyKey
```

`submitting` 期间点击、Enter、Space 和事件重放都不能创建第二个请求。服务端变更请求必须使用幂等键。

操作结果只有 live、owner、lifecycle、operation ID、operation generation、operation snapshot ID 全匹配时才可提交。成功后以新查询快照刷新受影响数据；失败归受影响行的操作结果 owner，并提供具体原因和可用重试。重试创建新的操作 ID、快照和幂等键。

权限冲突不得伪装成普通失败或自动重试；应重新解析动作范围，并要求用户基于新权限重新发起。数据版本冲突使旧操作快照失效，刷新数据后重新确认。请求已发出但无法确认服务端结果时进入 `outcome-unknown`，保留快照并提供“检查最新状态”入口，不能盲目重复执行。

## 7. 权限变化

权限更新分为实例档位和逐行动作集合两层：

1. 全部单行操作权限撤销时，`resolvedTier` 原子降为 `display`。移除操作列、菜单触发器、打开菜单和待启动操作，不保留空列、空菜单或只有解释而无恢复路径的禁用入口。
2. 仅个别动作失权时，从所有相关菜单移除该动作；业务状态暂不可用与权限失权必须分开处理。
3. 打开菜单中的焦点项被移除时，优先移动到同菜单最近的仍允许动作；没有动作时关闭菜单并返回仍存在的触发器。
4. 触发器也因档位降级被移除时，依次寻找同记录的详情链接、同列最近记录的等价控件、结果摘要或分页控件，并只迁移一次。
5. 权限变化形成新的 `permissionScope`；若它影响查询范围，立即建立新查询意图和快照。旧权限请求的响应不得提交。
6. 若权限缩小可能影响记录可见性，只能保留经新权限同步证明仍可见的旧行；无法证明的内容在新查询完成前不得继续暴露。
7. 已在服务端执行中的操作不能因本地权限变化被宣称为“已取消”。迟到结果不能重新显示越权入口；权限不再匹配时进入权限冲突或只触发新权限范围内的安全刷新。

## 8. 键盘操作

原生 Table 不接管方向键、Home、End、Page Up 或 Page Down。Tab 顺序只进入详情链接、展开按钮、菜单触发器、重试和分页等真实控件；静态单元格不设置 `tabindex="0"`。

菜单键盘模型：

- 触发器上的 `Enter`、`Space` 或 `ArrowDown`：打开并聚焦第一个可用项；
- `ArrowUp`：打开并聚焦最后一个可用项；
- 菜单内 `ArrowDown` / `ArrowUp`：移动到下一/上一项并在两端循环；
- `Home` / `End`：移动到首项/末项；
- 输入字符：按本地化可访问名称执行前缀查找；
- `Enter` / `Space`：激活当前项；
- `Escape`：关闭并返回触发器；
- `Tab` / `Shift+Tab`：关闭并离开菜单；
- `aria-disabled="true"` 的业务不可用项允许被感知但不可激活，并关联具体原因；
- 表格不得吞掉菜单的方向键、激活键或 Escape。

上一页、下一页、刷新和重试均为真实按钮，可用 Tab 到达，以 Enter 或 Space 激活。不存在对应游标时使用原生 `disabled`。

## 9. 焦点管理

`focusIntent` 始终记录事件来源和稳定数据标识。刷新后即使记录排序位置变化，也必须按记录 ID 找回目标，不能聚焦原数组索引上的另一条记录。

通用恢复顺序：

1. 同一 `recordId + columnId + controlId`；
2. 同记录的等价控件；
3. 同列最近记录的等价控件；
4. 结果摘要或列表标题；
5. 与事件相关的当前分页控件。

最终目标必须存活、可聚焦且有可访问名称，不能是 `document.body`、文档根或已移除节点。

具体约束：

- 显式刷新和刷新失败不抢走仍存活的触发器焦点；
- 刷新提交后精确目标仍存在时不产生额外 `focus()`；
- 翻页成功后只移动一次到结果摘要/标题；
- 游标自动恢复不得产生第二次迁移；
- 行操作成功且记录仍存在时保持触发器焦点；记录被删除时移动到相邻记录的同类控件，再回退到结果摘要；
- 菜单正常 Escape 关闭返回触发器；pointer 外部关闭和 Tab 离开不抢焦点；
- 权限降级先计算等价目标，再提交结构移除和一次焦点迁移；
- route/unmount 时绝不把焦点返回即将移除的旧触发器；新路由提交后仅由新路由策略聚焦一次页面主标题、主内容或主要操作。

## 10. ARIA 与公告

桌面使用原生 `<table>`，通过 `<caption>` 或 `aria-labelledby` 提供可区分名称。列头使用 `<th scope="col">`，记录身份优先使用 `<th scope="row">`。固定排序可在主排序列设置正确的 `aria-sort`，但不渲染不可操作的伪排序按钮。

结果容器：

- 关联列表名称、结果摘要、过期或错误说明；
- 加载和刷新时设置 `aria-busy="true"`；
- 成功、失败、过期和恢复状态均有可见文本，不能只靠颜色或图标；
- 查询 owner 拥有唯一 `announcementOwnerId`。

公告规则：

- 每个被接受的查询开始公告一次；
- 改变结果数量或位置的成功响应公告一次；
- 刷新失败公告一次“数据可能已过期”；
- 游标恢复成功公告一次；
- 被合并、丢弃、取代或 disposal 后到达的事件不公告；
- 菜单打开/关闭依靠焦点与 `aria-expanded` 表达，不额外播报；
- 同一完整错误只由一个 primary owner 显示和公告，不能同时由结果区、Toast 和全局 live region重复朗读。

分页使用 `<nav aria-label="列表分页">`。按钮名称为“上一组结果”“下一组结果”，不使用暗示可靠总页数的“第 X/Y 页”。

## 11. 桌面与移动端

桌面使用原生 Table。记录身份、主要状态和行操作列保持直接可定位；必要横向滚动只发生在表格容器，页面根不得横向溢出。滚动容器需提供首尾边界和仍可滚动方向的视觉与非颜色提示。

窄屏启用显式 `responsivePresentation: table-to-card`。字段映射固定为：

- 卡片可访问名称：记录身份；
- 直接展示：记录身份、主要状态、首要元数据、详情入口、行菜单；
- 次要字段：按确定顺序放入有名称的详情区域，每个值保留字段标签；
- 所有桌面可访问字段和动作必须在卡片中有等价入口。

卡片列表使用 `<ul>` / `<li>` 或等价列表语义，每张卡片具记录级名称；不得把卡片伪装成 Table 或 Grid。

实时断点转换必须：

- 保持同一 `ownerId`、查询快照、游标、展开状态、焦点意图和操作快照；
- 不新增查询、不重放操作、不重建代次；
- 任一时刻只有一个活动 Table 或卡片列表；
- 打开菜单只有一个 popup；使用 `recordId + triggerId` 重绑定卡片中的等价锚点；
- 菜单项仍存在时保持菜单内焦点；没有等价锚点时关闭并只迁移一次；
- 不因设备名称判断形态，以内容可用空间、缩放和输入能力决定转换。

需要覆盖 200% 缩放、字体放大、长翻译、低高度横屏、动态浏览器工具栏、虚拟键盘和四向安全区域。关键流程不得同时要求页面和列表双向滚动。移动端触发器采用足够大的触摸目标和间距；Hover、滑动、长按均不能成为唯一入口。

## 12. Disposal 与实例隔离

路由提交离开或 owner 卸载时，实例同步且幂等地进入 `disposed`，不等待菜单动画、网络请求或行动作返回。

处置顺序：

1. 设置 `live=false`，使 `lifecycleToken` 失效；之后拒绝查询、分页、菜单、操作、焦点和公告新工作。
2. Abort 当前查询、游标恢复和行操作请求；这只表示客户端停止等待，不宣称服务端业务已取消。
3. 失效待执行的重试、防抖、Promise continuation、焦点任务和 live-region 公告。
4. 关闭并立即移除当前实例的菜单 portal，不播放退出动画；清除 `aria-controls`、`aria-expanded` 等失效引用。
5. 停止菜单定位器、`requestAnimationFrame`、定时器、`ResizeObserver`、`IntersectionObserver`、窗口/文档监听器和数据订阅。
6. 移除当前实例 DOM，并清空仅属于该 owner 的资源登记。
7. 所有迟到回调仍执行完整提交门禁，失败后只记录 discarded，DOM、状态、焦点和公告写入均为零。

每项资源登记其 `ownerId`，`release()` 必须幂等且只执行一次。处置一个列表不得关闭同页另一列表的菜单、取消其请求、删除其 ARIA 节点或把焦点落到另一实例的同名按钮。不同实例的 generation 数值可以相同，但只能在各自 `ownerId + lifecycleToken` 命名空间内解释。

返回页面时创建全新的 `ownerId` 和 `lifecycleToken`。只有显式恢复策略允许恢复查询位置和滚动；恢复前重新校验权限范围、数据版本和游标有效性。旧菜单、权限解析结果、操作快照和错误状态均不回放。

## 13. 实施适用性清单

| 规则族 | 结论与依据 |
| --- | --- |
| 能力与状态 | 适用；显式 `row-action`，权限后解析为 `row-action` 或 `display`，四组状态独立 |
| 查询 | 适用；不可变快照、意图合并、代次与生命周期提交门禁 |
| 筛选 | 首版控件不适用；可观察依据为 `appliedFilters={}` 且无筛选 DOM/事件入口 |
| 排序 | 固定稳定排序适用；交互式排序不适用，表头无排序按钮 |
| 分页 | 适用；唯一为 cursor，仅有服务端支持的上一组/下一组 |
| 加载、错误、空状态 | 适用；区分首次、刷新、过期、空数据集和游标失效 |
| 选择与批量 | 不适用；`row-action` 下选择状态、复选框、全选和批量工具栏均不存在 |
| 单行操作 | 适用；菜单、操作快照、幂等、冲突和错误 owner 均已定义 |
| 列显示/固定/调宽 | 首版可选能力不适用；无控制器、固定状态或调整柄 |
| Table/Grid 与键盘 | 原生 Table 适用；ARIA Grid 不适用，因为没有二维单元格导航需求 |
| 焦点 | 适用；按稳定记录/列/控件标识恢复并限制一次迁移 |
| 响应式 | 适用；桌面 Table、显式等价卡片映射、单实例转换 |
| ARIA 与公告 | 适用；名称、header 关联、busy、菜单、分页和唯一公告 owner |
| Disposal 与实例隔离 | 适用；owner/token 门禁、资源登记、幂等释放和迟到回调丢弃 |
| 运行时验证边界 | 适用；以下项目在真实环境验证前均不得标记为通过 |

## 14. 尚未通过真实运行环境验证的边界

以下内容目前仅为设计契约，均为未验证：

- 真实游标接口的 `prevCursor`、`nextCursor`、失效游标恢复、`datasetVersion` 和权限范围参数是否满足契约；
- 服务端稳定排序、跨页版本一致性、行操作幂等键、记录版本冲突和结果未知核对能力；
- 快速刷新、上一页/下一页交错、权限变化期间旧响应乱序到达时的提交门禁；
- 菜单打开期间行重排、行删除、动作权限撤销、Table/卡片切换和刷新失败的锚点重绑定；
- 行操作在途时权限降级、数据版本变化、route unmount 和网络取消失败后的迟到响应；
- Chromium、Safari、Firefox 中 portal 菜单的 Escape、Tab、点击外部、滚动定位和焦点恢复；
- VoiceOver、NVDA、JAWS 对 Table header、`aria-busy`、菜单、不可用原因、刷新错误和单次公告的实际输出；
- 仅键盘完成刷新、游标分页、菜单操作、错误重试和焦点 fallback 的完整路径；
- 鼠标、触摸和键盘触发同一意图时的单请求与相同终态；
- `1440×900`、`1280×720`、平板横竖屏、`390×844` 窄屏、低高度横屏及实时断点切换；
- 200% 浏览器缩放、系统字体放大、长文本和国际化扩展下的溢出、遮挡与菜单定位；
- 动态视口、虚拟键盘、四向安全区域、Reduced Motion、高对比度和粗指针环境；
- route/unmount 时 AbortController、定位器、观察器、监听器、计时器、焦点任务、公告队列和 portal 是否均只释放一次；
- 同页双实例交错请求、同名控件焦点恢复及一个实例 disposal 后另一实例完全不受影响；
- 返回列表时权限、版本、游标和滚动恢复失败后的安全降级路径。
<!-- END RAW OUTPUT -->
