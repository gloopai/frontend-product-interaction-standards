# 全局反馈与通知交互规范

## 范围

适用于 Toast、Snackbar、Message、Notification、Alert、Banner、Inline Feedback、全局提示、消息提示、操作回执、结果回执、成功提示、错误提示、警告提示和跨区域轻量反馈。本文件是全局反馈通道选择、消息生命周期、结果绑定、去重堆叠、关闭语义、恢复入口、可访问公告和安全边界的唯一事实来源。

站内信系统、完整消息中心、邮件/短信/Push 通知、运营公告投放、订阅偏好、品牌视觉 token、图标样式和通知服务后端实现不属于本 owner。

## 与组件 owner 的关系

页面/区域级 loading、empty、error、stale、permission 和 recovery 读取 `feedback-states.md`；重试、撤销、查看详情等消息动作读取 `buttons.md`；字段错误和表单提交失败读取 `forms.md`；上传/导入任务、部分成功和错误明细读取 `uploads-imports.md`；管理台危险操作、权限、审计和任务中心读取 `admin-console.md`；移动端安全区域、触摸和遮挡风险读取 `responsive-adaptive.md`。当本文件与组件 owner 都适用时，两者都执行；冲突时停止并请用户裁决。

Global Feedback owner 不替代页面/区域状态、表单错误、任务中心、审计回执或危险确认；它只定义短暂或跨区域反馈消息能承载什么、不能承载什么。

## 场景与状态模型

每条全局反馈维护 `feedbackMessageState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `messageId` | 消息稳定身份。 |
| `channel` | `toast`、`snackbar`、`message`、`alert`、`banner`、`notification`、`inline-feedback`。 |
| `severity` | `success`、`info`、`warning`、`error`、`critical`、`unknown`。 |
| `sourceOwner` | 触发来源 owner，例如 button、form、upload/import、admin task、feedback state。 |
| `resultBinding` | 消息绑定的操作、请求、任务、区域、字段或审计结果身份。 |
| `durationPolicy` | `auto-dismiss`、`manual-dismiss`、`persistent-until-resolved` 或 `owner-controlled`。 |
| `dismissPolicy` | 用户关闭消息后的语义和是否保留持久结果。 |
| `announcementPolicy` | 可访问公告的优先级、去重和是否抢焦点。 |
| `dedupeKey` | 去重、更新和合并相同消息的稳定键。 |
| `sensitiveBoundary` | 不得泄露的对象、数量、字段、文件名、筛选值、错误明细和内部 ID。 |
| `recoveryActions` | 消息内或持久 owner 中可达的恢复入口。 |

全局反馈不能降级为 `showToast(text)`。没有 `sourceOwner` 和 `resultBinding` 的消息不得承载业务结果，只能作为纯辅助提示。

## GF-SCOPE 范围和术语

| 规则 ID | 规则 |
| --- | --- |
| GF-SCOPE-01 | Toast / Snackbar / Message 只适合短文本、低风险、无需恢复且结果已在页面或区域中持久体现的辅助反馈。 |
| GF-SCOPE-02 | Alert / Inline Feedback 用于当前区域内需要用户理解或处理的信息；Banner 用于页面级或系统级状态；Notification 用于跨页面提示，但不替代任务中心或审计。 |
| GF-SCOPE-03 | 危险操作、部分成功、未知结果、权限失败、长耗时任务和需要恢复的错误必须有持久 owner。 |
| GF-SCOPE-04 | 组件库默认 message/toast 行为不能降低本文件规则；冲突时必须配置、封装或替换。 |

对应验收：GF-A1、GF-A10。

## GF-STATE 消息状态与结果绑定

消息必须绑定来源操作、请求、任务、区域、字段、审计或结果。重复触发、迟到响应、重试结果和并发操作必须通过 `dedupeKey` 与 `resultBinding` 去重、更新或归并，不能无限堆叠。

| 规则 ID | 规则 |
| --- | --- |
| GF-STATE-01 | 每条反馈必须维护 `feedbackMessageState`，并包含 messageId、channel、severity、sourceOwner、resultBinding、durationPolicy、dismissPolicy、announcementPolicy、dedupeKey、sensitiveBoundary 和 recoveryActions。 |
| GF-STATE-02 | 没有 `sourceOwner` 和 `resultBinding` 的消息不得承载保存、删除、导入、导出、权限、任务或审计结果。 |
| GF-STATE-03 | 同一操作结果只能有一个 primary result owner；Toast 可以辅助，但不能和 Alert、区域状态或任务中心争夺结果所有权。 |
| GF-STATE-04 | 迟到结果只有仍匹配当前 owner、请求身份、权限版本和 resultBinding 时才可更新消息。 |

对应验收：GF-A1、GF-A8。

## GF-CHANNEL 通道选择

| 规则 ID | 规则 |
| --- | --- |
| GF-CHANNEL-01 | 成功且无后续动作、页面状态已更新、无需审计查看的低风险反馈可用 Toast。 |
| GF-CHANNEL-02 | 当前区域需要用户阅读、修复或决策时使用区域内 Alert / Inline Feedback。 |
| GF-CHANNEL-03 | 页面级系统状态、维护、只读、离线或全局权限变化使用 Banner 或页面级反馈状态。 |
| GF-CHANNEL-04 | 跨页面任务或后台事件可用 Notification 提醒，但必须提供持久任务中心、结果页或审计入口。 |
| GF-CHANNEL-05 | 反馈通道必须与 severity、风险、可恢复性、持续时间和可访问公告策略匹配。 |

对应验收：GF-A2、GF-A10。

## GF-TOAST Toast 红线

Toast 不能作为唯一反馈承载需要恢复、追踪、审计、安全解释或持续阅读的信息。

| 规则 ID | 规则 |
| --- | --- |
| GF-TOAST-01 | 删除、停用、权限变更、批量修改、敏感导出等危险操作不能只用 Toast 作为唯一回执。 |
| GF-TOAST-02 | 部分成功、部分失败、未知结果、冲突和需要检查状态的异步任务不能只用 Toast 作为唯一回执。 |
| GF-TOAST-03 | 表单提交失败、字段错误、权限失败、认证失败、网络失败和服务不可用不能只用 Toast 表示。 |
| GF-TOAST-04 | 导入导出任务、错误明细下载、长耗时任务和可取消任务不能只在自动消失 Toast 中呈现。 |
| GF-TOAST-05 | 无权限、只读、数据过期、筛选无结果和页面空态不能只靠 Toast 解释。 |

对应验收：GF-A3、GF-A4、GF-A10。

## GF-LIFE 生命周期、关闭和持久性

自动关闭只适用于低风险、无需恢复的消息。错误、警告、部分成功、未知结果、权限相关、任务相关和含恢复入口的消息不得只靠短时间自动消失。

| 规则 ID | 规则 |
| --- | --- |
| GF-LIFE-01 | `auto-dismiss` 仅适用于无需恢复且持久结果已在其他 owner 中体现的消息。 |
| GF-LIFE-02 | 关闭 Toast 只关闭客户端消息，不得取消已发送请求、服务端任务、审计记录或结果状态。 |
| GF-LIFE-03 | 含恢复动作的消息自动消失前，恢复入口必须仍在持久 owner 中可达。 |
| GF-LIFE-04 | 路由变化时，绑定当前页面的短暂消息可关闭；跨页面任务消息必须转移到任务中心、通知入口或持久 owner。 |

对应验收：GF-A4、GF-A5。

## GF-STACK 去重、堆叠和迟到结果

| 规则 ID | 规则 |
| --- | --- |
| GF-STACK-01 | 同一 `dedupeKey` 的重复消息必须更新、合并或忽略，不能无限堆叠。 |
| GF-STACK-02 | 多条消息堆叠必须有数量、顺序、最大可见数量和溢出策略。 |
| GF-STACK-03 | 迟到成功、失败或未知结果必须绑定 resultBinding；不匹配时丢弃或写入对应持久 owner，不得覆盖当前消息。 |
| GF-STACK-04 | 消息队列不得遮挡 Dialog/Drawer 操作区、危险确认、表单错误、移动端底部主操作或安全区域。 |

对应验收：GF-A5、GF-A9。

## GF-RECOVERY 恢复入口

| 规则 ID | 规则 |
| --- | --- |
| GF-RECOVERY-01 | 需要恢复的消息必须提供恢复入口，或明确指向持久 owner 中的恢复入口。 |
| GF-RECOVERY-02 | 恢复入口必须有动作对象，例如重试保存、查看任务、下载错误明细、重新认证、申请权限、查看详情。 |
| GF-RECOVERY-03 | Toast 中放不下完整恢复时，Toast 只能作为辅助提示，并指向 Alert、结果页、任务中心或错误摘要。 |
| GF-RECOVERY-04 | 撤销类反馈必须声明撤销窗口、对象、服务端结果和窗口结束后的持久状态。 |

对应验收：GF-A6、GF-A10。

## GF-PERM 权限、安全和敏感信息

| 规则 ID | 规则 |
| --- | --- |
| GF-PERM-01 | 全局反馈不得泄露无权对象名称、数量、字段、文件名、筛选值、错误明细、密钥、令牌、个人识别信息或内部 ID。 |
| GF-PERM-02 | 权限降级、租户切换或结果失效后，旧 Toast、Notification、Banner 和恢复入口必须失效或替换安全说明。 |
| GF-PERM-03 | 权限失败和认证失败必须提供安全恢复路径，不得暴露被拒绝资源详情。 |
| GF-PERM-04 | 敏感导出、批量权限变更和审计相关消息必须绑定 Admin owner 的风险、结果和审计回执。 |

对应验收：GF-A7、GF-A10。

## GF-A11Y 可访问性与移动端

| 规则 ID | 规则 |
| --- | --- |
| GF-A11Y-01 | 全局反馈必须有公告策略；低风险状态不抢焦点，需要处理的 Alert 应在区域内可聚焦或可导航。 |
| GF-A11Y-02 | 同一完整消息不得同时由 Toast、Alert、区域状态和 live region 重复播报。 |
| GF-A11Y-03 | 消息内按钮必须有可访问名称和动作对象。 |
| GF-A11Y-04 | 移动端 Toast / Snackbar 不得遮挡底部主操作、危险确认、键盘输入、导航栏、安全区域或恢复入口。 |
| GF-A11Y-05 | 关闭、查看详情和恢复入口必须可触控、可键盘或有等价路径。 |

对应验收：GF-A8、GF-A9、GF-A10。

## 可执行验收检查

下列检查以可观察状态、DOM、焦点日志、公告日志和结果快照断言；未实际执行时必须报告为**未验证**及所需环境。

1. **消息状态与绑定**：触发保存、删除、导入、导出、权限失败和任务创建；断言每条消息有完整 `feedbackMessageState`，包含 sourceOwner、resultBinding、durationPolicy、dismissPolicy、announcementPolicy、dedupeKey、sensitiveBoundary 和 recoveryActions。不得出现只有 `showToast(text)` 的业务结果。
2. **通道选择**：低风险复制/保存成功可用 Toast；表单失败、权限失败、导入部分成功、危险删除、长任务创建必须同时有持久 owner。断言 Toast 不是这些场景的唯一回执。
3. **Toast 红线**：分别构造危险操作、部分成功、未知结果、权限失败、认证失败、网络失败、导入导出任务和空状态；断言 Toast-only 方案失败，页面内 Alert、任务中心、错误摘要、结果页或区域状态存在。
4. **生命周期和关闭语义**：自动关闭只用于低风险消息。关闭 Toast 后，已发送请求、服务端任务、审计记录和结果状态不被取消或删除；含恢复入口的消息消失后，恢复入口仍在持久 owner 中可达。
5. **去重、堆叠和迟到结果**：重复点击、重试、迟到成功/失败/未知结果产生相同或不同 dedupeKey；断言同键消息更新或合并，不无限堆叠；迟到结果只在 resultBinding 匹配时更新。
6. **恢复入口**：检查重试保存、查看任务、下载错误明细、重新认证、申请权限、查看详情和撤销；断言每个动作有对象、owner、窗口或结果说明，并遵循 Button owner。
7. **权限和敏感信息**：权限降级、租户切换、认证失败和敏感导出后，旧 Toast、Notification、Banner 和恢复入口失效或替换安全说明；消息不泄露对象名称、数量、字段、文件名、筛选值、错误明细、密钥、令牌、个人识别信息或内部 ID。
8. **可访问公告和焦点**：记录 live region 和焦点；低风险 Toast 不抢焦点，需要处理的 Alert 可聚焦或可导航；同一完整消息不重复播报；消息按钮有可访问名称。
9. **移动端遮挡和安全区域**：在移动窄屏、虚拟键盘、底部导航、Dialog/Drawer、危险确认和底部主操作存在时显示消息；断言 Toast/Snackbar 不遮挡核心操作、安全区域或恢复入口，关闭和查看详情可达。
10. **运行时报告边界**：浏览器、屏幕阅读器、触摸设备、真实业务组件、缩放和移动端检查未实际执行时，最终报告必须逐项标为**未验证**，并写明所需浏览器、设备/viewport、输入方式及辅助技术环境。
