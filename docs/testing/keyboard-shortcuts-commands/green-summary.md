# GREEN：快捷键与键盘命令规范已加固

## 新增能力

- 新增 `references/keyboard-shortcuts-commands.md`，成为快捷键、键盘命令、全局快捷键、页面快捷键、局部快捷键、热键、组合键、快捷键帮助、快捷键冲突、输入框快捷键保护、系统快捷键避让和浏览器快捷键避让的 owner。
- `keyboardShortcutState` 已结构化声明 `shortcutOwnerId`、`shortcutSurface`、`scopeBinding`、`commandRegistry`、`keyBindingMap`、`focusContext`、`inputProtectionPolicy`、`conflictPolicy`、`discoverabilityPolicy`、`executionPolicy`、`permissionBoundary`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification`。
- 明确快捷键不是隐藏按钮，也不是绕过焦点、权限、确认、表单输入或浏览器默认行为的后门。
- 明确快捷键必须声明 `scopeBinding`；未声明作用域的全局 `keydown` 监听失败。
- 明确最上层 Dialog、Drawer、菜单、Popover、Select、编辑器或表格模式拥有优先权；外层页面快捷键不得穿透执行。
- 明确系统、浏览器、输入法、屏幕阅读器和编辑器保留快捷键不得被强行覆盖。
- 明确 input、textarea、contenteditable、搜索框、Select 搜索、日期输入、富文本、代码编辑器和 IME composition 中，页面级快捷键默认不生效。
- 明确高风险、删除、提交、权限变更、敏感导出、密钥重置、批量操作和外部系统动作必须进入对应确认 owner；确认完成前请求数为 0。
- 明确每个快捷键命令必须有按钮、菜单项、命令面板、帮助页、设置项或产品声明的等价可达路径。
- 明确移动端、触摸屏、无硬件键盘或辅助技术环境必须有等价入口。

## 集成范围

- `SKILL.md` 已加入快捷键、热键、keybinding、shortcut help 等相关路由。
- `README.md` 和 `HANDOFF.md` 已加入使用者可见摘要。
- 按钮、命令面板、表格、Dialog、菜单、导航和响应式规范已引用 `references/keyboard-shortcuts-commands.md`。

## 验证状态

- 静态结构、路由、相邻引用、README、HANDOFF、RED/GREEN 证据和项目泄露扫描由 `docs/testing/keyboard-shortcuts-commands/keyboard-shortcuts-commands-audit.rb` 覆盖。
- 真实浏览器、平台、键盘布局、输入法、读屏、移动端硬件键盘、Dialog/菜单/表格冲突和浏览器快捷键仍需在具体项目中验证；当前规范明确标为未验证。
