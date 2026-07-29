# 危险操作与恢复 RED 证据摘要

这些负向场景必须被规范和审计识别为失败：

- 没有 `riskActionState`，或缺少 `riskLevel`、`impactScope`、`confirmationPolicy`、`requestIdentity`、`undoPolicy`、`cancelPolicy`、`resultReceipt`、`auditBinding`。
- 危险操作只靠颜色、图标、Tooltip 或按钮位置表达风险，没有可读影响范围。
- 二次确认只有“确定 / 取消”“是 / 否”“提交 / 返回”等裸词，没有动作、对象、数量和关键后果。
- 未满足 `confirmationPolicy` 前就发送请求，请求数不是 0。
- `typed-confirm` 要求用户输入内部 ID、随机 token 或不可读字符串，或者错误输入也能通过。
- 撤销只是 Toast 装饰，没有 `undoPolicy`、撤销窗口、对象、服务端结果和窗口结束后的持久状态。
- 已发送请求因为关闭确认、Escape、路由离开、客户端取消或 Toast 消失而写成“已取消”。
- 取消请求已发送被当成服务端已取消；未知结果被伪装成成功或失败。
- 批量危险操作没有冻结选择快照、筛选快照、权限版本、目标数量、目标摘要和影响范围。
- 权限、租户/工作区、角色、目标版本或筛选范围变化后，旧确认、旧目标快照、旧撤销入口和旧结果回执仍继续可用。
- 移动端不得删除危险确认、影响范围、撤销/恢复入口、取消中状态、未知结果说明或审计回执。
- 浏览器、屏幕阅读器、触控设备、真实组件和真实视口没有执行时，不能写成已验证，必须标为未验证。

对应静态审计入口：`ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations`。
