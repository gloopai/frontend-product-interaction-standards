# 管理台 App Shell 与导航外框规范 GREEN 复核

本轮 GREEN 复核确认新增 `references/app-shell-navigation.md` 作为 App Shell、应用外框、管理台外框、全局导航、侧边导航、顶部导航、主导航、折叠菜单、用户菜单、工作区/租户切换、全局搜索入口、通知入口和移动端导航 Drawer 的外框级 owner。

## 状态模型覆盖

`appShellNavigationState` 已要求声明以下字段：

- `shellOwnerId`
- `shellSurface`
- `navigationRegistry`
- `currentNavBinding`
- `workspaceTenantBinding`
- `globalEntryRegistry`
- `userMenuBinding`
- `permissionBoundary`
- `responsivePolicy`
- `focusAnnouncementPolicy`
- `lifecycleDisposal`
- `runtimeVerification`

其中 `navigationRegistry`、`workspaceTenantBinding` 和 `globalEntryRegistry` 是本轮重点：它们分别约束全局导航结构、租户/工作区切换和全局入口转交。

## 集成关系覆盖

App Shell owner 已与以下相邻规范建立关系：

- `references/navigation-routing.md`
- `references/permissions-tenancy-visibility.md`
- `references/admin-console.md`
- `references/responsive-adaptive.md`
- `references/search-command-palette.md`
- `references/notifications-message-center-announcements.md`
- `references/overlays-menus-tooltips.md`
- `references/buttons.md`
- `references/auth-session-reauth.md`

## 入口与交接覆盖

`SKILL.md` 已补充 App Shell、应用外框、管理台外框、全局导航、侧边导航、顶部导航、用户菜单、工作区/租户切换、全局搜索入口、通知入口、移动端导航 Drawer 和英文 navigation shell 关键词的路由。

`README.md` 已补充“管理台 App Shell 与导航外框规范”和 `references/app-shell-navigation.md` 的入口说明。

`HANDOFF.md` 已补充“管理台 App Shell 与导航外框”交接摘要，并链接 `references/app-shell-navigation.md`。

## 验证边界

本轮 GREEN 复核只验证规范结构、路由、交叉引用和可执行审计契约；真实浏览器、键盘、读屏、触摸、权限切换、租户切换、会话变化、移动端 Drawer、快捷键和真实视口未执行，仍必须在具体项目落地时标为未验证。
