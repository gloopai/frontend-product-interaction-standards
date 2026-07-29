# 页面标题区与 Page Header 规范 GREEN 复核

本轮 GREEN 复核确认新增 `references/page-header-title-area.md` 作为 Page Header、页面标题区、页面头部、标题栏、页面标题、副标题、对象标题、状态摘要、标题区主操作、标题区次要操作、标题区权限说明和移动端标题区的页面级 owner。

## 状态模型覆盖

`pageHeaderState` 已要求声明以下字段：

- `headerOwnerId`
- `headerSurface`
- `pageIdentity`
- `titleBinding`
- `subtitlePolicy`
- `contextBinding`
- `statusSummary`
- `primaryActionSlot`
- `secondaryActionSlot`
- `navigationBinding`
- `permissionBoundary`
- `responsivePolicy`
- `focusAnnouncementPolicy`
- `lifecycleDisposal`
- `runtimeVerification`

其中 `titleBinding`、`primaryActionSlot` 和 `navigationBinding` 是本轮重点：它们分别约束标题与快照一致、标题区主操作只能作为入口并转交对应 owner，以及面包屑/返回仍归导航 owner。

## 集成关系覆盖

页面标题区 owner 已与以下相邻规范建立关系：

- `references/navigation-routing.md`
- `references/page-toolbars-actions.md`
- `references/information-display.md`
- `references/app-shell-navigation.md`
- `references/responsive-adaptive.md`
- `references/buttons.md`
- `references/permissions-tenancy-visibility.md`
- `references/admin-console.md`

## 入口与交接覆盖

`SKILL.md` 已补充 Page Header、页面标题区、页面头部、标题栏、页面标题、副标题、对象标题、状态摘要、标题区主操作、移动端标题区和英文 page header / page title / header actions 关键词的路由。

`README.md` 已补充“页面标题区与 Page Header 规范”和 `references/page-header-title-area.md` 的入口说明。

`HANDOFF.md` 已补充“页面标题区与 Page Header”交接摘要，并链接 `references/page-header-title-area.md`。

## 验证边界

本轮 GREEN 复核只验证规范结构、路由、交叉引用和可执行审计契约；真实浏览器、键盘、读屏、触摸、权限变化、路由切换、租户/工作区切换、移动端、断点转换、浏览器 `document.title` 和真实视口未执行，仍必须在具体项目落地时标为未验证。
