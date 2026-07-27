# GREEN 应用：数据导入、导出任务中心与审计日志

> 原始任务能力全部保留：CSV 导入、字段映射、预检查、后台执行、错误文件、敏感导出、下载链接、任务取消、任务重试、审计日志筛选和移动端查看。

<!-- admin-console-audit:start -->
```json
{
  "schemaVersion": 2,
  "scenario": "job-audit-console",
  "promptCapabilities": {
    "csvImport": true,
    "fieldMapping": true,
    "precheck": true,
    "backgroundExecution": true,
    "errorFile": true,
    "sensitiveExport": true,
    "downloadLink": true,
    "cancelTask": true,
    "retryTask": true,
    "auditFilter": true,
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
  "consoleSurfaces": ["job-center", "audit-log"],
  "stateOwners": ["navigationState", "permissionState", "surfaceState", "riskState", "auditState", "taskState", "feedbackState"],
  "permissionBoundary": {
    "tenantScoped": true,
    "oldDataDisposition": "hide-before-refresh",
    "oldMenuDisposition": "hide-before-refresh",
    "oldDownloadDisposition": "invalidate-before-refresh"
  },
  "riskOperations": [
    {
      "name": "sensitive-export",
      "requestIdentity": {"operationId": true, "idempotencyKey": true, "permissionVersion": true, "targetSnapshot": true, "initiator": true},
      "resultReceipt": {"states": ["success", "partial-success", "failure", "conflict", "unknown"], "auditReceipt": true, "pageInline": true}
    },
    {
      "name": "cancel-task",
      "requestIdentity": {"operationId": true, "idempotencyKey": true, "permissionVersion": true, "targetSnapshot": true, "initiator": true},
      "resultReceipt": {"states": ["success", "partial-success", "failure", "conflict", "unknown"], "auditReceipt": true, "pageInline": true}
    },
    {
      "name": "retry-task",
      "requestIdentity": {"operationId": true, "idempotencyKey": true, "permissionVersion": true, "targetSnapshot": true, "initiator": true},
      "resultReceipt": {"states": ["success", "partial-success", "failure", "conflict", "unknown"], "auditReceipt": true, "pageInline": true}
    }
  ],
  "audit": {"availabilityDeclared": true, "receiptLocationDeclared": true, "states": ["no-data", "no-permission", "filter-empty", "service-error", "data-delay"]},
  "taskContract": {
    "importPrecheckCreatesJob": false,
    "downloadReauthorizes": true,
    "pageCloseCancelsTask": false,
    "states": ["queued", "running", "success", "partial-success", "failure", "cancelling", "cancelled", "unknown", "expired"]
  },
  "dataTable": {
    "capabilityTier": "row-action",
    "resolvedTier": "row-action",
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

## 场景、权限与页面级状态

- `consoleSurface: job-center + audit-log`。`navigationState` 保留“运营 / 数据任务”与同一任务上下文的 Tabs；未完成映射草稿离开前确认，已启动任务离开只中止客户端观察。
- `permissionState` 保存 tenant/workspace/role/permissionVersion/resolvedSurface。变化时先隐藏旧任务、审计对象、错误文件、菜单和下载，再刷新；旧 Notification 和缓存 URL 不绕过下载重验。
- `surfaceState` 在任务列表与审计列表分别区分加载、内容、无数据、筛选无结果、无权限、服务错误和数据延迟。
- `riskState` 承载敏感导出、任务取消和重试；`auditState` 声明审计可用性、页面内写入回执、“审计日志 / 数据任务”位置和失败恢复；`feedbackState` 以任务详情/Alert 为 primary owner，Notification/Toast 只辅助。

## 导入表单、Dialog 与任务契约

导入表单约束 CSV、文件上限、字段映射、预检查与提交。每个映射字段保存 `initialValue/value/touched/dirty/syncErrors/asyncErrors/serverErrors/validationGeneration`；草稿与已提交映射分离。点击“开始导入”先建 `submitSnapshot + submitId`，重复点击/Enter/重放复用候选；预检查失败的执行任务创建数为 0，页面内 Alert 保留错误文件、行号和下一步。

导入确认、敏感导出、取消和重试都使用风险相称的 Dialog：遮罩不关闭，右上关闭存在，Escape 不伪造服务端取消，外框不滚动、内容区滚动，标题和操作区持续可见。焦点陷阱、初始焦点、失败后保持打开、退出完成后单次恢复和 route/unmount disposal 均按 Dialog owner。

`taskState` 对每个导入、导出和后台任务持续绑定快照、创建/执行/查看/下载权限、幂等键、排队/进度、结果和失败恢复。状态明确区分排队、运行中、成功、部分成功、失败、取消中、已取消、未知结果和过期。关闭页面不等于取消任务；取消请求不等于服务端已停止。

敏感导出冻结范围、筛选快照、权限范围、敏感字段规则、生成方式、过期时间与下载身份。下载每次重验 permissionVersion、initiator 和 requestIdentity；权限变化、过期或身份不匹配立即拒绝。敏感导出、取消和重试均冻结 `{operationId,idempotencyKey,permissionVersion,targetSnapshot,initiator}`，并提供成功、部分成功、失败、冲突、未知结果和审计回执。

## 任务/审计列表：data-table owner

两个列表均显式为 `capabilityTier: row-action`、`resolvedTier: row-action`；`filteringEnabled=true`、`sortingEnabled=true`、`paginationMode=cursor`、`pageSize=50`、`pageSelectionEnabled=false`、`allFilteredSelectionEnabled=false`、`rowOperationEnabled=true`、`bulkOperationEnabled=false`、`columnVisibilityEnabled=true`、`columnPinningEnabled=true`、`columnResizeEnabled=false`、`responsivePresentation=table-or-labeled-cards`。

- `queryState`：`appliedFilters/sortRules/pagination/pageSize/querySnapshot/snapshotId/datasetVersion/requestGeneration/requestPhase/queryError/stale`；响应仅在 live/owner/token/generation/snapshot 匹配时提交。
- `viewState`：`visibleColumnIds/pinnedColumnIds/columnWidths/density/rows/resultSummary`。
- `interactionState`：`focusIntent/recordId/columnId/openRowAction`；选择字段未实例化。
- `operationState`：行操作为查看详情、下载错误文件/导出文件、取消或重试；批量子槽未实例化。
- 独立 `lifecycleGuard`：`ownerId/lifecycleToken/live|disposed/ownedResources`，route/unmount 立即 disposal 且不声称服务端已取消。

| operationKind | currentValue | stateSlot | DOM | handler/event | request |
| --- | --- | --- | --- | --- | --- |
| row | detail/download/cancel/retry | rowOperation | 有名称行菜单 | row intent/confirm/recover | identity-bound request |
| bulk | not-instantiated | 0 | 0 | 0 | 0 |

筛选区按 forms owner 分离 draft/applied，使用 explicit apply、产品默认 reset、可见可移除条件、`urlSafe` 限制和字段错误 owner。任务列表排序为 `createdAt desc` + `taskId asc`，审计列表为 `occurredAt desc` + `auditId asc`；两者均 null last、Unicode case-fold、`zh-CN`、自然数字比较。游标分页只使用不透明 prev/next，方向缺失时原生 disabled，不伪造总页、跳页、加载更多或无限滚动；失效游标只恢复一次。

| ruleFamily | obligationKey | applicability | currentValueOrZeroEvidence | outputLocation | verificationStatus |
| --- | --- | --- | --- | --- | --- |
| filtering | draft-applied-separation | 适用 | draft/applied 分离 | 本节 | 未验证 |
| filtering | declared-apply-mode | 适用 | explicit | 本节 | 未验证 |
| filtering | default-reset | 适用 | 产品默认 | 本节 | 未验证 |
| filtering | visible-removable-applied-values | 适用 | 可见可移除 | 本节 | 未验证 |
| filtering | url-safety | 适用 | 仅 urlSafe | 本节 | 未验证 |
| filtering | field-error-owner | 适用 | field owner | 本节 | 未验证 |
| filtering | pagination-reset | 适用 | 回初始游标 | 本节 | 未验证 |
| sorting | actual-key-direction | 适用 | createdAt/occurredAt desc | 本节 | 静态已定义 |
| sorting | null-order | 适用 | null last | 本节 | 静态已定义 |
| sorting | case-rule | 适用 | Unicode case-fold | 本节 | 静态已定义 |
| sorting | locale-rule | 适用 | zh-CN | 本节 | 静态已定义 |
| sorting | natural-order-rule | 适用 | numeric | 本节 | 静态已定义 |
| sorting | unique-stable-key | 适用 | taskId/auditId asc | 本节 | 静态已定义 |
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

## 审计、公告、响应式与验证

审计日志独立展示无数据、无权限、筛选无结果、审计服务不可用和数据延迟；查询/导出不泄露无权主体、对象或租户名。任务详情和页面内 Alert 承载唯一完整结果/错误/恢复；Notification 用于跨页消息，Toast 仅辅助，Tooltip/Popover 不承载唯一错误或权限原因。

窄屏可用字段标签卡片或受控横向滚动，但任务身份、进度、错误文件、下载、取消、重试、审计筛选、权限原因和恢复入口全部可达。200% 缩放、长文本、低高度、虚拟键盘和 safe area 不删除核心能力。

浏览器、AT（屏幕阅读器）、touch（触摸设备）和真实组件运行时均未执行；任务 DOM/ARIA、键盘/焦点、事件日志、下载重验、取消终态和断点行为均为未验证。

| 原子规则族 | 适用性 | DOM | state | handler/event | request | 正文定位 | 验证状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 能力与状态 | 适用 | 两列表 | 四组 | tier resolve | query/row | “列表 owner” | 静态已定义 |
| 查询 | 适用 | 结果区 | queryState | snapshot/generation | query | “列表 owner” | 未验证 |
| 筛选 | 适用 | 筛选表单 | draft/applied | apply/reset | query | “列表 owner” | 未验证 |
| 排序 | 适用 | 表头按钮 | sortRules | sort | query | “列表 owner” | 未验证 |
| 分页 | 适用 | prev/next | cursor | page | query | “列表 owner” | 未验证 |
| 数据状态 | 适用 | busy/error/empty | requestPhase | retry | query | “场景、权限” | 未验证 |
| 选择 | 不适用 | 0 | 0 | 0 | 0 | row-action 档位 | 静态零值 |
| 单行操作 | 适用 | 行菜单 | operationState | confirm/recover | risk/task | operation 子槽 | 未验证 |
| 批量操作 | 不适用 | 0 | 0 | 0 | 0 | operation 子槽 | 静态零值 |
| 基础列状态 | 适用 | columns | viewState | render | 0 | “列表 owner” | 未验证 |
| 可选列控制 | 适用 | visibility/pin | viewState | column | 0 | “列表 owner” | 未验证 |
| Table 语义 | 适用 | table | viewState | keyboard | 0 | “审计、公告” | 未验证 |
| ARIA Grid 语义 | 不适用 | 0 | 0 | 0 | 0 | 采用原生 Table | 静态零值 |
| 键盘 | 适用 | controls | focusIntent | keyboard | query/task | “审计、公告” | 未验证 |
| 焦点 | 适用 | live target | interactionState | focus | 0 | “审计、公告” | 未验证 |
| 响应式 | 适用 | table/cards | owner 不变 | breakpoint | 0 | “审计、公告” | 未验证 |
| ARIA 与公告 | 适用 | named/status | owner | announce | 0 | “审计、公告” | 未验证 |
| disposal | 适用 | owned DOM | disposed | dispose | cancel only | `lifecycleGuard` | 未验证 |
| 实例隔离 | 适用 | owner DOM | owner/token | guarded callback | query/task | `lifecycleGuard` | 未验证 |
| 运行时验证边界 | 适用 | 未验证 | 未验证 | 未验证 | 未验证 | “验证” | 未验证 |
