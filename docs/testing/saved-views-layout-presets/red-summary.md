# 保存视图、视图预设与个性化布局 RED 证据摘要

这些负向场景必须被规范和审计识别为失败：

- 缺少 `savedViewState`，或者缺少 `appliedSnapshot`、`layoutSnapshot`、`draftBinding`、`defaultPolicy`、`sharePolicy`、`applyIntent`、`permissionBoundary`、`resultReceipt`、`auditBinding` 等状态边界。
- 保存了筛选草稿、Select query、active option 或未提交日期范围。
- 保存了当前页码、展开行、hover、高亮、焦点、loading、错误状态或旧结果缓存。
- 保存视图没有读取 `appliedSnapshot` 和明确允许持久化的 `layoutSnapshot`，而是从当前输入控件、当前页面 DOM 或临时表格状态拼装。
- 保存视图前没有说明保存的是已应用条件，也没有要求用户先应用/确认草稿。
- 应用视图没有 `applyIntent`，Query Filters、Data Table、Toolbar、URL、结果摘要和焦点读取了不同视图版本。
- 个人视图、共享视图、默认视图、团队默认、个人默认、角色默认和系统预设混在同一个状态里。
- 共享视图泄露无权限字段、筛选值、对象名称、数量、列名、内部 ID、成员、客户、文件名、金额、发票、密钥、审计字段或旧缓存。
- 权限、租户/工作区、角色、字段可见性、功能开关或数据范围变化后，旧视图仍可应用。
- 覆盖、删除、共享、设默认或恢复默认没有影响范围、视图版本、权限版本、请求身份和未知结果恢复。
- 高影响覆盖、删除、共享、设默认、取消共享或恢复默认在确认前发送请求；确认前请求数不是 0。
- 未知结果被写成已保存、已覆盖、已删除、已共享、已设为默认或已恢复默认。
- 移动端删除视图切换、当前视图说明、保存视图、覆盖视图、恢复默认、权限原因、冲突恢复、错误回执或审计入口。
- 真实浏览器、移动端、屏幕阅读器、权限/租户切换、URL 恢复、多人共享、默认冲突、审计写入和表格/筛选联动未执行时，不能写成已验证，必须标为未验证。

对应静态审计入口：`ruby docs/testing/saved-views-layout-presets/saved-views-layout-presets-audit.rb --mutations`。
