# Attempt 4 GREEN：单行操作管理列表

## 派发与完成元数据

- 实际 spawn args 恰为 `task_name=attempt_4_row_action_list`、`fork_turns=none` 和 `message`；`message` 是下方 RAW PROMPT 的逐字内容。
- `model` 与 `reasoning_effort` 均未发送。
- 精确 spawn tool return：`{"task_name":"/root/table_task5_green/attempt_4_row_action_list"}`
- 精确 completion envelope metadata：`Message Type FINAL_ANSWER`；recipient `Task name /root/table_task5_green`；`Sender /root/table_task5_green/attempt_4_row_action_list`。

## 原始提示

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个带 row-action 的管理列表。它使用游标分页，需要处理刷新失败、行菜单、焦点恢复、权限变化和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配，以及请求、菜单、焦点与其他资源在 disposal 时如何处理；同时列出尚未通过真实运行环境验证的边界。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

## 原始完成输出

<!-- BEGIN RAW OUTPUT -->
# 管理列表交互设计

## 1. 能力与配置定标

| 项目 | 设计结论 |
| --- | --- |
| `capabilityTier` | `row-action` |
| `resolvedTier` | 默认 `row-action`；操作权限全部撤销时降为 `display` |
| 数据结构 | 原生 `<table>`；不采用 ARIA Grid |
| 筛选 | 不启用。无筛选 DOM、草稿、提交 handler 或筛选请求入口；快照中的 `appliedFilters` 固定为空，仅用于统一协议 |
| 排序 | 启用固定、非交互排序：`updatedAt DESC NULLS LAST, recordId ASC` |
| 排序比较规则 | `updatedAt` 按 UTC 时间戳比较，无大小写、locale 或自然排序；`recordId` 为不可变规范化小写 ASCII ID，按码点升序，作为唯一稳定键 |
| 分页 | 唯一模式为 `cursor`，固定 `pageSize=25` |
| 选择/批量操作 | 不启用；不得出现选择列、全选、选择状态或批量工具栏 |
| 单行操作 | 启用；包括详情跳转和经权限校验的单记录命令 |
| 列配置 | 不启用用户隐藏、固定、调宽、拖拽排序或布局持久化 |
| 响应式形态 | 桌面/平板横屏使用表格；窄屏使用已评审的等价卡片映射 |
| 返回恢复 | `restorePolicy=query-and-scroll`；返回时重新验证权限、数据版本和游标，绝不恢复旧菜单或旧操作 |
| 排除能力 | 行内编辑、树表、行拖拽、透视、加载更多、无限滚动、随机跳页均不提供 |

整行不得包装成大链接。记录名称可以是独立详情链接，操作列另放独立菜单按钮，两者互不触发。

破坏性或高影响命令不能直接从菜单提交；菜单只产生操作意图，后续必须交由具备相应风险确认能力的独立流程处理。

## 2. 状态与 owner

每个实例生成唯一且不可复用的 `ownerId`、`lifecycleToken` 和 `announcementOwnerId`。

```ts
queryState = {
  requestPhase:
    | "idle"
    | "initial-loading"
    | "ready"
    | "refreshing"
    | "initial-error"
    | "refresh-error",
  querySnapshot,
  snapshotId,
  requestGeneration,
  currentRows,
  prevCursor,
  nextCursor,
  datasetVersion,
  queryError,
  stale
}

interactionState = {
  openMenu: null | {
    recordId,
    triggerId,
    focusedActionId,
    actionPolicyRevision
  },
  focusIntent: {
    sourceEvent,
    recordId?,
    columnId?,
    controlId?,
    fallbackId
  }
}

operationState = {
  operationId,
  operationGeneration,
  operationSnapshotId,
  recordId,
  actionId,
  phase,
  result,
  error
}

lifecycleState = "live" | "disposed"
```

`openMenu` 与单行操作阶段的局部枚举属于实现细节，不得用来绕过查询、操作或生命周期提交门禁。

状态写入严格分离：

- 查询响应只能写查询结果、游标、版本、查询错误和查询阶段。
- 菜单开关、菜单焦点和焦点意图只由交互 owner 写入。
- 单行操作错误归对应行或专用单行操作结果区，不得写入 `queryError`。
- 权限 owner 只提交权限解析结果；它不能直接伪造查询成功或操作成功。

## 3. 查询快照与游标分页

每次首次加载、上一页、下一页、显式刷新、重试、权限读取范围变化或失效游标恢复，都先创建不可变快照：

```ts
querySnapshot = {
  snapshotId,
  appliedFilters: {},
  sortRules: [
    { key: "updatedAt", direction: "desc", nulls: "last", compare: "utc-epoch" },
    { key: "recordId", direction: "asc", compare: "ascii-code-point" }
  ],
  pagination: {
    mode: "cursor",
    direction: "initial" | "previous" | "next" | "refresh",
    cursor?: "opaque-server-token"
  },
  pageSize: 25,
  readPermissionScope,
  datasetVersion?,
  reason
}
```

随后将 `requestGeneration` 严格加一。响应只有同时满足以下条件才能提交：

1. 实例仍为 `live`；
2. `ownerId` 匹配；
3. `lifecycleToken` 匹配；
4. `requestGeneration` 匹配；
5. `snapshotId` 匹配。

取消请求只用于节省资源，不能代替门禁。任何迟到、被替代或取消失败的响应只记录为 discarded，不得改 DOM、状态、焦点或 live region。

分页规则：

- 只显示“上一页”和“下一页”，只使用服务端返回的不透明 `prevCursor`、`nextCursor`。
- 缺少对应游标时，该方向使用原生 `disabled`。
- 不显示总页数、页码、随机跳页、加载更多或滚动自动请求。
- 同一导航请求在途时拒绝重复点击、Enter、Space 和事件重放，不预测尚未返回的下一游标。
- 用户触发翻页后，旧页可以在加载期间保留，但必须明确显示“正在加载下一组/上一组记录”，不能冒充目标结果。
- 匹配响应提交后，只移动一次焦点到结果摘要，并播报“已显示下一组 25 条记录”等真实信息，不虚构页号。
- 服务端判定游标失效时，只允许一次恢复：使用服务端给出的最近有效前向位置；没有该位置则回到初始游标。重复失效响应不得形成循环。
- 若页间 `datasetVersion` 不一致，立即使整条分页链失效、停止继续导航并回到初始游标重新建立链。
- 服务端若不提供一致数据版本或等价快照能力，产品不得承诺跨页绝无重复或遗漏。

显式刷新使用当前已提交查询上下文。同一在途刷新意图必须在创建新快照前合并，不增加代次、请求或公告；权限范围等导致意图键变化时，即使旧刷新仍在途，也必须创建新快照并淘汰旧响应。

## 4. 加载、刷新、错误与空状态

| 状态 | 呈现与恢复 |
| --- | --- |
| 首次加载 | 无可用结果时显示与最终结构相符、不可操作的骨架；结果容器 `aria-busy="true"` |
| 首次失败 | 进入 `initial-error`，用结果区域内的错误文本和“重试加载记录”按钮替代表格；重试创建新快照和新代次 |
| 刷新中 | 保留上次成功的行、游标和焦点意图，显示刷新状态，结果容器 `aria-busy="true"` |
| 刷新失败 | 保留旧行和当前游标，进入 `refresh-error`、`stale=true`；显示“刷新失败，当前数据可能已过期”及重试按钮 |
| 空数据集 | 显示“尚无记录”；只有另行配置且有权限时才能展示“新建”入口，不能从 `row-action` 档位推导创建权限 |
| 操作成功后刷新失败 | 操作成功仍是成功；另显示“操作已成功，但列表刷新失败，当前显示可能未更新”，只重试查询，不重复执行操作 |
| 操作失败 | 错误留在该记录的操作结果 owner，查询区域不显示同一完整错误 |

读取权限收窄属于安全边界：必须立即移除不能证明仍可见的旧记录。若无法逐行证明，先清空全部旧结果，再以新权限范围重新加载；即使刷新失败也不得恢复可能已越权的数据。仅操作权限变化而读取范围不变时，不发查询。

## 5. 行菜单

同一表格实例最多打开一个行菜单。桌面与移动端均由显式按钮打开，不依赖 Hover、长按或滑动。

触发器：

```html
<button
  aria-label="打开记录 Alice 的操作菜单"
  aria-haspopup="menu"
  aria-expanded="true|false"
  aria-controls="row-menu-r123">
</button>
```

弹层使用单一 `role="menu"`，名称包含记录身份；项目使用 `role="menuitem"`。禁止权限对应的项目不渲染；因记录状态暂不可执行但仍需解释的项目使用 `aria-disabled="true"`，保持可聚焦并通过 `aria-describedby` 说明原因，激活时不产生请求。

打开时冻结当前 `{recordId, actionPolicyRevision}`，但实际激活项目时必须再次同步校验当前权限和记录状态，不能仅相信打开菜单时的结果。

菜单关闭与焦点策略：

| 原因 | 行为 |
| --- | --- |
| Escape | 关闭并仅一次返回原触发器 |
| 再次激活触发器 | 关闭，焦点保留在触发器 |
| Tab / Shift+Tab | 关闭，由浏览器继续到自然的下一/上一控件，不强行返回触发器 |
| 点击菜单外 | 关闭，焦点保留在用户点击的目标，不抢焦点 |
| 激活普通命令 | 关闭；触发器仍存在时返回触发器，再开始命令反馈 |
| 激活导航项 | 关闭并进入目标路由，不返回旧触发器 |
| 记录被刷新移除 | 关闭，按稳定记录焦点回退策略迁移一次 |
| 权限移除当前项目 | 保留菜单时聚焦同位置的下一可用项，否则上一项；没有可用项则关闭 |
| 权限降为 `display` | 先关闭菜单并移除全部行操作；若焦点位于菜单或触发器，迁移到同记录详情链接，再到同列最近记录，最后到结果摘要 |
| route/unmount | 立即 disposal，不执行返回焦点 |

刷新过程中，只要记录和锚点仍存在，菜单可以保持打开；成功响应提交时按稳定 `recordId` 和 `actionId` 原子重整项目。原项目仍存在则保持焦点；项目消失才按上述策略迁移。刷新失败保留旧行和菜单，但结果区域必须标明数据可能过期，命令提交仍须服务端校验记录版本与权限。

## 6. 单行命令与权限竞态

导航项不建立命令请求。命令项在提交前建立不可变操作快照：

```ts
operationSnapshot = {
  ownerId,
  lifecycleToken,
  operationId,
  operationGeneration,
  operationSnapshotId,
  recordId,
  actionId,
  actionPolicyRevision,
  permissionScope,
  recordVersion,
  idempotencyKey
}
```

进入 `submitting/in-flight` 后，点击、Enter、Space 或事件重放不得创建第二请求。响应提交需要：

`live + ownerId + lifecycleToken + operationId + operationGeneration + operationSnapshotId`

六项全部匹配。

操作权限在请求在途期间发生变化时：

- 立即移除新操作入口，但不能宣称已经撤销服务端命令。
- 已提交命令不得自动使用旧幂等键重试。
- 服务端若返回权限冲突，显示“权限已变化，操作未执行”，不提供越权重试。
- 服务端若返回版本冲突，使旧快照失效，刷新该记录并要求用户重新发起。
- 若无法确认服务端是否执行，进入明确的“结果待核对”状态；保留核对入口，不自动重试。
- 已成功的命令触发一次新查询快照刷新；刷新不能重复执行该命令。
- 权限变化不能使旧响应重新渲染已撤销的菜单项。

## 7. 键盘操作

原生表格不接管方向键、Home、End、Page Up 或 Page Down；静态单元格不设置 `tabindex="0"`。Tab 只进入详情链接、行菜单按钮、分页和错误恢复按钮。

行菜单键盘模型：

- `Enter`、`Space`：打开菜单并聚焦第一个可用项目。
- 触发器上的 `ArrowDown`：打开并聚焦第一个可用项目。
- 触发器上的 `ArrowUp`：打开并聚焦最后一个可用项目。
- 菜单内 `ArrowDown` / `ArrowUp`：在项目间移动；到边界后循环属于本实现选定策略。
- `Home` / `End`：移动到首个/末个项目。
- `Enter` / `Space`：激活当前项目；`aria-disabled` 项不执行。
- `Escape`：关闭并返回触发器。
- `Tab` / `Shift+Tab`：关闭并离开菜单。

翻页按钮、刷新和重试均使用原生按钮键盘语义。触摸、鼠标和键盘触发同一意图时，必须产生相同状态转换和相同请求数量。

## 8. 焦点管理

焦点恢复必须使用稳定的 `recordId + columnId + controlId`，禁止使用数组索引或第几个 DOM 子节点。

优先级统一为：

1. 同记录、同语义控制；
2. 同记录的等价控制，例如菜单触发器改为详情链接；
3. 同列最近一条记录的等价控制，优先下一条，其次上一条；
4. 可聚焦的结果摘要或列表标题；
5. 当前分页控制。

具体规则：

- 后台刷新不抢仍存活焦点。
- 行顺序变化时恢复同一 `recordId`，不能落到原索引的另一条记录。
- 翻页成功后只聚焦一次结果摘要；自动游标恢复不得再次抢焦点。
- 操作成功移除当前记录时，焦点只迁移一次到同列最近记录或结果摘要。
- 权限降级移除控件前先确定并聚焦等价目标，再移除旧控件。
- 若当前焦点本来不在被移除的菜单或行内，权限变化和刷新不得无故抢焦点。
- 最终焦点不得落到 `document.body`、文档根、已移除元素或另一表格的同名控件。

结果摘要可设 `tabindex="-1"` 供程序化恢复，但不进入正常 Tab 顺序。

## 9. ARIA 与公告

桌面表格：

- 使用原生 `<table>`，以 `<caption>` 或 `aria-labelledby` 提供唯一名称。
- 列头使用 `<th scope="col">`；记录身份单元格可使用 `<th scope="row">`。
- 操作列表头有可读名称“操作”。
- 固定排序没有排序按钮；主排序表头可用可访问说明表达固定排序，但不得伪造可点击控件。
- 分页放入 `<nav aria-label="记录分页">`。
- 结果容器在查询期间设置 `aria-busy="true"`。

公告只由各自 primary owner 发出：

- 查询开始、结果位置变化、失效游标恢复和查询失败，各公告一次。
- 权限变化只有在实际改变当前活动菜单或焦点路径时，由交互 owner 简短公告一次“可用操作已更新”。
- 单行操作开始、成功、失败、权限冲突、版本冲突或结果待核对，各由操作结果 owner公告一次。
- 被合并、淘汰、迟到、disposal 后到达或静默失效的事件不公告。
- 同一完整错误不得同时出现在行、结果摘要和全局 live region。
- 公告不得朗读整行所有字段或全部菜单项目。

## 10. 桌面与移动端

桌面和平板横屏使用原生表格。记录身份、主要状态和操作列直接可定位；横向滚动只允许发生在表格容器，页面根不得横向溢出。

窄屏采用显式配置的卡片映射：

- 根使用具名称的列表，每张卡片拥有包含记录身份的可访问名称。
- 记录身份和主要状态直接展示。
- 次要字段使用字段标签和值的明确关联，例如 `<dl>`。
- 每张卡片保留同一个详情入口和同一个行菜单入口。
- 不因移动端空间不足删除操作、错误恢复或分页。
- Table 与卡片任一时刻只能存在一个活动数据根，不能同时留在可访问性树中。
- 断点切换保留同一 `ownerId`、查询、游标、菜单意图、焦点意图和在途操作，不新增请求或重放命令。
- 打开菜单能找到等价卡片锚点时，单一 popup 重新定位；找不到时关闭并迁移一次焦点，不能留下悬空 popup 或 ARIA 引用。

移动端仍使用按钮打开菜单，不提供仅滑动或长按可达的操作。触摸目标按产品阈值至少达到约 44×44 CSS px，并处理动态视口、虚拟键盘和四向安全区域。

在 200% 缩放下，核心任务不能要求页面和表格同时双向滚动。长记录名、翻译扩展和字体放大不得使记录身份、错误含义或菜单按钮名称不可读。

## 11. Route/unmount disposal

路由提交离开或表格 owner 卸载时，实例同步、幂等地进入 `disposed`，不等待菜单动画、查询或命令结果。进入后拒绝新的查询、分页、菜单、焦点、操作和公告工作。

处置顺序：

1. 将 `live=false`，使全部提交门禁立即失败。
2. 中止或失效查询、分页恢复、查询重试、防抖和预取。
3. 对已提交命令尝试中止传输仅用于节省资源；不得把本地中止描述成服务端操作已取消。
4. 关闭菜单并立即移除 portal，不播放退出动画。
5. 取消菜单定位任务、`requestAnimationFrame`、类型搜索计时器和待执行焦点任务。
6. 注销 document 外部点击、keydown、scroll、resize 监听器。
7. 断开 `ResizeObserver`、`IntersectionObserver`、`MutationObserver`。
8. 取消权限、数据、路由和媒体查询订阅。
9. 失效待发送的 live-region 公告及其他微任务回调。
10. 移除当前实例 DOM、popup、`aria-controls` 等引用。
11. 每项资源按其 `ownerId` 只释放一次，不影响同页其他表格。

disposal 不向即将移除的菜单触发器返回焦点。新路由提交后，只能由新路由自己的焦点策略移动一次到页面主标题、主内容容器或首个主要操作。

返回列表时创建全新的 `ownerId` 和 `lifecycleToken`。恢复前重新验证读取权限、数据版本和游标有效性；验证通过才恢复查询与滚动。旧权限结果、菜单、焦点 DOM 引用、单行操作快照和命令结果一律不回放。旧游标失效时从初始游标重新加载。

## 12. 实现检查清单

| 规则族 | 适用性 | 实现依据 |
| --- | --- | --- |
| 能力与状态 | 适用 | 显式 `row-action`，权限可降为 `display`，四类状态 owner 分离 |
| 查询 | 适用 | 不可变快照、代次及五项响应门禁 |
| 筛选 | 不适用 | 无筛选 DOM、可变筛选状态、handler 或请求入口；协议值固定为空 |
| 排序 | 适用 | 固定 `updatedAt DESC NULLS LAST, recordId ASC`，无伪交互按钮 |
| 分页 | 适用 | 唯一 cursor 模式、固定 25 条、双向不透明游标、单次失效恢复 |
| 数据状态 | 适用 | 首次/刷新加载与错误、过期、空数据集分别处理 |
| 选择与批量操作 | 不适用 | 无选择列、选择状态、全选 handler 和批量工具栏 |
| 单行操作 | 适用 | 独立操作快照、幂等、重复提交保护和六项门禁 |
| 列显示/固定/调宽 | 不适用 | 对应控件、状态和 handler 均不存在 |
| Table/Grid 与键盘 | 适用 | 原生 Table；不启用二维 Grid 导航 |
| 焦点 | 适用 | 稳定 ID、单次迁移、明确 fallback |
| 响应式 | 适用 | 表格与已评审卡片映射等价，单一活动数据根 |
| ARIA/公告 | 适用 | Table、menu、分页、busy、错误与公告 owner 明确 |
| Disposal/实例隔离 | 适用 | owner/token 隔离，资源按实例幂等释放 |
| 运行时验证边界 | 适用 | 下列项目必须在真实环境继续验证 |

## 13. 尚未通过真实运行环境验证的边界

以下仍为未验证，不能视为已经通过：

- Chrome、Safari、Firefox 中菜单的 Enter、Space、方向键、Tab、Escape 与焦点返回顺序。
- VoiceOver、NVDA、JAWS 对原生表格、菜单、`aria-disabled` 原因、busy、过期和公告去重的实际朗读。
- 真实接口的不透明前后游标、游标失效恢复、数据版本变化以及跨页重复/遗漏行为。
- 刷新失败、操作成功但刷新失败、操作结果待核对等组合状态。
- WebSocket/SSE 权限推送与打开菜单、点击项目、请求在途、刷新提交同时发生的竞态。
- 路由卸载时网络中止失败和所有迟到回调的门禁效果。
- 同页两个列表具有相同控件名称时的状态、焦点、portal 和资源释放隔离。
- `1440×900`、`1280×720`、平板横竖屏、`390×844` 窄屏及低高度横屏手机的布局和菜单定位。
- 200% 浏览器缩放、系统字体放大、长记录名、长翻译、高对比度和 Reduced Motion。
- 动态浏览器工具栏、虚拟键盘、四向 safe-area、触摸目标及表格到卡片实时转换。
- 打开菜单时滚动容器、窗口缩放、记录移除或锚点更换后的定位、关闭和单次焦点恢复。
- 返回页面时权限、数据版本与旧游标的真实重新验证路径。
<!-- END RAW OUTPUT -->
