# 数据表格规范 Attempt 2 失败汇总

状态：`FAILED/INCOMPLETE`

Attempt 2 证明第一轮核心缺陷已被修正：bulk 的初始空 `excludedIds` 位于 `selectionSnapshot` 内部，增加/移除排除项创建不可变后继，同范围普通翻页保持快照身份；三份输出也都提供应用清单。但严格审计发现合并清单行仍能掩盖相邻规则族遗漏，因此不能标为 GREEN。

## 矩阵

| 核对项 | 展示型 | 单行操作 | 批量操作 | 判断 |
| --- | --- | --- | --- | --- |
| 能力与 resolved tier | 通过 | 通过 | 通过 | 三者均声明档位、权限解析和可选能力。 |
| 查询快照/竞态/数据状态 | 通过 | 通过 | 通过 | 均覆盖不可变快照、提交门禁、刷新失败旧数据和迟到丢弃。 |
| 筛选 | 通过 | 合理不适用 | **失败** | display 完整；row 证明无 DOM/事件入口；bulk 虽写 draft/applied 与选择清除，却遗漏 `applyMode`、`defaultFilters`、持续摘要/移除、URL 安全及字段错误 owner。 |
| 排序 | 通过 | 通过 | **失败** | display/row 有完整稳定比较；bulk 只写“完整稳定排序”，没有空值、大小写、locale/natural 与唯一稳定键，也未覆盖排序 DOM/ARIA/焦点。 |
| 分页 | 通过 | 通过 | **失败** | display/row 的 numbered/cursor 契约完整；bulk 声明 numbered，但未完整覆盖边界 disabled、查询回起点、跳页错误与相应 DOM/焦点。 |
| 选择范围与 excludedIds | 合理不适用 | 合理不适用 | 通过 | bulk 明确内部空字段、不可变后继、旧快照不变与普通翻页身份保持。 |
| 操作与失败恢复 | 合理不适用 | 通过 | 通过 | 适用场景覆盖快照、六项门禁、重复提交、unknown、部分成功与失败项重试。 |
| Table/Grid、列、焦点、响应式、ARIA | 通过 | 通过 | 通过 | 可选列/Grid 能力有零入口依据；共同语义、焦点、响应式与公告有正文位置。 |
| disposal、实例隔离、验证边界 | 通过 | 通过 | 通过 | 三者均为正向契约并保留运行时未验证。 |
| 应用清单粒度 | 通过 | 通过 | **失败** | bulk 把“查询、筛选、排序、分页、数据状态”合并成一个适用行，无法暴露上述三个缺口。 |

场景结论：display `PASS`，row-action `PASS`，bulk `FAIL`；整体 `FAILED/INCOMPLETE`。`responsivePresentation` 的局部值没有行为冲突，不因未形成封闭枚举而失败。

## 后续修复

owner 新增 `DT-REPORT-03` / `A38`：强制五个相邻族逐行判定，并对筛选、排序、分页的独立完成条件逐项定位；缺一项即失败，不能被合并的查询行抵消。Attempt 2 原始证据保持不变。

## 证据

- [展示型原始输出](attempt-2-display-report.md)
- [单行操作原始输出](attempt-2-row-action-list.md)
- [批量操作原始输出](attempt-2-bulk-action-table.md)
- [派发与 SHA 回执](attempt-2-dispatch-receipts.md)
