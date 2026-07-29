# 密钥、令牌与敏感凭证 GREEN 证据摘要

当前规范和审计证明以下结构已经就位：

- `secretCredentialState` 包含 `credentialOwnerId`、`credentialIdentity`、`credentialVersion`、`secretVisibilityState`、`secretValuePolicy`、`revealIntent`、`copyIntent`、`downloadIntent`、`rotationIntent`、`permissionBoundary`、`authBinding`、`auditBinding` 和 `resultReceipt`。
- 真实值、脱敏值、不可再次查看的一次性值、旧版本值、已撤销值、过期值、泄露值和未知状态分型表达。
- 一次性密钥在创建前、创建中和创建后说明“一旦离开无法再次查看”，并提供安全保存、复制或下载路径。
- Reveal 只能由明确用户意图触发，不能由 hover、自动聚焦、页面加载、展开详情、复制失败或移动端键盘打开自动触发。
- Reveal 绑定 `revealIntent`、`permissionBoundary`、`authBinding`、`credentialVersion` 和过期清理策略；权限、会话、租户/工作区、路由或模态变化后真实值立即隐藏或失效。
- 复制真实密钥绑定 `copyIntent`、当前凭证版本、权限版本、租户/工作区、认证强度和请求身份。
- Toast、Notification、Banner、审计摘要和错误信息不包含真实密钥、完整 token、可复原片段、下载 URL、签名材料或剪贴板内容。
- 复制脱敏值不会伪装成已复制真实值；真实值不可复制时说明原因和替代路径。
- 下载凭证绑定 `downloadIntent`、凭证版本、文件格式、有效期、权限版本、认证强度、请求身份和审计。
- 旧下载链接、浏览器历史、Notification、任务入口和复制下载链接在权限变化、会话过期、凭证轮换、撤销、过期或租户切换后失效或重新证明安全。
- Rotate、Reset、Revoke、Delete、Disable、Enable 和泄露恢复进入 `risk-actions.md`；确认前请求数为 0，并展示影响范围、版本、环境、调用方、恢复能力、审计回执和未知结果处理；Switch 不能直接启停密钥。
- 旧真实值、旧复制按钮、旧 Reveal 状态、旧 Toast/Notification、旧任务入口、旧审计跳转和旧 ARIA 引用在轮换、撤销、权限变化、租户切换、会话过期、对象删除、版本冲突或未知结果后失效或重算。
- 审计绑定存在，但审计记录不包含真实凭证值或可复原材料。
- 移动端保留 Reveal、复制、下载、轮换、撤销、过期、审计和恢复路径，并说明系统剪贴板、截图、录屏、键盘建议或共享设备风险时不包含真实值。
- 真实浏览器、系统剪贴板、移动端设备、屏幕阅读器、真实权限切换、真实会话过期、真实下载和真实轮换任务检查在本轮文档工作中仍是未验证，需要在具体页面实现时补充。
