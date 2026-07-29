# 折叠面板与 Disclosure 交互规范设计

## 背景

管理台里经常用 Accordion、Collapse、Disclosure、展开/收起区块来压缩信息：设置分组、高级筛选、详情字段、权限矩阵、FAQ、错误详情、审计扩展信息和移动端长内容。它们看起来是展示组件，但经常把关键状态藏起来：

- 折叠面板里有必填错误，但外层没有错误摘要或展开提示。
- 权限变化后折叠标题还泄露内部对象名、数量或旧错误。
- 懒加载内容迟到后写回已经收起、卸载或无权限的 panel。
- 展开状态被当成业务提交值、保存视图或筛选条件。
- 移动端把折叠面板变成一长串不可达内容，或把核心操作藏到深层。
- 用 Accordion 伪装主流程步骤、Tabs 或 Tree，导致语义混乱。

现有 `information-display.md`、`responsive-adaptive.md` 和 `forms.md` 都提到折叠或隐藏内容，但没有一个专门 owner 约束展开状态、错误外显、懒加载、权限和移动端折叠策略。需要新增一个职责单一的 owner。

## 范围

新增 `references/disclosure-accordions.md`，作为以下场景的 primary owner：

- Accordion、Collapse、Disclosure、展开/收起面板、可折叠区块、详情折叠、筛选折叠、高级设置折叠、错误详情折叠、移动端折叠内容。
- 单开、多开、默认展开、受控展开、持久化展开、懒加载内容、嵌套折叠、折叠内表单错误、权限隐藏和无权限占位。
- 桌面折叠面板在移动端转换为分组、卡片、Drawer、独立页或保持折叠时的核心能力和状态延续。

不覆盖：

- Tree / Cascader / 层级选择；继续由 `references/tree-hierarchy.md` 负责。
- Tabs / 页面内视图切换；继续由 `references/tab-view-navigation.md` 负责。
- Wizard / Stepper / 主流程步骤；继续由 `references/wizards-steppers.md` 负责。
- 表单字段值、dirty、提交和错误摘要；继续由 `references/forms.md` 负责。
- 详情字段语义和只读展示；继续由 `references/information-display.md` 负责。

## 推荐方案

采用独立 owner：`disclosureAccordionState`。

独立 owner 的好处是把“内容是否展开”从业务状态里剥离出来。展开状态是呈现与可达性状态，不是字段值、不是提交值、不是权限事实，也不是路由。它可以持久化为偏好，但必须明确声明范围和安全边界。

### 方案对比

1. 独立 disclosure/accordion owner（推荐）
   - 优点：精确约束错误外显、懒加载、权限隐藏、嵌套折叠和移动端承载；不污染信息展示或表单 owner。
   - 代价：需要新增路由、相邻 owner 链接和专项审计。

2. 扩展 information-display
   - 优点：折叠常用于详情展示。
   - 代价：无法覆盖表单错误、高级筛选、设置分组和懒加载恢复。

3. 扩展 forms
   - 优点：隐藏表单错误是高频问题。
   - 代价：Accordion 也大量用于只读详情、权限说明、审计、报表和移动端内容。

## 状态模型

新 owner 定义 `disclosureAccordionState`，至少包含：

- `disclosureOwnerId`：当前折叠组稳定 owner 身份。
- `surfaceKind`：`settings-sections`、`detail-sections`、`filter-sections`、`form-sections`、`error-details`、`audit-details`、`mobile-sections`。
- `itemRegistry`：所有 item 的稳定 ID、标题、层级、默认展开、是否允许收起、权限、懒加载和可持久化策略。
- `expandedItemIds`：当前展开 item 集合。
- `expansionPolicy`：`single`、`multiple`、`at-least-one`、`manual-only`、`auto-expand-on-error`。
- `contentState`：每个 item 的 loading、ready、error、stale、empty、dirty、invalid、permission-denied、disposal 状态。
- `requestBinding`：懒加载内容请求绑定的 owner、itemId、对象 ID、权限版本、租户/工作区、route 和请求代次。
- `errorVisibilityBinding`：折叠内错误、必填缺失、无权限、异步失败和恢复入口如何在折叠标题或外层摘要中可见。
- `permissionBoundary`：标题、数量、摘要、图标、旧内容和子项关系的无泄露策略。
- `persistenceBinding`：是否保存展开状态、保存范围、URL/本地偏好/保存视图边界和恢复校验。
- `focusAnnouncementPolicy`：展开/收起后的焦点、标题按钮、`aria-expanded`、`aria-controls`、公告去重。
- `responsivePolicy`：移动端折叠、分组、卡片、Drawer、独立页、安全区域和触摸目标。

核心不变量：

- 展开状态不等于业务值、不等于表单提交、不等于权限事实。
- 折叠不能隐藏当前必须处理的错误、必填缺失、权限原因或恢复入口。
- disabled、hidden、permission-denied 和 not-enabled item 不是同一状态。
- 懒加载迟到响应不得写回已收起、卸载、无权限或身份不匹配的 item。
- 嵌套折叠必须有唯一 owner 和层级边界，不能让父子互相抢焦点或重复公告。
- 移动端不得删除标题、当前展开状态、错误摘要、权限原因、恢复入口和核心操作。

## 行为规则

### 展开状态与语义边界

Accordion / Disclosure 只能隐藏可延后阅读或可分组的信息，不能隐藏完成当前任务必须立即处理的错误、风险确认、主操作、必填字段、保存失败、权限拒绝或唯一恢复路径。展开状态不等于业务值、不等于表单提交、不等于权限事实。

单开、多开、至少一个展开、默认展开、自动展开错误项和是否允许全部收起都必须由 `expansionPolicy` 声明，不能由组件默认行为临时决定。

### 错误、必填与恢复入口外显

折叠不能隐藏当前必须处理的错误、必填缺失、权限原因或恢复入口。若错误、必填缺失、异步失败或权限拒绝位于收起内容中，折叠标题或外层摘要必须显示可访问的错误/状态提示，并提供展开或跳转路径。提交失败时，包含首个错误的 item 必须被展开或聚焦到可展开标题。

### 权限、隐藏与安全摘要

disabled、hidden、permission-denied 和 not-enabled item 不是同一状态。未启用表示 DOM、state、handler、request 和 URL/偏好入口均为 0。无权限不得泄露标题、数量、对象名、字段名、错误明细、子项关系、旧内容或内部 ID，除非产品明确允许安全占位。

权限、租户/工作区、对象状态或 itemRegistry 变化后，旧标题、旧摘要、旧展开状态、旧内容、旧请求、旧焦点和旧 ARIA 引用必须原子失效或重算。

### 懒加载、持久化与迟到响应

懒加载内容请求必须绑定 `disclosureOwnerId`、itemId、对象 ID、权限版本、租户/工作区、route 和请求代次。迟到响应不得写回已收起且声明不保活、已卸载、无权限或身份不匹配的 item。

展开状态可以作为用户偏好保存，但必须声明 `persistenceBinding`。不得把展开状态写成业务字段、提交 payload、筛选条件、导出范围或权限事实。URL、保存视图或本地偏好恢复展开状态前必须校验 itemRegistry 版本、权限、租户/工作区和对象状态。

### 焦点、ARIA 与嵌套折叠

触发器必须是真按钮或等价可访问控件，暴露 `aria-expanded` 和 `aria-controls`。展开后焦点默认留在触发器，只有用户意图明确或错误恢复需要时才移动到内容或错误目标。收起当前焦点所在内容前必须把焦点移动到对应触发器或安全替代入口。

嵌套折叠必须声明父子 owner 边界。父级收起时只清理自己的可见内容和子 owner 生命周期，不得释放兄弟 owner；父子展开、错误和 loading 公告不得重复朗读同一完整消息。

### 移动端与响应式

移动端不得删除标题、当前展开状态、错误摘要、权限原因、恢复入口和核心操作。折叠面板可以转为卡片、分组、Drawer 或独立页，但不能改变业务语义、丢失错误外显、跳过未保存保护或让关键操作只存在于不可达深层。

低高度、虚拟键盘、安全区域、200% 缩放和触摸输入下，当前触发器、展开内容、错误提示、恢复入口和返回路径必须可达。

## 相邻 owner 关系

- `references/forms.md`：折叠内字段 dirty、校验、提交和错误摘要归 Forms；本 owner 负责错误外显和自动展开。
- `references/information-display.md`：只读详情字段语义归信息展示；折叠分组和展开状态归本 owner。
- `references/query-filters.md`：高级筛选折叠只承载筛选 UI；筛选草稿、应用和 URL 仍归 query-filters。
- `references/feedback-states.md`：折叠内容 loading/error/stale/empty 的反馈承载执行反馈状态规范。
- `references/permissions-tenancy-visibility.md`：折叠标题、摘要和旧内容的权限无泄露执行权限规范。
- `references/responsive-adaptive.md`：移动端折叠、Drawer/独立页转换、安全区域和触摸目标执行响应式规范。
- `references/tab-view-navigation.md`：页面内视图切换归 Tabs，不得用 Accordion 伪装跨视图 tab。
- `references/tree-hierarchy.md`：层级选择和树节点展开归 Tree，不得用 Accordion 伪装可选择树。

## 路由触发词

`SKILL.md` 应新增路由，命中：

- 中文：Accordion、Collapse、Disclosure、折叠面板、折叠区块、展开收起、展开面板、收起面板、详情折叠、设置折叠、高级筛选折叠、错误详情折叠、移动端折叠、嵌套折叠。
- English：accordion、collapse、disclosure、expand collapse、expandable panel、collapsible panel、collapsible section、details disclosure、settings accordion、filter accordion、error details、mobile accordion、nested accordion。

## 可执行验收方向

实施计划需要新增 Ruby 审计，至少覆盖：

1. owner 文件存在，且包含完整 `disclosureAccordionState` 字段。
2. 精确规则：展开状态不等于业务值；折叠不能隐藏错误/必填/权限/恢复入口；disabled/hidden/permission-denied/not-enabled 分离；迟到响应不得写回失效 item；嵌套折叠有 owner 边界；移动端不得删除核心能力。
3. 持久化边界：展开状态不得写成提交 payload、筛选条件、导出范围或权限事实；恢复前校验 registry、权限、租户/工作区和对象状态。
4. 相邻 owner：forms、information-display、query-filters、feedback-states、permissions、responsive、tab-view-navigation、tree-hierarchy 必须链接到新 owner 或说明边界。
5. RED/GREEN 证据包含 expandedItemIds、expansionPolicy、contentState、requestBinding、errorVisibilityBinding、permissionBoundary、persistenceBinding、responsivePolicy 和 `未验证`。

## 风险与取舍

- 不在首版定义视觉样式、间距、动画曲线或具体组件 API。
- 不把 Tree、Tabs、Wizard 都收进 Accordion；语义不同时必须用对应 owner。
- 不禁止保存展开状态，但必须明确为偏好且经过安全恢复。
- 不要求所有内容默认展开；但错误、权限和恢复不能被无提示隐藏。

## 自检

- 范围聚焦：只新增折叠/展开 owner，不替代表单、详情、Tabs、Tree 或响应式 owner。
- 边界清晰：展开状态是 UI 状态；业务值、错误、权限和路由仍归各自 owner。
- 可审计：关键规则可转 exact terms 和 mutation cases。
- 运行时诚实：真实浏览器、键盘、屏幕阅读器、移动端、权限切换、懒加载迟到和表单提交未执行时必须标为 `未验证`。
