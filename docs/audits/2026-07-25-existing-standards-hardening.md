# 现有规范加固：失败基线与审计账本

**审计日期：** 2026-07-25  
**状态：** RED 基线；本账本记录规则缺口/歧义，不是实现验收通过声明。

## 范围与判定方法

本账本以 `docs/superpowers/specs/2026-07-25-existing-standards-hardening-design.md` 为已批准设计，并审阅 Dialog、Drawer、Select / Combobox 与响应式规范。`baseline-close.md`、`baseline-select.md` 与 `baseline-stack.md` 是三个未加载本 Skill 的新鲜代理 RED 输出；它们只作为交叉检查的简短佐证，不能替代本仓库规则的证据。

“`baseline-failing`”表示当前文字不能让两位合理实施者得出唯一且兼容的结果。后续修订须在 owner 文件中消除缺口，并把本账本的相关场景重放为静态规则推演；真实浏览器、读屏、触摸和视口验证仍需具体组件与环境。

## 发现账本

| ID | 状态 | 证据位置与短引 | 两种合理实现为何会分歧 | Owner | 最小预期修订 |
| --- | --- | --- | --- | --- | --- |
| F-01 | baseline-failing | `references/dialogs.md`「响应式与清理」第 27 条仅写“完整清理滚动锁定”；「动画」第 6 条只在关闭前要求“保持…滚动锁定”。 | 实现 A 在打开时取得并持有本实例的锁；实现 B 只在关闭前避免释放一个假定已存在的锁，或把锁的取得委托给未定义的外层。两者都能逐字满足现有句子，却会使 modal-open 的背景滚动结果不同。 | `references/dialogs.md` | 在 Dialog 规范性生命周期规则中明确：当前打开实例取得并持续持有页面滚动锁；只在关闭动画完成、路由变化或卸载时释放。 |
| F-02 | baseline-failing | `references/dialogs.md`「响应式与清理」第 27 条的“关闭、路由变化或组件卸载时，完整清理”；对照「动画」第 5–6 条的“动画完成后”与“关闭结束前”。 | 实现 A 将“关闭”解释为关闭请求，立即释放保护；实现 B 将其解释为退出动画完成。前者会在仍可见的 Dialog 下恢复背景或焦点，后者不会。 | `references/dialogs.md` | 将普通关闭清理边界明确为“关闭动画完成后”；保留路由变化/组件卸载的立即、幂等例外。 |
| F-03 | baseline-failing | `references/responsive-adaptive.md`「跨端形态与状态延续」第 2–3 条规定初次打开和**已打开**实时转换的动画。 | 正在关闭的实例既不是初次打开，也不再是“已打开”。实现 A 按新断点换为新形态的退出动画；实现 B 保留启动关闭时的形态。两者均未被规则排除。 | `references/responsive-adaptive.md` | 指定 later close 的动画所有者（以关闭开始时的已解析形态为准），并说明不能叠加另一形态动画。 |
| F-04 | baseline-failing | `references/responsive-adaptive.md`「跨端形态与状态延续」第 3、8 条只约束“已打开实例”转换与单实例副作用。 | 若断点在 close 已开始后到达，实现 A 继续容器转换，可能附带第二个退出/cleanup；实现 B 冻结 closing 形态。现有文字没有 closing-phase 的处置，无法裁定。 | `references/responsive-adaptive.md` | 明确 `closing` 期间忽略/冻结形态转换：不改变动画所有者、实例、层级、副作用持有者或清理时点。 |
| F-05 | baseline-failing | `references/selects-comboboxes.md`「状态模型与硬性不变量」的 `resolvedPlacement`，以及 placement `inline`、`panel`、`drawer` 段分别规定初始/关闭焦点；第 27 条要求保留业务状态。 | 外层 trigger、inline 主 Combobox、panel 内层 Combobox 与 Drawer 搜索 Combobox 都是合理焦点目标。实施者可保留旧焦点、移动至新输入或回到 trigger；现有规则未给转换时的确定映射。 | `references/selects-comboboxes.md` | 为每个 placement 对写出确定的焦点映射及失效回退，且不改变 `selectedValue`、`query`、`activeOption` 或请求会话。 |
| F-06 | baseline-failing | `references/selects-comboboxes.md` 第 27 条要求 Portal/转换中 ID “稳定”，第 35、39、41、45 条分别定义 `aria-controls`。 | 实现 A 先转移焦点后再替换 listbox/ARIA 所有权，短暂留下失效或重复 ID；实现 B 原子替换并立即更新同一逻辑 popup ID。两者都可能声称未“重复基础设施”，但辅助技术可见性不同。 | `references/selects-comboboxes.md` | 明确在焦点映射完成的同一可观察边界，逻辑 popup ID、`aria-controls` 和相关 ARIA 所有权必须唯一、存在且有效。 |
| F-07 | baseline-failing | 四份文件的「完成前检查」/「验收与报告」覆盖一般动画、焦点与断点；没有把 closing-time conversion 与 placement focus mapping 列为命名的跨文件重放场景。 | 实现 A 只检查静态打开转换和正常关闭；实现 B 另行重放关闭中断点切换与四个焦点端点。两者都能完成现有清单，覆盖强度却不同。 | 本审计账本（跨文件）；四份参考文件各自完成前检查 | 把 S-02 的 placement 焦点/ARIA 映射及 S-07 的 closing-time conversion 纳入命名、可操作的跨文件完成前检查。 |

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

## 后续验证状态

- 文档 RED 证据：已记录；修订前不得将 F-01 至 F-07 标为通过。
- 静态重放：待后续任务在修订后按 S-01 至 S-07 逐项复核。
- 真实交互验证：未验证；需要具体组件、浏览器、读屏、触摸设备与目标视口环境。
