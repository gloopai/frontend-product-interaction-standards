# 页面级表单操作栏与保存区 GREEN 证据摘要

当前规范和审计证明以下结构已经就位：

- 页面级表单操作栏、保存栏、底部操作区和 sticky footer 必须声明 `formActionBarState`，并包含 `actionBarOwnerId`、`formBinding`、`saveIntentPolicy`、`cancelIntentPolicy`、`buttonPolicy`、`layoutBoundary`、`permissionBoundary`、`feedbackBinding`、`focusReturnPolicy`、`responsivePolicy`。
- 保存、提交、应用、确认、取消、返回、关闭、放弃更改、重置、保存并返回、保存并继续和保存并新建必须是不同意图。
- 顶部保存、底部保存、快捷键保存和移动端保存共享同一个 Form owner、同一个 `submitSnapshot`、同一个提交门禁、同一个防重复策略和同一个结果回执，避免重复请求。
- sticky / fixed 保存栏必须为正文提供可验证底部避让，最后一个字段、字段错误、帮助文本、错误摘要、上传进度、表格分页、审计回执和恢复入口不得被遮挡。
- 保存栏展示的 dirty / pristine 只能来自 Forms owner，不能从按钮 disabled、字段 DOM、URL、Toast 或本地缓存推断。
- 取消、返回、关闭、浏览器 Back、Tab 切换、面包屑、菜单导航和外链必须进入 Navigation owner 的同一离开保护。
- 放弃更改必须说明会丢弃哪些草稿，确认前请求数为 0。
- 重置更改必须回到明确 initial/default/server-refill 状态，不能伪装成清空全部字段。
- 无权限、只读或未启用时，保存按钮的 DOM、state、handler、request 和快捷键入口为 0，或展示安全只读说明。
- 权限、租户/工作区、对象状态、表单版本或会话状态变化后，旧保存入口、旧快捷键、旧 loading、旧错误、旧 Toast、旧 focus target 和旧回调必须失效或重新证明安全。
- 保存成功、失败、冲突、未知和权限拒绝必须绑定页面内结果回执、状态更新、焦点恢复或恢复路径；Toast 只能辅助。
- 移动端不得删除保存、取消/返回、错误摘要、权限原因、脏状态说明和恢复路径。
- 虚拟键盘出现后，当前聚焦字段、字段错误、错误摘要、保存按钮、取消/返回、提交中状态和恢复入口仍必须可见或可滚动到达。
- 真实浏览器、移动端、屏幕阅读器、虚拟键盘、表单提交、权限切换、离开保护、sticky 布局和焦点恢复在本轮文档工作中仍是未验证，需要在具体项目落地时补充。

对应静态审计入口：`ruby docs/testing/page-form-action-bars/page-form-action-bars-audit.rb --mutations`。
