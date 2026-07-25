# 现有规范加固：最终审计账本

**审计日期：** 2026-07-25  
**结论：** F-01 至 F-07 均已以静态规则修订处置；S-01 至 S-07 均为 `determined-static`。这不是具体组件的运行时验收。

## 范围、事实来源与路由决定

本账本消费批准设计 `docs/superpowers/specs/2026-07-25-existing-standards-hardening-design.md`，并以 Dialog、Drawer、Select / Combobox、响应式四份 owner 规范为唯一规则证据。专项几何、动画和模态行为分别仍由 `references/dialogs.md` 与 `references/drawers.md` 持有；提交值、草稿、active、placement 和 ARIA 由 `references/selects-comboboxes.md` 持有；跨断点单实例与形态阶段由 `references/responsive-adaptive.md` 持有。

`SKILL.md` **no-change**：其四条路由已分别指向 Dialog、Drawer、Select / Combobox 与响应式 owner 文件，且本轮没有新增全局红线或组件类别。`README.md` **no-change**：已有四份完整规则链接和对生命周期/转换的用户摘要；本轮只是消除 owner 文件内已有主题的歧义，复制完整规则会违反职责边界。

## 发现处置

| ID | 处置 | 精确静态证据 | 结论 |
| --- | --- | --- | --- |
| F-01 | `repaired-static` | `references/dialogs.md`「语义与背景隔离」第 12 条 | 模态活动开始时当前 Dialog 实例取得并持有页面滚动锁，且与背景隔离同属该实例。 |
| F-02 | `repaired-static` | `references/dialogs.md`「动画」第 6 条；「响应式与清理」第 27 条 | 普通关闭从请求到动画完成、DOM 移除前持续保护；其后才统一清理。路由变化/卸载是立即、幂等的例外。 |
| F-03 | `repaired-static` | `references/responsive-adaptive.md`「跨端形态与状态延续」第 2–3 条 | 初次打开采用最终形态专项入场；随后关闭只采用关闭开始时当前渲染形态的专项退出。 |
| F-04 | `repaired-static` | `references/responsive-adaptive.md`「跨端形态与状态延续」第 8 条 | `closing` 后形态冻结；后续断点不得转换、重建、启动第二动画或额外清理。 |
| F-05 | `repaired-static` | `references/selects-comboboxes.md`「`resolvedPlacement` 转换的焦点、ID 与 ARIA」 | 每一目标 placement 都有唯一等价焦点；精确节点存活时保留，否则只移动一次，且不提交会话状态。 |
| F-06 | `repaired-static` | `references/selects-comboboxes.md`「`resolvedPlacement` 转换的焦点、ID 与 ARIA」 | 逻辑 popup/Listbox/option ID 延续；在焦点移动前或同一 committed render 同步目标 ARIA，并删除来源专属属性。 |
| F-07 | `repaired-static` | `references/selects-comboboxes.md`「验收与报告」第 1–4 项 | 所有不同 placement 的转换都有状态/请求、焦点、ID/引用和目标 ARIA 的集中验收，且明确要求报告未执行检查。 |

没有 `no-change` finding：七项已记录的缺口均需要上述最小 owner 修订。没有新增组件类别或重复维护一份专项完整规则。

## 静态场景重放（S-01 至 S-07）

每个场景都按批准设计的五个维度推演。下表中的五列均给出 owner 章节引用，因此状态为 `determined-static`；这表示规则文本能得出唯一预期，不表示浏览器已经执行过该行为。

| 场景 | 业务状态 | 单一活动实例/基础设施 | 关闭边界 | 焦点、背景与滚动连续性 | 动画、卸载与一次清理 |
| --- | --- | --- | --- | --- | --- |
| S-01：打开 Dialog 在宽屏与 Drawer 间往返 | `determined-static`：响应式「跨端形态与状态延续」第 1、3、7 条保持业务语义与未提交状态。 | `determined-static`：响应式第 8 条只保留一个实例、遮罩、请求、回调、焦点陷阱和滚动锁。 | `determined-static`：响应式第 3 条关闭使用开始时当前形态；Dialog「动画」第 6 条、Drawer「动画」第 11–12 条给出关闭边界。 | `determined-static`：响应式第 3、8 条保持焦点、隔离和锁；Dialog「语义与背景隔离」第 12 条与 Drawer「焦点、键盘、语义与背景隔离」第 18 条定义模态保护。 | `determined-static`：响应式第 3、8 条禁止叠加动画并冻结 closing；Dialog「响应式与清理」第 27 条及 Drawer「异步状态、错误与清理」第 22 条规定一次幂等清理。 |
| S-02：Select PC 浮层转 Drawer，含 query、active、loading/error | `determined-static`：Select「状态、不变量与会话」及「`resolvedPlacement` 转换的焦点、ID 与 ARIA」保持提交值、草稿与回调边界。 | `determined-static`：Select「确定性搜索位置决策」与响应式第 8 条禁止重复请求、遮罩、陷阱、锁和动画。 | `determined-static`：Select「模式与精确语义」的 `drawer` 与 Drawer「动画」第 11–12 条规定明确关闭、动画完成后卸载。 | `determined-static`：Select「`resolvedPlacement` 转换的焦点、ID 与 ARIA」指定 Drawer 内层搜索焦点和返回目标；Drawer「焦点、键盘、语义与背景隔离」第 14、18 条保证陷阱与隔离。 | `determined-static`：Select 同一转换章节的稳定 ID/同步 ARIA，加上「验收与报告」第 1–4 项及 Drawer「异步状态、错误与清理」第 22 条，限定一次转换与清理。 |
| S-03：多层 Dialog、Drawer 或混合叠加并逐层关闭 | `determined-static`：Dialog「多层 Dialog」第 17–18 条及 Drawer「焦点、键盘、语义与背景隔离」第 19 条只处理最上层；失败保持当前层由 Dialog 第 20–23 条、Drawer 第 20–21 条规定。 | `determined-static`：Dialog 第 17–19 条和 Drawer 第 19 条要求最上层唯一可交互、下层与页面隔离、共享层级。 | `determined-static`：Dialog「动画」第 6 条、Drawer「动画」第 11–12 条规定显式关闭且保护延续到动画完成。 | `determined-static`：Dialog 第 18 条与 Drawer 第 19 条规定逐层返回焦点；Dialog 第 12 条、Drawer 第 18 条连续保持隔离和滚动锁。 | `determined-static`：Dialog「响应式与清理」第 27 条和 Drawer「异步状态、错误与清理」第 22 条让每个实例只释放自身、幂等清理。 |
| S-04：异步提交时 Escape、内部关闭、断点、路由变化或卸载 | `determined-static`：Dialog「异步、错误与重复操作」第 20–23 条、Drawer「异步状态、错误与清理」第 20–21 条防重复并保持错误；响应式第 8 条不中断工作。 | `determined-static`：Dialog「语义与背景隔离」第 12 条、Drawer 第 18 条、响应式第 8 条分别规定实例持有保护且不重复。 | `determined-static`：Dialog「焦点与键盘」第 11 条、Drawer第 15 条规定 Escape 例外；Dialog「响应式与清理」第 27 条和 Drawer 第 22 条把路由/卸载规定为立即幂等 teardown。 | `determined-static`：Dialog「动画」第 6 条、Drawer第 12 条在普通关闭期间保持焦点/背景/锁；路由卸载按 Dialog第 27 条、Drawer第 22 条释放所属保护。 | `determined-static`：响应式第 8 条禁止 closing 时额外动画或清理；Dialog第 27 条、Drawer第 22 条定义一次清理边界。 |
| S-05：虚拟键盘、低高度、200% 缩放、安全区域与 reduced motion | `determined-static`：响应式「核心原则」第 1–3 条及「布局、视口与输入」第 1–3 条保持语义与可达性。 | `determined-static`：响应式「跨端形态与状态延续」第 8 条在约束触发转换时仍为单实例。 | `determined-static`：Dialog「动画」第 5–7 条、Drawer「动画」第 11–13 条和响应式「验收与报告」规定专项关闭及 reduced-motion 边界。 | `determined-static`：Dialog「响应式与清理」第 24–26 条、Drawer「布局、滚动和四个方向」第 6、9–10 条、响应式「布局、视口与输入」第 1–4 条确保焦点、操作和安全区。 | `determined-static`：响应式第 3、8 条与「验收与报告」规定无叠加动画、冻结 closing、一次卸载/清理。 |
| S-06：orphaned invalid、远程竞态与进入/离开 `none` | `determined-static`：Select「状态、不变量与会话」保留 orphaned invalid；「选择、ARIA option 与 active 对账」规定 `none` 暂停 query 过滤和唯一 active 对账；「键盘、关闭、错误与元素状态」规定远程竞态。 | `determined-static`：Select「确定性搜索位置决策」与「`resolvedPlacement` 转换的焦点、ID 与 ARIA」禁止转换重复请求、回调及模态基础设施。 | `determined-static`：Select「模式与精确语义」的 `none` 和「键盘、关闭、错误与元素状态」规定 Escape/Tab 的非提交关闭。 | `determined-static`：Select「`resolvedPlacement` 转换的焦点、ID 与 ARIA」将 `none` 焦点唯一映射到 Select-only Combobox；「选择、ARIA option 与 active 对账」限定有效的 active 描述符。 | `determined-static`：Select 同一转换章节的稳定 ID/ARIA 同步，以及「验收与报告」第 1–4 项，禁止多次回调、请求和清理。 |
| S-07：关闭动画期间重复关闭、重新打开或形态变化 | `determined-static`：Dialog「动画」第 6 条和 Drawer第 12 条拒绝重复操作；响应式第 8 条保持异步状态。 | `determined-static`：响应式第 8 条冻结 closing 实例并禁止重建/额外基础设施。 | `determined-static`：响应式第 3、8 条锁定 closing 时形态；Dialog第 6 条和 Drawer第 11–12 条保留唯一关闭流程。 | `determined-static`：Dialog第 6 条、Drawer第 12 条和响应式第 8 条规定完成前持续遮罩、隔离、锁与焦点约束。 | `determined-static`：响应式第 8 条禁止第二退出动画或额外清理；Dialog第 27 条和 Drawer第 22 条规定 DOM 移除后的唯一幂等 teardown。 |

## 验证记录

| 验证类别 | 结果 | 证据/边界 |
| --- | --- | --- |
| 官方 Skill 验证 | `passed-static` | 使用带 PyYAML 的隔离环境执行 `quick_validate.py .`；输出为 `Skill is valid!`。 |
| Markdown 相对链接 | `passed-static` | 仓库本地 Ruby 检查无输出且退出为 0。 |
| 占位符扫描 | `passed-static` | 对 `SKILL.md`、`README.md`、`references`、`docs/audits` 的指定 `rg` 模式无匹配。 |
| diff 检查与最终差异审查 | `passed-static` | `git diff --check` 退出为 0；`HEAD~3` 审查只包含 F-01 至 F-07 的 owner 规则与本账本，没有新组件类别或运行时通过声明。 |
| 静态场景重放 | `passed-static` | 上表 S-01 至 S-07 的五项断言均具 owner 章节引用。三份新鲜 GREEN 代理输出仅作为独立交叉检查：Select 转换、嵌套栈/路由卸载、以及 closing 期间断点变化均与修订契约一致；不复制其长文。 |
| 浏览器、屏幕阅读器、触摸设备与真实视口 | `unperformed-runtime` | **未验证。** 仍需在具体组件中实际点击/拖拽、切换断点与缩放、打开虚拟键盘、检查 DOM/ARIA、记录焦点与请求，并以读屏和触摸设备复测。 |

## 最终边界

本轮完成的是规范文本、交叉引用和静态推演。不得把上表的 `passed-static` 或 `determined-static` 写成浏览器、屏幕阅读器、触摸设备或真实视口已经通过；这些运行时检查保持 `unperformed-runtime`，直到具备具体实现和目标环境。
