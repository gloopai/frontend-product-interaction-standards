# Attempt 10 前置 RED：结构化选择代次事件契约

自由文本无法可靠表达“谁在何时写入 selectionGeneration”。Attempt 10 改以唯一固定表解析 actor/path、event、generationWrite、顺序、异步启动顺序、相对时序、快照效果、提交门禁和失配效果。

修复前运行：

```sh
ruby docs/testing/data-tables/attempt-10-selection-event-audit.rb
```

预期 owner 与 Attempt 9 都因缺少唯一结构化事件表而失败。

独立复核后追加九个 RED：intent/eligibility 原地修改快照、callback/operation 错误快照效果、callback guard 仅记录不比较、guard 多垃圾字段、callback/operation mismatch 追加 `selectionWrite=1`、以及结构化表额外第五行。收紧审计前九项均 `unexpectedly passed`；默认命令还因读取 Attempt 9 而返回 `EVIDENCE ... count=0`。这些失败确认解析器此前只覆盖了部分字段和 required key 的存在性。
