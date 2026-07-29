# 信息展示与详情页规范 GREEN 摘要

当前 GREEN 状态要求：

- `references/information-display.md` 已定义 `informationDisplayState`，并覆盖 `displayOwnerId`、`subjectIdentity`、`displaySnapshot`、`fieldSemantics`、`visibilityPolicy`、`freshnessState`、`statusSemantics`、`actionBinding`、`copyPolicy`、`responsivePolicy`、`a11yPolicy` 和 `auditBinding`。
- 详情页不得直接内嵌 input、textarea、select、可编辑表格或行内保存按钮来完成编辑。
- 只读状态不得用 disabled 表单控件充当展示文本；新增、编辑、复制创建和配置必须进入合适承载面。
- 空值、未配置、未知、加载失败、无权限、已删除和不适用必须可区分。
- 状态标签、徽标、颜色、图标和趋势箭头不能是唯一语义来源。
- 指标卡必须声明指标名、口径、单位、时间范围、数据延迟、刷新时间和权限范围。
- 复制操作不得复制脱敏或无权限字段的真实值；无权限展示不得泄露对象名称、字段值、数量、文件名、内部 ID、筛选值或旧缓存。
- 移动端不得删除字段 label、单位、状态说明、错误/权限说明、复制/恢复路径或审计入口。
- `SKILL.md`、`README.md` 和 `HANDOFF.md` 均已接入 `references/information-display.md`。
- 本次是文档和静态审计更新，真实浏览器、读屏、触摸、缩放、刷新、权限切换和真实数据检查仍标为未验证。

审计命令：

```bash
ruby docs/testing/information-display/information-display-audit.rb --mutations
```
