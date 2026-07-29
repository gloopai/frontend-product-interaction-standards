# 权限、租户与可见性 RED 证据

- 若缺少 `permissionVisibilityState`，或未声明 `permissionOwnerId`、`principalSnapshot`、`resourceSnapshot`、`capabilityMatrix`、`visibilityState`、`reasonState`、`dataBoundary`、`actionBoundary`、`cacheBoundary`、`focusBoundary`、`a11yBoundary` 和 `responsivePolicy`，应被判定为失败。
- 若只使用 `canEdit`、`isAdmin`、`disabled`、`hidden`、403 错误或组件库默认权限插槽表达权限，应被判定为失败。
- 若隐藏、禁用、只读、未启用和无权限被混成同一种状态，应被判定为失败；隐藏、禁用、只读、未启用和无权限不是同一件事。
- 若未启用能力仍保留 DOM、state、handler 或 request 入口，应被判定为失败；未启用表示产品或配置没有启用该能力，DOM、state、handler 和 request 入口均为 0。
- 若权限、租户/工作区、角色、认证状态、对象状态、权限版本或资源版本变化后没有原子重算，应被判定为失败；权限变化后必须原子重算。
- 若旧可见数据、旧菜单、旧按钮、旧确认、旧下载链接、旧任务入口、旧错误明细、旧搜索结果、旧表单草稿、旧图表明细或旧 ARIA label 继续暴露，应被判定为失败。
- 若无权限状态泄露对象名称、数量、字段、文件名、路径、父子关系、导出范围、错误明细、任务结果、搜索摘要、内部 ID、图标、排序位置、旧缓存或旧可访问名称，应被判定为失败；无权限状态不得泄露对象名称。
- 若旧请求、旧下载、旧导出、旧取消、旧重试、旧错误明细或旧审计入口继续使用旧权限版本，应被判定为失败。
- 若移动端删除权限说明、只读原因、禁用原因、申请权限、切换租户/工作区、安全占位、重新认证或恢复路径，应被判定为失败。
- 若未执行真实浏览器、键盘、屏幕阅读器、触摸、租户/工作区切换、权限降级、权限升级、缓存失效和移动端视口，却写成已验证，应被判定为失败；必须标为未验证。
