# 列表结果控制交互规范

适用于列表结果、结果控制、结果摘要、分页、页码、游标分页、上一页、下一页、跳页、页大小、每页数量、排序、列表排序、表格排序、刷新、自动刷新、结果刷新、过期数据、数据版本、迟到响应、请求代次、总数不可靠、list result、result controls、result summary、pagination、page number、cursor pagination、previous page、next page、jump page、page size、per page、sorting、list sorting、table sorting、refresh、auto refresh、result refresh、stale data、dataset version、late response、request generation 和 unreliable total。

列表 empty、zero-results、no results、首次使用、清空筛选、重置筛选和 empty CTA 必须同时执行 `references/empty-first-run-zero-results.md`。列表结果控制 owner 负责查询快照、分页、排序、刷新、总数可信度和结果摘要；空态 owner 负责 `emptyStateDecision`、emptyReason、CTA、权限空态和恢复路径。

本文件是已应用查询快照驱动的结果控制 primary owner。表格列、选择、批量和 ARIA Grid 继续执行 [数据表格交互规范](data-tables.md)；筛选草稿和已应用条件继续执行 [查询条件与筛选交互规范](query-filters.md)；关键词输入草稿和 IME composition 继续执行 [关键词搜索输入交互规范](keyword-search-inputs.md)；状态反馈继续执行 [反馈状态交互规范](feedback-states.md)；按钮本体继续执行 [按钮交互规范](buttons.md)；保存视图继续执行 [保存视图、视图预设与个性化布局交互规范](saved-views-layout-presets.md)；导出下载继续执行 [导出、下载与结果产物交付交互规范](exports-downloads-artifacts.md)；移动端适配继续执行 [响应式与自适应交互规范](responsive-adaptive.md)。

列表结果中的乐观新增、乐观删除、乐观状态变更、撤销、失败回滚、自动重试、离线队列或迟到响应协调必须同时执行 `references/optimistic-update-undo.md`；本文件继续负责已应用查询快照、结果刷新、stale、分页和选择影响，`optimistic-update-undo.md` 负责 pending 投影、撤销窗口、回滚依据、幂等、权威结果合并和旧投影清理。

已删除列表、已归档列表、回收站结果、包含已删除筛选、恢复后返回原列表、永久删除后的结果刷新和保留期到期清理必须同时执行 `references/trash-restore-retention.md`；列表结果 owner 负责查询快照、分页、排序、刷新和摘要，回收站 owner 负责 `trashRestoreState`、visibilityPolicy、retentionPolicy、restorePolicy、purgePolicy 和旧结果清理。

## 范围与非目标

本 owner 覆盖列表、表格、卡片列表、报表结果、审计日志、任务中心、文件库、成员列表和设置项列表中的结果位置、排序、分页、刷新、自动刷新、结果摘要、请求快照、迟到响应、总数可信度、URL 恢复、权限和移动端承载。

卡片列表、卡片式结果、资源卡片、模板卡片、应用卡片、项目卡片、卡片网格、移动端结果卡片和 Kanban-lite 的结果位置、排序、分页、刷新、自动刷新、结果摘要和迟到响应继续执行本文件；卡片结构、字段映射、交互区域、选择/操作区、大链接禁止和卡片内编辑禁止必须同时执行 `references/card-list-results.md` 与 `card-list-results.md`。

本 owner 不覆盖表格列渲染、固定列、行选择、全选、批量操作、ARIA Grid、筛选字段草稿、关键词输入草稿、表单提交、导出生命周期、后端分页协议、SQL 排序、缓存架构、组件库 API 或像素级样式。

## `listResultControlsState`

每个可分页、可排序、可刷新或需要结果摘要的结果区域必须声明 `listResultControlsState`：

| 字段 | 语义 |
| --- | --- |
| `resultControlsOwnerId` | 当前结果控制稳定 owner 身份，用于绑定请求、分页、排序、刷新、URL、焦点和反馈。 |
| `surfaceKind` | 承载类型：`table-result`、`card-list`、`report-result`、`audit-list`、`task-list`、`file-list`、`mobile-result`。 |
| `appliedQueryBinding` | 已应用筛选、已提交关键词、权限范围、租户/工作区、route、保存视图和数据集版本。 |
| `querySnapshot` | 本次请求冻结的筛选、关键词、排序、分页位置、页大小、权限版本、租户/工作区、route、数据版本和刷新原因。 |
| `requestGeneration` | 结果请求代次；每个被接受的新查询意图严格递增。 |
| `requestPhase` | `idle`、`initial-loading`、`ready`、`refreshing`、`initial-error`、`refresh-error`、`stale`。 |
| `sortState` | 可排序字段、当前排序、多列优先级、稳定次序键、空值/区域/自然排序规则。 |
| `paginationState` | `numbered` 或 `cursor`、当前位置、页大小、可靠总数状态、结果范围、上一页/下一页游标和失效页恢复。 |
| `refreshState` | 手动刷新、自动刷新、后台失效、同键刷新合并、刷新冷却和上次成功结果。 |
| `resultSummary` | 当前展示范围、结果数量、总数可信度、数据延迟、更新时间和过期说明。 |
| `selectionImpact` | 结果位置、排序、页大小、权限或数据版本变化对选择、批量范围和导出范围的影响。 |
| `urlHistoryBinding` | 哪些已提交结果控制可写 URL、浏览器历史、保存视图和恢复上下文。 |
| `permissionBoundary` | 权限、能力开关、只读、无权限、旧结果清理和无泄露策略。 |
| `feedbackBinding` | loading、refreshing、stale、empty、zero-results、invalid-page、error 和恢复入口的唯一反馈 owner。 |
| `responsivePolicy` | 移动端分页、排序、刷新、结果摘要、错误恢复和虚拟键盘/safe-area 可达性。 |

## Owner 边界和不变量

结果控制只能读取已应用查询，不得读取筛选草稿或搜索输入草稿。已应用查询包括 `appliedFilters`、`committedKeyword`、已提交排序、当前分页位置、页大小、权限版本、租户/工作区、route 和保存视图快照；`filterDraft`、`inputDraft`、`normalizedDraft`、composition 文本、Select query、active option、hover、focus 和临时列拖拽都不能直接改变结果。

排序变化、页大小变化和有效筛选/关键词变化必须建立新 `querySnapshot`。迟到响应不得覆盖当前 owner、当前代次或当前快照不匹配的结果。页码分页和游标分页不得在同一快照内混用。总数不可靠时不得展示精确总页数、随机跳页或“全部 N 条”的承诺。刷新保留旧结果并标记 refreshing/stale，不得把旧结果伪装成新响应。

## 查询快照与响应提交门禁

每次结果请求前，必须冻结 `querySnapshot`。快照至少包含已应用筛选、已提交关键词、排序规则、分页模式与位置、页大小、权限版本、租户/工作区、route、数据版本和刷新原因。发出后任何字段草稿、搜索草稿、焦点变化、打开菜单、列宽预览或权限旧缓存都不得修改该快照。

响应只有同时满足当前 owner live、`resultControlsOwnerId` 相同、`requestGeneration` 相同、`querySnapshot` 身份相同、权限/租户仍匹配时，才可写入结果、分页、总数、错误、loading 或结果摘要。不匹配响应只能记录为 `response-discarded`，不得清空结果、覆盖错误、重置页码、抢焦点、重复公告、写 URL、写保存视图或改变批量范围。

取消旧请求只用于节省资源，不能替代响应提交门禁。已取消但迟到的响应仍需经过同一门禁；旧 owner disposal 后的响应写入数必须为 0。

## 排序规则

排序控件只能提交产品声明的合法字段和方向。不可排序字段不得渲染排序按钮、快捷键或 URL 排序参数；旧 URL 恢复出不可排序字段时必须进入可见恢复状态。

提交不同排序时，页码分页回到第 1 页，游标分页回到初始游标，并创建新快照。多列排序必须展示并播报优先级；单列排序提交新字段时替换旧业务排序。所有分页排序都必须声明稳定次序键、空值位置、大小写/区域/自然排序规则。没有稳定排序时，不得承诺跨页无重复、无遗漏。

排序中的 hover、focus、active、按下视觉、预览态和菜单打开态不得伪装成已提交排序。排序提交后，结果摘要、URL、保存视图、导出范围和选择影响必须读取新快照。

## 分页、游标和页大小

每个结果 owner 只能选择 `numbered` 或 `cursor`。页码分页只有在总数可靠时才能展示总页数、跳页和末页；总数不可靠时只展示当前范围、是否还有下一页和更新时间。游标分页只能使用服务端提供的上一页/下一页游标，不得虚构页码或总页数。

改变页大小必须回到第一个有效位置并创建新快照。旧选择、旧批量范围、旧导出范围、旧 URL 和旧焦点目标只有重新证明仍匹配时才能保留；否则必须清理、失效或进入待重新确认态。服务端拒绝的页大小不能成为当前值。

请求页超过服务端最新有效范围时，不得循环重试或静默展示空结果。页码模式请求最近有效页，游标模式回到服务端给出的最近有效前向位置或初始游标；恢复成功后只公告一次新位置。

## 刷新、自动刷新和过期数据

刷新读取当前已应用查询快照，不读取筛选草稿、搜索输入草稿、旧权限或旧视图。手动刷新、自动刷新、后台失效、返回恢复和权限复核都必须声明 `refreshReason`。

同一 in-flight 且同键的刷新可以合并；不同键刷新必须新建代次。同键的定义必须至少包含 `resultControlsOwnerId`、`querySnapshot`、权限版本、租户/工作区、route、数据版本和刷新原因；不得因为页面里已有任意请求而全局吞掉刷新。

刷新已有结果时保留上次成功结果，进入 `refreshing` 或 `stale`，并展示“数据可能已过期”或等价说明和恢复入口。刷新失败不能清空已有结果；首次加载失败才可替代结果区域。自动刷新失败不得无限 Toast，也不得把旧结果写成刚更新成功。

## 结果摘要与总数可信度

结果摘要必须区分当前页范围、当前已加载数量、可选总数、估算总数、未知总数、权限过滤后的安全摘要、数据延迟和更新时间。无权限、权限降级、租户/工作区切换或总数不可信时，不得泄露真实数量、精确范围、对象名称、内部 ID、导出范围或旧缓存。

结果摘要只能由一个 primary owner 完整播报。列表标题、工具栏、Toast、表格 caption、分页区和全局 live region 不得重复朗读同一完整消息；可以由摘要播报概览，由错误区域或反馈 owner 播报完整恢复说明。

## URL、浏览器历史和保存视图恢复

只有已提交且 `urlSafe` 的排序、分页、页大小和查询条件可以写 URL。筛选草稿、搜索输入草稿、composition 文本、未提交排序预览、旧权限、旧数据版本、敏感自由文本、内部 ID、令牌、个人识别信息和权限范围不得写入路径、查询串、片段、页面标题、分析日志、浏览器历史或保存视图。

旧 URL、浏览器返回和保存视图恢复必须先校验版本、权限、租户/工作区、页大小合法性、排序字段合法性和分页模式。无效页、过期游标、不可排序字段、拒绝的页大小、无权限范围和不兼容版本不能静默忽略；必须进入可见恢复状态，并说明使用默认位置、清除非法参数或要求重新选择。

## 选择、批量和导出影响

结果位置、排序、页大小、权限范围或数据版本变化时，必须明确写入 `selectionImpact`。当前页选择通常随翻页、页大小、筛选和排序清除；全部筛选结果选择只能在范围键、权限范围和数据版本仍匹配时保留，否则必须清理或进入待重新确认态。

导出、下载、复制链接、批量操作和保存视图只能读取当前 `querySnapshot` 或被明确冻结的结果范围快照；不得从当前可见行、旧分页缓存、旧选择数量或旧结果摘要推导范围。

## 权限、反馈和生命周期

权限、租户/工作区、角色、能力开关、认证状态或对象状态变化后，无法同步证明仍安全的旧结果、旧分页、旧排序、旧刷新回调、旧 URL、旧保存视图、旧导出入口、旧选择范围、旧错误和旧可访问名称必须隐藏、失效或替换安全说明。

loading、refreshing、stale、empty、zero-results、invalid-page、error、permission-denied 和 restored 必须声明 `feedbackBinding`。Toast 不能作为唯一错误、唯一刷新失败说明、唯一过期说明或唯一恢复入口。首次加载失败、刷新失败、失效页恢复、权限拒绝和 URL 恢复失败都必须有可聚焦或可到达的恢复入口。

路由变化或 owner 卸载时，结果控制立即进入 disposal：取消或失效请求、防抖、自动刷新、轮询、URL 写入、保存视图写入、分页恢复、焦点迁移和旧回调。旧回调不得重新显示旧结果、旧分页、旧排序、旧摘要、旧错误或旧焦点目标。

## 移动端与响应式

移动端不得删除排序、分页、刷新、结果摘要、错误说明、权限原因、过期说明和恢复路径。低频排序可以进入 Drawer / Action Sheet，页大小可以折叠，跳页可以降级为上一页/下一页，但必须保留当前值、作用范围、禁用原因、恢复入口和焦点返回。

底部分页、固定工具栏、虚拟键盘和 safe-area 不能完全遮挡当前页、下一页、刷新、错误和结果摘要。断点切换时保持同一个 `resultControlsOwnerId`、`querySnapshot`、`requestGeneration` 和在途请求身份；不得重复请求、重复公告、重置结果、清空错误或改变导出范围。

## 完成前检查

- 验证每个可分页、可排序、可刷新或需要结果摘要的结果区域声明 `listResultControlsState`、`resultControlsOwnerId`、`surfaceKind`、`appliedQueryBinding`、`querySnapshot`、`requestGeneration`、`requestPhase`、`sortState`、`paginationState`、`refreshState`、`resultSummary`、`selectionImpact`、`urlHistoryBinding`、`permissionBoundary`、`feedbackBinding` 和 `responsivePolicy`。
- 验证结果控制只能读取已应用查询，不得读取筛选草稿或搜索输入草稿。
- 验证排序变化、页大小变化和有效筛选/关键词变化必须建立新 `querySnapshot`。
- 验证迟到响应不得覆盖当前 owner、当前代次或当前快照不匹配的结果。
- 验证页码分页和游标分页不得在同一快照内混用。
- 验证总数不可靠时不得展示精确总页数、随机跳页或“全部 N 条”的承诺。
- 验证刷新保留旧结果并标记 refreshing/stale，不得把旧结果伪装成新响应。
- 验证旧 URL、浏览器返回和保存视图恢复必须先校验版本、权限、租户/工作区、页大小合法性、排序字段合法性和分页模式。
- 验证移动端不得删除排序、分页、刷新、结果摘要、错误说明、权限原因、过期说明和恢复路径。
- 真实浏览器、移动端、触摸、虚拟键盘、屏幕阅读器、权限切换、网络迟到和数据版本变化未实际执行时，最终报告必须逐项标为**未验证**，并写明所需浏览器、设备/viewport、输入方式及辅助技术环境；不得将静态文档审计写成运行时通过。

## 参考资料

- [WAI-ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [WCAG: Status Messages](https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html)
- [WCAG: Focus Order](https://www.w3.org/WAI/WCAG22/Understanding/focus-order.html)
