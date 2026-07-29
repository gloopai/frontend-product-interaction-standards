# 危险操作与恢复交互规范

## 范围

适用于后台、管理台、控制台、SaaS console、内部工具和业务系统中的危险操作、风险操作、二次确认、强确认、输入确认、删除、停用、启用、禁用、归档、清空、重置、重置密钥、撤销、恢复、取消任务、重跑、批量删除、批量停用、权限变更、敏感导出、不可逆操作、未知结果、部分成功和审计回执。

批量删除、批量停用、批量归档、批量恢复、批量权限变更、敏感批量导出和大范围批处理必须同时执行 `references/bulk-actions-batch-operations.md`。风险 owner 负责风险分级、强确认、撤销窗口和不可逆说明；批量 owner 负责 `bulkActionState`、目标集合、范围冻结、部分成功、结果回执和恢复范围。

单条删除、单条停用、单条归档、单条恢复、取消任务、重跑任务和行菜单中的危险动作必须同时执行 `references/row-contextual-actions.md`。风险 owner 负责风险分级、影响范围、确认策略、撤销和审计；行操作 owner 负责 `rowActionState`、recordIdentity、sourceSnapshot、requestIdentity、resultReceipt 和旧行防护。

清空余额、购买大额额度、预算上限、超额付费、折扣/税率/汇率变更、关键阈值、权限数量、席位数、并发数、保留天数和不可逆配额变更必须同时执行 `references/numeric-amount-inputs.md`。风险 owner 负责风险分级、影响范围、确认策略和审计；数字 owner 负责 `numericInputState`、单位/币种/倍率、精度/舍入、范围边界、提交快照和误触输入防护。

删除后恢复、软删除、回收站、已删除列表、已归档列表、撤销删除、永久删除、清空回收站、保留期到期、法律保留和恢复审计必须同时执行 `references/trash-restore-retention.md`。风险 owner 负责确认前风险、影响范围和请求前门禁；回收站 owner 负责 `trashRestoreState`、retentionPolicy、restorePolicy、purgePolicy、resultReceipt、auditBinding 和旧入口清理。

本文件是风险动作生命周期的唯一事实来源。它定义风险分级、影响范围、确认策略、确认前请求边界、请求身份、撤销窗口、取消语义、未知结果、批量快照、权限收敛、审计回执、恢复入口、可访问性和移动端可达性。它不定义具体按钮视觉、Dialog 焦点陷阱、服务端事务或审计存储实现。

## 与组件 owner 的关系

按钮入口、loading、防重复和按钮可访问名称读取 `buttons.md`；确认承载面、遮罩、关闭、滚动和焦点陷阱读取 `dialogs.md` / `drawers.md`；表单 dirty、校验和提交错误读取 `forms.md`；表格选择、全部筛选结果选择、部分成功和批量范围读取 `data-tables.md`；会影响大量对象、跨分组、公开展示、业务优先级或不可自动恢复的人工排序与重排必须同时执行 `references/ordering-reordering.md`，风险 owner 只负责风险确认和结果风险，排序 owner 负责草稿顺序、范围和冲突；低风险可撤销动作、none-with-undo、乐观更新、撤销窗口、失败回滚、离线重试和迟到响应协调必须同时执行 `references/optimistic-update-undo.md`，风险 owner 继续负责风险分级、确认、审计和恢复，乐观 mutation owner 负责 pending 投影、撤销入口持久性、回滚依据和权威结果合并；查询筛选快照读取 `query-filters.md`；审批通过、驳回、撤回、转交、加签、委托、催办和批量审批读取 `references/approval-workflows.md`，风险 owner 只决定确认和结果风险，审批节点、意见/附件、审批人和工作流快照仍归 `approval-workflows.md`；导航离开、浏览器 Back/Forward 和 `dirtyBlockers` 读取 `navigation-routing.md`；管理台权限、任务中心和审计治理读取 `admin-console.md`；Toast、Alert、Banner、Notification 和恢复入口呈现读取 `global-feedback.md`；移动端、触摸、安全区域和缩放读取 `responsive-adaptive.md`。

Risk Actions owner 不替代上述 owner。它只决定一个动作是否有风险、风险如何被用户理解、请求什么时候可以发送、发送后如何解释结果、失败后如何恢复。

## 场景与状态模型

每个风险动作声明 `riskActionSurface`：`record-danger-action`、`bulk-danger-action`、`permission-change`、`sensitive-export`、`task-cancel`、`task-rerun`、`configuration-reset`、`secret-reset`、`irreversible-delete`、`recoverable-archive`、`undoable-action` 或 `async-risk-action`。

每个风险动作维护 `riskActionState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `riskActionId` | 当前风险动作稳定身份。 |
| `riskLevel` | `low-recoverable`、`medium-recoverable`、`high-impact`、`irreversible` 或 `async-unknown`。 |
| `actionObject` | 用户正在影响的对象、对象类型、数量、范围和可安全展示的名称。 |
| `impactScope` | 当前记录、当前页、全部筛选结果、关联对象、权限范围、数据导出范围或跨租户/工作区影响。 |
| `confirmationPolicy` | `none-with-undo`、`light-confirm`、`strong-confirm`、`typed-confirm`、`multi-step-confirm` 或 `task-flow`。 |
| `confirmationEvidence` | 用户已阅读、选择、输入或确认的证据；未满足前请求数必须为 0。 |
| `requestIdentity` | 操作 ID、幂等键、权限版本、目标快照、影响范围快照、发起者和来源入口。 |
| `executionPhase` | `idle`、`confirming`、`ready-to-submit`、`submitting`、`sent`、`undo-window`、`succeeded`、`partial-succeeded`、`failed`、`conflict`、`cancel-requested`、`cancelled`、`unknown` 或 `expired`。 |
| `undoPolicy` | 是否支持撤销、撤销窗口、撤销对象、撤销请求身份、窗口结束后的持久状态和撤销失败恢复。 |
| `cancelPolicy` | 是否可取消、取消请求语义、取消中状态、服务端回执要求和未知结果恢复。 |
| `resultReceipt` | 成功、部分成功、失败、冲突、未知、已取消、过期和审计回执的位置。 |
| `auditBinding` | 审计可用性、审计请求身份、审计失败说明和可追踪位置。 |
| `recoveryActions` | 重试、查看详情、恢复、撤销、检查最新状态、进入任务中心、下载错误明细或申请权限等恢复动作。 |

危险操作不得只靠颜色、图标、Tooltip 或按钮位置表达风险。二次确认不得只有“确定 / 取消”“是 / 否”“提交 / 返回”等裸词。未满足 `confirmationPolicy` 前，请求数必须为 0。

## RA-SCOPE 范围和所有权

| 规则 ID | 规则 |
| --- | --- |
| RA-SCOPE-01 | 删除、停用、启用、禁用、归档、清空、重置、重置密钥、权限变更、敏感导出、批量修改、取消任务、重跑任务和不可逆配置变更默认是风险动作。 |
| RA-SCOPE-02 | 风险动作必须声明 primary owner；按钮、菜单、Toast、Dialog 标题或任务中心入口不能单独替代 `riskActionState`。 |
| RA-SCOPE-03 | 风险动作必须说明是否改变数据、权限、审计、任务、导出结果、外部系统或关联对象。 |
| RA-SCOPE-04 | 组件库、路由库、浏览器确认框和服务端默认文案不能降低本文件规则；冲突时必须配置、封装或替换。 |

对应验收：RA-A1、RA-A10。

## RA-STATE 状态模型和请求身份

| 规则 ID | 规则 |
| --- | --- |
| RA-STATE-01 | 每个风险动作必须维护 `riskActionState`，包含 `riskActionId`、`riskLevel`、`actionObject`、`impactScope`、`confirmationPolicy`、`confirmationEvidence`、`requestIdentity`、`executionPhase`、`undoPolicy`、`cancelPolicy`、`resultReceipt`、`auditBinding` 和 `recoveryActions`。 |
| RA-STATE-02 | `requestIdentity` 必须在请求发送前冻结操作 ID、幂等键、权限版本、目标快照、影响范围快照、发起者和来源入口。 |
| RA-STATE-03 | 点击、Enter、Space、触摸、双击、事件重放和迟到响应不得创建多个等价请求或多个终态回执。 |
| RA-STATE-04 | `executionPhase` 必须互斥；`sent`、`cancel-requested`、`unknown`、`partial-succeeded` 和 `failed` 不得被 UI 文案合并成“已处理”。 |
| RA-STATE-05 | 风险动作结果必须绑定 `resultReceipt` 和 `auditBinding`；Toast 只能辅助提示，不能是唯一回执。 |

对应验收：RA-A1、RA-A2、RA-A8。

## RA-LEVEL 风险分级

| 规则 ID | 规则 |
| --- | --- |
| RA-LEVEL-01 | `low-recoverable` 只适用于轻量、影响局部、可撤销且可在页面内恢复的动作。 |
| RA-LEVEL-02 | `medium-recoverable` 适用于停用、归档、取消订阅、移出分组和可恢复批量状态变更，必须说明恢复路径。 |
| RA-LEVEL-03 | `high-impact` 适用于权限变更、敏感导出、批量修改、重跑任务和影响范围较大的配置变更。 |
| RA-LEVEL-04 | `irreversible` 适用于删除、清空、重置密钥、不可逆配置变更和无法完整恢复的批量操作。 |
| RA-LEVEL-05 | `async-unknown` 适用于取消任务、重跑任务、批量导入导出、跨页面长任务和网络中断后结果不明的动作。 |

对应验收：RA-A1、RA-A3。

## RA-CONFIRM 确认策略和误触防护

确认策略必须匹配风险等级。轻确认适合中风险可恢复动作；强确认适合高影响动作；输入确认、多步骤确认或任务流程适合不可逆、跨范围、敏感或批量动作。

| 规则 ID | 规则 |
| --- | --- |
| RA-CONFIRM-01 | `none-with-undo` 只能用于 `low-recoverable`，且撤销入口和持久结果必须在页面内可达。 |
| RA-CONFIRM-02 | `light-confirm` 必须说明动作、对象和可恢复性；不能只有“确定 / 取消”。 |
| RA-CONFIRM-03 | `strong-confirm` 必须说明动作、对象、数量、影响范围、关键后果和恢复路径。 |
| RA-CONFIRM-04 | `typed-confirm` 必须要求用户输入稳定对象名、数量、关键词或风险短语；输入值不得是内部 ID、随机 token 或不可读字符串。 |
| RA-CONFIRM-05 | 未满足 `confirmationPolicy` 前，请求数必须为 0；关闭确认、Escape、遮罩、浏览器返回和路由离开都不得提交请求。 |
| RA-CONFIRM-06 | 确认标题、正文、按钮文案、可访问名称和结果回执必须描述同一动作对象，不得出现裸词确认。 |

对应验收：RA-A2、RA-A3、RA-A9。

## RA-UNDO 撤销和恢复

撤销不是 Toast 装饰；必须声明撤销窗口、对象、服务端结果和窗口结束后的持久状态。撤销入口可以出现在页面内回执、结果区域、任务中心或全局反馈中，但不能只依赖自动消失 Toast。

| 规则 ID | 规则 |
| --- | --- |
| RA-UNDO-01 | 支持撤销的动作必须声明 `undoPolicy`，包含窗口时长、对象、请求身份、可见入口、成功状态、失败状态和窗口结束状态。 |
| RA-UNDO-02 | 撤销入口不得只存在于自动消失 Toast；Toast 可提示，但持久 owner 中必须有恢复入口或最终状态说明。 |
| RA-UNDO-03 | 撤销窗口结束后，不得继续展示可操作撤销按钮；必须更新为最终状态、查看详情或恢复说明。 |
| RA-UNDO-04 | 撤销请求失败、冲突、权限变化或未知结果时，必须有 `recoveryActions`，不得把失败吞掉。 |
| RA-UNDO-05 | 撤销不得复用原操作幂等键造成二次执行；必须声明撤销请求身份和服务端语义。 |

对应验收：RA-A4、RA-A8、RA-A10。

## RA-CANCEL 取消、关闭和未知结果

已发送请求不得因为关闭确认、Escape、路由离开、客户端取消或 Toast 消失而写成“已取消”。取消请求已发送不等于服务端已取消；未知结果不得伪装成成功或失败。

| 规则 ID | 规则 |
| --- | --- |
| RA-CANCEL-01 | 请求发送前关闭确认只关闭客户端确认；请求发送后关闭页面、Escape、浏览器返回或路由离开不得改变服务端执行语义。 |
| RA-CANCEL-02 | 可取消动作必须声明 `cancelPolicy`，区分不可取消、取消请求已发送、取消中、已取消、取消失败、未知和过期。 |
| RA-CANCEL-03 | 取消请求必须等待服务端结果；客户端关闭、网络断开或页面卸载不能伪装为服务端已取消。 |
| RA-CANCEL-04 | 未知结果不得伪装成成功或失败，必须提供检查最新状态、进入任务中心、刷新状态或联系支持路径。 |
| RA-CANCEL-05 | 长耗时和跨页面风险动作必须有持久结果 owner；自动消失反馈不得承载唯一状态。 |

对应验收：RA-A5、RA-A8、RA-A10。

## RA-BULK 批量、范围和部分成功

批量危险操作必须冻结选择快照、筛选快照、权限版本、目标数量、目标摘要和影响范围。全部筛选结果、当前页、已选择 N 项、跨页选择和动态筛选结果必须用不同文案和不同快照表达。

| 规则 ID | 规则 |
| --- | --- |
| RA-BULK-01 | 批量风险动作必须声明 `selectionSnapshot`、`filterSnapshot`、`permissionVersion`、目标数量、目标摘要和 `impactScope`。 |
| RA-BULK-02 | 当前页选择、全部筛选结果选择、跨页选择和手动选择不得共用同一确认文案。 |
| RA-BULK-03 | 筛选、排序、分页、权限或租户变化后，旧批量确认和旧目标快照必须失效或要求重新确认。 |
| RA-BULK-04 | 部分成功必须说明成功、失败、跳过、冲突和未知的对象范围，并提供错误明细或任务中心路径。 |
| RA-BULK-05 | 批量危险操作不得只显示总数；必须提供用户能理解的目标摘要和关键后果。 |

对应验收：RA-A6、RA-A8、RA-A10。

## RA-PERM 权限、租户和敏感信息

权限、租户/工作区、角色、目标版本或筛选范围变化后，旧确认、旧目标快照、旧撤销入口和旧结果回执必须失效或重新证明安全。

| 规则 ID | 规则 |
| --- | --- |
| RA-PERM-01 | 请求发送前必须复核权限版本、目标快照、影响范围和敏感导出范围。 |
| RA-PERM-02 | 权限降级、租户切换或对象删除后，旧确认、旧目标名、旧数量、旧撤销入口、旧下载入口和旧结果回执不得继续泄露敏感信息。 |
| RA-PERM-03 | 无权状态必须提供安全恢复路径，但不得泄露对象名称、数量、字段、文件名、导出范围、密钥、令牌或内部 ID。 |
| RA-PERM-04 | 权限冲突、版本冲突和目标过期必须进入冲突或重新确认流程，不得继续执行旧请求。 |
| RA-PERM-05 | 敏感导出、权限变更、密钥重置和跨租户影响必须使用强确认或更高策略。 |

对应验收：RA-A7、RA-A8。

## RA-AUDIT 审计回执和结果证据

风险动作必须能追踪主体、时间、租户/工作区、目标、请求身份、结果和审计可用性。审计失败不等于业务失败，但必须说明审计状态、可追踪位置和恢复路径。

| 规则 ID | 规则 |
| --- | --- |
| RA-AUDIT-01 | `auditBinding` 必须声明审计可用性、审计请求身份、审计写入结果、查看位置和审计失败说明。 |
| RA-AUDIT-02 | `resultReceipt` 必须区分成功、部分成功、失败、冲突、未知、已取消、过期和审计回执。 |
| RA-AUDIT-03 | 结果回执必须在页面内、结果区、任务中心或审计区可定位；Toast 不得作为唯一凭证。 |
| RA-AUDIT-04 | 审计不可用、延迟或失败时，必须说明业务结果是否已生效、如何检查、何时重试或联系谁。 |
| RA-AUDIT-05 | 审计和结果消息不得泄露无权对象名称、数量、字段、文件名、密钥、令牌或内部 ID。 |

对应验收：RA-A8、RA-A10。

## RA-A11Y 可访问性、焦点和公告

| 规则 ID | 规则 |
| --- | --- |
| RA-A11Y-01 | 风险等级、影响范围、对象、确认要求、撤销窗口、取消中状态、未知结果和恢复入口必须可读，不能只靠颜色或图标。 |
| RA-A11Y-02 | 输入确认字段必须有 label、说明、错误和可访问描述；失败原因不能只存在于 placeholder 或 Tooltip。 |
| RA-A11Y-03 | 确认打开、确认失败、请求发送、撤销窗口开始、取消中、未知结果、部分成功和审计失败必须由唯一 owner 公告。 |
| RA-A11Y-04 | 焦点必须在打开确认、提交失败、撤销成功/失败、取消中、未知结果和恢复入口之间只迁移一次，不得被迟到回调抢回。 |
| RA-A11Y-05 | 危险结果和恢复入口必须支持键盘、触摸和可访问名称；不能只在 hover、长按或临时 Toast 中可达。 |

对应验收：RA-A9、RA-A10。

## RA-RSP 响应式与移动端

移动端可以折叠说明，但不能删除危险确认、影响范围、撤销/恢复入口、取消中状态、未知结果说明或审计回执。

| 规则 ID | 规则 |
| --- | --- |
| RA-RSP-01 | 移动端不得删除危险确认、影响范围、撤销/恢复入口、取消中状态、未知结果说明或审计回执。 |
| RA-RSP-02 | 低高度、虚拟键盘、动态 viewport、四向 safe area、触摸和 200% 缩放下，确认内容、输入确认、提交、取消、撤销和恢复入口必须可达。 |
| RA-RSP-03 | 底部操作区、更多菜单和折叠确认不得遮挡关键后果、目标数量、输入确认字段或危险按钮。 |
| RA-RSP-04 | 移动端系统返回、WebView 返回和浏览器 Back 必须进入同一离开保护；不得绕过已打开确认或已发送风险动作。 |

对应验收：RA-A9、RA-A10。

## 可执行验收检查

下列检查以可观察状态、DOM 属性、事件日志、请求日志、结果回执、审计回执、权限快照和焦点轨迹断言；未实际执行时必须报告为**未验证**及所需环境。

1. **状态模型与风险分类**：记录 `{riskActionId, riskLevel, actionObject, impactScope, confirmationPolicy, confirmationEvidence, requestIdentity, executionPhase, undoPolicy, cancelPolicy, resultReceipt, auditBinding, recoveryActions}`。分别构造删除、停用、重置密钥、权限变更、敏感导出、取消任务、重跑和批量删除；断言每个动作有风险等级和 owner。
2. **确认前请求边界**：对 `light-confirm`、`strong-confirm`、`typed-confirm`、`multi-step-confirm` 和 `task-flow` 分别尝试未确认提交、关闭确认、Escape、遮罩、浏览器返回和重复点击。断言未满足 `confirmationPolicy` 前请求数为 0；确认文案不是裸词，且动作、对象、数量和影响范围可读。
3. **强确认和输入确认**：构造删除、清空、重置密钥、权限变更和批量删除。断言 `typed-confirm` 输入稳定对象名、数量、关键词或风险短语；输入内部 ID、随机 token、错误数量或空值不能通过。
4. **撤销窗口和恢复**：执行 `none-with-undo` 与中风险可恢复动作；断言撤销不是 Toast 装饰，`undoPolicy` 声明窗口、对象、服务端结果和窗口结束后的持久状态。窗口结束后撤销入口失效，撤销失败进入恢复路径。
5. **取消和未知结果**：执行取消任务、长耗时任务、网络中断、关闭页面和路由离开。断言已发送请求不得因为关闭确认、Escape、路由离开、客户端取消或 Toast 消失而写成“已取消”；取消请求已发送不等于服务端已取消；未知结果不得伪装成成功或失败。
6. **批量影响范围**：在当前页选择、全部筛选结果、跨页选择、筛选变化、权限变化和部分成功中触发批量危险操作。断言冻结选择快照、筛选快照、权限版本、目标数量、目标摘要和影响范围；部分成功有错误明细或任务中心路径。
7. **权限和敏感信息收敛**：在确认打开、请求发送前、撤销窗口中、结果回执后和下载入口存在时切换权限、租户/工作区、角色、目标版本或筛选范围。断言旧确认、旧目标快照、旧撤销入口和旧结果回执失效或重新证明安全，且不泄露无权对象。
8. **结果和审计回执**：断言 `resultReceipt` 区分成功、部分成功、失败、冲突、未知、已取消、过期和审计回执；`auditBinding` 声明审计可用性、写入结果、查看位置和失败恢复。Toast 不得作为唯一凭证。
9. **可访问性和焦点**：检查风险等级、影响范围、确认要求、输入确认字段、错误、撤销窗口、取消中、未知结果、审计失败和恢复入口的可访问名称和公告。焦点在确认、失败、撤销、取消中和恢复入口之间只迁移一次。
10. **移动端和运行时报告**：在移动窄屏、底部操作区、更多菜单、200% 缩放、字体放大、低高度、动态 viewport、虚拟键盘、四向 safe area、触摸、系统返回、WebView 返回和浏览器 Back 下，断言移动端不得删除危险确认、影响范围、撤销/恢复入口、取消中状态、未知结果说明或审计回执。上述浏览器、屏幕阅读器、触控设备、真实组件和真实视口检查未实际执行时，报告必须逐项标为**未验证**，并写明所需浏览器、设备/viewport、输入方式及辅助技术环境。
