# 表格列布局密度规范 GREEN 复核

新增 `references/table-column-layout-density.md` 后，表格列设置、列布局与密度具备独立 owner：

- `tableColumnLayoutState` 要求声明 `columnLayoutOwnerId`、`tableBinding`、`columnRegistry`、`draftLayout`、`appliedLayout`、`persistedLayout`、`densityPolicy`、`widthPolicy`、`pinningPolicy`、`orderingPolicy`、`resetPolicy`、`persistencePolicy`、`permissionBoundary`、`feedbackBinding`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification`。
- 明确禁止只用列数组、localStorage、CSS class、组件库默认 column picker、隐藏 DOM、媒体查询或保存视图名称替代 owner。
- `draftLayout`、`appliedLayout` 和 `persistedLayout` 分离，取消草稿不改变表格、URL、保存视图、导出范围或选择范围。
- 列顺序、宽度、固定和权限基于稳定列 ID，不基于数组下标、可见 index 或 DOM 顺序。
- 用户隐藏列、权限隐藏列和必显列语义区分。
- 无权限列不得出现在列设置、列数量、已隐藏列表、保存视图、导出字段、ARIA、Tooltip、旧布局、URL 或缓存。
- 列宽有最小/最大边界，固定列不得遮挡内容、浮层、焦点环或安全区域。
- 紧凑模式不得删除状态、错误、单位、禁用原因、行操作、选择摘要或恢复入口。
- 保存列布局到视图时读取已应用布局，未应用草稿不得静默保存。
- 真实浏览器、键盘、读屏、触摸、拖拽、横向滚动、固定列、缩放、移动端、权限切换和视图恢复未执行时必须标为未验证。

