# 对象、资源与成员选择器交互规范

适用于对象选择器、资源选择器、成员/用户选择器、负责人选择、处理人选择、审核人/审批人选择、角色主体选择、账号/项目/工作区选择、关联对象选择、关联资源选择、lookup field、entity picker、resource picker、object picker、user picker、member picker、assignee picker、owner picker、reviewer picker、principal picker、account picker、project picker 和 relation picker。本文件是“从候选对象中选择一个或多个可绑定业务实体”的 owner。

对象选择器不是普通 Select，也不是把 `label/value` 塞进下拉框。普通 Select / Combobox 的键盘、popup、定位、搜索输入和 ARIA 机制继续执行 `references/selects-comboboxes.md`；多选 chips、批量粘贴、自由文本 token 和标签删除继续执行 `references/multi-select-tag-inputs.md`；字段提交、校验和脏状态继续执行 `references/forms.md`；成员邀请、角色生命周期和成员危险动作继续执行 `references/members-invitations-access.md`；审批候选人和审批节点继续执行 `references/approval-workflows.md`；权限、租户、工作区和无泄露证明继续执行 `references/permissions-tenancy-visibility.md`；层级资源或级联资源继续执行 `references/tree-hierarchy.md`；从列表行操作进入选择器时继续执行 `references/row-contextual-actions.md`。

## 范围与边界

本 owner 覆盖：

- 选择用户、成员、负责人、处理人、审核人、审批人、代理人、角色主体、服务账号、客户、账号、项目、工作区、资源、文件、数据集、报表、仪表盘、模板、关联记录和父级对象。
- 搜索结果、最近使用、收藏、推荐、默认候选、已选摘要、候选状态、不可绑定原因、重复身份、跨租户/工作区/账号边界和权限复核。
- 已删除、已失效、无权限、不可绑定、只读、重复、跨范围、加载失败、迟到搜索结果、旧缓存、旧最近项和旧选中快照的恢复。

本 owner 不定义组件库 API、视觉 token、后端搜索算法、业务权限矩阵、成员目录同步或业务对象命名。不得因为组件库只有 Select、TreeSelect、Transfer 或 Cascader 就跳过本 owner。

## `entityResourcePickerState`

每个对象、资源或成员选择器必须维护 `entityResourcePickerState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `pickerOwnerId` | 当前选择器实例的稳定身份，绑定 trigger、popup/drawer、请求、缓存、回执和焦点恢复。 |
| `pickerSurface` | `select-popup`、`combobox-panel`、`dialog`、`drawer`、`mobile-sheet`、`page` 或产品声明的承载面。 |
| `entityKind` | 被选实体类型，例如 user、member、principal、project、workspace、resource、record、report。 |
| `selectionMode` | `single`、`multiple`、`replace`、`append`、`reassign` 或产品声明的选择模式。 |
| `committedSelection` | 已提交业务选择，包含稳定 ID、实体类型、作用域、版本和安全展示快照。 |
| `draftSelection` | 当前未提交选择草稿；不得直接写入业务记录、筛选已应用值或审批节点。 |
| `queryState` | 当前关键词、筛选、排序、分页、请求代次、输入法状态和取消/迟到策略。 |
| `candidateResults` | 当前搜索候选及其身份、作用域、版本、可绑定状态和不可绑定原因。 |
| `recentAndSuggested` | 最近、收藏、推荐和默认候选；必须与搜索结果和已选实体分层。 |
| `identityResolution` | label、头像、邮箱、路径、编号、display snapshot 与稳定业务身份的解析关系。 |
| `availabilityMap` | `available`、`disabled`、`readonly`、`not-bindable`、`deleted`、`stale`、`duplicate`、`permission-denied`、`unknown`。 |
| `permissionBoundary` | 当前操作者、权限版本、租户/工作区/账号、对象范围、可见性和绑定能力。 |
| `scopeBinding` | 目标表单、记录、审批节点、列表行或业务对象的作用域快照。 |
| `bindingPolicy` | 选择后如何绑定：立即预览、应用草稿、确认提交、保存表单、批量追加或替换。 |
| `validationBinding` | 必填、最小/最大数量、互斥、重复、跨范围、失效对象和服务端复核错误。 |
| `requestIdentity` | 搜索、详情补全、权限复核、提交绑定和刷新候选的请求身份。 |
| `feedbackBinding` | loading、empty、error、partial、permission-denied、stale、conflict、unknown 和恢复入口。 |
| `responsivePolicy` | 移动端搜索、已选摘要、候选列表、删除、清空、应用/取消、错误和权限说明。 |
| `focusAnnouncementPolicy` | trigger、搜索框、候选项、已选摘要、错误、应用/取消和关闭后的焦点与读屏播报。 |
| `lifecycleDisposal` | 关闭、卸载、路由变化、权限变化、作用域变化、实体版本变化后的请求、缓存、ARIA 和焦点清理。 |
| `runtimeVerification` | 浏览器、键盘、读屏、触摸、虚拟键盘、权限切换、迟到请求和移动端验证状态；未执行必须标为未验证。 |

不得只用 `value`、`label`、`selectedId`、`selectedUser`、`options`、`searchResult`、`recentItems`、表单字段值、表格行数据、旧缓存或组件库默认 value model 替代 `entityResourcePickerState`。

## 核心规则

| 规则 ID | 规则 |
| --- | --- |
| `ERP-SCOPE-01` | 只要候选项是业务对象、成员、资源、账号、项目、工作区、审批人、负责人或关联记录，就必须声明本 owner；不能按普通 Select 处理。 |
| `ERP-SCOPE-02` | display label 不是对象身份。提交和请求必须绑定稳定 ID、实体类型、作用域、版本和权限快照，不能从名称、头像、邮箱、路径、tooltip、aria-label 或旧 DOM 文案反推对象。 |
| `ERP-STATE-01` | 已提交选择、选择草稿、搜索 query、active option、候选结果、最近/收藏/推荐和展示快照必须分层。query 命中、hover、focus、active 或高亮不等于已选择。 |
| `ERP-STATE-02` | 最近、收藏、推荐、默认候选和搜索结果必须标明来源与刷新身份；不得从旧搜索结果、旧最近项、旧推荐项或旧缓存提交当前选择。 |
| `ERP-PERM-01` | 跨租户、跨工作区、跨账号、跨项目或跨权限边界选择必须先证明当前操作者可见且可绑定；只可见不等于可绑定。 |
| `ERP-PERM-02` | 无权限状态不得泄露对象名称、头像、邮箱、路径、父级、数量、状态、成员关系、内部 ID、旧搜索命中、旧最近项、旧选中摘要、旧 tooltip 或旧 aria-label。 |
| `ERP-VALID-01` | 已失效对象、已删除对象、无权限对象、不可绑定对象、重复对象、只读对象和未知对象必须是不同状态，并给出不同恢复路径。 |
| `ERP-VALID-02` | 候选项不可绑定时必须在候选行和提交前同时暴露原因；不得让用户先选中再只用 Toast 失败。 |
| `ERP-ASYNC-01` | 搜索、分页、详情补全和权限复核都必须绑定 `requestIdentity`；迟到响应不得写回已关闭、已换 scope、已换 query、已换权限或已卸载的选择器。 |
| `ERP-BIND-01` | 选择只产生草稿或确认意图；最终写入记录、审批节点、成员角色、筛选条件或设置必须由对应 owner 完成提交与回执。 |
| `ERP-FEED-01` | Toast 不能作为唯一选择失败、权限拒绝、对象失效、重复冲突、部分加载或绑定结果回执；承载面内必须保留可恢复状态。 |
| `ERP-RSP-01` | 移动端不得删除搜索、候选、已选摘要、删除、清空、应用、取消、错误说明、权限原因、不可绑定原因、加载失败、重试和焦点返回。 |
| `ERP-RSP-02` | 移动端可以从 popup 转为 Drawer / Bottom Sheet / 独立页，但必须保持 `pickerOwnerId`、草稿、请求身份、已选摘要和提交边界不变。 |
| `ERP-A11Y-01` | 候选项可访问名称必须来自当前安全展示快照；权限变化、候选失效或关闭后必须清理旧 aria-activedescendant、aria-label、tooltip 和描述引用。 |
| `ERP-VERIFY-01` | 未在真实浏览器、键盘、读屏、触摸、权限切换、迟到请求和移动端视口验证前，必须标为未验证。 |

## 选择流程

1. 打开时创建 `pickerOwnerId`，冻结 `scopeBinding`、`permissionBoundary` 和 `bindingPolicy`。
2. 拉取最近/收藏/推荐时写入 `recentAndSuggested`，不得覆盖 `candidateResults` 或 `committedSelection`。
3. 输入搜索时更新 `queryState` 并生成新 `requestIdentity`；旧请求返回后只能丢弃或写入已失效审计，不得更新可见候选。
4. 候选项渲染前必须完成身份解析、权限复核和可绑定状态判定；无法证明时按 `unknown` 或 `permission-denied` 安全占位。
5. 用户选择候选只更新 `draftSelection`；如果是多选，还必须执行 `multiValueInputState` 的 token/chips 规则。
6. 应用、确认或保存前复核目标 scope、实体版本、权限版本和不可绑定状态。
7. 成功后由目标 owner 更新业务值并给出持久回执；失败、部分成功、未知结果和权限拒绝必须保留恢复入口。
8. 关闭、切换 scope、权限变化或路由离开时清理请求、popup/drawer、焦点、ARIA、tooltip、旧候选和旧最近项。

## 移动端与窄屏

- 如果 popup 在 Dialog、Bottom Sheet、低高度视口或虚拟键盘下会遮挡底部操作区，应转为 Select Drawer 或 Bottom Sheet；任务复杂、筛选较多或需要对比摘要时升级为独立页。
- 移动端承载面必须同时显示搜索入口、候选列表、已选摘要、清空/删除、应用/取消、不可绑定原因、权限原因、错误和重试。
- Bottom Sheet 不得与外层 Dialog/Drawer 正文共享滚动容器；候选列表、已选摘要和底部操作必须分别有滚动与安全区域策略。
- 系统返回、滑动关闭或关闭按钮只能表达取消草稿；不得提交选择或让旧请求继续写入。

## 审计清单

- 是否声明 `entityResourcePickerState`，且字段覆盖 owner、surface、entity kind、选择模式、草稿、提交、query、候选、最近/推荐、身份解析、权限、scope、绑定策略、验证、反馈、响应式、焦点和生命周期。
- 是否明确 display label、头像、邮箱、路径、tooltip 和 aria-label 不是稳定身份。
- 是否区分已提交选择、草稿、搜索 query、active option、候选、最近、收藏、推荐和展示快照。
- 是否区分已失效、已删除、无权限、不可绑定、重复、只读和未知对象。
- 是否证明跨租户、跨工作区、跨账号、跨项目或跨权限边界可见且可绑定。
- 是否禁止旧搜索结果、旧最近项、旧推荐项、旧缓存、旧 tooltip 和旧 aria-label 泄露或提交。
- 是否在移动端保留核心能力，并明确未验证的真实运行时边界。
