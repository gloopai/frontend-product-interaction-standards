# 列表结果控制交互规范设计

## 背景

管理台列表、报表、任务中心、审计日志和文件库都会出现一组高频控制：分页、页大小、排序、刷新、结果摘要、数据版本、请求状态和空/错恢复。它们通常被写在表格组件里，看起来像“组件默认能力”，但实际很容易产生跨 owner 问题：

- 用户刚改筛选或关键词，旧分页请求迟到后覆盖新结果。
- 排序变化没有回到第一页，导致结果范围和页码语义不一致。
- 服务端总数不可靠，却展示精确总页数和跳页。
- 刷新按钮只看 `loading`，把首次加载、刷新失败、过期数据和局部操作混成一种状态。
- page size 改变后选择、批量范围、URL 和结果摘要仍沿用旧快照。
- 移动端把分页、刷新、排序说明或错误恢复直接删除。

现有 `data-tables.md` 已覆盖表格能力、选择、批量、表头排序和分页基础规则，但它同时承担列、行、选择、批量、ARIA Grid 等职责，继续往里塞会让表格 owner 过重。`query-filters.md` 负责已应用查询条件，`keyword-search-inputs.md` 负责搜索输入内部状态，`feedback-states.md` 负责状态反馈类型，都不是列表结果控制的 primary owner。因此需要新增一个更窄的 owner，专门约束“已应用查询快照如何驱动结果位置、排序、刷新和结果摘要”。

## 范围

新增 `references/list-result-controls.md`，作为以下场景的 primary owner：

- 列表、表格、卡片列表、报表结果、审计日志、任务中心、文件库、成员列表和设置项列表的结果控制。
- 页码分页、游标分页、上一页/下一页、页大小、直接跳页、排序提交、刷新、自动刷新、结果摘要、总数/范围说明、过期数据、迟到响应和结果请求门禁。
- 非表格列表的排序控件、移动端排序 Drawer / Action Sheet、卡片列表分页、结果工具栏刷新和局部列表刷新。
- 结果容器与上层筛选、搜索、权限、保存视图、URL、导出、选择和批量操作之间的快照边界。

不覆盖：

- 表格列、固定列、行选择、全选、批量操作和 ARIA Grid；继续由 `references/data-tables.md` 负责。
- 筛选字段草稿、已应用条件和 filter chips；继续由 `references/query-filters.md` 负责。
- 关键词输入、IME、防抖输入和搜索清空；继续由 `references/keyword-search-inputs.md` 负责。
- 按钮本体 loading、防重复、危险按钮和可访问名称；继续由 `references/buttons.md` 负责。
- 空态、错误、权限状态的通用反馈模型；继续由 `references/feedback-states.md` 负责。
- 保存视图、列布局和个性化预设；继续由 `references/saved-views-layout-presets.md` 负责。
- 导出、下载和产物领取；继续由 `references/exports-downloads-artifacts.md` 负责。

## 推荐方案

采用独立 owner：`listResultControlsState`。

我更推荐把结果控制从 `data-tables.md` 中抽成独立规范。原因很朴素：不是所有结果列表都是表格，报表卡片、文件库、任务中心、审计时间线也都有分页、排序和刷新；而表格本体已有大量选择/批量规则。如果仍由 data-table 独占，会让非表格结果要么无 owner，要么被迫套表格语义。

### 方案对比

1. 独立 list result controls owner（推荐）
   - 优点：覆盖表格和非表格结果；能精确约束请求快照、分页语义、排序重置、刷新去重和移动端结果控制；边界清晰。
   - 代价：需要新增路由、相邻 owner 链接和专项审计，并在 data-tables 中声明分页/排序/刷新可以委托或共同执行。

2. 继续扩展 data-tables
   - 优点：改动少，已有分页和排序规则。
   - 代价：非表格列表无明确 owner；data-tables 继续膨胀；卡片列表、任务列表和移动端结果页容易被误判为表格。

3. 放到 feedback-states 或 page-toolbars-actions
   - 优点：刷新和错误恢复常在工具栏/反馈区出现。
   - 代价：这两个 owner 不应持有查询快照、排序、分页位置或响应提交门禁。

## 状态模型

新 owner 定义 `listResultControlsState`，至少包含：

- `resultControlsOwnerId`：当前结果控制稳定 owner 身份。
- `surfaceKind`：`table-result`、`card-list`、`report-result`、`audit-list`、`task-list`、`file-list`、`mobile-result`。
- `appliedQueryBinding`：已应用筛选、已提交关键词、权限范围、租户/工作区、route、保存视图、数据集版本。
- `querySnapshot`：本次请求冻结的筛选、关键词、排序、分页位置、页大小、权限版本、租户/工作区、route、数据版本和刷新原因。
- `requestGeneration`：结果请求代次。
- `requestPhase`：`idle`、`initial-loading`、`ready`、`refreshing`、`initial-error`、`refresh-error`、`stale`。
- `sortState`：可排序字段、当前排序、多列优先级、稳定次序键、空值/区域/自然排序规则。
- `paginationState`：`numbered` 或 `cursor`、当前位置、页大小、可靠总数状态、结果范围、上一页/下一页游标、失效页恢复。
- `refreshState`：手动刷新、自动刷新、后台失效、同键刷新合并、刷新冷却、上次成功结果。
- `resultSummary`：当前展示范围、结果数量、总数可信度、数据延迟、更新时间和过期说明。
- `selectionImpact`：结果位置、排序、页大小或权限变化对选择/批量范围的影响。
- `urlHistoryBinding`：哪些已提交结果控制可写 URL、浏览器历史、保存视图和恢复上下文。
- `permissionBoundary`：权限、能力开关、只读、无权限、旧结果清理和无泄露策略。
- `feedbackBinding`：loading、refreshing、stale、empty、zero-results、invalid-page、error 和恢复入口的唯一反馈 owner。
- `responsivePolicy`：移动端分页、排序、刷新、结果摘要、错误恢复和虚拟键盘/安全区域可达性。

核心不变量：

- 结果控制只能读取已应用查询，不得读取筛选草稿或搜索输入草稿。
- 排序变化、页大小变化和有效筛选/关键词变化必须建立新 `querySnapshot`。
- 迟到响应不得覆盖当前 owner、当前代次或当前快照不匹配的结果。
- 页码分页和游标分页不得在同一快照内混用。
- 总数不可靠时不得展示精确总页数、随机跳页或“全部 N 条”的承诺。
- 刷新保留旧结果并标记 refreshing/stale，不得把旧结果伪装成新响应。

## 行为规则

### 查询快照与响应提交

每次结果请求前，必须冻结 `querySnapshot`。快照包含已应用筛选、已提交关键词、排序规则、分页模式与位置、页大小、权限版本、租户/工作区、route、数据版本和刷新原因。发出后任何 UI 草稿变化不得修改该快照。

响应只有同时满足当前 owner live、`resultControlsOwnerId` 相同、`requestGeneration` 相同、`querySnapshot` 身份相同、权限/租户仍匹配时，才可写入结果、分页、总数、错误、loading 或结果摘要。不匹配响应只能记录为 discarded，不得清空结果、覆盖错误、抢焦点或重复公告。

### 排序

排序控件只能提交产品声明的合法字段和方向。提交不同排序时，页码分页回到第 1 页，游标分页回到初始游标，并创建新快照。多列排序必须展示优先级；所有分页排序都必须声明稳定次序键、空值位置、大小写/区域/自然排序规则。没有稳定排序时，不得承诺跨页无重复、无遗漏。

### 分页与页大小

每个结果 owner 只能选择 `numbered` 或 `cursor`。页码分页只有在总数可靠时才能展示总页数、跳页和末页；总数不可靠时只展示当前范围、是否还有下一页和更新时间。游标分页只能使用服务端提供的上一页/下一页游标，不得虚构页码或总页数。

改变页大小必须回到第一个有效位置并创建新快照；旧选择、旧批量范围、旧导出范围和旧 URL 只有重新证明仍匹配时才能保留。服务端拒绝的页大小不能成为当前值。

### 刷新、自动刷新与过期数据

刷新读取当前已应用查询快照，不读取筛选草稿、搜索草稿、旧权限或旧视图。手动刷新和自动刷新都必须声明 `refreshReason`。同一 in-flight 且同键的刷新可以合并；不同键刷新必须新建代次，不得因为已有请求而全局吞掉。

刷新已有结果时保留上次成功结果，进入 `refreshing` 或 `stale`，展示“数据可能已过期”或等价说明和恢复入口。刷新失败不能清空已有结果；首次加载失败才可替代结果区域。

### 结果摘要、总数和 URL

结果摘要必须区分当前页范围、当前已加载数量、可选总数、估算总数、未知总数和权限过滤后的安全摘要。无权限或总数不可信时，不得泄露真实数量或精确范围。

只有已提交且 `urlSafe` 的排序、分页、页大小和查询条件可以写 URL。旧 URL、浏览器返回和保存视图恢复必须先校验版本、权限、租户/工作区、页大小合法性、排序字段合法性和分页模式；无效页不能静默显示空表，应进入失效页恢复路径。

### 移动端与响应式

移动端不得删除排序、分页、刷新、结果摘要、错误说明、权限原因、过期说明和恢复路径。低频排序可以进入 Drawer / Action Sheet，页大小可以折叠，但必须保留当前值、作用范围、禁用原因和焦点返回。底部分页、固定工具栏、虚拟键盘和 safe-area 不能完全遮挡当前页、下一页、刷新、错误和结果摘要。

## 相邻 owner 关系

- `references/data-tables.md`：表格仍负责列、行、选择、批量和 ARIA Grid；结果请求、分页、刷新和排序快照必须执行本 owner。
- `references/query-filters.md`：本 owner 只读取 `appliedFilters`，不得读取 `filterDraft`。
- `references/keyword-search-inputs.md`：本 owner 只读取 `committedKeyword`，不得读取 `inputDraft` 或 composition 文本。
- `references/page-toolbars-actions.md`：刷新、导出、视图工具等入口读取本 owner 的当前范围和快照。
- `references/feedback-states.md`：结果 loading、refresh-error、stale、empty 和 zero-results 的通用反馈执行该 owner，但状态来源由本 owner 提供。
- `references/saved-views-layout-presets.md`：保存视图只能持久化已提交且安全的结果控制，不保存草稿或旧权限。
- `references/exports-downloads-artifacts.md`：导出读取本 owner 的结果范围快照，但导出生命周期归导出 owner。
- `references/responsive-adaptive.md`：断点、动态 viewport、虚拟键盘和 safe-area 执行响应式规范。

## 路由触发词

`SKILL.md` 应新增路由，命中：

- 中文：列表结果、结果控制、结果摘要、分页、页码、游标分页、上一页、下一页、跳页、页大小、每页数量、排序、列表排序、表格排序、刷新、自动刷新、结果刷新、过期数据、数据版本、迟到响应、请求代次、总数不可靠。
- English：list result、result controls、result summary、pagination、page number、cursor pagination、previous page、next page、jump page、page size、per page、sorting、list sorting、table sorting、refresh、auto refresh、result refresh、stale data、dataset version、late response、request generation、unreliable total。

## 可执行验收方向

实施计划需要新增 Ruby 审计，至少覆盖：

1. owner 文件存在，且包含完整 `listResultControlsState` 字段。
2. 精确规则：只读取已应用查询；排序变化和页大小变化创建新快照；迟到响应不得覆盖当前结果；页码和游标不得混用；总数不可靠不得展示精确总页数；刷新保留旧结果并标记 stale/refreshing。
3. URL/历史边界：只写入已提交且 `urlSafe` 的结果控制，恢复时校验权限、租户、版本、页大小和排序字段。
4. 移动端规则：不得删除排序、分页、刷新、结果摘要、错误说明、权限原因、过期说明和恢复路径。
5. 相邻 owner：data-tables、query-filters、keyword-search-inputs、page-toolbars-actions、feedback-states、saved-views、exports-downloads 和 responsive-adaptive 必须链接到新 owner 或说明边界。
6. RED/GREEN 证据包含 querySnapshot、requestGeneration、late response、pagination mode、unreliable total、refresh stale、URL restore、mobile controls 和 `未验证`。

## 风险与取舍

- 不在首版定义后端分页协议、索引策略、SQL 排序或缓存架构；这里只约束前端交互 owner 和可观察行为。
- 不禁止无限滚动，但首版不纳入本 owner；若后续要支持，应独立补“加载更多/无限滚动”规范，不能让游标分页暗中伪装成无限滚动。
- 不要求所有列表都有页码。短列表、局部搜索结果和卡片列表可以无分页，但一旦存在结果位置、排序或刷新，就必须声明 owner 边界。
- 不把刷新失败写成全局错误；刷新失败应尽量保留旧结果，并给出过期说明和局部恢复路径。

## 自检

- 范围聚焦：本 spec 只新增列表结果控制 owner，不替代表格选择、筛选输入、搜索输入、反馈状态或导出生命周期。
- 边界清晰：字段草稿归字段 owner，已应用查询归 query-filters，结果位置和请求快照归本 owner。
- 可审计：关键规则都有 exact terms 和 mutation cases。
- 运行时诚实：真实浏览器、移动端、触摸、屏幕阅读器、权限切换、网络迟到和数据版本变化未执行时必须标为 `未验证`。
