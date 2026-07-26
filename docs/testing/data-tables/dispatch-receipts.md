# Attempt 6 最终 GREEN 派发与完整性回执

状态：`PASS_WITH_RUNTIME_UNVERIFIED`

## 调度事实

- 三次最终测试都使用新的 `fork_turns="none"` 代理；实际 spawn 参数仅为 `task_name`、`fork_turns` 与证据文件 RAW PROMPT 中逐字保存的 `message`，`model`、`reasoning_effort` 均未发送。
- display 与 row-action 先并行；row-action 完成释放槽位后，再派发 bulk-action。
- canonical identity 分别为 `/root/table_task5_green/attempt_6_display_report`、`/root/table_task5_green/attempt_6_row_action_list`、`/root/table_task5_green/attempt_6_bulk_action_table`。
- 三份原始 completion envelope 均为 Message Type `FINAL_ANSWER`，recipient Task name 为 `/root/table_task5_green`，Sender 为各自 canonical identity。
- 完成后的证据物化是独立跟进动作，不改变已经冻结的 completion payload。每份证据保存实际参数、精确 spawn tool return、completion envelope metadata 与完整 RAW PROMPT / RAW OUTPUT；没有添加工具未返回的 opaque ID 或时间。

## RAW SHA-256

| 场景 | Prompt SHA-256 | Output SHA-256 | UTF-8 output bytes | 证据 |
| --- | --- | --- | ---: | --- |
| 只读展示型报表 | `81fe54674d9037f72e01b9290235005a72cb88228c5ed2bc03c8b177597928d7` | `a100eb090319951cce5319ee5587255c32d63c2ec58d277215d44a76aecc6da7` | 20424 | [green-display-report.md](green-display-report.md) |
| 单行操作管理列表 | `111068c5e27c3cb8a555eabfe0be3ed97056441f9be9c860589bdcb1f869ed6e` | `2ae286c09cb9542fdbb2dd2ea9efba3489d22452bec267ef8bc3c25d6c85266b` | 21815 | [green-row-action-list.md](green-row-action-list.md) |
| 批量操作数据表格 | `32de51627ece3f0b85b5ce45944b54d373ddfde720db6d85a29d9a074f3ce0ab` | `96bdb8f975b5999ef2e99934469de70addf54bc6c170f3e3f5ea7ae6add1687f` | 22558 | [green-bulk-action-table.md](green-bulk-action-table.md) |

归一化协议：验证 UTF-8，把 CRLF/CR 归一化为 LF，每种标记必须恰有一对；捕获 `BEGIN` 与 `END` 标记之间的内容，不 trim、不补尾换行，直接计算 UTF-8 字节 SHA-256。

复算命令：

```sh
ruby -rdigest -e 'ARGV.each{|p| s=File.binread(p).force_encoding("UTF-8"); abort("invalid UTF-8: #{p}") unless s.valid_encoding?; s=s.gsub("\r\n","\n").gsub("\r","\n"); ["PROMPT","OUTPUT"].each{|kind| ms=s.scan(/<!-- BEGIN RAW #{kind} -->\n(.*?)\n<!-- END RAW #{kind} -->/m); abort("#{p} #{kind} count=#{ms.size}") unless ms.size==1; v=ms[0][0]; puts "#{File.basename(p)} #{kind.downcase}=#{Digest::SHA256.hexdigest(v.b)} bytes=#{v.bytesize}"}}' docs/testing/data-tables/green-display-report.md docs/testing/data-tables/green-row-action-list.md docs/testing/data-tables/green-bulk-action-table.md
```

## Tracked 字段与 mutation 证据

| 证据 | SHA-256 | 结论 |
| --- | --- | --- |
| [attempt-6-application-audit.rb](attempt-6-application-audit.rb) | `bfa671bf6e07cc25bd9902a6c3bb3a0d849d9109b449e893f583c80ad7aa5a83` | 可复跑字段、原子清单与 mutation 门禁 |
| [attempt-6-field-audit.md](attempt-6-field-audit.md) | `33e963ced5e0a299fc63c607132bd495d39635c41196f2f928c4514dc5b33886` | 三场景各 64 条，共 192 条 `outputLocation` 记录 |
| [attempt-6-mutation-receipt.md](attempt-6-mutation-receipt.md) | `003d8b18ec9af16e76e48e96a8e543608a7c4ba57127c72fc12bbf9507d104d7` | 基线 3/3 通过，19/19 mutation 预期失败 |

字段/规则族结论见 [green-summary.md](green-summary.md)。Attempt 1–5 的失败证据保持独立、未覆写；Attempt 5 的纠正见 [attempt-5-summary.md](attempt-5-summary.md)。
