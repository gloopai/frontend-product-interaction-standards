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
    ├── audit-log-activity-history.md
    ├── async-jobs-task-center.md
    ├── billing-subscription-invoices.md
    ├── buttons.md
    ├── charts-visualization.md
    ├── data-tables.md
    ├── date-time-ranges.md
    ├── dialogs.md
    ├── drawers.md
    ├── exports-downloads-artifacts.md
    ├── feedback-states.md
    ├── forms.md
    ├── global-feedback.md
    ├── information-display.md
    ├── navigation-routing.md
    ├── overlays-menus-tooltips.md
    ├── page-toolbars-actions.md
    ├── permissions-tenancy-visibility.md
    ├── query-filters.md
    ├── record-editing-surfaces.md
    ├── risk-actions.md
    ├── responsive-adaptive.md
    ├── search-command-palette.md
    ├── settings-preferences-configuration.md
    ├── selection-controls.md
    ├── selects-comboboxes.md
    ├── status-lifecycle-transitions.md
    ├── tree-hierarchy.md
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

### 数据表格

- 已定义展示、单行操作与批量操作档位下的查询、列、筛选、排序、页码/游标分页、选择、部分成功、响应式、无障碍与生命周期规则。
- 详细规则和可执行验收仅维护在 [数据表格交互规范](references/data-tables.md)，本交接不重复其状态模型或检查项。

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

### 图表与可视化

- 已定义图表、可视化、报表图形、趋势图、折线图、柱状图、饼图、散点图、漏斗图、排行图、热力图、图例、坐标轴、tooltip、钻取、联动和导出的首版 owner。
- 每个图表必须声明 `chartState.dataSnapshot` 与 `metricBinding`，并展示或可达地说明指标名、口径、单位、时间范围、时区、数据延迟、刷新时间和权限范围。
- 颜色不得作为唯一语义来源；图表 tooltip 不能承载唯一必读信息；非零基线、截断轴、对数轴、双轴、百分比堆叠和归一化必须显式标注。
- Hover/highlight、legend toggle、drilldown、brush、zoom、联动筛选、导出和查看明细必须在 `interactionPolicy` 中声明；图表必须区分 loading、empty、zero-results、partial、stale、refresh-error、permission-denied 和 metric-unavailable。
- 移动端不得删除图表标题、口径、单位、图例/series 含义、状态说明、错误/权限说明、数据延迟、刷新时间、导出/明细入口和恢复路径。
- 详细规则和可执行验收仅维护在 [图表与可视化交互规范](references/charts-visualization.md)，本交接不重复其状态模型或检查项。

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

### 记录新增/编辑承载面

- 已定义列表、表格、卡片列表、管理列表和报表明细中的新增、编辑、复制创建、配置和批量配置编辑承载面。
- 列表内嵌表单、常驻可编辑列表、单元格编辑、行内保存按钮和 spreadsheet-like 编辑矩阵均被完全禁止；每行直接放 input、textarea、select、排序输入和保存按钮也属于违规。
- 新增/编辑必须按场景进入 Dialog、Drawer 或独立页，并创建独立 `editSurfaceState`，包含来源列表快照、记录身份、权限版本、表单会话、返回策略和验证边界。
- 详细规则和可执行验收仅维护在 [记录新增/编辑承载面交互规范](references/record-editing-surfaces.md)，本交接不重复其状态模型或检查项。

### 按钮

- 已定义管理台和业务操作按钮的首版 owner。
- 按钮必须具备明确动作语义、文案对象、主次层级、可访问名称、禁用原因、loading 名称、防重复门禁、危险操作确认和响应式可达性。
- 图标按钮、更多菜单、批量按钮、导出按钮和任务按钮均需保留动作对象、权限边界、请求身份和结果 owner。
- 详细规则和可执行验收仅维护在 [按钮交互规范](references/buttons.md)，本交接不重复其状态模型或检查项。

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

### 反馈状态与状态承载

- 已定义页面/区域级 loading、skeleton、empty、zero-results、error、refresh-error、stale、permission、partial 和 recovery 的首版 owner。
- 反馈状态不得只散落在 `loading`、`error`、`empty` 三个布尔值里；首次加载与刷新失败必须区分，刷新失败保留旧内容并标记 stale。
- 空状态不能用“暂无数据”糊住所有情况；Toast 不能作为唯一错误或结果回执；无权状态不得泄露对象名称、数量、字段、文件名、筛选值或错误明细。
- 详细规则和可执行验收仅维护在 [反馈状态与状态承载规范](references/feedback-states.md)，本交接不重复其状态模型或检查项。

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

建议按优先级继续增加：

1. 超出管理台范围的上传能力。
2. 复杂编辑器和构建器。
3. 图表与可视化创作。
4. 文件与媒体管理。

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
