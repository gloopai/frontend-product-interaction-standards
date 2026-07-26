# 数据表格最终 GREEN 派发与完整性回执

## 调度事实

- 最终三次测试使用全新 `fork_turns="none"` 代理；实际 spawn 参数均恰为 `task_name`、`fork_turns` 与证据文件 RAW PROMPT 中逐字保存的 `message`。`model`、`reasoning_effort` 没有发送。
- display 与 row-action 先并行；display 完成释放槽位后派发 bulk。没有失败的最终 spawn 调用。
- 工具返回的 canonical identity 分别为 `/root/table_task5_green/attempt_4_display_report`、`/root/table_task5_green/attempt_4_row_action_list`、`/root/table_task5_green/attempt_4_bulk_action_table`。
- 原始完成 envelope 均为 Message Type `FINAL_ANSWER`，recipient Task name 均为 `/root/table_task5_green`，Sender 分别为上述 canonical identity。
- 每份证据保存实际参数、原始 spawn tool return、completion envelope metadata 和冻结 payload。没有添加工具未返回的 opaque ID 或时间。
- 完成后的证据物化是独立跟进动作，不改变已冻结的测试 payload。

## SHA-256

| 场景 | Prompt SHA-256 | Output SHA-256 | 证据 |
| --- | --- | --- | --- |
| 只读展示型报表 | `81fe54674d9037f72e01b9290235005a72cb88228c5ed2bc03c8b177597928d7` | `3041f6c4d360b027ca315aea2d6ac999780251b068fddc2403bd779edc4ee39e` | [green-display-report.md](green-display-report.md) |
| 单行操作管理列表 | `111068c5e27c3cb8a555eabfe0be3ed97056441f9be9c860589bdcb1f869ed6e` | `4209ee2ed899f12df7d584e60b7c0c99dbb6b6f574c4dbc722a4bde6eaa281ef` | [green-row-action-list.md](green-row-action-list.md) |
| 批量操作数据表格 | `32de51627ece3f0b85b5ce45944b54d373ddfde720db6d85a29d9a074f3ce0ab` | `74d20633fe23fd893e45588de31379939c27d7c6552bbf8add23a81c6d8db97f` | [green-bulk-action-table.md](green-bulk-action-table.md) |

## 归一化与边界协议

1. 以二进制读取文件并验证为 UTF-8。
2. 将 `CRLF` 和孤立 `CR` 归一化为 `LF`。
3. 每种内容必须恰有一对标记。捕获 `<!-- BEGIN RAW KIND -->\n` 与 `\n<!-- END RAW KIND -->` 之间的非贪婪内容；排除边界各一个 delimiter LF。
4. 不 trim、不补尾换行，直接对捕获内容的 UTF-8 字节计算 SHA-256。

复算命令：

```sh
ruby -rdigest -e 'ARGV.each{|p| s=File.binread(p).force_encoding("UTF-8"); abort("invalid UTF-8: #{p}") unless s.valid_encoding?; s=s.gsub("\r\n","\n").gsub("\r","\n"); ["PROMPT","OUTPUT"].each{|kind| ms=s.scan(/<!-- BEGIN RAW #{kind} -->\n(.*?)\n<!-- END RAW #{kind} -->/m); abort("#{p} #{kind} count=#{ms.size}") unless ms.size==1; v=ms[0][0]; puts "#{File.basename(p)} #{kind.downcase}=#{Digest::SHA256.hexdigest(v.b)} bytes=#{v.bytesize}"}}' docs/testing/data-tables/green-display-report.md docs/testing/data-tables/green-row-action-list.md docs/testing/data-tables/green-bulk-action-table.md
```

内容审计见 [green-summary.md](green-summary.md)。失败的 Attempt 1–3 证据保持独立、未覆写。
