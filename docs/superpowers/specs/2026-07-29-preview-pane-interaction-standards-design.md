# 详情预览面板交互规范设计

## 背景

管理台列表经常需要在不离开结果上下文的情况下查看一条记录的摘要、状态、审计线索或关键字段。常见做法是点击行后在右侧出现详情预览、在主从布局中展示只读详情，或在移动端转换成底部/全屏预览层。

这类能力容易和三个 owner 混在一起：表格行选择、详情页信息展示、记录编辑承载面。一旦边界不清，预览面板会变成半个编辑表单、迟到响应会写到新记录、无权限用户会看到旧标题或旧字段，移动端还可能直接删掉返回列表和权限说明。

## 推荐方案

新增独立 owner：`previewPaneState`。它只负责列表、表格、卡片列表、搜索结果和报表明细中的只读详情预览、侧边预览面板、主从预览和快速查看。

预览面板不承载新增、编辑、删除确认或危险操作。凡是修改业务字段、产生 dirty 状态、需要保存或提交的流程，都必须进入 `record-editing-surfaces.md` 规定的 Dialog、Drawer 或独立页。文件、图片、音视频等媒体渲染继续归 `files-media-assets.md`，本 owner 只定义从列表进入预览和预览状态边界。

## 状态模型

`previewPaneState` 至少包含：

- `previewOwnerId`：当前预览实例的稳定 owner。
- `surfaceKind`：`side-pane`、`split-pane`、`bottom-sheet`、`full-screen-preview` 或 `inline-region`。
- `sourceBinding`：来源列表、表格、卡片列表、搜索结果、筛选、排序、分页、滚动和触发焦点快照。
- `activePreviewTarget`：当前已提交预览目标，包含稳定记录 ID、对象类型、租户/工作区、权限版本和安全可见名称。
- `pendingPreviewIntent`：等待提交或请求中的预览意图；hover、focus、active row 和表格选择不能直接成为它。
- `previewSnapshot`：预览字段、摘要、状态、审计线索、数据版本、刷新时间和 stale 标记。
- `requestBinding`：请求代次、快照 ID、权限版本、owner live 状态和迟到响应丢弃策略。
- `permissionBoundary`：字段、标题、数量、文件名、内部 ID、旧缓存和错误明细的无泄露规则。
- `displayBinding`：只读字段、空值、长文本、复制、状态标签和来源说明的展示规则。
- `actionBoundary`：打开详情、复制、刷新、导出、编辑入口和危险操作入口的对象快照与转交 owner。
- `urlHistoryBinding`：是否同步 URL、恢复策略、敏感参数禁止项和浏览器返回行为。
- `focusReturnPolicy`：打开、切换记录、关闭、返回列表和权限收敛时的焦点策略。
- `responsivePolicy`：桌面侧边预览、分栏预览、移动端底部/全屏预览的转换条件和能力保留。
- `runtimeVerification`：浏览器、键盘、读屏、触摸、断点、真实数据竞态和权限切换验证状态；未执行时必须标为未验证。

## 硬性规则

1. 预览目标不等于表格选择、不等于 hover、不等于 focus、不等于 active row，也不等于编辑目标。
2. 预览面板不得渲染 input、textarea、select、combobox、日期选择器、单元格编辑、行内保存按钮或任何完整字段编辑表单。
3. 预览面板可以放“编辑”“打开详情”“复制”“刷新”等入口，但入口必须绑定当前 `previewSnapshot` 和权限版本；编辑入口只能转交记录编辑承载面。
4. 迟到预览响应只有同时匹配 `previewOwnerId`、owner live、请求代次、预览目标、租户/工作区和权限版本时才可提交；否则只记录 discarded，不得写 DOM、状态、焦点或公告。
5. 无权限、权限降级、租户切换、记录删除或来源范围失效时，不得泄露对象名称、字段、数量、文件名、内部 ID、旧标题、旧错误或旧复制内容。
6. 关闭预览不等于清空表格选择、不等于取消服务端任务、不等于提交表单、不等于路由返回；这些意图必须分别归属对应 owner。
7. 移动端可以把桌面侧边预览转换为底部 Drawer、全屏 Drawer 或独立详情页，但不得删除返回列表、当前预览目标、安全标题、权限原因、错误状态、主要只读信息和恢复入口。
8. 浏览器返回、URL 恢复、从详情返回列表和关闭预览必须经过 `navigation-routing.md` 的来源恢复与权限复核。
9. 预览区域的 loading、empty、refresh-error、stale、permission-denied 和 partial 状态必须由 feedback owner 承载，不能只用 Toast。
10. 未实际执行真实浏览器、键盘、触摸、读屏、断点、权限切换和真实请求竞态检查时，必须标为未验证。

## 相邻 owner

- 来源列表、分页、排序、选择和结果摘要读取 `data-tables.md` 与 `list-result-controls.md`。
- 只读字段、状态、复制和长文本读取 `information-display.md` 与 `copy-clipboard.md`。
- 新增、编辑、复制创建、批量配置读取 `record-editing-surfaces.md`。
- 预览层若采用模态 Drawer/Bottom Sheet，读取 `drawers.md`；若进入独立页，读取 `navigation-routing.md`。
- 权限、租户、旧缓存和无泄露读取 `permissions-tenancy-visibility.md`。
- loading、empty、error、stale 和恢复入口读取 `feedback-states.md`。
- 移动端、虚拟键盘、低高度、安全区域和断点转换读取 `responsive-adaptive.md`。
- 文件、图片、音视频、文档在线预览的媒体渲染读取 `files-media-assets.md`。

## 验收边界

首版验收采用静态文档审计和 mutation 测试，确保 owner 状态、禁止编辑、迟到响应、权限无泄露、移动端转换、路由恢复、相邻 owner 链接、README/HANDOFF 路由和运行时未验证声明全部存在。

运行时检查不在本轮执行。任何未来把该规范应用到业务项目的输出，都必须把未执行的浏览器、键盘、读屏、触摸、断点和真实请求竞态检查明确标为未验证。
