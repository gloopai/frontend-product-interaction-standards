# 选择控件与开关交互规范设计

## 背景

现有规范已经覆盖表单生命周期、Select / Combobox、数据表格选择、按钮、风险操作和管理台治理，但 Checkbox、Radio、Switch、Toggle、Segmented Control 这类基础选择控件仍缺少独立 owner。它们在设置页、权限配置、筛选区、表单、偏好设置和管理台状态控制中使用频率极高，也最容易被误用：把 switch 当成“一点即保存”的危险启停，把 checkbox group 的草稿直接写入结果，把 radio group 做成一组按钮但缺少单选语义，把 disabled 原因藏在 tooltip，把半选状态和全选混成一个布尔值。

这类问题不是按钮问题，也不完全是表单问题。按钮表达动作，表单管理提交生命周期，风险 owner 负责高风险确认；选择控件 owner 应负责“控件如何表达选项、当前值、草稿/提交、禁用原因、组关系和可访问语义”。

## 目标

- 新增 `references/selection-controls.md`，覆盖 Checkbox、Checkbox Group、Radio Group、Switch、Toggle、Toggle Group、Segmented Control 和三态 checkbox。
- 明确 `selectionControlState`，区分 `draftValue`、`committedValue`、`optionSet`、`controlKind`、`commitMode`、`riskPolicy`、`permissionState`、`feedbackState` 和 `a11yPolicy`。
- 禁止把 hover、focus、active、disabled、indeterminate 或展示状态当作已提交业务值。
- 规定 Switch/Toggle 只能表达可逆、低风险、即时生效或明确提交的布尔/枚举偏好；危险启停、权限变更、外部系统影响和不可逆状态必须进入 `risk-actions.md`。
- 规定 Checkbox Group、Radio Group、Segmented Control 的组语义、选项身份、错误归属、键盘和移动端可达性。
- 与 `forms.md`、`query-filters.md`、`data-tables.md`、`buttons.md`、`risk-actions.md`、`admin-console.md` 明确分流。
- 建立 RED/GREEN 摘要和静态审计，确保常见误用可被抓住。

## 非目标

- 不重新定义 Select / Combobox / Autocomplete；选项很多、需要搜索、需要异步检索或自绘 listbox 的场景继续由 `selects-comboboxes.md` 负责。
- 不重新定义表格行选择、表头全选、全部筛选结果选择和批量操作快照；这些继续由 `data-tables.md` 负责。
- 不重新定义表单提交、dirty/touched、错误摘要或未保存离开；这些继续由 `forms.md` 负责。
- 不重新定义危险确认、输入确认、撤销、未知结果和审计回执；这些继续由 `risk-actions.md` 负责。
- 不规定具体 UI 组件库、CSS token 或图标样式。

## 推荐方案

采用独立 `selection-controls.md` owner，聚焦“选择控件的语义、状态、提交边界和可访问性”。

### 方案对比

| 方案 | 优点 | 缺点 | 结论 |
| --- | --- | --- | --- |
| 独立 Selection Controls owner | 能统一 checkbox/radio/switch/toggle/segmented 的语义和误用边界；与风险、表格、表单分工清楚。 | 需要新增文件、路由、摘要和审计。 | 推荐。 |
| 放进 `forms.md` | 表单场景直接。 | 很多 switch/toggle 在设置页、筛选区、权限页和工具栏，不一定是表单提交；会让 forms 继续膨胀。 | 不采用。 |
| 放进 `buttons.md` | Toggle 看起来像按钮。 | 按钮是动作，选择控件是状态；混在一起会模糊提交边界和 ARIA。 | 不采用。 |

## 首版范围

首版覆盖：

- 单个 Checkbox、Checkbox Group、三态 Checkbox、Radio Group、Switch、Toggle、Toggle Group、Segmented Control。
- 表单字段、设置项、偏好配置、筛选条件、权限配置、展示密度/模式切换和低风险即时设置。
- 组 label、选项 label、帮助文本、禁用原因、错误归属、只读展示、必填校验和可访问名称。
- 草稿/提交分离、即时提交、显式保存、撤销/恢复、异步失败和权限变化。
- PC、移动端、触摸、键盘、低高度、200% 缩放、长文本、国际化和辅助技术。

暂不覆盖：

- 数据表格行选择、表头全选、批量范围和跨页选择。
- 大选项集搜索、远程选项检索、虚拟化选项列表。
- 复杂权限矩阵、树形权限编辑器和 spreadsheet-like 编辑矩阵。

## 核心设计

### 1. 状态模型

每个选择控件或控件组维护 `selectionControlState`：

| 字段 | 语义 |
| --- | --- |
| `controlOwnerId` | 当前控件或控件组稳定身份。 |
| `controlKind` | `checkbox`、`checkbox-group`、`radio-group`、`switch`、`toggle`、`toggle-group`、`segmented-control`、`tri-state-checkbox`。 |
| `optionSet` | 稳定选项集合、值、标签、禁用原因、权限和排序。 |
| `draftValue` | 当前控件内尚未提交的选择草稿。 |
| `committedValue` | 已提交到表单、筛选、设置或服务端的业务值。 |
| `commitMode` | `form-submit`、`explicit-save`、`immediate-safe`、`preview-only`。 |
| `indeterminateState` | 三态 checkbox 的部分选择来源、范围和刷新策略。 |
| `permissionState` | 当前用户、租户/工作区、对象状态和选项级权限。 |
| `riskPolicy` | 低风险、需确认、危险、不可逆或外部系统影响。 |
| `feedbackState` | loading、saving、saved、error、permission-denied、stale、read-only。 |
| `a11yPolicy` | label、group name、role、checked/pressed/selected、disabled、describedby、键盘和公告。 |
| `responsivePolicy` | 移动端换行、分组、触摸目标、底部操作和横向溢出策略。 |

`draftValue` 与 `committedValue` 必须分离。Hover、focus、active、pressed visual、disabled、indeterminate 和 optimistic preview 不得伪装成已提交业务值。只有符合 `commitMode` 的明确动作才能写入 `committedValue`。

### 2. 控件选择规则

Checkbox 用于独立布尔选择或多选组选项；Radio Group 用于少量互斥选项；Segmented Control 用于少量互斥且需要高频切换的视图/模式；Switch/Toggle 用于可逆、低风险且文案能明确表达开/关后果的设置。

选项超过少量、需要搜索、需要远程加载、标签很长、存在分组层级或需要解释性描述时，应优先使用 Select、Radio Card、Dialog/Drawer 或独立页，不得硬塞进横向 segmented 或一长串 switch。

不得用 Switch/Toggle 承载危险启停、权限变更、敏感导出、任务取消/重跑、密钥状态、计费影响、外部系统同步或不可逆状态；这些必须进入 `risk-actions.md`。若产品坚持使用视觉开关作为入口，点击开关也只能打开确认承载面，确认完成前请求数为 0，且开关状态不得提前翻转为成功。

### 3. 提交模式

`form-submit`：选择写入表单草稿，由表单提交统一保存。失败时由 `forms.md` 管理错误摘要、字段错误和 dirty 状态。

`explicit-save`：设置页或配置块里可以先编辑多个选择，再点击保存。保存前页面展示 `draftValue` 与未保存状态；离开页面触发未保存确认。

`immediate-safe`：仅适用于低风险、可逆、结果可恢复、失败可回滚且不会影响他人、权限、任务、导出、计费或外部系统的设置。点击后必须进入 saving，并以请求身份防重复；失败恢复到旧 `committedValue` 或显示冲突，不得静默成功。

`preview-only`：用于图表视图、密度、主题、展示模式等本地预览。它不得写服务端，不得写风险状态；若需要持久化，必须转为 `explicit-save` 或 `immediate-safe`。

### 4. 组语义和校验

Radio Group、Checkbox Group、Toggle Group 和 Segmented Control 必须有组 label 或等价可访问名称；每个选项必须有稳定值、可见标签、可访问名称和禁用原因。必选、至少 N 项、最多 N 项、互斥组合、依赖关系和冲突必须进入字段错误或组错误，不得只禁用提交按钮。

三态 checkbox 的 `indeterminateState` 只能表达“当前范围内部分选择”或“子项状态混合”，不能作为可提交业务值。用户激活三态 checkbox 后必须明确转换为选中或未选中，并说明作用范围；不得把 indeterminate 提交给后端。

禁用选项必须保留可发现原因。无权限选项可以隐藏或显示为禁用，但不得泄露敏感对象名称、数量、内部 ID 或旧状态。只读状态应使用只读展示文本或只读选择摘要，不得只用 disabled 控件假装信息展示。

### 5. 键盘和可访问性

原生可用时优先使用原生 checkbox、radio 和 button 语义。自绘控件必须保持等价 role、状态和键盘行为：Checkbox 支持 Space 切换；Radio Group 支持方向键移动选择、Tab 进出组；Switch 使用明确 label 和 checked 状态；Toggle Button 使用 pressed 状态；Segmented Control 使用 radio group 或等价 tab/toolbar 模式，但必须声明语义。

颜色、位置、图标、滑块方向、hover tooltip 或动画不能是唯一状态来源。状态变化、保存中、保存成功、失败、回滚、权限拒绝和冲突必须可被辅助技术理解。

### 6. 响应式和移动端

移动端不得删除选项、禁用原因、错误说明、保存/取消、恢复路径或当前已选摘要。横向 segmented 在窄屏中必须换行、滚动有边界提示或转换为 Radio Group/Select/Drawer；不得让页面根横向溢出。

触摸目标和间距必须适合手指；label 点击区域应触发对应控件。虚拟键盘、低高度、200% 缩放、长文本和国际化扩展下，组 label、选项 label、错误、保存/取消和禁用原因必须可达。

## 与现有 owner 的关系

- `forms.md`：字段状态、dirty/touched、提交、错误摘要和未保存离开由 Form owner 管理；本 owner 定义控件语义和选择值边界。
- `query-filters.md`：筛选条件区只接收已提交的控件业务值；控件草稿不得直接改变 `appliedFilters`。
- `data-tables.md`：表格行选择、表头全选、全部筛选结果选择、排除项和批量范围继续由 Data Table owner 管理。
- `selects-comboboxes.md`：需要搜索、远程选项、大选项集、复杂 listbox 或 Drawer 选项承载时使用 Select owner。
- `buttons.md`：保存、取消、应用、清空、重置和打开高级配置是按钮动作；Toggle Button 的选择状态由本 owner 管理。
- `risk-actions.md`：危险启停、权限变更、敏感导出、任务取消/重跑、密钥、外部系统影响和不可逆状态必须进入 Risk owner。
- `admin-console.md`：权限、租户/工作区、审计、安全降级和设置页治理复用管理台 owner。
- `responsive-adaptive.md`：移动端承载、触摸、断点、虚拟键盘和安全区域复用响应式 owner。

## 新 owner 草案结构

计划新增 `references/selection-controls.md`：

1. 范围与边界
2. `selectionControlState`
3. 控件选择规则
4. 提交模式
5. Checkbox 与三态
6. Radio、Toggle Group 和 Segmented
7. Switch / Toggle 风险边界
8. 禁用、只读、权限和错误
9. 键盘、焦点和可访问性
10. 响应式和移动端
11. 完成前检查

稳定规则族建议：

- `SC-SCOPE`：范围和 owner 分流。
- `SC-STATE`：状态模型、草稿/提交分离。
- `SC-KIND`：控件选择规则。
- `SC-COMMIT`：提交模式和请求边界。
- `SC-RISK`：Switch/Toggle 风险转交。
- `SC-GROUP`：组语义、校验和三态。
- `SC-PERM`：权限、禁用、只读和无泄露。
- `SC-A11Y`：键盘、role、状态和公告。
- `SC-RSP`：移动端、触摸和响应式。
- `SC-LIFE`：异步、失败、回滚和 disposal。

## 验收策略

- 新增 owner 文档、SKILL 路由、README/HANDOFF 摘要。
- 新增 GREEN/RED 摘要，覆盖安全示例和反例。
- 新增 `docs/testing/selection-controls/selection-controls-audit.rb`，检查 owner、路由、摘要和证据。
- 运行维护中的 owner 审计、Markdown 链接检查和 `git diff --check`。
- 真实浏览器、触摸、键盘、屏幕阅读器、权限切换、异步保存和移动端视口验证在本轮文档工作中标为未验证，后续业务项目实现时必须补充。
