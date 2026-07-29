# 空态、无结果与首次使用引导交互规范

适用于空状态、空态、暂无数据、无数据、无结果、筛选无结果、搜索无结果、首次使用、首次进入、初始化空态、未配置空态、未创建空态、只读空态、报表空态、权限空态、错误空态、加载空态、归档空态、禁用能力空态、创建入口、清空筛选、重置筛选、empty state、zero results、no data、first run、first use、onboarding empty、not configured、no results、no matching results 和 empty CTA。

本文件是空态、无结果与首次使用引导 owner。空状态不是“没有数据”的单一文案。它必须证明为什么空、谁有权看、当前是否受筛选影响、是否允许创建、是否只是只读展示、是否应恢复默认条件、是否存在错误或权限边界，以及 CTA 是否会误导用户。

页面/区域级 loading、error、partial、stale 和 recovery 承载继续执行 `references/feedback-states.md`；列表结果、分页、排序、刷新和总数可信度继续执行 `references/list-result-controls.md`；筛选草稿、已应用条件、清空/重置语义继续执行 `references/query-filters.md`；创建/新增入口继续执行 `references/record-editing-surfaces.md` 和 `references/buttons.md`；权限、租户与无泄露继续执行 `references/permissions-tenancy-visibility.md`；页面内容布局继续执行 `references/page-content-layout-sections.md`；表格和卡片结果继续执行 `references/data-tables.md` 与 `references/card-list-results.md`；移动端继续执行 `references/responsive-adaptive.md`。

## 范围与边界

本 owner 覆盖：

- 首次进入没有任何业务对象、用户尚未完成配置、当前租户/工作区为空、当前筛选无匹配结果、搜索无结果、归档/停用范围为空、只读报表无数据、权限导致不可见和错误导致无法展示结果。
- 空态文案、原因说明、主 CTA、次 CTA、恢复入口、创建入口、导入入口、清空筛选、重置筛选、查看示例、查看帮助、切换范围、申请权限和返回路径。
- 空态与列表、表格、卡片、Section、TabPanel、Dashboard 模块、详情关联区、任务结果区和移动端页面的归属关系。

本 owner 不覆盖：

- 品牌插画风格、营销 onboarding、教程系统、埋点平台或增长实验。
- 真实数据口径、后端统计、权限模型或具体业务对象命名。
- 表单字段内的空值说明；字段级空值继续执行 `references/field-guidance-help-text.md`。

## `emptyStateDecision`

每个空态、无结果或首次使用引导必须声明 `emptyStateDecision`：

| 字段 | 语义 |
| --- | --- |
| `emptyStateOwnerId` | 当前空态 owner 的稳定身份。 |
| `emptySurface` | `page`、`section`、`table`、`card-list`、`dashboard-module`、`tab-panel`、`preview-related`、`task-result`、`mobile-page`。 |
| `emptyReason` | first-run-empty、true-empty、zero-results、permission-empty、not-configured-empty、read-only-empty、archived-empty、error-empty、loading-empty、unsupported-empty。 |
| `dataScopeSnapshot` | 当前租户/工作区、对象范围、数据版本、时间范围、归档/状态范围和结果 owner 快照。 |
| `querySnapshot` | 已应用筛选、关键词、排序、分页、URL 条件和默认条件版本；无筛选影响时明确为 none。 |
| `permissionBoundary` | 查看数据、查看数量、查看对象名称、创建、导入、清筛选、申请权限和切换范围的权限版本。 |
| `capabilityPolicy` | 当前能力是否启用、是否只读、是否可创建、是否可导入、是否可申请权限、是否可查看示例。 |
| `contentPolicy` | 标题、说明、示例、数量、对象名称、筛选摘要、权限说明和敏感信息展示策略。 |
| `primaryActionPolicy` | 主 CTA 的动作对象、可用性、权限、目标 owner、禁用/隐藏原因和请求边界。 |
| `secondaryActionPolicy` | 次 CTA、帮助、示例、返回、切换范围、查看归档、申请权限和联系管理员策略。 |
| `recoveryPolicy` | 清空筛选、重置筛选、刷新、重试、切换时间范围、切换租户/工作区、恢复默认视图和返回路径。 |
| `illustrationPolicy` | 插图、图标和装饰是否可用；不得作为唯一语义来源。 |
| `feedbackBinding` | 与 loading、error、stale、partial、permission 和 recovery owner 的关系。 |
| `resultOwnerBinding` | 表格、卡片、列表、Dashboard 模块、TabPanel 或 Section 的结果 owner 绑定。 |
| `responsivePolicy` | 移动端布局、CTA 排列、说明折叠、筛选恢复和安全区域策略。 |
| `focusAnnouncementPolicy` | 空态出现、原因变化、清筛选、创建入口、权限变化、错误恢复和移动端返回的焦点与公告策略。 |
| `lifecycleDisposal` | 查询变化、权限变化、租户/工作区变化、数据版本变化、路由变化和 owner 卸载时的清理规则。 |
| `runtimeVerification` | 真实浏览器、键盘、读屏、触摸、筛选变化、权限切换、路由恢复、移动端和缩放验证状态；未执行必须标为未验证。 |

不得只用 `empty: true`、`data.length === 0`、`暂无数据`、空数组、HTTP 200、后端 count、插图、Toast、隐藏列表或组件默认 Empty 替代 `emptyStateDecision`。

## 空态原因和优先级

空态必须区分 firstRunEmpty、trueEmpty、zeroResults、permissionEmpty、errorEmpty、loadingEmpty、archivedEmpty、notConfiguredEmpty 和 readOnlyEmpty。不同原因不能复用同一个“暂无数据”文案和同一个 CTA。

优先级必须稳定：权限待解析和加载中优先于空数据；首次加载错误优先于空态；已应用筛选导致的 zeroResults 优先于 trueEmpty；权限不可见不能伪装成 trueEmpty；只读报表不能伪装成“去创建第一条记录”。

空态标题必须说明当前原因，例如“没有匹配的结果”“还没有创建记录”“当前账号无权查看此范围”“此报表暂无可展示数据”。说明文案应告诉用户下一步，但不能承诺不存在用户无权查看的数据。

## CTA、创建入口和恢复

空态 CTA 必须匹配 `emptyReason` 和 `capabilityPolicy`。首次使用且用户有创建权限时，可以给“新建/导入/配置”入口；zeroResults 的主恢复通常是清空筛选、调整关键词、重置时间范围或返回默认视图；权限空态优先申请权限、切换租户/工作区或重新认证；错误空态优先重试或查看状态。

创建入口不得出现在只读报表、权限不足、能力未启用、租户/工作区不可写、对象类型不可创建或筛选无结果但真实数据范围未知的场景。若创建入口可见，必须转交 `references/record-editing-surfaces.md`，并按 `references/buttons.md` 声明动作对象、权限和防重复。

清空筛选和重置筛选不是同一件事。清空筛选只移除用户已应用条件；重置筛选恢复产品默认条件、默认时间范围、默认视图或系统范围。两者必须创建新的查询意图，并让列表、导出、批量范围和焦点读取同一快照。

空态不能把“查看帮助”“联系我们”“返回首页”作为唯一恢复路径，除非产品明确没有可执行的数据恢复、创建、筛选或权限路径。

## 权限、安全和无泄露

权限空态、租户/工作区切换后的空态、权限降级后的空态和只读空态必须执行无泄露规则。无权限时不得泄露对象名称、数量、字段、筛选值、状态分布、归档数量、文件名、成员、金额、内部 ID、错误明细、旧搜索结果或旧可访问名称。

权限不可见不等于没有数据。文案不能说“没有任何记录”，只能给安全泛化说明，例如“当前账号没有访问此范围的权限”。只有当当前 `permissionBoundary` 证明数量和对象摘要可见时，才可展示具体数量、字段或示例。

权限变化、租户/工作区变化、能力关闭、角色变化或 URL 恢复失败后，旧空态标题、旧 CTA、旧数量、旧筛选摘要、旧插图 alt、旧按钮 accessible name 和旧焦点目标必须失效或重算。

## 可访问性和移动端

空态原因、结果范围、恢复动作、禁用原因和权限说明必须有可见文本或可访问描述。图标、插图、颜色、空白区域、hover tooltip、Toast 或相对位置不能是唯一语义来源。

空态出现、从 loading 进入 empty、从 zeroResults 恢复、清空筛选、创建入口打开、权限变化和错误恢复必须由唯一 owner 公告。焦点应迁移到空态标题、错误摘要、恢复入口或页面标题，且只迁移一次。

移动端不得删除空态原因、筛选摘要、主 CTA、恢复入口、权限说明、创建/导入入口、重试和返回路径。移动端可以压缩插图、折叠长说明、把次要帮助放入 Drawer / Bottom Sheet，但核心恢复动作必须在当前任务中可达。

低高度、虚拟键盘、动态 viewport、四向 safe area、系统字体放大、200% 缩放、触摸、系统返回、WebView 返回和浏览器 Back 下，空态标题、原因、主 CTA、恢复入口和权限说明仍必须可达。

## 生命周期和清理

每个空态 owner 必须登记查询快照、结果 owner、权限版本、租户/工作区、能力版本、默认条件版本、CTA owner、焦点任务和公告回调。

查询变化、筛选应用、筛选清空、视图切换、权限变化、租户/工作区变化、数据版本变化、结果刷新、路由变化或 owner 卸载后，旧空态、旧 CTA、旧恢复入口、旧数量、旧筛选摘要、旧插图 alt、旧 DOM、旧 ARIA 引用和旧焦点任务必须取消、失效或重算。

## 完成前检查

1. **owner 声明**：每个空态、无结果和首次使用引导声明 `emptyStateDecision`。
2. **原因区分**：firstRunEmpty、trueEmpty、zeroResults、permissionEmpty、errorEmpty、loadingEmpty、archivedEmpty、notConfiguredEmpty 和 readOnlyEmpty 没有混用。
3. **优先级**：权限待解析、加载、错误、筛选无结果、真实空数据和只读空态优先级稳定。
4. **CTA 匹配**：创建、导入、清筛选、重置筛选、申请权限、重试、帮助和返回与 `emptyReason`、`capabilityPolicy` 匹配。
5. **创建入口**：只读报表、无权限、能力未启用、不可写范围和 zeroResults 未被误导到创建。
6. **筛选恢复**：清空筛选和重置筛选语义不同，并创建新的查询意图。
7. **权限无泄露**：无权限不泄露对象名称、数量、字段、筛选值、归档数量、文件名、金额、内部 ID 或旧可访问名称。
8. **Toast 边界**：Toast 不是唯一空态原因、错误说明或恢复路径。
9. **移动端保真**：移动端保留空态原因、筛选摘要、主 CTA、恢复入口、权限说明、重试和返回。
10. **运行时报告**：真实浏览器、键盘、读屏、触摸、筛选变化、权限切换、路由恢复、移动端和缩放未执行时必须标为未验证。

