# 数据表格 Attempt 1 FAILED 派发回执

## 共同条件

- 三次成功派发均使用 `fork_turns=none`，没有继承 Task 5、RED 或其他代理上下文。
- 三次调用都省略 `model` 与 `reasoning_effort` 参数，因此记录为 `omitted (inherited runtime default)`；没有声称一个工具未返回的具体模型名或推理档位。
- 完整 prompt 与逐字输出保存在各自证据文件的 `BEGIN/END RAW` 标记之间；SHA-256 只计算标记内字节，不含标记或包装说明。
- 三名代理均被要求只返回用户式设计答复且不得修改文件；仓库检查没有发现代理写入。

## DONE receipts

| 场景 | canonical identity | model | reasoning effort | completion receipt | prompt SHA-256 | output SHA-256 | 证据 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 只读展示型报表 | `/root/table_task5_green/green_display_report` | omitted（runtime default） | omitted（runtime default） | `FINAL_ANSWER received; agent status completed` | `81fe54674d9037f72e01b9290235005a72cb88228c5ed2bc03c8b177597928d7` | `73cda675127237b38548a08c9164c539da0d51a3fdb02d89f08099cd9ce20591` | [attempt-1-display-report.md](attempt-1-display-report.md) |
| 单行操作管理列表 | `/root/table_task5_green/green_row_action_list` | omitted（runtime default） | omitted（runtime default） | `FINAL_ANSWER received; agent status completed` | `111068c5e27c3cb8a555eabfe0be3ed97056441f9be9c860589bdcb1f869ed6e` | `be471f8a2fda2b30bf3d1c19108d369b8b463d739cb8864fe15565d79721eaf8` | [attempt-1-row-action-list.md](attempt-1-row-action-list.md) |
| 批量操作数据表格 | `/root/table_task5_green/green_bulk_action_table` | omitted（runtime default） | omitted（runtime default） | `FINAL_ANSWER received; agent status completed` | `32de51627ece3f0b85b5ce45944b54d373ddfde720db6d85a29d9a074f3ce0ab` | `95924fe9c57312585928cd23e2827f74280d1011a8f69b84bcfbfdfb1370b4d9` | [attempt-1-bulk-action-table.md](attempt-1-bulk-action-table.md) |

## 调度说明

最初尝试与前两名代理同时派发批量场景时，线程树已达到并发上限，工具返回 `agent thread limit reached`，且没有创建代理。展示型代理完成并释放槽位后，重新以 `fork_turns=none` 成功创建 `/root/table_task5_green/green_bulk_action_table`。因此最终证据来自三名不同的成功新鲜代理；被拒绝的调用没有 identity、输出或完成回执，也不计入三份测试样本。
