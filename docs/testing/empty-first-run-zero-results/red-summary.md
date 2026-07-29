# 空态、无结果与首次使用引导规范 RED 复核

## 目标

证明审计会拒绝把所有空态都写成“暂无数据”的错误实现。

## 覆盖的失败样本

- 缺少 `emptyStateDecision` 或关键状态字段。
- 缺少“空状态不是‘没有数据’的单一文案”边界。
- 未区分 firstRunEmpty、trueEmpty、zeroResults、permissionEmpty、errorEmpty、loadingEmpty、archivedEmpty、notConfiguredEmpty 和 readOnlyEmpty。
- zeroResults 被误导到创建入口，而不是清空筛选、调整关键词、重置时间范围或恢复默认视图。
- 只读报表、权限不足、能力未启用、不可写范围和筛选无结果仍展示创建入口。
- 权限空态泄露对象名称、数量、字段、筛选值、归档数量、文件名、金额、内部 ID 或旧可访问名称。
- SKILL、README、HANDOFF 或相邻 owner 未建立路由。
- 未执行的运行时验证没有标为未验证。
- 文档出现项目专属泄露词。

## 命令

```bash
ruby docs/testing/empty-first-run-zero-results/empty-first-run-zero-results-audit.rb --mutations
```

## 结果

所有 mutation 均按预期失败，审计能够捕获关键缺口。

