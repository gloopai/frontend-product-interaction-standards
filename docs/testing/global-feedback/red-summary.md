# 全局反馈规范 RED 基线总结

没有 Global Feedback owner 时，常见失败包括：

- 全局反馈被降级为 `showToast(text)`，没有 `feedbackMessageState`。
- 消息没有 `sourceOwner` 或 `resultBinding`，却承载保存、删除、导入、导出、权限、任务或审计结果。
- 危险操作只用 Toast 作为唯一回执。
- 部分成功、部分失败、未知结果、冲突和异步任务只用 Toast 表示。
- 权限失败、认证失败、网络失败和服务不可用只用 Toast 表示。
- 导入导出任务、错误明细下载、长耗时任务和可取消任务只在自动消失 Toast 中呈现。
- 关闭 Toast 被误写成取消服务端任务、请求或审计记录。
- 没有 `dedupeKey`，重复触发导致 Toast 无限堆叠。
- 缺少 `sensitiveBoundary`，消息泄露敏感对象、数量、字段、文件名、筛选值或内部 ID。
- 移动端 Toast / Snackbar 遮挡底部主操作、危险确认、键盘输入、安全区域或恢复入口。

浏览器、屏幕阅读器、触摸设备和真实组件运行时未执行，保持未验证。
