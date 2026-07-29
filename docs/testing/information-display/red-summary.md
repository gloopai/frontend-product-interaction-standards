# 信息展示与详情页规范 RED 摘要

本审计覆盖 `informationDisplayState`、`displayOwnerId`、`subjectIdentity`、`displaySnapshot`、`fieldSemantics`、`visibilityPolicy`、`freshnessState`、`statusSemantics`、`actionBinding`、`copyPolicy`、`responsivePolicy`、`a11yPolicy`、`auditBinding`、disabled 表单控件、唯一语义来源和运行时检查未验证边界。

负向变异会删除或替换以下关键约束，并要求审计失败：

- 删除 `informationDisplayState` 或必要状态字段。
- 删除“详情页不得直接内嵌 input、textarea、select、可编辑表格或行内保存按钮来完成编辑”。
- 删除“只读状态不得用 disabled 表单控件充当展示文本”。
- 删除“空值、未配置、未知、加载失败、无权限、已删除和不适用必须可区分”。
- 删除“状态标签、徽标、颜色、图标和趋势箭头不能是唯一语义来源”。
- 删除“指标卡必须声明指标名、口径、单位、时间范围、数据延迟、刷新时间和权限范围”。
- 删除“复制操作不得复制脱敏或无权限字段的真实值”。
- 删除“无权限展示不得泄露对象名称、字段值、数量、文件名、内部 ID、筛选值或旧缓存”。
- 删除“移动端不得删除字段 label、单位、状态说明、错误/权限说明、复制/恢复路径或审计入口”。
- 把“未验证”改成“已验证”。
- 删除 `SKILL.md` 中指向 `references/information-display.md` 的路由。
- 注入 `fex-admin` 等项目专属词。

这些 RED 变异确保详情页不会退回到内嵌编辑、disabled 控件伪只读、空值混淆、状态只靠颜色、指标口径缺失、复制绕过脱敏、无权限泄漏或移动端信息缩水。
