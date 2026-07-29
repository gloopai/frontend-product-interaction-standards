# 页面操作栏与列表工具栏交互规范设计

## 背景

管理台页面里最常见的拥挤区域不是单个按钮，而是页面标题右侧、筛选区附近、结果摘要旁和表格上方的操作组合：新增、刷新、导出、批量操作、列设置、密度、视图切换、更多操作和权限降级提示常被堆在一起。现有 owner 已覆盖按钮本体、表格、筛选、导出、权限和响应式，但缺少一个“编排层”来约束这些入口如何共存。

本设计新增 `page-toolbars-actions` owner，作为页面级操作栏、列表工具栏和结果区操作编排的唯一事实来源。

## 目标

- 明确页面操作栏、结果工具栏、批量操作栏和视图工具的 owner 边界。
- 约束新增、刷新、导出、列设置、视图切换、更多操作和批量入口的分组、优先级、状态归属和权限收敛。
- 防止报表、只读列表或无批量能力页面误渲染空批量条、隐形选择状态、幽灵按钮或无权限旧入口。
- 定义移动端收纳策略：核心操作保持可达，低频操作可进入更多菜单、Action Sheet、Drawer 或独立页，但不能消失。
- 提供可执行审计，覆盖正向证据、负向突变和项目泄漏检查。

## 非目标

- 不重新定义单个按钮文案、loading、危险分级；这些继续归 `buttons.md` 和 `risk-actions.md`。
- 不重新定义表格能力档位、选择快照或批量终态；这些继续归 `data-tables.md`。
- 不重新定义筛选草稿/已应用、URL 恢复或字段校验；这些继续归 `query-filters.md` 与 `forms.md`。
- 不规定具体 CSS 框架、组件库、图标库或像素级样式。

## 方案

新增 `references/page-toolbars-actions.md`，并在 `SKILL.md` 增加路由关键词：page toolbar、action bar、list toolbar、result toolbar、bulk toolbar、view tools、refresh action、create action、column settings、density、视图切换、页面操作栏、列表工具栏、结果工具栏、批量操作栏等。

owner 定义 `toolbarState`：

- `toolbarOwnerId`：当前页面/结果工具栏稳定身份。
- `surface`：`page-header`、`filter-adjacent`、`result-toolbar`、`bulk-toolbar`、`view-toolbar`、`mobile-action-sheet`。
- `primaryActionPolicy`：主操作来源、唯一性、权限和禁用原因。
- `secondaryActionPolicy`：次要操作分组、更多菜单、排序和发现路径。
- `resultBinding`：绑定的查询结果 owner、已应用筛选、表格能力档位、数据版本和刷新意图。
- `selectionBinding`：批量条是否存在、选择快照、选择数量和资格状态。
- `viewToolsPolicy`：列显示、密度、视图切换、刷新和布局工具是否启用。
- `permissionBoundary`：权限、租户/工作区、能力开关和旧入口清理。
- `responsivePolicy`：移动端保留、收纳或升级承载策略。

## 核心规则

1. 页面主操作只能有一个 primary owner。新增、导入、创建配置等主操作必须在标题区或稳定主操作区可发现，不得被埋进无标签更多菜单作为唯一入口。
2. 列表结果工具栏只展示与当前结果 owner 绑定的操作。刷新、导出、列设置、密度和视图切换不得读取筛选草稿、旧结果或旧权限。
3. 批量操作栏只有在 Data Table 的 `resolvedTier=bulk-action` 且存在有效选择时才出现。只读报表、row-action 列表、无选择状态或选择失效时不得渲染空批量条。
4. 更多菜单只用于低频或空间不足收纳；危险操作、权限原因、错误恢复、主提交和唯一导出回执不能只存在于更多菜单、Tooltip 或 Toast。
5. 权限、租户/工作区、能力开关或结果 owner 变化后，工具栏必须原子重算可见操作、禁用原因、批量条、导出入口和视图工具；无法证明安全的旧入口先移除或替换为安全说明。
6. 移动端不得删除新增、刷新、错误恢复、已选摘要、批量入口、导出恢复或主要视图工具。可以将低频工具收纳进“更多操作”、Action Sheet、Drawer 或独立页，但必须保留可访问名称、分组标题和焦点返回。
7. 工具栏状态变化、批量条出现/消失、刷新开始/失败、权限降级和操作结果不能重复公告；每类消息必须归唯一 owner。

## 文档影响

- `README.md`：增加当前规范摘要和链接。
- `HANDOFF.md`：增加交接摘要，强调它是编排层 owner。
- `SKILL.md`：增加路由。
- `docs/testing/page-toolbars-actions/`：增加 `green-summary.md`、`red-summary.md` 和 `page-toolbars-actions-audit.rb`。

## 验证策略

- 静态审计要求 owner、路由、README、HANDOFF 和红绿证据都包含核心硬规则。
- 突变检查覆盖：缺少 owner state、主操作埋入更多菜单、工具栏读取筛选草稿、空批量条、旧权限入口保留、移动端删除核心操作、Toast/Tooltip/更多菜单作为唯一恢复、运行时边界伪装已验证、项目泄漏。
- 继续执行全量现有审计、Markdown 链接检查和 `git diff --check`。

## 自检

- 无占位符。
- owner 边界聚焦编排，不抢 Buttons、Data Table、Query Filter、Export 或 Permission 的职责。
- 适合单次实施：一个 reference、三处摘要/路由、一个测试目录。
