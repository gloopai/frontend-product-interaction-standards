# GREEN 应用：SaaS 收入概览与指标明细

> 原始任务能力全部保留：KPI 卡片、趋势图、明细表、时间范围筛选、导出入口和移动端查看。产品判断仍为报表默认展示型；显式要求的导出受权限、风险、审计和任务契约约束，不删除。

<!-- admin-console-audit:start -->
```json
{
  "schemaVersion": 2,
  "scenario": "report-dashboard",
  "promptCapabilities": {
    "kpiCards": true,
    "trendChart": true,
    "detailTable": true,
    "timeRangeFilter": true,
    "export": true,
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
  "consoleSurfaces": ["overview-dashboard", "report"],
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
      "requestIdentity": {
        "operationId": true,
        "idempotencyKey": true,
        "permissionVersion": true,
        "targetSnapshot": true,
        "initiator": true
      },
      "resultReceipt": {
        "states": ["success", "partial-success", "failure", "conflict", "unknown"],
        "auditReceipt": true,
        "pageInline": true
      }
    }
  ],
  "audit": {
    "availabilityDeclared": true,
    "receiptLocationDeclared": true,
    "states": ["no-data", "no-permission", "filter-empty", "service-error", "data-delay"]
  },
  "report": {
    "defaultDisplayOnly": true,
    "selectionEnabled": false,
    "rowActionsEnabled": false,
    "bulkEnabled": false,
    "exportEnabled": true,
    "metricDefinitionPresent": true,
    "refreshTimestampPresent": true,
    "dataLatencyPresent": true,
    "permissionScopePresent": true,
    "filterSnapshotShared": true
  },
  "dataTable": {
    "capabilityTier": "display",
    "resolvedTier": "display",
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

## 页面、权限与数据状态

- `consoleSurface: overview-dashboard + report`。`navigationState` 稳定标识“收入概览”、“分析 / 收入概览”和返回“分析”；筛选草稿 dirty 时离开前确认。
- `permissionState` 冻结 tenant、workspace、role、permissionVersion 和 `resolvedSurface`。租户或权限变化先隐藏旧 KPI、明细、菜单和导出下载，再以新范围刷新；禁用控件不泄露无权项目名或数量。
- `surfaceState` 分开首加载、内容、当前权限无数据、筛选无结果、指标未产生、服务失败、数据延迟和口径不可用。`feedbackState` 以结果区 Alert 为错误 primary owner，Toast 只辅助；唯一错误不能由 Toast 显示，Tooltip/Popover 不承载唯一权限原因或恢复入口。
- KPI“净收入”口径为已入账总收入减退款与折让；时间范围为用户已提交值；页面明示数据快照生成时间、最大 15 分钟延迟、tenant/workspace 权限范围与过滤条件。KPI、趋势图和明细表共用 `snapshotId + permissionVersion`。

## 明细表 owner 契约

`capabilityTier: display`，`resolvedTier: display`。`filteringEnabled=true`、`sortingEnabled=true`、`paginationMode=numbered`、`pageSize=25`、`pageSelectionEnabled=false`、`allFilteredSelectionEnabled=false`、`rowOperationEnabled=false`、`bulkOperationEnabled=false`、`columnVisibilityEnabled=true`、`columnPinningEnabled=true`、`columnResizeEnabled=false`、`responsivePresentation=table-or-labeled-cards`。

- `queryState`：`appliedFilters/sortRules/pagination/pageSize/querySnapshot/snapshotId/datasetVersion/requestGeneration/requestPhase/queryError/stale`；只有 live owner + generation + snapshot 门禁全匹配的响应可提交。
- `viewState`：`visibleColumnIds/pinnedColumnIds/columnWidths/density/rows/resultSummary`。
- `interactionState`：`focusIntent/recordId/columnId`；选择、展开行和行菜单未实例化。
- `operationState`：单行与批量均未实例化；导出属页面级 `taskState/riskState`，不伪装成表格行操作。
- 独立 `lifecycleGuard`：`ownerId/lifecycleToken/live|disposed/ownedResources`。route/unmount 立即 disposal，迟到查询不写 DOM/state/focus/live region，返回时重校验权限和数据版本。

| operationKind | currentValue | stateSlot | DOM | handler/event | request |
| --- | --- | --- | --- | --- | --- |
| row | not-instantiated | 0 | 0 | 0 | 0 |
| bulk | not-instantiated | 0 | 0 | 0 | 0 |

筛选表单把 `filterDraft` 与 `appliedFilters` 分离，时间范围为 `applyMode=explicit`；reset 回产品默认 28 天，只序列化 `urlSafe` 值。字段保留 `initialValue/value/touched/dirty/errors/validationGeneration`，错误紧邻字段并由错误摘要导航；只有已提交合法值生成新查询快照。查询失败保留旧结果、标记 stale 并提供可聚焦重试。

时间范围筛选作为 forms owner 的轻量表单执行完整生命周期：表单维护 `submitPhase`，阶段只允许 `idle`、`awaiting-validation`、`validation-aborted`、`request-in-flight`、`request-succeeded`、`request-failed`；等待校验期编辑策略为允许编辑但任何材料性输入立即把旧 `submitId` 终结为 `validation-aborted`。每次应用筛选先冻结 `submitSnapshot` 和 `submitId`，同步/异步校验均带 `live form session`、字段 id、`validationGeneration` 和候选值；`asyncErrors`、`serverErrors`、字段错误和表单级错误摘要分别有 primary owner。进入 `request-in-flight` 后旧响应只有在 live session、`submitId`、快照和权限版本都匹配时才能写回；`request-succeeded` 更新筛选基线，`request-failed` 保留草稿、dirty、错误摘要、焦点目标和重试路径。

| ruleFamily | obligationKey | applicability | currentValueOrZeroEvidence | outputLocation | verificationStatus |
| --- | --- | --- | --- | --- | --- |
| filtering | draft-applied-separation | 适用 | `filterDraft` / `appliedFilters` 分离 | 本节 | 静态已定义 |
| filtering | declared-apply-mode | 适用 | `explicit` | 本节 | 静态已定义 |
| filtering | default-reset | 适用 | 28 天 | 本节 | 静态已定义 |
| filtering | visible-removable-applied-values | 适用 | 摘要可见且可单独移除 | 本节 | 未验证 |
| filtering | url-safety | 适用 | 仅 `urlSafe` | 本节 | 未验证 |
| filtering | field-error-owner | 适用 | 字段 primary owner | 本节 | 未验证 |
| filtering | pagination-reset | 适用 | 回第 1 页 | 本节 | 未验证 |
| sorting | actual-key-direction | 适用 | `periodStart desc` | 本节 | 静态已定义 |
| sorting | null-order | 适用 | null last | 本节 | 静态已定义 |
| sorting | case-rule | 适用 | Unicode case-fold | 本节 | 静态已定义 |
| sorting | locale-rule | 适用 | `zh-CN` | 本节 | 静态已定义 |
| sorting | natural-order-rule | 适用 | numeric natural order | 本节 | 静态已定义 |
| sorting | unique-stable-key | 适用 | `revenueRecordId asc` | 本节 | 静态已定义 |
| sorting | interactive-dom | 适用 | 真实表头按钮 | 本节 | 未验证 |
| sorting | interactive-aria | 适用 | 主排序 `aria-sort` | 本节 | 未验证 |
| sorting | interactive-keyboard | 适用 | Enter/Space | 本节 | 未验证 |
| sorting | interactive-focus | 适用 | 保留表头按钮焦点 | 本节 | 未验证 |
| sorting | reset-to-origin | 适用 | 新排序回第 1 页 | 本节 | 未验证 |
| pagination | reliable-total-and-range | 适用 | 可靠总数、当前/总页和范围 | 本节 | 未验证 |
| pagination | direct-pages | 适用 | 直接页码 | 本节 | 未验证 |
| pagination | validated-jump | 适用 | 有标签且校验的跳页 | 本节 | 未验证 |
| pagination | native-boundaries | 适用 | 首末页原生 disabled | 本节 | 未验证 |
| pagination | page-size-control | 适用 | 25，允许 25/50/100 | 本节 | 未验证 |
| pagination | reset-to-first | 适用 | 筛选/排序回第 1 页 | 本节 | 未验证 |
| pagination | single-invalid-page-recovery | 适用 | 最近有效页恢复一次 | 本节 | 未验证 |
| pagination | input-semantics | 适用 | 真实按钮/输入并有名称 | 本节 | 未验证 |
| pagination | single-focus-transition | 适用 | 结果提交后一次焦点策略 | 本节 | 未验证 |

## 导出、Dialog、审计与反馈

导出入口显式存在。点击后先冻结导出范围、筛选快照、权限版本、敏感字段排除、过期时间和下载身份；敏感范围使用 Dialog 强确认。Dialog 点遮罩不关闭，有右上关闭、Escape 策略、焦点陷阱与发起器返回；外框不滚动，仅内容滚动，提交失败保持打开且聚焦错误摘要。

导出确认 Dialog 按 dialogs owner 展开而非只声明：打开时遮罩淡入、Dialog 从 `scale(0.96)` 到 `scale(1)`，`200ms ease-out`；关闭时 `150ms ease-in`，`prefers-reduced-motion` 下缩放禁用且过渡不超过 50ms。模态开始即取得 `inert` 背景隔离和页面滚动锁定；普通关闭顺序固定为退出动画完成 → `DOM 移除` → 释放模态保护（焦点约束、遮罩、背景隔离、页面滚动锁定）→ 焦点返回导出按钮，且只执行一次。提交中失败保持 Dialog 打开并聚焦错误摘要；route/unmount disposal 不等待退出动画、不焦点返回旧触发器，只清理当前实例资源。

`riskState` 保存 `riskLevel=sensitive`、`impactScope`、`confirmationPolicy=strong`，以及 `{operationId,idempotencyKey,permissionVersion,targetSnapshot,initiator}`。`resultReceipt` 区分成功、部分成功、失败、冲突、未知结果和审计回执。`taskState` 显示排队、生成、成功/失败/未知/过期，下载时重验权限与身份；`auditState` 明示审计可用性、页面内回执位置和失败恢复。

## 键盘、ARIA、响应式和验证边界

原生 Table 具有可区分名称；表头排序、筛选、页码、导出和 Dialog 全部可键盘到达，同一完整状态只公告一次。响应式等价覆盖 `1440×900`、`1280×720`、平板横竖屏、窄屏、低高度、200% 缩放、虚拟键盘和四向 safe area；窄屏把明细表转成有字段标签的等价卡片或受控横向滚动，保留 KPI 口径、导出、权限、错误恢复和审计回执。断点切换保持同一 owner、同一筛选草稿、同一 Dialog/导出任务和状态延续，不重建表单、表格、Dialog 或在途请求。

浏览器、AT（屏幕阅读器）、touch（触摸设备）和真实组件运行时均未执行；DOM/ARIA、焦点、键盘、事件日志、下载拒绝与断点行为均为未验证。

| 原子规则族 | 适用性 | DOM | state | handler/event | request | 正文定位 | 验证状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 能力与状态 | 适用 | 明细表 | 四组 | tier resolve | query | “明细表 owner 契约” | 静态已定义 |
| 查询 | 适用 | 结果区 | queryState | snapshot/generation | query | “明细表 owner 契约” | 未验证 |
| 筛选 | 适用 | 时间表单 | draft/applied | apply/reset | query | “明细表 owner 契约” | 未验证 |
| 排序 | 适用 | 表头按钮 | sortRules | sort commit | query | “原子应用义务” | 未验证 |
| 分页 | 适用 | 页码 | pagination | page change | query | “原子应用义务” | 未验证 |
| 数据状态 | 适用 | busy/error/empty | requestPhase | retry | query | “页面、权限与数据状态” | 未验证 |
| 选择 | 不适用 | 0 | 0 | 0 | 0 | `display` 档位 | 静态零值 |
| 单行操作 | 不适用 | 0 | 0 | 0 | 0 | operation 子槽 | 静态零值 |
| 批量操作 | 不适用 | 0 | 0 | 0 | 0 | operation 子槽 | 静态零值 |
| 基础列状态 | 适用 | columns | viewState | render | 0 | “明细表 owner 契约” | 未验证 |
| 可选列控制 | 适用 | visibility/pin | viewState | column events | 0 | “明细表 owner 契约” | 未验证 |
| Table 语义 | 适用 | table | viewState | keyboard | 0 | “键盘、ARIA” | 未验证 |
| ARIA Grid 语义 | 不适用 | 0 | 0 | 0 | 0 | 采用原生 Table | 静态零值 |
| 键盘 | 适用 | controls | focusIntent | keyboard events | query/export | “键盘、ARIA” | 未验证 |
| 焦点 | 适用 | live targets | interactionState | focus policy | 0 | “键盘、ARIA” | 未验证 |
| 响应式 | 适用 | table/cards | owner 不变 | breakpoint | 0 | “键盘、ARIA” | 未验证 |
| ARIA 与公告 | 适用 | named/status | announcement owner | announce | 0 | “键盘、ARIA” | 未验证 |
| disposal | 适用 | remove owned DOM | disposed | dispose | cancel only | `lifecycleGuard` | 未验证 |
| 实例隔离 | 适用 | owner DOM | owner/token | guarded callback | query | `lifecycleGuard` | 未验证 |
| 运行时验证边界 | 适用 | 未验证 | 未验证 | 未验证 | 未验证 | “验证边界” | 未验证 |
