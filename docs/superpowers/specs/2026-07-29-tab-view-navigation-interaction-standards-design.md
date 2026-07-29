# Tab 视图导航交互规范设计

## 背景

管理台里大量页面用 Tabs 或页面内视图切换承载同一对象的不同信息：详情 / 配置 / 日志 / 成员 / 账单 / 任务 / 报表，也会用 Tabs 在列表里切换“全部、启用、停用、草稿、已归档”等视图。它看起来只是导航，但实际经常踩坑：

- Tab 切换直接卸载表单，丢失未保存草稿。
- 权限变化后隐藏 tab，但旧 URL、旧焦点或旧 panel 仍泄露内容。
- Lazy loading 的旧请求迟到后写回当前 tab。
- 用 Tabs 承载互不相关页面，导致返回、面包屑、标题和权限语义混乱。
- 移动端把 tab 压成不可读横向滚动，或者转 Select 后改变业务语义。
- Tab URL、浏览器返回和保存视图恢复没有校验版本、权限和对象状态。

现有 `navigation-routing.md` 已覆盖全局导航、返回、面包屑、浏览器历史和路由离开保护，也提到 Tabs；但它不适合继续吞掉 tab panel 内部加载、权限、缓存和移动端承载细节。`selection-controls.md` 中的 Segmented Control 也不是页面导航 owner。需要新增一个独立且更窄的 owner。

## 范围

新增 `references/tab-view-navigation.md`，作为以下场景的 primary owner：

- 页面内 Tabs、标签页、对象详情 Tabs、设置页 Tabs、报表 Tabs、列表状态 Tabs、审计/任务/成员页 Tabs。
- TabList、TabPanel、当前 tab、默认 tab、禁用 tab、隐藏 tab、权限 tab、懒加载 tab、保活 tab、URL tab、浏览器返回恢复。
- 桌面 Tabs 转移动端 Segmented Control、Select、Action Sheet、Drawer 或独立页时的语义一致。
- Tab 切换与未保存更改、表单 dirty、异步请求、焦点、公告、权限和旧缓存之间的边界。

不覆盖：

- 全局导航、侧边导航、面包屑、路由树、外链和返回列表；继续由 `references/navigation-routing.md` 负责。
- Checkbox/Radio/Switch/Segmented Control 作为字段选择；继续由 `references/selection-controls.md` 负责。
- 保存视图对象、默认视图、共享视图和布局预设；继续由 `references/saved-views-layout-presets.md` 负责。
- TabPanel 内的表格、筛选、搜索、表单、图表、导出、任务、审计日志等内容；继续由对应专项 owner 负责。

## 推荐方案

采用独立 owner：`tabViewState`。

推荐独立 owner 的原因是：Tabs 既不是普通导航，也不是字段选择。它有页面结构、URL、懒加载、焦点、权限和未保存保护；但仍限定在同一资源或同一任务上下文内。独立 owner 可以清楚表达“什么时候 tab 是页面内视图，什么时候应该升级成路由页面”。

### 方案对比

1. 独立 tab view owner（推荐）
   - 优点：边界清楚；覆盖 URL/历史、lazy loading、权限隐藏、未保存保护和移动端转换；不会污染全局导航。
   - 代价：需要新增路由、相邻 owner 链接和专项审计。

2. 扩展 navigation-routing
   - 优点：改动少，Tabs 已在导航规范中出现。
   - 代价：navigation 会变得过重；TabPanel 内请求和缓存不是路由 owner 的职责。

3. 扩展 selection-controls
   - 优点：Segmented Control 与 Tabs 在视觉上相似。
   - 代价：会把页面导航误当字段选择，导致提交、dirty、表单值和 URL 语义混乱。

## 状态模型

新 owner 定义 `tabViewState`，至少包含：

- `tabOwnerId`：当前 tab 组稳定 owner 身份。
- `surfaceKind`：`page-tabs`、`record-tabs`、`settings-tabs`、`report-tabs`、`list-status-tabs`、`mobile-tab-select`、`mobile-tab-drawer`。
- `tabRegistry`：声明所有 tab 的稳定 ID、标题、作用域、权限、默认性、URL 策略、是否懒加载、是否保活。
- `activeTabId`：当前已激活 tab。
- `pendingTabIntent`：用户正在尝试切换的目标 tab、来源、触发方式和是否被阻止。
- `panelState`：每个 tab panel 的加载、ready、error、stale、dirty、keepAlive、disposal 和恢复状态。
- `requestBinding`：懒加载或刷新请求绑定的 owner、tabId、对象 ID、权限版本、租户/工作区、route 和请求代次。
- `urlHistoryBinding`：tab 是否写 URL、浏览器历史、返回恢复、默认 tab 恢复和非法 tab 恢复。
- `permissionBoundary`：tab 可见、禁用、隐藏、只读、无权限、权限变化和旧 panel 清理策略。
- `dirtyBoundary`：Tab 切换、浏览器 Back、路由离开、关闭容器和移动端返回是否进入同一未保存保护。
- `focusAnnouncementPolicy`：Tab 激活后的焦点目标、`aria-selected`、`aria-controls`、`aria-labelledby` 和状态公告去重。
- `responsivePolicy`：移动端横向滚动、折叠、Select、Action Sheet、Drawer、独立页和焦点返回策略。

核心不变量：

- Tabs 只能用于同一资源或同一任务上下文。
- 激活 tab 不等于提交表单、不等于保存视图、不等于切换租户/工作区。
- disabled tab、hidden tab、permission-denied tab 和 not-enabled tab 不是同一状态。
- 旧 tab 请求不得写回新 active tab 或无权限 panel。
- Tab 切换必须经过同一未保存保护管线。
- 移动端改变承载形态不得改变 `activeTabId`、URL、权限和 dirty 语义。

## 行为规则

### 语义边界

Tabs 只能承载同一资源或任务上下文下的平级视图。互不相关页面、跨对象导航、跨租户/工作区切换、主流程步骤和危险状态变更不能伪装成 Tabs；应使用路由、向导、表单操作或风险确认。

Tab 标题必须稳定、可访问、可区分，不能只靠图标、颜色、数量角标或 tooltip 表达。数量角标属于摘要，不得成为权限或数据存在性的唯一来源。

### 切换、URL 与历史

Tab 切换先创建 `pendingTabIntent`，通过权限、对象状态、dirtyBoundary 和可用性检查后，才能提交 `activeTabId`。写 URL 的 tab 必须只写稳定 `tabId`，不得写 tab 标题、敏感对象名、权限原因、内部 ID 或草稿状态。

浏览器 Back/Forward、URL 恢复、保存视图恢复和默认 tab 恢复必须先校验 tabRegistry 版本、权限、租户/工作区、对象状态和 tab 是否仍启用。无效 tab 不得静默落到第一个 tab；必须进入可见恢复状态，说明使用默认 tab、移除非法参数或需要申请权限。

### 懒加载、保活与迟到响应

懒加载请求必须绑定 `tabOwnerId`、`activeTabId`、目标 `tabId`、对象 ID、权限版本、租户/工作区、route 和请求代次。迟到响应只能写回仍 live、身份匹配且权限仍有效的 panel；不得覆盖当前 active tab、清空其他 panel、抢焦点、写 URL 或重复公告。

保活 tab 必须声明 keepAlive 范围、缓存失效条件和权限变化清理策略。权限、租户/工作区、对象状态、tabRegistry 或 route 变化后，无法证明仍安全的旧 panel、旧请求、旧缓存、旧错误、旧 focus target 和旧 ARIA 引用必须失效或清理。

### 未保存保护

Tab 切换、浏览器 Back、面包屑、菜单导航、关闭 Dialog/Drawer、移动端系统返回和路由离开必须进入同一未保存保护管线。dirty panel 可以阻止 tab 切换；用户确认放弃前不得卸载 panel、发起新 tab 请求或改变 URL。

切换被阻止时，焦点和公告留在当前 tab 或未保存确认 owner；不得先显示目标 tab 内容再回滚。

### 权限、禁用与隐藏

disabled tab、hidden tab、permission-denied tab 和 not-enabled tab 必须分开。未启用表示 DOM、state、handler、request 和 URL 入口均为 0；无权限不得泄露 tab 标题、数量、对象名、错误明细、旧内容或内部 ID，除非产品明确允许安全占位。

权限变化后，tabRegistry、activeTabId、URL、panel cache、请求、焦点和公告必须原子收敛。当前 active tab 失效时，不能私自选择第一个可见 tab；必须按产品声明的 fallbackPolicy 恢复，并说明原因。

### 移动端与响应式

移动端可以把 Tabs 转为横向 TabList、Segmented Control、Select、Action Sheet、Drawer 或独立页，但不得删除当前 tab、可用 tab、禁用原因、权限原因、错误状态、未保存保护、返回路径和恢复入口。

横向滚动 tab 必须有边界提示、键盘路径和当前 tab 可见保障；不能让页面根横向溢出。转换为 Select 或 Drawer 时仍是页面内 tab view，不得变成字段选择、不得提交表单值、不得丢失 `activeTabId`、URL、dirtyBoundary 或 panelState。

## 相邻 owner 关系

- `references/navigation-routing.md`：全局导航、路由离开、浏览器 Back/Forward、面包屑和返回列表继续由 Navigation owner 负责；本 owner 接入同一离开保护管线。
- `references/selection-controls.md`：Segmented Control 作为移动端承载时仍执行 tab view 语义；不能把页面 tab 当字段值提交。
- `references/forms.md`：TabPanel 内表单 dirty、提交和错误归 Forms owner；本 owner 只读取 dirtyBoundary。
- `references/permissions-tenancy-visibility.md`：tab 可见性、禁用、隐藏、只读、无权限和旧缓存清理执行权限规范。
- `references/responsive-adaptive.md`：断点、横向滚动、触摸、虚拟键盘、安全区域和焦点可达执行响应式规范。
- `references/feedback-states.md`：TabPanel loading/error/stale/empty 的反馈承载执行反馈状态规范，状态来源由 tab panel owner 提供。
- `references/page-toolbars-actions.md`：Tab 上方或 tab 内工具栏只读取当前 active tab 和已提交 panel 状态。
- `references/saved-views-layout-presets.md`：保存视图可保存安全的 active tab，但不得保存草稿、旧权限或无权限 tab。

## 路由触发词

`SKILL.md` 应新增路由，命中：

- 中文：Tabs、标签页、页签、TabList、TabPanel、当前标签、默认标签、禁用标签、隐藏标签、权限标签、页面内视图切换、对象详情标签、设置页标签、报表标签、列表状态标签、移动端标签、横向滚动标签。
- English：tabs、tab view、tab navigation、tablist、tabpanel、active tab、default tab、disabled tab、hidden tab、permission tab、page tabs、record tabs、settings tabs、report tabs、status tabs、mobile tabs、scrollable tabs。

## 可执行验收方向

实施计划需要新增 Ruby 审计，至少覆盖：

1. owner 文件存在，且包含完整 `tabViewState` 字段。
2. 精确规则：Tabs 只能用于同一资源或同一任务上下文；激活 tab 不等于提交表单；旧 tab 请求不得写回新 active tab；Tab 切换必须经过同一未保存保护管线；disabled/hidden/permission-denied/not-enabled 分离；移动端转换不得改变 activeTabId。
3. URL/历史边界：只写稳定 `tabId`，恢复前校验 registry、权限、租户/工作区和对象状态。
4. 相邻 owner：navigation-routing、selection-controls、forms、permissions、responsive、feedback、page-toolbars、saved-views 必须链接到新 owner 或说明边界。
5. RED/GREEN 证据包含 activeTabId、pendingTabIntent、panelState、requestBinding、dirtyBoundary、permissionBoundary、responsivePolicy 和 `未验证`。

## 风险与取舍

- 不在首版定义具体视觉样式、颜色、间距或动画曲线。
- 不把所有导航都纳入 Tabs；跨对象、跨业务域或主流程步骤应使用路由或向导。
- 不禁止移动端转换成 Select/Drawer，但转换后仍必须保持 tab view 语义。
- 不定义 TabPanel 内部业务内容；内部内容继续由对应专项 owner 负责。

## 自检

- 范围聚焦：只新增页面内 tab view owner，不替代全局 navigation 或字段 selection controls。
- 边界清晰：tab 激活归本 owner；路由离开归 navigation；字段值归 forms/selection controls。
- 可审计：关键规则可转 exact terms 和 mutation cases。
- 运行时诚实：真实浏览器、键盘、屏幕阅读器、移动端、权限切换、网络迟到和未保存确认未执行时必须标为 `未验证`。
