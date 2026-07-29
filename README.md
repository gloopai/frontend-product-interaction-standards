# 前端产品交互规范

为前端设计、开发、评审与测试提供可执行的统一产品交互标准。

## 当前规范

本 Skill 当前包含以下 Dialog、四向抽屉、折叠面板与 Disclosure、可搜索单选 Select、多选/标签输入与 Tokenized Input、选择控件与开关、树形结构与级联、表单、页面级表单操作栏与保存区、复杂编辑器和构建器、数据表格、查询条件与筛选、关键词搜索输入、列表结果控制、卡片列表与卡片式结果、搜索与命令面板、日期时间与时区、信息展示与详情页、详情预览面板、密钥、令牌与敏感凭证、Webhook/集成连接与回调配置、计费/套餐/订阅与发票、图表与可视化、概览页与仪表盘首页、导出/下载与结果产物、文件与媒体资产管理、用户侧附件与内容提交上传、页面操作栏与列表工具栏、保存视图与布局预设、设置/偏好与配置页、分步流程与配置向导、Tab 视图导航、管理台 App Shell 与导航外框、导航与路由、会话、认证与重新认证、记录新增/编辑承载面、按钮、浮层菜单与提示、危险操作与恢复、审批与审核工作流、状态流转与记录生命周期、成员、邀请与团队访问管理、权限/租户与可见性、异步任务与任务中心、审计日志与操作历史、上传与导入、反馈状态、全局反馈、跨端适配和管理台治理核心要求：

- PC、平板和移动端保持核心能力一致；低频能力可以折叠或收纳，但不能删除，且必须保持可发现、可访问。

- 遮罩点击不会关闭 Dialog；外框保持非滚动、仅内容区域滚动，且遮罩以正确层级覆盖整个视口。
- 打开和关闭动画防止重复操作并遵循 reduced-motion 偏好；焦点进入合理元素、在当前 Dialog 内循环，并在关闭后恢复。
- Dialog 具有可访问的角色、名称和可见操作；普通 Dialog 必须保留右上角关闭按钮，只有业务明确禁止退出时才可隐藏或禁用；背景隔离且多层 Dialog 仅允许最上层交互。
- Dialog 内 Select / Combobox / Dropdown popup 必须归属当前最上层模态实例，使用 portal、锚点重算、collision、页脚避让、安全间距和内部滚动；不得用临时 `z-index`、Dialog 外框滚动、贴住底部操作区或遮挡确认按钮来解决空间问题。截图型页脚冲突必须记录 trigger、popup、选中高亮行、滚动阴影、底部操作区和安全区域的可视矩形。
- 异步提交防止重复操作并可访问地传达 loading 与错误；关闭、路由变化和再次打开会清理相关状态。
- 在移动端、缩放、低高度与虚拟键盘场景中，内容和操作保持可访问。
- 上、下、左、右抽屉按来源边缘进入与退出；遮罩点击、拖拽和滑动均不会关闭抽屉，外框保持非滚动且仅内容区域滚动。
- 普通可退出抽屉在固定标题区右上角保留关闭按钮，并遵循全视口遮罩、焦点管理、背景隔离、安全区域、多层叠加、异步错误与状态清理规则。
- 折叠面板与 Disclosure 规范：见 `references/disclosure-accordions.md`。约束 disclosureAccordionState、展开状态、错误外显、权限隐藏、懒加载迟到、展开状态持久化、嵌套折叠、焦点公告和移动端承载。
- 自绘可搜索单选 Select 的值只能来自已有选项，支持完整键盘和 ARIA；`auto` 按稳定声明条件确定性解析为 `inline`、`panel`、`drawer` 或 Select-only `none`，PC 使用非模态浮层，移动端在需要时转换为移动端 Drawer。
- 多选、标签输入与 Tokenized Input 规范：见 `references/multi-select-tag-inputs.md`。约束 multiValueInputState、已提交值/草稿 token/query/active option 分层、创建标签、自由文本 token、批量粘贴、Backspace 删除、重复冲突、异步迟到结果、权限无泄露、ARIA 和移动端承载，避免 query 即提交、active 即选中、创建即保存、批量粘贴直接提交和 orphaned invalid 静默丢失。
- 选择控件与开关规范约束 Checkbox、Radio、Switch、Toggle、Segmented Control、三态 checkbox 的草稿/提交分离、组语义、风险转交、禁用原因、权限安全、键盘可达和移动端承载。
- 树形结构与级联规范约束 Tree、Tree Select、Cascader、组织树、权限树、菜单树、分类树的节点身份、展开、选择、级联、半选、过滤、懒加载、权限无泄露和移动端承载。
- 移动端复杂 Dialog 可转 Bottom Sheet；其最大高度、底部偏移、左右边距和右边距必须基于动态视口与 safe-area 计算，其内部 Select 若贴住底部操作区、遮挡确认按钮、受虚拟键盘挤压或无法安全定位，应优先转 Select Drawer，必要时再升级为全屏 Drawer 或独立页；Select Drawer 不得与外层 Bottom Sheet 正文共享滚动容器。
- 表单以明确的字段状态、校验与提交生命周期管理错误、恢复、未保存更改和可访问错误反馈。
- 页面级表单操作栏与保存区规范约束 formActionBarState、保存/取消/返回/放弃/重置意图区分、多保存入口共享、sticky/fixed 底部避让、dirty 绑定、权限收敛、保存结果回执、焦点恢复和移动端虚拟键盘可达性，避免重复请求、保存栏遮挡字段、Toast-only 回执和无权限幽灵保存按钮。
- 复杂编辑器和构建器规范约束 editorBuilderState、草稿/预览/保存/发布分层、完整结构校验、错误定位、预览可信边界、版本冲突、权限清理、自动保存、AI 生成、导入导出和移动端触摸承载，避免草稿污染正式配置、预览即保存、只校验可见区域、Toast-only 回执和权限幽灵入口。
- 数据表格以显式能力档位覆盖展示、单行与批量场景，并约束筛选、排序、页码/游标分页、列与固定列、选择、批量操作和部分成功的交互。
- 查询条件与筛选规范约束草稿/已应用分离、应用模式、默认值、重置/清空、已应用摘要、URL 安全同步、权限收敛和移动端筛选可达性。
- 关键词搜索输入规范：见 `references/keyword-search-inputs.md`。约束 keywordSearchInputState、输入草稿/normalizedDraft/已提交关键词分离、IME composition Enter 边界、防抖提交、最小长度、迟到请求、清空草稿/清空已提交关键词/重置默认关键词/取消输入意图区分、URL/历史敏感边界、单 owner 播报和移动端虚拟键盘承载。
- 列表结果控制规范：见 `references/list-result-controls.md`。约束 listResultControlsState、分页、页大小、排序、刷新、自动刷新、结果摘要、请求快照、迟到响应、总数可信度、URL 恢复、权限和移动端承载。
- 卡片列表与卡片式结果规范：见 `references/card-list-results.md`。约束 cardListResultState、卡片身份、字段映射、交互区域、能力档位、选择/操作边界、大链接禁止、卡片内编辑禁止、权限无泄露、迟到响应、移动端结果卡片和运行时未验证边界。
- 搜索与命令面板规范约束全局搜索、站内搜索、命令面板、快速跳转、动作搜索、结果分组、命令执行、权限无泄露、最近/保存搜索、快捷键、移动端承载和 AI 搜索边界。
- 日期时间与时区规范约束日期、时间、时间范围、快捷范围、时区、范围边界、URL 恢复、报表/导出/审计快照和移动端承载转换。
- 信息展示与详情页规范约束详情页、描述列表、只读字段、信息卡、状态标签、指标卡、字段语义、脱敏复制、权限收敛、审计摘要和移动端折叠。
- 详情预览面板规范：见 `references/preview-pane.md`。约束 previewPaneState、来源列表绑定、预览目标、只读边界、迟到响应、权限无泄露、关闭返回、URL 恢复、移动端 Bottom Sheet/全屏预览和运行时未验证边界，避免预览面板变成编辑面板、表格选择、hover/focus 或旧权限缓存。
- 复制与剪贴板操作规范约束复制字段、复制 ID、复制链接、复制脱敏值、复制真实值、系统剪贴板、旧 DOM/旧链接失效、Toast 边界、权限复核、失败恢复和移动端替代路径。
- 密钥、令牌与敏感凭证规范约束 API Key、Token、Webhook Secret、Client Secret、服务账号凭证的生成后一次性展示、Reveal、复制、下载凭证、Rotate/轮换、撤销、旧值失效、审计不泄露、系统剪贴板风险、Toast 边界和移动端恢复路径。
- Webhook、集成连接与回调配置规范约束 Webhook endpoint、回调 URL、事件订阅、连接测试、测试投递、签名校验、启停/删除、重试投递、事件回放、投递日志、旧 endpoint/secret/log 失效、审计不泄露、Toast 边界和移动端恢复路径。
- 计费、套餐、订阅与发票规范约束 plan/pricing、订阅版本、付款方式、支付状态、用量/额度、发票/收据下载、退款、取消/降级、价格快照、旧发票链接失效、审计不泄露、Toast 边界和移动端恢复路径。
- 图表与可视化规范约束图表数据快照、指标口径、维度编码、坐标轴、图例、tooltip、交互能力、空态错误、权限安全、导出明细、可访问性和移动端替代表达。
- 概览页与仪表盘首页规范：见 `references/overview-dashboard-pages.md`。约束 overviewDashboardState、页面级共享快照、只读默认、KPI/图表/明细/导出一致性、告警优先级、权限无泄露、移动端总览保留和运行时未验证边界。
- 图表与可视化创作配置规范约束 chartBuilderState、数据源/指标/维度/编码草稿、图形类型兼容、预览快照、完整校验、保存/发布边界、旧配置失效和移动端配置承载，避免预览即保存、保存即发布、图形类型切换静默丢配置、保存读取 Select query 或筛选草稿。
- 导出、下载与结果产物交付规范约束 export、download、artifact、result artifact、报表导出、图表导出、审计导出、错误明细下载和文件领取的范围快照、产物身份、下载意图、权限复核、有效期、敏感字段、旧链接失效、Toast 边界、恢复路径和移动端承载。
- 页面操作栏与列表工具栏规范约束 toolbarState、页面主操作、结果绑定、批量操作栏、视图工具、更多菜单、权限收敛和移动端收纳，避免主操作埋入菜单、读取筛选草稿、空批量条、旧权限入口和移动端核心操作消失。
- 保存视图、视图预设与个性化布局规范约束 savedViewState、已应用快照、布局快照、个人/共享/默认视图、保存筛选、列布局、密度预设、应用视图、覆盖/删除/共享/恢复默认、权限收敛、未知结果和移动端恢复路径，避免保存草稿、共享无权限字段、默认范围混淆和旧视图继续应用。
- 设置、偏好与配置页规范约束 settingsState、settingsScope、draftSettings、effectiveSettings、defaultSettings、applyMode、重置默认、权限收敛和移动端承载，避免草稿伪装生效、重置语义混合、危险配置绕过确认和移动端保存/取消消失。
- 分步流程与配置向导规范约束 Wizard、Stepper、多步骤表单、步骤状态、导航意图、草稿/复核/提交快照、跨步失效、异步结果、权限安全和移动端步骤承载。
- Tab 视图导航规范：见 `references/tab-view-navigation.md`。约束 tabViewState、TabList/TabPanel、activeTabId、URL/历史恢复、懒加载、权限隐藏、未保存保护、焦点公告和移动端形态转换。
- 管理台 App Shell 与导航外框规范：见 `references/app-shell-navigation.md`。约束 appShellNavigationState、全局导航结构、当前项绑定、工作区/租户切换、用户菜单、全局入口转交、权限无泄露、移动端导航 Drawer 和运行时未验证边界。
- 导航与路由规范约束导航入口、返回策略、来源上下文恢复、面包屑、Tabs、浏览器历史、路由离开保护、权限重校验和移动端返回可达性。
- 会话、认证与重新认证规范约束登录过期、重新认证、SSO/MFA callback、退出登录、账号切换、身份切换、租户/工作区切换、旧状态失效、Toast-only 禁止和移动端恢复路径，避免旧敏感动作、旧下载链接、旧权限缓存或错误 callback 被继续使用。
- 记录新增/编辑承载面禁止列表内嵌表单、常驻可编辑列表、单元格编辑、行内保存按钮和 spreadsheet-like 编辑矩阵；新增、编辑、复制创建和批量配置必须按场景进入 Dialog、Drawer 或独立页。
- 按钮规范首版聚焦管理台和业务操作按钮，约束按钮语义、文案、主次层级、禁用、loading、防重复、危险操作、图标按钮、按钮组和响应式可达性。
- 浮层菜单与提示规范约束 Tooltip、Popover、Dropdown Menu、Context Menu、更多菜单、Action Sheet 和移动端菜单 Drawer 的触发、可达性、关键内容边界、菜单项动作、Portal、碰撞、权限收敛和生命周期清理。
- 危险操作与恢复规范约束风险分级、影响范围、二次确认、输入确认、撤销窗口、取消边界、未知结果、批量快照、权限收敛、审计回执和移动端恢复可达性。
- 审批与审核工作流规范：见 `references/approval-workflows.md`。约束 approvalWorkflowState、审批决策快照、审批意见/附件、转交/加签/委托、批量审批、通知边界、审计回执、权限无泄露、移动端审批保真和运行时未验证边界。
- 状态流转与记录生命周期规范约束 status lifecycle、status transition、record lifecycle、发布/下线、审批/驳回、启停、归档/恢复、冻结/解冻、锁定/解锁的状态模型、转换意图、版本快照、结果状态、冲突恢复、权限无泄露、审计回执、批量快照和移动端承载。
- 成员、邀请与团队访问管理规范约束成员列表、邀请成员、邀请链接、重新发送/撤销邀请、角色变更、移除/禁用/启用成员、转移 Owner、外部成员、旧邀请链接失效、权限/会话/租户收敛、审计不泄露、Toast 边界和移动端恢复路径。
- 权限、租户与可见性规范约束 RBAC、ABAC、角色、能力开关、租户/工作区切换、权限降级、隐藏/禁用/只读/未启用语义、原子收敛、无泄露、请求绑定和移动端权限恢复。
- 异步任务与任务中心规范约束 async job、导入导出任务、批量任务、报表生成、AI 生成、同步任务的任务身份、进度、取消/重试、未知结果、任务中心恢复、结果产物、权限复核和移动端承载。
- 审计日志与操作历史规范约束 audit log、activity log、operation history、事件日志、变更记录和时间线的证据身份、主体/目标/动作快照、时间语义、完整性状态、权限无泄露、审计导出复核和移动端追溯。
- 上传与导入规范覆盖文件选择、拖拽、本地校验、上传队列、进度、取消、重试、表单内文件字段、导入预检、字段映射、部分成功、错误明细和下载权限复核。
- 文件与媒体资产管理规范约束 assetState、上传后状态分层、预览/缩略图权限边界、资产版本、变体、旧 URL 失效、裁剪/转码/发布意图区分、分享链接、删除恢复、使用关系和移动端播放器/裁剪器承载，避免上传成功即资产可用、缩略图当权限证明、Toast-only 分享和旧 CDN/下载链接泄漏。
- 用户侧附件与内容提交上传规范约束 attachmentSubmissionState、内容草稿绑定、相机/相册/粘贴/拖拽来源、附件草稿、上传引用、提交快照、发送结果、撤回/删除、权限隐私、弱网恢复和移动端输入承载，避免文件已选即发送、上传成功即内容成功、头像裁剪即生效、迟到结果写入新草稿和 Toast-only 附件错误。
- 反馈状态与状态承载规范区分 loading、skeleton、empty、zero-results、error、refresh-error、stale、permission、partial 和 recovery，约束旧内容保留、Toast 边界、敏感信息和恢复入口。
- 全局反馈与通知规范约束 Toast、Alert、Banner、Notification 和 Inline Feedback 的通道选择、结果绑定、自动关闭、去重堆叠、恢复入口、移动端遮挡和敏感信息边界。
- 通知中心、站内信与公告规范约束通知中心、站内信、公告、未读/已读、通知偏好、Toast 边界、点击目标、权限收敛、渠道投递、批量未知结果和移动端恢复路径。
- 管理台完整治理覆盖导航、权限/租户、危险操作、审计、导入导出、异步任务、报表口径和全局反馈，并规定报表默认只读、能力显式声明、Toast 不得作为唯一回执。

完整规则、验收标准与完成前检查见 [Dialog 交互规范](references/dialogs.md)、[Drawer 交互规范](references/drawers.md)、[可搜索单选 Select / Combobox 交互规范](references/selects-comboboxes.md)、多选、标签输入与 Tokenized Input 规范：`references/multi-select-tag-inputs.md`、[选择控件与开关交互规范](references/selection-controls.md)、[树形结构与级联交互规范](references/tree-hierarchy.md)、[表单状态、校验与错误交互规范](references/forms.md)、[页面级表单操作栏与保存区交互规范](references/page-form-action-bars.md)、[复杂编辑器和构建器交互规范](references/complex-editors-builders.md)、[数据表格交互规范](references/data-tables.md)、[查询条件与筛选交互规范](references/query-filters.md)、关键词搜索输入规范：`references/keyword-search-inputs.md`、列表结果控制规范：`references/list-result-controls.md`、卡片列表与卡片式结果规范：`references/card-list-results.md`、[搜索与命令面板交互规范](references/search-command-palette.md)、[日期时间与时区交互规范](references/date-time-ranges.md)、[信息展示与详情页交互规范](references/information-display.md)、详情预览面板规范：`references/preview-pane.md`、[复制与剪贴板操作交互规范](references/copy-clipboard.md)、[密钥、令牌与敏感凭证交互规范](references/secrets-credentials.md)、[Webhook、集成连接与回调配置交互规范](references/webhooks-integrations-callbacks.md)、[计费、套餐、订阅与发票交互规范](references/billing-subscription-invoices.md)、[通知中心、站内信与公告交互规范](references/notifications-message-center-announcements.md)、[图表与可视化交互规范](references/charts-visualization.md)、概览页与仪表盘首页规范：`references/overview-dashboard-pages.md`、图表与可视化创作配置规范：`references/chart-visualization-builders.md`、[导出、下载与结果产物交付交互规范](references/exports-downloads-artifacts.md)、文件与媒体资产管理交互规范：`references/files-media-assets.md`、用户侧附件与内容提交上传规范：`references/user-attachment-submission.md`、[页面操作栏与列表工具栏交互规范](references/page-toolbars-actions.md)、[保存视图、视图预设与个性化布局交互规范](references/saved-views-layout-presets.md)、[设置、偏好与配置页交互规范](references/settings-preferences-configuration.md)、[分步流程与配置向导交互规范](references/wizards-steppers.md)、管理台 App Shell 与导航外框规范：`references/app-shell-navigation.md`、[导航与路由交互规范](references/navigation-routing.md)、[会话、认证与重新认证交互规范](references/auth-session-reauth.md)、[记录新增/编辑承载面交互规范](references/record-editing-surfaces.md)、[按钮交互规范](references/buttons.md)、[浮层菜单与提示交互规范](references/overlays-menus-tooltips.md)、[危险操作与恢复交互规范](references/risk-actions.md)、审批与审核工作流规范：`references/approval-workflows.md`、[状态流转与记录生命周期交互规范](references/status-lifecycle-transitions.md)、[成员、邀请与团队访问管理交互规范](references/members-invitations-access.md)、[权限、租户与可见性交互规范](references/permissions-tenancy-visibility.md)、[异步任务与任务中心交互规范](references/async-jobs-task-center.md)、[审计日志与操作历史交互规范](references/audit-log-activity-history.md)、[上传与导入交互规范](references/uploads-imports.md)、[反馈状态与状态承载规范](references/feedback-states.md)、[全局反馈与通知交互规范](references/global-feedback.md)、[响应式与自适应交互规范](references/responsive-adaptive.md) 和 [管理台完整治理交互规范](references/admin-console.md)。

## 系统要求

需要已安装 Git、可使用 Codex，并且 `~/.codex/skills/` 目录具有写入权限。

## 安装

先确认目标目录不存在，再通过 HTTPS 克隆：

```sh
test ! -e ~/.codex/skills/frontend-product-interaction-standards
git clone https://github.com/gloopai/frontend-product-interaction-standards.git ~/.codex/skills/frontend-product-interaction-standards
```

## 使用

`SKILL.md` 的描述将此 Skill 定义为前端产品交互任务的适用规范，而 `agents/openai.yaml` 中的 `allow_implicit_invocation: true` 允许 Codex 在匹配的前端页面、组件、布局、Dialog、表单和交互任务中自动加载它。

也可以显式提出：`使用 $frontend-product-interaction-standards 检查这个 Dialog`。

## 项目接入

仅依赖隐式触发不足以保证业务项目强制执行本 Skill。需要在业务项目的 `AGENTS.md` 中加入最小接入片段，见 [项目 AGENTS.md 接入片段](docs/adoption/project-agents-snippet.md)；接入完成后可用 [项目接入检查清单](docs/adoption/checklist.md) 复核。

业务项目不要复制完整 `references/*.md` 作为长期事实来源；应强制读取本 Skill，并把项目例外留在业务项目内。

## 更新

```sh
git -C ~/.codex/skills/frontend-product-interaction-standards pull --ff-only
```

## 卸载

先确认目标目录存在：

```sh
test -d ~/.codex/skills/frontend-product-interaction-standards
```

删除该目录不可恢复。确认不再需要后，请由你自行删除 `~/.codex/skills/frontend-product-interaction-standards`；本文不提供删除命令。

## 目录结构

```text
frontend-product-interaction-standards/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
├── SKILL.md
├── agents/
│   └── openai.yaml
├── docs/
│   └── adoption/
│       ├── checklist.md
│       └── project-agents-snippet.md
└── references/
    ├── admin-console.md
    ├── approval-workflows.md
    ├── audit-log-activity-history.md
    ├── async-jobs-task-center.md
    ├── app-shell-navigation.md
    ├── billing-subscription-invoices.md
    ├── buttons.md
    ├── card-list-results.md
    ├── chart-visualization-builders.md
    ├── charts-visualization.md
    ├── complex-editors-builders.md
    ├── copy-clipboard.md
    ├── data-tables.md
    ├── date-time-ranges.md
    ├── disclosure-accordions.md
    ├── dialogs.md
    ├── drawers.md
    ├── exports-downloads-artifacts.md
    ├── feedback-states.md
    ├── files-media-assets.md
    ├── forms.md
    ├── global-feedback.md
    ├── information-display.md
    ├── list-result-controls.md
    ├── members-invitations-access.md
    ├── navigation-routing.md
    ├── notifications-message-center-announcements.md
    ├── overview-dashboard-pages.md
    ├── page-toolbars-actions.md
    ├── overlays-menus-tooltips.md
    ├── page-form-action-bars.md
    ├── permissions-tenancy-visibility.md
    ├── preview-pane.md
    ├── query-filters.md
    ├── record-editing-surfaces.md
    ├── risk-actions.md
    ├── saved-views-layout-presets.md
    ├── secrets-credentials.md
    ├── settings-preferences-configuration.md
    ├── selects-comboboxes.md
    ├── status-lifecycle-transitions.md
    ├── tab-view-navigation.md
    ├── tree-hierarchy.md
    ├── uploads-imports.md
    ├── user-attachment-submission.md
    ├── webhooks-integrations-callbacks.md
    ├── wizards-steppers.md
    └── responsive-adaptive.md
```

## 扩展规范

新增或调整规范时，请遵循 [贡献指南](CONTRIBUTING.md) 中的分类、路由与验证要求。

## 适用范围

已在 Codex 中验证安装和使用流程。其他 Agent Skills 工具尚未验证，使用前请自行确认其兼容性。

## 贡献

贡献流程见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 行为准则

社区参与规范见 [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)。

## 安全

安全问题的私密报告方式见 [SECURITY.md](SECURITY.md)。

## 许可证

本项目采用 [MIT License](LICENSE)。
