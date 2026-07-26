# Attempt 4 FAILED 汇总

状态：`FAILED_STATIC_APPLICATION_AUDIT`

三份样本来自 owner 当时版本后的全新 `fork_turns=none` 代理。后续字段级审计发现，先前的 GREEN 结论把规则族层面的描述误当成了字段级完成；本文件已更正为失败，原始派发参数、canonical identity、completion payload 与哈希保留在 Attempt 4 证据中。

## 独立规则族矩阵

| 规则族 / 可观察维度 | 展示型 | 单行操作 | 批量操作 | 证据与判断 |
| --- | --- | --- | --- | --- |
| 能力、`resolvedTier` 与状态 owner | 通过 | 失败 | 失败 | row 用 `lifecycleState` 取代缺失的 `viewState`；bulk 未声明 `interactionState`，且“全部筛选结果”只有条件描述，没有 `enableAllFilteredSelection` 当前值，也没有独立批量操作当前开关。 |
| 查询快照、代次、意图合并与迟到门禁 | 通过 | 通过 | 通过 | display §6、row §3、bulk §2/§3；均为不可变快照与 live/owner/token/generation/snapshot 门禁，取消不替代门禁。 |
| 筛选 | 通过 | 合理不适用 | 通过 | display §3、bulk §1/§3 覆盖 draft/applied、显式提交、实际 default、回第 1 页、摘要/移除、URL 安全和字段错误 owner；row §1/§12 证明无 DOM、草稿、handler 或请求入口。 |
| 排序 | 通过 | 通过 | 通过 | display §4、row §1/§3、bulk §1/§3 均给出当前业务键/方向、空值、大小写/locale/自然排序的实际值或字段不适用依据、唯一稳定键及回起点转换；交互场景另有按钮、ARIA、键盘和焦点。 |
| 分页 | 通过 | 通过 | 通过 | display §5 与 bulk §1/§3 为 numbered：可靠总数、范围/当前/总页、直接页码、具标签校验跳页、原生边界禁用、页大小、回第 1 页与单次恢复；row §3 为 cursor：不透明双向游标、缺失方向禁用、禁止虚构页码/跳页/加载更多/无限滚动、回初始游标与单次恢复。 |
| 数据加载、刷新、过期、错误与空状态 | 通过 | 通过 | 通过 | display §6/§7、row §4、bulk §4 区分首次与刷新，保留旧结果，分离筛选无匹配/数据源空与错误 owner。 |
| 当前页三态与全部筛选结果 | 合理不适用 | 合理不适用 | 通过 | display/row 明确零选择入口。bulk §5 把初始空 `excludedIds` 放在 `selectionSnapshot` 内，禁止布尔替代；排除变化创建后继、旧快照不变；同范围普通翻页保持同一快照身份。`selectionState` 没有可独立漂移的 sibling `excludedIds`。 |
| 操作快照、重复提交、完整裁决与恢复 | 合理不适用 | 通过 | 通过 | display 无操作；row §6 覆盖单行快照、幂等、六项门禁与冲突；bulk §6 覆盖确认、幂等、身份集合裁决、五类终态、unknown、部分成功和只重试可重试失败项。 |
| 原生 Table / ARIA Grid 与键盘 | 通过 | 通过 | 通过 | 三者选择原生 Table 且不接管 Grid 键；Grid 因无二维单元格导航而不适用，静态单元格不进入 Tab。 |
| 列能力与长内容 | 通过 | 失败 | 失败 | row 缺失整组 `viewState`；bulk 的 `viewState` 缺少 owner 要求的 `visibleColumnIds`、`pinnedColumnIds`、`columnWidths`、`density`。能力不适用不允许省略固定状态组及其 absence contract。 |
| 焦点 | 通过 | 通过 | 通过 | display §8、row §8、bulk §7：稳定 record/column/control ID，目标存活不移动，消失单次等价迁移，翻页恢复不二次抢焦点，不落 body/root/removed/另一实例。 |
| 响应式与极端视口 | 通过 | 通过 | 通过 | display §10、row §10、bulk §8 保持同 owner、同能力、单活动数据根、零额外请求；覆盖受控横向滚动/等价卡片、200% 缩放、长文本、触摸、虚拟键盘和安全区域。 |
| ARIA、错误与公告 owner | 通过 | 通过 | 通过 | display §9、row §9、bulk §7：名称/header 关联、busy/stale/三态、错误单 owner、已接受反馈一次、merged/discarded/disposed 静默。 |
| disposal 与多实例隔离 | 通过 | 失败 | 失败 | disposal 正文存在，但 row/bulk 把 lifecycle 当成第五/第四组状态；生命周期应是独立 owner guard，不能替代固定四组之一。 |
| 局部产品/实现决定 | 通过 | 通过 | 通过 | 实际字段、断点、排序比较、菜单阶段、确认形态均被标为本实例配置/实现，并未替代或放宽 owner。局部响应式值没有双实例、能力丢失、额外请求或焦点冲突。 |
| 运行时验证边界 | 适用、未验证 | 适用、未验证 | 失败 | bulk 正文列出未验证环境，但应用检查清单没有独立“运行时验证边界”判定行，不能用清单外章节替代。 |

## 结论

- display：本轮未发现上述新增字段级缺口，但整组三场景按全有或全无门禁处理，不能单独使 Attempt 4 通过。
- row-action：失败；缺 `viewState`，且 lifecycle 被当作状态组而不是独立 guard。
- bulk-action：失败；缺当前能力值、缺 `interactionState`、`viewState` 列字段不完整、生命周期角色错误，清单缺独立运行时验证边界行。
- Attempt 4 总结论：`FAILED`；不得作为最终样本或 GREEN 证据。

完整缺口与 RED 命令见 [attempt-4-red-diagnosis.md](attempt-4-red-diagnosis.md)。真实浏览器、辅助技术、键盘/触摸、200% 缩放、组件竞态、后端分页/幂等/裁决和逐资源 disposal 仍为未验证。
