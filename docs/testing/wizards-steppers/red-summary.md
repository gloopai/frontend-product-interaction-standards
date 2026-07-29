# 分步流程与配置向导规范 RED 摘要

本审计覆盖 `wizardState`、`wizardOwnerId`、`flowKind`、`stepRegistry`、`currentStepId`、`stepStates`、`stepDrafts`、`committedStepValues`、`crossStepValidation`、`progressPolicy`、`reviewSnapshot`、`submitSnapshot`、`asyncTaskBinding`、`exitPolicy`、`responsivePolicy`、`a11yPolicy`、取消客户端流程不等于取消服务端任务和运行时检查未验证边界。

负向变异会删除或替换以下关键约束，并要求审计失败：

- 删除 `wizardState` 或必要状态字段。
- 删除“每个步骤必须有稳定 ID、标题、进入条件、完成条件和错误归属”。
- 删除“上一步、下一步、跳过、直接跳转、保存草稿、取消和完成必须是不同意图”。
- 删除“`stepDrafts`、`committedStepValues`、`reviewSnapshot` 和 `submitSnapshot` 必须分离”。
- 删除“恢复草稿必须重新校验权限、依赖、选项有效性、文件引用、时间范围和业务版本”。
- 删除“上游步骤变化后，依赖它的后续步骤、预检、预览、费用、权限、导出范围和确认摘要必须失效或重算”。
- 删除“最终提交只能读取仍有效的 `reviewSnapshot` / `submitSnapshot`，不得读取正在编辑的草稿”。
- 删除“完成状态必须区分成功、部分成功、失败、冲突、未知、异步处理中、已取消和过期”。
- 删除“取消客户端流程不等于取消服务端任务”。
- 删除“移动端不得删除步骤标题、当前进度、步骤错误、上一步、下一步、保存/放弃草稿、复核页、取消路径、结果回执或恢复入口”。
- 把“未验证”改成“已验证”。
- 删除 `SKILL.md` 中指向 `references/wizards-steppers.md` 的路由。
- 注入 `fex-admin` 等项目专属词。

这些 RED 变异确保分步流程不会退回到局部状态拼接、步骤状态不明、草稿与提交混淆、跨步依赖不失效、客户端取消伪装服务端取消或移动端步骤能力缩水。
