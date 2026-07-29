# 搜索与命令面板交互规范设计

## 背景

现有 `query-filters.md` 已覆盖列表、报表、审计页和任务中心里的查询条件区，并明确排除全站搜索、命令面板、复杂查询语言、SQL/DSL、BI 自由分析器、AI 自然语言检索和搜索排序算法。`navigation-routing.md` 覆盖从搜索结果进入详情后的来源恢复，但不定义搜索入口本身；`buttons.md`、`risk-actions.md`、`feedback-states.md` 和 `admin-console.md` 分别覆盖按钮、风险命令、状态反馈和管理台安全边界。

管理台里常见的全局搜索、快捷跳转和命令面板仍然容易出问题：输入草稿触发导航、搜索建议泄露无权限对象、最近搜索保留敏感词、命令和结果混在一起、按 Enter 执行危险操作、移动端直接删除快捷能力、AI 搜索把不确定建议包装成确定命令。这些问题不属于列表筛选，也不是普通 Select，它们需要独立 owner。

本设计新增 `references/search-command-palette.md`，作为全局搜索、站内搜索、命令面板、快捷跳转、动作搜索和搜索结果承载的唯一事实来源。

## 目标

- 新增搜索与命令面板 owner，覆盖全局搜索、站内搜索、命令面板、快速跳转、动作搜索、搜索建议、最近搜索、保存搜索、结果分组和结果预览。
- 明确 `searchCommandState`，区分输入草稿、已提交查询、active result、高亮建议、选中对象、命令绑定、权限边界、历史策略和反馈状态。
- 防止草稿、hover、高亮建议、最近搜索或预览隐式导航、执行命令或产生请求副作用。
- 建立权限安全规则：无权限结果不得泄露对象名称、数量、字段、摘要片段、文件名、内部 ID 或旧缓存。
- 规定命令执行边界：会修改数据、权限、导出、任务、密钥或外部系统的命令必须进入 `risk-actions.md`。
- 规定移动端承载：可用全屏搜索页、Bottom Sheet 或 Drawer，但不能删除查询、提交、清空、结果分组、错误/权限说明、最近/保存搜索和恢复路径。
- 建立 RED/GREEN 证据与静态审计，确保常见违规能被抓住。

## 非目标

- 不重新定义列表、表格、报表或审计日志里的筛选条件；这些继续由 `query-filters.md` 负责。
- 不重新定义字段 Select、Combobox 的选项搜索、active option 和提交值；这些继续由 `selects-comboboxes.md` 负责。
- 不重新定义危险操作确认、输入确认、未知结果、审计回执和撤销；这些继续由 `risk-actions.md` 负责。
- 不重新定义搜索排序算法、索引实现、搜索引擎、向量检索、SQL/DSL 编辑器或 BI 自由分析器。
- 不规定框架、快捷键库、命令注册 API、索引服务或视觉 token。

## 推荐方案

采用独立 `search-command-palette.md` owner，聚焦“用户如何通过全局入口找到对象、跳转页面或触发命令”。

### 方案对比

| 方案 | 优点 | 缺点 | 结论 |
| --- | --- | --- | --- |
| 独立搜索与命令面板 owner | 边界清晰；能同时约束全局搜索、命令面板、权限泄露、历史记录、快捷键和移动端承载。 | 需要新增路由、README/HANDOFF 摘要和审计。 | 推荐。 |
| 扩展 `query-filters.md` | 少一个文件；搜索关键词看似相近。 | 会把列表筛选和全局发现/命令执行混在一起，导致结果、权限、URL 和命令边界混乱。 | 不采用。 |
| 扩展 `navigation-routing.md` | 能覆盖“从结果跳转”。 | 搜索输入、建议、结果状态、历史和命令执行并非导航 owner 的职责。 | 不采用。 |

## 首版范围

首版覆盖：

- 顶部全局搜索、站内搜索页、命令面板、快速跳转、动作搜索、对象搜索、搜索建议、最近搜索、保存搜索。
- 搜索结果分组、结果预览、对象结果、页面结果、命令结果、空状态、部分结果、过期结果、权限拒绝和错误恢复。
- 键盘快捷键打开、输入、上下移动、Enter 激活、Escape 关闭、Tab 焦点顺序、Home/End 和焦点恢复。
- 桌面、移动端、平板、低高度、虚拟键盘、触摸和辅助技术可达性。
- 管理台权限、租户/工作区、审计、安全导出、任务中心和跨页跳转场景。

暂不覆盖：

- 列表内关键词筛选、筛选条件区和 URL 筛选。
- SQL/DSL 查询编辑器、复杂语法解析器、BI 自由分析器。
- 搜索排序算法、索引同步策略和搜索服务实现。

## 核心设计

### 1. 状态模型

每个搜索或命令面板维护 `searchCommandState`：

| 字段 | 语义 |
| --- | --- |
| `searchOwnerId` | 当前搜索入口或命令面板的稳定 owner。 |
| `surfaceKind` | `global-search`、`site-search`、`command-palette`、`quick-switcher`、`action-search` 等承载类型。 |
| `queryDraft` | 用户正在输入、尚未提交的搜索草稿。 |
| `submittedQuery` | 已明确提交、用于结果请求、标题、URL 或历史的查询。 |
| `resultSnapshot` | 本次结果的不可变快照，包含查询、权限版本、租户/工作区、时间和来源。 |
| `resultGroups` | 按对象、页面、命令、最近、保存、帮助等分组后的结果。 |
| `activeResult` | 键盘或辅助技术当前指向的已渲染结果。 |
| `selectionState` | 已激活结果、已选择对象或待执行命令的状态。 |
| `commandBinding` | 命令身份、风险等级、所需权限、参数、确认策略和结果 owner。 |
| `permissionBoundary` | 搜索、展示、预览、跳转和命令执行各自的权限边界。 |
| `rankingPolicy` | 结果排序、分组、解释、置顶和最近/保存混排策略。 |
| `historyPolicy` | 最近搜索、保存搜索、清除路径、敏感查询和跨租户存储策略。 |
| `shortcutPolicy` | 打开快捷键、冲突处理、平台差异和禁用条件。 |
| `feedbackState` | loading、empty、zero-results、partial、stale、error、permission-denied 和 recovery。 |
| `responsivePolicy` | 桌面、移动端、Bottom Sheet、Drawer 或独立页承载。 |
| `a11yPolicy` | 角色、名称、焦点、键盘、公告和高对比度规则。 |

`queryDraft`、`activeResult`、hover suggestion 和最近搜索高亮不得触发导航、命令执行或请求副作用。只有明确提交搜索或激活结果后，才能改变导航、执行命令或写入已提交查询。

### 2. 搜索、建议和结果

输入时可以请求建议，但建议必须与已提交结果区分。建议区展示的是可探索线索，不是已经生效的导航或命令。结果必须按来源和对象类型分组，并说明排序或置顶依据；无法解释的个性化排序必须至少给出“最近访问”“高匹配”“常用命令”等安全可读原因。

结果状态必须区分 loading、empty、zero-results、partial、stale、error 和 permission-denied。部分结果不能伪装成完整结果；过期结果必须给出刷新或重试路径。无权限结果不得泄露对象名称、数量、字段、摘要片段、文件名、内部 ID 或旧缓存。

### 3. 命令面板和动作搜索

命令结果必须声明命令身份、动作对象、所需权限、风险等级、是否需要参数、是否会离开页面、结果回执 owner 和失败恢复。普通安全跳转可以直接执行；会修改数据、权限、导出、任务、密钥或外部系统的命令必须进入 `risk-actions.md`，并在确认完成前请求数为 0。

命令搜索不得把查询草稿当命令参数静默执行。Enter 只能激活当前可见且合法的 `activeResult`；若 active result 不存在、结果过期、权限变化或参数缺失，必须阻止执行并给出可读反馈。

### 4. 历史、保存和 URL

最近搜索和保存搜索属于敏感状态，必须声明存储范围、清除路径、权限复核和敏感查询策略。跨租户/工作区不得复用旧历史；权限降低后必须隐藏、失效或安全替换旧结果、旧建议和旧历史。

只有明确 `urlSafe` 的 `submittedQuery` 或结果页状态可以进入 URL。敏感自由文本、内部 ID、权限范围、个人识别信息和产品标记敏感的查询不得进入 URL、标题、日志或 analytics。

### 5. 导航与来源恢复

从搜索结果进入详情、设置页、任务中心、报表或外部页面时，必须建立 `sourceContext`，交给 `navigation-routing.md` 处理返回。返回搜索结果不等于 `history.back()`；必须恢复安全的 `submittedQuery`、结果快照、滚动位置和焦点，若权限或版本失效则进入安全兜底。

### 6. 响应式和可访问性

桌面端可使用顶部搜索框、居中 command palette 或独立搜索页；移动端可转换为全屏搜索页、Bottom Sheet 或 Drawer。转换不得删除查询输入、提交、清空、结果分组、权限/错误说明、最近/保存搜索入口或恢复路径。

命令面板和搜索结果必须有可访问名称、清晰焦点、键盘路径和状态公告。打开快捷键不能与浏览器、输入法、编辑器或页面关键快捷键冲突；冲突时应禁用或换用显式入口。触摸端不能依赖 hover 发现命令或预览。

### 7. AI / 自然语言搜索边界

若产品提供 AI 或自然语言搜索，必须区分“建议答案”“候选结果”“可执行命令”和“已执行结果”。AI 建议必须表达不确定性、来源、权限边界和恢复路径；不得在用户确认前静默执行命令、变更数据或导航到敏感对象。AI 搜索的排序和摘要不得泄露无权限对象。

## 与现有 owner 的关系

- `query-filters.md`：列表/报表筛选继续归 Query Filter；全局搜索、命令面板和快速跳转归本 owner。
- `selects-comboboxes.md`：字段 Select 的内部 query、active option 和 popup 不进入本 owner；本 owner 只接收明确提交的搜索入口或命令结果。
- `navigation-routing.md`：搜索结果激活后的来源上下文、返回策略和路由清理由导航 owner 处理。
- `buttons.md`：打开搜索、清空、保存搜索、执行命令和重试按钮遵循按钮 owner。
- `risk-actions.md`：任何风险命令、危险命令、权限变更、敏感导出、任务取消/重跑、密钥操作必须进入风险 owner。
- `feedback-states.md` / `global-feedback.md`：结果状态、错误恢复和操作回执分别复用状态与全局反馈 owner。
- `admin-console.md`：租户、工作区、RBAC、审计、导出、任务和权限收敛复用管理台治理。
- `responsive-adaptive.md`：移动端承载、虚拟键盘、安全区域和断点转换复用响应式 owner。

## 新 owner 草案结构

计划新增 `references/search-command-palette.md`：

1. 范围与边界
2. `searchCommandState` 状态模型
3. 草稿、提交和结果请求
4. 建议、结果分组、预览和排序说明
5. 命令面板、动作搜索和风险命令
6. 权限、租户/工作区和无泄露规则
7. 最近搜索、保存搜索、URL 和敏感查询
8. 键盘、焦点、快捷键和可访问性
9. 移动端承载和响应式转换
10. AI / 自然语言搜索边界
11. 完成前检查

稳定规则族建议：

- `SCP-SCOPE`：范围与 owner 分流。
- `SCP-STATE`：状态模型、草稿/提交分离。
- `SCP-RESULT`：结果分组、状态、预览和排序说明。
- `SCP-CMD`：命令绑定、执行边界和风险转交。
- `SCP-PERM`：权限、租户、无泄露和旧缓存清理。
- `SCP-HISTORY`：最近/保存搜索、URL、安全存储。
- `SCP-KBD`：快捷键、焦点、键盘激活和 Escape。
- `SCP-RSP`：移动端承载、Bottom Sheet/Drawer/独立页。
- `SCP-AI`：AI/自然语言搜索边界。
- `SCP-LIFE`：请求、迟到回调、卸载和实例清理。

## 验收策略

- 新增 owner 文档、SKILL 路由、README/HANDOFF 摘要。
- 新增 GREEN/RED 摘要，覆盖安全示例和反例。
- 新增 `docs/testing/search-command-palette/search-command-palette-audit.rb`，检查 owner、路由、摘要和证据。
- 运行维护中的 owner 审计、Markdown 链接检查和 `git diff --check`。
- 真实浏览器、触摸、快捷键、搜索服务、AI 服务、权限切换和移动端视口验证在本轮文档工作中标为未验证，后续业务项目实现时必须补充。
