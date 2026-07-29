# 反馈状态与状态承载规范

## 范围

适用于页面主内容区、列表/表格结果区、卡片列表、报表区域、详情区域、设置区域、任务结果区、上传/导入结果区、权限状态页和移动端筛选结果页中的空状态、空态、暂无数据、无结果、筛选无结果、加载、加载中、骨架屏、placeholder、错误状态、刷新失败、加载失败、重试、过期数据、部分结果、无权限状态和只读状态。

本文件是页面/区域级反馈状态与状态承载的唯一事实来源。它定义用户当前看到的区域状态由谁拥有、优先级如何决策、状态文案如何呈现、旧内容是否保留、恢复入口如何提供、敏感信息如何保护、状态变化如何公告。品牌插画、图标风格、颜色 token、全局通知中心、站内信、营销公告和邮件/Push 通知不属于本 owner。

## 与组件 owner 的关系

表格结果区的查询、排序、分页、选择和批量操作读取 `data-tables.md`；结果 loading、refresh-error、stale、empty、zero-results、invalid-page 和结果摘要的状态来源必须来自 `references/list-result-controls.md`，本文件只负责反馈承载、文案、恢复入口和公告去重；筛选无结果、清空筛选和恢复默认条件读取 `query-filters.md`；字段/表单错误读取 `forms.md`；重试、刷新、清空筛选、申请权限、返回、创建和导入按钮读取 `buttons.md`；上传/导入部分成功、错误明细和未知结果读取 `uploads-imports.md`；管理台权限、租户、审计、任务中心和全局反馈读取 `admin-console.md`；移动端、缩放、虚拟键盘和安全区域读取 `responsive-adaptive.md`。当本文件与组件 owner 都适用时，两者都执行；冲突时停止并请用户裁决。

Feedback States owner 不重新定义字段错误、表格查询、上传任务、按钮语义或管理台审计；它统一页面/区域级 loading、empty、error、stale、permission、partial 和 recovery 的状态承载。

## 场景与状态模型

每个可独立加载、失败、为空、过期或恢复的页面区域声明一个 `feedbackSurface`：`page-main`、`result-region`、`table-region`、`card-list`、`report-region`、`detail-region`、`settings-region`、`job-result`、`upload-import-result`、`permission-state` 或 `mobile-result-region`。

每个区域维护 `feedbackState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `ownerId` | 当前反馈区域稳定身份。 |
| `surfaceKind` | 区域类型和承载范围。 |
| `phase` | `initial-loading`、`refreshing`、`ready`、`empty`、`zero-results`、`initial-error`、`refresh-error`、`stale`、`partial`、`unknown`、`permission-denied`、`read-only`。 |
| `dataPresence` | `none-ever`、`none-for-current-query`、`previous-data-available`、`partial-data`、`data-hidden-by-permission`、`unknown`. |
| `errorKind` | `none`、`network`、`server`、`auth`、`permission`、`conflict`、`timeout`、`unavailable`、`unknown-result`。 |
| `permissionScope` | 当前权限、租户/工作区、数据范围和能否展示旧内容。 |
| `stale` | 当前可见内容是否过期或可能不再可信。 |
| `partial` | 当前内容是否为部分结果，以及缺失或失败范围。 |
| `messageOwner` | 可见状态文案、错误文案和状态公告的 primary owner。 |
| `recoveryActions` | 当前允许的恢复入口及其 owner，例如重试、刷新、清空筛选、申请权限、进入任务中心或返回。 |
| `announcementPolicy` | 状态变化公告、去重和焦点策略。 |
| `sensitiveBoundary` | 不得泄露的对象、数量、字段、文件名、筛选值和错误明细边界。 |

反馈状态不能只散落在 `loading`、`error`、`empty` 三个布尔值里。状态必须表达区域是否有旧内容、是否可恢复、是否涉及权限和是否包含部分或未知结果。

## FS-SCOPE 范围和术语

| 规则 ID | 规则 |
| --- | --- |
| FS-SCOPE-01 | 每个反馈区域必须声明自己控制的内容范围、结果 owner、恢复 owner 和敏感边界。 |
| FS-SCOPE-02 | `empty-dataset` 表示数据源本身为空；`zero-results` 表示当前条件无匹配；`permission-denied` 表示权限不足；三者不得共用含糊空态。 |
| FS-SCOPE-03 | Toast、Notification 或全局消息不能成为页面/区域状态的唯一 owner；区域内必须有可见状态或恢复路径。 |
| FS-SCOPE-04 | 组件库默认 skeleton、empty、result 或 alert 行为不能降低本文件规则；冲突时必须配置、封装或替换。 |

对应验收：FS-A1、FS-A10。

## FS-STATE 状态 owner、模型与优先级

一个区域同一时刻只能有一个 primary feedback owner。状态优先级必须可解释：权限/安全收敛优先于普通空态；首次加载失败不同于刷新失败；筛选无结果不同于数据源为空；部分结果不同于完全成功；未知结果不得伪装成成功或失败。

| 规则 ID | 规则 |
| --- | --- |
| FS-STATE-01 | `feedbackState` 必须包含 owner、phase、dataPresence、errorKind、permissionScope、stale、partial、messageOwner、recoveryActions、announcementPolicy 和 sensitiveBoundary。 |
| FS-STATE-02 | 权限、安全或租户无法证明时，优先进入安全状态，不得继续渲染旧内容、旧数量、旧对象名或旧恢复入口。 |
| FS-STATE-03 | 同一完整状态消息只能有一个 `messageOwner`；不得同时由 Toast、Alert、空态、结果区和 live region 重复播报。 |
| FS-STATE-04 | Loading、empty、error、stale、partial、unknown 和 permission 状态互斥或有明确组合规则；不得用多个布尔值让 UI 同时显示冲突状态。 |
| FS-STATE-05 | 状态切换必须记录来源意图，例如首次加载、刷新、筛选变化、权限变化、操作结果、任务回调或路由恢复。 |

对应验收：FS-A1、FS-A2、FS-A10。

## FS-LOAD Loading、Skeleton 和刷新

首次加载且没有可用内容时可用 skeleton、进度或 placeholder；刷新已有内容时应保留旧内容并标记 refreshing/stale，而不是清空成空白 skeleton。Skeleton 必须近似最终结构，但 Skeleton 不得包含可操作假数据、假按钮、假复选框、假链接或会被辅助技术误认为真实内容的文本。

| 规则 ID | 规则 |
| --- | --- |
| FS-LOAD-01 | 首次加载和刷新必须区分；首次加载无内容可显示 skeleton，刷新已有内容必须保留旧内容并显示刷新状态。 |
| FS-LOAD-02 | Skeleton 不得包含可操作假数据，不得进入 Tab 顺序，也不得被读屏当成真实内容。 |
| FS-LOAD-03 | 长加载必须有可见状态和适当公告；重复刷新公告必须去重。 |
| FS-LOAD-04 | 取消、关闭或离开只表示客户端停止等待；不得把服务端任务或请求结果写成已结束。 |
| FS-LOAD-05 | Loading 终止必须进入 ready、empty、zero-results、initial-error、refresh-error、partial、unknown 或 permission 等明确状态，不能永久悬挂。 |

对应验收：FS-A2、FS-A3。

## FS-EMPTY Empty、Zero Results 和下一步

空状态至少区分 `empty-dataset`、`zero-results`、`not-configured`、`not-created-yet`、`archived-only` 和 `permission-filtered-empty`。空状态不能用“暂无数据”糊住所有情况，也不能为了好看放一个无效 CTA。

| 规则 ID | 规则 |
| --- | --- |
| FS-EMPTY-01 | 数据源为空、筛选无结果、未配置、仅有归档数据和权限过滤为空必须使用不同状态文案和恢复路径。 |
| FS-EMPTY-02 | 筛选无结果必须展示当前条件影响，并提供调整筛选、清空可清空条件或恢复默认条件入口。 |
| FS-EMPTY-03 | 数据源本身为空应提供创建、导入、配置、了解更多或申请权限等与能力相符的下一步。 |
| FS-EMPTY-04 | 用户无创建、导入或配置权限时，不得展示不可执行主 CTA；应解释只读或申请路径。 |
| FS-EMPTY-05 | 空态文案不得泄露无权对象名称、数量、字段、文件名、筛选值或内部 ID。 |

对应验收：FS-A4、FS-A5、FS-A8、FS-A10。

## FS-ERROR Error、Stale、Partial 和 Unknown

错误状态必须区分首次加载失败、刷新失败、操作失败、权限失败、网络失败、服务不可用、数据延迟、冲突和未知结果。首次加载失败且没有可用内容时，区域内错误取代内容；刷新失败时保留旧内容，显示 stale 说明和重试入口。

| 规则 ID | 规则 |
| --- | --- |
| FS-ERROR-01 | 首次加载失败进入 `initial-error`，刷新失败进入 `refresh-error`；两者文案、内容保留和恢复入口不得混用。 |
| FS-ERROR-02 | 刷新失败时保留旧内容，标记 stale，并提供重试、刷新或检查状态入口；不得清空旧结果伪装成空态。 |
| FS-ERROR-03 | 操作失败归操作 owner；除非结果本身不可继续信任，否则不得覆盖整个结果区域。 |
| FS-ERROR-04 | 部分结果必须说明成功范围、失败范围、缺失范围、可继续风险和恢复入口。 |
| FS-ERROR-05 | 未知结果不得伪装成成功或失败，必须提供检查最新状态、进入任务中心或联系支持路径。 |
| FS-ERROR-06 | Toast 不能作为唯一错误或结果回执；区域内必须有可见错误、状态摘要或恢复入口。 |

对应验收：FS-A5、FS-A6、FS-A10。

## FS-RECOVERY 恢复入口

恢复入口必须与状态类型匹配。重试、刷新、检查状态、重新认证、申请权限、返回上一步、清空筛选、恢复默认条件、进入任务中心、下载错误明细或联系支持都必须有明确 owner、动作对象和可访问名称。

| 规则 ID | 规则 |
| --- | --- |
| FS-RECOVERY-01 | 每个非 ready 状态必须声明零个或多个 `recoveryActions`；若没有恢复入口，必须说明原因。 |
| FS-RECOVERY-02 | 重试必须说明重试范围：当前区域、当前查询、失败文件、失败任务、权限复核或完整页面。 |
| FS-RECOVERY-03 | 清空筛选和恢复默认条件必须读取 Query Filter owner；不得直接清空强制条件或敏感条件。 |
| FS-RECOVERY-04 | 申请权限、重新认证和返回入口必须保留当前安全上下文，不得泄露被拒绝资源。 |
| FS-RECOVERY-05 | 恢复按钮的 loading、防重复、禁用原因和结果回执遵循 Button owner。 |

对应验收：FS-A6、FS-A9、FS-A10。

## FS-PERM 权限、安全和敏感信息

无权限、权限降级、租户/工作区切换和范围变化时，反馈状态必须先保护敏感信息。无权状态不得泄露对象名称、数量、字段、文件名、筛选值、错误明细、旧 option label 或内部 ID。若旧内容无法证明仍可见，应隐藏、失效或替换为安全 placeholder。

| 规则 ID | 规则 |
| --- | --- |
| FS-PERM-01 | 权限/租户/工作区变化后，无法同步证明仍可见的内容、数量、操作、下载和恢复入口必须隐藏或替换为安全说明。 |
| FS-PERM-02 | 无权状态不得泄露对象名称、数量、字段、文件名、筛选值或错误明细。 |
| FS-PERM-03 | 只读状态和禁用能力必须说明原因和恢复路径；禁用原因不能只放在 hover tooltip。 |
| FS-PERM-04 | 若解释原因会泄露敏感信息，应显示安全说明和申请路径，不展示具体对象。 |
| FS-PERM-05 | 权限变化导致状态切换时，焦点只迁移一次到安全说明、恢复入口或页面标题；旧回调不得抢焦点。 |

对应验收：FS-A7、FS-A8、FS-A10。

## FS-A11Y 可访问性与公告

状态变化需要可感知但不重复的公告。区域应使用恰当的 `aria-busy`、可聚焦错误容器、描述关联、按钮可访问名称和焦点策略。完整错误消息不能同时被 Toast、Alert、结果区和 live region 重复播报。

| 规则 ID | 规则 |
| --- | --- |
| FS-A11Y-01 | 加载区域设置可观察 busy 状态；完成、失败、空态和部分结果由唯一 owner 公告。 |
| FS-A11Y-02 | 初始错误、无权限和关键恢复状态应有可聚焦容器或明确焦点入口。 |
| FS-A11Y-03 | 重试、刷新、清空筛选、申请权限、返回和任务中心按钮必须有动作对象。 |
| FS-A11Y-04 | Skeleton、装饰插画和纯视觉 placeholder 不得进入 Tab 顺序或被读屏当作真实内容。 |
| FS-A11Y-05 | 同一完整错误或状态消息不得重复播报；摘要可以播报概览，完整内容只归一个 owner。 |

对应验收：FS-A9、FS-A10。

## FS-RSP 响应式与移动端

移动端和窄屏可以压缩插画、说明和次要操作，但移动端不得删除主要恢复入口、错误原因、状态摘要、返回路径、安全说明、清空筛选、申请权限或重试能力。低高度、虚拟键盘、安全区域和 200% 缩放下，状态文案和恢复入口必须可达。

| 规则 ID | 规则 |
| --- | --- |
| FS-RSP-01 | 移动端不得删除重试、刷新、清空筛选、申请权限、返回、任务中心或查看错误等主要恢复入口。 |
| FS-RSP-02 | 窄屏可压缩插画和长说明，但状态类型、错误原因、安全说明和下一步不能消失。 |
| FS-RSP-03 | 虚拟键盘、低高度、动态 viewport、四向 safe area 和 200% 缩放下，恢复入口不能被固定区或键盘完全遮挡。 |
| FS-RSP-04 | 移动端状态变化后的焦点和公告仍只执行一次，不能因 Drawer/页面转换重复播报。 |

对应验收：FS-A9、FS-A10。

## 可执行验收检查

下列检查以可观察状态、DOM 属性、焦点日志、公告日志和结果快照断言；未实际执行时必须报告为**未验证**及所需环境。

1. **状态模型和优先级**：记录 `feedbackState` 全字段。分别触发首次加载、刷新、空数据源、筛选无结果、无权限、部分结果、未知结果和刷新失败；断言状态不是 `loading/error/empty` 三个布尔值组合，且每次只有一个 primary feedback owner。
2. **首次加载、刷新和 skeleton**：首次加载无内容时显示 skeleton 或进度；刷新已有内容时保留旧内容并设置 stale/refreshing。Skeleton 不包含可操作假数据、假按钮、假复选框、假链接或真实文本，不进入 Tab 顺序。
3. **加载终止和公告去重**：长加载有可见状态和适当公告；重复刷新公告去重；取消或离开只表示客户端停止等待，不把服务端任务写成已结束。Loading 必须在有限路径进入 ready、empty、zero-results、error、partial、unknown 或 permission。
4. **空态区分和下一步**：构造数据源为空、当前筛选无结果、未配置、仅归档、权限过滤为空；断言文案和恢复入口不同。筛选无结果提供调整、清空可清空条件或恢复默认条件；数据源为空只在有权限时提供创建、导入或配置 CTA。
5. **错误、stale 和部分结果**：首次加载失败替代内容；刷新失败保留旧内容并标记 stale；操作失败不覆盖整个结果区域，除非结果不可继续信任。部分结果展示成功、失败、缺失范围和恢复入口；未知结果提供检查状态、任务中心或支持路径。
6. **恢复入口和 Toast 边界**：网络失败、服务不可用、认证失败、权限失败、冲突、筛选无结果和未知任务分别提供匹配恢复入口。Toast 不能作为唯一错误或结果回执；区域内必须有可见状态或恢复路径。重试范围和按钮动作对象明确。
7. **权限和敏感信息保护**：在 ready、empty、zero-results、refresh-error 和 partial 状态切换权限、租户/工作区和角色；断言旧内容、数量、对象名、字段、文件名、筛选值、错误明细、下载和恢复入口被隐藏或替换安全说明。无权状态不泄露具体对象。
8. **只读与禁用能力**：无创建、导入、配置或恢复权限时，空态不展示不可执行主 CTA；只读和禁用能力说明原因与申请路径，原因不只放在 hover tooltip，且不泄露敏感信息。
9. **可访问性与移动端**：检查 `aria-busy`、可聚焦错误容器、描述关联、按钮可访问名称、焦点迁移一次、公告去重和 skeleton 不可聚焦。在移动窄屏、200% 缩放、字体放大、低高度、动态 viewport、虚拟键盘、四向 safe area 和触摸输入下，断言错误原因、状态摘要、重试、刷新、清空筛选、申请权限、返回、任务中心和查看错误入口可达。
10. **运行时报告边界**：浏览器、屏幕阅读器、触摸设备、真实业务组件、缩放和移动端检查未实际执行时，最终报告必须逐项标为**未验证**，并写明所需浏览器、设备/viewport、输入方式及辅助技术环境；不得将静态文档审计写成运行时通过。
