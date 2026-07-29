# 条件字段与依赖输入规范 GREEN 复核

## 目标

证明新增 owner、路由和相邻规范转接完整可用。

## 通过条件

- `references/conditional-fields-dependent-inputs.md` 声明 `fieldDependencyState`。
- owner 覆盖显隐、禁用、只读、不适用、条件必填、上游变化、清值、候选失效、隐藏值提交、自动填充、权限无泄露和移动端。
- SKILL、README、HANDOFF 和相邻 owner 均指向 `references/conditional-fields-dependent-inputs.md`。
- 运行时验证未执行的项目保持“未验证”。

## 命令

```bash
ruby docs/testing/conditional-fields-dependent-inputs/conditional-fields-dependent-inputs-audit.rb
```

## 结果

审计通过，新增规范未包含项目专属泄露词。

