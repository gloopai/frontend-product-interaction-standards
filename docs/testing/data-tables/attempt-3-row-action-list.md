# Attempt 3 FAILED：单行操作管理列表

## 派发与完成元数据

- 实际 spawn args 恰为 `task_name=attempt_3_row_action_list`、`fork_turns=none` 和 `message`；`message` 是下方 RAW PROMPT 的逐字内容。
- `model` 与 `reasoning_effort` 均未发送。
- 精确 spawn tool return：`{"task_name":"/root/table_task5_green/attempt_3_row_action_list"}`
- 精确 completion envelope metadata：`Message Type FINAL_ANSWER`；recipient `Task name /root/table_task5_green`；`Sender /root/table_task5_green/attempt_3_row_action_list`。

## 原始提示

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个带 row-action 的管理列表。它使用游标分页，需要处理刷新失败、行菜单、焦点恢复、权限变化和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配，以及请求、菜单、焦点与其他资源在 disposal 时如何处理；同时列出尚未通过真实运行环境验证的边界。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

## 原始完成输出

<!-- BEGIN RAW OUTPUT -->
# Row-action 管理列表交互设计

## 一、能力声明与边界

| 项目 | 设计决定 |
| --- | --- |
| `capabilityTier` | 固定为 `row-action` |
| `resolvedTier` | 默认 `row-action`；单行操作权限全部撤销但仍可读时降为 `display`；列表读取权限撤销时由页面权限层替换列表并立即 disposal |
| 筛选 | 不启用；不得保留隐藏筛选 DOM、状态、handler 或请求入口 |
| 排序 | 启用固定排序，不提供交互式排序按钮：`updatedAt DESC NULLS LAST, recordId DESC`；时间按 UTC 比较，`recordId` 为不可变唯一键并按服务端字节序比较 |
| 分页 | 只使用 `cursor`；固定 `pageSize=20`，仅“上一页/下一页”，不显示或推断总页数 |
| 单行能力 | 记录名称提供独立详情链接；次要操作进入行菜单 |
| 选择与批量 | 不启用复选框、表头全选、全部筛选结果选择及批量工具栏 |
| 列能力 | 不启用用户列显示、固定、调宽、拖拽排序和布局持久化 |
| 响应式 | 显式启用 `table-to-card`：桌面为原生表格，窄屏为经过配置的卡片映射，任一时刻只有一个活动数据根 |
| 页面返回 | `returnRestorePolicy=query-and-scroll`：只在重新校验权限、数据版本和游标位置后恢复查询与滚动；菜单、旧权限结果和未完成操作不得恢复 |

第一版不包含行内编辑、树形层级、拖拽行排序、透视、加载更多、无限滚动或虚拟化。破坏性行操作不得由菜单项直接提交，菜单只建立操作意图，后续必须接入符合风险等级的显式确认流程。

整行不得作为链接或点击目标。详情链接和菜单触发器分别激活各自行为，避免点击菜单时同时导航。

## 二、状态与 owner

每个实例创建不可复用的 `ownerId` 和 `lifecycleToken`，状态分为四个独立 owner：

| 状态组 | 最少字段 |
| --- | --- |
| `queryState` | `permissionScope`、`permissionVersion`、固定 `sortRules`、`pagination:{mode:"cursor",position,prevCursor,nextCursor}`、`pageSize`、不可变 `querySnapshot`、`snapshotId`、`datasetVersion?`、`requestGeneration`、`requestPhase`、`queryError`、`stale`、`recoveryAttempted` |
| `viewState` | 当前行、结果摘要、桌面/卡片表现形态、滚动恢复信息 |
| `interactionState` | `openMenuRecordId?`、`activeMenuActionId?`、`focusIntent`、当前 `recordId/columnId/controlId` |
| `operationState` | `idle/confirming/submitting/succeeded/failed/permission-conflict/outcome-unknown`、不可变 `operationSnapshot`、`operationId`、`operationGeneration`、幂等键、行级错误及恢复入口 |

查询错误只写入结果 owner；单行操作错误只写入对应记录的操作 owner；菜单定位错误不伪装成查询失败。每个错误使用稳定 `errorId`，只能有一个完整错误展示和一条完整公告路径。

## 三、查询、游标与状态转换

每次合法查询先冻结不可变快照：

```text
querySnapshot = {
  ownerId,
  lifecycleToken,
  snapshotId,
  requestGeneration,
  permissionScope,
  permissionVersion,
  sortRules,
  paginationMode: "cursor",
  positionCursor,
  pageSize: 20,
  datasetVersion?
}
```

响应只有同时满足以下五项才能提交：实例仍 live、`ownerId` 匹配、`lifecycleToken` 匹配、`requestGeneration` 为当前代次、`snapshotId` 为当前快照。取消请求只节省资源，不能替代此门禁。

主要转换如下：

| 事件 | 转换 |
| --- | --- |
| 首次进入 | `idle → initial-loading → ready / initial-error` |
| 显式刷新 | `ready/refresh-error → refreshing → ready/refresh-error` |
| 同一在途刷新意图重复触发 | 创建快照前合并；不增加代次、不新增请求、不重复公告 |
| 权限范围、游标位置或刷新原因变化 | 建立新快照、代次加一；即使旧请求仍在途也发新请求 |
| 下一页/上一页 | 使用当前已接受响应提供的对应游标建立新快照 |
| 方向游标缺失 | 对应原生按钮 `disabled`，请求数为零 |
| 当前游标失效 | 只执行一次服务端建议的最近有效前向位置恢复；没有建议则回到初始游标 |
| 页间 `datasetVersion` 不一致 | 标记 `stale`，停止继续导航，并从初始游标重新建立分页链 |
| 路由离开或 owner 卸载 | 任意状态立即进入 `disposed`，不再接受新工作 |

游标视为不透明值，不解析、不拼接、不写入日志。界面不得展示虚构页码、总页数、随机跳页、“加载更多”或滚动触发请求。

服务端提供不可变 `datasetVersion` 时，才可承诺同一分页链跨页无重复遗漏。没有版本能力时，只能保证固定排序请求一致；检测到页间变化后必须使链失效，不能继续将不同版本页面当作完整集合。

## 四、加载、错误、刷新与空状态

- `initial-loading`：无可用结果时显示与最终列结构相符的不可操作骨架；结果容器设置 `aria-busy="true"`，骨架中不得出现可点击链接、按钮或假数据。
- `refreshing`：保留上次成功的行、游标上下文和焦点意图，显示“正在刷新”，并设置 `aria-busy="true"`。旧行须明确属于上次成功结果，不能被标记为新结果。
- `initial-error`：无可用结果时以结果区域内的文本错误和可聚焦“重试加载”按钮替代表格；重试必须建立新快照和新代次。
- `refresh-error`：保留旧行和分页上下文，设置 `stale=true`，在结果区域显示“刷新失败，当前数据可能已过期”及“重试刷新”。不得清空表格、重置游标或移动仍有效的焦点。
- 空数据集：由于本实例不启用筛选，零结果只使用“当前没有记录”的数据源空状态，可提供与当前权限相符的创建入口；不得显示“当前条件无匹配”。以后启用筛选时，必须另行增加筛选零结果状态，不能复用此文案。
- 权限读取范围缩小时，不得继续展示可能已无权查看的旧行。能够由本地权限结果确定的行立即移除；无法确定时保留 `refreshing`，用不可操作的“权限范围变化，正在重新加载”占位替换潜在敏感结果。

查询开始、已接受且改变结果位置的成功、失败和游标恢复分别由结果 owner 简短公告一次。合并请求、迟到响应、disposal 后响应不得公告。

## 五、行菜单与单行操作

每条有至少一个当前可用操作的记录渲染真实 `<button>`：

```text
aria-label="打开〈记录名称〉的操作菜单"
aria-haspopup="menu"
aria-expanded="true|false"
aria-controls="row-menu-{ownerId}-{recordId}"
```

菜单规则：

- 同一表格最多打开一个菜单；打开另一行菜单时先同步关闭前一个。
- 菜单项来自最新的 `permissionVersion + recordId + rowVersion`，不由前端页面名称或后端偶然字段猜测。
- 菜单以单一 `role="menu"` 呈现，每项使用真实按钮并设置 `role="menuitem"`；项目名称必须描述具体动作和对象。
- 菜单可使用 portal，但 portal、锚点、定位任务和 ARIA 引用都归当前 `ownerId`。
- 点击外部关闭菜单但不抢夺用户刚点击目标的焦点；`Escape` 关闭并恢复到触发器。
- 激活导航类操作后关闭菜单，由新路由的焦点策略管理焦点；不得把焦点送回即将卸载的触发器。
- 激活写操作时先关闭菜单，再冻结不可变 `operationSnapshot`，至少包含 `recordId`、`rowVersion`、`actionId`、权限范围及版本、数据版本、`operationId`、操作代次和快照 ID；请求携带本次尝试的幂等键。
- `submitting` 期间点击、Enter、Space 和事件重放均不得产生第二请求。客户端取消不代表服务端取消，界面不得宣称操作已撤销。
- 操作响应使用统一六项门禁：`live + ownerId + lifecycleToken + operationId + operationGeneration + operationSnapshotId`。失配响应只记录丢弃，不写 DOM、状态、焦点或 live region。
- 操作成功后建立新查询快照刷新受影响数据；失败信息归该记录的操作结果区，并提供有名称的恢复或重试入口。
- 返回结果缺少完整记录身份、版本或明确终态时进入 `outcome-unknown`，保留操作快照，显示“核对最新状态”，不得当作成功或安全重试。

### 权限变化

权限更新作为原子提交处理：

1. 先更新 `permissionVersion` 和 `resolvedTier`。
2. 立即移除所有越权菜单项、事件 handler 和旧操作入口。
3. 若焦点所在菜单项失权，焦点只移动一次到同菜单最近的仍可用项；若无可用项，关闭菜单并恢复到同记录触发器。
4. 若触发器也因无操作而移除，依次迁移到同记录详情链接、同列最近记录的操作触发器、结果摘要。
5. 全局单行操作权限全部撤销时，`resolvedTier` 降为 `display`，关闭菜单并清空菜单交互状态，不保留空操作列。
6. 权限范围变化形成新的查询意图；旧权限请求即使随后返回也不得提交。
7. 权限在写操作途中变化时，使旧操作代次失效，进入可区分的权限冲突状态，刷新最新记录并要求重新确认；不得自动重试或复用旧幂等键。

## 六、键盘与焦点

本列表使用原生 `<table>`，不使用 ARIA Grid，因此不接管方向键、Home、End、Page Up 或 Page Down。静态单元格不设置 `tabindex="0"`；Tab 只经过详情链接、菜单触发器、错误恢复及分页按钮，并与视觉任务顺序一致。

行菜单键盘模型：

- 触发器 `Enter`、`Space` 或 `ArrowDown`：打开并聚焦第一项。
- 触发器 `ArrowUp`：打开并聚焦最后一项。
- 菜单内 `ArrowDown/ArrowUp`：移动到下一项/上一项并在首尾循环。
- `Home/End`：移动到首项/末项。
- 可打印字符：按当前可见标签执行首字符查找。
- `Enter/Space`：只激活当前项一次。
- `Escape`：关闭并返回原触发器。
- `Tab/Shift+Tab`：关闭菜单并继续到逻辑上的下一个/上一个页面控件，不形成焦点陷阱。
- Hover、长按、滑动和精确指针不得成为打开或发现菜单的唯一方式。

`focusIntent` 使用稳定的 `{sourceEvent, recordId?, columnId?, controlId?, fallbackId}`，不得使用行索引。刷新后精确目标仍存在、可聚焦且语义未变时不移动焦点；目标消失时依次尝试：

1. 同记录的等价控件；
2. 同列最近记录的等价控件；
3. 结果摘要或标题；
4. 当前分页控件。

最终目标必须存活、可见、有名称，不能是 `document.body`、文档根或已移除节点。每个用户意图最多发生一次最终焦点迁移。

翻页响应被接受后，焦点移动一次到结果摘要/标题；游标失效后的自动恢复不得再次抢焦点。刷新失败不移动仍有效的焦点。操作删除当前记录时，焦点移动一次到操作结果摘要或刷新后的结果摘要。路由离开时不恢复旧菜单触发器，由新路由在提交后聚焦主标题、主内容或主要操作一次。

## 七、DOM 与 ARIA

桌面结构采用原生语义：

```html
<section aria-labelledby="records-title" aria-describedby="records-summary">
  <h1 id="records-title">…</h1>
  <div id="records-summary" tabindex="-1">…</div>
  <div aria-busy="false">
    <table>
      <caption>…</caption>
      <thead>…<th scope="col">操作</th></thead>
      <tbody>…</tbody>
    </table>
  </div>
  <nav aria-label="记录分页">…</nav>
</section>
```

记录身份列优先使用 `<th scope="row">`；各列头使用 `<th scope="col">`。固定排序不渲染排序按钮，也不伪造 `aria-sort`。表格、结果摘要、分页和每个行菜单都必须具有可区分的名称。

结果容器的加载、过期和错误状态必须有可感知文本，不能只靠颜色、旋转图标或位置。使用一个由结果 owner 管理的礼貌型 live region 公告查询状态；行操作错误由行操作 owner 公告，不能在全局区域重复朗读完整错误。

## 八、桌面与移动端

桌面及空间足够时使用原生表格。断点由记录身份、主要状态和菜单触发器无法保持可用的内容宽度决定，不按设备名称判断。

窄屏使用显式卡片映射：

- 卡片根为有名称的列表，每张卡片具记录级可访问名称。
- 直接展示记录身份、主要状态、详情链接和行菜单。
- 次要字段采用固定顺序的 `<dl>` 或等价标签—值关联。
- 不得仅以 `display:none` 隐藏仍需访问的字段或操作。
- 触摸目标采用产品配置的至少 `44×44 CSS px`，关键操作不依赖精确点击。
- 低高度、虚拟键盘、动态浏览器工具栏和四向安全区域下，结果、错误、菜单和分页均能滚动到达。
- 200% 浏览器缩放及字体放大时，不得形成页面与数据容器同时双向滚动的关键流程；长名称和翻译扩展不得丢失记录身份或操作含义。

实时断点切换保持同一 `ownerId`、查询快照、游标、操作快照和焦点意图，不新增请求或重放操作。若打开菜单的同记录等价触发器存在，则复用同一菜单实例、重新锚定并保持当前动作；不存在等价锚点时关闭菜单，并只进行一次记录级焦点迁移。表格和卡片不得同时作为两个活动实例存在。

## 九、disposal 与资源释放

路由提交离开或 owner 卸载时立即、同步且幂等地执行：

1. 标记 `disposed=true`，使当前 `lifecycleToken` 失效；拒绝新的查询、分页、菜单、操作、焦点和公告任务。
2. 中止或失效查询、显式刷新、游标恢复、重试、防抖和单行操作客户端请求；服务端操作是否完成保持未知，不能伪装成已取消。
3. 无动画关闭行菜单，移除 portal，取消定位用的 animation frame、计时器、`ResizeObserver`、滚动/尺寸监听和外部点击/键盘监听。
4. 失效所有待执行焦点微任务、焦点恢复、live-region 公告和操作结果回调。
5. 注销权限订阅、路由订阅及当前实例的其他观察器和事件监听。
6. 移除本实例 DOM、popup 和相关 ARIA 引用；不访问已移除触发器。
7. 每项资源按 `ownerId` 只释放一次，不得影响同页其他列表或随后创建的新实例。

所有迟到查询仍执行五项查询门禁，迟到操作仍执行六项操作门禁；取消成功也不绕过门禁。新路由只能由自身焦点策略移动焦点一次。

同页多实例可以拥有相同数值的请求或操作代次，但必须在各自 `ownerId + lifecycleToken` 命名空间解释；菜单、错误、公告、焦点恢复和资源释放均不得跨实例。

## 十、实现适用性清单

| 规则族 | 结论与依据 |
| --- | --- |
| 能力与状态 | 适用：显式 `row-action`，只建立单行操作状态 |
| 查询 | 适用：不可变快照、代次及五项提交门禁 |
| 筛选 | 不适用：无筛选 DOM、状态、handler、URL 参数或请求入口 |
| 排序 | 适用：固定稳定排序；无排序按钮和交互事件 |
| 分页 | 适用：唯一 `cursor` 模式、方向边界、一次失效恢复和单次焦点策略 |
| 数据状态 | 适用：首次加载、刷新、初错、刷新错、过期和空数据集 |
| 选择 | 不适用：无选择状态、选择控件或选择 handler |
| 操作 | 单行操作适用；批量操作不适用 |
| 列能力 | 基本列语义适用；用户显示、固定、调宽和排序不适用 |
| Table/Grid 与键盘 | 原生 Table 适用；ARIA Grid 不适用，因无二维单元格导航需求 |
| 焦点 | 适用：稳定记录 ID、菜单恢复、翻页、权限变化和路由迁移 |
| 响应式 | 适用：显式 Table/Card 等价映射 |
| ARIA 与公告 | 适用：表格、菜单、状态、错误和一次公告 owner |
| disposal 与实例隔离 | 适用：请求、菜单、焦点、订阅及 portal 资源均归实例 |
| 运行时验证 | 尚未执行，不能标记为通过 |

## 十一、尚未通过真实运行环境验证的边界

以下仍需在真实组件、路由、权限服务和接口环境中验证：

- 游标 API 的 `prev/next`、失效游标恢复、`datasetVersion` 与固定排序契约。
- 请求取消失败、乱序响应、重复事件、旧权限响应及路由卸载后回调的门禁。
- 菜单在 portal、横向滚动、窗口缩放、断点切换和锚点移除时的定位与焦点恢复。
- 菜单打开期间撤销当前动作、撤销全部行操作权限，以及写操作途中权限变化。
- 刷新失败保留旧行、记录删除、游标失效恢复和返回页面恢复时的单次焦点行为。
- NVDA/Firefox、JAWS/Chrome、VoiceOver/Safari 与 TalkBack/Chrome 下的 Table、Menu、`aria-busy`、错误及 live-region 公告。
- 键盘完整路径，包括 Tab、Shift+Tab、方向键、Home/End、Enter、Space、Escape 和字符查找。
- 鼠标、触摸与键盘触发同一意图时的请求数和终态一致性。
- `1440×900`、`1280×720`、平板横竖屏、窄屏手机、低高度横屏、200% 缩放、字体放大、长翻译、虚拟键盘、动态视口和四向安全区域。
- 浏览器后退恢复查询/滚动时的权限、版本和游标重新校验，以及稳定来源记录的焦点回落。
- 同页两个列表的菜单、公告、代次、迟到响应和资源释放隔离。
- 客户端 abort 与服务端实际执行之间的差异、幂等键去重，以及 `outcome-unknown` 的人工核对流程。
<!-- END RAW OUTPUT -->
