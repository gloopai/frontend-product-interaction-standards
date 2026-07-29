# 批量操作与批处理动作规范 RED 复核

## 目标

证明审计会拒绝常见的批量操作缺陷，而不是只检查文件存在。

## 覆盖的失败样本

- 缺少 `bulkActionState` 或关键状态字段。
- 把批量操作降级成“对当前可见行循环单条操作”或“选择数量 + 一个按钮”。
- 未冻结 `selectionSnapshot`、`scopeBinding`、`targetIdentitySet`、`eligibilityMap`、`permissionBoundary` 和 `requestIdentity`。
- 混用当前页、已选择项、全部筛选结果、跨页集合和排除项集合。
- 筛选、搜索、排序、分页、权限、租户/工作区、数据版本或 eligibility 变化后旧批量意图仍可提交。
- 部分成功没有拆分成功、失败、跳过、冲突、未知和处理中对象范围。
- 批量结果只靠 Toast，没有 `resultReceipt`、`partialResult` 和 `recoveryActions`。
- 无权限或权限降级泄露旧目标名称、数量、字段、失败明细、导出范围、内部 ID 或旧回执。
- 把未执行的真实浏览器、键盘、读屏、触摸、弱网、异步任务或移动端验证写成已验证。
- SKILL、README、HANDOFF 或相邻 owner 未建立路由。
- 文档出现项目专属泄露词。

## 命令

```bash
ruby docs/testing/bulk-actions-batch-operations/bulk-actions-batch-operations-audit.rb --mutations
```

## 结果

所有 mutation 均按预期失败，审计能够捕获关键缺口。

