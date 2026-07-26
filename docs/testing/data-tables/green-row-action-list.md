# GREEN：单行操作管理列表

## 派发参数

```json
{
  "task_name": "green_row_action_list",
  "canonical_identity": "/root/table_task5_green/green_row_action_list",
  "fork_turns": "none",
  "model": "omitted (inherited runtime default)",
  "reasoning_effort": "omitted (inherited runtime default)",
  "filesystem_edits_by_agent": false
}
```

## 完整 Prompt

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个带 row-action 的管理列表。它使用游标分页，需要处理刷新失败、行菜单、焦点恢复、权限变化和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配，以及请求、菜单、焦点与其他资源在 disposal 时如何处理；同时列出尚未通过真实运行环境验证的边界。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

## 原始输出

<!-- BEGIN RAW OUTPUT -->
# 带 Row Action 的游标分页管理列表设计

## 1. 能力边界

实例必须显式声明：

```ts
capabilityTier: 'row-action'
paginationMode: 'cursor'
ownerId: string
lifecycleToken: string // 每次挂载重新生成、不可复用
```

权限解析后的 `resolvedTier` 只能决定当前渲染能力：

- `row-action`：支持查询、筛选、排序、上一页/下一页、详情或单行操作。
- `display`：权限降级后的只读形态；操作列、菜单、单行操作状态必须整体移除。
- 不因后端返回了某个 action、页面名称或是否存在复选框来推断档位。

本列表不提供多选、表头全选、批量工具栏，也不建立选择状态。第一版同时排除行内编辑、树形表格、拖拽行排序、透视表、加载更多、无限滚动、拖拽改变列顺序和个人布局持久化。若有“新建记录”等列表级操作，必须由独立权限声明，不能由 `row-action` 档位隐式获得。

每条记录必须有不可变且稳定的 `recordId`；分页和焦点恢复不得依赖数组索引。包含详情链接和菜单按钮的行不能整体包装成一个大链接。

客户端权限只控制入口可见性，不能作为服务端授权。所有修改操作仍须由服务端重新校验当前权限、记录版本和操作参数。破坏性或高影响操作必须移交给独立的确认流程，菜单项本身不得直接提交。

## 2. 状态模型

至少拆分以下状态，禁止用一个 `loading/error/open` 混合表达：

| 状态域 | 最少字段 |
| --- | --- |
| 生命周期 | `lifecycle: live \| disposed`、`ownerId`、`lifecycleToken` |
| 查询 | `querySnapshot`、`snapshotId`、`requestGeneration`、`requestPhase`、`queryError`、`stale`、`datasetVersion?` |
| 游标 | `currentPosition`、`prevCursor?`、`nextCursor?`、`pageSize`、当前查询链身份 |
| 展示 | 当前成功行、列配置、结果摘要、响应式呈现形态 |
| 菜单 | `closed \| opening \| open \| closing \| disposed`、`menuInstanceId`、`recordId`、`activeActionId?`、`permissionRevision` |
| 焦点 | `focusIntentId`、`sourceEvent`、`recordId?`、`columnId?`、`controlId?`、`fallbackId` |
| 单行操作 | `operationId`、`operationGeneration`、`operationSnapshotId`、`phase`、`recordId`、`actionId`、错误与恢复入口 |

菜单同一时刻最多打开一个。默认同一 `recordId + actionId` 只能有一个请求在途；是否允许不同记录并发由 action 配置显式声明。

### 主要转换

| 事件 | 转换与约束 |
| --- | --- |
| 首次查询 | `idle → initial-loading → ready / initial-error` |
| 显式刷新 | `ready / refresh-error → refreshing → ready / refresh-error`；保留上次成功结果 |
| 同一刷新重复触发 | 在创建快照前合并；不增加快照、代次、请求或公告 |
| 筛选、排序、页大小变化 | 游标回到初始位置，建立新快照；旧游标链作废 |
| 上一页/下一页 | 使用服务端支持的方向游标建立新快照；响应接受前不提交新位置 |
| 菜单打开 | `closed → opening → open`；先关闭旧菜单，不向旧触发器返焦 |
| 普通关闭 | `open → closing → closed`；是否返焦由关闭原因决定 |
| 权限提交 | 原子更新 `resolvedTier` 和菜单项；越权入口立即移除 |
| 路由离开或 owner 卸载 | 任意 live 状态立即进入 `disposed`，不等待请求或动画 |

## 3. 请求与游标分页

### 查询快照

每次被接受的查询意图先冻结不可变 `querySnapshot`，至少包含：

- 已应用筛选；
- 完整稳定排序，包括唯一稳定次序键、空值和区域规则；
- `paginationMode: cursor`、当前方向和本次使用的 opaque cursor；
- `pageSize`；
- 当前权限范围；
- `datasetVersion` 或等价服务端快照身份；
- 刷新原因。

随后生成新 `snapshotId`，并严格递增 `requestGeneration`。

查询响应必须同时通过以下门禁才能提交：

1. owner 仍为 `live`；
2. `ownerId` 匹配；
3. `lifecycleToken` 匹配；
4. `requestGeneration` 匹配；
5. `snapshotId` 匹配。

`AbortController` 只用于节省资源，不能代替提交门禁。取消失败或已经返回网络层的旧响应仍只能记录为 discarded，不能修改行、游标、错误、焦点或公告区域。

### 游标规则

- 只显示“上一页”和“下一页”，不虚构总页数、随机跳页、加载更多或无限滚动。
- 没有对应游标时使用原生 `disabled`，激活不得发请求。
- 游标是 opaque 值，只能在生成它的筛选、排序、页大小、权限范围和数据版本链内使用。
- 筛选、排序、页大小或权限范围变化后，旧 `prevCursor/nextCursor` 全部失效并回到初始游标。
- `datasetVersion` 与当前链不一致时，立即标记链失效和 `stale`，停止继续导航，从初始位置重新查询。
- 若服务端不提供一致性版本能力，不得承诺跨页无重复或遗漏。
- 当前游标因删除或数据变化失效时，只使用服务端返回的最近有效前向位置，或回到初始游标；自动恢复最多一次，避免空页循环。
- 分页请求失败时保留原页，明确显示“无法加载目标页，仍显示上一成功结果”，并提供重试。

### 显式刷新去重

`intentKey` 至少由已应用筛选、排序、当前游标位置、页大小、权限范围、数据版本和刷新原因组成。

- 同一 `intentKey` 已在途：点击、Enter、Space 或事件重放全部合并。
- `intentKey` 变化：即使旧请求仍在途，也必须接受新请求；例如权限范围从 P1 变为 P2。
- P1 的迟到响应不能覆盖 P2 结果。

## 4. 加载、错误、过期与空状态

### 首次加载

没有可用结果时显示与最终列结构一致的不可操作骨架：

- 结果容器 `aria-busy="true"`；
- 骨架内不得出现可操作链接、菜单按钮或假数据；
- 查询开始只公告一次。

### 刷新中

显式刷新当前查询时：

- 保留上次成功的行、列、当前游标上下文和 `focusIntent`；
- `requestPhase = refreshing`、结果容器 `aria-busy="true"`；
- 显示“正在刷新当前结果”；
- 旧行必须明确属于上次成功结果，不能伪装成新响应。

刷新不默认关闭已打开菜单。接受新结果时用稳定 `recordId/actionId` 重新核对菜单锚点和动作集合：目标仍等价则保留；否则按菜单焦点规则关闭或迁移。

### 首次失败

没有任何可用结果时进入 `initial-error`：

- 结果区内显示完整错误；
- 以可聚焦“重试加载记录”替代不可用表格；
- 重试创建新快照和新代次；
- 不渲染空表格或假行。

### 刷新失败

进入 `refresh-error`：

- 保留旧行、游标和焦点上下文；
- `stale = true`；
- 显示“刷新失败，当前显示的是上次成功结果，数据可能已过期”及重试按钮；
- 不清空表格、分页或菜单锚点；
- 同一完整错误只由结果 owner 显示和公告一次。

对旧数据上的修改动作采用显式 `stalePolicy`：

- `server-revalidate`：允许发起，但服务端必须原子校验权限与记录版本；
- `block`：后端不能可靠校验时，禁用修改动作并提供可感知原因，用户刷新成功后再试。

只读详情不因 stale 自动禁用。

### 空状态

必须区分：

- 有已应用筛选但结果为零：“当前条件无匹配记录”，提供调整或清除筛选入口。
- 初始游标、无有效筛选且数据源为空：“尚无记录”；只有另行授权时才显示“新建记录”。
- 非初始游标返回空且被服务端判定位置失效：走游标恢复，不显示普通空状态。

查询错误、筛选字段错误和单行操作错误分别归自己的 primary owner，不得互相覆盖或重复公告。

## 5. 行菜单

### 结构

每行操作单元格使用真实按钮：

```html
<button
  aria-haspopup="menu"
  aria-expanded="false"
  aria-controls="owner-record-menu"
>
  打开“记录名称”的操作菜单
</button>
```

菜单使用 `role="menu"`，由触发按钮通过 `aria-labelledby` 命名；操作使用 `role="menuitem"`。导航项可以是带 `role="menuitem"` 的真实链接，命令项使用真实按钮。

未授权动作必须不渲染，不能仅禁用后继续暴露。因记录状态暂时不可用但允许用户了解的动作可使用 `aria-disabled="true"`，阻止激活，并通过 `aria-describedby` 提供具体原因。

菜单可通过 portal 渲染，但 `aria-controls`、`aria-labelledby` 和 DOM ID 必须始终指向当前实例；ID 包含 `ownerId + recordId + menuInstanceId`，避免多列表冲突。

### 打开与关闭

菜单在以下情况关闭：

- Escape；
- 用户激活动作；
- 点击菜单外区域；
- 打开另一行菜单；
- 锚点记录被刷新结果移除；
- 操作权限被撤销且没有等价菜单项；
- 响应式转换后没有等价锚点；
- 路由离开或 owner 卸载。

普通关闭可有轻量动画，并遵守 Reduced Motion。disposal 关闭不播放动画。

菜单在表格容器滚动、窗口缩放和内容尺寸变化时应重新定位；如果锚点不可见或无法安全定位，则关闭菜单，不允许悬空 popup。固定列不得遮挡菜单、焦点环或滚动边界。

### 权限变化

权限提交必须一次完成：

1. 更新 `permissionRevision`、权限范围与 `resolvedTier`；
2. 移除未授权菜单项；
3. 若当前活动项被移除，先把焦点移到最近的仍可用菜单项；
4. 若已无菜单项，关闭菜单并移到同记录详情链接，其次结果摘要；
5. 若降级为 `display`，整体移除操作列、菜单状态和失效 ARIA 引用。

菜单关闭时若焦点本来不在菜单内，不得主动抢焦点。

权限增加只增加入口，不自动打开菜单或移动焦点。读取权限范围变化时，应立即发出包含新范围的查询；无法确认旧行仍可读时，在新权限结果返回前隐藏潜在越权内容，不能继续展示为普通 stale 数据。

在途单行操作不因客户端权限变化被声称为已取消。服务端仍须返回成功、权限冲突、版本冲突或结果待确认；后续重试必须使用当前权限重新建立操作快照。

## 6. 键盘操作

### 原生表格

本场景使用原生 `<table>`，不使用 ARIA Grid：

- Tab/Shift+Tab 只进入真实链接、按钮和菜单触发器；
- 静态单元格不设置 `tabindex="0"`；
- 表格不拦截方向键、Home、End、Page Up 或 Page Down；
- 行详情链接与菜单按钮各自只触发自己的动作。

### 菜单

- 触发器 Enter、Space、ArrowDown：打开并聚焦第一个可用项。
- ArrowUp：打开并聚焦最后一个可用项。
- 菜单内 ArrowDown/ArrowUp：移动到下一项/上一项并循环。
- Home/End：移动到首项/末项。
- 可选实现字符前缀搜索，但必须处理国际化文本和重复名称。
- Enter/Space：激活当前项；`aria-disabled` 项不执行。
- Escape：关闭并把焦点返回原触发器；若触发器已消失则执行 fallback。
- Tab/Shift+Tab：关闭菜单，并继续到触发器之后/之前的正常 Tab 目标；不得形成焦点陷阱。
- 指针点击菜单外区域：保留用户点击所得焦点，不强制返回旧触发器。

分页和重试按钮保持原生 Enter/Space 行为。重复触发保护必须覆盖点击、键盘和事件重放。

## 7. 焦点管理

`focusIntent` 使用稳定身份：

```ts
{
  focusIntentId,
  sourceEvent,
  recordId?,
  columnId?,
  controlId?,
  fallbackId
}
```

刷新或结果替换后按以下顺序处理：

1. 同一 `recordId + columnId + controlId` 仍存在且语义未变：保持焦点；节点未被替换时不得再次调用 `focus()`。
2. 精确控件消失：同记录的等价控件。
3. 记录消失：同列邻近记录的等价控件。
4. 无合适记录：结果摘要或结果标题。
5. 与分页相关时：当前分页控件。

不得按旧数组索引聚焦另一条记录，也不得落到 `document.body`、文档根或已移除节点。

具体事件策略：

- 点击刷新、应用筛选或排序后，触发器仍存在时不抢焦点。
- 用户翻页的匹配响应提交后，默认只移动一次到结果摘要/标题；若产品明确选择保留仍存活且语义未变的分页触发器，也只能采用一种策略。
- 游标失效自动恢复不得产生第二次焦点移动。
- 菜单动作导航到新路由时不返回旧触发器，由新路由处理焦点。
- 留在当前页的单行动作关闭菜单后返回触发器；若成功结果删除该行，再按稳定 ID fallback 迁移一次。
- 权限撤销或列移除前先锁定仍存活的 fallback；菜单活动项、触发器和 ARIA 引用按依赖顺序迁移和移除。
- 异步焦点任务必须携带 `ownerId + lifecycleToken + focusIntentId`，执行前再次校验。若用户已主动移动焦点且原目标未被本次提交移除，不得再抢焦点。

## 8. 单行操作请求

激活动作时建立不可变快照，至少冻结：

- `ownerId`、`lifecycleToken`；
- `operationId`、`operationGeneration`、`operationSnapshotId`；
- `recordId`、`actionId`；
- 当前记录版本或 `datasetVersion`；
- 权限范围；
- 本次尝试的幂等键。

操作响应只有以下六项全部匹配才能提交：`live + ownerId + lifecycleToken + operationId + operationGeneration + operationSnapshotId`。权限或数据版本的业务裁决由服务端响应表达，不能另造一个较短的生命周期门禁。

- 确定成功：显示一次结果反馈，并用新查询快照刷新受影响数据。
- 确定失败：错误属于该 `operationOwnerId`；行仍存在时显示在行操作面，行消失时由同一 owner 在列表级结果摘要显示，不能复制两份。
- 权限冲突：移除越权恢复入口，不自动重试。
- 数据版本冲突：刷新记录，要求用户重新发起动作。
- 请求超时但无法确认服务端是否执行：进入“结果待确认”，提供状态核对入口；不得直接按普通失败自动重试。
- 同一快照在途时的点击、Enter、Space 和事件重放都不得创建第二请求。

## 9. ARIA 与公告

- 表格使用 `<table>`、`<caption>` 或 `aria-labelledby` 提供可区分名称。
- 列头使用 `<th scope="col">`；记录身份列优先使用 `<th scope="row">`。
- 操作列列头为“操作”，每个菜单按钮名称必须包含记录身份。
- 分页使用 `<nav aria-label="记录分页">`；按钮名称为“上一页记录”“下一页记录”，缺少游标时使用原生 `disabled`。
- 结果摘要可聚焦，具有稳定 ID，作为分页、行移除和权限降级的通用 fallback。
- `initial-loading` 和 `refreshing` 时结果容器设置 `aria-busy="true"`，终态恢复为 `false`。
- stale、失败、权限冲突和结果待确认必须有文本表达，不能只依赖颜色或图标。
- 使用一个由结果 owner 管理的简洁 `role="status"`/`aria-live="polite"` 区域；不要把整个表格设为 live region。

公告基数：

- 每个被接受的查询开始一次；
- 改变结果数量或位置的已接受响应一次；
- 查询失败一次；
- 游标失效恢复成功一次；
- 影响当前用户的权限操作变化最多一次；
- 单行操作开始或终态按需要各一次。

被合并、丢弃、取代或 disposal 后到达的事件公告为零。不得重复朗读完整行、全部筛选条件或同一完整错误。

## 10. 桌面与移动端

桌面默认使用原生表格；必要横向滚动只发生在表格容器，页面根不得横向溢出。记录身份、主要状态和操作入口必须可直接定位。固定操作列只有在不会遮挡焦点、菜单和滚动边界时使用；空间不足时优先解除固定，而不是隐藏操作。

移动端有两种合法形态：

1. 保留表格并使用受控横向滚动；
2. 在显式配置 `responsivePresentation: card` 且字段映射完整时转换为卡片。

卡片必须：

- 每张卡片有包含记录身份的可访问名称；
- 字段值与标签关联；
- 保留详情和全部授权行操作；
- 使用同一 `ownerId`、查询快照、游标、操作和焦点意图；
- 与表格形态不能同时作为两个活动实例存在。

断点实时变化不得发查询、重放操作或重建 owner。菜单有等价锚点时重新锚定并保留活动项；没有等价锚点时关闭一次并恢复到记录级等价控件。

移动端仍使用非模态 popup 菜单，不引入额外 Drawer 契约。菜单按可用空间翻转，最大高度受动态视口限制并允许内部滚动，同时避开四向安全区域。触摸目标和间距不得依赖精确点击。

必须考虑 `1440×900`、`1280×720`、平板横竖屏、窄屏和低高度手机、200% 缩放、字体放大、长翻译、动态工具栏、虚拟键盘、安全区域、Reduced Motion 和高对比度。

## 11. Disposal

路由提交离开或表格 owner 卸载时，实例同步进入 `disposed`。这是生命周期终止，不是关闭动画。

处置顺序：

1. 原子标记 `live=false`，记录一次 `disposal-entered`；重复调用直接返回。
2. 拒绝新的查询、分页、菜单、焦点、操作和公告工作。
3. 取消查询、分页恢复、重试和防抖；失效所有对应回调。
4. 立即移除菜单和 popup，不播放关闭动画；取消定位任务。
5. 失效待执行焦点、操作结果和 live-region 公告。
6. 注销计时器、`requestAnimationFrame`、scroll/resize/pointer/keydown 监听器、媒体查询监听、路由和权限订阅、`ResizeObserver`、`IntersectionObserver` 等。
7. 移除当前实例 DOM 与 ARIA 引用。
8. 仅释放登记为当前 `ownerId + lifecycleToken` 持有的资源，每项最多一次。

取消网络请求不代表服务端操作已取消；不得把路由离开显示为“操作已取消成功”。所有迟到回调仍执行查询五项门禁或操作六项门禁，失败后只能记录 discarded，DOM、状态、焦点和公告写入必须为零。

旧触发器随路由移除时不得返焦。新路由提交后，只能由新路由自身把焦点移动一次到页面主标题、主内容或主要操作。

返回列表是否恢复查询和滚动位置必须由产品显式声明。即使允许恢复，也必须先重新校验权限、数据版本和游标位置，并创建新的 `ownerId/lifecycleToken`；旧菜单、权限结果和操作快照不得回放。

## 12. 尚未通过真实运行环境验证的边界

本文是实现设计，以下项目均尚未在真实组件、浏览器、辅助技术和后端环境中验证：

- 后端 opaque cursor 的过期、上一页支持、失效恢复、稳定排序和 `datasetVersion` 一致性契约。
- 权限推送时序、读取权限与操作权限的区分，以及权限变化和在途操作并发时的服务端裁决。
- 单行操作幂等键、超时后的状态核对接口，以及路由离开后服务端实际执行结果。
- 实际路由框架中 route commit、组件卸载、并发渲染或开发模式重复 effect 对 disposal 幂等性的影响。
- 菜单 portal 在 sticky 列、嵌套滚动、200% 缩放、低高度、动态视口和安全区域下的定位与裁剪。
- Chrome、Firefox、Safari 中菜单 Tab/Shift+Tab、事件重放和焦点恢复行为。
- NVDA、JAWS、VoiceOver 对原生表格、`aria-busy`、menu、stale 文案和单次 live announcement 的实际朗读。
- 键盘、鼠标、触摸、屏幕阅读器、高对比度、Reduced Motion、长文本和国际化扩展下的完整任务可达性。
- 表格与卡片实时切换时菜单重锚、活动焦点和单实例资源释放。
- 同页多个列表具有相同 generation 数值时，`ownerId + lifecycleToken` 的请求、菜单、焦点、公告和资源隔离。
- 取消失败后旧查询、旧菜单定位、旧焦点任务和旧操作结果任意顺序到达时，对新路由零写入的保证。
<!-- END RAW OUTPUT -->

## Completion receipt

- canonical agent：`/root/table_task5_green/green_row_action_list`
- receipt：`FINAL_ANSWER received; agent status completed`
- 原始输出完成后才包装本证据文件；原始输出区未做规范性改写。

## SHA-256

- prompt：`111068c5e27c3cb8a555eabfe0be3ed97056441f9be9c860589bdcb1f869ed6e`
- output：`be471f8a2fda2b30bf3d1c19108d369b8b463d739cb8864fe15565d79721eaf8`
