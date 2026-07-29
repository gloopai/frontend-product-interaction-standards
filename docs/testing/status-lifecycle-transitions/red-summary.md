# 状态流转与记录生命周期 RED 证据摘要

这些负向场景必须被规范和审计识别为失败：

- 只放状态 badge、颜色标签或图标，却没有 `lifecycleState`、`lifecycleOwnerId`、`currentStatus`、`versionSnapshot` 和 `transitionPolicy`。
- 把状态 badge、按钮 loading、乐观 UI、Toast 文案或本地缓存伪装成已完成状态流转。
- 状态展示和状态变更共用一个含糊 status 字段，无法区分当前已证明状态、目标状态、草稿/预览、处理中和结果。
- 没有冻结对象版本、权限版本、当前状态、目标状态、租户/工作区和请求身份，也没有冻结 `transitionIntent`，就提交状态变更。
- 版本冲突、权限变化、租户切换、对象删除、状态已变化或业务限制变化后，旧意图没有失效，仍继续提交或覆盖当前状态。
- transitionResult 没有区分 success、failure、partial-success、conflict、stale、unknown、queued、processing 和 cancelled-client-only，把冲突、未知或处理中伪装成成功。
- 无权限状态流转泄露当前状态、下一步动作、不可见原因、对象数量、批量影响范围、审批意见、拒绝原因、内部状态码、任务结果或旧缓存。
- 批量状态变更直接读取当前页面可见行，而不是冻结选择快照、筛选快照、权限版本和目标摘要。
- 移动端删除当前状态、状态原因、可用动作、禁用原因、确认、结果回执、审计入口或恢复路径。
- 真实浏览器、键盘、屏幕阅读器、触摸、权限切换、版本冲突、异步任务和移动端视口没有执行时，不能写成已验证，必须标为未验证。

对应静态审计入口：`ruby docs/testing/status-lifecycle-transitions/status-lifecycle-transitions-audit.rb --mutations`。
