# Attempt 8 Display Report Evidence

## Actual spawn args

```text
task_name=attempt_8_display_report
fork_turns=none
model/reasoning_effort not sent
```

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个只读数据报表。它需要支持筛选、稳定排序、页码分页和长内容；还必须能在浏览器 200% 缩放及移动端查看。请说明该报表的能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端行为，以及哪些结论尚未通过真实运行环境验证。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

## Exact spawn tool return

```json
{"task_name":"/root/table_task5_final_takeover/attempt_8_display_report"}
```

## Completion metadata

```text
Message Type FINAL_ANSWER
recipient /root/table_task5_final_takeover
sender /root/table_task5_final_takeover/attempt_8_display_report
```

<!-- BEGIN RAW OUTPUT -->
# 只读数据报表实现设计

## 1. 能力声明

本实例固定为只读展示档位：

- `capabilityTier=display`
- `resolvedTier=display`
- 仅提供查询、展示、排序和导航。
- “展开完整字段”是本地展示行为，不是单行业务操作，不产生业务请求。

| 能力字段 | 当前值 |
| --- | --- |
| `filteringEnabled` | `enabled` |
| `sortingEnabled` | `enabled`，单列排序，仅“更新时间” |
| `paginationMode` | `numbered` |
| `pageSize` | `25`，允许切换 `25/50/100` |
| `pageSelectionEnabled` | `false` |
| `allFilteredSelectionEnabled` | `false` |
| `rowOperationEnabled` | `false` |
| `bulkOperationEnabled` | `false` |
| `columnVisibilityEnabled` | `false` |
| `columnPinningEnabled` | `false` |
| `columnResizeEnabled` | `false` |
| `responsivePresentation` | `table-priority-details`：原生 Table 加优先级字段和行详情，不转换为卡片 |

`table-priority-details` 是本实例的产品配置值，不新增通用枚举：桌面展示完整列；窄屏及 200% 缩放时保留“记录、状态、更新时间、详情”列，其余字段进入同一记录的带标签详情区域。

### 能力边界

本版不提供：

- 行内编辑、选择、全选、批量操作、单行业务操作；
- 树表、透视表、拖拽行排序、加载更多、无限滚动；
- 用户列显示、固定、调宽、换序及个人布局持久化；
- 导出、保存视图或跨页草稿恢复。

页码分页要求服务端提供可靠总数。跨页无重复、无遗漏的保证还要求服务端提供不可变 `datasetVersion` 或等价查询快照；缺少该能力时，只能保证每次响应内部的确定性顺序，不得承诺动态数据集上的跨页完整性。

## 2. 数据结构与状态归属

### 2.1 报表字段

本实例采用以下稳定字段：

| `columnId` | 内容 | 桌面 | 窄屏 |
| --- | --- | --- | --- |
| `record` | `recordId` 与记录名称，身份列 | 直接显示 | 直接显示 |
| `status` | 状态 | 直接显示 | 直接显示 |
| `owner` | 负责人 | 直接显示 | 进入详情 |
| `updatedAt` | 更新时间 | 直接显示，可排序 | 直接显示，可排序 |
| `description` | 描述 | 摘要及“展开全文” | 进入详情 |
| `notes` | 备注 | 摘要及“展开全文” | 进入详情 |

`recordId` 必须唯一、不可变、规范化为大写 ASCII 标识。所有行状态、详情状态和焦点恢复都以该 ID 为依据，不使用数组索引。

### 2.2 固定四组状态

| 状态组 | 当前结构 |
| --- | --- |
| `queryState` | `defaultFilters`、`filterDraft`、`appliedFilters`、`sortRules`、`pagination:{mode:"numbered",page}`、`pageSize`、`querySnapshot`、`snapshotId`、`datasetVersion`、`requestGeneration`、`requestPhase`、`queryError`、`stale` |
| `viewState` | `visibleColumnIds=["record","status","owner","updatedAt","description","notes"]`、`pinnedColumnIds=[]`、固定 `columnWidths`、`density="comfortable"`、当前结果行、可靠总数和结果摘要；响应式布局不改变逻辑字段集合 |
| `interactionState` | `focusIntent:{sourceEvent,recordId?,columnId?,controlId?,fallbackId}`、当前 `recordId/columnId`、`expandedRecordIds`；选择、菜单和业务操作状态不实例化 |
| `operationState` | 仅保留明确的关闭契约；单行、批量两个子槽均不实例化 |

固定列宽初始值为：`record=280`、`status=120`、`owner=180`、`updatedAt=180`、`description=360`、`notes=360` CSS 像素。它们是布局输入，不是用户可调状态。

| operationKind | currentValue | stateSlot | DOM | handler/event | request |
| --- | --- | --- | --- | --- | --- |
| row | not-instantiated | 0 | 0 | 0 | 0 |
| bulk | not-instantiated | 0 | 0 | 0 | 0 |

### 2.3 生命周期保护

四组状态之外单独维护 `lifecycleGuard`：

```text
{
  ownerId,
  lifecycleToken,
  phase: "live" | "disposed",
  ownedResources: [
    queryAbortController,
    retryTasks,
    debounceTasks,
    scrollObserver,
    resizeObserver,
    pendingFocusTasks,
    pendingAnnouncementTasks
  ]
}
```

同页多份报表的 `ownerId`、`lifecycleToken`、DOM ID 和公告 owner 必须分别唯一。不同实例可以具有相同的数值型 generation，但只能在各自的 `ownerId + lifecycleToken` 命名空间内解释。

## 3. 查询能力

### 3.1 筛选

筛选区为具名称的原生 `<form>`，包含：

- 关键词：文本输入，最多 200 个字符；
- 状态：原生 `<select>`，值为 `all/active/inactive/archived`；
- 开始日期和结束日期：已提交业务值为 ISO 日期；
- “应用筛选”和“重置筛选”按钮。

所有筛选器均声明 `applyMode=explicit`。字段输入只更新字段 owner 和 `filterDraft`；只有完整校验通过并提交“应用筛选”后才更新 `appliedFilters`、回到第 1 页并发起查询。

默认值固定为：

```text
defaultFilters = {
  keyword: "",
  status: "all",
  startDate: null,
  endDate: null
}
```

重置恢复以上默认值；若其与当前 `appliedFilters` 语义相同，不创建请求。

字段错误由筛选字段或筛选表单 owner 负责，例如日期范围倒置、日期格式错误、关键词超长。错误紧邻字段，使用 `aria-invalid` 和稳定的 `aria-describedby`；字段错误不得写入 `queryError`。

已应用的非默认条件持续显示为具名称的条件摘要，并提供独立移除按钮，例如“移除筛选：状态为启用”。折叠筛选区时，已应用条件摘要仍保持可见。

URL 安全规则：

- `status`、`startDate`、`endDate` 标记为 `urlSafe`；
- `keyword` 按潜在敏感自由文本处理，不进入 URL、页面标题或分析日志；
- 未明确标记 `urlSafe` 的新增条件默认不得序列化。

### 3.2 稳定排序

默认且当前排序为：

```text
updatedAt DESC NULLS LAST,
recordId ASC
```

具体比较契约：

- `updatedAt` 转换为 UTC epoch 毫秒后进行数值比较；
- 空更新时间始终位于末尾；
- `recordId` 是唯一、不可变的稳定次序键，按大写 ASCII 字节序升序；
- `recordId` 比较区分大小写，但输入契约已要求规范化大写；
- locale 为 `und`/二进制排序，不使用区域文本比较；
- 自然排序关闭，即 `natural=false`。

只有“更新时间”列可排序。表头包含真实 `<button>`，在升序和降序间切换；其他列没有排序按钮，也不设置 `aria-sort`。当前表头的 `<th>` 设置 `aria-sort="ascending"` 或 `"descending"`，按钮名称描述下一动作，例如“按更新时间升序排列”。

提交新方向后回到第 1 页，冻结新快照并查询。请求开始不抢排序按钮焦点；匹配结果提交后按钮仍存在时保持焦点。

跨页查询必须携带首个接受页面的 `datasetVersion`。发现版本不一致时：

1. 将当前链标为 `stale`；
2. 禁止继续使用旧页链导航；
3. 显示“数据已变化，正在从第 1 页重新加载”；
4. 仅创建一次第 1 页恢复请求。

### 3.3 页码分页

服务端必须返回可靠 `totalCount`。界面显示：

- “第 X 页，共 Y 页”；
- “显示第 A–B 条，共 N 条”；
- 首页、上一页、直接页码、下一页、末页；
- 具可见标签的跳页输入及“跳转”按钮；
- 具名称的每页条数原生选择控件。

当前页使用 `aria-current="page"`。首页的首页/上一页、末页的下一页/末页使用原生 `disabled`。

跳页只接受 `1..totalPages` 内的整数。空值、小数、非数字和越界值显示字段错误、设置 `aria-invalid`，请求数为 0。输入框按 Enter 与点击“跳转”产生相同意图。

筛选、排序和页大小变化均回到第 1 页。普通直接翻页使用目标页。请求页超过最新末页时，只恢复一次到 `max(1, latestLastPage)`，成功后简短公告新位置；重复失效响应不得形成恢复循环。

窄屏仍保留首页、上一页、当前页附近页码、下一页、末页和跳页能力；省略的中间页码以非交互省略号表示，可通过跳页到达。

### 3.4 查询快照与竞态门禁

每次接受查询意图时先建立不可变快照：

```text
querySnapshot = {
  snapshotId,
  appliedFilters,
  sortRules: {
    key: "updatedAt",
    direction,
    nullOrder: "last",
    stableKey: "recordId",
    stableDirection: "asc",
    caseRule: "canonical-uppercase-binary",
    localeRule: "und",
    naturalOrder: false
  },
  pagination: { mode: "numbered", page },
  pageSize,
  permissionScope,
  datasetVersion
}
```

随后将 `requestGeneration` 严格加一并发送请求。响应只有同时满足以下条件才能写入：

```text
live
&& ownerId 匹配
&& lifecycleToken 匹配
&& requestGeneration 匹配
&& snapshotId 匹配
```

任一不匹配只记录 `response-discarded`，不得改变行、总数、错误、焦点、`aria-busy` 或 live region。取消请求只用于节省资源，不能替代上述门禁。

同一在途刷新意图根据筛选、排序、页码、页大小、权限、版本和刷新原因生成 `intentKey`；重复点击、Enter 或事件重放在创建快照前合并，不增加快照、代次、请求或公告。不同 `intentKey` 必须建立新请求，不能因另一个请求在途而被全局合并。

## 4. 状态转换与反馈

| 事件 | 转换 | 展示与恢复 |
| --- | --- | --- |
| 首次进入 | `idle → initial-loading` | 显示与最终列结构一致的非交互骨架，结果区 `aria-busy=true` |
| 首次成功 | `initial-loading → ready` | 提交行、总数、版本；解除 busy |
| 首次失败 | `initial-loading → initial-error` | 不渲染假表格；结果区显示完整错误和可聚焦重试 |
| 应用筛选、排序、翻页、页大小或刷新 | `ready → refreshing` | 保留旧行和焦点意图；明确标注“正在加载，新结果尚未返回” |
| 刷新成功 | `refreshing → ready` | 仅匹配响应替换结果，`stale=false` |
| 刷新失败 | `refreshing → refresh-error` | 保留旧行、分页和焦点，`stale=true`，显示“当前数据可能已过期”和重试 |
| 有筛选且总数为 0 | `ready`，`resultKind=filtered-empty` | 显示“当前条件无匹配”，提供调整和清除筛选 |
| 默认条件下总数为 0 | `ready`，`resultKind=dataset-empty` | 显示“当前数据源尚无记录”；只读档位不显示创建入口 |
| 页码失效 | 当前请求失效 | 只恢复一次到最新有效末页；最终结果只触发一次焦点移动 |
| 数据版本变化 | `ready/refreshing → stale` | 停止旧页链，回第 1 页建立新快照 |
| 路由提交或 owner 卸载 | `live → disposed` | 同步失效全部工作，不等待请求、动画或重试结束 |

首次加载骨架不得包含按钮、链接、选择控件或可操作假数据。

刷新期间旧行必须明确标识为“上次结果”；更新后的筛选摘要不能暗示旧行已经匹配新条件。

查询错误的完整文本只由结果区域拥有。筛选字段错误不复制到结果区；结果错误也不复制到筛选表单或全局提示。

## 5. 长内容、桌面和移动端

### 5.1 长内容

- 记录名称、ID、错误和字段值允许换行；长单词和无空格字符串使用 `overflow-wrap:anywhere`。
- 不通过单独的省略号、`title` 属性或 Hover 隐藏完整业务含义。
- 描述和备注可显示最多三行摘要，但同一单元格必须提供“展开记录 R-001 的完整字段”按钮。
- 按钮使用 `aria-expanded` 和 `aria-controls`；展开内容为同一表格中的详情行，内部使用 `<dl>/<dt>/<dd>` 保留字段标签、记录归属和固定顺序。
- 展开和折叠只改 `expandedRecordIds`，不发查询；焦点保持在触发按钮。
- 刷新后记录仍存在则保留展开状态；记录消失则清理该 ID，并按焦点策略迁移一次。

### 5.2 桌面

在 `1440×900` 和 `1280×720` 设计目标下，使用完整原生 Table。筛选区可多列排布，条件摘要位于筛选区与结果摘要之间。表格不设置内部垂直滚动；页面承担纵向滚动。

确有横向溢出时，只允许表格容器 `overflow-x:auto`，页面根不得产生横向溢出。容器仅在实际溢出时可聚焦，并具有“数据表格，横向滚动查看更多列”的名称及当前可滚动方向说明。

本实例不固定列，避免缩放、长文本和横向滚动时遮挡焦点与边界。

### 5.3 移动端和 200% 缩放

适配由可用空间决定，不依赖设备型号或 User-Agent。

- 筛选表单重排为单列，可收纳到具名称的 disclosure；已应用条件摘要始终在外部可见。
- 表格保留“记录、状态、更新时间、详情”列；负责人、描述和备注进入具标签详情。
- 移动端仍使用同一 Table owner，不创建第二张隐藏表格或卡片实例。
- 分页控件换行为多行布局，不删除跳页、页大小或边界按钮。
- 表格容器只横向滚动，页面只纵向滚动；关键流程不要求任一容器同时进行双向滚动。
- 触摸目标最小为 `44×44` CSS 像素，关键操作不依赖拖动、滑动、长按或 Hover。
- 使用 `100dvh` 时提供回退；四边加入相应 `safe-area-inset-*`。
- 虚拟键盘或动态浏览器工具栏出现后，筛选提交、结果摘要、分页和重试必须能通过页面滚动进入可视区。
- 200% 缩放及字体放大时，不使用固定页脚或浮动工具栏遮挡当前焦点。
- 断点切换保持同一 `ownerId`、查询快照、分页、展开状态和焦点意图；切换本身请求数为 0。

若断点切换后原焦点节点仍存活，焦点不变；若节点被响应式映射替换，则根据稳定 `recordId + controlId` 只移动一次到同一记录的等价详情按钮。

## 6. 键盘、焦点与 ARIA

### 6.1 Table 语义

使用原生：

```html
<section aria-labelledby="report-title">
  <form aria-labelledby="filter-title">…</form>
  <div aria-labelledby="result-summary">
    <table>
      <caption>数据记录报表</caption>
      …
    </table>
  </div>
</section>
```

具体要求：

- 表格有可区分的 `<caption>`，并由结果摘要补充当前范围；
- 列头使用 `<th scope="col">`；
- 详情行的单元格使用正确 `colspan`；
- 不设置 `role="grid"`；
- 静态单元格不设 `tabindex="0"`；
- Table 不接管方向键、Home、End、Page Up 或 Page Down。

### 6.2 键盘路径

Tab 顺序依次进入：

1. 筛选字段；
2. 应用、重置及已应用条件移除按钮；
3. 更新时间排序按钮；
4. 实际溢出时的横向滚动容器；
5. 行详情按钮；
6. 页大小、页码、跳页和重试控件。

原生按钮使用 Enter/Space；原生 `<select>` 保持平台语义；跳页输入按 Enter 提交。详情展开后，静态详情文本不进入额外 Tab 顺序。

鼠标、触摸和键盘触发同一查询意图时，生成相同快照并受到相同的重复提交保护。

### 6.3 焦点策略

- 编辑筛选草稿不移动焦点。
- 应用筛选和提交排序时，触发控件仍存在则保持焦点；结果提交移除目标时才迁移一次。
- 用户翻页后，匹配结果提交时把焦点移动一次到具 `tabindex="-1"` 的结果摘要；失效页自动恢复不得再次抢焦点。
- 重试成功导致重试按钮消失时，焦点移动一次到结果摘要。
- 后台刷新若精确 `recordId + columnId + controlId` 仍存在，焦点保持不变。
- 精确目标消失时依次选择：同记录等价控件、同列最近记录、结果摘要、当前分页控件。
- 最终目标必须存活、可聚焦、具名称；不得落到 `document.body`、文档根或已移除节点。

### 6.4 状态公告

结果区域是查询公告的唯一 primary owner：

- 每个被接受的查询开始简短公告一次；
- 改变结果数量或页码的接受响应公告一次；
- 查询失败公告一次；
- 失效页恢复成功公告一次；
- 完整错误只公告一次。

被合并、丢弃、取代、disposal 后到达的响应，以及静默失效事件，公告数为 0。公告不串联朗读全部行、全部筛选条件或重复完整错误。

`aria-busy` 设置在结果容器，不设置到筛选表单。加载、旧数据、过期、错误和空状态都必须有文本，不能只使用颜色、图标或位置。

## 7. Disposal、实例隔离与返回策略

路由提交离开或表格 owner 卸载时，同步且幂等地进入 `disposed`：

- 取消或失效查询、恢复请求、重试、防抖；
- 注销当前实例的滚动/尺寸观察器、监听器和订阅；
- 失效待执行焦点和公告任务；
- 移除当前实例 DOM 及其 ARIA 引用；
- 每项资源只由其 `ownerId` 释放一次；
- 迟到响应仍执行完整提交门禁，写入 DOM、状态、焦点和 live region 的数量均为 0。

旧触发器若随路由移除，不恢复焦点。新路由提交后，仅由新路由策略聚焦一次到主标题、主内容或主要操作。

本实例声明 `restorePolicy=none`：浏览器返回时建立新的 `ownerId/lifecycleToken`，不恢复旧请求、滚动、展开状态或错误。URL 中仍存在的安全筛选值可作为新实例初始值重新查询，但不视为恢复旧实例。

## 8. 原子应用义务

| ruleFamily | obligationKey | applicability | currentValueOrZeroEvidence | outputLocation | verificationStatus |
| --- | --- | --- | --- | --- | --- |
| 筛选 | `draft-applied-separation` | 适用 | 字段值进入 `filterDraft`；只有合法显式提交写入 `appliedFilters` | §3.1 | 未验证 |
| 筛选 | `declared-apply-mode` | 适用 | 关键词、状态、日期范围均为 `explicit` | §3.1 | 未验证 |
| 筛选 | `default-reset` | 适用 | 重置到空关键词、`status=all`、空日期；语义未变不请求 | §3.1 | 未验证 |
| 筛选 | `visible-removable-applied-values` | 适用 | 每个非默认条件持续显示并有独立移除按钮 | §3.1 | 未验证 |
| 筛选 | `url-safety` | 适用 | 仅状态和日期 URL-safe；关键词禁止进入 URL/标题/日志 | §3.1 | 未验证 |
| 筛选 | `field-error-owner` | 适用 | 格式、长度、日期范围错误归字段/筛选表单，不写 `queryError` | §3.1、§4 | 未验证 |
| 筛选 | `pagination-reset` | 适用 | 应用、移除、有效重置均回第 1 页 | §3.1、§3.3 | 未验证 |
| 排序 | `actual-key-direction` | 适用 | 当前 `updatedAt DESC`，之后追加 `recordId ASC` | §3.2 | 未验证 |
| 排序 | `null-order` | 适用 | `updatedAt NULLS LAST` | §3.2 | 未验证 |
| 排序 | `case-rule` | 适用 | `recordId` 为规范化大写 ASCII，按二进制区分大小写 | §3.2 | 未验证 |
| 排序 | `locale-rule` | 适用 | `locale=und`，不进行区域文本排序 | §3.2 | 未验证 |
| 排序 | `natural-order-rule` | 适用 | `natural=false` | §3.2 | 未验证 |
| 排序 | `unique-stable-key` | 适用 | 唯一、不可变 `recordId ASC` | §3.2 | 未验证 |
| 排序 | `interactive-dom` | 适用 | 仅更新时间 `<th>` 内有真实排序按钮 | §3.2、§6.1 | 未验证 |
| 排序 | `interactive-aria` | 适用 | 当前 `<th>` 设置 `aria-sort`；按钮名称描述下一方向 | §3.2、§6.1 | 未验证 |
| 排序 | `interactive-keyboard` | 适用 | Enter/Space 激活，其他表头没有排序 handler | §6.2 | 未验证 |
| 排序 | `interactive-focus` | 适用 | 请求和结果提交均保留存活排序按钮焦点 | §3.2、§6.3 | 未验证 |
| 排序 | `reset-to-origin` | 适用 | 方向提交后回第 1 页并建立新快照 | §3.2 | 未验证 |
| 分页 | `reliable-total-and-range` | 适用 | 服务端可靠 `totalCount`；显示当前页、总页、范围和总数 | §3.3 | 未验证 |
| 分页 | `direct-pages` | 适用 | 首页、末页、当前附近页码为直接按钮 | §3.3 | 未验证 |
| 分页 | `validated-jump` | 适用 | 只接受 `1..totalPages` 整数；无效值请求为 0 | §3.3 | 未验证 |
| 分页 | `native-boundaries` | 适用 | 首页/末页边界使用原生 `disabled` | §3.3 | 未验证 |
| 分页 | `page-size-control` | 适用 | 原生选择控件，值为 `25/50/100`，当前为 25 | §3.3 | 未验证 |
| 分页 | `reset-to-first` | 适用 | 筛选、排序、页大小变化回第 1 页 | §3.3 | 未验证 |
| 分页 | `single-invalid-page-recovery` | 适用 | 只恢复一次到最新有效末页，禁止循环 | §3.3、§4 | 未验证 |
| 分页 | `input-semantics` | 适用 | 按钮 Enter/Space；跳页 Enter；触摸和鼠标产生相同意图 | §3.3、§6.2 | 未验证 |
| 分页 | `single-focus-transition` | 适用 | 匹配页结果后仅一次聚焦结果摘要，自动恢复不二次聚焦 | §6.3 | 未验证 |

## 9. 应用检查清单

| 原子规则族 | 适用性 | DOM | state | handler/event | request | 正文定位 | 验证状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 能力与状态 | 适用 | 原生筛选、Table、分页；无越权结构 | 固定四组状态及 `display` 档位 | 仅查询、展示、详情事件 | 仅查询端点 | §1–§2 | 未验证 |
| 查询 | 适用 | 结果 owner 与 `aria-busy` | 不可变快照、generation、stale | apply/sort/page/refresh/retry | 每个接受意图一次 | §3.4、§4 | 未验证 |
| 筛选 | 适用 | 原生表单、条件摘要、字段错误 | `filterDraft` 与 `appliedFilters` 分离 | apply/reset/remove | 仅合法语义变化一次 | §3.1 | 未验证 |
| 排序 | 适用 | 更新时间表头真实按钮 | 单列方向及完整稳定比较规则 | Enter/Space/click | 每次有效方向提交一次 | §3.2 | 未验证 |
| 分页 | 适用 | 页码、跳页、页大小和原生禁用边界 | numbered 页、总数、页大小 | direct/jump/size/recovery | 每个合法目标一次 | §3.3 | 未验证 |
| 数据状态 | 适用 | 骨架、旧数据提示、错误、两类空状态 | 六阶段及 `stale` | retry/clear-filter | 重试使用新快照 | §4 | 未验证 |
| 选择 | 不适用 | 0 | 0 | 0 | 0 | §1、§2.2 | 未验证 |
| 单行操作 | 不适用 | 0 | 0 | 0 | 0 | §1、§2.2 | 未验证 |
| 批量操作 | 不适用 | 0 | 0 | 0 | 0 | §1、§2.2 | 未验证 |
| 基础列状态 | 适用 | 稳定列头、单元格和详情映射 | `visibleColumnIds/pinnedColumnIds/columnWidths/density` | 本地详情展开；无列变更事件 | 0 | §2.1–§2.2、§5 | 未验证 |
| 可选列控制 | 不适用 | 0 | 0 | 0 | 0 | §1、§2.2 | 未验证 |
| Table 语义 | 适用 | `<table>/<caption>/<th scope>` | 表头关联随响应式映射更新 | 使用原生控件语义 | 0 | §6.1 | 未验证 |
| ARIA Grid 语义 | 不适用 | 0 | 0 | 0 | 0 | §6.1 | 未验证 |
| 键盘 | 适用 | 仅真实控件和溢出容器进入 Tab | `focusIntent` | 原生 Tab、Enter、Space；Table 不吞导航键 | 与指针意图相同且不重复 | §6.2 | 未验证 |
| 焦点 | 适用 | 结果摘要可程序聚焦 | 稳定 record/column/control ID | 保持或仅一次 fallback | 焦点本身不发请求 | §6.3 | 未验证 |
| 响应式 | 适用 | 单一 Table 根、优先级列和详情 | 同 owner、快照、分页、展开和焦点意图 | 断点转换本身无业务事件 | 0 | §5 | 未验证 |
| ARIA 与公告 | 适用 | caption、label、describedby、live owner | busy/stale/error/empty 状态可区分 | 每个接受事件最多一次公告 | 合并/丢弃事件不公告 | §6.1、§6.4 | 未验证 |
| disposal | 适用 | 只移除来源实例 DOM/ARIA | `live→disposed`，资源按 owner 释放 | 迟到回调仅 discarded | disposal 后新请求为 0 | §7 | 未验证 |
| 实例隔离 | 适用 | ID 和公告区域按 owner 唯一 | generation 在 owner/token 命名空间解释 | 焦点、滚动、结果不跨实例 | 响应只能提交来源实例 | §2.3、§7 | 未验证 |
| 运行时验证边界 | 适用 | 需检查真实 DOM、滚动和可访问性树 | 需记录快照、代次、焦点和生命周期日志 | 需执行键盘、鼠标、触摸和竞态序列 | 需使用可控乱序响应及真实 API 契约 | §10 | 未验证 |

## 10. 尚未通过真实运行环境验证的结论

当前只有设计约束，尚未提供可运行实现，因此以下均不得视为已经通过：

- Chrome、Safari、Firefox、Edge 中的原生 Table、分页和筛选行为；
- VoiceOver + Safari、NVDA + Firefox/Chrome 等辅助技术下的表头关联、排序状态、公告去重和详情读取顺序；
- 纯键盘完成筛选、排序、翻页、跳页、展开全文和错误恢复；
- 鼠标、触摸与键盘是否产生完全相同的查询快照和请求数；
- `1440×900`、`1280×720`、平板横竖屏、`390×844`、低高度横屏手机及 200% 浏览器缩放；
- 200% 字体、长翻译、长单词、超长描述和备注下的换行、焦点可见性与页面根横向溢出；
- 表格横向滚动的键盘可达性、首尾边界提示及移动端触摸行为；
- 虚拟键盘、动态浏览器工具栏和四向安全区域下的筛选、分页及重试可达性；
- 高对比度、系统颜色、Reduced Motion 与焦点环可见性；
- 查询乱序、取消失败、重复刷新、失效页、路由卸载和同页多实例隔离；
- 服务端可靠总数、稳定 `recordId`、空值排序、`datasetVersion` 一致性以及跨页零重复遗漏；
- 首次加载、刷新失败、筛选零结果、空数据集和公告次数是否符合上述状态契约。
<!-- END RAW OUTPUT -->
