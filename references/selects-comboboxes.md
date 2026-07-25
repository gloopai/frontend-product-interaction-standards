# 可搜索单选 Select / Combobox 交互规范

适用于自绘、单选且业务值必须来自已有选项的 Select。本文件是搜索位置、状态、提交、键盘、ARIA、PC 弹层、Drawer 与验收的唯一事实来源。多选、标签输入、自由文本创建、树/级联/日期选择，以及含独立交互控件的复杂 option 不在范围内。

响应式转换同时执行 [响应式与自适应交互规范](responsive-adaptive.md)；最终形态为 Drawer 时同时执行 [Drawer 交互规范](drawers.md)。兼容规则全部执行。

## 状态、不变量与会话

- `selectedValue` 与 `selectedOption`：已提交业务值及完整选项。**新提交**只能来自当前存在且启用的选项。
- `query`：未提交的搜索草稿；`activeOption`：键盘/ARIA 当前建议项；`open`：复合控件是否打开；`loading`、`error`：搜索请求状态。
- `searchPlacement`：业务配置或自动解析的 `auto`、`inline`、`panel`、`drawer`、`none`；`resolvedPlacement` 是当前会话最终形态。
- `displayText`：`inline` 关闭时的输入值，恒为已提交 option 标签或允许的空展示；不得以 `query`、active 标签或未匹配文本代替。
- 打开时建立会话快照：提交值、缓存标签、`query`、`activeOption` 与 `resolvedPlacement`。搜索、Hover、active、结果刷新或模式切换绝不隐式更新 `selectedValue`。

已提交的合法值可在数据刷新后成为 **orphaned invalid**：保留原始值和缓存标签，显示失效状态；按业务风险阻止表单提交或要求重新选择，但不得静默清除、替换或自动选择新项。重新选择有效项后才解除失效。

## 确定性搜索位置决策

显式 `searchPlacement` 永远优先；显式 `drawer` 即使宽屏也保持 Drawer。仅 `auto` 按以下有序函数解析，所有输入都必须来自稳定、未过滤的选项元数据与已声明的产品/视口能力，**过滤后的结果数量不得参与**：

1. 搜索不需要且选项集少而稳定，解析为 `none`。
2. 受限空间或移动任务，且需要搜索或虚拟键盘明显影响布局，解析为 `drawer`。
3. 必须持续显示当前已选值，解析为 `panel`。
4. 已声明为频繁按名称、代码或 UID 搜索，解析为 `inline`。
5. 以上条件仍无法唯一确定时，产品必须显式配置；Agent 不得猜测。超过约 7 个选项只触发 type-ahead/搜索可用性评估，不是硬阈值。

解析模式、命中的条件和理由必须可记录、可测试。一个打开会话内冻结 `resolvedPlacement`；只有已声明的视口空间、输入能力或虚拟键盘变化可以触发转换。转换不得重复请求、回调、遮罩、焦点陷阱、滚动锁或动画；保留业务状态。Portal 与模式转换中，面板、Drawer、Listbox 与 option 的 ID 必须稳定。

## 模式与精确语义

### `inline`

主输入框是 Editable Combobox，适合频繁搜索。关闭时输入 `displayText`；打开时将会话 `query` 初始化为空草稿，首次可打印编辑替换显示的已提交标签而不是追加到标签；后续编辑只修改 `query`。明确选择或 `Enter` 提交后更新 `selectedValue`、缓存标签与 `displayText` 并关闭。外部关闭、`Escape`、`Tab` 离开、模式转换导致的非提交关闭或允许的 Drawer 关闭都丢弃草稿和 active，恢复 `displayText`，且不得触发值变化。

主输入有可见字段标签（`<label>` 或 `aria-labelledby`）、`role="combobox"`、`aria-expanded`、`aria-controls`（稳定 Listbox ID）、`aria-autocomplete="list"`；仅 active 已渲染时设置 `aria-activedescendant`。主 Combobox 承担业务校验：必填时 `aria-required="true"`，失效时 `aria-invalid="true"` 并关联选择错误文本。

### `panel`

外层为 disclosure button，展示场景化字段名、当前已提交值与动作名；它具有 `aria-expanded`，`aria-controls` 指向稳定的 panel container ID。除非它实际控制的弹出节点就是 Listbox，否则不得声明 `aria-haspopup="listbox"`。外层字段包装/触发器承担字段标签、已提交值、必填提示与折叠态选择错误；它不是 Editable Combobox。

panel 打开后焦点进入顶部的内层搜索 Combobox。内层仅过滤 Listbox：有场景化名称、`role="combobox"`、列表可见时 `aria-expanded="true"`、`aria-controls` 指向稳定 Listbox ID，并仅在 active option 已渲染时设置 `aria-activedescendant`。内层搜索只关联搜索请求错误，不得承载业务“必须选择”错误。关闭动画结束后外层才设 `aria-expanded="false"` 并恢复焦点。

### `drawer`

外层为 disclosure button，展示场景化字段名、当前已提交值与动作名，并具有 `aria-haspopup="dialog"`、`aria-controls` 指向稳定 Drawer dialog ID、`aria-expanded`。显式或自动解析为 `drawer` 时，任何视口都使用 Drawer。打开后焦点进入固定标题区下方、带此选择任务场景化名称的内层搜索 Combobox；该内层的 Combobox/ID/active 契约与 `panel` 相同。外层字段包装/触发器承担选择 required/invalid，内层只承担搜索错误。关闭动画结束后外层设 `aria-expanded="false"` 并恢复焦点。

Drawer 的遮罩、固定框架、关闭按钮、背景隔离、焦点陷阱、滚动与动画必须遵循 Drawer 规范。搜索区固定可见，仅 options 区滚动；遮罩或拖拽不关闭。`Tab`/`Shift+Tab` 必须留在 Drawer 焦点环内，绝不因 Tab 关闭 Drawer。

### `none`

`none` **只**采用 WAI-ARIA Select-only Combobox：带可见字段标签/已提交值的主控件使用 `role="combobox"`、`aria-expanded`、`aria-controls`（稳定 Listbox ID），隐含 `aria-haspopup="listbox"`（可显式写为 `listbox`）；必填时 `aria-required="true"`，失效时 `aria-invalid="true"` 并关联选择错误文本。它不渲染搜索输入，也不得使用 button + Listbox 替代模型。

DOM 焦点始终保留在主 Combobox；打开时仅 active 已渲染才设置 `aria-activedescendant`。`Space` 或 `Enter` 在关闭时打开；打开时 `Enter` 提交 active，`Space` 仅在已定义为同等激活动作时才提交，否则保持打开。可打印字符执行 type-ahead，只移动 active；`ArrowUp`/`ArrowDown` 与 `Home`/`End` 导航启用 options；`Escape` 放弃草稿并关闭；`Tab` 关闭并继续页面 Tab 顺序；关闭后焦点保留/返回主 Combobox。

## 选择、ARIA option 与 active 对账

Listbox 使用 `role="listbox"`；每项有稳定 ID、`role="option"` 和 `aria-disabled="true"`（如禁用）。打开且 active 存在时，active 是唯一 `aria-selected="true"` 的 option，`aria-activedescendant` 必须引用该已渲染 DOM 节点。此 APG 建议项选择与业务提交不同：已提交项若非 active 只能有独立视觉标记，不得制造第二个 `aria-selected="true"`。无 active 时所有 options 为 `aria-selected="false"` 且移除 `aria-activedescendant`；关闭后不得把隐藏 Listbox option 暴露为 selected。

只有点击/触摸明确激活可用 option，或对 active 按 `Enter`（以及 `none` 中明确允许的 Space）才更新 `selectedValue`。每次 query、结果、虚拟渲染或模式变化都按此顺序对账 active：仍启用且已渲染的现有 active；否则启用且已渲染的 committed option；否则首个启用且已渲染 option；否则 `null`。禁用项始终跳过导航。进入 `none` 时保留会话 `query` 但暂停过滤并展示完整 options；同一会话离开 `none` 时恢复草稿和过滤；非提交关闭丢弃草稿。

## 键盘、关闭、错误与元素状态

可编辑 `inline`/`panel`/`drawer` 中，`ArrowUp`/`ArrowDown` 打开或导航 active；`Enter` 仅提交 active。`Home`、`End`、左右键、Backspace、Delete 与所有平台修饰键组合保留原生单行文本/caret 语义，不能用来强制跳至列表首尾。`none` 才用 `Home`/`End` 导航 options。

PC `inline` 在无其他 popup 控件时 Tab 关闭并继续页面。`inline` 的搜索错误重试必须是输入后相邻、键盘可达的 popup-composite 按钮，出现时 Tab 可进入；离开整个复合区才关闭。`panel` 的 Tab 可在内层搜索、状态和重试间移动；只有离开整个复合区域才关闭。重试不得放在 option 内。外部关闭、`Escape` 与允许的 Drawer 关闭按钮都放弃未提交 query/active、保留已提交值；Drawer 的 Escape 例外以 Drawer 规范为准。

优先使用原生 `disabled`/`readonly`。无法使用原生元素时，自绘 trigger/Combobox 必须使用 `aria-disabled="true"`/`aria-readonly="true"` 并阻止交互；Disabled 不可聚焦或打开，read-only 可读取已提交值但不可搜索、清空或选择。搜索错误保持当前复合控件打开并提供文本错误与重试；请求约 `250ms` 防抖，取消旧请求或忽略过期结果。请求/刷新不得清除提交值、随机重排或自动提交新第一项。

## 布局、性能与动画

PC `inline` 弹层锚定主 Combobox，`panel` 锚定 disclosure button，`none` 锚定 Select-only Combobox；至少锚点宽、可上下翻转、不得被 overflow 裁切，必要时 Portal 到应用根。非模态 PC 弹层无全屏遮罩；存在搜索时搜索/状态固定，只有 options 滚动。初次 PC 弹层打开 `150ms ease-out` 淡入小位移，关闭 `100ms ease-in`，完成后卸载；reduced motion 不位移且淡入淡出最多 `50ms`。

大量结果可虚拟化，但 active 引用的 option 必须实际在 DOM 并滚入可视区；播报结果数量/位置。远程分页不得重复 options、丢失提交值或意外移动 active。

## 验收与报告

至少验证：五种 placement 的显式配置、`auto` 决策顺序/理由/会话冻结与允许转换；inline displayText/首次编辑/非提交恢复；panel/drawer 外层与内层 ID、ARIA、焦点、动画后返回；select-only `none` 的 Space/Enter/type-ahead/Tab；唯一 `aria-selected` 和 active 对账；校验归属；PC composite Tab/重试与 Drawer 焦点陷阱；可编辑 caret 键优先级；none 查询暂停/恢复；orphaned invalid；disabled/read-only/disabled option；本地/远程搜索、竞态、错误、虚拟列表、Portal、缩放、虚拟键盘、断点和 reduced motion。未实际检查必须报告为**未验证**并写明所需检查。

## 参考资料

- [WAI-ARIA Combobox Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/)
- [WAI-ARIA Select-only Combobox Example](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/examples/combobox-select-only/)
- [WAI-ARIA Listbox Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/listbox/)
