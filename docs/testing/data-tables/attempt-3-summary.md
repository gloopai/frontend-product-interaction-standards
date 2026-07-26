# 数据表格规范 Attempt 3 失败汇总

状态：`FAILED/INCOMPLETE`

Attempt 3 的 display 与 row-action 全部适用维度通过；bulk 已把查询、筛选、排序、分页和数据状态拆成独立行，并继续正确把初始空 `excludedIds` 放在 `selectionSnapshot` 内，以不可变后继表达排除项变化。但 bulk 仍有两个硬规则缺口，整体不能标为 GREEN。

| 核对项 | display | row-action | bulk-action | 判断 |
| --- | --- | --- | --- | --- |
| 能力/状态/查询/数据状态 | 通过 | 通过 | 通过 | 三者声明 resolved tier、唯一分页和提交门禁。 |
| 筛选 | 通过 | 合理不适用 | 通过 | bulk 已覆盖 apply mode、默认重置、摘要、URL 安全与选择失效。 |
| 排序 | 通过 | 通过 | **失败** | bulk 只说空值、大小写、自然排序与 locale“必须配置”，未声明本实例当前采用的实际值；待配置占位不能满足稳定比较契约。 |
| 分页 | 通过 | 通过 | **失败** | bulk 的 numbered 设计缺少直接页码、具标签且校验的跳页，以及显示当前值/名称的页大小控件。 |
| selectionSnapshot.excludedIds | 合理不适用 | 合理不适用 | 通过 | 初始空字段嵌套于快照，排除变化建立后继，旧快照不变，普通翻页保持身份。操作快照中的不可变投影不构成可漂移选择 sibling。 |
| 操作/语义/焦点/响应式/ARIA | 合理不适用 | 通过 | 通过 | 所有适用项有正文位置。 |
| disposal/实例隔离/未验证 | 通过 | 通过 | 通过 | 正向契约完整，运行时仍未验证。 |

场景结论：display `PASS`，row-action `PASS`，bulk `FAIL`；整体 `FAILED/INCOMPLETE`。局部响应式/阶段枚举只按行为冲突判断，没有因枚举未封闭而失败。

owner 随后强化 `DT-REPORT-03.c/d` 与 `A38`：实际稳定比较值不得用“后续配置”占位；numbered/cursor 分页按模式列出完整、互斥的可观察完成条件。Attempt 3 证据保持不变。
