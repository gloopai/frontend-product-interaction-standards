# 穿梭框、分配列表与授权资源选择 GREEN 摘要

<!-- transfer-assignment-lists-audit:start -->
```json
{
  "schemaVersion": 1,
  "assignmentTransferOwnerApplied": true,
  "moveIsNotSave": true,
  "checkIsNotMove": true,
  "visibleSelectionScopeSeparated": true,
  "draftAndInitialSeparated": true,
  "permissionLeakForbidden": true,
  "lockedInheritedStatesSeparated": true,
  "treeHalfCheckedNotSubmitValue": true,
  "staleRequestDiscarded": true,
  "toastOnlyForbidden": true,
  "mobileCoreActionsReachable": true,
  "assignmentTransferState": {
    "transferOwnerId": true,
    "assignmentSurface": true,
    "subjectBinding": true,
    "candidateScope": true,
    "initialAssignedSet": true,
    "draftAssignedSet": true,
    "sourceVisibleSet": true,
    "targetVisibleSet": true,
    "selectionBuckets": true,
    "moveIntent": true,
    "eligibilityMap": true,
    "permissionBoundary": true,
    "requestIdentity": true,
    "diffSummary": true,
    "validationBinding": true,
    "savePolicy": true,
    "feedbackBinding": true,
    "responsivePolicy": true,
    "focusAnnouncementPolicy": true,
    "lifecycleDisposal": true,
    "runtimeVerification": true
  },
  "componentOwners": {
    "entity-resource-pickers": true,
    "multi-select-tag-inputs": true,
    "tree-hierarchy": true,
    "data-tables": true,
    "bulk-actions-batch-operations": true,
    "forms": true,
    "permissions-tenancy-visibility": true,
    "risk-actions": true,
    "responsive-adaptive": true
  },
  "negativeCases": [
    "two-selects-only",
    "selected-keys-only",
    "move-as-save",
    "visible-page-as-all",
    "permission-leak-old-assigned",
    "locked-inherited-collapsed",
    "tree-half-checked-submit",
    "toast-only-save-result",
    "mobile-diff-summary-removed"
  ],
  "runtimeVerification": {
    "browser": false,
    "keyboard": false,
    "screenReader": false,
    "touch": false,
    "permissionSwitch": false,
    "lateRequest": false,
    "bulkScope": false,
    "mobileViewport": false
  }
}
```
<!-- transfer-assignment-lists-audit:end -->

本 GREEN 摘要确认穿梭框、分配列表与授权资源选择已执行 `assignmentTransferState`。移动不等于保存，勾选不等于移动，搜索命中不等于已分配。

`initialAssignedSet`、`draftAssignedSet`、`sourceVisibleSet`、`targetVisibleSet`、`selectionBuckets` 和 `diffSummary` 保持分层。当前页全选、全部筛选结果、全部候选、跨页选择和排除项必须分别表达。

无权限、只读、锁定、继承、已删除、失效、重复和未知状态不会合并。Toast 不能作为唯一保存失败、部分成功、未知结果、权限拒绝或版本冲突回执。

运行时验证边界：真实浏览器、键盘、读屏、触摸、权限切换、迟到请求、批量范围和移动端视口均为未验证。
