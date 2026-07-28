# 危险操作、二次确认与撤销恢复交互规范设计

## 背景

当前 Skill 已在 `buttons.md`、`admin-console.md`、`global-feedback.md`、`navigation-routing.md` 和 `record-editing-surfaces.md` 中约束了危险按钮、风险操作、Toast 边界、离开保护和审计回执。但这些规则仍分散在不同 owner 中，容易出现实现时“按钮有确认、页面有 Toast、审计另说”的割裂状态。

需要新增一个职责单一的 `references/risk-actions.md`，专门定义危险操作本身的生命周期：如何判定风险等级、如何表达影响范围、如何选择确认策略、如何冻结请求身份、如何处理撤销、取消、未知结果、部分成功、权限变化、审计失败和移动端可达性。

## 目标

- 建立统一的 `riskActionState` 状态模型，成为危险操作生命周期的唯一事实来源。
- 明确低风险可恢复、中风险可恢复、高风险不可逆、异步/未知结果四类风险动作的确认和恢复要求。
- 禁止危险操作只靠颜色、裸词确认、Toast-only 回执或客户端关闭来表达关键状态。
- 把撤销、取消、未知结果和审计回执从“提示文案”提升为必须声明的产品状态。
- 与按钮、Dialog/Drawer、表格批量、表单、导航、管理台、全局反馈和响应式 owner 保持边界清晰。

## 非目标

- 不定义具体视觉 token、颜色值、图标、间距或组件库 API。
- 不替代 `buttons.md` 的按钮语义、loading、防重复和可访问名称。
- 不替代 `dialogs.md` / `drawers.md` 的确认容器、焦点陷阱、滚动和关闭规则。
- 不替代 `admin-console.md` 的权限、审计、任务中心和管理台页面级治理。
- 不定义服务端事务、权限模型或审计存储实现；只定义前端产品交互必须证明的状态和证据。

## Owner 边界

`risk-actions.md` 是风险动作生命周期 owner。

- 按钮入口读取 `buttons.md`，但风险等级、影响范围、确认策略、撤销窗口、取消边界和结果状态读取 `risk-actions.md`。
- 确认使用 Dialog、Drawer 或独立页承载时，容器交互读取对应 owner；确认内容和风险语义读取 `risk-actions.md`。
- 表格批量操作读取 `data-tables.md` 的选择快照；目标快照、影响范围和批量风险确认读取 `risk-actions.md`。
- 记录新增/编辑读取 `record-editing-surfaces.md`；纯命令式删除、停用、归档、重置、取消、重跑和清空读取 `risk-actions.md`。
- 全局反馈读取 `global-feedback.md`；危险结果的 primary owner、恢复入口和审计回执由 `risk-actions.md` 声明。
- 路由离开读取 `navigation-routing.md`；危险确认中、请求已发送、撤销窗口中和未知结果状态必须进入 `dirtyBlockers` 或等价离开保护。

## 状态模型

每个风险动作必须维护 `riskActionState`：

| 字段 | 语义 |
| --- | --- |
| `riskActionId` | 稳定动作身份。 |
| `riskLevel` | `low-recoverable`、`medium-recoverable`、`high-impact`、`irreversible` 或 `async-unknown`。 |
| `actionObject` | 用户正在影响的对象、对象类型、数量、范围和可安全展示的名称。 |
| `impactScope` | 影响范围，包括当前记录、当前页、全部筛选结果、关联对象、权限范围、数据导出范围或跨租户/工作区影响。 |
| `confirmationPolicy` | `none-with-undo`、`light-confirm`、`strong-confirm`、`typed-confirm`、`multi-step-confirm` 或 `task-flow`。 |
| `confirmationEvidence` | 用户已阅读、选择、输入或确认的证据；未满足前请求数必须为 0。 |
| `requestIdentity` | 操作 ID、幂等键、权限版本、目标快照、影响范围快照、发起者和来源入口。 |
| `executionPhase` | `idle`、`confirming`、`ready-to-submit`、`submitting`、`sent`、`undo-window`、`succeeded`、`partial-succeeded`、`failed`、`conflict`、`cancel-requested`、`cancelled`、`unknown` 或 `expired`。 |
| `undoPolicy` | 是否支持撤销、撤销窗口、撤销对象、撤销请求身份、窗口结束后的持久状态和撤销失败恢复。 |
| `cancelPolicy` | 是否可取消、取消请求语义、取消中状态、服务端回执要求和未知结果恢复。 |
| `resultReceipt` | 成功、部分成功、失败、冲突、未知、已取消、过期和审计回执的位置。 |
| `auditBinding` | 审计可用性、审计请求身份、审计失败说明和可追踪位置。 |
| `recoveryActions` | 重试、查看详情、恢复、撤销、检查最新状态、进入任务中心、下载错误明细或申请权限等恢复动作。 |

## 风险分级与确认策略

### 低风险可恢复

适用于移出收藏、关闭提示、移除草稿标签等轻量动作。可以不弹确认，但必须满足：

- 结果在页面内可见。
- 撤销或恢复入口可达。
- `undoPolicy` 声明窗口、对象和窗口结束后的最终状态。
- Toast 可作为辅助提示，但不得是唯一恢复入口。

### 中风险可恢复

适用于停用、归档、移出分组、批量状态变更、取消订阅等动作。必须满足：

- 使用轻确认或强确认。
- 明确对象、数量、影响范围和恢复路径。
- 冻结 `requestIdentity`。
- 结果必须有页面内回执或任务中心回执。
- 支持撤销时，撤销窗口和最终不可撤销时间必须可见。

### 高风险或不可逆

适用于删除、清空、重置密钥、权限变更、敏感导出、不可逆配置变更、批量删除和影响范围难以恢复的动作。必须满足：

- 使用强确认、输入确认、多步骤确认或任务流程。
- 不得只使用“确定 / 取消”裸词。
- 确认标题、正文、按钮和可访问名称必须包含动作、对象、数量和关键后果。
- 请求发送前必须复核权限版本、目标快照和影响范围。
- 结果必须区分成功、部分成功、失败、冲突、未知和审计回执。

### 异步或未知结果

适用于取消任务、重跑任务、批量导入导出、批量删除、跨页面长任务和网络中断后结果不明的动作。必须满足：

- 关闭页面、关闭确认、Escape、浏览器返回或 Toast 消失不得伪装成取消。
- 取消请求已发送不等于服务端已取消。
- 未知结果不得伪装成成功或失败。
- 必须提供检查最新状态、查看任务中心、刷新状态或联系支持的恢复路径。

## 硬性红线

- 危险操作不得只靠颜色、图标、Tooltip 或按钮位置表达风险。
- 二次确认不得只有“确定 / 取消”“是 / 否”“提交 / 返回”等裸词。
- 未满足 `confirmationPolicy` 前，请求数必须为 0。
- 已发送请求不得因为关闭确认、Escape、路由离开、客户端取消或 Toast 消失而写成“已取消”。
- 撤销不是 Toast 装饰；必须声明撤销窗口、对象、服务端结果和窗口结束后的持久状态。
- 批量危险操作必须冻结选择快照、筛选快照、权限版本、目标数量、目标摘要和影响范围。
- 权限、租户/工作区、角色、目标版本或筛选范围变化后，旧确认、旧目标快照、旧撤销入口和旧结果回执必须失效或重新证明安全。
- 未知结果不得伪装成成功或失败，必须提供检查最新状态或任务中心路径。
- 移动端不得删除危险确认、影响范围、撤销/恢复入口、取消中状态、未知结果说明或审计回执。

## 路由触发

`SKILL.md` 应在以下词汇出现时完整读取 `references/risk-actions.md`：

- 中文：危险操作、风险操作、二次确认、强确认、输入确认、删除、停用、启用、禁用、归档、清空、重置、重置密钥、撤销、恢复、取消任务、重跑、批量删除、批量停用、权限变更、敏感导出、不可逆操作、未知结果、部分成功、审计回执。
- 英文：danger action、risk action、destructive action、confirm、double confirm、typed confirm、delete、disable、enable、archive、clear、reset、reset key、undo、recover、cancel job、rerun、bulk delete、permission change、sensitive export、irreversible、unknown result、partial success、audit receipt。

## 审计策略

新增 `docs/testing/risk-actions/risk-actions-audit.rb`，验证：

- owner 存在完整 `riskActionState` 字段。
- owner 覆盖四类风险等级、确认策略、撤销、取消、未知结果、批量快照、权限收敛、审计和移动端。
- `SKILL.md` 路由包含中英文关键词。
- README 和 HANDOFF 只做摘要，不复制完整规则。
- RED/GREEN 证据包含高风险场景和运行时未验证边界。
- 负向变异能抓住：去掉 typed confirm、把 Toast 当唯一撤销入口、把关闭确认等同取消、把未知结果写成功、移除批量快照、移除权限重校验、移除移动端危险确认、把未验证改为已验证。

## 验收口径

完成后应能回答并验证：

1. 这个动作为什么是风险动作，风险等级是什么。
2. 影响哪些对象、多少对象、哪些范围和哪些关联结果。
3. 用户必须完成什么确认，确认前请求是否为 0。
4. 请求身份是否冻结了操作 ID、幂等键、权限版本、目标快照和发起者。
5. 关闭确认、路由离开和客户端取消是否没有伪装服务端结果。
6. 撤销窗口是否真实存在，窗口结束后状态是否可解释。
7. 部分成功、失败、冲突和未知结果是否有持久恢复路径。
8. 权限或租户变化后，旧确认和旧结果入口是否安全失效。
9. 审计回执是否可定位，审计失败是否有说明。
10. 移动端、键盘、屏幕阅读器和真实组件未执行时是否标为未验证。
