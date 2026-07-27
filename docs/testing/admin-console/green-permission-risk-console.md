# GREEN 应用：多租户用户与角色管理

> 原始任务能力全部保留：租户切换、RBAC 权限变化、用户列表、角色详情、删除用户、批量停用、权限变更、确认弹窗、结果提示和移动端使用。

<!-- admin-console-audit:start -->
```json
{
  "schemaVersion": 2,
  "scenario": "permission-risk-console",
  "promptCapabilities": {
    "tenantSwitch": true,
    "rbacChanges": true,
    "userList": true,
    "roleDetail": true,
    "deleteUser": true,
    "bulkDeactivate": true,
    "permissionChange": true,
    "confirmationDialog": true,
    "mobile": true
  },
  "componentOwners": {
    "admin-console": true,
    "data-tables": true,
    "dialogs": true,
    "forms": true,
    "responsive-adaptive": true
  },
  "componentContracts": {"dataTableReport": true, "dialogLifecycle": true, "formLifecycle": true, "responsiveEquivalence": true},
  "consoleSurfaces": ["record-list", "record-detail", "record-editor", "settings"],
  "stateOwners": ["navigationState", "permissionState", "surfaceState", "riskState", "auditState", "taskState", "feedbackState"],
  "permissionBoundary": {
    "tenantScoped": true,
    "oldDataDisposition": "hide-before-refresh",
    "oldMenuDisposition": "hide-before-refresh",
    "oldDownloadDisposition": "invalidate-before-refresh"
  },
  "riskOperations": [
    {
      "name": "delete-user",
      "requestIdentity": {"operationId": true, "idempotencyKey": true, "permissionVersion": true, "targetSnapshot": true, "initiator": true},
      "resultReceipt": {"states": ["success", "partial-success", "failure", "conflict", "unknown"], "auditReceipt": true, "pageInline": true}
    },
    {
      "name": "bulk-deactivate",
      "requestIdentity": {"operationId": true, "idempotencyKey": true, "permissionVersion": true, "targetSnapshot": true, "initiator": true},
      "resultReceipt": {"states": ["success", "partial-success", "failure", "conflict", "unknown"], "auditReceipt": true, "pageInline": true}
    },
    {
      "name": "permission-change",
      "requestIdentity": {"operationId": true, "idempotencyKey": true, "permissionVersion": true, "targetSnapshot": true, "initiator": true},
      "resultReceipt": {"states": ["success", "partial-success", "failure", "conflict", "unknown"], "auditReceipt": true, "pageInline": true}
    }
  ],
  "audit": {"availabilityDeclared": true, "receiptLocationDeclared": true, "states": ["no-data", "no-permission", "filter-empty", "service-error", "data-delay"]},
  "dataTable": {
    "capabilityTier": "bulk-action",
    "resolvedTier": "bulk-action",
    "fixedStateGroups": ["queryState", "viewState", "interactionState", "operationState"],
    "lifecycleGuard": true,
    "applicationChecklist": true,
    "atomicObligations": true
  },
  "feedback": {"toastOnly": false, "tooltipOnly": false, "primaryOwnerUnique": true},
  "runtimeVerification": {"browser": false, "screenReader": false, "touch": false, "realComponent": false}
}
```
<!-- admin-console-audit:end -->

## 页面结构与七个 owner

- `consoleSurface: record-list + record-detail + record-editor + settings`。`navigationState` 维护“设置 / 成员 / 角色详情”、返回列表及 dirty 权限表单的离开确认。
- `permissionState` 保存 tenant、workspace、role、permissionVersion、resolvedSurface。租户/角色/权限版本改变时，旧成员数据、旧菜单、选择、确认快照、详情表单和下载均先隐藏或安全占位，再刷新；不展示无权成员姓名、数量或字段。
- `surfaceState` 区分首加载、内容、数据源空、筛选空、无权限、首加载失败、刷新失败和延迟。
- `riskState` 分开删除用户、批量停用与权限变更；`auditState` 说明审计可用性、回执位置“审计日志 / 成员与角色”和写入失败恢复；`taskState` 仅在批量操作转后台时记录排队/执行/结果；`feedbackState` 以页面内回执和 Alert 为 primary owner。

## 用户列表：data-table owner

`capabilityTier: bulk-action`，`resolvedTier: bulk-action`。`filteringEnabled=true`、`sortingEnabled=true`、`paginationMode=cursor`、`pageSize=50`、`pageSelectionEnabled=true`、`allFilteredSelectionEnabled=false`、`rowOperationEnabled=true`、`bulkOperationEnabled=true`、`columnVisibilityEnabled=true`、`columnPinningEnabled=true`、`columnResizeEnabled=false`、`responsivePresentation=table-or-labeled-cards`。全部筛选结果选择未启用；批量停用只针对用户已确认的当前页稳定 ID。

- `queryState`：`appliedFilters/sortRules/pagination/pageSize/querySnapshot/snapshotId/datasetVersion/requestGeneration/requestPhase/queryError/stale`；查询响应使用 live + ownerId + lifecycleToken + generation + snapshot 门禁。
- `viewState`：`visibleColumnIds/pinnedColumnIds/columnWidths/density/rows/resultSummary`。
- `interactionState`：`focusIntent/recordId/columnId/openRowAction/selectionMode=page/selectionGeneration/selectedIds`；权限或查询范围改变清除旧选择。
- `operationState`：单行删除和批量停用各有不可变 operationSnapshot、operationId/generation、idempotencyKey、互斥结果、错误 owner、恢复入口和焦点意图。
- 独立 `lifecycleGuard`：`ownerId/lifecycleToken/live|disposed/ownedResources`；route/unmount 同步且幂等 disposal，迟到响应不写回。

| operationKind | currentValue | stateSlot | DOM | handler/event | request |
| --- | --- | --- | --- | --- | --- |
| row | delete-user | rowOperation | 行菜单“删除用户” | row intent/confirm/recover | operationSnapshot + idempotencyKey |
| bulk | bulk-deactivate | bulkOperation | 当前页复选框+批量栏 | select/confirm/retry | selectionSnapshot + operationSnapshot + idempotencyKey |

筛选表单使用 `filterDraft/appliedFilters`、显式应用、默认 active 重置、可见可移除条件和 `urlSafe` 限制；字段错误属字段 owner。排序为 `displayName asc`、null last、Unicode case-fold、`zh-CN`、自然数字比较、`memberId asc` 稳定键；改排序回初始游标。游标分页仅有服务端支持的上一页/下一页，缺失方向原生 disabled，不伪造总页数、跳页、加载更多或无限滚动。

| ruleFamily | obligationKey | applicability | currentValueOrZeroEvidence | outputLocation | verificationStatus |
| --- | --- | --- | --- | --- | --- |
| filtering | draft-applied-separation | 适用 | draft/applied 分离 | 本节 | 未验证 |
| filtering | declared-apply-mode | 适用 | explicit | 本节 | 未验证 |
| filtering | default-reset | 适用 | active | 本节 | 未验证 |
| filtering | visible-removable-applied-values | 适用 | 可见可移除 | 本节 | 未验证 |
| filtering | url-safety | 适用 | 仅 urlSafe | 本节 | 未验证 |
| filtering | field-error-owner | 适用 | field owner | 本节 | 未验证 |
| filtering | pagination-reset | 适用 | 回初始游标 | 本节 | 未验证 |
| sorting | actual-key-direction | 适用 | displayName asc | 本节 | 静态已定义 |
| sorting | null-order | 适用 | null last | 本节 | 静态已定义 |
| sorting | case-rule | 适用 | Unicode case-fold | 本节 | 静态已定义 |
| sorting | locale-rule | 适用 | zh-CN | 本节 | 静态已定义 |
| sorting | natural-order-rule | 适用 | numeric | 本节 | 静态已定义 |
| sorting | unique-stable-key | 适用 | memberId asc | 本节 | 静态已定义 |
| sorting | interactive-dom | 适用 | 表头按钮 | 本节 | 未验证 |
| sorting | interactive-aria | 适用 | aria-sort | 本节 | 未验证 |
| sorting | interactive-keyboard | 适用 | Enter/Space | 本节 | 未验证 |
| sorting | interactive-focus | 适用 | 保留表头焦点 | 本节 | 未验证 |
| sorting | reset-to-origin | 适用 | 回初始游标 | 本节 | 未验证 |
| pagination | opaque-bidirectional-cursors | 适用 | opaque prev/next | 本节 | 未验证 |
| pagination | missing-direction-disabled | 适用 | native disabled | 本节 | 未验证 |
| pagination | forbidden-numbered-and-stream-entries | 适用 | 禁止页码/跳页/加载更多/无限滚动 | 本节 | 未验证 |
| pagination | origin-and-single-recovery | 适用 | 回初始游标；失效恢复一次 | 本节 | 未验证 |
| pagination | input-semantics | 适用 | 有名称真实按钮 | 本节 | 未验证 |
| pagination | single-focus-transition | 适用 | 单次焦点策略 | 本节 | 未验证 |

## 角色详情表单与确认 Dialog

角色详情保留 `initialValue/value/touched/dirty/syncErrors/asyncErrors/serverErrors/validationGeneration`；提交创建不可变 `submitSnapshot + submitId`，预校验未通过请求为 0，重复点击/Enter/重放不创建第二请求。字段错误、跨字段错误和 `submitError` 各有唯一 owner；失败保留草稿、dirty、错误与恢复路径。

删除、批量停用、权限变更分别打开强度匹配的 Dialog：遮罩点击不关闭，右上关闭存在，Escape 只在尚未发请求且策略允许时关闭，焦点陷阱、初始焦点、退出完成后的单次返回和 route/unmount disposal 均按 Dialog owner。外框不滚动，标题/操作区固定，内容区滚动；提交失败不关闭。

三类操作的 `requestIdentity` 都冻结 `{operationId,idempotencyKey,permissionVersion,targetSnapshot,initiator}`；`resultReceipt` 都区分成功、部分成功、失败、冲突、未知结果与审计回执。权限版本或目标快照 stale 时不执行；页面内回执保留影响数、失败项、冲突/未知恢复与审计位置。关闭确认或离开页面不等于已发请求取消成功。

## 响应式、ARIA、反馈与验证

原生 Table 与卡片映射保留成员身份、状态、角色、选择、删除、批量停用和恢复。选择控件说明成员身份、当前页范围与混合/禁用状态；键盘可完成筛选、分页、行操作、页选择、批量确认和错误恢复。结果页面内回执是 primary owner，Toast 仅辅助；Tooltip/Popover 不承载唯一权限原因、错误或确认后果。

窄屏可收纳次要列和筛选，但租户、用户身份、角色详情、删除、批量停用、权限原因、确认后果、回执和恢复均可达；断点转换不重建正在编辑的表单或打开 Dialog。

浏览器、AT（屏幕阅读器）、touch（触摸设备）与真实组件运行时未执行；DOM/ARIA、焦点迁移、键盘、事件日志、批量部分成功和窄屏布局均为未验证。

| 原子规则族 | 适用性 | DOM | state | handler/event | request | 正文定位 | 验证状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 能力与状态 | 适用 | 用户列表 | 四组 | tier resolve | query/operation | “用户列表” | 静态已定义 |
| 查询 | 适用 | 结果区 | queryState | snapshot/generation | query | “用户列表” | 未验证 |
| 筛选 | 适用 | 筛选表单 | draft/applied | apply/reset | query | “用户列表” | 未验证 |
| 排序 | 适用 | 表头按钮 | sortRules | sort commit | query | “用户列表” | 未验证 |
| 分页 | 适用 | prev/next | cursor | page event | query | “用户列表” | 未验证 |
| 数据状态 | 适用 | busy/error/empty | requestPhase | retry | query | “页面结构” | 未验证 |
| 选择 | 适用 | 当前页 checkbox | interactionState | selection events | 0 | “用户列表” | 未验证 |
| 单行操作 | 适用 | 删除入口 | operationState | confirm/recover | risk request | operation 子槽 | 未验证 |
| 批量操作 | 适用 | 批量停用 | operationState | confirm/retry | bulk request | operation 子槽 | 未验证 |
| 基础列状态 | 适用 | columns | viewState | render | 0 | “用户列表” | 未验证 |
| 可选列控制 | 适用 | visibility/pin | viewState | column events | 0 | “用户列表” | 未验证 |
| Table 语义 | 适用 | table | viewState | keyboard | 0 | “响应式、ARIA” | 未验证 |
| ARIA Grid 语义 | 不适用 | 0 | 0 | 0 | 0 | 采用原生 Table | 静态零值 |
| 键盘 | 适用 | controls | focusIntent | keyboard events | query/operation | “响应式、ARIA” | 未验证 |
| 焦点 | 适用 | live target | interactionState | focus policy | 0 | “响应式、ARIA” | 未验证 |
| 响应式 | 适用 | table/cards | owner 不变 | breakpoint | 0 | “响应式、ARIA” | 未验证 |
| ARIA 与公告 | 适用 | named/status | primary owner | announce | 0 | “响应式、ARIA” | 未验证 |
| disposal | 适用 | owned DOM | disposed | dispose | cancel only | `lifecycleGuard` | 未验证 |
| 实例隔离 | 适用 | owner DOM | owner/token | guarded callback | query/operation | `lifecycleGuard` | 未验证 |
| 运行时验证边界 | 适用 | 未验证 | 未验证 | 未验证 | 未验证 | “验证” | 未验证 |
