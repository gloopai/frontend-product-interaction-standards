# 审计日志与操作历史 GREEN 证据摘要

当前规范和审计证明以下结构已经就位：

- 每个审计日志、操作历史、活动时间线、审计详情或审计导出入口必须声明 `auditLogState`。
- `auditLogState` 覆盖 `auditOwnerId`、`eventIdentity`、`actorSnapshot`、`targetSnapshot`、`actionSnapshot`、`timeSemantics`、`integrityState`、`permissionBoundary`、`filterSnapshot`、`exportState`、`feedbackState`、`a11yPolicy` 和 `responsivePolicy`。
- 审计记录不是普通列表行；缺少证据身份的操作历史只能作为普通活动提示，不能写成审计日志。
- 审计日志必须区分事件发生时间、审计写入时间、展示时区、存储时区、筛选范围、数据延迟和刷新时间。
- 无权限审计不得泄露主体名称、目标名称、字段名、旧值、新值、数量、文件名、IP、设备、地理位置、错误明细、内部 ID、请求参数、导出范围、任务结果或旧缓存。
- 审计缺口、延迟、重复、顺序未决、来源不可用和修正记录不能伪装成完整日志。
- 审计导出、复制、跳转、查看详情、查看关联任务、查看风险回执和追溯链路必须复核权限、租户/工作区、筛选快照、时间范围、敏感字段和请求身份。
- 移动端必须保留筛选、时间范围、时区说明、数据延迟、审计详情、追溯路径、导出权限说明、无权限说明和恢复路径。
- 真实浏览器、权限切换、审计导出、时间范围、时区、任务追溯和移动端视口检查在本轮文档工作中仍是未验证，需要在具体页面实现时补充。

对应静态审计入口：`ruby docs/testing/audit-log-activity-history/audit-log-activity-history-audit.rb --mutations`。
