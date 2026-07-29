# 权限、租户与可见性交互规范

适用于 permission、permissions、role、RBAC、ABAC、tenant、workspace、权限、角色、权限矩阵、能力开关、租户、工作区、权限降级、权限升级、权限版本、无权限、只读、隐藏入口、禁用原因、申请权限、可见性、权限泄露、旧缓存、旧菜单和旧下载链接。本文件是权限解析、租户/工作区切换、可见性语义、权限收敛、无泄露、请求绑定、可访问性和验收的唯一事实来源。

批量操作、批处理动作、全部筛选结果操作、跨页批量、批量结果回执和批量错误明细必须同时执行 `references/bulk-actions-batch-operations.md`。权限 owner 负责权限、租户/工作区、能力矩阵、无泄露和旧缓存收敛；批量 owner 负责 `bulkActionState`、targetIdentitySet、eligibilityMap、permissionBoundary、resultReceipt 和 recoveryActions。

权限空态、无权限无结果、只读空态、能力未启用空态和租户/工作区切换后的空态必须同时执行 `references/empty-first-run-zero-results.md`。权限 owner 负责权限解析、无泄露和旧缓存收敛；空态 owner 负责 `emptyStateDecision`、permissionBoundary、capabilityPolicy、CTA 可见性和恢复路径。

按钮入口、禁用、loading 和动作对象继续执行 [按钮交互规范](buttons.md)。表格行、列、选择、批量和跨页范围继续执行 [数据表格交互规范](data-tables.md)。字段、表单错误和未保存离开继续执行 [表单状态、校验与错误交互规范](forms.md)。字段 label、placeholder、帮助文本、空值说明、权限原因、只读原因和禁用原因必须同时执行 `references/field-guidance-help-text.md`；权限 owner 负责证明说明文案无泄露，`field-guidance-help-text.md` 负责说明身份、可访问描述和旧引用清理。Page Header、页面标题区、页面标题、副标题、对象标题、状态摘要、标题区主操作、标题区权限说明和浏览器标题必须同时执行 `references/page-header-title-area.md`；权限 owner 负责证明标题区无泄露，`page-header-title-area.md` 负责标题快照、操作槽和旧标题/旧 DOM/ARIA 引用收敛。导航、返回和路由恢复继续执行 [导航与路由交互规范](navigation-routing.md)。App Shell、全局导航、侧边导航、顶部导航、用户菜单、工作区/租户切换、全局搜索入口和通知入口必须同时执行 `references/app-shell-navigation.md`；权限 owner 负责证明入口和标签安全，`app-shell-navigation.md` 负责外框级菜单、入口、badge、快捷键和旧 DOM/ARIA 引用收敛。页面内 tab 可见性、禁用、隐藏、无权限、安全占位和旧 panel 清理必须同时执行 `references/tab-view-navigation.md`，并按本文件证明权限、租户/工作区和旧缓存无泄露。异步任务、下载产物和任务中心继续执行 [异步任务与任务中心交互规范](async-jobs-task-center.md)。上传、导入、模板和错误明细继续执行 [上传与导入交互规范](uploads-imports.md)。风险确认、权限变更和敏感导出继续执行 [危险操作与恢复交互规范](risk-actions.md)。Toast、Notification 和页面消息继续执行 [全局反馈与通知交互规范](global-feedback.md)。管理台跨页面治理继续执行 [管理台完整治理交互规范](admin-console.md)。

折叠标题、摘要、数量、图标、展开状态、旧内容和子项关系必须同时执行 `references/disclosure-accordions.md`；无权限或未启用时不得通过收起标题、旧摘要、旧 ARIA label 或旧缓存泄露内部对象。

详情预览、侧边预览、行预览、记录预览、快速查看、只读预览和 Master-Detail 必须同时执行 `references/preview-pane.md`；权限 owner 负责证明预览目标、字段、标题、数量、文件名、内部 ID、复制内容、错误明细和旧缓存安全，`preview-pane.md` 负责在预览切换、关闭、迟到响应和移动端转换中应用这些权限边界。

卡片列表、卡片式结果、资源卡片、模板卡片、应用卡片、项目卡片、卡片网格、移动端结果卡片和 Kanban-lite 必须同时执行 `references/card-list-results.md`；权限 owner 负责证明卡片标题、封面、缩略图、标签、状态、数量、文件名、菜单项、错误、复制内容和旧 ARIA label 安全，`card-list-results.md` 负责卡片 owner 中的无泄露应用和旧状态清理。

乐观更新、先改界面、撤销、回滚、自动重试、离线队列、迟到响应和 pending mutation 必须同时执行 `references/optimistic-update-undo.md`；权限 owner 负责权限、租户/工作区、角色、能力和旧缓存的无泄露证明，`optimistic-update-undo.md` 负责旧乐观投影、旧撤销入口、旧回滚依据、旧成功提示和旧回调的失效或重算。

概览页、仪表盘首页、管理台首页、运营看板、业务看板、指标总览、报表总览和 dashboard landing 必须同时执行 `references/overview-dashboard-pages.md`；权限 owner 负责证明 KPI 名称和值、图表 series、明细数量、导出范围、告警标题、菜单项和旧 ARIA label 安全，`overview-dashboard-pages.md` 负责页面级模块收敛和旧快照清理。

审批对象、审批人、代理人、审批意见、审批附件、审批节点、待办、通知和审批历史的权限边界必须同时执行 `references/approval-workflows.md`；本文件继续负责权限和租户收敛，`approval-workflows.md` 负责审批工作流状态、节点与决策快照。

## 范围与边界

本 owner 覆盖：

- RBAC、ABAC、角色、权限矩阵、能力开关、租户、工作区、组织、认证状态、权限版本和资源版本。
- 页面、菜单、导航、按钮、表单字段、表格列、表格行、筛选项、下载入口、任务入口、搜索结果、图表明细、错误明细和审计入口的可见性解析。
- 权限降级、权限升级、租户/工作区切换、角色变化、对象状态变化、认证过期、资源删除、能力关闭和旧缓存失效。
- 隐藏、禁用、只读、未启用、无权限、权限待解析、安全占位、申请权限、切换租户/工作区和重新认证。
- DOM、state、handler、request、cache、focus、ARIA、日志和移动端折叠中的无泄露要求。

本 owner 不覆盖：

- 后端授权模型、策略引擎、组织架构、账号体系或具体权限 DSL。
- 组件局部交互的完整状态机。
- 某个业务项目的角色、菜单、资源命名或内部权限码。

## `permissionVisibilityState`

每个页面、区域、资源集合、操作集合或权限敏感组件必须维护 `permissionVisibilityState`：

| 字段 | 语义 |
| --- | --- |
| `permissionOwnerId` | 当前权限解析 owner 稳定身份。 |
| `principalSnapshot` | 当前用户、角色、组织、租户、工作区、权限版本和认证状态快照。 |
| `resourceSnapshot` | 页面、记录、字段、文件、任务、菜单、操作、报表或外部系统目标快照。 |
| `capabilityMatrix` | 查看、创建、编辑、删除、导出、下载、取消、重试、审批、配置等能力解析结果。 |
| `visibilityState` | `visible`、`hidden-by-permission`、`disabled-by-permission`、`read-only`、`not-enabled`、`pending-resolution`、`permission-denied`。 |
| `reasonState` | 可展示原因、安全占位、申请权限路径、切换租户/工作区路径、重新认证路径和不可泄露内容。 |
| `dataBoundary` | 可见字段、可见行、可见数量、可见聚合、脱敏规则和旧数据清理策略。 |
| `actionBoundary` | DOM、state、handler、request 和审计的零值证据或可执行请求身份。 |
| `cacheBoundary` | 旧菜单、旧搜索结果、旧下载、旧任务、旧错误、旧表单草稿和旧快照失效策略。 |
| `focusBoundary` | 权限收敛、入口移除、只读转换和恢复路径的焦点迁移规则。 |
| `a11yBoundary` | 可访问名称、描述、公告、禁用原因、只读说明和无泄露 ARIA 策略。 |
| `responsivePolicy` | 移动端权限说明、申请权限、租户/工作区切换、安全占位和恢复路径保留策略。 |

不得只用 `canEdit`、`isAdmin`、`disabled`、`hidden`、403 错误、按钮 loading、后端异常或组件库默认权限插槽替代 `permissionVisibilityState`。

## 可见性语义

隐藏、禁用、只读、未启用和无权限不是同一件事。

隐藏表示当前主体不应知道或不应访问该入口；入口、可访问名称、tooltip、快捷键、菜单项、handler 和请求路径都不得暴露。

禁用表示入口可见但当前上下文不可执行，且原因可安全展示；禁用不是安全边界，不能保留可执行 handler、快捷键、请求或旧确认。

只读表示信息可见但不可编辑；应使用只读展示、只读摘要或详情 owner，不得用 disabled 表单控件假装展示文本。

未启用表示产品或配置没有启用该能力，DOM、state、handler 和 request 入口均为 0。未启用不能被包装成“无权限”，否则会误导用户申请不存在的能力。

无权限表示权限不足，必须提供安全说明或恢复路径，但不得泄露敏感内容。权限待解析时应显示 pending、安全骨架或安全占位，不得短暂闪现有权内容。

## 原子收敛和旧状态清理

权限、租户/工作区、角色、认证状态、对象状态、权限版本或资源版本变化后，必须原子重算可见数据、菜单、按钮、表单字段、筛选项、导航、下载、任务入口、确认面板和缓存。

旧可见数据、旧菜单、旧按钮、旧确认、旧下载链接、旧任务入口、旧错误明细、旧搜索结果、旧表单草稿、旧图表明细和旧 ARIA label 不得继续暴露。

原子收敛期间不能先展示旧内容再异步补权限。无法证明安全的旧内容先隐藏、失效或替换为安全占位；新的 `principalSnapshot`、`resourceSnapshot` 和 `capabilityMatrix` 验证完成后才能恢复可见能力。

迟到请求、缓存回放、路由恢复、浏览器 Back、任务中心回调、搜索建议回调和下载回调必须匹配当前 `permissionOwnerId`、租户/工作区、权限版本、资源版本和 owner 生命周期；失配只能丢弃或转入安全恢复。

## 无泄露要求

无权限状态不得泄露对象名称、数量、字段、文件名、路径、父子关系、导出范围、错误明细、任务结果、搜索摘要、内部 ID、图标、排序位置、旧缓存或旧可访问名称。

tooltip、popover、disabled reason、placeholder、空态、错误消息、搜索结果数量、表格总数、图表 tooltip、下载文件名、错误明细文件名、Notification 标题、ARIA label、DOM data 属性、日志和缓存摘要同样不得泄露无权信息。

如果产品需要给出原因，使用安全泛化说明，例如“当前账号没有访问该资源的权限”“请切换工作区或申请权限”。只有当对象名称、数量、字段或范围已被当前 `capabilityMatrix` 证明可见时，才能展示具体内容。

## 请求、冲突和审计

任何会改变数据、读取敏感数据、下载文件、导出、取消任务、重试任务、查看错误明细、查看审计或进入外部系统的操作，都必须绑定当前 `principalSnapshot`、`resourceSnapshot`、`capabilityMatrix` 和权限版本。

权限冲突、版本过期、租户/工作区切换、对象状态变化、认证过期或能力关闭后，旧请求、旧幂等键、旧确认、旧下载、旧重试和旧任务动作必须进入冲突、重新确认、只读、安全占位或恢复路径，不能继续执行旧请求。

审计必须记录当前主体、租户/工作区、资源快照、权限版本、能力判定、请求身份和结果。审计不可用不等于业务失败，但必须说明业务结果是否已生效、如何检查和如何恢复。

## 可访问性、焦点和移动端

权限说明、只读原因、禁用原因、申请权限、切换租户/工作区、安全占位、重新认证和恢复路径必须有可见文本或可访问描述。颜色、锁图标、灰色按钮、hover tooltip、隐藏菜单、Toast 或 403 裸错误不能是唯一说明。

权限收敛、入口移除、只读转换和恢复路径展示时，焦点只迁移一次。当前焦点所在入口因权限收敛消失时，迁移到安全说明、恢复入口或稳定页面标题；不得落到 body、页面根、已移除节点或无权限对象。

移动端不得删除权限说明、只读原因、禁用原因、申请权限、切换租户/工作区、安全占位、重新认证或恢复路径。低频权限详情可以折叠，但必须可发现、可触达、可键盘或辅助技术访问。

低高度、虚拟键盘、动态 viewport、四向 safe area、系统字体放大、200% 缩放、触摸、系统返回、WebView 返回和浏览器 Back 下，权限说明、恢复入口、切换租户/工作区和重新认证路径必须可达。

## 生命周期和处置

每个权限 owner 必须登记权限解析请求、能力缓存、菜单缓存、搜索缓存、下载入口、任务入口、表单草稿、图表明细、错误明细、焦点恢复和公告。权限、租户/工作区、角色、认证状态、对象状态或资源版本变化时，进入 disposal 或 recompute：取消或失效旧请求、旧缓存、旧 DOM 引用、旧 ARIA 引用、旧下载、旧任务动作和旧焦点任务。

权限升级也必须重新解析，不能直接复用降级前旧缓存；权限升级后的数据应来自新快照。权限降级必须优先清理旧可见内容，再展示安全说明或新范围。

## 完成前检查

- 验证每个权限敏感页面、区域、资源集合、操作集合或组件声明 `permissionVisibilityState`、`permissionOwnerId`、`principalSnapshot`、`resourceSnapshot`、`capabilityMatrix`、`visibilityState`、`reasonState`、`dataBoundary`、`actionBoundary`、`cacheBoundary`、`focusBoundary`、`a11yBoundary` 和 `responsivePolicy`。
- 验证隐藏、禁用、只读、未启用和无权限不是同一件事；未启用表示产品或配置没有启用该能力，DOM、state、handler 和 request 入口均为 0。
- 验证权限、租户/工作区、角色、认证状态、对象状态、权限版本或资源版本变化后，必须原子重算可见数据、菜单、按钮、表单字段、筛选项、导航、下载、任务入口、确认面板和缓存。
- 验证旧可见数据、旧菜单、旧按钮、旧确认、旧下载链接、旧任务入口、旧错误明细、旧搜索结果、旧表单草稿、旧图表明细和旧 ARIA label 不得继续暴露。
- 验证无权限状态不得泄露对象名称、数量、字段、文件名、路径、父子关系、导出范围、错误明细、任务结果、搜索摘要、内部 ID、图标、排序位置、旧缓存或旧可访问名称。
- 验证请求、下载、导出、取消、重试、查看错误明细和查看审计绑定当前 `principalSnapshot`、`resourceSnapshot`、`capabilityMatrix` 和权限版本。
- 验证移动端不得删除权限说明、只读原因、禁用原因、申请权限、切换租户/工作区、安全占位、重新认证或恢复路径。
- 验证权限收敛、入口移除、只读转换和恢复路径展示时焦点只迁移一次，并且不会落到 body、页面根、已移除节点或无权限对象。
- 真实浏览器、键盘、屏幕阅读器、触摸、租户/工作区切换、权限降级、权限升级、缓存失效和移动端视口未实际执行时，必须明确标为未验证，并列出所需验证。

## 参考资料

- [WAI-ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [WCAG: Keyboard](https://www.w3.org/WAI/WCAG22/Understanding/keyboard.html)
- [WCAG: Focus Appearance](https://www.w3.org/WAI/WCAG22/Understanding/focus-appearance.html)
- [WCAG: Status Messages](https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html)
