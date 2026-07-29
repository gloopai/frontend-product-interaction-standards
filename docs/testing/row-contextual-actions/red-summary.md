# 行操作与上下文操作规范 RED 复核

## 目标

证明审计会拒绝把行操作当作当前 DOM 按钮或菜单项 key 的错误实现。

## 覆盖的失败样本

- 缺少 `rowActionState` 或关键状态字段。
- 缺少“行操作不是在当前行 DOM 上挂一个按钮”的边界。
- 动作请求读取当前 hover row、active row、虚拟列表 DOM、旧 record 或 rowIndex。
- 虚拟行复用、分页、筛选、排序、自动刷新或权限变化后旧菜单仍可操作。
- visible、hidden-by-permission、disabled-by-state、disabled-by-permission、read-only 和 not-applicable 混用。
- 更多菜单隐藏唯一危险确认、权限原因、错误恢复或核心任务入口。
- Toast 是唯一结果、错误、审计或恢复路径。
- 无权限泄露记录名称、字段值、状态、动作数量、菜单项、禁用原因、内部 ID、旧 tooltip 或旧 aria-label。
- SKILL、README、HANDOFF 或相邻 owner 未建立路由。

## 命令

```bash
ruby docs/testing/row-contextual-actions/row-contextual-actions-audit.rb --mutations
```

## 结果

所有 mutation 均按预期失败，审计能够捕获关键缺口。

