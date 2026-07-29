# 关键词搜索输入交互规范设计

## 背景

管理台里最常见的输入之一是“搜索一下”：列表顶部关键词搜索、局部对象搜索、筛选栏里的文本条件、搜索框清空、输入后自动请求、按 Enter 提交、移动端键盘遮挡、IME 输入法 composition、URL 恢复和返回恢复。这类控件看起来简单，但最容易出现几个灰色地带：

- 输入每个字符就请求，导致结果、URL、数量、批量范围和 loading 抖动。
- 中文/日文/韩文输入法 composition 未结束时按 Enter，被误当成搜索提交。
- 清空按钮既清 query 又清已应用搜索，或者只清 UI 不清结果。
- debounce 迟到请求写回新 owner、新租户、新权限或新 route。
- 移动端键盘弹起后搜索框、清空、提交、取消、错误和结果摘要被遮挡。
- 列表关键词搜索、全局搜索、Select 内部搜索、命令面板搜索的 owner 边界不清。

现有 `query-filters.md` 已要求关键词搜索声明最小输入策略、防抖、清空策略和提交边界，但它负责查询意图和已应用条件，不适合继续吞掉输入框内部状态。现有 `search-command-palette.md` 负责全局搜索、命令面板、结果分组和命令执行，也不应约束普通列表关键词字段。需要新增一个职责更窄的 owner。

## 范围

新增 `references/keyword-search-inputs.md`，作为以下场景的 primary owner：

- 列表、表格、报表、审计日志、任务中心、文件库、成员页和管理台记录页中的关键词搜索输入。
- 筛选栏内单个文本搜索条件、局部对象搜索框、页面内搜索框、即时搜索框、显式提交搜索框。
- 支持防抖、最小输入长度、清空、重置、提交、取消、URL 恢复、历史恢复、搜索建议但不进入全局结果页的轻量搜索输入。
- 移动端搜索输入在 toolbar、filter bar、Drawer、Bottom Sheet、独立搜索页或列表顶部的承载。

不覆盖：

- 全局搜索、站内搜索页、命令面板、快速跳转、动作搜索和 AI 搜索；继续由 `references/search-command-palette.md` 负责。
- Select / Combobox 的 option 搜索、active option、popup 和 Drawer；继续由 `references/selects-comboboxes.md` 负责。
- 多选标签、tokenized input、收件人 chips 和批量粘贴 token；继续由 `references/multi-select-tag-inputs.md` 负责。
- 表单提交、字段错误摘要、dirty/touched；继续由 `references/forms.md` 负责。
- 查询条件整体的 `filterDraft`、`appliedFilters`、URL 安全和结果请求快照；继续由 `references/query-filters.md` 负责。

## 推荐方案

采用独立 owner：`keywordSearchInputState`。

我不建议把这组规则继续放进 `query-filters.md`，因为这样会把“字段内部 query 草稿”和“已应用查询条件”混在一起；也不建议放进 `search-command-palette.md`，因为全局搜索和命令执行的权限、历史、结果分组太重，会污染普通列表搜索框。独立 owner 更干净：它只输出合法的 keyword value 或 search intent candidate，让筛选、表格、搜索页等上层 owner 决定何时应用。

### 方案对比

1. 独立 keyword owner（推荐）
   - 优点：边界清楚；能精确约束 IME、debounce、clear、Enter、mobile keyboard；列表、报表、审计日志接入时都能复用。
   - 代价：需要新增路由、相邻 owner 链接和专项审计。

2. 扩展 query-filters
   - 优点：实现改动少，关键词搜索常见于筛选栏。
   - 代价：字段内部状态会污染筛选 owner；页面内搜索、局部搜索、非筛选搜索仍然不好归属。

3. 扩展 search-command-palette
   - 优点：名字上都叫 search。
   - 代价：全局搜索/命令面板规则太重；会把普通输入框误要求结果分组、命令绑定、历史策略和 AI 边界。

## 状态模型

新 owner 定义 `keywordSearchInputState`，至少包含：

- `keywordOwnerId`：当前搜索输入稳定身份。
- `surfaceKind`：`list-keyword`、`filter-keyword`、`local-search`、`table-search`、`report-search`、`drawer-search`、`mobile-search-page`。
- `inputDraft`：用户正在编辑的原始文本。
- `normalizedDraft`：按声明规则 trim、大小写、空白折叠、全半角、停用词或特殊字符处理后的候选值。
- `committedKeyword`：已明确提交给上层 owner 的关键词。
- `compositionState`：IME composition 是否进行中、composition 文本、最近一次 composition end 代次。
- `submitPolicy`：`explicit`、`debounced-immediate`、`on-blur`、`enter-and-button`，以及最小长度和空值策略。
- `debounceState`：防抖计时器、请求代次、等待原因、取消和 flush 策略。
- `clearPolicy`：清空草稿、清空已提交关键词、恢复默认关键词、取消在途请求之间的差异。
- `requestBinding`：若输入框 owner 自己发建议或轻量搜索请求，必须绑定 owner、query、权限版本、租户/工作区、route 和代次。
- `historyBinding`：是否写最近关键词、URL、local state、浏览器历史或保存视图；敏感关键词默认禁止持久化。
- `permissionBoundary`：输入、建议、提交、清空、历史、URL 和请求的权限边界。
- `feedbackBinding`：loading、empty、too-short、invalid、error、stale、permission-denied、cleared、submitted 的反馈归属。
- `responsivePolicy`：移动端、虚拟键盘、safe-area、固定 toolbar、底部操作和结果摘要可达性。

核心不变量：

- 输入草稿不等于已提交关键词。
- normalizedDraft 不等于 committedKeyword。
- composition 未结束时 Enter 不得提交。
- debounce 到期不等于用户明确提交，除非 `submitPolicy` 明确声明即时策略。
- 清空草稿、清空已提交关键词、重置默认关键词、取消请求必须是不同意图。

## 行为规则

### 输入、提交与 IME

普通输入只更新 `inputDraft` 和 `normalizedDraft`。提交只能来自符合 `submitPolicy` 的明确动作：点击搜索按钮、按 Enter 且 composition 已结束、清空后明确应用空关键词、on-blur 策略的合法 blur，或 debounced-immediate 策略的合法防抖触发。

IME 输入法是硬边界：compositionstart 到 compositionend 之间，Enter、Space、方向键和候选选择优先归输入法；不得触发搜索提交、表格请求、URL 写入、历史写入、结果清空或按钮 loading。compositionend 后如需自动搜索，也必须重新走 `submitPolicy` 和 debounce gate。

### 防抖、最小长度与请求

即时搜索必须声明最小长度、空值策略、防抖时长、最大请求频率、请求取消、迟到结果处理和重复值合并。没有声明时默认 `explicit`，不得输入即请求。

防抖请求必须绑定 `keywordOwnerId`、normalized query、权限版本、租户/工作区、route、surfaceKind 和请求代次。迟到结果只能写回仍 live 且身份匹配的 owner；旧请求不得覆盖新 keyword、URL、结果、loading、empty、错误、焦点或 aria-describedby。

### 清空、重置与取消

搜索输入至少需要区分四个动作：

- 清空草稿：只清 `inputDraft`，不改变 `committedKeyword` 和结果。
- 清空已提交关键词：提交空关键词或移除该条件，由上层 owner 产生新查询意图。
- 重置默认关键词：恢复产品声明的默认关键词，若默认不存在则说明无默认。
- 取消输入：丢弃草稿，恢复到 `committedKeyword` 的展示。

清空按钮不能靠一个 `onClear` 同时猜测四种意图。移动端尤其要保留取消/返回和清空的区别；“取消”不得偷偷应用当前草稿。

### URL、历史与敏感词

只有上层 owner 允许且关键词明确 `urlSafe` 时，`committedKeyword` 才能进入 URL。`inputDraft`、composition 文本、未提交 normalizedDraft、敏感自由文本、邮箱、手机号、内部 ID、令牌、密钥、个人识别信息和权限范围不得写入 URL、页面标题、日志、analytics、最近搜索或保存视图。

浏览器返回、URL 恢复或保存视图恢复时，必须先解析版本、权限、租户/工作区和敏感策略；无效、过期或无权限关键词不能静默忽略，要进入可见恢复状态。

### 可访问性与反馈

输入框必须有可见 label 或等价可访问名称；placeholder 不能是唯一 label。清空、搜索、取消、重置和重试按钮必须说明动作对象。loading、too-short、invalid、error、permission-denied、cleared 和 submitted 只能由一个 primary owner 完整播报，不能同时由字段、Toast、结果摘要和全局 live region 重复播报。

Enter 行为必须可解释：当草稿为空、低于最小长度、composition 中、请求中、无权限或与当前提交值相同时，必须阻止或合并提交，并给出可感知反馈或禁用原因。

### 移动端与响应式

移动端可以把搜索框放进 toolbar、filter Drawer、Bottom Sheet、全屏搜索页或独立页，但不得删除输入、清空、提交、取消/返回、错误说明、权限原因、loading、结果摘要和恢复路径。

虚拟键盘打开时，当前输入、清空、提交、取消、错误和结果摘要不能被固定 toolbar、底部按钮、安全区域或键盘完全遮挡。移动端返回手势、系统返回和路由返回必须声明是取消草稿、保留草稿还是应用已提交关键词；不能让返回键隐式提交未完成输入。

## 相邻 owner 关系

- `references/query-filters.md`：当关键词作为筛选条件时，本 owner 输出合法 `committedKeyword`，query-filters 决定何时写入 `filterDraft` / `appliedFilters` 和 URL。
- `references/data-tables.md`：表格只读取上层结果 owner 的查询快照，不直接读取 `inputDraft`。
- `references/search-command-palette.md`：全局搜索、命令面板和搜索结果页仍由该 owner 负责；本 owner 只负责轻量关键词输入字段。
- `references/forms.md`：关键词输入作为表单字段时，只把 `committedKeyword` 作为字段业务值；inputDraft 与 compositionState 不进入表单 dirty 或 submit payload。
- `references/responsive-adaptive.md`：移动端键盘、safe-area、动态 viewport、缩放和断点转换仍执行响应式规范。
- `references/buttons.md`：搜索、清空、取消、重置和重试按钮仍执行按钮规范，尤其是 loading、防重复、禁用原因和可访问名称。

## 路由触发词

`SKILL.md` 应新增路由，命中：

- 中文：关键词搜索、搜索输入、搜索框、文本搜索、列表搜索、表格搜索、报表搜索、局部搜索、页面内搜索、筛选搜索、即时搜索、防抖搜索、搜索清空、清空搜索、搜索重置、输入法搜索、中文输入法搜索、IME 搜索、搜索建议、搜索历史、最近关键词、搜索 URL。
- English：keyword search、search input、search box、text search、list search、table search、report search、local search、in-page search、filter search、instant search、debounced search、search clear、clear search、reset search、IME search、composition search、search suggestion、search history、recent keyword、search URL。

## 可执行验收方向

实施计划需要新增 Ruby 审计，至少覆盖：

1. owner 文件存在，且包含完整 `keywordSearchInputState` 字段。
2. 精确规则：输入草稿不等于已提交关键词；composition 未结束时 Enter 不得提交；没有声明 submitPolicy 时默认 explicit；防抖请求必须绑定 owner/query/权限/租户/route/代次；清空草稿、清空已提交关键词、重置默认关键词、取消输入是不同意图。
3. URL/历史敏感边界：inputDraft、composition 文本和敏感关键词不得进入 URL、标题、日志、analytics、最近搜索或保存视图。
4. 移动端规则：不得删除输入、清空、提交、取消/返回、错误说明、权限原因、loading、结果摘要和恢复路径。
5. 相邻 owner：query-filters、search-command-palette、forms、data-tables、buttons、responsive-adaptive 必须链接到新 owner 或说明边界。
6. RED/GREEN 证据包含 IME、debounce、clear/reset/cancel、URL/history、late result、mobile keyboard、permission 和 `未验证`。

## 风险与取舍

- 不在首版定义搜索算法、分词、排序、索引、拼音匹配、高亮算法或后端接口；这些不是交互规范的职责。
- 不强制所有搜索都显式提交。低成本局部搜索可以使用 `debounced-immediate`，但必须声明最小长度、防抖和请求边界。
- 不禁止搜索建议，但建议不得写成 committedKeyword，也不得污染 URL、历史或结果快照。
- 不把全局搜索降级为普通输入框；全局搜索仍需要搜索与命令面板 owner 的结果、历史、权限和命令规则。

## 自检

- 范围聚焦：本 spec 只新增关键词搜索输入 owner，不修改全局搜索、Select 搜索、多选标签或查询筛选整体模型。
- 边界清晰：字段内部草稿由新 owner 负责，已应用条件仍由 query-filters 负责。
- 可审计：所有关键规则都可转成 exact terms 和 mutation cases。
- 运行时诚实：真实浏览器、IME、移动端键盘、权限切换和网络迟到未执行时必须标为 `未验证`。
