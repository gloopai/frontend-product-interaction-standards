# Attempt 5 RED 诊断

状态：`RED_REPRODUCED`

## 结论

Attempt 5 必须失败。三份原始 payload、派发事实和 SHA-256 保存在 `attempt-5-*.md` 与 `attempt-5-dispatch-receipts.md`；本诊断不修改 RAW PROMPT / RAW OUTPUT。

## RED 回执

执行二值适用性审计后退出码为 `1`：

```text
RED: binary applicability violated in 3 checklist rows
attempt-5-row-action-list.md RAW OUTPUT §11: | 选择与操作 | 部分适用 | ... |
attempt-5-row-action-list.md RAW OUTPUT §11: | 列 | 部分适用 | ... |
attempt-5-bulk-action-table.md RAW OUTPUT §10: | 列 | 部分适用 | ... |
```

复现命令按 RAW OUTPUT 标记提取三份 payload，逐行拒绝清单中 `部分适用`；任一命中使整批失败。修复后的审计还必须拒绝 `条件适用`、`适用/不适用`、一格多判定，以及把选择/单行操作/批量操作或基础列状态/可选列控制合并成一行。

## 根因

`DT-REPORT-02.b` 要求每个规则族标记“适用”或“不适用”，但没有列出必须拆分的原子清单行；`A37` 也没有以破坏副本明确拒绝“部分适用”和合并行。生成答复因此能以混合结论保留正文覆盖，却逃避每个子能力独立的二值门禁。

另一个证据缺口是 Attempt 5 只有 `51/51` 汇总，没有把 A38/A39 的每条 `capabilityKey/currentValue`、`stateGroup/minimumField`、`lifecycleRole`、`checklistRow` 与 `outputLocation` 保存为 tracked 记录，也没有保存逐项 mutation 的命令、失败诊断和回执。Attempt 6 必须把这些明细作为完成证据的一部分。
