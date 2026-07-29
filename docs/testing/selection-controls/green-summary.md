# 选择控件与开关 GREEN 证据摘要

当前规范和审计证明以下结构已经就位：

- `selectionControlState` 固定包含 owner、控件类型、选项集、草稿值、已提交值、提交模式、三态、权限、风险、反馈、可访问性和响应式策略。
- `draftValue` 与 `committedValue` 必须分离。
- Hover、focus、active、pressed visual、disabled、indeterminate 和 optimistic preview 不得伪装成已提交业务值。
- Switch/Toggle 只能表达可逆、低风险且文案能明确表达开/关后果的设置。
- 危险启停、权限变更、敏感导出、任务取消/重跑、密钥、外部系统影响和不可逆状态必须进入 `risk-actions.md`。
- 确认完成前请求数为 0，且开关状态不得提前翻转为成功。
- 三态 checkbox 的 `indeterminateState` 不能作为可提交业务值。
- Radio Group、Checkbox Group、Toggle Group 和 Segmented Control 必须有组 label 或等价可访问名称。
- 禁用选项必须保留可发现原因。
- 移动端不得删除选项、禁用原因、错误说明、保存/取消、恢复路径或当前已选摘要。
- 真实浏览器、触摸、键盘、屏幕阅读器、权限切换、异步保存和移动端视口仍是未验证。

对应静态审计入口：`ruby docs/testing/selection-controls/selection-controls-audit.rb --mutations`。
