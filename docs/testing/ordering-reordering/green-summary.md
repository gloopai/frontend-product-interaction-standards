# 排序与重排 GREEN 复核

## 已补齐

- 新增 `references/ordering-reordering.md`，声明 `orderingReorderingState`。
- `orderingReorderingState` 覆盖 `orderingOwnerId`、`orderingSurface`、`scopeBinding`、`sourceSnapshot`、`itemIdentityMap`、`draftOrder`、`committedOrderSnapshot`、`movementPolicy`、`inputAlternativePolicy`、`submitPolicy`、`conflictPolicy`、`permissionBoundary`、`feedbackBinding`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification`。
- 明确“列表、表格或卡片中不得常驻排序输入、每行保存按钮或 spreadsheet-like 排序矩阵”。
- 明确“拖拽不能是唯一排序方式”。
- 明确“当前页局部重排不得伪装成全部结果、全部分组或全局顺序已更新”。
- 明确保存前必须证明 `draftOrder` 没有重复、缺失、外部 ID 或无权限对象。
- 明确筛选、搜索、分页、分组、权限、租户/工作区、数据版本或对象集合变化后，旧排序草稿必须失效、刷新或要求重新确认。

## 验证边界

已通过结构化审计设计覆盖 owner 文档、SKILL 路由、README、HANDOFF、相邻 owner 引用、RED/GREEN 证据和项目泄漏扫描。

真实浏览器、键盘、读屏、触摸、拖拽、权限变化、断点转换、移动端视口和真实数据竞态未在本仓库执行，因此运行时检查仍标为未验证。
