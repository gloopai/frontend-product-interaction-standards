# 记录编辑承载面 GREEN 应用输出

<!-- record-editing-surfaces-audit:start -->
```json
{
  "schemaVersion": 1,
  "recordEditingSurface": true,
  "inlineEditingForbidden": true,
  "persistentEditableListForbidden": true,
  "rowSaveButtonsForbidden": true,
  "cellFieldControlsForbidden": true,
  "listRowsReadOnly": true,
  "choiceOrder": [
    "page",
    "drawer",
    "dialog"
  ],
  "editSurfaceState": {
    "surfaceId": true,
    "mode": true,
    "surfaceType": "drawer",
    "sourceListSnapshot": true,
    "recordIdentity": true,
    "permissionVersion": true,
    "formSessionId": true,
    "returnStrategy": true,
    "runtimeVerification": true
  },
  "componentOwners": {
    "forms": true,
    "dialogs": true,
    "drawers": true,
    "data-tables": true,
    "responsive-adaptive": true,
    "admin-console": true
  },
  "returnRevalidation": [
    "permission",
    "dataVersion",
    "recordVisibility",
    "focusTarget"
  ],
  "negativeCases": [
    "expanded-row-form",
    "inline-cell-input",
    "row-save-button",
    "editable-sort-input",
    "report-auto-edit-action"
  ],
  "runtimeVerification": {
    "browser": false,
    "screenReader": false,
    "touch": false,
    "realComponent": false
  }
}
```
<!-- record-editing-surfaces-audit:end -->

## 场景

管理台模板列表需要维护标题、描述、正文、分类、状态和排序。列表不是表单 owner：每一行只展示只读值、状态和操作入口。禁止在列表单元格里放 input、textarea、select、combobox、排序输入或每行“保存”按钮；禁止表格行下展开完整编辑表单；禁止报表明细自动推导编辑入口。

## 承载面选择

本场景需要保留来源列表上下文，字段数量中等，编辑后返回同一列表，因此选择 Drawer。独立页被排除的原因是本场景未声明深链、长会话、多步骤或刷新恢复；Dialog 被排除的原因是正文 textarea 和错误恢复会让轻量弹窗过窄。

`editSurfaceState` 包含 `surfaceId`、`mode`、`surfaceType`、`sourceListSnapshot`、`recordIdentity`、`permissionVersion`、`formSessionId`、`returnStrategy` 和 `runtimeVerification`。字段值、dirty、校验、`submitSnapshot`、`submitId`、错误摘要和失败恢复由表单 owner 负责。

## 列表入口与返回

列表只提供“新增”“编辑”“复制创建”“调整排序”等入口。打开 Drawer 前冻结 `sourceListSnapshot`；返回时执行权限、dataVersion、recordVisibility 和 focusTarget 复核。旧行、旧菜单、旧选择、旧下载入口和任何行内保存状态都不回放。

运行时验证边界：浏览器、屏幕阅读器、触摸设备和真实组件运行时均未执行，保持未验证；需要在具体项目中补充键盘、焦点、断点、错误恢复和真实权限变化检查。

