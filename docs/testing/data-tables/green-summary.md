# Attempt 6 数据表格规范汇总（已作废）

状态：`RECLASSIFIED_FAIL`

> Fix Round 4 纠正：本文件以下原始 GREEN 判断建立在旧审计器上。旧审计器只验证字段、标题、清单与粗粒度位置，未验证 DT-SEL-06 的资格变化代次/快照、四项协调门禁及操作结果写选择前的捕获代次关系。保留的 Attempt 6 RAW OUTPUT 缺少修正契约要求的唯一三行选择代次语义表；修正审计 exit `1`，因此 Attempt 6 只能作为失败历史。以下旧计数与结论均为当时记录，不再代表当前裁决；RED 与后续裁决分别见 [attempt-6-selection-generation-red-mutation.md](attempt-6-selection-generation-red-mutation.md) 和 [attempt-7-summary.md](attempt-7-summary.md)。

三份最终样本来自原子二值完成契约修复后的全新 `fork_turns=none` 代理。门禁采用全有或全无：任一当前能力值、固定状态组、最少字段、独立 lifecycle guard、原子清单行、二值适用性、独立验证状态或适用正文位置缺失，整个场景失败；其他段落不能抵消。

## Tracked 字段级审计

每个场景保存 64 条记录，合计 192 条；每条都有真实 RAW `outputLocation`：

| 记录类别 | 每场景记录数 | 保存字段 |
| --- | ---: | --- |
| 当前能力值 | 14 | `capabilityKey/currentValue/outputLocation` |
| 固定状态组 | 4 | `stateGroup/outputLocation` |
| 状态最少字段 | 22 | `stateGroup/minimumField/outputLocation` |
| 独立生命周期 guard | 4 | `lifecycleRole/minimumField/outputLocation` |
| 原子应用清单 | 20 | `checklistRow/applicability/verificationStatus/outputLocation` |
| 合计 | 64 | display、row-action、bulk-action 均完整 |

完整账本见 [attempt-6-field-audit.md](attempt-6-field-audit.md)。可复跑审计确认三份基线零错误；十九个删除、替换或合并 mutation 全部预期失败，完整诊断见 [attempt-6-mutation-receipt.md](attempt-6-mutation-receipt.md)。

## 原子二值清单

| 门禁 | 展示型 | 单行操作 | 批量操作 |
| --- | --- | --- | --- |
| 二十个指定原子行恰好各一次 | 通过 | 通过 | 通过 |
| 适用性单元格精确为“适用”或“不适用” | 通过 | 通过 | 通过 |
| 验证状态独立成列 | 通过 | 通过 | 通过 |
| 选择 / 单行操作 / 批量操作拆行 | 通过 | 通过 | 通过 |
| 基础列状态 / 可选列控制拆行 | 通过 | 通过 | 通过 |
| Table / ARIA Grid 拆行 | 通过 | 通过 | 通过 |
| disposal / 实例隔离拆行 | 通过 | 通过 | 通过 |
| 不适用行具有 DOM/state/handler/request 四类零值证据 | 通过 | 通过 | 通过 |
| “部分/条件/混合适用”命中数 | `0` | `0` | `0` |

## 规则族结论

| 规则族 / 可观察维度 | 展示型 | 单行操作 | 批量操作 | 判断 |
| --- | --- | --- | --- | --- |
| 能力与固定状态 | 通过 | 通过 | 通过 | 十四个能力字段有当前值；query/view/interaction/operation 四组及最少字段完整；lifecycle 为独立 guard。 |
| 查询、筛选、排序、分页、数据状态 | 通过 | 通过 | 通过 | 五族分别成行；适用项落实具体值、转换和恢复，row 筛选 N/A 有四类零入口证据；numbered/cursor 义务互斥完整。 |
| 选择 | 合理不适用 | 合理不适用 | 通过 | bulk 的 `selectionSnapshot.excludedIds` 内嵌初始空集合，排除变化创建不可变后继，同范围翻页保持快照身份。 |
| 单行操作 | 合理不适用 | 通过 | 合理不适用 | row 有菜单、快照、六项门禁、权限变化和恢复；display/bulk 均给出四类零入口证据。 |
| 批量操作 | 合理不适用 | 合理不适用 | 通过 | bulk 覆盖确认、完整身份裁决、unknown、五类终态、部分成功及仅重试可重试失败项。 |
| 基础列状态与可选列控制 | 通过 | 通过 | 通过 | 基础 viewState 始终适用；三场景可选列控制 N/A 且零入口，未再用“部分适用”。 |
| Table、ARIA Grid 与键盘 | 通过 | 通过 | 通过 | Table 与 Grid 分开判断；三者原生 Table 适用、Grid 合理 N/A，核心任务键盘路径完整。 |
| 焦点、响应式、ARIA 与公告 | 通过 | 通过 | 通过 | 稳定 ID、单次迁移、Table/Card 等价、错误单 owner 与公告去重完整。 |
| disposal 与实例隔离 | 通过 | 通过 | 通过 | 两族分开判断；同步幂等 disposal、逐资源释放、迟到零写入和 owner/token 命名空间完整。 |
| 运行时验证边界 | 适用、未验证 | 适用、未验证 | 适用、未验证 | 适用性精确为“适用”，未验证状态在独立列并定位实际环境。 |

## Mutation 结论

- A39 字段 mutation：能力行删除、当前值改为条件文字、固定组删除、六个 view 最少字段逐项删除、lifecycle 替代、运行时清单行删除，全部失败。
- A38 mutation：独立筛选行删除，失败。
- A37 原子二值 mutation：“部分适用”、三组操作合并、列族合并、Table/Grid 合并、disposal/实例隔离合并、把验证状态混入适用性，全部失败。
- 汇总：基线 `3/3 PASS`；mutation `19/19 EXPECTED_FAIL`；unexpected pass=`0`。

## 最终结论

- display、row-action、bulk-action 的所有适用字段和原子规则族均通过；不适用能力都有可观察的四类 absence contract。
- 适用未定位数、固定字段缺失/替代数、原子行缺失/重复/合并数、非二值适用性数及不适用禁止入口数均为 `0`。
- 原始 prompt SHA-256 与 Attempt 1–5 相同，证明测试输入未夹带诊断或期望答案；完整 envelope 与 output 哈希可按 [dispatch-receipts.md](dispatch-receipts.md) 复算。

本结论只证明 owner 的静态应用完整性和证据可复算性。真实浏览器、屏幕阅读器、键盘/触摸、200% 缩放、真实组件竞态、后端分页/幂等/裁决与逐资源 disposal 仍未执行，保持 `未验证`。
