# 选择控件与开关 RED 证据摘要

这些负向场景必须被规范和审计识别为失败：

- Switch 点击后直接启停危险业务状态，绕过 `risk-actions.md`。
- `selectionControlState` 缺少 owner、控件类型、选项集、草稿值、已提交值、提交模式、三态、权限、风险、反馈、可访问性或响应式策略。
- Switch/Toggle 承载不可逆、外部系统影响、权限变更或任务取消，却声称只是低风险设置。
- `draftValue` 与 `committedValue` 混用，筛选结果、表单提交或设置状态读取未提交草稿。
- Hover、focus、active、pressed visual、disabled、indeterminate 或 optimistic preview 被写成已提交业务值。
- 确认完成前请求数为 0 这条规则被破坏，或者开关状态提前翻转为成功。
- 三态 checkbox 的 `indeterminateState` 被提交给后端。
- Radio Group、Checkbox Group、Toggle Group 或 Segmented Control 没有组 label 或等价可访问名称。
- 禁用选项只靠灰色或 hover tooltip 表达原因，违反“禁用选项必须保留可发现原因”。
- 移动端不得删除选项这条规则被破坏，导致移动端删除禁用原因、错误说明、保存/取消、恢复路径或当前已选摘要。
- 真实浏览器、触摸、键盘、屏幕阅读器、权限切换、异步保存和移动端视口没有执行时，不能写成已验证，必须标为未验证。

对应静态审计入口：`ruby docs/testing/selection-controls/selection-controls-audit.rb --mutations`。
