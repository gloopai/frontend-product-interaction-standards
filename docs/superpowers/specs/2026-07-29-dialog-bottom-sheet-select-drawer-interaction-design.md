# Dialog、Bottom Sheet 与 Select Drawer 响应式承载设计

## 背景

管理台里常见“修改套餐”“编辑记录”“新增配置”等任务会放在 Dialog 中，Dialog 内又包含 Select / Combobox。截图暴露的问题是：Select options 在 Dialog 内向下展开后，和 Dialog 标题、内容滚动区、固定页脚、确认按钮或外框边界产生冲突。若只靠提高 `z-index`、压缩行高、隐藏阴影或让 Dialog 外框滚动，会把视觉问题变成焦点、ARIA、滚动锁、虚拟键盘和移动端遮挡问题。

同一类任务在移动端还会遇到另一个问题：居中 Dialog 可用高度太少，Select popup 又需要更大的触摸目标和搜索空间。此时把整个任务转换成底部弹出的 Bottom Sheet 是合理方向；但 Bottom Sheet 只是视觉承载变化，不能降低 Drawer 的模态规则。字段级 Select 也不能简单铺在外层 Bottom Sheet 内容区里，否则会复用外层确认按钮、共享滚动容器，并导致两层交互边界混乱。

现有规范已经分别覆盖 Dialog、Drawer、Select / Combobox 和响应式转换。本设计把这些规则收束成一个明确决策：桌面端优先修正 popup 层级和碰撞；移动端任务承载层可转 Bottom Sheet；字段选项层在空间不足时转 Select Drawer；两层必须保持独立实例、独立滚动边界、独立焦点与清理责任。

## 目标

- 明确 Dialog 内 Select popup 与固定页脚、确认按钮、标题和内容滚动区冲突时的处理顺序。
- 明确 PC / 宽屏、移动端、低高度、虚拟键盘和安全区域下 Dialog、Bottom Sheet、Select Drawer 的承载选择。
- 规定 Bottom Sheet 可以保留左右边距、右边距、顶部圆角和底部安全区域，但行为上必须执行 Drawer 模态规则。
- 规定 Select Drawer 是字段选项层，不是外层任务提交层；不得复用外层确认按钮、错误状态、脏状态或滚动容器。
- 把“只靠 `z-index` 修截图”“Dialog 外框跟着 Select 滚”“移动端删除字段能力”“Select popup 覆盖确认按钮”列为失败模式。

## 非目标

- 不定义具体组件库 API、CSS 类名、Portal 实现、动画 token 或设计系统尺寸 token。
- 不强制所有移动端 Dialog 都转 Bottom Sheet；长流程、高风险、多步骤、需要稳定 URL 或刷新恢复的任务仍应升级为全屏 Drawer 或独立页。
- 不强制所有 Select 都转 Drawer；桌面端空间充足、选项少且无固定页脚冲突时仍可使用普通 popup。

## 推荐方案

采用分层承载策略。

1. **桌面 / 宽屏 Dialog 内 Select：优先修正 popup。** popup 归属当前最上层 Dialog 实例，使用模态层专用 root 或应用 root，做锚点定位、collision、flip、max-height 和 options-only scroll。popup 不得被 Dialog 内容区、外框、固定页脚、`overflow` 或 `transform` 裁切，也不得遮挡主要确认按钮。
2. **移动端任务承载层：中等复杂任务可转 Bottom Sheet。** Bottom Sheet 可从底部弹出，并保留左右边距、右边距、圆角和 safe-area 视觉处理；但遮罩覆盖、背景隔离、滚动锁、焦点陷阱、固定标题、关闭按钮、固定底部操作、内容区滚动、遮罩点击不关闭、拖拽不关闭和 disposal 均按 Drawer 执行。
3. **移动端字段选项层：Select 空间不足时转 Select Drawer。** Select Drawer 只负责字段选择，保留 `selectedValue`、`query`、`activeOption`、loading、error、orphaned invalid、请求身份和焦点返回。关闭后焦点回到原 Select trigger，外层 Bottom Sheet 的取消、确认、关闭、错误摘要、脏状态和底部操作保持不变。

不采用以下方案：

- **纯 `z-index` 补丁。** 只能让截图暂时看起来不被压住，不能解决裁切、焦点、滚动、ARIA、层级归属和路由清理。
- **移动端把 Select options 直接铺在外层 Bottom Sheet 内容区。** 会造成字段选项层和任务提交层混用，外层确认按钮被误认为 Select 提交按钮，滚动容器和清理责任也会混。
- **一刀切改成独立页或全屏 Drawer。** 虽然稳，但会让轻量任务过重；只有长表单、多步骤、高风险、需要深链或刷新恢复时才升级。

## 决策规则

### Dialog 内 Select popup 冲突处理顺序

当 Select popup 与 Dialog 标题、内容滚动区、固定页脚、确认按钮或外框冲突时，按以下顺序处理：

1. 确认 popup 是否挂在当前最上层模态实例可控的 root 上，并且不受局部 `overflow`、`transform`、滚动容器或固定页脚裁切。
2. 使用锚点定位和 collision 计算；下方空间不足时向上翻转。
3. 给 options 区设置最大高度，并只让 options 内部滚动；不得让 Dialog 外框滚动。
4. 保留 popup 与底部操作区、错误摘要、安全区域之间的最小避让距离。
5. 若仍无法同时保证选项可读、触摸目标、确认按钮可达和错误可见，则在当前视口把该 Select 转为 Select Drawer。
6. 若外层任务本身也无法保证标题、正文、错误和操作可达，则把任务承载层升级为 Bottom Sheet、全屏 Drawer 或独立页。

### Bottom Sheet 的移动端语义

Bottom Sheet 可以有卡片感：左右边距、右边距、顶部圆角、底部 safe-area 间距、阴影和贴底动效都可以存在。但只要它承载一个模态任务，就必须满足 Drawer 语义：

- 遮罩覆盖完整浏览器视口。
- 背景对鼠标、触摸、键盘和辅助技术不可交互。
- 页面滚动锁定由当前实例持有和释放。
- 标题、右上角关闭、错误摘要和底部操作在低高度、字体放大、虚拟键盘和安全区域下仍可达。
- 正文滚动只发生在内容区；外框不滚。
- 遮罩点击和拖拽不关闭；关闭只能由关闭、取消、确认或明确业务操作触发。
- 形态转换保持同一实例，不重复遮罩、焦点陷阱、滚动锁、请求、动画或清理。

### Select Drawer 的字段层语义

Select Drawer 不是外层任务的替代提交层。它必须：

- 拥有自己的标题或字段名称、搜索区、options 区、loading、error、empty 和重试。
- 拥有自己的焦点约束、滚动容器、ARIA、定位/动画和 disposal。
- 只提交字段值，不提交外层表单。
- 关闭后焦点返回原 Select trigger。
- 不重置外层 Dialog / Bottom Sheet 的错误、脏状态、loading、确认按钮或取消路径。
- 不复用外层底部确认按钮作为 Select 的确认按钮。
- 不与外层正文共用滚动容器、滚动位置、滚动阴影或清理责任。

## 失败模式

- Select options 贴住或覆盖 Dialog 的取消/确认按钮，但仍被判定为“可点击所以通过”。
- 通过透明覆盖、负 margin、压缩 option 行高、隐藏滚动阴影或局部 `z-index` 让截图看似正常。
- Dialog 外框因为 Select 展开而开始滚动，标题或底部操作不再固定。
- Select popup 穿透到更上层 Dialog / Drawer，或被下层固定页脚覆盖。
- Dialog 关闭、路由卸载、滚动锚点移除后，popup DOM、定位任务、`aria-controls` 或 `aria-activedescendant` 残留。
- 移动端 Bottom Sheet 因为保留左右边距，就被实现成局部浮层，遮罩不覆盖全屏或背景仍可滚动。
- Select Drawer 打开后隐藏外层关闭/取消/确认，或把外层确认按钮当作选择提交。
- 断点切换时重建两套实例，导致重复请求、重复动画、重复滚动锁或焦点跳两次。

## 验收策略

静态规范验收：

- `references/dialogs.md` 必须包含 Dialog 内 Select popup 的 Portal、层级归属、collision、向上翻转、max-height、options-only scroll、页脚避让、ARIA 清理和移动端 Select Drawer 转换规则。
- `references/selects-comboboxes.md` 必须包含 `resolvedPlacement`、`drawer` 转换、Dialog / Bottom Sheet 内 Select Drawer、外层任务状态保持、独立滚动容器和不复用外层确认按钮规则。
- `references/responsive-adaptive.md` 必须包含 Dialog 到 Bottom Sheet、Select 到 Select Drawer、两层不重复遮罩/滚动锁/焦点陷阱、safe-area、虚拟键盘和断点转换状态延续规则。

运行时验收需要真实浏览器或组件示例覆盖：

- PC `1440×900`、`1280×720`、200% 缩放下，在 Dialog 中打开靠近底部页脚的 Select，记录 trigger、popup、选中高亮行、滚动阴影、底部操作区和安全区域矩形，确认无相交且有最小间距。
- 窄屏、低高度、横屏手机、虚拟键盘和系统字体放大下，验证任务层转 Bottom Sheet 后标题、关闭、错误摘要、正文、取消和确认可达。
- Bottom Sheet 内打开 Select，验证字段选项层转 Select Drawer 后，外层确认、取消、关闭、错误、脏状态和滚动锁保持，关闭后焦点只返回原 Select trigger。
- Dialog / Bottom Sheet 内容滚动、窗口缩放、路由卸载、上层模态打开和 trigger 移除后，验证旧 popup / Select Drawer 不残留 DOM、定位任务、监听器或 ARIA 引用。

未实际执行的浏览器、移动端、屏幕阅读器、触摸、虚拟键盘、系统字体放大和真实组件检查必须标为**未验证**。

## 设计取舍

这个方案不是把所有移动端弹窗都改成抽屉，也不是把所有 Select 都改成 Drawer。它的核心是按任务层和字段层分清 owner：外层承载任务，内层承载字段选择。桌面端先把 popup 做对；移动端在空间不足时用 Bottom Sheet 和 Select Drawer 承担各自职责。这样既能解决截图里的遮挡和裁切，也不会牺牲确认按钮、错误恢复、焦点顺序、滚动锁和辅助技术语义。
