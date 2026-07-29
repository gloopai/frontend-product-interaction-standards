# 树形结构与级联 GREEN 证据

- `treeHierarchyState` 固定包含 `treeOwnerId`、`nodeIdentity`、`treeDataSnapshot`、`expandedNodeIds`、`activeNodeId`、`selectedNodeIds`、`checkedNodeState`、`cascadePolicy`、`filterState`、`loadState`、`permissionBoundary`、`commitMode`、`feedbackState`、`a11yPolicy` 和 `responsivePolicy`。
- 展开、active、hover、filter match、visible descendants、indeterminate、partial loaded 和 optimistic preview 不会伪装成已提交选择。
- 节点使用稳定业务 ID、节点类型、父子关系、路径版本和权限版本，不使用展示名称、排序位置、过滤位置、懒加载顺序或 DOM key 作为业务身份。
- 半选只表达派生状态，不是业务提交值。
- `indeterminate` / half-checked / partial selected 不能提交给后端。
- 懒加载未完成、过滤后仅展示部分节点、权限未知或存在 disabled 后代时，“全选当前可见”不会被伪装成“全选全部后代”。
- 无权限节点不泄露节点名称、数量、路径、父子关系、图标、类型、内部 ID、排序位置、子节点是否存在或旧缓存。
- 移动端保留搜索、展开、返回上级、路径摘要、已选摘要、清空、应用、错误说明、权限说明和恢复路径。
- 真实浏览器、触摸、键盘、屏幕阅读器、权限切换、懒加载、过滤、虚拟化和移动端视口未实际执行时，必须标为未验证。
