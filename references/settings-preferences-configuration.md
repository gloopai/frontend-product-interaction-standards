# 设置、偏好与配置页交互规范

适用于 settings、preferences、configuration、config page、setting page、preference page、feature setting、notification setting、integration setting、default setting、save settings、reset defaults、inherit defaults、设置、偏好、配置页、设置页、偏好页、配置项、策略配置、通知设置、集成设置、默认设置、保存设置、重置默认和继承默认。本文件是设置页、偏好页、配置项、策略项、默认值、继承配置、生效模式、保存/取消/重置和权限收敛的唯一事实来源。

字段状态、校验、错误摘要和表单提交继续执行 [表单状态、校验与错误交互规范](forms.md)。Switch、Radio、Checkbox、Toggle 和 Segmented Control 继续执行 [选择控件与开关交互规范](selection-controls.md)。按钮语义、loading 和防重复继续执行 [按钮交互规范](buttons.md)。危险配置、强确认和不可逆影响继续执行 [危险操作与恢复交互规范](risk-actions.md)。权限、租户/工作区和无泄露继续执行 [权限、租户与可见性交互规范](permissions-tenancy-visibility.md)。离开页面和未保存保护继续执行 [导航与路由交互规范](navigation-routing.md)。移动端承载继续执行 [响应式与自适应交互规范](responsive-adaptive.md)。审计回执继续执行 [审计日志与操作历史交互规范](audit-log-activity-history.md)。

条件设置项、依赖配置、继承默认影响下游、上游配置切换、条件必填、自动填充和隐藏配置值清理必须同时执行 `references/conditional-fields-dependent-inputs.md`。设置 owner 负责 draftSettings、savedSettings、effectiveSettings、defaultSettings、applyMode 和 resultReceipt；条件字段 owner 负责 `fieldDependencyState`、upstreamSnapshot、downstreamPolicy、valueRetentionPolicy 和 submitSnapshotPolicy。

## 范围与非目标

本 owner 覆盖用户偏好、租户配置、工作区配置、项目配置、环境配置、角色配置、对象配置、通知设置、功能开关、策略配置、外部集成配置、默认值、继承默认、保存设置、重置默认、恢复保存值、清空自定义、配置保存结果和配置审计回执。

本 owner 不覆盖具体设置项、业务默认值、后端接口、存储模型、字段校验细节、单个按钮文案、Switch/Radio/Checkbox 控件语义或危险操作强确认细节。

## `settingsState`

每个设置页、设置组或配置项必须声明 `settingsState`：

| 字段 | 语义 |
| --- | --- |
| `settingsOwnerId` | 当前设置页面、设置组或配置项的稳定 owner 身份。 |
| `settingsScope` | 配置作用域：用户、租户、工作区、项目、环境、角色、对象、集成或组合范围。 |
| `draftSettings` | 用户当前编辑但未保存的设置草稿。 |
| `savedSettings` | 服务端确认保存的配置值和版本。 |
| `effectiveSettings` | 当前实际生效的值，可能来自保存值、默认值、继承值或权限派生值。 |
| `defaultSettings` | 产品默认、组织默认、上级继承默认或权限派生默认。 |
| `applyMode` | `immediate`、`explicit-save`、`confirm-required`。 |
| `dirtyState` | 脏字段、脏分组、保存能力、取消能力、离开保护和恢复目标。 |
| `resetPolicy` | 恢复保存值、重置默认、继承默认和清空自定义的语义边界。 |
| `permissionBoundary` | 谁可读、可改、可恢复、可查看默认、可查看审计和可管理集成。 |
| `requestIdentity` | 保存、恢复、重置、继承或清空请求的配置快照、作用域、权限版本和幂等键。 |
| `resultReceipt` | 保存成功、部分成功、失败、冲突、未知结果和审计回执。 |
| `responsivePolicy` | 移动端保存/取消、脏状态、作用域、默认值、错误和恢复路径保留策略。 |

设置项必须声明作用域和生效模式。用户偏好、租户配置、工作区配置、项目配置、环境配置、角色配置、对象配置和集成配置不得混用同一含糊状态，也不得用当前页面标题临时推断作用域。

## 草稿、保存值、生效值和默认值

`draftSettings` 不得伪装成 `effectiveSettings`。显式保存模式下，编辑字段、切换开关、选择选项或重排配置只改变草稿；结果摘要、审计、外部集成状态和下游页面不能把草稿写成已生效。

`savedSettings` 表示服务端已确认的配置值；`effectiveSettings` 表示当前实际生效值。两者可以不同：例如继承默认、等待发布、外部系统同步中、权限派生覆盖或部分保存失败。界面必须说明当前显示的是草稿、已保存值、生效值、默认值还是继承值。

`defaultSettings` 必须说明来源：产品默认、组织默认、上级继承、环境默认或权限派生默认。默认值、强制默认和用户自定义值必须可区分，不得都显示成普通当前值。

## 生效模式和提交边界

`applyMode=immediate` 的设置必须在控件旁说明更改会立即生效。每次更改都建立不可变请求身份；失败时恢复到上一个有效值或进入可见失败状态，不得静默回跳或只发 Toast。

`applyMode=explicit-save` 的设置必须提供保存和取消/恢复路径。保存前 `draftSettings` 与 `savedSettings` 可同时展示差异；保存成功后才更新 `savedSettings`，只有服务端确认生效后才更新 `effectiveSettings`。

`applyMode=confirm-required` 用于高影响、高风险、跨租户/工作区、外部集成、权限、账单、安全、通知群发、数据保留或不可逆配置。高风险设置必须进入 `risk-actions.md`，保存前请求数为 0；未完成确认不得发送保存请求。

同一设置组内混用即时生效和显式保存时，必须清楚分区并分别说明；不得让用户误以为所有更改都会一起保存或立即生效。

## 保存、取消、恢复和重置

保存、取消、恢复保存值、重置默认、继承默认和清空自定义是不同意图，不得都写成“重置”。每个意图必须说明作用范围：当前字段、当前分组、当前页面、当前作用域、全部子项或继承链。

取消只丢弃 `draftSettings`，恢复到 `savedSettings` 或当前可证明的 `effectiveSettings`；不得取消已发送且服务端可能继续执行的保存请求。恢复保存值表示回到最近一次服务端确认值。重置默认表示应用 `defaultSettings`；继承默认表示移除本层覆盖并读取上级值；清空自定义表示删除用户配置但不一定等于产品默认。

有脏状态时，页面离开、切换设置组、切换租户/工作区、关闭 Drawer/Dialog、浏览器 Back 或系统返回必须经过未保存保护。保护只处理客户端草稿，不得把已发送请求写成“已取消”。

## 权限、租户和版本收敛

权限、租户/工作区、角色、对象状态或配置版本变化后，旧草稿、旧默认值、旧禁用原因、旧保存按钮和旧集成状态必须原子收敛。无法证明仍安全的配置值、按钮、菜单、保存请求、默认说明、继承链和旧错误先隐藏、失效或替换安全说明。

无权限、只读、禁用、未启用和继承锁定必须区分。无权限不得泄露配置名称、当前值、默认值、继承来源、集成状态、内部 ID、目标对象或旧缓存；只读可显示允许读取的值；未启用表示该能力 DOM、state、handler 和 request 入口均为 0。

## 异步结果、冲突和审计

保存、恢复、重置、继承和清空请求必须绑定不可变配置快照、`settingsScope`、权限版本、配置版本和幂等键。迟到结果只有 owner、scope、权限版本、配置版本和请求身份匹配时才能提交。

保存结果必须区分成功、部分成功、失败、冲突、未知结果和审计回执。部分成功、失败、冲突和未知结果不得伪装成成功。冲突必须显示当前服务端版本、用户草稿是否仍可应用、重新加载、覆盖或合并的安全路径；未知结果必须提供检查最新状态或查看审计/任务的路径。

保存成功、失败、部分成功、冲突、未知和审计回执不能只靠 Toast；必须在设置页、设置组、操作历史或审计入口中可追溯。

## 移动端与可访问性

移动端不得删除保存/取消、脏状态、作用域说明、默认值说明、继承说明、危险确认、错误摘要、审计回执或恢复路径。复杂设置可以进入 Drawer、Bottom Sheet、分步配置或独立页，但核心状态和恢复路径必须保持。

设置组必须有可感知标题和说明。字段、默认值、继承值、脏状态、保存状态、错误和禁用原因不能只靠颜色、图标、Tooltip 或位置表达。保存成功、失败、冲突、未知和权限降级必须由唯一 owner 公告，不能重复播报。

## 生命周期和清理

路由变化或 owner 卸载时，设置 owner 立即进入 disposal：取消或失效草稿防抖、保存请求、默认值加载、集成状态订阅、权限订阅、审计回执监听和旧焦点任务。旧回调不得重新显示旧草稿、旧默认值、旧保存按钮、旧集成状态、旧错误或旧焦点目标。

## 完成前检查

- 验证每个设置页、设置组或配置项声明 `settingsState`、`settingsOwnerId`、`settingsScope`、`draftSettings`、`savedSettings`、`effectiveSettings`、`defaultSettings`、`applyMode`、`dirtyState`、`resetPolicy`、`permissionBoundary` 和 `resultReceipt`。
- 验证设置项必须声明作用域和生效模式，不从页面标题、URL 或当前租户临时猜测。
- 验证 `draftSettings` 不得伪装成 `effectiveSettings`；显式保存前下游、审计和结果摘要不读取草稿。
- 验证保存、取消、恢复保存值、重置默认、继承默认和清空自定义是不同意图。
- 验证高风险设置必须进入 `risk-actions.md`，保存前请求数为 0。
- 验证权限、租户/工作区、角色、对象状态或配置版本变化后，旧草稿、旧默认值、旧禁用原因、旧保存按钮和旧集成状态必须原子收敛。
- 验证部分成功、失败、冲突和未知结果不得伪装成成功，且有页面内回执或审计恢复路径。
- 验证移动端不得删除保存/取消、脏状态、作用域说明、默认值说明、继承说明、危险确认、错误摘要、审计回执或恢复路径。
- 真实浏览器、键盘、屏幕阅读器、触摸、权限切换、租户切换、配置版本冲突、外部集成状态和移动端视口未实际执行时，必须明确标为未验证，并列出所需验证。

## 参考资料

- [WAI-ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [WCAG: Error Identification](https://www.w3.org/WAI/WCAG22/Understanding/error-identification.html)
- [WCAG: Focus Order](https://www.w3.org/WAI/WCAG22/Understanding/focus-order.html)
- [WCAG: Status Messages](https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html)
