# 保存视图、视图预设与个性化布局交互规范设计

## 背景

管理台常见“保存当前视图”“我的视图”“共享视图”“设为默认”“恢复默认”“列设置”“密度”“排序/筛选组合”“看板/表格视图切换”“报表预设”和“个人列布局”。现有规范已经覆盖相邻能力：

- `data-tables.md` 负责数据表格的查询、排序、分页、列、选择和结果状态。
- `query-filters.md` 负责筛选草稿、已应用筛选、URL 同步、重置和权限收敛。
- `page-toolbars-actions.md` 负责页面工具栏、列设置、密度和视图切换入口。
- `settings-preferences-configuration.md` 负责普通设置页草稿、生效和默认值。
- `permissions-tenancy-visibility.md` 负责权限、租户/工作区和无泄露。

缺口是：没有 owner 负责“把当前查询/筛选/排序/列布局/密度/展示模式保存成可复用视图”的完整状态链。项目容易把保存视图实现成一份本地 JSON 或 URL 收藏，却漏掉保存的是草稿还是已应用条件、保存范围是个人还是团队、共享后是否泄露字段、默认视图覆盖了谁、旧视图在权限变化后是否失效、移动端是否还能切换/恢复，以及视图应用是否会悄悄改写当前未保存筛选。

## 目标

- 新增“保存视图、视图预设与个性化布局” owner，覆盖 saved view、view preset、personal view、shared view、default view、favorite view、saved filter、column layout、layout preset、density preset、view switcher preset 和 restore default view。
- 明确保存视图必须绑定 `savedViewState`：视图身份、作用域、查询快照、筛选快照、排序、列布局、密度、展示模式、权限版本、租户/工作区、默认策略、共享策略、应用结果和审计。
- 区分当前草稿、已应用条件、当前临时布局、已保存视图、默认视图、共享视图和系统预设。
- 禁止把筛选草稿、Select query、未提交日期范围、当前页码、局部展开、临时列拖拽或旧权限字段误保存成正式视图。
- 规定应用视图、覆盖视图、重命名、删除、设为默认、共享、取消共享、恢复默认和导入/导出视图的权限、风险、未知结果和恢复路径。
- 规定移动端不得删除视图切换、当前视图说明、保存/覆盖、恢复默认、权限原因、冲突恢复和审计入口。

## 非目标

- 不替代 `data-tables.md` 的表格基础状态、列渲染和排序分页规则。
- 不替代 `query-filters.md` 的筛选字段、草稿/已应用分离和 URL 筛选规则。
- 不替代 `page-toolbars-actions.md` 的工具栏入口、更多菜单收纳和移动端操作承载。
- 不定义后端保存视图存储、同步协议、协作编辑、推荐算法或跨产品模板市场。
- 不强制所有页面都支持保存视图；不支持时必须有 absence contract，不能残留隐藏状态或请求路径。

## 推荐方案

推荐新增独立 owner：`references/saved-views-layout-presets.md`。

备选方案：

1. **扩展 Data Tables。** 优点是保存视图常用于表格；缺点是保存视图也出现在报表、看板、日志、任务中心、审计列表和配置列表，且涉及个人/共享/默认作用域。
2. **扩展 Query Filters。** 优点是保存视图包含筛选；缺点是视图还包含列、密度、排序、展示模式、默认视图和共享权限。
3. **扩展 Settings。** 优点是个人偏好像设置；缺点是保存视图是页面级可应用对象，不是普通设置项，应用视图会影响查询和结果 owner。
4. **独立 Saved Views owner。** 推荐。该 owner 只负责保存/应用/共享/默认/恢复的状态链，并与 Data Table、Query Filters、Toolbar、Permissions 交叉执行。

## Owner 边界

建议路由关键词：

- 中文：保存视图、视图预设、我的视图、个人视图、共享视图、团队视图、默认视图、系统视图、收藏视图、保存筛选、筛选预设、列布局、列设置预设、布局预设、密度预设、恢复默认视图、设为默认视图、复制视图、共享筛选、视图切换器。
- 英文：saved view、saved views、view preset、view presets、personal view、shared view、team view、default view、system view、favorite view、saved filter、filter preset、column layout、layout preset、density preset、restore default view、set default view、copy view、share view、view switcher.

该 owner 维护 `savedViewState`，至少包含：

| 字段 | 说明 |
| --- | --- |
| `savedViewOwnerId` | 当前页面或列表的保存视图 owner 稳定身份。 |
| `viewIdentity` | 视图 ID、名称、类型、来源、版本、创建人、更新时间和是否系统预设。 |
| `viewScope` | 个人、团队、租户/工作区、角色、系统默认、共享范围和可见权限。 |
| `appliedSnapshot` | 当前已应用查询、筛选、排序、时间范围和展示上下文快照。 |
| `layoutSnapshot` | 列可见性、列顺序、固定列、列宽、密度、展示模式、分组和图表/表格模式。 |
| `draftBinding` | 当前筛选草稿、列调整草稿、命名草稿和分享设置草稿，必须与已保存视图区分。 |
| `defaultPolicy` | 系统默认、个人默认、团队默认、角色默认、恢复默认和默认冲突策略。 |
| `sharePolicy` | 可共享对象、共享范围、继承权限、外部成员可见性和无泄露策略。 |
| `applyIntent` | 应用视图、覆盖视图、复制视图、删除视图、设为默认、取消共享和恢复默认的冻结意图。 |
| `permissionBoundary` | 查看、应用、保存、覆盖、删除、共享、设默认和审计所需权限版本。 |
| `resultReceipt` | 成功、失败、部分成功、未知、权限拒绝、冲突、过期和恢复路径。 |
| `auditBinding` | 创建、覆盖、应用、共享、取消共享、设默认、恢复默认和删除视图的审计身份。 |

## 核心规则

### 保存的是已应用快照，不是输入草稿

保存视图必须读取 `appliedSnapshot` 和明确允许持久化的 `layoutSnapshot`。筛选草稿、Select query、active option、未提交日期范围、正在编辑的列拖拽、当前临时页码、展开行、hover、高亮、焦点、loading、错误状态和旧结果缓存不得进入正式保存视图。

若用户正在编辑筛选或列设置，保存视图前必须明确“保存已应用条件”或要求用户先应用/确认草稿。不能悄悄把草稿当作已保存视图，也不能因保存视图而自动应用草稿。

### 应用视图不是普通筛选重置

应用视图必须创建 `applyIntent`，说明将替换哪些内容：筛选、排序、时间范围、列布局、密度、展示模式、分组或图表配置。应用前如存在未保存筛选草稿、未提交列设置或正在进行的任务，必须按对应 owner 处理离开/覆盖确认。

应用视图后，Query Filters、Data Table、Toolbar、URL、结果摘要和焦点必须读取同一视图版本。旧查询请求、旧结果、旧列布局、旧 URL、旧焦点和旧 live region 必须失效或重算。

### 个人、共享和默认不能混用

个人视图、团队共享视图、系统预设、个人默认、团队默认和角色默认必须分开表达。设为默认必须说明影响范围；共享必须说明可见对象和权限继承；删除共享视图不得删除他人的个人副本；恢复默认必须说明恢复到系统默认、个人默认还是团队默认。

共享视图不得泄露无权限字段、筛选值、对象名称、数量、列名、内部 ID、成员、客户、文件名、金额、发票、密钥、审计字段或旧缓存。权限、租户/工作区、角色、字段可见性、功能开关或数据范围变化后，旧视图必须失效、过滤、降级或要求重新确认。

### 覆盖、删除和共享是风险动作

覆盖视图、删除视图、设为默认、共享给团队、取消共享、恢复默认和批量管理视图必须说明影响范围、视图版本、目标范围、权限版本、请求身份和未知结果。高影响动作应进入 `risk-actions.md`；确认前请求数为 0。

未知结果不能伪装成已保存、已覆盖、已删除、已共享、已设为默认或已恢复默认。必须提供刷新视图列表、检查当前视图、查看审计、重试或联系支持路径。

### 移动端能力不能丢

移动端可以把视图列表、列设置、共享设置和默认设置放进 Drawer、Bottom Sheet、Action Sheet 或独立页，但不得删除视图切换、当前视图说明、保存视图、覆盖视图、恢复默认、权限原因、冲突恢复、错误回执和审计入口。

低高度、虚拟键盘、安全区域、系统字体放大、横屏和 WebView 返回后，当前视图名、已应用摘要、保存/取消、应用/恢复、共享范围、错误说明和焦点返回仍必须可达。

## 与其他 owner 的关系

- `query-filters.md`：筛选草稿、已应用筛选、URL 筛选和字段校验归 Query Filters；本 owner 只保存和应用已证明安全的筛选快照。
- `data-tables.md`：表格列、排序、分页、选择和结果状态归 Data Tables；本 owner 管理可持久化布局快照，不能保存临时选择或当前页码冒充视图。
- `page-toolbars-actions.md`：视图切换器、列设置入口和更多菜单收纳归 Toolbar；本 owner 负责视图对象状态、应用/保存/共享/默认结果。
- `settings-preferences-configuration.md`：若视图作为个人偏好存在，草稿/保存/生效仍读 Settings；本 owner 负责页面视图语义和查询/布局联动。
- `permissions-tenancy-visibility.md`：共享范围、字段可见性、旧视图降级和无泄露为基础规则。
- `risk-actions.md`：覆盖、删除、共享、设默认、恢复默认和批量管理视图的高影响确认。
- `audit-log-activity-history.md`：视图创建、覆盖、应用、共享、设默认、恢复默认和删除的审计。
- `responsive-adaptive.md`：移动端视图切换、列设置和分享设置的承载转换。

## 验收策略

后续正式实现新增静态审计 `docs/testing/saved-views-layout-presets/saved-views-layout-presets-audit.rb`，检查：

- `SKILL.md` 有保存视图、视图预设、个人视图、共享视图、默认视图、保存筛选、列布局、布局预设、密度预设、saved view、view preset、personal view、shared view、default view、saved filter、column layout 等路由。
- `references/saved-views-layout-presets.md` 存在并包含 `savedViewState`、`savedViewOwnerId`、`viewIdentity`、`viewScope`、`appliedSnapshot`、`layoutSnapshot`、`draftBinding`、`defaultPolicy`、`sharePolicy`、`applyIntent`、`permissionBoundary`、`resultReceipt`、`auditBinding`。
- README / HANDOFF 有中文摘要。
- RED/GREEN 证据覆盖保存筛选草稿、保存当前页码、共享无权限字段、默认视图范围混淆、覆盖未知结果伪成功、删除共享视图误删个人副本、旧视图权限变化后继续应用、移动端删除恢复默认、运行时验证误标已验证等负例。
- mutation 模式删除任一关键规则会失败。

运行时真实浏览器、移动端设备、屏幕阅读器、真实权限切换、真实租户/工作区切换、真实 URL 恢复、真实多人共享、真实默认视图冲突、真实审计写入和真实数据表格/筛选联动未执行时，必须标为**未验证**。

## 设计取舍

保存视图不是普通筛选，也不是普通设置。它是把多个 owner 的已应用状态冻结为一个可命名、可应用、可共享、可默认的对象。独立 owner 能防住最常见事故：保存了草稿、共享了无权限字段、默认覆盖范围不清、旧视图继续使用旧权限、移动端找不到恢复默认，以及未知结果被写成保存成功。
