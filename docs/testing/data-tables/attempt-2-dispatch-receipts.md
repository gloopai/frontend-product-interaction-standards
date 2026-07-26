# 数据表格 Attempt 2 FAILED 派发与完整性回执

## 调度事实

- 三次成功调用的实际参数只有 `task_name`、`fork_turns` 和 `message`；均为 `fork_turns="none"`。`model` 与 `reasoning_effort` 没有发送。
- display 与 row-action 先并行派发；row-action 完成并释放槽位后派发 bulk。没有失败的 spawn 调用。
- 工具返回的 canonical identity 依次为 `/root/table_task5_green/attempt_2_display_report`、`/root/table_task5_green/attempt_2_row_action_list`、`/root/table_task5_green/attempt_2_bulk_action_table`。
- 三次完成 envelope 的 Message Type 均为 `FINAL_ANSWER`，recipient Task name 均为 `/root/table_task5_green`，Sender 分别等于上述 canonical identity。实际 spawn JSON、原始工具返回、envelope 字段及原始 payload 逐份保存在证据文件；没有添加工具未返回的 opaque ID 或时间。

## 内容摘要

| 场景 | Prompt SHA-256 | Output SHA-256 | 证据 |
| --- | --- | --- | --- |
| 只读展示型报表 | `81fe54674d9037f72e01b9290235005a72cb88228c5ed2bc03c8b177597928d7` | `1c63e9c7ececcafb49a0cadf2ebe91a085235b5e5b21d11281ca1bad116ce604` | [attempt-2-display-report.md](attempt-2-display-report.md) |
| 单行操作管理列表 | `111068c5e27c3cb8a555eabfe0be3ed97056441f9be9c860589bdcb1f869ed6e` | `11d3948faa3986432f4652f6efeb4131f26bccbb8715f1363961b6fdcaa516a8` | [attempt-2-row-action-list.md](attempt-2-row-action-list.md) |
| 批量操作数据表格 | `32de51627ece3f0b85b5ce45944b54d373ddfde720db6d85a29d9a074f3ce0ab` | `9a1090bd8823c4b3a064e4ba8bfef37d1a4155fd0b59fb964a302b0b5473bcd6` | [attempt-2-bulk-action-table.md](attempt-2-bulk-action-table.md) |

## SHA-256 协议

1. 以二进制读取证据文件，按 UTF-8 验证。
2. 把 `CRLF` 和孤立 `CR` 归一化为 `LF`。
3. 使用非贪婪正则捕获 `<!-- BEGIN RAW PROMPT -->\n` 与 `\n<!-- END RAW PROMPT -->` 之间，或相应 OUTPUT 标记之间的字节；边界各排除恰好一个 delimiter LF。
4. 不 trim、不补换行，直接对捕获内容的 UTF-8 字节计算 SHA-256。

从仓库根可重复执行：

```sh
ruby -rdigest -e 'ARGV.each{|p| s=File.binread(p).force_encoding("UTF-8"); abort("invalid UTF-8: #{p}") unless s.valid_encoding?; s=s.gsub("\r\n","\n").gsub("\r","\n"); ["PROMPT","OUTPUT"].each{|kind| m=s.match(/<!-- BEGIN RAW #{kind} -->\n(.*?)\n<!-- END RAW #{kind} -->/m) or abort("missing #{kind}: #{p}"); puts "#{File.basename(p)} #{kind.downcase}=#{Digest::SHA256.hexdigest(m[1].b)} bytes=#{m[1].bytesize}"}}' docs/testing/data-tables/attempt-2-display-report.md docs/testing/data-tables/attempt-2-row-action-list.md docs/testing/data-tables/attempt-2-bulk-action-table.md
```

Attempt 2 的完整性审计通过；内容适用性审计失败，见 [attempt-2-summary.md](attempt-2-summary.md)。
