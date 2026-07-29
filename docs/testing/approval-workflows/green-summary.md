# 审批与审核工作流规范 GREEN 复核

本轮 GREEN 复核确认新增 `references/approval-workflows.md` 作为审批、审核、提交审批、撤回审批、通过、驳回、转交、加签、委托、催办、会签、串签、待办审批和批量审批的工作流 owner。

## 状态模型覆盖

`approvalWorkflowState` 已要求声明以下字段：

- `workflowInstanceId`
- `approvalSurface`
- `approvalObjectSnapshot`
- `currentStepBinding`
- `approverBinding`
- `decisionIntent`
- `commentPolicy`
- `attachmentPolicy`
- `assignmentPolicy`
- `delegationPolicy`
- `batchApprovalSnapshot`
- `notificationBinding`
- `auditBinding`
- `permissionBoundary`
- `feedbackState`
- `responsivePolicy`
- `runtimeVerification`

其中 `decisionIntent`、`batchApprovalSnapshot` 和 `commentPolicy` 是本轮重点：它们分别约束单次审批决策快照、批量审批目标集合和审批意见/原因的提交边界。

## 集成关系覆盖

审批工作流 owner 已与以下相邻规范建立关系：

- `references/status-lifecycle-transitions.md`
- `references/risk-actions.md`
- `references/members-invitations-access.md`
- `references/forms.md`
- `references/buttons.md`
- `references/data-tables.md`
- `references/notifications-message-center-announcements.md`
- `references/audit-log-activity-history.md`
- `references/permissions-tenancy-visibility.md`
- `references/global-feedback.md`
- `references/responsive-adaptive.md`
- `references/admin-console.md`

## 入口与交接覆盖

`SKILL.md` 已补充审批、审核、提交审批、撤回审批、通过、驳回、转交、加签、会签、串签、委托审批、代理审批、催办、审批意见、审批附件、审批历史、待办审批、批量审批和英文 approval/review workflow 关键词的路由。

`README.md` 已补充“审批与审核工作流规范”和 `references/approval-workflows.md` 的入口说明。

`HANDOFF.md` 已补充“审批与审核工作流”交接摘要，并链接 `references/approval-workflows.md`。

## 验证边界

本轮 GREEN 复核只验证规范结构、路由、交叉引用和可执行审计契约；真实浏览器、键盘、读屏、触摸、权限切换、节点冲突、真实通知、真实审计、附件上传和移动端视口未执行，仍必须在具体项目落地时标为未验证。
