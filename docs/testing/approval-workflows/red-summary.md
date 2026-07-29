# 审批与审核工作流规范 RED 复核

当前规范已经覆盖 `lifecycleState`、`riskActionState`、`membershipAccessState`、`notificationCenterState` 和 `auditLogState`，但缺少专门的 `approvalWorkflowState` owner。

缺口如下：

- 审批、审核、提交审批、撤回审批、通过、驳回、转交、加签、委托、催办、会签、串签和批量审批没有独立路由。
- 审批意见和审批附件没有统一要求，无法区分普通备注、必填意见、敏感意见、附件证据和审计证据。
- 当前审批节点、待处理人、已处理人、下一节点、代理/委托、会签/串签规则和冲突恢复没有页面级状态模型。
- 通知可以提示待办，但不能证明审批状态、审批历史、审计回执或恢复路径；这需要 owner 明确约束。
- 批量审批容易读取当前可见行、旧选择或旧筛选，需要冻结审批对象、节点、权限版本、意见和请求身份。

RED 期望新增 owner 后至少覆盖 `approvalWorkflowState`、`workflowInstanceId`、`approvalSurface`、`approvalObjectSnapshot`、`currentStepBinding`、`approverBinding`、`decisionIntent`、`commentPolicy`、`attachmentPolicy`、`assignmentPolicy`、`delegationPolicy`、`batchApprovalSnapshot`、`notificationBinding`、`auditBinding`、`permissionBoundary`、`feedbackState`、`responsivePolicy`、`runtimeVerification`、未验证。
