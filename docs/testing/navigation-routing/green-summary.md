# 导航与路由 GREEN 证据摘要

当前规范和审计证明以下结构已经就位：

- `navigationState` 明确包含 `routeOwnerId`、`currentLocation`、`sourceContext`、`returnPolicy`、`historyIntent`、`permissionVersion`、`dirtyBlockers`、`focusRestoreTarget` 和 `disposalLog`。
- 返回不得直接等同于 `history.back()`；返回列表、关闭容器、返回上级、保存后返回和外链返回都必须读取 `sourceContext` 与 `returnPolicy`。
- 浏览器 Back/Forward、面包屑、Tabs、菜单导航、关闭容器和外部链接都必须经过同一离开保护管线，并读取 `dirtyBlockers`。
- 面包屑表示层级路径，不表示最近历史；Tabs 只用于同一资源或同一任务上下文。
- 权限、租户/工作区、角色或数据范围变化后，旧导航上下文、旧面包屑标签、旧记录名、旧返回目标、旧 URL 参数和旧焦点目标都必须重新证明安全。
- route/unmount 后的迟到回调不得写回内容、URL、标题、面包屑、Tabs、全局反馈或焦点。
- 移动端不得删除返回、当前位置、未保存保护、权限说明或恢复路径。
- 浏览器、屏幕阅读器、触控设备、真实组件和真实视口检查在本轮文档工作中仍是未验证，需要在具体页面实现时补充。

对应静态审计入口：`ruby docs/testing/navigation-routing/navigation-routing-audit.rb --mutations`。
