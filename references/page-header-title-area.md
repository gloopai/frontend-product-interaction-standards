# 页面标题区与 Page Header 交互规范

适用于 Page Header、页面标题区、页面头部、标题栏、页面标题、副标题、对象标题、详情标题、列表标题、设置页标题、报表标题、审批页标题、任务页标题、状态摘要、标题区主操作、标题区次要操作、标题区返回区域、标题区权限说明、标题区刷新状态、移动端标题区、page header、page title、title area、header actions、header primary action、object title、status summary 和 mobile page header。

本文件是页面标题区与 Page Header owner。它负责当前页面身份、标题/副标题、对象上下文、状态摘要、标题区操作槽、导航绑定、权限收敛、焦点公告、移动端压缩和生命周期清理。App Shell、全局导航和外框读取 `references/app-shell-navigation.md`；页面内容区、主内容区、Section/Card 布局、主滚动和 Sticky/fixed 避让读取 `references/page-content-layout-sections.md`；面包屑、返回、URL 和路由来源读取 `references/navigation-routing.md`；标题区按钮本体读取 `references/buttons.md`；页面操作栏和列表工具栏读取 `references/page-toolbars-actions.md`；信息展示和只读字段读取 `references/information-display.md`；权限与无泄露读取 `references/permissions-tenancy-visibility.md`；响应式读取 `references/responsive-adaptive.md`；管理台跨页面治理读取 `references/admin-console.md`。

## 范围与边界

页面标题区不是装饰，也不是 App Shell 的一部分。它是页面级 owner，用来让用户确认“我在哪、正在看谁、当前范围是什么、主要状态是什么、下一步主要动作是什么”。

本 owner 不覆盖全局导航、面包屑路由策略、按钮点击状态、表格工具栏、筛选条件、字段展示、Dialog/Drawer 标题、品牌视觉 token 或业务命名词库。它只定义标题区如何绑定当前页面 owner、权限版本、业务快照和移动端保留策略。

## `pageHeaderState`

每个管理台页面、列表页、详情页、设置页、报表页、审批页、任务页或配置页的标题区必须声明 `pageHeaderState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `headerOwnerId` | 当前页面标题区 owner 的稳定身份。 |
| `headerSurface` | `list-page`、`detail-page`、`settings-page`、`report-page`、`approval-page`、`task-page`、`dashboard-page` 或产品声明的页面类型。 |
| `pageIdentity` | 页面 owner、URL、租户/工作区、权限版本、对象/集合身份和业务范围。 |
| `titleBinding` | 标题文案、对象名、集合名、状态、远程标题来源、加载/失败/无权限标题策略。 |
| `subtitlePolicy` | 副标题、说明、范围摘要、时间范围、数据延迟、来源说明和安全降级策略。 |
| `contextBinding` | 当前筛选、视图、对象版本、审批节点、任务状态、报表范围或其他页面上下文。 |
| `statusSummary` | 主要状态、数量、风险、只读/无权限、刷新中、过期、部分结果和未知结果摘要。 |
| `primaryActionSlot` | 标题区主操作的 owner、动作对象、权限、禁用原因、风险等级和结果转交。 |
| `secondaryActionSlot` | 标题区次要操作、更多菜单、刷新、导出、复制、编辑、审计和帮助入口。 |
| `navigationBinding` | 面包屑、返回、来源恢复、上级路径和路由失败说明的转交关系。 |
| `permissionBoundary` | 标题、对象名、数量、状态、操作、tooltip、ARIA 和 DOM 中可见信息的权限边界。 |
| `responsivePolicy` | 窄屏、移动端、低高度、长标题、200% 缩放、安全区域和折叠策略。 |
| `focusAnnouncementPolicy` | 标题加载、页面切换、权限收敛、主状态变化、失败恢复和移动端压缩后的焦点与公告。 |
| `lifecycleDisposal` | route/unmount、权限变化、租户切换、对象切换、远程标题迟到和断点转换清理。 |
| `runtimeVerification` | 真实浏览器、键盘、读屏、触摸、权限变化、路由切换、移动端和真实视口验证状态；未执行必须标为未验证。 |

不得只用 `title`、`pageTitle`、`breadcrumbTitle`、`document.title`、`headerActions`、组件库 PageHeader 配置、路由 meta 或 App Shell 当前项替代 `pageHeaderState`。

## 标题、上下文和状态摘要

标题区必须绑定当前页面 owner、URL、权限版本和业务范围。标题、对象名、状态、数量、时间范围、租户/工作区和权限说明必须来自同一有效快照；不得混用旧标题和新内容。

| 规则 ID | 规则 |
| --- | --- |
| `PHA-TITLE-01` | 标题必须让用户确认当前页面或对象；无权限时只能展示安全泛化标题，不能泄露旧对象名、数量、字段或内部 ID。 |
| `PHA-TITLE-02` | 远程标题、对象名、数量、状态和副标题必须绑定 `pageIdentity` 与权限版本；迟到响应失配时不得写回。 |
| `PHA-TITLE-03` | 列表、报表和仪表盘标题区若展示范围、筛选、视图、时间范围或数据延迟，必须引用已应用快照，不得读取筛选草稿。 |
| `PHA-STATUS-01` | 状态摘要不能只靠颜色、图标或位置表达；风险、部分成功、未知结果、只读和无权限必须转交对应 owner。 |
| `PHA-STATUS-02` | 加载中、刷新中、过期数据、错误、无权限和空结果不是同一状态，标题区不得只展示一个 loading 或空标题。 |

## 操作槽和导航边界

标题区主操作只能作为入口，必须转交按钮、工具栏、表单、记录编辑、风险操作、审批、导出、异步任务或对应业务 owner；标题区不能直接吞掉动作结果。

| 规则 ID | 规则 |
| --- | --- |
| `PHA-ACTION-01` | 每个页面任务区最多一个标题区主操作；主操作必须声明动作对象、权限版本、禁用原因、风险等级和结果 owner。 |
| `PHA-ACTION-02` | 新增、编辑、导入、导出、审批、危险操作、刷新和更多菜单必须转交对应 owner；标题区只负责入口位置和上下文绑定。 |
| `PHA-ACTION-03` | 标题区操作不得读取旧对象、旧筛选草稿、旧选择范围、旧权限、旧状态摘要或旧远程标题。 |
| `PHA-NAV-01` | 面包屑、返回和路由来源仍归导航 owner；标题区只能展示或转交，不能把返回写成裸 `history.back()`。 |
| `PHA-NAV-02` | 标题区、浏览器 `document.title`、面包屑最后一级、App Shell 当前项和页面主内容必须在权限安全前提下一致；不一致时必须说明或进入恢复。 |

## 权限、安全和生命周期

权限降级、租户/工作区切换、对象切换、路由变化、视图切换、远程标题失败、菜单配置变化或断点转换后，旧标题、旧副标题、旧数量、旧状态、旧操作、旧 tooltip、旧 `document.title`、旧 ARIA label、旧 DOM 和旧焦点目标必须失效或重算。

| 规则 ID | 规则 |
| --- | --- |
| `PHA-PERM-01` | 无权限页面不得通过标题、副标题、状态、数量、图标、操作名、tooltip、ARIA、DOM data 属性或浏览器标题泄露对象、成员、金额、文件名、任务名、审批节点或内部 ID。 |
| `PHA-PERM-02` | 标题区权限待解析时显示安全骨架或泛化标题，不得先渲染旧标题再异步收敛。 |
| `PHA-LIFE-01` | route/unmount 后的远程标题、状态、数量、权限、操作和焦点回调不得写回新页面标题区。 |
| `PHA-A11Y-01` | 页面必须有唯一可感知主标题；标题变化、权限收敛、加载失败和恢复路径由唯一 owner 公告，不得重复播报。 |

## 响应式和移动端

移动端可以压缩标题区、折叠副标题、收纳次要操作或把更多操作放入 Action Sheet / Drawer，但不得删除页面身份、主要状态、权限说明、主操作入口、返回/恢复路径和运行时未验证声明。

| 规则 ID | 规则 |
| --- | --- |
| `PHA-RSP-01` | 长标题、翻译扩展、200% 缩放、系统字体放大、低高度、动态 viewport 和 safe area 下，标题、主要状态、主操作和恢复路径必须可达。 |
| `PHA-RSP-02` | 移动端隐藏副标题、范围摘要或面包屑时，必须保留等价的当前位置、范围说明、上级路径或恢复入口。 |
| `PHA-RSP-03` | 固定 App Shell、固定页头、Sticky 工具栏、Dialog/Drawer 和虚拟键盘不得完全遮挡当前标题、状态摘要、权限说明或主操作。 |

## 完成前检查

1. 是否声明 `pageHeaderState` 及全部字段。
2. 标题、副标题、对象名、状态、数量、时间范围、租户/工作区和权限说明是否来自同一有效快照。
3. 标题区主操作是否只作为入口并转交对应 owner，且声明动作对象、权限版本、禁用原因、风险等级和结果 owner。
4. 面包屑、返回和路由来源是否仍归导航 owner，未被标题区裸 `history.back()` 替代。
5. 权限降级、租户/工作区切换、对象切换、路由变化、视图切换、远程标题失败或断点转换后，旧标题、旧副标题、旧数量、旧状态、旧操作、旧 tooltip、旧 `document.title`、旧 ARIA label、旧 DOM 和旧焦点目标是否失效或重算。
6. 无权限页面是否没有通过标题区泄露对象、成员、金额、文件名、任务名、审批节点或内部 ID。
7. 移动端是否保留页面身份、主要状态、权限说明、主操作入口、返回/恢复路径和未验证边界。
8. 真实浏览器、键盘、读屏、触摸、权限变化、路由切换、租户/工作区切换、移动端和真实视口未实际执行时，是否明确标为未验证并列出所需验证。
