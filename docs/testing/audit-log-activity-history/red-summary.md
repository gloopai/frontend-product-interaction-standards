# 审计日志与操作历史 RED 证据摘要

错误实现通常缺少 `auditLogState`、`auditOwnerId`、`eventIdentity`、`actorSnapshot`、`targetSnapshot`、`actionSnapshot` 或 `timeSemantics`，却仍把普通操作历史包装成审计证据。

这些负向场景必须被规范和审计识别为失败：

- 把普通列表行、普通活动流、Toast 成功文案或 Notification 标题伪装成审计日志；这种场景违反“审计记录不是普通列表行”的边界。
- 操作历史缺少证据身份，缺少 `eventIdentity`、`actorSnapshot`、`targetSnapshot`、`actionSnapshot`、`timeSemantics` 或 `permissionBoundary`，却仍被写成审计证据。
- 审计日志必须区分事件发生时间；混用事件发生时间、审计写入时间、展示时区、存储时区、筛选范围、数据延迟和刷新时间属于失败。
- 无权限审计不得泄露主体名称；无权限状态泄露目标名称、字段名、旧值、新值、数量、文件名、IP、设备、地理位置、错误明细、内部 ID、请求参数、导出范围、任务结果或旧缓存也属于失败。
- 审计缺口、延迟、重复、顺序未决、来源不可用或修正记录被伪装成完整日志，违反不能伪装成完整日志的要求。
- 旧导出链接、旧详情页、旧查询 URL、旧任务中心入口或旧缓存绕过审计导出、复制、跳转的权限、租户/工作区、筛选快照、时间范围、敏感字段和请求身份复核。
- 移动端删除筛选、时间范围、时区说明、数据延迟、审计详情、追溯路径、导出权限说明、无权限说明或恢复路径。
- 真实浏览器、权限切换、审计导出、时间范围、时区、任务追溯和移动端视口没有执行时，不能写成已验证，必须标为未验证。

对应静态审计入口：`ruby docs/testing/audit-log-activity-history/audit-log-activity-history-audit.rb --mutations`。
