# 树形结构与级联交互规范

适用于 Tree、Tree View、Tree Select、Tree Grid、Cascader、级联选择、树形选择、组织树、部门树、权限树、菜单树、分类树、资源目录树和地区级联。本文件是层级数据展示、展开、选择、级联、半选、过滤、懒加载、权限安全、可访问性和验收的唯一事实来源。

基础 Checkbox、Radio、Switch、Toggle 和 Segmented Control 继续执行 [选择控件与开关交互规范](selection-controls.md)。普通 Select / Combobox、异步选项搜索和自绘 listbox 继续执行 [可搜索单选 Select / Combobox 交互规范](selects-comboboxes.md)。表格树列、表格行选择、表头全选、跨页选择和批量范围继续执行 [数据表格交互规范](data-tables.md)。字段提交、错误摘要和未保存离开继续执行 [表单状态、校验与错误交互规范](forms.md)。危险权限变更、删除、发布、启停和不可逆操作必须进入 [危险操作与恢复交互规范](risk-actions.md)。

树形选择、级联选择、父子字段和层级条件作为上游或下游字段参与字段联动时，必须同时执行 `references/conditional-fields-dependent-inputs.md`。树形 owner 负责节点身份、展开、选择、半选和懒加载；条件字段 owner 负责 `fieldDependencyState`、upstreamSnapshot、downstreamPolicy、candidatePolicy 和隐藏/失效后的提交策略。

树形资源选择、组织成员选择、部门成员选择、项目/工作区层级选择、父级对象选择、关联资源选择和 Tree Select / Cascader 承载业务对象绑定时，必须同时执行 `references/entity-resource-pickers.md`，并声明 `entityResourcePickerState`。树形 owner 负责节点展开、层级、半选、懒加载和路径；对象资源 owner 负责候选实体身份、scope、可绑定性、权限无泄露、最近/推荐和提交边界。

普通内容折叠、设置分组折叠和错误详情折叠执行 `references/disclosure-accordions.md`；不得用 Accordion 伪装可选择 Tree、Tree Select、Cascader、懒加载树节点或半选层级关系。

## 范围与边界

本 owner 覆盖：

- Tree、Tree View、Tree Select、Tree Grid、Cascader、级联选择、树形选择、多级分类、地区级联、组织树、部门树、权限树、菜单树、资源目录树和目录导航。
- 节点展开/收起、active、hover、焦点、搜索过滤、高亮匹配、路径摘要、面包屑、当前层级返回和移动端分层承载。
- 单选、多选、父子级联、只选叶子、父节点可选、半选、全选当前范围、全选全部后代、禁用节点、无权限节点和已删除/失效节点。
- 懒加载、局部加载、远程过滤、局部错误、权限版本、路径版本、旧缓存清理、请求取消和异步回调归属。
- 键盘、屏幕阅读器语义、虚拟化、缩放、低高度、触摸、虚拟键盘、安全区域和窄屏能力保留。

本 owner 不覆盖：

- 普通列表、普通 Select、Radio Group、Checkbox Group、Segmented Control 或单层筛选。
- 表格自己的列配置、行选择、固定列、分页、跨页批量和表头全选。
- 危险操作确认、审计回执、未知结果、撤销窗口和后台任务生命周期。
- 具体组件库 API 的命名差异；组件库默认行为不能降低本 owner 的状态、权限和验收要求。

## `treeHierarchyState`

每个树形结构、级联入口或树形选择器必须维护 `treeHierarchyState`：

| 字段 | 语义 |
| --- | --- |
| `treeOwnerId` | 当前树或级联控件的稳定实例身份。 |
| `nodeIdentity` | 节点稳定业务 ID、节点类型、父子关系、路径版本、权限版本和失效策略。 |
| `treeDataSnapshot` | 当前可用于展示/选择/提交的树数据快照、加载代次、过滤代次和权限范围。 |
| `expandedNodeIds` | 已展开节点集合；只表达视图状态，不表达业务选择。 |
| `activeNodeId` | 当前键盘或浏览焦点所在节点；不得触发提交。 |
| `selectedNodeIds` | 单选或非级联选择草稿/已提交节点集合，必须声明提交边界。 |
| `checkedNodeState` | 多选、父子级联、半选、禁用后代、未加载后代和派生状态。 |
| `cascadePolicy` | `none`、`leaf-only`、`parent-selectable`、`loaded-descendants`、`all-descendants`、`visible-only` 等级联策略。 |
| `filterState` | 本地/远程过滤、查询草稿、匹配高亮、可见范围、结果为空和错误。 |
| `loadState` | unloaded、loading、loaded、partial、stale、error、permission-denied 和 retry。 |
| `permissionBoundary` | 当前用户、租户/工作区、对象权限、节点权限、禁用原因和无泄露策略。 |
| `commitMode` | `form-submit`、`explicit-apply`、`immediate-safe`、`preview-only`。 |
| `feedbackState` | loading、saving、saved、error、partial、conflict、stale、read-only、permission-denied。 |
| `a11yPolicy` | role、aria-level、aria-expanded、aria-selected、aria-checked、键盘模型、公告和焦点恢复。 |
| `responsivePolicy` | 移动端 Drawer/独立页/分层选择、路径摘要、底部操作、触摸目标和安全区域策略。 |

展开、active、hover、filter match、visible descendants、indeterminate、partial loaded 和 optimistic preview 不得伪装成已提交选择。只有符合 `commitMode` 的明确提交动作才能写入业务值、URL、请求参数、权限变更或审计结果。

## 节点身份、路径和快照

节点必须有稳定业务 ID、节点类型、父子关系、路径版本和权限版本。不得使用展示名称、排序位置、数组下标、过滤后位置、懒加载返回顺序、DOM key、面包屑文本或图标作为业务身份。

同一节点在不同父级、租户、工作区、语言、权限版本或路径版本下含义可能不同；提交、批量、导出、权限变更和审计必须绑定 `treeDataSnapshot`、`nodeIdentity`、`permissionBoundary` 和提交代次。节点移动、删除、重命名、权限变化或路径过期后，旧选择、旧半选、旧面包屑、旧错误和旧缓存必须重新校验。

过滤、搜索、折叠、虚拟化和懒加载只能改变“当前可见树”；不能改变节点业务身份。高亮匹配、hover、active 和展开状态不等于选择状态。

## 展开、选择和提交

展开/收起是视图导航行为，不得写入业务结果；选择、勾选和应用是业务意图，必须有清晰文案、范围摘要和提交边界。单击节点默认做浏览、展开或选择时必须一致且可预测；同一区域不能让文本点击、箭头点击、checkbox 点击和行点击互相抢占。

`form-submit` 由表单 owner 统一提交；树控件只能写入表单草稿。`explicit-apply` 必须保留应用、取消、清空、恢复路径和已选摘要。`immediate-safe` 仅适用于低风险、可逆、失败可回滚且不会影响他人、权限、计费、导出、任务或外部系统的选择。`preview-only` 只能改变本地展示，不得写服务端、URL、风险状态或审计。

用于查询条件时，过滤树的查询草稿、展开节点、当前 active 节点和匹配高亮不得直接刷新结果；只有应用后的筛选快照才能进入请求、URL 或已应用摘要。

## 级联、半选和全选范围

必须声明 `cascadePolicy`。父节点勾选究竟代表自身、已加载后代、全部后代、当前可见后代、仅叶子、排除禁用项或包含禁用项，必须在文案、摘要、提交值和验收中一致。

半选只表达派生状态，不是业务提交值。`indeterminate` / half-checked / partial selected 不能提交给后端；用户激活半选父节点后，必须明确转换为选中或未选中，并说明影响范围。

懒加载未完成、过滤后仅展示部分节点、权限未知或存在 disabled 后代时，不能把“全选当前可见”伪装成“全选全部后代”。如果需要全选全部后代，必须由后端或可信数据源确认目标集合、目标数量、排除项、权限版本和不可选择原因；确认前只能标为预览、部分选择或当前可见范围。

禁用节点、只读节点和无权限节点必须保留可发现原因。禁用父节点与可选子节点、可选父节点与禁用子节点、部分加载父节点和权限混合父节点都必须给出明确规则；不能只靠灰色、缩进、tooltip 或半选图标解释。

## 过滤、搜索和懒加载

过滤必须声明本地过滤还是远程过滤。过滤输入草稿与已应用过滤条件必须分离；匹配高亮和命中展开只是视图状态，不得改变已选值、提交值或后端范围。

懒加载失败不能等同于“没有子节点”；权限拒绝不能等同于“空目录”；超时不能等同于“已完整加载”。`loadState` 必须区分 unloaded、loading、loaded、partial、stale、error 和 permission-denied，并提供 retry、恢复、路径回退或错误说明。

虚拟化树必须保证键盘顺序、焦点恢复、aria 层级和屏幕阅读器状态不被窗口裁切破坏。过滤、加载、折叠或虚拟窗口改变后，active 节点不存在时必须恢复到可解释目标，不能丢焦点到页面根。

## 权限、安全和无泄露

无权限节点不得泄露节点名称、数量、路径、父子关系、图标、类型、内部 ID、排序位置、子节点是否存在或旧缓存。权限不足可以隐藏、展示泛化占位或展示可达的权限说明，但不得通过搜索结果数量、展开错误、禁用 tooltip、ARIA label、DOM 属性、日志或缓存摘要泄露敏感结构。

权限降低、租户/工作区切换、角色变化、对象状态变化、节点删除或目录迁移后，必须失效旧 `treeDataSnapshot`、旧 `selectedNodeIds`、旧 `checkedNodeState`、旧路径摘要、旧错误和旧懒加载缓存。异步回调必须匹配 `treeOwnerId`、租户/工作区、权限版本、路径版本和加载代次；失配只能丢弃，不能写入新实例。

危险权限变更、菜单发布、组织调整、分类删除、批量迁移、继承策略修改和外部系统同步必须转交 `risk-actions.md`；确认完成前不得提前改变树上业务状态。

## 可访问性和键盘

树视图必须使用可理解的 Tree / Treeitem / Group 语义；树表格使用 Tree Grid 语义。自绘实现必须暴露层级、展开状态、选中状态、勾选状态、禁用原因和错误说明。`aria-level`、`aria-posinset`、`aria-setsize`、`aria-expanded`、`aria-selected` 和 `aria-checked` 必须与当前可见结构一致。

键盘至少支持 Tab/Shift+Tab 进出组件、方向键移动、左右键展开/收起或进入/返回层级、Home/End、Space 勾选、Enter 激活、Escape 关闭临时承载面或清除局部模式。焦点环必须可见，不能被缩进线、滚动容器、固定底栏、虚拟化窗口或 overflow 裁切。

颜色、缩进、图标、连接线、hover、tooltip、轻微阴影或动画不能是唯一语义来源。加载、错误、权限拒绝、过滤无结果、部分加载、选择变化和应用成功/失败都必须有可见文本或可访问公告。

## 响应式和移动端

移动端可以把复杂树形 Dialog 转换为 Bottom Sheet、移动端 Drawer、全屏 Drawer 或独立页；Tree Select 和 Cascader 可以转换为从底部弹出的选择 Drawer、分层选择页或步骤式选择。承载面可以保留与外框右边距一致的视觉边距、圆角和安全区域，但必须执行完整焦点、遮罩、滚动、返回和底部操作规则。

移动端不得删除搜索、展开、返回上级、路径摘要、已选摘要、清空、应用、错误说明、权限说明或恢复路径。低频能力可以折叠进更多操作，但必须可发现、可触达、可键盘/屏幕阅读器访问，并保持与 PC 相同的业务结果。

触摸目标、缩进、层级线、checkbox、展开箭头和行高必须适合手指。长节点名、国际化文本、200% 缩放、低高度、横竖屏、虚拟键盘和安全区域下，当前路径、已选摘要、主要操作、取消路径和错误说明必须可达；页面根不得出现无意横向溢出。

## 生命周期和清理

每个树实例必须登记请求、懒加载、过滤防抖、虚拟化测量、滚动定位、焦点恢复、状态公告、缓存订阅和提交任务。关闭 Dialog/Drawer、路由变化、owner 卸载、权限变化、租户/工作区切换或节点集合替换时，进入 disposal：取消或失效请求、防抖、回调、测量、公告和焦点任务；清理 ARIA 引用、popup DOM 和旧缓存；不得影响其他存活树实例。

打开承载面时必须能恢复来源焦点；关闭后只能恢复到仍存在且仍有权限的来源目标。来源目标已移除、无权限或不可见时，恢复到明确后备目标，并提供可访问说明。

## 完成前检查

- 验证每个 Tree、Tree View、Tree Select、Tree Grid、Cascader 和级联选择声明 `treeHierarchyState`、`treeOwnerId`、`nodeIdentity`、`treeDataSnapshot`、`checkedNodeState`、`cascadePolicy`、`permissionBoundary`、`commitMode`、`a11yPolicy` 和 `responsivePolicy`。
- 验证展开、active、hover、filter match、visible descendants、indeterminate、partial loaded 和 optimistic preview 不得伪装成已提交选择。
- 验证节点必须有稳定业务 ID、节点类型、父子关系、路径版本和权限版本；不得使用展示名称、排序位置、过滤位置、懒加载顺序或 DOM key 作为业务身份。
- 验证半选只表达派生状态，不是业务提交值；`indeterminate` / half-checked / partial selected 不能提交给后端。
- 验证懒加载未完成、过滤后仅展示部分节点、权限未知或存在 disabled 后代时，不能把“全选当前可见”伪装成“全选全部后代”。
- 验证无权限节点不得泄露节点名称、数量、路径、父子关系、图标、类型、内部 ID、排序位置、子节点是否存在或旧缓存。
- 验证移动端不得删除搜索、展开、返回上级、路径摘要、已选摘要、清空、应用、错误说明、权限说明或恢复路径。
- 验证懒加载失败、权限拒绝、过滤无结果、部分加载、stale、冲突和未知结果都有明确文本、可访问公告和恢复路径。
- 验证 Tree / Treeitem / Group / Tree Grid 语义、键盘、焦点环、aria 层级、aria 选中/勾选、错误说明和状态公告。
- 验证路由变化、owner 卸载、权限变化、租户/工作区切换和节点集合替换后的 disposal：旧请求、防抖、缓存、公告、测量和焦点任务全部取消或失效。
- 真实浏览器、触摸、键盘、屏幕阅读器、权限切换、懒加载、过滤、虚拟化和移动端视口未实际执行时，必须明确标为未验证，并列出所需验证。

## 参考资料

- [WAI-ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [WAI-ARIA Tree View Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/treeview/)
- [WAI-ARIA Treegrid Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/treegrid/)
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [WCAG: Keyboard](https://www.w3.org/WAI/WCAG22/Understanding/keyboard.html)
- [WCAG: Focus Appearance](https://www.w3.org/WAI/WCAG22/Understanding/focus-appearance.html)
- [WCAG: Status Messages](https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html)
