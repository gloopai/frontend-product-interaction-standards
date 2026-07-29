# 关键词搜索输入规范 RED 证据

本次 RED 在新增 primary owner 前执行，目标是证明当前规范库尚未对关键词搜索、搜索输入、搜索框、文本搜索、列表搜索、表格搜索、报表搜索、局部搜索、页面内搜索、筛选搜索、即时搜索、防抖搜索、搜索清空、搜索重置、IME 搜索、搜索建议、搜索历史、最近关键词、搜索 URL 和移动端搜索输入建立可执行约束。

- primary owner：当前缺少 `references/keyword-search-inputs.md`，因此无法证明关键词搜索输入拥有唯一事实来源。
- 状态模型缺口：缺少完整 `keywordSearchInputState`，也缺少 `keywordOwnerId surfaceKind inputDraft normalizedDraft committedKeyword compositionState submitPolicy debounceState clearPolicy requestBinding historyBinding permissionBoundary feedbackBinding responsivePolicy`。
- 草稿与提交缺口：当前无法证明 `输入草稿`、`normalizedDraft`、`committedKeyword` 和 `已提交关键词` 已分层。
- 输入法缺口：当前无法证明 `IME` / `composition` 期间按 `Enter` 不会触发提交、表格请求、URL 写入、搜索历史写入或结果清空。
- 防抖缺口：当前无法证明 `debounce` / `防抖` 请求绑定 owner、query、权限、租户、route 和代次。
- 清空意图缺口：当前无法证明 `清空草稿`、`清空已提交关键词`、`重置默认关键词` 和 `取消输入` 是不同意图。
- URL 与历史缺口：当前无法证明 `URL`、`搜索历史` 和 `最近关键词` 不会保存未提交草稿、composition 文本或敏感关键词。
- 迟到结果缺口：当前无法证明 `迟到结果` 不能写回新 owner、新权限、新租户或新 route。
- 移动端缺口：当前无法证明 `虚拟键盘` 打开时，`移动端` 搜索输入、清空、提交、取消/返回、错误、权限原因、loading、结果摘要和恢复路径仍可达。
- 运行时缺口：本次只执行静态审计，未执行真实浏览器、IME、移动端虚拟键盘、权限切换、网络迟到、读屏或触摸检查，运行时行为仍标记为 `未验证`。
