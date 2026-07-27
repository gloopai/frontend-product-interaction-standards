# GREEN 应用：数据导入、任务与审计控制台

## 场景与状态 owner

- `consoleSurface: job-center`；辅助 `consoleSurface: audit-log`；标题“数据任务”，当前导航“运维 / 数据任务”，返回路径“运维”。
- `navigationState`：未完成导入或取消中的任务离开前确认或安全中止；返回恢复时重校验 tenant、permissionVersion 与任务范围。
- `permissionState`：记录 tenant、workspace、role、permissionVersion 与 `resolvedSurface`；改变后原子重算任务可见范围、创建/查看/下载能力。无法证明安全的旧任务、错误文件和下载入口隐藏，焦点只迁移一次。
- `surfaceState`：任务页和审计页各自区分加载、内容、无数据、筛选无结果、无权限、服务错误和数据延迟。
- `riskState`：取消运行任务声明 `riskLevel: medium`、`impactScope: 指定 taskId`、`confirmationPolicy: 显式确认`、`requestIdentity: cancelRequestId`、`resultReceipt: 任务详情中的取消中/已取消状态`；关闭页面不等于取消，取消请求不等于服务端已停止。
- `auditState`：显示审计可用性；每次创建、取消和重试在任务详情页面内提供写入回执及“审计日志 / 数据任务”位置。审计失败用 Alert 提供恢复；查询分别展示无数据、无权限、筛选无结果、审计服务不可用和数据延迟，不合并为空态。
- `taskState`：维护导入、导出和异步任务的服务端状态与统一绑定契约。
- `feedbackState`：任务详情为结果和恢复的 primary owner；Notification 仅用于跨页面任务消息，Toast 仅辅助，Tooltip/Popover 不承载唯一错误或权限原因。

## 导入、导出与任务契约

导入声明允许文件类型 CSV/XLSX、最大 20 MB、字段映射、预检查、提交快照、幂等键、部分成功、错误文件和重试。预检查失败不创建执行任务，而在页面内 Alert 显示错误文件、行号和下一步；重试沿用幂等键并说明已成功行不重复执行。

导出声明范围、筛选快照、权限范围、敏感字段排除规则、生成方式、过期时间与下载身份。下载链接绑定权限和 requestIdentity；权限变化、链接过期或身份不匹配时拒绝下载，不保留旧 Notification 或缓存入口。

每个导入、导出和异步任务持续保留快照、权限、幂等、进度、结果与失败恢复：状态明确区分排队、运行中、成功、部分成功、失败、取消中、已取消、未知结果和过期。风险操作或任务结果不使用 Toast-only；页面内状态保留错误详情、恢复下一步和审计位置。

## 审计、报告零值与未验证边界

审计记录主体、时间、tenant/workspace、目标、requestIdentity 和结果；导出审计不泄露无权主体、对象或租户名。本场景未启用报表或仪表盘。报表零值证据：DOM=0（无图表/指标卡/报表筛选）；state=0（无报表快照）；handler/event=0（无报表刷新或钻取事件）；request=0（无报表请求）。

浏览器、AT（屏幕阅读器）、touch（触摸设备）和真实组件运行时未执行；任务状态 DOM/ARIA、事件日志、下载拒绝与断点行为均为未验证。
