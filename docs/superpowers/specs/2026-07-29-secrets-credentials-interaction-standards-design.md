# 密钥、令牌与敏感凭证交互规范设计

## 背景

管理台经常提供 API Key、Access Token、Webhook Secret、OAuth Client Secret、集成凭证、下载凭证、一次性密钥、签名密钥和服务账号凭证。它们看起来只是“详情字段 + 复制按钮 + 重置按钮”，但实际风险比普通字段高很多：生成后只应显示一次、复制会进入系统剪贴板、Reveal 会改变暴露面、Rotate/Revoke 会影响线上调用、旧链接和旧 Toast 可能泄露密钥、移动端可能把密钥放进截图和键盘建议、导出或日志可能把真实值带出去。

现有规范已零散覆盖部分边界：

- `information-display.md` 约束脱敏展示、复制和只读详情。
- `risk-actions.md` 约束重置密钥、删除、撤销等危险动作。
- `permissions-tenancy-visibility.md` 约束权限无泄露和旧缓存清理。
- `auth-session-reauth.md` 约束重新认证、登录过期和旧会话失效。
- `audit-log-activity-history.md` 约束审计和复制/导出复核。

但目前没有 owner 负责“密钥本身的生命周期和暴露窗口”。这会导致项目实现把密钥当普通文本字段处理，或者只在重置动作上加确认，却忽略创建后一次性展示、复制回执、Reveal 计时、权限/会话变化后失效、下载凭证、审计回执和移动端恢复。

## 目标

- 新增“密钥、令牌与敏感凭证” owner，覆盖 Secret / Token / Credential 的生成、展示、Reveal、复制、下载、轮换、重置、撤销、过期、泄露恢复和审计。
- 明确真实值、脱敏值、一次性值、已复制值、已下载凭证、旧凭证、已撤销凭证和未知结果的状态边界。
- 禁止把密钥作为普通只读字段、普通复制字段、普通 Toast 成功或普通确认 Dialog 处理。
- 规定复制、Reveal、下载、Rotate/Revoke 前后的权限、认证、租户/工作区、凭证版本、请求身份和审计绑定。
- 规定移动端、低高度、虚拟键盘、系统截图风险、系统剪贴板和辅助技术下的可达性与不泄露边界。

## 非目标

- 不定义密钥生成算法、加密方案、哈希策略、服务端存储、KMS、HSM、Secret Manager 或 provider API。
- 不替代 `risk-actions.md` 的危险操作确认；Rotate/Revoke/Delete/Reset 等仍进入 Risk owner。
- 不替代 `auth-session-reauth.md` 的重新认证挑战；Reveal、下载真实凭证或高风险轮换可要求重新认证。
- 不替代 `permissions-tenancy-visibility.md` 的权限解析与租户/工作区可见性。
- 不替代 `audit-log-activity-history.md` 的审计证据模型。
- 不定义品牌视觉 token、图标、颜色或具体组件库 API。

## Owner 边界

新增文件：`references/secrets-credentials.md`。

建议路由关键词：

- 中文：密钥、令牌、凭证、API Key、访问令牌、Webhook Secret、Client Secret、集成凭证、服务账号、签名密钥、一次性密钥、显示密钥、Reveal、复制密钥、下载凭证、轮换密钥、重置密钥、撤销密钥、泄露恢复。
- 英文：secret、secrets、credential、credentials、API key、access token、refresh token、webhook secret、client secret、integration credential、service account、signing key、one-time secret、reveal secret、copy secret、download credential、rotate key、reset key、revoke key、leak recovery。

该 owner 维护 `secretCredentialState`，至少包含：

| 字段 | 说明 |
| --- | --- |
| `credentialOwnerId` | 当前凭证 owner 实例身份，用于绑定页面、弹层、请求、Reveal、复制、下载和审计。 |
| `credentialIdentity` | 凭证稳定身份、类型、所属对象、租户/工作区、环境、用途和作用域。 |
| `credentialVersion` | 当前凭证版本、轮换代次、创建时间、过期时间和撤销时间。 |
| `secretVisibilityState` | `masked`、`reveal-requested`、`revealed`、`reveal-expired`、`copy-ready`、`copied`、`download-ready`、`downloaded`、`revoked`、`rotating`、`unknown`。 |
| `secretValuePolicy` | 是否一次性可见、是否允许再次 Reveal、是否允许复制、是否允许下载、是否允许局部显示。 |
| `revealIntent` | Reveal 的触发来源、原因、权限版本、认证强度和过期策略。 |
| `copyIntent` | 复制动作的目标字段、格式、权限版本、剪贴板策略和回执。 |
| `downloadIntent` | 下载凭证文件、配置片段或环境变量模板的范围、格式、有效期和权限复核。 |
| `rotationIntent` | Rotate/Reset/Revoke 的动作类型、影响范围、回滚/恢复策略和风险 owner 绑定。 |
| `permissionBoundary` | 查看、Reveal、复制、下载、轮换、撤销和审计所需的权限版本与数据范围。 |
| `authBinding` | 是否需要重新认证、当前认证强度、`authOwnerId` 和挑战结果。 |
| `auditBinding` | Reveal、复制、下载、轮换、撤销、失败和未知结果的审计身份。 |
| `resultReceipt` | 成功、取消、失败、部分完成、未知、过期和权限拒绝的持久回执。 |

## 核心交互规则

### 密钥不是普通只读字段

密钥、令牌和敏感凭证不能只按普通详情字段展示。真实值、脱敏值、不可再次查看的一次性值、旧版本值、已撤销值和未知状态必须明确区分。默认展示应为脱敏或安全占位；若凭证只在创建时显示一次，页面必须在创建前、创建中和创建后明确说明“一旦离开无法再次查看”的语义，并提供安全保存路径。

### Reveal 必须有意图和边界

Reveal 真实值必须由明确用户意图触发，不能在 hover、自动聚焦、页面加载、展开详情、复制失败或移动端键盘打开时自动 Reveal。Reveal 必须绑定 `revealIntent`、`permissionBoundary`、`authBinding`、`credentialVersion` 和过期策略。Reveal 后应有可见过期、重新隐藏或离开清理规则；权限变化、会话过期、租户/工作区切换、路由卸载或上层模态关闭时，真实值必须立即隐藏或失效。

### 复制不是普通 Toast

复制真实密钥必须绑定 `copyIntent`、当前凭证版本、权限版本、租户/工作区、认证强度和请求身份。复制成功可以用短反馈，但不能泄露真实值、不能在 Toast/Notification 中包含密钥片段、不能把复制成功当成已安全保存。复制失败必须说明原因和替代路径，不能静默失败。复制脱敏值不得误导用户以为复制了真实值；如果真实值不可复制，按钮必须说明原因。

### 下载凭证需要产物身份

下载 `.env`、JSON、证书、配置片段、客户端密钥或服务账号凭证时，不得复用普通导出下载规则而缺少凭证语义。下载必须绑定 `downloadIntent`、凭证版本、文件格式、有效期、权限版本、认证强度、请求身份和审计。旧下载链接、浏览器历史、Notification、任务入口和复制下载链接都必须在权限变化、会话过期、凭证轮换、撤销、过期或租户切换后失效或重新证明安全。

### Rotate / Reset / Revoke 是风险操作

轮换、重置、撤销、删除、停用、启用或泄露恢复必须进入 `risk-actions.md`。确认前请求数为 0；确认面板必须显示影响范围、当前版本、目标版本、受影响环境、调用方、回滚/恢复能力、审计回执和未知结果处理。不得用 Switch 直接启停密钥，不得点击“重置”后直接生成新密钥而无复核。

### 旧值和未知结果不能继续可用

密钥轮换、撤销、权限变化、租户/工作区切换、会话过期、对象删除、版本冲突或未知结果后，旧真实值、旧复制按钮、旧下载链接、旧 Reveal 状态、旧 Toast/Notification、旧任务入口、旧审计跳转和旧 ARIA 引用必须失效或重算。未知结果不能伪装成轮换成功或撤销成功；必须提供检查状态、查看审计、重试或联系支持路径。

### 审计不泄露真实密钥

Reveal、复制、下载、轮换、撤销、失败、取消和未知结果都需要审计绑定，但审计记录不得包含真实密钥、完整 token、可复原片段、下载 URL、签名材料或剪贴板内容。审计可记录动作、主体、目标、权限版本、凭证版本、时间、结果、IP/设备等允许字段；无权限审计仍不能泄露凭证名称、作用域、环境或存在性。

### 移动端与系统剪贴板

移动端不得删除 Reveal、复制、下载、轮换、撤销、过期、审计和恢复路径。低高度、虚拟键盘、安全区域、系统字体放大、浏览器 Back、WebView 返回和系统分享/剪贴板能力变化后，真实值不被固定底部、键盘、Toast 或系统浮层遮挡。需要提醒系统剪贴板、截图、录屏、键盘建议或共享设备风险时，说明必须持久、可访问且不包含真实值。

## 与其他 owner 的关系

- `information-display.md`：负责普通详情字段、脱敏值、复制字段和长文本展示；本 owner 负责凭证真实值和生命周期。
- `risk-actions.md`：负责 Rotate/Reset/Revoke/Delete 的风险确认、影响范围和结果；本 owner 提供凭证身份、版本和暴露边界。
- `auth-session-reauth.md`：负责 Reveal、下载真实凭证或高风险轮换前的重新认证挑战；本 owner 绑定凭证意图。
- `permissions-tenancy-visibility.md`：负责可见性和无泄露；本 owner 规定凭证字段、旧值和下载链接如何随权限失效。
- `exports-downloads-artifacts.md`：负责下载产物领取；本 owner 规定凭证产物的额外身份、有效期和真实值边界。
- `audit-log-activity-history.md`：负责审计证据；本 owner 规定审计不得包含真实凭证值。
- `global-feedback.md` / `feedback-states.md`：负责反馈通道；本 owner 规定 Toast/Notification 不得泄露真实值或作为唯一恢复路径。
- `selection-controls.md`：视觉 Switch/Toggle 不能直接承载密钥启停；必须转入 Risk owner。

## 验收策略

新增静态审计 `docs/testing/secrets-credentials/secrets-credentials-audit.rb`，检查：

- `SKILL.md` 有密钥、令牌、凭证、API Key、secret、token、credential、rotate、revoke 等路由。
- `references/secrets-credentials.md` 存在并包含 owner state、Reveal、复制、下载、Rotate/Revoke、旧值失效、审计不泄露、移动端恢复和未验证边界。
- README / HANDOFF 有中文摘要。
- RED/GREEN 证据覆盖普通字段展示真实值、创建后未说明一次性显示、hover 自动 Reveal、复制脱敏值误导、Toast 泄露真实值、下载链接长期有效、Switch 直接启停密钥、轮换未知结果伪装成功、审计记录真实密钥、移动端删除恢复路径等负例。
- mutation 模式删除任一关键规则会失败。

运行时真实浏览器、系统剪贴板、移动端设备、屏幕阅读器、真实权限切换、真实会话过期、真实下载和真实轮换任务未执行时，必须标为**未验证**，不能把静态审计写成运行时通过。

## 设计取舍

推荐新增独立 owner，而不是把规则继续分散到 Information Display、Risk、Permissions 和 Export。原因是 Secret/Credential 的核心风险不是某一个动作，而是“真实值暴露窗口”和“凭证生命周期”：一次性展示、Reveal、复制、下载、轮换、撤销、旧链接失效和审计都必须围绕同一个 `credentialIdentity` 与 `credentialVersion` 对齐。独立 owner 能把凭证真实值、版本、权限、认证、剪贴板、下载和审计绑定到同一条状态链上，再把危险确认、权限解析、下载领取和反馈通道交给已有 owner。
