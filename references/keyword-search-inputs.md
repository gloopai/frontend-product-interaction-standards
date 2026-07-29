# 关键词搜索输入交互规范

## 适用范围

本文件是关键词搜索、搜索输入、搜索框、文本搜索、列表搜索、表格搜索、报表搜索、局部搜索、页面内搜索、筛选搜索、即时搜索、防抖搜索、搜索清空、清空搜索、搜索重置、输入法搜索、中文输入法搜索、IME 搜索、搜索建议、搜索历史、最近关键词、搜索 URL、keyword search、search input、search box、text search、list search、table search、report search、local search、in-page search、filter search、instant search、debounced search、search clear、clear search、reset search、IME search、composition search、search suggestion、search history、recent keyword 和 search URL 的 primary owner。

本文件只负责关键词搜索输入字段内部状态：用户正在输入什么、何时提交为关键词、怎样防抖、怎样清空、如何处理 IME、如何保护 URL/历史、如何在移动端保留核心能力。它不定义搜索算法、索引、排序、分词、高亮、后端接口或结果展示结构。

## 与其他 owner 的关系

- 全局搜索、站内搜索页、命令面板、快速跳转、动作搜索、结果分组、命令执行和 AI 搜索继续执行 `references/search-command-palette.md`。
- Select / Combobox option 搜索、active option、popup、Drawer 和提交值继续执行 `references/selects-comboboxes.md`。
- 多选标签、tokenized input、收件人 chips、批量粘贴 token 和多值远程检索继续执行 `references/multi-select-tag-inputs.md`。
- 关键词作为筛选条件时，本 owner 只输出 `committedKeyword`，`references/query-filters.md` 决定何时写入 `filterDraft`、`appliedFilters` 和 URL。
- 关键词输入作为表单字段时，字段值、错误摘要、dirty/touched 和提交仍执行 `references/forms.md`。
- 搜索、清空、取消、重置和重试按钮仍执行 `references/buttons.md`。
- 表格结果、分页、排序、选择和批量范围仍执行 `references/data-tables.md`，并只读取上层 owner 的已应用查询快照。
- 移动端虚拟键盘、safe-area、动态 viewport、缩放、断点和触摸目标仍执行 `references/responsive-adaptive.md`。

## `keywordSearchInputState`

每个关键词搜索输入必须维护 `keywordSearchInputState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `keywordOwnerId` | 当前搜索输入稳定身份，用于绑定输入、composition、防抖、请求、URL、历史、焦点和反馈。 |
| `surfaceKind` | 承载类型：`list-keyword`、`filter-keyword`、`local-search`、`table-search`、`report-search`、`drawer-search`、`mobile-search-page`。 |
| `inputDraft` | 用户正在编辑的原始文本，包括尚未提交的输入和恢复草稿。 |
| `normalizedDraft` | 按产品声明规则处理后的候选文本，例如 trim、大小写、空白折叠、全半角或特殊字符处理。 |
| `committedKeyword` | 已明确提交给上层 owner 的关键词，才可影响结果、URL、标题、历史或查询快照。 |
| `compositionState` | IME composition 是否进行中、composition 文本、最近一次 composition end 代次和提交门禁。 |
| `submitPolicy` | 提交策略：`explicit`、`debounced-immediate`、`on-blur`、`enter-and-button`，以及最小长度和空值策略。 |
| `debounceState` | 防抖计时器、请求代次、等待原因、取消策略、flush 策略和重复值合并。 |
| `clearPolicy` | 清空草稿、清空已提交关键词、重置默认关键词、取消输入和取消在途请求之间的差异。 |
| `requestBinding` | 建议或轻量搜索请求绑定的 owner、query、权限版本、租户/工作区、route、surfaceKind 和请求代次。 |
| `historyBinding` | 是否写 URL、浏览器历史、最近关键词、搜索历史、本地状态或保存视图，以及敏感词策略。 |
| `permissionBoundary` | 输入、建议、提交、清空、历史、URL、请求和结果摘要的权限边界。 |
| `feedbackBinding` | loading、empty、too-short、invalid、error、stale、permission-denied、cleared、submitted 的反馈归属。 |
| `responsivePolicy` | 移动端、虚拟键盘、safe-area、固定 toolbar、底部操作、结果摘要和恢复路径可达性。 |

输入草稿不等于已提交关键词。
normalizedDraft 不等于 committedKeyword。
composition 未结束时 Enter 不得提交。
debounce 到期不等于用户明确提交，除非 `submitPolicy` 明确声明即时策略。
清空草稿、清空已提交关键词、重置默认关键词、取消输入必须是不同意图。

## 输入、提交与 IME

普通输入只更新 `inputDraft` 和 `normalizedDraft`。

提交只能来自符合 `submitPolicy` 的明确动作：点击搜索按钮、composition 已结束后的 Enter、清空后明确应用空关键词、`on-blur` 策略声明的合法 blur，或 `debounced-immediate` 策略声明的合法防抖触发。hover、focus、placeholder 变化、方向键、输入法候选高亮、自动聚焦、历史项预览和结果摘要展开都不得提交。

IME 输入法是硬边界。
compositionstart 到 compositionend 之间，Enter、Space、方向键和候选选择优先归输入法。
不得触发搜索提交、表格请求、URL 写入、历史写入、结果清空或按钮 loading。

compositionend 后如果产品希望自动搜索，也必须重新经过 `submitPolicy`、最小长度、权限和 debounce gate。不得把 compositionend 当成隐藏提交，也不得把输入法候选文本写入最近关键词或 URL。

## 防抖、最小长度与迟到请求

没有声明时默认 `explicit`，不得输入即请求。

即时搜索必须声明最小长度、空值策略、防抖时长、最大请求频率、请求取消、迟到结果处理和重复值合并。低成本局部搜索可以使用 `debounced-immediate`，但需要说明何时更新 loading、结果、empty、错误和历史。

防抖请求必须绑定 `keywordOwnerId`、normalized query、权限版本、租户/工作区、route、surfaceKind 和请求代次。
迟到结果只能写回仍 live 且身份匹配的 owner。

输入继续变化、route 变化、owner 卸载、权限变化、租户/工作区切换、surfaceKind 变化或 committedKeyword 变化后，旧防抖、旧请求、旧错误、旧 loading、旧焦点目标和旧 aria-describedby 必须失效或重新证明安全。重复 Enter、重复点击、重复 blur 或防抖回放不得生成多个等价提交。

## 清空、重置与取消

清空草稿只清 `inputDraft`，不改变 `committedKeyword`、结果、URL、最近关键词或上层查询快照。

清空已提交关键词提交空关键词或移除该条件，由上层 owner 产生新的查询意图、结果快照或恢复默认状态。

重置默认关键词恢复产品声明的默认关键词；没有默认关键词时，必须说明无默认，不得含糊地清空全部条件。

取消输入丢弃当前草稿，恢复到 `committedKeyword` 的展示；移动端返回、系统返回、Drawer 关闭或路由返回都必须声明它们是取消草稿、保留草稿还是仅返回结果页。

清空按钮不能靠一个 `onClear` 同时猜测四种意图。

清空、重置、取消、提交和重试都必须有明确动作对象和可感知反馈。请求中清空时，需要说明是取消当前请求、等待请求自然失效，还是创建新的空关键词请求。

## URL、历史与敏感词

只有上层 owner 允许且关键词明确 `urlSafe` 时，`committedKeyword` 才能进入 URL。`inputDraft`、composition 文本、未提交 normalizedDraft、敏感自由文本、邮箱、手机号、内部 ID、令牌、密钥、个人识别信息和权限范围不得写入 URL、页面标题、日志、analytics、最近搜索或保存视图。

浏览器返回、URL 恢复、保存视图恢复或最近关键词恢复时，必须先解析版本、权限、租户/工作区、敏感策略和默认策略；无效、过期或无权限关键词不能静默忽略，要进入可见恢复状态。

最近关键词和搜索历史必须声明存储范围、清除路径、跨租户隔离、权限复核和过期策略。清除后不得通过刷新、离线缓存、旧回调或浏览器返回重新出现。

## 可访问性与反馈

placeholder 不能是唯一 label。

输入框必须有可见 label 或等价可访问名称；帮助、最小长度、敏感说明、错误和状态文本通过稳定描述关联到当前存活输入。搜索、清空、取消、重置和重试按钮必须有动作对象，例如“清空当前搜索草稿”“搜索关键词”“取消关键词编辑”。

loading、too-short、invalid、error、permission-denied、cleared 和 submitted 只能由一个 primary owner 完整播报。

Enter 行为必须可解释：当草稿为空、低于最小长度、composition 中、请求中、无权限、与当前提交值相同或当前 owner 已失效时，必须阻止、合并或延后提交，并给出可感知反馈或禁用原因。颜色、图标、placeholder、hover tooltip 或 Toast 不能成为唯一错误说明。

## 移动端与虚拟键盘

移动端不得删除输入、清空、提交、取消/返回、错误说明、权限原因、loading、结果摘要和恢复路径。
虚拟键盘打开时，当前输入、清空、提交、取消、错误和结果摘要不能被固定 toolbar、底部按钮、安全区域或键盘完全遮挡。

移动端可以把搜索输入放入 toolbar、filter Drawer、Bottom Sheet、全屏搜索页或独立页，但必须保留当前 `keywordSearchInputState`。横竖屏、动态 viewport、系统字体放大、200% 缩放、触摸输入和 safe-area 变化不得重置草稿、提交关键词、防抖请求、错误或结果摘要。

移动端返回手势、系统返回和路由返回必须声明行为：取消草稿、保留草稿、返回结果、关闭承载面或维持 committedKeyword。不能让返回键隐式提交未完成输入。

## 完成前检查

- 是否声明完整 `keywordSearchInputState`，并包含 `keywordOwnerId`、`surfaceKind`、`inputDraft`、`normalizedDraft`、`committedKeyword`、`compositionState`、`submitPolicy`、`debounceState`、`clearPolicy`、`requestBinding`、`historyBinding`、`permissionBoundary`、`feedbackBinding` 和 `responsivePolicy`。
- 是否验证 `inputDraft`、`normalizedDraft`、`committedKeyword`、composition 文本和已提交关键词分离。
- 是否验证 IME composition 未结束时 Enter 不得提交。
- 是否验证 debounce 请求绑定、最小长度、空值策略、重复值合并和迟到结果处理。
- 是否验证清空草稿、清空已提交关键词、重置默认关键词和取消输入是不同意图。
- 是否验证 URL、搜索历史、最近关键词和保存视图不会保存未提交草稿、composition 文本或敏感关键词。
- 是否验证 placeholder 不是唯一 label，搜索、清空、取消、重置和重试按钮都有动作对象。
- 是否验证 loading、too-short、invalid、error、permission-denied、cleared 和 submitted 只由一个 primary owner 完整播报。
- 是否验证移动端虚拟键盘下输入、清空、提交、取消、错误、权限原因、loading、结果摘要和恢复路径仍可达。
- 真实浏览器、真实 IME、移动端虚拟键盘、权限切换、网络迟到、读屏和触摸检查未执行时，必须标记 `未验证`。
