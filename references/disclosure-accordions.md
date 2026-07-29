# 折叠面板与 Disclosure 交互规范

适用于 Accordion、Collapse、Disclosure、折叠面板、折叠区块、展开收起、展开面板、收起面板、详情折叠、设置折叠、高级筛选折叠、错误详情折叠、移动端折叠、嵌套折叠、accordion、collapse、disclosure、expand collapse、expandable panel、collapsible panel、collapsible section、details disclosure、settings accordion、filter accordion、error details、mobile accordion 和 nested accordion。

本文件是折叠/展开容器的 primary owner。表单字段、dirty、提交和错误摘要继续执行 [表单状态、校验与错误交互规范](forms.md)；只读详情字段语义继续执行 [信息展示与详情页交互规范](information-display.md)；筛选草稿、应用和 URL 继续执行 [查询条件与筛选交互规范](query-filters.md)；权限无泄露继续执行 [权限、租户与可见性交互规范](permissions-tenancy-visibility.md)；移动端和断点继续执行 [响应式与自适应交互规范](responsive-adaptive.md)。

## 范围与非目标

本 owner 覆盖 Accordion、Collapse、Disclosure、展开/收起面板、可折叠区块、详情折叠、筛选折叠、高级设置折叠、错误详情折叠、移动端折叠内容、单开、多开、默认展开、自动展开错误项、懒加载、持久化展开状态、嵌套折叠和权限隐藏。

本 owner 不覆盖 Tree 节点展开、Tabs 页面内视图切换、Wizard 步骤、表单字段值、提交生命周期、具体动画曲线、图标样式、颜色、间距或组件库 API。

## `disclosureAccordionState`

每个折叠组必须声明 `disclosureAccordionState`：

| 字段 | 语义 |
| --- | --- |
| `disclosureOwnerId` | 当前折叠组稳定 owner 身份，用于绑定 item、内容、请求、焦点、ARIA 和反馈。 |
| `surfaceKind` | 承载类型：`settings-sections`、`detail-sections`、`filter-sections`、`form-sections`、`error-details`、`audit-details`、`mobile-sections`。 |
| `itemRegistry` | 所有 item 的稳定 ID、标题、层级、默认展开、是否允许收起、权限、懒加载和可持久化策略。 |
| `expandedItemIds` | 当前展开 item 集合；它是 UI 可见性状态，不是业务事实。 |
| `expansionPolicy` | `single`、`multiple`、`at-least-one`、`manual-only`、`auto-expand-on-error`。 |
| `contentState` | 每个 item 的 loading、ready、error、stale、empty、dirty、invalid、permission-denied、disposal 状态。 |
| `requestBinding` | 懒加载内容请求绑定的 owner、itemId、对象 ID、权限版本、租户/工作区、route 和请求代次。 |
| `errorVisibilityBinding` | 折叠内错误、必填缺失、无权限、异步失败和恢复入口如何在折叠标题或外层摘要中可见。 |
| `permissionBoundary` | 标题、数量、摘要、图标、旧内容和子项关系的无泄露策略。 |
| `persistenceBinding` | 是否保存展开状态、保存范围、URL/本地偏好/保存视图边界和恢复校验。 |
| `focusAnnouncementPolicy` | 展开/收起后的焦点、标题按钮、`aria-expanded`、`aria-controls`、公告去重。 |
| `responsivePolicy` | 移动端折叠、分组、卡片、Drawer、独立页、安全区域和触摸目标。 |

## 语义边界与展开策略

展开状态不等于业务值、不等于表单提交、不等于权限事实。Accordion / Disclosure 只能隐藏可延后阅读或可分组的信息，不能隐藏完成当前任务必须立即处理的错误、风险确认、主操作、必填字段、保存失败、权限拒绝或唯一恢复路径。

单开、多开、至少一个展开、默认展开、自动展开错误项和是否允许全部收起都必须由 `expansionPolicy` 声明。不得依赖组件默认值决定业务可达性，不得把“当前收起”写成对象状态、表单字段、筛选条件、导出范围或权限事实。

## 错误、必填与恢复入口外显

折叠不能隐藏当前必须处理的错误、必填缺失、权限原因或恢复入口。若错误、必填缺失、异步失败或权限拒绝位于收起内容中，折叠标题或外层摘要必须显示可访问的错误/状态提示，并提供展开或跳转路径。

提交失败时，包含首个错误的 item 必须被展开或聚焦到可展开标题。错误摘要仍归 Forms 或 Feedback owner；本 owner 负责让折叠标题、展开状态和焦点路径能到达该错误。

## 权限、隐藏与安全摘要

disabled、hidden、permission-denied 和 not-enabled item 不是同一状态。disabled item 说明当前前置条件或对象状态不可用；hidden item 不暴露入口；permission-denied item 只能显示安全占位和申请路径；not-enabled item 表示能力不存在。

未启用 item 的 DOM、state、handler、request、URL 和偏好入口均为 0。无权限不得泄露标题、数量、对象名、字段名、错误明细、子项关系、旧内容或内部 ID，除非产品明确允许安全占位。

权限、租户/工作区、对象状态或 itemRegistry 变化后，旧标题、旧摘要、旧展开状态、旧内容、旧请求、旧焦点和旧 ARIA 引用必须原子失效或重算。

## 懒加载、持久化与迟到响应

懒加载内容请求必须绑定 `disclosureOwnerId`、itemId、对象 ID、权限版本、租户/工作区、route 和请求代次。懒加载迟到响应不得写回已收起、卸载、无权限或身份不匹配的 item；只能记录为 `disclosure-response-discarded`。

展开状态可以作为用户偏好保存，但必须声明 `persistenceBinding`。不得把展开状态写成业务字段、提交 payload、筛选条件、导出范围或权限事实。

URL、保存视图或本地偏好恢复展开状态前必须校验 itemRegistry 版本、权限、租户/工作区和对象状态。失效 item 不能静默展开、不能泄露标题或旧内容；必须使用安全默认展开、清理非法值或提示恢复原因。

## 焦点、ARIA 与嵌套折叠

触发器必须是真按钮或等价可访问控件，暴露 `aria-expanded` 和 `aria-controls`。展开后焦点默认留在触发器，只有用户意图明确或错误恢复需要时才移动到内容或错误目标。收起当前焦点所在内容前必须把焦点移动到对应触发器或安全替代入口。

嵌套折叠必须有唯一 owner 和层级边界。父级收起时只清理自己的可见内容和子 owner 生命周期，不得释放兄弟 owner；父子展开、错误和 loading 公告不得重复朗读同一完整消息。

## 移动端与响应式

移动端不得删除标题、当前展开状态、错误摘要、权限原因、恢复入口和核心操作。折叠面板可以转为卡片、分组、Drawer 或独立页，但不能改变业务语义、丢失错误外显、跳过未保存保护或让关键操作只存在于不可达深层。

低高度、虚拟键盘、安全区域、200% 缩放和触摸输入下，当前触发器、展开内容、错误提示、恢复入口和返回路径必须可达。

## 完成前检查

- 验证每个折叠组声明 `disclosureAccordionState`、`disclosureOwnerId`、`surfaceKind`、`itemRegistry`、`expandedItemIds`、`expansionPolicy`、`contentState`、`requestBinding`、`errorVisibilityBinding`、`permissionBoundary`、`persistenceBinding`、`focusAnnouncementPolicy` 和 `responsivePolicy`。
- 验证展开状态不等于业务值、不等于表单提交、不等于权限事实。
- 验证折叠不能隐藏当前必须处理的错误、必填缺失、权限原因或恢复入口。
- 验证 disabled、hidden、permission-denied 和 not-enabled item 不是同一状态。
- 验证懒加载迟到响应不得写回已收起、卸载、无权限或身份不匹配的 item。
- 验证嵌套折叠必须有唯一 owner 和层级边界。
- 验证移动端不得删除标题、当前展开状态、错误摘要、权限原因、恢复入口和核心操作。
- 真实浏览器、键盘、屏幕阅读器、移动端、权限切换、懒加载迟到和表单提交未实际执行时，最终报告必须逐项标为**未验证**，并写明所需浏览器、设备/viewport、输入方式及辅助技术环境；不得将静态文档审计写成运行时通过。

## 参考资料

- [WAI-ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [WCAG: Focus Order](https://www.w3.org/WAI/WCAG22/Understanding/focus-order.html)
- [WCAG: Status Messages](https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html)
