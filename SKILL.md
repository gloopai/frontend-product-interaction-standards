---
name: frontend-product-interaction-standards
description: 用于创建、修改、重构、评审或测试前端页面、组件、布局、弹窗、表单及交互行为时；凡是前端产品交互任务都应自动加载。
---

# 前端产品交互规范

## 核心原则

把本 Skill 中与任务相关的规则视为硬性验收条件。框架限制、组件库默认行为、现有代码和交付压力都不能降低标准。只有用户针对明确范围作出的直接授权才构成例外。

## 执行流程

1. 判断任务涉及哪些交互类别。
2. 修改或评审前读取对应参考文件。
3. 实现前检查方案，实现后检查代码并验证相关交互和视口。
4. 第三方组件冲突时，优先配置、封装或替换。
5. 最终回复列明已验证的相关规则；无法验证时明确说明。

## 规范路由

- 涉及 Dialog、Modal、弹窗或对话框时，必须完整读取 `references/dialogs.md`。
- 涉及 Drawer、Sheet、抽屉、侧滑面板或上下滑出面板时，必须完整读取 `references/drawers.md`。
- 涉及 Select、Combobox、下拉选择、可搜索选择器、Autocomplete、Dropdown Select、Searchable Select、单选选择器，或 select、combobox、dropdown、autocomplete、searchable select、single-select 时，必须完整读取 `references/selects-comboboxes.md`。
- 涉及 Checkbox、Checkbox Group、Radio、Radio Group、Switch、Toggle、Toggle Group、Segmented Control、三态 checkbox、复选框、复选组、多选、单选组、单选按钮、开关、切换、分段控件、选择控件、布尔设置、偏好开关，或 checkbox、checkbox group、radio、radio group、switch、toggle、toggle group、segmented control、tri-state checkbox、boolean setting、preference toggle 时，必须完整读取 `references/selection-controls.md`。
- 涉及 Tree、Tree View、Tree Select、Tree Grid、Cascader、树形结构、树形选择、级联选择、层级选择、组织树、部门树、权限树、菜单树、分类树、资源目录树、地区级联、父子级联、半选、懒加载节点、树节点搜索，或 tree、tree view、tree select、tree grid、cascader、hierarchy、hierarchical select、cascade select、organization tree、permission tree、menu tree、category tree、lazy tree、half checked 时，必须完整读取 `references/tree-hierarchy.md`。
- 涉及表单、字段、校验、必填/选填、错误摘要、提交、脏状态/已修改状态、已触碰状态、dirty/touched、未保存更改或错误恢复，或 form、field、validation、required/optional、error summary、submit、dirty/touched、unsaved changes、error recovery 时，必须完整读取 `references/forms.md`。
- 涉及表格、数据表格、报表、列、固定列、筛选、排序、分页、游标分页、行选择、全选、批量操作或部分成功，或 table、data table、report、column、pinned column、filter、sort、pagination、cursor pagination、row selection、select all、bulk action、partial success 时，必须完整读取 `references/data-tables.md`。
- 涉及查询条件、筛选、过滤、搜索、关键词搜索、高级筛选、更多筛选、筛选条件、查询条件区、筛选区、重置筛选、清空筛选、已应用条件、筛选标签、URL 筛选，或 query filter、filters、filter bar、search filter、keyword search、advanced filters、filter drawer、applied filters、filter chips、reset filters、clear filters、URL filters 时，必须完整读取 `references/query-filters.md`。
- 涉及全局搜索、全站搜索、站内搜索、命令面板、快捷命令、快速跳转、快捷搜索、搜索建议、搜索历史、最近搜索、保存搜索、搜索结果、结果分组、搜索预览、动作搜索、命令执行、自然语言搜索、AI 搜索，或 global search、site search、universal search、command palette、quick switcher、quick search、action search、search suggestions、recent searches、saved searches、search results、result groups、result preview、command execution、natural language search、AI search 时，必须完整读取 `references/search-command-palette.md`。
- 涉及日期、时间、日期范围、时间范围、日期时间、日期选择、时间选择、日期时间选择、时区、快捷时间、快捷日期、今天、昨天、本周、本月、近 7 天、近 30 天、开始时间、结束时间、过期时间、刷新时间、数据延迟、审计时间、导出时间范围，或 date、time、date range、time range、datetime、date picker、time picker、timezone、time zone、preset range、relative range、today、yesterday、this week、this month、last 7 days、last 30 days、start date、end date、expiry、refresh time、data latency、audit time、export range 时，必须完整读取 `references/date-time-ranges.md`。
- 涉及详情页、详情、对象详情、信息展示、描述列表、只读详情、只读字段、信息卡、概览卡、指标卡、摘要卡、元数据、基础信息、状态标签、状态徽标、字段展示、复制字段、脱敏展示、长文本展示、审计摘要、更新时间、创建人、操作人，或 detail page、details、object detail、information display、description list、key value list、readonly detail、read-only field、info card、summary card、metric card、metadata、basic information、status badge、status tag、field display、copy field、masked value、long text display、audit summary、updated at、created by、operator 时，必须完整读取 `references/information-display.md`。
- 涉及图表、可视化、报表图形、仪表盘图表、趋势图、折线图、柱状图、条形图、面积图、饼图、环图、散点图、气泡图、漏斗图、排行图、热力图、组合图、迷你趋势图、图例、坐标轴、数据标签、参考线、阈值线、图表 tooltip、图表钻取、图表联动、图表导出、查看明细，或 chart、visualization、data visualization、dashboard chart、report chart、line chart、bar chart、column chart、area chart、pie chart、donut chart、scatter plot、bubble chart、funnel chart、ranking chart、heatmap、combo chart、sparkline、legend、axis、data label、reference line、threshold line、chart tooltip、chart drilldown、chart interaction、chart export、view details 时，必须完整读取 `references/charts-visualization.md`。
- 涉及 export、download、artifact、result artifact、file delivery、download link、download URL、CSV、Excel、PDF、image export、report export、chart export、audit export、error report、error detail、expiry、expires、导出、下载、结果产物、文件领取、下载链接、下载地址、文件有效期、过期文件、重新生成、错误明细、报表导出、图表导出、审计导出、CSV、Excel、PDF、图片导出 时，必须完整读取 `references/exports-downloads-artifacts.md`。
- 涉及 page toolbar、action bar、list toolbar、result toolbar、bulk toolbar、view tools、refresh action、create action、column settings、density、view switcher、页面操作栏、列表工具栏、结果工具栏、批量操作栏、视图工具、刷新操作、新增操作、列设置、密度、视图切换 时，必须完整读取 `references/page-toolbars-actions.md`。
- 涉及 settings、preferences、configuration、config page、setting page、preference page、feature setting、notification setting、integration setting、default setting、save settings、reset defaults、inherit defaults、设置、偏好、配置页、设置页、偏好页、配置项、策略配置、通知设置、集成设置、默认设置、保存设置、重置默认、继承默认 时，必须完整读取 `references/settings-preferences-configuration.md`。
- 涉及分步流程、配置向导、创建向导、导入向导、发布流程、分步表单、步骤条、步骤器、上一步、下一步、跳过步骤、保存草稿、恢复草稿、复核页、确认页、预览步骤、完成页、流程结果、多步骤提交、跨步校验、步骤错误，或 wizard、stepper、multi-step form、multi step form、multi-step flow、setup wizard、create wizard、import wizard、publish flow、previous step、next step、skip step、save draft、resume draft、review step、confirmation step、preview step、finish step、flow result、cross-step validation、step error 时，必须完整读取 `references/wizards-steppers.md`。
- 涉及导航、返回、面包屑、路径导航、浏览器返回、路由、路由切换、离开页面、未保存离开、返回列表、详情返回、Tabs、标签页、侧边导航、顶部导航、外部链接，或 navigation、back、breadcrumb、browser back、route change、routing、leave page、unsaved leave、return to list、detail back、tabs、side navigation、top navigation、external link 时，必须完整读取 `references/navigation-routing.md`。
- 涉及登录、登出、退出登录、会话、会话过期、登录过期、认证、认证失败、重新认证、二次认证、多因素认证、MFA、2FA、SSO、单点登录、账号切换、身份切换、授权回调、认证回调，或 login、logout、sign in、sign out、session、session expired、token expired、authentication、auth failure、reauth、reauthentication、MFA、2FA、SSO、account switch、identity switch、auth callback、authorization callback 时，必须完整读取 `references/auth-session-reauth.md`。
- 涉及新增记录、编辑记录、新建记录、复制创建、列表内编辑、表格内编辑、行内编辑、内嵌表单、常驻可编辑列表、单元格编辑、行内保存、记录配置、批量配置编辑、记录编辑承载面、编辑承载面，或 create record、edit record、record editor、inline edit、inline create、inline form、row edit、cell edit、embedded form、editing surface、row save、editable grid 时，必须完整读取 `references/record-editing-surfaces.md`。
- 涉及按钮、主按钮、次按钮、图标按钮、保存按钮、提交按钮、取消按钮、确认按钮、删除按钮、导出按钮、批量按钮、行操作按钮、危险按钮、禁用按钮、loading 按钮、按钮组、工具栏按钮，或 button、primary button、secondary button、icon button、submit button、save button、cancel button、confirm button、delete button、export button、bulk action button、row action button、danger button、disabled button、loading button、button group、toolbar action 时，必须完整读取 `references/buttons.md`。
- 涉及 Tooltip、Popover、Dropdown、Dropdown Menu、Menu、Context Menu、更多菜单、操作菜单、悬浮说明、Hover 帮助、非模态浮层、Action Sheet、移动端菜单 Drawer，或 tooltip、popover、dropdown、dropdown menu、menu、context menu、more actions、action menu、hover help、floating layer、non-modal overlay、action sheet、mobile menu drawer 时，必须完整读取 `references/overlays-menus-tooltips.md`。
- 涉及危险操作、风险操作、二次确认、强确认、输入确认、删除、停用、启用、禁用、归档、清空、重置、重置密钥、撤销、恢复、取消任务、重跑、批量删除、批量停用、权限变更、敏感导出、不可逆操作、未知结果、部分成功、审计回执，或 danger action、risk action、destructive action、confirm、double confirm、typed confirm、delete、disable、enable、archive、clear、reset、reset key、undo、recover、cancel job、rerun、bulk delete、permission change、sensitive export、irreversible、unknown result、partial success、audit receipt 时，必须完整读取 `references/risk-actions.md`。
- 涉及 status lifecycle、status transition、record lifecycle、state machine、publish、unpublish、approve、reject、enable、disable、activate、deactivate、archive、restore、freeze、unfreeze、lock、unlock、draft、published、状态流转、生命周期、记录生命周期、状态机、发布、下线、审批、审核、驳回、启用、停用、激活、归档、恢复、冻结、解冻、锁定、解锁、草稿、已发布 时，必须完整读取 `references/status-lifecycle-transitions.md`。
- 涉及 permission、permissions、role、RBAC、ABAC、tenant、workspace、权限、角色、权限矩阵、能力开关、租户、工作区、权限降级、权限升级、权限版本、无权限、只读、隐藏入口、禁用原因、申请权限、可见性、权限泄露、旧缓存、旧菜单、旧下载链接，或 permission denied、read only、read-only、hidden by permission、disabled by permission、permission version、capability matrix、feature flag、visibility、access control、stale permission、permission leakage 时，必须完整读取 `references/permissions-tenancy-visibility.md`。
- 涉及 async job、background task、job center、task center、异步任务、后台任务、任务中心、任务详情、任务进度、任务取消、取消中、重跑任务、任务重试、导入任务、导出任务、批量任务、报表生成、AI 生成、同步任务、结果领取、错误明细、未知结果、过期任务，或 job detail、job progress、cancel job、cancelling、rerun job、retry job、import job、export job、bulk job、report generation、AI generation、sync job、result artifact、error report、unknown result、expired job 时，必须完整读取 `references/async-jobs-task-center.md`。
- 涉及 audit log、activity log、operation history、event log、change history、audit detail、audit export、audit receipt、traceability、operation record、login log、access log、timeline、审计日志、操作历史、活动记录、事件日志、变更记录、审计详情、审计导出、审计回执、追溯链路、操作记录、登录日志、访问日志、时间线 时，必须完整读取 `references/audit-log-activity-history.md`。
- 涉及上传、文件上传、附件、拖拽上传、导入、批量导入、模板下载、导入预检、字段映射、错误明细、上传进度、取消上传、重试上传，或 upload、file upload、attachment、drag upload、dropzone、import、bulk import、template download、preflight import、field mapping、error report、upload progress、cancel upload、retry upload 时，必须完整读取 `references/uploads-imports.md`。
- 涉及空状态、空态、暂无数据、无结果、筛选无结果、加载、加载中、骨架屏、placeholder、错误状态、刷新失败、加载失败、重试、过期数据、部分结果、无权限状态、只读状态，或 empty state、zero results、no data、loading state、skeleton、placeholder、error state、refresh error、load error、retry state、stale data、partial result、permission denied state、read-only state 时，必须完整读取 `references/feedback-states.md`。
- 涉及 Toast、提示、全局提示、消息提示、通知、Notification、Alert、Banner、Snackbar、操作回执、结果回执、成功提示、错误提示、警告提示，或 toast、snackbar、message、notification、alert、banner、global feedback、operation receipt、result receipt、success message、error message、warning message 时，必须完整读取 `references/global-feedback.md`。
- 涉及响应式、移动端、手机、PC、桌面端、平板、断点、视口、横竖屏、窄屏、触摸、虚拟键盘、安全区域、缩放或跨端适配，或涉及 responsive、adaptive、desktop、mobile、tablet、breakpoint、viewport、orientation、portrait、landscape、touch、virtual keyboard、safe area、zoom 时，必须完整读取 `references/responsive-adaptive.md`。
- 涉及后台、管理台、控制台、运营后台、内部工具、SaaS console、RBAC、权限降级、租户/工作区切换、危险操作、审计日志、导入、导出、异步任务、任务中心、报表仪表盘或全局反馈，或 admin、console、dashboard、RBAC、tenant、workspace、audit log、import、export、async job、job center 时，必须完整读取 `references/admin-console.md`。
- 用户增加新类别规范时，创建职责单一的 `references/<category>.md`，并在此增加路由。

## 与项目规则的关系

- 兼容规则全部执行。
- 一方更严格且不冲突时，执行更严格的规则。
- 规则冲突时停止受影响的实现并请用户裁决，不能自行采用宽松版本。

## 红线

- 不得因为“组件默认如此”而保留违规行为。
- 不得因为“只要求检查其他内容”而忽略当前改动涉及的交互违规。
- 不得把未执行的验证写成已经通过。
- 不得在给出实现建议、评审结论或受限环境反馈时省略验证状态；未实际执行点击、滚动或视口检查的，必须明确标为未验证并列出所需验证。
- 不得将“今天必须交付”“最小可交付”或“少依赖”当成允许遮罩点击关闭或整个 Dialog 滚动的理由。
- 不得以仅内容区域滚动会导致固定标题或底部在小屏溢出为由让 Dialog 外框滚动；应调整内容布局和高度限制。
