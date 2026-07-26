# Attempt 3 FAILED：批量操作数据表格

## 实际 spawn 参数

```json
{
  "task_name": "attempt_3_bulk_action_table",
  "fork_turns": "none",
  "message": "Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.\n\n请设计一个 bulk-action 数据表格。它要支持当前页选择，以及可选的“全部筛选结果”选择模式、排除项、筛选变化、部分成功、失败项重试和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配、选择与查询的关系，以及 disposal 后旧响应和资源如何处理；同时列出尚未通过真实运行环境验证的边界。\n\n请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。"
}
```

`model` 与 `reasoning_effort` 没有作为调用参数发送。

## spawn 工具返回

```json
{"task_name":"/root/table_task5_green/attempt_3_bulk_action_table"}
```

## 完成 envelope

- Message Type: `FINAL_ANSWER`
- Task name（recipient）: `/root/table_task5_green`
- Sender: `/root/table_task5_green/attempt_3_bulk_action_table`
- Payload: 以下 `BEGIN/END RAW OUTPUT` 之间的原始内容。

## 完整 Prompt

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个 bulk-action 数据表格。它要支持当前页选择，以及可选的“全部筛选结果”选择模式、排除项、筛选变化、部分成功、失败项重试和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配、选择与查询的关系，以及 disposal 后旧响应和资源如何处理；同时列出尚未通过真实运行环境验证的边界。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

## 原始完成 payload

<!-- BEGIN RAW OUTPUT -->
# Bulk-action 数据表格实现设计

## 1. 能力声明

本实例固定声明：

| 项目 | 配置 |
|---|---|
| `capabilityTier` | `bulk-action` |
| `resolvedTier` | 当前已授权场景为 `bulk-action`；权限降低时可原子降为 `row-action` 或 `display` |
| 筛选 | 启用；每个筛选项显式声明 `immediate` 或 `explicit` |
| 排序 | 启用；单列交互排序，服务端追加稳定 ID 次序键 |
| 分页 | 仅 `numbered`，默认每页 20 条；依赖可靠总数 |
| 当前页选择 | 启用 |
| 全部筛选结果 | 显式启用 |
| 排除项 | 启用，且只能存在于不可变 `selectionSnapshot` 内 |
| 批量操作 | 启用；第一版使用页面内联确认区 |
| 单行操作 | 不启用，不渲染行菜单或对应 handler |
| 列显示、固定、调宽 | 不启用，不建立相关状态、控件或隐藏 handler |
| 桌面/移动形态 | 均使用同一原生 Table；窄屏采用受控横向滚动，不转换为卡片或 Grid |

第一版不包含行内编辑、树表、拖拽排序、透视、加载更多、无限滚动、用户调整列顺序和个人布局持久化。

“全部筛选结果”只有在服务端同时提供稳定记录 ID、可靠的可选总数、权限范围、数据版本或等价不可变快照、排除项语义、幂等执行和逐项裁决能力时才允许启用。缺少任一项时，只提供当前页选择。

## 2. 状态所有权

每个实例必须有不可复用的 `ownerId`、`lifecycleToken` 和唯一 `announcementOwnerId`。至少维护四组互不混写的状态：

```ts
queryState = {
  filterDraft,
  appliedFilters,
  sortRules,
  pagination,
  pageSize,
  querySnapshot,
  snapshotId,
  datasetVersion,
  requestGeneration,
  requestPhase,
  queryError,
  stale
}

viewState = {
  rows,
  resultSummary,
  visibleColumnIds,
  density
}

interactionState = {
  focusIntent,
  selectionMode,          // page | all-filtered
  selectionValidity,      // valid | pending-reconfirmation | invalid
  selectedIds,            // 仅 page 模式
  selectionSnapshot,      // 仅 all-filtered 模式
  selectionGeneration
}

operationState = {
  phase,
  operationSnapshot,
  operationId,
  operationGeneration,
  idempotencyKey,
  successIds,
  failedItems,
  conflict,
  errorOwner,
  focusIntent
}
```

查询响应只能写查询和结果状态；选择 owner 只能写选择；操作错误只能写批量结果区，不得写入 `queryError`。

## 3. 查询、筛选、排序和分页

每次查询前冻结不可变 `querySnapshot`，至少包含：

```ts
{
  snapshotId,
  appliedFilters,
  completeSortRules,
  paginationMode: "numbered",
  page,
  pageSize,
  permissionScope,
  datasetVersion
}
```

随后严格递增 `requestGeneration`。响应只有同时满足以下条件才能提交：

- 实例仍为 live；
- `ownerId`、`lifecycleToken` 匹配；
- `requestGeneration` 等于当前代次；
- `snapshotId` 等于当前快照。

取消请求只用于节省资源，不能代替响应门禁。

筛选规则：

- 字段内部值、校验和控件草稿归筛选字段 owner；表格只接收字段已经提交的合法业务值。
- `filterDraft` 与 `appliedFilters` 分开。结果标题、数量、URL 和请求只反映 `appliedFilters`。
- 简单、低成本筛选可配置为 `immediate`；多字段或高成本筛选使用 `explicit` 的“应用筛选”按钮。
- “重置”恢复产品配置的 `defaultFilters`，不是无条件清空。
- 所有已应用条件以可访问的摘要项持续显示，并可逐项移除。
- 只有明确标记 `urlSafe` 的值进入 URL；敏感值、自由文本个人信息不得进入 URL、标题或分析日志。
- 应用、移除、重置筛选均回到第 1 页，并清理或失效选择。

排序规则：

- 默认排序建议为 `updatedAt DESC, recordId ASC`；业务列改变时仍追加唯一且不可变的 `recordId`。
- 空值位置、大小写、自然排序和区域规则必须由前后端共同配置并冻结在快照中，不依赖数据库偶然顺序。
- 可排序表头使用真实按钮；当前排序表头设置正确 `aria-sort`，不可排序列不渲染按钮或伪造 `aria-sort`。
- 排序提交回到第 1 页。
- 服务端没有一致数据版本时，不承诺跨页绝无重复或遗漏；检测到页间变化后使分页链失效并从首个有效位置重启。

分页规则：

- 只使用页码分页。显示当前页、总页数和结果范围，当前页使用 `aria-current="page"`。
- 首页“上一页”、末页“下一页”使用原生 `disabled`，越界操作不请求。
- 改变页大小回到第 1 页。
- 删除导致当前页超过最新末页时，只恢复一次到最近有效页，不循环重试；恢复成功只公告一次。
- 只有总数可靠时才能提供直接页码和“全部筛选结果”总量。否则本设计必须切换为另一个明确的分页方案，并关闭全部范围选择。

## 4. 选择模型及与查询的关系

### 当前页模式

初始状态始终为：

```ts
selectionMode = "page"
selectedIds = new Set()
```

行只能按稳定 `recordId` 选择。不可操作记录不进入选择集合和数量，其禁用复选框必须显示具体原因。

表头复选框永远只控制当前页可选记录：

- 当前页可选项全选：选中；
- 部分选择：混合态；
- 有可选项但未选择：未选；
- 零可选项：未选且 `disabled`，并说明“本页没有可批量操作的记录”。

建议名称为：“选择当前页可操作记录，已选 X/Y”。不得把表头复选框描述为“选择全部结果”。

当前页选择在以下事件提交时清除：

- 应用、移除或重置筛选；
- 提交排序；
- 翻页；
- 改变页大小；
- 权限范围变化；
- 数据集版本变化。

### 全部筛选结果模式

只有先完成当前页全部可选记录的选择，才显示独立操作：

> 选择符合当前筛选条件的全部 237 条可操作记录

用户确认后创建不可变 `selectionSnapshot`：

```ts
{
  selectionSnapshotId,
  sourceQuerySnapshotId,
  rangeKey,
  appliedFilters,
  permissionScope,
  datasetVersion,
  eligibleTotal,
  excludedIds: Set<recordId>, // 初始必须为空
  serverSelectionToken,
  targetIdentityDigest
}
```

`eligibleTotal` 是可操作记录总数，不是未过滤数据总数。界面持续显示：

> 已选择全部筛选结果：236 条；排除 1 条

取消某行时不能原地修改快照，而要创建新的后继快照，只向内部 `excludedIds` 增加该 ID；重新选择时创建另一后继快照并移除该 ID。可见选择数为：

```text
eligibleTotal - 有效 excludedIds 数
```

普通翻页在 `rangeKey + permissionScope + datasetVersion` 均未变化时保留同一快照身份。每页表头仍只根据该页可选 ID 与当前排除项计算三态。

范围变化处理：

| 事件 | `page` 模式 | `all-filtered` 模式 |
|---|---|---|
| 普通翻页 | 清除 | 保留 |
| 筛选变化 | 清除 | 立即失效并清除 |
| 权限变化 | 清除 | 立即失效并清除 |
| 数据版本变化 | 清除 | 立即失效并清除 |
| 仅排序变化 | 清除 | 进入 `pending-reconfirmation` |
| 同范围资格变化 | 移除失效 ID | 创建后继快照并更新可选总数/排除项 |

`pending-reconfirmation` 期间禁止批量提交，并显示新的范围、数量以及“重新确认”和“清除选择”。确认后绑定新查询快照；取消则清除选择。

每个被接受的选择意图递增 `selectionGeneration`。异步资格协调结果必须校验 live、owner、lifecycle 和当前选择代次，迟到结果只记录丢弃，不改选择或公告。

## 5. 批量操作状态机

操作阶段：

```text
idle
  → confirming
  → submitting / in-flight
  → all-success
  → partial-success
  → all-failed
  → permission-conflict
  → dataset-version-conflict
  → outcome-unknown（非终态）
```

只有非空、有效、非待重确认、非过期的选择能进入确认。

开始确认时冻结不可变 `operationSnapshot`：

```ts
{
  operationSnapshotId,
  ownerId,
  operationId,
  operationGeneration,
  actionType,
  selectionGeneration,
  selectionMode,
  selectedRecordIds,        // page 模式
  selectionSnapshot,        // all-filtered 模式
  excludedIds,
  expectedCount,
  permissionScope,
  datasetVersion
}
```

确认区必须显示操作名称、预计数量、已应用筛选范围、排除数量、不可操作数量和风险。第一版采用表格上方的内联确认区域，不创建 Dialog 或 Drawer。

破坏性操作必须显式确认。不可逆或高影响操作在产品未定义更强确认协议前不得开放普通提交按钮。

每次尝试使用新的幂等键。`submitting/in-flight` 中点击、Enter、Space 和事件重放最多产生一次请求，重复触发只记为忽略。操作执行期间当前选择可以继续变化，但不能再启动第二个批量操作；旧操作结果只有在捕获的 `selectionGeneration` 仍匹配时才可调整当前选择。

### 结果裁决

只有满足以下条件才能分类业务终态：

- `adjudicatedCount === operationSnapshot.expectedCount`；
- 成功和失败身份无重复、无交集；
- 裁决身份集合与操作目标集合精确相等；
- 操作响应通过完整生命周期门禁。

对大量“全部筛选结果”，服务端可分页返回结果清单，但结果 owner 必须完成全部身份清单或等价不可变清单证明的核对后才能进入终态。计数相等但存在遗漏、外部 ID、重复或重叠时进入 `outcome-unknown`，保留快照、选择和失败 owner，提供“核对执行结果”入口，不得清理选择或盲目重试。

终态处理：

- 全部成功：成功数等于预计数且失败为零；选择代次匹配时清除已完成选择，然后建立一个新查询快照刷新。
- 部分成功：成功和失败均非空。成功项不得再执行；失败项保留稳定 ID、具体原因和 `retryable`。刷新成功子集或在 ID、数据版本可证明一致时本地确定性重整。
- 全部失败：成功为零；代次匹配时保留原选择和操作快照。
- 权限冲突：重新解析权限，移除越权项，显示剩余数量并要求再次确认；越权项不得自动重试。
- 数据版本冲突：旧操作快照立即失效，刷新数据并要求重新选择或重新确认。
- `outcome-unknown`：先查询操作状态或进入人工核对，不创建新的执行尝试。

失败重试只针对 `retryableFailedIds` 创建新的 `operationId`、操作代次、不可变快照和幂等键。成功项和不可重试项的重试请求数必须为零。

## 6. 加载、错误和空状态

| 场景 | 表现 |
|---|---|
| 首次加载 | 显示与最终列结构一致、不可操作的骨架；结果容器 `aria-busy="true"` |
| 后台刷新 | 保留上次成功行、分页和焦点；明确显示“正在刷新”，不能把旧行伪装成新条件结果 |
| 首次失败 | 不渲染不可用表格；结果区显示完整错误及可聚焦“重试加载” |
| 刷新失败 | 保留旧行，`stale=true`，显示“数据可能已过期”及重试入口 |
| 筛选后零结果 | 显示“当前条件无匹配”，提供调整或清除筛选 |
| 数据源为空 | 显示独立的空数据集状态，不使用含糊的“暂无数据” |
| 当前页零可选项 | 保留结果；表头选择框 disabled，并说明具体不可选原因 |
| 批量失败 | 只在操作结果 owner 显示，不覆盖查询错误或清空表格 |

范围、位置或筛选正在切换时，旧行可以保留用于视觉连续性，但必须标明是上一结果，并暂时禁止对旧结果建立新选择或发起批量操作。

## 7. 键盘、焦点和 ARIA

使用原生 `<table>`，提供可区分的 `<caption>` 或 `aria-labelledby`，表头使用 `<th scope="col">`。没有二维单元格导航需求，因此不得添加 `role="grid"`。

键盘行为：

- Tab/Shift+Tab 只进入筛选、排序按钮、复选框、批量操作、分页和重试等真实控件。
- 行及表头复选框使用 Space 切换；按钮支持 Enter/Space。
- 原生 Table 不接管方向键、Home、End、Page Up 或 Page Down。
- 内联确认区内按 Escape 等价于取消并返回触发按钮；确认区不设置焦点陷阱。
- 鼠标、触摸和键盘触发同一意图时必须进入同一状态转换，并共享重复提交保护。

复选框使用原生 `checked`、`disabled` 和 `indeterminate`；行名称包含记录身份，例如“选择订单 A-1042”。禁用原因通过邻近文本和 `aria-describedby` 关联。

焦点规则：

- 发起筛选、排序或刷新不抢走仍存活的触发控件。
- 展开选择范围确认时，焦点一次移动到确认区标题；确认后移动到选择摘要，取消后返回触发按钮。
- 翻页成功后一次移动到结果标题或摘要；失效页自动恢复不再二次移动。
- 批量结果提交前记录当前焦点。目标仍存活、可聚焦且语义未变时不移动；目标消失时一次移动到对应的结果摘要、首个失败项、重试、重新确认或结果核对入口。
- 部分成功后的刷新不得把焦点从仍存活的失败项移走。
- 权限降级移除控件前，先迁移到同记录等价控件、结果摘要或分页控件。
- 焦点不得落到 `body`、文档根、已卸载节点或另一表格的同名控件。

查询、选择和操作分别拥有独立的 `aria-live="polite"` 状态 owner。每个需要反馈的事件只发一次简洁公告；不逐行朗读，不重复完整筛选条件或错误。合并、过期、被替代、disposal 后到达的事件保持静默。

## 8. 桌面和移动端适配

桌面、平板和手机提供完全相同的筛选、分页、选择范围、确认等级、批量结果和重试能力。

- 桌面：筛选、结果摘要和批量工具栏横向排列；表格占主内容宽度。
- 窄屏：筛选区纵向排列；选择摘要与主批量按钮形成单列工具栏。
- 表格保持单一原生 Table。列顺序固定为选择、记录身份、主要状态、主要操作信息、次要字段。
- 必要的横向滚动只发生在表格容器；页面根不得横向溢出。容器提供首尾边界和可滚动方向的非颜色提示。
- 不使用 `display:none` 无入口删除次要字段；关键身份、状态、错误和操作名称不能只靠截断、图标或 Hover。
- 有选择时可显示底部 sticky 批量栏，但必须预留内容空间和 `safe-area-inset-*`，不得遮挡聚焦项；低高度或虚拟键盘出现时可退回普通文档流。
- 200% 缩放下关键流程不得同时要求页面和表格双向滚动。
- 触摸目标采用产品移动端最小尺寸和间距，不把拖动、滑动或长按作为唯一入口。
- 断点变化只改变布局，不更换 `ownerId`、不重建状态、不发查询、不重放操作。精确焦点目标存活时保持焦点。

## 9. 路由卸载与旧响应处理

路由提交离开或 owner 卸载时，实例同步进入终止性的 `disposed`，不等待请求、操作结果、菜单动画或重试。

处置流程必须幂等，并按 `ownerId` 逐项完成：

- 中止或失效查询、分页恢复、重试和防抖；
- 关闭菜单、popup，取消定位和动画回调；
- 失效待执行的焦点、选择协调、操作结果和公告任务；
- 注销监听器、计时器、观察器、订阅和 `requestAnimationFrame`；
- 移除本实例 DOM、popup 与 ARIA 引用；
- 每项资源只释放一次，不触碰其他实例持有的资源。

查询迟到响应执行：

```text
live
+ ownerId
+ lifecycleToken
+ requestGeneration
+ snapshotId
```

操作迟到响应执行唯一完整门禁：

```text
live
+ ownerId
+ lifecycleToken
+ operationId
+ operationGeneration
+ operationSnapshotId
```

任一项不匹配，只记录 `response-discarded` 或 `operation-result-discarded`；DOM、状态、焦点和 live region 写入必须为零。客户端离开只表示本地不再接收结果，不能宣称服务端工作已成功取消。

旧触发器即将随路由移除时不得返回焦点。新路由提交后，只由新路由策略移动一次到主标题、主内容或首个主要操作。

返回页面是否恢复查询和滚动位置由产品显式配置；恢复前重新校验权限、数据版本和分页位置，并创建新的 `ownerId` 与 `lifecycleToken`。旧选择、排除项、权限结果、菜单和操作快照一律不回放。

## 10. 实现应用检查清单

| 规则族 | 结论 | 实现依据 |
|---|---|---|
| 能力与状态 | 适用 | 显式 `bulk-action` 档位及四组正交状态 |
| 查询 | 适用 | 不可变查询快照、五项响应门禁、请求代次 |
| 筛选 | 适用 | draft/applied、应用模式、默认重置、摘要、URL 安全、字段错误 owner 均已定义 |
| 排序 | 适用 | 单列交互排序、稳定 ID、空值/区域规则、回第 1 页 |
| 分页 | 适用 | 唯一页码模式、可靠总数、边界禁用和失效页恢复 |
| 数据状态 | 适用 | 首次/刷新加载、首次/刷新错误、过期和两类空状态分离 |
| 选择与操作 | 适用 | 当前页、全部范围、排除项、部分成功、重试和冲突完整定义 |
| 列显示/固定/调宽 | 不适用 | 不配置相应状态、控件、DOM 或事件入口 |
| 原生 Table | 适用 | 原生表格、真实控件和表头关联 |
| ARIA Grid | 不适用 | 没有二维单元格导航或单元格选择需求，不渲染 `role="grid"` |
| 焦点 | 适用 | 稳定记录 ID、单次迁移和终态等价目标 |
| 响应式 | 适用 | 同能力、单实例、受控横向滚动和极端视口约束 |
| 卡片转换 | 不适用 | 未配置完整卡片字段映射，窄屏继续使用同一 Table |
| ARIA 与公告 | 适用 | 控件名称、三态、busy/stale/结果公告及唯一错误 owner |
| disposal 与实例隔离 | 适用 | owner/token 门禁、资源归属、迟到结果零写入 |
| 真实运行时验证 | 未验证 | 需在下列真实环境中执行 |

## 11. 尚未通过真实运行环境验证的边界

当前仅完成设计契约，以下边界仍需真实运行验证：

- `1440×900`、`1280×720`、平板横竖屏、`390×844`、低高度横屏手机及动态视口；
- 200% 浏览器缩放、系统字体放大、长文本和多语言扩展；
- 虚拟键盘、四向安全区域、sticky 批量栏遮挡和表格横向滚动；
- 仅键盘完成筛选、翻页、当前页全选、全部范围确认、批量提交、失败重试；
- VoiceOver/Safari、NVDA/Firefox、JAWS/Chrome 对原生复选框混合态、禁用原因、表头关联和 live region 的实际播报；
- 鼠标、触摸、键盘及事件重放下的单请求保护；
- 快速筛选、排序、翻页乱序响应，以及取消失败后的迟到响应门禁；
- 路由卸载时仍挂起查询、分页恢复、重试、防抖、菜单定位、焦点和操作结果的资源释放；
- 同页多个表格 owner 隔离及相同 generation 数值下的交错响应；
- 服务端 `eligibleTotal`、`datasetVersion`、范围 token、排除项、幂等键、逐项裁决和结果清单完整性；
- 大规模全部范围下失败清单分页、身份集合核对、内存和渲染性能；
- 权限变化、数据版本冲突、网络结果不确定和操作状态核对接口；
- 浏览器返回时仅恢复合法查询/滚动，而不恢复旧选择、排除项或操作快照。
<!-- END RAW OUTPUT -->
