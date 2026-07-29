# 条件字段与依赖输入规范 RED 复核

## 目标

证明审计会拒绝把字段联动写成临时 UI if 判断的错误实现。

## 覆盖的失败样本

- 缺少 `fieldDependencyState` 或关键状态字段。
- 缺少“字段联动不是 `if value then show field` 的临时 UI 逻辑”边界。
- 混用 hidden-by-condition、hidden-by-permission、disabled-by-condition、disabled-by-permission、read-only 和 not-applicable。
- 上游字段变化后，下游字段没有原子进入保留、清空、失效、重算、禁用、只读或隐藏状态。
- 隐藏字段旧值仍静默提交。
- 下游候选、active option、孤儿值、远程结果和异步校验未绑定当前 `upstreamSnapshot`。
- 条件必填未在 label、帮助文本、错误摘要和提交前校验中一致表达。
- 自动填充、派生值、默认值、继承值和用户输入不可区分。
- 无权限泄露字段名称、字段值、候选项、字段数量、条件表达式、默认值、错误原因、内部 ID 或旧可访问名称。
- SKILL、README、HANDOFF 或相邻 owner 未建立路由。

## 命令

```bash
ruby docs/testing/conditional-fields-dependent-inputs/conditional-fields-dependent-inputs-audit.rb --mutations
```

## 结果

所有 mutation 均按预期失败，审计能够捕获关键缺口。

