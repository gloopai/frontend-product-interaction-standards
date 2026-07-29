# 页面标题区与 Page Header 交互规范设计

## 背景

管理台每个列表、详情、设置、报表、审批、任务和配置页都有页面标题区。它通常承载页面标题、副标题、对象身份、状态摘要、返回/面包屑附近区域、主操作、次要操作、刷新状态、权限说明和移动端压缩布局。现在这些要求分散在导航、按钮、工具栏、信息展示和权限规范里，容易导致标题与内容不一致、主操作无 owner、旧对象名泄露、移动端只剩图标或标题区被固定栏遮挡。

## 推荐方案

新增 `references/page-header-title-area.md` 作为页面标题区 owner。它不替代导航、App Shell、按钮或工具栏 owner，只负责“当前页面是谁、标题区展示什么、主操作槽归谁、标题区在权限/路由/移动端变化时如何收敛”。

## 范围

- 覆盖 Page Header、页面标题区、页面头部、标题栏、页面标题、副标题、对象标题、状态摘要、标题区主操作、标题区返回附近区域、标题区权限说明、标题区加载/刷新状态和移动端标题区。
- 排除 App Shell 全局导航、面包屑路由策略、按钮本体语义、表格工具栏、具体字段展示、品牌视觉 token。

## 状态模型

新增 `pageHeaderState`，至少包含 `headerOwnerId`、`headerSurface`、`pageIdentity`、`titleBinding`、`subtitlePolicy`、`contextBinding`、`statusSummary`、`primaryActionSlot`、`secondaryActionSlot`、`navigationBinding`、`permissionBoundary`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification`。

## 核心规则

1. 页面标题区不是装饰，也不是 App Shell 的一部分；它必须绑定当前页面 owner、URL、权限版本和业务范围。
2. 标题、对象名、状态、数量、时间范围、租户/工作区和权限说明必须来自同一有效快照；不得混用旧标题和新内容。
3. 标题区主操作只能作为入口，必须转交按钮、工具栏、表单、记录编辑、风险操作或对应业务 owner；标题区不能直接吞掉动作结果。
4. 面包屑、返回和路由来源仍归导航 owner；标题区只能展示或转交，不能把返回写成裸 `history.back()`。
5. 移动端可以压缩标题区，但不得删除页面身份、主要状态、权限说明、主操作入口、返回/恢复路径和运行时未验证声明。

## 验收

本轮只新增规范、路由、相邻引用和可执行审计。真实浏览器、键盘、读屏、触摸、权限变化、路由切换、租户/工作区切换、移动端和真实视口必须在具体项目落地时继续标为未验证。
