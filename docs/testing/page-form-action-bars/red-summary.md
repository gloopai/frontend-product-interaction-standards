# 页面级表单操作栏与保存区 RED 证据摘要

这些负向场景必须被规范和审计识别为失败：

- 缺少 `formActionBarState`，或者缺少 `actionBarOwnerId`、`formBinding`、`saveIntentPolicy`、`cancelIntentPolicy`、`buttonPolicy`、`layoutBoundary`、`permissionBoundary`、`feedbackBinding`、`focusReturnPolicy`、`responsivePolicy`。
- 保存、提交、应用、确认、取消、返回、关闭、放弃更改、重置、保存并返回、保存并继续和保存并新建混用同一个意图。
- 顶部保存、底部保存、快捷键保存和移动端保存各自发送重复请求。
- sticky / fixed 保存栏遮挡最后一个字段、字段错误、帮助文本、错误摘要、上传进度、表格分页、审计回执或恢复入口。
- 保存栏从按钮 disabled、字段 DOM、URL、Toast 或本地缓存推断 dirty。
- 取消、返回、关闭、浏览器 Back、Tab 切换、面包屑、菜单导航或外链绕过 Navigation owner 的同一离开保护。
- 放弃更改没有说明会丢弃哪些草稿，或确认前请求数不是 0。
- 重置更改被实现成清空全部字段，而不是回到明确 initial/default/server-refill 状态。
- 无权限、只读或未启用时仍保留无原因的 disabled 幽灵保存按钮，且 DOM、state、handler、request 或快捷键入口不是 0。
- 权限、租户/工作区、对象状态、表单版本或会话状态变化后，旧保存入口、旧快捷键、旧 loading、旧错误、旧 Toast、旧 focus target 或旧回调继续生效。
- 保存成功只显示 Toast，没有页面内结果回执、状态更新、焦点恢复或恢复路径。
- 移动端删除保存、取消/返回、错误摘要、权限原因、脏状态说明或恢复路径。
- 虚拟键盘出现后，当前聚焦字段、字段错误、错误摘要、保存按钮、取消/返回、提交中状态或恢复入口不可见且不可滚动到达。
- 真实浏览器、移动端、屏幕阅读器、虚拟键盘、表单提交、权限切换、离开保护、sticky 布局和焦点恢复未执行时，不能写成已验证，必须标为未验证。

对应静态审计入口：`ruby docs/testing/page-form-action-bars/page-form-action-bars-audit.rb --mutations`。
