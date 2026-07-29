# 导出、下载与结果产物交付交互规范

适用于 export、download、artifact、result artifact、file delivery、download link、download URL、CSV、Excel、PDF、image export、report export、chart export、audit export、error report、error detail、expiry、expires、导出、下载、结果产物、文件领取、下载链接、下载地址、文件有效期、过期文件、重新生成、错误明细、报表导出、图表导出、审计导出、CSV、Excel、PDF 和图片导出。本文件是导出状态、产物身份、下载意图、范围快照、有效期、权限复核、敏感字段、旧链接失效、Toast 边界、结果恢复、可访问性和验收的唯一事实来源。

表格导出范围、选择快照和批量范围继续执行 [数据表格交互规范](data-tables.md)。查询条件、已应用筛选和 URL 恢复继续执行 [查询条件与筛选交互规范](query-filters.md)。导出范围必须读取 `references/list-result-controls.md` 的当前结果范围快照、`querySnapshot`、排序、分页、页大小、数据版本和总数可信度，但导出创建、生成、领取、下载和过期生命周期仍归本 owner。时间范围、时区、相对时间和导出快照继续执行 [日期时间与时区交互规范](date-time-ranges.md)。权限、租户/工作区和无泄露继续执行 [权限、租户与可见性交互规范](permissions-tenancy-visibility.md)。敏感导出、高风险导出和强确认继续执行 [危险操作与恢复交互规范](risk-actions.md)。异步导出、任务中心和结果领取继续执行 [异步任务与任务中心交互规范](async-jobs-task-center.md)。导入结果产物、错误明细下载和文件预检继续执行 [上传与导入交互规范](uploads-imports.md)。审计导出和操作历史继续执行 [审计日志与操作历史交互规范](audit-log-activity-history.md)。图表/报表导出继续执行 [图表与可视化交互规范](charts-visualization.md)。下载、复制链接、重新生成和重试按钮继续执行 [按钮交互规范](buttons.md)。移动端承载继续执行 [响应式与自适应交互规范](responsive-adaptive.md)。

概览页、仪表盘首页、管理台首页、运营看板、业务看板、指标总览、报表总览和 dashboard landing 的导出必须同时执行 `references/overview-dashboard-pages.md`；本文件负责产物生命周期，`overview-dashboard-pages.md` 负责导出绑定当前页面级 `dataSnapshot`、`timeRangeSnapshot`、权限版本、模块口径和数据延迟。

## 范围与边界

本 owner 覆盖：

- 同步导出、异步导出、报表导出、图表导出、审计导出、列表导出、批量结果导出、错误明细下载、任务结果产物、导入结果产物、文件领取、下载链接、下载地址、复制下载链接、重新生成和重试下载。
- CSV、Excel、PDF、图片、压缩包、错误明细、回执文件、导入结果、报表快照、审计快照和任务产物。
- 导出范围、产物身份、下载身份、文件有效期、敏感字段、权限复核、租户/工作区、请求身份、审计回执、结果状态、过期恢复和移动端领取。

本 owner 不覆盖：

- 后端文件存储、对象存储签名、下载 CDN、加密、压缩、转码、病毒扫描或保留策略。
- 某个业务项目的文件格式、字段清单、文件命名规则、接口字段或存储桶路径。
- 普通上传队列、文件选择和导入预检本身；这些归上传导入 owner。

## `exportState` 与 `artifactState`

每个导出、下载、错误明细、结果产物或文件领取入口必须声明 `exportState` 或 `artifactState`：

| 字段 | 语义 |
| --- | --- |
| `exportOwnerId` | 当前导出意图、导出任务或导出入口的稳定 owner 身份。 |
| `artifactOwnerId` | 当前文件产物、错误明细或结果领取入口的稳定 owner 身份。 |
| `exportSurface` | `table-export`、`report-export`、`chart-export`、`audit-export`、`task-artifact`、`error-report`、`bulk-result`、`detail-download`、`mobile-download`。 |
| `scopeSnapshot` | 已应用筛选、时间范围、时区、排序、列配置、选择/批量范围、权限版本、租户/工作区和结果 owner 快照。 |
| `artifactIdentity` | 文件 ID、任务 ID、产物 ID、格式、生成时间、文件版本、文件大小、请求身份和审计回执。 |
| `downloadIntent` | 本次下载、复制链接、领取、重新生成或重试的冻结意图。 |
| `permissionBoundary` | 创建导出、查看任务、查看产物、下载文件、复制链接、重新生成和查看错误明细的权限版本。 |
| `expiryPolicy` | 文件有效期、链接有效期、过期说明、重新生成策略和过期恢复入口。 |
| `sensitiveFieldPolicy` | 敏感字段、脱敏策略、导出级别、强确认要求、字段说明和无泄露策略。 |
| `deliveryReceipt` | 创建导出、生成完成、下载成功、下载失败、过期、拒绝、部分成功、未知和审计回执。 |
| `recoveryPolicy` | 重新生成、重试下载、刷新状态、查看任务、查看审计、下载错误明细、申请权限或返回。 |
| `feedbackState` | queued、processing、ready、downloaded、expired、failed、partial-success、permission-denied、unknown、unavailable。 |
| `a11yPolicy` | 文件格式、范围、状态、有效期、敏感性、错误、恢复和公告策略。 |
| `responsivePolicy` | 移动端导出范围、文件状态、有效期、下载、错误明细、重新生成、任务详情和恢复路径保留策略。 |

创建导出、生成文件、领取产物和下载文件不得合并成一个含糊状态。创建导出读取 `scopeSnapshot`；生成完成产生 `artifactIdentity`；下载、复制链接、领取产物、重新生成和重试下载必须创建新的 `downloadIntent` 并复核当前权限。

## 范围快照和导出意图

导出范围不得读取筛选草稿、未提交时间范围、Select query、active option、当前页面可见行或旧缓存。导出只能读取已应用筛选、已提交时间范围、当前权限版本、租户/工作区、数据范围、排序/列配置、选择快照、批量范围和结果 owner 快照。

同步导出和异步导出都必须冻结 `scopeSnapshot`。若导出的是“当前页”“全部筛选结果”“选中项”“图表可见数据”“聚合后数据”“原始明细”“错误明细”或“审计范围”，必须在入口、确认、任务、结果和文件说明中保持一致。

导出创建后，编辑筛选、切换时间范围、切换租户/工作区、权限变化、列配置变化或重新排序，不得静默改变已创建导出的范围。若用户要使用新范围，必须创建新的导出意图或明确重新生成。

## 下载意图、链接有效期和旧入口

下载链接不得被当作权限证明；每次下载必须复核权限、租户/工作区、有效期、请求身份和产物身份。下载、复制链接、重新生成、下载错误明细和查看任务详情都读取新的 `downloadIntent`，不得只信任旧 URL。

旧 Notification、旧任务入口、旧 URL、旧缓存、旧文件名或旧下载链接不得绕过权限复核。权限降级、租户切换、工作区切换、登录过期、任务过期、文件过期、文件删除、请求身份不匹配或产物身份失配时，旧入口必须失效或替换为安全说明，并提供重新生成、重新认证、申请权限或返回路径。

文件有效期和链接有效期必须可见或可达。过期文件不能继续展示可点击下载按钮；过期后如果允许恢复，必须说明是重新生成原范围快照，还是基于当前已应用范围创建新导出。

## 敏感字段、审计和权限安全

敏感导出、审计导出、错误明细下载和跨租户/工作区产物必须说明敏感字段、范围、有效期、权限边界和审计回执。敏感字段可以脱敏、隐藏、聚合或要求强确认；不得只在文件内部或下载后才提示。

无权限下载、无权限导出或无权限查看产物时，不得泄露文件名、对象名称、数量、字段名、敏感字段、导出范围、错误明细、任务结果、审计主体、内部 ID、存储路径、URL 参数或旧缓存。可以显示安全泛化说明、申请权限、切换租户/工作区或重新认证路径。

导出创建、生成完成、下载成功、下载失败、重新生成、过期拒绝、权限拒绝、部分成功和未知结果必须关联 `deliveryReceipt`、任务身份或审计回执；若未实际验证审计链路，必须标为审计未验证。

## 结果状态、Toast 边界和恢复

导出和产物交付必须区分 queued、processing、ready、downloaded、expired、failed、partial-success、permission-denied、unknown 和 unavailable。部分成功、未知、过期、无权限和文件不可用不得伪装成成功。

Toast、Snackbar、Notification 或浏览器下载提示不得作为唯一下载入口、唯一结果回执、唯一错误说明或唯一恢复路径。它们可以提示“导出已创建”“文件已生成”“下载失败”或“链接已过期”，但必须能回到页面结果区、任务中心、操作历史、审计记录或详情页继续处理。

失败后必须说明失败阶段：创建失败、生成失败、下载失败、权限拒绝、过期、文件不可用、任务未知或网络中断。未知结果必须提供检查状态、刷新、查看任务、查看审计或联系支持路径。部分成功必须说明成功范围、失败范围、缺失范围、错误明细和下一步。

## 可访问性和移动端

文件格式、导出范围、文件状态、有效期、敏感性、错误和恢复不能只靠图标、颜色、hover、tooltip、Toast 或浏览器下载栏表达。下载按钮、复制链接、重新生成、重试、查看任务、查看审计和下载错误明细必须有动作对象和可访问名称。

状态变化、生成完成、下载失败、链接过期、权限拒绝、部分成功和未知结果必须由唯一 owner 公告。焦点在导出入口、确认、任务状态、结果区、下载按钮、错误摘要、重新生成和恢复入口之间只迁移一次。

移动端不得删除导出范围、文件状态、格式、有效期、权限说明、敏感字段说明、错误明细、重新生成、任务详情、审计入口或恢复路径。移动端可以把导出详情、字段说明和错误明细筛选放入 Drawer / Bottom Sheet / 独立页，但下载、重试、重新生成、查看任务和恢复必须可达。

低高度、虚拟键盘、动态 viewport、四向 safe area、系统字体放大、200% 缩放、触摸、系统返回、WebView 返回和浏览器 Back 下，导出范围、文件状态、有效期、下载、错误明细、重新生成、任务详情、审计入口和恢复路径必须可达。

## 生命周期和清理

每个导出或产物 owner 必须登记导出请求、任务订阅、下载意图、下载链接、复制链接、重新生成请求、错误明细请求、权限版本、租户/工作区、焦点任务、公告和审计回执。权限变化、租户/工作区切换、路由变化、owner 卸载、文件过期、任务过期或范围快照替换时，旧请求、旧订阅、旧链接、旧文件名、旧任务入口、旧结果、旧 ARIA 引用和旧焦点任务必须取消或失效。

迟到生成结果、迟到下载结果、旧错误明细或旧下载链接必须匹配 `exportOwnerId`、`artifactOwnerId`、`scopeSnapshot`、`artifactIdentity`、`permissionBoundary`、租户/工作区和请求身份。失配结果只能丢弃或转入安全恢复；不得覆盖当前状态、重启下载、暴露文件名、清除当前错误或触发旧焦点恢复。

## 完成前检查

- 验证每个导出、下载、错误明细、结果产物或文件领取入口声明 `exportState`、`artifactState`、`downloadIntent`、`exportOwnerId`、`artifactOwnerId`、`exportSurface`、`scopeSnapshot`、`artifactIdentity`、`permissionBoundary`、`expiryPolicy`、`sensitiveFieldPolicy`、`deliveryReceipt`、`recoveryPolicy`、`feedbackState`、`a11yPolicy` 和 `responsivePolicy`。
- 验证导出范围不得读取筛选草稿、未提交时间范围、Select query、active option、当前页面可见行或旧缓存。
- 验证创建导出、生成文件、领取产物和下载文件不得合并成一个含糊状态。
- 验证下载链接不得被当作权限证明；每次下载必须复核权限、租户/工作区、有效期、请求身份和产物身份。
- 验证旧 Notification、旧任务入口、旧 URL、旧缓存、旧文件名或旧下载链接不得绕过权限复核。
- 验证 Toast、Snackbar、Notification 或浏览器下载提示不得作为唯一下载入口、唯一结果回执、唯一错误说明或唯一恢复路径。
- 验证敏感导出、审计导出、错误明细下载和跨租户/工作区产物必须说明敏感字段、范围、有效期、权限边界和审计回执。
- 验证部分成功、未知、过期、无权限和文件不可用不得伪装成成功。
- 验证移动端不得删除导出范围、文件状态、格式、有效期、权限说明、敏感字段说明、错误明细、重新生成、任务详情、审计入口或恢复路径。
- 真实浏览器下载、键盘、屏幕阅读器、触摸、权限切换、链接过期、任务结果和移动端视口未实际执行时，必须明确标为未验证，并列出所需验证。

## 参考资料

- [WAI-ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [WCAG: Status Messages](https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html)
- [WCAG: Focus Order](https://www.w3.org/WAI/WCAG22/Understanding/focus-order.html)
- [WCAG: Error Identification](https://www.w3.org/WAI/WCAG22/Understanding/error-identification.html)
