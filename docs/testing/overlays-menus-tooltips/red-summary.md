# 浮层菜单与提示 RED 证据摘要

这些负向场景必须被规范和审计识别为失败：

- 没有 `overlayState`，或缺少 `overlayKind`、`triggerOwner`、`contentOwner`、`placementPolicy`、`interactionMode`、`dismissPolicy`、`focusPolicy`、`itemStates`、`responsivePolicy`、`disposalLog`。
- 重要信息只放在 Hover、Tooltip、Popover 临时可见状态或 Context Menu 里。
- Tooltip / Popover 承载唯一必读权限原因、错误、确认后果、危险操作、结果回执、审计凭证或恢复入口。
- 更多菜单成为隐藏权限原因、错误、确认后果或唯一恢复入口的地方。
- Context Menu 是关键操作唯一入口，没有按钮、更多菜单、键盘或等价路径。
- 移动端复杂菜单没有转换为 Action Sheet 或 Drawer，导致触摸目标过小或 hover-only 内容不可达。
- 菜单项只有“操作”“更多”“处理”“查看”等裸词，没有动作对象。
- 禁用菜单项、禁用按钮或只读能力的原因只存在于 hover tooltip。
- 危险菜单项没有保留风险标记、影响范围、确认策略、请求身份、结果回执和审计回执，或没有进入 `risk-actions.md`。
- 非模态浮层被父容器、滚动区、固定列、固定页脚、`overflow` 或 `transform` 裁切。
- 浮层缺少 Portal、flip、collision、max-height 或内部滚动策略，导致层级和定位不稳定。
- route/unmount、权限变化、断点转换或 trigger 消失后，旧菜单、Popover、Tooltip 或迟到定位回调继续悬空或写回。
- 移动端不得删除菜单入口、禁用原因、危险确认、错误恢复或权限说明。
- 浏览器、屏幕阅读器、触摸设备、真实组件和真实视口没有执行时，不能写成已验证，必须标为未验证。

对应静态审计入口：`ruby docs/testing/overlays-menus-tooltips/overlays-menus-tooltips-audit.rb --mutations`。
