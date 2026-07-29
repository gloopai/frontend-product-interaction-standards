# 通知中心、站内信与公告交互规范

适用于通知中心、消息中心、站内信、消息列表、未读角标、系统公告、运营公告、维护公告、发布公告、通知设置、通知偏好、订阅偏好、邮件通知、短信通知、Push 通知、Webhook 通知、通知点击、通知详情、全部已读、标记已读/未读、归档通知、删除通知和退订通知。本文件是持久通知、公告、投递渠道和订阅偏好的前端产品交互 owner。

Toast、Snackbar、Alert、Banner 和轻量 Notification 读取 [全局反馈与通知交互规范](global-feedback.md)；普通设置页草稿、保存、生效和未保存保护读取 [设置、偏好与配置页交互规范](settings-preferences-configuration.md)；点击跳转、返回和深链读取 [导航与路由交互规范](navigation-routing.md)；权限、租户/工作区和无泄露读取 [权限、租户与可见性交互规范](permissions-tenancy-visibility.md)；高影响批量、退订、清空和强制公告关闭读取 [危险操作与恢复交互规范](risk-actions.md)；审计证据读取 [审计日志与操作历史交互规范](audit-log-activity-history.md)；管理台整体治理读取 [管理台完整治理交互规范](admin-console.md)。兼容规则全部执行；一方更严格且不冲突时，执行更严格规则。

## 场景与状态模型

每个通知中心、站内信列表、公告承载或通知偏好入口维护 `notificationCenterState`：

| 字段 | 语义 |
| --- | --- |
| `notificationOwnerId` | 当前通知中心、公告或偏好 owner 稳定身份，绑定列表、角标、点击、设置、请求和审计。 |
| `notificationIdentity` | 通知稳定 ID、类型、来源 owner、事件版本、投递版本、租户/工作区和目标对象快照。 |
| `recipientBoundary` | 接收人、角色、租户/工作区、权限版本、订阅状态、偏好版本和渠道可达性。 |
| `messageState` | `unread`、`read`、`archived`、`deleted`、`expired`、`hidden-by-permission` 或 `unknown`。 |
| `deliveryChannelState` | `in-app`、`email`、`sms`、`push`、`webhook`、`muted`、`disabled`、`failed` 或 `unknown`。 |
| `announcementState` | 公告范围、生效时间、过期时间、强制阅读、可关闭策略、显示频率和遮挡边界。 |
| `clickTargetBinding` | 点击目标路由、对象快照、来源上下文、权限复核、目标过期和恢复策略。 |
| `preferenceState` | 通知分类、订阅偏好、渠道偏好、静默策略、草稿/已保存/生效值和偏好版本。 |
| `badgeState` | 未读数、分类计数、是否估算、刷新时间、权限过滤和旧计数失效策略。 |
| `riskBinding` | 全部已读、批量归档、删除通知、退订、强制公告关闭等动作的风险或确认 owner 绑定。 |
| `permissionBoundary` | 查看通知、点击目标、修改偏好、批量操作、查看审计和公告详情所需权限版本。 |
| `auditBinding` | 通知生成、投递、阅读、点击、归档、删除、退订、公告展示和未知结果的审计身份。 |
| `resultReceipt` | 成功、失败、部分成功、未知、权限拒绝、目标不可用、渠道失败和审计回执。 |

持久通知、系统公告、运营公告、通知中心列表、外部投递渠道和通知偏好可以在同一产品入口下出现，但状态 owner 必须分开。不得用一个普通 Dropdown、一条 Toast 或一个布尔 `hasUnread` 同时表达消息身份、未读数、投递渠道、点击目标、公告范围、偏好版本和审计结果。

## NMA-SCOPE 范围与 owner 边界

| 规则 ID | 规则 |
| --- | --- |
| NMA-SCOPE-01 | 通知中心、消息中心、站内信、公告、未读角标、通知偏好和外部通知渠道必须声明 `notificationCenterState`。 |
| NMA-SCOPE-02 | 本 owner 只定义前端产品交互：消息身份、接收边界、已读状态、点击目标、公告展示、渠道偏好、结果回执、权限和审计；不定义通知服务后端、provider、模板、队列、频控或营销投放系统。 |
| NMA-SCOPE-03 | Toast、Snackbar、Alert、Banner 和轻量 Notification 只可作为辅助提醒；完整消息记录、恢复、审计和偏好必须归本 owner 或相邻 owner。 |
| NMA-SCOPE-04 | 通知设置页的字段草稿、保存和未保存保护归设置 owner；通知分类、渠道可达性、订阅语义和投递结果归本 owner。 |

对应验收：NMA-A1、NMA-A2。

## NMA-STATE 通知身份、接收边界和状态

| 规则 ID | 规则 |
| --- | --- |
| NMA-STATE-01 | 每条持久通知必须绑定 `notificationIdentity`、目标对象快照、来源 owner、事件版本、投递版本、租户/工作区和 `auditBinding`。 |
| NMA-STATE-02 | 每条通知必须绑定 `recipientBoundary`：接收人、角色、权限版本、租户/工作区、订阅状态、偏好版本和渠道可达性。 |
| NMA-STATE-03 | `messageState` 的 `unread`、`read`、`archived`、`deleted`、`expired`、`hidden-by-permission` 和 `unknown` 必须分开。标记已读不等于归档；归档不等于删除；删除通知不等于删除目标对象；关闭公告不等于已读所有相关消息。 |
| NMA-STATE-04 | 未读数必须绑定 `badgeState`，包含计数来源、分类、权限过滤、刷新时间、是否估算和失效策略。未读角标不能只从当前可见列表长度推断。 |
| NMA-STATE-05 | 权限、租户/工作区、对象状态、事件版本、投递版本、偏好版本、会话或渠道状态变化后，旧通知、旧未读数和旧状态必须失效或重算。 |

对应验收：NMA-A1、NMA-A3、NMA-A7。

## NMA-FEEDBACK 持久通知不是 Toast

持久通知不是 Toast。Toast 可以提示“有新消息”，但不能成为唯一消息记录、唯一恢复入口、唯一审计入口或唯一错误说明。

| 规则 ID | 规则 |
| --- | --- |
| NMA-FEEDBACK-01 | 需要用户稍后处理、跨页面查看、追踪、审计或恢复的通知必须进入持久 owner，不能只用 Toast、Snackbar、Message 或轻量 Notification 承载。 |
| NMA-FEEDBACK-02 | Toast / Notification 关闭只关闭客户端提醒，不代表通知已读、归档、删除、退订、公告已关闭或外部渠道停止投递。 |
| NMA-FEEDBACK-03 | 部分成功、未知结果、权限拒绝、目标不可用、渠道失败、公告受限和偏好保存失败不得只出现在自动消失 Toast 中。 |
| NMA-FEEDBACK-04 | Toast、Banner 或公告与通知中心同时出现时，必须通过 `notificationIdentity` 或 `resultReceipt` 去重或说明关系，不能重复播报冲突状态。 |

对应验收：NMA-A2、NMA-A8。

## NMA-CLICK 通知点击和旧入口失效

通知点击不是普通链接；点击前必须复核权限、目标对象状态、租户/工作区、来源上下文和目标路由是否仍安全。

| 规则 ID | 规则 |
| --- | --- |
| NMA-CLICK-01 | `clickTargetBinding` 必须包含目标路由、对象快照、来源上下文、权限版本、目标过期策略和恢复路径。 |
| NMA-CLICK-02 | 点击通知、邮件入口、短信入口、Push deep link、Webhook 通知入口或公告详情前，必须复核权限、租户/工作区、会话、对象状态和目标路由。 |
| NMA-CLICK-03 | 旧通知、旧点击链接、旧邮件入口、旧 Push deep link、旧公告、旧 Toast/Notification 和旧未读角标必须在权限、租户/工作区、对象状态、事件版本、投递版本、偏好版本、会话或渠道状态变化后失效或重算。 |
| NMA-CLICK-04 | 目标对象已删除、过期、隐藏、无权限或跨租户时，不得直接跳到错误页面；必须提供安全说明、返回通知中心、刷新、申请权限或查看审计等恢复路径。 |

对应验收：NMA-A4、NMA-A7、NMA-A9。

## NMA-PREF 偏好、订阅和渠道投递

保存偏好成功不等于邮件、短信、Push 或 Webhook 通知真实可达。

| 规则 ID | 规则 |
| --- | --- |
| NMA-PREF-01 | `preferenceState` 必须区分草稿偏好、已保存偏好、生效偏好、偏好版本、通知分类、渠道偏好、静默策略和退订状态。 |
| NMA-PREF-02 | `deliveryChannelState` 必须区分 `in-app`、`email`、`sms`、`push`、`webhook`、`muted`、`disabled`、`failed` 和 `unknown`。渠道不可达不能伪装成偏好保存失败，也不能把偏好保存成功伪装成渠道投递成功。 |
| NMA-PREF-03 | 退订、重新订阅、关闭安全通知、关闭高影响业务通知、修改强制渠道和影响审计或安全恢复的偏好必须进入 `risk-actions.md`。 |
| NMA-PREF-04 | 通知设置页保存成功后，应说明偏好何时生效、影响哪些通知分类、哪些渠道不可用、是否需要重新授权系统通知，以及如何恢复默认或重新订阅。 |

对应验收：NMA-A5、NMA-A8。

## NMA-ANN 公告展示和遮挡边界

系统公告、维护公告、发布公告、运营公告和强制阅读公告必须维护 `announcementState`。

| 规则 ID | 规则 |
| --- | --- |
| NMA-ANN-01 | 公告必须声明范围、生效时间、过期时间、可关闭策略、显示频率、优先级、详情入口和遮挡边界。 |
| NMA-ANN-02 | 公告 Banner、Modal、Drawer 或顶部条不能遮挡 Dialog/Drawer 底部操作、危险确认、表单错误、支付确认、导出下载、任务取消、导航返回或安全区域。 |
| NMA-ANN-03 | 强制公告必须说明为什么不可关闭、何时恢复、是否影响当前任务和如何查看详情。不可关闭不能由组件默认行为或 Agent 自行决定。 |
| NMA-ANN-04 | 关闭公告只代表当前公告实例的客户端展示状态，不能隐式标记全部消息已读，也不能隐藏未完成的强制维护影响。 |

对应验收：NMA-A6、NMA-A9。

## NMA-PERM 权限、隐私和敏感信息

无权限用户不得通过通知标题、摘要、图标、未读数、分类、错误、空态、DOM/ARIA、邮件预览、短信文案、Push 文案、下载链接、点击目标或审计摘要推断对象名称、金额、成员、邮箱、发票编号、文件名、密钥、payload、内部 ID、外部对象或旧缓存。

| 规则 ID | 规则 |
| --- | --- |
| NMA-PERM-01 | 通知标题、摘要、角标、分类、图标、空态、错误、DOM、ARIA、外部渠道文案和审计摘要均必须执行无泄露规则。 |
| NMA-PERM-02 | 权限、租户/工作区、会话、对象状态、通知版本、偏好版本或渠道状态变化后，旧通知列表、旧角标、旧筛选、旧点击目标、旧公告、旧偏好控件、旧 Toast/Notification、旧审计跳转、旧焦点目标和旧 ARIA 引用必须失效或重算。 |
| NMA-PERM-03 | 隐藏通知、禁用点击、只读公告、无权限详情、渠道不可用和偏好不可改必须区分，不得合并成一个灰色不可点状态。 |
| NMA-PERM-04 | 邮件预览、短信摘要、Push 横幅和系统通知 deep link 在锁屏、共享设备、无权限或会话过期场景下必须使用安全文案或安全跳转。 |

对应验收：NMA-A7、NMA-A9。

## NMA-RISK 批量、清空、退订和未知结果

全部已读、批量标记已读/未读、批量归档、删除通知、清空通知、退订通知、恢复订阅和关闭强制公告必须说明范围、数量、分类、权限版本、目标快照、请求身份、结果回执和未知结果处理。

| 规则 ID | 规则 |
| --- | --- |
| NMA-RISK-01 | 高影响或不可恢复批量动作必须进入 `risk-actions.md`，确认前请求数为 0。 |
| NMA-RISK-02 | 未知结果不能伪装成已读成功、归档成功、删除成功、退订成功、公告关闭成功或偏好保存成功。 |
| NMA-RISK-03 | 部分成功必须展示成功数、失败数、未知数、失败分类、权限变化、恢复路径、审计回执和可重试范围。 |
| NMA-RISK-04 | 删除通知、清空通知和归档通知不得暗示目标对象被删除或业务任务已完成。 |

对应验收：NMA-A8。

## NMA-RSP 移动端和跨端一致性

移动端不得删除通知分类、未读/已读状态、未读角标含义、筛选、标记已读/未读、归档、退订/偏好入口、公告详情、点击恢复、权限说明、审计入口和错误恢复路径。

| 规则 ID | 规则 |
| --- | --- |
| NMA-RSP-01 | 通知中心在移动端可以转换为 Drawer、Bottom Sheet、独立页或分组列表，但核心通知分类、状态、恢复和偏好能力必须保留。 |
| NMA-RSP-02 | 低高度、虚拟键盘、安全区域、系统字体放大、浏览器 Back、WebView 返回、系统通知 deep link 和触摸长按后，通知内容、分类、点击目标、偏好保存、公告关闭、错误摘要和恢复入口仍必须可达。 |
| NMA-RSP-03 | 移动端公告不得遮挡底部主操作、危险确认、表单错误、导航返回、任务取消、下载领取、虚拟键盘输入或 safe-area。 |
| NMA-RSP-04 | 系统通知 deep link 从后台进入时，必须先重建会话、权限、租户/工作区和目标状态，再决定跳转、展示安全说明或回到通知中心。 |

对应验收：NMA-A9。

## 可执行验收检查

下列检查以通知状态、DOM/ARIA、路由日志、权限快照、偏好版本、渠道状态、审计记录和结果回执断言；未实际执行时必须报告为**未验证**并说明所需环境。

1. **状态模型**：记录 `notificationCenterState`，断言 `notificationOwnerId`、`notificationIdentity`、`recipientBoundary`、`messageState`、`deliveryChannelState`、`announcementState`、`clickTargetBinding`、`preferenceState`、`badgeState`、`riskBinding`、`permissionBoundary`、`auditBinding` 和 `resultReceipt` 均存在。
2. **Toast 边界**：构造只用 Toast 表示新消息、已读成功、渠道失败、权限拒绝和未知结果的实现，断言失败；持久通知、恢复和审计入口必须可达。
3. **已读状态**：执行标记已读、标记未读、全部已读、归档、删除、关闭公告；断言 `read`、`unread`、`archived`、`deleted`、`expired`、`hidden-by-permission` 和 `unknown` 不混用。
4. **通知点击**：从站内通知、邮件入口、短信入口、Push deep link、Webhook 通知入口和公告详情跳转；断言点击前复核权限、租户/工作区、会话、对象状态、目标路由和来源上下文。
5. **偏好和渠道**：保存通知偏好、退订、重新订阅、关闭渠道、打开 Push；断言偏好保存、偏好生效、渠道可达和真实投递结果分开表达。
6. **公告遮挡**：在 Dialog、Drawer、风险确认、表单错误、支付确认、导出下载、任务取消和导航返回同时存在时显示公告；断言公告不遮挡关键操作、安全区域或错误恢复。
7. **权限无泄露**：切换权限、租户/工作区、会话、对象状态、偏好版本和渠道状态；断言旧通知、旧角标、旧点击、旧公告、旧 Toast/Notification、旧 DOM/ARIA、旧外部渠道文案和旧审计跳转失效或重算。
8. **批量和未知结果**：执行全部已读、批量归档、删除通知、清空通知、退订通知、恢复订阅和关闭强制公告；断言确认前请求数为 0，高影响动作进入风险 owner，未知和部分成功不伪装成成功。
9. **移动端和 deep link**：在窄屏、低高度、横屏、虚拟键盘、字体放大、安全区域、WebView 返回和系统通知 deep link 下验证通知分类、状态、偏好、公告详情、点击恢复、权限说明、审计入口和错误恢复均可达。
10. **运行时报告边界**：浏览器、移动端设备、屏幕阅读器、真实邮件/短信/Push/Webhook 投递、真实系统通知 deep link、真实权限切换、真实会话过期、真实公告展示、真实偏好保存和真实审计写入未实际执行时，必须标为**未验证**。

## 参考资料

- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [WAI-ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
