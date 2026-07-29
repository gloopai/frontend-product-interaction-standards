# 页面操作栏与列表工具栏交互规范

适用于 page toolbar、action bar、list toolbar、result toolbar、bulk toolbar、view tools、refresh action、create action、column settings、density、view switcher、页面操作栏、列表工具栏、结果工具栏、批量操作栏、视图工具、刷新操作、新增操作、列设置、密度和视图切换。本文件是页面标题操作区、结果工具栏、批量条、视图工具、更多菜单收纳、移动端操作承载和权限收敛的唯一事实来源。

按钮本体继续执行 [按钮交互规范](buttons.md)。Page Header、页面标题区、标题区主操作、标题区次要操作、标题区权限说明和移动端标题区必须同时执行 `references/page-header-title-area.md`；本文件负责工具栏能力编排、结果绑定和移动端收纳，`page-header-title-area.md` 负责标题区页面身份、标题快照、操作槽归属和标题区权限收敛。页面工具栏所在内容区、Section 工具栏、固定工具栏、主滚动和移动端收纳必须同时执行 `references/page-content-layout-sections.md`；本文件负责操作编排，`page-content-layout-sections.md` 负责内容区位置、Section 注册、滚动边界和 Sticky/fixed 避让。表格能力档位、选择快照、批量操作结果继续执行 [数据表格交互规范](data-tables.md)。筛选草稿、已应用条件、URL 恢复继续执行 [查询条件与筛选交互规范](query-filters.md)。刷新、导出、视图工具、结果范围和结果摘要必须读取 `references/list-result-controls.md` 的当前范围、`querySnapshot` 和结果控制状态，不得读取筛选草稿、搜索输入草稿或旧结果。导出、下载和结果产物继续执行 [导出、下载与结果产物交付交互规范](exports-downloads-artifacts.md)。权限、租户/工作区、能力开关和无泄露继续执行 [权限、租户与可见性交互规范](permissions-tenancy-visibility.md)。移动端收纳和断点切换继续执行 [响应式与自适应交互规范](responsive-adaptive.md)。更多菜单、Action Sheet、Popover 和 Tooltip 继续执行 [浮层菜单与提示交互规范](overlays-menus-tooltips.md)。风险操作继续执行 [危险操作与恢复交互规范](risk-actions.md)。

Tab 上方或 TabPanel 内工具栏必须同时执行 `references/tab-view-navigation.md`；工具栏只读取当前 `activeTabId`、已提交 panel 状态和合法范围，不得从隐藏 tab、旧 panel、未确认 pendingTabIntent 或无权限 panel 推导操作。

## 范围与非目标

本 owner 覆盖页面标题右侧操作区、列表工具栏、结果工具栏、批量操作栏、视图工具栏、移动端更多操作、Action Sheet、工具栏 Drawer 和结果区恢复入口；覆盖新增、导入、刷新、导出、下载、列显示、列固定、密度、视图切换、批量操作入口、更多操作、权限说明和错误恢复的编排关系。

本 owner 不覆盖单个按钮文案、loading、防重复、危险分级、图标按钮语义、表格行列分页、选择快照、批量终态、筛选字段、字段校验、Select popup、表单提交、具体 CSS、组件库、图标库、像素级间距或后端接口。

## `toolbarState`

每个页面操作栏、列表工具栏、结果工具栏或批量操作栏必须声明 `toolbarState`：

| 字段 | 语义 |
| --- | --- |
| `toolbarOwnerId` | 当前工具栏稳定 owner 身份，与页面、结果或批量条实例绑定。 |
| `surface` | `page-header`、`filter-adjacent`、`result-toolbar`、`bulk-toolbar`、`view-toolbar`、`mobile-action-sheet`、`mobile-drawer`。 |
| `primaryActionPolicy` | 页面主操作来源、唯一性、权限、禁用原因和移动端保留策略。 |
| `secondaryActionPolicy` | 次要操作分组、排序、更多菜单收纳、可发现性和禁用原因。 |
| `resultBinding` | 当前结果 owner、已应用筛选、排序、分页、数据版本、刷新意图和结果状态。 |
| `selectionBinding` | 批量条是否存在、选择快照、选择数量、资格状态、失效原因和恢复路径。 |
| `viewToolsPolicy` | 列设置、密度、视图切换、刷新、展开/收起或布局工具的启用条件和作用范围。 |
| `permissionBoundary` | 权限、租户/工作区、能力开关、对象状态、权限版本和旧入口清理策略。 |
| `feedbackOwner` | 工具栏状态变化、刷新、权限降级、批量条变化和操作结果的唯一公告 owner。 |
| `responsivePolicy` | 移动端保留、收纳、Action Sheet、Drawer、独立页和焦点返回策略。 |

工具栏不得读取筛选草稿、旧结果、旧权限或 Select query。刷新、导出、列设置、密度、视图切换、更多菜单和批量条只能读取 `resultBinding`、`selectionBinding` 或对应专项 owner 已提交的状态。

## 主操作与次要操作

页面主操作只能有一个 primary owner。新增、创建、导入、配置、发布等主任务必须在页面标题区或稳定主操作区可发现，不得被埋进无标签更多菜单作为唯一入口。确有多个候选主操作时，产品必须按当前任务声明唯一 primary，其余降级为 secondary 或分组入口。

同一操作不得同时以主按钮、工具栏按钮、更多菜单项、快捷键和浮动按钮多处独立提交；多入口可以存在，但必须共享同一操作 owner、同一权限判断、同一禁用原因、同一请求身份和同一反馈 owner。

次要操作按任务分组：结果操作、视图工具、导入导出、批量操作、危险操作和帮助信息不得混成一串图标。仅图标按钮必须有可访问名称；禁用原因不得只放在 Tooltip；危险操作不得只靠颜色、位置或更多菜单分组表达风险。

## 结果绑定、刷新和导出

结果工具栏只服务一个当前结果 owner。刷新、导出、列设置、密度和视图切换必须说明作用范围：当前已应用筛选、当前页、全部筛选结果、当前视图、报表快照或选择范围。范围不明确时不得启用操作。

刷新操作读取当前 `resultBinding` 的已应用筛选、排序、分页、数据版本、权限版本和刷新原因；不得读取筛选草稿、旧结果、旧权限或 Select query。刷新开始、成功、失败和 stale 状态由结果 owner 或 `feedbackOwner` 唯一公告，不能再由 Toast、结果摘要和全局 live region 重复朗读同一完整消息。

导出、下载、复制链接和结果产物入口必须读取导出 owner 的范围快照与权限复核；工具栏只负责入口编排。导出创建、生成、领取、下载、过期和失败不得被工具栏合并成含糊的“已处理”。

## 批量操作栏

批量操作栏只有在 Data Table 的 `resolvedTier=bulk-action` 且存在有效选择时才出现。只读报表、row-action 列表、无选择状态或选择失效时不得渲染空批量条、隐藏批量状态、不可见选择状态或只有 disabled 按钮的占位条。

批量条必须显示当前选择模式、已选数量、范围、排除项、不可操作项或失效原因；全部筛选结果模式必须显示范围摘要。批量条中的操作只能读取 `selectionBinding` 的合法选择快照，不得从当前可见行、分页缓存、旧选择或结果摘要推导范围。

选择失效、权限降级、结果 owner 变化、筛选应用、排序变化、数据版本冲突或批量操作完成后，批量条必须按 Data Table owner 的选择规则清理或进入待重新确认态。不得只隐藏复选框而保留旧批量按钮，也不得自动提交新范围。

## 视图工具与个性化入口

列设置、列固定、密度、视图切换、卡片/表格切换、展开/收起和布局工具属于 `viewToolsPolicy`。它们只能改变展示形态，不得隐式改变已应用筛选、排序、权限、导出范围、选择快照或业务提交结果。

工具栏启用卡片列表、卡片式结果、资源卡片、模板卡片、应用卡片、项目卡片、卡片网格、移动端结果卡片或 Kanban-lite 视图时，必须同时执行 `references/card-list-results.md`；工具栏只提交视图意图和结果绑定，卡片 owner 负责 `card-list-results.md` 的字段映射、交互区域、能力档位、选择/操作边界和响应式保留。

视图工具的可用性必须来自产品声明和权限/能力开关。未启用时 DOM、state、handler 和 request 入口均为 0；不得渲染禁用但无原因的幽灵按钮。持久化个人设置前必须说明作用范围，例如当前用户、当前工作区、当前表格或当前报表。

## 更多菜单、Tooltip、Toast 和恢复路径

更多菜单只用于低频操作或空间不足收纳，必须有可访问名称、分组标题和稳定排序。更多菜单、Tooltip、Toast 或浏览器提示不得作为唯一错误恢复、权限原因、主操作入口或导出回执。

如果某个操作被收纳，原位置必须保留可发现入口，例如“更多操作”。收纳后仍执行同一按钮、菜单、风险、导出或权限 owner；不得因为进入更多菜单就省略二次确认、禁用原因、审计回执、下载复核、错误恢复或焦点返回。

## 权限、租户和能力收敛

权限、租户/工作区、能力开关或结果 owner 变化后，工具栏必须原子重算可见操作、禁用原因、批量条、导出入口和视图工具。无法同步证明仍安全的旧入口先移除或替换安全说明；不得保留旧按钮、旧菜单项、旧快捷键、旧可访问名称、旧导出入口、旧批量条或旧视图工具。

无权限、只读、禁用和未启用必须区分：无权限可提供申请权限或切换工作区；只读可展示但不可改；禁用需说明当前对象状态或前置条件；未启用表示该能力不存在，四类入口为 0。

## 移动端与响应式收纳

移动端不得删除新增、刷新、错误恢复、已选摘要、批量入口、导出恢复或主要视图工具。低频操作可以进入更多菜单、Action Sheet、Drawer 或独立页，但必须保留可访问名称、分组标题、禁用原因、当前范围、焦点返回和恢复路径。

移动端工具栏不得把所有操作压成一排不可读图标。常见策略是：保留一个主操作、一个结果恢复/刷新入口、一个可发现的更多操作入口；批量选择时以批量条或底部操作区展示已选摘要和主批量操作；复杂列设置、导出字段或视图配置进入 Drawer 或独立页。

断点切换时保持同一个 `toolbarOwnerId`、`resultBinding`、`selectionBinding`、`viewToolsPolicy` 和在途操作身份。精确焦点节点仍存在时保留焦点；否则只迁移一次到语义等价入口。不得因从桌面工具栏转移动端更多菜单而重复请求、重复公告、重置选择、清空错误或改变导出范围。

## 可访问性、反馈和生命周期

工具栏区域必须有可感知名称，并说明它控制哪个页面、结果区或选择范围。键盘顺序按任务流排列：页面主操作、筛选/结果摘要、结果工具、批量条、表格或结果内容、分页和恢复入口。收纳菜单打开、关闭和断点转换后的焦点返回必须可预测。

工具栏状态变化、批量条出现/消失、刷新开始/失败、权限降级和操作结果不能重复公告；每类消息必须归唯一 `feedbackOwner`。Toast 可以辅助，但不能替代页面内状态、错误恢复、权限原因或导出回执。

路由变化或拥有页面卸载时，工具栏立即进入 disposal：取消或失效刷新、防抖、菜单定位、快捷键、权限订阅、视图持久化请求和旧回调。旧回调不得重新显示旧操作、旧菜单、旧批量条、旧导出入口或旧焦点目标。

## 完成前检查

- 验证每个页面操作栏、列表工具栏、结果工具栏或批量操作栏声明 `toolbarState`、`toolbarOwnerId`、`primaryActionPolicy`、`secondaryActionPolicy`、`resultBinding`、`selectionBinding`、`viewToolsPolicy`、`permissionBoundary` 和 `responsivePolicy`。
- 验证页面主操作只能有一个 primary owner，新增/创建/导入等主入口不得被埋进无标签更多菜单作为唯一入口。
- 验证工具栏不得读取筛选草稿、旧结果、旧权限或 Select query；刷新、导出、列设置和视图切换读取当前已提交范围。
- 验证批量操作栏只有在 Data Table 的 `resolvedTier=bulk-action` 且存在有效选择时才出现；只读报表、row-action 列表、无选择状态或选择失效时不得渲染空批量条。
- 验证更多菜单、Tooltip、Toast 或浏览器提示不得作为唯一错误恢复、权限原因、主操作入口或导出回执。
- 验证权限、租户/工作区、能力开关或结果 owner 变化后，工具栏必须原子重算可见操作、禁用原因、批量条、导出入口和视图工具，并清理旧可访问名称、快捷键和回调。
- 验证移动端不得删除新增、刷新、错误恢复、已选摘要、批量入口、导出恢复或主要视图工具；收纳入口有名称、分组、范围、禁用原因和焦点返回。
- 真实浏览器、键盘、屏幕阅读器、触摸、权限切换、断点切换、移动端视口和真实组件未实际执行时，必须明确标为未验证，并列出所需验证。

## 参考资料

- [WAI-ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [WCAG: Keyboard](https://www.w3.org/WAI/WCAG22/Understanding/keyboard.html)
- [WCAG: Focus Order](https://www.w3.org/WAI/WCAG22/Understanding/focus-order.html)
- [WCAG: Status Messages](https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html)
