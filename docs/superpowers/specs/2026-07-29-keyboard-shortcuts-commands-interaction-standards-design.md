# 快捷键与键盘命令交互规范设计

## 背景

管理台常会增加快捷键：打开命令面板、保存、刷新、删除、批量操作、表格行导航、关闭弹窗、打开菜单。没有统一 owner 时，最容易出现全局 `keydown` 穿透 Dialog、在输入框里误触页面命令、覆盖浏览器或读屏快捷键、移动端无替代入口、无权限命令仍在帮助里泄露。

## 推荐方案

新增独立 owner `references/keyboard-shortcuts-commands.md`。它只负责快捷键注册、作用域、冲突、输入保护、系统/浏览器/辅助技术避让、可发现性、执行门禁、移动端替代和生命周期清理；命令语义仍转交按钮、命令面板、表格、Dialog、菜单、导航、风险、表单和权限 owner。

## 目标

1. 定义 `keyboardShortcutState`，包含 `scopeBinding`、`commandRegistry`、`keyBindingMap`、`focusContext`、`inputProtectionPolicy`、`conflictPolicy`、`discoverabilityPolicy`、`executionPolicy` 和 `runtimeVerification`。
2. 明确快捷键不是隐藏按钮，也不能绕过焦点、权限、确认、表单输入或浏览器默认行为。
3. 禁止未声明作用域的全局 `keydown` 监听。
4. 禁止输入框、编辑器、Select 搜索和 IME composition 中页面级快捷键抢事件。
5. 明确高风险、提交、删除、权限变更、敏感导出、密钥重置和批量操作必须进入对应确认 owner。

## 非目标

- 不规定具体快捷键组合。
- 不实现框架级快捷键库或键位解析器。
- 不替代表格键盘导航、菜单键盘行为、Dialog Escape 关闭、命令面板命令执行或按钮防重复。

## 验收

- `SKILL.md` 可以自动路由快捷键、hotkey、keybinding、shortcut help 等任务。
- `README.md`、`HANDOFF.md` 和相邻 owner 引用 `references/keyboard-shortcuts-commands.md`。
- RED/GREEN 证据覆盖 `keyboardShortcutState`、作用域、输入保护、冲突、可发现性、移动端替代和未验证边界。
- 审计脚本能捕获关键语义缺失、路由缺失、相邻引用缺失和项目泄露。
