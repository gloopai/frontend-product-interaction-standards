# Attempt 7 严格应用审计

状态：`BLOCKED_APPLICATION_FAIL`

Attempt 7 使用三个新的 `fork_turns=none` 代理和与 Attempts 1–6 字节相同的用户式 prompt。display 与 row-action 通过；bulk-action 虽已正确应用本轮新增的 DT-SEL-06 语义契约，仍遗漏其他既有 A37–A39 硬门禁。因此全套不得进入 GREEN，依修复轮指令停止，不创建 Attempt 8，也不改写任何 Attempt 7 RAW OUTPUT。

## 机器审计结论

复跑命令：

```sh
DATA_TABLE_AUDIT_PREFIX=attempt-7 ruby docs/testing/data-tables/attempt-6-application-audit.rb
```

结果为 exit `1`、`BASELINE FAIL errors=19`：

| 场景 | 字段/语义记录 | 错误数 | 裁决 |
| --- | ---: | ---: | --- |
| display | 91 | 0 | PASS |
| row-action | 76 | 0 | PASS |
| bulk-action | 93 | 19 | FAIL |
| 合计 | 260 | 19 | BLOCKED |

完整账本及每个缺口的 `outputLocation` / 空位置见 [attempt-7-field-audit.md](attempt-7-field-audit.md)。审计按清单表头名称解析列，不再假定“验证状态”固定在最后一列，也不再把数字章节引用本身当成语义完成。

## DT-SEL-06 专项裁决：PASS

bulk 的唯一三行语义表位于 RAW OUTPUT L247–L249；字段级审计保存了每行五列的原值。

| 路径 | 严格语义结果 |
| --- | --- |
| 资格变化 | `selectionGeneration +1`；创建新的不可变后继 `selectionSnapshot`；旧快照写入为 0。 |
| 异步选择协调回调 | `live + ownerId + lifecycleToken + selectionGeneration` 四项全匹配才提交；失配只记录 `selection-result-discarded`，选择写入为 0。 |
| 操作结果调整当前选择 | 写选择前比较捕获代次与当前 `selectionGeneration`；不匹配只写 operation result owner，选择写入为 0。 |

M20–M22 分别保留同类字段名但反转 `+1` 状态转换、删除 `lifecycleToken` 门禁、允许代次不匹配后写选择；三者都产生独立新增语义错误。由此证明本轮 DT-SEL-06 不是靠关键词或验收编号计数判定。

## bulk 的 19 个阻断缺口

| 契约 | 缺口 | 数量 |
| --- | --- | ---: |
| `DT-REPORT-04.c` / A39 | `operationState` 未声明已关闭单行操作的未实例化/absence contract。 | 1 |
| `DT-REPORT-05.c` / A37 | ARIA Grid“不适用”行缺 request 零值证据。 | 1 |
| `DT-REPORT-03.b` / A38 筛选 | 缺 draft/applied 分离、`defaultFilters` 重置、URL/敏感值边界、字段错误 owner、筛选后回第 1 页；显式应用模式与已应用条件可见/可移除已有证据。 | 5 |
| `DT-REPORT-03.c` / A38 排序 | 缺自然排序策略、交互排序 ARIA、交互排序键盘语义、提交排序后回分页起点；实际键/方向、NULL、大小写、locale、唯一稳定键、DOM 和焦点已有证据。 | 4 |
| `DT-REPORT-03.d` / A38 numbered 分页 | 缺可靠总数/结果范围、直接页码、校验跳页、原生边界禁用、页大小控件、筛选/排序/页大小复位、单次失效页恢复及分页输入语义；翻页后单次焦点已有证据。 | 8 |
| 合计 | 任一项都不能由同族摘要或清单中的“已定义”文字抵消。 | 19 |

## Mutation 与历史纠正

- [attempt-7-mutation-receipt.md](attempt-7-mutation-receipt.md) 保存相对失败基线计算的新错误集合：M01–M22 全部 `EXPECTED_FAIL`，unexpected pass=`0`。命令仍 exit `1`，因为 mutation 通过不能抵消 Attempt 7 基线失败。
- [attempt-6-selection-generation-red-mutation.md](attempt-6-selection-generation-red-mutation.md) 保存先写出的 RED：旧审计对保留 DT-SEL-06 词汇但反转关系的 M20 给出 `UNEXPECTED_PASS`。
- Attempt 6 的三份 RAW 输出、旧字段账本和旧 mutation 回执保持原样；旧 `PASS_WITH_RUNTIME_UNVERIFIED` 裁决已作废。修正审计要求唯一三行选择代次语义表，Attempt 6 缺表并以 exit `1` 失败。

## 最终结论

派发、completion envelope、RAW 标记和 SHA-256 完整性通过；应用完整性失败。按“Attempt 7 失败即停止”的边界，本轮结论为 `BLOCKED_APPLICATION_FAIL`，不允许自循环修 owner 后再次派发。

真实浏览器、屏幕阅读器、键盘/触摸、200% 缩放、真实组件竞态、后端分页/幂等/裁决与逐资源 disposal 仍未执行，继续标记为未验证；这些运行时 concern 与本次静态硬门禁失败相互独立。
