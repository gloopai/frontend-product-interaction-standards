# 批量操作与批处理动作交互规范实施计划

## 计划

1. 创建 `references/bulk-actions-batch-operations.md`，定义 owner 边界、`bulkActionState`、范围绑定、确认、请求、结果、权限、移动端和生命周期。
2. 更新 SKILL 路由，让批量操作、批处理动作、bulk action 和 apply to all filtered 命中该 owner。
3. 更新 README、HANDOFF 和相邻 owner，形成从表格、卡片、按钮、风险、审批、导出、权限、反馈到批量 owner 的转接关系。
4. 增加结构化审计、RED 和 GREEN 复核文档。
5. 执行 mutation、全量审计、Markdown 链接、diff check 和项目专属词扫描。

## 验收

- 审计能拒绝缺少 owner、范围冻结、部分成功、Toast 边界、权限无泄露和路由转接的文档。
- 全量审计通过。
- 文档链接可解析。
- 新增文档保持中文且不包含项目专属词。

