# 多选、标签输入与 Tokenized Input 交互规范设计

## 背景

现有 `references/selects-comboboxes.md` 明确只覆盖“自绘、单选且业务值必须来自已有选项”的 Select / Combobox，并排除了多选、标签输入和自由文本创建。`references/selection-controls.md` 覆盖 Checkbox Group、Toggle Group 等少量固定选项；`references/tree-hierarchy.md` 覆盖树形多选；`references/data-tables.md` 覆盖表格行选择。

这留下一个高频缺口：多选 Select、标签输入、收件人 chips、成员选择、角色标签、分类标签、可创建标签、邮箱/手机号 token、批量粘贴、异步搜索多选、输入后按 Enter 创建、删除 chip、拖拽排序和移动端多值选择。这类交互常被误做成“单选 Select 加数组”，于是出现一串问题：输入 query 被提交成业务值；active option 被当成已选；创建标签绕过校验；批量粘贴重复创建；删除 chip 误删已提交值；远程搜索迟到结果覆盖新草稿；无权限选项还残留在 DOM/请求里；移动端把已选摘要、删除、清空、应用、错误恢复藏没了。

因此下一阶段应新增独立 owner：多选、标签输入与 Tokenized Input。它负责“一个字段或筛选条件中选择/创建多个值”的状态模型、提交边界、键盘、ARIA、创建策略、批量粘贴、重复/冲突、权限、移动端和验证，而不是扩大单选 Select 或少量 Checkbox owner 的范围。

## 目标

新增 `references/multi-select-tag-inputs.md`，作为多选 Select、标签输入、Tokenized Input、chips input、收件人输入、成员多选、标签创建、邮箱/手机号 token、批量粘贴和异步多值检索的专属 owner。

该 owner 需要约束：

- 已提交多值、当前草稿 tokens、输入 query、active option、候选列表、创建候选和批量粘贴结果的分层。
- 选择已有选项、创建新标签、删除 chip、清空、排序、应用、取消、表单提交、筛选应用和设置保存的提交边界。
- 远程搜索、异步校验、重复值、失效值、orphaned invalid、权限不可见值和迟到结果的处理。
- 键盘、ARIA、屏幕阅读器公告、chip 删除按钮、Listbox 多选语义、Combobox 输入语义和移动端 Drawer/独立页承载。
- 与表单、筛选、成员邀请、权限、上传附件、按钮、浮层、响应式等 owner 的关系。

## 非目标

- 不替代 `selects-comboboxes.md` 的单选 Select / Combobox；单选仍走该 owner。
- 不替代 `selection-controls.md` 的少量固定 Checkbox Group 或 Toggle Group。
- 不替代 `tree-hierarchy.md` 的树形多选、级联选择、半选和懒加载层级选择。
- 不替代 `data-tables.md` 的表格行选择、跨页选择和批量操作选择。
- 不替代 `members-invitations-access.md` 的邀请权限、角色变更、转移 Owner 和成员审计；本 owner 只定义多值输入控件层。
- 不定义邮箱、手机号、标签命名、反垃圾、用户搜索排序、身份解析或后端去重算法。

## 方案比较

### 方案 A：扩展单选 Select owner

优点是搜索、popup、Drawer、ARIA 逻辑可以复用。缺点是单选和多选的核心状态完全不同：单选只有一个 committed value，多选有 committed values、draft tokens、query、active candidate、created candidates、批量粘贴候选和删除/清空边界。塞进单选文件会让两个 owner 都变得不好读。

### 方案 B：扩展选择控件 owner

优点是“多选”这个词看起来接近 Checkbox Group。缺点是标签输入通常需要搜索、远程加载、自由文本创建、批量粘贴、chip 删除、虚拟列表和移动端 Drawer；这些不是少量固定选择控件的职责。

### 方案 C：新增多选、标签输入与 Tokenized Input owner

优点是边界清楚：单选读 Select owner，少量固定多选读 Selection Controls，树形多选读 Tree owner，多值搜索/创建/chips 输入读本 owner。缺点是需要新增一套路由、README/HANDOFF 摘要、相邻关系和静态审计。

推荐方案 C。这个 owner 能覆盖管理台和用户侧都常见的“多值输入”，而且不会把单选 Select 的规则搅成一锅。小小的 chips，背后是一串状态账本；值得单独立户。

## 范围和触发词

中文触发词：

多选 Select、多选选择器、多选下拉、标签输入、标签选择、标签创建、创建标签、可创建选项、自由文本标签、Token 输入、收件人输入、邮箱标签、手机号标签、成员多选、角色多选、用户多选、分类标签、批量粘贴、粘贴多个值、已选标签、删除标签、清空标签、拖拽排序标签、chip、chips、tokenized input。

英文触发词：

multi-select, multiselect, multiple select, multi select dropdown, tag input, tags input, tag selector, create tag, creatable option, free text tag, token input, tokenized input, chips input, recipient input, email chips, phone chips, member multi-select, user multi-select, role multi-select, category tags, paste tokens, bulk paste, selected chips, remove chip, clear tags, reorder tags.

## `multiValueInputState`

每个多值输入场景必须声明 `multiValueInputState`：

| 字段 | 含义 |
| --- | --- |
| `multiValueOwnerId` | 当前多值输入实例身份，绑定字段、筛选、设置、承载面、权限版本、选项版本和会话。 |
| `valueKind` | `existing-options-only`、`creatable-options`、`free-text-tokens`、`recipient-resolver` 或 `mixed`。 |
| `committedValues` | 已提交业务值、标签、来源、顺序、失效状态、权限边界和版本。 |
| `draftTokens` | 当前会话中已选但未提交的 tokens，包括已有选项、创建候选、粘贴候选、invalid 值和删除标记。 |
| `queryState` | 输入 query、active option、搜索请求身份、防抖、加载、错误、空结果和过期结果策略。 |
| `candidateOptions` | 当前候选列表、分组、禁用原因、权限、去重键、渲染身份和虚拟化窗口。 |
| `creationPolicy` | 是否允许创建、创建文案、校验、重复策略、待确认状态、服务端创建结果和取消路径。 |
| `pastePolicy` | 批量粘贴的分隔符、解析、去重、无效项、冲突项、预览、确认和错误定位。 |
| `commitPolicy` | `form-submit`、`filter-apply`、`explicit-save`、`immediate-safe`、`draft-only` 的提交策略。 |
| `validationState` | 必填、最少/最多数量、重复、互斥、权限、格式、失效值、orphaned invalid 和服务端校验结果。 |
| `permissionBoundary` | 查看、搜索、选择、创建、删除、清空、重排和提交时的权限、租户/工作区和旧状态收敛。 |
| `feedbackBinding` | 字段错误、token 错误、搜索错误、创建错误、粘贴错误、提交结果和公告 owner。 |
| `responsivePolicy` | PC popup/panel、移动端 Drawer/独立页、虚拟键盘、已选摘要、底部操作、安全区域和触摸排序。 |

`committedValues`、`draftTokens`、`queryState.activeOption` 和 `candidateOptions` 必须分离。Hover、focus、active option、搜索 query、创建候选、粘贴候选、chip 临时高亮和拖拽预览都不得伪装成已提交业务值。

## 核心规则

### 已提交值、草稿 token 和 query 分层

多值输入不能只维护一个数组。已提交值、当前草稿 tokens、输入 query、active option、候选列表、创建候选和粘贴候选必须分别可观察。

搜索、Hover、键盘 active、远程结果刷新、过滤候选、创建候选出现、粘贴解析完成和移动端承载转换都不得自动写入 `committedValues`。只有符合 `commitPolicy` 的明确提交动作，才允许把合法 `draftTokens` 写入已提交值。

`Enter` 的语义必须由当前状态决定：存在 active option 时选择该 option；存在唯一明确创建候选且创建策略允许时进入创建候选；存在无效 query 时显示错误；不得因为按 Enter 就把任意 query 提交为业务值。

### 选择、创建和自由文本

`existing-options-only` 只能选择当前存在且启用的选项。选项刷新后已提交值失效时，必须保留原值和缓存标签并标记 orphaned invalid；不得静默清除、替换或自动选择相似项。

`creatable-options` 必须声明创建策略：允许字符、长度、大小写/空格归一化、重复判断、权限、审核状态、服务端创建结果和取消路径。创建标签不等于已提交字段；服务端创建成功不等于表单保存、筛选应用或设置生效。

`free-text-tokens` 必须声明格式校验、分隔符、大小写归一化、敏感内容、重复策略和错误定位。邮箱、手机号、ID 或外部对象 token 不得只靠前端正则证明身份有效；需要解析身份时必须进入 `recipient-resolver` 或服务端校验状态。

### 删除、清空、重排和撤销

删除 chip、Backspace 删除、点击清空、批量移除、拖拽排序和撤销必须只影响当前草稿，除非 `commitPolicy` 明确是 `immediate-safe` 且满足低风险可恢复条件。

Backspace 在 query 非空时只编辑 query；query 为空且焦点在输入框时，第一次 Backspace 只能高亮最后一个可删除 token，第二次明确删除该 token。读屏用户必须能听到将要删除的 token 名称和删除后的数量。

清空全部必须说明作用范围：清空当前草稿、清空已应用筛选、清空表单字段、清空设置值或清空远程订阅。清空危险或影响他人、权限、通知、计费、导出、任务或外部系统时，必须进入 `references/risk-actions.md`。

### 批量粘贴和重复冲突

批量粘贴不能直接提交。粘贴多个值必须进入 `pastePolicy`，解析出合法项、重复项、无效项、无权限项、待创建项和冲突项，并给出预览、确认、取消和错误定位。

重复判断必须基于稳定业务键，而不是显示标签。大小写、空格、全角/半角、别名、邮箱大小写、手机号格式化和旧缓存标签必须按产品声明的规范化策略处理。无法确认是否重复时，不能自动创建或自动合并，必须标为待确认或进入服务端校验。

### 异步搜索、创建和迟到结果

每次搜索、创建、解析、校验和批量粘贴确认都必须绑定请求身份、query、草稿代次、权限版本、选项版本和 owner。迟到结果只能写回仍 live 且身份匹配的 `multiValueOwnerId` 和草稿代次。

删除 token、清空、切换租户/工作区、权限变化、表单 reset、筛选应用、路由离开、移动端 Drawer 关闭或承载转换后，旧搜索结果、旧创建结果、旧校验错误、旧 active option、旧焦点目标和旧 ARIA 引用必须失效或重新证明安全。

### 权限、失效值和安全

无权或未启用时，搜索、候选列表、选择、创建、粘贴、删除、清空、重排、提交、快捷键和请求入口的 DOM、state、handler、request 和快捷键入口为 0。

无权限候选、成员、角色、标签、项目、邮箱、手机号或外部对象不得通过搜索结果数量、chip 文案、禁用 tooltip、ARIA label、DOM data 属性、错误日志、旧缓存标签或粘贴解析结果泄露。

失效值、已删除选项、权限不可见选项、未启用能力和服务端拒绝值必须进入 `validationState`。它们可以保留为只读 token 或 orphaned invalid，但不得静默丢失，也不得在提交 payload 中伪装成有效值。

### 可访问性和键盘

多值输入必须有可见字段标签或等价可访问名称。已选 token 列表、输入框、候选列表、错误摘要和操作按钮必须有稳定关系。chip 删除按钮必须有动作对象，例如“删除 标签 A”“移除 成员 B”。

候选列表使用 listbox 语义时，必须说明多选状态：已选、active、禁用和不可见原因不得混成一个 `aria-selected`。输入框的 `aria-activedescendant` 只能指向已渲染 active option；虚拟化或过滤导致 active 不存在时必须清除引用。

新增、删除、清空、粘贴解析、创建成功、创建失败、搜索失败、重复跳过和提交结果必须由唯一 owner 公告。同一完整消息不能同时由字段、chip、Toast 和全局 live region 重复播报。

### 移动端和响应式承载

移动端不得删除已选摘要、搜索、候选列表、创建入口、粘贴解析、重复/无效项说明、删除 token、清空、应用/取消、字段错误、权限原因、重试、恢复和离开保护。

移动端可以把多值输入转为 Select Drawer、全屏 Drawer、独立页或分步选择页，但必须保留同一个 `multiValueInputState`、同一个 `draftTokens`、同一个 `queryState`、同一个 `validationState`、同一个提交策略和同一个焦点返回目标。虚拟键盘、低高度、系统字体放大、横竖屏、安全区域和触摸排序出现后，已选值、错误、搜索、候选和底部操作仍必须可达。

## 与现有 owner 的关系

- `selects-comboboxes.md`：负责单选且值来自已有选项的 Select / Combobox；本 owner 负责多值、标签、创建和 tokenized input。
- `selection-controls.md`：负责少量固定 Checkbox Group、Radio Group、Toggle Group 和 Segmented；选项多、需要搜索/创建/粘贴/异步时进入本 owner。
- `tree-hierarchy.md`：负责树形、级联、父子关系、半选和懒加载节点；树形多选不由本 owner 重定义。
- `data-tables.md`：负责表格行选择、跨页选择和批量操作范围；本 owner 只负责字段或筛选里的多值输入。
- `forms.md`：负责字段 dirty/touched、错误摘要、提交快照和未保存离开；本 owner 提供多值字段自己的草稿、校验和 token 级错误。
- `query-filters.md`：负责筛选草稿/已应用边界；多值筛选字段必须同时执行本 owner。
- `members-invitations-access.md`：负责成员、邀请、角色和访问管理业务动作；成员多选控件层同时执行本 owner。
- `permissions-tenancy-visibility.md`：负责无权限、禁用、隐藏、未启用和旧缓存无泄露。
- `overlays-menus-tooltips.md`、`drawers.md` 和 `responsive-adaptive.md`：负责 popup、Action Sheet、Drawer、移动端、虚拟键盘和安全区域承载。

## 可执行审计设计

新增 `docs/testing/multi-select-tag-inputs/multi-select-tag-inputs-audit.rb`，采用现有 Ruby 静态审计模式。

审计需要验证：

1. owner 文件存在，且包含 `multiValueInputState` 与全部状态字段。
2. `SKILL.md` 包含多选 Select、标签输入、标签创建、可创建选项、Token 输入、收件人输入、邮箱标签、成员多选、批量粘贴、删除标签、拖拽排序标签等中英文触发词。
3. `selects-comboboxes.md`、`selection-controls.md`、`query-filters.md` 和 `members-invitations-access.md` 至少声明与本 owner 的相邻关系。
4. `README.md` 与 `HANDOFF.md` 只保留摘要和 owner 链接，不复制完整规则。
5. RED/GREEN 证据覆盖 query 即提交、active 即选中、创建即保存、Backspace 误删、批量粘贴直接提交、重复按标签去重、迟到搜索写入新草稿、无权候选泄露、orphaned invalid 静默清除、移动端删除已选摘要/清空/应用、重复公告和运行时验证伪装已通过。
6. owner 不包含业务项目路径、客户名、具体框架、组件库或服务商例外。

## 验收清单

- 每个多值输入场景声明 `multiValueInputState` 全字段。
- `committedValues`、`draftTokens`、`queryState.activeOption`、`candidateOptions`、创建候选和粘贴候选分开表达。
- query、hover、active option、远程结果、创建候选、粘贴解析和移动端转换不得自动写入已提交值。
- `Enter` 在 active option、创建候选和无效 query 下有确定语义，不得提交任意 query。
- 创建标签不等于字段提交；服务端创建成功不等于表单保存、筛选应用或设置生效。
- Backspace 删除 token 必须两步可感知，且 query 非空时只编辑 query。
- 批量粘贴先预览合法、重复、无效、无权、待创建和冲突项，不得直接提交。
- 重复判断使用稳定业务键和声明的规范化策略，不只比较显示标签。
- 搜索、创建、解析、校验和粘贴确认的迟到结果不能写入新 owner 或新草稿代次。
- 无权或未启用时，搜索、候选、选择、创建、粘贴、删除、清空、重排、提交、快捷键和请求入口为 0。
- orphaned invalid、已删除选项、权限不可见选项和服务端拒绝值不得静默丢失或伪装有效。
- 移动端保留已选摘要、搜索、候选列表、创建入口、粘贴解析、重复/无效项说明、删除 token、清空、应用/取消、字段错误、权限原因、重试、恢复和离开保护。
- 未执行真实浏览器、真实远程搜索、真实创建、真实批量粘贴、键盘、触摸、读屏和移动端视口检查时，必须标为未验证。

## 实施交付物

- 新增 `references/multi-select-tag-inputs.md`。
- 新增 `docs/testing/multi-select-tag-inputs/multi-select-tag-inputs-audit.rb`。
- 新增 RED/GREEN 证据摘要。
- 更新 `SKILL.md` 自动触发路由。
- 更新 `README.md` 使用者摘要和 references 目录。
- 更新 `HANDOFF.md` 已完成规范、结构和后续建议。
- 在 `selects-comboboxes.md`、`selection-controls.md`、`query-filters.md` 和 `members-invitations-access.md` 中补充 owner 关系说明。
- 运行专属 mutation 审计、相邻 owner 审计、全量 owner 审计、Markdown 链接检查和 `git diff --check`。

## 自检结论

本设计聚焦单一 owner：多选、标签输入与 Tokenized Input。它不替代单选 Select、少量固定选择控件、树形多选、表格行选择、成员邀请业务动作或表单/筛选提交 owner，而是定义多值输入自身的草稿、query、候选、创建、粘贴、删除、校验、权限、可访问性和移动端边界。文档没有引入具体业务项目、组件库、框架或服务商例外；真实浏览器、远程搜索、创建、批量粘贴、键盘、触摸、读屏和移动端视口验证明确留到业务实现阶段。
