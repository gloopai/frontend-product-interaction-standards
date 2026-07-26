# Attempt 4 RED 诊断

状态：`RED_REPRODUCED`

## 结论

Attempt 4 必须失败。原始 payload 与哈希保存在三份 `attempt-4-*.md` 和 `attempt-4-dispatch-receipts.md`；本诊断只解释失败，不改写 RAW PROMPT / RAW OUTPUT。

## 直接缺口

| 场景 | 缺口 | 可观察证据 |
| --- | --- | --- |
| bulk-action | 能力声明不是当前值 | 未单列批量操作是否启用；`enableAllFilteredSelection` 只有“满足后端契约时启用”的条件描述，没有当前 `true/false` 或启用/不启用值。 |
| row-action | 固定四组状态不完整 | 有 `queryState`、`interactionState`、`operationState`、`lifecycleState`，但没有 `viewState`。生命周期被当作第四组，替代了展示状态。 |
| bulk-action | 固定四组状态不完整 | 状态表有 query/view/selection/operation/lifecycle，但没有 `interactionState`；另建 selection/lifecycle 不能替代固定四组。 |
| bulk-action | `viewState` 字段不完整 | 缺 `visibleColumnIds`、`pinnedColumnIds`、`columnWidths`、`density`；关闭列控件只产生 absence contract，不能删除 owner 要求的展示状态字段。 |
| row/bulk | 生命周期角色错误 | lifecycle 应为独立 owner guard，持有 `live/disposed` 与资源；不能计入 query/view/interaction/operation 四组。 |
| bulk-action | 应用清单不完整 | §11 列出未验证环境，但 §10 清单没有独立“运行时验证边界”行；正文不能替代 checklist 判定。 |

## RED 复现

对 Attempt 4 的 row/bulk RAW OUTPUT 执行字段审计，结果为 10 个失败且退出码为 1：批量操作当前开关、全部筛选结果当前值、row `viewState`、row 固定四组、bulk `interactionState`、bulk 固定四组、bulk `viewState` 四个列字段、row/bulk 独立 lifecycle guard、bulk 清单运行时验证行。

根因是 `DT-REPORT-02` / `A37` 只要求规则族层面的“声明”与“定位”，没有把当前能力值、四组固定结构、N/A absence contract、生命周期 guard 角色和 checklist 行定义成不可互相替代的字段级完成契约。修复必须由独立 clause 与可执行反例约束，不能只修改审计说明。
