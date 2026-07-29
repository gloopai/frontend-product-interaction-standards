# 批量操作与批处理动作交互规范

适用于批量操作、批处理动作、批量动作、批量选择操作、批量提交、批量删除、批量停用、批量启用、批量归档、批量恢复、批量导出、批量审批、批量移动、批量分配、批量打标签、批量改状态、全部筛选结果操作、当前页批量、跨页批量、部分成功、批量确认、批量回执、batch operation、bulk action、bulk operation、bulk selection action、mass action、multi-record action、apply to selected、apply to all filtered、partial success、bulk confirmation 和 bulk receipt。

本文件是批量操作与批处理动作 owner。批量操作不是“对当前可见行循环单条操作”，也不是“选择数量 + 一个按钮”。它必须证明目标集合、选择范围、可执行性、确认、请求、结果拆分、恢复、权限和审计边界。行选择、全选、分页、排序和表格展示继续执行 `references/data-tables.md`；卡片选择继续执行 `references/card-list-results.md`；触发按钮继续执行 `references/buttons.md`；危险批量操作继续执行 `references/risk-actions.md`；批量删除、批量恢复、批量永久删除、清空回收站和保留期到期清理必须同时执行 `references/trash-restore-retention.md`，批量 owner 负责目标集合和部分成功，回收站 owner 负责 `trashRestoreState`、保留期、恢复/永久删除和旧入口清理；批量审批继续执行 `references/approval-workflows.md`；批量导出和错误明细下载继续执行 `references/exports-downloads-artifacts.md`；权限和租户收敛继续执行 `references/permissions-tenancy-visibility.md`；部分成功、未知和恢复承载继续执行 `references/feedback-states.md`；异步长任务继续执行 `references/async-jobs-task-center.md`。

批量分配、批量授权、批量移动到已分配、批量从已分配移除、穿梭框全选当前结果、全选全部候选和跨页分配必须同时执行 `references/transfer-assignment-lists.md`，并声明 `assignmentTransferState`。批量 owner 负责范围、部分成功和恢复；分配列表 owner 负责左右集合、选中桶、移动意图、diff 摘要和保存边界。

## 范围与边界

本 owner 覆盖：

- 由表格、卡片列表、结果列表、审批列表、任务列表、成员列表、文件列表或报表明细触发的多对象操作。
- 当前页、已选择项、全部筛选结果、跨页集合、排除项集合和基于固定查询快照的批量范围。
- 批量删除、停用、启用、归档、恢复、移动、分配、打标签、修改状态、提交审批、审批通过/驳回、导出、下载、重试、取消、重新生成和同步。
- 批量确认、强确认、权限排除、不可操作项、幂等请求、异步执行、部分成功、未知结果、结果回执、错误明细、重试范围和恢复入口。

本 owner 不覆盖：

- 后端队列、数据库事务、分片执行、重试算法或具体接口协议。
- 单条记录编辑、新增记录、单元格编辑或列表内嵌编辑；这些继续执行 `references/record-editing-surfaces.md`。
- 纯展示列表、报表只读明细和无选择动作的静态结果区。

## `bulkActionState`

每个批量工具栏、批量确认、批量请求、批量任务和批量结果必须声明 `bulkActionState`：

| 字段 | 语义 |
| --- | --- |
| `bulkActionOwnerId` | 当前批量操作 owner 的稳定身份。 |
| `bulkSurface` | `table-bulk-toolbar`、`card-bulk-toolbar`、`result-bulk-toolbar`、`approval-bulk`、`export-bulk`、`task-bulk`、`mobile-bulk-sheet` 等承载面。 |
| `actionKind` | 本次批量动作类型，例如删除、停用、启用、归档、恢复、审批、导出、分配、打标签、移动、重试或取消。 |
| `selectionSnapshot` | 用户形成批量意图时冻结的选择状态、来源 owner、选择版本、查询版本和可见摘要。 |
| `scopeBinding` | 当前页、已选择项、全部筛选结果、跨页集合、排除集合或固定查询快照的范围绑定。 |
| `targetIdentitySet` | 可被本次批量请求识别的目标集合、集合版本、对象身份和数量边界。 |
| `eligibilityMap` | 每个目标或目标分组的可操作性、不可操作原因、权限排除、状态冲突和跳过策略。 |
| `excludedTargetSet` | 用户取消选择、权限排除、状态不适用、数据失效或确认时排除的目标集合。 |
| `impactSummary` | 操作影响、风险等级、目标数量、字段/状态变化、不可逆性、异步性和审计影响。 |
| `confirmationPolicy` | 是否需要确认、强确认、输入确认、分组确认、二次确认或风险 owner 转交。 |
| `requestIdentity` | 幂等键、权限版本、租户/工作区、数据版本、查询快照、发起人和来源 owner。 |
| `executionPhase` | idle、selecting、confirming、ready、submitting、processing、partial-succeeded、succeeded、failed、conflict、unknown、cancelled、expired。 |
| `partialResult` | 成功、失败、跳过、冲突、未知、处理中和不可重试对象范围及数量。 |
| `resultReceipt` | 操作结果、审计回执、任务身份、错误明细、导出产物、通知关系和完成时间。 |
| `recoveryActions` | 重试失败项、重试未知项、下载错误明细、查看任务、查看审计、刷新范围、申请权限、返回列表。 |
| `permissionBoundary` | 查看目标、执行动作、查看结果、下载明细、查看审计和重试恢复所需权限版本。 |
| `feedbackBinding` | 页面结果区、批量条、任务中心、Toast、Notification、Inline Feedback 和错误摘要的归属。 |
| `responsivePolicy` | 移动端批量条、底部面板、确认、错误明细、任务入口和恢复路径保留策略。 |
| `focusAnnouncementPolicy` | 选择变化、确认打开、提交、部分成功、失败、未知、权限变化和恢复的焦点与公告策略。 |
| `lifecycleDisposal` | 路由变化、筛选变化、权限变化、数据版本变化、owner 卸载和结果关闭时的清理规则。 |
| `runtimeVerification` | 真实浏览器、键盘、读屏、触摸、分页/筛选变化、权限切换、弱网、异步任务和移动端验证状态；未执行必须标为未验证。 |

批量操作必须冻结 selectionSnapshot、scopeBinding、targetIdentitySet、eligibilityMap、permissionBoundary 和 requestIdentity。不得只用 `selectedIds`、`checkedRows`、`allSelected`、按钮 loading、Toast、后端 200 或当前可见 DOM 行替代 `bulkActionState`。

## 范围绑定和目标集合

当前页、已选择项、全部筛选结果、跨页集合和排除项集合必须用不同 scopeBinding 表达。范围文案、确认标题、请求参数、结果回执、错误明细和审计摘要必须使用同一个范围定义。

“全部筛选结果”不是“当前页全选”。它必须冻结已应用筛选、关键词、排序、权限版本、租户/工作区、数据版本和查询身份。分页、游标、虚拟滚动、懒加载或卡片瀑布流不得把未加载对象静默排除。

跨页批量必须明确是否允许排除个别目标。存在排除项时，`excludedTargetSet` 必须在确认、结果和审计中可追溯。排除不能只存在于前端 checkbox 状态，也不能在刷新后丢失。

筛选、搜索、排序、分页、权限、租户/工作区、数据版本或 eligibility 变化后，旧批量意图必须失效、刷新或重新确认。不得让旧选择快照继续触发新范围的请求。

## 可执行性和确认

批量操作必须在提交前计算 `eligibilityMap`。不可操作项、权限排除项、状态冲突项、已失效项和需要拆分确认的目标不得被静默丢弃。用户看到的目标数量必须区分总目标、可执行、不可执行、排除、未知和需异步确认。

危险、不可逆、权限变更、敏感导出、跨租户/工作区、批量删除、批量停用、批量归档、批量审批和大范围修改必须转交 `references/risk-actions.md`，并把 `impactSummary` 作为强确认依据。确认按钮不得读取新的 hover、active option、筛选草稿或旧批量条 DOM。

批量确认可以使用 Dialog、Drawer、Bottom Sheet 或独立页，但不能把批量编辑字段内嵌回列表。复杂批量配置、多字段映射、批量分配、批量打标签和需要预览差异的操作，应升级到 Drawer 或独立页；列表页面只保留选择、摘要和入口。

## 请求、执行和部分成功

批量请求必须绑定 `requestIdentity`，并具备幂等和重复触发防护。点击、Enter、Space、触摸、菜单重放、浏览器返回恢复和迟到响应都不得创建额外请求或覆盖新一轮批量结果。

执行阶段必须区分提交中、处理中、已完成、部分成功、失败、冲突、未知、已取消和已过期。异步长任务必须进入任务中心或可回访的结果页；关闭确认面、关闭 Toast、离开列表或移动端系统返回不等于服务端取消。

部分成功必须区分成功、失败、跳过、冲突、未知和处理中对象范围。结果不得只给一个“处理完成”提示；必须提供错误明细、失败原因、可重试范围、不可重试说明、审计入口或任务详情。

批量结果不得只用 Toast 表达；必须有 resultReceipt、partialResult 和 recoveryActions。Toast、Snackbar 或 Notification 可以辅助提示，但不能成为唯一结果回执、唯一错误明细、唯一恢复入口或唯一审计凭证。

## 权限、安全和无泄露

无权限或权限降级不得泄露旧目标名称、数量、字段、失败明细、导出范围、内部 ID 或旧回执。权限待解析时显示安全占位或泛化说明，不得闪现旧批量条、旧选中数量、旧目标摘要、旧错误明细、旧导出文件名或旧 ARIA label。

权限、租户/工作区、角色、对象状态或数据版本变化后，批量条、确认面、请求、结果、任务入口、错误明细、下载链接、审计入口、焦点任务和公告必须原子收敛。无法证明安全的旧状态必须先失效，再重新计算。

批量导出、错误明细下载、审计导出和结果产物领取必须再次复核下载权限、产物身份和有效期。旧下载链接、旧通知入口、旧任务入口或旧文件名不能作为权限证明。

## 可访问性和移动端

批量选择数量、范围、不可操作项、风险、提交中、部分成功、失败、未知和恢复路径必须有可访问名称或描述，不能只靠颜色、图标、位置、Toast、tooltip 或 hover 表达。

焦点必须在选择控件、批量工具栏、确认标题、错误摘要、结果区、任务入口和恢复入口之间只迁移一次。选择变化、范围切换、确认打开、提交、部分成功、权限变化、未知结果和恢复完成必须由唯一 owner 公告。

移动端可以把批量工具栏转为底部操作条、Bottom Sheet、Drawer 或独立页，但不得删除范围摘要、目标数量、不可操作项、确认、结果回执、错误明细、任务入口、审计入口和恢复路径。低高度、虚拟键盘、动态 viewport、四向 safe area、系统字体放大、200% 缩放、触摸、系统返回和浏览器 Back 下，这些能力仍必须可达。

## 生命周期和清理

每个批量 owner 必须登记选择订阅、查询快照、权限版本、租户/工作区、eligibility 计算、确认面、请求、任务订阅、结果回执、错误明细、下载入口、审计入口、焦点任务和公告。

路由变化、owner 卸载、筛选/搜索/排序/分页变化、权限变化、租户/工作区变化、数据版本变化、任务完成、结果关闭或恢复后，旧选择快照、旧确认、旧请求、旧任务订阅、旧错误明细、旧下载链接、旧审计入口、旧 DOM、旧 ARIA 引用和旧焦点任务必须取消、失效或重算。

## 完成前检查

1. **owner 声明**：批量入口、确认、请求、任务和结果声明 `bulkActionState`。
2. **范围冻结**：`selectionSnapshot`、`scopeBinding`、`targetIdentitySet`、`eligibilityMap`、`permissionBoundary` 和 `requestIdentity` 已冻结。
3. **范围语义**：当前页、已选择项、全部筛选结果、跨页集合和排除项集合没有混用。
4. **失效规则**：筛选、搜索、排序、分页、权限、租户/工作区、数据版本或 eligibility 变化后旧意图不会继续提交。
5. **确认策略**：危险、不可逆、敏感、批量审批和大范围操作转交风险 owner。
6. **部分成功**：成功、失败、跳过、冲突、未知和处理中范围可见，并提供恢复路径。
7. **Toast 边界**：Toast 不是唯一结果、唯一错误、唯一审计或唯一恢复。
8. **权限无泄露**：权限降级和无权限不泄露旧目标名称、数量、字段、失败明细、导出范围、内部 ID 或旧回执。
9. **移动端保真**：移动端保留范围摘要、目标数量、确认、结果、错误明细、任务入口、审计入口和恢复。
10. **运行时报告**：真实浏览器、键盘、读屏、触摸、分页/筛选变化、权限切换、弱网、异步任务和移动端未执行时必须标为未验证。
