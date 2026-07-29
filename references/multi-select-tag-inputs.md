# 多选、标签输入与 Tokenized Input 交互规范

## 适用范围

本文件是多选 Select、多选选择器、多选下拉、标签输入、标签选择、标签创建、创建标签、可创建选项、自由文本标签、Token 输入、tokenized input、chips input、收件人输入、邮箱标签、手机号标签、成员多选、角色多选、用户多选、分类标签、批量粘贴、粘贴多个值、已选标签、删除标签、清空标签、拖拽排序标签、异步多值检索和 bulk paste 的 primary owner。

凡是一个输入面同时存在多个已选值、可编辑 query、候选 option、待创建项、批量粘贴解析结果或 chip/token 列表，都进入本 owner。不要把它降级为普通数组字段、普通 Select、普通 Checkbox Group 或普通文本输入。

## 与其他 owner 的关系

- 单选且业务值必须来自已有选项的 Select / Combobox 继续由 `references/selects-comboboxes.md` 负责；一旦允许多选、创建、自由文本 token、收件人 chips 或批量粘贴，就必须执行本文件。
- 少量固定 Checkbox Group、Radio Group、Toggle Group 和 Segmented Control 继续由 `references/selection-controls.md` 负责；选项很多、需要搜索、异步、创建或 chip 承载时进入本文件。
- 多值筛选、标签筛选、成员筛选和批量粘贴筛选值同时执行 `references/query-filters.md`；本文件负责字段内部多值输入，筛选 owner 负责 `filterDraft`、`appliedFilters`、URL、重置和应用边界。
- 成员、角色、邀请和访问管理业务动作同时执行 `references/members-invitations-access.md`；本文件只约束成员候选如何被选择、创建、粘贴、删除和提交到草稿。
- 权限可见性、无权限入口、旧权限缓存和租户/工作区切换同时执行 `references/permissions-tenancy-visibility.md`。
- 移动端承载、断点、虚拟键盘、安全区域、触摸目标和底部抽屉转换同时执行 `references/responsive-adaptive.md`。
- 字段 label、必填、错误摘要、dirty/touched、提交和未保存离开继续执行 `references/forms.md`；本 owner 的 committedValues 只是交给表单或筛选 owner 的合法业务候选。

## `multiValueInputState`

每个多值输入实例必须维护 `multiValueInputState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `multiValueOwnerId` | 当前多值输入稳定身份，用于绑定值、query、候选、创建、粘贴、异步请求、焦点、ARIA 和回调。 |
| `valueKind` | 值类型和来源：已有选项、可创建标签、自由文本 token、成员、邮箱、手机号、角色、分类、远程对象或混合类型。 |
| `committedValues` | 已提交给表单、筛选、设置、成员动作或服务端请求的合法业务值集合。 |
| `draftTokens` | 当前会话中尚未提交或等待用户确认的 token、待创建项、待校验项和粘贴解析项。 |
| `queryState` | 输入 query、composition、光标、active option、搜索 loading/error/retry、请求代次和防抖状态。 |
| `candidateOptions` | 当前候选列表、分页、分组、禁用项、无权限项、已选项、重复项、缓存标签和远程结果身份。 |
| `creationPolicy` | 是否允许创建、创建类型、格式校验、重复校验、服务端创建请求、失败恢复和创建后待提交策略。 |
| `pastePolicy` | 是否允许批量粘贴、分隔符、解析规则、最大数量、重复处理、非法项保留和确认策略。 |
| `commitPolicy` | 允许哪些明确动作把合法 `draftTokens` 写入 `committedValues`，以及是否进入表单提交、筛选应用或设置保存。 |
| `validationState` | 必填、数量上下限、格式错误、重复冲突、无权限、orphaned invalid、远程校验和字段错误归属。 |
| `permissionBoundary` | 当前用户、租户/工作区、角色版本、对象状态、字段能力、创建能力、粘贴能力和请求权限版本。 |
| `feedbackBinding` | 字段错误、chip 错误、批量解析说明、Toast、Alert、live region、重试和恢复入口的归属关系。 |
| `responsivePolicy` | PC、窄屏、移动端、虚拟键盘、底部抽屉、全屏选择页、触摸目标和安全区域策略。 |

多值输入不能只维护一个数组；已提交值、当前草稿 tokens、输入 query、active option、候选列表、创建候选和粘贴候选必须分别可观察。

## 已提交值、草稿 tokens 与 query 分层

只有符合 `commitPolicy` 的明确提交动作，才允许把合法 `draftTokens` 写入已提交值；不得因为按 Enter 就把任意 query 提交为业务值。

- `committedValues` 是业务值，只能来自已选择的合法 option、已确认的创建结果、已通过校验的自由文本 token 或用户确认后的批量解析结果。
- `draftTokens` 是编辑中的候选集合，可以包含待创建、待校验、重复、无权限、冲突、非法格式或等待确认的项；它不得被报表、筛选结果、保存请求、导出范围或成员动作当成已经生效。
- `queryState.query` 只是输入草稿；query 清空不等于清空 `committedValues`，query 变化不等于值变化，搜索 loading 不等于字段 saving。
- `active option` 只代表键盘或 ARIA 当前高亮候选，不代表已选中，也不得写入 `committedValues`、URL、表单 dirty 结果或筛选摘要。
- 外部关闭、Esc、失焦、断点转换、滚动锁转换、Portal 转移或候选刷新都不得隐式提交 query、active option 或 draftTokens。

## 选择、创建与自由文本 token

选择已有 option 必须使用稳定业务键写入 `draftTokens` 或 `committedValues`，不能只写显示 label、列表索引或当前 query。禁用、无权限、过期、跨租户、已删除或未加载完整身份的 option 不得被提交。

创建标签不等于已提交字段；服务端创建成功不等于表单保存、筛选应用或设置生效。

- 可创建选项必须使用明确文案，例如“创建标签：设计系统”，不能把普通候选和创建候选混成同一种 option。
- 创建前必须完成格式、数量、重复、权限和敏感词校验；失败时保留原 query 或 draft token，并给出可恢复路径。
- 服务端创建成功只说明“候选对象创建成功”或“标签实体可用”，还需要用户符合 `commitPolicy` 的提交动作，才能进入 `committedValues`。
- 自由文本 token 必须声明是否允许、允许类型、格式、长度、最大数量、重复策略、非法 token 是否保留以及是否需要远程校验。
- 邮箱标签、手机号标签和收件人输入必须区分可发送身份、待解析文本、格式错误、无权限接收人、外部接收人和已退订/不可达对象。

## 删除、清空、重排与撤销

Backspace 在 query 非空时只编辑 query；第一次 Backspace 只能高亮最后一个可删除 token，第二次明确删除该 token。

- 每个 chip/token 必须有可见删除入口、键盘可达删除入口和可访问名称，名称必须包含该 token 的可安全展示标签。
- 删除 token 只删除当前 owner 的对应 token，不得清空 query、候选列表、其他字段草稿或已提交筛选。
- 清空全部必须有可见入口，并按风险声明是否需要二次确认或撤销；清空 committedValues 与清空 draftTokens 必须分开。
- 拖拽排序标签必须有键盘排序路径，并在排序后说明当前顺序是否影响业务优先级、展示顺序、通知顺序或权限继承。
- 删除、清空或重排失败时必须恢复到可解释状态；不得只用 Toast 提示失败但 UI 已经丢失 token。

## 批量粘贴、重复与冲突

批量粘贴不能直接提交；重复判断必须基于稳定业务键，而不是显示标签。

- 粘贴多个值后必须进入解析状态，展示新增、重复、无效、无权限、待创建、冲突和超限项，用户确认后才进入 `draftTokens` 或 `committedValues`。
- 分隔符、引号、换行、空格、大小写、全角半角、邮箱别名、手机号区号、标签同义词和成员唯一身份必须由 `pastePolicy` 声明。
- 重复项可以合并、跳过或要求用户选择，但必须说明依据；不能因为两个 label 相同就误判为同一业务对象，也不能因为 label 不同就允许同一业务键重复提交。
- 批量解析失败不得丢弃原始粘贴内容；必须提供复制错误、重新解析、逐项修正或取消路径。
- 已超数量限制时，必须说明已保留、已跳过、待确认和需要删除的项，不能只禁用保存按钮。

## 异步搜索、创建与迟到结果

迟到结果只能写回仍 live 且身份匹配的 `multiValueOwnerId` 和草稿代次。
旧搜索结果、旧创建结果、旧校验错误、旧 active option、旧焦点目标和旧 ARIA 引用必须失效或重新证明安全。

- 搜索请求、创建请求、远程校验、分页加载、去重请求和权限复核都必须绑定 `multiValueOwnerId`、query、权限版本、租户/工作区和请求代次。
- 输入继续变化、owner 卸载、路由切换、Dialog/Drawer 关闭、租户切换、权限变化或 valueKind 变化后，旧请求只能丢弃或进入明确的 stale 状态。
- loading、empty、error、retry、部分结果、分页加载和远程去重必须属于 `queryState` 或 `candidateOptions`，不得污染 `committedValues`。
- 创建成功但表单保存失败、表单保存成功但创建状态未知、搜索失败但已有 committedValues 仍可展示，三者必须可区分。
- 虚拟列表或分页候选中，`aria-activedescendant` 只能引用已渲染且仍属于当前候选集合的 option。

## 权限、失效与安全

无权或未启用时，搜索、候选列表、选择、创建、粘贴、删除、清空、重排、提交、快捷键和请求入口的 DOM、state、handler、request 和快捷键入口为 0。

- 权限降低、角色变更、租户/工作区切换、对象删除、字段禁用、成员失效或功能开关关闭后，旧候选、旧草稿、旧错误、旧请求、旧焦点目标、旧 live region 和旧 ARIA 引用必须清理或重新证明安全。
- 无权状态不得泄露候选名称、成员邮箱、手机号、内部 ID、角色名、标签数量、分组路径、历史搜索、粘贴内容、重复原因、禁用原因的敏感部分或旧缓存 label。
- 禁用只是视觉状态时不够；如果无权，相关 handler、快捷键、请求构造、Portal 内容、隐藏 option、批量解析队列和浏览器自动填充入口也必须不可达。
- 权限恢复后不得自动重新提交旧草稿；用户必须重新确认仍然适用的 `draftTokens`。

## invalid 与 orphaned invalid

orphaned invalid 是已经提交或恢复出来、但后来被删除、无权限、格式规则变化、租户切换、远程解析失败或当前候选集中不存在的 token。

- orphaned invalid 不得被静默删除、替换为第一个可用项或只在提交时才报错。
- UI 必须保留其安全展示标签、原始业务键、失效原因、影响范围和处理入口；如果标签敏感，只展示脱敏摘要。
- 用户可以删除、替换、重新验证或请求权限；在完成处理前，表单提交、筛选应用或成员动作是否允许继续必须由 `validationState` 明确声明。
- URL 恢复、保存视图恢复、草稿恢复和浏览器返回恢复出的失效 token 也必须进入 orphaned invalid，而不是被忽略。

## 可访问性与反馈

同一完整消息不能同时由字段、chip、Toast 和全局 live region 重复播报。

- 输入区必须有可见 label 或 `aria-labelledby`；多值输入的说明、数量限制、格式规则和错误必须通过稳定 `aria-describedby` 关联。
- 候选列表使用 combobox/listbox/option 语义时，`aria-expanded`、`aria-controls`、`aria-activedescendant`、`aria-selected` 和禁用状态必须与当前 DOM 同步。
- chip 删除按钮必须有明确名称，例如“删除标签：设计系统”；只读 token 不得暴露删除按钮。
- Enter、Space、Arrow、Home/End、Esc、Tab、Backspace、Delete、粘贴和输入法 composition 必须有明确行为；输入法 composition 未结束时不得提交 token。
- 批量解析、重复、无效、无权限、创建失败、搜索失败和 orphaned invalid 必须有字段内可恢复说明；Toast 只能作为补充回执，不能替代字段错误。
- live region 只播报状态变化摘要；不要对每个 chip、字段错误、Toast 和全局消息重复完整文本。

## 移动端与响应式承载

移动端不得删除已选摘要、搜索、候选列表、创建入口、粘贴解析、重复/无效项说明、删除 token、清空、应用/取消、字段错误、权限原因、重试、恢复和离开保护。

- 移动端可以改为底部抽屉、全屏选择页或紧凑面板；如果使用底部抽屉，必须保留标题、关闭、已选摘要、搜索输入、候选列表、错误说明和底部应用/取消区。
- 虚拟键盘打开时，搜索输入、active option、错误、应用/取消和清空入口不能被遮挡；底部安全区域和固定操作区必须避让。
- chip 列表可以折叠为摘要，但必须提供查看、删除、清空、处理 invalid、处理重复和恢复入口。
- 批量粘贴在移动端仍要展示解析结果；不能因为屏幕窄而自动提交或只保留成功项。
- 触摸目标、拖拽排序替代、屏幕阅读器顺序、横竖屏切换和路由返回都必须保持当前 `multiValueInputState` 可恢复。

## 完成前检查

- 是否声明完整 `multiValueInputState`，并包含 `multiValueOwnerId`、`valueKind`、`committedValues`、`draftTokens`、`queryState`、`candidateOptions`、`creationPolicy`、`pastePolicy`、`commitPolicy`、`validationState`、`permissionBoundary`、`feedbackBinding` 和 `responsivePolicy`。
- 是否能区分 `committedValues`、`draftTokens`、`query`、`active option` 和 `candidateOptions`。
- 是否验证创建标签、服务端创建成功、Backspace、批量粘贴、稳定业务键、迟到结果、旧搜索结果、orphaned invalid、权限 0 入口和移动端承载。
- 是否确认无权或未启用时，搜索、候选列表、选择、创建、粘贴、删除、清空、重排、提交、快捷键和请求入口的 DOM、state、handler、request 和快捷键入口为 0。
- 是否确认同一完整消息不会同时由字段、chip、Toast 和全局 live region 重复播报。
- 未实际执行点击、键盘、粘贴、权限切换、网络迟到和移动端视口检查时，必须标记 `未验证`。
