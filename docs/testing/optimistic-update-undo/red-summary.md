# RED：乐观更新、撤销与回滚规范缺口

## 当前失败点

- 缺少独立 `optimisticMutationState`，乐观 UI、先改界面、撤销、失败回滚、离线队列、自动重试、迟到响应和幂等容易散落在按钮、表单、列表、卡片、反馈或风险 owner 中。
- 缺少 `mutationOwnerId`、`mutationSurface`、`sourceSnapshot`、`targetIdentity`、`visibleProjection`、`pendingMutation`、`commitSnapshot`、`idempotencyPolicy`、`optimisticPolicy`、`undoPolicy`、`rollbackPolicy`、`reconciliationPolicy`、`permissionBoundary`、`feedbackBinding`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification` 时，无法证明 mutation 身份、投影、提交、撤销、回滚、合并和验证边界。
- 乐观更新不是成功回执，也不是绕过确认、权限、审计或服务端权威状态的捷径；当前缺口会让 pending、syncing、undoable 或 queued 被误写成“已成功”。
- 高风险、不可逆、敏感导出、权限变更、密钥重置和强审计操作可能被错误地乐观完成。
- 撤销入口可能只存在于自动消失 Toast；`undoPolicy` 的窗口、对象、请求身份、结束状态和失败恢复不完整。
- 失败回滚可能依赖 DOM、当前数组索引、旧缓存或猜测值，而不是 `sourceSnapshot`、权威刷新或 conflict payload。
- 迟到响应、重复响应和离线重放可能覆盖当前对象、当前字段、当前权限或新 mutation 的可见投影。
- 真实浏览器、移动端、键盘、读屏、弱网、离线、重试、权限变化、版本冲突和迟到响应验证目前应标为未验证。

## 预期失败检测

审计应能在以下突变中失败：

- 删除 `optimisticMutationState` 或任一关键字段。
- 删除“乐观更新不是成功回执”。
- 删除 pending/syncing/undoable/queued 非终态要求。
- 删除高风险不得乐观完成边界。
- 删除 Toast-only 撤销禁止。
- 删除基于 `sourceSnapshot` 的回滚要求。
- 删除迟到响应匹配要求。
- 删除权限降级和旧投影清理要求。
- 将运行时未验证边界写成已验证。
- 删除 `SKILL.md` 路由、README 链接、HANDOFF 小节或相邻 owner 引用。
