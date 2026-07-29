# 行操作与上下文操作规范 GREEN 复核

## 目标

证明新增 owner、路由和相邻规范转接完整可用。

## 通过条件

- `references/row-contextual-actions.md` 声明 `rowActionState`。
- owner 覆盖动作目标、来源快照、旧行防护、动作可见性、菜单边界、请求身份、结果回执、权限无泄露和移动端。
- SKILL、README、HANDOFF 和相邻 owner 均指向 `references/row-contextual-actions.md`。
- 运行时验证未执行的项目保持“未验证”。

## 命令

```bash
ruby docs/testing/row-contextual-actions/row-contextual-actions-audit.rb
```

## 结果

审计通过，新增规范未包含项目专属泄露词。

