# 成员、邀请与团队访问管理交互规范设计

## 背景

管理台常见“成员列表 + 邀请按钮 + 角色下拉 + 移除按钮”的实现，但这些操作并不是普通列表操作。邀请链接可能过期、撤销或被错误租户使用；成员可能处于已加入、待邀请、邀请过期、已禁用、已移除、外部成员、最后 owner 等状态；角色变更、移除成员、禁用成员、转移 owner 会影响权限边界、审计链路和正在进行的会话。若前端只把它们当成普通表格行、普通 Select 或普通危险确认，很容易产生旧权限入口、旧邀请链接、旧成员缓存、无权限泄露、确认前发请求或 Toast-only 回执。

现有规范已覆盖部分边界：

- `permissions-tenancy-visibility.md` 负责权限、租户/工作区、可见性、无泄露和旧状态收敛。
- `auth-session-reauth.md` 负责重新认证、账号/身份切换和旧敏感动作失效。
- `risk-actions.md` 负责危险操作、二次确认、未知结果和审计回执。
- `audit-log-activity-history.md` 负责审计证据身份和无权限审计不泄露。
- `data-tables.md` 负责成员列表、行操作、批量操作、焦点和响应式等表格行为。
- `global-feedback.md` / `feedback-states.md` 负责结果反馈、错误恢复和 Toast 边界。

缺口是：没有 owner 专门负责“成员身份、邀请身份、角色授权意图和成员生命周期”。这导致项目实现无法证明邀请链接、角色变更、成员移除、禁用、恢复、转移 owner 与权限/审计状态是一致的。

## 目标

- 新增“成员、邀请与团队访问管理” owner，覆盖成员列表、邀请、重新发送邀请、撤销邀请、接受邀请、拒绝邀请、邀请过期、修改角色、移除成员、禁用/启用成员、转移 owner、外部成员和成员恢复路径。
- 明确成员状态、邀请状态、角色状态和权限快照的区别，避免把待邀请、已加入、已禁用、已移除、最后 owner、外部成员和未知结果混成普通启停字段。
- 规定角色变更、移除、禁用、转移 owner、跨租户邀请、批量成员操作的风险确认、确认前请求数为 0、权限复核、重新认证和审计回执。
- 规定邀请链接、旧成员缓存、旧角色下拉、旧菜单、旧 Notification、旧审计跳转、旧 ARIA 引用在权限/会话/租户/成员版本变化后失效或重算。
- 规定移动端成员管理不能删除角色说明、成员状态、邀请恢复、撤销入口、禁用原因、审计入口和 owner 转移路径。

## 非目标

- 不定义后端组织架构、账号体系、身份提供商、目录同步、SCIM、SSO provider、邮件发送服务或权限 DSL。
- 不替代 `permissions-tenancy-visibility.md` 的权限解析和无泄露模型。
- 不替代 `auth-session-reauth.md` 的重新认证挑战。
- 不替代 `risk-actions.md` 的危险动作确认。
- 不替代 `data-tables.md` 的表格查询、列、分页、选择、批量和响应式规则。
- 不定义品牌视觉、图标、颜色、角色名称或业务项目具体权限矩阵。

## 推荐方案

推荐新增独立 owner：`references/members-invitations-access.md`。

备选方案有两种：

1. **分散补到权限、表格和风险规范里。** 优点是文件少；缺点是邀请状态、成员状态和角色变更意图没有单一事实来源，项目容易只读其中一个 owner 就漏掉邀请链接、最后 owner 或成员版本失效。
2. **只作为权限 owner 的子章节。** 优点是权限语义集中；缺点是成员管理还包含邀请、身份状态、邮件/链接、接受/拒绝、外部成员、禁用恢复和审计回执，不只是权限可见性。
3. **独立 owner 协调相邻规范。** 推荐。成员/邀请 owner 维护成员与邀请生命周期，角色变更和成员危险动作进入风险 owner，权限解析进入权限 owner，重新认证进入认证 owner，列表行为进入表格 owner，审计进入审计 owner。

选择独立 owner 的理由：成员管理的核心风险不是单个按钮，而是“成员身份 + 邀请身份 + 角色授权 + 权限版本 + 租户/工作区 + 审计回执”必须同时对齐。

## Owner 边界

建议新增文件：`references/members-invitations-access.md`。

建议路由关键词：

- 中文：成员、团队成员、工作区成员、组织成员、用户管理、账号管理、邀请成员、邀请链接、重新发送邀请、撤销邀请、接受邀请、拒绝邀请、邀请过期、角色、角色变更、权限角色、成员角色、Owner、转移 Owner、管理员、外部成员、访客、移除成员、禁用成员、启用成员、恢复成员、成员状态、成员审计。
- 英文：member、members、team member、workspace member、organization member、user management、account management、invite member、invitation、invite link、resend invite、revoke invite、accept invite、decline invite、expired invite、role、role change、member role、owner、transfer owner、admin、external member、guest、remove member、disable member、enable member、restore member、member status、membership audit。

该 owner 维护 `membershipAccessState`，至少包含：

| 字段 | 说明 |
| --- | --- |
| `membershipOwnerId` | 当前成员访问管理 owner 实例身份，用于绑定列表、弹层、邀请、角色变更、请求、审计和回执。 |
| `principalSnapshot` | 当前操作者、认证状态、租户/工作区、权限版本、角色版本和会话身份快照。 |
| `memberIdentity` | 目标成员稳定身份、账号、邮箱/标识脱敏策略、所属租户/工作区、成员版本和成员来源。 |
| `membershipStatus` | `active`、`invited`、`invite-expired`、`invite-revoked`、`disabled`、`removed`、`owner-transfer-required`、`external`、`unknown`。 |
| `invitationState` | 邀请创建、发送、重新发送、撤销、接受、拒绝、过期、域名限制、重复邀请和链接有效期。 |
| `roleAssignmentState` | 当前角色、目标角色、角色草稿、角色版本、授权范围、继承来源和生效状态。 |
| `accessChangeIntent` | 邀请、重发、撤销、角色变更、移除、禁用、启用、恢复、转移 owner 或批量操作的用户意图。 |
| `permissionBoundary` | 查看成员、邀请、修改角色、移除、禁用、转移 owner 和审计所需的权限版本与范围。 |
| `authBinding` | 是否需要重新认证、当前认证强度、`authOwnerId` 和挑战结果。 |
| `riskBinding` | 是否进入 `risk-actions.md`、风险等级、影响范围、确认策略和确认前请求数。 |
| `auditBinding` | 邀请、重发、撤销、接受、拒绝、角色变更、移除、禁用、启用、转移 owner、失败和未知结果的审计身份。 |
| `resultReceipt` | 成功、取消、失败、部分完成、未知、权限拒绝、邀请过期和成员版本冲突的持久回执。 |

## 核心规则

### 成员不是普通用户行

成员、邀请和角色不能只按普通数据表格行展示。成员状态、邀请状态、角色状态、权限状态和认证状态必须分开表达。`invited`、`invite-expired`、`disabled`、`removed`、`external`、`owner-transfer-required` 和 `unknown` 不能被合并成一个普通状态标签或 Switch。

成员列表必须同时执行 `data-tables.md`：查询、分页、筛选、行操作、批量操作、焦点恢复和移动端卡片/横向滚动都不能降低成员 owner 的身份和权限要求。

### 邀请必须有链接和身份边界

邀请成员必须绑定 `invitationState`、目标邮箱/账号、租户/工作区、角色、邀请人、有效期、权限版本和审计身份。邀请链接不是普通下载链接、普通文本或普通 Notification；旧邀请链接、旧邮件入口、旧复制链接、旧 Toast、旧任务入口和浏览器历史必须在撤销、过期、角色变更、租户/工作区切换、权限变化、会话过期或重复邀请后失效或重新证明安全。

重新发送邀请不得创建重复成员或绕过权限复核。撤销邀请、接受邀请、拒绝邀请、邀请过期和重复邀请必须有可区分回执。无权限用户不得通过邀请错误、搜索结果、邮箱补全、列表数量或审计摘要推断成员是否存在。

### 角色变更不是普通 Select

角色 Select 只能编辑 `roleAssignmentState` 草稿；确认前不得改变已生效角色，不得发起真实请求。保存角色变更必须读取当前成员版本、角色版本、权限版本、租户/工作区、操作者身份和目标角色快照。

提升为管理员、降低管理员、修改外部成员权限、跨租户/工作区授权、批量角色变更、影响自身权限或影响最后 owner 的操作必须进入 `risk-actions.md`，必要时进入 `auth-session-reauth.md`。确认前请求数为 0；未知结果不能伪装成成功或失败。

### 移除、禁用、启用和转移 Owner 是风险操作

移除成员、禁用成员、启用成员、恢复成员、转移 owner、移除最后管理员、移除自己、禁用自己、批量移除或批量禁用都必须进入 `risk-actions.md`。确认面板必须展示目标成员、角色、范围、影响对象、当前 owner/管理员数量、恢复能力、会话影响、审计回执和未知结果处理。

不能用 Switch/Toggle 直接启停成员，也不能点击“移除成员”后直接发送请求。若保留开关视觉，只能作为打开风险确认承载面的入口；确认完成前旧 `committed` 状态不变。

### 权限、会话和租户变化必须原子收敛

权限变化、会话过期、重新认证失败、账号切换、身份切换、租户/工作区切换、角色版本变化、成员版本变化或对象删除后，旧成员列表、旧角色 Select、旧邀请链接、旧菜单、旧按钮、旧确认面板、旧 Toast/Notification、旧审计跳转、旧焦点目标和旧 ARIA 引用必须失效或重算。

迟到请求、缓存回放、浏览器 Back、任务中心回调、邮件链接 callback 和审计跳转只有在 `membershipOwnerId`、租户/工作区、成员版本、权限版本和请求身份仍匹配时才能写回。

### 审计与反馈不能泄露

邀请、重发、撤销、接受、拒绝、角色变更、移除、禁用、启用、恢复、转移 owner、失败、取消和未知结果都需要审计绑定。审计可记录主体、目标、角色快照、成员版本、租户/工作区、权限版本、时间和结果；无权限审计不得泄露成员姓名、邮箱、角色、邀请状态、外部身份、成员是否存在、内部 ID 或旧缓存。

Toast、Notification、Banner 只能辅助提示，不能作为唯一结果回执、唯一邀请恢复入口、唯一审计入口、唯一错误说明或唯一权限原因。成员邮箱、邀请链接、内部 ID、外部身份和角色详情不得泄露在全局反馈里。

### 移动端能力不能丢

移动端不得删除邀请成员、成员状态、角色说明、角色变更确认、撤销邀请、重新发送邀请、禁用原因、移除/恢复路径、转移 owner、审计入口、权限说明和错误恢复。低高度、虚拟键盘、系统字体放大、安全区域、浏览器 Back、WebView 返回和触摸长按后，成员身份、角色、确认按钮、取消路径和错误摘要仍必须可达。

## 验收策略

后续实现新增静态审计 `docs/testing/members-invitations-access/members-invitations-access-audit.rb`，检查：

- `SKILL.md` 有成员、邀请、角色、owner 转移、成员移除、禁用、external member 等路由。
- `references/members-invitations-access.md` 存在并包含 `membershipAccessState`、成员状态、邀请状态、角色草稿/提交、风险操作、旧链接失效、权限/会话/租户收敛、审计无泄露、Toast 边界、移动端恢复和未验证边界。
- README / HANDOFF 有中文摘要。
- RED/GREEN 证据覆盖普通用户行、角色 Select 直接提交、Switch 直接禁用、旧邀请链接有效、最后 owner 被移除、无权限泄露成员邮箱、Toast-only 成功、未知结果伪装成功、移动端删除恢复路径等负例。
- mutation 模式删除任一关键规则会失败。

运行时真实浏览器、移动端设备、屏幕阅读器、真实邀请邮件/链接、真实权限切换、真实会话过期、真实重新认证、真实成员角色变更和真实审计写入未执行时，必须标为**未验证**，不能把静态审计写成运行时通过。

## 设计取舍

此规范刻意不定义业务角色名，也不定义后台权限系统如何计算权限。它只定义前端交互必须持有的成员身份、邀请身份、角色授权意图、风险确认、权限/认证绑定和审计回执。这样既能约束管理台最常见的成员管理事故，又不会把本 Skill 变成某个项目的组织模型。
