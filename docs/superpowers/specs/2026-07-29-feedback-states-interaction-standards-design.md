# 反馈状态与状态承载规范设计

## 背景

当前规范已经覆盖 Dialog、Drawer、表单、表格、查询筛选、记录编辑、按钮、上传导入、响应式和管理台治理。很多 owner 都提到了 loading、empty、error、stale、permission denied 或 Toast 不得作为唯一回执，但这些状态还没有一个统一的页面/区域级 owner。结果业务项目里常见问题仍会反复出现：首次加载骨架像真实数据、刷新失败直接清空旧结果、筛选无结果和数据源为空都写“暂无数据”、无权限泄露对象名、错误只 Toast、重试按钮没有上下文、空状态没有下一步、加载和错误状态互相覆盖。

这些问题不是单个表格、表单或按钮能完全负责的；它们属于“用户当前看见的是哪个状态、这个状态由谁拥有、下一步是什么”的体验层。新增一个 `feedback-states.md` owner，可以统一页面区域的加载、空态、错误、过期、无权限、只读、部分结果和恢复入口。

## 目标

- 新增 `references/feedback-states.md`，覆盖页面/区域级 loading、skeleton、empty、zero-results、error、refresh-error、stale、permission-denied、read-only、partial-result 和 recovery。
- 区分数据源为空、筛选无结果、无权限、加载失败、刷新失败、部分成功、任务未知结果和离线/弱网状态。
- 明确反馈状态的 primary owner、可见文本、可访问公告、重试/恢复入口、旧内容保留和敏感信息边界。
- 与 Data Table、Query Filter、Form、Button、Admin Console、Upload/Import 和 Responsive owner 组合，不重复它们的局部状态。
- 建立 RED/GREEN 文档压力测试和结构化审计，确保常见反馈状态违规可被抓住。

## 非目标

- 不定义品牌插画、空态图片风格、图标库、具体色值、动效 token 或 skeleton 视觉 token。
- 不替代表格、表单、上传导入、管理台任务、按钮或 Dialog/Drawer 的具体交互 owner。
- 不覆盖全局消息中心、复杂通知规则、站内信、邮件通知或运营公告系统。
- 不规定框架、组件库或埋点实现方式。

## 推荐方案

采用独立 Feedback States owner，聚焦页面/区域状态呈现与恢复路径。

### 方案对比

| 方案 | 优点 | 缺点 | 结论 |
| --- | --- | --- | --- |
| 独立 `feedback-states.md` owner | 能统一 loading/empty/error/stale/permission 的语义和恢复；适用于所有页面区域。 | 需要新增路由和审计，并写清与已有 owner 边界。 | 推荐。 |
| 继续分散到 Data Table、Form、Admin 等 owner | 不新增文件。 | 规则重复且遗漏非表格区域；错误只 Toast、空态混淆等跨场景问题无统一入口。 | 不采用。 |
| 做成视觉设计系统规范 | 能统一视觉。 | 范围偏视觉 token，不能解决状态 owner、恢复路径和安全边界。 | 不采用。 |

## 首版范围

首版覆盖：

- 页面主内容区、列表/表格结果区、卡片列表、报表区域、详情区域、设置区域、任务结果区、上传/导入结果区。
- 首次加载、刷新中、骨架屏、空数据集、筛选无结果、加载失败、刷新失败、过期数据、部分结果、无权限、只读/禁用能力、未知结果和恢复入口。
- 区域内 Alert、Inline Error、Empty State、Skeleton、Retry、Refresh、Clear Filters、Request Access、Go Back 等状态交互。
- PC、移动端、键盘、屏幕阅读器、缩放、低高度、虚拟键盘和安全区域。

暂不覆盖：

- 全局通知中心、站内信、营销公告、邮件/短信/Push 通知。
- 视觉插画、图标、颜色和 skeleton 具体样式。
- 业务文案语气指南的完整体系。

## 核心设计

### 1. 状态 owner 与优先级

每个可独立加载或恢复的页面区域维护 `feedbackState`，至少包含 `ownerId`、`surfaceKind`、`phase`、`dataPresence`、`errorKind`、`permissionScope`、`stale`、`partial`、`messageOwner`、`recoveryActions`、`announcementPolicy` 和 `sensitiveBoundary`。状态不能只散落在 `loading`、`error`、`empty` 三个布尔值里。

状态优先级必须可解释：权限/安全收敛优先于普通空态；首次加载失败不同于刷新失败；筛选无结果不同于数据源为空；部分结果不同于完全成功；未知结果不得伪装成成功或失败。一个区域同一时刻只能有一个 primary feedback owner，避免 Toast、空态、Alert 和结果区互相打架。

### 2. Loading 与 Skeleton

首次加载且没有可用内容时可用 skeleton、进度或 placeholder；刷新已有内容时应保留旧内容并标记 refreshing/stale，而不是清空成空白 skeleton。Skeleton 必须近似最终结构，但不得包含可操作假数据、假按钮、假复选框或会被读屏误认为真实内容的文本。

Loading 状态必须有开始、持续和终止路径。长加载需要可见状态和适当公告；重复刷新需要去重；取消或离开只表示客户端停止等待，不能假装服务端任务结束。

### 3. Empty 与 Zero Results

空状态至少区分 `empty-dataset`、`zero-results`、`not-configured`、`not-created-yet`、`archived-only` 和 `permission-filtered-empty`。筛选无结果必须展示当前条件影响，并提供调整筛选、清空可清空条件或恢复默认条件入口。数据源本身为空应提供创建、导入、配置或了解更多等与能力相符的下一步；只读或无权限时不能展示不可执行主操作。

空状态不能用“暂无数据”糊住所有情况，也不能为了好看放一个无效 CTA。若用户没有创建权限，空态应解释可见范围和可申请路径，而不是给“新增”按钮。

### 4. Error、Stale 与 Recovery

错误状态必须区分首次加载失败、刷新失败、操作失败、权限失败、网络失败、服务不可用、数据延迟、冲突和未知结果。首次加载失败且没有可用内容时，区域内错误取代内容；刷新失败时保留旧内容，显示 stale 说明和重试入口；操作失败归操作 owner，不应覆盖整个结果区域，除非结果本身不可继续信任。

恢复入口必须与错误类型匹配：重试、刷新、检查状态、重新认证、申请权限、返回上一步、清空筛选、进入任务中心或联系支持。Toast 不能作为唯一错误或结果回执。

### 5. 权限与敏感信息

无权限、权限降级、租户/工作区切换和范围变化时，反馈状态必须先保护敏感信息。无权状态不得泄露对象名称、数量、字段、文件名、筛选值或错误明细。若旧内容无法证明仍可见，应隐藏、失效或替换为安全 placeholder。

只读状态和禁用能力必须说明原因和可恢复路径。禁用原因不能只放在 hover tooltip；若展示原因会泄露敏感信息，应改为安全说明。

### 6. 可访问性与响应式

状态变化需要可感知但不重复的公告。Loading、error、empty、stale、partial 和 success/unknown 等状态由唯一 owner 公告；完整错误消息不能同时被 Toast、Alert、结果区和 live region 重复播报。区域应使用恰当的 `aria-busy`、可聚焦错误容器、描述关联和按钮可访问名称。

移动端和窄屏可以压缩插画、说明和次要操作，但不能删除错误原因、状态摘要、主要恢复入口、返回路径或安全说明。低高度、虚拟键盘、安全区域和 200% 缩放下，状态文案、重试、清空筛选、申请权限和返回入口必须可达。

## 与现有 owner 的关系

- `data-tables.md`：表格结果区的首次加载、刷新失败、空结果和 stale 继续执行 Data Table 查询规则；Feedback owner 统一状态文案、恢复入口和跨区域优先级。
- `query-filters.md`：筛选无结果、清空筛选、恢复默认条件读取 Query Filter；Feedback owner 负责 zero-results 体验和下一步。
- `forms.md`：字段/表单错误归 Form；Feedback owner 只处理区域级或页面级错误。
- `buttons.md`：重试、刷新、清空筛选、申请权限、返回、创建和导入按钮遵循 Button 规范。
- `uploads-imports.md`：上传/导入部分成功、错误明细、未知结果读取 Upload/Import；Feedback owner 统一结果状态呈现。
- `admin-console.md`：权限、租户、审计、任务中心和 Toast 不得唯一回执等治理继续归 Admin；Feedback owner 补充页面区域状态体验。
- `responsive-adaptive.md`：跨端可达、缩放和安全区域仍归 Responsive；Feedback owner 声明状态与恢复不能消失。

## 新 owner 草案结构

计划新增 `references/feedback-states.md`：

1. 范围与术语
2. 与组件 owner 的关系
3. `feedbackState` 状态模型
4. 状态优先级和 primary owner
5. Loading、Skeleton 和刷新
6. Empty、Zero Results 和下一步
7. Error、Stale、Partial 和 Unknown
8. Recovery Actions 恢复入口
9. 权限、安全和敏感信息
10. 可访问性、公告和响应式
11. 可执行验收

稳定规则族建议：

- `FS-SCOPE-*`：范围、术语和非目标。
- `FS-STATE-*`：feedbackState、phase、owner 和优先级。
- `FS-LOAD-*`：首次加载、刷新、Skeleton、旧内容保留和去重公告。
- `FS-EMPTY-*`：empty-dataset、zero-results、not-configured、permission-filtered-empty。
- `FS-ERROR-*`：initial-error、refresh-error、operation-error、stale、partial、unknown。
- `FS-RECOVERY-*`：重试、刷新、清空筛选、申请权限、任务中心和返回。
- `FS-PERM-*`：无权限、权限降级、敏感信息保护和只读原因。
- `FS-A11Y-*`：aria-busy、live region、焦点、错误容器和重复公告。
- `FS-RSP-*`：移动端、缩放、虚拟键盘、安全区域和操作可达。

## 路由更新

`SKILL.md` 增加触发：

- 中文：空状态、空态、暂无数据、无结果、筛选无结果、加载、加载中、骨架屏、placeholder、错误状态、刷新失败、加载失败、重试、过期数据、部分结果、无权限状态、只读状态。
- 英文：empty state、zero results、no data、loading state、skeleton、placeholder、error state、refresh error、load error、retry state、stale data、partial result、permission denied state、read-only state。

`README.md` 与 `HANDOFF.md` 增加摘要和链接，但不复制 owner 细节。

## 测试与验证策略

采用 RED/GREEN 文档压力测试：

- RED：在没有 Feedback States owner 的情况下，让 fresh 输出列表、报表、详情页、上传导入结果、无权限页和移动端空态设计，记录是否出现所有空态都叫暂无数据、错误只 Toast、刷新失败清空旧数据、skeleton 假操作、无权限泄露对象、移动端删除恢复入口等问题。
- GREEN：启用 owner 后，同样任务必须声明 `feedbackState`、状态优先级、loading/refresh 区分、empty/zero-results 区分、错误类别、stale、recoveryActions、敏感边界、公告策略和运行时验证边界。
- 审计脚本：检查 owner 规则、路由、状态字段、Toast-only 禁止、刷新失败保留旧内容、空态区分、无权限不泄露、skeleton 不可操作、移动端恢复入口和未验证边界。

关键 mutation：

- 把 `feedbackState` 降级为 loading/error/empty 三个布尔值，必须失败。
- 删除首次加载与刷新失败区分，必须失败。
- 让 skeleton 包含可操作假数据，必须失败。
- 把筛选无结果和数据源为空共用“暂无数据”，必须失败。
- 空态提供无权限用户不可执行 CTA，必须失败。
- 错误只用 Toast 表示，必须失败。
- 刷新失败清空旧内容，必须失败。
- 无权限状态泄露对象名称、数量或字段，必须失败。
- 移动端删除重试、清空筛选、申请权限或返回入口，必须失败。
- 把浏览器/移动端/辅助技术运行时写成已验证，必须失败。

## 验收标准

- Feedback States owner 首版范围清晰，覆盖加载、空态、错误、过期、部分结果、权限和恢复入口。
- 与 Data Table、Query Filter、Form、Button、Upload/Import、Admin Console 和 Responsive owner 边界不冲突。
- README/HANDOFF/SKILL 只做摘要和路由，不复制 owner 细节。
- RED/GREEN 输出和审计 mutation 能覆盖核心反例。
- 未执行浏览器、屏幕阅读器、触摸设备或真实组件运行时时，所有证据必须标为未验证。
