# GREEN 应用：成员权限风险控制台

## 场景与状态 owner

- `consoleSurface: settings`；页面标题“成员权限”，当前导航“设置 / 成员权限”，返回路径“设置”。
- `navigationState`：记录返回路径和离开保护；权限编辑为 dirty 时，离开前确认，恢复前重校验 permissionVersion、tenant 与范围。
- `permissionState`：保存 tenant、workspace、role、permissionVersion、`resolvedSurface`、可见字段和可执行操作。租户、工作区、角色或权限版本变化时原子重算；旧成员数据、选择、菜单、确认快照和下载入口立即隐藏或安全占位，焦点只迁移一次。权限不足说明恢复路径，不泄露成员姓名、数量或权限字段。
- `surfaceState`：区分加载、内容、空态、错误、延迟和安全占位。
- `riskState`：权限更新声明 `riskLevel: high`、`impactScope: 当前工作区的指定成员及其角色`、`confirmationPolicy: 显式确认受影响成员与新旧角色`、`requestIdentity: permissionChangeId`、`resultReceipt: 页面内“权限变更结果”回执`。关闭确认、Escape 或离开页面只关闭客户端确认；已发送请求与未知结果进入“检查最新状态”或任务中心路径，不伪装成取消。
- `auditState`：页面显示审计可用性；成功或未知结果的页面内回执给出 `permissionChangeId` 和审计日志位置“审计日志 / 成员权限变更”。审计失败显示 Alert 与重试/查询最新状态路径，Toast 不是唯一回执。
- `taskState`：未启用导入、导出或异步任务。任务零值证据：DOM=0；state=0；handler/event=0；request=0。
- `feedbackState`：权限变更结果由页面内回执作为 primary owner，阻断错误由 Alert 作为 primary owner；Toast 仅辅助，Tooltip/Popover 不承载唯一权限原因、错误或确认后果。

## 风险、审计与可用性

提交请求包含 `permissionChangeId`、tenant/workspace、目标成员匿名标识、权限版本和结果。审计记录主体、时间、tenant/workspace、目标、请求身份和结果；审计查询无权访问时不泄露主体或对象。当前页面未提供审计日志查询列表；审计查询零值证据：DOM=0；state=0；handler/event=0；request=0。

风险操作不以 Toast-only 结束：页面内回执保留成功、失败、未知结果与可恢复下一步；未知结果提供“检查最新状态”和审计位置。移动端可折叠次要导航，但确认、权限原因、结果回执和恢复入口不消失。

## 未验证边界

浏览器、AT（屏幕阅读器）、touch（触摸设备）及真实组件运行时未执行；确认 Dialog 的 DOM/ARIA、焦点迁移、事件日志和窄屏布局均为未验证。
