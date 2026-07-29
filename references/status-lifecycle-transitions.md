# 状态流转与记录生命周期交互规范

适用于 status lifecycle、status transition、record lifecycle、state machine、publish、unpublish、approve、reject、enable、disable、activate、deactivate、archive、restore、freeze、unfreeze、lock、unlock、draft、published、状态流转、生命周期、记录生命周期、状态机、发布、下线、审批、审核、驳回、启用、停用、激活、归档、恢复、冻结、解冻、锁定、解锁、草稿和已发布。本文件是状态展示、状态变更、生命周期意图、版本快照、结果状态、冲突恢复、权限无泄露、审计回执、批量生命周期变更、可访问性和验收的唯一事实来源。

状态流转按钮、loading、禁用和按钮组继续执行 [按钮交互规范](buttons.md)。高风险、不可逆、外部系统影响或需要强确认的状态变更继续执行 [危险操作与恢复交互规范](risk-actions.md)。状态流转如果允许乐观更新、先改状态、撤销、失败回滚、自动重试、离线队列或迟到响应协调，必须同时执行 `references/optimistic-update-undo.md`；本文件继续负责当前已证明状态、目标状态、转换意图和生命周期结果，乐观 mutation owner 负责 pending 投影、非终态标记、回滚依据、幂等和权威结果合并。审批、审核、提交审批、通过、驳回、撤回、转交、加签、委托、催办、待办和批量审批必须同时执行 `references/approval-workflows.md`；本文件继续负责生命周期状态，`approval-workflows.md` 负责审批实例、节点、审批人、意见/附件、通知、审计和工作流决策快照。权限、租户/工作区、可见性和无泄露继续执行 [权限、租户与可见性交互规范](permissions-tenancy-visibility.md)。审计回执、操作历史和追溯继续执行 [审计日志与操作历史交互规范](audit-log-activity-history.md)。异步状态变更、任务中心和结果领取继续执行 [异步任务与任务中心交互规范](async-jobs-task-center.md)。批量状态变更的选择快照、筛选快照、分页和部分成功继续执行 [数据表格交互规范](data-tables.md)。只读详情、状态标签和对象摘要继续执行 [信息展示与详情页交互规范](information-display.md)。移动端承载继续执行 [响应式与自适应交互规范](responsive-adaptive.md)。

从行操作、记录菜单、卡片操作、右键菜单或长按菜单触发的单条状态流转必须同时执行 `references/row-contextual-actions.md`。生命周期 owner 负责当前状态、目标状态、转换意图和结果；行操作 owner 负责 `rowActionState`、recordIdentity、sourceSnapshot、availabilityMap、requestIdentity 和旧行防护。

## 范围与边界

本 owner 覆盖：

- 记录生命周期、对象状态、状态机、状态标签、状态详情、状态原因、状态变更入口、状态变更确认、状态结果、状态冲突、状态恢复和状态审计。
- 启用、停用、发布、下线、审批、审核、驳回、归档、恢复、冻结、解冻、锁定、解锁、激活、暂停、恢复运行、提交审核、撤回审核、设为草稿和设为已发布。
- 单条记录状态变更、批量状态变更、详情页状态变更、表格行操作状态变更、配置页生命周期、异步状态流转和移动端状态承载。

本 owner 不覆盖：

- 后端状态机、工作流引擎、审批引擎、数据库锁、事件溯源、接口幂等或任务调度实现。
- 某个业务项目的状态枚举、审批角色、状态颜色、按钮文案、接口字段或数据模型。
- 纯展示型状态标签的视觉设计；视觉仍归设计系统，状态语义归本 owner。

## `lifecycleState`

每个可展示或变更生命周期的对象必须声明 `lifecycleState`：

| 字段 | 语义 |
| --- | --- |
| `lifecycleOwnerId` | 当前状态展示、状态详情或状态变更 owner 的稳定身份。 |
| `lifecycleSurface` | `list-row`、`detail-header`、`status-card`、`toolbar`、`bulk-action`、`dialog`、`drawer`、`task-result`、`mobile-sheet`。 |
| `currentStatus` | 当前已证明状态、状态标签、状态原因、状态来源和可见说明。 |
| `targetStatus` | 本次意图要变更到的目标状态；无状态变更意图时为 `null`。 |
| `statusSource` | 来源系统、更新时间、刷新时间、数据延迟、状态版本和状态可信度。 |
| `versionSnapshot` | 对象版本、状态版本、权限版本、租户/工作区、资源版本、列表/详情快照和请求身份。 |
| `transitionIntent` | 冻结后的状态变更意图，包含来源、对象、当前状态、目标状态、影响范围、确认策略和请求身份。 |
| `transitionPolicy` | 当前可用转移动作、禁止原因、风险等级、确认要求、异步策略和恢复策略。 |
| `transitionResult` | success、failure、partial-success、conflict、stale、unknown、queued、processing、cancelled-client-only。 |
| `permissionBoundary` | 查看状态、查看原因、查看可用动作、提交变更、批量变更、查看结果和查看审计的权限边界。 |
| `auditReceipt` | 请求身份、审计回执、操作历史、任务身份和追溯入口。 |
| `recoveryPolicy` | 失败、冲突、未知、异步处理中、无权限、过期和部分成功后的恢复入口。 |
| `feedbackState` | loading、confirming、submitting、processing、success、failure、partial、conflict、unknown、stale、permission-denied。 |
| `a11yPolicy` | 状态名称、状态原因、可用动作、禁用原因、结果公告、焦点目标和颜色非唯一语义。 |
| `responsivePolicy` | 移动端状态、原因、动作、确认、结果、审计和恢复路径保留策略。 |

状态展示和状态变更不得共用一个含糊 status 字段。`status` 可以是后端字段名，但产品交互必须拆出当前已证明状态、目标状态、草稿/预览、处理中、结果和恢复策略。

## 状态展示与状态变更边界

状态 badge、按钮 loading、乐观 UI、Toast 文案或本地缓存不得伪装成已完成状态流转。状态 badge 只表达 `currentStatus`；状态变更按钮只表达当前允许的 `transitionPolicy`；loading 只表达提交中或处理中；Toast 只能辅助提示结果，不能替代 `transitionResult`、审计回执或恢复路径。

Hover、focus、active、pressed visual、草稿、预览、确认页摘要、乐观更新、禁用态和本地筛选高亮都不是已提交生命周期。只有服务端或权威来源返回的状态结果，且匹配当前 `versionSnapshot`、`transitionIntent`、权限版本、租户/工作区和请求身份，才能更新 `currentStatus`。

如果业务允许乐观更新，必须显式显示 optimistic / syncing / processing 状态，并保留回滚、刷新、查看任务或查看审计路径。乐观状态不得覆盖真实状态原因、状态版本或冲突说明。

## 转换意图、版本快照和提交

每次启用、停用、发布、下线、审批、审核、驳回、归档、恢复、冻结、解冻、锁定、解锁、激活、暂停、提交审核、撤回审核或类似状态变更，必须创建不可变 `transitionIntent`。

没有冻结对象版本、权限版本、当前状态、目标状态、租户/工作区和请求身份，不得提交状态变更。冻结快照至少包含对象 ID、对象版本、状态版本、当前状态、目标状态、权限版本、租户/工作区、数据范围、影响范围、确认策略、来源 owner、请求身份和时间。

提交请求只能读取已冻结 `transitionIntent`，不得读取当前 hover、active、未提交表单草稿、临时状态预览、旧按钮 data 属性、旧详情缓存或当前页面可见行。确认页、二次确认、输入确认、批量摘要和审计回执展示的对象、状态和影响范围必须来自同一个冻结意图。

版本冲突、权限变化、租户切换、对象删除、状态已变化或业务限制变化时，旧意图必须失效。旧意图失效后，必须阻止提交、说明原因，并提供重新加载、重新确认、返回列表、查看当前状态或申请权限路径。

## 结果状态、异步和恢复

transitionResult 必须区分 success、failure、partial-success、conflict、stale、unknown、queued、processing 和 cancelled-client-only。不得把 conflict、stale、unknown、queued 或 processing 写成 success；不得把客户端关闭写成服务端取消。

状态变更成功后，必须说明当前状态、目标对象、影响范围、更新时间、状态来源和审计回执或未验证边界。失败后必须说明失败原因、是否已改变状态、恢复入口和是否可重试。未知结果必须提供检查状态、刷新、查看任务中心、查看审计或联系支持路径。

异步状态变更创建任务时，当前页面只能表达任务已创建、处理中、可取消请求已发送或等待结果；最终生命周期必须由任务结果、状态刷新或审计回执证明。关闭 Dialog、Drawer、Toast、Notification、来源页面、浏览器 Tab 或移动端系统返回，只能表达客户端关闭或停止等待，不得伪装成服务端状态已取消。

## 权限、安全和审计

状态流转必须复核权限、租户/工作区、对象版本、当前状态、目标状态和可用转移动作。状态入口隐藏、禁用、只读、未启用、无权限和业务不可流转不是同一件事；必须分别说明，并执行权限 owner 的无泄露规则。

无权限状态流转不得泄露当前状态、下一步动作、不可见原因、对象数量、批量影响范围、审批意见、拒绝原因、内部状态码、任务结果或旧缓存。无权限可以显示安全泛化说明、申请权限、切换租户/工作区或重新认证路径。

成功、失败、部分成功、冲突、未知和异步完成必须关联 `auditReceipt`、任务身份或操作历史；若未实际验证审计链路，必须标为审计未验证。审计回执不能只存在于 Toast；必须能从结果区、详情页、任务中心或操作历史恢复。

## 批量状态变更

批量状态变更不得用当前页面可见行替代选择快照、筛选快照、权限版本和目标摘要。批量启用、停用、发布、下线、审批、驳回、归档、恢复、冻结、解冻、锁定和解锁必须冻结目标集合、排除集合、不可操作集合、权限版本、筛选快照、当前状态分布、目标状态、影响范围和请求身份。

批量结果必须区分全部成功、部分成功、全部失败、冲突、未知和处理中。部分成功不得只写“操作完成”；必须展示成功数量、失败数量、跳过数量、冲突数量、失败原因分类、可重试范围、不可重试范围、导出错误明细和审计回执。

批量状态变更后，旧选择、旧筛选、旧分页、旧状态分布、旧批量按钮和旧结果回执必须按结果快照失效或刷新；不得让旧可见行继续显示为可操作。

## 可访问性和移动端

状态、状态原因、可用动作、禁用原因、确认风险、结果和恢复路径不能只靠颜色、图标、位置、hover、tooltip、toast 或相对时间表达。状态标签必须有可访问名称；状态变化、提交中、冲突、未知、部分成功、失败和恢复成功必须由唯一 owner 公告。

焦点必须在状态入口、确认面、错误摘要、结果区、恢复入口和审计入口之间只迁移一次。状态变更失败后，焦点进入错误摘要或恢复入口；成功后进入结果摘要或更新后的状态区域；冲突后进入当前状态说明。

移动端不得删除当前状态、状态原因、可用动作、禁用原因、确认、结果回执、审计入口或恢复路径。移动端可以把复杂状态说明、批量状态分布、审批意见或确认摘要放入 Drawer / Bottom Sheet / 独立页，但必须保持当前状态、目标状态、影响范围、提交、取消、结果、审计和恢复可达。

低高度、虚拟键盘、动态 viewport、四向 safe area、系统字体放大、200% 缩放、触摸、系统返回、WebView 返回和浏览器 Back 下，状态原因、确认、结果回执、任务入口、审计入口和恢复路径必须可达。

## 生命周期和清理

每个生命周期 owner 必须登记状态查询、状态订阅、状态变更请求、异步任务、确认面、延迟回调、焦点任务、公告、审计回执和恢复入口。权限变化、租户/工作区切换、路由变化、owner 卸载、对象版本变化、状态版本变化或旧意图失效时，旧请求、旧订阅、旧确认、旧按钮状态、旧结果、旧审计入口、旧 ARIA 引用和旧焦点任务必须取消或失效。

迟到状态结果必须匹配 `lifecycleOwnerId`、`transitionIntent`、`versionSnapshot`、`permissionBoundary`、租户/工作区和请求身份。失配结果只能丢弃或转入安全恢复；不得覆盖当前状态、清除当前错误、释放其他 owner 的 loading，或触发旧焦点恢复。

## 完成前检查

- 验证每个状态展示、状态详情、状态变更、批量生命周期变更或异步状态结果声明 `lifecycleState`、`lifecycleOwnerId`、`lifecycleSurface`、`currentStatus`、`targetStatus`、`statusSource`、`versionSnapshot`、`transitionIntent`、`transitionPolicy`、`transitionResult`、`permissionBoundary`、`auditReceipt`、`recoveryPolicy`、`feedbackState`、`a11yPolicy` 和 `responsivePolicy`。
- 验证状态 badge、按钮 loading、乐观 UI、Toast 文案或本地缓存不得伪装成已完成状态流转。
- 验证状态展示和状态变更不得共用一个含糊 status 字段，必须区分当前已证明状态、目标状态、草稿/预览、处理中和结果。
- 验证没有冻结对象版本、权限版本、当前状态、目标状态、租户/工作区和请求身份，不得提交状态变更。
- 验证版本冲突、权限变化、租户切换、对象删除、状态已变化或业务限制变化时，旧意图必须失效。
- 验证 transitionResult 必须区分 success、failure、partial-success、conflict、stale、unknown、queued、processing 和 cancelled-client-only。
- 验证无权限状态流转不得泄露当前状态、下一步动作、不可见原因、对象数量、批量影响范围、审批意见、拒绝原因、内部状态码、任务结果或旧缓存。
- 验证批量状态变更不得用当前页面可见行替代选择快照、筛选快照、权限版本和目标摘要。
- 验证移动端不得删除当前状态、状态原因、可用动作、禁用原因、确认、结果回执、审计入口或恢复路径。
- 真实浏览器、键盘、屏幕阅读器、触摸、权限切换、版本冲突、异步任务和移动端视口未实际执行时，必须明确标为未验证，并列出所需验证。

## 参考资料

- [WAI-ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [WCAG: Status Messages](https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html)
- [WCAG: Focus Order](https://www.w3.org/WAI/WCAG22/Understanding/focus-order.html)
- [WCAG: Error Identification](https://www.w3.org/WAI/WCAG22/Understanding/error-identification.html)
