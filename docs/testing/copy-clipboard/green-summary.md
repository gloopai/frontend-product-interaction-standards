# 复制与剪贴板操作 GREEN 证据

## GREEN 场景

正式实现新增：

- `references/copy-clipboard.md`
- `SKILL.md` 路由
- `README.md` 中文摘要
- `HANDOFF.md` 中文交接摘要
- `docs/testing/copy-clipboard/copy-clipboard-audit.rb`

运行：

```sh
ruby docs/testing/copy-clipboard/copy-clipboard-audit.rb
```

预期通过：

```text
PASS: 复制与剪贴板 owner、路由、摘要和证据符合结构化审计契约。
```

## GREEN 覆盖

- `copyActionState` 包含 `copyOwnerId`、`copyIntent`、`sourceBinding`、`valuePolicy`、`sensitiveBoundary`、`clipboardCapability`、`linkBinding`、`resultReceipt`、`auditBinding`、`focusReturn` 和 `disposalState`。
- `resultReceipt` 明确 `copy-ready`、`copying`、`copied`、`failed`、`denied`、`expired`、`stale` 和 `unknown`。
- 复制必须绑定当前快照；每个业务复制按钮、菜单项或快捷动作都必须创建 `copyIntent`。
- 复制不得读取旧 DOM、旧缓存、旧请求结果、隐藏字段、旧权限字段、旧下载 URL、旧邀请链接或旧审计详情。
- `valuePolicy` 区分真实值、脱敏值、安全摘要、链接、结构化片段、图片和文件引用。
- 复制脱敏值必须明确告诉用户复制的是脱敏值或安全摘要，不能误导用户以为复制了真实值。
- Toast、Notification、Tooltip、ARIA label、审计摘要和错误说明不得包含真实密钥、token 片段、完整下载 URL、邀请 token、签名材料、payload、无权限字段或可复原敏感内容。
- 复制链接不是权限证明；`linkBinding` 必须说明链接类型、目标对象、有效期、权限复核、租户/工作区、一次性/可撤销/过期策略和旧链接失效路径。
- 旧复制链接、旧浏览器历史、旧 Toast/Notification、旧菜单项和旧 DOM 属性必须失效或重新证明安全。
- 复制成功只表示写入系统剪贴板成功，不代表用户已经安全保存、链接已经被使用、邀请已经发送、文件已经下载、任务已经完成、字段已经更新或审计已经导出。
- 复制失败不能静默吞掉，必须说明原因并提供恢复路径。
- 复制入口必须有动作对象和可访问名称；复制成功、失败、权限拒绝、过期和未知结果必须由唯一 owner 公告。
- 移动端不得删除核心复制入口、复制失败原因、敏感警示、权限说明或替代路径。

## 未验证边界

本次只做文档和静态审计。浏览器、移动端设备、WebView、系统剪贴板权限、屏幕阅读器、真实链接有效期、真实权限切换、真实重新认证、真实系统分享面板和真实审计写入均未执行，必须在业务项目运行时验证中继续标为未验证。
