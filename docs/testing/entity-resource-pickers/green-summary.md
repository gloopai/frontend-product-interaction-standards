# 对象、资源与成员选择器 GREEN 摘要

<!-- entity-resource-pickers-audit:start -->
```json
{
  "schemaVersion": 1,
  "entityResourcePickerOwnerApplied": true,
  "labelIsNotIdentity": true,
  "draftAndCommittedSeparated": true,
  "candidateSourcesSeparated": true,
  "crossScopeProofRequired": true,
  "permissionLeakForbidden": true,
  "invalidStatesSeparated": true,
  "staleRequestDiscarded": true,
  "toastOnlyForbidden": true,
  "mobileCoreActionsReachable": true,
  "entityResourcePickerState": {
    "pickerOwnerId": true,
    "pickerSurface": true,
    "entityKind": true,
    "selectionMode": true,
    "committedSelection": true,
    "draftSelection": true,
    "queryState": true,
    "candidateResults": true,
    "recentAndSuggested": true,
    "identityResolution": true,
    "availabilityMap": true,
    "permissionBoundary": true,
    "scopeBinding": true,
    "bindingPolicy": true,
    "validationBinding": true,
    "requestIdentity": true,
    "feedbackBinding": true,
    "responsivePolicy": true,
    "focusAnnouncementPolicy": true,
    "lifecycleDisposal": true,
    "runtimeVerification": true
  },
  "componentOwners": {
    "selects-comboboxes": true,
    "multi-select-tag-inputs": true,
    "forms": true,
    "permissions-tenancy-visibility": true,
    "members-invitations-access": true,
    "approval-workflows": true,
    "tree-hierarchy": true
  },
  "negativeCases": [
    "ordinary-select-only",
    "label-as-identity",
    "recent-search-cache-submit",
    "cross-scope-without-proof",
    "permission-leak-old-cache",
    "invalid-states-collapsed",
    "toast-only-picker-failure",
    "mobile-apply-cancel-removed"
  ],
  "runtimeVerification": {
    "browser": false,
    "keyboard": false,
    "screenReader": false,
    "touch": false,
    "permissionSwitch": false,
    "mobileViewport": false
  }
}
```
<!-- entity-resource-pickers-audit:end -->

本 GREEN 摘要确认对象、资源与成员选择器已执行 `entityResourcePickerState`。稳定 ID、作用域、版本和权限快照是身份来源；display label、头像、邮箱、路径、tooltip 和 aria-label 只属于安全展示快照。

已提交选择、选择草稿、搜索 query、active option、候选结果、最近/收藏/推荐和展示快照保持分层。旧搜索结果、旧最近项、旧推荐项和旧缓存不得继续提交。跨租户、跨工作区、跨账号、跨项目或跨权限边界选择必须先证明可见且可绑定；无权限状态不得泄露旧缓存、旧搜索命中或旧选中摘要。

Toast 不能作为唯一选择失败、权限拒绝、对象失效、重复冲突、部分加载或绑定结果回执；承载面内必须保留可恢复状态。

运行时验证边界：真实浏览器、键盘、读屏、触摸、权限切换和移动端视口均为未验证。
