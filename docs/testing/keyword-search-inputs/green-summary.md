# 关键词搜索输入规范 GREEN 证据

本次 GREEN 在新增 primary owner、路由、相邻 owner 边界和交接摘要后执行，目标是证明关键词搜索、搜索输入、搜索框、文本搜索、列表搜索、表格搜索、报表搜索、局部搜索、页面内搜索、筛选搜索、即时搜索、防抖搜索、搜索清空、搜索重置、IME 搜索、搜索建议、搜索历史、最近关键词、搜索 URL 和移动端搜索输入已经具备可执行约束。

- primary owner：已新增 `references/keyword-search-inputs.md`，作为关键词搜索输入唯一事实来源。
- 状态模型：`keywordSearchInputState` 已要求声明 `keywordOwnerId surfaceKind inputDraft normalizedDraft committedKeyword compositionState submitPolicy debounceState clearPolicy requestBinding historyBinding permissionBoundary feedbackBinding responsivePolicy`。
- 草稿与提交：规范已区分 `输入草稿`、`normalizedDraft`、`committedKeyword` 和 `已提交关键词`。
- 输入法：规范已声明 `IME` / `composition` 期间按 `Enter` 不会触发提交、表格请求、URL 写入、搜索历史写入或结果清空。
- 防抖：规范已声明 `debounce` / `防抖` 请求必须绑定 owner、query、权限、租户、route、surfaceKind 和代次。
- 清空意图：规范已声明 `清空草稿`、`清空已提交关键词`、`重置默认关键词` 和 `取消输入` 是不同意图。
- URL 与历史：规范已要求 `URL`、`搜索历史` 和 `最近关键词` 不保存未提交草稿、composition 文本或敏感关键词。
- 异步收敛：规范已约束 `迟到结果` 只能写回仍 live 且身份匹配的 owner。
- 移动端承载：规范已要求 `虚拟键盘` 打开时，`移动端` 搜索输入、清空、提交、取消/返回、错误、权限原因、loading、结果摘要和恢复路径仍可达。
- 运行时边界：本次执行的是静态规范审计；真实浏览器、IME、移动端虚拟键盘、权限切换、网络迟到、读屏和触摸检查仍需在具体项目里执行，未执行时必须标记为 `未验证`。
