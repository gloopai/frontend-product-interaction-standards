# 穿梭框、分配列表与授权资源选择交互规范

适用于穿梭框、Transfer、双列表选择、左右列表分配、资源分配、权限分配、菜单授权、角色授权、成员分组、项目分配、工作区分配、数据范围授权、关联资源批量绑定、权限树授权、分配成员、分配资源、授权菜单、授权数据、assigned/unassigned lists、dual listbox、transfer list、pick list、assignment list、permission assignment 和 resource assignment。本文件是“从候选集合把对象移动到已分配集合，并在确认后提交绑定关系”的 owner。

穿梭框不是两个普通 Select，也不是两个表格加左右按钮。普通候选对象身份继续执行 `references/entity-resource-pickers.md`，并声明 `entityResourcePickerState`；多值 chip/token 输入继续执行 `references/multi-select-tag-inputs.md`；树形授权、菜单树、部门树和权限树继续执行 `references/tree-hierarchy.md`；表格行、分页、筛选、虚拟滚动和选择继续执行 `references/data-tables.md`；批量移动、批量授权和部分成功继续执行 `references/bulk-actions-batch-operations.md`；字段提交、dirty、错误摘要和未保存离开继续执行 `references/forms.md`；权限、租户、工作区和无泄露证明继续执行 `references/permissions-tenancy-visibility.md`；风险授权或影响访问能力时继续执行 `references/risk-actions.md`；移动端承载继续执行 `references/responsive-adaptive.md`。

## 范围与边界

本 owner 覆盖：

- 左右集合、未分配/已分配、可选/已选、候选/目标、源列表/目标列表、包含/排除集合和分配草稿。
- 单项移动、批量移动、全选当前结果、全选全部候选、移除已分配、恢复初始分配、清空草稿、应用、取消和保存。
- 搜索、筛选、分页、排序、懒加载、树形半选、不可移动项、只读项、锁定项、继承项、无权限项、重复项、已删除项、迟到请求和部分成功。
- 角色菜单授权、成员分组、资源授权、数据范围授权、项目绑定、工作区绑定、关联资源绑定和配置向导里的分配步骤。

本 owner 不定义业务权限矩阵、后端授权 DSL、目录同步、具体角色名称、资源树结构或组件库 Transfer API。不得因为组件库提供 Transfer、Table Transfer、Tree Transfer 或 picklist 就跳过本 owner。

## `assignmentTransferState`

每个穿梭框、分配列表或授权资源选择器必须维护 `assignmentTransferState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `transferOwnerId` | 当前分配会话稳定身份，绑定左右列表、移动按钮、搜索请求、确认、回执和焦点恢复。 |
| `assignmentSurface` | `dialog`、`drawer`、`page`、`wizard-step`、`mobile-sheet` 或产品声明的承载面。 |
| `subjectBinding` | 被授权或被分配的主体，例如角色、用户组、成员、项目、工作区、客户、规则或记录。 |
| `candidateScope` | 可分配候选的来源范围、筛选快照、租户/工作区、权限版本、数据版本和分页策略。 |
| `initialAssignedSet` | 打开会话时已经生效的已分配集合，包含稳定 ID、类型、作用域、版本和安全展示快照。 |
| `draftAssignedSet` | 当前草稿已分配集合；移动、全选和移除只更新草稿，不得直接写入生效授权。 |
| `sourceVisibleSet` | 当前可见未分配候选，绑定搜索、筛选、分页、排序、权限和请求代次。 |
| `targetVisibleSet` | 当前可见已分配草稿，绑定搜索、筛选、排序、锁定/继承状态和请求代次。 |
| `selectionBuckets` | 左侧选中、右侧选中、跨页选中、排除项、全选当前结果和全选全部候选的独立集合。 |
| `moveIntent` | 本次移动意图：add、remove、add-page、remove-page、add-all-filtered、remove-all-filtered、reset、clear 或产品声明意图。 |
| `eligibilityMap` | 每个候选是否可移动、可移除、只读、锁定、继承、无权限、已删除、失效、重复或未知。 |
| `permissionBoundary` | 查看候选、查看已分配、添加、移除、全选、保存和审计所需权限与租户/工作区/账号边界。 |
| `requestIdentity` | 候选加载、已分配补全、权限复核、移动预检、保存提交和结果刷新请求身份。 |
| `diffSummary` | 相对 `initialAssignedSet` 的新增、移除、保留、锁定、不可提交和冲突摘要。 |
| `validationBinding` | 最小/最大数量、必选项、互斥项、继承项不可移除、跨范围限制、重复和服务端复核错误。 |
| `savePolicy` | 保存方式、确认要求、风险转交、乐观更新、部分成功、未知结果、重试和回滚策略。 |
| `feedbackBinding` | loading、empty、filtered-empty、partial、conflict、permission-denied、stale、unknown、success 和 recovery。 |
| `responsivePolicy` | 移动端单列/分步承载、当前集合切换、已分配摘要、移动/移除、搜索、应用/取消和错误恢复。 |
| `focusAnnouncementPolicy` | 左右列表、搜索、批量选择、移动按钮、差异摘要、错误、保存/取消和关闭后的焦点与读屏播报。 |
| `lifecycleDisposal` | 关闭、取消、保存后、路由变化、主体变化、权限变化、scope 变化和请求迟到后的草稿、请求、缓存、ARIA 与焦点清理。 |
| `runtimeVerification` | 浏览器、键盘、读屏、触摸、虚拟键盘、权限切换、迟到请求、批量范围和移动端验证状态；未执行必须标为未验证。 |

不得只用 `selectedKeys`、`targetKeys`、`checkedKeys`、`leftData`、`rightData`、`dataSource`、两个普通数组、表格行选择、树形 checked keys 或组件库 Transfer 默认状态替代 `assignmentTransferState`。

## 核心规则

| 规则 ID | 规则 |
| --- | --- |
| `ATL-SCOPE-01` | 只要存在候选集合与已分配集合之间的移动、授权、绑定、分组或包含/排除关系，就必须声明本 owner；不能按普通多选、普通 Select、两个表格或树 checked keys 处理。 |
| `ATL-STATE-01` | `initialAssignedSet`、`draftAssignedSet`、`sourceVisibleSet`、`targetVisibleSet`、`selectionBuckets` 和 `diffSummary` 必须分层；移动不等于保存，勾选不等于移动，搜索命中不等于已分配。 |
| `ATL-STATE-02` | 左侧选中、右侧选中、跨页选中、排除项、全选当前结果和全选全部候选必须是不同意图；不得用一个 `selectedKeys` 同时表达。 |
| `ATL-ID-01` | 分配对象必须绑定稳定 ID、实体类型、作用域、版本和安全展示快照；不得用名称、路径、序号、树节点 label、tooltip 或 aria-label 作为授权身份。 |
| `ATL-MOVE-01` | 单项移动、批量移动、全选当前结果、全选全部候选、移除当前结果和移除全部已分配必须生成明确 `moveIntent`，并在执行前复核 eligibility 与权限。 |
| `ATL-MOVE-02` | 搜索、筛选或分页后的“全选”只能作用于明确范围；不得把当前可见页伪装成全部候选，也不得把全部筛选结果伪装成全部资源。 |
| `ATL-PERM-01` | 无权限、不可见、只读、锁定、继承、已删除、失效、重复和未知不是同一状态，必须在候选行、目标行、差异摘要和保存前分别表达。 |
| `ATL-PERM-02` | 无权限状态不得泄露资源名称、路径、父级、子级数量、成员数量、授权关系、内部 ID、排序位置、旧候选、旧已分配摘要、旧 tooltip 或旧 aria-label。 |
| `ATL-TREE-01` | 树形授权中的半选只表达派生覆盖状态，不是可提交业务值；懒加载未完成、过滤后部分节点、无权限后代或锁定继承项存在时，不得把父节点全选伪装成全量授权。 |
| `ATL-SAVE-01` | 保存必须提交相对初始集合的 diff 或等价快照，并绑定 subject、scope、权限版本、数据版本和请求身份；不得从当前 DOM、当前页可见行或旧 checked keys 推导提交范围。 |
| `ATL-SAVE-02` | 保存失败、部分成功、未知结果、权限拒绝、版本冲突和继承冲突必须保留差异摘要与恢复入口；Toast 不能作为唯一回执。 |
| `ATL-ASYNC-01` | 候选加载、搜索、已分配补全、权限复核和保存响应都必须绑定 `requestIdentity`；迟到响应不得写回已关闭、已换主体、已换 scope、已换权限或已卸载的 owner。 |
| `ATL-RSP-01` | 移动端不得删除候选搜索、已分配摘要、待保存差异、单项移动、批量移动、移除、清空/重置、应用/取消、不可移动原因、权限原因、错误和重试。 |
| `ATL-RSP-02` | 移动端可以转为单列分步、Drawer 或独立页；左右集合可以折叠为“可添加/已分配”切换，但 `assignmentTransferState`、草稿、范围、差异摘要和保存边界必须不变。 |
| `ATL-A11Y-01` | 左右列表必须有可访问名称、集合计数、已选计数、移动结果公告和禁用原因；权限变化或关闭后必须清理旧 aria-selected、aria-describedby、tooltip 和焦点目标。 |
| `ATL-VERIFY-01` | 未在真实浏览器、键盘、读屏、触摸、权限切换、迟到请求、批量范围和移动端视口验证前，必须标为未验证。 |

## 标准流程

1. 打开时建立 `transferOwnerId`，冻结 `subjectBinding`、`candidateScope`、`permissionBoundary`、`initialAssignedSet` 和 `requestIdentity`。
2. 加载候选与已分配补全时分别更新 `sourceVisibleSet` 和 `targetVisibleSet`，不得覆盖 `initialAssignedSet` 或已形成的 `draftAssignedSet`。
3. 搜索、筛选、分页或排序变化必须生成新请求身份，并清理不再适用的可见选中；跨页选择保留时必须有明确范围和排除项。
4. 勾选只更新 `selectionBuckets`；移动按钮或明确操作才更新 `draftAssignedSet` 与 `diffSummary`。
5. 每次移动前复核 `eligibilityMap`、权限、锁定/继承、重复和失效状态；不可移动项必须在列表内说明原因。
6. 保存前展示 diff 摘要，必要时进入风险确认；提交时绑定 subject、scope、权限版本、数据版本、请求身份和 diff。
7. 保存结果必须区分成功、部分成功、失败、未知、权限拒绝和版本冲突；保留可恢复差异与重试入口。
8. 关闭、取消、主体变化、权限变化或路由离开时清理草稿、请求、缓存、ARIA、tooltip 和焦点引用。

## 移动端与窄屏

- 推荐把左右并列转为“可添加 / 已分配”两个分步面板，底部保留差异摘要、保存和取消。
- 列表很长、需要树形路径或批量范围说明时，优先使用全屏 Drawer 或独立页，不要塞进小弹窗。
- 移动端必须保留搜索、筛选摘要、已分配数量、待新增/待移除数量、不可移动原因、权限原因、清空/重置、保存/取消、错误恢复和焦点返回。
- 系统返回、滑动关闭或关闭按钮只表达取消草稿；不得提交授权，也不得让旧请求继续写入。

## 审计清单

- 是否声明 `assignmentTransferState`，且字段覆盖 owner、subject、scope、初始集合、草稿集合、左右可见集合、选中桶、移动意图、eligibility、权限、请求、diff、校验、保存、反馈、响应式、焦点、生命周期和运行时验证。
- 是否明确移动不等于保存、勾选不等于移动、搜索命中不等于已分配。
- 是否区分当前页全选、全部筛选结果、全部候选、跨页选择和排除项。
- 是否证明无权限、只读、锁定、继承、已删除、失效、重复和未知状态不会合并或泄露。
- 是否禁止旧候选、旧已分配摘要、旧 checked keys、旧 tooltip 和旧 aria-label 继续提交或泄露。
- 是否在树形授权中处理半选、懒加载未完成、过滤后部分节点、无权限后代和锁定继承项。
- 是否在移动端保留核心分配能力，并明确未验证的真实运行时边界。
