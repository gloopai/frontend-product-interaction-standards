# Tab 视图导航交互规范

适用于 Tabs、标签页、页签、TabList、TabPanel、当前标签、默认标签、禁用标签、隐藏标签、权限标签、页面内视图切换、对象详情标签、设置页标签、报表标签、列表状态标签、移动端标签、横向滚动标签、tabs、tab view、tab navigation、tablist、tabpanel、active tab、default tab、disabled tab、hidden tab、permission tab、page tabs、record tabs、settings tabs、report tabs、status tabs、mobile tabs 和 scrollable tabs。

本文件是页面内 tab view 的 primary owner。全局导航、侧边导航、面包屑、浏览器 Back/Forward、路由离开和返回列表继续执行 [导航与路由交互规范](navigation-routing.md)；字段型 Segmented Control、Radio、Toggle 继续执行 [选择控件与开关交互规范](selection-controls.md)；TabPanel 内表单继续执行 [表单状态、校验与错误交互规范](forms.md)；权限、租户与可见性继续执行 [权限、租户与可见性交互规范](permissions-tenancy-visibility.md)；移动端与断点继续执行 [响应式与自适应交互规范](responsive-adaptive.md)。

TabPanel 内可折叠内容、错误详情折叠和设置分组折叠必须同时执行 `references/disclosure-accordions.md`；不得用 Accordion 伪装页面内 tab navigation，也不得让折叠展开状态改变 `activeTabId`、URL 或 tab 权限语义。

## 范围与非目标

本 owner 覆盖页面内 Tabs、对象详情 Tabs、设置页 Tabs、报表 Tabs、列表状态 Tabs、TabList、TabPanel、active tab、default tab、disabled tab、hidden tab、permission tab、URL tab、懒加载 tab、保活 tab、权限变化后的恢复和移动端形态转换。

本 owner 不覆盖全局路由树、侧边导航、顶部导航、面包屑、主流程步骤、字段选择值、TabPanel 内业务表格/表单/图表/任务/导出生命周期、组件库样式、颜色、间距或动画曲线。

## `tabViewState`

每个页面内 tab view 必须声明 `tabViewState`：

| 字段 | 语义 |
| --- | --- |
| `tabOwnerId` | 当前 tab 组稳定 owner 身份，用于绑定 tab、panel、请求、URL、焦点和反馈。 |
| `surfaceKind` | 承载类型：`page-tabs`、`record-tabs`、`settings-tabs`、`report-tabs`、`list-status-tabs`、`mobile-tab-select`、`mobile-tab-drawer`。 |
| `tabRegistry` | 所有 tab 的稳定 ID、标题、作用域、权限、默认性、URL 策略、懒加载策略、保活策略和 fallbackPolicy。 |
| `activeTabId` | 当前已激活且通过权限和可用性检查的 tab。 |
| `pendingTabIntent` | 用户正在尝试切换的目标 tab、来源 tab、触发方式、检查状态和阻止原因。 |
| `panelState` | 每个 TabPanel 的 loading、ready、error、stale、dirty、keepAlive、disposal 和恢复状态。 |
| `requestBinding` | 懒加载或刷新请求绑定的 owner、tabId、对象 ID、权限版本、租户/工作区、route 和请求代次。 |
| `urlHistoryBinding` | tab 是否写 URL、浏览器历史、返回恢复、默认 tab 恢复、非法 tab 恢复和 URL 安全策略。 |
| `permissionBoundary` | tab 可见、禁用、隐藏、只读、无权限、权限变化和旧 panel 清理策略。 |
| `dirtyBoundary` | Tab 切换、浏览器 Back、路由离开、关闭容器和移动端返回是否进入同一未保存保护。 |
| `focusAnnouncementPolicy` | Tab 激活后的焦点目标、`aria-selected`、`aria-controls`、`aria-labelledby` 和状态公告去重。 |
| `responsivePolicy` | 移动端横向滚动、折叠、Select、Action Sheet、Drawer、独立页和焦点返回策略。 |

## 语义边界和不变量

Tabs 只能用于同一资源或同一任务上下文。互不相关页面、跨对象导航、跨租户/工作区切换、主流程步骤、危险状态变更和表单提交不能伪装成 Tabs；应使用路由、向导、表单操作或风险确认。

激活 tab 不等于提交表单、不等于保存视图、不等于切换租户/工作区。disabled tab、hidden tab、permission-denied tab 和 not-enabled tab 不是同一状态。旧 tab 请求不得写回新 active tab 或无权限 panel。Tab 切换必须经过同一未保存保护管线。移动端改变承载形态不得改变 `activeTabId`、URL、权限和 dirty 语义。

Tab 标题必须稳定、可访问、可区分，不能只靠图标、颜色、数量角标或 tooltip 表达。数量角标属于摘要，不得成为权限、状态或数据存在性的唯一来源。

## 激活、切换与 URL

Tab 切换先创建 `pendingTabIntent`，记录来源 tab、目标 tab、触发方式、输入方式、权限版本、对象版本和当前 dirty 状态。只有通过 tabRegistry、权限、对象状态、dirtyBoundary 和可用性检查后，才可提交 `activeTabId`。

写 URL 的 tab 必须只写稳定 `tabId`。不得把 tab 标题、敏感对象名、权限原因、内部 ID、数量角标、错误详情、草稿状态、旧权限或旧对象版本写入路径、查询串、片段、页面标题、分析日志或保存视图。

浏览器 Back/Forward、URL 恢复、保存视图恢复和默认 tab 恢复必须先校验 tabRegistry 版本、权限、租户/工作区、对象状态和 tab 是否仍启用。无效 tab 不得静默落到第一个 tab；必须进入可见恢复状态，说明使用默认 tab、移除非法参数、进入安全占位或需要申请权限。

## 懒加载、保活和迟到响应

懒加载请求必须绑定 `tabOwnerId`、`activeTabId`、目标 `tabId`、对象 ID、权限版本、租户/工作区、route 和请求代次。响应只有 owner live、tabOwnerId、目标 tabId、请求代次、权限版本、租户/工作区和 route 仍匹配时，才能写入对应 `panelState`。

迟到响应不得覆盖当前 active tab、不得清空其他 panel、不得抢焦点、不得写 URL、不得重复公告、不得重新显示无权限旧内容。旧 tab 请求不得写回新 active tab 或无权限 panel；不匹配响应只能记录为 `tab-response-discarded`。

保活 tab 必须声明 keepAlive 范围、缓存失效条件和权限变化清理策略。权限、租户/工作区、对象状态、tabRegistry、route 或会话变化后，无法证明仍安全的旧 panel、旧请求、旧缓存、旧错误、旧 focus target 和旧 ARIA 引用必须失效或清理。

## 未保存保护

Tab 切换、浏览器 Back、面包屑、菜单导航、关闭 Dialog/Drawer、移动端系统返回和路由离开必须进入同一未保存保护管线。dirty panel 可以阻止 tab 切换；用户确认放弃前不得卸载 panel、发起新 tab 请求或改变 URL。

切换被阻止时，焦点和公告留在当前 tab、当前 dirty panel 或未保存确认 owner；不得先显示目标 tab 内容再回滚，不得在阻止状态下预加载敏感目标 panel。

## 权限、禁用、隐藏和未启用

disabled tab、hidden tab、permission-denied tab 和 not-enabled tab 必须分开。disabled tab 表示当前状态暂不可用且应说明原因；hidden tab 表示当前用户不应发现入口；permission-denied tab 可以显示安全占位和申请路径；not-enabled tab 表示能力不存在。

未启用表示 DOM、state、handler、request 和 URL 入口均为 0。无权限不得泄露 tab 标题、数量、对象名、错误明细、旧内容或内部 ID，除非产品明确允许安全占位。权限变化后，tabRegistry、activeTabId、URL、panel cache、请求、焦点和公告必须原子收敛。

当前 active tab 失效时，不能私自选择第一个可见 tab；必须按产品声明的 fallbackPolicy 恢复，并说明原因。旧 URL 指向失效 tab 时走 URL 恢复路径，不得把失效原因藏在 Toast。

## 焦点、ARIA 和反馈

TabList 必须有可访问名称，tab 与 panel 使用稳定 `aria-controls` / `aria-labelledby` 关系。当前 tab 暴露正确 `aria-selected`；不可用 tab 使用可感知禁用或安全隐藏策略。横向 TabList 支持键盘方向键或等价可访问路径，Tab 键进入当前 panel 的合理首焦点或保持在当前 tab。

Tab 激活、加载、错误、权限拒绝、未保存阻止和 URL 恢复只能由一个 primary owner 完整公告。Tab 标题、Panel Alert、Toast 和全局 live region 不得重复朗读同一完整消息。

TabPanel loading、error、stale、empty 和 permission-denied 的承载继续执行反馈状态规范；本 owner 只决定该状态属于哪个 tab、能否保活、何时清理和如何恢复焦点。

## 移动端与响应式

移动端不得删除当前 tab、可用 tab、禁用原因、权限原因、错误状态、未保存保护、返回路径和恢复入口。横向滚动 tab 必须有边界提示、键盘路径和当前 tab 可见保障；不能让页面根横向溢出。

移动端可以把 Tabs 转为横向 TabList、Segmented Control、Select、Action Sheet、Drawer 或独立页。转换为 Select 或 Drawer 时仍是页面内 tab view，不得变成字段选择，不得提交表单值，不得丢失 `activeTabId`、URL、dirtyBoundary、panelState、权限状态或焦点返回。

断点切换时保持同一个 `tabOwnerId`、`tabRegistry`、`activeTabId`、`pendingTabIntent`、`panelState` 和在途请求身份。不得重复请求、重复公告、重置 panel、清空错误、跳过未保存确认或改变 URL。

## 完成前检查

- 验证每个页面内 tab view 声明 `tabViewState`、`tabOwnerId`、`surfaceKind`、`tabRegistry`、`activeTabId`、`pendingTabIntent`、`panelState`、`requestBinding`、`urlHistoryBinding`、`permissionBoundary`、`dirtyBoundary`、`focusAnnouncementPolicy` 和 `responsivePolicy`。
- 验证 Tabs 只能用于同一资源或同一任务上下文。
- 验证激活 tab 不等于提交表单、不等于保存视图、不等于切换租户/工作区。
- 验证 disabled tab、hidden tab、permission-denied tab 和 not-enabled tab 不是同一状态。
- 验证旧 tab 请求不得写回新 active tab 或无权限 panel。
- 验证 Tab 切换必须经过同一未保存保护管线。
- 验证写 URL 的 tab 必须只写稳定 `tabId`，恢复前校验 tabRegistry 版本、权限、租户/工作区、对象状态和 tab 是否仍启用。
- 验证移动端改变承载形态不得改变 `activeTabId`、URL、权限和 dirty 语义。
- 真实浏览器、键盘、屏幕阅读器、移动端、权限切换、网络迟到和未保存确认未实际执行时，最终报告必须逐项标为**未验证**，并写明所需浏览器、设备/viewport、输入方式及辅助技术环境；不得将静态文档审计写成运行时通过。

## 参考资料

- [WAI-ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [WCAG: Focus Order](https://www.w3.org/WAI/WCAG22/Understanding/focus-order.html)
- [WCAG: Status Messages](https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html)
