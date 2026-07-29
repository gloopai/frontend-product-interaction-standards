# 页面级表单操作栏与保存区交互规范

适用于后台、管理台、控制台、SaaS console 和内部工具中的页面表单操作栏、表单操作栏、保存栏、保存区、底部操作区、固定底部操作、固定保存栏、sticky 保存栏、sticky footer、保存按钮区、保存并返回、保存并继续、保存并新建、取消编辑、放弃更改、重置更改、脏状态条和未保存提示条。

本文件是页面级保存/取消/返回/放弃更改/重置操作区的唯一 owner。它定义页面级操作区如何读取表单、按钮、导航、权限、反馈、风险和响应式 owner；不替代这些 owner 的底层状态和组件规则。

## 范围与非目标

本 owner 覆盖页面、独立编辑页、设置页、详情编辑页、抽屉内容、复杂 Dialog 内容和移动端底部固定区中的保存区编排。它覆盖保存意图、取消/返回意图、dirty 绑定、多保存入口共享、sticky/fixed 布局避让、底部安全区域、虚拟键盘、权限收敛、结果回执和焦点恢复。

本 owner 不定义字段值、字段校验、`submitSnapshot` 生成、按钮视觉样式、按钮 loading 文案、Dialog/Drawer 遮罩、路由历史实现、后端保存接口、CSS token、组件库 API 或像素级间距。若页面没有页面级保存区或固定底部操作区，必须给出 absence contract：DOM、state、handler、request、快捷键和旧入口均为 0。

## `formActionBarState`

每个页面级表单操作栏、保存栏、底部操作区或 sticky footer 必须声明 `formActionBarState`：

| 字段 | 语义 |
| --- | --- |
| `actionBarOwnerId` | 当前页面、表单会话、Drawer、Dialog 或独立编辑页中的操作区稳定身份。 |
| `formBinding` | 关联的 Form owner、表单会话、dirty/pristine、`submitSnapshot`、字段错误、错误摘要和提交阶段。 |
| `saveIntentPolicy` | 保存、提交、应用、保存并返回、保存并继续、保存并新建的意图、请求身份、提交后动作和终态策略。 |
| `cancelIntentPolicy` | 取消、返回、关闭、放弃更改、重置更改的区别、dirty blocker、确认策略和恢复目标。 |
| `buttonPolicy` | 主按钮、次按钮、危险按钮、禁用原因、loading、防重复、快捷键和多入口共享策略。 |
| `layoutBoundary` | static、sticky、fixed、容器内固定、底部固定、滚动容器、底部留白、遮挡避让和内容结束边界。 |
| `permissionBoundary` | 可编辑、只读、无权限、未启用、对象状态、能力开关、租户/工作区和旧入口清理策略。 |
| `feedbackBinding` | 保存成功、保存失败、部分成功、冲突、未知、权限拒绝、离开阻止和恢复入口的结果 owner。 |
| `focusReturnPolicy` | 提交失败、保存成功、取消、返回、放弃、更改重置、断点切换和 disposal 后的焦点目标。 |
| `responsivePolicy` | 桌面、平板、移动端、低高度、虚拟键盘、安全区域、触摸、Action Sheet、Drawer、Bottom Sheet 和独立页承载策略。 |

`formActionBarState` 只能编排页面级操作区。字段内部草稿、表单校验、按钮点击语义、导航历史和权限缓存仍由各自 owner 维护。

## 操作意图与多入口提交

保存、提交、应用、确认、取消、返回、关闭、放弃更改、重置、保存并返回、保存并继续和保存并新建必须是不同意图。取消不等于返回，返回不等于放弃更改，重置不等于清空，保存成功不等于导航成功。

保存并返回必须先完成当前 Form owner 的提交终态，再按 Navigation owner 执行来源恢复；保存并继续必须保留当前表单会话或按产品声明进入新 pristine 会话；保存并新建必须在成功后创建明确的新建会话，不能复用旧 `submitSnapshot` 或旧错误。

页面上存在多个保存入口时，它们必须共享同一个 Form owner、同一个 `submitSnapshot`、同一个提交门禁、同一个防重复策略和同一个结果回执。顶部保存、底部保存、快捷键保存、移动端保存、菜单保存和浮动保存不得各自发送重复请求。

保存区中的主按钮必须绑定当前可提交意图。存在 in-flight 提交时，重复点击、Enter、Space、触摸双击、快捷键重复和事件重放不得创建第二个提交意图、第二个请求或第二个成功/失败回执。

## Sticky / fixed 布局避让

sticky / fixed 保存栏必须为正文提供可验证的底部避让空间。最后一个字段、字段错误、帮助文本、错误摘要、上传进度、表格分页、审计回执和恢复入口不得被保存栏遮挡。

保存栏固定在视口底部、容器底部或 Drawer/Dialog 底部时，正文滚动容器必须计入保存栏高度、阴影、边框、底部安全区域、虚拟键盘后的可用高度和系统缩放。不得依赖透明覆盖、负 margin、压缩字段间距、隐藏错误摘要或缩小触摸目标制造“看起来没挡住”。

页面根和内容区只能有清晰的主滚动关系。保存栏不得让页面根和内容区同时产生互相竞争的纵向滚动；不得让保存栏跟随长内容滚走，导致用户到页面底部前无法保存或取消；也不得让固定保存栏覆盖表格分页、批量条、上传进度或错误恢复入口。

如果内容太短，保存栏可以静态放在内容末尾；如果内容较长或移动端可用高度有限，保存栏可以 sticky/fixed。但无论形态如何，保存、取消/返回、错误摘要、权限原因、脏状态说明和恢复路径必须可发现且可达。

## 脏状态、取消、返回与离开保护

保存栏展示的脏状态必须来自 Forms owner 的 dirty / pristine 计算，不能从按钮禁用、字段 DOM、URL、Toast 或本地缓存推断。dirty 条、未保存提示条、保存按钮启用、取消确认和离开保护必须读取同一 Form 会话。

取消、返回、关闭、浏览器 Back、Tab 切换、面包屑、菜单导航和外链必须进入 Navigation owner 的同一离开保护。存在 dirty、上传中、导入预检中、校验等待中、保存中、风险确认中或异步任务待确认时，任何离开入口都不能绕过 `dirtyBlockers`。

放弃更改必须说明会丢弃哪些草稿，并在确认前请求数为 0。放弃只丢弃客户端草稿和当前表单会话，不得伪装成服务端已撤销、已取消任务或已恢复默认；若已经发送保存请求，关闭页面或放弃客户端流程不能改变服务端结果语义。

重置更改必须回到明确的 initial/default/server-refill 状态。重置不是清空全部字段；若业务确实需要清空，应使用清空意图、说明影响范围，并按 Forms 和 Risk Actions owner 执行。

## 权限、只读与旧入口清理

只读、无权限、未启用、对象锁定、审批中、归档、会话过期、能力关闭或租户/工作区切换后，保存区必须原子重算。无权或未启用时，保存按钮的 DOM、state、handler、request 和快捷键入口为 0，或显示安全只读说明。

只读页面可以显示保存区不存在、只读原因、申请权限、切换工作区、重新认证或返回路径；不能渲染禁用但无原因的幽灵保存按钮。禁用按钮必须说明可恢复前置条件，例如必填错误、无更改、对象锁定、权限不足、提交中或依赖任务未完成。

权限、租户/工作区、对象状态、表单版本或会话状态变化后，旧保存入口、旧快捷键、旧 loading、旧错误、旧 Toast、旧 focus target 和旧回调必须失效或重新证明安全。迟到提交结果不得重启旧保存栏、写回旧错误、恢复到旧焦点目标或泄露无权限字段。

无权限、只读、未启用和对象状态禁用必须分开表达。未启用表示产品或配置没有该能力，四类入口为 0；只读表示可查看但不可保存；无权限表示可提供申请权限或切换身份；对象状态禁用表示当前对象不允许编辑。

## 移动端、虚拟键盘与响应式承载

移动端不得删除保存、取消/返回、错误摘要、权限原因、脏状态说明和恢复路径。次要操作可以进入更多菜单、Action Sheet、Drawer、Bottom Sheet 或独立页，但保存、取消/返回、提交中状态和错误恢复必须仍然可发现、可触达并有可访问名称。

虚拟键盘出现后，当前聚焦字段、字段错误、错误摘要、保存按钮、取消/返回、提交中状态和恢复入口仍必须可见或可滚动到达。底部固定区必须处理 `safe-area-inset-bottom`、动态视口、浏览器工具栏变化、横屏低高度、系统字体放大、200% 缩放和触摸目标。

断点切换时必须保持同一 `actionBarOwnerId`、`formBinding`、dirty 状态、提交意图、取消意图、权限判断和反馈 owner。不得因桌面 sticky 保存栏转移动端底部固定区而重复请求、丢失草稿、清空错误、重置 dirty、改变返回目标或重复公告。

若移动端无法同时保持字段、错误摘要、保存、取消/返回、权限原因和恢复入口可达，必须升级为全屏 Drawer、独立页或分步流程；不能用隐藏取消按钮、隐藏错误摘要、缩小触摸目标或关闭离开保护来换空间。

## 与其他 owner 的关系

- [表单状态、校验与错误交互规范](forms.md)：字段状态、dirty、校验、`submitSnapshot`、错误摘要和提交生命周期归 Forms；本 owner 只读取并编排页面级操作区。
- [按钮交互规范](buttons.md)：按钮文案、主次、loading、防重复、disabled、图标按钮和危险按钮归 Buttons；本 owner 负责它们在保存区的关系、布局和多入口共享。
- [导航与路由交互规范](navigation-routing.md)：返回、取消后的来源恢复、dirty blockers、浏览器 Back、Tab 切换、面包屑和外链离开保护归 Navigation。
- [Dialog 交互规范](dialogs.md) / [Drawer 交互规范](drawers.md)：模态容器内遮罩、焦点陷阱、固定底部操作、关闭和 disposal 归容器 owner；本 owner 补充保存区意图、dirty 绑定和底部避让。
- [权限、租户与可见性交互规范](permissions-tenancy-visibility.md)：只读、无权限、未启用、权限变化、旧入口清理和无泄露为基础规则。
- [危险操作与恢复交互规范](risk-actions.md)：放弃更改、重置关键配置、覆盖设置、权限变更或不可逆保存需要风险确认时进入 Risk Actions。
- [全局反馈与通知交互规范](global-feedback.md)：保存结果、错误、未知结果、冲突、权限拒绝和恢复入口的反馈通道。
- [响应式与自适应交互规范](responsive-adaptive.md)：移动端底部固定区、虚拟键盘、安全区域、断点转换和触摸目标。

## 完成前检查

- 验证每个页面级表单操作栏、保存栏、底部操作区或 sticky footer 声明 `formActionBarState`、`actionBarOwnerId`、`formBinding`、`saveIntentPolicy`、`cancelIntentPolicy`、`buttonPolicy`、`layoutBoundary`、`permissionBoundary`、`feedbackBinding`、`focusReturnPolicy` 和 `responsivePolicy`。
- 验证保存、提交、应用、确认、取消、返回、关闭、放弃更改、重置、保存并返回、保存并继续和保存并新建是不同意图，并且文案、按钮和回调不混用。
- 验证多个保存入口共享同一个 Form owner、同一个 `submitSnapshot`、同一个提交门禁、同一个防重复策略和同一个结果回执；重复点击、快捷键和触摸双击不会发重复请求。
- 验证 sticky / fixed 保存栏为正文提供可验证底部避让；最后一个字段、字段错误、帮助文本、错误摘要、上传进度、表格分页、审计回执和恢复入口不被遮挡。
- 验证保存栏 dirty 状态来自 Forms owner 的 dirty / pristine 计算，而不是按钮 disabled、字段 DOM、URL、Toast 或本地缓存。
- 验证取消、返回、关闭、浏览器 Back、Tab 切换、面包屑、菜单导航和外链都进入 Navigation owner 的同一离开保护。
- 验证放弃更改说明会丢弃哪些草稿，确认前请求数为 0；重置更改回到明确的 initial/default/server-refill 状态，不能伪装成清空全部字段。
- 验证无权或未启用时保存按钮 DOM、state、handler、request 和快捷键入口为 0，或显示安全只读说明；权限和对象状态变化后旧保存入口、旧快捷键、旧 loading、旧错误、旧 Toast、旧 focus target 和旧回调失效。
- 验证移动端不得删除保存、取消/返回、错误摘要、权限原因、脏状态说明和恢复路径。
- 验证虚拟键盘出现后，当前聚焦字段、字段错误、错误摘要、保存按钮、取消/返回、提交中状态和恢复入口仍可见或可滚动到达。
- 真实浏览器、移动端设备、屏幕阅读器、真实虚拟键盘、真实表单提交、真实权限切换、真实离开保护、真实 sticky 布局和真实焦点恢复未执行时，必须明确标为未验证，并列出所需验证。

## 参考资料

- [WAI-ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [WCAG: Focus Not Obscured](https://www.w3.org/WAI/WCAG22/Understanding/focus-not-obscured-minimum.html)
- [WCAG: Focus Order](https://www.w3.org/WAI/WCAG22/Understanding/focus-order.html)
- [WCAG: Status Messages](https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html)
