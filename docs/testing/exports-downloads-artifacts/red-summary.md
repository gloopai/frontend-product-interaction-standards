# 导出、下载与结果产物交付 RED 证据摘要

这些负向场景必须被规范和审计识别为失败：

- 导出、下载、错误明细或结果产物缺少 `exportState`、`artifactState`、`downloadIntent`、`scopeSnapshot` 或 `artifactIdentity`。
- 导出范围不得读取筛选草稿；读取未提交时间范围、Select query、active option、当前页面可见行或旧缓存同样是失败。
- 创建导出、生成文件、领取产物和下载文件被合并成一个含糊状态，无法区分 queued、processing、ready、downloaded、expired、failed、partial-success、permission-denied、unknown 和 unavailable。
- 下载链接不得被当作权限证明；如果没有在每次下载时复核权限、租户/工作区、有效期、请求身份和产物身份，就是失败。
- 旧 Notification、旧任务入口、旧 URL、旧缓存、旧文件名或旧下载链接绕过权限复核。
- Toast、Snackbar、Notification 或浏览器下载提示成为唯一下载入口、唯一结果回执、唯一错误说明或唯一恢复路径。
- 敏感导出、审计导出、错误明细下载和跨租户/工作区产物没有说明敏感字段、范围、有效期、权限边界和审计回执。
- 部分成功、未知、过期、无权限和文件不可用被伪装成成功。
- 移动端删除导出范围、文件状态、格式、有效期、权限说明、敏感字段说明、错误明细、重新生成、任务详情、审计入口或恢复路径。
- 真实浏览器下载、键盘、屏幕阅读器、触摸、权限切换、链接过期、任务结果和移动端视口没有执行时，不能写成已验证，必须标为未验证。

对应静态审计入口：`ruby docs/testing/exports-downloads-artifacts/exports-downloads-artifacts-audit.rb --mutations`。
