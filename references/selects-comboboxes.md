# 可搜索单选 Select / Combobox 交互规范

适用于自绘、可搜索、**单选**且业务值必须来自已有选项的 Select。本文件是此类组件的搜索位置、状态、键盘、ARIA、PC 弹层、移动端 Drawer 与验收规则的唯一事实来源。各模式都使用 Listbox，但搜索输入的位置和外部触发器语义必须按场景选择，不能统一假定为 Editable Combobox。

多选、标签输入、自由文本创建、树选择、级联选择、日期选择，以及选项中含按钮、链接、复选框等独立交互控件的复杂列表不在本规范范围；它们不得伪装成此类 Select。

涉及响应式转换时，同时执行 [响应式与自适应交互规范](responsive-adaptive.md)；移动端最终形态为 Drawer 时，同时执行 [Drawer 交互规范](drawers.md)。兼容规则全部执行。

## 状态模型与提交边界

组件必须分离以下状态：

- `selectedValue`：已提交的业务值；只能为已有、有效选项的值，或业务明确允许的空值。
- `selectedOption`：与 `selectedValue` 对应的完整选项。
- `query`：当前搜索文本，不是业务值。
- `activeOption`：键盘当前高亮、尚未提交的选项。
- `open`：弹层或 Drawer 是否打开。
- `loading`、`error`：异步搜索状态。
- `searchPlacement`：搜索位置策略，值为 `auto`、`inline`、`panel`、`drawer` 或 `none`；`auto` 的最终模式必须可确定且可访问。

搜索、键盘移动、Hover、结果刷新和打开时的默认高亮只能改变 `query`、`activeOption`、结果或展示；不得隐式改变 `selectedValue`。只有用户明确选择可用选项，或执行业务允许的独立清空操作，才能更新 `selectedValue`，触发一次值变化与校验。不得把未匹配的 `query`、第一项、新到达的远程结果或 Hover 项提交为值。

打开时，有已选值则定位并高亮该选项；无已选值时可以高亮第一项，但不得自动提交。改变搜索位置或响应式断点时，必须保留同一 `selectedValue`、`query`、`activeOption`、`open`、加载与错误状态，不得清空已选值、重复请求/回调或产生多实例。Disabled 状态不得聚焦或打开；Read-only 状态可读取当前值，但不得搜索、清空或选择。打开、关闭、选择与异步回调期间必须防止重复执行。

## 搜索位置策略

业务可显式指定 `searchPlacement`；`auto` 由选项规模、搜索频率、是否必须持续展示已选值、可用空间、输入方式和虚拟键盘影响共同决定。Agent 不得只凭个人偏好选择模式，也不得以脆弱的固定数量阈值取代场景判断；选项超过约 7 项时，应评估 type-ahead 或搜索是否更易用。

- `inline`：主输入框就是 Editable Combobox，显示当前值并承载搜索，适合用户频繁按名称、代码或 UID 搜索的场景。
- `panel`：外部是展示已选值的 Select 触发按钮；PC 弹层顶部的搜索输入才是控制 Listbox 的 Combobox，适合必须始终看见已选值的 PC 表单。不得将该触发按钮错误标为 Editable Combobox。
- `drawer`：外部为触发按钮；Drawer 固定标题区下方的搜索输入才是控制 Listbox 的 Combobox，适合移动端、选项很多或虚拟键盘显著影响布局的场景，同时执行 Drawer 规则。
- `none`：少量简单选项不展示搜索框，使用 Select-only Combobox 或按钮 + Listbox，并提供键盘 type-ahead。不得渲染没有实际搜索能力的假搜索输入。
- `auto`：在打开前或切换时解析为上述某一最终模式；解析结果必须保持用户当前业务上下文，不能在一次打开中并存两套触发器、搜索输入、遮罩、焦点陷阱或回调。

## 打开、关闭、清空与错误

1. 点击当前模式的输入区域或触发按钮打开；`ArrowDown` 与可选的 `Alt + ArrowDown` 也可打开。
2. 选择一个可选项后，更新 `selectedValue`、仅触发一次值变化并关闭。PC 非模态浮层点击外部可以关闭，但不得改变已提交值。
3. 外部关闭、`Escape` 与允许关闭的 Drawer 右上角关闭按钮都必须放弃本次未提交的搜索和高亮，保留已选值；`Tab` 正常离开当前控件并关闭。它们都不得把未匹配文本提交为值。Drawer 的遮罩、关闭路径与 Escape 例外同时执行 Drawer 规范。
4. 是否可清空由业务显式配置。可清空时提供与展开按钮语义分离、可聚焦且有可访问名称的清空按钮；必填字段不得提供会静默产生无效状态的清空方式。清空执行一次正常的校验和值变化回调。
5. 搜索失败时保持组件打开，显示文本错误和重试操作；不要自动关闭、清除已选值或转而选中其他选项。Loading、结果数量、无结果和错误必须向辅助技术暴露恰当的状态消息。

## 搜索、选项与异步数据

- 默认只匹配选项主标签，并忽略首尾空格和大小写。代码、中文名称、拼音或其他字段必须由业务明确配置，不能默认猜测。
- 本地数据即时过滤；清空 `query` 恢复完整结果；无匹配结果显示清晰空状态。
- 远程搜索建议约 `250ms` 防抖。新请求发出时取消旧请求，或以请求序号/查询键忽略**过期结果**；过期结果不得覆盖当前查询、错误、结果或 `activeOption`。
- 查询变化、请求失败、结果刷新、分页或排序均不得清除或替换 `selectedValue`。已选项暂时不在当前搜索结果中时仍须保留。
- 选项排序保持稳定；异步刷新不得随机重排或使高亮项无故跳动。相同标签必须提供可区分信息；禁用项清楚可见、不可选择，必要时说明原因。
- 数据刷新后若已选值失效，展示明确失效状态并要求用户重新选择；不得静默清空、自动改选或自动提交第一项。

## 键盘、焦点与 ARIA

有搜索输入的 `inline`、`panel` 和 `drawer` 模式中，**控制 Listbox 的搜索输入**必须进入正常页面 `Tab` 顺序，并支持：

- `ArrowDown` / `ArrowUp`：打开或在可选项间移动 `activeOption`；跳过不可选项。
- `Enter`：仅提交当前高亮且可选的选项。
- `Escape`：关闭并放弃本次未提交状态。
- `Home` / `End`：移动至第一项/最后一项；可打印字符执行文本输入和搜索。
- `Backspace`、`Delete`、左右方向键和系统文本编辑快捷键保持原生单行文本编辑语义。

仅明确选择一个可用选项或按 `Enter` 才能提交；高亮、type-ahead 匹配、鼠标 Hover、触发器打开和模式切换绝不等同提交。`none` 模式不渲染搜索输入：Select-only Combobox 或按钮 + Listbox 必须支持 type-ahead，并使用箭头键、`Home`、`End`、`Enter`、`Escape` 和可打印字符定位/选择选项。

PC Listbox 打开时，当前控制 Listbox 的 Combobox 必须保留 DOM 焦点并以 `aria-activedescendant` 表达高亮项；高亮、已选与焦点状态必须可视地区分。关闭后焦点返回相应的 Combobox 或外部触发按钮；跨端或运行时模式转换时移至等价搜索输入或触发按钮，无法对应时移至合理标题。

`inline` 的主输入框是 Editable Combobox，必须有可见 Label 并以原生 `<label>` 或 `aria-labelledby` 关联，且具备 `role="combobox"`、`aria-expanded`、`aria-controls`、`aria-autocomplete="list"`；打开且存在高亮项时设置 `aria-activedescendant`。

`panel` 与 `drawer` 的外部触发器是展示已选值的按钮，不得标为 Editable Combobox；它应具有可访问名称、`aria-expanded`、`aria-controls`，并按实现使用适当的 popup/listbox 语义。弹层顶部或 Drawer 固定标题区下方的搜索输入才是带 `role="combobox"`、`aria-controls`、`aria-autocomplete="list"` 和在有高亮项时 `aria-activedescendant` 的控件。`none` 模式的 Select-only Combobox 或按钮 + Listbox 按其实际模式提供对应语义，不能虚构搜索字段。

每个搜索输入必须有场景化可访问名称，例如“搜索币种”或“搜索用户”；不得只提供缺少上下文的泛化占位符。必填项设置 `aria-required="true"`；出错时设置 `aria-invalid="true"` 并关联错误文本。

选项容器使用 `role="listbox"`；每个选项使用稳定唯一 ID、`role="option"` 与正确的 `aria-selected`。Option 内不得放置独立可交互控件。辅助技术必须可获得名称、当前值、展开状态、高亮项、选中项、结果数量及错误状态。

## PC 非模态弹层

- `inline` 的弹层锚定 Editable Combobox；`panel` 的弹层锚定外部触发按钮，顶部放置控制 Listbox 的搜索 Combobox；`none` 锚定其 Select-only Combobox 或按钮。弹层至少与其锚点同宽；可按内容扩大但不能超出视口。根据可用空间向下或向上展开，不能被 `overflow` 祖先裁切；必要时挂载到应用根节点。
- 弹层非模态，不使用全屏遮罩。存在搜索输入时，搜索输入与状态区域保持可见；仅选项区域设置最大高度并滚动。
- 初次打开使用淡入与小幅位移 `150ms ease-out`；关闭使用 `100ms ease-in`。`prefers-reduced-motion: reduce` 时取消位移，淡入淡出最多 `50ms`，或直接切换。动画期间阻止重复打开、关闭与回调，关闭后再卸载。

## 移动端与 Drawer

选项少且空间充足时可保留锚定浮层；选项多、需要搜索或虚拟键盘显著影响布局时，`drawer` 模式使用底部 Drawer。Drawer 内的固定标题区下方使用控制 Listbox 的独立搜索 Combobox；外部保留展示已选值的触发按钮。二者与 PC 共享同一 `selectedValue`、选项数据源、`query`、`activeOption`、错误与请求状态，且搜索区固定可见、仅选项列表滚动。

转换为 Drawer 后，关闭路径、遮罩、滚动、焦点、背景隔离、固定标题与右上角关闭按钮、层级、清理和 Drawer 动画必须遵循 [Drawer 交互规范](drawers.md)；选择值、查询和高亮仍遵循本文件的状态规则。初次打开只使用最终形态的动画：PC 使用本文件的弹层动画，移动端最终为 Drawer 时使用 Drawer 动画。已打开实例跨断点转换时保持**单实例**，不重复请求、遮罩、焦点陷阱、滚动锁或值变化回调，也不得叠加两套进入/退出动画；保留未提交状态并转移焦点到等价目标。

## 大数据量与性能

普通数据量使用完整 Listbox。大量选项可使用**虚拟列表**，但 `aria-activedescendant` 指向的高亮选项必须实际存在于 DOM，并自动滚入可视区域。辅助技术必须可获得结果数量与当前位置。远程分页或无限加载不得丢失已选值、产生重复结果或意外改变高亮项。

## 验收与报告

至少验证 `auto` 解析和 `inline`、`panel`、`drawer`、`none` 每一种最终模式：鼠标/触摸打开、输入搜索（适用时）、type-ahead（`none`）、明确选择、PC 外部关闭与 Drawer 关闭按钮；完整键盘与原生文本编辑快捷键；`Escape`、`Tab` 与未匹配文本不改变已选值；模式或断点运行时切换仍保持单实例和状态分离；本地与远程搜索、防抖、竞态、Loading、空结果、失败和重试；Disabled、Read-only、Required、Invalid 与清空；长/重复/禁用选项和失效值；PC 上下定位、滚动容器与 Portal；移动端 Drawer、虚拟键盘、200% 缩放、Reduced Motion、长文本/国际化和大量数据；以及屏幕阅读器的场景化名称、状态播报与各模式语义。

未实际执行的交互、输入方式、辅助技术或视口检查必须明确报告为**未验证**，并写明所需检查；不得将未执行检查表述为已通过。

## 参考资料

- [WAI-ARIA Combobox Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/)
- [WAI-ARIA Listbox Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/listbox/)
- [W3C WCAG 2.2](https://www.w3.org/TR/WCAG22/)
