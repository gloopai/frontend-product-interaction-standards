# 树形结构与级联交互规范设计

## 背景

现有 `forms.md` 明确不定义树/级联等复合字段；`selection-controls.md` 覆盖 Checkbox、Radio、Switch、Segmented 等基础选择控件，但排除了树形选择、级联选择和复杂权限矩阵；`data-tables.md` 负责表格和表格行选择，不负责通用组织树、分类树、菜单树或权限树。管理台里树形结构使用频率很高：组织架构、部门、角色权限、菜单、分类、地区、资源目录和级联选择都离不开它。

这类交互最容易出事故：节点 ID 不稳定、懒加载后旧选择失效、半选被提交、搜索过滤后误以为全选全部节点、父子级联范围不清、禁用节点被级联改变、无权限子节点被数量或路径泄露、拖拽重排和权限变更没有审计。它需要独立 owner 来定义层级身份、展开、选择、级联、过滤、权限、异步加载和移动端承载。

## 目标

- 新增 `references/tree-hierarchy.md`，覆盖 Tree、Tree Select、Cascader、Tree View、Tree Grid、组织树、权限树、菜单树、分类树和级联选择。
- 明确 `treeHierarchyState`，区分节点身份、路径、展开状态、加载状态、过滤状态、选择状态、级联策略、半选状态、权限边界和异步请求。
- 禁止把展开、active、hover、filter match、visible descendants、indeterminate 或部分加载状态当作已提交选择。
- 规定父子级联、半选、全选当前可见、全选全部后代、懒加载节点和禁用节点的边界。
- 防止无权限节点通过路径、数量、子节点存在、半选、搜索结果或懒加载错误泄露。
- 明确移动端承载：树过深、节点多、需搜索或需复核时应转 Drawer、独立页或分步选择，不得压成不可触达的小树。
- 建立 RED/GREEN 摘要和静态审计，确保常见树形误用能被抓住。

## 非目标

- 不重新定义普通 Checkbox/Radio/Switch/Segmented；无层级关系的基础选择继续由 `selection-controls.md` 负责。
- 不重新定义 Select / Combobox 的 listbox、搜索和单选提交；简单下拉选择继续由 `selects-comboboxes.md` 负责。
- 不重新定义数据表格树表、行选择、批量范围和跨页选择；这些继续由 `data-tables.md` 负责。
- 不重新定义危险操作确认、权限变更审计、拖拽重排提交和未知结果；这些继续由 `risk-actions.md` 负责。
- 不规定具体树组件库、虚拟化库、后端树接口或搜索算法。

## 推荐方案

采用独立 `tree-hierarchy.md` owner，聚焦“层级数据如何展示、选择、级联和安全提交”。

### 方案对比

| 方案 | 优点 | 缺点 | 结论 |
| --- | --- | --- | --- |
| 独立 Tree/Hierarchy owner | 能统一树节点身份、半选、级联、懒加载、过滤、权限和移动端承载。 | 需要新增路由、摘要和审计。 | 推荐。 |
| 放进 `selection-controls.md` | checkbox tree 看似相近。 | 树的路径、懒加载、级联和权限泄露远超基础控件职责，会把 owner 拖成大泥球。 | 不采用。 |
| 放进 `data-tables.md` | treegrid 与表格有交集。 | 通用 Tree、Cascader、权限树和组织树不是数据表格。 | 不采用。 |

## 首版范围

首版覆盖：

- Tree View、Tree Select、Cascader、组织树、部门树、菜单树、分类树、权限树、资源目录树、地区级联。
- 展开/折叠、active node、current node、selected nodes、checked nodes、half-checked nodes、disabled nodes。
- 懒加载、加载失败、重试、过滤/搜索、虚拟滚动、路径展示、面包屑路径和返回恢复。
- 父子级联选择、仅叶子可选、父节点可选、禁用节点、部分加载节点和权限降级。
- PC、移动端、触摸、键盘、屏幕阅读器、低高度、200% 缩放、长文本和国际化。

暂不覆盖：

- 表格树表的列、排序、分页、行操作和批量操作。
- 权限矩阵的完整单元格编辑模型。
- 拖拽排序的具体算法；若提交排序影响业务或权限，必须进入风险/审计 owner。

## 核心设计

### 1. 状态模型

每个树形结构维护 `treeHierarchyState`：

| 字段 | 语义 |
| --- | --- |
| `treeOwnerId` | 当前树实例稳定身份。 |
| `nodeIdentity` | 节点稳定 ID、类型、路径、父 ID、版本和权限范围。 |
| `treeDataSnapshot` | 当前树数据快照、租户/工作区、权限版本、加载时间和数据范围。 |
| `expandedNodeIds` | 展开节点集合。 |
| `activeNodeId` | 键盘或辅助技术当前指向的已渲染节点。 |
| `selectedNodeIds` | 已提交或待提交的业务选择，取决于 `commitMode`。 |
| `checkedNodeState` | checked、unchecked、indeterminate 的来源和范围。 |
| `cascadePolicy` | 父子级联、仅叶子、父可选、禁用节点、未知后代和过滤范围策略。 |
| `filterState` | 搜索词、匹配节点、保留祖先、隐藏后代、过滤结果版本。 |
| `loadState` | unloaded、loading、loaded、error、partial、stale。 |
| `permissionBoundary` | 节点可见、可展开、可选择、可提交、可拖拽和可查看路径的权限。 |
| `commitMode` | `form-submit`、`explicit-apply`、`immediate-safe`、`preview-only`。 |
| `feedbackState` | loading、empty、zero-results、partial、error、permission-denied、stale。 |
| `a11yPolicy` | tree/treeitem/group、level、posinset、setsize、expanded、selected、checked、键盘和公告。 |
| `responsivePolicy` | 移动端 Drawer、独立页、分步选择、触摸目标和安全区域。 |

展开、active、hover、filter match、visible descendants、indeterminate、partial loaded 和 optimistic preview 不得伪装成已提交选择。只有符合 `commitMode` 的明确动作才能写入业务选择或提交请求。

### 2. 节点身份和路径

节点必须有稳定业务 ID、节点类型、父子关系、路径版本和权限版本。不得用显示名称、数组 index、当前过滤位置、懒加载顺序或 DOM key 作为业务身份。

路径显示必须区分完整路径、截断路径和无权限路径。无权限祖先或子节点不能通过“还有 3 个子节点”“某某部门 / 隐藏节点 / 目标节点”这类路径泄露对象存在。

### 3. 级联、半选和提交

父子级联必须显式声明 `cascadePolicy`：是否选择父节点会选择全部已加载后代、全部可选后代、仅当前可见后代、仅叶子节点，或只选择父节点本身。

半选只表达派生状态，不是业务提交值。`indeterminate` / half-checked / partial selected 不能提交给后端；提交必须转换为明确的节点 ID 集合、范围快照或后端声明的选择表达式。

懒加载未完成、过滤后仅展示部分节点、权限未知或存在 disabled 后代时，不能把“全选当前可见”伪装成“全选全部后代”。若支持全选全部后代，必须冻结不可变 `selectionSnapshot`，包含根节点、查询/过滤、权限版本、可选总数、排除项和时间。

### 4. 过滤、搜索和懒加载

过滤和搜索只改变 `filterState` 与可见节点，不得隐式改变选择。过滤结果必须说明是只搜已加载节点、全量远程搜索、还是按权限裁剪后的搜索。清空过滤后，选择、展开和 active 的恢复策略必须明确。

懒加载节点必须区分 unloaded、loading、loaded、error、partial 和 stale。加载失败不能把节点当作无子节点；partial 不能伪装成完整。重试请求必须绑定 `treeOwnerId`、节点 ID、权限版本和数据快照。

### 5. 权限和安全

每个节点都要区分可见、可展开、可选择、可提交、可拖拽和可查看路径权限。权限降低、租户/工作区切换、角色变化、节点删除或路径变化后，旧展开、旧选择、旧半选、旧过滤结果、旧路径和旧加载错误必须重新校验。

无权限节点不得泄露节点名称、数量、路径、父子关系、图标、类型、内部 ID、排序位置、子节点是否存在或旧缓存。权限树和菜单树尤其不能通过父节点半选或子节点计数泄露隐藏权限项。

### 6. 键盘、可访问性和移动端

树控件必须有可访问名称。Tree View 使用 tree/treeitem/group 语义；Tree Grid 使用 grid/treegrid 语义并执行对应表格 owner；Cascader 必须声明每一级的名称、当前路径和选择状态。

键盘至少支持 Tab 进入/离开树，方向键移动，右键展开，左键折叠或返回父节点，Home/End，Space 选择/勾选，Enter 激活或提交，Escape 关闭浮层或清除当前临时状态。虚拟化时 active 节点必须真实存在于 DOM。

移动端不得删除搜索、展开、返回上级、路径摘要、已选摘要、清空、应用、错误说明、权限说明或恢复路径。树过深、节点多、触摸目标过小、需要搜索或需要复核时，应转换为 Drawer、Bottom Sheet、独立页或分步选择。

## 与现有 owner 的关系

- `selection-controls.md`：基础 Checkbox/Radio/Switch/Segmented 归 Selection Controls；存在层级、父子级联、半选来源或懒加载时归本 owner。
- `selects-comboboxes.md`：简单单选下拉归 Select；树形选择、级联选择和多级路径选择归本 owner。
- `forms.md`：表单提交、dirty/touched、错误摘要和未保存离开由 Form owner 管理；本 owner 只向表单提交明确业务值。
- `query-filters.md`：树形筛选条件只在明确提交后进入 `appliedFilters`；过滤树节点不等于应用列表筛选。
- `data-tables.md`：树表的列、分页、排序、行选择和批量操作归 Data Table；通用 Tree/Cascader 归本 owner。
- `risk-actions.md`：权限变更、批量授权、菜单发布、拖拽重排提交、不可逆移动、外部系统影响和未知结果归 Risk owner。
- `admin-console.md`：组织、权限、菜单、审计、租户/工作区和 RBAC 边界复用管理台 owner。
- `responsive-adaptive.md`：移动端承载、触摸、虚拟键盘、安全区域和断点转换复用响应式 owner。

## 新 owner 草案结构

计划新增 `references/tree-hierarchy.md`：

1. 范围与边界
2. `treeHierarchyState`
3. 节点身份、路径和数据快照
4. 展开、active、选择和提交
5. 级联、半选和全选范围
6. 过滤、搜索和懒加载
7. 权限、安全和无泄露
8. 键盘、焦点和可访问性
9. 移动端承载和响应式
10. 生命周期、异步和 disposal
11. 完成前检查

稳定规则族建议：

- `TH-SCOPE`：范围和 owner 分流。
- `TH-STATE`：状态模型和状态分离。
- `TH-ID`：节点身份、路径和快照。
- `TH-CASCADE`：级联、半选和全选范围。
- `TH-FILTER`：过滤、搜索和懒加载。
- `TH-PERM`：权限、安全和无泄露。
- `TH-A11Y`：键盘、ARIA 和公告。
- `TH-RSP`：移动端和响应式承载。
- `TH-LIFE`：异步、迟到回调和 disposal。

## 验收策略

- 新增 owner 文档、SKILL 路由、README/HANDOFF 摘要。
- 新增 GREEN/RED 摘要，覆盖安全示例和反例。
- 新增 `docs/testing/tree-hierarchy/tree-hierarchy-audit.rb`，检查 owner、路由、摘要和证据。
- 运行维护中的 owner 审计、Markdown 链接检查和 `git diff --check`。
- 真实浏览器、触摸、键盘、屏幕阅读器、权限切换、懒加载、虚拟化、远程搜索和移动端视口验证在本轮文档工作中标为未验证，后续业务项目实现时必须补充。
