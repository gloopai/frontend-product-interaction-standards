# 可搜索单选 Select / Combobox 交互规范

适用于自绘、单选且业务值必须来自已有选项的 Select。本文件是搜索位置、状态、提交、键盘、ARIA、PC 弹层、Drawer 与验收的唯一事实来源。多选、标签输入、自由文本创建、树/级联/日期选择，以及含独立交互控件的复杂 option 不在范围内。

多选 Select、标签输入、Tokenized Input、可创建选项、收件人 chips、批量粘贴和多值远程检索必须执行 `references/multi-select-tag-inputs.md`；本文件继续只负责单选且业务值必须来自已有选项的 Select / Combobox。

对象选择器、资源选择器、成员选择器、用户选择器、负责人选择、审批人选择、角色主体选择、账号选择器、项目选择器、工作区选择器、关联对象和关联资源必须同时执行 `references/entity-resource-pickers.md`，并声明 `entityResourcePickerState`。本文件只负责 Combobox/Listbox、popup 定位、键盘、搜索输入和 ARIA 机制；对象资源 owner 负责稳定身份、作用域、权限、最近/收藏/推荐、可绑定性和旧缓存无泄露。

作为上游或下游字段参与条件字段、依赖字段、字段联动、级联字段、联动筛选或自动填充时，必须同时执行 `references/conditional-fields-dependent-inputs.md`。Select owner 负责 query、active option、popup、候选和 selectedValue 会话；条件字段 owner 负责 `fieldDependencyState`、upstreamSnapshot、downstreamPolicy、candidatePolicy、孤儿值和隐藏值提交策略。

响应式转换同时执行 [响应式与自适应交互规范](responsive-adaptive.md)；最终形态为 Drawer 时同时执行 [Drawer 交互规范](drawers.md)。兼容规则全部执行。

## 状态、不变量与会话

- `selectedValue` 与 `selectedOption`：已提交业务值及完整选项。**新提交**只能来自当前存在且启用的选项。
- `query`：未提交的搜索草稿；`activeOption`：键盘/ARIA 当前建议项；`open`：复合控件是否打开；`loading`、`error`：搜索请求状态。
- `searchPlacement`：业务配置或自动解析的 `auto`、`inline`、`panel`、`drawer`、`none`；`resolvedPlacement` 是当前会话最终形态。
- `displayText`：`inline` 关闭时的输入值，恒为已提交 option 标签或允许的空展示；不得以 `query`、active 标签或未匹配文本代替。
- 打开时建立会话快照：提交值、缓存标签、`query`、`activeOption` 与 `resolvedPlacement`。搜索、Hover、active、结果刷新或模式切换绝不隐式更新 `selectedValue`。

已提交的合法值可在数据刷新后成为 **orphaned invalid**：保留原始值和缓存标签，显示失效状态；按业务风险阻止表单提交或要求重新选择，但不得静默清除、替换或自动选择新项。重新选择有效项后才解除失效。

## 确定性搜索位置决策

Select 承载面不得只按选项数量决定。必须同时判断搜索需求、选项文本长度、禁用项/失效项、远程加载、错误重试、虚拟键盘、触控目标、外层容器剩余高度和底部操作避让。桌面端空间充足且无固定页脚冲突时可继续使用非模态 popup；移动端、低高度、虚拟键盘、Dialog/Bottom Sheet 内、需要搜索或会遮挡确认区时默认解析为 `drawer`。不得把所有 Select 一刀切改成 Drawer，也不得为了保留 popup 而牺牲确认按钮、错误摘要、焦点可达性或外层容器的滚动边界。

显式 `searchPlacement` 永远优先；显式 `drawer` 即使宽屏也保持 Drawer。仅 `auto` 按以下有序函数解析，所有输入都必须来自稳定、未过滤的选项元数据与已声明的产品/视口能力，**过滤后的结果数量不得参与**：

1. 搜索不需要且选项集少而稳定，解析为 `none`。
2. 受限空间或移动任务，且需要搜索或虚拟键盘明显影响布局，解析为 `drawer`。
3. 必须持续显示当前已选值，解析为 `panel`。
4. 已声明为频繁按名称、代码或 UID 搜索，解析为 `inline`。
5. 以上条件仍无法唯一确定时，产品必须显式配置；Agent 不得猜测。超过约 7 个选项只触发 type-ahead/搜索可用性评估，不是硬阈值。

解析模式、命中的条件和理由必须可记录、可测试。一个打开会话内冻结 `resolvedPlacement`；只有已声明的视口空间、输入能力或虚拟键盘变化可以触发转换。转换不得重复请求、回调、遮罩、焦点陷阱、滚动锁或动画；保留业务状态。Portal 与模式转换中，面板、Drawer、Listbox 与 option 的 ID 必须稳定。

### `resolvedPlacement` 转换的焦点、ID 与 ARIA

以下映射适用于任一来源 `resolvedPlacement`（`inline`、`panel`、`drawer` 或 `none`）转换到另一最终 placement；它是跨形态焦点的唯一事实来源。转换绝不提交 `query` 或 `activeOption`，绝不改变 `selectedValue`，也绝不触发值变化回调。

- 目标为 `inline`：焦点移至主 Editable Combobox，并依 `inline` 的草稿编辑契约暴露保留的会话 `query`。
- 目标为 `panel`：复合控件保持打开时，焦点移至其内层搜索 Combobox；若一个另行定义的外部动作同时导致关闭，则在关闭动画完成后将焦点返回该 panel 的外层 disclosure trigger。
- 目标为 `drawer`：焦点移至活动焦点陷阱内的内层搜索 Combobox；外层 trigger 保留为该会话最终关闭时的返回焦点目标。
- 目标为 `none`：焦点移至 Select-only Combobox，保留会话 `query` 但不应用它，按完整、未过滤 option 集合对账 `activeOption`，且仅在 active option 已渲染时暴露 `aria-activedescendant`。

若当前精确焦点节点在 Portal 或布局移动后仍存活，必须保持该节点焦点，不得产生 blur/refocus 周期；否则只能一次性移动到上述目标形态的等价控制器。对应逻辑节点跨转换继续存在时，必须保留该会话的逻辑 popup、Listbox 与 option ID。移动焦点前或与其同一已提交渲染中，必须以目标 DOM 同步更新 `aria-controls`、`aria-expanded`、`aria-haspopup` 与 `aria-activedescendant`；不得让已聚焦控制器指向已移除的 Listbox 或 option。目标控制器角色不同，必须移除仅属于来源角色的 ARIA 属性，不得携带到目标。

### Drawer 模态基础设施转换

- 任一非 `drawer` 来源进入 `drawer` 时，必须在焦点进入 Drawer 内层搜索 Combobox 之前，以同一次不可分割的转换为当前 Select 实例取得 Drawer 遮罩、背景隔离、页面滚动锁和焦点陷阱，四项取得均恰好一次，并使 Drawer dialog DOM、名称与 ARIA 映射同时有效。转换后的最终状态只能有一套上述基础设施，页面背景不可交互；不得出现焦点已进入 Drawer 而保护尚未建立的可观察中间状态。
- 离开 `drawer` 并进入 `inline`、`panel` 或 `none` 时，必须在同一次不可分割的转换中释放当前 Select 实例持有的 Drawer 专属遮罩、背景隔离、页面滚动锁和焦点陷阱，四项释放均恰好一次。这不是关闭、取消或非提交关闭，不能触发对应回调，不能丢弃 `query`/`activeOption`，也不能改变 `selectedValue`、其他草稿或异步状态。目标 DOM/ARIA、焦点接管、Drawer DOM 移除和专属基础设施释放之间不得暴露“旧 Drawer 仍可见但背景已可交互”的中间状态。
- 焦点/ARIA 映射与模态基础设施转换必须作为同一个可观察事务结束：目标为 `drawer` 时，最终有且仅有一套有效遮罩、背景隔离、滚动锁、焦点陷阱和 Dialog ARIA；目标为 `inline`、`panel` 或 `none` 时，最终不得残留 Drawer 遮罩、`inert`、滚动锁、焦点陷阱、Drawer dialog DOM 或仅属于 Dialog 的 ARIA，且目标 placement 的 popup/Combobox ARIA 已有效。任何方向都不得重复执行进入/退出动画；单实例与动画所有权分别以 [响应式与自适应交互规范](responsive-adaptive.md) 和 [Drawer 交互规范](drawers.md) 为准。

路由变化或拥有 Select 的组件卸载时，立即执行响应式规范第 9 条的 disposal。Select 负责取消或失效自己的 query 请求、重试/防抖工作、结果/选择/值变化回调，并拆除自己的 popup、Listbox、option 引用与 ARIA 所有权；旧结果或回调不得改变新实例的 `query`、`activeOption`、`selectedValue` 或触发值变化，也不得清除其他实例持有的 Drawer 模态基础设施。此路径不向将被移除的旧 trigger 恢复焦点。

## 模式与精确语义

### `inline`

主输入框是 Editable Combobox，适合频繁搜索。关闭时可见输入值为 `displayText`；打开时将会话 `query` 初始化为空草稿。任何编辑意图——可打印输入、`Backspace`、`Delete`、paste 或 cut——都必须先把可见输入切换为 draft `query`；首次编辑替换已提交标签而不是追加，之后只更新 `query`。编辑期间 `selectedValue` 与 `displayText` 仍是 committed 值；只有明确选择或 `Enter` 才更新它们并关闭。外部关闭、`Escape`、`Tab` 离开、模式转换导致的非提交关闭或允许的 Drawer 关闭都丢弃草稿和 active，恢复 `displayText`，且不得触发值变化。

主输入有可见字段标签（`<label>` 或 `aria-labelledby`）、`role="combobox"`、`aria-expanded`、`aria-controls`（稳定 Listbox ID）、`aria-autocomplete="list"`；仅 active 已渲染时设置 `aria-activedescendant`。主 Combobox 承担业务校验：必填时 `aria-required="true"`，失效时 `aria-invalid="true"` 并关联选择错误文本。

### `panel`

外层为 disclosure button，展示场景化字段名、当前已提交值与动作名；它具有 `aria-expanded`，`aria-controls` 指向稳定的 panel container ID。除非它实际控制的弹出节点就是 Listbox，否则不得声明 `aria-haspopup="listbox"`。外层字段包装/触发器承担字段标签、已提交值、必填提示与折叠态选择错误；它不是 Editable Combobox。

panel 打开后焦点进入顶部的内层搜索 Combobox。内层仅过滤 Listbox：有场景化名称、`role="combobox"`、`aria-autocomplete="list"`、列表可见时 `aria-expanded="true"`、`aria-controls` 指向稳定 Listbox ID，并仅在 active option 已渲染时设置 `aria-activedescendant`。内层搜索只关联搜索请求错误，不得承载业务“必须选择”错误。关闭动画结束后外层才设 `aria-expanded="false"` 并恢复焦点。

### `drawer`

外层为 disclosure button，展示场景化字段名、当前已提交值与动作名，并具有 `aria-haspopup="dialog"`、`aria-controls` 指向稳定 Drawer dialog ID、`aria-expanded`。显式或自动解析为 `drawer` 时，任何视口都使用 Drawer。打开后焦点进入固定标题区下方、带此选择任务场景化名称的内层搜索 Combobox；该内层明确使用 `aria-autocomplete="list"`，其余 Combobox/ID/active 契约与 `panel` 相同。外层字段包装/触发器承担选择 required/invalid，内层只承担搜索错误。关闭动画结束后外层设 `aria-expanded="false"` 并恢复焦点。

Drawer 的遮罩、固定框架、关闭按钮、背景隔离、焦点陷阱、滚动与动画必须遵循 Drawer 规范。搜索区固定可见，仅 options 区滚动；遮罩或拖拽不关闭。`Tab`/`Shift+Tab` 必须留在 Drawer 焦点环内，绝不因 Tab 关闭 Drawer。

### `none`

`none` **只**采用 WAI-ARIA Select-only Combobox：带可见字段标签/已提交值的主控件使用 `role="combobox"`、`aria-expanded`、`aria-controls`（稳定 Listbox ID），隐含 `aria-haspopup="listbox"`（可显式写为 `listbox`）；必填时 `aria-required="true"`，失效时 `aria-invalid="true"` 并关联选择错误文本。它不渲染搜索输入，也不得使用 button + Listbox 替代模型。

DOM 焦点始终保留在主 Combobox；打开时仅 active 已渲染才设置 `aria-activedescendant`。`Space` 或 `Enter` 在关闭时打开；打开时 `Space` 与 `Enter` 都提交 active 并关闭。可打印字符执行 type-ahead，只移动 active；`ArrowUp`/`ArrowDown` 与 `Home`/`End` 导航启用 options；`Escape` 放弃草稿并关闭；`Tab` 关闭并继续页面 Tab 顺序；关闭后焦点保留/返回主 Combobox。

## 选择、ARIA option 与 active 对账

Listbox 使用 `role="listbox"`；每项有稳定 ID、`role="option"` 和 `aria-disabled="true"`（如禁用）。打开且 active 存在时，active 是唯一 `aria-selected="true"` 的 option，`aria-activedescendant` 必须引用该已渲染 DOM 节点。此 APG 建议项选择与业务提交不同：已提交项若非 active 只能有独立视觉标记，不得制造第二个 `aria-selected="true"`。无 active 时所有 options 为 `aria-selected="false"` 且移除 `aria-activedescendant`；关闭后不得把隐藏 Listbox option 暴露为 selected。

只有点击/触摸明确激活可用 option，或对 active 按 `Enter`（以及 `none` 中明确允许的 Space）才更新 `selectedValue`。每次 query、结果、虚拟渲染或模式变化都按此顺序对账 active：仍启用且已渲染的现有 active；否则启用且已渲染的 committed option；否则首个启用且已渲染 option；否则 `null`。禁用项始终跳过导航。进入 `none` 时保留会话 `query` 但暂停过滤并展示完整 options；同一会话离开 `none` 时恢复草稿和过滤；非提交关闭丢弃草稿。

## 键盘、关闭、错误与元素状态

可编辑 `inline`/`panel`/`drawer` 中，`ArrowUp`/`ArrowDown` 打开或导航 active；`Enter` 仅提交 active。`Home`、`End`、左右键、Backspace、Delete 与所有平台修饰键组合保留原生单行文本/caret 语义，不能用来强制跳至列表首尾。`none` 才用 `Home`/`End` 导航 options。

PC `inline` 在无其他 popup 控件时 Tab 关闭并继续页面。`inline` 的搜索错误重试必须是输入后相邻、键盘可达的 popup-composite 按钮，出现时 Tab 可进入；离开整个复合区才关闭。`panel` 的 Tab 可在内层搜索、状态和重试间移动；只有离开整个复合区域才关闭。重试不得放在 option 内。外部关闭、`Escape` 与允许的 Drawer 关闭按钮都放弃未提交 query/active、保留已提交值；Drawer 的 Escape 例外以 Drawer 规范为准。

优先使用原生 `disabled`/`readonly`。无法使用原生元素时，自绘 trigger/Combobox 必须使用 `aria-disabled="true"`/`aria-readonly="true"` 并阻止交互；Disabled 不可聚焦或打开，read-only 可读取已提交值但不可搜索、清空或选择。本地搜索必须随 `query` 立即过滤并在清空时恢复完整结果；Loading、结果数量、空结果和错误必须以可访问状态消息播报。搜索错误保持当前复合控件打开并提供文本错误与重试；请求约 `250ms` 防抖，取消旧请求或忽略过期结果。请求/刷新不得清除提交值、随机重排或自动提交新第一项。

## 布局、性能与动画

PC `inline` 弹层锚定主 Combobox，`panel` 锚定 disclosure button，`none` 锚定 Select-only Combobox；至少锚点宽、可上下翻转、不得被 overflow 裁切，必要时 Portal 到应用根。非模态 PC 弹层无全屏遮罩；存在搜索时搜索/状态固定，只有 options 滚动。初次 PC 弹层打开 `150ms ease-out` 淡入小位移，关闭 `100ms ease-in`，完成后卸载；reduced motion 不位移且淡入淡出最多 `50ms`。

Dialog、Drawer 或其他模态容器内的 PC Select popup 不得被容器内容区、外框、固定页脚、局部容器、`overflow` 或 `transform` 裁切。popup 应 Portal 到应用根或当前模态层专用 popup root，并锚定原 trigger；层级高于当前 Dialog 内容和固定页脚，低于更上层 Dialog/Drawer。空间不足时必须向上翻转、限制最大高度并仅让 options 区滚动，或按 `resolvedPlacement` 转换为 `drawer`；不得要求 Dialog 外框滚动，不得遮挡主要确认按钮。

模态容器内 popup 的定位、碰撞和生命周期必须绑定当前 Select 会话与当前最上层模态实例。打开、输入筛选、选项高度变化、Dialog 内容滚动、窗口缩放、动态视口变化、虚拟键盘出现和字体缩放后，必须重新计算锚点、可用空间、页脚避让和最大高度；无法安全定位时关闭 popup 或转换为 `drawer`，不得留下悬空 popup。不得用一次性 `z-index` 覆盖截图问题；popup 不能穿透更上层模态，不能被当前固定页脚盖住，也不能覆盖 Dialog 的主要确认按钮而没有翻转、限高或 Drawer 转换。关闭、取消、提交、路由卸载或来源 trigger 移除时，必须同步移除 popup DOM、定位任务和 `aria-controls` / `aria-activedescendant` 引用。

移动端、窄屏、低高度、虚拟键盘明显影响布局、触控需要更大选项目标、Dialog 内 popup 会被裁切或选项/搜索内容较多时，`auto` 应优先解析为 `drawer`。转换为 Select Drawer 后，搜索区固定可见，options 区滚动，外层 trigger 保留为最终关闭后的焦点返回目标；`selectedValue`、会话 `query`、`activeOption`、loading、error、orphaned invalid 和请求身份必须保持，不得触发值变化回调、重复请求或重复动画。

当 Select 位于移动端 Bottom Sheet Dialog 内时，若弹出 options 会挤压、遮挡或覆盖底部确认区，默认不得继续使用非模态 popup；应把该 Select 自身转换为 Select Drawer，或由产品明确把整个任务升级为全屏 Drawer/独立页。转换过程中，外层 Dialog/Sheet 的提交按钮、取消/关闭路径、错误状态和脏状态保持，不得因为打开 Select 而改变表单提交边界。

Dialog 或 Bottom Sheet 内的 Select Drawer 是字段选项层，不是外层任务承载层的替代提交。打开 Select Drawer 时，当前最上层交互切换到字段选项层；关闭 Select Drawer 后焦点返回原 Select trigger，外层 Dialog/Bottom Sheet 的确认、取消、关闭、脏状态、错误摘要和底部操作继续存在并保持原状态。不得因为 Select Drawer 打开而隐藏外层任务的关闭路径、提前提交外层表单、重置外层错误、释放外层滚动锁，或让外层确认按钮在视觉上被当作当前 Select 的提交按钮。

若移动端视觉方案要求 Bottom Sheet 保留右边距、左右边距或顶部圆角，Select Drawer 仍必须独立满足 Drawer 语义和 Select 会话语义。它可以采用符合设计系统的下方弹出样式，但不得只在原 Dialog 内部铺开 options；不得让 options 与外层固定页脚共享滚动容器；不得让 options 列表贴边覆盖外层固定页脚、取消按钮、确认按钮或错误摘要；不得以缩小字号、压缩行高或覆盖确认按钮来避免转换。

Select Drawer 是字段选项层的独立承载面，不得让 Select Drawer 与外层 Bottom Sheet 正文共用同一个滚动容器。外层任务承载层的标题、关闭、错误摘要、脏状态和底部操作区保持自己的固定/滚动边界；内层 Select Drawer 的搜索、状态、options、active option 和确认/取消语义保持自己的滚动边界与焦点约束。两层可以在视觉上同属一套底部弹出语言，但 DOM、ARIA、滚动锁、焦点陷阱、滚动容器和清理责任必须能按实例区分。

大量结果可虚拟化，但 active 引用的 option 必须实际在 DOM 并滚入可视区；播报结果数量/位置。远程分页不得重复 options、丢失提交值或意外移动 active。

## 验收与报告

至少验证：五种 placement 的显式配置、`auto` 决策顺序/理由/会话冻结与允许转换；inline 的可打印/Backspace/Delete/paste/cut 草稿进入、displayText 与非提交恢复；panel/drawer 内层 `aria-autocomplete="list"`、outer/inner ID、ARIA、焦点和动画后返回；select-only `none` 的 Space/Enter 均提交、type-ahead/Tab；唯一 `aria-selected` 和 active 对账；校验归属；本地即时过滤与 Loading/结果数量/空/错误播报；PC composite Tab/重试与 Drawer 焦点陷阱；可编辑 caret 键优先级；none 查询暂停/恢复；orphaned invalid；disabled/read-only/disabled option；远程竞态、虚拟列表、Portal、缩放、虚拟键盘、断点和 reduced motion。

任一 `inline`、`panel`、`drawer`、`none` 来源到任一不同目标的转换，都必须在 `query`、active、loading、error、orphaned invalid 与远程请求存在时执行以下集中验收检查：

1. 逐项比较转换前后 `selectedValue` 与会话 `query`，两者必须保持；`activeOption` 也必须保持，唯目标为 `none` 时按「选择、ARIA option 与 active 对账」的完整未过滤集合规则对账。确认没有值变化回调或重复请求，且关闭返回目标保持。
2. 记录焦点与 `focus`/`blur` 事件：精确焦点节点仍存活时不得有 blur/refocus；否则只能向目标等价控制器发生一次焦点移动。
3. 对仍延续的逻辑节点比较转换前后 popup、Listbox 与 option ID，必须相同；同时确认 `aria-controls` 当前存在，`aria-activedescendant` 只引用已渲染 active option。
4. 在焦点移动前或同一 committed render 检查目的 DOM：`aria-expanded`、`aria-haspopup`、`aria-controls` 与 `aria-activedescendant` 均与目标控制器和节点一致；控制器角色改变时，来源专属 ARIA 属性已经移除。
5. 对每个非 `drawer` 来源进入 `drawer`，分别记录遮罩、背景隔离、页面滚动锁和焦点陷阱的取得计数及 Drawer 内层搜索 Combobox 的 `focus` 事件；四项计数都必须从 0 变为 1 且先于焦点进入，最终背景不可交互、只有一套 Drawer 模态基础设施和有效 Dialog ARIA。
6. 从 `drawer` 分别转换到 `inline`、`panel`、`none`，记录四项 Drawer 专属基础设施的释放计数、关闭/取消/值变化回调和每一帧的背景/模态状态；每项只能释放一次，三个关闭类回调均不得触发，业务与草稿状态保持，且最终没有残留遮罩、`inert`、滚动锁、焦点陷阱、Drawer DOM 或 Dialog 专属 ARIA。全过程不得出现旧 Drawer 仍可见但背景可交互的状态，目标 placement 的焦点与 ARIA 必须有效。
7. 在 query 请求、重试/防抖和结果/选择回调待处理时触发路由变化及拥有组件卸载；确认这些工作全部取消或失效，旧回调不能改变新实例或触发值变化，Select 自己的 popup/Listbox/option 与 ARIA 引用全部拆除，只释放自己持有的基础设施，且焦点不返回将被移除的旧 trigger。
8. 在 Dialog 内打开 Select popup，确认 popup 未被 Dialog 内容区、外框、固定页脚、局部容器、`overflow` 或 `transform` 裁切；PC 空间不足时向上翻转、限高且仅 options 区滚动；移动端或虚拟键盘场景转换为 Select Drawer 后，`selectedValue`、`query`、`activeOption`、loading、error 和请求身份保持，且没有重复遮罩、焦点陷阱、滚动锁、请求或动画。
9. 在 Dialog 内容滚动、固定页脚遮挡、锚点移除、窗口缩放、字体放大、虚拟键盘出现和更上层模态打开时检查 popup 定位与层级：必须重算或安全关闭，不能穿透更上层模态，不能留下悬空 popup，ARIA 引用不能指向已卸载节点。
10. 在移动端 Bottom Sheet 内打开 Select，验证 Select Drawer 是字段选项层：外层 Dialog/Bottom Sheet 的确认、取消、关闭、脏状态、错误摘要、底部操作和滚动锁保持；Select Drawer 关闭后焦点只返回原 Select trigger，不提交外层表单、不重置外层错误、不把外层确认按钮当作 Select 提交按钮；并记录外层正文滚动容器与内层 options 滚动容器是可区分的独立实例，没有共享滚动容器、滚动位置串扰或清理互相释放。

未实际检查必须报告为**未验证**并写明所需检查。

## 参考资料

- [WAI-ARIA Combobox Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/)
- [WAI-ARIA Select-only Combobox Example](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/examples/combobox-select-only/)
- [WAI-ARIA Listbox Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/listbox/)
