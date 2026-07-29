# 通知中心、站内信与公告交互规范设计

## 背景

管理台常见通知中心、站内信、消息列表、未读角标、系统公告、运营公告、维护公告、邮件通知、短信通知、Push 通知、Webhook 通知、通知订阅偏好和消息点击跳转。它们经常被做成一个铃铛 Dropdown、一张消息列表、一个“全部已读”按钮、一个公告 Banner，或者直接复用 Toast/Notification。这个做法很容易出问题：Toast 被当成持久通知；旧通知在权限降级后仍泄露对象名称或金额；未读数和消息列表不同步；通知点击跳到已删除或无权限对象；公告遮挡 Dialog/Drawer 的关键操作；邮件/短信/Push 偏好保存成功被写成真实送达成功；移动端把通知分类、已读、恢复、审计和退订入口藏掉。

现有规范已覆盖部分边界：

- `global-feedback.md` 负责 Toast、Snackbar、Alert、Banner、Notification 等短暂或跨区域轻量反馈，并明确不覆盖站内信系统、完整消息中心、邮件/短信/Push 通知、运营公告投放、订阅偏好和通知服务后端实现。
- `feedback-states.md` 负责页面区域状态、空态、错误、权限和恢复。
- `navigation-routing.md` 负责通知点击后的来源上下文、返回策略、深链、浏览器历史和权限跳转。
- `permissions-tenancy-visibility.md` 负责权限、租户/工作区、无泄露、旧入口失效和旧缓存清理。
- `audit-log-activity-history.md` 负责可追踪通知动作、审计入口和无权限审计不泄露。
- `settings-preferences-configuration.md` 负责普通通知偏好草稿、保存、生效和作用域。
- `risk-actions.md` 负责批量标记、清空、删除、退订、强制公告关闭等高影响或不可逆动作。

缺口是：没有 owner 负责“持久消息身份 + 投递渠道 + 已读状态 + 点击目标 + 公告生效窗口 + 订阅偏好”的一致性。这会导致项目实现只读 Toast/全局反馈规范，却漏掉消息中心、通知权限、旧通知失效、已读计数、公告遮挡和移动端恢复。

## 目标

- 新增“通知中心、站内信与公告” owner，覆盖 notification center、message center、inbox、announcement、unread count、read/unread、mark all read、archive/delete notification、notification preference、email/SMS/Push channel、maintenance announcement、system announcement、release announcement 和 notification click-through。
- 明确短暂反馈、持久通知、通知中心消息、系统公告、运营公告、通知订阅偏好、外部投递渠道和审计记录的边界。
- 规定通知消息身份、目标对象快照、权限版本、租户/工作区、投递渠道、已读状态、点击目标、过期策略和审计绑定。
- 规定旧通知、旧未读数、旧点击链接、旧公告、旧邮件入口、旧 Push deep link、旧 Toast/Notification 在权限、租户/工作区、对象状态、通知版本、偏好版本、会话或渠道状态变化后失效或重算。
- 禁止通过通知标题、摘要、角标、错误、空态、DOM/ARIA、邮件预览、Push 文案或审计摘要向无权限用户泄露对象名称、金额、成员、发票、密钥、文件名、内部 ID 或旧缓存。
- 规定移动端不得删除通知分类、未读/已读状态、过滤、退订/偏好入口、公告详情、恢复路径、权限说明和审计入口。

## 非目标

- 不定义通知服务后端、邮件/短信/Push provider、推送协议、发送队列、频控策略、模板渲染系统、营销系统、站内信存储、反垃圾策略、A/B 测试、运营投放平台、品牌视觉、图标、声音、震动或平台通知权限 API。
- 不替代 `global-feedback.md` 的 Toast、Snackbar、Alert、Banner 和轻量 Notification 通道选择。
- 不替代 `settings-preferences-configuration.md` 的偏好页草稿、保存、生效、作用域和未保存保护。
- 不替代 `navigation-routing.md` 的通知点击后的路由、返回和来源恢复。
- 不替代 `permissions-tenancy-visibility.md` 的权限解析、租户/工作区和无泄露。
- 不替代 `audit-log-activity-history.md` 的审计证据模型。

## 推荐方案

推荐新增独立 owner：`references/notifications-message-center-announcements.md`。

备选方案：

1. **扩展全局反馈规范。** 优点是 Toast/Notification 已在那里；缺点是该 owner 明确只管轻量反馈，若塞入完整消息中心会模糊短暂反馈和持久消息的边界。
2. **放入设置规范。** 优点是通知偏好确实像设置项；缺点是消息中心、已读状态、点击目标、公告展示和投递渠道不只是设置保存。
3. **独立 Notifications owner 协调相邻规范。** 推荐。该 owner 维护持久消息、公告、投递渠道和偏好状态；Toast 仍读 Global Feedback，偏好表单仍读 Settings，点击跳转仍读 Navigation，权限仍读 Permissions。

选择独立 owner 的理由：通知事故通常发生在“消息还在、目标已变、权限已变、点击路径仍旧、未读数还亮着”。独立 owner 能把通知身份、对象快照、权限版本、渠道状态、已读状态、点击目标、公告窗口和审计绑定到同一条状态链上。

## Owner 边界

建议新增文件：`references/notifications-message-center-announcements.md`。

建议路由关键词：

- 中文：通知中心、消息中心、站内信、通知、消息、公告、系统公告、运营公告、维护公告、发布公告、未读、已读、全部已读、标记已读、标记未读、归档通知、删除通知、通知设置、通知偏好、订阅偏好、邮件通知、短信通知、Push 通知、推送通知、通知入口、铃铛、消息角标、通知跳转、通知详情、退订通知。
- 英文：notification center、message center、inbox、notification、message、announcement、system announcement、maintenance announcement、release announcement、unread、read、mark read、mark unread、mark all read、archive notification、delete notification、notification settings、notification preferences、subscription preferences、email notification、sms notification、push notification、notification bell、badge count、notification click、notification detail、unsubscribe notification。

该 owner 维护 `notificationCenterState`，至少包含：

| 字段 | 说明 |
| --- | --- |
| `notificationOwnerId` | 当前通知中心、公告或偏好 owner 稳定身份，绑定列表、角标、点击、设置、请求和审计。 |
| `notificationIdentity` | 通知稳定 ID、类型、来源 owner、事件版本、投递版本、租户/工作区和目标对象快照。 |
| `recipientBoundary` | 接收人、角色、租户/工作区、权限版本、订阅状态、偏好版本和渠道可达性。 |
| `messageState` | `unread`、`read`、`archived`、`deleted`、`expired`、`hidden-by-permission`、`unknown`。 |
| `deliveryChannelState` | `in-app`、`email`、`sms`、`push`、`webhook`、`muted`、`disabled`、`failed`、`unknown`。 |
| `announcementState` | 公告范围、生效时间、过期时间、强制阅读、可关闭策略、显示频率和遮挡边界。 |
| `clickTargetBinding` | 点击目标路由、对象快照、来源上下文、权限复核、目标过期和恢复策略。 |
| `preferenceState` | 通知分类、订阅偏好、渠道偏好、静默策略、草稿/已保存/生效值和偏好版本。 |
| `badgeState` | 未读数、分类计数、是否估算、刷新时间、权限过滤和旧计数失效策略。 |
| `riskBinding` | 全部已读、批量归档、删除通知、退订、强制公告关闭等动作的风险或确认 owner 绑定。 |
| `permissionBoundary` | 查看通知、点击目标、修改偏好、批量操作、查看审计和公告详情所需权限版本。 |
| `auditBinding` | 通知生成、投递、阅读、点击、归档、删除、退订、公告展示和未知结果的审计身份。 |
| `resultReceipt` | 成功、失败、部分成功、未知、权限拒绝、目标不可用、渠道失败和审计回执。 |

## 核心规则

### 持久通知不是 Toast

通知中心、站内信、消息列表和公告不能只按 Toast、Snackbar、Message 或轻量 Notification 处理。短暂反馈、持久通知、系统公告、运营公告、通知偏好、外部投递渠道和审计记录必须分开表达。

Toast 可以提示“有新消息”，但不能成为唯一消息记录、唯一恢复入口、唯一审计入口或唯一错误说明。需要用户稍后处理、跨页面查看、追踪、审计或恢复的通知必须进入持久 owner。

### 通知身份和点击目标必须绑定

每条通知必须绑定 `notificationIdentity`、`recipientBoundary`、目标对象快照、权限版本、租户/工作区、事件版本、投递版本和 `clickTargetBinding`。通知点击不是普通链接；点击前必须复核权限、目标对象状态、租户/工作区、来源上下文和目标路由是否仍安全。

旧通知、旧点击链接、旧邮件入口、旧 Push deep link、旧公告、旧 Toast/Notification 和旧未读角标必须在权限、租户/工作区、对象状态、事件版本、投递版本、偏好版本、会话或渠道状态变化后失效或重算。

### 已读、未读、归档和删除不能混合

`messageState` 的 `unread`、`read`、`archived`、`deleted`、`expired`、`hidden-by-permission` 和 `unknown` 必须分开。标记已读不等于归档；归档不等于删除；删除通知不等于删除目标对象；关闭公告不等于已读所有相关消息。

未读数必须绑定 `badgeState`：计数来源、分类、权限过滤、刷新时间、是否估算和失效策略。未读角标不能只从当前可见列表长度推断，也不能在权限降级后继续显示旧对象数量。

### 偏好保存不等于渠道投递成功

通知设置、通知偏好、订阅偏好、邮件通知、短信通知、Push 通知和静默策略必须维护 `preferenceState`。偏好草稿、已保存偏好、生效偏好、渠道可达性和实际投递结果必须分开表达。

保存偏好成功不等于邮件、短信、Push 或 Webhook 通知真实可达。渠道验证、退订、重新订阅、静默时段、频率限制和失败恢复必须说明当前状态和下一步动作。偏好页仍执行 `settings-preferences-configuration.md`；高影响退订或影响安全通知的关闭必须进入 `risk-actions.md`。

### 公告不能遮挡关键任务

系统公告、维护公告、发布公告、运营公告和强制阅读公告必须维护 `announcementState`。公告必须声明范围、生效时间、过期时间、可关闭策略、显示频率、优先级、遮挡边界和移动端承载。

公告 Banner、Modal、Drawer 或顶部条不能遮挡 Dialog/Drawer 底部操作、危险确认、表单错误、支付确认、导出下载、任务取消、导航返回或安全区域。强制公告必须说明为什么不可关闭、何时恢复、是否影响当前任务和如何查看详情。

### 权限和敏感信息不能泄露

无权限用户不得通过通知标题、摘要、图标、未读数、分类、错误、空态、DOM/ARIA、邮件预览、短信文案、Push 文案、下载链接、点击目标或审计摘要推断对象名称、金额、成员、邮箱、发票编号、文件名、密钥、payload、内部 ID、外部对象或旧缓存。

权限、租户/工作区、会话、对象状态、通知版本、偏好版本或渠道状态变化后，旧通知列表、旧角标、旧筛选、旧点击目标、旧公告、旧偏好控件、旧 Toast/Notification、旧审计跳转、旧焦点目标和旧 ARIA 引用必须失效或重算。

### 批量和未知结果必须可恢复

全部已读、批量标记已读/未读、批量归档、删除通知、清空通知、退订通知、恢复订阅和关闭强制公告必须说明范围、数量、分类、权限版本、目标快照、请求身份、结果回执和未知结果处理。确认前请求数为 0 适用于高影响或不可恢复批量动作。

未知结果不能伪装成已读成功、归档成功、删除成功、退订成功、公告关闭成功或偏好保存成功。必须提供检查最新状态、刷新通知中心、查看审计、重试或联系支持路径。

### 移动端能力不能丢

移动端不得删除通知分类、未读/已读状态、未读角标含义、筛选、标记已读/未读、归档、退订/偏好入口、公告详情、点击恢复、权限说明、审计入口和错误恢复路径。

低高度、虚拟键盘、安全区域、系统字体放大、浏览器 Back、WebView 返回、系统通知 deep link 和触摸长按后，通知内容、分类、点击目标、偏好保存、公告关闭、错误摘要和恢复入口仍必须可达。

## 与其他 owner 的关系

- `global-feedback.md`：负责 Toast、Snackbar、Alert、Banner、轻量 Notification 的通道选择和敏感边界；本 owner 负责持久消息中心、公告、投递渠道和订阅偏好。
- `settings-preferences-configuration.md`：负责通知偏好表单的草稿、保存、生效和未保存保护；本 owner 绑定通知分类、渠道和投递语义。
- `navigation-routing.md`：负责通知点击后的路由、来源恢复、深链、浏览器历史和无权限跳转；本 owner 提供通知身份、对象快照和点击目标。
- `permissions-tenancy-visibility.md`：负责权限、租户/工作区、无泄露和旧缓存收敛；本 owner 规定通知标题、摘要、角标、渠道文案和旧点击入口如何失效。
- `audit-log-activity-history.md`：负责通知生成、投递、阅读、点击、归档、删除、退订和公告展示的审计证据。
- `risk-actions.md`：负责高影响退订、清空通知、删除通知、关闭安全通知或强制公告关闭等风险确认。
- `data-tables.md`：负责通知列表、消息历史、公告列表和偏好记录的表格行为；本 owner 规定消息身份、状态和权限边界。

## 验收策略

后续实现新增静态审计 `docs/testing/notifications-message-center-announcements/notifications-message-center-announcements-audit.rb`，检查：

- `SKILL.md` 有通知中心、消息中心、站内信、公告、未读、已读、通知偏好、邮件通知、短信通知、Push 通知、notification center、message center、announcement、unread、read、notification preferences 等路由。
- `references/notifications-message-center-announcements.md` 存在并包含 `notificationCenterState`、`notificationIdentity`、`recipientBoundary`、`messageState`、`deliveryChannelState`、`announcementState`、`clickTargetBinding`、`preferenceState`、`badgeState`、权限无泄露、Toast 边界、移动端恢复和未验证边界。
- README / HANDOFF 有中文摘要。
- RED/GREEN 证据覆盖 Toast 充当持久通知、通知点击旧对象、已读/归档/删除混淆、未读数旧权限泄露、偏好保存伪装渠道投递成功、公告遮挡关键操作、无权限泄露对象名/金额/发票/密钥、批量已读未知结果伪装成功、移动端删除偏好/公告/恢复路径等负例。
- mutation 模式删除任一关键规则会失败。

运行时真实浏览器、移动端设备、屏幕阅读器、真实邮件/短信/Push/Webhook 投递、真实系统通知 deep link、真实权限切换、真实会话过期、真实公告展示、真实偏好保存和真实审计写入未执行时，必须标为**未验证**，不能把静态审计写成运行时通过。

## 设计取舍

这个 owner 的边界有意停在前端产品交互层：不定义通知服务后端、不定义邮件/短信/Push provider，也不定义运营投放策略。它强制前端证明每条通知、公告和偏好都绑定通知身份、接收边界、权限版本、渠道状态、点击目标、已读状态和审计回执。这样能防住管理台里最常见的通知事故：用户看到旧通知、点进无权限对象、未读数泄露旧数量、公告遮挡关键操作，或以为偏好保存就代表外部渠道已经真实送达。
