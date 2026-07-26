# Attempt 1 FAILED：批量操作数据表格

## 派发参数

```json
{
  "task_name": "green_bulk_action_table",
  "canonical_identity": "/root/table_task5_green/green_bulk_action_table",
  "fork_turns": "none",
  "model": "omitted (inherited runtime default)",
  "reasoning_effort": "omitted (inherited runtime default)",
  "filesystem_edits_by_agent": false
}
```

## 完整 Prompt

<!-- BEGIN RAW PROMPT -->
Use $frontend-product-interaction-standards at /Users/evanqi/.codex/skills/frontend-product-interaction-standards/.worktrees/data-table-interaction-standards to define/review this data-table interaction.

请设计一个 bulk-action 数据表格。它要支持当前页选择，以及可选的“全部筛选结果”选择模式、排除项、筛选变化、部分成功、失败项重试和路由卸载。请说明能力边界、状态转换、加载/错误/空状态、键盘操作、焦点管理、ARIA 语义、桌面与移动端适配、选择与查询的关系，以及 disposal 后旧响应和资源如何处理；同时列出尚未通过真实运行环境验证的边界。

请直接以面向实现团队的中文设计说明回答。只返回完整设计答复，不要附加测试诊断、评分或对提示词的复述；不要修改任何文件。
<!-- END RAW PROMPT -->

## 原始输出

<!-- BEGIN RAW OUTPUT -->
# Bulk-action 数据表格设计说明

## 1. 能力边界

表格实例必须显式声明 `capabilityTier: "bulk-action"`，权限解析后的 `resolvedTier` 才决定是否渲染选择列、批量工具栏和批量操作入口。权限降级时应原子移除越权入口及其交互状态，并迁移落在已移除控件上的焦点。

本期支持：

- 服务端分页、筛选、稳定排序与刷新。
- 当前页选择。
- 产品显式启用后的“全部筛选结果”选择。
- 全部模式中的排除项。
- 全部成功、部分成功、全部失败、权限冲突、数据版本冲突和结果未知。
- 对明确可重试失败项的重试。
- 桌面 Table，以及经过完整字段映射后启用的移动端卡片形态。
- Route 离开和 owner 卸载时的幂等 disposal。

本期不包含行内编辑、树表、拖拽行排序、透视表、加载更多、无限滚动、拖拽改变列顺序或个人布局持久化。

“全部筛选结果”能力仅在后端同时满足以下条件时启用：

- 能返回可靠的可选记录总数，而不是估算值。
- 能以稳定的 `rangeKey + appliedFilters + permissionScope + datasetVersion` 表达目标集合。
- 能接受排除 ID，并在执行时重新校验权限和资格。
- 能返回逐记录的完整裁决集合，以及稳定的 `operationId`、幂等语义和状态核对能力。

若缺少一致的数据版本或等价服务端快照，只提供当前页选择；不得承诺跨页零重复遗漏，也不得启用“全部筛选结果”。

## 2. 状态模型

查询、展示、选择、操作和生命周期必须由不同 owner 管理，不得合并为一个 `loading`、`error` 或 `allSelected` 布尔值。

```ts
type QueryState = {
  appliedFilters: AppliedFilter[];
  sortRules: SortRule[];
  pagination: NumberedPage | CursorPage;
  pageSize: number;
  querySnapshot: QuerySnapshot | null;
  snapshotId: string | null;
  datasetVersion?: string;
  requestGeneration: number;
  requestPhase:
    | "idle"
    | "initial-loading"
    | "ready"
    | "refreshing"
    | "initial-error"
    | "refresh-error";
  queryError?: QueryError;
  stale: boolean;
};

type SelectionState = {
  mode: "page" | "all-filtered";
  phase: "valid" | "pending-reconfirmation";
  selectionGeneration: number;
  selectedIds: Set<RecordId>;       // page 模式
  selectionSnapshot?: {
    selectionSnapshotId: string;
    sourceQuerySnapshotId: string;
    rangeKey: string;
    appliedFilters: AppliedFilter[];
    permissionScope: PermissionScope;
    datasetVersion?: string;
    eligibleTotal: number;
  };
  excludedIds: Set<RecordId>;       // all-filtered 模式
};

type OperationState = {
  phase:
    | "idle"
    | "confirming"
    | "submitting"
    | "in-flight"
    | "all-success"
    | "partial-success"
    | "all-failed"
    | "permission-conflict"
    | "dataset-version-conflict"
    | "outcome-unknown";
  operationGeneration: number;
  operationSnapshot?: OperationSnapshot;
  successIds: Set<RecordId>;
  failedItems: Array<{
    recordId: RecordId;
    reason: string;
    retryable: boolean;
  }>;
};

type LifecycleState = {
  ownerId: string;
  lifecycleToken: string;
  live: boolean;
  disposed: boolean;
};
```

`querySnapshot`、`selectionSnapshot` 和 `operationSnapshot` 均为不可变对象。状态变化应创建后继快照，不得原地修改旧快照。

## 3. 查询与选择的关系

筛选草稿与已应用筛选分离。只有字段 owner 提交的合法业务值才能进入 `appliedFilters` 并创建查询。结果标题、总数、URL 和选择范围只反映已应用筛选。

每次应用筛选、排序、翻页、改变页大小或接受刷新前，应先冻结完整 `querySnapshot`，内容至少包括：

- 已应用筛选。
- 完整稳定排序及最终唯一稳定键。
- 分页模式和位置。
- 页大小。
- 权限范围。
- 数据版本。
- 新 `snapshotId` 和递增的 `requestGeneration`。

选择和查询的转换规则如下：

| 事件 | 当前页模式 | 全部筛选结果模式 |
|---|---|---|
| 普通翻页 | 清除选择 | 范围键、权限和版本相同时保留 |
| 改变页大小 | 清除选择 | 重新查询；若范围语义变化则失效 |
| 应用、移除、重置筛选 | 清除选择 | 立即失效并清除，禁止操作 |
| 提交排序 | 清除选择 | 进入 `pending-reconfirmation`，确认前禁止操作 |
| 权限范围变化 | 清除选择 | 立即失效并清除 |
| 数据版本变化 | 清除选择 | 立即失效并清除 |
| 同范围刷新且版本不变 | 保留仍在当前页且仍可选的 ID | 可保留；资格或总数变化时创建新的选择快照 |
| 同范围记录失去资格 | 移除该 ID | 从有效目标中移除，修正总数/排除项并公告一次 |

页面返回恢复只允许在产品显式声明恢复策略并重新校验权限、版本和分页位置后恢复查询及滚动；不得恢复旧选择、排除项、打开菜单或操作快照。

## 4. 选择交互

### 当前页选择

初始模式固定为 `page`。

- 行复选框只操作该行稳定 `recordId`。
- 表头复选框只控制当前页可选记录，绝不代表整个筛选结果。
- 当前页全部可选记录已选时为选中，部分已选时为混合态，无选择时为未选。
- 不可选记录不进入选择集合或数量；禁用复选框旁必须显示可感知的具体原因。
- 当前页没有可选记录时，表头复选框保持未选并禁用，同时显示“本页没有可批量操作的记录”等具体说明。
- 摘要持续显示“当前页已选 X/Y 条”。

不能通过点击整行切换选择，以免与行链接、菜单和文本选择冲突。

### 全部筛选结果选择

用户先选择当前页全部可选记录后，才显示独立二次入口，例如：

> 已选择本页 20 条。选择当前筛选条件下全部 237 条可操作记录

确认界面必须显示：

- 全部可选数量。
- 已应用筛选摘要。
- 权限范围或业务范围。
- 当前不可操作数量。
- 操作将使用的数据版本。

确认后进入 `all-filtered`，创建完整不可变 `selectionSnapshot`。不能只保存 `allSelected=true` 或一个数量。

在全部模式中：

- 取消某行：将其稳定 ID 加入 `excludedIds`。
- 重新选择该行：仅从 `excludedIds` 移除该 ID。
- 显示数量：`eligibleTotal - 有效 excludedIds 数量`。
- 摘要持续显示“已选择全部 237 条筛选结果，排除 2 条，实际将处理 235 条”。
- 每页表头三态仍只根据该页可选 ID 与排除项计算。
- 提供明确的“清除选择”操作。

每个被接受的选择意图递增 `selectionGeneration`。异步资格协调结果只有在 `live`、`ownerId`、`lifecycleToken` 和 `selectionGeneration` 全部匹配时才能提交。

## 5. 批量操作状态转换

```text
idle
  → confirming
  → submitting
  → in-flight
      ├─ all-success
      ├─ partial-success
      ├─ all-failed
      ├─ permission-conflict
      ├─ dataset-version-conflict
      └─ outcome-unknown
```

只有非空、有效且不处于待重新确认态的选择可以进入 `confirming`。

确认时创建不可变 `operationSnapshot`，至少冻结：

- `ownerId`、`lifecycleToken`。
- `operationId`、`operationGeneration`。
- 操作类型和风险等级。
- 捕获的 `selectionGeneration`。
- 当前页稳定 ID，或全部范围快照与排除 ID。
- 预计影响数量。
- 权限范围和数据版本。
- `operationSnapshotId`。
- 本次尝试的幂等键。

确认后发生的选择变化不得修改操作快照。表格可以允许用户准备下一批选择，但在当前操作终结前不得提交第二个批量操作；旧操作结果只有在捕获的选择代次仍匹配时才能调整当前选择。

`submitting` 和 `in-flight` 期间，点击、Enter、Space 或事件重放只能产生一个请求。重复触发记录为忽略，不得重新启用一个实际上仍在执行的提交按钮。

## 6. 批量结果与失败重试

任何业务终态都必须先通过两层门禁：

1. 生命周期门禁：`live + ownerId + lifecycleToken + operationId + operationGeneration + operationSnapshotId` 全部匹配。
2. 裁决完整性门禁：`adjudicatedCount === expectedCount`，且成功与失败 ID 不重叠、无重复、无外部 ID，其并集精确等于操作目标集合。

不满足完整裁决时进入非终态 `outcome-unknown`：

- 保留操作快照、当前选择和已有失败信息。
- 不执行选择清理、成功项重整或自动重试。
- 提供“核对操作结果”入口，通过服务端 `operationId` 查询状态。
- 网络超时或连接中断不能直接视为全部失败。

终态处理：

- **全部成功**：显示完成数量；仅当选择代次仍匹配时清除已完成选择；创建新查询快照刷新受影响数据。
- **部分成功**：显示成功数/失败数；成功项永不重试；失败项保留稳定 ID、具体原因和 `retryable`；成功子集通过新查询刷新，或在 ID 与版本可证明一致时本地确定性重整。
- **全部失败**：保留原操作快照；选择代次匹配时保留原选择；显示一个完整错误 owner 和可用恢复入口。
- **权限冲突**：重新解析可操作范围，移除越权项，显示新数量并要求确认；越权项不得自动重试。
- **数据版本冲突**：旧操作快照立即失效，刷新数据并要求重新选择或重新确认；不得复用旧幂等键。

“重试失败项”仅从 `retryable=true` 的失败项创建新的 `operationId`、操作代次、不可变快照和幂等键。已成功项和不可重试项不得进入请求。重试后成功的记录只从对应失败集合移除，不得清除其他仍失败或不可重试记录。

## 7. 加载、错误与空状态

| 场景 | 展示与行为 |
|---|---|
| 首次加载 | 无可用结果时显示与最终列结构相符的骨架；结果容器 `aria-busy="true"`；骨架不含可操作假数据 |
| 后台刷新 | 保留旧行、分页和焦点意图；显示“正在刷新”；旧结果明确标为仍在刷新，不能伪装成新结果 |
| 首次查询失败 | 结果区域用文本错误和可聚焦“重试加载”替代表格；重试创建新请求代次 |
| 刷新失败 | 保留旧行和分页，设 `stale=true`，显示“数据可能已过期”及重试入口 |
| 筛选无匹配 | 显示“当前筛选条件无匹配”，提供移除条件或重置筛选 |
| 数据源为空 | 显示独立的空数据集说明；不要与筛选无结果共用“暂无数据” |
| 操作执行中 | 批量结果 owner 显示进度或执行中状态；不写入 `queryError` |
| 操作失败 | 完整错误仅归批量结果 owner；失败项显示自身原因和恢复入口 |
| 当前页失效 | 页码模式回到最近有效页，游标模式回到服务端提供的最近有效位置；只恢复一次，避免循环重试 |

若刷新失败且无法证明旧 `datasetVersion` 仍可用于安全提交，应禁用新的全部范围确认和高风险批量提交，并说明需先刷新；当前页低风险操作是否允许由产品和后端版本校验能力显式决定。

## 8. 键盘操作与焦点管理

推荐使用原生 `<table>`。普通数据表格不接管方向键、Home、End、Page Up 或 Page Down。

键盘路径：

- `Tab/Shift+Tab`：按视觉任务顺序进入筛选、排序按钮、复选框、行操作、批量工具栏、分页和错误恢复控件。
- `Space`：切换获得焦点的原生复选框。
- `Enter/Space`：激活排序、范围确认、批量操作、重试和分页按钮。
- 行静态单元格不添加 `tabindex="0"`。
- 不提供未声明快捷键，也不依赖 Hover、长按或拖动。

只有产品明确需要单元格级二维导航时才可改用 ARIA Grid，并完整实现单一 Tab 入口、方向键、Home/End、Ctrl/Command+Home/End、Page Up/Page Down，以及 Enter/F2 进入单元格控件、Escape 返回 Grid 导航模式。

焦点规则：

- 行选择、表头选择和筛选提交后，原控件仍存在时保持焦点。
- 查询开始不抢焦点；结果提交使目标消失时，按稳定 `recordId + columnId + controlId` 恢复，不能按数组索引恢复到另一条记录。
- 翻页响应提交后，焦点移动一次到结果摘要或标题；若产品显式保留了语义未变的分页触发器，可保持原焦点。
- 操作结果提交前记录当前焦点。目标仍存活、可聚焦且语义未变时不移动。
- 目标消失时只移动一次：部分成功优先到首个失败项或失败摘要；全部失败到错误摘要或重试；冲突到重新确认入口；结果未知到“核对结果”入口；全部成功到结果摘要或仍存活的批量工具栏。
- 焦点不得落到 `document.body`、文档根或已移除元素；后续刷新不能产生第二次迁移。
- Live region 只播报状态，不主动接收焦点。

## 9. ARIA 与可访问语义

- 表格使用 `<table>`、可访问的 `<caption>` 或 `aria-labelledby`；表头使用 `<th scope="col|row">`。
- 结果容器具有可区分名称，并在请求期间设置 `aria-busy="true"`。
- 可排序表头内使用真实按钮；只在当前排序表头设置正确的 `aria-sort`。
- 表头和行选择使用原生复选框。混合态通过原生 `indeterminate` 状态暴露。
- 表头复选框名称应类似“选择当前页可操作记录，已选 7/20 条”；行复选框名称应包含记录身份。
- 不可选行的禁用原因使用可见文本并与控件关联，不能只用颜色或 Tooltip。
- 选择摘要、过期、执行中、部分成功、失败、冲突及结果未知均有文字表达。
- 查询、选择范围和批量操作分别只有一个 primary live region owner。
- 每个被接受且需要反馈的事件只公告一次；被合并、丢弃、取代、disposed 后到达或静默失效的事件不公告。
- 同一 `errorId` 只有一个完整错误 owner 和一条完整公告路径；不得同时在行、全局提示和 live region 重复完整内容。
- 公告保持简洁，例如“已选择全部 237 条结果，排除 2 条”“操作完成：3 条成功，2 条失败”，不得逐行朗读整个表格或全部筛选条件。

## 10. 桌面与移动端适配

桌面端：

- 筛选和结果摘要位于表格上方。
- 选择后显示持续可见的批量工具栏，包含选择范围、数量、排除数量、操作及“清除选择”。
- 表格横向滚动仅发生在表格容器，页面根不得横向溢出。
- 记录身份、主要状态和主要操作为关键列，不得隐藏。
- 固定列不得遮挡焦点、错误、菜单或滚动边界。

移动端和平板：

- 核心筛选、翻页、选择、范围确认、风险确认、错误恢复必须与桌面等价。
- 只有配置了 `responsivePresentation` 且完成字段映射评审时才转换为卡片。
- 每张卡片必须有记录级可访问名称；每个值与字段标签关联；选择、详情和行操作一一保留。
- 映射不完整时继续使用原生表格和受控横向滚动，不临时猜测卡片结构。
- 批量工具栏可成为底部固定操作区，但必须考虑 `safe-area-inset-bottom`，不得遮挡失败摘要、焦点或最后一条记录。
- 实时断点切换保持同一 `ownerId` 及查询、分页、选择、排除项、焦点意图和操作快照；不能重新请求、重放操作或重建代次。
- 任一时刻只能有一个活动 Table/Grid 或卡片列表根。
- 200% 缩放、字体放大、长翻译、低高度、虚拟键盘和动态浏览器工具栏下，筛选、结果、分页、批量摘要及错误恢复仍须可达。

## 11. Route 卸载与 disposal

Route 提交离开或表格 owner 卸载时，实例同步且仅一次进入 `disposed`，不等待请求、操作结果、菜单动画或关闭动画。

处置顺序：

1. 立即令 `live=false` 并使 `lifecycleToken` 失效。
2. 拒绝新的查询、分页、选择、焦点、菜单、重试、操作和公告工作。
3. 取消或失效查询、分页恢复、重试、防抖、计时器、动画帧和状态核对任务。
4. 关闭菜单、popup、portal，并取消定位回调。
5. 失效待执行的焦点、选择协调、操作结果和 live-region 回调。
6. 注销该实例的事件监听器、观察器和订阅。
7. 移除本实例 DOM、popup 和 ARIA 引用。
8. 按 `ownerId` 仅释放本实例持有的资源一次。

取消请求只用于节省资源，不能代替提交门禁。迟到查询响应必须匹配：

```text
live
+ ownerId
+ lifecycleToken
+ requestGeneration
+ snapshotId
```

迟到操作响应必须匹配：

```text
live
+ ownerId
+ lifecycleToken
+ operationId
+ operationGeneration
+ operationSnapshotId
```

任何一项不匹配，只记录 discarded；DOM、状态、焦点和 live region 写入均为零。不得把本地卸载描述为服务端操作已经取消；长任务若需要离页后追踪，应由服务端操作中心或全局任务 owner 承接，而不是恢复已 disposed 的表格实例。

旧触发器即将随路由移除时不返回焦点。新路由提交后，只由新路由的焦点策略移动一次到主标题、主内容或主要操作。

## 12. 尚未通过真实运行环境验证的边界

本说明是实现契约，以下项目仍需在真实系统中确认：

- 后端是否提供精确可选总数、稳定 `rangeKey`、数据版本和跨页一致性快照。
- 全部筛选结果加大量排除项时的请求大小、服务端性能和产品上限。
- 幂等键、操作状态核对、网络超时及未知结果恢复是否符合上述语义。
- 服务端逐记录裁决是否保证无重复、无遗漏、无外部 ID，并能区分权限冲突与版本冲突。
- 快速筛选、排序、翻页、重试、路由离开和操作响应交错时，旧响应是否确实无法写入。
- 浏览器取消请求失败、后台操作继续执行及返回页面后的新 owner 隔离。
- NVDA/Firefox、JAWS/Chrome、VoiceOver/Safari、TalkBack/Chrome 对混合复选框、busy、live region、表格/卡片语义和禁用原因的实际朗读。
- 仅键盘完成筛选、翻页、当前页选择、全部范围确认、批量提交和失败重试的完整路径。
- 鼠标、触摸和键盘触发同一意图时的状态、请求数及防重复结果是否一致。
- `1440×900`、`1280×720`、平板横竖屏、`390×844` 窄屏及低高度横屏下的布局。
- 200% 浏览器缩放、系统字体放大、长文本、长单词、国际化和高对比度下的可达性。
- 虚拟键盘、动态视口和四向安全区域下，固定批量工具栏及焦点是否被遮挡。
- 表格与卡片实时切换时，焦点、选择、排除项、打开菜单、in-flight 操作和 ARIA 引用是否保持单实例且无重复请求。
- 数据量较大、失败项很多或失败原因很长时，批量结果区域的性能、可读性和焦点恢复。
- 浏览器前进/后退时，仅恢复查询和滚动、不恢复旧选择与操作快照的实际行为。
<!-- END RAW OUTPUT -->

## Completion receipt

- canonical agent：`/root/table_task5_green/green_bulk_action_table`
- receipt：`FINAL_ANSWER received; agent status completed`
- 原始输出完成后才包装本证据文件；原始输出区未做规范性改写。

## SHA-256

- prompt：`32de51627ece3f0b85b5ce45944b54d373ddfde720db6d85a29d9a074f3ce0ab`
- output：`95924fe9c57312585928cd23e2827f74280d1011a8f69b84bcfbfdfb1370b4d9`
