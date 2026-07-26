# 数据表格规范 Attempt 1 失败汇总

状态：`FAILED/INCOMPLETE`

Attempt 1 的三份完整输出与派发回执继续保留，但 `7fee3d1` 不是 Task 5 完成提交。第一版 summary 漏判 bulk 的 `selectionSnapshot`，并把未封闭的 `responsivePresentation` 局部值本身误判为失败；本文件按 owner 逐项重新审计并取代该结论。

## 严格审计原则

- 只有输出明确覆盖 owner 硬规则，或基于能力/配置的可观察条件明确标为不适用，才记通过或合理不适用。
- 一个矩阵单元存在任一硬规则遗漏即记失败，不以其他段落的优点抵消。
- `responsivePresentation` 没有封闭枚举；`table-card` 或 `card` 只有在导致双实例、字段/能力丢失、额外请求或焦点错误时才失败。Attempt 1 的局部值没有这些行为冲突，因此不单独判失败。
- 实现可以增加局部状态，但必须说明它属于既有 owner、产品配置或实现细节，且不得覆盖 owner 状态或转换。未说明归属的新增策略记应用失败，不自动成为 owner 规则。

## 全矩阵结果

| 核对项 | 展示型 | 单行操作 | 批量操作 | 严格判断 |
| --- | --- | --- | --- | --- |
| 能力档位与选择能力显式启用 | 失败 | 通过 | 通过 | display 声明 `capabilityTier` 但未声明权限解析后的 `resolvedTier`；row/bulk 明确档位、降级或允许结构。 |
| 查询快照、代次与迟到响应 | 通过 | 通过 | 通过 | 三者均写出不可变快照、代次及 live/owner/token/generation/snapshot 门禁，且取消不替代门禁。 |
| 筛选草稿、已应用条件和默认重置 | 通过 | 失败 | 失败 | display 覆盖 draft/applied、合法提交、默认重置、摘要与 URL；row 未建立该模型；bulk 只写 draft/applied，遗漏 applyMode、defaultFilters、持续可见条件与 URL 安全。 |
| 稳定排序与分页重置 | 通过 | 通过 | 失败 | display/row 写出唯一键、空值/区域规则和回起点；bulk 只写最终唯一键，遗漏空值、大小写、区域/自然排序规则。 |
| 页码/游标边界、首次失败、刷新失败、过期与零结果 | 通过 | 通过 | 失败 | display/row 各自选定 numbered/cursor 并覆盖边界；bulk 使用 `NumberedPage | CursorPage`，没有为实例显式选择唯一分页模式。 |
| 当前页三态与全部筛选结果范围 | 合理不适用 | 合理不适用 | **失败** | display/row 明确禁止选择。bulk 虽覆盖三态、提升和排除行为，但类型定义把 `excludedIds` 放在 `selectionSnapshot` 外；这违反 `DT-SEL-03` 要求把初始空排除项冻结进不可变范围快照，也使后续 sibling set 可独立漂移。 |
| 操作快照、重复提交、部分成功与恢复 | 合理不适用 | 通过 | 通过 | display 无操作；row/bulk 都覆盖不可变操作快照、六项门禁、幂等/重复提交和恢复；bulk 覆盖完整裁决、unknown 与五类终态。 |
| 原生 Table/Grid 选择与键盘 | 通过 | 通过 | 通过 | display/row 明确使用原生 Table 且不接管 Grid 键；bulk 给出 Table 优先及 Grid 的条件和完整键盘模型。 |
| 列隐藏/固定/宽度、响应式等价与横向滚动 | 失败 | 失败 | 失败 | 三份都覆盖部分响应式/滚动/固定遮挡，但都未明确列显示依赖迁移与键盘调宽；也没有按未启用列控制的条件标为不适用。 |
| disposal、实例隔离、焦点、ARIA、公告和运行时边界 | 失败 | 失败 | 失败 | 三者的焦点/ARIA/公告/未验证边界大体完整；display disposal 缺幂等释放、资源注销、返回恢复和实例隔离；row/bulk 未把同页两 live 实例隔离写为正向契约。 |
| owner 状态/产品决策归属 | 失败 | 失败 | 失败 | 三份都没有完成前适用性/来源清单；row 的菜单 phase 与 `stalePolicy`、bulk 的资格变化重建选择快照未标明归属，后者还偏离 `DT-SEL-05` 的既定转换。responsivePresentation 局部值本身不计失败。 |

## 场景结论

- 展示型：`FAILED`。查询、筛选、排序、页码、数据状态、Table、焦点和响应式内容可用，但能力解析、列契约、完整 lifecycle/实例隔离及规则来源未闭环。
- 单行操作：`FAILED`。成功消除 RED 的“加载下一段”，并覆盖游标、菜单、操作与 disposal；但筛选、列、正向实例隔离和新增局部状态归属未闭环。
- 批量操作：`FAILED`。选择和操作主体明显进步，但 `excludedIds` 快照归属直接错误，同时遗漏分页模式、筛选/排序细则、列、实例隔离和新增转换归属。

## RED → Attempt 1 的有效进步

这些进步保留为诊断事实，但不改变失败状态：三个输出开始共享显式能力档位、查询快照和代次；row-action 消除了加载更多；bulk 建立当前页三态、全部范围、操作完整裁决和失败重试；三者都正确保留刷新失败的旧数据、优先原生 Table、保持跨端能力并列出运行时未验证边界。

## 证据

- [展示型原始输出](attempt-1-display-report.md)
- [单行操作原始输出](attempt-1-row-action-list.md)
- [批量操作原始输出](attempt-1-bulk-action-table.md)
- [Attempt 1 派发回执](attempt-1-dispatch-receipts.md)
- [失败与根因诊断](attempt-1-red-diagnosis.md)
