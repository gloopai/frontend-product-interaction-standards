# Attempt 8 最终静态应用审计

状态：`BLOCKED_APPLICATION_FAIL`

Attempt 8 是 Task 5 的第 5/5 最终修复轮。三个全新 `fork_turns=none` 代理使用与 Attempts 1–7 字节相同的用户式 prompt，没有收到诊断、答案或期望字段。三份原始输出、spawn return、completion metadata 与 SHA-256 均完整保存。

## RED 与 owner 修复

- RED 保留 Attempt 7 bulk 的原始 19 项缺口，并证明旧三份输出都没有固定八列清单、操作子槽和原子义务表头。
- owner 新增 `DT-REPORT-06.a–e` / `A40`：固定八列二十行清单；固定 row/bulk 操作子槽；固定六列筛选、排序与当前分页模式原子义务；具体当前值/精确四类零值；表头、行、字段移位和粗粒度引用熔断。
- A37–A39 的事件与日志同步使用固定槽，A22 覆盖到 A40。自由文本仍可解释实现，但不能抵消任一缺槽。

## Attempt 8 严格结论

| 门禁 | 记录 | 错误 | 结果 |
| --- | ---: | ---: | --- |
| A39 当前值、固定状态组、lifecycle、选择代次 | 135 | 1 | FAIL（bulk） |
| A40 固定清单、操作子槽、原子义务 | 144 | 0 | PASS |
| Mutation M23–M50 + A40 cardinality | 31 expected failures | 0 unexpected pass | PASS（不能抵消失败基线） |
| 派发、completion、UTF-8、RAW 标记、SHA-256 | 3 scenarios | 0 | PASS |

Attempt 7 bulk 的 row absence、ARIA Grid request 零值、五个筛选、四个排序和八个 numbered 分页缺口全部具有独立固定槽；三份场景的所有适用槽有具体当前值/转换/语义与位置，不适用槽使用精确 `DOM=0;state=0;handler/event=0;request=0`。

但 bulk 的“异步选择协调回调”把 `selectionGeneration` 写成“只有接受结果后按对应选择意图递增”。owner 要求在选择意图接受时先恰好加一，再启动异步协调，使旧回调立即失配；推迟到结果接受后留下旧回调可提交窗口。正确的四项 commit guard 与失配写入 0 不能抵消 generationEffect 的错误。

历史 Attempt 6/7 审计器未修改；它不理解 A40 新表导致的同名首列，也把 owner 未要求的 Markdown 形态当作条件，因此其 Attempt 8 结果只作兼容性诊断，不作最终裁决。兼容审计的放宽仅限展示形态，六个针对当前值、状态最少字段、lifecycle 和选择关系的 mutation 均被拒绝。

## 最终边界

这是最终允许的第 5/5 轮；RAW 输出不得改写，且不允许 Attempt 9。因此依熔断规则停止为 `BLOCKED_APPLICATION_FAIL`。真实浏览器、辅助技术、键盘/触摸、200% 缩放、真实组件乱序竞态、后端总数/游标/幂等/完整裁决和逐资源 disposal 同样未执行。没有创建 Attempt 9。
