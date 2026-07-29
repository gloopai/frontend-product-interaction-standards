# 树形结构与级联 RED 证据

- 若缺少 `treeHierarchyState`，或未声明 `treeOwnerId`、`nodeIdentity`、`treeDataSnapshot`、`checkedNodeState`、`cascadePolicy`、`permissionBoundary`、`a11yPolicy` 和 `responsivePolicy`，应被判定为失败。

- 若使用展示名称、数组下标、过滤后位置、懒加载返回顺序或 DOM key 作为业务身份，应被判定为失败；`nodeIdentity` 必须绑定稳定业务 ID、节点类型、父子关系、路径版本和权限版本。
- 若展开、active、hover、filter match、visible descendants、indeterminate、partial loaded 和 optimistic preview 被提交为已选择，应被判定为失败。
- 若半选被当成业务提交值，应被判定为失败；半选只表达派生状态，不是业务提交值。
- 若 `indeterminate` / half-checked / partial selected 不能提交给后端 这一条被删除或被反向实现，应被判定为失败。
- 若过滤后“全选当前可见”被当成“全选全部后代”，应被判定为失败。
- 若懒加载失败被当成没有子节点，或局部加载被当成完整加载，应被判定为失败。
- 若无权限节点泄露节点名称、数量、路径、父子关系、图标、类型、内部 ID、排序位置、子节点是否存在或旧缓存，应被判定为失败。
- 若移动端删除搜索、展开、返回上级、路径摘要、已选摘要、清空、应用、错误说明、权限说明或恢复路径，应被判定为失败。
- 若未执行真实浏览器、触摸、键盘、屏幕阅读器、权限切换、懒加载、过滤、虚拟化和移动端视口，却写成已验证，应被判定为失败；必须标为未验证。
