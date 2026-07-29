# 详情预览面板规范 GREEN 摘要

## 覆盖范围

本轮新增 `references/preview-pane.md`，覆盖详情预览、侧边预览、预览面板、列表预览、行预览、记录预览、快速查看、只读预览、主从预览、Master Detail 和 Master-Detail。

## `previewPaneState`

GREEN 证据要求 owner 明确包含：

- `previewOwnerId`
- `surfaceKind`
- `sourceBinding`
- `activePreviewTarget`
- `pendingPreviewIntent`
- `previewSnapshot`
- `requestBinding`
- `permissionBoundary`
- `displayBinding`
- `actionBoundary`
- `urlHistoryBinding`
- `focusReturnPolicy`
- `responsivePolicy`
- `runtimeVerification`

## 关键不变量

- 预览目标不等于表格选择、不等于 hover、不等于 focus、不等于 active row，也不等于编辑目标。
- 预览面板不得渲染 input、textarea、select、combobox、日期选择器、单元格编辑、行内保存按钮或任何完整字段编辑表单。
- 编辑入口只能转交记录编辑承载面，并创建独立 `editSurfaceState`。
- 迟到预览响应只有同时匹配 `previewOwnerId`、owner live、请求代次、预览目标、租户/工作区和权限版本时才可提交。
- 无权限、权限降级、租户切换、记录删除或来源范围失效时，不得泄露对象名称、字段、数量、文件名、内部 ID、旧标题、旧错误或旧复制内容。
- 关闭预览不等于清空表格选择、不等于取消服务端任务、不等于提交表单、不等于路由返回。
- 移动端可以把桌面侧边预览转换为底部 Drawer、全屏 Drawer 或独立详情页。
- 移动端不得删除返回列表、当前预览目标、安全标题、权限原因、错误状态、主要只读信息和恢复入口。

## 相邻 owner

已在以下文件补充 `references/preview-pane.md` 和 `preview-pane.md` 关系：

- `references/data-tables.md`
- `references/information-display.md`
- `references/record-editing-surfaces.md`
- `references/drawers.md`
- `references/navigation-routing.md`
- `references/permissions-tenancy-visibility.md`
- `references/feedback-states.md`
- `references/responsive-adaptive.md`

## 路由与交接

- `SKILL.md` 已加入详情预览、侧边预览、预览面板、列表预览、行预览、记录预览、快速查看、只读预览、主从预览、preview pane、detail preview、side preview、row preview、record preview、quick view、master detail 和 master-detail 路由。
- `README.md` 已加入详情预览面板规范摘要和 `references/preview-pane.md`。
- `HANDOFF.md` 已加入“详情预览面板”阶段性交接。

## 验证边界

本轮为静态文档规范和 Ruby 审计。真实浏览器、键盘、读屏、触摸、断点转换、权限切换、真实请求竞态和真实组件运行时均为未验证；应用到具体业务项目前必须补充运行时验证。
