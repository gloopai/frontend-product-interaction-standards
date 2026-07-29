# 权限、租户与可见性 GREEN 证据

- `permissionVisibilityState` 固定包含 `permissionOwnerId`、`principalSnapshot`、`resourceSnapshot`、`capabilityMatrix`、`visibilityState`、`reasonState`、`dataBoundary`、`actionBoundary`、`cacheBoundary`、`focusBoundary`、`a11yBoundary` 和 `responsivePolicy`。
- 不使用单独的 `canEdit`、`isAdmin`、`disabled`、`hidden`、403 错误或组件库默认权限插槽替代权限 owner。
- 隐藏、禁用、只读、未启用和无权限不是同一件事。
- 未启用表示产品或配置没有启用该能力，DOM、state、handler 和 request 入口均为 0。
- 权限、租户/工作区、角色、认证状态、对象状态、权限版本或资源版本变化后，必须原子重算可见数据、菜单、按钮、表单字段、筛选项、导航、下载、任务入口、确认面板和缓存。
- 旧可见数据、旧菜单、旧按钮、旧确认、旧下载链接、旧任务入口、旧错误明细、旧搜索结果、旧表单草稿、旧图表明细和旧 ARIA label 不得继续暴露。
- 无权限状态不得泄露对象名称、数量、字段、文件名、路径、父子关系、导出范围、错误明细、任务结果、搜索摘要、内部 ID、图标、排序位置、旧缓存或旧可访问名称。
- 请求、下载、导出、取消、重试、查看错误明细和查看审计绑定当前 `principalSnapshot`、`resourceSnapshot`、`capabilityMatrix` 和权限版本。
- 移动端不得删除权限说明、只读原因、禁用原因、申请权限、切换租户/工作区、安全占位、重新认证或恢复路径。
- 真实浏览器、键盘、屏幕阅读器、触摸、租户/工作区切换、权限降级、权限升级、缓存失效和移动端视口未实际执行时，必须标为未验证。
