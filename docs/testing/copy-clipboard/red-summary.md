# 复制与剪贴板操作 RED 证据

## RED 场景

审计器先在缺少正式 owner 的仓库状态下运行：

```sh
ruby docs/testing/copy-clipboard/copy-clipboard-audit.rb
```

预期失败：

```text
missing file: /Users/evanqi/.codex/skills/frontend-product-interaction-standards/references/copy-clipboard.md
```

该 RED 证明审计会阻止只写设计稿、不新增正式 `references/copy-clipboard.md` 的状态。

## 覆盖的失败模式

- 缺少 `copyActionState`、`copyIntent`、`sourceBinding`、`valuePolicy`、`sensitiveBoundary`、`clipboardCapability`、`linkBinding` 和 `resultReceipt` 等核心状态字段。
- 复制动作没有绑定当前展示快照和权限版本。
- 从旧 DOM、旧缓存、旧请求结果、隐藏字段、旧权限字段、旧下载 URL、旧邀请链接或旧审计详情复制。
- 复制脱敏值时误导用户以为复制了真实值。
- Toast、Notification、Tooltip、ARIA label、审计摘要或错误说明泄露真实密钥、token 片段、完整下载 URL、邀请 token、签名材料、payload、无权限字段或可复原敏感内容。
- 将复制链接当作权限证明，或让旧复制链接在权限、会话、租户/工作区、对象、任务、文件、邀请、凭证或链接版本变化后继续可用。
- 复制成功被伪装成用户已经安全保存、链接已经被使用、邀请已经发送、文件已经下载、任务已经完成、字段已经更新或审计已经导出。
- 复制失败静默吞掉，或只让按钮闪一下，没有可恢复原因和替代路径。
- 图标按钮、菜单项或快捷操作缺少动作对象和可访问名称。
- 同一完整结果在按钮、Toast、Alert、Tooltip 和 live region 中重复播报。
- 移动端、低高度、虚拟键盘、安全区域、WebView、系统分享面板、系统剪贴板限制和 200% 缩放下删除复制入口、复制失败原因、敏感警示、权限说明或替代路径。
- 将浏览器、移动端设备、WebView、系统剪贴板权限、屏幕阅读器、真实链接有效期、真实权限切换、真实重新认证、真实系统分享面板和真实审计写入写成已验证；这些运行时边界必须保持未验证。

## RED 断言关键词

审计器要求 RED 证据包含 `copyActionState`、`copyIntent`、`sourceBinding`、`valuePolicy`、`sensitiveBoundary`、`clipboardCapability`、`linkBinding`、`resultReceipt`、旧 DOM、旧复制链接、脱敏值、Toast、复制失败、移动端和未验证。
