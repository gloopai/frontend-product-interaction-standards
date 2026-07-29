# 管理台 App Shell 与导航外框交互规范

适用于 App Shell、应用外框、管理台外框、全局导航、侧边导航、顶部导航、主导航、导航栏、侧边栏、折叠菜单、Logo/Home 入口、当前导航项、用户菜单、账号菜单、租户切换、工作区切换、组织切换、全局搜索入口、通知入口、帮助入口、移动端导航 Drawer、移动端菜单、app shell、application shell、global navigation、side navigation、top navigation、sidebar navigation、workspace switcher、tenant switcher、organization switcher、user menu、account menu、mobile navigation drawer 和 navigation shell。

本文件是管理台 App Shell 与导航外框 owner。它负责持久外框、全局导航结构、当前导航项、租户/工作区切换、用户菜单、全局入口、权限收敛、移动端外框、焦点公告和生命周期清理。页面级路由、返回和浏览器历史读取 `references/navigation-routing.md`；权限与租户可见性读取 `references/permissions-tenancy-visibility.md`；管理台跨页面治理读取 `references/admin-console.md`；响应式读取 `references/responsive-adaptive.md`；全局搜索读取 `references/search-command-palette.md`；通知入口读取 `references/notifications-message-center-announcements.md`；菜单和浮层读取 `references/overlays-menus-tooltips.md`；按钮入口读取 `references/buttons.md`；会话、账号切换和重新认证读取 `references/auth-session-reauth.md`。

## 范围与排除项

App Shell 不是普通页面，也不是一组静态链接。它是跨页面持久 owner，承载当前产品区域、导航结构、全局入口、租户/工作区、用户身份、权限版本、移动端导航形态和外框级焦点。

本 owner 不覆盖具体业务页面的查询、筛选、表格、表单、Tabs、Dialog、Drawer、后端权限模型、菜单配置 DSL、品牌视觉 token、官网/营销页导航或具体产品路由实现。

## `appShellNavigationState`

每个管理台 App Shell、全局导航、侧边栏、顶部栏、移动端导航或外框级入口必须声明 `appShellNavigationState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `shellOwnerId` | 当前 App Shell owner 的稳定身份。 |
| `shellSurface` | `admin-shell`、`console-shell`、`workspace-shell`、`tenant-shell`、`mobile-shell` 或产品声明的外框 surface。 |
| `navigationRegistry` | 主导航、侧边导航、顶部导航、分组、折叠、排序、徽标、快捷键、移动端顺序和不可隐藏入口。 |
| `currentNavBinding` | 当前页面、当前导航项、父级路径、面包屑来源、URL、权限版本和页面 owner 的绑定。 |
| `workspaceTenantBinding` | 当前组织、租户、工作区、切换候选、切换意图、权限版本、失败恢复和旧范围清理策略。 |
| `globalEntryRegistry` | 全局搜索、通知、帮助、任务中心、审计、创建入口和其他全局入口的 owner 转交。 |
| `userMenuBinding` | 当前用户、账号菜单、身份切换、退出登录、重新认证、偏好入口和安全状态。 |
| `permissionBoundary` | 查看导航、查看 badge、打开菜单、切换工作区、访问全局入口和显示可访问名称所需权限。 |
| `responsivePolicy` | 桌面、平板、窄屏、移动端 Drawer/Bottom Sheet/独立导航页、折叠策略和安全区域。 |
| `focusAnnouncementPolicy` | 打开/关闭导航、当前项变化、权限收敛、租户切换、移动端 Drawer 和错误恢复的焦点与公告策略。 |
| `lifecycleDisposal` | route/unmount、权限变化、租户切换、会话变化、断点转换和旧回调清理。 |
| `runtimeVerification` | 真实浏览器、键盘、读屏、触摸、权限切换、租户切换、会话变化和移动端视口验证状态；未执行必须标为未验证。 |

不得只用 `menuItems`、`routes`、`sidebarOpen`、`collapsed`、`selectedKeys`、`currentUser`、`tenantId`、`workspaceId`、`hasNotification` 或组件库导航默认状态替代 `appShellNavigationState`。

## 外框 owner 与页面 owner 边界

App Shell 可以跨页面存活，但不得吞掉页面 owner。页面标题、页面数据、表单 dirty、列表选择、详情返回和业务结果仍归各自页面或组件 owner；外框只持有导航结构、全局入口、当前项绑定、租户/工作区和焦点公告。

| 规则 ID | 规则 |
| --- | --- |
| `ASN-SCOPE-01` | App Shell 必须声明自己的 owner，不得由任一当前页面、路由库、组件库菜单或全局 store 暗中代理。 |
| `ASN-SCOPE-02` | 页面切换不得重建不必要的全局入口，也不得让旧页面迟到回调改写当前导航项、菜单、badge、用户菜单或焦点。 |
| `ASN-SCOPE-03` | 当前导航项必须绑定当前页面 owner、URL、权限版本和父级路径；不得只靠路径字符串或菜单 key 高亮。 |
| `ASN-SCOPE-04` | Logo/Home、主导航、面包屑入口、返回入口和页面内 Tabs 的职责必须分开，不得互相伪装。 |

## 导航结构、当前项和全局入口

导航结构必须可解释、可访问、权限安全。分组、折叠、当前项、徽标、快捷键和更多入口都必须绑定 `navigationRegistry`。

| 规则 ID | 规则 |
| --- | --- |
| `ASN-NAV-01` | 当前页面必须能定位到稳定的当前导航项、上级分组或声明的“无导航归属”状态。 |
| `ASN-NAV-02` | 当前项、父级分组、badge、图标、快捷键、tooltip、ARIA label 和隐藏文本必须来自同一权限版本。 |
| `ASN-NAV-03` | 全局搜索、通知、帮助、任务中心、审计和创建入口只作为入口；不能替代对应 owner 的状态、结果、审计或恢复路径。 |
| `ASN-NAV-04` | 折叠菜单不得隐藏唯一当前位置、唯一权限原因、唯一错误恢复、唯一租户/工作区切换或唯一退出路径。 |

## 租户/工作区切换和用户菜单

租户、工作区、组织和账号切换不是普通 Select。切换必须冻结当前身份、目标范围、权限版本、当前页面、离开 blocker、可恢复目标和失败恢复。

| 规则 ID | 规则 |
| --- | --- |
| `ASN-CTX-01` | 租户/工作区切换必须声明 `workspaceTenantBinding`，并经过未保存保护、权限复核、可见范围重算和焦点恢复。 |
| `ASN-CTX-02` | 切换中不得短暂闪现旧导航、旧对象名、旧 badge、旧菜单项、旧搜索结果、旧通知标题或旧 ARIA label。 |
| `ASN-CTX-03` | 切换失败、权限不足、会话过期或目标工作区不可用时，必须保留安全说明、重试、返回原范围、重新认证或选择其他范围路径。 |
| `ASN-CTX-04` | 用户菜单中的账号切换、退出登录、偏好、账单、安全设置和重新认证必须绑定 `userMenuBinding`，不得只作为普通 Dropdown 链接。 |

## 权限、安全和无泄露

权限降级、租户切换、工作区切换、会话变化、角色变化、功能关闭或菜单配置变化后，旧菜单、旧 badge、旧 tooltip、旧快捷键、旧搜索入口、旧通知入口、旧用户菜单、旧 DOM 和旧 ARIA 引用必须失效或重算。

| 规则 ID | 规则 |
| --- | --- |
| `ASN-PERM-01` | 无权限用户不得通过导航标签、图标、分组、排序位置、badge、快捷键、tooltip、URL、DOM、ARIA label、搜索入口或通知入口推断对象、数量、模块、成员、文件、任务、审批或旧缓存。 |
| `ASN-PERM-02` | 隐藏、禁用、只读、未启用和加载中必须分开表达；不能把无权限菜单留在 DOM 中只靠 CSS 隐藏。 |
| `ASN-PERM-03` | 权限待解析时显示安全骨架或泛化外框，不得先渲染旧导航再异步收敛。 |
| `ASN-PERM-04` | 菜单项被移除时，焦点只迁移一次到安全标题、上级导航、恢复入口或稳定外框区域。 |

## 响应式和移动端导航

移动端可以把侧边导航转为 Drawer、Bottom Sheet、全屏导航页或分组菜单，但不得删除当前位置、主导航、工作区/租户切换、用户菜单、全局搜索入口、通知入口、权限说明、返回/恢复路径和退出路径。

| 规则 ID | 规则 |
| --- | --- |
| `ASN-RSP-01` | 移动端导航形态必须保留与桌面相同的核心入口、权限判断、当前项和恢复路径。 |
| `ASN-RSP-02` | 移动端导航 Drawer 必须执行 Drawer owner 的遮罩、焦点、滚动、安全区域、关闭和 disposal 规则。 |
| `ASN-RSP-03` | 低高度、虚拟键盘、动态 viewport、四向 safe area、系统字体放大、200% 缩放、触摸、系统返回、WebView 返回和浏览器 Back 下，导航打开/关闭、工作区切换、用户菜单、搜索入口、通知入口和权限恢复必须可达。 |
| `ASN-RSP-04` | 折叠为更多菜单时，当前项、主导航、退出登录、重新认证、权限说明和错误恢复不能只藏在 hover、长按或不可达层级里。 |

## 可访问性、焦点和生命周期

App Shell、主导航、分组、当前项、用户菜单、工作区切换、搜索入口、通知入口、帮助入口和移动端导航入口必须有可访问名称。当前位置、权限收敛、切换结果、错误恢复和移动端打开/关闭必须由唯一 owner 公告。

每个 App Shell owner 必须登记菜单订阅、权限解析、工作区切换、用户菜单、全局入口、badge 订阅、快捷键、焦点任务、公告和断点转换。route/unmount、权限变化、租户/工作区切换、会话变化、断点转换或外框卸载时，旧订阅、旧菜单、旧 badge、旧快捷键、旧 tooltip、旧 ARIA、旧焦点任务和旧公告必须取消或失效。

迟到回调必须匹配 `shellOwnerId`、`navigationRegistry`、`permissionBoundary`、`workspaceTenantBinding`、会话版本和当前外框生命周期。失配结果只能丢弃或转入安全恢复；不得改写当前导航项、badge、用户菜单、URL、焦点或公告。

## 可执行验收检查

1. **状态模型**：记录 `appShellNavigationState` 全字段。
2. **owner 边界**：页面切换时 App Shell 不被页面 owner 误代理，旧页面迟到回调不能改写外框。
3. **当前项绑定**：当前导航项绑定页面 owner、URL、权限版本和父级路径；无归属页面显示安全说明。
4. **全局入口转交**：全局搜索、通知、帮助、任务中心、审计和创建入口只作为入口，不替代对应 owner 的状态、结果或恢复。
5. **租户/工作区切换**：切换冻结身份、目标范围、权限版本、当前页面、离开 blocker 和恢复目标；失败时提供安全恢复。
6. **用户菜单**：账号切换、退出登录、偏好、安全设置和重新认证绑定 `userMenuBinding`，不是普通 Dropdown 链接。
7. **权限无泄露**：权限降级或切换后旧菜单、旧 badge、旧 tooltip、旧快捷键、旧搜索/通知入口、旧 DOM 和旧 ARIA label 不暴露。
8. **移动端保真**：移动端保留当前位置、主导航、工作区/租户切换、用户菜单、搜索入口、通知入口、权限说明、返回/恢复路径和退出路径。
9. **焦点公告**：导航打开/关闭、当前项变化、权限收敛、租户切换和错误恢复只由唯一 owner 公告，焦点只迁移一次。
10. **运行时报告边界**：真实浏览器、键盘、读屏、触摸、权限切换、租户切换、会话变化、移动端 Drawer、快捷键和真实视口未执行时，必须逐项标为未验证。

## 完成前检查

- 是否声明 `appShellNavigationState` 及全部必要字段。
- 是否把 App Shell 外框与页面路由、页面内容和页面内 Tabs 分开。
- 是否让当前导航项、父级路径、badge、tooltip 和 ARIA label 绑定同一权限版本。
- 是否把租户/工作区切换作为上下文切换处理，而不是普通 Select。
- 是否让全局搜索、通知、帮助、任务中心和审计只作为入口转交对应 owner。
- 是否防止旧菜单、旧入口、旧 badge、旧快捷键和迟到回调泄露或写回。
- 是否在移动端保留核心导航、上下文切换、用户菜单、搜索、通知、权限说明和恢复。
- 未实际执行运行时检查时，是否明确标为未验证。
