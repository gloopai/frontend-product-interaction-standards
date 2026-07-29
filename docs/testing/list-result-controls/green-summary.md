# 列表结果控制规范 GREEN 复核

## 结论

GREEN 通过：已新增 `references/list-result-controls.md`，并补齐路由、README、HANDOFF、相邻 owner 边界和 mutation 审计。

## 执行命令

`ruby docs/testing/list-result-controls/list-result-controls-audit.rb --mutations`

## 覆盖点

- listResultControlsState
- resultControlsOwnerId、surfaceKind、appliedQueryBinding、querySnapshot、requestGeneration、requestPhase
- sortState、paginationState、refreshState、resultSummary、selectionImpact
- urlHistoryBinding、permissionBoundary、feedbackBinding、responsivePolicy
- 已应用查询、筛选草稿、搜索输入草稿
- 排序变化、页大小变化、有效筛选/关键词变化
- 迟到响应、owner live、requestGeneration、querySnapshot
- 页码分页、游标分页、总数不可靠、精确总页数
- refreshing、stale、刷新失败、旧结果
- URL、浏览器返回、保存视图恢复
- 移动端、虚拟键盘、safe-area
- 未验证

## 未验证

真实浏览器、移动端、触摸、虚拟键盘、屏幕阅读器、权限切换、网络迟到和数据版本变化尚未执行；这些必须在业务项目接入时继续标为未验证。
