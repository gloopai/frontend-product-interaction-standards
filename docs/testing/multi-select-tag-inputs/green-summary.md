# 多选、标签输入与 Tokenized Input 规范 GREEN 证据

本次 GREEN 在新增 primary owner、路由、相邻 owner 边界和交接摘要后执行，目标是证明多选 Select、标签输入、Tokenized Input、chips input、收件人输入、成员多选、创建标签、自由文本 token、批量粘贴、异步多值检索和移动端承载已经具备可执行约束。

- primary owner：已新增 `references/multi-select-tag-inputs.md`，作为多值输入唯一事实来源。
- 状态模型：`multiValueInputState` 已要求声明 `multiValueOwnerId valueKind committedValues draftTokens queryState candidateOptions creationPolicy pastePolicy commitPolicy validationState permissionBoundary feedbackBinding responsivePolicy`。
- 草稿与提交：规范已区分 `query`、`active option`、已提交值和草稿 token，禁止把输入过程误当提交结果。
- 创建流程：规范已声明 `创建标签` 不等于字段提交，`服务端创建成功` 不等于表单保存、筛选应用或设置生效。
- 键盘行为：规范已约束 `Backspace` 在 query 非空时只编辑 query，并要求二次 Backspace 才明确删除 token。
- 粘贴流程：规范已声明 `批量粘贴` 不能直接提交，必须先解析、复核和确认。
- 去重策略：规范已声明重复判断必须基于 `稳定业务键`，不能只基于显示标签。
- 异步收敛：规范已约束 `迟到结果` 和 `旧搜索结果` 必须绑定仍 live 的 owner、权限版本、租户/工作区和草稿代次后再写回。
- 失效值：规范已要求 `orphaned invalid` token 不得静默清除，必须展示原因、影响和处理入口。
- 权限边界：规范已要求无权或未启用时相关 `DOM、state、handler、request 和快捷键入口为 0`。
- 移动端承载：规范已要求 `移动端` 不得删除已选摘要、搜索、候选列表、创建入口、粘贴解析、错误说明、删除、清空、应用/取消、权限原因、重试和恢复能力。
- 运行时边界：本次执行的是静态规范审计；真实点击、键盘、粘贴、权限切换、网络迟到和移动端视口检查仍需在具体项目里执行，未执行时必须标记为 `未验证`。
