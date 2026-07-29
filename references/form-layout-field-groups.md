# 表单布局、字段分组与响应式排列交互规范

适用于表单布局、字段布局、字段分组、表单区块、字段区块、两列表单、三列表单、详情编辑布局、设置表单布局、筛选表单布局、表单栅格、字段对齐、label 对齐、帮助文本排列、错误文本排列、表单 Section、表单 Card、移动端表单布局、field layout、form layout、form grid、field group、form section、form card、two-column form、responsive form 和 settings form layout。本文件是“字段如何在页面、Dialog、Drawer、Sheet 或独立编辑页中被排列、分组、换行和响应式转换”的 owner。

本 owner 只负责表单 UI 布局与交互排列，不定义字段业务值、校验规则、提交生命周期、权限策略、后端模型或视觉 token。字段状态、dirty、touched、校验、错误摘要和提交继续执行 `references/forms.md`；字段 label、placeholder、帮助文本、单位、格式示例和错误描述关系继续执行 `references/field-guidance-help-text.md`；Dialog / Drawer 承载继续执行 `references/dialogs.md` 与 `references/drawers.md`；页面内容区、Section/Card 注册、主滚动和 sticky/fixed 避让继续执行 `references/page-content-layout-sections.md`；页面保存区和底部操作栏继续执行 `references/page-form-action-bars.md`；响应式、触摸、虚拟键盘、安全区域和缩放继续执行 `references/responsive-adaptive.md`；文本溢出继续执行 `references/text-overflow-truncation.md`。

## 范围与边界

本 owner 覆盖：

- 单列表单、两列表单、三列表单、紧凑设置表单、宽字段跨列、字段组、表单 Section、表单 Card、说明区、只读/编辑混排和分步表单中的单步布局。
- label、输入控件、帮助文本、错误文本、单位、后缀、前缀、计数、字段内操作、组合字段和跨字段说明的布局关系。
- 字段顺序、视觉顺序、键盘顺序、读屏顺序、移动端单列转换、低高度视口、虚拟键盘、安全区域、底部保存栏避让和滚动定位。
- 字段新增/隐藏/展开、条件字段显隐后的布局重排、错误定位、首个错误聚焦、字段组错误摘要和局部加载骨架。

本 owner 不覆盖完整记录编辑承载面选择；新增/编辑记录必须继续执行 `references/record-editing-surfaces.md`。折叠分组执行 `references/disclosure-accordions.md`，本文件只规定折叠前后的布局与错误外显要求。

## `formLayoutState`

每个复杂表单、设置表单、编辑页、Dialog 表单或 Drawer 表单必须维护 `formLayoutState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `formLayoutOwnerId` | 当前表单布局实例身份，绑定字段注册、Section、滚动、错误定位和响应式转换。 |
| `layoutSurface` | `page`、`dialog`、`drawer`、`mobile-sheet`、`wizard-step`、`settings-page` 或产品声明的承载面。 |
| `fieldRegistry` | 字段、组合字段、只读字段、隐藏字段、跨列字段、字段内操作和错误目标的注册表。 |
| `groupRegistry` | 字段组、Section、Card、标题、描述、组级错误、组级操作和折叠状态的注册表。 |
| `layoutMode` | `single-column`、`two-column`、`three-column`、`compact-grid`、`definition-edit` 或产品声明的布局模式。 |
| `breakpointPolicy` | 各断点下列数、字段跨列、组顺序、操作区位置、滚动容器和安全区域策略。 |
| `fieldOrder` | 视觉顺序、DOM 顺序、Tab 顺序和读屏顺序；四者不一致时必须声明原因与补偿。 |
| `alignmentPolicy` | label、控件、单位、帮助文本、错误文本、计数、后缀、前缀和字段内操作的对齐方式。 |
| `spanPolicy` | 长文本、富文本、上传、代码、地址、描述、表格子项、预览区和危险说明等跨列策略。 |
| `densityPolicy` | 默认、紧凑、舒适、只读、编辑、低高度和高缩放场景下的间距与触控目标。 |
| `overflowPolicy` | 长 label、长帮助、长错误、长选项、长值、组合字段和横向溢出的折行、截断与查看全文策略。 |
| `errorPlacementPolicy` | 字段错误、组级错误、错误摘要、首个错误滚动、聚焦目标和底部操作栏避让策略。 |
| `loadingPlaceholderPolicy` | 字段级 loading、组级 loading、骨架屏、保留高度、迟到加载和布局跳动防护。 |
| `conditionalLayoutBinding` | 条件字段显隐、动态字段插入、字段组展开/收起、清值和错误外显后的布局重排边界。 |
| `actionBarAvoidance` | sticky/fixed 保存栏、Dialog footer、Drawer footer、移动端底部操作和虚拟键盘的避让关系。 |
| `responsivePolicy` | 移动端单列、字段顺序、组标题、帮助/错误、保存/取消、滚动定位和键盘恢复策略。 |
| `focusRestorationPolicy` | 添加/删除/隐藏字段、断点转换、错误跳转、保存失败和关闭后的焦点恢复。 |
| `lifecycleDisposal` | 卸载、关闭、断点转换、字段注册变化、条件显隐和迟到布局测量后的清理。 |
| `runtimeVerification` | 浏览器、键盘、读屏、触摸、虚拟键盘、缩放、低高度和移动端验证状态；未执行必须标为未验证。 |

不得只用 CSS Grid、栅格列数、`span`、`labelCol`、`wrapperCol`、组件库 Form.Item 布局、两个 div、媒体查询或视觉稿截图替代 `formLayoutState`。

## 核心规则

| 规则 ID | 规则 |
| --- | --- |
| `FLG-SCOPE-01` | 只要表单存在字段分组、两列及以上布局、跨列字段、动态字段、底部操作栏或移动端转换，就必须声明本 owner。 |
| `FLG-ORDER-01` | 视觉顺序、DOM 顺序、Tab 顺序和读屏顺序默认必须一致；不一致时必须有明确原因、键盘补偿和读屏补偿。 |
| `FLG-GROUP-01` | 字段组必须有可见标题或等价语义；组描述、组级错误和组级操作不得只靠空间距离暗示归属。 |
| `FLG-LABEL-01` | label、帮助文本、单位、错误文本和计数必须绑定到对应字段；不得用占位符、tooltip-only 或相邻文本替代字段 label。 |
| `FLG-GRID-01` | 两列/三列表单不得让跨列字段、长错误、长帮助或组合字段挤压相邻字段；必要时必须跨列或降级为单列。 |
| `FLG-GRID-02` | 栅格列数不能只由屏幕宽度决定，还必须考虑字段类型、内容长度、输入复杂度、错误文本、底部操作栏、缩放和虚拟键盘。 |
| `FLG-SPAN-01` | 富文本、上传、代码、长描述、地址、多选标签、对象选择器、表格子项和预览区默认跨列；除非有真实空间证明，否则不得塞进窄列。 |
| `FLG-ERROR-01` | 字段错误必须出现在字段附近，错误摘要必须能滚动并聚焦到真实字段；sticky/fixed footer 不得遮挡错误、帮助或聚焦字段。 |
| `FLG-DYNAMIC-01` | 条件字段显示、隐藏、插入、删除或展开后，布局、Tab 顺序、错误摘要、滚动锚点和焦点目标必须同步重算。 |
| `FLG-LOADING-01` | 字段或字段组 loading 必须保留可预测高度，避免保存栏、错误摘要和焦点目标跳动；迟到布局测量不得覆盖当前断点或已卸载 owner。 |
| `FLG-RSP-01` | 移动端必须转为单列或等价分组，不得保留需要横向滚动才能填写的两列/三列主表单。 |
| `FLG-RSP-02` | 移动端不得删除组标题、字段 label、帮助文本、错误文本、必填/选填、保存/取消、未保存提示和错误跳转。 |
| `FLG-A11Y-01` | 字段组、组合字段、错误文本、帮助文本和动态字段变化必须有可访问语义；视觉缩进、颜色或位置不能作为唯一关系。 |
| `FLG-VERIFY-01` | 未在真实浏览器、键盘、读屏、触摸、虚拟键盘、缩放、低高度和移动端视口验证前，必须标为未验证。 |

## 推荐布局策略

- 单列表单用于短流程、移动端、Dialog 小表单、错误较多或字段说明较长的场景。
- 两列表单用于字段较多但每个字段输入简单、说明较短且错误文本不会挤压相邻字段的 PC 场景。
- 三列表单只用于非常短的设置项或筛选项；出现长 label、长错误、对象选择、上传、富文本、日期范围或多选标签时必须降级。
- 字段组应按任务或语义分组，不按后端字段顺序机械切块；同一组内字段数量过多时拆分 Section 或使用向导。
- 只读/编辑混排时，只读字段也必须占据稳定布局位置，并明确哪些字段可编辑；不得靠输入框边框有无让用户猜。

## 移动端与窄屏

1. 两列/三列布局转为单列，字段顺序以任务流程为准，不得简单逐列拼接导致语义错乱。
2. 组标题、描述、字段 label、帮助文本、错误文本和保存/取消必须保留。
3. 虚拟键盘出现时，当前字段、错误文本和底部操作栏必须同时可达；不能让固定 footer 覆盖输入。
4. 错误摘要跳转必须滚动到字段、显示错误并把焦点放到可编辑控件或组级错误。
5. 字段组折叠时，有错误的组必须外显错误数量和可达跳转。

## 审计清单

- 是否声明 `formLayoutState`，且覆盖字段注册、组注册、布局模式、断点、顺序、对齐、跨列、密度、溢出、错误、loading、条件布局、操作栏避让、响应式、焦点和生命周期。
- 是否证明视觉顺序、DOM 顺序、Tab 顺序和读屏顺序一致或有补偿。
- 是否禁止用 CSS Grid、span、labelCol/wrapperCol、组件库默认 Form.Item 或截图替代布局 owner。
- 是否处理长 label、长帮助、长错误、组合字段、跨列字段和底部操作栏遮挡。
- 是否在移动端保留组标题、label、帮助、错误、保存/取消、未保存提示和错误跳转。
- 是否明确未验证的真实运行时边界。
