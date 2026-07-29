# 设置、偏好与配置页 GREEN 证据摘要

合格规范必须证明：

- `settingsState` 声明 `settingsScope`、`draftSettings`、`savedSettings`、`effectiveSettings`、`defaultSettings`、`applyMode`、dirty、reset、权限和结果回执。
- 设置项说明作用域，用户偏好、租户配置、工作区配置、项目配置、环境配置、角色配置、对象配置和集成配置不会混用。
- `draftSettings` 不会伪装成 `effectiveSettings`；显式保存模式下编辑只改变草稿。
- `applyMode` 区分即时生效、显式保存和需要确认。
- 保存、取消、恢复保存值、重置默认、继承默认和清空自定义是不同意图。
- 高风险设置进入风险 owner；权限变化后旧草稿、旧默认值、旧保存按钮和旧集成状态原子收敛。
- 部分成功、失败、冲突和未知结果不会伪装成成功。
- 移动端保留保存/取消、脏状态、作用域说明、默认值说明、危险确认、错误摘要、审计回执和恢复路径。
- 真实浏览器、触摸设备、屏幕阅读器、权限切换和移动端视口仍是未验证，需要在具体页面实现时补充。
