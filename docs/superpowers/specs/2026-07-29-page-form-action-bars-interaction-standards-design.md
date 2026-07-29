# 页面级表单操作栏与保存区交互规范设计

## 背景

管理台高频页面里常见这些操作形态：页面底部“保存 / 取消”、详情编辑页 sticky footer、设置页保存栏、抽屉或独立页中的固定底部操作区、移动端底部提交区、脏状态提示条、保存后继续编辑、保存后返回列表、保存并新建、重置/放弃更改和保存失败恢复。

现有 owner 已覆盖相邻职责：

- `forms.md` 负责字段值、dirty、校验、提交快照、错误摘要和提交生命周期。
- `buttons.md` 负责单个按钮的语义、主次、loading、防重复、危险按钮和图标按钮。
- `navigation-routing.md` 负责返回、离开页面、dirty blockers、来源恢复和焦点恢复。
- `dialogs.md` / `drawers.md` 负责模态容器里的固定标题、固定底部操作、滚动与焦点。
- `settings-preferences-configuration.md` 负责设置项的草稿、生效、保存和默认值。
- `responsive-adaptive.md` 负责移动端、低高度、虚拟键盘、安全区域和断点转换。

缺口是：没有 owner 专门约束“页面级操作区如何承载保存意图”。结果项目很容易出现：保存按钮跟随页面滚走、移动端按钮被虚拟键盘遮挡、取消和返回混用、保存成功 Toast 之后页面状态没更新、保存失败后焦点不回错误、sticky footer 遮住最后一个字段、多个保存入口重复提交、保存并返回/保存并继续语义不清、只读/无权限时还保留幽灵保存按钮。

## 目标

- 新增“页面级表单操作栏与保存区” owner，覆盖 page form action bar、sticky action bar、save bar、bottom action bar、fixed footer actions、保存区、保存栏、底部操作区、保存/取消区、脏状态条、保存并返回、保存并继续、保存并新建、放弃更改、重置更改。
- 明确页面级操作区必须声明 `formActionBarState`：owner 身份、关联表单、保存意图、取消/返回意图、dirty 绑定、提交绑定、权限边界、布局避让、响应式策略、结果回执和焦点恢复。
- 区分保存、提交、应用、确认、取消、返回、关闭、放弃更改、重置、保存并返回、保存并继续和保存并新建，不允许用一个按钮或一个回调混合多个意图。
- 规定 sticky / fixed 操作区不得遮挡字段、错误摘要、帮助文本、表格分页、上传进度、底部安全区域或移动端键盘后的焦点。
- 规定多个保存入口共享同一提交 owner、同一 `submitSnapshot`、同一防重复和同一结果回执，不能各自发请求。
- 规定移动端不得删除保存、取消/返回、错误摘要、权限原因、脏状态说明和恢复路径。

## 非目标

- 不替代 `forms.md` 的字段状态、校验、dirty、submitSnapshot 和错误摘要。
- 不替代 `buttons.md` 的按钮文案、主次、loading、防重复和危险按钮规则。
- 不替代 `navigation-routing.md` 的来源恢复、浏览器 Back 和未保存离开保护。
- 不替代 Dialog/Drawer 容器内的模态遮罩、焦点陷阱和关闭顺序。
- 不规定具体 CSS token、阴影、圆角、组件库 API 或后端保存接口。
- 不强制所有页面都有 sticky footer；只在页面启用页面级保存区、底部操作区或固定操作区时适用。

## 推荐方案

推荐新增独立 owner：`references/page-form-action-bars.md`。

备选方案：

1. **扩展 Forms。** 优点是保存区常服务表单；缺点是 Forms 已经很重，且页面级保存区还涉及导航、权限、响应式避让和多入口编排。
2. **扩展 Buttons。** 优点是保存/取消都是按钮；缺点是按钮 owner 不应该管理页面布局、dirty 绑定、底部避让、来源恢复和提交结果。
3. **扩展 Navigation。** 优点是取消/返回/保存后返回关联导航；缺点是保存区还有提交、校验、权限、固定布局和移动端操作。
4. **独立 Page Form Action Bar owner。** 推荐。它只负责页面级操作区编排，并明确调用 Forms、Buttons、Navigation、Permissions、Responsive、Feedback、Risk owner。

## Owner 边界

建议路由关键词：

- 中文：页面表单操作栏、表单操作栏、保存栏、保存区、底部操作区、固定底部操作、固定保存栏、sticky 保存栏、sticky footer、保存按钮区、保存并返回、保存并继续、保存并新建、取消编辑、放弃更改、重置更改、脏状态条、未保存提示条。
- 英文：page form action bar、form action bar、save bar、save area、bottom action bar、fixed footer actions、sticky action bar、sticky footer actions、save and return、save and continue、save and create、cancel edit、discard changes、reset changes、dirty bar、unsaved changes bar.

该 owner 维护 `formActionBarState`，至少包含：

| 字段 | 说明 |
| --- | --- |
| `actionBarOwnerId` | 当前页面、表单会话或容器中的操作区稳定身份。 |
| `formBinding` | 关联的 Form owner、表单会话、dirty 状态、submitSnapshot 和错误摘要位置。 |
| `saveIntentPolicy` | 保存、提交、应用、保存并返回、保存并继续、保存并新建的意图、请求身份和终态策略。 |
| `cancelIntentPolicy` | 取消、返回、关闭、放弃更改、重置更改的区别、dirty blocker 和恢复目标。 |
| `buttonPolicy` | 主按钮、次按钮、危险按钮、禁用原因、loading、防重复和多入口共享策略。 |
| `layoutBoundary` | sticky/fixed/static 形态、滚动容器、底部留白、遮挡避让和内容结束边界。 |
| `permissionBoundary` | 可编辑、只读、无权限、未启用、对象状态和能力开关后的入口收敛。 |
| `feedbackBinding` | 保存成功、失败、部分成功、未知、冲突、权限拒绝和恢复入口的结果 owner。 |
| `focusReturnPolicy` | 提交失败、保存成功、取消、返回、重置、断点切换和 disposal 后的焦点目标。 |
| `responsivePolicy` | 移动端底部固定区、虚拟键盘、安全区域、低高度、触摸和系统返回策略。 |

## 核心规则

### 操作意图不能混用

保存、提交、应用、确认、取消、返回、关闭、放弃更改、重置、保存并返回、保存并继续和保存并新建必须是不同意图。取消不等于返回，返回不等于放弃更改，重置不等于清空，保存成功不等于导航成功。

页面上存在多个保存入口时，它们必须共享同一个 Form owner、同一个 `submitSnapshot`、同一个提交门禁、同一个防重复策略和同一个结果回执。不得让顶部保存、底部保存、快捷键保存和移动端保存各自发送请求。

### 固定操作区不得遮挡内容

sticky / fixed 保存栏必须为正文提供可验证的底部避让空间。最后一个字段、字段错误、帮助文本、错误摘要、上传进度、表格分页、审计回执和恢复入口不得被保存栏遮挡。不能用透明遮罩、负 margin、压缩字段间距或缩小触摸目标制造“看起来没挡住”。

页面根、内容区和保存栏只能有清晰的主滚动关系。若保存栏固定在视口底部，正文滚动容器必须把保存栏高度、阴影、底部安全区域和虚拟键盘后的可用高度计入布局。

### 脏状态和离开保护要统一

保存栏展示的脏状态必须来自 Forms owner 的 dirty / pristine 计算，不能从按钮禁用、字段 DOM、URL、Toast 或本地缓存推断。存在 dirty 时，取消、返回、关闭、浏览器 Back、Tab 切换、面包屑、菜单导航和外链必须进入 Navigation owner 的同一离开保护。

放弃更改必须说明会丢弃哪些草稿，并在确认前请求数为 0。重置更改必须回到明确的 initial/default/server-refill 状态；不能把重置写成“清空全部字段”。

### 权限和只读状态要收敛

只读、无权限、未启用、对象锁定、审批中、归档、会话过期或能力关闭时，保存区必须原子重算。无权或未启用时，保存按钮的 DOM、state、handler、request 和快捷键入口为 0，或显示安全只读说明；不得保留 disabled 幽灵按钮且无原因。

权限、租户/工作区、对象状态、表单版本或会话状态变化后，旧保存入口、旧快捷键、旧 loading、旧错误、旧 Toast、旧 focus target 和旧回调必须失效或重新证明安全。

### 移动端底部操作不能缩水

移动端可以把次要操作收进更多菜单、Action Sheet、Drawer 或独立页，但不得删除保存、取消/返回、错误摘要、权限原因、脏状态说明和恢复路径。底部固定区必须处理 `safe-area-inset-bottom`、动态视口、虚拟键盘、横屏低高度、系统字体放大、200% 缩放和触摸目标。

虚拟键盘出现后，当前聚焦字段、字段错误、错误摘要、保存按钮、取消/返回、提交中状态和恢复入口仍必须可见或可滚动到达。若无法保证，必须转换为更合适的 Drawer、独立页或分步流程，而不是隐藏取消或禁用错误摘要。

## 与其他 owner 的关系

- `forms.md`：字段状态、dirty、校验、submitSnapshot、错误摘要和提交生命周期归 Forms；本 owner 只读取这些状态并编排操作区。
- `buttons.md`：按钮文案、主次、loading、防重复、disabled、图标按钮和危险按钮归 Buttons；本 owner 负责这些按钮在页面级操作区的关系和布局。
- `navigation-routing.md`：返回、取消后的来源恢复、dirty blockers、浏览器 Back、Tab 切换和离开保护归 Navigation。
- `dialogs.md` / `drawers.md`：模态容器内固定底部操作、遮罩、焦点陷阱、关闭和 disposal 归容器 owner；本 owner 只补充保存区意图和避让。
- `permissions-tenancy-visibility.md`：只读、无权限、未启用、权限变化、旧入口清理和无泄露为基础规则。
- `risk-actions.md`：放弃更改、重置关键配置、覆盖设置、权限变更或不可逆保存需要风险确认时进入 Risk Actions。
- `global-feedback.md`：保存结果、错误、未知结果、冲突和恢复入口的反馈通道。
- `responsive-adaptive.md`：移动端底部固定区、虚拟键盘、安全区域、断点转换和触摸目标。

## 验收策略

后续正式实现新增静态审计 `docs/testing/page-form-action-bars/page-form-action-bars-audit.rb`，检查：

- `SKILL.md` 有页面表单操作栏、保存栏、保存区、底部操作区、固定保存栏、sticky footer、保存并返回、保存并继续、取消编辑、放弃更改、重置更改、dirty bar、form action bar、save bar、bottom action bar 等路由。
- `references/page-form-action-bars.md` 存在并包含 `formActionBarState`、`actionBarOwnerId`、`formBinding`、`saveIntentPolicy`、`cancelIntentPolicy`、`buttonPolicy`、`layoutBoundary`、`permissionBoundary`、`feedbackBinding`、`focusReturnPolicy` 和 `responsivePolicy`。
- README / HANDOFF 有中文摘要。
- RED/GREEN 证据覆盖保存/取消混用、保存并返回语义不清、多个保存入口重复请求、sticky footer 遮挡最后字段、移动端虚拟键盘遮挡按钮、dirty 状态从 DOM 推断、无权限幽灵保存按钮、保存成功 Toast-only、保存失败无错误恢复、运行时验证误标已验证等负例。
- mutation 模式删除任一关键规则会失败。

运行时真实浏览器、移动端设备、屏幕阅读器、真实虚拟键盘、真实表单提交、真实权限切换、真实离开保护、真实 sticky 布局和真实焦点恢复未执行时，必须标为**未验证**。

## 设计取舍

页面级保存区不是普通按钮，也不是表单 owner 的内部细节。它是把表单提交、按钮状态、页面布局、离开保护、权限收敛、反馈回执和移动端底部安全区串起来的编排层。独立 owner 能防住最常见事故：保存按钮滚走、sticky footer 遮挡字段、取消误当返回、多入口重复提交、Toast-only 成功、权限变化后旧保存入口还能触发，以及移动端键盘盖住底部操作。
