# 排序与重排 RED 复核

## 失败样例

一个管理列表在每行直接展示“排序”数字输入框和“保存”按钮，或只提供拖拽排序：

- 没有 `orderingReorderingState`。
- 没有 `orderingOwnerId`、`orderingSurface`、`scopeBinding`、`sourceSnapshot`、`itemIdentityMap`、`draftOrder`、`committedOrderSnapshot`、`movementPolicy`、`inputAlternativePolicy`、`submitPolicy`、`conflictPolicy`、`permissionBoundary`、`feedbackBinding`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification`。
- 列表、表格或卡片中常驻排序输入、每行保存按钮或 spreadsheet-like 排序矩阵。
- 拖拽是唯一排序方式，没有上移/下移、置顶/置底、键盘或按钮替代路径。
- 只调整当前页顺序，却把结果写成全量排序已生效。
- 筛选、搜索、分页、权限或数据版本变化后仍提交旧排序草稿。

## 预期审计结果

删除任一核心字段、删除禁止项、缺少 SKILL 路由、缺少 README/HANDOFF 引用、缺少相邻 owner 引用或把真实拖拽/键盘/触摸检查写成已验证，都必须失败。

真实浏览器、键盘、读屏、触摸、拖拽、权限变化、断点转换、移动端视口和真实数据竞态未实际执行，因此本 RED 证据标为未验证。
