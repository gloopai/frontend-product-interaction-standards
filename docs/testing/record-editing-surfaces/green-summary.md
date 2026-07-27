# 记录编辑承载面 GREEN 总结

GREEN 输出将列表中的新增、编辑、复制创建和配置全部建模为 Dialog、Drawer 或独立页入口，而不是列表内字段控件。模板列表维护标题、描述、正文、分类、状态和排序时，列表行保持只读，只放操作入口；每行 input、textarea、select、排序输入和“保存”按钮均被判定为违规。

审计命令：

```bash
ruby docs/testing/record-editing-surfaces/record-editing-surfaces-audit.rb --mutations
```

审计覆盖：

- owner 中的 `RES-SCOPE-*`、`RES-CHOICE-*`、`RES-LIST-*`、`RES-FORM-*`、`RES-AUDIT-*` 和 `RES-RSP-*` 规则族。
- `editSurfaceState` 的来源列表快照、记录身份、权限版本、表单会话、返回策略和验证边界。
- 常驻可编辑列表、单元格编辑、行内保存按钮、行展开表单、可编辑排序输入和报表自动编辑入口等负例。
- Dialog、Drawer、表单、数据表格、响应式和管理台 owner 的联动。

本总结只证明静态文档结构和结构化契约可审计；浏览器、屏幕阅读器、触摸设备、真实组件运行时和真实权限竞态未执行，保持未验证。

