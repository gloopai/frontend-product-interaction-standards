# 条件字段与依赖输入交互规范设计

## 背景

管理台里的表单、筛选和设置页经常有字段联动：上游选择改变后，下游字段显示、隐藏、必填、禁用、候选项和默认值都会变化。没有独立规范时，常见问题是隐藏字段旧值仍提交、旧候选继续可选、条件必填只靠红星表达、权限降级后旧字段值或错误泄露。

## 设计方案

新增 `references/conditional-fields-dependent-inputs.md` 作为条件字段与依赖输入 owner。核心状态为 `fieldDependencyState`，明确依赖图、上游快照、下游策略、显隐/禁用/只读语义、清值策略、候选失效、校验重算、提交快照和权限边界。

## 关键规则

- 字段联动不是 `if value then show field` 的临时 UI 逻辑。
- hidden-by-condition、hidden-by-permission、disabled-by-condition、disabled-by-permission、read-only 和 not-applicable 必须区分。
- 上游字段变化后，下游字段必须原子进入保留、清空、失效、重算、禁用、只读或隐藏。
- 隐藏字段的旧值不得静默提交。
- 级联候选、远程搜索、active option、孤儿值和异步校验必须绑定当前 `upstreamSnapshot`。
- 条件必填必须在 label、帮助文本、错误摘要和提交前校验中一致表达。
- 自动填充、派生值、默认值、继承值和用户输入必须可区分。

## 非目标

- 不定义后端规则引擎、表达式 DSL、表单 schema 语法或具体业务字段。
- 不替代 Tree/Cascader、Select、多选、表单提交和设置保存 owner。
- 不覆盖完整复杂规则构建器或流程编排器。

