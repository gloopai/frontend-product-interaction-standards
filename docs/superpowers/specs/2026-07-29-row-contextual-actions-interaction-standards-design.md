# 行操作与上下文操作交互规范设计

## 背景

管理台列表里的行操作、更多菜单、右键菜单和卡片操作非常高频。常见问题是动作绑定当前 DOM 或 rowIndex，虚拟列表复用后误操作；权限变化后旧菜单项仍可见；编辑入口在行内直接承载字段；危险动作只靠菜单项和 Toast；右键或 hover 操作没有键盘/触摸等价入口。

## 设计方案

新增 `references/row-contextual-actions.md` 作为独立 owner。按钮、菜单、表格和卡片只负责入口形态与记录展示；行操作 owner 负责动作目标、来源快照、动作目录、可用性、权限、请求身份、结果回执和旧行清理。

核心状态为 `rowActionState`，包含 `recordIdentity`、`sourceSnapshot`、`actionCatalog`、`availabilityMap`、`requestIdentity`、`resultReceipt`、`riskHandoff`、`editSurfaceHandoff` 和 `lifecycleDisposal`。

## 关键规则

- 行操作不是“在当前行 DOM 上挂一个按钮”。
- 请求不得读取当前 hover row、active row、虚拟列表 DOM、菜单闭包里的旧 record 或 rowIndex。
- 虚拟行复用、分页、筛选、排序、自动刷新、权限变化和记录状态变化后，旧菜单必须失效或重新确认。
- 更多菜单不能隐藏唯一危险确认、权限原因、错误恢复或核心任务入口。
- 危险动作转交风险 owner；编辑/复制创建/配置转交记录编辑承载面。
- Toast 不能作为唯一结果回执。

## 非目标

- 不覆盖批量操作、多对象范围和部分成功。
- 不定义浮层定位和碰撞实现。
- 不规定具体业务字段、组件库或技术栈。

