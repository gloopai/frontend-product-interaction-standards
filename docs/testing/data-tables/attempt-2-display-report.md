# Attempt 2 FAILED：只读展示型报表

## 实际 spawn 参数

```json
{
  "task_name": "attempt_2_display_report",
  "fork_turns": "none",
  "message": "Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.\n\n请设计一个只读数据报表。它需要支持筛选、稳定排序、页码分页和长内容；还必须能在浏览器 200% 缩放及移动端查看。请说明该报表的能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端行为，以及哪些结论尚未通过真实运行环境验证。\n\n请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。"
}
```

`model` 与 `reasoning_effort` 没有作为调用参数发送。

## spawn 工具返回

```json
{"task_name":"/root/table_task5_green/attempt_2_display_report"}
```

## 完成 envelope

- Message Type: `FINAL_ANSWER`
- Task name（recipient）: `/root/table_task5_green`
- Sender: `/root/table_task5_green/attempt_2_display_report`
- Payload: 以下 `BEGIN/END RAW OUTPUT` 之间的原始内容。

## 完整 Prompt

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个只读数据报表。它需要支持筛选、稳定排序、页码分页和长内容；还必须能在浏览器 200% 缩放及移动端查看。请说明该报表的能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端行为，以及哪些结论尚未通过真实运行环境验证。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

## 原始完成 payload

<!-- BEGIN RAW OUTPUT -->
# 只读数据报表交互设计说明

## 1. 能力声明与边界

本报表固定采用以下配置：

| 项目 | 配置 |
| --- | --- |
| `capabilityTier` | `display` |
| `resolvedTier` | 权限解析后仍为 `display` |
| 分页模式 | `numbered`，不可与游标分页混用 |
| 页大小 | 固定 25 条；首版不提供页大小切换 |
| 筛选 | 启用，统一采用 `applyMode: explicit` |
| 排序 | 启用，单业务列排序；请求中始终追加稳定次序键 |
| 选择/全选 | 不启用 |
| 全部筛选结果选择 | 不启用 |
| 单行/批量操作 | 不启用 |
| 行内编辑 | 不启用 |
| 列显示/固定/调宽 | 不启用；全部业务列可见，`pinnedColumnIds=[]` |
| 桌面语义 | 原生 `<table>` |
| ARIA Grid | 不启用，无单元格级二维导航需求 |
| 响应式形态 | 桌面/空间充足时 Table；窄容器时等价卡片列表 |
| 返回页面恢复 | 只恢复查询条件、排序、合法页码与滚动位置；不恢复任何旧权限结果或临时浮层 |

DOM、状态和事件处理器中不得出现选择列、复选框、行操作菜单、批量工具栏、编辑控件、树表、拖拽排序、透视、加载更多、无限滚动、列重排或个人布局持久化。

页码分页依赖服务端返回可靠 `total`；跨页“无重复、无遗漏”的强保证还依赖不可变 `datasetVersion` 或等价服务端快照。若后端缺少可靠总数，则不能伪造页码和总页数；若缺少数据版本能力，只能保证单次响应按稳定键排序，不能承诺实时变化数据集的跨页完整性。

页面配置必须在实现前明确：稳定且不可变的 `recordId`、列 ID/标签/类型/顺序、卡片映射顺序、筛选字段与 `defaultFilters`、敏感字段、可排序列、默认业务排序、字符串区域规则及权限范围。它们属于产品配置，但不得替代或放宽下述状态、竞态、可访问性和响应式规则。

## 2. 页面结构

视觉及 DOM 顺序保持一致：

1. 页面标题与报表说明。
2. 筛选表单。
3. 已应用筛选摘要。
4. 移动卡片形态使用的排序控件；桌面形态由表头提供排序控件。
5. 结果状态与结果摘要。
6. 单一活动数据根：Table 或卡片列表，不能同时保留两个活动实例。
7. 页码分页。

结果区域有稳定 ID，由标题通过 `aria-labelledby` 命名，并关联描述当前条件、总数、页码和数据新鲜度的摘要。页面使用主文档纵向滚动，不为表格再建立纵向滚动区。

## 3. 状态归属与查询快照

### 3.1 状态分组

`queryState` 至少包含：

```text
appliedFilters
sortRules
pagination = { mode: "numbered", page }
pageSize = 25
querySnapshot
snapshotId
datasetVersion?
requestGeneration
requestPhase
queryError
stale
lastSuccessfulResult
```

`requestPhase` 只能明确处于：

```text
idle
initial-loading
ready
refreshing
initial-error
refresh-error
```

`viewState` 至少包含：

```text
visibleColumnIds
columnWidths（只读配置值）
presentation = table | cards
rows
resultSummary
```

`interactionState` 只保存：

```text
focusIntent
当前 recordId / columnId / controlId
scrollPosition
```

由于 `resolvedTier=display`，不建立选择子状态和 `operationState`，也不存在相关 DOM、请求或事件入口。

筛选字段由筛选表单 owner 管理 `value`、`initialValue`、`touched`、`dirty`、校验结果和 `validationGeneration`；表格 owner 只接收字段已提交且合法的业务值。自绘 Select/Combobox 不在首版范围内；枚举字段优先使用带可见 `<label>` 的原生 `<select>`。若以后引入自绘控件，其搜索词、活动选项和弹层草稿不得进入表格的 `filterDraft` 或查询参数。

### 3.2 查询快照

每次合法查询前先冻结不可变 `querySnapshot`：

```text
ownerId
lifecycleToken
snapshotId
requestGeneration
appliedFilters
完整 sortRules
pagination
pageSize
permissionScope
datasetVersion（适用时）
reason
```

完整排序必须包含：

```text
业务排序列 + 方向
null 位置
大小写规则
locale / natural-sort 规则
不可变且唯一的 stableRecordId 次序键
```

默认约定为 null 始终排末尾，文本按页面配置的 locale、大小写及数字自然排序规则比较，最后追加 `stableRecordId ASC`。前后端必须使用同一约定。

响应只有同时满足以下条件才可提交：

- owner 仍为 live；
- `ownerId` 匹配；
- `lifecycleToken` 匹配；
- `requestGeneration` 等于当前代次；
- `snapshotId` 等于当前快照。

任一不匹配均丢弃，不得写入行、总数、错误、焦点或 live region。取消旧请求只用于节省资源，不能替代上述门禁。

显式刷新先生成包含筛选、排序、页码、页大小、权限、版本和原因的 `intentKey`。同一在途意图只合并，不增加快照、代次、请求或公告；意图键不同则正常创建新查询，即使旧请求尚未返回。

## 4. 状态转换

| 事件 | 转换 |
| --- | --- |
| 首次进入 | `idle → initial-loading`，无可用旧结果 |
| 首次成功 | `initial-loading → ready`，提交行、总数、页码和版本 |
| 首次失败 | `initial-loading → initial-error` |
| 编辑筛选字段 | 只更新字段值及 `filterDraft`，不查询 |
| 应用/移除/有效重置筛选 | 校验通过后更新 `appliedFilters`，回第 1 页，创建新快照，进入 `refreshing` |
| 无语义变化的重置 | 不创建请求 |
| 提交新排序 | 更新完整排序，回第 1 页，创建新快照，进入 `refreshing` |
| 合法翻页/跳页 | 保持筛选和排序，更新目标页并创建新快照 |
| 刷新成功 | `refreshing → ready`，替换结果并清除 `stale` |
| 刷新失败 | `refreshing → refresh-error`，保留旧结果并设 `stale=true` |
| 重试 | 基于当前已应用查询建立新快照和新代次 |
| 当前页超出最新末页 | 只恢复一次到最近有效页，最小为第 1 页 |
| 页间版本不一致 | 当前分页链失效，`stale=true`，停止继续导航并从第 1 页重新开始 |
| Table/Card 断点转换 | 只改变 `presentation`；不查询、不改 owner、不重置页码或焦点意图 |
| 路由离开或 owner 卸载 | 同步进入 `disposed`，拒绝全部新工作 |

筛选、排序或刷新期间保留上次成功结果时，结果区必须明确显示“正在按新条件更新，以下为上次成功结果”，旧结果继续绑定其原快照和页码摘要，不能被标成已匹配新条件。

## 5. 筛选

筛选使用原生 `<form>`，包含可见字段标签、“应用筛选”和“重置为默认条件”按钮：

- `filterDraft` 与 `appliedFilters` 分离。
- 所有字段均为显式应用；编辑和失焦不直接查询。
- Enter 提交筛选表单；已知无效时请求数为 0。
- “重置”恢复明确的 `defaultFilters`，不是无条件清空。
- 应用、移除或有效重置后回到第 1 页。
- 所有已应用条件在结果上方持续显示，即使原字段在移动端折叠。
- 每个条件有独立按钮，例如“移除筛选：状态为启用”。
- 只有标记 `urlSafe` 的条件可写入 URL；账号、令牌、个人信息、敏感标记和敏感自由文本不得进入 URL、标题或分析日志。
- 字段错误紧邻字段显示，设置 `aria-invalid="true"` 并通过稳定 `aria-describedby` 关联；筛选错误摘要可聚焦并导航到字段，但不得重复播报完整错误。
- 校验失败时聚焦错误摘要或第一个适用错误字段；合法查询开始后不抢走仍存活的“应用筛选”按钮焦点。

## 6. 稳定排序

桌面端仅可排序列的 `<th>` 内放真实 `<button>`；不可排序列不放按钮，也不设置 `aria-sort`。

交互规则：

- 单业务列排序；点击另一列会替换原业务排序。
- 同一列在升序和降序之间切换；稳定记录键始终作为不可见的末级排序存在。
- 排序按钮名称说明动作，例如“按更新时间升序排列”；提交后名称更新为下一动作。
- 原生 Table 仅当前业务排序表头设置 `aria-sort="ascending|descending"`。
- 每次排序提交回到第 1 页并建立新查询快照。
- 结果摘要显示当前业务排序；不得把稳定记录键伪装成用户选择的第二排序列。

卡片形态没有表头，因此在结果上方提供带可见标签的原生“排序字段” `<select>` 和“切换升序/降序”按钮，二者读写同一 `sortRules`。断点切换不触发排序请求；若桌面排序按钮因切换消失且正持有焦点，只迁移一次到等价移动排序控件。

## 7. 页码分页

服务端总数可靠时显示：

- 当前结果范围，例如“第 26–50 条，共 238 条”；
- 当前页与总页数；
- 首页、上一页、紧邻页码、下一页、末页；
- “跳转到页”数字输入和按钮。

当前页按钮使用 `aria-current="page"`。首页的首页/上一页、末页的下一页/末页使用原生 `disabled`。越界、空值和非整数跳页在字段旁显示错误，不发请求。

移动端可减少同时显示的邻近页码，但首页、上一页、当前页/总页数、下一页、末页和跳页能力都必须保留。翻页响应提交后，焦点只移动一次到结果标题或结果摘要；失效页自动恢复不得造成第二次抢焦点。

## 8. 长内容

- 单元格不使用只靠省略号或 `title` 才能读取的截断。
- 文本完整保留在 DOM，行高随内容增长。
- 普通文本允许换行；不可分割的长单词、ID 和 URL 使用 `overflow-wrap:anywhere`，不得撑出页面根。
- 身份、状态、错误和操作名称不得只靠颜色或图标表达。
- 数字可保持对齐，但不能因固定宽度覆盖相邻数据。
- 首版不使用固定列和列宽拖拽，避免缩放、长文本和横向滚动时遮挡焦点或边界。
- 每页固定 25 条，不使用无限滚动或虚拟化，保证完整文本、表头关联和辅助技术阅读顺序稳定。

## 9. 加载、错误、过期与空状态

### 首次加载

无旧结果时只显示与最终列结构相符的静态骨架；结果容器设置 `aria-busy="true"`。骨架内不得出现可点击按钮、链接或假数据。

### 后台刷新

保留上次成功的行、列、页码上下文和焦点意图，显示文本状态“正在更新”，并设 `aria-busy="true"`。旧结果必须标明其为上次成功结果。

### 首次错误

没有可用结果时进入 `initial-error`，用结果区域内的文本错误和可聚焦“重试加载报表”按钮替代不可用表格，不渲染空表壳。

### 刷新错误

保留旧结果和原分页上下文，进入 `refresh-error`，设置 `stale=true`，显示“数据可能已过期”及“重试更新”入口。不得清空表格或把旧错误覆盖到筛选字段。

### 空状态

- 已应用非默认筛选且总数为 0：显示“当前条件无匹配结果”，提供移除单个条件、重置筛选或返回筛选字段的路径。
- 无有效筛选且数据源本身为空：显示“报表当前没有数据”。
- 两者不得共用含糊的“暂无数据”。

### 公告

结果区域是查询状态的唯一公告 owner：

- 每个被接受的查询开始公告一次；
- 改变数量或位置的成功响应公告一次；
- 查询失败公告一次；
- 失效页恢复成功公告一次；
- 被合并、丢弃、取代或 disposal 后到达的事件不公告。

公告只说必要摘要，例如“正在更新报表”“找到 238 条，当前第 2 页”“更新失败，当前显示旧数据”，不朗读完整表格、全部筛选条件或重复完整错误。

## 10. 键盘操作

本报表使用原生 Table，不实现 Grid 键盘模型：

- Tab/Shift+Tab 只进入筛选控件、条件移除按钮、排序按钮、错误重试和分页控件。
- 静态单元格和卡片字段不设置 `tabindex="0"`。
- 表格不拦截方向键、Home、End、Page Up 或 Page Down。
- 原生按钮由 Enter/Space 激活。
- 筛选表单和跳页表单可由 Enter 提交。
- 原生 `<select>` 保留平台默认键盘行为。
- Hover 不承载唯一信息；关闭 Hover 后仍能发现筛选状态、排序、错误、分页和完整字段内容。
- 所有触摸关键任务都有同等点击和键盘路径，最小触摸目标按产品标准不小于 44×44 CSS px。

## 11. 焦点管理

`focusIntent` 使用稳定业务标识，不使用数组索引或第几个 DOM 节点：

```text
sourceEvent
recordId?
columnId?
controlId?
fallbackId
```

规则如下：

- 首次成功加载不主动移动焦点。
- 筛选、排序和显式刷新发请求时不抢走仍存活的触发控件焦点。
- 同页刷新后精确 `recordId + columnId + controlId` 仍存在时保持焦点；记录换到另一索引也不得聚焦旧索引的其他记录。
- 精确目标消失时，按“同记录等价控件 → 同列最近记录 → 结果摘要/标题 → 当前分页控件”只迁移一次。
- 用户翻页成功后聚焦结果标题/摘要一次；自动页码恢复不再移动。
- 筛选校验失败聚焦错误摘要或首个错误字段。
- 响应式转换时，原节点仍存活则不产生 blur/refocus；节点消失才移动一次到等价控件。
- 最终焦点不得落到 `document.body`、文档根、已移除节点或隐藏节点。
- 路由离开时不向即将删除的旧触发器恢复焦点；新路由提交后由新路由策略聚焦主标题、主内容或主要操作。

## 12. ARIA 与语义

桌面 Table：

- 使用原生 `<table>`，由 `<caption>` 或 `aria-labelledby` 提供可区分名称。
- 列头使用 `<th scope="col">`；记录身份列可使用 `<th scope="row">`。
- 表头和单元格关联不得依赖视觉位置猜测。
- 只在当前排序表头设置 `aria-sort`。
- 不添加 `role="grid"`。

卡片列表：

- 使用单一 `<ul>`/列表根，每条记录为 `<li>` 内的 `<article>`。
- 每张卡片通过身份字段获得记录级名称。
- 字段使用 `<dl><dt><dd>` 或等价显式标签关联。
- 所有 Table 列必须在卡片映射中出现一次；身份、主要状态和主要指标排在前面，次要字段仍可直接读取。

其他语义：

- 结果容器在查询期间设置 `aria-busy="true"`。
- 分页放在 `<nav aria-label="报表分页">` 内。
- 筛选字段有可见 label；帮助、单位和错误只作为描述。
- 加载、旧数据、错误和空状态均有可见文本，不只靠颜色或图标。
- 同一错误只有一个 primary owner；完整查询错误只在结果区域呈现和公告，字段错误只归对应字段。

## 13. 桌面、移动端与 200% 缩放

`responsivePresentation` 显式配置为 `table-to-cards`。转换阈值由列最小宽度总和及容器可用空间确定，不依赖设备名称或 User-Agent。

- 空间充足：原生 Table。
- 容器不足以保持可读列宽时：转换为卡片列表。
- 卡片配置必须验证每个 `visibleColumnId` 都有唯一映射；配置不完整时不得猜测或丢列，回退为原生 Table 加受控横向滚动。
- 横向滚动只允许出现在表格容器，页面根不得横向溢出；容器需以渐隐边界或文本提示表达仍可滚动方向，并支持键盘和触摸。
- 任一时刻只有 Table 或卡片一个活动数据根。
- 断点转换保持同一 `ownerId`、查询、页码、结果、版本、焦点意图和在途请求；转换本身请求增量为 0。
- 200% 浏览器缩放通常会因可用 CSS 宽度减少而进入卡片形态；筛选和分页重排为单列或可换行布局，核心任务不要求页面和表格同时双向滚动。
- 低高度、横屏手机、动态浏览器工具栏和虚拟键盘出现时，筛选提交、结果、错误重试和分页都保留在正常文档流并可滚动到达。
- 使用四向 `safe-area-inset-*` 为页面内容、焦点和主要控件留出内边距。
- 支持长标签、200% 字体放大和国际化文本扩展；不得删除字段、错误或恢复入口。
- 固定栏若存在，不得覆盖当前焦点、错误或分页；本方案不设置固定底部操作栏。

## 14. 生命周期与实例隔离

每个报表实例拥有唯一 `ownerId`、不可复用 `lifecycleToken` 和独立公告 owner。同页多份报表即使请求代次数值相同，也必须在 `ownerId + lifecycleToken` 命名空间内解释。

路由提交离开或 owner 卸载时立即、幂等地进入 `disposed`：

- 取消或失效查询、分页恢复、筛选防抖、重试和待执行焦点任务；
- 注销该实例的监听器、计时器、观察器和订阅；
- 移除自己的 DOM 与 ARIA 引用；
- disposal 后拒绝查询、分页、焦点和公告新工作；
- 迟到回调仍必须经过完整门禁，写入计数为 0；
- 一个实例不得清理或改写另一个实例的状态、错误、焦点或资源。

返回页面时，只有显式 `restorePolicy=query-and-scroll` 才允许恢复查询与滚动；恢复前重新校验权限范围、数据版本和页码有效性，并创建新的 `ownerId` 与 `lifecycleToken`。校验失败时从新权限下的第 1 页重新查询。

## 15. 实现应用清单

| 规则族 | 结论 | 可观察依据 |
| --- | --- | --- |
| 能力档位与状态 | 适用 | 显式 `display`；查询、展示、焦点状态分离 |
| 查询门禁与竞态 | 适用 | 不可变快照、五项响应门禁、同意图合并 |
| 筛选与字段校验 | 适用 | 草稿/已应用分离、显式应用、错误 owner |
| 稳定排序 | 适用 | 业务键后追加唯一不可变记录键 |
| 页码分页 | 适用 | 可靠总数、页码/跳页、边界 disabled、失效页恢复 |
| 加载/错误/空状态 | 适用 | 六阶段、旧结果保留、两种空状态 |
| 选择与全部筛选结果 | 不适用 | 无选择 DOM、状态、处理器或请求 |
| 单行/批量操作 | 不适用 | 无操作入口、快照、工具栏或请求 |
| 列显示/固定/调宽 | 不适用 | 配置均关闭，无控制器和事件处理器 |
| 原生 Table | 适用 | `<table>`、`th scope`、静态单元格不进 Tab |
| ARIA Grid | 不适用 | 无二维单元格导航需求，DOM 中无 `role="grid"` |
| 焦点恢复 | 适用 | 稳定记录/列 ID 与单次 fallback |
| 响应式与卡片等价 | 适用 | 显式完整映射、单活动数据根、状态不重建 |
| ARIA 与公告 | 适用 | 唯一结果公告 owner、名称/状态/错误关联 |
| disposal 与实例隔离 | 适用 | owner/token 门禁、资源按实例释放 |
| 自绘 Select/Combobox | 不适用 | 首版只使用原生表单控件 |
| 真实运行验证边界 | 适用 | 按下节逐项保留未验证状态 |

## 16. 尚未通过真实运行环境验证的结论

以上内容是实现契约，当前未在真实页面或组件运行时执行，因此下列结论全部为“未验证”：

- Chrome、Firefox、Safari、Edge 下的原生 Table、排序、筛选、页码和卡片切换。
- `1440×900`、`1280×720`、平板横竖屏、`390×844` 窄屏及低高度横屏手机。
- 浏览器 200% 缩放、系统字体 200%、长翻译、超长单词、ID 和多段文本。
- 动态 viewport、虚拟键盘开关及四向安全区域。
- 纯键盘任务路径、实际 Tab 顺序、焦点迁移次数和焦点不被旧回调夺走。
- 触摸、鼠标和键盘触发同一意图时的等价终态与重复请求保护。
- NVDA/Firefox、NVDA/Chrome、JAWS/Chrome、VoiceOver/Safari 下的表头关联、`aria-sort`、`aria-busy`、卡片字段标签及公告去重。
- 快速连续筛选、排序、翻页、重复刷新、迟到响应、取消失败和多实例交错响应。
- 首次错误、刷新错误、筛选零结果、空数据集、失效页恢复及 `datasetVersion` 变化。
- Table/Card 实时转换期间的单实例、状态延续、请求增量为 0 和单次等价焦点迁移。
- 路由离开、owner 卸载、资源释放和 disposal 后迟到回调隔离。
- 后端是否真正提供可靠总数、不可变稳定记录键、统一排序规则及一致数据版本。

实现完成后必须在上述浏览器、视口、输入方式、辅助技术和可控网络竞态环境中逐项执行并保存结果；静态代码审查不能替代这些运行时结论。
<!-- END RAW OUTPUT -->
