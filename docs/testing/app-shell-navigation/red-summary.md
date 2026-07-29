# 管理台 App Shell 与导航外框规范 RED 复核

当前规范已经覆盖 `navigationState`、`permissionVisibilityState`、`searchCommandState`、`notificationCenterState` 和 `consoleSurface`，但缺少专门的 `appShellNavigationState` owner。

缺口如下：

- 侧边导航、顶部导航、全局导航、应用外框、Logo/Home 入口和折叠菜单没有独立路由。
- 用户菜单、租户/工作区切换、通知入口、全局搜索入口和帮助入口容易被当成普通菜单或普通链接。
- 当前导航项、菜单 badge、权限隐藏/禁用、旧 tooltip、旧 ARIA label 和旧快捷键没有外框级收敛要求。
- 移动端导航 Drawer 或 Bottom Sheet 可能删除当前位置、主导航、工作区切换、权限说明和恢复路径。

RED 期望新增 owner 后至少覆盖 `appShellNavigationState`、`shellOwnerId`、`shellSurface`、`navigationRegistry`、`currentNavBinding`、`workspaceTenantBinding`、`globalEntryRegistry`、`userMenuBinding`、`permissionBoundary`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal`、`runtimeVerification`、未验证。
