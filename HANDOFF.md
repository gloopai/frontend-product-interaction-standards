# 前端产品交互规范 Skill 交接说明

## 项目定位

这是一个面向 Codex Agent 的中文前端产品交互规范 Skill。它应在创建、修改、重构、评审或测试前端页面、组件和交互行为时自动触发，并将相关规范作为硬性验收条件。

## 项目位置

- Codex 本地 Skill：`/Users/evanqi/.codex/skills/frontend-product-interaction-standards`
- GitHub 仓库：`https://github.com/gloopai/frontend-product-interaction-standards`
- 默认分支：`main`
- 当前状态以本地 `HEAD`、`git status --short` 和与远端的比较为准；本交接不固定记录 SHA。

新建 Codex Project 时，请直接选择本地 Skill 目录，不要选择原业务项目 `/Users/evanqi/code/fex-admin`。

## 当前结构

```text
frontend-product-interaction-standards/
├── SKILL.md
├── README.md
├── agents/openai.yaml
├── docs/
│   └── audits/
│       └── 2026-07-25-existing-standards-hardening.md
└── references/
    ├── admin-console.md
    ├── approval-workflows.md
    ├── audit-log-activity-history.md
    ├── async-jobs-task-center.md
    ├── app-shell-navigation.md
    ├── billing-subscription-invoices.md
    ├── bulk-actions-batch-operations.md
    ├── buttons.md
    ├── card-list-results.md
    ├── chart-visualization-builders.md
    ├── charts-visualization.md
    ├── complex-editors-builders.md
    ├── conditional-fields-dependent-inputs.md
    ├── copy-clipboard.md
    ├── data-tables.md
    ├── date-time-ranges.md
    ├── dialogs.md
    ├── drawers.md
    ├── empty-first-run-zero-results.md
    ├── exports-downloads-artifacts.md
    ├── feedback-states.md
    ├── field-guidance-help-text.md
    ├── files-media-assets.md
    ├── forms.md
    ├── global-feedback.md
    ├── information-display.md
    ├── keyboard-shortcuts-commands.md
    ├── page-form-action-bars.md
    ├── notifications-message-center-announcements.md
    ├── numeric-amount-inputs.md
    ├── ordering-reordering.md
    ├── optimistic-update-undo.md
    ├── text-overflow-truncation.md
    ├── overview-dashboard-pages.md
    ├── page-content-layout-sections.md
    ├── page-header-title-area.md
    ├── navigation-routing.md
    ├── overlays-menus-tooltips.md
    ├── page-toolbars-actions.md
    ├── permissions-tenancy-visibility.md
    ├── preview-pane.md
    ├── query-filters.md
    ├── record-editing-surfaces.md
    ├── risk-actions.md
    ├── row-contextual-actions.md
    ├── responsive-adaptive.md
    ├── saved-views-layout-presets.md
    ├── search-command-palette.md
    ├── settings-preferences-configuration.md
    ├── selection-controls.md
    ├── selects-comboboxes.md
    ├── status-lifecycle-transitions.md
    ├── trash-restore-retention.md
    ├── table-column-layout-density.md
    ├── tree-hierarchy.md
    ├── user-attachment-submission.md
    ├── webhooks-integrations-callbacks.md
    ├── wizards-steppers.md
    └── uploads-imports.md
```

仓库同时包含 `LICENSE`、`CONTRIBUTING.md`、`CODE_OF_CONDUCT.md` 和 `SECURITY.md` 等开源项目文件。

## 已完成规范

### Dialog

- 点击遮罩不得关闭 Dialog。
- 遮罩必须覆盖完整视口。
- 外框不得滚动，仅内容区域滚动；标题、关闭按钮和操作区保持可见。
- 普通可退出 Dialog 必须保留右上角关闭按钮。
- 已定义打开/关闭动画、焦点管理、Escape、焦点陷阱、多层弹窗、异步状态、错误反馈、清理和 reduced motion。
- 普通关闭固定遵循“退出完成 → DOM 移除 → 本实例保护释放 → 恰好一次焦点恢复”；路由变化或卸载走立即 disposal。
- Dialog 内 Select / Combobox / Dropdown popup 必须归属当前模态实例；通过 portal、锚点重算、collision、页脚避让、安全间距、限高和 options 区滚动解决遮挡，不能只靠临时 `z-index`、Dialog 外框滚动、贴住底部操作区或覆盖主要确认按钮。截图型页脚冲突必须记录 trigger、popup、选中高亮行、滚动阴影、底部操作区和安全区域的可视矩形，不能只用“还能点击”判定通过。

### 折叠面板与 Disclosure

- 已定义 Accordion、Collapse、Disclosure、折叠面板、折叠区块、展开收起、错误详情折叠、移动端折叠和嵌套折叠的首版 owner。
- `disclosureAccordionState` 必须声明 `disclosureOwnerId`、`surfaceKind`、`itemRegistry`、`expandedItemIds`、`expansionPolicy`、`contentState`、`requestBinding`、`errorVisibilityBinding`、`permissionBoundary`、`persistenceBinding`、`focusAnnouncementPolicy` 和 `responsivePolicy`。
- 展开状态不等于业务值、不等于表单提交、不等于权限事实。
- 折叠不能隐藏当前必须处理的错误、必填缺失、权限原因或恢复入口。
- 懒加载迟到响应不得写回已收起、卸载、无权限或身份不匹配的 item。
- 移动端不得删除标题、当前展开状态、错误摘要、权限原因、恢复入口和核心操作。
- 详细规则和可执行验收仅维护在 [折叠面板与 Disclosure 交互规范](references/disclosure-accordions.md)，本交接不重复其状态模型或检查项。

### Drawer

- 支持上、下、左、右四个方向。
- 已定义遮罩、关闭路径、滚动区域、焦点、层级、动画、异步状态和响应式规则。
- PC 与移动端核心能力保持一致；低频能力可以折叠，但不能彻底删除。
- 移动端 Bottom Sheet 可以保留左右边距、顶部圆角和安全区域视觉，但最大高度、底部偏移、左右边距和右边距必须基于动态视口与 safe-area 计算，并仍执行完整 Drawer 语义；其内部 Select 若会贴住底部操作区、遮挡确认按钮或被虚拟键盘挤压，应优先转 Select Drawer，任务承载不足时再升级为全屏 Drawer 或独立页。Select Drawer 是独立字段选项层，不得与外层 Bottom Sheet 正文共享滚动容器、滚动位置、滚动阴影或清理责任。
- 从 Drawer 转为非模态形态时，Drawer 专属模态基础设施必须释放；进入 Drawer 时必须由其取得，并且每项只处理一次。
- 普通关闭固定遵循“退出完成 → DOM 移除 → 本实例保护释放 → 恰好一次焦点恢复”；路由变化或 owner 卸载立即执行幂等 disposal。

### PC 与移动端兼容

- 以核心任务和能力一致为原则，不要求像素级一致。
- 对触控、键盘、低高度视口、动态视口、软键盘、安全区域、缩放和布局迁移均有约束。

### 可搜索单选 Select

- 只支持单选，提交值必须来自当前合法选项。
- 使用自绘 Combobox/Listbox 交互，支持键盘和无障碍语义。
- 搜索位置支持 `auto`、`inline`、`panel`、`drawer`、`none`。
- `auto` 必须按照稳定条件确定性解析，不能由 Agent 临时猜测，也不能因过滤结果数量在打开期间跳变。
- PC 可以使用行内输入或非模态面板；受限空间和移动端场景可以使用 Drawer。
- 位于 Dialog/Bottom Sheet 内的 Select popup 必须跟随锚点、滚动、视口、虚拟键盘和上层模态变化重算或安全关闭；关闭/卸载/trigger 移除时同步清理 popup DOM、定位任务和 ARIA 引用。
- `none` 仅使用 Select-only Combobox，不再允许 button + Listbox 的替代模型。
- 已定义草稿查询与已提交值、失效值、异步搜索、状态播报、焦点、Tab、Space/Enter、Home/End 和 ARIA 所有权。
- `resolvedPlacement` 转换保留逻辑 ID；目标焦点和 ARIA 必须在焦点移动前或同一 committed render 更新，来源专属属性随之移除，且转换不提交值或草稿。

### 多选、标签输入与 Tokenized Input

- 已定义多选 Select、标签输入、Tokenized Input、chips input、收件人输入、成员多选、标签创建、自由文本 token、批量粘贴和异步多值检索的首版 owner。
- `multiValueInputState` 必须声明 `multiValueOwnerId`、`valueKind`、`committedValues`、`draftTokens`、`queryState`、`candidateOptions`、`creationPolicy`、`pastePolicy`、`commitPolicy`、`validationState`、`permissionBoundary`、`feedbackBinding` 和 `responsivePolicy`。
- 多值输入不能只维护一个数组；已提交值、当前草稿 tokens、输入 query、active option、候选列表、创建候选和粘贴候选必须分别可观察。
- 创建标签不等于已提交字段；服务端创建成功不等于表单保存、筛选应用或设置生效。
- 移动端不得删除已选摘要、搜索、候选列表、创建入口、粘贴解析、重复/无效项说明、删除 token、清空、应用/取消、字段错误、权限原因、重试、恢复和离开保护。
- 详细规则和可执行验收仅维护在 `references/multi-select-tag-inputs.md`，本交接不重复其状态模型或检查项。

### 关键词搜索输入

- 已定义关键词搜索、搜索输入、搜索框、文本搜索、列表搜索、表格搜索、报表搜索、局部搜索、页面内搜索、筛选搜索、即时搜索、防抖搜索、搜索清空、搜索重置、IME 搜索、搜索建议、搜索历史、最近关键词和搜索 URL 的首版 owner。
- `keywordSearchInputState` 必须声明 `keywordOwnerId`、`surfaceKind`、`inputDraft`、`normalizedDraft`、`committedKeyword`、`compositionState`、`submitPolicy`、`debounceState`、`clearPolicy`、`requestBinding`、`historyBinding`、`permissionBoundary`、`feedbackBinding` 和 `responsivePolicy`。
- 输入草稿不等于已提交关键词；normalizedDraft 不等于 committedKeyword；composition 未结束时 Enter 不得提交。
- 清空草稿、清空已提交关键词、重置默认关键词、取消输入必须是不同意图。
- 移动端不得删除输入、清空、提交、取消/返回、错误说明、权限原因、loading、结果摘要和恢复路径。
- 详细规则和可执行验收仅维护在 `references/keyword-search-inputs.md`，本交接不重复其状态模型或检查项。

### 列表结果控制

- 已定义列表结果、结果控制、结果摘要、分页、页码、游标分页、页大小、排序、刷新、自动刷新、过期数据、数据版本、迟到响应、请求代次和总数不可靠的首版 owner。
- `listResultControlsState` 必须声明 `resultControlsOwnerId`、`surfaceKind`、`appliedQueryBinding`、`querySnapshot`、`requestGeneration`、`requestPhase`、`sortState`、`paginationState`、`refreshState`、`resultSummary`、`selectionImpact`、`urlHistoryBinding`、`permissionBoundary`、`feedbackBinding` 和 `responsivePolicy`。
- 结果控制只能读取已应用查询，不得读取筛选草稿或搜索输入草稿。
- 排序变化、页大小变化和有效筛选/关键词变化必须建立新 `querySnapshot`；迟到响应不得覆盖当前 owner、当前代次或当前快照不匹配的结果。
- 页码分页和游标分页不得在同一快照内混用；总数不可靠时不得展示精确总页数、随机跳页或“全部 N 条”的承诺。
- 移动端不得删除排序、分页、刷新、结果摘要、错误说明、权限原因、过期说明和恢复路径。
- 详细规则和可执行验收仅维护在 [列表结果控制交互规范](references/list-result-controls.md)，本交接不重复其状态模型或检查项。

### 选择控件与开关

- 已定义 Checkbox、Radio Group、Switch、Toggle、Toggle Group、Segmented Control 和三态 checkbox 的首版 owner。
- 草稿/提交分离要求下，`draftValue` 与 `committedValue` 必须分离；hover、focus、active、pressed visual、disabled、indeterminate 和 optimistic preview 不得伪装成已提交业务值。
- 风险转交要求下，危险启停、权限变更、敏感导出、任务取消/重跑、密钥、外部系统影响和不可逆状态必须进入 `risk-actions.md`；确认完成前请求数为 0。
- 三态 checkbox 的 `indeterminateState` 不能作为可提交业务值；移动端不得删除选项、禁用原因、错误说明、保存/取消、恢复路径或当前已选摘要。
- 详细规则和可执行验收仅维护在 [选择控件与开关交互规范](references/selection-controls.md)，本交接不重复其状态模型或检查项。

### 树形结构与级联

- 已定义 Tree、Tree Select、Cascader、组织树、权限树、菜单树、分类树和级联选择的首版 owner。
- 展开、active、hover、filter match、visible descendants、indeterminate、partial loaded 和 optimistic preview 不得伪装成已提交选择。
- 半选只表达派生状态，不是业务提交值；懒加载未完成、过滤后仅展示部分节点、权限未知或存在 disabled 后代时，不能把“全选当前可见”伪装成“全选全部后代”。
- 无权限节点不得泄露节点名称、数量、路径、父子关系、图标、类型、内部 ID、排序位置、子节点是否存在或旧缓存。
- 移动端不得删除搜索、展开、返回上级、路径摘要、已选摘要、清空、应用、错误说明、权限说明或恢复路径。
- 详细规则和可执行验收仅维护在 [树形结构与级联交互规范](references/tree-hierarchy.md)，本交接不重复其状态模型或检查项。

### 异步任务与任务中心

- 已定义 async job、导入导出任务、批量任务、报表生成、AI 生成、同步任务、任务取消、重跑任务和任务中心的首版 owner。
- 覆盖任务身份、进度、取消/重试、未知结果、任务中心恢复、结果产物、权限复核和移动端承载。
- 关闭 Dialog、Drawer、Toast、Notification、来源页面、浏览器 Tab 或移动端系统返回，只能表达客户端关闭或停止等待，不得伪装成服务端任务已取消。
- 取消请求已发送不等于任务已取消；未知结果不得伪装成成功或失败。
- Toast 和 Notification 只能辅助提醒，不能作为唯一状态、唯一错误、唯一下载入口或唯一恢复路径。
- 领取、下载、复制、重试和分享前必须复核任务身份、权限版本、租户/工作区、有效期和请求身份。
- 移动端不得删除任务中心入口、任务状态、进度、取消中、重试、结果领取、错误明细、未知结果说明、权限说明或恢复路径。
- 详细规则和可执行验收仅维护在 [异步任务与任务中心交互规范](references/async-jobs-task-center.md)，本交接不重复其状态模型或检查项。

### 权限、租户与可见性

- 已定义 RBAC、ABAC、角色、能力开关、租户/工作区切换、权限降级、权限升级、隐藏入口、禁用原因、只读、无权限和权限泄露防护的首版 owner。
- 覆盖隐藏/禁用/只读/未启用语义、原子收敛、无泄露、请求绑定和移动端权限恢复。
- 隐藏、禁用、只读、未启用和无权限不是同一件事；未启用表示产品或配置没有启用该能力，DOM、state、handler 和 request 入口均为 0。
- 权限、租户/工作区、角色、认证状态、对象状态、权限版本或资源版本变化后，必须原子重算可见数据、菜单、按钮、表单字段、筛选项、导航、下载、任务入口、确认面板和缓存。
- 旧可见数据、旧菜单、旧按钮、旧确认、旧下载链接、旧任务入口、旧错误明细、旧搜索结果、旧表单草稿、旧图表明细和旧 ARIA label 不得继续暴露。
- 无权限状态不得泄露对象名称、数量、字段、文件名、路径、父子关系、导出范围、错误明细、任务结果、搜索摘要、内部 ID、图标、排序位置、旧缓存或旧可访问名称。
- 移动端不得删除权限说明、只读原因、禁用原因、申请权限、切换租户/工作区、安全占位、重新认证或恢复路径。
- 详细规则和可执行验收仅维护在 [权限、租户与可见性交互规范](references/permissions-tenancy-visibility.md)，本交接不重复其状态模型或检查项。

### 成员、邀请与团队访问管理

- 已定义成员列表、邀请成员、重新发送邀请、撤销邀请、接受/拒绝邀请、邀请过期、角色变更、移除成员、禁用/启用成员、恢复成员、转移 Owner、外部成员和成员审计的 owner。
- 成员状态、邀请状态、角色状态、权限状态和认证状态必须分开表达；待邀请、邀请过期、已撤销、已禁用、已移除、外部成员、需要转移 Owner 和未知结果不得合并成普通状态标签或 Switch。
- 邀请成员必须绑定目标邮箱/账号、租户/工作区、角色、邀请人、有效期、权限版本和审计身份；旧邀请链接、旧邮件入口、旧复制链接、旧 Toast、旧任务入口和浏览器历史在撤销、过期、角色变更、租户/工作区切换、权限变化、会话过期或重复邀请后失效。
- 角色 Select 只能编辑 `roleAssignmentState` 草稿；确认前不得改变已生效角色，确认前请求数为 0。
- 管理员升降级、外部成员权限、跨租户/工作区授权、批量角色变更、影响自身权限或影响最后 Owner 的操作必须进入 `risk-actions.md`，必要时进入 `auth-session-reauth.md`。
- 移除、禁用、启用、恢复、转移 Owner、移除最后管理员、移除自己、禁用自己、批量移除或批量禁用必须进入 `risk-actions.md`；不能用 Switch/Toggle 直接启停成员。
- 权限、会话、账号、身份、租户/工作区、角色版本、成员版本或对象状态变化后，旧成员列表、旧角色 Select、旧邀请链接、旧菜单、旧确认面板、旧 Toast/Notification、旧审计跳转、旧焦点目标和旧 ARIA 引用必须失效或重算。
- 审计和反馈不得向无权限用户泄露成员姓名、邮箱、角色、邀请状态、外部身份、成员是否存在、内部 ID、邀请链接或旧缓存。
- 移动端不得删除邀请成员、成员状态、角色说明、角色变更确认、撤销邀请、重新发送邀请、禁用原因、移除/恢复路径、转移 Owner、审计入口、权限说明和错误恢复。
- 详细规则和可执行验收仅维护在 [成员、邀请与团队访问管理交互规范](references/members-invitations-access.md)，本交接不重复其状态模型或检查项。

### 会话、认证与重新认证

- 已定义登录、登出、会话过期、登录过期、认证失败、重新认证、二次认证、MFA、SSO/MFA callback、账号切换、身份切换和授权回调的 owner。
- 认证状态、权限状态、租户/工作区状态、对象状态、表单脏状态、请求状态和敏感动作意图必须分层表达，不能合并成一个普通 loading/error。
- 登录过期不得直接清空页面并无条件跳登录页；必须冻结或失效不安全请求，保存安全 `returnContext`，清理敏感草稿、旧下载链接、旧任务入口、旧权限菜单和旧确认面板，再提供恢复路径。
- 重新认证不是普通确认 Dialog；挑战完成前敏感请求发送数为 0，完成后只有当前用户、租户/工作区、权限版本、目标状态和幂等键仍匹配时才可恢复动作。
- SSO/MFA callback 必须绑定 `state`、`nonce`、`authOwnerId`、`returnContext`、租户/工作区和过期时间；旧、重复、过期、错误租户和已退出 callback 只能进入安全说明或重新开始。
- 退出登录、账号切换、身份切换和租户/工作区切换后，旧页面数据、菜单、按钮、下载、任务、弹层、消息、焦点和 ARIA 引用原子失效或重算。
- Toast-only、裸 401/403、provider-code-only、灰色按钮、锁图标和 hover-only 都不能作为认证失败或重新认证恢复的唯一说明。
- 移动端不得删除重新登录、重新认证、返回安全页、切换租户/工作区、放弃草稿、重试 callback 和查看原因。
- 详细规则和可执行验收仅维护在 [会话、认证与重新认证交互规范](references/auth-session-reauth.md)，本交接不重复其状态模型或检查项。

### 审计日志与操作历史

- 已定义 audit log、activity log、operation history、event log、change history、timeline、审计日志、操作历史、活动记录、事件日志、变更记录、时间线和追溯链路的首版 owner。
- 覆盖证据身份、主体/目标/动作快照、时间语义、完整性状态、权限无泄露、审计导出复核和移动端追溯。
- 审计记录不是普通列表行，也不是 Toast 成功文案；缺少证据身份的操作历史只能作为普通活动提示，不能写成审计日志。
- 审计日志必须区分事件发生时间、审计写入时间、展示时区、存储时区、筛选范围、数据延迟和刷新时间。
- 无权限审计不得泄露主体名称、目标名称、字段名、旧值、新值、数量、文件名、IP、设备、地理位置、错误明细、内部 ID、请求参数、导出范围、任务结果或旧缓存。
- 审计缺口、延迟、重复、顺序未决、来源不可用和修正记录必须明确说明，不能伪装成完整日志。
- 审计导出、复制、跳转、查看详情、查看关联任务、查看风险回执和追溯链路必须复核权限、租户/工作区、筛选快照、时间范围、敏感字段和请求身份。
- 移动端不得删除筛选、时间范围、时区说明、数据延迟、审计详情、追溯路径、导出权限说明、无权限说明或恢复路径。
- 详细规则和可执行验收仅维护在 [审计日志与操作历史交互规范](references/audit-log-activity-history.md)，本交接不重复其状态模型或检查项。

### 表单

- 已定义字段与表单的状态、校验时机、提交快照、错误归属、失败恢复、未保存更改确认及可访问错误反馈。
- 详细规则和可执行验收仅维护在 [表单状态、校验与错误交互规范](references/forms.md)，本交接不重复其状态模型或检查项。

### 数字、金额、比例与配额输入

- 已定义 `numericInputState`，覆盖数字输入、金额、百分比、比例、费率、数量、排序序号、权重、阈值、配额、额度、余额、预算、时长、容量和单价。
- 数字字段不是普通文本框加 `type=number`；必须分离 `draftText`、`parsedValue` 和 `committedValue`，并声明单位/币种/倍率、精度/舍入、硬软边界、步进、粘贴、IME 和提交快照。
- 空值、0、负数和非法值不是同一件事；金额必须声明币种，百分比必须声明提交倍率，容量/时长/配额必须声明单位和计量周期。
- 无权限不得泄露金额、余额、额度、用量、阈值、单价、套餐限制、历史值、旧 aria-label 或错误明细；移动端不得删除单位、错误、边界说明、保存/取消、恢复或权限说明。
- 详细规则和可执行验收仅维护在 [数字、金额、比例与配额输入交互规范](references/numeric-amount-inputs.md)，本交接不重复其状态模型或检查项。

### 条件字段与依赖输入

- 已定义 `fieldDependencyState`，覆盖条件字段、依赖字段、字段联动、条件显示/隐藏、条件必填、条件禁用/只读、上游字段、下游字段、动态字段、派生字段、计算字段和自动填充。
- 字段联动不是 `if value then show field` 的临时 UI 逻辑；必须声明 `dependencyGraph`、`upstreamSnapshot`、`downstreamPolicy`、`valueRetentionPolicy`、`candidatePolicy` 和 `submitSnapshotPolicy`。
- 隐藏字段的旧值不得静默提交；上游变化后，下游字段必须原子进入保留、清空、失效、重算、禁用、只读或隐藏状态。
- 详细规则和可执行验收维护在 `references/conditional-fields-dependent-inputs.md`。

### 字段说明、帮助文本与占位提示

- 已定义字段 label、字段标题、必填、选填、条件必填、placeholder、帮助文本、辅助说明、单位、格式示例、来源说明、空值说明、权限原因、只读原因、禁用原因和 Tooltip 帮助的首版 owner。
- `fieldGuidanceState` 必须声明 `guidanceOwnerId`、`guidanceSurface`、`fieldIdentity`、`labelPolicy`、`requirementPolicy`、`descriptionPolicy`、`placeholderPolicy`、`helpDisclosurePolicy`、`unitAndFormatPolicy`、`emptyValuePolicy`、`permissionReasonPolicy`、`errorRelationship`、`responsivePolicy`、`lifecycleDisposal` 和 `runtimeVerification`。
- 字段说明不是 Tooltip，也不是 placeholder；placeholder 不能替代 label、默认值、帮助说明、错误说明或空值状态。
- Hover-only 帮助在移动端、触摸、键盘和读屏下必须有等价路径；错误文本不得覆盖帮助文本的唯一含义。
- 详细规则和可执行验收仅维护在 [字段说明、帮助文本与占位提示交互规范](references/field-guidance-help-text.md)，本交接不重复其状态模型或检查项。

### 页面级表单操作栏与保存区

- 已定义页面表单操作栏、表单操作栏、保存栏、保存区、底部操作区、固定保存栏、sticky footer、保存并返回、保存并继续、保存并新建、取消编辑、放弃更改、重置更改、脏状态条和未保存提示条的首版 owner。
- `formActionBarState` 必须声明 `actionBarOwnerId`、`formBinding`、`saveIntentPolicy`、`cancelIntentPolicy`、`buttonPolicy`、`layoutBoundary`、`permissionBoundary`、`feedbackBinding`、`focusReturnPolicy` 和 `responsivePolicy`。
- 保存、提交、应用、确认、取消、返回、关闭、放弃更改、重置、保存并返回、保存并继续和保存并新建必须是不同意图；多个保存入口必须共享同一个 Form owner、同一个 `submitSnapshot`、同一个提交门禁、同一个防重复策略和同一个结果回执。
- sticky / fixed 保存栏必须提供底部避让，最后一个字段、字段错误、帮助文本、错误摘要、上传进度、表格分页、审计回执和恢复入口不得被保存栏遮挡。
- 保存栏 dirty 状态必须来自 Forms owner；取消、返回、关闭、浏览器 Back、Tab 切换、面包屑、菜单导航和外链必须进入 Navigation owner 的同一离开保护。
- 无权或未启用时保存按钮的 DOM、state、handler、request 和快捷键入口为 0；权限、租户/工作区、对象状态、表单版本或会话状态变化后旧保存入口、旧快捷键、旧 loading、旧错误、旧 Toast、旧 focus target 和旧回调必须失效或重新证明安全。
- 移动端不得删除保存、取消/返回、错误摘要、权限原因、脏状态说明和恢复路径；虚拟键盘出现后当前聚焦字段、字段错误、错误摘要、保存按钮、取消/返回、提交中状态和恢复入口仍必须可见或可滚动到达。
- 详细规则和可执行验收仅维护在 [页面级表单操作栏与保存区交互规范](references/page-form-action-bars.md)，本交接不重复其状态模型或检查项。

### 复杂编辑器和构建器

- 已定义复杂编辑器、构建器、富文本编辑器、Markdown 编辑器、代码编辑器、JSON/YAML 编辑器、模板编辑器、规则构建器、流程编排器、节点编辑、画布编辑、字段映射、表达式编辑、报表构建器和 AI 生成配置的首版 owner。
- `editorBuilderState` 必须声明 `editorOwnerId`、`sourceSnapshot`、`draftModel`、`validationState`、`previewState`、`versionPolicy`、`savePolicy`、`publishPolicy`、`importExportPolicy`、`permissionBoundary`、`collaborationPolicy` 和 `responsivePolicy`。
- 草稿、预览、保存、发布、应用、启用、提交审核、回滚、导入、导出和复制必须是不同意图；输入、拖拽、节点连接、格式化、粘贴、AI 生成、导入片段和自动修复只能写入 `draftModel`。
- 复杂编辑器必须校验完整结构，而不是只校验当前可见区域；折叠节点、隐藏面板、未展开分支、不可见字段、禁用节点、孤立节点、断开的边、循环依赖、缺失变量、重复 key、非法表达式、未映射字段、权限不可见引用、旧版本引用和外部资源失效都必须进入 `validationState`。
- 移动端不得删除编辑、预览、校验、保存草稿、发布/提交、错误摘要、错误定位、版本/冲突说明、权限原因、恢复路径和离开保护。
- 详细规则和可执行验收仅维护在 [复杂编辑器和构建器交互规范](references/complex-editors-builders.md)，本交接不重复其状态模型或检查项。

### 数据表格

- 已定义展示、单行操作与批量操作档位下的查询、列、筛选、排序、页码/游标分页、选择、部分成功、响应式、无障碍与生命周期规则。
- 详细规则和可执行验收仅维护在 [数据表格交互规范](references/data-tables.md)，本交接不重复其状态模型或检查项。

### 表格列设置、列布局与密度

- 已定义 `tableColumnLayoutState`，覆盖列设置、列显示、列隐藏、列顺序、列宽调整、固定列、冻结列、列分组、列密度、紧凑模式、舒适模式、重置列、恢复默认列、保存列布局和列配置抽屉。
- 表格列配置不是“把列数组存到 localStorage”；必须分离 `draftLayout`、`appliedLayout` 和 `persistedLayout`。
- 用户隐藏列、权限隐藏列和必显列不是同一件事；无权限列不得出现在列设置、列数量、已隐藏列表、保存视图、导出字段、ARIA、Tooltip、旧布局、URL 或缓存。
- 列顺序、宽度、固定和权限必须基于稳定列 ID；紧凑模式不得删除状态、错误、单位、禁用原因、行操作、选择摘要或恢复入口。
- 详细规则和可执行验收仅维护在 [表格列设置、列布局与密度交互规范](references/table-column-layout-density.md)，本交接不重复其状态模型或检查项。

### 批量操作与批处理动作

- 已定义 `bulkActionState`，覆盖批量操作、批处理动作、当前页批量、全部筛选结果、跨页集合、排除项集合、可执行性、确认、请求身份、部分成功、结果回执、恢复、权限无泄露和移动端承载。
- 批量操作不是“对当前可见行循环单条操作”，也不是“选择数量 + 一个按钮”；批量入口必须冻结 `selectionSnapshot`、`scopeBinding`、`targetIdentitySet`、`eligibilityMap`、`permissionBoundary` 和 `requestIdentity`。
- `partialResult` 必须拆分成功、失败、跳过、冲突、未知和处理中对象范围；Toast 不能作为唯一批量结果，恢复入口和审计/任务/错误明细必须可达。
- 详细规则和可执行验收维护在 `references/bulk-actions-batch-operations.md`。

### 页面操作栏与列表工具栏

- 已定义 page toolbar、action bar、list toolbar、result toolbar、bulk toolbar、view tools、页面操作栏、列表工具栏、结果工具栏、批量操作栏、视图工具、刷新操作、新增操作、列设置、密度和视图切换的首版 owner。
- `toolbarState` 必须声明 `toolbarOwnerId`、`primaryActionPolicy`、`secondaryActionPolicy`、`resultBinding`、`selectionBinding`、`viewToolsPolicy`、`permissionBoundary` 和 `responsivePolicy`，并明确页面主操作、结果绑定、批量操作栏、视图工具、更多菜单、权限收敛和移动端收纳。
- 页面主操作只能有一个 primary owner；新增、创建或导入等主入口不得被埋进无标签更多菜单作为唯一入口。
- 工具栏不得读取筛选草稿、旧结果、旧权限或 Select query；刷新、导出、列设置和视图切换读取当前已提交范围。
- 批量操作栏只有在 Data Table 的 `resolvedTier=bulk-action` 且存在有效选择时才出现；只读报表、row-action 列表、无选择状态或选择失效时不得渲染空批量条。
- 更多菜单、Tooltip、Toast 或浏览器提示不得作为唯一错误恢复、权限原因、主操作入口或导出回执。
- 权限、租户/工作区、能力开关或结果 owner 变化后，工具栏必须原子重算可见操作、禁用原因、批量条、导出入口和视图工具。
- 移动端不得删除新增、刷新、错误恢复、已选摘要、批量入口、导出恢复或主要视图工具；低频工具可进入更多菜单、Action Sheet、Drawer 或独立页，但必须保持可访问名称、分组、范围、禁用原因和焦点返回。
- 详细规则和可执行验收仅维护在 [页面操作栏与列表工具栏交互规范](references/page-toolbars-actions.md)，本交接不重复其状态模型或检查项。

### 保存视图、视图预设与个性化布局

- 已定义保存视图、视图预设、我的视图、个人视图、共享视图、团队视图、默认视图、系统视图、保存筛选、筛选预设、列布局、布局预设、密度预设、恢复默认视图、设为默认视图和视图切换器的首版 owner。
- `savedViewState` 必须声明 `savedViewOwnerId`、`viewIdentity`、`viewScope`、`appliedSnapshot`、`layoutSnapshot`、`draftBinding`、`defaultPolicy`、`sharePolicy`、`applyIntent`、`permissionBoundary`、`resultReceipt`、`auditBinding` 和 `responsivePolicy`。
- 保存视图必须读取 `appliedSnapshot` 和明确允许持久化的 `layoutSnapshot`；筛选草稿、Select query、active option、未提交日期范围、当前页码、展开行、hover、高亮、焦点、loading、错误状态和旧结果缓存不得进入正式保存视图。
- 应用视图必须创建 `applyIntent`，并让 Query Filters、Data Table、Toolbar、URL、结果摘要和焦点读取同一视图版本；旧请求、旧结果、旧 URL、旧导出范围和旧焦点任务必须失效或重算。
- 个人视图、团队共享视图、系统预设、个人默认、团队默认和角色默认必须分开表达；共享视图不得泄露无权限字段、筛选值、对象名称、数量、列名、内部 ID、成员、客户、文件名、金额、发票、密钥、审计字段或旧缓存。
- 覆盖、删除、共享、设默认、取消共享、恢复默认和批量管理视图必须说明影响范围、视图版本、权限版本、请求身份和未知结果；高影响动作进入 `risk-actions.md`，确认前请求数为 0。
- 未知结果不能伪装成已保存、已覆盖、已删除、已共享、已设为默认或已恢复默认，必须提供刷新视图列表、检查当前视图、查看审计、重试或联系支持路径。
- 移动端不得删除视图切换、当前视图说明、保存视图、覆盖视图、恢复默认、权限原因、冲突恢复、错误回执和审计入口；复杂视图管理可以进入 Drawer、Bottom Sheet、Action Sheet 或独立页。
- 详细规则和可执行验收仅维护在 [保存视图、视图预设与个性化布局交互规范](references/saved-views-layout-presets.md)，本交接不重复其状态模型或检查项。

### 查询条件与筛选

- 已定义列表、报表、审计日志、任务中心和管理台记录页的查询条件区 owner。
- `filterDraft` 与 `appliedFilters` 必须分离；字段内部草稿、Select query 和 active option 不得进入结果、URL 或已应用摘要。
- 重置恢复 `defaultFilters`，清空只移除可清空条件；敏感条件不得进入 URL；移动端不得删除筛选、应用、重置/清空、已应用摘要或错误恢复能力。
- 详细规则和可执行验收仅维护在 [查询条件与筛选交互规范](references/query-filters.md)，本交接不重复其状态模型或检查项。

### 搜索与命令面板

- 已定义全局搜索、站内搜索、命令面板、快速跳转、动作搜索、搜索建议、最近/保存搜索、结果分组、命令执行和 AI 搜索边界。
- 搜索草稿、active result、hover suggestion 和最近搜索高亮不得触发导航、命令执行或请求副作用；只有明确提交搜索或激活结果后才能改变导航或执行命令。
- 会修改数据、权限、导出、任务、密钥或外部系统的命令必须进入 `risk-actions.md`；权限无泄露要求下，无权限结果不得泄露对象名称、数量、字段、摘要片段、文件名、内部 ID 或旧缓存。
- 移动端不得删除查询输入、提交、清空、结果分组、错误/权限说明、最近/保存搜索入口或恢复路径。
- 详细规则和可执行验收仅维护在 [搜索与命令面板交互规范](references/search-command-palette.md)，本交接不重复其状态模型或检查项。

### 日期时间与时区

- 已定义日期、时间、日期范围、时间范围、日期时间、快捷范围、相对范围和时区的首版 owner。
- 日期时间值必须声明展示时区、存储/请求时区、边界语义和粒度；不得使用含糊本地字符串，范围推荐使用 `[start, end)`。
- 快捷范围必须冻结应用时的 `relativeAnchor`；报表、导出和审计必须携带范围快照、时区、数据延迟和刷新时间。
- 移动端可以把复杂日期时间 Dialog 转换为 Bottom Drawer、Bottom Sheet 或独立页，但不得删除清空、重置、快捷范围、错误说明或时区说明。
- 详细规则和可执行验收仅维护在 [日期时间与时区交互规范](references/date-time-ranges.md)，本交接不重复其状态模型或检查项。

### 信息展示与详情页

- 已定义详情页、对象详情、信息展示、描述列表、只读字段、信息卡、状态标签、指标卡、元数据和审计摘要的首版 owner。
- 详情页不得直接内嵌 input、textarea、select、可编辑表格或行内保存按钮来完成编辑；只读状态不得用 disabled 表单控件充当展示文本。
- 空值、未配置、未知、加载失败、无权限、已删除和不适用必须可区分；状态标签、颜色、图标和趋势箭头不能是唯一语义来源。
- 指标卡必须声明指标名、口径、单位、时间范围、数据延迟、刷新时间和权限范围；复制、导出、跳转、编辑和危险操作必须绑定当前展示快照与权限版本。
- 移动端不得删除字段 label、单位、状态说明、错误/权限说明、复制/恢复路径或审计入口。
- 详细规则和可执行验收仅维护在 [信息展示与详情页交互规范](references/information-display.md)，本交接不重复其状态模型或检查项。

### 详情预览面板

- 已定义详情预览、侧边预览、预览面板、行预览、记录预览、快速查看、只读预览和 Master-Detail 的首版 owner。
- `previewPaneState` 必须声明 `previewOwnerId`、`surfaceKind`、`sourceBinding`、`activePreviewTarget`、`pendingPreviewIntent`、`previewSnapshot`、`requestBinding`、`permissionBoundary`、`displayBinding`、`actionBoundary`、`urlHistoryBinding`、`focusReturnPolicy`、`responsivePolicy` 和 `runtimeVerification`。
- 预览目标不等于表格选择、不等于 hover、不等于 focus、不等于 active row，也不等于编辑目标。
- 预览面板不得渲染 input、textarea、select、combobox、日期选择器、单元格编辑、行内保存按钮或任何完整字段编辑表单；编辑入口只能转交记录编辑承载面。
- 迟到预览响应只有同时匹配 `previewOwnerId`、owner live、请求代次、预览目标、租户/工作区和权限版本时才可提交。
- 移动端可以把桌面侧边预览转换为底部 Drawer、全屏 Drawer 或独立详情页，但不得删除返回列表、当前预览目标、安全标题、权限原因、错误状态、主要只读信息和恢复入口。
- 详细规则和可执行验收仅维护在 [详情预览面板交互规范](references/preview-pane.md)，本交接不重复其状态模型或检查项。

### 复制与剪贴板操作

- 已定义复制、复制字段、复制值、复制文本、复制 ID、复制编号、复制错误编号、复制链接、复制邀请链接、复制下载链接、复制地址、复制 URL、复制配置、复制片段、复制命令、复制审计字段、复制数据、复制图片、复制脱敏值、复制真实值、剪贴板、系统剪贴板、一键复制和复制失败的通用 owner。
- `copyActionState` 必须声明 `copyOwnerId`、`copyIntent`、`sourceBinding`、`valuePolicy`、`sensitiveBoundary`、`clipboardCapability`、`linkBinding`、`resultReceipt`、`auditBinding`、`focusReturn` 和 `disposalState`。
- 复制必须绑定当前快照；每个业务复制按钮、菜单项或快捷动作都必须创建 `copyIntent`，不得读取旧 DOM、旧缓存、旧请求结果、隐藏字段、旧权限字段、旧下载 URL、旧邀请链接或旧审计详情。
- 复制脱敏值必须明确告诉用户复制的是脱敏值或安全摘要，不能误导用户以为复制了真实值；复制真实值必须由来源 owner 明确允许。
- Toast、Notification、Tooltip、ARIA label、审计摘要和错误说明不得包含真实密钥、token 片段、完整下载 URL、邀请 token、签名材料、payload、无权限字段或可复原敏感内容。
- 复制链接不是权限证明；旧复制链接、旧浏览器历史、旧 Toast/Notification、旧菜单项和旧 DOM 属性必须在权限变化、会话过期、租户/工作区切换、对象删除、任务过期、文件过期、邀请撤销、凭证轮换或链接版本变化后失效或重新证明安全。
- 复制成功只表示写入系统剪贴板成功，不代表用户已经安全保存、链接已经被使用、邀请已经发送、文件已经下载、任务已经完成、字段已经更新或审计已经导出。
- 复制失败不能静默吞掉，必须说明可恢复原因并提供重试、手动选择、下载、Reveal、重新生成、重新认证、查看安全说明或联系支持等适用路径。
- 复制按钮、图标按钮、菜单项和快捷操作必须有动作对象和可访问名称；复制成功、失败、权限拒绝、过期和未知结果必须由唯一 owner 公告。
- 移动端、低高度、虚拟键盘、安全区域、WebView、系统分享面板、系统剪贴板限制和 200% 缩放下，不得删除核心复制入口、复制失败原因、敏感警示、权限说明或替代路径。
- 详细规则和可执行验收仅维护在 [复制与剪贴板操作交互规范](references/copy-clipboard.md)，本交接不重复其状态模型或检查项。

### 密钥、令牌与敏感凭证

- 已定义 API Key、Access Token、Webhook Secret、Client Secret、集成凭证、服务账号、签名密钥、一次性密钥、Reveal、复制、下载、轮换、重置、撤销和泄露恢复的 owner。
- 密钥不是普通只读字段；真实值、脱敏值、一次性值、旧版本、已撤销、过期、泄露和未知状态必须区分。
- 一次性密钥必须在创建前、创建中和创建后说明“一旦离开无法再次查看”，并提供安全保存、复制或下载路径。
- Reveal 必须由明确用户意图触发，绑定 `revealIntent`、`permissionBoundary`、`authBinding`、`credentialVersion` 和过期清理策略；hover、自动聚焦、页面加载、展开详情、复制失败或移动端键盘打开不得自动 Reveal。
- 复制真实密钥必须绑定 `copyIntent`、凭证版本、权限版本、租户/工作区、认证强度和请求身份；Toast/Notification 不得包含真实值或片段。
- 下载凭证必须绑定 `downloadIntent`、凭证版本、文件格式、有效期、权限版本、认证强度、请求身份和审计；旧下载链接在权限、会话、租户、轮换、撤销或过期后失效。
- Rotate、Reset、Revoke、Delete、Disable、Enable 和泄露恢复必须进入 `risk-actions.md`；确认前请求数为 0，不能用 Switch 直接启停密钥。
- 审计记录不得包含真实密钥、完整 token、可复原片段、下载 URL、签名材料或剪贴板内容。
- 移动端不得删除 Reveal、复制、下载、轮换、撤销、过期、审计和恢复路径。
- 详细规则和可执行验收仅维护在 [密钥、令牌与敏感凭证交互规范](references/secrets-credentials.md)，本交接不重复其状态模型或检查项。

### Webhook、集成连接与回调配置

- 已定义 Webhook、集成连接、回调配置、回调 URL、Endpoint、连接测试、测试投递、事件订阅、签名校验、启停/删除、重试投递、事件回放、投递日志和回调日志的 owner。
- Webhook 不是普通设置项；配置草稿、已保存配置、生效配置、外部连接状态、事件订阅状态、投递状态和审计状态必须分开表达。
- 测试成功不等于配置已生效，保存成功不等于外部系统可达，启用成功不等于历史投递已恢复。
- endpoint、事件订阅、环境、租户/工作区、provider 和外部系统身份必须绑定 `configurationVersion`、`integrationIdentity` 和 `permissionBoundary`。
- 测试连接、测试投递、验证签名和事件回放必须绑定 `testDeliveryIntent`，并说明是否会发送真实请求、是否使用样例 payload、是否创建外部记录、是否可重试、是否进入回调日志。
- 启用 Webhook、停用 Webhook、删除 Webhook、重置签名 secret、重试投递、事件回放、批量重试和敏感日志导出必须进入 `risk-actions.md`，确认前请求数为 0；不能用 Switch 直接启停 Webhook。
- 旧 endpoint、旧事件订阅、旧签名 secret、旧测试投递、旧日志入口、旧重试任务、旧复制链接和旧 Toast/Notification 在配置、权限、会话、租户/工作区、环境或外部连接状态变化后必须失效或重算。
- 回调日志、投递日志、错误明细和审计摘要不得泄露无权限 URL、payload、header、签名、token、secret、客户数据、外部系统对象、内部 ID 或旧缓存。
- Toast、Notification、Snackbar 或浏览器提示不能作为唯一保存回执、测试回执、投递结果、日志入口、任务入口、审计入口、错误说明或恢复路径。
- 移动端不得删除 endpoint 状态、事件订阅摘要、测试连接、测试投递、签名校验说明、启停原因、重试/回放、回调日志、错误明细、任务入口、审计入口、权限说明和恢复路径。
- 详细规则和可执行验收仅维护在 [Webhook、集成连接与回调配置交互规范](references/webhooks-integrations-callbacks.md)，本交接不重复其状态模型或检查项。

### 计费、套餐、订阅与发票

- 已定义计费、套餐、订阅、发票、付款方式、支付状态、用量、额度、退款、优惠券、账期、自动续费和账单历史的 owner。
- 计费不是普通设置项；套餐展示状态、确认状态、支付状态、订阅生效状态、权益生效状态、用量状态、发票产物状态和审计状态必须分开表达。
- 付款方式保存成功不等于支付成功，支付成功不等于订阅已生效，订阅已生效不等于所有权益、用量额度、发票和审计都已更新。
- 套餐卡、确认页、支付请求、审计记录和结果回执必须绑定同一个 `pricingSnapshot`。
- 升级、降级、切换账期、应用优惠、购买额度、取消续费或恢复订阅前必须展示当前套餐、目标套餐、账期、生效时间、权益变化、数据保留、额度变化、费用变化和未知结果处理。
- 取消订阅、取消自动续费、降级套餐、删除付款方式、申请退款、撤销退款、清空余额、购买大额额度和高影响账期切换必须进入 `risk-actions.md`，确认前请求数为 0；不能用 Switch 直接取消订阅或切换高影响账期。
- 发票、收据、账单明细、对账单、消费记录和税务资料下载必须执行 `exports-downloads-artifacts.md`，旧发票链接、旧收据链接、旧账单导出任务、旧浏览器历史、旧 Notification、旧复制链接和旧 Toast/Notification 必须失效或重新证明安全。
- 用量、额度、余额、抵扣、试用剩余额度、超额状态和消费记录必须声明计量周期、刷新时间、数据延迟、估算/最终状态、单位、权限范围和适用套餐；用量条不能作为实时额度证明。
- 无权限用户不得通过套餐卡、价格、折扣、税费、发票列表、支付错误、用量条、账单历史、DOM/ARIA、Toast、Notification、下载链接或审计摘要泄露账单主体、付款方式、金额、税号、地址、邮箱、发票编号、内部 ID、支付 provider 对象或旧缓存。
- Toast、Notification、Snackbar 或浏览器提示不能作为唯一支付失败、支付未知、取消订阅、降级、退款、发票生成失败、发票下载失败、用量同步失败、权限拒绝或部分成功恢复路径。
- 移动端不得删除当前套餐、目标套餐、金额、币种、账期、税费/折扣摘要、权益变化、用量口径、额度状态、付款方式状态、支付失败恢复、取消/降级影响范围、发票下载、账单历史、审计入口、权限说明和恢复路径。
- 详细规则和可执行验收仅维护在 [计费、套餐、订阅与发票交互规范](references/billing-subscription-invoices.md)，本交接不重复其状态模型或检查项。

### 通知中心、站内信与公告

- 已定义通知中心、消息中心、站内信、通知、消息、公告、系统公告、运营公告、维护公告、发布公告、未读、已读、全部已读、标记已读/未读、归档通知、删除通知、通知设置、通知偏好、订阅偏好、邮件通知、短信通知、Push 通知、推送通知、通知入口、铃铛、消息角标、通知跳转、通知详情和退订通知的 owner。
- `notificationCenterState` 必须声明 `notificationOwnerId`、`notificationIdentity`、`recipientBoundary`、`messageState`、`deliveryChannelState`、`announcementState`、`clickTargetBinding`、`preferenceState`、`badgeState`、`riskBinding`、`permissionBoundary`、`auditBinding` 和 `resultReceipt`。
- 持久通知不是 Toast；Toast 可以提示“有新消息”，但不能成为唯一消息记录、唯一恢复入口、唯一审计入口或唯一错误说明。
- 通知点击不是普通链接；点击前必须复核权限、目标对象状态、租户/工作区、来源上下文和目标路由是否仍安全。
- 旧通知、旧点击链接、旧邮件入口、旧 Push deep link、旧公告、旧 Toast/Notification 和旧未读角标必须在权限、租户/工作区、对象状态、事件版本、投递版本、偏好版本、会话或渠道状态变化后失效或重算。
- 标记已读不等于归档，归档不等于删除，删除通知不等于删除目标对象，关闭公告不等于已读所有相关消息；未读数必须绑定 `badgeState`。
- 保存偏好成功不等于邮件、短信、Push 或 Webhook 通知真实可达；偏好保存、偏好生效、渠道可达和真实投递结果必须分开表达。
- 系统公告、维护公告、发布公告、运营公告和强制阅读公告必须维护 `announcementState`，公告 Banner、Modal、Drawer 或顶部条不能遮挡 Dialog/Drawer 底部操作、危险确认、表单错误、支付确认、导出下载、任务取消、导航返回或安全区域。
- 无权限用户不得通过通知标题、摘要、图标、未读数、分类、错误、空态、DOM/ARIA、邮件预览、短信文案、Push 文案、下载链接、点击目标或审计摘要泄露对象名称、金额、成员、邮箱、发票编号、文件名、密钥、payload、内部 ID、外部对象或旧缓存。
- 全部已读、批量标记已读/未读、批量归档、删除通知、清空通知、退订通知、恢复订阅和关闭强制公告必须说明范围、数量、分类、权限版本、目标快照、请求身份、结果回执和未知结果处理；高影响动作确认前请求数为 0。
- 未知结果不能伪装成已读成功、归档成功、删除成功、退订成功、公告关闭成功或偏好保存成功。
- 移动端不得删除通知分类、未读/已读状态、未读角标含义、筛选、标记已读/未读、归档、退订/偏好入口、公告详情、点击恢复、权限说明、审计入口和错误恢复路径。
- 详细规则和可执行验收仅维护在 [通知中心、站内信与公告交互规范](references/notifications-message-center-announcements.md)，本交接不重复其状态模型或检查项。

### 图表与可视化

- 已定义图表、可视化、报表图形、趋势图、折线图、柱状图、饼图、散点图、漏斗图、排行图、热力图、图例、坐标轴、tooltip、钻取、联动和导出的首版 owner。
- 每个图表必须声明 `chartState.dataSnapshot` 与 `metricBinding`，并展示或可达地说明指标名、口径、单位、时间范围、时区、数据延迟、刷新时间和权限范围。
- 颜色不得作为唯一语义来源；图表 tooltip 不能承载唯一必读信息；非零基线、截断轴、对数轴、双轴、百分比堆叠和归一化必须显式标注。
- Hover/highlight、legend toggle、drilldown、brush、zoom、联动筛选、导出和查看明细必须在 `interactionPolicy` 中声明；图表必须区分 loading、empty、zero-results、partial、stale、refresh-error、permission-denied 和 metric-unavailable。
- 移动端不得删除图表标题、口径、单位、图例/series 含义、状态说明、错误/权限说明、数据延迟、刷新时间、导出/明细入口和恢复路径。
- 详细规则和可执行验收仅维护在 [图表与可视化交互规范](references/charts-visualization.md)，本交接不重复其状态模型或检查项。

### 概览页与仪表盘首页

- 已定义概览页、仪表盘首页、管理台首页、运营看板、业务看板、指标总览、报表总览和 dashboard landing 的首版 owner。
- `overviewDashboardState` 必须声明 `dashboardOwnerId`、`consoleSurface`、`layoutRegistry`、`globalFilterBinding`、`timeRangeSnapshot`、`dataSnapshot`、`moduleRegistry`、`metricCardsBinding`、`chartBinding`、`detailBinding`、`refreshPolicy`、`alertPriority`、`actionBoundary`、`permissionBoundary`、`feedbackBinding`、`responsivePolicy`、`focusAnnouncementPolicy` 和 `runtimeVerification`。
- 概览页和仪表盘首页默认只读展示；选择、行操作、批量、编辑、订阅、钻取、导出、查看明细和跳转都必须显式声明。
- KPI、图表、明细表、导出任务、页面摘要和刷新状态共享同一业务范围时，必须引用同一 `dataSnapshot`、`timeRangeSnapshot`、权限范围和数据延迟；不同范围必须可见说明。
- 页面布局不能使用营销式 hero 或纯装饰大卡片承载主要工作区。
- 详细规则和可执行验收仅维护在 [概览页与仪表盘首页交互规范](references/overview-dashboard-pages.md)，本交接不重复其状态模型或检查项。

### 图表与可视化创作配置

- 已定义图表创建、图表编辑、可视化配置、报表图表配置、仪表盘图表配置、图表构建器和图表配置向导的首版 owner。
- `chartBuilderState` 必须声明 `chartBuilderOwnerId`、`sourceConfigSnapshot`、`dataSourceBinding`、`metricDraft`、`dimensionDraft`、`encodingDraft`、`interactionDraft`、`filterBindingDraft`、`previewState`、`validationState`、`savePolicy`、`publishPolicy`、`permissionBoundary` 和 `responsivePolicy`。
- 预览成功不等于保存成功；保存成功不等于发布成功；发布请求发送不等于仪表盘或外部嵌入已生效；加入仪表盘请求发送不等于仪表盘已更新。
- 切换图形类型时，不能静默删除不兼容配置；必须展示迁移摘要、待修复项、保留项、丢弃项和撤销/取消路径。
- 保存时不得读取 Select query、active option、筛选草稿、hover 字段、预览高亮、当前可见结果或旧缓存。
- 移动端不得删除数据源说明、指标配置、维度配置、图形类型、预览、完整校验、错误定位、保存草稿、发布/加入仪表盘、权限原因、版本冲突、恢复路径和离开保护。
- 详细规则和可执行验收仅维护在 `references/chart-visualization-builders.md`，本交接不重复其状态模型或检查项。

### 导出、下载与结果产物交付

- 已定义 export、download、artifact、result artifact、file delivery、download link、CSV、Excel、PDF、报表导出、图表导出、审计导出、错误明细下载和文件领取的首版 owner。
- 覆盖范围快照、产物身份、下载意图、权限复核、有效期、敏感字段、旧链接失效、Toast 边界、恢复路径和移动端承载。
- 导出范围不得读取筛选草稿、未提交时间范围、Select query、active option、当前页面可见行或旧缓存。
- 创建导出、生成文件、领取产物和下载文件不得合并成一个含糊状态。
- 下载链接不得被当作权限证明；每次下载必须复核权限、租户/工作区、有效期、请求身份和产物身份。
- 旧 Notification、旧任务入口、旧 URL、旧缓存、旧文件名或旧下载链接不得绕过权限复核。
- Toast、Snackbar、Notification 或浏览器下载提示不得作为唯一下载入口、唯一结果回执、唯一错误说明或唯一恢复路径。
- 敏感导出、审计导出、错误明细下载和跨租户/工作区产物必须说明敏感字段、范围、有效期、权限边界和审计回执。
- 部分成功、未知、过期、无权限和文件不可用不得伪装成成功。
- 移动端不得删除导出范围、文件状态、格式、有效期、权限说明、敏感字段说明、错误明细、重新生成、任务详情、审计入口或恢复路径。
- 详细规则和可执行验收仅维护在 [导出、下载与结果产物交付交互规范](references/exports-downloads-artifacts.md)，本交接不重复其状态模型或检查项。

### 设置、偏好与配置页

- 已定义 settings、preferences、configuration、设置、偏好、配置页、设置页、偏好页、配置项、策略配置、通知设置、集成设置、默认设置、保存设置、重置默认和继承默认的首版 owner。
- `settingsState` 必须声明 `settingsOwnerId`、`settingsScope`、`draftSettings`、`savedSettings`、`effectiveSettings`、`defaultSettings`、`applyMode`、`dirtyState`、`resetPolicy`、`permissionBoundary` 和 `resultReceipt`。
- 设置项必须声明作用域和生效模式；用户偏好、租户配置、工作区配置、项目配置、环境配置、角色配置、对象配置和集成配置不得混用同一含糊状态。
- `draftSettings` 不得伪装成 `effectiveSettings`；显式保存模式下编辑只改变草稿，保存成功和服务端确认后才更新保存值或生效值。
- 保存、取消、恢复保存值、重置默认、继承默认和清空自定义是不同意图，不得都写成“重置默认”。
- 高风险设置必须进入 `risk-actions.md`，保存前请求数为 0；部分成功、失败、冲突和未知结果不得伪装成成功。
- 权限、租户/工作区、角色、对象状态或配置版本变化后，旧草稿、旧默认值、旧禁用原因、旧保存按钮和旧集成状态必须原子收敛。
- 移动端不得删除保存/取消、脏状态、作用域说明、默认值说明、继承说明、危险确认、错误摘要、审计回执或恢复路径。
- 详细规则和可执行验收仅维护在 [设置、偏好与配置页交互规范](references/settings-preferences-configuration.md)，本交接不重复其状态模型或检查项。

### 分步流程与配置向导

- 已定义 Wizard、Stepper、多步骤表单、配置向导、导入向导、发布流程、复核页、保存草稿、恢复草稿、跨步校验和流程结果的首版 owner。
- 每个步骤必须有稳定 ID、标题、进入条件、完成条件和错误归属；上一步、下一步、跳过、直接跳转、保存草稿、取消和完成必须是不同意图。
- `stepDrafts`、`committedStepValues`、`reviewSnapshot` 和 `submitSnapshot` 必须分离；最终提交只能读取仍有效的 `reviewSnapshot` / `submitSnapshot`，不得读取正在编辑的草稿。
- 上游步骤变化后，依赖它的后续步骤、预检、预览、费用、权限、导出范围和确认摘要必须失效或重算；取消客户端流程不等于取消服务端任务。
- 移动端不得删除步骤标题、当前进度、步骤错误、上一步、下一步、保存/放弃草稿、复核页、取消路径、结果回执或恢复入口。
- 详细规则和可执行验收仅维护在 [分步流程与配置向导交互规范](references/wizards-steppers.md)，本交接不重复其状态模型或检查项。

### 导航与路由

- 已定义导航入口、返回、面包屑、Tabs、浏览器历史和路由离开保护的首版 owner。
- 返回不得直接等同于 `history.back()`；必须声明 `sourceContext`、`returnPolicy`、权限版本、dirty blockers 和焦点恢复目标。
- 浏览器 Back/Forward、面包屑、Tabs、菜单导航、关闭容器和外部链接都必须经过同一离开保护管线；移动端不得删除返回、当前位置、未保存保护、权限说明或恢复路径。
- 详细规则和可执行验收仅维护在 [导航与路由交互规范](references/navigation-routing.md)，本交接不重复其状态模型或检查项。

### 页面标题区与 Page Header

- 已定义 Page Header、页面标题区、页面头部、标题栏、页面标题、副标题、对象标题、状态摘要、标题区主操作、标题区次要操作、标题区权限说明和移动端标题区的首版 owner。
- `pageHeaderState` 必须声明 `headerOwnerId`、`headerSurface`、`pageIdentity`、`titleBinding`、`subtitlePolicy`、`contextBinding`、`statusSummary`、`primaryActionSlot`、`secondaryActionSlot`、`navigationBinding`、`permissionBoundary`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification`。
- 页面标题区不是装饰，也不是 App Shell 的一部分；标题、对象名、状态、数量、时间范围、租户/工作区和权限说明必须来自同一有效快照。
- 标题区主操作只能作为入口，必须转交按钮、工具栏、表单、记录编辑、风险操作、审批、导出、异步任务或对应业务 owner。
- 详细规则和可执行验收仅维护在 [页面标题区与 Page Header 交互规范](references/page-header-title-area.md)，本交接不重复其状态模型或检查项。

### 页面内容区与 Section 布局

- 已定义页面内容区、页面正文、主内容区、Section、区块、卡片区块、内容卡片、分栏布局、栅格布局、主滚动、嵌套滚动、Sticky/fixed 避让、内容密度和移动端单列的首版 owner。
- `pageContentLayoutState` 必须声明 `contentOwnerId`、`contentSurface`、`pageBinding`、`sectionRegistry`、`layoutGridPolicy`、`scrollBoundary`、`stickyBoundary`、`densityPolicy`、`contentPriority`、`emptyLoadingErrorBinding`、`ownerHandoff`、`permissionBoundary`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification`。
- 页面内容区不是随意堆卡片，也不是 CSS 网格细节；页面正文必须绑定当前页面 owner、标题区、工具栏、权限版本和主内容区域。
- 每个 Section、Card、分栏、列表区、表单区、图表区和信息区必须有明确 ownerHandoff；主滚动只能有一个可解释 owner。
- 详细规则和可执行验收仅维护在 [页面内容区与 Section 布局交互规范](references/page-content-layout-sections.md)，本交接不重复其状态模型或检查项。

### 管理台 App Shell 与导航外框

- 已定义 App Shell、应用外框、管理台外框、全局导航、侧边导航、顶部导航、主导航、用户菜单、工作区/租户切换、全局搜索入口、通知入口和移动端导航 Drawer 的首版 owner。
- `appShellNavigationState` 必须声明 `shellOwnerId`、`shellSurface`、`navigationRegistry`、`currentNavBinding`、`workspaceTenantBinding`、`globalEntryRegistry`、`userMenuBinding`、`permissionBoundary`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification`。
- App Shell 不是普通页面，也不是一组静态链接；它是跨页面持久 owner，负责全局导航结构、当前项、全局入口、上下文切换和外框级焦点公告。
- 租户、工作区、组织和账号切换不是普通 Select；必须冻结身份、目标范围、权限版本、当前页面、离开 blocker、可恢复目标和失败恢复。
- 详细规则和可执行验收仅维护在 [管理台 App Shell 与导航外框交互规范](references/app-shell-navigation.md)，本交接不重复其状态模型或检查项。

### Tab 视图导航

- 已定义 Tabs、标签页、页签、TabList、TabPanel、当前标签、默认标签、禁用标签、隐藏标签、权限标签、页面内视图切换和移动端标签承载的首版 owner。
- `tabViewState` 必须声明 `tabOwnerId`、`surfaceKind`、`tabRegistry`、`activeTabId`、`pendingTabIntent`、`panelState`、`requestBinding`、`urlHistoryBinding`、`permissionBoundary`、`dirtyBoundary`、`focusAnnouncementPolicy` 和 `responsivePolicy`。
- Tabs 只能用于同一资源或同一任务上下文；激活 tab 不等于提交表单、不等于保存视图、不等于切换租户/工作区。
- 旧 tab 请求不得写回新 active tab 或无权限 panel；Tab 切换必须经过同一未保存保护管线。
- 移动端改变承载形态不得改变 `activeTabId`、URL、权限和 dirty 语义。
- 详细规则和可执行验收仅维护在 [Tab 视图导航交互规范](references/tab-view-navigation.md)，本交接不重复其状态模型或检查项。

### 记录新增/编辑承载面

- 已定义列表、表格、卡片列表、管理列表和报表明细中的新增、编辑、复制创建、配置和批量配置编辑承载面。
- 列表内嵌表单、常驻可编辑列表、单元格编辑、行内保存按钮和 spreadsheet-like 编辑矩阵均被完全禁止；每行直接放 input、textarea、select、排序输入和保存按钮也属于违规。
- 新增/编辑必须按场景进入 Dialog、Drawer 或独立页，并创建独立 `editSurfaceState`，包含来源列表快照、记录身份、权限版本、表单会话、返回策略和验证边界。
- 详细规则和可执行验收仅维护在 [记录新增/编辑承载面交互规范](references/record-editing-surfaces.md)，本交接不重复其状态模型或检查项。

### 排序与重排

- 已定义排序、手动排序、人工排序、调整排序、展示顺序、拖拽排序、重排、上移、下移、置顶、置底、排序模式、保存顺序和顺序冲突的首版 owner。
- `orderingReorderingState` 必须声明 `orderingOwnerId`、`orderingSurface`、`scopeBinding`、`sourceSnapshot`、`itemIdentityMap`、`draftOrder`、`committedOrderSnapshot`、`movementPolicy`、`inputAlternativePolicy`、`submitPolicy`、`conflictPolicy`、`permissionBoundary`、`feedbackBinding`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification`。
- 排序与重排不是列表内编辑，也不是查询排序；列表、表格或卡片中不得常驻排序输入、每行保存按钮或 spreadsheet-like 排序矩阵。
- 拖拽不能是唯一排序方式；当前页局部重排不得伪装成全部结果、全部分组或全局顺序已更新。
- 详细规则和可执行验收仅维护在 [排序与重排交互规范](references/ordering-reordering.md)，本交接不重复其状态模型或检查项。

### 文本溢出与截断

- 已定义文本溢出、文本截断、省略号、line clamp、查看全文、展开全文、复制全文、长文本、长标题、长状态、长错误、长按钮文案、代码、JSON、URL、文件名和路径展示的首版 owner。
- `textOverflowState` 必须声明 `textOwnerId`、`textSurface`、`sourceBinding`、`contentIdentity`、`displayPolicy`、`truncationPolicy`、`fullTextAccessPolicy`、`copyPolicy`、`tooltipPopoverBoundary`、`lineWrapPolicy`、`measurementPolicy`、`permissionBoundary`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification`。
- 文本截断不是内容删除，也不是 hover tooltip 的同义词；省略号、line clamp、max-width、title 属性或 Tooltip 不得作为查看完整内容的唯一方式。
- 被截断内容必须声明 `fullTextAccessPolicy`；重要身份、状态、错误、金额、权限原因、主操作文案和恢复路径不得只显示省略号。
- 详细规则和可执行验收仅维护在 [文本溢出与截断交互规范](references/text-overflow-truncation.md)，本交接不重复其状态模型或检查项。

### 乐观更新、撤销与回滚

- 已定义乐观更新、乐观 UI、先改界面、pending mutation、syncing、撤销、回滚、失败回滚、离线队列、自动重试、迟到响应、幂等和冲突恢复的首版 owner。
- `optimisticMutationState` 必须声明 `mutationOwnerId`、`mutationSurface`、`sourceSnapshot`、`targetIdentity`、`visibleProjection`、`pendingMutation`、`commitSnapshot`、`idempotencyPolicy`、`optimisticPolicy`、`undoPolicy`、`rollbackPolicy`、`reconciliationPolicy`、`permissionBoundary`、`feedbackBinding`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification`。
- 乐观更新不是成功回执；未得到权威确认前必须标记为 pending、syncing、undoable 或 queued，不得绕过确认、权限、审计或服务端权威状态。
- 撤销入口不得只存在于自动消失 Toast；失败回滚必须基于 `sourceSnapshot`、权威刷新或 conflict payload。
- 详细规则和可执行验收仅维护在 [乐观更新、撤销与回滚交互规范](references/optimistic-update-undo.md)，本交接不重复其状态模型或检查项。

### 快捷键与键盘命令

- 已定义快捷键、键盘命令、全局快捷键、页面快捷键、局部快捷键、热键、组合键、访问键、助记键、快捷键帮助、快捷键冲突、输入框快捷键保护、系统快捷键避让和浏览器快捷键避让的首版 owner。
- `keyboardShortcutState` 必须声明 `shortcutOwnerId`、`shortcutSurface`、`scopeBinding`、`commandRegistry`、`keyBindingMap`、`focusContext`、`inputProtectionPolicy`、`conflictPolicy`、`discoverabilityPolicy`、`executionPolicy`、`permissionBoundary`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification`。
- 快捷键不是隐藏按钮，也不是绕过焦点、权限、确认、表单输入或浏览器默认行为的后门；未声明作用域的全局 `keydown` 监听失败。
- 输入框、编辑器、Select 搜索和 IME composition 中页面级快捷键默认不生效；系统、浏览器、输入法、屏幕阅读器和编辑器保留快捷键不得被强行覆盖。
- 详细规则和可执行验收仅维护在 [快捷键与键盘命令交互规范](references/keyboard-shortcuts-commands.md)，本交接不重复其状态模型或检查项。

### 卡片列表与卡片式结果

- 已定义卡片列表、卡片式结果、资源卡片、模板卡片、应用卡片、内容卡片、项目卡片、卡片网格、移动端结果卡片和 Kanban-lite 的首版 owner。
- `cardListResultState` 必须声明 `cardListOwnerId`、`surfaceKind`、`capabilityTier`、`sourceBinding`、`cardIdentityMap`、`fieldMapping`、`interactionZones`、`selectionBinding`、`actionBinding`、`requestBinding`、`permissionBoundary`、`feedbackBinding`、`responsivePolicy`、`focusKeyboardPolicy` 和 `runtimeVerification`。
- 卡片列表不是营销卡片墙；每张卡片必须有记录身份、字段映射、状态文本、权限边界和可访问名称。
- 整张卡片不得包成一个大链接再在内部塞按钮、菜单、checkbox 或复制控件；打开详情区、选择区和操作区必须是独立交互区域。
- 卡片内不得承载新增、编辑、复制创建、单元格编辑、字段保存、行内保存或完整字段表单。
- 详细规则和可执行验收仅维护在 [卡片列表与卡片式结果交互规范](references/card-list-results.md)，本交接不重复其状态模型或检查项。

### 按钮

- 已定义管理台和业务操作按钮的首版 owner。
- 按钮必须具备明确动作语义、文案对象、主次层级、可访问名称、禁用原因、loading 名称、防重复门禁、危险操作确认和响应式可达性。
- 图标按钮、更多菜单、批量按钮、导出按钮和任务按钮均需保留动作对象、权限边界、请求身份和结果 owner。
- 详细规则和可执行验收仅维护在 [按钮交互规范](references/buttons.md)，本交接不重复其状态模型或检查项。

### 行操作与上下文操作

- 已定义 `rowActionState`，覆盖行操作、记录操作、上下文操作、更多菜单、卡片操作、操作列、右键菜单、长按菜单、单条删除/编辑/停用/启用/归档/恢复等单条记录动作。
- 行操作不是“在当前行 DOM 上挂一个按钮”；动作必须冻结 `recordIdentity`、`sourceSnapshot`、权限版本和状态版本，不得读取 hover row、active row、虚拟行 DOM、旧 record 或 rowIndex。
- 虚拟行复用、分页、筛选、排序、自动刷新和权限变化后，旧菜单不能操作新记录；Toast 不能作为唯一结果、错误、审计或恢复路径。
- 详细规则和可执行验收维护在 `references/row-contextual-actions.md`。

### 浮层菜单与提示

- 已定义 Tooltip、Popover、Dropdown Menu、Context Menu、更多菜单、Action Sheet 和移动端菜单 Drawer 的首版 owner。
- 重要信息不得仅依赖 Hover、Tooltip、Popover 临时可见状态或 Context Menu；Tooltip / Popover 不得承载唯一必读权限原因、错误、确认后果、危险操作、结果回执、审计凭证或恢复入口。
- 菜单项必须有动作对象、权限状态、可访问名称、禁用原因、请求身份和结果 owner；危险菜单项必须进入 `risk-actions.md`。
- 非模态浮层不得被父容器、滚动区、固定列、固定页脚、`overflow` 或 `transform` 裁切；移动端 hover-only 内容必须有触摸和键盘等价路径。
- 详细规则和可执行验收仅维护在 [浮层菜单与提示交互规范](references/overlays-menus-tooltips.md)，本交接不重复其状态模型或检查项。

### 危险操作与恢复

- 已定义危险操作、风险操作、二次确认、输入确认、撤销、取消、未知结果、部分成功和审计回执的首版 owner。
- 危险操作不得只靠颜色表达风险；二次确认不得只有“确定 / 取消”；未满足 `confirmationPolicy` 前请求数必须为 0。
- 已发送请求不得因为关闭确认、Escape、路由离开、客户端取消或 Toast 消失而写成“已取消”；未知结果不得伪装成成功或失败。
- 批量危险操作必须冻结选择快照、筛选快照、权限版本、目标数量、目标摘要和影响范围；移动端不得删除危险确认、撤销/恢复入口、未知结果说明或审计回执。
- 详细规则和可执行验收仅维护在 [危险操作与恢复交互规范](references/risk-actions.md)，本交接不重复其状态模型或检查项。

### 回收站、软删除、归档恢复与保留期

- 已定义 `trashRestoreState`，覆盖删除后恢复、软删除、回收站、垃圾箱、已删除列表、已归档列表、恢复记录、撤销删除、永久删除、清空回收站、保留期、到期清理、法律保留、删除审计和恢复审计。
- 删除不是一个按钮点击，也不是一个 Toast；soft delete、archive、disable、restore、permanent delete、purge、retention expired 和 legal hold 必须区分。
- 承诺可恢复时，恢复入口不能只存在于 Toast、旧列表行或浏览器历史；保留期必须展示绝对时间、时区、起算点、规则来源和到期动作。
- 删除后旧列表、详情、预览、下载、复制、菜单、批量选择、导出、搜索、URL、ARIA 和焦点目标必须失效或重算；无权限不得泄露已删除对象名称、数量、字段、文件名、路径、删除原因、操作者、删除时间、保留期、内部 ID 或旧缓存。
- 详细规则和可执行验收仅维护在 [回收站、软删除、归档恢复与保留期交互规范](references/trash-restore-retention.md)，本交接不重复其状态模型或检查项。

### 审批与审核工作流

- 已定义审批、审核、提交审批、撤回审批、通过、驳回、转交、加签、委托、催办、会签、串签、待办审批和批量审批的首版 owner。
- `approvalWorkflowState` 必须声明 `workflowInstanceId`、`approvalSurface`、`approvalObjectSnapshot`、`currentStepBinding`、`approverBinding`、`decisionIntent`、`commentPolicy`、`attachmentPolicy`、`assignmentPolicy`、`delegationPolicy`、`batchApprovalSnapshot`、`notificationBinding`、`auditBinding`、`permissionBoundary`、`feedbackState`、`responsivePolicy` 和 `runtimeVerification`。
- 审批动作不是普通状态按钮；提交审批、通过、驳回、撤回、转交、加签、委托、催办和批量审批都必须冻结审批对象、节点、权限、意见/附件和请求身份。
- 通知只提示待办、催办或结果，不能替代当前审批状态、审批历史、审计回执或恢复入口。
- 详细规则和可执行验收仅维护在 [审批与审核工作流交互规范](references/approval-workflows.md)，本交接不重复其状态模型或检查项。

### 状态流转与记录生命周期

- 已定义 status lifecycle、status transition、record lifecycle、state machine、发布/下线、审批/驳回、启停、归档/恢复、冻结/解冻、锁定/解锁的首版 owner。
- 覆盖状态模型、转换意图、版本快照、结果状态、冲突恢复、权限无泄露、审计回执、批量快照和移动端承载。
- 状态 badge、按钮 loading、乐观 UI、Toast 文案或本地缓存不得伪装成已完成状态流转。
- 状态展示和状态变更不得共用一个含糊 status 字段。
- 没有冻结对象版本、权限版本、当前状态、目标状态、租户/工作区和请求身份，不得提交状态变更。
- 版本冲突、权限变化、租户切换、对象删除、状态已变化或业务限制变化时，旧意图必须失效。
- transitionResult 必须区分 success、failure、partial-success、conflict、stale、unknown、queued、processing 和 cancelled-client-only。
- 无权限状态流转不得泄露当前状态、下一步动作、不可见原因、对象数量、批量影响范围、审批意见、拒绝原因、内部状态码、任务结果或旧缓存。
- 批量状态变更不得用当前页面可见行替代选择快照、筛选快照、权限版本和目标摘要。
- 移动端不得删除当前状态、状态原因、可用动作、禁用原因、确认、结果回执、审计入口或恢复路径。
- 详细规则和可执行验收仅维护在 [状态流转与记录生命周期交互规范](references/status-lifecycle-transitions.md)，本交接不重复其状态模型或检查项。

### 上传与导入

- 已定义普通上传、表单内上传和结构化导入的首版 owner。
- 文件选择、拖拽、本地校验、上传队列、进度、取消、重试、导入预检、字段映射、部分成功、错误明细和下载权限复核均有独立状态与验收。
- 浏览器 `accept` 只能作为选择器提示，客户端取消不等于服务端取消，部分成功不能只靠 Toast，错误明细下载必须复核权限和任务身份。
- 详细规则和可执行验收仅维护在 [上传与导入交互规范](references/uploads-imports.md)，本交接不重复其状态模型或检查项。

### 文件与媒体资产管理

- 已定义文件管理、文件库、附件管理、媒体资产、素材库、在线预览、缩略图、图片裁剪、音视频转码、替换文件、资产版本、发布/下架、分享链接、删除恢复和使用关系的首版 owner。
- `assetState` 必须声明 `assetOwnerId`、`assetIdentity`、`assetLifecycle`、`variantState`、`previewPolicy`、`downloadPolicy`、`sharePolicy`、`editPolicy`、`publishPolicy`、`usageBinding`、`permissionBoundary`、`retentionPolicy`、`feedbackBinding` 和 `responsivePolicy`。
- 上传完成、资产入库、扫描完成、转码完成、缩略图生成完成、预览可用、下载可用、发布可用、CDN 生效和分享链接可用必须是不同状态。
- 缩略图、预览图、播放器 poster、PDF 首页图、波形图和已缓存媒体片段不能作为权限证明；旧预览 URL、旧下载 URL、旧分享链接、旧 CDN 地址、旧缩略图、旧播放器状态、旧复制内容、旧焦点目标和旧 ARIA 引用必须失效或重新证明安全。
- 移动端不得删除预览、下载、替换、删除/恢复、转码状态、权限原因、分享管理、使用关系、版本说明、错误恢复和审计入口。
- 详细规则和可执行验收仅维护在 `references/files-media-assets.md`，本交接不重复其状态模型或检查项。

### 用户侧附件与内容提交上传

- 已定义头像上传、评论附件、聊天附件、消息附件、工单附件、反馈附件、内容投稿附件、移动端拍照/录音/录像、发送前预览、发送后附件引用和附件草稿恢复的首版 owner。
- `attachmentSubmissionState` 必须声明 `attachmentSubmissionOwnerId`、`contentDraftBinding`、`inputSourcePolicy`、`localAttachmentDrafts`、`uploadBinding`、`submitSnapshot`、`sendPolicy`、`postSubmitState`、`revisionPolicy`、`permissionBoundary`、`feedbackBinding` 和 `responsivePolicy`。
- 上传成功只能说明文件引用可用于当前提交候选；不能自动说明消息已发送、评论已发布、头像已生效、内容已审核通过或资产已入库。
- 发送按钮不得只读取“是否有本地文件名”；必须绑定文本草稿、附件草稿、上传状态、必填规则、权限、会话、内容版本和提交策略。
- 移动端不得删除相机、相册、文件选择、录音录像、附件预览、文件级错误、上传进度、删除/替换、重试、发送状态、离开保护、权限原因、失败恢复和已发送附件状态。
- 详细规则和可执行验收仅维护在 `references/user-attachment-submission.md`，本交接不重复其状态模型或检查项。

### 反馈状态与状态承载

- 已定义页面/区域级 loading、skeleton、empty、zero-results、error、refresh-error、stale、permission、partial 和 recovery 的首版 owner。
- 反馈状态不得只散落在 `loading`、`error`、`empty` 三个布尔值里；首次加载与刷新失败必须区分，刷新失败保留旧内容并标记 stale。
- 空状态不能用“暂无数据”糊住所有情况；Toast 不能作为唯一错误或结果回执；无权状态不得泄露对象名称、数量、字段、文件名、筛选值或错误明细。
- 详细规则和可执行验收仅维护在 [反馈状态与状态承载规范](references/feedback-states.md)，本交接不重复其状态模型或检查项。

### 空态、无结果与首次使用引导

- 已定义 `emptyStateDecision`，覆盖空态、无结果、首次使用、初始化空态、未配置空态、只读报表空态、权限空态、错误空态、归档空态和 empty CTA。
- 空状态不是“没有数据”的单一文案；必须区分 firstRunEmpty、trueEmpty、zeroResults、permissionEmpty、errorEmpty、loadingEmpty、archivedEmpty、notConfiguredEmpty 和 readOnlyEmpty。
- zeroResults 优先清空筛选、调整关键词、重置时间范围或返回默认视图；创建入口不得出现在只读报表、权限不足、能力未启用、不可写范围或筛选无结果但真实数据范围未知的场景。
- 详细规则和可执行验收维护在 `references/empty-first-run-zero-results.md`。

### 全局反馈与通知

- 已定义 Toast、Snackbar、Message、Alert、Banner、Notification 和 Inline Feedback 的首版 owner。
- 全局反馈不得降级为 `showToast(text)`；每条业务结果消息必须有 `feedbackMessageState`、`sourceOwner`、`resultBinding`、去重键、敏感边界和恢复策略。
- 危险操作、部分成功、未知结果、权限失败、导入导出任务、长耗时任务和需要恢复的错误不能只用 Toast 作为唯一回执。
- 详细规则和可执行验收仅维护在 [全局反馈与通知交互规范](references/global-feedback.md)，本交接不重复其状态模型或检查项。

### 管理台完整治理

- 已定义后台、管理台、控制台、SaaS console 和内部工具的跨页面 owner。
- 报表和仪表盘默认只读展示；选择、行操作、批量、导出和钻取均需显式声明。
- 权限、租户/工作区、危险操作、审计、导入导出、异步任务、全局反馈和移动端折叠均有页面级约束。
- 详细规则和可执行验收仅维护在 [管理台完整治理交互规范](references/admin-console.md)，本交接不重复其状态模型或检查项。

### 响应式 closing

- 进入 closing 后冻结当前渲染形态，忽略后续断点转换；只能执行一次专项退出动画、卸载和清理，并持续保持保护直到该流程完成。

详细的 F-01 至 F-07 加固账本、交叉矩阵、静态场景重放和验证边界见 [现有规范加固最终审计账本](docs/audits/2026-07-25-existing-standards-hardening.md)。本交接仅摘要已完成保证，不复制该账本。

## 已确认的设计原则

1. 核心能力跨端一致，低频能力可以折叠但不能删除。
2. 搜索位置按场景灵活处理，但必须通过明确配置或确定性 `auto` 规则得出。
3. 选择必须显式提交；关闭、取消或模式切换不得静默改变已提交值。
4. 组件库默认行为与规范冲突时，应配置、封装或替换组件，而不是降低规范。
5. 实现完成后必须逐项验证相关交互、键盘、无障碍和视口；未实际验证的项目必须明确报告。

## 与原业务项目的关系

原业务项目位于 `/Users/evanqi/code/fex-admin`。该项目的 `AGENTS.md` 已保留 Dialog 和可搜索单选 Select 的关键兜底约束，供未成功加载 Skill 的 Agent 使用。

规范仓库和业务仓库应独立维护：

- 通用规则修改在 Skill 仓库完成并发布。
- 业务实现修改在具体业务仓库完成。
- 只有确实需要离线兜底的关键约束才同步到业务项目的 `AGENTS.md`，避免两份完整规范长期漂移。

业务项目强制接入应使用通用接入材料：

- [项目 AGENTS.md 接入片段](docs/adoption/project-agents-snippet.md)
- [项目接入检查清单](docs/adoption/checklist.md)

这些文档只提供项目级加载门禁；具体业务项目的技术栈、目录、运行命令和例外仍留在各自业务仓库，不反向写入通用 Skill。

## 后续建议

当前高频管理台与用户侧附件规范已形成首轮覆盖。继续扩展时，优先选择使用频率高、容易误把状态或权限边界合并的交互 owner。

每次新增规范时，应同步检查：

- `SKILL.md` 是否有准确的自动触发关键词和参考文件路由。
- 详细规则是否只保存在对应 `references/*.md`，避免与 README 重复。
- `README.md` 是否只保留面向使用者的摘要、安装和贡献说明。
- `agents/openai.yaml` 是否仍与 Skill 定位一致。
- `docs/adoption/` 是否仍保持项目无关，并且没有复制业务项目专属例外。
- 新规则是否有明确的状态模型、键盘交互、ARIA、跨端行为和验收清单。
- 修改是否已提交并推送到公开仓库，Codex 本地 Skill 是否与 `origin/main` 一致。

## 新 Project 的建议开场指令

切换后可以直接发送：

> 请先阅读 `HANDOFF.md`、`SKILL.md`、`README.md` 和现有 `references/`，确认仓库状态与远端 `main` 一致。之后继续维护“前端产品交互规范” Skill；新增规范时保持中文、自动触发、跨端核心能力一致，并在提交前完成独立评审和验证。

## 当前验证状态

- Ruby 结构化审计、Markdown 相对链接检查和 `git diff --check` 等本地文档静态检查已通过；当前管理台审计包含 42 个负向变异和 3 个否定语义正向对照。官方 `quick_validate.py` 未完成校验：运行环境缺少 PyYAML，解释器在导入阶段报 `ModuleNotFoundError: No module named 'yaml'`；未安装依赖，不得记为通过。
- 已完成 Base→Head 完整差异审查、独立 RED/GREEN 应用检查及最终复审；静态修订、账本和证据边界见上述审计链接。
- `docs/` 已允许纳入 Git；当前提交与推送状态应以本地 `HEAD`、`git status --short` 及与远端的比较为准。
- 本轮属于规范文档工作；浏览器、屏幕阅读器、触控设备和真实业务组件测试均未执行，需在具体组件实现时完成。
