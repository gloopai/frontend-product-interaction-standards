# 回收站恢复保留规范 GREEN 复核

新增 `references/trash-restore-retention.md` 后，删除后生命周期具备独立 owner：

- `trashRestoreState` 要求声明 `trashOwnerId`、`objectIdentity`、`lifecycleKind`、`deletedState`、`sourceSnapshot`、`retentionPolicy`、`restorePolicy`、`purgePolicy`、`visibilityPolicy`、`availabilityMap`、`permissionBoundary`、`requestIdentity`、`resultReceipt`、`auditBinding`、`feedbackBinding`、`navigationBinding`、`responsivePolicy`、`lifecycleDisposal` 和 `runtimeVerification`。
- soft delete、archive、disable、restore、permanent delete、purge、retention expired 和 legal hold 被明确区分。
- Toast 不能作为唯一恢复入口、唯一审计回执、唯一失败说明或唯一未知结果处理。
- 保留期必须展示绝对时间、时区、起算点、规则来源和到期动作。
- 永久删除、清空回收站和到期清理必须进入 `risk-actions.md`，确认前请求数为 0。
- 恢复前检查版本、父级、唯一键、权限、状态机、保留期、关联对象和冲突。
- 删除后旧列表、详情、预览、下载、复制、菜单、选择、导出、搜索、URL、ARIA 和焦点目标必须失效或重算。
- 无权限不得泄露已删除对象名称、数量、字段、文件名、路径、删除原因、操作者、删除时间、保留期、内部 ID 或旧缓存。
- 批量删除、批量恢复、批量永久删除和清空回收站必须冻结目标集合，并提供部分成功恢复路径。
- 真实浏览器、键盘、读屏、移动端、权限切换、迟到响应、保留期到期、批量部分成功、任务中心和审计追溯未执行时必须标为未验证。

