# 按钮规范 GREEN 应用输出

<!-- buttons-audit:start -->
```json
{
  "schemaVersion": 1,
  "buttonOwnerApplied": true,
  "nativeButtonRequired": true,
  "fakeButtonForbidden": true,
  "iconButtonAccessibleNameRequired": true,
  "loadingNamePreserved": true,
  "singlePrimaryPerTaskArea": true,
  "tooltipOnlyDisabledReasonForbidden": true,
  "dangerRequiresConfirmationAndReceipt": true,
  "bulkButtonRequiresSnapshotAndPermission": true,
  "sentTaskCancelNotClientOnly": true,
  "mobileCoreActionsReachable": true,
  "buttonActionState": {
    "buttonId": true,
    "actionKind": true,
    "hierarchy": true,
    "availability": true,
    "disabledReasonOwner": true,
    "asyncPhase": true,
    "requestIdentity": true,
    "resultOwner": true,
    "accessibleName": true
  },
  "componentOwners": {
    "forms": true,
    "dialogs": true,
    "drawers": true,
    "data-tables": true,
    "admin-console": true,
    "record-editing-surfaces": true,
    "responsive-adaptive": true
  },
  "negativeCases": [
    "div-fake-button",
    "icon-button-no-accessible-name",
    "loading-spinner-only",
    "two-primary-buttons-one-task",
    "danger-color-only",
    "disabled-reason-tooltip-only",
    "bulk-action-no-selection-snapshot",
    "cancel-sent-task-as-client-only",
    "mobile-core-action-removed"
  ],
  "runtimeVerification": {
    "browser": false,
    "screenReader": false,
    "touch": false,
    "realComponent": false
  }
}
```
<!-- buttons-audit:end -->

## 场景

后台用户列表和模板编辑表单同时包含保存、取消、删除用户、导出当前筛选结果、批量停用、重试任务和图标行操作按钮。所有业务操作使用真实按钮语义；图标按钮具有包含动作对象的可访问名称；loading 中保留动作对象；每个任务区只有一个主按钮。

`buttonActionState` 记录 `buttonId`、`actionKind`、`hierarchy`、`availability`、`disabledReasonOwner`、`asyncPhase`、`requestIdentity`、`resultOwner` 和 `accessibleName`。批量按钮绑定选择快照和权限版本；危险按钮声明影响范围、确认策略、请求身份、结果回执和恢复路径。运行时验证边界保持未验证。

