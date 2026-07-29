# 表单布局、字段分组与响应式排列 GREEN 摘要

<!-- form-layout-field-groups-audit:start -->
```json
{
  "schemaVersion": 1,
  "formLayoutOwnerApplied": true,
  "cssGridOnlyForbidden": true,
  "visualDomTabScreenReaderOrderAligned": true,
  "fieldGroupsSemantic": true,
  "labelsHelpErrorsBound": true,
  "multiColumnMobileForbidden": true,
  "footerAvoidanceRequired": true,
  "dynamicLayoutRecomputed": true,
  "runtimeUnverifiedDeclared": true,
  "formLayoutState": {
    "formLayoutOwnerId": true,
    "layoutSurface": true,
    "fieldRegistry": true,
    "groupRegistry": true,
    "layoutMode": true,
    "breakpointPolicy": true,
    "fieldOrder": true,
    "alignmentPolicy": true,
    "spanPolicy": true,
    "densityPolicy": true,
    "overflowPolicy": true,
    "errorPlacementPolicy": true,
    "loadingPlaceholderPolicy": true,
    "conditionalLayoutBinding": true,
    "actionBarAvoidance": true,
    "responsivePolicy": true,
    "focusRestorationPolicy": true,
    "lifecycleDisposal": true,
    "runtimeVerification": true
  },
  "componentOwners": {
    "forms": true,
    "field-guidance-help-text": true,
    "dialogs": true,
    "drawers": true,
    "page-content-layout-sections": true,
    "page-form-action-bars": true,
    "responsive-adaptive": true,
    "text-overflow-truncation": true
  },
  "negativeCases": [
    "css-grid-only",
    "visual-dom-order-mismatch",
    "group-without-heading",
    "placeholder-as-label",
    "long-error-overlaps-neighbor",
    "mobile-horizontal-form",
    "footer-covers-error",
    "dynamic-field-stale-focus"
  ],
  "runtimeVerification": {
    "browser": false,
    "keyboard": false,
    "screenReader": false,
    "touch": false,
    "virtualKeyboard": false,
    "zoom": false,
    "lowHeight": false,
    "mobileViewport": false
  }
}
```
<!-- form-layout-field-groups-audit:end -->

本 GREEN 摘要确认表单布局、字段分组与响应式排列已执行 `formLayoutState`。CSS Grid、span、labelCol/wrapperCol、组件库 Form.Item 或截图不能替代布局 owner。

视觉顺序、DOM 顺序、Tab 顺序和读屏顺序默认一致。字段组必须有语义，label、帮助文本、单位、错误文本和计数必须绑定到对应字段。

移动端不得保留需要横向滚动才能填写的两列/三列主表单。底部保存栏、Dialog footer、Drawer footer 和虚拟键盘不得遮挡字段、帮助或错误。

运行时验证边界：真实浏览器、键盘、读屏、触摸、虚拟键盘、缩放、低高度和移动端视口均为未验证。
