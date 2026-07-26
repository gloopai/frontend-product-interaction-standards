# Attempt 5 数据表格规范最终 GREEN 汇总

状态：`PASS_WITH_RUNTIME_UNVERIFIED`

三份最终样本来自 owner 字段级完成契约修复后的全新 `fork_turns=none` 代理。门禁采用全有或全无：任一当前能力值、固定状态组、最少字段、独立 lifecycle guard、应用清单行或适用规则族正文位置缺失，整个场景失败；其他段落再完整也不能抵消。

## 固定字段审计

| 门禁 | 展示型 | 单行操作 | 批量操作 |
| --- | --- | --- | --- |
| `capabilityTier`、`resolvedTier` 与十二个当前能力值 | 通过 | 通过 | 通过 |
| 恰有固定语义的 `queryState` / `viewState` / `interactionState` / `operationState` | 通过 | 通过 | 通过 |
| `queryState` owner 最少字段 | 通过 | 通过 | 通过 |
| `viewState.visibleColumnIds/pinnedColumnIds/columnWidths/density`、当前行和摘要 | 通过 | 通过 | 通过 |
| `interactionState` 焦点字段与可选交互的结构/absence contract | 通过 | 通过 | 通过 |
| `operationState` 单行/批量结构或四类零入口 absence contract | 通过 | 通过 | 通过 |
| 四组之外的 `lifecycleGuard`：owner/token/live/disposed/resources | 通过 | 通过 | 通过 |
| 应用清单独立“运行时验证边界”行 | 通过 | 通过 | 通过 |
| 机器字段/规则族门禁 | `51/51` | `51/51` | `51/51` |

display 对操作组明确未实例化并证明无操作快照/幂等键/错误/请求；row 对选择和批量结构给出零 DOM、状态、handler、请求证据；bulk 对单行操作给出同样 absence contract。三者都没有把 lifecycle 作为第五状态组或用它替代固定四组。

## 独立规则族矩阵

| 规则族 / 可观察维度 | 展示型 | 单行操作 | 批量操作 | 证据与判断 |
| --- | --- | --- | --- | --- |
| 查询快照、代次、意图合并与迟到门禁 | 通过 | 通过 | 通过 | 三份正文都冻结不可变查询快照，校验 live/owner/token/generation/snapshot；取消不替代门禁。 |
| 筛选 | 通过 | 合理不适用 | 通过 | display/bulk 分别覆盖 draft/applied、apply mode、实际默认重置、回第 1 页、摘要/移除、URL 安全和字段错误 owner；row 证明无筛选 DOM、draft、handler、请求入口与 URL 序列化。 |
| 排序 | 通过 | 通过 | 通过 | 都给出当前业务键/方向、空值、大小写/locale/自然排序的实际值或字段 N/A 理由，以及唯一不可变稳定键；交互排序另含按钮、ARIA、回起点与选择转换。 |
| 分页 | 通过 | 通过 | 通过 | display/bulk 的 numbered 包含可靠总数、范围、直接页码、具标签校验跳页、原生边界禁用、页大小、回第 1 页和单次恢复；row 的 cursor 包含不透明双向游标、缺失方向禁用、四类禁止入口、回初始位置和单次恢复。 |
| 数据加载、刷新、过期、错误与空状态 | 通过 | 通过 | 通过 | 三者分别建模首次/刷新加载与错误、stale、真实空数据集；启用筛选的场景另分无匹配。 |
| 当前页三态与全部筛选结果 | 合理不适用 | 合理不适用 | 通过 | bulk 把初始空 `excludedIds` 放在 `selectionSnapshot` 内；增加/移除排除项创建不可变后继，同范围翻页保留快照身份，`interactionState` 无可漂移 sibling 排除状态。 |
| 操作快照、重复提交、完整裁决与恢复 | 合理不适用 | 通过 | 通过 | row/bulk 都有不可变操作快照、幂等、完整六项门禁、身份集合裁决、unknown 与恢复；bulk 另覆盖五类终态、部分成功及只重试可重试失败项。 |
| 原生 Table / ARIA Grid 与键盘 | 通过 | 通过 | 通过 | 三者使用原生 Table，不伪造 Grid，不接管二维按键，静态单元格不进 Tab。 |
| 列与长内容 | 通过 | 通过 | 通过 | 固定 viewState 列字段完整；禁用列控件时仍保留展示状态并证明控制 DOM/handler/请求为零。display 另定义长内容展开。 |
| 焦点 | 通过 | 通过 | 通过 | 使用稳定 record/column/control ID；目标存活不移动，目标消失一次迁移，失效恢复/后续刷新不二次抢焦点，不落 body/root/removed/另一实例。 |
| 响应式与极端视口 | 通过 | 通过 | 通过 | Table/Card 单 owner、单活动数据根、零额外请求；覆盖 200% 缩放、长文本、低高度、触摸、虚拟键盘和安全区域。 |
| ARIA、错误与公告 owner | 通过 | 通过 | 通过 | 名称/header 关联、busy/stale/三态、错误单 owner；只对已接受且需反馈事件公告，merged/discarded/disposed 静默。 |
| disposal 与多实例隔离 | 通过 | 通过 | 通过 | lifecycle guard 独立；同步幂等 disposal、逐资源释放、迟到零写入、新路由焦点、owner/token 命名空间及安全返回恢复完整。 |
| 应用清单与运行时边界 | 通过 | 通过 | 通过 | 五个查询相邻族分别成行，所有 owner 规则族有独立判断；运行时边界单独成行并定位实际未验证环境。 |

## 结论

- display、row-action、bulk-action 的所有适用字段和规则族均通过；不适用能力都有可观察的 absence contract。
- 适用未定位数：`0`；固定字段缺失/替代数：`0`；不适用但存在被禁止入口数：`0`。
- 原始 prompt 哈希与 Attempt 4 相同，证明测试输入未夹带诊断或期望答案；output 哈希及完整 envelope 可按 [dispatch-receipts.md](dispatch-receipts.md) 复算。

本结论只证明 owner 的静态应用完整性和证据可复算性。真实浏览器、屏幕阅读器、键盘/触摸、200% 缩放、真实组件竞态、后端分页/幂等/裁决与逐资源 disposal 仍未执行，保持 `未验证`。
