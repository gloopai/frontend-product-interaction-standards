# 非模态浮层、菜单与 Tooltip 交互规范设计

## 背景

当前 Skill 已在按钮、管理台、响应式、表格和全局反馈规范中零散约束 Tooltip、Popover、Menu 和更多菜单：图标按钮不能只靠 tooltip，禁用原因不能只放在 hover，Popover / Tooltip 不能承载唯一必读内容，菜单导航不能绕过离开保护。但这些要求分布在多个 owner 中，缺少一个统一回答：

- Tooltip、Popover、Menu、Dropdown、Context Menu、更多菜单分别适合承载什么。
- 哪些信息不能只放在 hover 或临时浮层里。
- 打开、关闭、焦点、键盘、层级、Portal、定位、裁切和滚动怎么处理。
- 移动端如何从 hover / menu / popover 转换为点击入口、底部菜单或 Drawer。
- 菜单项中的危险操作、禁用原因、权限变化和结果回执如何连接到按钮、风险操作和全局反馈 owner。

因此需要新增 `references/overlays-menus-tooltips.md`，作为非模态浮层、菜单和 Tooltip 的唯一事实来源。

## 目标

- 定义 `overlayState`，统一描述 Tooltip、Popover、Menu、Dropdown、Context Menu、Action Sheet 和临时信息浮层。
- 区分四种常见承载：纯解释 Tooltip、可交互 Popover、命令 Menu、移动端 Action Sheet / Drawer。
- 禁止 hover-only、tooltip-only 和 popover-only 承载关键内容、权限原因、错误、确认后果、危险操作或恢复入口。
- 明确菜单项必须有动作对象、权限状态、请求身份和结果 owner；危险菜单项必须进入 `risk-actions.md`。
- 明确非模态 popup 的 Portal、层级、定位、flip、max-height、焦点和关闭规则，避免裁切、遮挡和悬空。
- 明确移动端无 hover 环境下的等价入口：点击、键盘、触摸、Action Sheet 或 Drawer。

## 非目标

- 不替代 Select / Combobox 的 option、query、active option 和提交语义。
- 不替代 Dialog / Drawer 的模态容器规则。
- 不定义品牌视觉 token、阴影、圆角、动画曲线或组件库 API。
- 不定义命令执行本身；命令按钮读取 `buttons.md`，危险动作读取 `risk-actions.md`，结果回执读取 `global-feedback.md`。

## Owner 边界

- Tooltip 只承载短解释、补充说明或辅助标签；不得承载唯一必读内容。
- Popover 可承载可交互轻量内容，但不得替代表单错误、页面 Alert、确认 Dialog、任务中心或结果回执。
- Menu / Dropdown Menu 承载一组互斥或并列命令入口；菜单项语义仍按 Button owner 执行。
- Context Menu 不能是唯一入口；必须有可见按钮、更多菜单、键盘或等价路径。
- 移动端 Action Sheet / Drawer 是菜单或可交互浮层的移动端承载形态，但仍保留原动作语义和对应 owner。

## 状态模型

每个浮层维护 `overlayState`：

| 字段 | 语义 |
| --- | --- |
| `overlayId` | 浮层稳定身份。 |
| `overlayKind` | `tooltip`、`popover`、`menu`、`dropdown-menu`、`context-menu`、`action-sheet` 或 `mobile-drawer`。 |
| `triggerOwner` | 触发控件 owner、可访问名称、触发方式和焦点返回目标。 |
| `contentOwner` | 浮层内容的 primary owner；说明、命令、状态、错误、权限或风险动作分别指向对应 owner。 |
| `openState` | `closed`、`opening`、`open`、`closing` 或 `disposed`。 |
| `placementPolicy` | 锚点、方向、flip、collision、max-height、Portal root、层级和滚动策略。 |
| `interactionMode` | hover、focus、click、keyboard、touch、contextmenu 或 programmatic 的组合。 |
| `dismissPolicy` | Escape、外部点击、trigger 再次点击、blur、route/unmount 和选择后关闭规则。 |
| `focusPolicy` | 打开焦点、内部焦点、关闭焦点返回和禁止抢焦点规则。 |
| `itemStates` | 菜单项或动作项的可见性、禁用原因、权限、危险等级、请求身份和结果 owner。 |
| `responsivePolicy` | 移动端、窄屏、低高度、触摸和虚拟键盘下的等价承载。 |
| `disposalLog` | route/unmount、权限变化、断点转换和关闭动画时已清理的监听器、定位任务、回调和浮层 DOM。 |

## 承载选择

### Tooltip

只适合短解释、术语说明、图标辅助标签或非关键补充。Tooltip 内容消失后，用户仍必须能完成任务、理解权限、读取错误、确认后果和找到恢复入口。

### Popover

适合轻量可交互内容，例如简短详情、筛选帮助、低风险解释、辅助配置入口。Popover 不适合承载长表单、复杂编辑、危险确认、结果回执、任务状态或必须持续阅读的错误。

### Menu / Dropdown Menu

适合命令集合、更多操作、行操作、工具栏折叠操作和低频操作。每个菜单项都必须有动作对象、权限状态、可访问名称、禁用原因和结果 owner。危险菜单项必须保留风险标记，并进入 `risk-actions.md` 的确认与回执流程。

### Context Menu

可以作为效率入口，但不能是唯一入口。右键、长按或精确指针不是关键操作唯一可达路径；必须有按钮、更多菜单、快捷键或其他显式入口。

### 移动端 Action Sheet / Drawer

移动端没有可靠 hover。Tooltip 信息必须转为可点击说明、内联帮助、Popover、Action Sheet 或 Drawer。复杂 Popover 和 Menu 在窄屏、低高度、触摸目标不足或虚拟键盘影响布局时，可以转换为 Action Sheet / Drawer；转换必须保持单实例、动作对象、权限、禁用原因、风险等级和焦点返回。

## 硬性红线

- 重要信息不得仅依赖 Hover、Tooltip、Popover 临时可见状态或 Context Menu。
- Tooltip / Popover 不得承载唯一必读权限原因、错误、确认后果、危险操作、结果回执、审计凭证或恢复入口。
- 更多菜单不得成为隐藏权限原因、错误、确认后果或唯一恢复入口的地方。
- 菜单项不能只有“操作”“更多”“处理”“查看”等裸词；必须描述动作对象。
- 禁用菜单项的原因必须可发现、可访问，且不能只存在于 hover tooltip。
- 危险菜单项必须保留风险标记、影响范围、确认策略、请求身份、结果回执和审计回执。
- 非模态浮层不得被父容器、滚动区、固定列、固定页脚、`overflow` 或 `transform` 裁切；必要时 Portal 到应用根或当前模态层专用 root。
- 打开的菜单、Popover 和 Tooltip 在 route/unmount、权限变化、断点转换或 trigger 消失后不得悬空；迟到定位回调不得写回新实例。
- 移动端不得删除菜单入口、禁用原因、危险确认、错误恢复或权限说明；hover-only 内容必须有触摸和键盘等价路径。

## 审计策略

新增 `docs/testing/overlays-menus-tooltips/overlays-menus-tooltips-audit.rb`，验证：

- owner 包含完整 `overlayState` 字段。
- owner 覆盖 Tooltip、Popover、Menu、Dropdown Menu、Context Menu、Action Sheet 和 mobile Drawer。
- owner 包含 hover-only、tooltip-only、popover-only、context-menu-only 和 menu-hidden-critical-content 的红线。
- owner 覆盖 Portal、flip、collision、max-height、层级、焦点、键盘、关闭、disposal、权限变化和移动端转换。
- `SKILL.md` 路由包含中英文关键词。
- README/HANDOFF 只做摘要。
- RED/GREEN 证据覆盖关键负例和未验证边界。

## 验收口径

完成后应能验证：

1. Tooltip 只承载短解释，移除 Tooltip 后任务仍可完成。
2. Popover 不承载唯一错误、确认、结果或恢复。
3. Menu 每项有动作对象、权限状态、禁用原因和结果 owner。
4. 危险菜单项进入风险动作 owner。
5. Context Menu 不是唯一入口。
6. Hover-only 信息在键盘、触摸和移动端有等价路径。
7. popup 不被裁切、不遮挡关键操作，空间不足时 flip、限高或转换。
8. 权限变化和 route/unmount 后旧浮层被清理，迟到回调不写回。
9. 移动端 Action Sheet / Drawer 保留同一动作语义、状态和焦点返回。
10. 浏览器、屏幕阅读器、触摸设备和真实组件未执行时标为未验证。
