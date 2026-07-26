# Attempt 8 字段级与固定槽审计

状态：`FAIL`

## 裁决审计

Attempt 8 由两个互补且可重放的审计器裁决：

| 审计 | 范围 | display | row-action | bulk-action | 合计 | 结果 |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| `attempt-8-report-contract-audit.rb` | 当前能力值、固定四状态组与最少字段、独立 lifecycle guard、bulk 三行选择代次语义 | 44 / 0 | 44 / 0 | 47 / 1 | 135 | FAIL |
| `attempt-8-output-slot-audit.rb` | 固定八列二十行清单、row/bulk 操作子槽、筛选/排序/当前分页模式逐项义务 | 49 | 46 | 49 | 144 | 0 errors |
| 合计 | A37–A40 当前静态应用门禁 | 93 / 0 | 90 / 0 | 96 / 1 | 279 | BLOCKED |

复跑命令：

```sh
DATA_TABLE_AUDIT_PREFIX=attempt-8 ruby docs/testing/data-tables/attempt-8-report-contract-audit.rb --records
DATA_TABLE_AUDIT_PREFIX=attempt-8 ruby docs/testing/data-tables/attempt-8-output-slot-audit.rb --records
```

两条命令均逐行输出 `currentValue` 或固定表原值及 RAW `outputLocation`，末尾分别为：

```text
REPORT-CONTRACT FAIL scenarios=3 records=135 errors=1
  display: PASS records=44 errors=0
  row-action: PASS records=44 errors=0
  bulk-action: FAIL records=47 errors=1
    selection contract 异步选择协调回调: generationEffect must increment when intent is accepted, before async result

A40 PASS scenarios=3 records=144 errors=0
  display: PASS records=49 errors=0
  row-action: PASS records=46 errors=0
  bulk-action: PASS records=49 errors=0
```

## Attempt 7 缺口回归

Attempt 7 bulk 的 19 项缺口均在固定槽中有唯一记录：关闭 row operation 的 `not-instantiated + 0/0/0/0` 子槽；ARIA Grid request 独立 `0`；筛选缺失五项；排序缺失四项；numbered 分页缺失八项。A40 不以全文关键词抵消槽位缺失，M23–M41 逐项删除这些槽位后均产生独立新增错误。

## Attempt 8 终态阻断

bulk RAW OUTPUT 的“异步选择协调回调”行把 `generationEffect` 写成“只有接受结果后按对应选择意图递增”。`DT-SEL-06` / A25 要求在选择意图被接受时令 `selectionGeneration` 恰好加一，再启动异步工作；否则旧回调在新意图已接受但新结果尚未返回的窗口仍可能匹配旧代次。门禁列与 mismatch 列正确不能抵消这一时序错误。RAW evidence 已冻结，最终第 5/5 轮不得改写或重派，因此结论为 `BLOCKED_APPLICATION_FAIL`。

## 历史脚本兼容性诊断

历史 [attempt-6-application-audit.rb](attempt-6-application-audit.rb) 保持未修改。直接令它读取 Attempt 8 会稳定返回 exit 1 / 43 errors，但这不是 owner 应用残余：

- 它在全文按首列文字搜索清单行；A40 新增的原子义务表再次以“筛选/排序/分页”为首列，因此被错误计为清单重复。
- 它要求能力值必须处于两列表格、固定状态组必须是三级标题；`DT-REPORT-04` 只要求逐项当前值和按固定名称逐组声明，允许 labelled list 与精确首列表格行。
- 它用固定措辞正则要求 `defaultFilters` 等实现变量名；A40 要求并已记录具体当前默认值与转换，不要求该变量名。

因此历史脚本仅作为 compatibility diagnostic 保存；Attempt 8 没有改写历史 corpus、脚本或旧回执。新的 report-contract 审计只放宽未写入 owner 的 Markdown 形态；修正后的关系检查明确拒绝上述 generationEffect，并由 M45–M50 继续验证其他六个单缺口。

## 审计边界

派发、证据完整性与 A40 固定槽通过，但不能抵消选择代次语义失败。浏览器、屏幕阅读器、键盘/触摸、200% 缩放、真实组件竞态、真实后端分页/幂等/裁决和逐资源 disposal 也均未执行。
