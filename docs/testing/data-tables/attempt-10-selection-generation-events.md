# Attempt 10 结构化选择代次事件证据

Attempt 10 不改写 Attempt 8 或 Attempt 9。它只验证 owner 新增的结构化事件契约；以下表格是本证据的权威裁决输入。

| actorPath | event | generationWrite | sequence | asyncStartSequence | relativeTiming | snapshotEffect | commitGuard | mismatchEffect |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| selection-owner | selection-intent-accepted | +1 | 10 | 20 | before-async-start | 创建新的不可变后继；旧快照写入=0 | live+ownerId+lifecycleToken+current-selectionGeneration | rejected-before-async; selectionWrite=0 |
| selection-owner-eligibility | selection-eligibility-change-accepted | +1 | 11 | 21 | before-async-start | 创建新的不可变后继；旧快照写入=0 | live+ownerId+lifecycleToken+current-selectionGeneration | selection-result-discarded; selectionWrite=0 |
| async-selection-coordination-callback | selection-coordination-result-arrived | 0 | 30 | 20 | after-async-start | 仅门禁匹配时按已接受意图创建后继；回调不改代次 | live+ownerId+lifecycleToken+selectionGeneration | selection-result-discarded; selectionWrite=0 |
| operation-result-owner | operation-result-adjust-selection | 0 | 40 | 20 | after-async-start | 仅捕获代次匹配时创建合法后继；旧快照写入=0 | capturedSelectionGeneration===currentSelectionGeneration | operation-result-owner; selectionWrite=0 |

<!-- LEGAL PROSE CONTROL -->

浏览器、辅助技术、真实组件运行时与真实竞态仍未验证。
