# 页面标题区与 Page Header 规范 RED 复核

当前规范缺少专门 owner 来约束 Page Header、页面标题区、页面头部、标题栏、页面标题、副标题、对象标题、状态摘要、标题区主操作、标题区权限说明和移动端标题区。

必须新增 `pageHeaderState`，并覆盖 `headerOwnerId`、`headerSurface`、`pageIdentity`、`titleBinding`、`subtitlePolicy`、`contextBinding`、`statusSummary`、`primaryActionSlot`、`secondaryActionSlot`、`navigationBinding`、`permissionBoundary`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification`。

审计必须能识别标题区被当作装饰、标题和内容快照不一致、主操作无 owner、面包屑/返回被标题区吞掉、旧标题或旧数量泄露、移动端标题区删除关键身份和真实交互未验证等缺口。

本轮 RED 阶段的真实浏览器、键盘、读屏、触摸、权限变化、路由切换、租户/工作区切换、移动端、断点转换和真实视口均未执行，必须标为未验证。
