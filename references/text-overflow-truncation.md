# 文本溢出与截断交互规范

适用于文本溢出、文本截断、省略号、截断、折行、换行、自动换行、多行截断、单行截断、查看全文、展开全文、收起全文、复制全文、长文本、长标题、长字段、长状态、长错误、长按钮文案、代码换行、JSON 展示、URL 换行、文件名截断、路径截断、text overflow、text truncation、ellipsis、truncate、line clamp、line-clamp、wrap text、word break、show more、read more、full text、long text、long title、long label、long error 和 copy full text。

本文件是文本溢出、截断、省略号与全文恢复路径的 owner。它负责内容身份、展示策略、截断策略、全文访问、复制全文、Tooltip/Popover 边界、换行测量、权限安全、断点转换和生命周期清理。详情字段和值语义读取 `references/information-display.md`；字段 label、帮助文本、placeholder 和错误说明读取 `references/field-guidance-help-text.md`；Tooltip、Popover、Dropdown 和移动端浮层触发/定位/关闭读取 `references/overlays-menus-tooltips.md`；表格单元格和列宽读取 `references/data-tables.md`；表格列宽、列显隐、固定列、密度、横向滚动、列标题截断和单元格截断必须同时执行 `references/table-column-layout-density.md`，文本溢出 owner 负责截断和全文恢复，列布局 owner 负责 `tableColumnLayoutState`、widthPolicy、pinningPolicy、densityPolicy、列宽边界和固定列遮挡防护；卡片标题、字段区和操作区读取 `references/card-list-results.md`；按钮语义与操作层级读取 `references/buttons.md`；错误、空态和恢复反馈读取 `references/feedback-states.md`；移动端、缩放、字体放大和安全区域读取 `references/responsive-adaptive.md`。

文本截断不是内容删除，也不是 hover tooltip 的同义词。截断只是一种空间受限时的展示策略；只要内容仍影响用户判断、操作、审计或恢复，就必须提供可发现、可访问、可复制或可展开的完整内容路径。

## `textOverflowState`

每个会主动折行、截断、line clamp、显示省略号、隐藏溢出、提供查看全文或复制全文的区域必须声明 `textOverflowState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `textOwnerId` | 当前文本展示 owner 的稳定身份。 |
| `textSurface` | `table-cell`、`card-field`、`detail-field`、`button-label`、`status-copy`、`error-message`、`code-block`、`popover-content`、`dialog-content`、`drawer-content` 或产品声明的承载面。 |
| `sourceBinding` | 文本来源、数据快照、字段路径、权限版本、语言版本和格式化版本。 |
| `contentIdentity` | 内容对象、字段名、业务含义、敏感等级、是否关键、是否可被用户完整读取。 |
| `displayPolicy` | 单行、多行、折行、保留空白、等宽展示、代码块、摘要、分段展示或专用查看器策略。 |
| `truncationPolicy` | 是否允许截断、截断行数、最小可见信息、截断位置、不可截断片段和测量依据。 |
| `fullTextAccessPolicy` | 查看全文、展开全文、收起全文、详情页、Drawer、Dialog、专用预览或不需要恢复路径的声明。 |
| `copyPolicy` | 复制可见文本、复制全文、复制脱敏值、复制真实值、复制失败、复制权限复核和复制回执策略。 |
| `tooltipPopoverBoundary` | Tooltip/Popover 是否允许辅助展示全文、触发方式、移动端替代、键盘/focus 路径和不可作为唯一来源的边界。 |
| `lineWrapPolicy` | 中文、英文长词、URL、邮箱、文件名、路径、代码、JSON、数字串、i18n 和 200% 缩放下的换行策略。 |
| `measurementPolicy` | 容器宽高、字体加载、系统字号、语言切换、断点、虚拟键盘、内容刷新和 Resize 后的重算策略。 |
| `permissionBoundary` | 权限待解析、权限降级、脱敏、隐藏、只读、复制权限、全文权限和 DOM/ARIA/request/log 无泄露边界。 |
| `responsivePolicy` | 移动端、低高度、窄屏、触摸、无 hover、横竖屏、安全区域和底部操作区遮挡下的等价查看全文路径。 |
| `focusAnnouncementPolicy` | 展开、收起、打开全文、复制结果、截断状态变化和错误恢复的焦点与公告策略。 |
| `lifecycleDisposal` | route/unmount、权限变化、语言切换、断点转换、数据刷新、字体加载、测量任务和旧浮层/旧复制值清理。 |
| `runtimeVerification` | 真实浏览器、移动端、键盘、读屏、触摸、字体放大、缩放、语言切换、权限变化和真实数据测量验证状态；未执行必须标为未验证。 |

不得只用 `ellipsis`、`truncate`、`line-clamp`、`max-width`、`overflow: hidden`、`title` 属性、CSS class、组件默认 Tooltip 或设计稿标注替代 `textOverflowState`。

## 禁止项和 owner 边界

省略号、line clamp、max-width、title 属性或 Tooltip 不得作为查看完整内容的唯一方式。鼠标 hover 不是移动端、键盘和读屏用户的通用能力。

| 规则 ID | 规则 |
| --- | --- |
| `TOT-SCOPE-01` | 被截断内容必须声明 `fullTextAccessPolicy`；重要身份、状态、错误、金额、权限原因、主操作文案和恢复路径不得只显示省略号。 |
| `TOT-SCOPE-02` | 只有装饰性或已由同屏等价文本完整表达的内容可以无恢复路径截断，并必须在 `contentIdentity` 中声明。 |
| `TOT-SCOPE-03` | Tooltip/Popover 可以辅助展示全文，但不能替代展开、复制、详情、Drawer/Dialog 或移动端等价路径。 |
| `TOT-SCOPE-04` | 截断策略不得改变业务含义；不得把关键前缀、后缀、状态、单位、币种、版本、错误原因或风险等级截掉后仍允许用户确认。 |

## 不同内容类型

不同文本不能共用一个“统一省略号”策略。每类内容必须说明最小可见信息和完整恢复路径。

| 规则 ID | 内容类型 | 要求 |
| --- | --- | --- |
| `TOT-TYPE-01` | 长标题/对象名 | 必须保留可识别身份；同名对象需显示额外 disambiguator，不能只靠 hover 区分。 |
| `TOT-TYPE-02` | 状态/标签/错误 | 状态和错误必须有可见文本；截断后仍要保留严重度、动作建议和恢复入口。 |
| `TOT-TYPE-03` | 长 ID/代码/JSON/URL/邮箱/文件名/路径 | 长 ID、代码、JSON、URL、邮箱、文件名、路径、错误详情和审计字段必须提供换行、展开、复制或专用查看方式。 |
| `TOT-TYPE-04` | 金额/数量/单位/时间 | 不得截断会改变读数的数字、单位、币种、时区、正负号、小数位或范围端点。 |
| `TOT-TYPE-05` | 按钮文案 | 主操作、危险操作和提交按钮不得只剩动词或图标；窄屏收纳后仍要保留动作对象和可访问名称。 |
| `TOT-TYPE-06` | 用户生成内容 | 摘要可以截断，但必须防止 HTML/Markdown 注入、权限泄露和复制到旧全文。 |

## 查看全文、展开和复制

被截断内容的恢复路径必须与内容重要性匹配。低风险短文本可在原地展开；中等长度可用 Popover/Drawer；结构化内容、代码、错误详情、审计内容或敏感内容应使用专用查看器、详情区或独立页。

| 规则 ID | 规则 |
| --- | --- |
| `TOT-FULL-01` | “查看全文/展开全文”必须是可聚焦控件，有明确对象名称；展开后焦点和读屏上下文不得丢失。 |
| `TOT-FULL-02` | 展开状态必须可收起或有清晰返回路径；展开不得遮挡同一区域主操作、错误或保存栏。 |
| `TOT-FULL-03` | 复制全文必须复制当前权限和当前快照允许的内容，不得复制旧全文、隐藏敏感字段或用户不可见字段。 |
| `TOT-FULL-04` | 复制成功、复制失败、权限不足和剪贴板不可用必须有就近或全局回执；Toast 不能作为敏感复制失败的唯一恢复。 |
| `TOT-FULL-05` | 详情页、Drawer 或 Dialog 查看全文时，来源对象、字段名、更新时间、权限状态和关闭返回必须明确。 |

## 移动端与响应式

移动端不得依赖 hover、title 属性或精确指针查看全文。窄屏、低高度、系统字体放大、200% 缩放、虚拟键盘和安全区域下，核心信息、恢复入口、复制入口和关闭入口必须可达。

| 规则 ID | 规则 |
| --- | --- |
| `TOT-RSP-01` | 移动端长文本优先使用折行、展开、Bottom Sheet/Drawer 或详情页；Tooltip-only 全文展示失败。 |
| `TOT-RSP-02` | 断点转换不得丢失展开状态、焦点目标、当前内容快照或复制权限；无法安全保持时必须关闭并重新进入。 |
| `TOT-RSP-03` | 底部操作栏、虚拟键盘、浏览器工具栏和 safe-area 不得遮挡查看全文、收起、复制、错误和关闭。 |
| `TOT-RSP-04` | 200% 缩放和系统字体放大下，不得为了保持布局而删除关键字段、状态、错误或操作对象。 |

## 权限、安全和生命周期

权限降级、语言切换、数据刷新、断点转换、字体放大或 owner 卸载后，旧全文、旧 title、旧 tooltip、旧复制值、旧 aria-label、旧测量结果和旧展开状态必须失效或重算。

| 规则 ID | 规则 |
| --- | --- |
| `TOT-PERM-01` | 可见摘要、可查看全文、可复制全文和可查看真实值是不同权限，不得互相推导。 |
| `TOT-PERM-02` | 权限待解析时不得先渲染旧全文、旧 title、旧 Tooltip 内容、旧复制按钮或旧 ARIA label。 |
| `TOT-LIFE-01` | 文本刷新、语言切换、字体加载、容器 Resize、断点变化和虚拟键盘变化后必须重算截断状态与全文入口。 |
| `TOT-LIFE-02` | disposal 必须释放 Resize/Intersection 监听、测量任务、浮层引用、复制回调、公告回调和焦点任务，且只释放本 owner 持有资源。 |
| `TOT-A11Y-01` | 截断状态、查看全文、展开/收起和复制全文必须有可访问名称；不得只靠视觉省略号表达可操作性。 |
| `TOT-A11Y-02` | `aria-label` 不得偷偷包含用户无权查看的全文；读屏可获取的信息必须与视觉权限边界一致。 |

## 完成前检查

1. 是否声明 `textOverflowState` 及全部字段。
2. 是否证明文本截断不是内容删除，也不是 hover tooltip 的同义词。
3. 是否禁止省略号、line clamp、max-width、title 属性或 Tooltip 作为查看完整内容的唯一方式。
4. 被截断内容是否声明 `fullTextAccessPolicy`；重要身份、状态、错误、金额、权限原因、主操作文案和恢复路径是否没有只显示省略号。
5. 长 ID、代码、JSON、URL、邮箱、文件名、路径、错误详情和审计字段是否提供换行、展开、复制或专用查看方式。
6. 移动端是否不依赖 hover、title 属性或精确指针查看全文。
7. 权限降级、语言切换、数据刷新、断点转换、字体放大或 owner 卸载后，旧全文、旧 title、旧 tooltip、旧复制值、旧 aria-label、旧测量结果和旧展开状态是否失效或重算。
8. 真实浏览器、移动端、键盘、读屏、触摸、字体放大、缩放、语言切换、权限变化和真实数据测量未实际执行时，是否明确标为未验证并列出所需验证。
