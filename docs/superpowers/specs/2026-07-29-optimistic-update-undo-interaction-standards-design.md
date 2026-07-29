# 乐观更新、撤销与回滚交互规范设计

## 背景

管理台中常见“先把界面改掉，再等接口结果”的交互：开关切换、状态启停、收藏、归档、批量更新、排序保存、卡片操作、Toast 撤销和弱网重试。没有统一 owner 时，前端容易把 pending 当成功、把 Toast 撤销当恢复机制、失败后用 DOM 或数组索引猜测回滚，或者让迟到响应覆盖新状态。

## 推荐方案

新增独立 owner `references/optimistic-update-undo.md`。它不替代按钮、表单、风险操作、状态流转或反馈状态，而是统一管理 mutation 的“非权威阶段”：乐观投影、撤销窗口、回滚依据、权威结果 reconciliation、迟到响应、幂等、权限收敛和移动端恢复。

## 目标

1. 定义 `optimisticMutationState`，覆盖 `sourceSnapshot`、`visibleProjection`、`pendingMutation`、`commitSnapshot`、`undoPolicy`、`rollbackPolicy`、`reconciliationPolicy` 和 `runtimeVerification`。
2. 明确“乐观更新不是成功回执”，未获权威确认前必须标记 pending/syncing/undoable/queued。
3. 明确高风险、不可逆、敏感导出、权限变更、密钥重置和强审计操作默认不得乐观完成。
4. 明确撤销不是 Toast 装饰，失败回滚不得基于 DOM、当前数组索引、旧缓存或猜测值。
5. 将按钮、表单、风险、状态流转、列表结果、卡片、反馈、权限和响应式规范接入该 owner。

## 非目标

- 不定义服务端事务、数据库补偿、事件溯源或缓存库 API。
- 不强制所有 mutation 使用乐观更新；很多管理台操作应该等待权威结果。
- 不改变已有风险确认、审计、表单 dirty 或状态生命周期 owner 的职责。

## 验收

- `SKILL.md` 能自动路由乐观更新、撤销、回滚、离线队列、迟到响应和幂等相关任务。
- `README.md`、`HANDOFF.md` 和相邻 owner 都引用 `references/optimistic-update-undo.md`。
- RED/GREEN 证据覆盖 `optimisticMutationState`、`undoPolicy`、`rollbackPolicy`、`reconciliationPolicy`、`idempotencyPolicy` 和“未验证”边界。
- 审计脚本能捕获 owner 关键语义、路由、README、HANDOFF、相邻引用和项目泄露问题。
