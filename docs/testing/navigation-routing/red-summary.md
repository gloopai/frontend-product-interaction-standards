# 导航与路由 RED 证据摘要

这些负向场景必须被规范和审计识别为失败：

- 页面只有 `history.back()`，没有 `navigationState`、`sourceContext` 或 `returnPolicy`，却向用户承诺“返回列表”。
- 浏览器 Back/Forward、面包屑、Tabs、菜单导航、关闭容器和外部链接没有经过同一离开保护管线，导致 `dirtyBlockers` 被绕过。
- 面包屑表示层级路径，不表示最近历史；若把最近访问记录伪装成面包屑，用户会误判当前位置。
- Tabs 只用于同一资源或同一任务上下文；若把跨模块、跨权限域或跨租户页面放进同一组 Tabs，任务边界会被打碎。
- 权限变化后继续展示旧导航上下文、旧面包屑标签、旧记录名、旧返回目标、旧 URL 参数或旧焦点目标，属于敏感信息泄露风险。
- route/unmount 后的迟到回调继续写回标题、内容、面包屑、Tabs、全局反馈或焦点，属于旧 owner 污染新 owner。
- 移动端不得删除返回、当前位置、未保存保护、权限说明或恢复路径；只留下系统 Back 或手势返回不合格。
- 浏览器、屏幕阅读器、触控设备、真实组件和真实视口没有执行时，不能写成已验证，必须标为未验证。

对应静态审计入口：`ruby docs/testing/navigation-routing/navigation-routing-audit.rb --mutations`。
