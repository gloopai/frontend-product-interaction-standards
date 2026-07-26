# Attempt 5 FAILED 派发与完整性回执（原始证据）

状态：`FAILED_BINARY_APPLICABILITY_AUDIT`

> 本回执保留 Attempt 5 的实际派发事实与原始哈希；后续原子清单审计发现三行“部分适用”，推翻了当时的 GREEN 判定。RAW PROMPT / RAW OUTPUT 字节未改。

## 调度事实

- 三次最终测试都使用新的 `fork_turns="none"` 代理；实际 spawn 参数仅为 `task_name`、`fork_turns` 与证据文件 RAW PROMPT 中逐字保存的 `message`，`model`、`reasoning_effort` 均未发送。
- display 与 row-action 先并行；display 完成后释放槽位，再派发 bulk-action。
- canonical identity 分别为 `/root/table_task5_green/attempt_5_display_report`、`/root/table_task5_green/attempt_5_row_action_list`、`/root/table_task5_green/attempt_5_bulk_action_table`。
- 三份原始 completion envelope 均为 Message Type `FINAL_ANSWER`，recipient Task name 为 `/root/table_task5_green`，Sender 为各自 canonical identity。
- 完成后的证据物化是独立跟进动作，不改变已经冻结的 completion payload。每份证据都保存实际参数、精确 spawn tool return、completion envelope metadata 与完整 RAW PROMPT / RAW OUTPUT；没有添加工具未返回的 opaque ID 或时间。

## SHA-256

| 场景 | Prompt SHA-256 | Output SHA-256 | UTF-8 output bytes | 证据 |
| --- | --- | --- | ---: | --- |
| 只读展示型报表 | `81fe54674d9037f72e01b9290235005a72cb88228c5ed2bc03c8b177597928d7` | `51b1105ac7c8cabae9bb25d8282442a12189be6162e426489463fb26d8a81e91` | 18856 | [attempt-5-display-report.md](attempt-5-display-report.md) |
| 单行操作管理列表 | `111068c5e27c3cb8a555eabfe0be3ed97056441f9be9c860589bdcb1f869ed6e` | `dd7717d2e0b21b49c8ba34feb2c80e6185dd918e5538313a3f24622f344f0d76` | 25092 | [attempt-5-row-action-list.md](attempt-5-row-action-list.md) |
| 批量操作数据表格 | `32de51627ece3f0b85b5ce45944b54d373ddfde720db6d85a29d9a074f3ce0ab` | `208cbe5bbae2d2d82059f31427a6d869c10e5b55565c7024d1ef923745b1043b` | 27814 | [attempt-5-bulk-action-table.md](attempt-5-bulk-action-table.md) |

## 归一化与边界协议

1. 以二进制读取文件并验证 UTF-8。
2. 把 `CRLF` 与孤立 `CR` 归一化为 `LF`。
3. 每种内容必须恰有一对标记；捕获 `<!-- BEGIN RAW KIND -->\n` 与 `\n<!-- END RAW KIND -->` 之间的非贪婪内容，排除边界各一个 delimiter LF。
4. 不 trim、不补尾换行，直接对捕获内容的 UTF-8 字节计算 SHA-256。

复算命令：

```sh
ruby -rdigest -e 'ARGV.each{|p| s=File.binread(p).force_encoding("UTF-8"); abort("invalid UTF-8: #{p}") unless s.valid_encoding?; s=s.gsub("\r\n","\n").gsub("\r","\n"); ["PROMPT","OUTPUT"].each{|kind| ms=s.scan(/<!-- BEGIN RAW #{kind} -->\n(.*?)\n<!-- END RAW #{kind} -->/m); abort("#{p} #{kind} count=#{ms.size}") unless ms.size==1; v=ms[0][0]; puts "#{File.basename(p)} #{kind.downcase}=#{Digest::SHA256.hexdigest(v.b)} bytes=#{v.bytesize}"}}' docs/testing/data-tables/attempt-5-display-report.md docs/testing/data-tables/attempt-5-row-action-list.md docs/testing/data-tables/attempt-5-bulk-action-table.md
```

失败审计见 [attempt-5-summary.md](attempt-5-summary.md) 与 [attempt-5-red-diagnosis.md](attempt-5-red-diagnosis.md)。Attempt 1–4 失败证据保持独立、未覆写。
