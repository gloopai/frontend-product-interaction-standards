# GREEN：乐观更新、撤销与回滚规范已加固

## 新增能力

- 新增 `references/optimistic-update-undo.md`，成为乐观更新、乐观 UI、先改界面、pending mutation、syncing、撤销、回滚、失败回滚、离线队列、自动重试、迟到响应、幂等和冲突恢复的 owner。
- `optimisticMutationState` 已结构化声明 `mutationOwnerId`、`mutationSurface`、`sourceSnapshot`、`targetIdentity`、`visibleProjection`、`pendingMutation`、`commitSnapshot`、`idempotencyPolicy`、`optimisticPolicy`、`undoPolicy`、`rollbackPolicy`、`reconciliationPolicy`、`permissionBoundary`、`feedbackBinding`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification`。
- 明确乐观更新不是成功回执，也不是绕过确认、权限、审计或服务端权威状态的捷径。
- 明确未得到权威确认前，乐观状态必须标记为 pending、syncing、undoable 或 queued。
- 明确高风险、不可逆、敏感导出、权限变更、密钥重置和强审计操作默认不得乐观完成。
- 明确撤销入口不得只存在于自动消失 Toast，并必须声明 `undoPolicy`。
- 明确失败回滚必须基于 `sourceSnapshot`、权威刷新或 conflict payload，不得通过 DOM、当前数组索引、旧缓存或猜测值回滚。
- 明确权威结果、迟到响应、重复响应和离线重放必须匹配 owner、幂等键、权限版本、目标版本、租户/工作区和 `commitSnapshot`。
- 明确权限降级、租户切换、对象删除、能力关闭、认证过期、版本冲突或 owner 卸载后，旧投影、旧撤销入口、旧回滚依据、旧成功提示和旧回调必须失效。

## 集成范围

- `SKILL.md` 已加入乐观更新、撤销、回滚、离线队列、迟到响应和幂等相关路由。
- `README.md` 和 `HANDOFF.md` 已加入使用者可见摘要。
- 按钮、表单、风险操作、状态流转、列表结果、卡片、反馈、权限规范已引用 `references/optimistic-update-undo.md`。

## 验证状态

- 静态结构、路由、相邻引用、README、HANDOFF、RED/GREEN 证据和项目泄露扫描由 `docs/testing/optimistic-update-undo/optimistic-update-undo-audit.rb` 覆盖。
- 真实浏览器、移动端、键盘、读屏、弱网、离线、重试、权限变化、版本冲突和迟到响应仍需在具体项目中验证；当前规范明确标为未验证。
