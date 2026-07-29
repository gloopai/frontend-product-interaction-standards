# RED：快捷键与键盘命令规范缺口

## 当前失败点

- 缺少独立 `keyboardShortcutState`，快捷键、热键、命令快捷键、全局快捷键、页面快捷键和局部快捷键容易散落在按钮、表格、命令面板、Dialog、菜单或页面监听器中。
- 缺少 `shortcutOwnerId`、`shortcutSurface`、`scopeBinding`、`commandRegistry`、`keyBindingMap`、`focusContext`、`inputProtectionPolicy`、`conflictPolicy`、`discoverabilityPolicy`、`executionPolicy`、`permissionBoundary`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification` 时，无法证明快捷键作用域、冲突、输入保护、执行门禁和验证边界。
- 快捷键不是隐藏按钮，也不是绕过焦点、权限、确认、表单输入或浏览器默认行为的后门；当前缺口会让全局 `keydown` 穿透最上层 Dialog、Drawer、菜单、Popover、Select、编辑器或表格模式。
- input、textarea、contenteditable、搜索框、Select 搜索、日期输入、富文本、代码编辑器和 IME composition 中，页面级快捷键可能误触提交、删除、导航或关闭。
- 系统、浏览器、输入法、屏幕阅读器和编辑器保留快捷键可能被强行覆盖。
- 快捷键可能成为唯一入口，移动端、触摸屏、无硬件键盘或辅助技术环境没有等价路径。
- route/unmount、模态层级变化、权限变化、租户/工作区切换、断点转换、输入法切换、编辑器挂载/卸载或快捷键重注册后，旧监听器、旧命令、旧帮助和旧回调可能没有失效。
- 真实浏览器、平台、键盘布局、输入法、读屏、移动端硬件键盘、Dialog/菜单/表格冲突和浏览器快捷键验证目前应标为未验证。

## 预期失败检测

审计应能在以下突变中失败：

- 删除 `keyboardShortcutState` 或任一关键字段。
- 删除“快捷键不是隐藏按钮”。
- 删除未声明作用域全局 `keydown` 禁止。
- 删除最上层模态/菜单/编辑器优先级。
- 删除系统/浏览器/读屏快捷键避让。
- 删除输入保护要求。
- 删除确认 owner 转交要求。
- 删除可发现等价入口要求。
- 删除生命周期清理要求。
- 将运行时未验证边界写成已验证。
