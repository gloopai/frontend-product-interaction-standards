# 卡片列表与卡片式结果交互规范设计

## 背景

后台和管理台不只有表格。资源库、模板库、项目列表、应用市场、配置项列表、移动端结果页和 Kanban-lite 场景经常使用卡片列表。现有 `data-tables.md` 已覆盖“表格转换为卡片”的等价规则，但还缺少一个独立 owner 处理“本来就是卡片式结果”的结构和交互边界。

卡片列表常见问题很集中：整张卡片被做成大链接导致内部按钮冲突；字段只靠图标或位置表达；操作藏到 hover；移动端删掉次要但仍必要的字段；选择 checkbox 和打开详情互相抢点击；卡片内嵌编辑字段；迟到刷新把旧状态写回新卡片；无权限状态保留旧封面、旧标题或旧计数。

## 推荐方案

新增独立 owner：`cardListResultState`。它覆盖卡片列表、资源卡片、模板卡片、应用卡片、内容卡片、项目卡片、卡片式结果、卡片网格、移动端结果卡片和 Kanban-lite 列表。

它不替代表格 owner：如果一个结果本质是数据表格，只是在窄屏转换成卡片，仍以 `data-tables.md` 为主，卡片列表 owner 只作为结构补充。如果产品一开始就选择卡片作为主要结果形态，则必须声明 `cardListResultState`。

## 状态模型

`cardListResultState` 至少包含：

- `cardListOwnerId`：当前卡片列表实例 owner。
- `surfaceKind`：`grid`、`list`、`masonry-forbidden`、`kanban-lite`、`mobile-card-list` 或产品声明的卡片形态。
- `capabilityTier`：`display`、`item-action` 或 `selection-action`。
- `sourceBinding`：已应用查询、排序、分页/游标、结果版本、权限范围和来源 owner。
- `cardIdentityMap`：每张卡片的稳定记录 ID、对象类型、安全可见名称、租户/工作区、权限版本。
- `fieldMapping`：卡片标题、副标题、主状态、关键指标、缩略图、元数据、次要字段、可展开字段和不可隐藏字段。
- `interactionZones`：打开详情区、选择区、操作区、复制区、菜单区、预览入口和拖拽/排序禁用边界。
- `selectionBinding`：卡片选择、全选、批量范围、不可选原因、排除项和选择代次。
- `actionBinding`：单卡片操作、批量操作、危险操作、编辑入口、预览入口和结果 owner。
- `requestBinding`：结果请求代次、卡片数据快照、迟到响应和 stale/refresh 处理。
- `permissionBoundary`：标题、封面、缩略图、数量、标签、状态、字段、文件名、旧缓存和 ARIA label 无泄露。
- `feedbackBinding`：loading、empty、zero-results、refresh-error、stale、partial、permission-denied 和恢复入口。
- `responsivePolicy`：列数、最小宽度、断点、触摸目标、200% 缩放、虚拟键盘、安全区域和低高度策略。
- `focusKeyboardPolicy`：卡片整体、内部控件、菜单、选择、详情和断点转换的焦点策略。
- `runtimeVerification`：真实浏览器、键盘、读屏、触摸、断点和真实数据竞态验证状态；未执行必须标为未验证。

## 硬性规则

1. 卡片列表不是营销卡片墙。每张卡片必须有明确记录身份、字段 label/value 关系、状态文本、权限状态和可访问名称。
2. 整张卡片不得包成一个大链接再在内部塞按钮、菜单、checkbox 或复制控件；打开详情区、选择区和操作区必须是独立交互区域。
3. `display` 档位只展示、筛选、排序、分页和打开详情/预览；不得渲染选择列、批量工具栏或隐藏选择状态。
4. `item-action` 可以提供单卡片操作和详情/预览入口，但不得自动获得多选或批量能力。
5. 只有 `selection-action` 可以渲染选择与批量操作；选择状态必须读取稳定记录 ID，不得用当前数组索引或 DOM 顺序。
6. 卡片内不得承载新增、编辑、复制创建、单元格编辑、字段保存、行内保存或完整字段表单；编辑入口只能转交记录编辑承载面。
7. 重要字段、权限原因、错误状态、恢复入口和主要操作不得只靠 hover、右键、隐藏菜单、图标、颜色、封面图或截断文本表达。
8. 移动端、200% 缩放、低高度、长标题、翻译扩展和字体放大不得删除记录身份、主状态、错误/权限说明、选择摘要、主要操作、分页/刷新和恢复入口。
9. 刷新、自动刷新、翻页、排序、权限变化和来源范围变化必须建立结果快照和请求代次；迟到响应不得写回新卡片、新权限或已卸载列表。
10. 无权限或权限降级不得泄露旧标题、旧封面、旧缩略图、旧标签、旧状态、旧数量、旧文件名、旧菜单项、旧错误或旧 ARIA label。

## 相邻 owner

- 查询、排序、分页、刷新和结果摘要读取 `list-result-controls.md`。
- 表格转卡片等价、批量操作、表格语义读取 `data-tables.md`。
- 详情预览读取 `preview-pane.md`；完整详情和只读字段读取 `information-display.md`。
- 编辑入口读取 `record-editing-surfaces.md`。
- 按钮、菜单、危险操作、权限、反馈和响应式分别读取 `buttons.md`、`overlays-menus-tooltips.md`、`risk-actions.md`、`permissions-tenancy-visibility.md`、`feedback-states.md` 和 `responsive-adaptive.md`。

## 验收边界

首版验收使用 Ruby 静态审计和 mutation 测试，保证 owner 状态、卡片结构、交互区域、能力档位、选择边界、编辑禁止、权限无泄露、响应式保留、相邻 owner 链接、README/HANDOFF 和运行时未验证声明存在。

真实浏览器、键盘、读屏、触摸、断点、权限切换和真实数据竞态本轮不执行；应用到具体业务项目时必须逐项标为未验证或补充运行时证据。
