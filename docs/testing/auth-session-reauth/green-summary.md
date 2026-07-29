# 会话、认证与重新认证 GREEN 证据摘要

当前规范和审计证明以下结构已经就位：

- `authSessionState` 包含 `authOwnerId`、`sessionIdentity`、`authLevel`、`sessionStatus`、`reauthIntent`、`reauthReason`、`returnContext`、`sensitiveActionBinding`、`permissionBoundary`、`callbackBinding`、`recoveryPolicy` 和 `resultReceipt`。
- 会话状态、权限状态、租户/工作区状态、对象状态、表单脏状态、请求状态和敏感动作意图分层表达，不合并成笼统 loading/error。
- 登录过期和会话过期先冻结或失效不安全请求，保存允许保留的安全 `returnContext`，清理敏感草稿、旧下载链接、旧任务入口、旧权限菜单和旧确认面板，再提供重新登录或返回安全页路径。
- 重新认证挑战绑定 `reauthIntent`、`sensitiveActionBinding`、权限版本、目标快照、幂等键和 `returnContext`；挑战完成前敏感请求发送数为 0。
- 重新认证完成后只恢复仍匹配当前用户、租户/工作区、权限版本、目标状态和幂等键的动作；不匹配时回到复核或重新确认。
- SSO/MFA callback 验证 `state`、`nonce`、`authOwnerId`、`returnContext`、租户/工作区和过期时间；旧标签页 callback、重复、过期、错误租户和已退出 callback 只能进入安全说明或重新开始。
- 退出登录、账号切换、身份切换、租户/工作区切换和权限版本变化后，旧 UI 状态、请求、菜单、下载、任务、弹层、消息、焦点和 ARIA 引用原子失效或重算。
- 登录失败、会话过期、重新认证取消、重新认证失败、MFA 失败、SSO callback 失败、权限拒绝、租户不匹配、网络失败和未知结果分型呈现。
- Toast 不是认证失败或重新认证恢复的唯一承载；页面、Dialog/Drawer、表单错误摘要、区域 Alert 或安全说明页承载持久可访问恢复路径。
- 移动端不得删除重新登录、重新认证、返回安全页、切换租户/工作区、放弃草稿、重试 callback 和查看原因入口。
- 真实浏览器、真实 SSO/MFA provider、触摸设备、屏幕阅读器、WebView/system back 和真实网络中断检查在本轮文档工作中仍是未验证，需要在具体页面实现时补充。
