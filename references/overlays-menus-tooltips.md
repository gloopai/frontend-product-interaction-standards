# 浮层菜单与提示交互规范

卡片列表、卡片式结果、资源卡片、模板卡片、应用卡片、项目卡片、卡片网格、移动端结果卡片和 Kanban-lite 中的更多菜单、Dropdown、Popover、Tooltip、Context Menu 和 Action Sheet 必须同时执行 `references/card-list-results.md`；本文件负责浮层触发、定位、键盘、权限和清理，`card-list-results.md` 负责卡片交互区域、大链接禁止、hover-only 禁止和卡片内操作入口边界。

## 范围

适用于 Tooltip、Popover、Dropdown、Dropdown Menu、Menu、Context Menu、更多菜单、操作菜单、悬浮说明、Hover 帮助、非模态浮层、Action Sheet 和移动端菜单 Drawer。本文件是非模态浮层、菜单和提示的触发、承载、定位、焦点、关闭、权限、移动端转换和清理规则的唯一事实来源。

Select / Combobox 的 option list、搜索、active option 和提交值读取 `selects-comboboxes.md`；Dialog / Drawer 等模态容器读取 `dialogs.md` / `drawers.md`；业务按钮、图标按钮和菜单项动作读取 `buttons.md`；危险菜单项读取 `risk-actions.md`；表格行菜单和固定列遮挡读取 `data-tables.md`；权限、审计和管理台页面级治理读取 `admin-console.md`；Toast、Alert、结果回执和恢复入口读取 `global-feedback.md`；跨端转换、触摸、虚拟键盘和安全区域读取 `responsive-adaptive.md`。

## 场景与状态模型

每个非模态浮层维护 `overlayState`：

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

重要信息不得仅依赖 Hover、Tooltip、Popover 临时可见状态或 Context Menu。Tooltip / Popover 不得承载唯一必读权限原因、错误、确认后果、危险操作、结果回执、审计凭证或恢复入口。

## OMT-SCOPE 范围和所有权

| 规则 ID | 规则 |
| --- | --- |
| OMT-SCOPE-01 | Tooltip、Popover、Menu、Dropdown Menu、Context Menu、Action Sheet 和 mobile Drawer 必须声明 `overlayKind` 和 `contentOwner`。 |
| OMT-SCOPE-02 | 浮层 owner 只定义触发、可达、定位、关闭、焦点、移动端转换和清理；命令执行、风险确认、结果回执和字段校验仍归对应 owner。 |
| OMT-SCOPE-03 | 组件库默认 hover、portal、auto-close、focus 和 collision 行为不能降低本文件规则；冲突时必须配置、封装或替换。 |
| OMT-SCOPE-04 | Select / Combobox option list 不归本文件定义，但其 popup 裁切、Portal 和移动端转换必须同时满足相关 owner 的兼容规则。 |

对应验收：OMT-A1、OMT-A10。

## OMT-STATE 状态、定位和实例身份

| 规则 ID | 规则 |
| --- | --- |
| OMT-STATE-01 | 每个非模态浮层必须维护 `overlayState`，包含 `overlayId`、`overlayKind`、`triggerOwner`、`contentOwner`、`openState`、`placementPolicy`、`interactionMode`、`dismissPolicy`、`focusPolicy`、`itemStates`、`responsivePolicy` 和 `disposalLog`。 |
| OMT-STATE-02 | `triggerOwner` 必须记录触发控件身份、可访问名称、触发方式、锚点和关闭后焦点返回目标。 |
| OMT-STATE-03 | `contentOwner` 必须说明内容是解释、命令、权限原因、状态、错误、风险动作、结果回执还是恢复入口；关键内容不得无 owner。 |
| OMT-STATE-04 | `placementPolicy` 必须声明 Portal root、层级、锚点、方向、flip、collision、max-height 和滚动策略。 |
| OMT-STATE-05 | `openState` 和 `disposalLog` 必须防止 route/unmount、权限变化、断点转换或迟到定位回调写回旧浮层。 |

对应验收：OMT-A1、OMT-A8。

## OMT-CHOICE 承载选择

| 规则 ID | 规则 |
| --- | --- |
| OMT-CHOICE-01 | Tooltip 只适合短解释、术语说明、图标辅助标签或非关键补充；移除 Tooltip 后用户仍必须能完成任务。 |
| OMT-CHOICE-02 | Popover 可承载轻量可交互内容，但不得替代表单错误、页面 Alert、确认 Dialog、任务中心或结果回执。 |
| OMT-CHOICE-03 | Menu / Dropdown Menu 承载命令集合、更多操作、行操作、工具栏折叠操作和低频操作。 |
| OMT-CHOICE-04 | Context Menu 可以作为效率入口，但不能是唯一入口；右键、长按或精确指针不是关键操作唯一可达路径。 |
| OMT-CHOICE-05 | 移动端复杂 Popover、Menu 和 hover 帮助必须转换为点击入口、内联说明、Action Sheet 或 Drawer。 |

对应验收：OMT-A2、OMT-A9。

## OMT-TRIGGER 触发、关闭和焦点

| 规则 ID | 规则 |
| --- | --- |
| OMT-TRIGGER-01 | Hover 触发的 Tooltip 必须同时支持键盘 Focus；可交互浮层必须支持点击和键盘触发。 |
| OMT-TRIGGER-02 | 触摸设备和移动端不得依赖 hover；必须有可点击、可触摸或可键盘访问的等价入口。 |
| OMT-TRIGGER-03 | 打开浮层时不得无故抢走焦点；可交互 Popover/Menu 打开后焦点策略必须明确且可恢复。 |
| OMT-TRIGGER-04 | Escape、外部点击、trigger 再次点击、选择菜单项、route/unmount 和断点转换的关闭语义必须声明，不得混用。 |
| OMT-TRIGGER-05 | 关闭后焦点只能迁移一次到仍存在且仍有权限的 trigger 或等价目标；trigger 消失时迁移到安全替代目标。 |

对应验收：OMT-A3、OMT-A8、OMT-A9。

## OMT-CONTENT 内容边界和信息安全

Tooltip / Popover 不得承载唯一必读权限原因、错误、确认后果、危险操作、结果回执、审计凭证或恢复入口。更多菜单不得成为隐藏权限原因、错误、确认后果或唯一恢复入口的地方。

| 规则 ID | 规则 |
| --- | --- |
| OMT-CONTENT-01 | 重要信息不得仅依赖 Hover、Tooltip、Popover 临时可见状态或 Context Menu。 |
| OMT-CONTENT-02 | Tooltip / Popover 不得承载唯一必读权限原因、错误、确认后果、危险操作、结果回执、审计凭证或恢复入口。 |
| OMT-CONTENT-03 | 更多菜单不得成为隐藏权限原因、错误、确认后果或唯一恢复入口的地方。 |
| OMT-CONTENT-04 | 禁用菜单项、禁用按钮和只读能力的原因必须可发现、可访问，且不能只存在于 hover tooltip。 |
| OMT-CONTENT-05 | 无权对象名称、数量、字段、文件名、密钥、令牌、内部 ID 和敏感筛选值不得泄露在 Tooltip、Popover、Menu 或历史浮层中。 |

对应验收：OMT-A4、OMT-A7。

## OMT-MENU 菜单项、更多菜单和动作

菜单项是动作入口，不是装饰文本。每个菜单项都必须有动作对象、权限状态、可访问名称、禁用原因、请求身份和结果 owner。菜单项不能只有“操作”“更多”“处理”“查看”等裸词；必须描述动作对象。

| 规则 ID | 规则 |
| --- | --- |
| OMT-MENU-01 | 每个菜单项必须声明动作对象、权限状态、可访问名称、禁用原因、请求身份和结果 owner。 |
| OMT-MENU-02 | 菜单项不能只有“操作”“更多”“处理”“查看”等裸词；必须描述动作对象。 |
| OMT-MENU-03 | 危险菜单项必须保留风险标记、影响范围、确认策略、请求身份、结果回执和审计回执，并进入 `risk-actions.md`。 |
| OMT-MENU-04 | 菜单中的外链、导航、下载、导出、取消任务和重跑任务必须保留对应 owner 的权限、离开保护、请求身份和结果回执。 |
| OMT-MENU-05 | 菜单项触发后是否关闭菜单必须按动作类型声明；提交中、确认中、错误恢复和未知结果不得被菜单自动关闭吞掉。 |

对应验收：OMT-A5、OMT-A6。

## OMT-LAYOUT Portal、层级、裁切和碰撞

非模态浮层不得被父容器、滚动区、固定列、固定页脚、`overflow` 或 `transform` 裁切；必要时 Portal 到应用根或当前模态层专用 root。浮层不得遮挡关键确认、底部主操作、错误摘要、危险确认或焦点目标；空间不足时必须 flip、collision adjust、max-height、内部滚动或转换承载形态。

| 规则 ID | 规则 |
| --- | --- |
| OMT-LAYOUT-01 | `placementPolicy` 必须声明 Portal root、层级、锚点、方向、flip、collision、max-height 和滚动策略。 |
| OMT-LAYOUT-02 | 非模态浮层不得被父容器、滚动区、固定列、固定页脚、`overflow` 或 `transform` 裁切。 |
| OMT-LAYOUT-03 | 空间不足时必须 flip、collision adjust、max-height、内部滚动或转换为 Action Sheet / Drawer；不得扩大页面或破坏外层滚动规则。 |
| OMT-LAYOUT-04 | 浮层不得遮挡关键确认、底部主操作、错误摘要、危险确认、虚拟键盘输入或当前焦点。 |
| OMT-LAYOUT-05 | 同一层级系统内只能有一个当前活动菜单链；多层子菜单必须有明确延迟、方向、边界和关闭路径。 |

对应验收：OMT-A6、OMT-A9。

## OMT-PERM 权限变化和安全收敛

| 规则 ID | 规则 |
| --- | --- |
| OMT-PERM-01 | 权限、租户/工作区、角色、数据版本或目标对象变化后，旧 Tooltip、Popover、Menu、菜单项和恢复入口必须失效或重新证明安全。 |
| OMT-PERM-02 | 旧菜单项、旧禁用原因、旧对象名称、旧下载入口和旧危险确认不得继续暴露。 |
| OMT-PERM-03 | 权限不足时，应在页面内或持久 owner 中提供安全说明；Tooltip 或 Popover 只能补充，不能作为唯一说明。 |
| OMT-PERM-04 | 菜单项隐藏、禁用和未实例化必须区分；若展示会泄露敏感能力或对象，应隐藏或替换安全说明。 |
| OMT-PERM-05 | 迟到权限回调和定位回调只有仍匹配 `overlayId`、trigger、权限版本和 owner 时才可写回。 |

对应验收：OMT-A7、OMT-A8。

## OMT-A11Y 键盘、语义和公告

| 规则 ID | 规则 |
| --- | --- |
| OMT-A11Y-01 | Tooltip trigger 必须有自身可访问名称；Tooltip 不能作为图标按钮唯一名称来源。 |
| OMT-A11Y-02 | Menu trigger 暴露展开状态和控制关系；菜单项支持方向键、Home/End、Enter/Space 和 Escape 的明确语义。 |
| OMT-A11Y-03 | Popover 内可交互内容必须有合理焦点顺序；关闭后焦点返回 trigger 或安全替代目标。 |
| OMT-A11Y-04 | 完整错误、权限原因、确认后果、结果回执和恢复入口不得只由 tooltip、hover 或临时浮层公告。 |
| OMT-A11Y-05 | 浮层状态公告必须去重；不得与 Toast、Alert、表单错误或结果 owner 重复播报同一完整消息。 |

对应验收：OMT-A3、OMT-A4、OMT-A10。

## OMT-RSP 响应式与移动端

移动端不得删除菜单入口、禁用原因、危险确认、错误恢复或权限说明；hover-only 内容必须有触摸和键盘等价路径。

| 规则 ID | 规则 |
| --- | --- |
| OMT-RSP-01 | 移动端不得删除菜单入口、禁用原因、危险确认、错误恢复或权限说明。 |
| OMT-RSP-02 | Hover-only Tooltip 在触摸和移动端必须转换为内联说明、点击说明、Popover、Action Sheet 或 Drawer。 |
| OMT-RSP-03 | 复杂 Popover、Menu 和多项更多操作在窄屏、低高度、触摸目标不足或虚拟键盘影响布局时，应转换为 Action Sheet / Drawer。 |
| OMT-RSP-04 | Action Sheet / Drawer 转换必须保留同一动作语义、权限状态、禁用原因、风险等级、结果 owner、焦点返回和验证边界。 |
| OMT-RSP-05 | 移动端底部菜单不得遮挡底部主操作、安全区域、危险确认、恢复入口或虚拟键盘输入。 |

对应验收：OMT-A9、OMT-A10。

## OMT-LIFE 生命周期和清理

| 规则 ID | 规则 |
| --- | --- |
| OMT-LIFE-01 | 打开的菜单、Popover 和 Tooltip 在 route/unmount、权限变化、断点转换或 trigger 消失后不得悬空。 |
| OMT-LIFE-02 | disposal 必须清理当前实例的浮层 DOM、定位任务、滚动监听、resize 监听、延迟关闭计时器、外部点击监听和 ARIA 引用。 |
| OMT-LIFE-03 | 迟到定位回调、关闭动画回调、权限回调和异步菜单项回调不得写回新实例或清除其他实例资源。 |
| OMT-LIFE-04 | 打开新浮层前必须关闭或失效互斥的旧浮层；同一 trigger 的重复打开不得产生重复 DOM、监听器或焦点迁移。 |
| OMT-LIFE-05 | 关闭开始后冻结当前实例形态；后续断点变化不得重建第二个浮层、第二套动画或第二组清理。 |

对应验收：OMT-A8、OMT-A10。

## 可执行验收检查

下列检查以可观察状态、DOM/ARIA、事件日志、焦点轨迹、定位日志、权限快照和结果回执断言；未实际执行时必须报告为**未验证**及所需环境。

1. **状态模型与承载选择**：记录 `{overlayId, overlayKind, triggerOwner, contentOwner, openState, placementPolicy, interactionMode, dismissPolicy, focusPolicy, itemStates, responsivePolicy, disposalLog}`。分别构造 Tooltip、Popover、Menu、Dropdown Menu、Context Menu、Action Sheet 和 mobile Drawer；断言每个浮层有 owner 和承载理由。
2. **Tooltip 与 Hover 边界**：移除 Tooltip、关闭 Hover、只使用键盘和触摸；断言任务仍可完成，权限原因、错误、确认后果、危险操作、结果回执和恢复入口仍在持久 owner 或等价路径中可达。
3. **触发、关闭和焦点**：用 hover、focus、click、keyboard、touch、contextmenu 和 programmatic 打开；用 Escape、外部点击、trigger 再次点击、菜单项选择、route/unmount 和断点转换关闭。断言关闭语义明确，焦点只迁移一次。
4. **内容边界**：构造权限不足、表单错误、危险确认、部分成功、未知结果和恢复入口；断言 Tooltip / Popover 不是唯一承载，更多菜单不是隐藏唯一说明的位置。
5. **菜单项动作**：打开更多菜单、行菜单、工具栏菜单和折叠操作菜单；断言每个菜单项有动作对象、权限状态、可访问名称、禁用原因、请求身份和结果 owner。裸词菜单项失败。
6. **危险菜单项和外链任务**：在菜单中触发删除、停用、敏感导出、取消任务、重跑任务、外链和下载；断言危险项进入 `risk-actions.md`，外链和下载保留权限、离开保护、请求身份和结果回执。
7. **权限变化和安全收敛**：打开 Tooltip、Popover、Menu 和恢复入口后切换权限、租户/工作区、角色、数据版本和目标对象；断言旧浮层、旧菜单项、旧禁用原因、旧对象名和旧下载入口失效或重新证明安全。
8. **Portal、碰撞和生命周期**：在滚动容器、固定列、固定页脚、Dialog、Drawer、`overflow` 和 `transform` 场景打开浮层；断言不裁切、不遮挡关键操作，空间不足时 flip、collision adjust、max-height、内部滚动或转换。route/unmount 后旧定位和关闭回调不能写回。
9. **移动端 Action Sheet / Drawer**：在移动窄屏、低高度、触摸、虚拟键盘、200% 缩放、字体放大和安全区域下使用 Tooltip、Popover 和 Menu；断言 hover-only 内容转换为等价路径，复杂菜单转换为 Action Sheet / Drawer，并保留动作语义、权限、禁用原因、风险等级、结果 owner 和焦点返回。
10. **运行时报告边界**：浏览器、屏幕阅读器、触摸设备、真实业务组件、缩放、定位碰撞和移动端检查未实际执行时，最终报告必须逐项标为**未验证**，并写明所需浏览器、设备/viewport、输入方式及辅助技术环境。
