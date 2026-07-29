# 行操作与上下文操作交互规范

适用于行操作、记录操作、上下文操作、更多操作、行更多菜单、卡片操作、列表项操作、记录菜单、右键菜单、长按菜单、操作列、固定操作列、悬浮行操作、批内单条操作、单条删除、单条编辑、单条停用、单条启用、单条归档、单条恢复、单条复制、单条导出、row action、row actions、contextual action、record action、item action、card action、action column、more actions、context menu、overflow menu 和 per-record action。

本文件是行操作与上下文操作 owner。行操作不是“在当前行 DOM 上挂一个按钮”，也不是“更多菜单里放几个命令”。它必须证明动作目标、来源快照、权限、可用性、风险、请求身份、结果回执、迟到响应、虚拟列表、移动端和生命周期。

表格行、列、选择、分页和虚拟滚动继续执行 `references/data-tables.md`；卡片身份和卡片操作区继续执行 `references/card-list-results.md`；按钮语义继续执行 `references/buttons.md`；更多菜单、Context Menu、Action Sheet 和浮层定位继续执行 `references/overlays-menus-tooltips.md`；新增/编辑/复制创建承载面继续执行 `references/record-editing-surfaces.md`；危险动作继续执行 `references/risk-actions.md`；删除后恢复、软删除、归档恢复、永久删除和回收站入口必须同时执行 `references/trash-restore-retention.md`，行操作 owner 负责动作触发和 `rowActionState`，回收站 owner 负责 `trashRestoreState`、保留期、恢复和旧入口清理；权限和租户无泄露继续执行 `references/permissions-tenancy-visibility.md`；详情预览继续执行 `references/preview-pane.md`；状态流转继续执行 `references/status-lifecycle-transitions.md`；移动端继续执行 `references/responsive-adaptive.md`。

## 范围与边界

本 owner 覆盖：

- 表格行操作、卡片操作、列表项操作、详情预览入口、行内更多菜单、右键菜单、长按菜单、固定操作列、悬浮操作和移动端 Action Sheet。
- 查看详情、预览、编辑、复制创建、删除、停用、启用、归档、恢复、复制字段、导出单条、下载单条、审批单条、重试单条、取消任务、查看审计、查看历史和打开外部系统。
- 操作可见性、禁用原因、权限变化、记录状态变化、过期行、虚拟行复用、迟到菜单回调、请求去重、结果回执和恢复入口。

本 owner 不覆盖：

- 批量操作；多对象范围和部分成功继续执行 `references/bulk-actions-batch-operations.md`。
- 记录编辑表单本身；新增、编辑、复制创建和配置流程必须转交 `references/record-editing-surfaces.md`。
- 浮层定位、碰撞和焦点陷阱底层细节；这些继续由浮层或容器 owner 负责。

## `rowActionState`

每个行操作区、卡片操作区、行更多菜单、右键菜单、长按菜单或单条记录动作必须声明 `rowActionState`：

| 字段 | 语义 |
| --- | --- |
| `rowActionOwnerId` | 当前行操作 owner 的稳定身份。 |
| `actionSurface` | `table-row`、`fixed-action-column`、`card-actions`、`preview-actions`、`row-menu`、`context-menu`、`mobile-action-sheet`。 |
| `recordIdentity` | 记录 ID、对象类型、租户/工作区、数据版本、来源列表 owner 和可安全展示摘要。 |
| `sourceSnapshot` | 触发动作时的行/卡片/预览快照、分页、排序、筛选、数据版本、权限版本和状态版本。 |
| `actionCatalog` | 当前记录可用动作集合、动作对象、分组、排序、危险等级、低频收纳和移动端映射。 |
| `availabilityMap` | 每个动作的 visible、hidden-by-permission、disabled-by-state、disabled-by-permission、read-only、not-applicable。 |
| `disabledReasonPolicy` | 禁用原因、只读原因、不可用原因、可见范围、可访问描述和无泄露策略。 |
| `triggerPolicy` | 点击、键盘、菜单项、右键、长按、快捷键、触摸和程序恢复入口的触发策略。 |
| `requestIdentity` | 幂等键、动作类型、记录身份、权限版本、状态版本、来源 owner、发起者和请求代次。 |
| `resultReceipt` | 成功、失败、冲突、未知、权限拒绝、审计回执、任务身份和恢复入口。 |
| `riskHandoff` | 删除、停用、归档、权限变更、取消任务、重跑、不可逆和高影响动作的风险 owner 转交。 |
| `editSurfaceHandoff` | 编辑、复制创建、配置和字段保存的编辑承载面转交。 |
| `navigationBinding` | 查看详情、预览、打开外部系统、返回列表和来源上下文恢复策略。 |
| `permissionBoundary` | 查看记录、查看动作、执行动作、查看结果、查看审计和下载产物的权限版本。 |
| `feedbackBinding` | 行内状态、菜单状态、页面结果区、Toast、任务中心、审计入口和错误摘要归属。 |
| `responsivePolicy` | 窄屏、触摸、卡片化、Action Sheet、长按菜单和移动端返回策略。 |
| `focusAnnouncementPolicy` | 打开菜单、动作提交、确认打开、禁用原因、结果、权限变化和恢复的焦点与公告策略。 |
| `lifecycleDisposal` | 虚拟行复用、分页/筛选变化、权限变化、记录状态变化、菜单关闭、路由变化和 owner 卸载时的清理规则。 |
| `runtimeVerification` | 真实浏览器、键盘、读屏、触摸、右键、长按、虚拟列表、权限切换、移动端和缩放验证状态；未执行必须标为未验证。 |

不得只用按钮 onClick、菜单项 key、当前行 DOM、rowIndex、record 对象引用、disabled、hidden、后端 403、Toast 或组件库默认 action column 替代 `rowActionState`。

## 动作目标、来源快照和旧行防护

行操作必须绑定 `recordIdentity` 和 `sourceSnapshot`。动作触发时读取的是冻结的记录身份、状态版本、权限版本和来源 owner；不得在请求发送时重新读取当前 hover row、当前 active row、虚拟列表 DOM、菜单闭包里的旧 record 或 rowIndex。

虚拟列表、分页、筛选、排序、自动刷新、权限变化、记录状态变化或卡片重排后，旧行操作、旧菜单、旧确认、旧请求和旧结果必须失效、重算或重新确认。虚拟行复用不得让旧菜单项操作新记录，也不得让新记录继承旧禁用原因、旧 aria-label 或旧 handler。

右键菜单、长按菜单和悬浮行操作不能是唯一入口；关键动作必须有键盘和触摸可达的等价入口。

## 动作可见性、禁用和菜单

visible、hidden-by-permission、disabled-by-state、disabled-by-permission、read-only 和 not-applicable 不是同一件事。禁用不是安全边界；无权限动作不得保留 handler、快捷键、菜单项请求路径或可泄露的 tooltip。

更多菜单可以收纳低频动作，但不能隐藏唯一的危险确认、权限原因、错误恢复或核心任务入口。菜单项必须描述动作对象，例如“停用用户”“归档项目”，不得只有“操作”“更多”“处理”“确认”。

危险动作必须保留风险标记、影响范围、确认策略、请求身份、结果回执和审计回执，并转交 `references/risk-actions.md`。编辑、复制创建和配置动作只能是入口，必须转交 `references/record-editing-surfaces.md`，不能在行内或菜单内承载字段表单。

## 请求、结果和恢复

行操作请求必须绑定 `requestIdentity`。点击、Enter、Space、触摸、右键选择、长按选择、快捷键、事件重放和菜单重复点击只能产生一个等价请求或被拒绝。

操作结果必须区分 succeeded、failed、conflict、unknown、permission-denied、cancelled、processing 和 expired。关闭菜单、关闭 Toast、关闭确认、离开列表或移动端系统返回不等于服务端动作取消。

Toast 不能作为唯一结果回执、唯一错误说明、唯一审计凭证或唯一恢复入口。失败、冲突、未知和权限拒绝必须提供刷新记录、查看详情、查看任务、查看审计、重试、申请权限或返回列表路径。

## 权限、安全和无泄露

无权限或权限降级不得泄露记录名称、字段值、状态、动作数量、菜单项、禁用原因、文件名、错误明细、审计摘要、内部 ID、旧 aria-label、旧 tooltip 或旧菜单缓存。权限待解析时应隐藏或显示安全占位，不得闪现旧动作。

权限、租户/工作区、角色、记录状态、状态版本或数据版本变化后，动作目录、菜单项、按钮、确认、请求、结果、审计入口、下载入口、焦点任务和公告必须原子收敛。

## 可访问性和移动端

每个行操作入口必须有可访问名称，包含动作和对象；图标按钮、更多按钮、固定列按钮、右键入口和移动端 Action Sheet 入口都不能只依赖图标、位置、hover、tooltip 或颜色。

打开菜单、展开 Action Sheet、提交动作、确认打开、禁用原因、失败、冲突、未知、权限变化和恢复完成必须由唯一 owner 公告。焦点在触发器、菜单项、确认面、错误摘要、结果区和恢复入口之间只迁移一次。

移动端可以把行操作转为 Action Sheet、Bottom Sheet、Drawer 或卡片操作区，但不得删除查看、编辑、关键恢复、危险确认、权限说明、审计入口或返回路径。右键和 hover 行操作必须有触摸等价入口。

## 生命周期和清理

每个行操作 owner 必须登记记录身份、动作目录、权限版本、状态版本、菜单实例、确认实例、请求、任务订阅、结果回执、审计入口、下载入口、焦点任务和公告回调。

分页、筛选、排序、刷新、虚拟行复用、卡片重排、权限变化、租户/工作区变化、记录状态变化、菜单关闭、确认关闭、路由变化或 owner 卸载后，旧菜单、旧按钮、旧 handler、旧请求、旧确认、旧结果、旧审计入口、旧下载入口、旧 DOM、旧 ARIA 引用和旧焦点任务必须取消、失效或重算。

## 完成前检查

1. **owner 声明**：行操作区、卡片操作区、更多菜单、右键菜单、长按菜单或单条动作声明 `rowActionState`。
2. **目标冻结**：动作触发读取冻结的 `recordIdentity`、`sourceSnapshot`、权限版本和状态版本。
3. **旧行防护**：虚拟行复用、分页、筛选、排序、自动刷新和权限变化后旧菜单不能操作新记录。
4. **可见性语义**：visible、hidden-by-permission、disabled-by-state、disabled-by-permission、read-only 和 not-applicable 没有混用。
5. **菜单边界**：更多菜单不隐藏唯一危险确认、权限原因、错误恢复或核心任务入口。
6. **转交正确**：危险动作转交风险 owner；编辑/复制创建/配置转交记录编辑承载面；查看/预览转交导航或预览 owner。
7. **结果回执**：Toast 不是唯一结果、错误、审计或恢复路径。
8. **权限无泄露**：无权限不泄露记录名称、字段值、状态、动作数量、菜单项、禁用原因、内部 ID、旧 tooltip 或旧 aria-label。
9. **移动端保真**：移动端保留查看、编辑、关键恢复、危险确认、权限说明、审计入口和返回路径。
10. **运行时报告**：真实浏览器、键盘、读屏、触摸、右键、长按、虚拟列表、权限切换、移动端和缩放未执行时必须标为未验证。
