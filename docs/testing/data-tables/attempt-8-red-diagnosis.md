# Attempt 8 前置 RED：原子输出槽位缺失

状态：`RED_REPRODUCED`

本文件只保存 owner 修复前的失败证据；Attempt 7 的 RAW PROMPT / RAW OUTPUT、字段账本、mutation 与 SHA-256 均保持不变。

## 既有 19 项应用缺口

```sh
DATA_TABLE_AUDIT_PREFIX=attempt-7 ruby docs/testing/data-tables/attempt-6-application-audit.rb
```

预期 exit `1`。结果稳定为 display `91/0`、row-action `76/0`、bulk-action `93/19`。bulk 的 19 项为：

- `operationState` 缺单行操作 absence contract：1；
- ARIA Grid 不适用行缺 request 零值：1；
- 筛选缺 draft/applied、默认重置、URL 安全、字段错误 owner、分页复位：5；
- 排序缺自然排序、ARIA、键盘、回分页起点：4；
- numbered 分页缺可靠总数/范围、直接页码、校验跳页、原生边界禁用、页大小、回第 1 页、单次失效页恢复、输入语义：8。

## 固定槽位 RED

```sh
ruby docs/testing/data-tables/attempt-8-output-slot-audit.rb
```

owner 修复前的原始结果为 exit `1`：

```text
A40 FAIL scenarios=3 records=0 errors=9
  display: FAIL records=0 errors=3
    checklist: exact fixed header missing
    operation slots: exact fixed header missing
    family slots: exact fixed header missing
  row-action: FAIL records=0 errors=3
    checklist: exact fixed header missing
    operation slots: exact fixed header missing
    family slots: exact fixed header missing
  bulk-action: FAIL records=0 errors=3
    checklist: exact fixed header missing
    operation slots: exact fixed header missing
    family slots: exact fixed header missing
```

## 根因

`DT-REPORT-03` 至 `DT-REPORT-05` 虽枚举了义务并要求定位，但仍允许把清单证据写成章节引用或自由文本。它们没有固定：

1. 二十个原子规则族的 DOM/state/handler/request 独立列；
2. `operationState` 中 row/bulk 两个不可互相替代的子槽；
3. 筛选、排序和所选分页模式的逐 `obligationKey` 行。

因此清单行可以声称“已定义”，而正文实际遗漏 19 项。修复必须改变 owner 的正向输出契约，并由独立 A40 与 mutation 检查槽位缺失、合并、粗粒度引用和零值缺列；只增加提醒或继续依赖全文关键词扫描不能关闭该 RED。

## 最终轮补充诊断

Attempt 8 的 A40 固定槽关闭了上述 19 项结构缺口，但 bulk 的选择代次契约产生新的关系级残余：异步选择协调回调把 generation 递增写在“接受结果后”，而不是“接受选择意图时”。这不是 Markdown 形态或措辞差异；它改变旧回调被拒绝的时间窗口。修正后的 report-contract 审计以 1 个基线错误稳定拒绝该 RAW 输出，最终轮按熔断规则停止。
