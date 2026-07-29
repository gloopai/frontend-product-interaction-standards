# 回收站、软删除、归档恢复与保留期交互规范设计

## 背景

管理台删除类操作已经有 `risk-actions.md` 约束确认前风险，也有 `status-lifecycle-transitions.md` 约束状态流转。但删除之后对象“在哪里、多久能恢复、谁能看到、如何恢复、何时永久删除、旧入口如何失效、审计如何追溯”仍缺少独立 owner。实际项目很容易只做一个 Toast 撤销，或把归档、禁用、软删除、永久删除混成同一种状态。

## 推荐方案

新增 `references/trash-restore-retention.md` 作为删除后生命周期 owner。它不替代危险确认，而是负责确认之后的恢复、回收站、保留期、永久删除、权限无泄露、批量部分成功、任务中心和审计绑定。

相比把规则塞进 `risk-actions.md`，独立 owner 可以让删除前风险和删除后生命周期保持边界清晰；相比只在状态流转规范补充，独立 owner 更能覆盖回收站视图、旧入口清理、保留期到期、legal hold 和恢复冲突。

## 核心要求

- 每个可删除、可归档、可恢复或可永久删除对象范围声明 `trashRestoreState`。
- 明确区分 soft delete、archive、disable、restore、permanent delete、purge、retention expired 和 legal hold。
- Toast 不能作为唯一恢复入口、唯一审计回执、唯一失败说明或唯一未知结果处理。
- 承诺可恢复时必须有可发现恢复入口，并绑定同一 `trashRestoreState`。
- 保留期必须展示绝对时间、时区、起算点、规则来源和到期动作。
- 永久删除、清空回收站、到期清理必须进入 `risk-actions.md`。
- 恢复前检查版本、父级、唯一键、权限、状态机、保留期、关联对象和冲突。
- 删除后旧列表、详情、预览、下载、复制、菜单、选择、导出、搜索、URL、ARIA 和焦点目标必须失效或重算。
- 无权限不得泄露已删除对象名称、数量、字段、文件名、路径、删除原因、操作者、删除时间、保留期、内部 ID 或旧缓存。
- 批量删除/恢复/永久删除必须冻结目标范围，并提供部分成功恢复路径。

## 测试策略

新增 `docs/testing/trash-restore-retention/trash-restore-retention-audit.rb`：

- 检查 owner 文档包含状态字段和硬性术语。
- 检查 `SKILL.md`、`README.md`、`HANDOFF.md` 接入。
- 检查相邻 owner 引用本 owner 和 `trashRestoreState`。
- 使用 mutation 模式确认删除核心约束会失败。
- 对新增文档执行项目泄漏扫描。

