# 导航与路由交互规范

## 范围

适用于管理台、业务后台、SaaS console、内部工具、报表页、列表页、详情页、配置页和工作流页中的主导航、侧边导航、顶部导航、面包屑、Tabs、返回按钮、返回列表、关闭容器、浏览器 Back/Forward、路由切换、外部链接、未保存离开保护、来源恢复、权限变化后的跳转和移动端返回。

本文件是用户如何在页面、容器和路由之间安全移动的唯一事实来源。它定义导航入口、来源上下文、返回策略、路由离开保护、层级路径、任务上下文、浏览器历史、权限重校验、焦点恢复和卸载清理。它不重新定义 Dialog、Drawer、表格、筛选、表单字段或全局反馈的内部交互；这些 owner 仍按各自文件执行。

## 与组件 owner 的关系

App Shell、应用外框、管理台外框、全局导航、侧边导航、顶部导航、用户菜单、工作区/租户切换和移动端导航 Drawer 必须同时执行 `references/app-shell-navigation.md`；本文件负责路由意图、来源恢复、离开保护和焦点恢复，`app-shell-navigation.md` 负责持久外框、全局入口、当前项绑定和外框级权限收敛。

Page Header、页面标题区、页面头部、标题栏、页面标题、副标题、对象标题、状态摘要、标题区主操作和移动端标题区必须同时执行 `references/page-header-title-area.md`；本文件负责面包屑、返回、URL、来源恢复和路由失败，`page-header-title-area.md` 负责标题区页面身份、标题快照、操作槽和标题区权限收敛。

返回、保存、取消、关闭、删除、导出和打开外链等按钮读取 `buttons.md`；表单脏状态、未保存更改和提交生命周期读取 `forms.md`；页面内 Tabs、TabList、TabPanel、active tab、权限 tab、懒加载 tab 和移动端 tab 承载必须同时执行 `references/tab-view-navigation.md`，并接入本文件同一离开保护管线；列表、分页、排序、选择和批量范围读取 `data-tables.md`；查询条件恢复和 URL 筛选读取 `query-filters.md`；新增/编辑承载面读取 `record-editing-surfaces.md`；Dialog / Drawer 关闭和焦点规则读取 `dialogs.md` / `drawers.md`；权限、租户/工作区、危险操作和审计读取 `admin-console.md`；Toast、Banner 和错误回执读取 `global-feedback.md`；移动端断点、安全区域和触控读取 `responsive-adaptive.md`。

从列表上下文打开、关闭、恢复或通过 URL 表达详情预览、侧边预览、行预览、记录预览、快速查看、只读预览和 Master-Detail 时，必须同时执行 `references/preview-pane.md`；本文件负责来源恢复、浏览器 Back/Forward、URL 安全、焦点恢复和兜底目标，`preview-pane.md` 负责预览目标、来源绑定、预览关闭与权限无泄露。

当本文件与其他 owner 都适用时，两者都执行。冲突时停止受影响实现并请用户裁决；不得用“路由库默认如此”“浏览器默认如此”或“组件默认如此”降低规范。

## 场景与状态模型

每个导航区域或路由容器声明 `navigationSurface`：`global-navigation`、`side-navigation`、`top-navigation`、`breadcrumb`、`tabs`、`record-return`、`container-close`、`route-change`、`browser-history`、`external-link`、`mobile-navigation` 或 `permission-redirect`。

每个导航区域或路由容器维护 `navigationState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `routeOwnerId` | 当前页面、容器或路由 owner 的稳定身份。 |
| `currentLocation` | 当前路径、路由参数、查询参数、hash、租户/工作区、权限范围和页面语义。 |
| `sourceContext` | 用户进入当前页面的来源列表、来源任务、来源筛选、来源滚动、来源焦点、来源容器和进入原因。 |
| `returnPolicy` | 返回目标、返回失败兜底、是否恢复来源、是否允许关闭容器、是否需要二次确认和权限失败策略。 |
| `historyIntent` | push、replace、restore、close、external、redirect、blocked 或 recover 等浏览器历史意图。 |
| `permissionVersion` | 进入、恢复、返回和打开外链时使用的权限、租户/工作区、角色和数据范围版本。 |
| `dirtyBlockers` | 未保存表单、未完成上传、批量任务、临时编辑、草稿、危险操作确认和自定义离开保护。 |
| `focusRestoreTarget` | 导航完成、返回、关闭、阻止离开或失败恢复后的焦点目标。 |
| `disposalLog` | route/unmount、容器关闭、权限跳转和失败恢复时已清理的订阅、请求、计时器、焦点保护和临时状态。 |

返回不得直接等同于 `history.back()`。`history.back()` 只能是 `returnPolicy` 经过来源验证、权限验证、离开保护、焦点恢复和兜底声明之后的一个实现选项；没有 `sourceContext` 和 `returnPolicy` 的页面不得提供“返回列表”“返回上一页”或关闭容器。

## NAV-SCOPE 范围和导航所有权

| 规则 ID | 规则 |
| --- | --- |
| NAV-SCOPE-01 | 每个页面、容器和导航区域必须声明 `routeOwnerId`、受控区域、导航入口和返回出口。 |
| NAV-SCOPE-02 | 全局导航、侧边导航、顶部导航、面包屑、Tabs、返回按钮、浏览器 Back/Forward、关闭容器和外部链接都必须创建可解释的 `historyIntent`。 |
| NAV-SCOPE-03 | 导航 owner 只负责路由意图、来源恢复、离开保护和焦点恢复；字段校验、列表请求、弹窗关闭和全局反馈仍归对应 owner。 |
| NAV-SCOPE-04 | 路由库、组件库、浏览器历史栈和移动端 WebView 默认行为不能绕过本文件规则；冲突时必须配置、封装或拦截。 |

对应验收：NAV-A1、NAV-A10。

## NAV-STATE 导航状态与来源上下文

`sourceContext` 必须描述用户从哪里来、为什么来、返回时恢复什么、恢复失败怎么办。来源可以是列表、筛选结果、报表钻取、任务中心、搜索结果、外部深链、通知、弹窗/抽屉内打开或权限跳转。来源不能只存在于浏览器历史栈，也不能只存在于某个组件局部变量。

| 规则 ID | 规则 |
| --- | --- |
| NAV-STATE-01 | `navigationState` 必须包含 `routeOwnerId`、`currentLocation`、`sourceContext`、`returnPolicy`、`historyIntent`、`permissionVersion`、`dirtyBlockers`、`focusRestoreTarget` 和 `disposalLog`。 |
| NAV-STATE-02 | `currentLocation` 必须记录路径、参数、查询、hash、租户/工作区、权限范围和页面语义；不得只保存 path 字符串。 |
| NAV-STATE-03 | `sourceContext` 必须记录来源 owner、来源位置、来源筛选/排序/分页、来源滚动、来源焦点、进入原因和恢复版本。 |
| NAV-STATE-04 | `returnPolicy` 必须声明返回目标、兜底目标、恢复方式、失败说明、是否需要离开确认和权限失败处理。 |
| NAV-STATE-05 | 权限、租户/工作区、角色、数据范围、URL 参数或来源 owner 变化后，必须重建或重新验证 `navigationState`。 |

对应验收：NAV-A1、NAV-A2、NAV-A8。

## NAV-RETURN 返回、来源恢复和关闭容器

返回动作的目标是让用户回到可理解、可恢复、权限安全的位置，而不是机械退回历史栈。返回列表、返回上一级、关闭详情、关闭编辑器、返回报表、返回搜索结果和返回任务中心必须各自声明语义。

| 规则 ID | 规则 |
| --- | --- |
| NAV-RETURN-01 | 返回不得直接等同于 `history.back()`；必须先读取 `returnPolicy` 并验证来源、权限、离开保护和焦点恢复。 |
| NAV-RETURN-02 | 缺少 `sourceContext` 时，返回按钮不得承诺“返回来源”；只能进入声明过的安全兜底目标，并说明来源不可恢复。 |
| NAV-RETURN-03 | 返回列表必须恢复安全的 `appliedFilters`、排序、分页/游标、滚动位置、选中摘要和来源焦点；不能只跳到列表首页。 |
| NAV-RETURN-04 | 从 Dialog、Drawer、独立页或移动端独立编辑页返回时，必须区分关闭容器、返回来源、保存后跳转和放弃草稿。 |
| NAV-RETURN-05 | 返回失败、来源过期、来源无权限或来源已删除时，必须进入安全兜底目标，并提供可见说明和下一步。 |
| NAV-RETURN-06 | 返回、取消、关闭、保存后返回和外链返回不得共享一个无语义的 `goBack()`；每个动作必须有动作对象和结果 owner。 |

对应验收：NAV-A2、NAV-A3、NAV-A10。

## NAV-BLOCK 路由离开保护和未保存状态

浏览器 Back/Forward、面包屑、Tabs、菜单导航、关闭容器和外部链接都必须经过同一离开保护管线。该管线读取 `dirtyBlockers`，按 owner 合并未保存表单、未完成上传、批量操作、草稿、危险确认和异步提交状态，并生成允许、阻止、确认、保存后继续或丢弃后继续的结果。

| 规则 ID | 规则 |
| --- | --- |
| NAV-BLOCK-01 | 浏览器 Back/Forward、面包屑、Tabs、菜单导航、关闭容器和外部链接都必须经过同一离开保护管线。 |
| NAV-BLOCK-02 | `dirtyBlockers` 必须包含 blocker owner、阻止原因、可保存性、可丢弃性、异步状态、确认文案和继续目标。 |
| NAV-BLOCK-03 | 未保存状态存在时，不得让路由先切走再弹确认；必须先阻止导航，确认后再创建新的 `historyIntent`。 |
| NAV-BLOCK-04 | 保存中、上传中、导入预检中、危险操作确认中和批量任务范围未确认时，不得通过 Back、外链或菜单绕过当前 owner。 |
| NAV-BLOCK-05 | 离开被阻止后，焦点必须回到确认、保存入口、错误摘要或触发导航的控件；不得丢到页面顶部或隐藏元素。 |

对应验收：NAV-A4、NAV-A9、NAV-A10。

## NAV-STRUCT 面包屑、Tabs 和导航结构

面包屑表示层级路径，不表示最近历史。Tabs 只用于同一资源或同一任务上下文；不能把无关页面、全局导航、筛选视图或最近访问记录伪装成 Tabs。

| 规则 ID | 规则 |
| --- | --- |
| NAV-STRUCT-01 | 面包屑表示层级路径，不表示最近历史；每一级必须有稳定层级语义、可访问名称和权限验证。 |
| NAV-STRUCT-02 | 面包屑最后一级表示当前位置，通常不可点击；若可点击刷新或重载，必须明确动作语义。 |
| NAV-STRUCT-03 | 面包屑跳转必须经过离开保护、权限重校验和来源更新；不能作为无保护的普通链接。 |
| NAV-STRUCT-04 | Tabs 只用于同一资源或同一任务上下文；跨模块、跨权限域、跨租户/工作区或无共享上下文的页面不得放进同一组 Tabs。 |
| NAV-STRUCT-05 | Tab 切换必须声明是否保留草稿、滚动、筛选、焦点和请求结果；切换失败必须保持当前 Tab 可理解。 |

对应验收：NAV-A5、NAV-A6、NAV-A10。

## NAV-HISTORY 浏览器历史、URL 和外部链接

浏览器历史是结果，不是产品策略。push、replace、restore、redirect、external 和 blocked 必须由 `historyIntent` 声明。URL 变化、浏览器 Back/Forward、刷新、深链打开和分享链接必须与页面语义、权限、来源恢复和状态摘要一致。

| 规则 ID | 规则 |
| --- | --- |
| NAV-HISTORY-01 | push、replace、restore、redirect、external 和 blocked 必须写入 `historyIntent`；不得由散落的路由调用临时决定。 |
| NAV-HISTORY-02 | URL 参数恢复必须先经过 schema、版本、权限和敏感性校验；不得静默接收过期或无权参数。 |
| NAV-HISTORY-03 | 浏览器 Back/Forward 不得绕过 `dirtyBlockers`、权限重校验、来源恢复、焦点恢复或全局反馈。 |
| NAV-HISTORY-04 | 外部链接必须声明打开方式、来源保留、权限风险、未保存离开保护和回到产品的路径。 |
| NAV-HISTORY-05 | 路由跳转失败、权限跳转、登录过期和网络失败必须可恢复；不得留下 URL、标题、面包屑和内容彼此不一致的状态。 |

对应验收：NAV-A3、NAV-A6、NAV-A7。

## NAV-PERM 权限、租户和安全收敛

旧导航上下文、旧面包屑标签、旧记录名、旧返回目标、旧 URL 参数和旧焦点目标都必须重新证明安全。权限降级、租户/工作区切换、角色变化、数据范围变化、登录过期和对象删除后，导航文案、链接目标和恢复状态不得泄露无权信息。

| 规则 ID | 规则 |
| --- | --- |
| NAV-PERM-01 | 每次进入、返回、恢复、面包屑跳转、Tab 切换、外链打开和权限跳转都必须携带并校验 `permissionVersion`。 |
| NAV-PERM-02 | 旧导航上下文、旧面包屑标签、旧记录名、旧返回目标、旧 URL 参数和旧焦点目标都必须重新证明安全。 |
| NAV-PERM-03 | 无权位置不得显示原对象名称、数量、字段、筛选值、文件名、任务名或内部 ID；只能显示安全说明和允许的下一步。 |
| NAV-PERM-04 | 权限变化导致当前位置不可访问时，必须明确是留在安全说明、跳到上级、跳到默认首页还是要求重新认证。 |
| NAV-PERM-05 | 权限跳转、登录过期和租户切换不得吞掉未保存保护；必须先处理 `dirtyBlockers` 或声明不可恢复原因。 |

对应验收：NAV-A7、NAV-A8、NAV-A10。

## NAV-A11Y 焦点、可访问名称和状态公告

导航不是只给鼠标用户用。当前位置、层级、返回、离开阻止、跳转失败、权限失效和恢复成功都必须可感知，且不能由多个 owner 重复播报同一完整消息。

| 规则 ID | 规则 |
| --- | --- |
| NAV-A11Y-01 | 导航区域、面包屑、Tabs、返回按钮、关闭容器和外部链接必须有可访问名称，并说明动作对象。 |
| NAV-A11Y-02 | 当前页面、当前面包屑层级和当前 Tab 必须通过可见状态和语义状态表达；不能只靠颜色。 |
| NAV-A11Y-03 | 导航完成、返回完成、离开被阻止、跳转失败和权限失效必须由唯一 owner 公告，不得重复播报。 |
| NAV-A11Y-04 | `focusRestoreTarget` 必须在导航前声明；完成、取消、阻止、失败和兜底恢复后只能迁移一次焦点。 |
| NAV-A11Y-05 | route/unmount 后的迟到回调不得写回内容、URL、标题、面包屑、Tabs、全局反馈或焦点。 |

对应验收：NAV-A8、NAV-A9、NAV-A10。

## NAV-RSP 响应式与移动端

PC、平板和移动端的核心导航能力必须一致。移动端可以压缩导航、折叠菜单或用独立页承载编辑，但移动端不得删除返回、当前位置、未保存保护、权限说明或恢复路径。

| 规则 ID | 规则 |
| --- | --- |
| NAV-RSP-01 | 移动端不得删除返回、当前位置、未保存保护、权限说明或恢复路径。 |
| NAV-RSP-02 | 移动端隐藏侧边导航或面包屑时，必须提供可发现的当前位置、上级路径、菜单入口和返回/关闭路径。 |
| NAV-RSP-03 | 虚拟键盘、低高度、动态 viewport、四向 safe area、触控和 200% 缩放下，返回、确认离开、取消、保存后继续和错误恢复必须可达。 |
| NAV-RSP-04 | 移动端系统返回、WebView 返回、手势返回和浏览器 Back 必须进入同一离开保护管线；不得只处理页面内返回按钮。 |

对应验收：NAV-A9、NAV-A10。

## 生命周期和清理

route/unmount、权限跳转、容器关闭、来源失效、外链打开和失败恢复都必须记录 `disposalLog`。清理至少覆盖路由监听、未完成请求、计时器、焦点保护、滚动恢复、全局反馈绑定、上传/导入引用、临时草稿和 blocker 注册。清理是幂等的；重复触发不得恢复旧 owner。

## 可执行验收检查

下列检查以可观察状态、URL、DOM 属性、事件日志、导航日志、焦点轨迹和权限快照断言；未实际执行时必须报告为**未验证**及所需环境。

1. **状态模型与 owner 边界**：记录 `{routeOwnerId, currentLocation, sourceContext, returnPolicy, historyIntent, permissionVersion, dirtyBlockers, focusRestoreTarget, disposalLog}`。断言每个导航入口都有 owner，返回、关闭、面包屑、Tabs、浏览器 Back/Forward 和外链都创建可解释意图。
2. **返回与来源恢复**：从列表、筛选结果、报表钻取、搜索结果、通知和深链进入详情；触发返回列表、返回上级、关闭容器和保存后返回。断言返回不得直接等同于 `history.back()`，且按 `sourceContext` 和 `returnPolicy` 恢复安全来源、筛选、排序、分页/游标、滚动和焦点；来源无效时进入安全兜底。
3. **浏览器历史和 URL 一致性**：测试 push、replace、restore、redirect、external、refresh 和 Back/Forward。断言 URL、标题、内容、面包屑、Tabs、全局反馈和 `historyIntent` 一致；失败时保留可恢复说明。
4. **统一离开保护**：在表单脏状态、上传中、导入预检中、保存中、批量范围待确认和危险确认中，分别触发浏览器 Back/Forward、面包屑、Tabs、菜单导航、关闭容器和外部链接。断言所有入口都经过同一离开保护管线，`dirtyBlockers` 被读取，确认前不切路由。
5. **面包屑层级**：构造层级路径、无权上级、对象删除、最后一级当前位置和深链进入。断言面包屑表示层级路径，不表示最近历史；每一级有权限验证、可访问名称和安全失败路径。
6. **Tabs 任务边界**：构造同一资源 Tabs、跨模块页面、跨租户/工作区页面、无共享上下文页面和切换失败。断言 Tabs 只用于同一资源或同一任务上下文；切换策略明确保留或丢弃草稿、滚动、筛选、焦点和请求结果。
7. **权限和敏感信息收敛**：在进入、返回、恢复、面包屑跳转、Tab 切换、外链打开、登录过期和租户切换时改变权限版本。断言旧导航上下文、旧面包屑标签、旧记录名、旧返回目标、旧 URL 参数和旧焦点目标都重新证明安全；无权状态不泄露对象信息。
8. **route/unmount 与迟到回调**：在路由监听、权限复核、远程标题、面包屑数据、筛选恢复、滚动恢复和保存后跳转待处理时触发 route/unmount。断言 `disposalLog` 完整，route/unmount 后的迟到回调不得写回内容、URL、标题、面包屑、Tabs、全局反馈或焦点。
9. **焦点和可访问性**：检查导航区域名称、面包屑语义、Tabs 语义、当前状态、返回/关闭/外链动作对象、阻止离开确认、跳转失败公告和权限失效公告。断言 `focusRestoreTarget` 在完成、取消、阻止、失败和兜底恢复后只迁移一次焦点。
10. **移动端和运行时报告**：在移动窄屏、折叠菜单、独立编辑页、200% 缩放、字体放大、低高度、动态 viewport、虚拟键盘、四向 safe area、触摸、系统返回、WebView 返回和浏览器 Back 下，断言移动端不得删除返回、当前位置、未保存保护、权限说明或恢复路径。上述浏览器、屏幕阅读器、触控设备、真实组件和真实视口检查未实际执行时，报告必须逐项标为**未验证**，并写明所需浏览器、设备/viewport、输入方式及辅助技术环境。
