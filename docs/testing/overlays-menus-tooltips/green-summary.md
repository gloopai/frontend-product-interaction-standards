# 浮层菜单与提示 GREEN 证据摘要

当前规范和审计证明以下结构已经就位：

- `overlayState` 明确包含 `overlayId`、`overlayKind`、`triggerOwner`、`contentOwner`、`openState`、`placementPolicy`、`interactionMode`、`dismissPolicy`、`focusPolicy`、`itemStates`、`responsivePolicy` 和 `disposalLog`。
- owner 覆盖 Tooltip、Popover、Menu、Dropdown Menu、Context Menu、Action Sheet 和 mobile Drawer。
- 重要信息不得仅依赖 Hover、Tooltip、Popover 临时可见状态或 Context Menu。
- Tooltip / Popover 不得承载唯一必读权限原因、错误、确认后果、危险操作、结果回执、审计凭证或恢复入口。
- 更多菜单不得成为隐藏权限原因、错误、确认后果或唯一恢复入口的地方；Context Menu 不能是唯一入口。
- 菜单项必须有动作对象、权限状态、可访问名称、禁用原因、请求身份和结果 owner；危险菜单项必须进入 `risk-actions.md`。
- 非模态浮层必须通过 Portal、flip、collision、max-height、内部滚动或承载转换避免裁切和遮挡。
- route/unmount、权限变化、断点转换或 trigger 消失后，旧浮层和迟到回调必须清理。
- 移动端不得删除菜单入口、禁用原因、危险确认、错误恢复或权限说明；Hover 内容必须有触摸和键盘等价路径。
- 浏览器、屏幕阅读器、触摸设备、真实组件和真实视口检查在本轮文档工作中仍是未验证，需要在具体页面实现时补充。

对应静态审计入口：`ruby docs/testing/overlays-menus-tooltips/overlays-menus-tooltips-audit.rb --mutations`。
