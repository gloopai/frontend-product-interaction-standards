# Attempt 6 字段级应用审计账本

状态：`PASS`

生成命令：

```sh
ruby docs/testing/data-tables/attempt-6-application-audit.rb --records
```

下表逐条保存 A38/A39 应用记录。`outputLocation` 是对应冻结 RAW OUTPUT 内的 1-based 行号；空列表示该记录类型不使用该字段，而不是未审计。

| scenario | recordKind | capabilityKey | currentValue | stateGroup | minimumField | lifecycleRole | checklistRow | applicability | verificationStatus | outputLocation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| display | capability | capabilityTier | `display` |  |  |  |  |  |  | RAW OUTPUT:L9 |
| display | capability | resolvedTier | `display` |  |  |  |  |  |  | RAW OUTPUT:L10 |
| display | capability | filteringEnabled | `true` |  |  |  |  |  |  | RAW OUTPUT:L11 |
| display | capability | sortingEnabled | `true`，单列交互排序 |  |  |  |  |  |  | RAW OUTPUT:L12 |
| display | capability | paginationMode | `numbered` |  |  |  |  |  |  | RAW OUTPUT:L13 |
| display | capability | pageSize | `25`，可选 `25 / 50 / 100` |  |  |  |  |  |  | RAW OUTPUT:L14 |
| display | capability | pageSelectionEnabled | `false` |  |  |  |  |  |  | RAW OUTPUT:L15 |
| display | capability | allFilteredSelectionEnabled | `false` |  |  |  |  |  |  | RAW OUTPUT:L16 |
| display | capability | rowOperationEnabled | `false` |  |  |  |  |  |  | RAW OUTPUT:L17 |
| display | capability | bulkOperationEnabled | `false` |  |  |  |  |  |  | RAW OUTPUT:L18 |
| display | capability | columnVisibilityEnabled | `false` |  |  |  |  |  |  | RAW OUTPUT:L19 |
| display | capability | columnPinningEnabled | `false` |  |  |  |  |  |  | RAW OUTPUT:L20 |
| display | capability | columnResizeEnabled | `false` |  |  |  |  |  |  | RAW OUTPUT:L21 |
| display | capability | responsivePresentation | `table-to-cards` |  |  |  |  |  |  | RAW OUTPUT:L22 |
| display | state-group |  | declared | queryState |  |  |  |  |  | RAW OUTPUT:L137 |
| display | state-minimum |  | present | queryState | appliedFilters |  |  |  |  | RAW OUTPUT:L144 |
| display | state-minimum |  | present | queryState | sortRules |  |  |  |  | RAW OUTPUT:L145 |
| display | state-minimum |  | present | queryState | pagination |  |  |  |  | RAW OUTPUT:L146 |
| display | state-minimum |  | present | queryState | pageSize |  |  |  |  | RAW OUTPUT:L147 |
| display | state-minimum |  | present | queryState | querySnapshot |  |  |  |  | RAW OUTPUT:L148 |
| display | state-minimum |  | present | queryState | snapshotId |  |  |  |  | RAW OUTPUT:L149 |
| display | state-minimum |  | present | queryState | datasetVersion |  |  |  |  | RAW OUTPUT:L150 |
| display | state-minimum |  | present | queryState | requestGeneration |  |  |  |  | RAW OUTPUT:L151 |
| display | state-minimum |  | present | queryState | requestPhase |  |  |  |  | RAW OUTPUT:L152 |
| display | state-minimum |  | present | queryState | queryError |  |  |  |  | RAW OUTPUT:L153 |
| display | state-minimum |  | present | queryState | stale |  |  |  |  | RAW OUTPUT:L154 |
| display | state-group |  | declared | viewState |  |  |  |  |  | RAW OUTPUT:L193 |
| display | state-minimum |  | present | viewState | visibleColumnIds |  |  |  |  | RAW OUTPUT:L198 |
| display | state-minimum |  | present | viewState | pinnedColumnIds |  |  |  |  | RAW OUTPUT:L199 |
| display | state-minimum |  | present | viewState | columnWidths |  |  |  |  | RAW OUTPUT:L200 |
| display | state-minimum |  | present | viewState | density |  |  |  |  | RAW OUTPUT:L201 |
| display | state-minimum |  | present | viewState | rows |  |  |  |  | RAW OUTPUT:L202 |
| display | state-minimum |  | present | viewState | resultSummary |  |  |  |  | RAW OUTPUT:L203 |
| display | state-group |  | declared | interactionState |  |  |  |  |  | RAW OUTPUT:L209 |
| display | state-minimum |  | present | interactionState | focusIntent |  |  |  |  | RAW OUTPUT:L214 |
| display | state-minimum |  | present | interactionState | recordId |  |  |  |  | RAW OUTPUT:L215 |
| display | state-minimum |  | present | interactionState | columnId |  |  |  |  | RAW OUTPUT:L216 |
| display | state-group |  | declared | operationState |  |  |  |  |  | RAW OUTPUT:L223 |
| display | state-minimum |  | present | operationState | row-operation-or-absence |  |  |  |  | RAW OUTPUT:L225 |
| display | state-minimum |  | present | operationState | bulk-operation-or-absence |  |  |  |  | RAW OUTPUT:L225 |
| display | lifecycle |  | present |  | ownerId | guard |  |  |  | RAW OUTPUT:L232 |
| display | lifecycle |  | present |  | lifecycleToken | guard |  |  |  | RAW OUTPUT:L233 |
| display | lifecycle |  | present |  | live/disposed | guard |  |  |  | RAW OUTPUT:L234 |
| display | lifecycle |  | present |  | ownedResources | guard |  |  |  | RAW OUTPUT:L235 |
| display | checklist |  | `display` 档位、十二项能力当前值和固定四组状态已声明 1、5 |  |  |  | 能力与状态 | 适用 | 未验证 | RAW OUTPUT:L389 |
| display | checklist |  | 不可变快照、请求代次及五项响应门禁已定义 5、6 |  |  |  | 查询 | 适用 | 未验证 | RAW OUTPUT:L390 |
| display | checklist |  | 草稿/已应用值、提交模式、默认重置、分页复位、摘要移除、URL 安全和字段错误 owner 均已定义 4.1 |  |  |  | 筛选 | 适用 | 未验证 | RAW OUTPUT:L391 |
| display | checklist |  | 当前业务键、方向、空值、大小写、locale、自然排序和唯一稳定键已定义 4.2 |  |  |  | 排序 | 适用 | 未验证 | RAW OUTPUT:L392 |
| display | checklist |  | 唯一 `numbered` 模式、可靠总数、直接页码、校验跳页、边界禁用、页大小和单次恢复已定义 4.3 |  |  |  | 分页 | 适用 | 未验证 | RAW OUTPUT:L393 |
| display | checklist |  | 首次加载、刷新、初错、刷新错、过期和两类空状态已定义 7 |  |  |  | 数据状态 | 适用 | 未验证 | RAW OUTPUT:L394 |
| display | checklist |  | 选择 DOM=0；选择子状态=0；选择 handler/事件=0；选择请求=0 2、5 |  |  |  | 选择 | 不适用 | 未验证 | RAW OUTPUT:L395 |
| display | checklist |  | 单行操作 DOM=0；操作子状态=0；操作 handler/事件=0；操作请求=0 2、5 |  |  |  | 单行操作 | 不适用 | 未验证 | RAW OUTPUT:L396 |
| display | checklist |  | 批量 DOM=0；批量状态=0；批量 handler/事件=0；批量请求=0 2、5 |  |  |  | 批量操作 | 不适用 | 未验证 | RAW OUTPUT:L397 |
| display | checklist |  | 稳定列 ID、可见列、空固定列、静态宽度、密度和当前结果均已定义 3、5 |  |  |  | 基础列状态 | 适用 | 未验证 | RAW OUTPUT:L398 |
| display | checklist |  | 列控制 DOM=0；可选控制子状态=0；调整/固定/显示 handler=0；相关请求=0 1、2、5 |  |  |  | 可选列控制 | 不适用 | 未验证 | RAW OUTPUT:L399 |
| display | checklist |  | 原生 Table、caption、scope、排序表头和静态单元格规则已定义 9 |  |  |  | Table 语义 | 适用 | 未验证 | RAW OUTPUT:L400 |
| display | checklist |  | `role=grid` DOM=0；活动单元格状态=0；Grid 键盘 handler=0；相关请求=0 2、8 |  |  |  | ARIA Grid 语义 | 不适用 | 未验证 | RAW OUTPUT:L401 |
| display | checklist |  | 筛选、排序、翻页、展开和错误恢复的键盘路径已定义 8 |  |  |  | 键盘 | 适用 | 未验证 | RAW OUTPUT:L402 |
| display | checklist |  | 稳定 ID 恢复、分页焦点、目标消失回退和响应式迁移已定义 8 |  |  |  | 焦点 | 适用 | 未验证 | RAW OUTPUT:L403 |
| display | checklist |  | 表格/卡片等价、200% 回流、长内容、移动端和安全区域已定义 3、10 |  |  |  | 响应式 | 适用 | 未验证 | RAW OUTPUT:L404 |
| display | checklist |  | 名称、状态、结果 owner、单次公告和错误归属已定义 9 |  |  |  | ARIA 与公告 | 适用 | 未验证 | RAW OUTPUT:L405 |
| display | checklist |  | 同步幂等处置、资源失效、迟到回调门禁已定义 11 |  |  |  | disposal | 适用 | 未验证 | RAW OUTPUT:L406 |
| display | checklist |  | owner、token、公告 owner 和资源释放均按实例隔离 5、11 |  |  |  | 实例隔离 | 适用 | 未验证 | RAW OUTPUT:L407 |
| display | checklist |  | 已逐项列明浏览器、设备、辅助技术、竞态和 API 环境缺口 12 |  |  |  | 运行时验证边界 | 适用 | 未验证 | RAW OUTPUT:L408 |
| row-action | capability | capabilityTier | `row-action` |  |  |  |  |  |  | RAW OUTPUT:L9 |
| row-action | capability | resolvedTier | `row-action`；操作权限全部撤销后降为 `display` |  |  |  |  |  |  | RAW OUTPUT:L10 |
| row-action | capability | filteringEnabled | `false` |  |  |  |  |  |  | RAW OUTPUT:L11 |
| row-action | capability | sortingEnabled | `false`，无交互排序，使用服务端固定稳定排序 |  |  |  |  |  |  | RAW OUTPUT:L12 |
| row-action | capability | paginationMode | `cursor` |  |  |  |  |  |  | RAW OUTPUT:L13 |
| row-action | capability | pageSize | `20`，固定，无页大小选择器 |  |  |  |  |  |  | RAW OUTPUT:L14 |
| row-action | capability | pageSelectionEnabled | `false` |  |  |  |  |  |  | RAW OUTPUT:L15 |
| row-action | capability | allFilteredSelectionEnabled | `false` |  |  |  |  |  |  | RAW OUTPUT:L16 |
| row-action | capability | rowOperationEnabled | `true` |  |  |  |  |  |  | RAW OUTPUT:L17 |
| row-action | capability | bulkOperationEnabled | `false` |  |  |  |  |  |  | RAW OUTPUT:L18 |
| row-action | capability | columnVisibilityEnabled | `false` |  |  |  |  |  |  | RAW OUTPUT:L19 |
| row-action | capability | columnPinningEnabled | `false` |  |  |  |  |  |  | RAW OUTPUT:L20 |
| row-action | capability | columnResizeEnabled | `false` |  |  |  |  |  |  | RAW OUTPUT:L21 |
| row-action | capability | responsivePresentation | `table-card`；列表容器小于 720 CSS px 时使用经评审的卡片映射 |  |  |  |  |  |  | RAW OUTPUT:L22 |
| row-action | state-group |  | declared | queryState |  |  |  |  |  | RAW OUTPUT:L47 |
| row-action | state-minimum |  | present | queryState | appliedFilters |  |  |  |  | RAW OUTPUT:L52 |
| row-action | state-minimum |  | present | queryState | sortRules |  |  |  |  | RAW OUTPUT:L53 |
| row-action | state-minimum |  | present | queryState | pagination |  |  |  |  | RAW OUTPUT:L54 |
| row-action | state-minimum |  | present | queryState | pageSize |  |  |  |  | RAW OUTPUT:L61 |
| row-action | state-minimum |  | present | queryState | querySnapshot |  |  |  |  | RAW OUTPUT:L62 |
| row-action | state-minimum |  | present | queryState | snapshotId |  |  |  |  | RAW OUTPUT:L63 |
| row-action | state-minimum |  | present | queryState | datasetVersion |  |  |  |  | RAW OUTPUT:L64 |
| row-action | state-minimum |  | present | queryState | requestGeneration |  |  |  |  | RAW OUTPUT:L65 |
| row-action | state-minimum |  | present | queryState | requestPhase |  |  |  |  | RAW OUTPUT:L66 |
| row-action | state-minimum |  | present | queryState | queryError |  |  |  |  | RAW OUTPUT:L67 |
| row-action | state-minimum |  | present | queryState | stale |  |  |  |  | RAW OUTPUT:L68 |
| row-action | state-group |  | declared | viewState |  |  |  |  |  | RAW OUTPUT:L93 |
| row-action | state-minimum |  | present | viewState | visibleColumnIds |  |  |  |  | RAW OUTPUT:L98 |
| row-action | state-minimum |  | present | viewState | pinnedColumnIds |  |  |  |  | RAW OUTPUT:L101 |
| row-action | state-minimum |  | present | viewState | columnWidths |  |  |  |  | RAW OUTPUT:L102 |
| row-action | state-minimum |  | present | viewState | density |  |  |  |  | RAW OUTPUT:L103 |
| row-action | state-minimum |  | present | viewState | rows |  |  |  |  | RAW OUTPUT:L104 |
| row-action | state-minimum |  | present | viewState | resultSummary |  |  |  |  | RAW OUTPUT:L105 |
| row-action | state-group |  | declared | interactionState |  |  |  |  |  | RAW OUTPUT:L111 |
| row-action | state-minimum |  | present | interactionState | focusIntent |  |  |  |  | RAW OUTPUT:L116 |
| row-action | state-minimum |  | present | interactionState | recordId |  |  |  |  | RAW OUTPUT:L118 |
| row-action | state-minimum |  | present | interactionState | columnId |  |  |  |  | RAW OUTPUT:L119 |
| row-action | state-group |  | declared | operationState |  |  |  |  |  | RAW OUTPUT:L137 |
| row-action | state-minimum |  | present | operationState | row-operation-or-absence |  |  |  |  | RAW OUTPUT:L139 |
| row-action | state-minimum |  | present | operationState | bulk-operation-or-absence |  |  |  |  | RAW OUTPUT:L143 |
| row-action | lifecycle |  | present |  | ownerId | guard |  |  |  | RAW OUTPUT:L175 |
| row-action | lifecycle |  | present |  | lifecycleToken | guard |  |  |  | RAW OUTPUT:L176 |
| row-action | lifecycle |  | present |  | live/disposed | guard |  |  |  | RAW OUTPUT:L177 |
| row-action | lifecycle |  | present |  | ownedResources | guard |  |  |  | RAW OUTPUT:L179 |
| row-action | checklist |  | 第 1、2 节；十二项当前能力值、固定四组状态及独立 lifecycle guard |  |  |  | 能力与状态 | 适用 | 设计覆盖；运行未验证 | RAW OUTPUT:L449 |
| row-action | checklist |  | 第 3、4 节；不可变快照、代次、五项提交门禁和同意图合并 |  |  |  | 查询 | 适用 | 设计覆盖；竞态未验证 | RAW OUTPUT:L450 |
| row-action | checklist |  | DOM 筛选控件=0；`filterDraft` 状态槽=0；筛选 handler=0；筛选触发请求=0；`appliedFilters` 仅固定为空对象 |  |  |  | 筛选 | 不适用 | 配置已声明；零入口待运行确认 | RAW OUTPUT:L451 |
| row-action | checklist |  | 第 2、3、9 节；固定 `updatedAt DESC NULLS LAST, recordId ASC`，无伪排序按钮 |  |  |  | 排序 | 适用 | 设计覆盖；服务端顺序未验证 | RAW OUTPUT:L452 |
| row-action | checklist |  | 第 3、4 节；固定 pageSize 20、不透明双向游标、边界禁用和单次恢复 |  |  |  | 分页 | 适用 | 设计覆盖；接口未验证 | RAW OUTPUT:L453 |
| row-action | checklist |  | 第 4、5 节；首次加载、刷新、过期、失败和空数据集 |  |  |  | 数据状态 | 适用 | 设计覆盖；运行未验证 | RAW OUTPUT:L454 |
| row-action | checklist |  | 选择 DOM=0；选择状态槽=0；选择 handler/事件=0；选择请求=0 |  |  |  | 选择 | 不适用 | 配置已声明；零入口待运行确认 | RAW OUTPUT:L455 |
| row-action | checklist |  | 第 6、7 节；菜单、操作快照、重复提交保护、错误与冲突恢复 |  |  |  | 单行操作 | 适用 | 设计覆盖；运行未验证 | RAW OUTPUT:L456 |
| row-action | checklist |  | 批量 DOM=0；批量状态槽=0；批量 handler/事件=0；批量请求=0 |  |  |  | 批量操作 | 不适用 | 配置已声明；零入口待运行确认 | RAW OUTPUT:L457 |
| row-action | checklist |  | 第 2 节；稳定 columnId、固定可见列、宽度与密度状态 |  |  |  | 基础列状态 | 适用 | 设计覆盖；渲染未验证 | RAW OUTPUT:L458 |
| row-action | checklist |  | 列控制 DOM=0；控制会话状态=0；显示/固定/调宽 handler=0；相关请求=0 |  |  |  | 可选列控制 | 不适用 | 配置已声明；零入口待运行确认 | RAW OUTPUT:L459 |
| row-action | checklist |  | 第 9 节；原生 table、行列 header 关联和真实控件 Tab 顺序 |  |  |  | Table 语义 | 适用 | 设计覆盖；可访问性树未验证 | RAW OUTPUT:L460 |
| row-action | checklist |  | `role=grid` DOM=0；Grid 导航状态=0；Grid 键盘 handler=0；Grid 请求=0 |  |  |  | ARIA Grid 语义 | 不适用 | 配置已声明；零入口待运行确认 | RAW OUTPUT:L461 |
| row-action | checklist |  | 第 6、8、9 节；菜单、详情、重试和分页完整键盘路径 |  |  |  | 键盘 | 适用 | 设计覆盖；真实键盘未验证 | RAW OUTPUT:L462 |
| row-action | checklist |  | 第 7、8 节；稳定 ID、一次迁移、记录级回退和路由边界 |  |  |  | 焦点 | 适用 | 设计覆盖；浏览器焦点未验证 | RAW OUTPUT:L463 |
| row-action | checklist |  | 第 10 节；显式 Table/卡片映射、单 owner 和跨端能力等价 |  |  |  | 响应式 | 适用 | 设计覆盖；真实视口未验证 | RAW OUTPUT:L464 |
| row-action | checklist |  | 第 6、9 节；名称、状态、busy/stale 与单一公告 owner |  |  |  | ARIA 与公告 | 适用 | 设计覆盖；屏幕阅读器未验证 | RAW OUTPUT:L465 |
| row-action | checklist |  | 第 11 节；立即幂等处置、迟到回调门禁及逐资源释放 |  |  |  | disposal | 适用 | 设计覆盖；卸载竞态未验证 | RAW OUTPUT:L466 |
| row-action | checklist |  | 第 2、11 节；owner/token/announcement 命名空间和资源隔离 |  |  |  | 实例隔离 | 适用 | 设计覆盖；双实例未验证 | RAW OUTPUT:L467 |
| row-action | checklist |  | 第 12 节；列明浏览器、辅助技术、输入、视口、API 和竞态环境 |  |  |  | 运行时验证边界 | 适用 | 未验证 | RAW OUTPUT:L468 |
| bulk-action | capability | capabilityTier | `bulk-action` |  |  |  |  |  |  | RAW OUTPUT:L9 |
| bulk-action | capability | resolvedTier | `bulk-action`，以当前权限解析结果为准 |  |  |  |  |  |  | RAW OUTPUT:L10 |
| bulk-action | capability | filteringEnabled | `true` |  |  |  |  |  |  | RAW OUTPUT:L11 |
| bulk-action | capability | sortingEnabled | `true`，单列交互排序 |  |  |  |  |  |  | RAW OUTPUT:L12 |
| bulk-action | capability | paginationMode | `numbered` |  |  |  |  |  |  | RAW OUTPUT:L13 |
| bulk-action | capability | pageSize | `25` |  |  |  |  |  |  | RAW OUTPUT:L14 |
| bulk-action | capability | pageSelectionEnabled | `true` |  |  |  |  |  |  | RAW OUTPUT:L15 |
| bulk-action | capability | allFilteredSelectionEnabled | `true` |  |  |  |  |  |  | RAW OUTPUT:L16 |
| bulk-action | capability | rowOperationEnabled | `false` |  |  |  |  |  |  | RAW OUTPUT:L17 |
| bulk-action | capability | bulkOperationEnabled | `true` |  |  |  |  |  |  | RAW OUTPUT:L18 |
| bulk-action | capability | columnVisibilityEnabled | `false` |  |  |  |  |  |  | RAW OUTPUT:L19 |
| bulk-action | capability | columnPinningEnabled | `false` |  |  |  |  |  |  | RAW OUTPUT:L20 |
| bulk-action | capability | columnResizeEnabled | `false` |  |  |  |  |  |  | RAW OUTPUT:L21 |
| bulk-action | capability | responsivePresentation | `table-card` |  |  |  |  |  |  | RAW OUTPUT:L22 |
| bulk-action | state-group |  | declared | queryState |  |  |  |  |  | RAW OUTPUT:L75 |
| bulk-action | state-minimum |  | present | queryState | appliedFilters |  |  |  |  | RAW OUTPUT:L80 |
| bulk-action | state-minimum |  | present | queryState | sortRules |  |  |  |  | RAW OUTPUT:L81 |
| bulk-action | state-minimum |  | present | queryState | pagination |  |  |  |  | RAW OUTPUT:L82 |
| bulk-action | state-minimum |  | present | queryState | pageSize |  |  |  |  | RAW OUTPUT:L88 |
| bulk-action | state-minimum |  | present | queryState | querySnapshot |  |  |  |  | RAW OUTPUT:L89 |
| bulk-action | state-minimum |  | present | queryState | snapshotId |  |  |  |  | RAW OUTPUT:L90 |
| bulk-action | state-minimum |  | present | queryState | datasetVersion |  |  |  |  | RAW OUTPUT:L91 |
| bulk-action | state-minimum |  | present | queryState | requestGeneration |  |  |  |  | RAW OUTPUT:L92 |
| bulk-action | state-minimum |  | present | queryState | requestPhase |  |  |  |  | RAW OUTPUT:L93 |
| bulk-action | state-minimum |  | present | queryState | queryError |  |  |  |  | RAW OUTPUT:L100 |
| bulk-action | state-minimum |  | present | queryState | stale |  |  |  |  | RAW OUTPUT:L101 |
| bulk-action | state-group |  | declared | viewState |  |  |  |  |  | RAW OUTPUT:L119 |
| bulk-action | state-minimum |  | present | viewState | visibleColumnIds |  |  |  |  | RAW OUTPUT:L123 |
| bulk-action | state-minimum |  | present | viewState | pinnedColumnIds |  |  |  |  | RAW OUTPUT:L131 |
| bulk-action | state-minimum |  | present | viewState | columnWidths |  |  |  |  | RAW OUTPUT:L132 |
| bulk-action | state-minimum |  | present | viewState | density |  |  |  |  | RAW OUTPUT:L140 |
| bulk-action | state-minimum |  | present | viewState | rows |  |  |  |  | RAW OUTPUT:L141 |
| bulk-action | state-minimum |  | present | viewState | resultSummary |  |  |  |  | RAW OUTPUT:L142 |
| bulk-action | state-group |  | declared | interactionState |  |  |  |  |  | RAW OUTPUT:L149 |
| bulk-action | state-minimum |  | present | interactionState | focusIntent |  |  |  |  | RAW OUTPUT:L153 |
| bulk-action | state-minimum |  | present | interactionState | recordId |  |  |  |  | RAW OUTPUT:L155 |
| bulk-action | state-minimum |  | present | interactionState | columnId |  |  |  |  | RAW OUTPUT:L156 |
| bulk-action | state-group |  | declared | operationState |  |  |  |  |  | RAW OUTPUT:L173 |
| bulk-action | state-minimum |  | present | operationState | row-operation-or-absence |  |  |  |  | RAW OUTPUT:L200 |
| bulk-action | state-minimum |  | present | operationState | bulk-operation-or-absence |  |  |  |  | RAW OUTPUT:L190 |
| bulk-action | lifecycle |  | present |  | ownerId | guard |  |  |  | RAW OUTPUT:L212 |
| bulk-action | lifecycle |  | present |  | lifecycleToken | guard |  |  |  | RAW OUTPUT:L213 |
| bulk-action | lifecycle |  | present |  | live/disposed | guard |  |  |  | RAW OUTPUT:L214 |
| bulk-action | lifecycle |  | present |  | ownedResources | guard |  |  |  | RAW OUTPUT:L216 |
| bulk-action | checklist |  | 第 1、3 节 |  |  |  | 能力与状态 | 适用 | 未验证 | RAW OUTPUT:L564 |
| bulk-action | checklist |  | 第 3、5 节 |  |  |  | 查询 | 适用 | 未验证 | RAW OUTPUT:L565 |
| bulk-action | checklist |  | 第 1、4、5 节 |  |  |  | 筛选 | 适用 | 未验证 | RAW OUTPUT:L566 |
| bulk-action | checklist |  | 第 1、4、7、9 节 |  |  |  | 排序 | 适用 | 未验证 | RAW OUTPUT:L567 |
| bulk-action | checklist |  | 第 1、4、5、7 节 |  |  |  | 分页 | 适用 | 未验证 | RAW OUTPUT:L568 |
| bulk-action | checklist |  | 第 5 节 |  |  |  | 数据状态 | 适用 | 未验证 | RAW OUTPUT:L569 |
| bulk-action | checklist |  | 第 4 节 |  |  |  | 选择 | 适用 | 未验证 | RAW OUTPUT:L570 |
| bulk-action | checklist |  | `rowOperationEnabled=false`；无单行操作 DOM、状态槽、handler/事件和业务请求入口 |  |  |  | 单行操作 | 不适用 | 未验证 | RAW OUTPUT:L571 |
| bulk-action | checklist |  | 第 2、3、6 节 |  |  |  | 批量操作 | 适用 | 未验证 | RAW OUTPUT:L572 |
| bulk-action | checklist |  | 第 3 节 `viewState` |  |  |  | 基础列状态 | 适用 | 未验证 | RAW OUTPUT:L573 |
| bulk-action | checklist |  | 三项列控制均为 `false`；无控制 DOM、交互状态、handler/事件和请求入口 |  |  |  | 可选列控制 | 不适用 | 未验证 | RAW OUTPUT:L574 |
| bulk-action | checklist |  | 第 7、9、10 节 |  |  |  | Table 语义 | 适用 | 未验证 | RAW OUTPUT:L575 |
| bulk-action | checklist |  | 无二维导航需求；无 `role="grid"` DOM、Grid 状态、键盘 handler 和相关请求入口 |  |  |  | ARIA Grid 语义 | 不适用 | 未验证 | RAW OUTPUT:L576 |
| bulk-action | checklist |  | 第 7 节 |  |  |  | 键盘 | 适用 | 未验证 | RAW OUTPUT:L577 |
| bulk-action | checklist |  | 第 8 节 |  |  |  | 焦点 | 适用 | 未验证 | RAW OUTPUT:L578 |
| bulk-action | checklist |  | 第 10 节 |  |  |  | 响应式 | 适用 | 未验证 | RAW OUTPUT:L579 |
| bulk-action | checklist |  | 第 9 节 |  |  |  | ARIA 与公告 | 适用 | 未验证 | RAW OUTPUT:L580 |
| bulk-action | checklist |  | 第 11 节 |  |  |  | disposal | 适用 | 未验证 | RAW OUTPUT:L581 |
| bulk-action | checklist |  | 第 3、8、11 节 |  |  |  | 实例隔离 | 适用 | 未验证 | RAW OUTPUT:L582 |
| bulk-action | checklist |  | 第 13 节 |  |  |  | 运行时验证边界 | 适用 | 未验证 | RAW OUTPUT:L583 |
RECORD_COUNT display=64
RECORD_COUNT row-action=64
RECORD_COUNT bulk-action=64
