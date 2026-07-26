# Attempt 8 mutation 回执

状态：`MUTATIONS_PASS_BASELINE_BLOCKED`

## 固定槽 M23–M44、A40-M45–M47

```sh
DATA_TABLE_AUDIT_PREFIX=attempt-8 ruby docs/testing/data-tables/attempt-8-output-slot-audit.rb --mutations
```

基线：`A40 PASS scenarios=3 records=144 errors=0`。

| mutation | 单缺口 | 结果 |
| --- | --- | --- |
| M23 | 删除 row operation 子槽 | `EXPECTED_FAIL` |
| M24 | 删除 ARIA Grid request 独立零值 | `EXPECTED_FAIL` |
| M25–M29 | 分别删除 Attempt 7 缺失的五个筛选义务槽 | `5/5 EXPECTED_FAIL` |
| M30–M33 | 分别删除 Attempt 7 缺失的四个排序义务槽 | `4/4 EXPECTED_FAIL` |
| M34–M41 | 分别删除 Attempt 7 缺失的八个 numbered 分页义务槽 | `8/8 EXPECTED_FAIL` |
| M42 | 把具体当前值改成仅“见第 3 节” | `EXPECTED_FAIL` |
| M43 | 交换固定清单表头字段 | `EXPECTED_FAIL` |
| M44 | 四类零值删除 request | `EXPECTED_FAIL` |
| A40-M45 | 删除一个清单行 | `EXPECTED_FAIL`，命中 19/20 与缺行 |
| A40-M46 | 重复一个清单行 | `EXPECTED_FAIL`，命中 21/20 与重复行 |
| A40-M47 | 用 bulk 替换关闭的 row 操作子槽 | `EXPECTED_FAIL`，命中 row 缺失与 bulk 重复 |

终行：`MUTATION AUDIT PASS expected_failures=25/25`；exit 0，unexpected pass=`0`。

## 报告契约 M45–M50

```sh
DATA_TABLE_AUDIT_PREFIX=attempt-8 ruby docs/testing/data-tables/attempt-8-report-contract-audit.rb --mutations
```

基线：`REPORT-CONTRACT FAIL scenarios=3 records=135 errors=1`。唯一基线错误是 bulk 把 `selectionGeneration` 递增推迟到异步结果接受后；这是终态阻断项。

| mutation | 单缺口 | 结果 |
| --- | --- | --- |
| M45 | 删除 labelled `capabilityTier` 当前值 | `EXPECTED_FAIL` |
| M46 | 删除 row 的 `queryState` 固定组 | `EXPECTED_FAIL` |
| M47 | 从 display `queryState` 删除 `snapshotId` 最少字段 | `EXPECTED_FAIL` |
| M48 | 从 display lifecycle guard 删除 `ownerId` | `EXPECTED_FAIL` |
| M49 | 从 bulk 异步选择协调门禁删除 `lifecycleToken` | `EXPECTED_FAIL` |
| M50 | 改成捕获代次失配后仍写选择 | `EXPECTED_FAIL`，并命中相反语义 |

六个 mutation 都在失败基线之上产生独立新增错误，终行仍为 `MUTATION AUDIT PASS expected_failures=6/6`；命令最终 exit 1，因为 mutation 抗性不能抵消基线错误。

总计 31 个单缺口 mutation 全部被独立拒绝；A40 基线为 0 errors，但 report-contract 基线有 1 个真实语义错误，所以全套仍为 `BLOCKED_APPLICATION_FAIL`。
