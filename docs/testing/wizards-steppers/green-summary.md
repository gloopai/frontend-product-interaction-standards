# 分步流程与配置向导规范 GREEN 摘要

当前 GREEN 状态要求：

- `references/wizards-steppers.md` 已定义 `wizardState`，并覆盖 `wizardOwnerId`、`flowKind`、`stepRegistry`、`currentStepId`、`stepStates`、`stepDrafts`、`committedStepValues`、`crossStepValidation`、`progressPolicy`、`reviewSnapshot`、`submitSnapshot`、`asyncTaskBinding`、`exitPolicy`、`responsivePolicy` 和 `a11yPolicy`。
- 每个步骤必须有稳定 ID、标题、进入条件、完成条件和错误归属。
- 上一步、下一步、跳过、直接跳转、保存草稿、取消和完成必须是不同意图。
- `stepDrafts`、`committedStepValues`、`reviewSnapshot` 和 `submitSnapshot` 必须分离。
- 恢复草稿必须重新校验权限、依赖、选项有效性、文件引用、时间范围和业务版本。
- 上游步骤变化后，依赖它的后续步骤、预检、预览、费用、权限、导出范围和确认摘要必须失效或重算。
- 最终提交只能读取仍有效的 `reviewSnapshot` / `submitSnapshot`，不得读取正在编辑的草稿。
- 完成状态必须区分成功、部分成功、失败、冲突、未知、异步处理中、已取消和过期。
- 取消客户端流程不等于取消服务端任务。
- 移动端不得删除步骤标题、当前进度、步骤错误、上一步、下一步、保存/放弃草稿、复核页、取消路径、结果回执或恢复入口。
- `SKILL.md`、`README.md` 和 `HANDOFF.md` 均已接入 `references/wizards-steppers.md`。
- 本次是文档和静态审计更新，真实浏览器、键盘、读屏、触摸、移动端、断点转换、权限变化和异步竞态检查仍标为未验证。

审计命令：

```bash
ruby docs/testing/wizards-steppers/wizards-steppers-audit.rb --mutations
```
