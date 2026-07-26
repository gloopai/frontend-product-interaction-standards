# Attempt 6 DT-SEL-06 RED mutation

状态：`RED_CONFIRMED`

目标缺口：证明旧审计器只检查能力字段、状态组和清单引用，不能判断资格变化、异步选择协调和操作结果写选择之间的代次语义。

## Mutation

`M20-break-selection-generation-contract` 把 bulk 的资格变化说明替换为一段保留下列词汇、但反转关系的实现：

- 原地修改当前 `selectionSnapshot`；
- `selectionGeneration +1` 只写入展示数字；
- `ownerId`、`lifecycleToken`、`selectionGeneration` 被记录但不参与门禁；
- 迟到结果仍可提交，`selection-result-discarded` 只作标签；
- 操作捕获代次不匹配时仍调整当前选择。

因此该 mutation 不能靠删除关键词或编号被识别；审计必须解析字段间语义。

## RED 命令与原始结果

```sh
ruby docs/testing/data-tables/attempt-6-application-audit.rb
```

在增强审计前执行，exit code 为 `1`，关键原始输出为：

```text
BASELINE PASS scenarios=3 records=192
  display: PASS records=64
  row-action: PASS records=64
  bulk-action: PASS records=64
MUTATION UNEXPECTED_PASS id=M20-break-selection-generation-contract scenario=bulk-action operator="preserve DT-SEL-06 vocabulary while inverting eligibility, callback and operation-result semantics"
MUTATION AUDIT FAIL unexpected_passes=M20-break-selection-generation-contract
```

M01–M19 在同次执行中仍全部为 `EXPECTED_FAIL`；M20 是唯一 unexpected pass。

## Attempt 6 重新审计

加入首轮 DT-SEL-06 语义契约后，未修改 Attempt 6 RAW OUTPUT，重新执行当时版本的同一脚本得到 exit code `1`：

```text
BASELINE FAIL errors=4
  selection contract: exact semantic header rows=0
  selection contract 资格变化: rows=0
  selection contract 异步选择协调回调: rows=0
  selection contract 操作结果调整当前选择: rows=0
```

结论：Attempt 6 的原始字段账本和旧 mutation 回执只保留为历史证据；其 GREEN 判定失败。

其后同一审计器又加入 A38 筛选、排序与分页的语义义务定位，所以当前版本可能报告更多既有缺口；这不改变上面按时间冻结的四条首轮 RED 输出，也不恢复 Attempt 6。
