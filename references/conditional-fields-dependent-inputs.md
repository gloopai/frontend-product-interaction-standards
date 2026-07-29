# 条件字段与依赖输入交互规范

适用于条件字段、依赖字段、联动字段、字段联动、条件显示、条件隐藏、条件必填、条件禁用、条件只读、级联字段、父子字段、上游字段、下游字段、动态字段、动态表单、依赖输入、派生字段、计算字段、自动填充、条件校验、隐藏字段清理、条件筛选、联动筛选、dependent field、conditional field、conditional required、conditional visibility、dynamic field、field dependency、field dependency graph、cascading field、derived field、computed field、auto fill 和 dependent input。

本文件是条件字段与依赖输入 owner。字段联动不是 `if value then show field` 的临时 UI 逻辑。它必须证明依赖图、上游快照、下游值策略、显隐/禁用/只读语义、条件必填、清值规则、候选失效、校验重算、提交快照、权限边界、移动端和生命周期。

表单字段值、dirty、校验、错误摘要和提交生命周期继续执行 `references/forms.md`；字段 label、帮助文本、条件必填说明、禁用/只读原因和空值说明继续执行 `references/field-guidance-help-text.md`；Select / Combobox 的 query、active option、popup 和已提交值继续执行 `references/selects-comboboxes.md`；多选和 token 输入继续执行 `references/multi-select-tag-inputs.md`；筛选条件联动继续执行 `references/query-filters.md`；设置和配置页的 draft/effective/default 继续执行 `references/settings-preferences-configuration.md`；权限与无泄露继续执行 `references/permissions-tenancy-visibility.md`；树形和级联选择继续执行 `references/tree-hierarchy.md`；复杂规则构建器继续执行 `references/complex-editors-builders.md`；移动端继续执行 `references/responsive-adaptive.md`。

## 范围与边界

本 owner 覆盖：

- 字段显隐、启用/禁用、只读、条件必填、条件校验、条件帮助文本、条件 placeholder、条件默认值和条件错误。
- 上游字段改变后，下游字段的保留、清空、失效、重算、禁用、只读、隐藏、重新请求候选、重新校验和重新提交策略。
- 表单、筛选区、设置页、向导步骤、批量配置、导入字段映射、报表配置和规则配置中的字段依赖。
- 异步候选、迟到响应、级联下拉、联动筛选、自动填充、派生字段、计算字段和权限收敛。

本 owner 不覆盖：

- 后端规则引擎、表达式 DSL、表单 schema 语法或具体业务字段。
- Tree/Cascader 节点级选择本身；节点选择继续执行树形结构 owner。
- 完整复杂规则构建器、可视化条件编辑器和流程编排器；这些继续由复杂编辑器 owner 负责。

## `fieldDependencyState`

每个条件字段组、字段依赖图、联动筛选组、设置组或动态字段区域必须声明 `fieldDependencyState`：

| 字段 | 语义 |
| --- | --- |
| `dependencyOwnerId` | 当前依赖图 owner 的稳定身份。 |
| `dependencySurface` | `form`、`filter-bar`、`settings`、`wizard-step`、`bulk-config`、`import-mapping`、`report-config`、`rule-config`。 |
| `dependencyGraph` | 上游字段、下游字段、条件表达式、依赖方向、循环禁止、分组和优先级。 |
| `upstreamSnapshot` | 触发本轮联动的上游已提交业务值、权限版本、租户/工作区、字段版本和请求代次。 |
| `downstreamPolicy` | 下游字段保留、清空、失效、重算、隐藏、禁用、只读、默认值、自动填充和候选请求策略。 |
| `visibilityPolicy` | visible、hidden-by-condition、hidden-by-permission、disabled-by-condition、disabled-by-permission、read-only、not-applicable 的语义。 |
| `requirementPolicy` | 必填、选填、条件必填、条件不适用、提交前必填重算和错误文案归属。 |
| `valueRetentionPolicy` | 隐藏、禁用、只读、条件不适用、权限降级和上游变化后的值保留、清理或失效策略。 |
| `validationPolicy` | 条件校验、跨字段校验、异步校验、错误失效、错误迁移和错误摘要策略。 |
| `candidatePolicy` | 下游候选项、远程搜索、缓存、迟到响应、孤儿值、无权限候选和空候选策略。 |
| `derivedValuePolicy` | 自动填充、派生值、计算值、用户覆盖、重新计算、冲突和回滚策略。 |
| `submitSnapshotPolicy` | 提交 payload 中包含、排除、清空、置 null、保留旧值或发送显式 unset 的策略。 |
| `permissionBoundary` | 查看字段、查看候选、编辑字段、保留隐藏值、提交派生值和读取旧错误的权限版本。 |
| `feedbackBinding` | 字段错误、组错误、条件说明、候选加载、空候选、权限原因和恢复入口归属。 |
| `responsivePolicy` | 移动端字段顺序、折叠、步骤拆分、下游错误外显和虚拟键盘策略。 |
| `focusAnnouncementPolicy` | 字段出现/消失、禁用/只读、必填变化、清值、错误迁移和候选重算的焦点与公告策略。 |
| `lifecycleDisposal` | 路由变化、owner 卸载、上游请求失效、权限变化、字段 schema 变化和断点转换时的清理规则。 |
| `runtimeVerification` | 真实浏览器、键盘、读屏、触摸、IME、异步迟到、权限切换、移动端和缩放验证状态；未执行必须标为未验证。 |

不得只用 `watch(field)`、`disabled={...}`、`hidden={...}`、`required={...}`、前端 if、字段 schema、后端 400、空字符串、组件默认 reset 或 submit 时临时过滤替代 `fieldDependencyState`。

## 显隐、禁用、只读和不适用

hidden-by-condition、hidden-by-permission、disabled-by-condition、disabled-by-permission、read-only 和 not-applicable 不是同一件事。它们对 DOM、值、校验、提交、可访问名称、错误、帮助文本和权限泄露的要求不同。

条件隐藏表示当前条件下字段不应参与当前任务；它必须声明值是清空、保留但不提交、发送 unset、还是保持服务端旧值。权限隐藏表示当前主体不应知道字段或候选存在，不能保留可访问名称、错误、placeholder、tooltip、缓存候选或隐藏输入。

禁用字段不能提交新值，也不能保留可执行 handler。只读字段可以展示当前可读值，但不能用 disabled 控件假装只读说明。not-applicable 必须说明为什么不适用，以及是否从提交 payload 中排除。

## 上游变化、清值和候选失效

上游字段变化后，所有受影响下游字段必须按 `downstreamPolicy` 原子进入保留、清空、失效、重算、禁用、只读或隐藏状态。不得先展示旧下游值再异步补清，也不得让旧候选、旧 active option、旧错误或旧帮助文本继续可见。

隐藏字段的旧值不得静默提交。隐藏、禁用、条件不适用、权限降级或候选失效后，提交策略必须明确是排除字段、发送 null、发送 unset、保留服务端旧值还是要求用户重新确认。不能由后端 400 才发现旧值非法。

级联 Select、远程候选和异步校验必须绑定 `upstreamSnapshot`、权限版本、租户/工作区和请求代次。迟到响应只有匹配当前依赖图和上游快照时才能写回；失配结果只能丢弃或进入安全恢复。

孤儿值必须可识别。若旧下游值不再属于新候选、权限范围或条件范围，必须展示可恢复说明、要求重新选择、发送 unset 或保留为只读旧值；不得静默把它当作合法提交值，也不得无提示删除用户选择。

## 条件必填、校验和错误摘要

条件必填必须在字段 label、帮助文本、错误摘要和提交前校验中一致表达。不得只在 placeholder、红星、tooltip 或后端错误里体现条件必填。

条件变化后，旧错误必须失效、迁移或重新归属。隐藏字段的错误不能留在错误摘要里指向不可见控件；如果错误仍阻塞提交，必须让相关字段或条件说明可见、可聚焦、可恢复。

跨字段校验必须说明依赖字段、触发时机、错误归属和提交门禁。上游变化、下游清值、权限降级和候选重算时，跨字段错误必须重新计算，不能继续引用旧字段 ID、旧 ARIA 描述或旧可见状态。

## 自动填充、派生值和用户覆盖

自动填充和派生值不是用户手填值。自动填充必须说明来源、是否可编辑、是否会覆盖用户输入、是否需要确认、是否进入 dirty、是否进入提交 payload，以及来源变化后如何重算。

用户覆盖后，上游变化不得静默覆盖用户值，除非产品声明并提示覆盖规则。计算值、派生值、默认值、继承值和用户输入必须在状态中可区分；保存结果和审计不得把自动填充误写成用户手填。

自动填充、派生值、默认值、继承值和用户输入必须在状态中可区分。

## 权限、安全和无泄露

权限降级、租户/工作区变化、能力关闭或字段 schema 变化后，旧字段值、旧候选、旧错误、旧 placeholder、旧帮助文本、旧 aria-describedby、旧隐藏输入、旧自动填充值和旧提交 payload 必须失效或重算。

无权限时不得泄露字段名称、字段值、候选项、字段数量、条件表达式、默认值、继承来源、错误原因、内部 ID、上游对象、下游对象或旧可访问名称。权限隐藏的字段 DOM、state、handler、request、cache 和快捷键入口必须为 0。

## 可访问性和移动端

字段出现、消失、禁用、只读、必填变化、清值、候选重算、错误迁移和自动填充必须有可见说明或可访问公告。颜色、红星、灰态、缩进、位置、tooltip 或 Toast 不能是唯一语义。

焦点所在字段因条件变化消失或禁用时，焦点只迁移一次到上游字段、条件说明、下一个可编辑字段、错误摘要或稳定页面标题。不得落到 body、隐藏输入、已移除字段或无权限内容。

移动端不得删除条件说明、必填变化、下游错误、清值说明、候选加载、重新选择、权限原因和恢复入口。复杂依赖可以拆为步骤、折叠区、Drawer 或独立页，但依赖关系和提交门禁必须可发现。

## 生命周期和清理

每个依赖 owner 必须登记依赖图、上游订阅、下游字段、候选请求、异步校验、自动填充、错误引用、帮助文本引用、焦点任务、公告回调和提交策略。

路由变化、owner 卸载、字段 schema 变化、权限变化、租户/工作区变化、断点转换、上游请求失效或表单会话重建后，旧订阅、旧候选、旧错误、旧帮助文本、旧隐藏输入、旧提交过滤、旧 ARIA 引用和旧焦点任务必须取消、失效或重算。

## 完成前检查

1. **owner 声明**：条件字段组、字段依赖图、联动筛选组、设置组或动态字段区域声明 `fieldDependencyState`。
2. **状态区分**：hidden-by-condition、hidden-by-permission、disabled-by-condition、disabled-by-permission、read-only 和 not-applicable 没有混用。
3. **上游快照**：上游变化冻结 `upstreamSnapshot`，下游按 `downstreamPolicy` 原子收敛。
4. **隐藏值提交**：隐藏字段的旧值不得静默提交；提交策略明确排除、null、unset、保留旧值或重新确认。
5. **候选失效**：下游候选、active option、孤儿值、远程结果和异步校验都绑定当前上游快照。
6. **条件必填**：label、帮助文本、错误摘要和提交前校验一致表达条件必填。
7. **自动填充**：自动填充、派生值、默认值、继承值和用户输入可区分，且不会静默覆盖用户输入。
8. **权限无泄露**：无权限不泄露字段名称、字段值、候选项、字段数量、条件表达式、默认值、错误原因、内部 ID 或旧可访问名称。
9. **移动端保真**：移动端保留条件说明、必填变化、下游错误、清值说明、候选加载、重新选择、权限原因和恢复入口。
10. **运行时报告**：真实浏览器、键盘、读屏、触摸、IME、异步迟到、权限切换、移动端和缩放未执行时必须标为未验证。
