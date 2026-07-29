# 页面内容区与 Section 布局 RED 复核

## 失败样例

一个页面只用几个卡片容器和 CSS 栅格把内容堆起来：

- 没有 `pageContentLayoutState`。
- 没有 `contentOwnerId`、`contentSurface`、`pageBinding`、`sectionRegistry`、`layoutGridPolicy`、`scrollBoundary`、`stickyBoundary`、`densityPolicy`、`contentPriority`、`emptyLoadingErrorBinding`、`ownerHandoff`、`permissionBoundary`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification`。
- 页面正文没有绑定当前页面 owner、标题区、工具栏、权限版本和主内容区域。
- Section、Card、分栏、列表区、表单区、图表区和信息区没有明确 `ownerHandoff`。
- 主滚动不唯一，页面、卡片、表格、Drawer 和 Dialog 存在无声明的嵌套滚动。
- sticky/fixed 工具栏、分页或底部操作可能遮挡焦点、错误、状态摘要、主操作或恢复路径。
- 移动端直接隐藏低频 Section、权限原因或错误恢复。

## 预期审计结果

删除任一核心字段、删除 owner 硬规则、缺少 SKILL 路由、缺少 README/HANDOFF 引用、缺少相邻 owner 引用或把真实视口检查写成已验证，都必须失败。

真实浏览器、键盘、读屏、触摸、权限变化、断点切换、移动端视口、主滚动和 sticky/fixed 避让未实际执行，因此本 RED 证据标为未验证。
