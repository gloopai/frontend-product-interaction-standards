# 复制与剪贴板操作交互规范设计

## 背景

管理台里复制操作非常高频：复制字段值、记录 ID、错误编号、审计字段、配置片段、邀请链接、下载链接、Webhook endpoint、回调 URL、任务结果链接、报表数据、图表图片、脱敏值、真实密钥或一次性凭证。现有规范已经在多个 owner 中分别覆盖部分复制风险：

- `information-display.md` 约束详情页字段展示、脱敏展示和字段复制。
- `secrets-credentials.md` 约束真实密钥、Reveal、一次性凭证和敏感复制。
- `exports-downloads-artifacts.md` 约束下载链接、复制下载链接和产物权限复核。
- `audit-log-activity-history.md` 约束审计字段复制、脱敏和追溯。
- `webhooks-integrations-callbacks.md`、`billing-subscription-invoices.md`、`async-jobs-task-center.md` 等 owner 均提到旧复制链接失效。

缺口是：没有通用 owner 约束所有“复制到剪贴板”动作。项目容易把复制当成本地小交互，只写 `navigator.clipboard.writeText(value)` 和 “复制成功” Toast，却漏掉复制对象身份、当前展示快照、权限版本、租户/工作区、脱敏语义、链接有效期、系统剪贴板失败、移动端权限、审计和旧 DOM 失效。

## 目标

- 新增“复制与剪贴板操作” owner，覆盖复制字段、复制 ID、复制名称、复制错误编号、复制链接、复制下载链接、复制邀请链接、复制配置片段、复制审计字段、复制图表/报表数据、复制脱敏值、复制真实值、复制失败和移动端剪贴板。
- 规定复制动作必须声明 `copyIntent`，绑定来源 owner、目标字段/对象、展示快照、权限版本、租户/工作区、敏感级别、输出格式、剪贴板能力、请求身份、审计和结果回执。
- 规定复制前必须复核当前权限、当前展示快照、对象状态、租户/工作区、链接有效期和敏感策略；不得复制旧 DOM、旧缓存、旧链接、旧脱敏状态或旧权限内容。
- 区分真实值复制、脱敏值复制、安全摘要复制、链接复制、结构化片段复制和浏览器原生文本选择复制。
- 禁止 Toast/Notification 泄露真实值、密钥片段、内部 ID、下载 URL、邀请 token、签名材料、payload 或无权限对象信息。
- 规定移动端、非安全上下文、剪贴板权限拒绝、浏览器不支持、系统策略禁用和失败重试的恢复路径。

## 非目标

- 不替代 `secrets-credentials.md` 对密钥、令牌、凭证、Reveal 和一次性真实值复制的更严格规则。
- 不替代 `exports-downloads-artifacts.md` 对下载链接、产物领取、文件有效期和权限复核的规则。
- 不替代 `audit-log-activity-history.md` 对审计字段复制、追溯链路和审计导出的规则。
- 不定义具体剪贴板 API、浏览器权限 API、移动端原生桥、组件库按钮 API 或设计系统视觉 token。
- 不禁止浏览器原生文本选择复制；但业务提供的复制按钮、复制菜单项和复制快捷操作必须进入本 owner。

## 推荐方案

推荐新增独立 owner：`references/copy-clipboard.md`。

备选方案：

1. **继续分散在各 owner。** 优点是局部规则贴近业务；缺点是每个新复制按钮都要靠记忆拼规则，容易遗漏剪贴板失败、旧快照、脱敏语义和移动端恢复。
2. **放入 Buttons owner。** 优点是复制常表现为按钮；缺点是复制语义不只是按钮行为，还涉及内容来源、权限、敏感策略、输出格式、链接有效期和审计。
3. **新增 Copy / Clipboard owner。** 推荐。按钮、菜单、详情、密钥、导出、审计等 owner 继续保留业务规则；复制 owner 负责通用状态模型、剪贴板能力、旧内容失效、回执、失败恢复和移动端底线。

选择独立 owner 的理由：复制是一个横切动作，风险不在“点按钮”本身，而在复制了什么、从哪个快照复制、权限是否仍有效、用户是否知道复制的是脱敏值还是真实值、复制链接是否仍安全，以及失败后是否有恢复路径。

## Owner 边界

建议新增文件：`references/copy-clipboard.md`。

建议路由关键词：

- 中文：复制、复制字段、复制值、复制文本、复制 ID、复制编号、复制错误编号、复制链接、复制邀请链接、复制下载链接、复制地址、复制 URL、复制配置、复制片段、复制命令、复制审计字段、复制数据、复制图片、复制脱敏值、复制真实值、剪贴板、系统剪贴板、一键复制、复制失败。
- 英文：copy、clipboard、copy field、copy value、copy text、copy id、copy identifier、copy error code、copy link、copy invite link、copy download link、copy URL、copy address、copy config、copy snippet、copy command、copy audit field、copy data、copy image、copy masked value、copy real value、copy to clipboard、clipboard failure.

该 owner 维护 `copyActionState`，至少包含：

| 字段 | 说明 |
| --- | --- |
| `copyOwnerId` | 当前复制动作 owner 稳定身份，绑定按钮/菜单、来源 owner、请求、回执和清理。 |
| `copyIntent` | 用户本次复制意图，包含目标字段/对象、格式、范围、触发方式、请求身份和时间。 |
| `sourceBinding` | 来源 owner、展示快照、对象身份、字段身份、版本、租户/工作区和权限版本。 |
| `valuePolicy` | 复制真实值、脱敏值、安全摘要、链接、结构化片段、图片或文件引用的策略。 |
| `sensitiveBoundary` | 敏感级别、脱敏规则、是否允许复制真实值、是否需要重新认证和是否需要持久警示。 |
| `clipboardCapability` | 安全上下文、浏览器/系统权限、移动端桥、用户手势、可写类型和失败原因。 |
| `linkBinding` | 链接类型、有效期、目标对象、权限复核、租户/工作区、一次性/可撤销/过期策略。 |
| `resultReceipt` | `copy-ready`、`copying`、`copied`、`failed`、`denied`、`expired`、`stale` 或 `unknown`。 |
| `auditBinding` | 复制动作、主体、目标、权限版本、字段类型、敏感等级和结果的审计身份。 |
| `focusReturn` | 复制后焦点保持、失败恢复焦点、菜单关闭和移动端替代路径。 |
| `disposalState` | 权限、路由、对象、快照、链接或 owner 变化后的旧复制入口、回执和 ARIA 清理。 |

## 核心规则

### 复制必须绑定当前快照

每个业务复制按钮、菜单项或快捷动作都必须创建 `copyIntent`，并绑定 `sourceBinding`。复制前读取的是当前可见且已证明安全的展示快照，不得读取旧 DOM、旧缓存、旧请求结果、隐藏字段、旧权限字段、旧下载 URL、旧邀请链接或旧审计详情。

若复制触发后权限、租户/工作区、对象状态、字段版本、链接有效期、显示快照或 owner 已变化，本次复制必须失败为 `stale`、`expired`、`denied` 或 `unknown`，不能继续写入剪贴板。

### 脱敏值和真实值必须分清

复制脱敏值必须明确告诉用户复制的是脱敏值或安全摘要，不能误导用户以为复制了真实值。复制真实值必须由来源 owner 明确允许，并执行更严格规则；密钥、令牌和凭证继续执行 `secrets-credentials.md`。

Toast、Notification、Tooltip、ARIA label、审计摘要和错误说明不得包含真实密钥、token 片段、完整下载 URL、邀请 token、签名材料、payload、无权限字段或可复原敏感内容。

### 复制链接不是权限证明

复制链接、复制下载链接、复制邀请链接、复制任务结果链接、复制审计跳转、复制 Webhook URL 或复制 deep link 时，链接本身不是长期授权。`linkBinding` 必须说明目标、有效期、权限复核、租户/工作区、一次性/可撤销/过期策略和旧链接失效路径。

旧复制链接、旧浏览器历史、旧 Toast/Notification、旧菜单项和旧 DOM 属性必须在权限变化、会话过期、租户/工作区切换、对象删除、任务过期、文件过期、邀请撤销、凭证轮换或链接版本变化后失效或重新证明安全。

### 回执不能泄露或伪装业务完成

复制成功只表示写入系统剪贴板成功，不代表用户已经安全保存、链接已经被使用、邀请已经发送、文件已经下载、任务已经完成、字段已经更新或审计已经导出。回执应表达“已复制 X 的 Y”，但不得泄露敏感值。

复制失败不能静默吞掉，也不能只让按钮闪一下。必须说明可恢复原因：浏览器不支持、非安全上下文、系统剪贴板权限拒绝、移动端桥失败、内容已过期、权限变化、对象不可用、值不可复制或需要重新认证，并提供重试、手动选择、下载、Reveal、重新生成或查看安全说明等路径。

### 复制操作必须可访问

复制按钮、图标按钮、菜单项和快捷操作必须有动作对象和可访问名称，例如“复制用户 ID”“复制发票下载链接”“复制脱敏邮箱”。不能只叫“复制”或只靠图标、Tooltip、Hover、颜色表达。

复制成功、失败、权限拒绝、过期和未知结果必须由唯一 owner 公告，不能在按钮、Toast、Alert、Tooltip 和 live region 中重复播报同一完整消息。焦点默认保持在触发控件；菜单中复制后是否关闭菜单必须按菜单 owner 声明，失败恢复必须能返回触发控件或错误说明。

### 移动端不能删复制能力

移动端、低高度、虚拟键盘、安全区域、WebView、系统分享面板、系统剪贴板限制和 200% 缩放下，不得删除核心复制入口、复制失败原因、敏感警示、权限说明或替代路径。

如果系统剪贴板不可用，可以提供选择文本、下载文件、分享面板、二维码、重新生成链接或手动复制面板，但必须说明安全边界，并保证不会暴露无权限或过期内容。

## 与其他 owner 的关系

- `buttons.md`：负责复制按钮的文案、图标按钮、loading、防重复和禁用原因；本 owner 负责复制内容、权限、剪贴板、回执和清理。
- `overlays-menus-tooltips.md`：负责菜单项、更多菜单和移动端 Action Sheet；本 owner 负责菜单里复制动作的内容绑定、失败恢复和安全回执。
- `information-display.md`：负责字段展示、只读详情、脱敏展示和可复制字段；本 owner 负责统一复制意图和剪贴板结果。
- `secrets-credentials.md`：真实密钥、令牌、凭证、Reveal 和一次性真实值复制执行更严格规则；本 owner 提供通用剪贴板底线。
- `exports-downloads-artifacts.md`：下载链接、产物链接和错误明细链接复制执行导出/产物 owner 的有效期和权限复核；本 owner 约束复制动作本身。
- `audit-log-activity-history.md`：审计字段复制、追溯和导出执行审计 owner 的脱敏和权限；本 owner 约束剪贴板写入与回执。
- `permissions-tenancy-visibility.md`：权限、租户/工作区和无泄露为所有复制动作的基础。
- `global-feedback.md`：复制结果短反馈可用 Toast/Snackbar，但不能泄露值，不能作为敏感复制、过期、权限拒绝或失败恢复的唯一说明。
- `responsive-adaptive.md`：移动端、WebView、虚拟键盘、安全区域和输入方式变化下复制能力与恢复路径保持可达。

## 验收策略

后续正式实现新增静态审计 `docs/testing/copy-clipboard/copy-clipboard-audit.rb`，检查：

- `SKILL.md` 有复制、复制字段、复制 ID、复制链接、复制下载链接、复制邀请链接、复制脱敏值、复制真实值、剪贴板、copy、clipboard、copy link、copy to clipboard 等路由。
- `references/copy-clipboard.md` 存在并包含 `copyActionState`、`copyOwnerId`、`copyIntent`、`sourceBinding`、`valuePolicy`、`sensitiveBoundary`、`clipboardCapability`、`linkBinding`、`resultReceipt`、`auditBinding`、`focusReturn`、`disposalState`。
- README / HANDOFF 有中文摘要。
- RED/GREEN 证据覆盖旧 DOM 复制、脱敏值误导、真实值泄露到 Toast、旧复制链接权限绕过、剪贴板失败静默、复制成功伪装业务完成、无动作对象的图标按钮、移动端删除复制入口、运行时剪贴板检查误标已验证等负例。
- mutation 模式删除任一关键规则会失败。

运行时真实浏览器、移动端设备、WebView、系统剪贴板权限、屏幕阅读器、真实链接有效期、真实权限切换、真实重新认证、真实系统分享面板和真实审计写入未执行时，必须标为**未验证**，不能把静态审计写成运行时通过。

## 设计取舍

这个 owner 不试图替代所有“复制”相关业务规范。它只提供复制动作的统一安全底线：复制什么、来自哪个快照、是否仍有权限、复制的是脱敏值还是真实值、链接是否仍安全、剪贴板是否可用、结果如何回执、失败如何恢复、旧入口如何失效。具体业务对象仍由对应 owner 决定是否允许复制、是否需要确认、是否需要重新认证和是否写审计。
