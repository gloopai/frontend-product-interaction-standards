# 审批与审核工作流交互规范

适用于审批、审核、提交审批、提交审核、撤回审批、审批通过、审核通过、驳回、拒绝、转交、加签、会签、串签、或签、委托审批、代理审批、催办、审批意见、审批备注、审批附件、审批历史、审批节点、待办审批、批量审批、approval workflow、review workflow、submit for approval、approve、reject、withdraw approval、delegate approval、reassign approval、add approver、approval comment、approval history 和 approval task。

本文件是审批与审核工作流 owner。它负责审批实例、审批对象、当前节点、审批人、意见/附件、决策意图、节点流转、转交/委托、批量审批、通知、审计、权限、移动端和运行时验证边界。状态展示和生命周期变更读取 `references/status-lifecycle-transitions.md`；危险确认读取 `references/risk-actions.md`；审批人、角色和成员身份读取 `references/members-invitations-access.md`；审批意见表单读取 `references/forms.md`；按钮读取 `references/buttons.md`；批量审批列表读取 `references/data-tables.md`；批量审批的目标集合、范围冻结、部分成功和恢复读取 `references/bulk-actions-batch-operations.md`，并声明 `bulkActionState`；通知读取 `references/notifications-message-center-announcements.md`；审计读取 `references/audit-log-activity-history.md`；权限读取 `references/permissions-tenancy-visibility.md`；全局反馈读取 `references/global-feedback.md`；响应式读取 `references/responsive-adaptive.md`；管理台跨页面治理读取 `references/admin-console.md`。

## 范围与排除项

审批动作不是普通状态按钮。提交审批、通过、驳回、撤回、转交、加签、委托、催办和批量审批都必须显式声明审批工作流 owner，不能只依赖状态枚举、按钮 loading、表格行操作、Toast 或后端 200。

本 owner 不覆盖后端工作流引擎、组织架构计算、审批模板 DSL、法务合规制度、消息投递服务、审计存储或业务项目的具体审批角色名称。

## `approvalWorkflowState`

每个审批入口、审批详情、待办审批、审批历史、审批确认或批量审批承载面必须声明 `approvalWorkflowState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `workflowInstanceId` | 当前审批实例、待办任务或审批历史 owner 的稳定身份。 |
| `approvalSurface` | `detail-approval`、`list-row-approval`、`approval-task`、`bulk-approval`、`approval-history`、`dialog`、`drawer`、`mobile-sheet` 或产品声明的 surface。 |
| `approvalObjectSnapshot` | 审批对象、对象版本、当前业务状态、租户/工作区、数据范围、来源列表/详情快照和可安全展示摘要。 |
| `currentStepBinding` | 当前节点、节点版本、节点顺序、会签/串签/或签规则、超时状态、下一节点和节点完成条件。 |
| `approverBinding` | 当前审批人、候选审批人、已处理人、代理/委托人、角色来源、权限版本和成员身份快照。 |
| `decisionIntent` | 本次提交、通过、驳回、撤回、转交、加签、委托、催办或批量审批的冻结意图。 |
| `commentPolicy` | 审批意见是否必填、最小信息、可见范围、敏感字段、修改/删除边界和审计用途。 |
| `attachmentPolicy` | 审批附件、证据文件、上传状态、引用快照、权限、有效期和删除/替换边界。 |
| `assignmentPolicy` | 指派、转交、加签、候选人搜索、多人节点、不可指派原因和节点重新计算策略。 |
| `delegationPolicy` | 委托、代理审批、临时授权、原审批人可见性、代理范围、到期和撤销策略。 |
| `batchApprovalSnapshot` | 批量审批目标集合、排除集合、节点分布、权限版本、筛选快照、意见策略和结果拆分。 |
| `notificationBinding` | 待办、催办、审批完成、驳回、转交、加签、超时和未知结果通知的身份和去重策略。 |
| `auditBinding` | 审批实例、节点、审批人、意见、附件、通知、结果和未知状态的审计身份。 |
| `permissionBoundary` | 查看审批对象、查看意见、查看附件、审批、驳回、转交、加签、催办、查看历史和审计所需权限。 |
| `feedbackState` | loading、empty、pending、submitted、approved、rejected、withdrawn、transferred、delegated、partial、conflict、unknown、permission-denied 和 recovery。 |
| `responsivePolicy` | 移动端节点摘要、意见输入、附件、历史、确认、结果、通知、审计和恢复路径保留策略。 |
| `runtimeVerification` | 真实浏览器、键盘、读屏、触摸、权限切换、节点冲突、真实通知、真实审计和移动端验证状态；未执行必须标为未验证。 |

不得只用 `status`、`approved`、`reviewStatus`、`assignee`、`comment`、`taskId`、按钮 loading、表格选择、Toast 或通知标题替代 `approvalWorkflowState`。

## 审批对象、节点和决策意图

审批提交前必须冻结 `decisionIntent`。冻结快照至少包含审批对象、对象版本、当前业务状态、当前审批节点、节点版本、审批人权限、租户/工作区、意见/附件、确认策略、来源 owner、请求身份和时间。

| 规则 ID | 规则 |
| --- | --- |
| `APW-SNAP-01` | 提交审批、通过、驳回、撤回、转交、加签、委托、催办和批量审批只能读取已冻结 `decisionIntent`，不得读取当前 hover、active option、未提交意见草稿、旧按钮 data、旧通知入口或旧详情缓存。 |
| `APW-SNAP-02` | 当前节点、审批人、对象版本、权限版本、租户/工作区或业务状态变化后，旧 `decisionIntent` 必须失效并要求重新确认。 |
| `APW-SNAP-03` | 会签、串签、或签、多级审批和条件分支必须展示当前节点、已完成节点、待处理人、下一节点是否已知、剩余完成条件和冲突恢复。 |
| `APW-SNAP-04` | 审批成功只证明当前决策已被接受，不自动证明后续节点完成、业务对象已发布、外部系统已生效或通知真实送达。 |

## 审批意见、附件和表单边界

审批意见不是普通备注。通过、驳回、撤回、转交、加签、委托和批量审批必须声明 `commentPolicy`；附件必须声明 `attachmentPolicy`。

| 规则 ID | 规则 |
| --- | --- |
| `APW-COMMENT-01` | 驳回、退回、转交、加签、委托、越权代理、批量审批和高影响通过必须明确意见是否必填；必填未满足前请求数为 0。 |
| `APW-COMMENT-02` | 审批意见的可见范围必须明确：申请人、当前审批人、后续审批人、管理员、审计员和无权限用户不得混用。 |
| `APW-COMMENT-03` | 审批意见、附件名、附件预览、附件下载、错误摘要、Toast、Notification、ARIA label 和审计摘要不得泄露无权字段、成员、金额、客户、文件名、内部原因、旧意见或旧附件。 |
| `APW-COMMENT-04` | 附件上传成功不等于审批提交成功；审批提交成功不等于附件长期可下载；删除附件不等于撤回审批。 |

## 指派、转交、加签、委托和催办

转交、加签、委托、代理审批和催办不是普通成员选择。候选人搜索、角色来源、可指派范围、代理到期、原审批人可见性和通知去重都必须显式声明。

| 规则 ID | 规则 |
| --- | --- |
| `APW-ASSIGN-01` | 指派、转交和加签必须绑定 `assignmentPolicy`，并复核候选人权限、角色来源、节点版本、租户/工作区和成员状态。 |
| `APW-ASSIGN-02` | 委托和代理审批必须绑定 `delegationPolicy`，说明代理范围、到期时间、撤销方式、原审批人责任和审计展示。 |
| `APW-ASSIGN-03` | 候选审批人 Select 的 query、active option、hover 高亮和旧搜索结果不得进入已提交审批人。 |
| `APW-ASSIGN-04` | 催办只表示催办请求已发送或待确认，不等于审批人已处理、通知已读或外部渠道已送达。 |

## 结果、通知、审计和未知状态

审批结果必须区分 submitted、approved、rejected、withdrawn、transferred、delegated、partial、conflict、unknown、permission-denied 和 recovery。未知结果不得伪装成审批成功、驳回成功、撤回成功、转交成功、加签成功、委托成功或催办成功。

| 规则 ID | 规则 |
| --- | --- |
| `APW-RESULT-01` | Toast 只能辅助提示，不能成为唯一审批结果、唯一审批历史、唯一审计回执、唯一待办入口或唯一恢复路径。 |
| `APW-RESULT-02` | 通知只提示待办、催办或结果，不能替代当前审批状态、审批历史、审计回执或恢复入口。 |
| `APW-RESULT-03` | 审批通过、驳回、撤回、转交、加签、委托、催办、失败、冲突、未知和部分成功必须关联 `auditBinding` 或明确标为审计未验证。 |
| `APW-RESULT-04` | 关闭 Dialog、Drawer、Toast、通知、待办页或移动端系统返回，只能表达客户端关闭或停止等待，不得伪装成服务端审批已取消。 |

## 批量审批

批量审批必须冻结 `batchApprovalSnapshot`。批量通过、批量驳回、批量撤回、批量转交、批量加签和批量催办不得用当前页面可见行替代选择快照、筛选快照、权限版本和节点分布。

| 规则 ID | 规则 |
| --- | --- |
| `APW-BULK-01` | 批量审批必须展示目标数量、节点分布、不同意见要求、不可审批项、权限排除、冲突风险和结果拆分。 |
| `APW-BULK-02` | 批量意见不得静默复制到用户无权查看的对象；不同节点、不同权限范围或不同意见策略必须拆分确认。 |
| `APW-BULK-03` | 部分成功必须展示成功、失败、跳过、冲突和未知数量，并提供可重试范围、错误明细、审批历史或任务中心路径。 |
| `APW-BULK-04` | 筛选、排序、分页、权限、节点版本或租户/工作区变化后，旧批量审批确认和旧目标快照必须失效。 |

## 权限、安全和无泄露

无权限或权限降级不得泄露审批对象名称、申请人、审批人、代理人、意见、附件名、节点名称、节点数量、下一节点、拒绝原因、内部状态码、任务结果、通知标题、审计摘要、旧缓存或 ARIA label。

| 规则 ID | 规则 |
| --- | --- |
| `APW-PERM-01` | 权限待解析时显示安全骨架或泛化说明，不得闪现旧审批对象、旧意见、旧附件、旧审批人、旧节点或旧待办数量。 |
| `APW-PERM-02` | 权限降级、租户切换、节点变化、审批完成、委托撤销或对象删除后，旧按钮、旧确认、旧意见草稿、旧附件、旧通知、旧待办入口、旧审计跳转、旧 DOM 和旧 ARIA 引用必须失效或重算。 |
| `APW-PERM-03` | 无权限说明可以提供申请权限、切换工作区、重新认证或返回路径，但不得包含未授权审批对象、成员、意见、附件、节点或数量。 |

## 移动端与可访问性

移动端可以把审批历史、节点详情、附件列表和批量分布折叠或转为 Drawer / Bottom Sheet / 独立页，但不得删除当前节点、审批对象摘要、审批人/候选人安全摘要、意见要求、附件状态、提交/取消、结果回执、通知关系、审计入口和恢复路径。

| 规则 ID | 规则 |
| --- | --- |
| `APW-A11Y-01` | 审批状态、当前节点、审批对象、意见要求、附件状态、可用动作、禁用原因、结果和恢复路径必须有可访问名称或描述，不能只靠颜色、图标、头像、Tooltip、Toast、相对时间或位置表达。 |
| `APW-A11Y-02` | 打开确认、意见校验失败、提交中、冲突、未知、部分成功、权限降级、转交完成和恢复完成必须由唯一 owner 公告。 |
| `APW-A11Y-03` | 焦点必须在审批入口、意见字段、附件、确认面、错误摘要、结果区、审计入口和恢复路径之间只迁移一次。 |
| `APW-RSP-01` | 低高度、虚拟键盘、动态 viewport、四向 safe area、系统字体放大、200% 缩放、触摸、WebView 返回和浏览器 Back 下，意见输入、附件、提交、取消、确认、结果、审计和恢复入口必须可达。 |

## 生命周期和清理

每个审批 owner 必须登记审批查询、节点订阅、候选人搜索、附件上传、提交请求、通知入口、审计入口、焦点任务和公告回调。route/unmount、权限收敛、租户/工作区切换、节点变化、对象版本变化、委托撤销或审批完成后，旧请求、旧搜索、旧附件上传、旧确认、旧通知、旧待办、旧审计跳转、旧 ARIA 引用和旧焦点任务必须取消或失效。

迟到审批结果必须匹配 `workflowInstanceId`、`decisionIntent`、`approvalObjectSnapshot`、`currentStepBinding`、`approverBinding`、`permissionBoundary`、租户/工作区和请求身份。失配结果只能丢弃或转入安全恢复；不得覆盖当前节点、当前意见、附件状态、结果、通知或焦点。

## 可执行验收检查

1. **状态模型**：记录 `approvalWorkflowState` 全字段。
2. **决策快照**：提交审批、通过、驳回、撤回、转交、加签、委托、催办和批量审批只读取冻结 `decisionIntent`。
3. **节点差异**：会签、串签、或签、多级审批和条件分支展示当前节点、已完成节点、待处理人、下一节点和剩余完成条件。
4. **意见和附件**：驳回、转交、加签、委托、批量审批和高影响通过按 `commentPolicy` 校验；附件上传、引用、权限和有效期按 `attachmentPolicy` 校验。
5. **指派和委托**：候选人搜索、转交、加签、代理审批和催办复核成员状态、权限版本、节点版本和租户/工作区。
6. **通知边界**：待办、催办和结果通知不能替代审批状态、审批历史、审计回执或恢复入口。
7. **批量审批**：冻结目标集合、节点分布、权限版本、筛选快照和意见策略；部分成功展示成功、失败、跳过、冲突和未知数量。
8. **权限无泄露**：无权限或权限降级时旧审批对象、申请人、审批人、意见、附件名、节点、下一节点、通知、审计摘要、DOM 和 ARIA label 不暴露。
9. **移动端保真**：移动端保留当前节点、审批对象摘要、意见要求、附件状态、提交/取消、结果、通知关系、审计入口和恢复路径。
10. **运行时报告边界**：真实浏览器、键盘、读屏、触摸、权限切换、节点冲突、真实通知、真实审计、附件上传和移动端视口未执行时，必须逐项标为未验证。

## 完成前检查

- 是否声明 `approvalWorkflowState` 及全部必要字段。
- 是否把审批动作与普通状态按钮、Toast 和通知入口分离。
- 是否冻结并复核 `decisionIntent`、节点版本、权限版本、审批对象和意见/附件。
- 是否区分意见、附件、指派、转交、加签、委托、催办和批量审批的专属策略。
- 是否防止未知结果伪装为审批成功或驳回成功。
- 是否保证通知、审计、待办和审批历史各自有边界。
- 是否防止旧权限、旧节点、旧意见、旧附件、旧通知和迟到结果泄露或写回。
- 是否在移动端保留当前节点、意见、附件、确认、结果、审计和恢复。
- 未实际执行运行时检查时，是否明确标为未验证。
