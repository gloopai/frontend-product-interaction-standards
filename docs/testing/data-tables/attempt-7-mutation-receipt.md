# Attempt 7 mutation 回执

状态：`MUTATIONS_PASS_BASELINE_FAIL`

复跑命令：

```sh
DATA_TABLE_AUDIT_PREFIX=attempt-7 ruby docs/testing/data-tables/attempt-6-application-audit.rb --mutations-on-failing-baseline
```

预期 exit：`1`，因为 Attempt 7 基线仍失败。mutation 采用相对基线错误集合的增量判定，避免既有失败让破坏副本伪通过；`22/22 EXPECTED_FAIL` 只证明门禁能识别每个新增破坏，不把基线变成 GREEN。

```text
BASELINE FAIL scenarios=3 records=260 errors=19
  display: PASS records=91 errors=0
  row-action: PASS records=76 errors=0
  bulk-action: FAIL records=93 errors=19
    operationState.row-operation-or-absence: missing minimum field
    checklist ARIA Grid 语义: N/A zero evidence missing request
    filtering.draft-applied-separation: semantic evidence missing
    filtering.default-reset: semantic evidence missing
    filtering.url-safety: semantic evidence missing
    filtering.field-error-owner: semantic evidence missing
    filtering.pagination-reset: semantic evidence missing
    sorting.natural-order-rule: semantic evidence missing
    sorting.interactive-aria: semantic evidence missing
    sorting.interactive-keyboard: semantic evidence missing
    sorting.reset-to-origin: semantic evidence missing
    pagination-numbered.reliable-total-and-range: semantic evidence missing
    pagination-numbered.direct-pages: semantic evidence missing
    pagination-numbered.validated-jump: semantic evidence missing
    pagination-numbered.native-boundaries: semantic evidence missing
    pagination-numbered.page-size-control: semantic evidence missing
    pagination-numbered.reset-to-first: semantic evidence missing
    pagination-numbered.single-invalid-page-recovery: semantic evidence missing
    pagination-numbered.input-semantics: semantic evidence missing
MUTATION EXPECTED_FAIL id=M01-remove-bulkOperationEnabled scenario=bulk-action operator="delete capability current value" new_errors=1
  capability bulkOperationEnabled: rows=0
MUTATION EXPECTED_FAIL id=M02-conditional-allFilteredSelectionEnabled scenario=bulk-action operator="replace current boolean with condition-only text" new_errors=1
  capability allFilteredSelectionEnabled: conditional/non-current value="满足后端条件时启用"
MUTATION EXPECTED_FAIL id=M03-remove-row-viewState scenario=row-action operator="rename fixed viewState heading" new_errors=1
  state group viewState: missing exact heading
MUTATION EXPECTED_FAIL id=M04-remove-bulk-interactionState scenario=bulk-action operator="rename fixed interactionState heading" new_errors=1
  state group interactionState: missing exact heading
MUTATION EXPECTED_FAIL id=M05-remove-bulk-view-visibleColumnIds scenario=bulk-action operator="remove visibleColumnIds from viewState" new_errors=1
  viewState.visibleColumnIds: missing minimum field
MUTATION EXPECTED_FAIL id=M06-remove-bulk-view-pinnedColumnIds scenario=bulk-action operator="remove pinnedColumnIds from viewState" new_errors=1
  viewState.pinnedColumnIds: missing minimum field
MUTATION EXPECTED_FAIL id=M07-remove-bulk-view-columnWidths scenario=bulk-action operator="remove columnWidths from viewState" new_errors=1
  viewState.columnWidths: missing minimum field
MUTATION EXPECTED_FAIL id=M08-remove-bulk-view-density scenario=bulk-action operator="remove density from viewState" new_errors=1
  viewState.density: missing minimum field
MUTATION EXPECTED_FAIL id=M09-remove-bulk-view-rows scenario=bulk-action operator="remove rows from viewState" new_errors=1
  viewState.rows: missing minimum field
MUTATION EXPECTED_FAIL id=M10-remove-bulk-view-resultSummary scenario=bulk-action operator="remove resultSummary from viewState" new_errors=1
  viewState.resultSummary: missing minimum field
MUTATION EXPECTED_FAIL id=M11-lifecycle-substitutes-group scenario=row-action operator="replace independent lifecycle guard heading with lifecycleState" new_errors=1
  lifecycleRole: independent guard heading missing
MUTATION EXPECTED_FAIL id=M12-delete-runtime-checklist-row scenario=display operator="delete standalone runtime verification checklist row" new_errors=1
  checklist 运行时验证边界: rows=0
MUTATION EXPECTED_FAIL id=M13-delete-filter-checklist-row scenario=display operator="delete independent A38 filter checklist row" new_errors=1
  checklist 筛选: rows=0
MUTATION EXPECTED_FAIL id=M14-partial-applicability scenario=row-action operator="replace binary selection applicability with 部分适用" new_errors=2
  checklist 选择: non-binary applicability="部分适用"
  checklist 选择: forbidden mixed applicability at RAW OUTPUT:L351
MUTATION EXPECTED_FAIL id=M15-merge-selection-operations scenario=row-action operator="merge selection, row operation and bulk operation" new_errors=5
  checklist 选择: rows=0
  checklist 单行操作: rows=0
  checklist 批量操作: rows=0
  checklist 选择与操作: forbidden mixed applicability at RAW OUTPUT:L351
  checklist 选择与操作: forbidden merged row at RAW OUTPUT:L351
MUTATION EXPECTED_FAIL id=M16-merge-column-families scenario=bulk-action operator="merge base column state and optional column controls" new_errors=4
  checklist 基础列状态: rows=0
  checklist 可选列控制: rows=0
  checklist 列: forbidden mixed applicability at RAW OUTPUT:L429
  checklist 列: forbidden merged row at RAW OUTPUT:L429
MUTATION EXPECTED_FAIL id=M17-merge-table-grid scenario=display operator="merge Table and ARIA Grid semantics" new_errors=4
  checklist Table 语义: rows=0
  checklist ARIA Grid 语义: rows=0
  checklist Table/Grid: forbidden mixed applicability at RAW OUTPUT:L488
  checklist Table/Grid: forbidden merged row at RAW OUTPUT:L488
MUTATION EXPECTED_FAIL id=M18-merge-disposal-isolation scenario=display operator="merge disposal and instance isolation" new_errors=4
  checklist disposal: rows=0
  checklist 实例隔离: rows=0
  checklist disposal/实例隔离: forbidden mixed applicability at RAW OUTPUT:L494
  checklist disposal/实例隔离: forbidden merged row at RAW OUTPUT:L494
MUTATION EXPECTED_FAIL id=M19-status-in-applicability scenario=display operator="mix runtime verification status into applicability" new_errors=1
  checklist 运行时验证边界: non-binary applicability="适用，当前未验证"
MUTATION EXPECTED_FAIL id=M20-break-selection-generation-contract scenario=bulk-action operator="preserve selectionGeneration reference while changing +1 state transition to display-only" new_errors=1
  selection contract 资格变化: generationEffect must increment exactly once
MUTATION EXPECTED_FAIL id=M21-drop-selection-lifecycleToken-guard scenario=bulk-action operator="remove lifecycleToken from the async selection commit guard" new_errors=1
  selection contract 异步选择协调回调: commitGuard must equal live+ownerId+lifecycleToken+selectionGeneration
MUTATION EXPECTED_FAIL id=M22-operation-generation-mismatch-writes-selection scenario=bulk-action operator="allow operation result to adjust selection after captured generation mismatch" new_errors=1
  selection contract 操作结果调整当前选择: mismatchEffect must be operation owner only with selectionWrite=0
MUTATION AUDIT PASS expected_failures=22/22
```
