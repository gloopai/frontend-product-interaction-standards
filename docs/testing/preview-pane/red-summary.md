# 详情预览面板规范 RED 摘要

## 目标

新增 `previewPaneState` 的静态审计，确保详情预览、侧边预览、行预览、记录预览、主从预览和快速查看有独立 owner，不会被列表选择、hover/focus、详情展示或记录编辑承载面吞并。

## RED 期望

在 owner 文档、路由和 GREEN 证据尚未补齐时，审计应失败并定位以下缺口：

- `previewPaneState` 与 `previewOwnerId`、`surfaceKind`、`sourceBinding`、`activePreviewTarget`、`pendingPreviewIntent`、`previewSnapshot`、`requestBinding`、`permissionBoundary`、`displayBinding`、`actionBoundary`、`urlHistoryBinding`、`focusReturnPolicy`、`responsivePolicy`、`runtimeVerification` 字段缺失。
- 预览目标不等于表格选择、不等于 hover、不等于 focus、不等于 active row，也不等于编辑目标。
- 预览面板不得渲染 input、textarea、select、combobox、日期选择器、单元格编辑、行内保存按钮或任何完整字段编辑表单。
- 编辑入口只能转交记录编辑承载面。
- 迟到预览响应只有同时匹配 `previewOwnerId`、owner live、请求代次、预览目标、租户/工作区和权限版本时才可提交。
- 无权限、权限降级、租户切换、记录删除或来源范围失效时，不得泄露对象名称、字段、数量、文件名、内部 ID、旧标题、旧错误或旧复制内容。
- 关闭预览不等于清空表格选择、不等于取消服务端任务、不等于提交表单、不等于路由返回。
- 移动端可以把桌面侧边预览转换为底部 Drawer、全屏 Drawer 或独立详情页，并且不得删除返回列表、当前预览目标、安全标题、权限原因、错误状态、主要只读信息和恢复入口。
- 相邻 owner 必须链接到 `references/preview-pane.md` 和 `preview-pane.md`。
- README、HANDOFF 和 SKILL 路由必须包含详情预览面板规范。

## mutation 覆盖

`ruby docs/testing/preview-pane/preview-pane-audit.rb --mutations` 会删除或篡改上述关键句，预期全部出现 `EXPECTED_FAIL`。这保护 preview owner、禁止编辑、迟到响应、权限无泄露、移动端转换、路由和相邻 owner 链接。

## 运行时验证边界

本 RED 仅做静态文档审计。真实浏览器、键盘、读屏、触摸、断点转换、权限切换、真实请求竞态和真实组件运行时均为未验证，应用该规范到具体项目前必须另行执行。
