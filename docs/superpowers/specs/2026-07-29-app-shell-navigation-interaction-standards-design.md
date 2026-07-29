# 管理台 App Shell 与导航外框交互规范设计

## 背景

现有 `navigation-routing.md` 约束页面、路由、返回和浏览器历史，但管理台的全局外框仍缺少独立 owner。实际落地时，侧边栏、顶部栏、租户/工作区切换、用户菜单、通知入口、全局搜索入口、折叠菜单和移动端导航 Drawer 常常承担安全与信息架构职责；如果只按普通导航或普通菜单处理，容易出现旧菜单泄露、当前页面不清楚、权限变化后入口残留、移动端丢核心入口等问题。

## 目标

新增 `references/app-shell-navigation.md` 作为管理台 App Shell 与导航外框 owner，定义 `appShellNavigationState`，并与 `navigation-routing.md`、`permissions-tenancy-visibility.md`、`admin-console.md`、`responsive-adaptive.md`、`search-command-palette.md`、`notifications-message-center-announcements.md`、`overlays-menus-tooltips.md`、`buttons.md` 和 `auth-session-reauth.md` 建立边界。

## 范围

覆盖侧边导航、顶部导航、全局导航、应用外框、Logo/Home 入口、当前导航项、折叠菜单、用户菜单、租户/工作区切换、全局搜索入口、通知入口、帮助入口、移动端导航 Drawer、全局加载/权限收敛和外框级焦点/公告。

不覆盖具体页面路由策略、页面内 Tabs、字段菜单、业务列表、营销站点导航、视觉品牌 token、后端权限模型或业务项目菜单配置。

## 关键设计

- 每个管理台外框声明 `appShellNavigationState`，记录 shell owner、导航结构、当前项、租户/工作区、权限版本、全局入口、用户菜单、响应式形态、焦点和运行时验证边界。
- App Shell 是跨页面持久 owner；页面切换不得重建不必要的全局入口，也不得让旧页面迟到回调改写外框。
- 菜单可隐藏、禁用或只读，但三者语义必须分开；权限降级后旧菜单、旧 badge、旧 tooltip、旧 ARIA label、旧快捷键和旧入口必须失效。
- 工作区/租户切换不是普通 Select；切换必须冻结身份、权限、当前页面、未保存 blocker、可恢复目标和失败恢复。
- 全局搜索、通知、帮助、用户菜单只是入口，不能替代各自 owner 的状态、结果、审计或恢复。
- 移动端可以将侧边栏转为 Drawer/Bottom Sheet/独立导航页，但不得删除当前位置、主导航、工作区切换、权限说明、返回/恢复路径和关键全局入口。

## 验收

新增 Ruby 审计检查 owner 条款、SKILL 路由、README/HANDOFF 入口、相邻 owner 链接、RED/GREEN 证据和项目特定词泄露。运行时浏览器、键盘、屏幕阅读器、触摸、真实权限切换、真实租户切换和移动端视口未执行时必须标为未验证。
