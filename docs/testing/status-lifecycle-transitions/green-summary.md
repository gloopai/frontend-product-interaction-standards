# 状态流转与记录生命周期 GREEN 证据摘要

当前规范和审计证明以下结构已经就位：

- 每个状态展示、状态详情、状态变更、批量生命周期变更或异步状态结果必须声明 `lifecycleState`。
- `lifecycleState` 覆盖 `lifecycleOwnerId`、`lifecycleSurface`、`currentStatus`、`targetStatus`、`statusSource`、`versionSnapshot`、`transitionIntent`、`transitionPolicy`、`transitionResult`、`permissionBoundary`、`auditReceipt`、`recoveryPolicy`、`feedbackState`、`a11yPolicy` 和 `responsivePolicy`。
- 状态 badge、按钮 loading、乐观 UI、Toast 文案或本地缓存不得伪装成已完成状态流转。
- 状态展示和状态变更不得共用一个含糊 status 字段。
- 没有冻结对象版本、权限版本、当前状态、目标状态、租户/工作区和请求身份，不得提交状态变更。
- 版本冲突、权限变化、租户切换、对象删除、状态已变化或业务限制变化时，旧意图必须失效。
- transitionResult 必须区分 success、failure、partial-success、conflict、stale、unknown、queued、processing 和 cancelled-client-only。
- 无权限状态流转不得泄露当前状态、下一步动作、不可见原因、对象数量、批量影响范围、审批意见、拒绝原因、内部状态码、任务结果或旧缓存。
- 批量状态变更不得用当前页面可见行替代选择快照、筛选快照、权限版本和目标摘要。
- 移动端不得删除当前状态、状态原因、可用动作、禁用原因、确认、结果回执、审计入口或恢复路径。
- 真实浏览器、键盘、屏幕阅读器、触摸、权限切换、版本冲突、异步任务和移动端视口检查在本轮文档工作中仍是未验证，需要在具体页面实现时补充。

对应静态审计入口：`ruby docs/testing/status-lifecycle-transitions/status-lifecycle-transitions-audit.rb --mutations`。
