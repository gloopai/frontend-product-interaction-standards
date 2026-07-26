# Attempt 6 Mutation 审计回执

状态：`PASS`

命令：

```sh
ruby docs/testing/data-tables/attempt-6-application-audit.rb
```

判定协议：三份冻结基线必须零错误；每个命名 mutation 必须至少产生一个字段级失败诊断。任一基线失败或 mutation 意外通过时脚本非零退出。

## 完整回执

```text
BASELINE PASS scenarios=3 records=192
  display: PASS records=64
  row-action: PASS records=64
  bulk-action: PASS records=64
MUTATION EXPECTED_FAIL id=M01-remove-bulkOperationEnabled scenario=bulk-action operator="delete capability current value" errors=1
  capability bulkOperationEnabled: rows=0
MUTATION EXPECTED_FAIL id=M02-conditional-allFilteredSelectionEnabled scenario=bulk-action operator="replace current boolean with condition-only text" errors=1
  capability allFilteredSelectionEnabled: conditional/non-current value="满足后端条件时启用"
MUTATION EXPECTED_FAIL id=M03-remove-row-viewState scenario=row-action operator="rename fixed viewState heading" errors=1
  state group viewState: missing exact heading
MUTATION EXPECTED_FAIL id=M04-remove-bulk-interactionState scenario=bulk-action operator="rename fixed interactionState heading" errors=1
  state group interactionState: missing exact heading
MUTATION EXPECTED_FAIL id=M05-remove-bulk-view-visibleColumnIds scenario=bulk-action operator="remove visibleColumnIds from viewState" errors=1
  viewState.visibleColumnIds: missing minimum field
MUTATION EXPECTED_FAIL id=M06-remove-bulk-view-pinnedColumnIds scenario=bulk-action operator="remove pinnedColumnIds from viewState" errors=1
  viewState.pinnedColumnIds: missing minimum field
MUTATION EXPECTED_FAIL id=M07-remove-bulk-view-columnWidths scenario=bulk-action operator="remove columnWidths from viewState" errors=1
  viewState.columnWidths: missing minimum field
MUTATION EXPECTED_FAIL id=M08-remove-bulk-view-density scenario=bulk-action operator="remove density from viewState" errors=1
  viewState.density: missing minimum field
MUTATION EXPECTED_FAIL id=M09-remove-bulk-view-rows scenario=bulk-action operator="remove rows from viewState" errors=1
  viewState.rows: missing minimum field
MUTATION EXPECTED_FAIL id=M10-remove-bulk-view-resultSummary scenario=bulk-action operator="remove resultSummary from viewState" errors=1
  viewState.resultSummary: missing minimum field
MUTATION EXPECTED_FAIL id=M11-lifecycle-substitutes-group scenario=row-action operator="replace independent lifecycle guard heading with lifecycleState" errors=1
  lifecycleRole: independent guard heading missing
MUTATION EXPECTED_FAIL id=M12-delete-runtime-checklist-row scenario=display operator="delete standalone runtime verification checklist row" errors=1
  checklist 运行时验证边界: rows=0
MUTATION EXPECTED_FAIL id=M13-delete-filter-checklist-row scenario=display operator="delete independent A38 filter checklist row" errors=1
  checklist 筛选: rows=0
MUTATION EXPECTED_FAIL id=M14-partial-applicability scenario=row-action operator="replace binary selection applicability with 部分适用" errors=2
  checklist 选择: non-binary applicability="部分适用"
  checklist 选择: forbidden mixed applicability at RAW OUTPUT:L455
MUTATION EXPECTED_FAIL id=M15-merge-selection-operations scenario=row-action operator="merge selection, row operation and bulk operation" errors=5
  checklist 选择: rows=0
  checklist 单行操作: rows=0
  checklist 批量操作: rows=0
  checklist 选择与操作: forbidden mixed applicability at RAW OUTPUT:L455
  checklist 选择与操作: forbidden merged row at RAW OUTPUT:L455
MUTATION EXPECTED_FAIL id=M16-merge-column-families scenario=bulk-action operator="merge base column state and optional column controls" errors=4
  checklist 基础列状态: rows=0
  checklist 可选列控制: rows=0
  checklist 列: forbidden mixed applicability at RAW OUTPUT:L573
  checklist 列: forbidden merged row at RAW OUTPUT:L573
MUTATION EXPECTED_FAIL id=M17-merge-table-grid scenario=display operator="merge Table and ARIA Grid semantics" errors=4
  checklist Table 语义: rows=0
  checklist ARIA Grid 语义: rows=0
  checklist Table/Grid: forbidden mixed applicability at RAW OUTPUT:L400
  checklist Table/Grid: forbidden merged row at RAW OUTPUT:L400
MUTATION EXPECTED_FAIL id=M18-merge-disposal-isolation scenario=display operator="merge disposal and instance isolation" errors=4
  checklist disposal: rows=0
  checklist 实例隔离: rows=0
  checklist disposal/实例隔离: forbidden mixed applicability at RAW OUTPUT:L406
  checklist disposal/实例隔离: forbidden merged row at RAW OUTPUT:L406
MUTATION EXPECTED_FAIL id=M19-status-in-applicability scenario=display operator="mix runtime verification status into applicability" errors=1
  checklist 运行时验证边界: non-binary applicability="适用，当前未验证"
MUTATION AUDIT PASS expected_failures=19/19
```
