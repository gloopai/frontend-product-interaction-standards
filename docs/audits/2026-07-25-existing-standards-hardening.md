# 现有规范加固：最终审计账本

**审计日期：** 2026-07-25
**分支基线：** `3ce6579e137fc84aa497df90447f133164fa247e`
**结论：** F-01 至 F-07 均已由 owner 规则作 `repaired-static` 处置；S-01 至 S-07 均为 `determined-static`。这不是具体组件的运行时验收。

## 范围、事实来源与路由决定

本账本消费批准设计 `docs/superpowers/specs/2026-07-25-existing-standards-hardening-design.md`，并以 Dialog、Drawer、Select / Combobox、响应式四份规范为唯一规则证据。专项几何、动画和模态行为分别由 `references/dialogs.md` 与 `references/drawers.md` 持有；提交值、草稿、active、placement、Select 请求/回调和 ARIA 由 `references/selects-comboboxes.md` 持有；跨断点单实例、形态阶段和 route/unmount disposal 由 `references/responsive-adaptive.md` 持有。

`SKILL.md` **no-change**：四条路由仍分别指向四个 owner 文件，本轮没有新增全局红线或组件类别。`README.md` **no-change**：已有四份完整规则链接与生命周期/转换摘要；复制本轮完整修订会违反 owner 边界。

## F-01 至 F-07 耐久发现账本

“基线”均指分支基线提交 `3ce6579e137fc84aa497df90447f133164fa247e` 中的规则；Git 历史不是下表的替代品。

| ID | 基线证据 | 基线失败结果 | 合理实现为何会分歧 | Owner | 最小修复 | 最终处置 |
| --- | --- | --- | --- | --- | --- | --- |
| F-01 | 基线 Dialog「语义与背景隔离」第 12 条只要求背景不可交互；「响应式与清理」第 27 条却在关闭时提到清理滚动锁。 | `baseline-failing`：打开时没有规范性取得/持有页面滚动锁的责任方。 | 一种实现由 Dialog 实例取得锁，另一种依赖未定义外层或只在 cleanup 中尝试解锁；二者资源所有权不同。 | `references/dialogs.md` | 在模态活动开始时由当前实例取得并持有滚动锁，并为普通关闭/销毁给出 owner 清理。 | `repaired-static`：Dialog「语义与背景隔离」第 12 条定义取得方；「响应式与清理」第 27 条限定每实例只释放自己的保护。运行时计数未执行。 |
| F-02 | 基线 Dialog「动画」第 5–6 条只说动画后卸载和关闭结束前保持部分保护；第 27 条把“关闭、路由变化或卸载”合为同一清理时点。 | `baseline-failing`：普通关闭可能在退出开始、退出完成或 DOM 移除后释放保护并恢复焦点。 | 一种实现先解除焦点陷阱再卸载，另一种先卸载再解除；多个完成回调还可能重复恢复焦点。 | `references/dialogs.md` | 为普通关闭规定唯一顺序，并把 route/unmount 作为立即 disposal 例外。 | `repaired-static`：Dialog「焦点与键盘」第 10 条规定“退出完成 → DOM 移除 → 本实例保护释放 → 恰好一次焦点恢复”；第 27 条定义 disposal 例外。 |
| F-03 | 基线响应式「跨端形态与状态延续」第 2 条只定义初次入场动画，第 3 条只定义打开态转换无入/退场动画。 | `baseline-failing`：实时转换后的 later close 没有唯一专项退出动画 owner。 | 实现者可分别选初始形态、目标形态或同时播放两形态退出，均不直接违反旧文。 | `references/responsive-adaptive.md` | 关闭只使用关闭开始时当前渲染形态的专项退出动画。 | `repaired-static`：响应式「跨端形态与状态延续」第 3 条确定退出 owner；「验收与报告」要求关闭前/关闭中两次断点复放。 |
| F-04 | 基线响应式第 8 条只要求打开浮层转换保持单实例，没有 closing 期间断点输入的处置。 | `baseline-failing`：closing 时断点变化可启动转换、第二退出动画、重建或重复 cleanup。 | 一种实现冻结 closing 形态，另一种继续响应断点并重新解析；副作用与动画计数不同。 | `references/responsive-adaptive.md` | closing 后冻结渲染形态，保持保护到唯一卸载/清理，忽略后续形态转换。 | `repaired-static`：响应式第 8 条禁止 closing 后转换、第二动画、重建或额外清理；集中验收观察一次动画、卸载和清理。 |
| F-05 | 基线 Select「确定性搜索位置决策」只要求业务状态和 ID 保持；各 mode 只写各自打开焦点，没有完整转换焦点表。 | `baseline-failing`：`inline`、`panel`、`drawer`、`none` 互转时目标焦点及存活节点处理不唯一。 | 实现者可保留即将移除节点的焦点、回到外层 trigger，或进入目标内层控制器；都能声称“保持焦点”。 | `references/selects-comboboxes.md` | 以目标 placement 定义唯一等价控制器；存活节点保持，否则只移动一次且不提交状态。 | `repaired-static`：Select「`resolvedPlacement` 转换的焦点、ID 与 ARIA」给出四目标映射；集中验收第 1–4 项记录状态、焦点和 ARIA。 |
| F-06 | 基线 Select 第 27 条只说模式转换中 ID 稳定，没有规定焦点接管时目标控制器的 ARIA 提交边界。 | `baseline-failing`：焦点可能短暂指向已移除 Listbox/option，或带着来源角色的 ARIA 进入目标。 | 一种实现先移动焦点后补 ARIA，另一种在同一提交更新；辅助技术可观察结果不同。 | `references/selects-comboboxes.md` | 延续逻辑 ID，在焦点移动前或同一 committed render 更新目标 ARIA并移除来源专属属性。 | `repaired-static`：Select 同一转换章节和集中验收第 2–4 项只支持焦点/ID/ARIA 结论；动画与模态基础设施计数分别由响应式单实例规则、Select「Drawer 模态基础设施转换」和 Drawer 生命周期支持。 |
| F-07 | 基线四份「完成前检查/验收与报告」没有命名复放 closing-time conversion 与完整 Select focus mapping。 | `baseline-failing`：规则即使局部存在，也没有可重复执行的跨文档验收把它们收束起来。 | 一位验证者可能只测打开态断点，另一位只测单个 Select 方向；二者都可报告“验证了响应式”。 | 本账本；验收步骤由各 owner 持有 | 增加 closing 前/后断点复放、四 placement 焦点/ARIA 复放及双向 Drawer 基础设施计数。 | `repaired-static`：响应式「验收与报告」明确 closing-time conversion；Select「验收与报告」第 1–7 项明确 focus mapping、ARIA、双向模态基础设施与 disposal。运行时仍为 `unperformed-runtime`。 |

七项 finding 都要求最小 owner 修订，因此没有 `no-change` finding；`no-change` 仅适用于上面的路由/摘要文件与下方矩阵中明确不属于某类别的形态细节。

## 11 维 × 4 参考规范交叉矩阵

缩写：D = `references/dialogs.md`，Dr = `references/drawers.md`，S = `references/selects-comboboxes.md`，R = `references/responsive-adaptive.md`。每个单元格引用现有规则；`no-change` 表示该维度的专项细节由另一个明确 owner 持有，而不是遗漏。

| 维度 | Dialog（D） | Drawer（Dr） | Select / Combobox（S） | 响应式（R） |
| --- | --- | --- | --- | --- |
| 生命周期 | D「动画」4–7、「异步、错误与重复操作」20–23、「响应式与清理」27–28：打开、失败、普通关闭、disposal、重开。 | Dr「动画与减少动态效果」11–13、「异步状态、错误与清理」20–22：打开、失败、普通关闭、disposal、重开。 | S「状态、不变量与会话」、「模式与精确语义」、Drawer 转换后的 disposal 段：会话、提交、失败、关闭、卸载。 | R「跨端形态与状态延续」2–3、8–9：初开、转换、closing、disposal。 |
| 关闭路径 | D「遮罩与滚动」1、「焦点与键盘」10–11、「语义与背景隔离」15–16：遮罩不关、内部动作/Escape、普通关闭顺序。 | Dr「模态边界、遮罩与关闭」2–5、「焦点、键盘…」15–16：遮罩/手势不关、内部动作/Escape、普通关闭顺序。 | S 各 placement 段与「键盘、关闭、错误与元素状态」：Escape、Tab、外部/Drawer 关闭的提交边界；Drawer 转换明确不是关闭。 | R 第 3、8–9 条：转换后的 close owner、closing 冻结与 disposal 例外；专项按钮/手势 `no-change`，由 D/Dr/S 持有。 |
| 焦点与键盘 | D「焦点与键盘」8–11、「多层 Dialog」17–18。 | Dr「焦点、键盘、语义与背景隔离」14–19。 | S「`resolvedPlacement` 转换的焦点、ID 与 ARIA」、各 placement 键盘语义与集中验收 1–4。 | R 第 8–9 条：存活节点/等价控制器、旧 trigger 例外和新路由焦点策略；placement 目标 `no-change`，由 S 持有。 |
| 模态边界 | D「语义与背景隔离」12–19：遮罩、隔离、锁、最上层。 | Dr「模态边界、遮罩与关闭」1–5、「焦点、键盘…」17–19。 | S「Drawer 模态基础设施转换」与 `drawer` mode：进入取得、离开释放；非模态 PC popup 见「布局、性能与动画」。 | R 第 3、8–9 条：转换/closing/disposal 中单实例保护所有权；形态专项几何 `no-change`，由 D/Dr 持有。 |
| 布局与滚动 | D「遮罩与滚动」2–3、「响应式与清理」24–26。 | Dr「布局、滚动和四个方向」6–10。 | S 各 mode 固定搜索/选项滚动与「布局、性能与动画」。 | R「布局、视口与输入」1–5：缩放、虚拟键盘、安全区域、主滚动。 |
| 动画 | D「动画」4–7；关闭顺序见第 10 条。 | Dr「动画与减少动态效果」11–13；关闭顺序见第 16 条。 | S「布局、性能与动画」定义非模态 popup；Drawer 转换动画 owner 引用 R/Dr。 | R 第 2–3、8 条与「验收与报告」：初开、实时转换、later close、closing 断点。 |
| 业务状态 | D「异步、错误与重复操作」20–23：提交、loading、失败、不可中断。 | Dr「异步状态、错误与清理」20–22。 | S「状态、不变量与会话」、「选择、ARIA option 与 active 对账」、「键盘、关闭、错误与元素状态」：committed/draft/orphaned/request。 | R「核心原则」1、3 与第 7–9 条：跨端语义、未提交状态和异步工作连续性。 |
| 跨端转换 | D 开头 owner 边界链接 R；形态专项动画仍由 D「动画」持有。 | Dr 开头 owner 边界链接 R；方向/几何仍由 Dr 7–13 持有。 | S「确定性搜索位置决策」、转换焦点/ARIA、Drawer 模态基础设施转换。 | R「跨端形态与状态延续」1–9：跨形态单实例、状态、动画和 disposal 的 owner。 |
| 无障碍 | D「焦点与键盘」8–11、「语义与背景隔离」12–16。 | Dr「焦点、键盘、语义与背景隔离」14–19。 | S 各 placement 角色、ARIA、Listbox/option/active 对账及状态播报。 | R「核心原则」1–4、「布局、视口与输入」2–5、「内容与国际化」1–2。 |
| 清理与恢复 | D「响应式与清理」27–28：实例资源、disposal、重开旧回调；第 10 条焦点恢复。 | Dr「异步状态、错误与清理」22；第 16 条焦点恢复。 | S Drawer 转换后的 disposal 段：请求/回调/popup/ARIA；转换章节清理 Drawer 专属设施。 | R 第 8–9 条：closing 唯一 cleanup 与 route/unmount 共享 disposal、新路由焦点。 |
| 验收与报告 | D「完成前检查」：遮罩、滚动、关闭顺序/计数、栈、disposal、旧回调重开。 | Dr「完成前检查」：四方向、关闭顺序/计数、栈、disposal、旧回调。 | S「验收与报告」1–7：状态、焦点、ARIA、双向基础设施和 disposal。 | R「验收与报告」：视口、closing-time conversion、route/unmount disposal 和未验证声明。 |

## 静态场景重放（S-01 至 S-07）

每行按批准设计的五个断言重放；`determined-static` 表示规则文本给出唯一结果，不表示浏览器已执行。

| 场景 | 业务状态 | 单一活动实例/基础设施 | 关闭边界 | 焦点、背景与滚动连续性 | 动画、卸载与一次清理 |
| --- | --- | --- | --- | --- | --- |
| S-01：打开 Dialog 在宽屏与 Drawer 间往返 | `determined-static`：R 第 1、3、7 条保持业务语义与未提交状态。 | `determined-static`：R 第 8 条只保留一个实例和一套副作用。 | `determined-static`：R 第 3、8 条使用 closing 开始时形态并冻结。 | `determined-static`：R 第 3、8 条持续保护；D 第 12 条、Dr 第 18 条定义形态内保护。 | `determined-static`：R 第 8 条只允许一个退出、卸载和 cleanup。 |
| S-02：Select PC popup 转 Drawer，含 query、active、loading/error | `determined-static`：S「状态、不变量与会话」及转换焦点章节不提交值或草稿。 | `determined-static`：R 第 8 条保持单实例；S「Drawer 模态基础设施转换」要求取得计数各 1，Dr 第 18 条定义最终保护。 | `determined-static`：转换本身不是关闭；之后普通关闭采用 Dr 第 11–12、16 条。 | `determined-static`：F-06 只由 S 转换章节/验收 2–4 支持焦点、ID、ARIA；背景连续性由 S Drawer 转换和 Dr 第 18 条支持。 | `determined-static`：动画/基础设施清理由 R 第 3、8 条、Dr 第 11–12、22 条及 S 验收 5–6 支持，不以 F-06 作为证据。 |
| S-03：多层 Dialog/Drawer 混合逐层关闭 | `determined-static`：D 20–23、Dr 20–21 保持最上层失败/工作状态。 | `determined-static`：D 17–19、Dr 19 只让最上层交互。 | `determined-static`：D 第 10 条、Dr 第 16 条给出相同普通关闭顺序。 | `determined-static`：焦点恰好一次回到存活下层 trigger；页面/下层保护持续。 | `determined-static`：D 27、Dr 22 每实例只释放自己资源一次。 |
| S-04：异步提交时 Escape、内部关闭、断点、路由或卸载 | `determined-static`：D 20–23、Dr 20–21 保持业务状态；R 第 9 条拒绝 disposal 后新工作。 | `determined-static`：R 第 8 条限制转换/closing 单实例，第 9 条限制每实例资源 owner。 | `determined-static`：普通关闭走 D 10/Dr 16；route/unmount 立即进入 R 第 9 条 disposal。 | `determined-static`：disposal 不回旧 trigger；新路由提交后由其焦点策略移动一次。 | `determined-static`：旧请求、重试/防抖、动画完成处理器、监听器和过期回调被取消/失效；每项自有资源只释放一次。 |
| S-05：虚拟键盘、低高度、200% 缩放、安全区域与 reduced motion | `determined-static`：R「核心原则」1–3 保持语义。 | `determined-static`：R 第 8 条在约束触发转换时仍为单实例。 | `determined-static`：D 4–7、Dr 11–13 与 R 验收定义专项关闭/reduced motion。 | `determined-static`：D 24–26、Dr 6/9–10、R「布局、视口与输入」保持可达。 | `determined-static`：R 第 3、8 条禁止叠加动画并要求一次卸载/清理。 |
| S-06：orphaned invalid、远程竞态与进入/离开 `none` | `determined-static`：S 状态/active 对账保留 invalid 和 query 提交边界。 | `determined-static`：S 决策规则与 R 第 8 条禁止重复请求/回调/设施。 | `determined-static`：S `none` 与键盘章节定义 Escape/Tab 非提交关闭。 | `determined-static`：S 转换章节将焦点映射到 Select-only Combobox 并保证有效 active 引用。 | `determined-static`：S 验收 1–4 检查稳定 ID/ARIA 和无重复请求/值回调。 |
| S-07：关闭动画期间重复关闭、重开或形态变化 | `determined-static`：D 第 6 条、Dr 第 12 条拒绝重复；R 第 8 条保持异步状态。 | `determined-static`：R 第 8 条冻结 closing 并禁止重建/额外设施。 | `determined-static`：R 第 3、8 条锁定退出 owner；D 10/Dr 16 锁定完成顺序。 | `determined-static`：保护持续至 DOM 移除；D 重开验收显式让旧延迟清理在新实例激活后到达并确认不能破坏新实例。 | `determined-static`：R closing-time 验收验证一次退出/卸载/清理；S focus mapping 验收 1–4 继续覆盖 Select 转换，合并满足 F-07。 |

## 验证记录

| 验证类别 | 结果 | 命令与证据边界 |
| --- | --- | --- |
| focused RED | `observed-red` | 修复前 9 个集中断言均输出 `EXPECTED-FAIL`，汇总 `focused-red failures=9 expected=9`，命令退出 1。 |
| focused GREEN | `passed-static` | 同一 9 个集中断言全部输出 `PASS`，汇总 `focused-green failures=0 expected=0`，命令退出 0。 |
| Markdown 相对链接 | `passed-static` | 实施计划中的仓库本地 Ruby 检查退出 0、无输出。 |
| 官方 Skill 验证 | `passed-static` | `/tmp/frontend-standards-validation-venv/bin/python /Users/evanqi/.codex/skills/.system/skill-creator/scripts/quick_validate.py .` 退出 0，输出 `Skill is valid!`。 |
| 占位符与 diff 检查 | `passed-static` | 指定 placeholder scan 输出 `placeholder scan: no matches` 并退出 0；`git diff --check` 退出 0、无输出。 |
| Base→Head 完整差异审查 | `passed-static` | 以修复后新 HEAD 执行 `git diff 3ce6579e137fc84aa497df90447f133164fa247e..HEAD -- SKILL.md README.md references docs/audits`；完整范围只含本账本和四份 owner reference，所有规范变化映射到 F-01–F-07，没有新类别、没有 `SKILL.md`/`README.md` 变化，也没有运行时通过声明。不再以 `HEAD~3` 冒充完整范围。 |
| 浏览器、屏幕阅读器、触摸设备与真实视口 | `unperformed-runtime` | **未验证。** 仍需在具体组件中实际点击/拖拽、切换断点与缩放、打开虚拟键盘、检查 DOM/ARIA、记录焦点与请求，并以读屏和触摸设备复测。 |

## 最终边界

本轮完成的是规范文本、交叉引用和静态推演。不得把 `passed-static`、`repaired-static` 或 `determined-static` 写成浏览器、屏幕阅读器、触摸设备或真实视口已经通过；这些运行时检查保持 `unperformed-runtime`，直到具备具体实现和目标环境。
