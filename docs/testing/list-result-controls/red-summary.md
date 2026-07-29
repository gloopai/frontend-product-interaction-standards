# 列表结果控制规范 RED 复核

## 结论

RED 通过：新增审计在 owner 文件缺失时失败，证明当前仓库还没有独立的列表结果控制 owner。

## 执行命令

`ruby docs/testing/list-result-controls/list-result-controls-audit.rb`

## 期望失败

`missing file: .../references/list-result-controls.md`

## 覆盖点

- listResultControlsState
- resultControlsOwnerId、appliedQueryBinding、querySnapshot、requestGeneration、requestPhase
- sortState、paginationState、refreshState、resultSummary、selectionImpact
- urlHistoryBinding、permissionBoundary、feedbackBinding、responsivePolicy
- 已应用查询、筛选草稿、搜索输入草稿
- 排序变化、页大小变化、有效筛选/关键词变化、querySnapshot
- 迟到响应、owner live、requestGeneration
- 页码分页、游标分页、总数不可靠、精确总页数
- refreshing、stale、刷新失败、旧结果
- URL、浏览器返回、保存视图恢复
- 移动端、虚拟键盘、safe-area
- 未验证

## 未验证

真实浏览器、移动端、触摸、虚拟键盘、屏幕阅读器、权限切换、网络迟到和数据版本变化尚未执行；这些必须在业务项目接入时继续标为未验证。
