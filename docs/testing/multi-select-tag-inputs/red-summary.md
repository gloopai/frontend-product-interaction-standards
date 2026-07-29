# 多选、标签输入与 Tokenized Input 规范 RED 证据

本次 RED 在新增 primary owner 前执行，目标是证明当前规范库尚未对多选 Select、标签输入、Tokenized Input、chips input、收件人输入、成员多选、创建标签、自由文本 token、批量粘贴、异步多值检索和移动端承载建立可执行约束。

- primary owner：当前缺少 `references/multi-select-tag-inputs.md`，因此无法证明多值输入拥有唯一事实来源。
- 状态模型缺口：缺少完整 `multiValueInputState`，也缺少 `multiValueOwnerId valueKind committedValues draftTokens queryState candidateOptions creationPolicy pastePolicy commitPolicy validationState permissionBoundary feedbackBinding responsivePolicy`。
- 草稿与提交缺口：当前无法证明 `query`、`active option`、已提交值和草稿 token 已分层，存在把输入过程误当提交结果的风险。
- 创建缺口：当前无法证明 `创建标签` 与字段提交分离，也无法证明 `服务端创建成功` 不会被误当成表单保存、筛选应用或设置生效。
- 键盘缺口：当前无法证明 `Backspace` 在 query 非空时只编辑 query，也无法证明二次 Backspace 删除 token 的安全边界。
- 粘贴缺口：当前无法证明 `批量粘贴` 会进入解析、复核和确认流程，而不是直接提交。
- 去重缺口：当前无法证明重复判断基于 `稳定业务键`，而不是仅基于显示标签。
- 异步缺口：当前无法证明 `迟到结果` 和 `旧搜索结果` 会被绑定到仍 live 的 owner 与草稿代次后再写回。
- 失效值缺口：当前无法证明 `orphaned invalid` token 不会被静默清除。
- 权限缺口：当前无法证明无权或未启用时相关 `DOM、state、handler、request 和快捷键入口为 0`。
- 移动端缺口：当前无法证明 `移动端` 不会删除已选摘要、搜索、候选列表、创建入口、粘贴解析、错误说明、删除、清空、应用/取消、权限原因、重试和恢复能力。
- 运行时缺口：本次只执行静态审计，未执行真实点击、键盘、粘贴、权限切换、网络迟到和移动端视口检查，运行时行为仍标记为 `未验证`。
