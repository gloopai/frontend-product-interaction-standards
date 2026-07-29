# 选择控件与开关交互规范

适用于 Checkbox、Checkbox Group、Radio Group、Switch、Toggle、Toggle Group、Segmented Control、三态 checkbox、复选、多选、单选、开关、切换和分段选择控件。本文件是选择控件语义、状态、提交边界、风险转交、权限、安全、可访问性和验收的唯一事实来源。

表格行选择、表头全选、全部筛选结果选择和批量范围继续执行 [数据表格交互规范](data-tables.md)。字段提交、dirty/touched、错误摘要和未保存离开继续执行 [表单状态、校验与错误交互规范](forms.md)。选项很多、需要搜索、需要异步检索或自绘 listbox 的选择入口继续执行 [可搜索单选 Select / Combobox 交互规范](selects-comboboxes.md)。危险启停、权限变更、敏感导出、任务取消/重跑、密钥、外部系统影响和不可逆状态必须进入 [危险操作与恢复交互规范](risk-actions.md)。

## 范围与边界

本 owner 覆盖：

- 单个 checkbox、checkbox group、radio group、switch、toggle、toggle group、segmented control 和 tri-state checkbox。
- 表单字段、设置项、偏好开关、筛选条件、权限配置、展示模式、密度切换和低风险即时设置。
- 控件 label、组 label、选项 label、禁用原因、帮助文本、字段错误、组错误、只读展示、必填和可访问名称。
- 草稿/提交分离、即时提交、显式保存、本地预览、异步保存、失败回滚、权限变化和移动端承载。

本 owner 不覆盖：

- 数据表格行选择、表头全选、全部筛选结果、排除项、批量操作和跨页选择。
- Select / Combobox / Autocomplete、搜索选项、虚拟化 listbox、树形选择、级联选择和复杂权限矩阵。
- 按钮动作本身、危险确认流程、撤销窗口、未知结果、审计回执和服务端任务生命周期。

## `selectionControlState`

每个选择控件或控件组必须维护 `selectionControlState`：

| 字段 | 语义 |
| --- | --- |
| `controlOwnerId` | 当前控件或控件组稳定身份。 |
| `controlKind` | `checkbox`、`checkbox-group`、`radio-group`、`switch`、`toggle`、`toggle-group`、`segmented-control`、`tri-state-checkbox`。 |
| `optionSet` | 稳定选项集合、值、标签、禁用原因、权限、排序和展示说明。 |
| `draftValue` | 当前控件内尚未提交的选择草稿。 |
| `committedValue` | 已提交到表单、筛选、设置、本地偏好或服务端的业务值。 |
| `commitMode` | `form-submit`、`explicit-save`、`immediate-safe`、`preview-only`。 |
| `indeterminateState` | 三态 checkbox 的部分选择来源、范围、代次和刷新策略。 |
| `permissionState` | 当前用户、租户/工作区、对象状态、选项级权限和禁用原因。 |
| `riskPolicy` | 低风险、需确认、危险、不可逆、计费影响或外部系统影响。 |
| `feedbackState` | loading、saving、saved、error、permission-denied、stale、conflict、read-only。 |
| `a11yPolicy` | label、group name、role、checked/pressed/selected、disabled、describedby、键盘和公告。 |
| `responsivePolicy` | 移动端换行、分组、触摸目标、底部操作、横向溢出和安全区域策略。 |

`draftValue` 与 `committedValue` 必须分离。Hover、focus、active、pressed visual、disabled、indeterminate 和 optimistic preview 不得伪装成已提交业务值。只有符合 `commitMode` 的明确动作才能写入 `committedValue`。

## 控件选择规则

Checkbox 用于独立布尔选择或多选组选项；Checkbox Group 用于少量多选；Radio Group 用于少量互斥选项；Segmented Control 用于少量互斥且需要高频切换的视图或模式；Switch/Toggle 用于可逆、低风险且文案能明确表达开/关后果的设置。

选项超过少量、需要搜索、需要远程加载、标签很长、存在分组层级、需要解释性描述或移动端无法完整展示时，应优先使用 Select、Radio Card、Dialog、Drawer 或独立页，不得硬塞进横向 segmented 或一长串 switch。

不得把 Toggle Button 的视觉按下态当普通按钮动作；它表达状态时必须进入本 owner，表达一次性动作时必须进入 `buttons.md`。同一控件不能同时表达“已选择状态”和“立即执行动作”，除非明确拆成选择控件与动作按钮两个 owner。

## 提交模式

`form-submit`：控件写入表单草稿，由表单提交统一保存。失败时由 `forms.md` 管理字段错误、错误摘要、dirty/touched 和未保存离开。

`explicit-save`：设置页或配置块允许先编辑多个控件，再点击保存。保存前必须展示 `draftValue`、未保存状态、保存/取消路径和离开保护；结果、权限、导出或批量范围不得读取未提交草稿。

`immediate-safe`：仅适用于低风险、可逆、失败可回滚、结果可恢复且不会影响他人、权限、任务、导出、计费、审计、密钥或外部系统的设置。点击后进入 saving，并绑定请求身份防重复；失败恢复到旧 `committedValue` 或显示冲突，不得静默成功。

`preview-only`：仅用于主题、密度、图表视图、展示模式或本地预览。它不得写服务端、不得写风险状态、不得进入审计结果；若需要持久化，必须转为 `explicit-save` 或 `immediate-safe`。

## Switch / Toggle 风险边界

Switch/Toggle 只能表达可逆、低风险且文案能明确表达开/关后果的设置。

危险启停、权限变更、敏感导出、任务取消/重跑、密钥、外部系统影响和不可逆状态必须进入 `risk-actions.md`。确认完成前请求数为 0，且开关状态不得提前翻转为成功。

若产品坚持使用视觉开关作为危险操作入口，点击开关也只能打开 Dialog、Drawer 或独立页确认承载面；确认取消后保留旧 `committedValue`；确认失败后显示错误并恢复旧值；未知结果不得伪装成开关已成功切换。

## Checkbox、Radio、Toggle Group 和 Segmented

Radio Group、Checkbox Group、Toggle Group 和 Segmented Control 必须有组 label 或等价可访问名称。每个选项必须有稳定值、可见标签、可访问名称、禁用原因、权限状态和错误归属。

必选、至少 N 项、最多 N 项、互斥组合、依赖关系、冲突和失效选项必须进入字段错误或组错误，不得只禁用提交按钮，不得只用 Toast 或 tooltip 解释。

三态 checkbox 的 `indeterminateState` 不能作为可提交业务值。它只能表达“当前范围内部分选择”或“子项状态混合”；用户激活后必须明确转换为选中或未选中，并说明作用范围。不得把 indeterminate、mixed、partial 或半选状态提交给后端。

Segmented Control 只适合少量互斥选项。选项过多、标签过长、需要解释、需要权限原因或移动端空间不足时，应转换为 Radio Group、Select、Drawer 或独立页。横向滚动 segmented 必须有边界提示和键盘路径，不得让页面根横向溢出。

## 禁用、只读、权限和错误

禁用选项必须保留可发现原因。禁用原因不能只靠灰色、透明度、hover tooltip、禁用指针或不可聚焦状态表达；必须有可见文本、关联描述、错误/权限说明或可达详情。

无权限选项可以隐藏或显示为禁用，但不得泄露敏感对象名称、数量、内部 ID、旧状态、权限范围或跨租户数据。权限降低、租户/工作区切换、对象状态变化或配置过期后，旧 `draftValue`、旧 `committedValue`、旧选项 label 和旧错误必须重新校验。

只读状态应使用只读展示文本、只读选择摘要或信息展示 owner；不得只用 disabled checkbox、disabled radio 或 disabled switch 假装信息展示。只读摘要必须表达当前值、来源、权限和无法编辑原因。

错误必须归属到具体控件或控件组。异步保存失败、权限冲突、版本冲突、网络失败、未知结果和回滚都必须以文本说明，并保留恢复路径；不能只靠 Toast、颜色或按钮 disabled。

## 键盘、焦点和可访问性

原生可用时优先使用原生 checkbox、radio 和 button 语义。自绘控件必须保持等价 role、状态和键盘行为：Checkbox 支持 Space 切换；Radio Group 支持方向键移动选择、Tab 进出组；Switch 暴露明确 label 与 checked 状态；Toggle Button 暴露 pressed 状态；Segmented Control 使用 radio group 或等价 tab/toolbar 模式，并声明语义。

焦点环必须可见，不能被滑块、卡片、固定栏或 overflow 裁切。label 点击区域应触发对应控件；组内选项的焦点顺序必须符合视觉和业务顺序。禁用、保存中、回滚、错误、权限拒绝和只读状态必须可被辅助技术理解。

颜色、位置、图标、滑块方向、动画、hover tooltip 或轻微阴影不能是唯一状态来源。状态变化、保存中、保存成功、失败、回滚、权限拒绝和冲突必须有可访问公告或相邻文本反馈。

## 响应式和移动端

移动端不得删除选项、禁用原因、错误说明、保存/取消、恢复路径或当前已选摘要。低频选项可以折叠或放入 Drawer，但必须可发现、可访问并保留当前值和错误归属。

触摸目标和间距必须适合手指；长 label、国际化文本、200% 缩放、低高度、虚拟键盘和安全区域下，组 label、选项 label、错误、保存/取消、禁用原因和当前已选摘要必须可达。

横向 segmented 或 toggle group 在窄屏下必须换行、提供受控横向滚动与边界提示，或转换为 Radio Group、Select、Drawer、Bottom Sheet 或独立页。不得让页面根横向溢出，不得要求精确拖拽才能选择。

## 生命周期、异步和清理

每个控件实例必须登记请求、保存、防抖、回滚、权限复核、焦点恢复、状态公告和错误恢复任务。异步回调必须匹配 `controlOwnerId`、权限版本、租户/工作区、当前 `committedValue` 或提交代次；失配只丢弃，不得写入新实例。

关闭 Dialog/Drawer、路由变化、拥有组件卸载、权限变化或选项集合替换时，当前控件进入 disposal：取消或失效请求、防抖、回滚、公告和焦点任务；清理 ARIA 引用；不得恢复到将被移除的旧焦点；不得清理其他存活控件实例的状态。

## 完成前检查

- 验证每个控件声明 `controlKind`、`commitMode`、`optionSet`、`permissionState`、`riskPolicy`、`feedbackState`、`a11yPolicy` 和 `responsivePolicy`。
- 验证 `draftValue` 与 `committedValue` 必须分离；hover、focus、active、pressed visual、disabled、indeterminate 和 optimistic preview 不得伪装成已提交业务值。
- 验证 Checkbox、Checkbox Group、Radio Group、Switch、Toggle、Toggle Group、Segmented Control 和三态 checkbox 的选用理由；选项过多、需要搜索或移动端空间不足时转交 Select、Drawer 或独立页。
- 验证 `form-submit`、`explicit-save`、`immediate-safe` 和 `preview-only` 的提交边界、请求数、防重复、失败回滚和未保存离开。
- 验证危险启停、权限变更、敏感导出、任务取消/重跑、密钥、外部系统影响和不可逆状态必须进入 `risk-actions.md`；确认完成前请求数为 0，且开关状态不得提前翻转为成功。
- 验证三态 checkbox 的 `indeterminateState` 不能作为可提交业务值；用户激活后明确转换为选中或未选中，并说明作用范围。
- 验证 Radio Group、Checkbox Group、Toggle Group 和 Segmented Control 必须有组 label 或等价可访问名称；选项有稳定值、可见标签、可访问名称、禁用原因和错误归属。
- 验证禁用选项必须保留可发现原因；禁用原因不只靠灰色、透明度、hover tooltip、禁用指针或不可聚焦状态表达。
- 验证权限降低、租户/工作区切换、对象状态变化或配置过期后，旧值、旧 label、旧错误和旧权限状态被重新校验且不泄露敏感信息。
- 验证键盘 Space、方向键、Tab/Shift+Tab、焦点环、label 点击、状态公告、保存中、失败、回滚、权限拒绝和只读说明。
- 验证移动端不得删除选项、禁用原因、错误说明、保存/取消、恢复路径或当前已选摘要；横向 segmented 不造成页面根横向溢出。
- 验证路由变化、拥有组件卸载、权限变化和选项集合替换后的 disposal：旧请求、防抖、回滚、公告和焦点任务全部取消或失效，旧回调不能改变新实例。
- 真实浏览器、触摸、键盘、屏幕阅读器、权限切换、异步保存和移动端视口未实际执行时，必须明确标为未验证，并列出所需验证。

## 参考资料

- [WAI-ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [WAI-ARIA Checkbox Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/checkbox/)
- [WAI-ARIA Radio Group Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/radio/)
- [WAI-ARIA Switch Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/switch/)
- [WAI-ARIA Button Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/button/)
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [WCAG: Keyboard](https://www.w3.org/WAI/WCAG22/Understanding/keyboard.html)
- [WCAG: Focus Appearance](https://www.w3.org/WAI/WCAG22/Understanding/focus-appearance.html)
- [WCAG: Status Messages](https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html)
