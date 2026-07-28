# 全局反馈与通知交互规范设计

## 背景

当前规范已经新增 `feedback-states.md`，用于页面/区域级 loading、empty、error、stale、permission 和 recovery。但业务项目里仍有另一类高频问题：把所有结果都塞进 Toast。保存失败只 Toast、删除成功只 Toast、导入部分成功只 Toast、权限不足只 Toast、异步任务创建后 Toast 消失、危险操作没有持久回执、多个 Toast 叠满屏、读屏重复播报、刷新页面后关键结果找不到。

这类问题不完全属于页面区域状态，也不等同于管理台任务中心。它需要一个独立 owner 来回答：什么时候用 Toast，什么时候用页面内 Alert，什么时候用 Banner，什么时候用 Notification，什么时候必须有持久回执或任务中心入口，以及全局反馈如何去重、排队、关闭、公告和保护敏感信息。

本设计新增 `references/global-feedback.md`，作为 Toast、Alert、Notification、Banner 和全局反馈消息的唯一事实来源。它聚焦反馈通道选择、消息生命周期、可恢复性、可访问公告、堆叠去重和安全边界。

## 目标

- 新增 `references/global-feedback.md`，覆盖 Toast、Alert、Notification、Banner、Inline Feedback、全局消息区域和通知入口的选择规则。
- 明确哪些反馈可以短暂显示，哪些必须持久呈现，哪些必须绑定区域 owner、操作 owner、任务中心或审计回执。
- 禁止 Toast 作为危险操作、部分成功、未知结果、权限失败、导入导出任务、长耗时任务和需要恢复的错误的唯一回执。
- 定义 `feedbackMessageState`，包含 messageId、channel、severity、sourceOwner、resultBinding、durationPolicy、dismissPolicy、announcementPolicy、dedupeKey、sensitiveBoundary 和 recoveryActions。
- 建立 RED/GREEN 文档压力测试和结构化审计，确保常见全局反馈违规形态可被抓住。

## 非目标

- 不覆盖站内信系统、消息中心完整产品、邮件/短信/Push 通知、运营公告投放或用户订阅偏好。
- 不定义品牌视觉、图标、颜色 token、动画曲线或具体 Toast 组件 API。
- 不替代 Feedback States、Admin Console、Button、Upload/Import、Form、Data Table 的局部 owner。
- 不规定埋点、日志平台或通知服务后端实现。

## 推荐方案

采用独立 Global Feedback owner，聚焦轻量反馈通道和持久回执边界。

### 方案对比

| 方案 | 优点 | 缺点 | 结论 |
| --- | --- | --- | --- |
| 独立 `global-feedback.md` owner | 能统一 Toast/Alert/Notification/Banner 的选择和红线；避免 Toast 滥用。 | 需要新增路由、摘要和审计，并与 Feedback States 写清边界。 | 推荐。 |
| 继续只依赖 `feedback-states.md` | 文件更少。 | 页面状态和短暂消息职责不同，Toast 队列、去重、时长和关闭策略会稀释区域状态 owner。 | 不采用。 |
| 全部放入 `admin-console.md` | 管理台场景直接。 | 非管理台表单、上传、列表也会滥用 Toast；通用性不足。 | 不采用。 |

## 首版范围

首版覆盖：

- Toast / Snackbar / Message。
- 页面内 Alert / Inline Feedback。
- 顶部 Banner / System Notice。
- Notification / 全局通知入口的轻量规则。
- 成功、失败、警告、信息、部分成功、未知结果、权限失败、任务创建、导入导出、批量操作、网络失败和恢复入口。
- 消息去重、堆叠、自动关闭、手动关闭、可访问公告、焦点与移动端可达。

暂不覆盖：

- 完整站内信、通知收件箱、订阅偏好、Push 权限申请。
- 运营公告发布系统。
- 具体组件库 API。

## 核心设计

### 1. 通道选择

Toast 只适合低风险、短文本、无需恢复、不会影响数据理解、结果已经在页面/区域中持久体现的辅助反馈。例如“已复制链接”“保存成功且表单状态已更新”。凡是需要用户稍后追踪、恢复、审计、下载、查看明细、理解权限或确认部分成功的反馈，都必须有持久 owner。

Alert / Inline Feedback 用于当前页面或区域内需要用户理解和处理的信息；Banner 用于页面级或系统级状态；Notification 可以提示跨页面事件，但不能替代任务中心、审计、错误明细或页面内回执。

### 2. 消息状态模型

每条反馈维护 `feedbackMessageState`，至少包含 `messageId`、`channel`、`severity`、`sourceOwner`、`resultBinding`、`durationPolicy`、`dismissPolicy`、`announcementPolicy`、`dedupeKey`、`sensitiveBoundary` 和 `recoveryActions`。全局反馈不能只是 `showToast(text)`。

消息必须绑定来源操作、结果、任务、区域或字段 owner。没有 owner 的消息不能承载业务结果。重复触发、迟到响应和重试结果必须按 `dedupeKey` 和 resultBinding 去重或更新，而不是不断堆叠新 Toast。

### 3. Toast 红线

Toast 不能作为以下情况的唯一反馈：

- 删除、停用、权限变更、批量修改、敏感导出等危险操作。
- 部分成功、部分失败、未知结果、冲突、需要检查状态的异步任务。
- 表单提交失败、字段错误、权限失败、认证失败、网络失败和服务不可用。
- 导入导出任务、错误明细下载、长耗时任务、可取消任务。
- 无权限、只读、数据过期、筛选无结果和页面空态。

这些场景可以附带 Toast，但必须同时提供页面内状态、结果回执、任务中心、错误摘要、Alert 或可恢复入口。

### 4. 生命周期、关闭和恢复

自动关闭只适用于低风险、无需恢复的消息。错误、警告、部分成功、未知结果、权限相关、任务相关和含恢复入口的消息不得只靠短时间自动消失。关闭 Toast 只关闭客户端消息，不得取消已发送请求、任务或结果；关闭 Notification 也不得删除审计或任务记录。

恢复入口必须可达且绑定 owner，例如“重试保存”“查看任务”“下载错误明细”“重新认证”“申请权限”“查看详情”。如果恢复入口不能放在 Toast 中，Toast 应指向持久位置。

### 5. 可访问性、堆叠和移动端

全局反馈需要可访问公告策略。状态消息不应抢焦点；需要用户处理的 Alert 应在区域内可聚焦或可导航。多个 Toast 需要限流、去重和堆叠规则，不能遮挡主操作、确认按钮、错误恢复或移动端底部安全区域。

移动端 Toast / Snackbar 不能遮挡底部主操作、危险确认、键盘输入、导航栏或安全区域。消息关闭、查看详情和恢复入口必须可触控、可键盘或有等价路径。

### 6. 安全和敏感信息

全局反馈不得泄露无权对象名称、数量、字段、文件名、筛选值、错误明细、密钥、令牌、个人识别信息或内部 ID。权限降级、租户切换或结果失效后，旧 Toast、Notification、Banner 和恢复入口必须失效或替换安全说明。

## 与现有 owner 的关系

- `feedback-states.md`：页面/区域状态、空态、错误、stale 和恢复入口归 Feedback States；Global Feedback 只管短暂或跨区域消息通道。
- `buttons.md`：Toast 中的查看详情、撤销、重试等动作遵循 Button owner。
- `forms.md`：字段错误、错误摘要和提交失败恢复归 Form；Toast 不得替代表单错误。
- `uploads-imports.md`：导入导出任务、部分成功、错误明细和未知结果归 Upload/Import；Toast 只能辅助提示。
- `admin-console.md`：危险操作、权限、审计、任务中心和全局治理归 Admin；Global Feedback 不得绕过这些 owner。
- `responsive-adaptive.md`：移动端安全区域、触摸和遮挡风险归 Responsive；Global Feedback 声明消息不能遮挡核心操作。

## 新 owner 草案结构

计划新增 `references/global-feedback.md`：

1. 范围与术语
2. 与组件 owner 的关系
3. `feedbackMessageState` 状态模型
4. 通道选择：Toast、Alert、Banner、Notification、Inline
5. Toast 红线和唯一回执禁止
6. 生命周期、关闭、自动消失和持久性
7. 去重、堆叠、顺序和迟到结果
8. 恢复入口和结果绑定
9. 安全、权限和敏感信息
10. 可访问性、公告和移动端
11. 可执行验收

稳定规则族建议：

- `GF-SCOPE-*`：范围和术语。
- `GF-STATE-*`：message state、owner、result binding。
- `GF-CHANNEL-*`：通道选择。
- `GF-TOAST-*`：Toast 允许范围和红线。
- `GF-LIFE-*`：时长、关闭、持久性。
- `GF-STACK-*`：去重、堆叠和迟到结果。
- `GF-RECOVERY-*`：恢复入口。
- `GF-PERM-*`：权限和敏感信息。
- `GF-A11Y-*`：公告、焦点和移动端。

## 路由更新

`SKILL.md` 增加触发：

- 中文：Toast、提示、全局提示、消息提示、通知、Notification、Alert、Banner、Snackbar、操作回执、结果回执、成功提示、错误提示、警告提示。
- 英文：toast、snackbar、message、notification、alert、banner、global feedback、operation receipt、result receipt、success message、error message、warning message。

`notification`、`toast`、`alert` 等词目前在管理台 owner 中只有与管理台上下文同时出现才触发；新增 owner 后，单独出现也应触发 `global-feedback.md`。

## 测试与验证策略

采用 RED/GREEN 文档压力测试：

- RED：在没有 Global Feedback owner 的情况下，让 fresh 输出保存、删除、批量操作、导入部分成功、权限失败、长任务创建和移动端 Toast 设计，记录 Toast-only、自动消失错误、无 owner 消息、重复 Toast、遮挡底部操作和敏感泄露等问题。
- GREEN：启用 owner 后，同样任务必须声明 `feedbackMessageState`、通道选择、Toast 红线、持久 owner、去重、关闭语义、恢复入口、安全边界和运行时验证边界。
- 审计脚本：检查 owner 规则、路由、状态字段、Toast-only 禁止、危险/部分成功/权限失败/任务红线、自动关闭边界、恢复入口、敏感信息、移动端遮挡和未验证边界。

关键 mutation：

- 把全局反馈降级为 `showToast(text)`，必须失败。
- 删除 resultBinding 或 sourceOwner，必须失败。
- 允许危险操作只 Toast，必须失败。
- 允许部分成功只 Toast，必须失败。
- 允许权限失败只 Toast，必须失败。
- 允许任务创建后只有自动消失 Toast，必须失败。
- 关闭 Toast 被写成取消服务端任务，必须失败。
- 删除去重/堆叠策略，必须失败。
- 全局反馈泄露敏感对象，必须失败。
- 移动端 Toast 遮挡主操作或恢复入口，必须失败。

## 验收标准

- Global Feedback owner 首版范围清晰，覆盖 Toast、Alert、Banner、Notification 和 Inline Feedback。
- 与 Feedback States、Admin Console、Form、Button、Upload/Import 和 Responsive owner 边界不冲突。
- README/HANDOFF/SKILL 只做摘要和路由，不复制 owner 细节。
- RED/GREEN 输出和审计 mutation 能覆盖核心反例。
- 未执行浏览器、屏幕阅读器、触摸设备或真实组件运行时时，所有证据必须标为未验证。
