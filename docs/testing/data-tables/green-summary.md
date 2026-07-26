# 数据表格规范 GREEN 前向测试汇总

## 结论

状态：`DONE_WITH_CONCERNS`

三名 `fork_turns=none` 新鲜代理都实际读取并应用了当前 Skill，且相较 [RED 汇总](red-summary.md) 明显收敛到共享 owner：三份输出都使用显式能力档位、不可变查询快照、请求代次、稳定标识焦点、原生 Table 优先、响应式等价、迟到响应门禁和运行时未验证边界；row-action 输出也消除了 RED 的“加载下一段”，改为只有上一页/下一页的游标分页。

严格逐项检查并非三份全通过。展示型输出对 disposal/实例隔离展开不足；row-action 与 bulk-action 对筛选 owner 的硬规则覆盖不完整；三份都没有完整复述列显示/固定/键盘调宽契约；另有少量 owner 未定义的局部枚举或策略。它们是本轮要求先记录的真实应用失败，不是 owner 缺口。

## RED → GREEN

| 场景 | RED 的主要问题 | GREEN 的收敛 | 尚存应用失败 |
| --- | --- | --- | --- |
| 只读展示型报表 | 没有共享档位和生命周期门禁，规则来自场景局部推导 | 显式 `display`；没有选择/批量结构；查询快照、稳定排序、页码边界、筛选草稿/应用/默认重置、首次/刷新失败、Table、卡片等价、焦点和公告均与 owner 对齐 | 没有说明 `resolvedTier`；disposal 只写失效请求/公告/焦点，遗漏幂等释放、资源注销、返回恢复与两实例隔离；列显示/固定/调宽规则未覆盖；使用 owner 未枚举的 `responsivePresentation: table-card` 字面值 |
| 单行操作管理列表 | 使用“加载下一段”与 `appending`，直接违反只支持前后游标分页的范围 | 显式 `row-action`/`cursor`；只提供上一页/下一页；无选择；含查询五项门禁、同键刷新合并、权限降级、操作六项门禁、完整 disposal、焦点/ARIA/公告及运行时边界 | 未定义 `filterDraft`、`applyMode`、`defaultFilters`、已应用条件摘要和 URL 安全；列显示/键盘调宽规则未覆盖；两实例隔离只列为待验证；新增 owner 未定义的菜单 phase、`stalePolicy` 和 `responsivePresentation: card` 局部枚举 |
| 批量操作数据表格 | 选择与操作只靠场景内 `queryKey/queryToken`，没有共享档位、查询/选择/操作快照和完整裁决门禁 | 显式 `bulk-action`；当前页三态、全部筛选结果、排除项、选择失效/重确认、不可变操作快照、重复提交、完整裁决、unknown/五类终态、失败项重试、响应式等价和 disposal 均显著收敛 | 实例没有选定 `numbered` 或 `cursor` 分页模式；筛选只覆盖 draft/applied 分离，遗漏 applyMode、默认重置、持续可见条件和 URL 安全；稳定排序遗漏空值/大小写/区域规则；列隐藏/键盘调宽未覆盖；两实例隔离未形成正向契约；“资格或总数变化时创建新选择快照”不是 owner 声明的转换 |

## Task 5 硬规则矩阵

`通过` 表示场景所需能力完整对齐；`不适用` 只用于能力档位明确禁止的结构；`部分` 或 `失败` 均已在上表记录，不能被三份输出的其他优点抵消。

| 核对项 | 展示型 | 单行操作 | 批量操作 | 依据与判断 |
| --- | --- | --- | --- | --- |
| 能力档位与选择能力显式启用 | 部分 | 通过 | 通过 | 三者声明 `display/row-action/bulk-action`；展示型没有写权限解析后的 `resolvedTier`。 |
| 查询快照、代次与迟到响应 | 通过 | 通过 | 通过 | 三者都建立不可变快照/代次并使用 live、owner、token、generation、snapshot 门禁；取消不替代门禁。 |
| 筛选草稿、已应用条件与默认重置 | 通过 | 失败 | 部分 | 展示型覆盖完整；row-action 未建立草稿/应用模型；bulk-action 未覆盖 applyMode、默认值和 URL/摘要全部规则。 |
| 稳定排序与分页重置 | 通过 | 通过 | 部分 | bulk-action 只有唯一稳定键，遗漏 owner 要求的空值、大小写和区域/自然排序规则。 |
| 页码/游标边界、首次失败、刷新失败、过期与零结果 | 通过 | 通过 | 部分 | display/row 各自完整选择分页模式；bulk 未为实例选择唯一分页模式，虽覆盖两类失效恢复和数据状态。 |
| 当前页三态与全部筛选结果范围 | 不适用且正确禁止 | 不适用且正确禁止 | 通过 | bulk 覆盖三态、零可选、二次提升、完整快照、排除项、数量和选择代次。 |
| 操作快照、重复提交、部分成功与恢复 | 不适用 | 通过 | 通过 | row/bulk 均使用六项门禁和幂等；bulk 另覆盖完整裁决、unknown、五类业务终态及失败重试。 |
| 原生 Table/Grid 选择与键盘 | 通过 | 通过 | 通过 | 三者优先原生 Table；bulk 明确只有二维需求才用 Grid，并列出完整键盘模型。 |
| 列隐藏/固定/宽度、响应式等价与横向滚动 | 部分 | 部分 | 部分 | 三者覆盖响应式/横向滚动/固定遮挡的相关子集，但没有任何一份覆盖 owner 的完整隐藏依赖和键盘调宽契约。 |
| disposal、实例隔离、焦点、ARIA、公告与运行时边界 | 部分 | 部分 | 部分 | 焦点/ARIA/公告/未验证边界三者均强；展示型 disposal 不完整，row/bulk 未把同页两 live 实例隔离写成正向契约。 |

## owner 未定义内容的处理

先记录而不吸收以下内容：

- 展示型的 `responsivePresentation: table-card`，以及 row-action 的 `responsivePresentation: card`：owner 要求显式配置和完整字段映射，但没有定义这两个枚举字面值。
- row-action 的 `closed/opening/open/closing/disposed` 菜单 phase、`permissionRevision` 与 `stalePolicy: server-revalidate | block`：它们是代理选择的局部实现模型，不是现有四组表格状态或已声明转换。
- bulk-action 在同范围资格/总数变化时“创建新的选择快照”：owner 当前只声明移除失效 ID、更新数量并公告，不允许由代理自行提升为新的规范转换。

这些新增内容没有暴露 Task 5 目标中的真实 normative gap：相关硬要求已经分别由 `DT-CAP-*`、`DT-REQ-*`、`DT-FIL-*`、`DT-SORT-*`、`DT-PAG-*`、`DT-DATA-*`、`DT-SEL-*`、`DT-OP-*`、`DT-COL-*`、`DT-SEM-*`、`DT-FOC-*`、`DT-RSP-*`、`DT-A11Y-*`、`DT-LIFE-*` 和 `DT-REPORT-01` 定义，并有 `A01`–`A36` 验收。遗漏项都能直接指向已有 owner 规则；新增项则是具体产品/实现选择，不能仅因一次代理输出就成为共享硬规则。因此本轮没有修改 `references/data-tables.md`、`SKILL.md`、`README.md` 或 `HANDOFF.md`，也不新增验收。

## 证据与验证边界

- 三份完整 prompt、原始输出、canonical identity、派发参数、DONE receipt 和可复算 SHA-256 见 [展示型](green-display-report.md)、[单行操作](green-row-action-list.md)、[批量操作](green-bulk-action-table.md)及[派发回执](dispatch-receipts.md)。
- GREEN 代理执行的是静态设计应用，不是浏览器或组件运行时测试。三份输出都明确把浏览器、屏幕阅读器、键盘、触摸、缩放、真实数据竞态、真实后端能力与 disposal 资源计数列为未验证。
- 本轮仓库验证结果记录于 Task 5 报告；不能把相对链接、Markdown、占位符或 diff 检查写成上述运行时行为已通过。
