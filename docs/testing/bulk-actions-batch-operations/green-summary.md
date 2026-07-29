# 批量操作与批处理动作规范 GREEN 复核

## 目标

证明新增批量操作 owner、SKILL 路由、README、HANDOFF 和相邻高频 owner 已形成可执行规范。

## 通过条件

- `references/bulk-actions-batch-operations.md` 声明 `bulkActionState`，并覆盖范围、目标、可执行性、确认、请求、部分成功、结果回执、恢复、权限、移动端和生命周期。
- `references/data-tables.md`、`references/card-list-results.md`、`references/buttons.md`、`references/risk-actions.md`、`references/approval-workflows.md`、`references/exports-downloads-artifacts.md`、`references/permissions-tenancy-visibility.md` 和 `references/feedback-states.md` 均转接到 `references/bulk-actions-batch-operations.md`。
- SKILL 路由包含批量操作、批处理动作、bulk action 和 apply to all filtered。
- README 和 HANDOFF 记录批量操作与批处理动作规范。
- 运行时验证未执行的项目保持“未验证”标记。

## 命令

```bash
ruby docs/testing/bulk-actions-batch-operations/bulk-actions-batch-operations-audit.rb
```

## 结果

审计通过，新增规范未包含项目专属泄露词。

