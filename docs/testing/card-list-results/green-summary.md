# 卡片列表与卡片式结果规范 GREEN 摘要

## 覆盖范围

本轮新增 `references/card-list-results.md`，覆盖卡片列表、卡片式结果、资源卡片、模板卡片、应用卡片、内容卡片、项目卡片、卡片网格、移动端结果卡片和 Kanban-lite。

## `cardListResultState`

GREEN 证据要求 owner 明确包含：

- `cardListOwnerId`
- `surfaceKind`
- `capabilityTier`
- `sourceBinding`
- `cardIdentityMap`
- `fieldMapping`
- `interactionZones`
- `selectionBinding`
- `actionBinding`
- `requestBinding`
- `permissionBoundary`
- `feedbackBinding`
- `responsivePolicy`
- `focusKeyboardPolicy`
- `runtimeVerification`

## 关键不变量

- 卡片列表不是营销卡片墙。
- 整张卡片不得包成一个大链接再在内部塞按钮、菜单、checkbox 或复制控件。
- 打开详情区、选择区和操作区必须是独立交互区域。
- `capabilityTier` 只能是 `display`、`item-action` 或 `selection-action`。
- 只有 `selection-action` 可以渲染选择与批量操作。
- 选择状态必须读取稳定记录 ID，不得用当前数组索引或 DOM 顺序。
- 卡片内不得承载新增、编辑、复制创建、单元格编辑、字段保存、行内保存或完整字段表单。
- 重要字段、权限原因、错误状态、恢复入口和主要操作不得只靠 hover、右键、隐藏菜单、图标、颜色、封面图或截断文本表达。
- 移动端、200% 缩放、低高度、长标题、翻译扩展和字体放大不得删除记录身份、主状态、错误/权限说明、选择摘要、主要操作、分页/刷新和恢复入口。
- 迟到响应不得写回新卡片、新权限或已卸载列表。
- 无权限或权限降级不得泄露旧标题、旧封面、旧缩略图、旧标签、旧状态、旧数量、旧文件名、旧菜单项、旧错误或旧 ARIA label。

## 相邻 owner

已在以下文件补充 `references/card-list-results.md` 和 `card-list-results.md` 关系：

- `references/data-tables.md`
- `references/list-result-controls.md`
- `references/page-toolbars-actions.md`
- `references/buttons.md`
- `references/overlays-menus-tooltips.md`
- `references/preview-pane.md`
- `references/record-editing-surfaces.md`
- `references/feedback-states.md`
- `references/responsive-adaptive.md`
- `references/permissions-tenancy-visibility.md`

## 路由与交接

- `SKILL.md` 已加入卡片列表、卡片式结果、资源卡片、模板卡片、应用卡片、内容卡片、项目卡片、卡片网格、移动端结果卡片、卡片操作区、卡片选择、card list、card results、result cards、resource cards、template cards、app cards、content cards、project cards、card grid、mobile cards 和 kanban-lite 路由。
- `README.md` 已加入卡片列表与卡片式结果规范摘要和 `references/card-list-results.md`。
- `HANDOFF.md` 已加入“卡片列表与卡片式结果”阶段性交接。

## 验证边界

本轮为静态文档规范和 Ruby 审计。真实浏览器、键盘、读屏、触摸、断点转换、权限切换、真实请求竞态和真实组件运行时均为未验证；应用到具体业务项目前必须补充运行时验证。
