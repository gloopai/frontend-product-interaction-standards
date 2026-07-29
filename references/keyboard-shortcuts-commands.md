# 快捷键与键盘命令交互规范

适用于快捷键、键盘命令、全局快捷键、页面快捷键、局部快捷键、命令快捷键、组合键、热键、访问键、助记键、键盘入口、快捷键帮助、快捷键冲突、输入框快捷键保护、系统快捷键避让、浏览器快捷键避让、快捷键禁用、快捷键作用域、shortcut、keyboard shortcut、hotkey、keybinding、key binding、accelerator、access key、mnemonic、command shortcut、global shortcut、scoped shortcut、keyboard command 和 shortcut help。

本文件是快捷键注册、作用域、冲突、输入保护、系统/浏览器/辅助技术避让、可发现性、执行门禁、移动端替代和生命周期清理的 owner。按钮语义、loading 和防重复读取 `references/buttons.md`；命令面板、动作搜索和快速跳转读取 `references/search-command-palette.md`；表格 ARIA Grid、单元格导航和行/批量操作读取 `references/data-tables.md`；Dialog/Drawer 的焦点陷阱与 Escape 关闭读取 `references/dialogs.md` / `references/drawers.md`；菜单、Popover、Context Menu 和 Action Sheet 读取 `references/overlays-menus-tooltips.md`；导航、返回和路由离开读取 `references/navigation-routing.md`；表单输入、dirty、提交和错误读取 `references/forms.md`；权限无泄露读取 `references/permissions-tenancy-visibility.md`；响应式、触摸、移动端替代和辅助技术组合读取 `references/responsive-adaptive.md`。

快捷键不是隐藏按钮，也不是绕过焦点、权限、确认、表单输入或浏览器默认行为的后门。每个快捷键必须有可见或可发现的等价入口；高风险、提交、删除、权限变更、敏感导出和外部系统动作不得只靠快捷键触发。

## `keyboardShortcutState`

每个页面、应用外框、命令面板、表格、编辑器、Dialog、Drawer、菜单或组件级快捷键集合必须声明 `keyboardShortcutState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `shortcutOwnerId` | 当前快捷键集合的稳定 owner 身份。 |
| `shortcutSurface` | `app-shell`、`page`、`dialog`、`drawer`、`table-grid`、`menu`、`command-palette`、`form`、`editor`、`card-list` 或产品声明承载面。 |
| `scopeBinding` | 快捷键生效范围、当前焦点区域、模态层级、路由、租户/工作区、权限版本和启用条件。 |
| `commandRegistry` | 注册的命令、动作对象、可见入口、所需权限、风险等级、结果 owner 和是否可重复触发。 |
| `keyBindingMap` | 平台差异后的按键组合、修饰键、键盘布局、IME 状态、冲突状态和替代按键。 |
| `focusContext` | 当前焦点目标、可编辑区域、组合输入状态、活动浮层、表格模式、菜单模式和焦点陷阱状态。 |
| `inputProtectionPolicy` | input、textarea、contenteditable、Select 搜索、日期输入、编辑器、IME composition 和屏幕阅读器浏览模式下的保护规则。 |
| `conflictPolicy` | 系统、浏览器、辅助技术、输入法、编辑器、全局/局部快捷键和同层 owner 冲突时的禁用、改键或优先级规则。 |
| `discoverabilityPolicy` | 快捷键帮助、按钮/菜单提示、命令面板展示、设置页、空态提示和移动端替代说明。 |
| `executionPolicy` | 快捷键命中后的权限复核、状态门禁、确认转交、重复触发、防抖、幂等和结果 owner。 |
| `permissionBoundary` | 快捷键、帮助文案、菜单提示、ARIA、DOM、handler、request 和日志的无泄露边界。 |
| `responsivePolicy` | 移动端、触摸、虚拟键盘、硬件键盘、平板、WebView、远程桌面和无键盘环境的替代入口。 |
| `focusAnnouncementPolicy` | 快捷键执行、阻止、冲突、禁用、打开/关闭帮助、结果和错误的焦点与公告策略。 |
| `lifecycleDisposal` | route/unmount、模态层级变化、权限变化、断点转换、快捷键重注册、监听器和旧回调清理。 |
| `runtimeVerification` | 真实浏览器、平台、键盘布局、输入法、读屏、移动端硬件键盘、Dialog/菜单/表格冲突和浏览器快捷键验证状态；未执行必须标为未验证。 |

不得只用 `onKeyDown`、`keydown`、`hotkeys`、`shortcut` 字符串、全局监听器、命令面板配置、按钮 tooltip、菜单文案或浏览器事件默认顺序替代 `keyboardShortcutState`。

## 作用域、冲突和优先级

快捷键必须先解析作用域，再执行命令。最上层模态、活动菜单、当前编辑器、当前表格焦点和页面级 owner 不能同时争抢同一个按键。

| 规则 ID | 规则 |
| --- | --- |
| `KSC-SCOPE-01` | 快捷键必须声明 `scopeBinding`；未声明作用域的全局 `keydown` 监听失败。 |
| `KSC-SCOPE-02` | 最上层 Dialog、Drawer、菜单、Popover、Select、编辑器或表格模式拥有优先权；外层页面快捷键不得穿透执行。 |
| `KSC-SCOPE-03` | 系统、浏览器、输入法、屏幕阅读器和编辑器保留快捷键不得被强行覆盖；冲突时禁用、改键或提供显式入口。 |
| `KSC-SCOPE-04` | 同一作用域同一组合键不得绑定多个会产生副作用的命令；冲突必须在 `conflictPolicy` 中可见说明。 |

## 输入保护和执行门禁

用户正在输入时，快捷键默认保护输入上下文。除非快捷键是该输入组件明确拥有的编辑命令，否则不得提交、导航、删除、打开菜单或执行页面命令。

| 规则 ID | 规则 |
| --- | --- |
| `KSC-INPUT-01` | input、textarea、contenteditable、搜索框、Select 搜索、日期输入、富文本、代码编辑器和 IME composition 中，页面级快捷键默认不生效。 |
| `KSC-INPUT-02` | Enter、Escape、Backspace、Delete、Space、Arrow、Tab、Home/End 和组合键必须按当前 focus owner 解析，不能被页面全局监听抢走。 |
| `KSC-EXEC-01` | 快捷键执行前必须复核权限、可见入口、对象身份、当前状态、风险等级和 dirty/confirm 阻断；不得绕过按钮、风险、表单或路由 owner。 |
| `KSC-EXEC-02` | 重复按键、长按、键盘自动重复、浏览器恢复和旧监听器回放必须进入同一幂等/防重复门禁。 |
| `KSC-EXEC-03` | 高风险、删除、提交、权限变更、敏感导出、密钥重置、批量操作和外部系统动作必须进入对应确认 owner；确认完成前请求数为 0。 |

## 可发现性和替代入口

快捷键不能是唯一入口。每个快捷键命令必须有按钮、菜单项、命令面板、帮助页、设置项或产品声明的等价可达路径。

| 规则 ID | 规则 |
| --- | --- |
| `KSC-DISC-01` | 每个快捷键必须在可见入口、菜单、命令面板、快捷键帮助或设置页中至少有一个可发现说明。 |
| `KSC-DISC-02` | 快捷键帮助必须说明作用域、平台差异、禁用条件和替代入口；不得只列按键不列动作对象。 |
| `KSC-DISC-03` | 图标按钮、菜单项和命令面板展示快捷键时，不得泄露无权限动作、对象名称、数量、文件名、内部 ID 或旧缓存。 |
| `KSC-DISC-04` | 移动端、触摸屏、无硬件键盘或辅助技术环境必须有等价入口；低频命令可收纳，但不能删除核心能力。 |

## 生命周期、安全和移动端

route/unmount、模态层级变化、权限变化、租户/工作区切换、断点转换、输入法切换、编辑器挂载/卸载或快捷键重注册后，旧监听器、旧命令、旧可访问名称、旧帮助、旧权限、旧焦点目标和旧请求回调必须失效或重算。

| 规则 ID | 规则 |
| --- | --- |
| `KSC-PERM-01` | 可见快捷键、可执行命令、可展示帮助和可记录日志是不同权限；不得互相推导。 |
| `KSC-PERM-02` | 无权限或权限待解析时，不得通过快捷键帮助、菜单提示、ARIA、DOM data 属性、日志或 handler 暴露敏感动作或对象。 |
| `KSC-RSP-01` | 移动端不得要求用户拥有硬件键盘才能完成核心任务；快捷键只能增强，不能替代触摸/点击路径。 |
| `KSC-RSP-02` | 平板硬件键盘、远程桌面、WebView、系统返回键、虚拟键盘和辅助技术快捷键必须在 `responsivePolicy` 中声明验证边界。 |
| `KSC-A11Y-01` | 快捷键执行、阻止、冲突、权限拒绝、确认转交和结果必须由唯一 owner 公告；不得重复播报完整结果。 |
| `KSC-LIFE-01` | disposal 必须释放 keydown/keyup、组合键状态、长按状态、帮助浮层、命令回调、公告回调和焦点任务，且只释放本 owner 持有资源。 |

## 完成前检查

1. 是否声明 `keyboardShortcutState` 及全部字段。
2. 是否证明快捷键不是隐藏按钮，也不是绕过焦点、权限、确认、表单输入或浏览器默认行为的后门。
3. 是否声明 `scopeBinding`，并阻止未声明作用域的全局 `keydown`。
4. 最上层 Dialog、Drawer、菜单、Popover、Select、编辑器或表格模式是否阻止外层页面快捷键穿透。
5. 系统、浏览器、输入法、屏幕阅读器和编辑器保留快捷键是否没有被强行覆盖。
6. input、textarea、contenteditable、搜索框、Select 搜索、日期输入、富文本、代码编辑器和 IME composition 中，页面级快捷键是否默认不生效。
7. 快捷键执行前是否复核权限、可见入口、对象身份、当前状态、风险等级和 dirty/confirm 阻断。
8. 高风险、删除、提交、权限变更、敏感导出、密钥重置、批量操作和外部系统动作是否进入对应确认 owner，确认完成前请求数为 0。
9. 每个快捷键是否有按钮、菜单项、命令面板、帮助页、设置项或等价可达路径。
10. 移动端、触摸屏、无硬件键盘或辅助技术环境是否有等价入口。
11. route/unmount、模态层级变化、权限变化、租户/工作区切换、断点转换、输入法切换、编辑器挂载/卸载或快捷键重注册后，旧监听器、旧命令、旧帮助和旧回调是否失效或重算。
12. 真实浏览器、平台、键盘布局、输入法、读屏、移动端硬件键盘、Dialog/菜单/表格冲突和浏览器快捷键未实际执行时，是否明确标为未验证并列出所需验证。
