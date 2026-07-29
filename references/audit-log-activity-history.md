# 审计日志与操作历史交互规范

适用于 audit log、activity log、operation history、event log、change history、audit detail、audit export、audit receipt、traceability、operation record、login log、access log、timeline、审计日志、操作历史、活动记录、事件日志、变更记录、审计详情、审计导出、审计回执、追溯链路、操作记录、登录日志、访问日志和时间线。本文件是审计证据、操作历史、活动时间线、时间语义、完整性、导出复核、权限无泄露、可访问性和验收的唯一事实来源。

审计日志表格、分页、排序和行选择继续执行 [数据表格交互规范](data-tables.md)。审计查询条件、时间范围筛选、主体筛选和动作筛选继续执行 [查询条件与筛选交互规范](query-filters.md)。日期时间、时区、相对时间和数据延迟继续执行 [日期时间与时区交互规范](date-time-ranges.md)。权限、租户/工作区和无泄露继续执行 [权限、租户与可见性交互规范](permissions-tenancy-visibility.md)。危险操作、审计回执和未知结果继续执行 [危险操作与恢复交互规范](risk-actions.md)。审批实例、审批节点、审批意见、审批附件、审批人、转交、加签、委托、催办和批量审批的审计证据必须同时执行 `references/approval-workflows.md`。异步任务、任务结果和任务追溯继续执行 [异步任务与任务中心交互规范](async-jobs-task-center.md)。管理台跨页面治理继续执行 [管理台完整治理交互规范](admin-console.md)。

## 范围与边界

本 owner 覆盖：

- 审计日志、活动记录、操作历史、事件日志、登录日志、访问日志、变更记录、对象时间线、审计详情、审计导出和追溯链路。
- 主体、目标、动作、结果、请求身份、任务身份、来源 owner、事件发生时间、审计写入时间、展示时区、筛选范围和数据延迟。
- 审计缺口、延迟、重复、顺序未决、来源不可用、修正记录、部分可见、无权限、过期、导出、复制和查看详情。
- 表格、时间线、详情页、Drawer、Dialog、Notification 跳转、任务中心跳转和移动端折叠中的审计证据展示。

本 owner 不覆盖：

- 后端审计存储、签名、不可篡改账本、日志采集、SIEM、告警规则或合规制度。
- 普通业务列表、普通详情页、普通 Toast 或纯运营活动流。
- 某个业务项目的审计字段、角色名称、资源类型或内部事件码。

## `auditLogState`

每个审计日志、操作历史、活动时间线、审计详情或审计导出入口必须维护 `auditLogState`：

| 字段 | 语义 |
| --- | --- |
| `auditOwnerId` | 当前审计日志、操作历史或时间线 owner 稳定身份。 |
| `auditSurface` | `audit-log`、`activity-log`、`operation-history`、`change-history`、`timeline`、`audit-detail`、`audit-export`。 |
| `eventIdentity` | 审计事件 ID、事件类型、来源系统、幂等键或请求身份。 |
| `actorSnapshot` | 操作主体、主体类型、租户/工作区、角色和脱敏策略。 |
| `targetSnapshot` | 目标对象、对象类型、字段、范围、旧值/新值和脱敏策略。 |
| `actionSnapshot` | 动作、风险等级、来源 owner、请求身份、任务身份和结果。 |
| `timeSemantics` | 事件发生时间、写入时间、展示时区、存储时区、数据延迟和筛选范围。 |
| `integrityState` | 审计可用性、延迟、缺口、修正、重复、顺序未决和来源可信度说明。 |
| `permissionBoundary` | 查看列表、查看详情、查看字段、复制、导出、跳转和追溯的权限版本。 |
| `filterSnapshot` | 已应用筛选、搜索、时间范围、主体、动作、目标、结果和 URL 安全策略。 |
| `exportState` | 审计导出范围、权限复核、敏感字段、文件有效期、下载身份和审计导出回执。 |
| `feedbackState` | loading、empty、zero-results、partial、stale、permission-denied、error、recovery。 |
| `a11yPolicy` | 表格、时间线和详情语义、公告、焦点、可访问名称和无泄露描述。 |
| `responsivePolicy` | 移动端筛选、时间线、详情、导出、追溯路径和恢复路径保留策略。 |

审计状态不能只绑定到普通表格数据、Toast 文案、Notification 标题、详情页字段或后端返回的未解释 JSON。

## 证据身份和审计边界

审计记录不是普通列表行，也不是 Toast 成功文案。每条可展示审计记录必须绑定 `eventIdentity`、`actorSnapshot`、`targetSnapshot`、`actionSnapshot`、`timeSemantics`、`permissionBoundary` 和来源 owner。

缺少证据身份的操作历史只能作为普通活动提示，不能写成审计日志。普通活动提示不能承担合规证明、风险回执、操作追溯、导出证据或权限争议裁决。

审计详情必须能追溯到来源操作、请求身份、任务身份、风险回执或业务结果。无法证明来源时，必须显示来源不可用、证据缺口或普通活动提示；不得补写伪审计证据。

## 时间语义和筛选

审计日志必须区分事件发生时间、审计写入时间、展示时区、存储时区、筛选范围、数据延迟和刷新时间。

审计筛选使用的时间字段必须可见说明。若按事件发生时间筛选，写入延迟可能导致新记录稍后出现；若按写入时间筛选，事件发生顺序可能与展示顺序不同。相对时间如“今天”“昨天”“近 7 天”用于审计回执、导出或离线阅读时，必须补充绝对日期。

审计查询、导出和追溯只能读取已应用 `filterSnapshot`；不得读取正在编辑的筛选草稿、未提交时间范围、临时 active option 或 UI 高亮。

## 权限、安全和无泄露

无权限审计不得泄露主体名称、目标名称、字段名、旧值、新值、数量、文件名、IP、设备、地理位置、错误明细、内部 ID、请求参数、导出范围、任务结果或旧缓存。

无权限可以显示安全泛化说明、申请权限、切换租户/工作区或重新认证路径。只有当前 `permissionBoundary` 证明可见的主体、目标、字段、数量、旧值、新值、文件名、IP、设备和任务结果，才能展示、复制、导出或进入可访问名称。

筛选候选、搜索建议、结果数量、空态文案、排序位置、导出文件名、详情 URL、ARIA label、DOM data 属性、错误日志和缓存摘要都不得泄露无权审计信息。

## 完整性、延迟和结果状态

审计列表必须区分 loading、empty、zero-results、partial、stale、permission-denied、error、audit-unavailable 和 recovery。空态不能只写“暂无日志”；必须区分确无记录、筛选无结果、无权限、审计服务不可用、数据延迟、审计缺口和日志保留期已过。

审计缺口、延迟、重复、顺序未决、来源不可用和修正记录必须明确说明，不能伪装成完整日志。审计不可用不等于业务操作失败；业务结果、任务结果和审计结果必须分别说明。

修正记录、撤销记录、重跑记录、取消记录和外部系统回执必须保留与原事件的关系，不得覆盖原事件，也不得只展示最后状态。

## 导出、复制、跳转和追溯

审计导出、复制、跳转、查看详情、查看关联任务、查看风险回执和追溯链路必须复核权限、租户/工作区、筛选快照、时间范围、敏感字段和请求身份。

旧导出链接、旧详情页、旧查询 URL、旧 Notification、旧任务中心入口和旧缓存不得绕过权限复核。导出文件必须说明范围、时间字段、时区、数据延迟、敏感字段、生成时间、有效期和下载身份。

复制审计字段必须按当前权限脱敏；不能因为字段在页面可见就允许复制完整值。跳转到目标对象、任务、风险回执或外部系统前必须重新验证目标仍可见。

## 可访问性和移动端

审计表格、时间线和详情必须有可访问名称。主体、动作、目标、结果、时间、完整性状态和权限说明不能只靠颜色、图标、缩进、tooltip、hover、相对时间或位置表达。

状态变化、查询完成、无结果、权限拒绝、审计不可用、部分结果、导出完成和导出失败必须由唯一 owner 公告。焦点在筛选、列表、详情、导出、返回和恢复路径之间只迁移一次。

移动端不得删除筛选、时间范围、时区说明、数据延迟、审计详情、追溯路径、导出权限说明、无权限说明或恢复路径。时间线可以折叠字段，但必须保留主体、动作、目标安全摘要、结果、时间语义和查看详情路径。

低高度、虚拟键盘、动态 viewport、四向 safe area、系统字体放大、200% 缩放、触摸、系统返回、WebView 返回和浏览器 Back 下，审计筛选、详情、导出、追溯和恢复路径必须可达。

## 生命周期和清理

每个审计 owner 必须登记查询请求、导出请求、下载链接、详情订阅、时间范围快照、筛选快照、权限版本、焦点恢复、公告和缓存订阅。权限变化、租户/工作区切换、路由变化、owner 卸载或筛选快照替换时，旧请求、旧导出、旧下载、旧详情、旧缓存、旧 ARIA 引用和旧焦点任务必须取消或失效。

迟到审计查询、导出结果、详情结果或下载链接必须匹配 `auditOwnerId`、`filterSnapshot`、`permissionBoundary`、租户/工作区和时间范围；失配只能丢弃或转入安全恢复。

## 完成前检查

- 验证每个审计日志、操作历史、活动时间线、审计详情或审计导出入口声明 `auditLogState`、`auditOwnerId`、`auditSurface`、`eventIdentity`、`actorSnapshot`、`targetSnapshot`、`actionSnapshot`、`timeSemantics`、`integrityState`、`permissionBoundary`、`filterSnapshot`、`exportState`、`feedbackState`、`a11yPolicy` 和 `responsivePolicy`。
- 验证审计记录不是普通列表行，也不是 Toast 成功文案；缺少证据身份的操作历史只能作为普通活动提示，不能写成审计日志。
- 验证审计日志必须区分事件发生时间、审计写入时间、展示时区、存储时区、筛选范围、数据延迟和刷新时间。
- 验证无权限审计不得泄露主体名称、目标名称、字段名、旧值、新值、数量、文件名、IP、设备、地理位置、错误明细、内部 ID、请求参数、导出范围、任务结果或旧缓存。
- 验证审计缺口、延迟、重复、顺序未决、来源不可用和修正记录必须明确说明，不能伪装成完整日志。
- 验证审计导出、复制、跳转、查看详情、查看关联任务、查看风险回执和追溯链路必须复核权限、租户/工作区、筛选快照、时间范围、敏感字段和请求身份。
- 验证移动端不得删除筛选、时间范围、时区说明、数据延迟、审计详情、追溯路径、导出权限说明、无权限说明或恢复路径。
- 真实浏览器、键盘、屏幕阅读器、触摸、权限切换、审计导出、时间范围、时区、任务追溯和移动端视口未实际执行时，必须明确标为未验证，并列出所需验证。

## 参考资料

- [WAI-ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [WCAG: Keyboard](https://www.w3.org/WAI/WCAG22/Understanding/keyboard.html)
- [WCAG: Focus Appearance](https://www.w3.org/WAI/WCAG22/Understanding/focus-appearance.html)
- [WCAG: Status Messages](https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html)
