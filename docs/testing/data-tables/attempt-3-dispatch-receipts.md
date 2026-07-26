# 数据表格 Attempt 3 FAILED 派发与完整性回执

- 三次成功 spawn 的实际参数均只有 `task_name`、`fork_turns="none"` 和各证据文件 RAW PROMPT 中的 `message`；`model`、`reasoning_effort` 未发送。
- canonical identity 分别为 `/root/table_task5_green/attempt_3_display_report`、`/root/table_task5_green/attempt_3_row_action_list`、`/root/table_task5_green/attempt_3_bulk_action_table`。
- 完成 envelope 均为 `FINAL_ANSWER`，recipient 为 `/root/table_task5_green`，Sender 为相应 canonical identity。逐份证据保存实际参数、原始工具返回、envelope metadata 和冻结 payload；没有 opaque ID 或时间。

| 场景 | Prompt SHA-256 | Output SHA-256 | 证据 |
| --- | --- | --- | --- |
| display | `81fe54674d9037f72e01b9290235005a72cb88228c5ed2bc03c8b177597928d7` | `4e97e5687a926ecb631d76e1da3a1a451f20a77b619e179af343dc15a175829e` | [attempt-3-display-report.md](attempt-3-display-report.md) |
| row-action | `111068c5e27c3cb8a555eabfe0be3ed97056441f9be9c860589bdcb1f869ed6e` | `3e91d9891a490532f914b5d6c56e6f019dc1dd8aaf13be87dd7db2f732a6dbc9` | [attempt-3-row-action-list.md](attempt-3-row-action-list.md) |
| bulk-action | `32de51627ece3f0b85b5ce45944b54d373ddfde720db6d85a29d9a074f3ce0ab` | `32792095e1c871e5e31abd953fb8b444caa32ad0c4f292b90c21545012dfd454` | [attempt-3-bulk-action-table.md](attempt-3-bulk-action-table.md) |

SHA 协议与 [Attempt 2 回执](attempt-2-dispatch-receipts.md) 相同：UTF-8；CRLF/CR 归一为 LF；捕获标记之间内容并排除各一个 delimiter LF；不 trim。复算命令：

```sh
ruby -rdigest -e 'ARGV.each{|p| s=File.binread(p).force_encoding("UTF-8"); abort("invalid UTF-8: #{p}") unless s.valid_encoding?; s=s.gsub("\r\n","\n").gsub("\r","\n"); ["PROMPT","OUTPUT"].each{|kind| m=s.match(/<!-- BEGIN RAW #{kind} -->\n(.*?)\n<!-- END RAW #{kind} -->/m) or abort("missing #{kind}: #{p}"); puts "#{File.basename(p)} #{kind.downcase}=#{Digest::SHA256.hexdigest(m[1].b)} bytes=#{m[1].bytesize}"}}' docs/testing/data-tables/attempt-3-display-report.md docs/testing/data-tables/attempt-3-row-action-list.md docs/testing/data-tables/attempt-3-bulk-action-table.md
```

内容判定见 [attempt-3-summary.md](attempt-3-summary.md)。
