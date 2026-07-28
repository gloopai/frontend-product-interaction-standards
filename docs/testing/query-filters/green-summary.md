# 查询条件与筛选规范 GREEN 总结

GREEN 输出证明查询条件区被建模为独立 Query Filter owner，而不是散落在 Data Table、Form、Select 或 Admin 文本中。审计命令：

```bash
ruby docs/testing/query-filters/query-filters-audit.rb --mutations
```

审计覆盖：

- `queryFilterState` 的 `filterOwnerId`、`filterDraft`、`appliedFilters`、`defaultFilters`、`filterSchema`、`queryIntent`、`urlState` 和 `requestBinding`。
- `filterDraft` 与 `appliedFilters` 必须分离。
- 字段内部草稿、Select query、active option 和 popup 状态不得进入 `filterDraft`、`appliedFilters`、URL 或结果摘要。
- 每个条件必须声明 `applyMode: immediate | explicit`，未声明时不得发查询。
- “重置”恢复 `defaultFilters`，“清空”只移除可清空条件。
- 已应用条件必须持续可见或在摘要中可发现。
- 只有明确 `urlSafe` 且非 `sensitive` 的已应用条件可以进入 URL。
- 不得静默忽略 URL 中的已知条件。
- 无权条件、敏感值、旧租户选项和旧 URL 状态不能继续暴露。
- 移动端不得删除核心筛选能力。
- 通用 owner 保持项目无关，不包含业务项目专属名称、页面、模块或组件库。

浏览器、屏幕阅读器、触摸设备和真实组件运行时未执行，保持未验证。
