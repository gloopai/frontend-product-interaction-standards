# 页面内容区与 Section 布局 GREEN 复核

## 已补齐

- 新增 `references/page-content-layout-sections.md`，声明 `pageContentLayoutState`。
- `pageContentLayoutState` 覆盖 `contentOwnerId`、`contentSurface`、`pageBinding`、`sectionRegistry`、`layoutGridPolicy`、`scrollBoundary`、`stickyBoundary`、`densityPolicy`、`contentPriority`、`emptyLoadingErrorBinding`、`ownerHandoff`、`permissionBoundary`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification`。
- 明确“页面内容区不是随意堆卡片，也不是 CSS 网格细节”。
- 明确“页面正文必须绑定当前页面 owner、标题区、工具栏、权限版本和主内容区域”。
- 明确“每个 Section、Card、分栏、列表区、表单区、图表区和信息区必须有明确 ownerHandoff”。
- 明确“主滚动只能有一个可解释 owner；不得让页面、卡片、表格、Drawer 和 Dialog 形成无声明的嵌套滚动”。
- 明确 sticky/fixed、底部操作、分页、工具栏、标题区和安全区域不得遮挡焦点、错误、状态摘要、主操作或恢复路径。
- 明确移动端可以重排、折叠、分组或转单列，但不得删除页面标题、核心 Section、状态说明、权限原因、主操作、错误恢复和返回路径。

## 验证边界

已通过结构化审计设计覆盖 owner 文档、SKILL 路由、README、HANDOFF、相邻 owner 引用、RED/GREEN 证据和项目泄漏扫描。

真实浏览器、键盘、读屏、触摸、权限变化、断点切换、移动端视口、主滚动、嵌套滚动和 sticky/fixed 避让未在本仓库执行，因此运行时检查仍标为未验证。
