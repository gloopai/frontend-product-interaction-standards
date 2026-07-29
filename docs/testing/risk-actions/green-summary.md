# 危险操作与恢复 GREEN 证据摘要

当前规范和审计证明以下结构已经就位：

- `riskActionState` 明确包含 `riskActionId`、`riskLevel`、`actionObject`、`impactScope`、`confirmationPolicy`、`confirmationEvidence`、`requestIdentity`、`executionPhase`、`undoPolicy`、`cancelPolicy`、`resultReceipt`、`auditBinding` 和 `recoveryActions`。
- 风险等级覆盖 `low-recoverable`、`medium-recoverable`、`high-impact`、`irreversible` 和 `async-unknown`。
- 确认策略覆盖 `none-with-undo`、`light-confirm`、`strong-confirm`、`typed-confirm`、`multi-step-confirm` 和 `task-flow`。
- 危险操作不得只靠颜色表达风险；二次确认不得只有裸词；未满足 `confirmationPolicy` 前请求数必须为 0。
- 撤销不是 Toast 装饰；必须声明 `undoPolicy`、撤销窗口、对象、服务端结果和窗口结束后的持久状态。
- `cancelPolicy` 区分取消请求、取消中、已取消、取消失败、未知和过期；未知结果不得伪装成成功或失败。
- 批量危险操作必须冻结选择快照、筛选快照、权限版本、目标数量、目标摘要和 `impactScope`。
- `resultReceipt` 和 `auditBinding` 必须可定位；Toast 不能作为唯一结果凭证。
- 移动端不得删除危险确认、影响范围、撤销/恢复入口、取消中状态、未知结果说明或审计回执。
- 浏览器、屏幕阅读器、触控设备、真实组件和真实视口检查在本轮文档工作中仍是未验证，需要在具体页面实现时补充。

对应静态审计入口：`ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations`。
