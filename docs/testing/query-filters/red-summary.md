# 查询条件与筛选规范 RED 基线总结

没有 Query Filter owner 时，常见失败包括：

- `filterDraft` 和 `appliedFilters` 没有分离，用户编辑草稿时结果、URL、标题和数量已经变化。
- Select 的内部 query、active option 或 popup 草稿进入 `appliedFilters`。
- 条件没有声明 `applyMode`，默认输入即请求，导致重复请求和昂贵查询抖动。
- “重置”被写成清空所有条件，破坏 `defaultFilters`、强制条件和权限派生条件。
- 已应用条件隐藏在折叠区，没有摘要、chips 或数量提示。
- `sensitive` 条件、个人识别值或内部权限范围被写入 URL、标题、日志或 analytics。
- 浏览器返回/前进时只改 URL 不改结果，或静默忽略 URL 中的已知无效条件。
- 权限变化后继续显示旧筛选值、旧 option label、旧 URL 参数或旧 chips。
- 移动端不得删除核心筛选能力；常见坏例是移动端删除筛选、应用、重置/清空、已应用摘要、单项移除或错误恢复。

浏览器、屏幕阅读器、触摸设备和真实组件运行时未执行，保持未验证。
