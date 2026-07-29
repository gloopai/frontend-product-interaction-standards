# 页面内容区与 Section 布局交互规范

适用于页面内容区、页面正文、主内容区、内容布局、Section、区块、卡片区块、内容卡片、布局容器、分栏布局、栅格布局、主滚动、嵌套滚动、吸顶、sticky、fixed、固定栏、内容密度、页面留白、安全区域、移动端单列、页面分组、page content、main content、content layout、content section、section layout、card section、layout grid、responsive layout、main scroll、nested scroll、sticky section、content density 和 mobile single column。

本文件是页面正文内容布局 owner。它负责页面主内容区域、Section/Card 注册、分栏与密度策略、主滚动边界、sticky/fixed 避让、状态承载转交、权限无泄露、移动端重排和生命周期清理。Page Header、页面标题区和标题区主操作读取 `references/page-header-title-area.md`；页面操作栏、列表工具栏和 Section 工具栏读取 `references/page-toolbars-actions.md`；表格结果读取 `references/data-tables.md`；表单和字段错误读取 `references/forms.md`；信息卡、详情字段和只读展示读取 `references/information-display.md`；loading、empty、error、stale、permission 和 recovery 读取 `references/feedback-states.md`；跨端断点、安全区域和触摸输入读取 `references/responsive-adaptive.md`；管理台跨页面治理读取 `references/admin-console.md`。

页面正文中的表单布局、字段分组、表单 Section/Card、两列/三列字段排列、字段对齐、底部操作栏避让和移动端表单单列必须同时执行 `references/form-layout-field-groups.md`，并声明 `formLayoutState`。页面内容 owner 负责页面 Section、主滚动和整体布局；表单布局 owner 负责字段注册、组注册、字段顺序、跨列、错误定位和表单内部响应式排列。

页面级、Section 级、Dashboard 模块级和 TabPanel 内的空态、无结果、首次使用、未配置空态和 empty CTA 必须同时执行 `references/empty-first-run-zero-results.md`。页面内容 owner 负责空态所在区域、主滚动、Section 注册和布局；空态 owner 负责 `emptyStateDecision`、原因、CTA、恢复和权限边界。

## 范围与边界

页面内容区不是随意堆卡片，也不是 CSS 网格细节。它是用户完成主要任务的正文 owner，用来回答“当前页面主体有哪些区域、先看什么、哪个区域负责什么、滚动在哪里发生、固定元素会不会遮挡、移动端如何保留同等能力”。

本 owner 不覆盖标题文案、按钮语义、表格列、字段校验、图表编码、只读字段口径、Dialog/Drawer 内部滚动、具体 CSS token、组件库或业务命名词库。它只定义页面正文如何绑定当前页面、如何组织 Section/Card、如何转交业务 owner、如何控制主滚动和响应式重排。

## `pageContentLayoutState`

每个列表页、详情页、设置页、报表页、概览页、审批页、任务页、配置页或管理台主工作页面必须声明 `pageContentLayoutState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `contentOwnerId` | 当前页面内容区 owner 的稳定身份。 |
| `contentSurface` | `list-page`、`detail-page`、`settings-page`、`report-page`、`dashboard-page`、`approval-page`、`task-page`、`config-page` 或产品声明的页面类型。 |
| `pageBinding` | 当前页面 owner、URL、Page Header、工具栏、租户/工作区、权限版本、对象/集合身份和主内容区域。 |
| `sectionRegistry` | 页面内 Section、Card、分栏、列表区、表单区、图表区、信息区、反馈区和辅助区的稳定注册表。 |
| `layoutGridPolicy` | 单列、多列、主从、卡片网格、信息分组、响应式断点、最小宽度、排序和重排策略。 |
| `scrollBoundary` | 主滚动 owner、局部滚动例外、滚动阴影、滚动恢复、焦点滚入和嵌套滚动限制。 |
| `stickyBoundary` | 固定页头、sticky 工具栏、底部操作、分页、Tabs、App Shell、Dialog/Drawer 和安全区域的遮挡避让。 |
| `densityPolicy` | 默认密度、紧凑/宽松切换、内容优先级、可读行长、卡片间距和移动端触摸目标。 |
| `contentPriority` | 首屏核心 Section、次要 Section、辅助说明、低频配置、折叠优先级和错误/权限优先级。 |
| `emptyLoadingErrorBinding` | 页面级或 Section 级 loading、empty、zero-results、error、stale、partial、permission 和 recovery 的转交关系。 |
| `ownerHandoff` | 每个 Section/Card 内部表格、表单、图表、信息展示、反馈状态、Toolbar、按钮、风险操作和导出 owner 的明确转交。 |
| `permissionBoundary` | Section 可见、只读、隐藏、禁用、权限原因、旧内容清理、敏感字段和无权限安全占位。 |
| `responsivePolicy` | 移动端单列、Section 分组/折叠、底部操作避让、虚拟键盘、安全区域、横屏和 200% 缩放策略。 |
| `focusAnnouncementPolicy` | 页面主内容进入、Section 加载/失败/隐藏、断点转换、滚动恢复和 sticky 遮挡后的焦点与公告。 |
| `lifecycleDisposal` | route/unmount、权限变化、租户切换、断点转换、Section 卸载、旧滚动位置、旧 sticky 偏移和旧 ARIA 引用清理。 |
| `runtimeVerification` | 真实浏览器、键盘、读屏、触摸、权限变化、断点切换、移动端、主滚动、嵌套滚动和 sticky/fixed 避让验证状态；未执行必须标为未验证。 |

不得只用 `children`、`cards`、`sections`、`gridTemplate`、`columns`、`containerClassName`、`layout="grid"`、组件库 Layout 配置或页面 CSS 替代 `pageContentLayoutState`。

## 页面绑定和 Section 注册

页面正文必须绑定当前页面 owner、标题区、工具栏、权限版本和主内容区域。标题、工具栏、正文、反馈状态和当前导航之间不允许各自读取不同的旧快照。

每个 Section、Card、分栏、列表区、表单区、图表区和信息区必须有明确 ownerHandoff；如果无法说明内部能力由哪个 owner 接管，该区域不得作为可交互内容上线。

| 规则 ID | 规则 |
| --- | --- |
| `PCL-SCOPE-01` | 每个页面正文必须声明自己受哪个页面 owner 控制，并和 Page Header、页面工具栏、App Shell 当前项及主内容 landmark 保持可解释关系。 |
| `PCL-SCOPE-02` | 每个 Section、Card、分栏、列表区、表单区、图表区和信息区必须有稳定 id、名称、内容类型、权限边界、状态来源和 `ownerHandoff`。 |
| `PCL-SCOPE-03` | Section 不得只按接口返回顺序或视觉大小排序；顺序必须反映任务优先级、风险、状态和恢复路径。 |
| `PCL-SCOPE-04` | 页面正文不能把表格、表单、图表、详情、反馈、导出或危险操作的规则吞并成本地布局约定；必须转交对应 owner。 |

## 布局、密度和内容优先级

内容布局必须服务任务，不得为了“看起来丰富”堆装饰卡、重复摘要或空卡片。首屏优先显示页面任务所需的主要 Section、状态摘要、权限原因、关键错误和下一步。

| 规则 ID | 规则 |
| --- | --- |
| `PCL-LAYOUT-01` | 单列、多列、主从、卡片网格或左右分栏必须有内容依据；不得让关键路径依赖用户猜测右侧隐藏区、hover 卡片或不可见折叠。 |
| `PCL-LAYOUT-02` | 多列布局在窄屏重排时必须保持 Section 标题、字段 label/value、图表说明、表格操作和错误归属不串位。 |
| `PCL-LAYOUT-03` | 内容密度可以切换，但不得通过紧凑模式删除 label、单位、权限原因、错误说明、恢复入口、主操作或焦点可见性。 |
| `PCL-LAYOUT-04` | 低频 Section 可以折叠或收纳，但折叠标题必须暴露错误、权限、未保存、部分结果、stale 和恢复入口摘要。 |
| `PCL-LAYOUT-05` | 空卡片、纯装饰卡片、营销式 hero 或无状态占位不得承载管理台主要工作区。 |

## 主滚动、嵌套滚动和 sticky/fixed 避让

主滚动只能有一个可解释 owner；不得让页面、卡片、表格、Drawer 和 Dialog 形成无声明的嵌套滚动。局部滚动只允许用于明确的数据结构或固定高度区域，并必须说明键盘、触摸、焦点滚入和阴影提示。

| 规则 ID | 规则 |
| --- | --- |
| `PCL-SCROLL-01` | 页面正文必须声明主滚动容器；App Shell、Page Header、Toolbar、Tab、分页、底部操作和内容区的滚动关系必须可解释。 |
| `PCL-SCROLL-02` | 局部滚动区域必须有可见边界、滚动提示、键盘可达路径和焦点滚入策略；不得让用户困在卡片内滚动。 |
| `PCL-SCROLL-03` | Sticky、fixed、吸顶、底部操作、分页、工具栏、标题区和安全区域不得遮挡当前焦点、错误、状态摘要、主操作或恢复路径。 |
| `PCL-SCROLL-04` | 断点转换、字体放大、200% 缩放、虚拟键盘、动态视口或安全区域变化后，sticky 偏移、滚动恢复和焦点滚入必须重算。 |
| `PCL-SCROLL-05` | 不得通过把整个页面和每张卡片都设为可滚动来解决高度问题；冲突时应重新分配主滚动或改为更合适承载面。 |

## 状态、权限和 owner 转交

页面内容区只负责 Section 状态承载和转交，不重新定义业务状态本身。每个可加载、失败、为空、权限受限或部分结果的 Section 必须声明反馈 owner。

| 规则 ID | 规则 |
| --- | --- |
| `PCL-STATE-01` | Section 的 loading、empty、zero-results、error、stale、partial、permission 和 recovery 必须转交 `feedback-states.md` 或对应业务 owner。 |
| `PCL-STATE-02` | 页面级状态和 Section 级状态必须有优先级；关键 Section 失败或无权限时不得把全页伪装成正常。 |
| `PCL-PERM-01` | 权限待解析或权限降级时，不得先渲染旧 Section、旧卡片、旧数量、旧字段、旧操作、旧图表摘要或旧 ARIA 名称。 |
| `PCL-PERM-02` | 隐藏、只读、禁用、未启用和无权限 Section 必须区分；不得只把区域 display none 且不提供原因或恢复路径。 |
| `PCL-HANDOFF-01` | Section 内的新增、编辑、危险操作、导出、复制、刷新、表格选择、表单提交和图表钻取必须绑定各自 owner 的当前快照。 |

## 移动端与响应式

移动端可以重排、折叠、分组或转为单列，但不得删除页面标题、核心 Section、状态说明、权限原因、主操作、错误恢复和返回路径。

| 规则 ID | 规则 |
| --- | --- |
| `PCL-RSP-01` | 多列和卡片网格转单列时，Section 顺序、标题、状态、权限原因、主操作和恢复路径必须保持可发现。 |
| `PCL-RSP-02` | 移动端底部操作、分页、虚拟键盘、浏览器工具栏和 safe-area 不得遮挡当前 Section 的焦点、错误或提交入口。 |
| `PCL-RSP-03` | 宽内容可转换为卡片、详情展开、分组或受控横向滚动；不得无入口地删除字段、列、图例、操作或恢复路径。 |
| `PCL-RSP-04` | 断点转换保持同一 `contentOwnerId`、`sectionRegistry`、`ownerHandoff`、错误状态和滚动身份；不得重建页面导致草稿、选择、展开、焦点或在途请求丢失。 |

## 生命周期和清理

权限降级、租户/工作区切换、断点转换、Section 隐藏、数据刷新、路由变化或 owner 卸载后，旧 Section、旧卡片、旧滚动位置、旧 sticky 偏移、旧 ARIA 区域、旧焦点目标和旧占位必须失效或重算。

| 规则 ID | 规则 |
| --- | --- |
| `PCL-LIFE-01` | route/unmount 后的 Section 加载、布局测量、滚动恢复、sticky 偏移、权限回调和焦点回调不得写回新页面。 |
| `PCL-LIFE-02` | Section 卸载只清理自己的订阅、滚动监听、测量任务、ARIA 引用和焦点回调，不得释放仍存活 Section 的资源。 |
| `PCL-LIFE-03` | 内容区恢复滚动位置前必须确认页面 owner、URL、权限版本、断点、Section 注册表和内容高度仍匹配。 |
| `PCL-A11Y-01` | 页面主内容必须有可感知 landmark；Section、Card、错误区和操作组必须有可访问名称。 |
| `PCL-A11Y-02` | Section 顺序、焦点顺序和读屏顺序必须与视觉任务流一致；重排后不得只改变视觉位置而不更新语义关系。 |

## 完成前检查

1. 是否声明 `pageContentLayoutState` 及全部字段。
2. 页面正文是否绑定当前页面 owner、标题区、工具栏、权限版本和主内容区域。
3. 每个 Section、Card、分栏、列表区、表单区、图表区和信息区是否有稳定 id、状态来源、权限边界和 `ownerHandoff`。
4. 主滚动是否只有一个可解释 owner；局部滚动是否有边界、提示、键盘路径和焦点滚入策略。
5. Sticky、fixed、吸顶、底部操作、分页、工具栏、标题区和安全区域是否不会遮挡当前焦点、错误、状态摘要、主操作或恢复路径。
6. loading、empty、error、stale、permission、partial 和 recovery 是否转交对应反馈或业务 owner，且不会把关键 Section 失败伪装成全页正常。
7. 权限降级、租户/工作区切换、断点转换、Section 隐藏、数据刷新、路由变化或 owner 卸载后，旧 Section、旧卡片、旧滚动位置、旧 sticky 偏移、旧 ARIA 区域、旧焦点目标和旧占位是否失效或重算。
8. 移动端是否保留页面标题、核心 Section、状态说明、权限原因、主操作、错误恢复和返回路径。
9. 真实浏览器、键盘、读屏、触摸、权限变化、断点切换、移动端、主滚动、嵌套滚动和 sticky/fixed 避让未实际执行时，是否明确标为未验证并列出所需验证。
