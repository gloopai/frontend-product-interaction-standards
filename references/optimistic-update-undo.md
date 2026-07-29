# 乐观更新、撤销与回滚交互规范

适用于乐观更新、乐观 UI、先改界面、预提交状态、同步中、撤销、撤回、回滚、失败回滚、部分回滚、重试、冲突恢复、操作排队、离线队列、弱网恢复、重复提交、迟到响应、幂等、optimistic update、optimistic UI、optimistic mutation、pending mutation、syncing、undo、undo action、rollback、revert、retry mutation、queued mutation、offline queue、late response、idempotency 和 conflict recovery。

本文件是乐观更新、撤销窗口、失败回滚和 mutation 协调的 owner。它负责 mutation 身份、来源快照、可见投影、权威提交、撤销语义、回滚依据、冲突处理、服务端回执、迟到结果、权限收敛、焦点公告和生命周期清理。按钮入口、loading 和防重复读取 `references/buttons.md`；表单字段、dirty、校验和提交生命周期读取 `references/forms.md`；危险操作、确认、撤销窗口、审计和恢复读取 `references/risk-actions.md`；状态流转和生命周期结果读取 `references/status-lifecycle-transitions.md`；列表结果刷新、stale、分页和选择影响读取 `references/list-result-controls.md`；卡片字段投影和操作区读取 `references/card-list-results.md`；页面/区域反馈和恢复入口读取 `references/feedback-states.md`；权限、租户、可见性和旧缓存无泄露读取 `references/permissions-tenancy-visibility.md`；移动端、弱网、触摸和安全区域读取 `references/responsive-adaptive.md`。

乐观更新不是成功回执，也不是绕过确认、权限、审计或服务端权威状态的捷径。任何先于权威结果展示的变化都必须被标记为 pending、syncing、undoable、queued 或产品声明的非终态；不得把它展示成已完成、已生效或已审计。

## `optimisticMutationState`

每个允许先改 UI、展示 pending 结果、提供撤销、失败回滚、离线队列、自动重试或迟到结果协调的操作必须声明 `optimisticMutationState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `mutationOwnerId` | 当前 mutation owner 的稳定身份。 |
| `mutationSurface` | `button-action`、`form-submit`、`list-row`、`card-action`、`bulk-action`、`status-transition`、`settings-toggle`、`toast-undo`、`offline-queue` 或产品声明承载面。 |
| `sourceSnapshot` | 操作前的对象、列表、筛选、分页、权限、租户/工作区、版本、显示值和焦点快照。 |
| `targetIdentity` | 被影响对象、对象集合、字段、状态、数量、影响范围和安全可见名称。 |
| `visibleProjection` | 乐观展示层，包含当前可见值、pending 标记、syncing 标记、撤销入口和与权威值的差异。 |
| `pendingMutation` | 已接受但未得到权威结果的 mutation，含操作类型、payload、来源入口、请求身份、幂等键和发起者。 |
| `commitSnapshot` | 请求发送时冻结的最终提交快照、幂等键、权限版本、目标版本和影响范围。 |
| `idempotencyPolicy` | 重复点击、Enter、Space、触摸、自动重试、离线重放和页面恢复后的去重策略。 |
| `optimisticPolicy` | 是否允许乐观投影、允许投影哪些字段、哪些字段必须等待权威结果、如何标记非终态。 |
| `undoPolicy` | 是否支持撤销、撤销窗口、撤销入口、撤销请求身份、窗口结束状态和撤销失败恢复。 |
| `rollbackPolicy` | 失败、冲突、权限变化、版本过期、网络未知和部分成功时回滚或重算的依据。 |
| `reconciliationPolicy` | 权威成功、权威失败、部分成功、冲突、迟到响应、重复响应和后台同步结果如何合并。 |
| `permissionBoundary` | 可见投影、撤销入口、回滚内容、错误、DOM/ARIA/request/log/cache 的无泄露边界。 |
| `feedbackBinding` | pending、syncing、undo-window、queued、retrying、succeeded、failed、conflict、unknown 和 recovered 的反馈 owner。 |
| `responsivePolicy` | 移动端、弱网、低高度、虚拟键盘、触摸、safe-area、后台切换和离线恢复策略。 |
| `focusAnnouncementPolicy` | 乐观变化、撤销窗口开始/结束、回滚、重试、冲突、未知和最终结果的焦点与公告策略。 |
| `lifecycleDisposal` | route/unmount、owner 卸载、权限变化、断点转换、队列恢复、旧计时器、旧回调和旧投影清理。 |
| `runtimeVerification` | 真实浏览器、移动端、键盘、读屏、弱网、离线、重试、权限变化、版本冲突和迟到响应验证状态；未执行必须标为未验证。 |

不得只用 `isOptimistic`、`pending`、`loading`、`undoToast`、`rollback()`、本地数组补丁、缓存库默认 mutation、按钮 disabled、Toast 文案或服务端最终刷新替代 `optimisticMutationState`。

## 乐观更新边界

未得到服务端或权威来源确认前，乐观状态必须标记为 pending、syncing、undoable 或 queued；不得覆盖真实状态原因、审计状态、权限边界、版本号或冲突说明。

| 规则 ID | 规则 |
| --- | --- |
| `OM-SCOPE-01` | 乐观更新只能用于低风险、可恢复、范围明确且有权威 reconciliation 的操作；高风险、不可逆、敏感导出、权限变更、密钥重置和强审计操作默认不得乐观完成。 |
| `OM-SCOPE-02` | 乐观投影不得把请求已发送、队列已接收、撤销窗口打开、后台处理中或未知结果写成“已成功”。 |
| `OM-SCOPE-03` | 乐观投影不得删除用户仍需理解的对象身份、错误、权限原因、审计入口、任务入口或恢复路径。 |
| `OM-SCOPE-04` | 多个 pending mutation 影响同一对象、同一字段、同一列表或同一批量范围时，必须串行、合并、排队或阻止；不得互相覆盖。 |

## 撤销、回滚和恢复

撤销不是 Toast 装饰，回滚不是把 DOM 猜回去。撤销必须有服务端语义或明确的本地未提交语义；回滚必须来自 `sourceSnapshot`、权威刷新或可证明安全的重算结果。

| 规则 ID | 规则 |
| --- | --- |
| `OM-UNDO-01` | 支持撤销时，`undoPolicy` 必须声明窗口时长、对象、入口位置、撤销请求身份、窗口结束状态、成功状态和失败恢复。 |
| `OM-UNDO-02` | 撤销入口不得只存在于自动消失 Toast；Toast 可提示，但页面、结果区、任务中心或全局反馈必须有持久状态或恢复说明。 |
| `OM-UNDO-03` | 撤销窗口结束后，不得继续展示可操作撤销按钮；必须更新为最终状态、查看详情、重试或恢复说明。 |
| `OM-ROLLBACK-01` | 失败回滚必须基于 `sourceSnapshot`、权威刷新或 conflict payload；不得通过当前 DOM、当前数组索引、旧缓存或猜测值回滚。 |
| `OM-ROLLBACK-02` | 部分成功必须分别标记成功、失败、跳过、冲突和未知对象；不得把列表整体回滚或整体成功。 |
| `OM-ROLLBACK-03` | 回滚后必须说明哪些内容恢复、哪些仍在处理中、哪些需要刷新/重试/查看详情，且焦点不得被迟到回调抢走。 |

## 权威结果、迟到响应和幂等

权威结果只能写回匹配当前 owner、幂等键、权限版本、目标版本、租户/工作区和 `commitSnapshot` 的 mutation。失配结果只能丢弃、进入安全恢复或提示刷新。

| 规则 ID | 规则 |
| --- | --- |
| `OM-COMMIT-01` | 请求发送前必须冻结 `commitSnapshot`；请求不得读取 hover、active、临时投影、旧按钮属性、旧列表缓存或未提交表单草稿。 |
| `OM-IDEMP-01` | 重复点击、键盘重复触发、触摸重复触发、自动重试、离线重放和浏览器恢复必须复用同一幂等策略或被拒绝。 |
| `OM-REC-01` | 权威成功必须把 `visibleProjection` 替换为已证明的权威值，并清理 pending、undo-window、旧错误和旧计时器。 |
| `OM-REC-02` | 权威失败、冲突、权限变化、版本过期或 unknown 不得静默刷新吞掉；必须进入失败、冲突、未知或恢复状态。 |
| `OM-REC-03` | 迟到响应、重复响应或旧队列恢复不得覆盖当前对象、当前字段、当前权限或新 mutation 的可见投影。 |

## 权限、安全和移动端

权限降级、租户/工作区切换、对象删除、能力关闭、认证过期、版本冲突或 owner 卸载后，旧乐观投影、旧撤销入口、旧回滚依据、旧错误、旧成功提示、旧 aria-label、旧计时器和旧请求回调必须失效或重新证明安全。

| 规则 ID | 规则 |
| --- | --- |
| `OM-PERM-01` | 可见乐观投影、可撤销、可重试、可查看结果和可查看审计是不同权限；不得互相推导。 |
| `OM-PERM-02` | 无权限或权限待解析时，不得通过旧投影、旧撤销入口、旧回滚消息、旧 Toast、DOM、ARIA、日志或缓存泄露对象名称、数量、字段、文件名、状态、内部 ID 或旧值。 |
| `OM-RSP-01` | 移动端不得删除 pending/syncing 标记、撤销入口、失败原因、回滚说明、重试、查看详情、任务入口或未知结果恢复。 |
| `OM-RSP-02` | 弱网、离线、后台切换、系统返回、浏览器 Back、虚拟键盘和 safe-area 下，撤销窗口、重试、恢复和最终结果仍必须可达。 |
| `OM-A11Y-01` | 乐观变化、撤销窗口、回滚、冲突、未知和最终结果必须由唯一 owner 公告；不得同时由按钮、Toast、列表和全局 live region 重复播报。 |
| `OM-LIFE-01` | disposal 必须释放撤销计时器、重试计时器、队列订阅、网络监听、缓存订阅、请求回调、公告回调和焦点任务，且只释放本 owner 持有资源。 |

## 完成前检查

1. 是否声明 `optimisticMutationState` 及全部字段。
2. 是否证明乐观更新不是成功回执，也不是绕过确认、权限、审计或服务端权威状态的捷径。
3. 未得到权威确认前，乐观状态是否标记为 pending、syncing、undoable 或 queued，而不是“已成功”。
4. 高风险、不可逆、敏感导出、权限变更、密钥重置和强审计操作是否没有乐观完成。
5. 撤销入口是否不只存在于自动消失 Toast，并声明 `undoPolicy`。
6. 失败回滚是否基于 `sourceSnapshot`、权威刷新或 conflict payload，而不是 DOM、数组索引、旧缓存或猜测值。
7. 权威结果、迟到响应、重复响应和离线重放是否匹配 owner、幂等键、权限版本、目标版本、租户/工作区和 `commitSnapshot`。
8. 权限降级、租户切换、对象删除、能力关闭、认证过期、版本冲突或 owner 卸载后，旧投影、旧撤销入口、旧回滚依据、旧成功提示和旧回调是否失效。
9. 移动端、弱网、离线、后台切换、系统返回、浏览器 Back、虚拟键盘和 safe-area 下，pending、撤销、失败、重试、查看详情和未知结果恢复是否可达。
10. 真实浏览器、移动端、键盘、读屏、弱网、离线、重试、权限变化、版本冲突和迟到响应未实际执行时，是否明确标为未验证并列出所需验证。
