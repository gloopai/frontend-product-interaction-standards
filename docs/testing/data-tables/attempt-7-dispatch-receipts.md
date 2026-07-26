# Attempt 7 派发、completion 与完整性回执

状态：`PROVENANCE_PASS_APPLICATION_FAIL`

## 调度事实

- 三个测试均使用全新的 `fork_turns="none"` 代理；实际 spawn 参数只包含下表的 `task_name`、`fork_turns` 和各证据文件逐字保存的用户式 `message`，没有发送 `model` 或 `reasoning_effort`。
- display 与 row-action 先并行；row-action 完成并释放并发槽后才派发 bulk-action。
- completion 后只用独立 follow-up 把已经冻结的 payload 逐字物化到 tracked 文件；follow-up 没有改写原 completion 内容。
- 每个证据文件都恰有一对 RAW PROMPT / RAW OUTPUT 标记，并保存精确 spawn tool return 与 completion envelope metadata。

| 场景 | spawn `task_name` | canonical identity / 精确 spawn return | completion envelope |
| --- | --- | --- | --- |
| display | `attempt_7_display_report` | `/root/table_task5_takeover/attempt_7_display_report`；`{"task_name":"/root/table_task5_takeover/attempt_7_display_report"}` | Message Type `FINAL_ANSWER`；recipient `/root/table_task5_takeover`；sender 为该 canonical identity |
| row-action | `attempt_7_row_action_list` | `/root/table_task5_takeover/attempt_7_row_action_list`；`{"task_name":"/root/table_task5_takeover/attempt_7_row_action_list"}` | Message Type `FINAL_ANSWER`；recipient `/root/table_task5_takeover`；sender 为该 canonical identity |
| bulk-action | `attempt_7_bulk_action_table` | `/root/table_task5_takeover/attempt_7_bulk_action_table`；`{"task_name":"/root/table_task5_takeover/attempt_7_bulk_action_table"}` | Message Type `FINAL_ANSWER`；recipient `/root/table_task5_takeover`；sender 为该 canonical identity |

## RAW SHA-256

| 场景 | Prompt SHA-256 | Prompt bytes | Output SHA-256 | Output bytes | 完整证据 |
| --- | --- | ---: | --- | ---: | --- |
| display | `81fe54674d9037f72e01b9290235005a72cb88228c5ed2bc03c8b177597928d7` | 748 | `e26491ebb2af32fbbbf6e60bad86862fe4209eca2a872d2c7ed8cc2f445a8ec3` | 23167 | [attempt-7-display-report.md](attempt-7-display-report.md) |
| row-action | `111068c5e27c3cb8a555eabfe0be3ed97056441f9be9c860589bdcb1f869ed6e` | 812 | `1360b48ce7db6fc461df0627e07a3f5329e9efc042aead74af31ecf9e8e0467b` | 18544 | [attempt-7-row-action-list.md](attempt-7-row-action-list.md) |
| bulk-action | `32de51627ece3f0b85b5ce45944b54d373ddfde720db6d85a29d9a074f3ce0ab` | 861 | `351ac2d2d866fcd292ab1617f1882ce922d6147841f217ed8249b316480ab6d9` | 21811 | [attempt-7-bulk-action-table.md](attempt-7-bulk-action-table.md) |

三个 prompt hash 与 Attempts 1–6 相同；因此 Attempt 7 未夹带 DT-SEL-06 诊断、预期字段或期望答案。

归一化协议：先验证 UTF-8，把 CRLF/CR 归一化为 LF；每种 RAW 标记必须恰有一对；捕获标记间内容，不 trim、不补尾换行，直接计算 UTF-8 字节 SHA-256。

```sh
ruby -rdigest -e 'ARGV.each{|p| s=File.binread(p).force_encoding("UTF-8"); abort("invalid UTF-8: #{p}") unless s.valid_encoding?; s=s.gsub("\r\n","\n").gsub("\r","\n"); ["PROMPT","OUTPUT"].each{|kind| ms=s.scan(/<!-- BEGIN RAW #{kind} -->\n(.*?)\n<!-- END RAW #{kind} -->/m); abort("#{p} #{kind} count=#{ms.size}") unless ms.size==1; v=ms[0][0]; puts "#{File.basename(p)} #{kind.downcase}=#{Digest::SHA256.hexdigest(v.b)} bytes=#{v.bytesize}"}}' docs/testing/data-tables/attempt-7-display-report.md docs/testing/data-tables/attempt-7-row-action-list.md docs/testing/data-tables/attempt-7-bulk-action-table.md
```

派发与 payload 完整性通过不等于应用通过。严格应用裁决见 [attempt-7-summary.md](attempt-7-summary.md)。
