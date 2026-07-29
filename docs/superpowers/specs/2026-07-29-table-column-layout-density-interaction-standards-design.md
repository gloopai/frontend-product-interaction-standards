# 表格列设置、列布局与密度交互规范设计

## 背景

管理台中表格列设置很高频，但目前规则分散在 `data-tables.md`、`saved-views-layout-presets.md` 和 `page-toolbars-actions.md`。这导致实际项目容易把列数组直接存到本地缓存，或者把列草稿、已应用布局、保存视图混在一起；权限降级后旧列名和旧单元格内容也容易泄露。

## 推荐方案

新增 `references/table-column-layout-density.md` 作为独立 owner。它只负责列布局和密度本身：列显隐、顺序、宽度、固定、密度、重置、持久化边界、权限无泄露和移动端承载。

边界保持清晰：

- `data-tables.md` 继续负责表格能力、结果、选择、分页、排序和批量。
- `saved-views-layout-presets.md` 继续负责视图身份、保存、共享和默认。
- `page-toolbars-actions.md` 继续负责列设置入口和工具栏收纳。
- 新 owner 提供可应用、可持久化、可验证的 `tableColumnLayoutState`。

## 核心要求

- 每个支持列设置、列宽、固定列或密度切换的表格声明 `tableColumnLayoutState`。
- `draftLayout`、`appliedLayout` 和 `persistedLayout` 必须分离。
- 列顺序、宽度、固定和权限基于稳定列 ID，不基于数组下标、可见 index 或 DOM 顺序。
- 用户隐藏列、权限隐藏列和必显列语义必须区分。
- 无权限列不得出现在列设置、列数量、已隐藏列表、保存视图、导出字段、ARIA、Tooltip、旧布局、URL 或缓存。
- 列宽有最小/最大边界，固定列不能遮挡内容、浮层、焦点环或安全区域。
- 密度切换不能删除状态、错误、单位、禁用原因、行操作、选择摘要或恢复入口。
- 重置草稿、恢复个人默认、恢复团队默认、恢复系统默认和清空本地布局不得混用。
- 保存列布局到视图时读取已应用布局，未应用草稿不得静默保存。

## 测试策略

新增 `docs/testing/table-column-layout-density/table-column-layout-density-audit.rb`：

- 检查 owner 文档包含状态字段、硬性术语和完成前检查。
- 检查 `SKILL.md`、`README.md`、`HANDOFF.md` 接入。
- 检查相邻 owner 引用本 owner 和 `tableColumnLayoutState`。
- 使用 mutation 模式确认删除核心约束会失败。
- 对新增文档执行项目泄漏扫描。

