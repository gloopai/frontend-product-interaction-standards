# 日期、时间、时间范围与时区交互规范设计

## 背景

日期和时间控件在管理台中出现频率很高，常见于查询筛选、报表仪表盘、导出任务、审计日志、过期时间、计划任务和权限有效期。现有规范已在查询条件、管理台、导入导出、反馈状态中零散提到日期范围、刷新时间、数据延迟和过期状态，但缺少一个统一 owner 来约束日期时间值如何表达、提交、序列化、跨时区展示和进入请求。

这类问题很隐蔽：同一个“今天”在用户本地时区、业务时区和服务端 UTC 中可能不是同一天；“结束时间”如果没有声明闭区间或开区间，会造成报表多算或漏算；页面停留一晚后“近 7 天”如果自动漂移，会让用户看到与已应用筛选不一致的结果；移动端如果把日期选择器简单塞进 Dialog，容易出现浮层裁切、键盘遮挡和底部按钮不可达。

## 目标

新增 `references/date-time-ranges.md`，作为日期、时间、日期范围、日期时间范围、快捷范围和时区交互的唯一 owner。该 owner 不替代 `references/forms.md`、`references/query-filters.md`、`references/admin-console.md` 或 `references/responsive-adaptive.md`，而是在它们涉及时间语义时提供更严格的横切规则。

## 范围

- Date Picker、Date Range Picker、DateTime Picker、DateTime Range Picker、Time Picker。
- 月、季度、年等粗粒度选择。
- 今天、昨天、本周、本月、近 7 天、近 30 天等快捷范围。
- 用户展示时区、业务时区、存储时区和请求时区。
- 查询筛选、报表、导出、审计日志、计划任务、过期时间和数据刷新时间。
- PC、移动端、窄屏、虚拟键盘和触摸场景中的日期时间控件转换。

## 非目标

- 不规定具体组件库或日期库。
- 不规定后端存储格式的技术实现，只规定前端必须暴露和绑定的语义。
- 不扩展具体业务日历，如交易日、工作日、节假日或财年；这些必须由业务 owner 明确声明。

## 设计原则

1. **时间值不能含糊**：任何进入请求、URL、报表或审计的日期时间值都必须声明展示时区、存储/请求时区、边界语义和粒度。
2. **范围必须可复现**：范围推荐使用 `[start, end)`，否则必须明确声明 inclusive/exclusive 规则；快捷范围必须冻结应用时的 anchor。
3. **草稿与已应用分离**：输入、选择、快捷项预览和弹层焦点属于控件内部状态，只有合法提交后的业务值才能进入表单、筛选、URL 或请求。
4. **时区是可见语义，不是隐藏实现**：跨时区、跨 DST、跨日期边界的场景必须给用户可理解的展示和确认。
5. **移动端改变承载，不改变语义**：Dialog、Drawer、Bottom Sheet 或独立页可以转换，但不能删除清空、重置、快捷范围、错误说明、时区说明和提交边界。

## 状态模型

规范新增 `dateTimeState`，至少包含：

- `dateTimeOwnerId`：日期时间控件 owner。
- `valueKind`：`date | time | datetime | dateRange | datetimeRange | month | quarter | year | relativeRange`。
- `inputMode`：`calendar | text | select | segmentedPreset | mixed`。
- `displayTimezone`：用户看到和理解的时区。
- `storageTimezone`：进入请求、存储、导出或审计时使用的时区或 UTC 策略。
- `rangeBoundary`：`[start, end)`、`[start, end]`、`(start, end]` 或单点值语义。
- `granularity`：`minute | hour | day | week | month | quarter | year`。
- `presetPolicy`：快捷范围列表、是否允许自定义、是否允许相对范围。
- `relativeAnchor`：快捷范围应用时冻结的基准时间。
- `validationState`：空值、部分范围、格式错误、越界、`end < start`、DST 冲突等状态。
- `urlSerialization`：是否 `urlSafe`、格式版本、编码方式和恢复策略。
- `requestBinding`：进入请求时的字段名、格式、边界转换和幂等快照。
- `localePolicy`：展示格式、输入格式、周起始日、12/24 小时制和语言环境。

## 核心规则族

### DTR-SCOPE：职责与适用范围

- 日期时间控件必须有明确 owner；不得把日期格式化、范围边界和请求转换散落在页面组件、表格列、导出按钮或请求函数中。
- 涉及业务范围、权限范围、导出范围或审计范围时，必须能回溯当时应用的日期时间快照。

### DTR-STATE：状态分离

- 输入草稿、弹层焦点、hover 日期、键盘高亮、快捷项预览和已提交业务值必须分离。
- 未完整范围不得进入 `appliedFilters`、URL、请求或报表摘要；除非产品显式定义“开放开始”或“开放结束”的业务语义。

### DTR-RANGE：范围边界

- 范围推荐使用 `[start, end)`，尤其是按日、按月、按季度和按年汇总。
- 如果使用闭区间结束值，必须说明结束日是否包含整天、是否转换为下一粒度起点，以及如何避免毫秒级或秒级漏算。
- `end < start` 必须进入字段错误，不得自动交换开始和结束。

### DTR-PRESET：快捷范围

- 今天、昨天、本周、本月、近 7 天和近 30 天必须声明业务时区、周起始日和粒度。
- 快捷范围必须冻结应用时的 `relativeAnchor`；页面停留期间，同一已应用查询不得随时间自动漂移。
- 若用户重新点击快捷项、刷新页面或从 URL 恢复，必须明确是恢复原快照还是按当前时间重新计算。

### DTR-TZ：时区与 DST

- 用户展示时区和存储/请求时区必须分离；不得把本地字符串直接作为服务端时间含义。
- 跨 DST 的日期、时间和范围必须可解释；不存在的本地时间、重复的本地时间、跨日边界必须进入可见校验或明确转换策略。
- 报表、导出、审计日志和任务回执必须展示使用的时区；不能只显示无时区的时间戳。

### DTR-VALID：校验与错误恢复

- 空值、必填缺失、部分范围、格式错误、越界、不可选日期、`end < start`、DST 冲突和权限范围冲突必须有可区分错误。
- 错误归属控件 owner；不能只靠 Toast 或禁用提交按钮解释。
- 清空、重置、取消和应用必须是不同意图。

### DTR-URL：URL 与恢复

- 只有明确 `urlSafe` 的日期时间值可以进入 URL。
- URL 中的日期时间值必须带格式版本、时区或可还原的时区策略。
- 无效、过期、权限不可用或业务日历变化导致无法恢复的时间值，必须进入可见失效状态并提供移除、替换或回到默认路径。

### DTR-REPORT：报表、导出与审计

- 报表、导出和审计必须携带范围快照、时区、数据延迟和刷新时间。
- 指标卡、图表、明细表、导出任务和页面摘要必须共享同一日期时间快照；不得各自重新计算“当前范围”。
- 导出任务必须记录提交时的日期时间范围、筛选快照、时区、生成时间、过期时间和下载身份。

### DTR-A11Y：可访问性与可理解性

- 日期时间字段必须有标签、格式提示、错误说明和键盘路径。
- 范围选择必须可被读屏理解为开始、结束和当前选择状态。
- 用户可见文案使用“今天”“昨天”“近 7 天”等相对时间时，报表、审计、导出和回执中必须补充绝对日期，避免离线阅读时失真。

### DTR-RSP：移动端与响应式

- 移动端可以把复杂日期时间 Dialog 转换为 Bottom Drawer、Bottom Sheet 或独立页。
- Select、Calendar、Time Picker 等子浮层在移动端可以转换为底部选择器，但必须继承原 owner 的 `selectedValue`、`query`、`activeOption`、`validationState` 和提交边界。
- 移动端不得删除清空、重置、快捷范围、错误说明或时区说明。

### DTR-LIFE：生命周期与请求绑定

- 已应用时间范围进入请求前必须生成快照；请求返回只能写回匹配快照的结果区域。
- 刷新、重试、导出、切换分页、切换报表 tab 和浏览器返回必须复用或显式替换同一日期时间快照。
- 页面卸载、弹层关闭或控件销毁不得遗留悬空定时器、异步解析或过期 popup。

## 与现有 owner 的关系

- `references/query-filters.md` 继续负责筛选草稿、已应用条件、URL 筛选和结果绑定；本 owner 负责其中日期时间值的语义。
- `references/forms.md` 继续负责字段 dirty/touched、错误摘要和提交；本 owner 负责日期时间字段的边界、格式、时区和范围校验。
- `references/admin-console.md` 继续负责管理台权限、审计、导入导出和报表一致性；本 owner 负责报表和任务中时间范围快照的不可含糊表达。
- `references/responsive-adaptive.md` 继续负责跨端转换；本 owner 负责日期时间控件在转换后语义不丢失。
- `references/overlays-menus-tooltips.md` 继续负责浮层定位与层级；本 owner 负责日期时间 popup、快捷范围菜单和移动端替代承载的业务状态。

## 路由关键词

中文关键词：日期、时间、日期范围、时间范围、日期时间、日期选择、时间选择、日期时间选择、时区、快捷时间、快捷日期、今天、昨天、本周、本月、近 7 天、近 30 天、开始时间、结束时间、过期时间、刷新时间、数据延迟、审计时间、导出时间范围。

English keywords: date, time, date range, time range, datetime, date picker, time picker, timezone, time zone, preset range, relative range, today, yesterday, this week, this month, last 7 days, last 30 days, start date, end date, expiry, refresh time, data latency, audit time, export range.

## 验收设计

新增 `docs/testing/date-time-ranges/date-time-ranges-audit.rb`：

- 检查 owner 文件包含 `dateTimeState` 和所有状态字段。
- 检查范围边界、快捷范围冻结、时区、DST、URL、报表导出审计、移动端转换和未验证边界。
- 检查 `SKILL.md` 路由包含中英文关键词并指向 `references/date-time-ranges.md`。
- 检查 `README.md` 和 `HANDOFF.md` 包含摘要与引用。
- 使用负向变异删除关键规则，确保审计失败。
- 使用项目泄漏扫描，确保规范不绑定 `fex-admin` 或当前项目实现。

## 风险与处理

- **规则过宽导致重复**：owner 只写日期时间语义，不重写筛选、表单、管理台的完整规则。
- **快捷范围争议**：不规定业务必须使用哪些快捷项，但使用后必须声明 anchor、时区和粒度。
- **时区展示复杂**：允许业务选择只读展示或显式可切换，但必须声明 display/storage/request 语义。
- **移动端承载争议**：不强制所有日期控件使用 Bottom Sheet；只要求转换后保留状态、错误、清空、重置和提交边界。

## 明确非验证项

本次是规范与静态审计更新，不执行具体项目运行时 UI 检查。任何应用到实际项目的日期时间控件仍必须单独验证点击、键盘、滚动、时区、DST、视口和请求绑定；未执行这些检查时必须标为未验证。
