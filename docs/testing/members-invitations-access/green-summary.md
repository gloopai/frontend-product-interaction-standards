# 成员、邀请与团队访问管理 GREEN 证据摘要

当前规范和审计证明以下结构已经就位：

- `membershipAccessState` 包含 `membershipOwnerId`、`principalSnapshot`、`memberIdentity`、`membershipStatus`、`invitationState`、`roleAssignmentState`、`accessChangeIntent`、`permissionBoundary`、`authBinding`、`riskBinding`、`auditBinding` 和 `resultReceipt`。
- 成员状态、邀请状态、角色状态、权限状态和认证状态分开表达，`active`、`invited`、`invite-expired`、`invite-revoked`、`disabled`、`removed`、`owner-transfer-required`、`external` 和 `unknown` 不合并。
- 邀请成员绑定 `invitationState`、目标邮箱/账号、租户/工作区、角色、邀请人、有效期、权限版本和审计身份。
- 旧邀请链接、旧邮件入口、旧复制链接、旧 Toast、旧任务入口和浏览器历史在撤销、过期、角色变更、租户/工作区切换、权限变化、会话过期或重复邀请后失效或重新证明安全。
- 重新发送邀请不会创建重复成员，也不能绕过权限复核。
- 无权限用户不能通过邀请错误、搜索结果、邮箱补全、列表数量、Toast、Notification、审计摘要或 DOM/ARIA 推断成员姓名、邮箱、角色、邀请状态、外部身份、成员是否存在或内部 ID。
- 角色 Select 只能编辑 `roleAssignmentState` 草稿；确认前不得改变已生效角色，确认前请求数为 0。
- 保存角色变更绑定当前成员版本、角色版本、权限版本、租户/工作区、操作者身份和目标角色快照。
- 提升管理员、降低管理员、修改外部成员权限、跨租户/工作区授权、批量角色变更、影响自身权限或影响最后 owner 的操作进入 `risk-actions.md`，必要时进入 `auth-session-reauth.md`。
- 移除成员、禁用成员、启用成员、恢复成员、转移 owner、移除最后管理员、移除自己、禁用自己、批量移除或批量禁用进入 `risk-actions.md`。
- Switch/Toggle 不能直接启停成员；若保留开关视觉，只能作为打开风险确认承载面的入口。
- 权限、会话、账号、身份、租户/工作区、角色版本、成员版本或对象状态变化后，旧成员列表、旧角色 Select、旧邀请链接、旧菜单、旧按钮、旧确认面板、旧 Toast/Notification、旧审计跳转、旧焦点目标和旧 ARIA 引用失效或重算。
- 迟到请求、缓存回放、浏览器 Back、任务中心回调、邮件链接 callback 和审计跳转只有在 `membershipOwnerId`、租户/工作区、成员版本、权限版本和请求身份仍匹配时才能写回。
- 未知结果不会伪装成角色变更成功、邀请成功、撤销成功、移除成功或禁用成功。
- Toast、Notification 和 Banner 只能辅助提示，不能作为唯一结果回执、唯一邀请恢复入口、唯一审计入口、唯一错误说明或唯一权限原因。
- 移动端保留邀请成员、成员状态、角色说明、角色变更确认、撤销邀请、重新发送邀请、禁用原因、移除/恢复路径、转移 owner、审计入口、权限说明和错误恢复。
- 真实浏览器、移动端设备、屏幕阅读器、真实邀请邮件/链接、真实权限切换、真实会话过期、真实重新认证、真实成员角色变更和真实审计写入检查在本轮文档工作中仍是未验证，需要在具体页面实现时补充。
