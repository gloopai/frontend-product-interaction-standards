# 现有规范加固：失败基线与审计账本

**审计日期：** 2026-07-25  
**状态：** RED 基线；本账本记录规则缺口/歧义，不是实现验收通过声明。

## 范围与判定方法

本账本以 `docs/superpowers/specs/2026-07-25-existing-standards-hardening-design.md` 为已批准设计，并审阅 Dialog、Drawer、Select / Combobox 与响应式规范。`baseline-close.md`、`baseline-select.md` 与 `baseline-stack.md` 是三个未加载本 Skill 的新鲜代理 RED 输出；它们只作为交叉检查的简短佐证，不能替代本仓库规则的证据。

“`baseline-failing`”表示当前文字不能让两位合理实施者得出唯一且兼容的结果。后续修订须在 owner 文件中消除缺口，并把本账本的相关场景重放为静态规则推演；真实浏览器、读屏、触摸和视口验证仍需具体组件与环境。

## 发现账本

| ID | 状态 | 证据位置与短引 | 两种合理实现为何会分歧 | Owner | 最小预期修订 |
| --- | --- | --- | --- | --- | --- |
| F-01 | repaired-static | 已修订 `references/dialogs.md`「焦点与键盘」第 12 条：模态活动开始时当前活动实例取得页面滚动锁定，并与背景隔离同属该实例。 | 先前的打开锁取得方已不再开放解释；接受断言：Dialog acquires page scroll lock when modal activity begins. | `references/dialogs.md` | 已修订：当前打开实例取得并持续持有页面滚动锁。真实运行时滚动行为仍需具体组件验证。 |
| F-02 | repaired-static | 已修订 `references/dialogs.md`「动画」第 6 条及「响应式与清理」第 27 条：普通关闭的保护持续到关闭动画完成且 DOM 移除，随后统一清理；路由变化/卸载为立即、幂等例外。 | 关闭请求不再等同于清理时点；接受断言：Modal protections remain until close animation completion and DOM removal. | `references/dialogs.md` | 已修订：普通关闭只在动画完成和 DOM 移除后清理。真实运行时清理顺序仍需具体组件验证。 |
| F-03 | repaired-static | 已修订 `references/responsive-adaptive.md`「跨端形态与状态延续」第 2–3 条：初次打开采用最终形态的入场动画，随后关闭采用关闭开始时当前渲染形态的专项退出动画。 | 退出动画所有者已唯一；接受断言：Closing uses the currently rendered shape’s exit animation. | `references/responsive-adaptive.md` | 已修订：later close 以关闭开始时的已解析形态为准，不能叠加另一形态退出动画。真实动画仍需具体组件验证。 |
| F-04 | repaired-static | 已修订 `references/responsive-adaptive.md`「跨端形态与状态延续」第 8 条：关闭开始后冻结 closing 实例形态，后续断点不得转换、重建、启动第二动画或额外清理。 | closing-phase 的断点处置已唯一；接受断言：Once closing begins, the rendered shape is frozen and later breakpoint changes cannot start conversion. | `references/responsive-adaptive.md` | 已修订：closing 期间保持同一实例和副作用持有者，动画完成后仅一次清理。真实断点切换仍需具体组件验证。 |
| F-05 | baseline-failing | `references/selects-comboboxes.md`「状态模型与硬性不变量」的 `resolvedPlacement`，以及 placement `inline`、`panel`、`drawer` 段分别规定初始/关闭焦点；第 27 条要求保留业务状态。 | 外层 trigger、inline 主 Combobox、panel 内层 Combobox 与 Drawer 搜索 Combobox 都是合理焦点目标。实施者可保留旧焦点、移动至新输入或回到 trigger；现有规则未给转换时的确定映射。 | `references/selects-comboboxes.md` | 为每个 placement 对写出确定的焦点映射及失效回退，且不改变 `selectedValue`、`query`、`activeOption` 或请求会话。 |
| F-06 | baseline-failing | `references/selects-comboboxes.md` 第 27 条要求 Portal/转换中 ID “稳定”，第 35、39、41、45 条分别定义 `aria-controls`。 | 实现 A 先转移焦点后再替换 listbox/ARIA 所有权，短暂留下失效或重复 ID；实现 B 原子替换并立即更新同一逻辑 popup ID。两者都可能声称未“重复基础设施”，但辅助技术可见性不同。 | `references/selects-comboboxes.md` | 明确在焦点映射完成的同一可观察边界，逻辑 popup ID、`aria-controls` 和相关 ARIA 所有权必须唯一、存在且有效。 |
| F-07 | baseline-failing | `references/dialogs.md:63-71`「完成前检查」只列“打开/关闭动画、快速连续操作”；`references/drawers.md:46-54`只列“快速连续操作…关闭、路由变化、卸载”；`references/selects-comboboxes.md:75-77`只笼统列“焦点和动画后返回”与“断点”；`references/responsive-adaptive.md:36-40`只笼统列“断点切换期间的…打开浮层”。四者均未命名 closing-time conversion 或 placement focus mapping 的重放。 | 实现 A 只检查静态打开转换和正常关闭；实现 B 另行重放关闭中断点切换与四个焦点端点。两者都能完成现有清单，覆盖强度却不同。 | 本审计账本（跨文件）；四份参考文件各自完成前检查 | 把 S-02 的 placement 焦点/ARIA 映射及 S-07 的 closing-time conversion 纳入命名、可操作的跨文件完成前检查。 |

## 外部 RED 佐证摘要

- `baseline-close.md` 暴露了 closing 状态需固定动画所有者、把副作用持有到统一 finalize 的分歧；对应 F-02、F-03、F-04。
- `baseline-select.md` 暴露了展示层替换时等价搜索输入焦点、稳定 listbox ID 与无失效 ARIA 引用的分歧；对应 F-05、F-06。
- `baseline-stack.md` 暴露了覆盖层栈中滚动锁所有权、焦点连续性和路由卸载清理顺序的分歧；对应 F-01、F-02、F-07。

这些原始 RED 输出保持不修改；上表以仓库规则位置为主证据。

## 场景基线（S-01 至 S-07）

每项均按批准设计的五个核对维度记录。`underdetermined` 仅在其对应发现仍未修复时使用；其余项目为当前可从规则直接推得的下限。

### S-01：打开的 Dialog 在宽屏与 Drawer 间往返

| 断言 | 基线判定 | 规则或发现 |
| --- | --- | --- |
| 业务状态 | already-determined：提交、错误与工作语义连续。 | 响应式「跨端形态与状态延续」第 1、3 条 |
| 一个活动实例/基础设施集合 | already-determined：不得重复遮罩、请求、回调、焦点陷阱或滚动锁。 | 响应式第 8 条 |
| 关闭边界 | underdetermined：若随后的 close 与断点交叠，退出形态与处理未规定。 | F-03、F-04 |
| 焦点/背景连续性 | already-determined：保持同一实例、状态与焦点，并持续保护背景。 | 响应式第 3 条 |
| 动画/卸载/清理恰好一次 | underdetermined：转换后 close 的动画/cleanup 所有者未唯一。 | F-03、F-04、F-07 |

### S-02：可搜索 Select 从 PC 浮层转为 Drawer，带 query、active、loading 或 error

| 断言 | 基线判定 | 规则或发现 |
| --- | --- | --- |
| 业务状态 | already-determined：`selectedValue` 不隐式更新，转换保留草稿、搜索、错误和请求语义。 | Select 第 13、27 条；响应式第 4 条 |
| 一个活动实例/基础设施集合 | already-determined：不得重复请求、回调、遮罩、焦点陷阱、滚动锁或动画。 | Select 第 27 条 |
| 关闭边界 | already-determined：Drawer 关闭动画完成后才卸载并返回焦点。 | Drawer 第 11–12、16 条 |
| 焦点/背景连续性 | underdetermined：四个合理焦点端点间没有确定转换映射。 | F-05 |
| 动画/卸载/清理恰好一次 | underdetermined：转换后焦点边界与同一逻辑 popup 的 ARIA/ID 有效性未被原子化规定。 | F-06、F-07 |

### S-03：多层 Dialog、Drawer 或混合叠加，逐层关闭

| 断言 | 基线判定 | 规则或发现 |
| --- | --- | --- |
| 业务状态 | already-determined：只处理最上层，异步失败保持当前层打开。 | Dialog 第 17–23 条；Drawer 第 19–21 条 |
| 一个活动实例/基础设施集合 | already-determined：最上层唯一可交互，下层与页面隔离。 | Dialog 第 17–19 条；Drawer 第 19 条 |
| 关闭边界 | underdetermined：Dialog 的普通“关闭”清理可被理解为退出开始而非动画完成。 | F-02 |
| 焦点/背景连续性 | already-determined：最上层关闭后回到下层触发元素。 | Dialog 第 18 条；Drawer 第 19 条 |
| 动画/卸载/清理恰好一次 | underdetermined：Dialog 生命周期没有把关闭前保护与第 27 条清理显式收束为同一边界。 | F-02 |

### S-04：异步提交时触发 Escape、内部关闭、断点、路由变化或卸载

| 断言 | 基线判定 | 规则或发现 |
| --- | --- | --- |
| 业务状态 | already-determined：防重复、失败保持打开；不可中断时可禁用 Escape/关闭。 | Dialog 第 20–23 条；Drawer 第 15、20–21 条 |
| 一个活动实例/基础设施集合 | underdetermined：Dialog 未明确当前打开实例取得并持有滚动锁。 | F-01 |
| 关闭边界 | underdetermined：关闭请求与关闭动画完成的清理边界不唯一。 | F-02 |
| 焦点/背景连续性 | already-determined：关闭动画完成后才返回焦点；背景在 Dialog 打开时隔离。 | Dialog 第 10、12 条 |
| 动画/卸载/清理恰好一次 | underdetermined：路由/卸载例外与普通 Dialog 关闭的同一幂等 finalize 边界未明确。 | F-02、F-07 |

### S-05：虚拟键盘、低高度、200% 缩放、四向安全区域与 reduced motion

| 断言 | 基线判定 | 规则或发现 |
| --- | --- | --- |
| 业务状态 | already-determined：形态适配不得改变业务语义、提交结果或默认值。 | 响应式第 3 条 |
| 一个活动实例/基础设施集合 | already-determined：实时转换只保留一个活动实例。 | 响应式第 8 条 |
| 关闭边界 | already-determined：关闭动画完成后才卸载。 | Dialog 第 5 条；Drawer 第 11 条 |
| 焦点/背景连续性 | already-determined：焦点不被固定区或键盘完全遮挡，背景仍隔离。 | Dialog 第 24–25 条；Drawer 第 10、18 条 |
| 动画/卸载/清理恰好一次 | already-determined：reduced motion 的专项动画限制仍适用。 | Dialog 第 7 条；Drawer 第 13 条；响应式第 3 条 |

### S-06：已提交 option orphaned invalid、远程搜索竞态与会话进入/离开 `none`

| 断言 | 基线判定 | 规则或发现 |
| --- | --- | --- |
| 业务状态 | already-determined：搜索、active、结果刷新或模式切换不隐式更新 `selectedValue`。 | Select 第 13 条 |
| 一个活动实例/基础设施集合 | already-determined：模式转换不得重复请求、回调、遮罩、陷阱、滚动锁或动画。 | Select 第 27 条 |
| 关闭边界 | already-determined：`none` 的 Escape/Tab 关闭语义已列出。 | Select 第 53 条 |
| 焦点/背景连续性 | underdetermined：placement 变换后，旧/新 Combobox 与触发器的确定焦点映射缺失。 | F-05 |
| 动画/卸载/清理恰好一次 | underdetermined：焦点映射后同一逻辑 popup ID 与 `aria-controls` 的立即有效性未规定。 | F-06 |

### S-07：关闭动画未结束时重复关闭、重新打开或形态变化

| 断言 | 基线判定 | 规则或发现 |
| --- | --- | --- |
| 业务状态 | already-determined：动画期间阻止重复打开、关闭和回调。 | Dialog 第 6 条；Drawer 第 12 条 |
| 一个活动实例/基础设施集合 | underdetermined：closing 中断点变化是否转换形态或重建基础设施没有处置。 | F-04 |
| 关闭边界 | underdetermined：later close 由何种形态动画完成未定义。 | F-03 |
| 焦点/背景连续性 | underdetermined：Dialog 的滚动锁取得/持有未作规范性明确要求，且关闭清理时点有歧义。 | F-01、F-02 |
| 动画/卸载/清理恰好一次 | underdetermined：closing 断点变化未禁止重复动画或 cleanup，也未列为命名复放检查。 | F-04、F-07 |

## Task 2 静态规则重放

| 场景 | 静态重放结果与修订规则 | 运行时状态 |
| --- | --- | --- |
| S-01：打开的 Dialog 在宽屏与 Drawer 间往返 | repaired-static：`responsive-adaptive.md`「跨端形态与状态延续」第 3 条规定打开期间的单实例、无入/退场转换，并指定随后关闭使用关闭开始时的当前渲染形态；第 8 条规定 closing 后冻结形态并保持保护直到一次清理。 | 未验证；需要具体组件在宽窄断点间往返后关闭。 |
| S-03：多层 Dialog、Drawer 或混合叠加，逐层关闭 | repaired-static：`dialogs.md`「动画」第 6 条和「响应式与清理」第 27 条将顶层普通关闭的保护与清理统一到动画完成及 DOM 移除后；第 12 条规定活动实例持有滚动锁和背景隔离。 | 未验证；需要具体叠层、焦点返回和滚动锁计数验证。 |
| S-04：异步提交时触发 Escape、内部关闭、断点、路由变化或卸载 | repaired-static：`dialogs.md`第 6、12、27 条规定关闭期间保护、锁的取得和路由/卸载的立即幂等 teardown；`responsive-adaptive.md`第 8 条规定 closing 中保持异步状态且不得额外 cleanup。 | 未验证；需要具体异步请求、路由和卸载环境验证。 |
| S-07：关闭动画未结束时重复关闭、重新打开或形态变化 | repaired-static：`responsive-adaptive.md`第 3 条将退出动画归属到关闭开始时的当前形态，第 8 条冻结 closing 形态并禁止第二个退出动画、重建或额外清理；`dialogs.md`第 6、27 条保持保护至一次 finalize。 | 未验证；需要在关闭动画期间触发重复操作和断点变化。 |

## 后续验证状态

- 文档 RED 证据：已记录；F-01 至 F-04 已完成本任务的静态修订，F-05 至 F-07 仍为 baseline-failing。
- 静态重放：S-01、S-03、S-04、S-07 已按修订规则重放为 repaired-static；其余场景待对应任务复核。
- 真实交互验证：未验证；需要具体组件、浏览器、读屏、触摸设备与目标视口环境。
