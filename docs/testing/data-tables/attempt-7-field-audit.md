# Attempt 7 字段级与语义级审计

状态：`FAIL`

复跑命令：

```sh
DATA_TABLE_AUDIT_PREFIX=attempt-7 ruby docs/testing/data-tables/attempt-6-application-audit.rb --records
```

预期 exit：`1`。以下为逐字 stdout；账本即使基线失败也完整保存，末尾的 `AUDIT_STATUS` / `AUDIT_ERROR` 是裁决依据。

| scenario | recordKind | capabilityKey | currentValue | stateGroup | minimumField | lifecycleRole | checklistRow | adjacentFamily | semanticObligation | selectionContractPath | generationEffect | snapshotEffect | commitGuard | mismatchEffect | applicability | verificationStatus | outputLocation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| display | capability | capabilityTier | `display` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L9 |
| display | capability | resolvedTier | `display` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L10 |
| display | capability | filteringEnabled | `enabled` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L11 |
| display | capability | sortingEnabled | `enabled`，单列交互式排序 |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L12 |
| display | capability | paginationMode | `numbered` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L13 |
| display | capability | pageSize | `25` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L14 |
| display | capability | pageSelectionEnabled | `false` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L15 |
| display | capability | allFilteredSelectionEnabled | `false` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L16 |
| display | capability | rowOperationEnabled | `false` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L17 |
| display | capability | bulkOperationEnabled | `false` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L18 |
| display | capability | columnVisibilityEnabled | `false` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L19 |
| display | capability | columnPinningEnabled | `false` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L20 |
| display | capability | columnResizeEnabled | `false` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L21 |
| display | capability | responsivePresentation | `enabled: table-card` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L22 |
| display | state-group |  | declared | queryState |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L60 |
| display | state-minimum |  | present | queryState | appliedFilters |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L66 |
| display | state-minimum |  | present | queryState | sortRules |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L67 |
| display | state-minimum |  | present | queryState | pagination |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L68 |
| display | state-minimum |  | present | queryState | pageSize |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L69 |
| display | state-minimum |  | present | queryState | querySnapshot |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L70 |
| display | state-minimum |  | present | queryState | snapshotId |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L71 |
| display | state-minimum |  | present | queryState | datasetVersion |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L72 |
| display | state-minimum |  | present | queryState | requestGeneration |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L73 |
| display | state-minimum |  | present | queryState | requestPhase |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L74 |
| display | state-minimum |  | present | queryState | queryError |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L75 |
| display | state-minimum |  | present | queryState | stale |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L76 |
| display | state-group |  | declared | viewState |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L92 |
| display | state-minimum |  | present | viewState | visibleColumnIds |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L97 |
| display | state-minimum |  | present | viewState | pinnedColumnIds |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L99 |
| display | state-minimum |  | present | viewState | columnWidths |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L100 |
| display | state-minimum |  | present | viewState | density |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L101 |
| display | state-minimum |  | present | viewState | rows |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L102 |
| display | state-minimum |  | present | viewState | resultSummary |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L103 |
| display | state-group |  | declared | interactionState |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L109 |
| display | state-minimum |  | present | interactionState | focusIntent |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L114 |
| display | state-minimum |  | present | interactionState | recordId |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L116 |
| display | state-minimum |  | present | interactionState | columnId |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L117 |
| display | state-group |  | declared | operationState |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L135 |
| display | state-minimum |  | present | operationState | row-operation-or-absence |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L137 |
| display | state-minimum |  | present | operationState | bulk-operation-or-absence |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L137 |
| display | lifecycle |  | present |  | ownerId | guard |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L151 |
| display | lifecycle |  | present |  | lifecycleToken | guard |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L152 |
| display | lifecycle |  | present |  | live/disposed | guard |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L153 |
| display | lifecycle |  | present |  | ownedResources | guard |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L155 |
| display | checklist |  | 见“能力声明与边界”“固定状态模型” |  |  |  | 能力与状态 |  |  |  |  |  |  |  | 适用 | 未验证 | RAW OUTPUT:L477 |
| display | checklist |  | 见“查询快照与竞态门禁”“状态转换” |  |  |  | 查询 |  |  |  |  |  |  |  | 适用 | 未验证 | RAW OUTPUT:L478 |
| display | checklist |  | 见“筛选设计”；草稿、应用、重置、URL、字段错误和分页复位均已定义 |  |  |  | 筛选 |  |  |  |  |  |  |  | 适用 | 未验证 | RAW OUTPUT:L479 |
| display | checklist |  | 见“稳定排序”；实际键、方向、空值、大小写、locale、自然排序和稳定键均已定义 |  |  |  | 排序 |  |  |  |  |  |  |  | 适用 | 未验证 | RAW OUTPUT:L480 |
| display | checklist |  | 见“页码分页”；可靠总数、页码、跳页、边界、页大小、复位和单次恢复均已定义 |  |  |  | 分页 |  |  |  |  |  |  |  | 适用 | 未验证 | RAW OUTPUT:L481 |
| display | checklist |  | 见“加载、错误与空状态” |  |  |  | 数据状态 |  |  |  |  |  |  |  | 适用 | 未验证 | RAW OUTPUT:L482 |
| display | checklist |  | DOM 无选择列/复选框；状态槽未实例化；无选择 handler/事件；无选择请求入口 |  |  |  | 选择 |  |  |  |  |  |  |  | 不适用 | 未验证 | RAW OUTPUT:L483 |
| display | checklist |  | DOM 无行链接、操作按钮或菜单；状态槽未实例化；无单行 handler/事件；无单行请求入口 |  |  |  | 单行操作 |  |  |  |  |  |  |  | 不适用 | 未验证 | RAW OUTPUT:L484 |
| display | checklist |  | DOM 无批量工具栏或确认入口；状态槽未实例化；无批量 handler/事件；无批量请求入口 |  |  |  | 批量操作 |  |  |  |  |  |  |  | 不适用 | 未验证 | RAW OUTPUT:L485 |
| display | checklist |  | 见 `viewState` 的可见列、空固定列、静态宽度、密度和结果摘要 |  |  |  | 基础列状态 |  |  |  |  |  |  |  | 适用 | 未验证 | RAW OUTPUT:L486 |
| display | checklist |  | DOM 无列控制/固定/调宽入口；无相应可变状态槽；无列控制 handler/事件；不触发查询 |  |  |  | 可选列控制 |  |  |  |  |  |  |  | 不适用 | 未验证 | RAW OUTPUT:L487 |
| display | checklist |  | 见“DOM、ARIA 与状态公告”的原生 `<table>` 契约 |  |  |  | Table 语义 |  |  |  |  |  |  |  | 适用 | 未验证 | RAW OUTPUT:L488 |
| display | checklist |  | DOM 无 `role="grid"`；无活动单元格状态；无二维键盘 handler；无 Grid 请求入口 |  |  |  | ARIA Grid 语义 |  |  |  |  |  |  |  | 不适用 | 未验证 | RAW OUTPUT:L489 |
| display | checklist |  | 见“键盘与焦点” |  |  |  | 键盘 |  |  |  |  |  |  |  | 适用 | 未验证 | RAW OUTPUT:L490 |
| display | checklist |  | 见 `focusIntent` 与“焦点规则” |  |  |  | 焦点 |  |  |  |  |  |  |  | 适用 | 未验证 | RAW OUTPUT:L491 |
| display | checklist |  | 见“长内容、200% 缩放与移动端” |  |  |  | 响应式 |  |  |  |  |  |  |  | 适用 | 未验证 | RAW OUTPUT:L492 |
| display | checklist |  | 见“DOM、ARIA 与状态公告” |  |  |  | ARIA 与公告 |  |  |  |  |  |  |  | 适用 | 未验证 | RAW OUTPUT:L493 |
| display | checklist |  | 见“Disposal、返回恢复与实例隔离” |  |  |  | disposal |  |  |  |  |  |  |  | 适用 | 未验证 | RAW OUTPUT:L494 |
| display | checklist |  | 见独立 `lifecycleGuard`、唯一 owner 和资源归属规则 |  |  |  | 实例隔离 |  |  |  |  |  |  |  | 适用 | 未验证 | RAW OUTPUT:L495 |
| display | checklist |  | 见“尚未通过真实运行环境验证的结论” |  |  |  | 运行时验证边界 |  |  |  |  |  |  |  | 适用 | 未验证 | RAW OUTPUT:L496 |
| display | adjacent-semantic |  | present |  |  |  |  | filtering | draft-applied-separation |  |  |  |  |  |  |  | RAW OUTPUT:L187 |
| display | adjacent-semantic |  | present |  |  |  |  | filtering | declared-apply-mode |  |  |  |  |  |  |  | RAW OUTPUT:L169 |
| display | adjacent-semantic |  | present |  |  |  |  | filtering | default-reset |  |  |  |  |  |  |  | RAW OUTPUT:L172 |
| display | adjacent-semantic |  | present |  |  |  |  | filtering | visible-removable-applied-values |  |  |  |  |  |  |  | RAW OUTPUT:L193 |
| display | adjacent-semantic |  | present |  |  |  |  | filtering | url-safety |  |  |  |  |  |  |  | RAW OUTPUT:L194 |
| display | adjacent-semantic |  | present |  |  |  |  | filtering | field-error-owner |  |  |  |  |  |  |  | RAW OUTPUT:L90 |
| display | adjacent-semantic |  | present |  |  |  |  | filtering | pagination-reset |  |  |  |  |  |  |  | RAW OUTPUT:L246 |
| display | adjacent-semantic |  | present |  |  |  |  | sorting | actual-key-direction |  |  |  |  |  |  |  | RAW OUTPUT:L202 |
| display | adjacent-semantic |  | present |  |  |  |  | sorting | null-order |  |  |  |  |  |  |  | RAW OUTPUT:L202 |
| display | adjacent-semantic |  | present |  |  |  |  | sorting | case-rule |  |  |  |  |  |  |  | RAW OUTPUT:L214 |
| display | adjacent-semantic |  | present |  |  |  |  | sorting | locale-rule |  |  |  |  |  |  |  | RAW OUTPUT:L38 |
| display | adjacent-semantic |  | present |  |  |  |  | sorting | natural-order-rule |  |  |  |  |  |  |  | RAW OUTPUT:L214 |
| display | adjacent-semantic |  | present |  |  |  |  | sorting | unique-stable-key |  |  |  |  |  |  |  | RAW OUTPUT:L210 |
| display | adjacent-semantic |  | present |  |  |  |  | sorting | interactive-dom |  |  |  |  |  |  |  | RAW OUTPUT:L217 |
| display | adjacent-semantic |  | present |  |  |  |  | sorting | interactive-aria |  |  |  |  |  |  |  | RAW OUTPUT:L218 |
| display | adjacent-semantic |  | present |  |  |  |  | sorting | interactive-keyboard |  |  |  |  |  |  |  | RAW OUTPUT:L396 |
| display | adjacent-semantic |  | present |  |  |  |  | sorting | interactive-focus |  |  |  |  |  |  |  | RAW OUTPUT:L220 |
| display | adjacent-semantic |  | present |  |  |  |  | sorting | reset-to-origin |  |  |  |  |  |  |  | RAW OUTPUT:L216 |
| display | adjacent-semantic |  | present |  |  |  |  | pagination-numbered | reliable-total-and-range |  |  |  |  |  |  |  | RAW OUTPUT:L30 |
| display | adjacent-semantic |  | present |  |  |  |  | pagination-numbered | direct-pages |  |  |  |  |  |  |  | RAW OUTPUT:L236 |
| display | adjacent-semantic |  | present |  |  |  |  | pagination-numbered | validated-jump |  |  |  |  |  |  |  | RAW OUTPUT:L240 |
| display | adjacent-semantic |  | present |  |  |  |  | pagination-numbered | native-boundaries |  |  |  |  |  |  |  | RAW OUTPUT:L239 |
| display | adjacent-semantic |  | present |  |  |  |  | pagination-numbered | page-size-control |  |  |  |  |  |  |  | RAW OUTPUT:L231 |
| display | adjacent-semantic |  | present |  |  |  |  | pagination-numbered | reset-to-first |  |  |  |  |  |  |  | RAW OUTPUT:L216 |
| display | adjacent-semantic |  | present |  |  |  |  | pagination-numbered | single-invalid-page-recovery |  |  |  |  |  |  |  | RAW OUTPUT:L248 |
| display | adjacent-semantic |  | present |  |  |  |  | pagination-numbered | input-semantics |  |  |  |  |  |  |  | RAW OUTPUT:L238 |
| display | adjacent-semantic |  | present |  |  |  |  | pagination-numbered | single-focus-transition |  |  |  |  |  |  |  | RAW OUTPUT:L250 |
| row-action | capability | capabilityTier | `row-action` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L7 |
| row-action | capability | resolvedTier | `row-action`；权限整体撤销后降为 `display` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L8 |
| row-action | capability | filteringEnabled | `false` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L9 |
| row-action | capability | sortingEnabled | `false`，无用户可操作排序；查询仍使用固定稳定排序 |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L10 |
| row-action | capability | paginationMode | `cursor` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L11 |
| row-action | capability | pageSize | `25`，本版固定，无页大小控件 |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L12 |
| row-action | capability | pageSelectionEnabled | `false` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L13 |
| row-action | capability | allFilteredSelectionEnabled | `false` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L14 |
| row-action | capability | rowOperationEnabled | `true` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L15 |
| row-action | capability | bulkOperationEnabled | `false` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L16 |
| row-action | capability | columnVisibilityEnabled | `false` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L17 |
| row-action | capability | columnPinningEnabled | `false` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L18 |
| row-action | capability | columnResizeEnabled | `false` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L19 |
| row-action | capability | responsivePresentation | `table-to-card`，显式启用并使用固定字段映射 |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L20 |
| row-action | state-group |  | declared | queryState |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L44 |
| row-action | state-minimum |  | present | queryState | appliedFilters |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L47 |
| row-action | state-minimum |  | present | queryState | sortRules |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L48 |
| row-action | state-minimum |  | present | queryState | pagination |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L49 |
| row-action | state-minimum |  | present | queryState | pageSize |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L55 |
| row-action | state-minimum |  | present | queryState | querySnapshot |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L56 |
| row-action | state-minimum |  | present | queryState | snapshotId |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L57 |
| row-action | state-minimum |  | present | queryState | datasetVersion |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L59 |
| row-action | state-minimum |  | present | queryState | requestGeneration |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L60 |
| row-action | state-minimum |  | present | queryState | requestPhase |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L61 |
| row-action | state-minimum |  | present | queryState | queryError |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L63 |
| row-action | state-minimum |  | present | queryState | stale |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L64 |
| row-action | state-group |  | declared | viewState |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L71 |
| row-action | state-minimum |  | present | viewState | visibleColumnIds |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L74 |
| row-action | state-minimum |  | present | viewState | pinnedColumnIds |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L75 |
| row-action | state-minimum |  | present | viewState | columnWidths |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L76 |
| row-action | state-minimum |  | present | viewState | density |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L77 |
| row-action | state-minimum |  | present | viewState | rows |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L78 |
| row-action | state-minimum |  | present | viewState | resultSummary |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L79 |
| row-action | state-group |  | declared | interactionState |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L85 |
| row-action | state-minimum |  | present | interactionState | focusIntent |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L88 |
| row-action | state-minimum |  | present | interactionState | recordId |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L90 |
| row-action | state-minimum |  | present | interactionState | columnId |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L91 |
| row-action | state-group |  | declared | operationState |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L108 |
| row-action | state-minimum |  | present | operationState | row-operation-or-absence |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L121 |
| row-action | state-minimum |  | present | operationState | bulk-operation-or-absence |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L116 |
| row-action | lifecycle |  | present |  | ownerId | guard |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L135 |
| row-action | lifecycle |  | present |  | lifecycleToken | guard |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L136 |
| row-action | lifecycle |  | present |  | live/disposed | guard |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L137 |
| row-action | lifecycle |  | present |  | ownedResources | guard |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L138 |
| row-action | checklist |  | 第 1、2 节 |  |  |  | 能力与状态 |  |  |  |  |  |  |  | 适用 | 设计已定义；运行时未验证 | RAW OUTPUT:L345 |
| row-action | checklist |  | 第 3 节的快照与五项提交门禁 |  |  |  | 查询 |  |  |  |  |  |  |  | 适用 | 设计已定义；运行时未验证 | RAW OUTPUT:L346 |
| row-action | checklist |  | 无筛选 DOM；仅固定空 `appliedFilters`，无 `filterDraft`；无 handler；无筛选请求 |  |  |  | 筛选 |  |  |  |  |  |  |  | 不适用 | 零入口约束已定义 | RAW OUTPUT:L347 |
| row-action | checklist |  | 第 1、7 节的固定稳定排序、`aria-sort` 及无交互契约 |  |  |  | 排序 |  |  |  |  |  |  |  | 适用 | 设计已定义；运行时未验证 | RAW OUTPUT:L348 |
| row-action | checklist |  | 第 3 节的唯一 cursor 模式和固定 `pageSize=25` |  |  |  | 分页 |  |  |  |  |  |  |  | 适用 | 设计已定义；运行时未验证 | RAW OUTPUT:L349 |
| row-action | checklist |  | 第 3 节的加载、错误、过期和空状态 |  |  |  | 数据状态 |  |  |  |  |  |  |  | 适用 | 设计已定义；运行时未验证 | RAW OUTPUT:L350 |
| row-action | checklist |  | 无选择 DOM、状态槽、事件 handler 或请求 |  |  |  | 选择 |  |  |  |  |  |  |  | 不适用 | 零入口约束已定义 | RAW OUTPUT:L351 |
| row-action | checklist |  | 第 4、5 节 |  |  |  | 单行操作 |  |  |  |  |  |  |  | 适用 | 设计已定义；运行时未验证 | RAW OUTPUT:L352 |
| row-action | checklist |  | 无批量 DOM、状态槽、handler 或请求 |  |  |  | 批量操作 |  |  |  |  |  |  |  | 不适用 | 零入口约束已定义 | RAW OUTPUT:L353 |
| row-action | checklist |  | 第 2 节 `viewState` |  |  |  | 基础列状态 |  |  |  |  |  |  |  | 适用 | 设计已定义；运行时未验证 | RAW OUTPUT:L354 |
| row-action | checklist |  | 无列控制 DOM、偏好/拖拽状态、handler 或请求 |  |  |  | 可选列控制 |  |  |  |  |  |  |  | 不适用 | 零入口约束已定义 | RAW OUTPUT:L355 |
| row-action | checklist |  | 第 7 节 |  |  |  | Table 语义 |  |  |  |  |  |  |  | 适用 | 设计已定义；辅助技术未验证 | RAW OUTPUT:L356 |
| row-action | checklist |  | 无 `role="grid"`、活动单元格状态、Grid 键盘 handler 或请求 |  |  |  | ARIA Grid 语义 |  |  |  |  |  |  |  | 不适用 | 零入口约束已定义 | RAW OUTPUT:L357 |
| row-action | checklist |  | 第 4、6、7 节 |  |  |  | 键盘 |  |  |  |  |  |  |  | 适用 | 设计已定义；真实键盘未验证 | RAW OUTPUT:L358 |
| row-action | checklist |  | 第 6 节 |  |  |  | 焦点 |  |  |  |  |  |  |  | 适用 | 设计已定义；真实焦点事件未验证 | RAW OUTPUT:L359 |
| row-action | checklist |  | 第 8 节 |  |  |  | 响应式 |  |  |  |  |  |  |  | 适用 | 设计已定义；真实视口未验证 | RAW OUTPUT:L360 |
| row-action | checklist |  | 第 4、7 节 |  |  |  | ARIA 与公告 |  |  |  |  |  |  |  | 适用 | 设计已定义；读屏未验证 | RAW OUTPUT:L361 |
| row-action | checklist |  | 第 9 节 |  |  |  | disposal |  |  |  |  |  |  |  | 适用 | 设计已定义；真实卸载竞态未验证 | RAW OUTPUT:L362 |
| row-action | checklist |  | 第 9 节 |  |  |  | 实例隔离 |  |  |  |  |  |  |  | 适用 | 设计已定义；多实例运行时未验证 | RAW OUTPUT:L363 |
| row-action | checklist |  | 第 10 节列出的真实 API、浏览器、辅助技术、输入和视口环境 |  |  |  | 运行时验证边界 |  |  |  |  |  |  |  | 适用 | 未验证 | RAW OUTPUT:L364 |
| row-action | adjacent-semantic |  | present |  |  |  |  | sorting | actual-key-direction |  |  |  |  |  |  |  | RAW OUTPUT:L35 |
| row-action | adjacent-semantic |  | present |  |  |  |  | sorting | null-order |  |  |  |  |  |  |  | RAW OUTPUT:L35 |
| row-action | adjacent-semantic |  | present |  |  |  |  | sorting | case-rule |  |  |  |  |  |  |  | RAW OUTPUT:L38 |
| row-action | adjacent-semantic |  | present |  |  |  |  | sorting | locale-rule |  |  |  |  |  |  |  | RAW OUTPUT:L38 |
| row-action | adjacent-semantic |  | present |  |  |  |  | sorting | natural-order-rule |  |  |  |  |  |  |  | RAW OUTPUT:L38 |
| row-action | adjacent-semantic |  | present |  |  |  |  | sorting | unique-stable-key |  |  |  |  |  |  |  | RAW OUTPUT:L36 |
| row-action | adjacent-semantic |  | present |  |  |  |  | pagination-cursor | opaque-bidirectional-cursors |  |  |  |  |  |  |  | RAW OUTPUT:L28 |
| row-action | adjacent-semantic |  | present |  |  |  |  | pagination-cursor | missing-direction-disabled |  |  |  |  |  |  |  | RAW OUTPUT:L173 |
| row-action | adjacent-semantic |  | present |  |  |  |  | pagination-cursor | forbidden-numbered-and-stream-entries |  |  |  |  |  |  |  | RAW OUTPUT:L173 |
| row-action | adjacent-semantic |  | present |  |  |  |  | pagination-cursor | origin-and-single-recovery |  |  |  |  |  |  |  | RAW OUTPUT:L170 |
| row-action | adjacent-semantic |  | present |  |  |  |  | pagination-cursor | input-semantics |  |  |  |  |  |  |  | RAW OUTPUT:L173 |
| row-action | adjacent-semantic |  | present |  |  |  |  | pagination-cursor | single-focus-transition |  |  |  |  |  |  |  | RAW OUTPUT:L250 |
| bulk-action | capability | capabilityTier | `bulk-action` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L9 |
| bulk-action | capability | resolvedTier | `bulk-action`；权限降级时可变为 `row-action` 或 `display` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L10 |
| bulk-action | capability | filteringEnabled | `true`，显式应用 |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L11 |
| bulk-action | capability | sortingEnabled | `true`，单列业务排序 |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L12 |
| bulk-action | capability | paginationMode | `numbered` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L13 |
| bulk-action | capability | pageSize | `25` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L14 |
| bulk-action | capability | pageSelectionEnabled | `true` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L15 |
| bulk-action | capability | allFilteredSelectionEnabled | `true`，但必须满足下述服务端前提；否则整个能力关闭 |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L16 |
| bulk-action | capability | rowOperationEnabled | `false` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L17 |
| bulk-action | capability | bulkOperationEnabled | `true` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L18 |
| bulk-action | capability | columnVisibilityEnabled | `false` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L19 |
| bulk-action | capability | columnPinningEnabled | `false` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L20 |
| bulk-action | capability | columnResizeEnabled | `false` |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L21 |
| bulk-action | capability | responsivePresentation | 保持原生 Table，以受控横向滚动适配窄屏，不转换为卡片 |  |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L22 |
| bulk-action | state-group |  | declared | queryState |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L42 |
| bulk-action | state-minimum |  | present | queryState | appliedFilters |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L47 |
| bulk-action | state-minimum |  | present | queryState | sortRules |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L48 |
| bulk-action | state-minimum |  | present | queryState | pagination |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L49 |
| bulk-action | state-minimum |  | present | queryState | pageSize |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L50 |
| bulk-action | state-minimum |  | present | queryState | querySnapshot |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L51 |
| bulk-action | state-minimum |  | present | queryState | snapshotId |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L52 |
| bulk-action | state-minimum |  | present | queryState | datasetVersion |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L53 |
| bulk-action | state-minimum |  | present | queryState | requestGeneration |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L54 |
| bulk-action | state-minimum |  | present | queryState | requestPhase |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L55 |
| bulk-action | state-minimum |  | present | queryState | queryError |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L56 |
| bulk-action | state-minimum |  | present | queryState | stale |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L57 |
| bulk-action | state-group |  | declared | viewState |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L85 |
| bulk-action | state-minimum |  | present | viewState | visibleColumnIds |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L90 |
| bulk-action | state-minimum |  | present | viewState | pinnedColumnIds |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L91 |
| bulk-action | state-minimum |  | present | viewState | columnWidths |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L92 |
| bulk-action | state-minimum |  | present | viewState | density |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L93 |
| bulk-action | state-minimum |  | present | viewState | rows |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L94 |
| bulk-action | state-minimum |  | present | viewState | resultSummary |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L95 |
| bulk-action | state-group |  | declared | interactionState |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L100 |
| bulk-action | state-minimum |  | present | interactionState | focusIntent |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L105 |
| bulk-action | state-minimum |  | present | interactionState | recordId |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L106 |
| bulk-action | state-minimum |  | present | interactionState | columnId |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L107 |
| bulk-action | state-group |  | declared | operationState |  |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L133 |
| bulk-action | state-minimum |  | present | operationState | bulk-operation-or-absence |  |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L141 |
| bulk-action | lifecycle |  | present |  | ownerId | guard |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L172 |
| bulk-action | lifecycle |  | present |  | lifecycleToken | guard |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L173 |
| bulk-action | lifecycle |  | present |  | live/disposed | guard |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L174 |
| bulk-action | lifecycle |  | present |  | ownedResources | guard |  |  |  |  |  |  |  |  |  |  | RAW OUTPUT:L175 |
| bulk-action | checklist |  | 第 1、2 节 |  |  |  | 能力与状态 |  |  |  |  |  |  |  | 适用 | 静态设计已定义；运行时未验证 | RAW OUTPUT:L420 |
| bulk-action | checklist |  | `querySnapshot` 与五项响应门禁 |  |  |  | 查询 |  |  |  |  |  |  |  | 适用 | 静态设计已定义；运行时未验证 | RAW OUTPUT:L421 |
| bulk-action | checklist |  | 草稿/已应用值分离、显式应用、筛选变化矩阵 |  |  |  | 筛选 |  |  |  |  |  |  |  | 适用 | 静态设计已定义；运行时未验证 | RAW OUTPUT:L422 |
| bulk-action | checklist |  | 固定完整排序、分页复位、全部范围重新确认 |  |  |  | 排序 |  |  |  |  |  |  |  | 适用 | 静态设计已定义；运行时未验证 | RAW OUTPUT:L423 |
| bulk-action | checklist |  | 唯一 numbered 模式、pageSize 25、边界与焦点策略 |  |  |  | 分页 |  |  |  |  |  |  |  | 适用 | 静态设计已定义；运行时未验证 | RAW OUTPUT:L424 |
| bulk-action | checklist |  | 第 5 节 |  |  |  | 数据状态 |  |  |  |  |  |  |  | 适用 | 静态设计已定义；运行时未验证 | RAW OUTPUT:L425 |
| bulk-action | checklist |  | 第 3 节及唯一选择代次契约表 |  |  |  | 选择 |  |  |  |  |  |  |  | 适用 | 静态设计已定义；运行时未验证 | RAW OUTPUT:L426 |
| bulk-action | checklist |  | 不渲染 DOM；不建立状态槽、handler、事件或请求入口 |  |  |  | 单行操作 |  |  |  |  |  |  |  | 不适用 | 配置边界待实现核验 | RAW OUTPUT:L427 |
| bulk-action | checklist |  | 第 4 节 |  |  |  | 批量操作 |  |  |  |  |  |  |  | 适用 | 静态设计已定义；运行时未验证 | RAW OUTPUT:L428 |
| bulk-action | checklist |  | `viewState` 固定字段 |  |  |  | 基础列状态 |  |  |  |  |  |  |  | 适用 | 静态设计已定义；运行时未验证 | RAW OUTPUT:L429 |
| bulk-action | checklist |  | 显示、固定、调宽入口及对应状态写入、handler、请求均为 0 |  |  |  | 可选列控制 |  |  |  |  |  |  |  | 不适用 | 配置边界待实现核验 | RAW OUTPUT:L430 |
| bulk-action | checklist |  | 原生 `<table>`、caption、`th` 关联 |  |  |  | Table 语义 |  |  |  |  |  |  |  | 适用 | 静态设计已定义；运行时未验证 | RAW OUTPUT:L431 |
| bulk-action | checklist |  | 不渲染 `role=grid`，无 roving tabindex 或 Grid 键盘 handler |  |  |  | ARIA Grid 语义 |  |  |  |  |  |  |  | 不适用 | DOM 边界待实现核验 | RAW OUTPUT:L432 |
| bulk-action | checklist |  | 第 6 节 |  |  |  | 键盘 |  |  |  |  |  |  |  | 适用 | 运行时未验证 | RAW OUTPUT:L433 |
| bulk-action | checklist |  | 稳定 ID 焦点意图及一次迁移规则 |  |  |  | 焦点 |  |  |  |  |  |  |  | 适用 | 运行时未验证 | RAW OUTPUT:L434 |
| bulk-action | checklist |  | 第 7 节 |  |  |  | 响应式 |  |  |  |  |  |  |  | 适用 | 运行时未验证 | RAW OUTPUT:L435 |
| bulk-action | checklist |  | 第 6 节唯一 owner 与公告去重 |  |  |  | ARIA 与公告 |  |  |  |  |  |  |  | 适用 | 辅助技术未验证 | RAW OUTPUT:L436 |
| bulk-action | checklist |  | 第 8 节 |  |  |  | disposal |  |  |  |  |  |  |  | 适用 | 运行时未验证 | RAW OUTPUT:L437 |
| bulk-action | checklist |  | `ownerId + lifecycleToken` 命名空间及资源归属 |  |  |  | 实例隔离 |  |  |  |  |  |  |  | 适用 | 运行时未验证 | RAW OUTPUT:L438 |
| bulk-action | checklist |  | 第 9 节所列浏览器、设备、辅助技术与真实服务端场景 |  |  |  | 运行时验证边界 |  |  |  |  |  |  |  | 适用 | 未验证 | RAW OUTPUT:L439 |
| bulk-action | adjacent-semantic |  | missing |  |  |  |  | filtering | draft-applied-separation |  |  |  |  |  |  |  |  |
| bulk-action | adjacent-semantic |  | present |  |  |  |  | filtering | declared-apply-mode |  |  |  |  |  |  |  | RAW OUTPUT:L11 |
| bulk-action | adjacent-semantic |  | missing |  |  |  |  | filtering | default-reset |  |  |  |  |  |  |  |  |
| bulk-action | adjacent-semantic |  | present |  |  |  |  | filtering | visible-removable-applied-values |  |  |  |  |  |  |  | RAW OUTPUT:L366 |
| bulk-action | adjacent-semantic |  | missing |  |  |  |  | filtering | url-safety |  |  |  |  |  |  |  |  |
| bulk-action | adjacent-semantic |  | missing |  |  |  |  | filtering | field-error-owner |  |  |  |  |  |  |  |  |
| bulk-action | adjacent-semantic |  | missing |  |  |  |  | filtering | pagination-reset |  |  |  |  |  |  |  |  |
| bulk-action | adjacent-semantic |  | present |  |  |  |  | sorting | actual-key-direction |  |  |  |  |  |  |  | RAW OUTPUT:L24 |
| bulk-action | adjacent-semantic |  | present |  |  |  |  | sorting | null-order |  |  |  |  |  |  |  | RAW OUTPUT:L24 |
| bulk-action | adjacent-semantic |  | present |  |  |  |  | sorting | case-rule |  |  |  |  |  |  |  | RAW OUTPUT:L24 |
| bulk-action | adjacent-semantic |  | present |  |  |  |  | sorting | locale-rule |  |  |  |  |  |  |  | RAW OUTPUT:L24 |
| bulk-action | adjacent-semantic |  | missing |  |  |  |  | sorting | natural-order-rule |  |  |  |  |  |  |  |  |
| bulk-action | adjacent-semantic |  | present |  |  |  |  | sorting | unique-stable-key |  |  |  |  |  |  |  | RAW OUTPUT:L24 |
| bulk-action | adjacent-semantic |  | present |  |  |  |  | sorting | interactive-dom |  |  |  |  |  |  |  | RAW OUTPUT:L335 |
| bulk-action | adjacent-semantic |  | missing |  |  |  |  | sorting | interactive-aria |  |  |  |  |  |  |  |  |
| bulk-action | adjacent-semantic |  | missing |  |  |  |  | sorting | interactive-keyboard |  |  |  |  |  |  |  |  |
| bulk-action | adjacent-semantic |  | present |  |  |  |  | sorting | interactive-focus |  |  |  |  |  |  |  | RAW OUTPUT:L355 |
| bulk-action | adjacent-semantic |  | missing |  |  |  |  | sorting | reset-to-origin |  |  |  |  |  |  |  |  |
| bulk-action | adjacent-semantic |  | missing |  |  |  |  | pagination-numbered | reliable-total-and-range |  |  |  |  |  |  |  |  |
| bulk-action | adjacent-semantic |  | missing |  |  |  |  | pagination-numbered | direct-pages |  |  |  |  |  |  |  |  |
| bulk-action | adjacent-semantic |  | missing |  |  |  |  | pagination-numbered | validated-jump |  |  |  |  |  |  |  |  |
| bulk-action | adjacent-semantic |  | missing |  |  |  |  | pagination-numbered | native-boundaries |  |  |  |  |  |  |  |  |
| bulk-action | adjacent-semantic |  | missing |  |  |  |  | pagination-numbered | page-size-control |  |  |  |  |  |  |  |  |
| bulk-action | adjacent-semantic |  | missing |  |  |  |  | pagination-numbered | reset-to-first |  |  |  |  |  |  |  |  |
| bulk-action | adjacent-semantic |  | missing |  |  |  |  | pagination-numbered | single-invalid-page-recovery |  |  |  |  |  |  |  |  |
| bulk-action | adjacent-semantic |  | missing |  |  |  |  | pagination-numbered | input-semantics |  |  |  |  |  |  |  |  |
| bulk-action | adjacent-semantic |  | present |  |  |  |  | pagination-numbered | single-focus-transition |  |  |  |  |  |  |  | RAW OUTPUT:L356 |
| bulk-action | selection-contract |  |  |  |  |  |  |  |  | 资格变化 | `selectionGeneration +1` | 创建新的不可变后继 `selectionSnapshot`；旧快照写入为 0 | 当前 live owner、范围键、权限范围和数据版本均仍适用 | 失效结果不得提交，旧快照和当前选择写入均为 0 |  |  | RAW OUTPUT:L247 |
| bulk-action | selection-contract |  |  |  |  |  |  |  |  | 异步选择协调回调 | 不自行改变；仅提交创建时捕获的代次结果 | 只有匹配结果可成为当前快照 | `live + ownerId + lifecycleToken + selectionGeneration` 全部匹配 | 只记录 `selection-result-discarded`，选择写入为 0 |  |  | RAW OUTPUT:L248 |
| bulk-action | selection-contract |  |  |  |  |  |  |  |  | 操作结果调整当前选择 | 仅在捕获代次等于当前代次时按意图递增 | 匹配时创建移除成功项后的后继状态，不原地修改操作快照 | 捕获的 `selectionGeneration === 当前 selectionGeneration` | 只写 operation result owner；选择写入为 0 |  |  | RAW OUTPUT:L249 |
RECORD_COUNT display=91
RECORD_COUNT row-action=76
RECORD_COUNT bulk-action=93
AUDIT_STATUS FAIL errors=19
AUDIT_ERROR operationState.row-operation-or-absence: missing minimum field
AUDIT_ERROR checklist ARIA Grid 语义: N/A zero evidence missing request
AUDIT_ERROR filtering.draft-applied-separation: semantic evidence missing
AUDIT_ERROR filtering.default-reset: semantic evidence missing
AUDIT_ERROR filtering.url-safety: semantic evidence missing
AUDIT_ERROR filtering.field-error-owner: semantic evidence missing
AUDIT_ERROR filtering.pagination-reset: semantic evidence missing
AUDIT_ERROR sorting.natural-order-rule: semantic evidence missing
AUDIT_ERROR sorting.interactive-aria: semantic evidence missing
AUDIT_ERROR sorting.interactive-keyboard: semantic evidence missing
AUDIT_ERROR sorting.reset-to-origin: semantic evidence missing
AUDIT_ERROR pagination-numbered.reliable-total-and-range: semantic evidence missing
AUDIT_ERROR pagination-numbered.direct-pages: semantic evidence missing
AUDIT_ERROR pagination-numbered.validated-jump: semantic evidence missing
AUDIT_ERROR pagination-numbered.native-boundaries: semantic evidence missing
AUDIT_ERROR pagination-numbered.page-size-control: semantic evidence missing
AUDIT_ERROR pagination-numbered.reset-to-first: semantic evidence missing
AUDIT_ERROR pagination-numbered.single-invalid-page-recovery: semantic evidence missing
AUDIT_ERROR pagination-numbered.input-semantics: semantic evidence missing
