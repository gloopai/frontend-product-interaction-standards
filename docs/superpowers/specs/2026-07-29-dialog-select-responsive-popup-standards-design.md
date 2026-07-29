# Dialog 内浮层裁切与移动端底部 Drawer 转换规范设计

## 背景

用户截图中，Dialog 内 Select 展开后被 Dialog 内容区或外框裁切，选项列表与底部操作区挤压在同一可视区域里，导致层级、滚动、焦点和可读性都不稳定。这个问题通常来自两类错误实现：

- 把 Select popup 渲染在 Dialog 内容滚动区内部，使其受 `overflow`、局部定位上下文或固定底部操作区裁切。
- 为了解决 popup 裁切，反向放宽 Dialog 外框滚动规则，导致标题、关闭按钮或底部操作区随内容滚走。

同时，移动端空间、虚拟键盘和触控场景下，居中 Dialog 承载长表单或 Select 列表会很局促。现有 `responsive-adaptive.md` 已允许内容较多的桌面 Dialog 在窄屏转换为底部或全屏 Drawer，也允许 Select 自动解析为 Drawer；但还需要把“Dialog 内 Select popup 裁切”和“底部留边距 Drawer / Bottom Sheet”写成更明确的验收点。

## 目标

- 明确 Dialog 内 Select / Combobox / Dropdown popup 不得被 Dialog 内容区、外框、固定页脚或局部容器裁切。
- PC / 宽屏优先通过 portal、统一浮层层级、flip、max-height 和 options-only scroll 解决，而不是让 Dialog 外框滚动。
- 移动端复杂 Dialog 推荐转换为底部 Drawer / Bottom Sheet；视觉上可左右留边距和圆角，但交互语义按 Drawer 执行。
- 移动端 Select 在空间不足、需要搜索、虚拟键盘明显影响布局或选项较多时，优先转换为 Select Drawer。
- 明确转换必须保持单实例、状态连续、焦点连续、模态保护连续，不得重复请求、重复动画、重复遮罩或丢失草稿。

## 非目标

- 不规定具体圆角、阴影、色值、间距 token 或组件库 API。
- 不把所有移动端 Dialog 强制改成 Drawer；短确认、短提示和极轻量任务仍可保留居中 Dialog。
- 不改变 Select 的业务提交语义：非提交关闭仍不得改变 `selectedValue`。
- 不降低 Dialog 和 Drawer 现有遮罩、关闭、焦点、滚动和清理规则。

## 设计方案

### PC / 宽屏 Dialog 内 popup

Dialog 外框继续保持不可滚动，只有内容区域滚动。Dialog 内的 Select / Combobox / Dropdown popup 必须渲染到不会被 Dialog 内容滚动区裁切的位置，优先是应用根节点或当前模态层的专用 popup root。popup 仍锚定触发控件，并受同一模态层约束：高于 Dialog 内容和固定页脚，低于更上层 Dialog/Drawer。

当下方空间不足时，popup 应向上翻转或限制 options 区高度；搜索框、状态和关键操作保持固定，只有 options 区滚动。不得通过放开 Dialog 外框滚动、隐藏底部操作区、覆盖确认按钮或扩大遮罩外内容来解决。

### 移动端 Dialog 转底部 Drawer

移动端复杂 Dialog 可以转换为底部 Drawer / Bottom Sheet。适用场景包括：内容较长、有表单、有 Select、有虚拟键盘、有固定底部操作、需要参考上下文但空间不足。短确认、极短提示、低复杂度任务可继续使用居中 Dialog。

底部 Drawer 可以不是全宽贴边；允许左右留边距、顶部圆角和底部安全区域适配。但只要它是模态底部浮层，交互上必须执行 Drawer owner：完整遮罩、背景隔离、页面滚动锁、焦点陷阱、固定标题/关闭、固定底部操作、内容区滚动、遮罩点击不关闭、拖拽不关闭。

### 移动端 Select 转 Select Drawer

Dialog 内 Select 在移动端若需要搜索、选项较多、popup 会被裁切、虚拟键盘影响布局或触控选择需要更大空间，应解析为 `drawer`。Select Drawer 内搜索区固定，options 区滚动；外层 trigger 保留为关闭后的焦点返回目标。

Select 从 PC popup 转到 Drawer，或从 Drawer 转回 PC popup 时，必须保持同一 Select 会话：`selectedValue`、`query`、`activeOption`、loading/error、orphaned invalid 和异步请求身份不丢失、不重复提交、不重复请求。

## 硬性红线

- Dialog 内 popup 不得被 Dialog 内容滚动区、外框、固定页脚、局部容器、`overflow` 或 `transform` 裁切。
- 不得为了 Select popup 展开而让 Dialog 外框滚动。
- popup 不得遮挡 Dialog 主要确认按钮；空间不足时必须 flip、限高或转换为 Drawer。
- 移动端复杂 Dialog 转 Bottom Drawer 后，不能删除标题、关闭路径、提交、取消、错误、未保存保护或底部操作。
- Bottom Drawer 即使左右留边距和圆角，也必须执行 Drawer 的模态、焦点、遮罩、滚动和清理规则。
- Select 转 Drawer 不得改变已提交值、提交草稿、重置搜索、重复请求或触发值变化回调。
- 已打开 Dialog/Select 在断点变化时必须保持单实例，不能产生重复遮罩、焦点陷阱、滚动锁、动画或异步回调。

## 验收策略

新增或扩展审计脚本，验证：

- `dialogs.md` 明确 Dialog 内 popup 不得被裁切，且不得通过外框滚动解决。
- `selects-comboboxes.md` 明确 PC popup portal/flip/max-height，移动端空间不足时 Select Drawer 优先。
- `responsive-adaptive.md` 明确 Bottom Drawer 可左右留边距和圆角，但语义仍为 Drawer。
- RED/GREEN 证据包含截图对应负例：Dialog 内 Select popup 被页脚裁切、Dialog 外框被迫滚动、移动端删除关闭/底部操作、Select 转 Drawer 丢 query 或 selectedValue。
- 运行时浏览器、触摸设备、真实组件和真实视口未执行时必须标为未验证。
